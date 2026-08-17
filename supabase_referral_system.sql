-- SQL Migration: EZMoov Partner Referral Program Setup with Automated Database Triggers
-- Run this script in your Supabase SQL Editor

-- 0. CLEANUP EXISTING TRIGGERS & FUNCTIONS TO AVOID TYPE SIGNATURE MISMATCHES
DROP TRIGGER IF EXISTS trigger_on_driver_referral ON public.drivers;
DROP TRIGGER IF EXISTS trigger_on_driver_verification ON public.drivers;
DROP FUNCTION IF EXISTS process_new_driver_referral() CASCADE;
DROP FUNCTION IF EXISTS process_driver_verification_reward() CASCADE;
DROP FUNCTION IF EXISTS reward_referrer_on_verification(UUID) CASCADE;
DROP FUNCTION IF EXISTS reward_referrer_on_verification(TEXT) CASCADE;

-- 1. Add referral columns to drivers table
ALTER TABLE public.drivers 
  ADD COLUMN IF NOT EXISTS referral_code TEXT UNIQUE,
  ADD COLUMN IF NOT EXISTS referred_by_code TEXT;

-- Index for fast referral code lookups
CREATE INDEX IF NOT EXISTS idx_drivers_referral_code ON public.drivers(referral_code);

-- 2. Create referrals tracking table
CREATE TABLE IF NOT EXISTS public.referrals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_driver_id UUID NOT NULL REFERENCES public.drivers(id) ON DELETE CASCADE,
  referred_driver_id UUID NOT NULL REFERENCES public.drivers(id) ON DELETE CASCADE,
  referral_code TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'completed'
  reward_amount NUMERIC(10, 2) NOT NULL DEFAULT 25.00,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  CONSTRAINT referrals_referred_driver_id_key UNIQUE(referred_driver_id)
);

-- Index for fast queries by referrer
CREATE INDEX IF NOT EXISTS idx_referrals_referrer_id ON public.referrals(referrer_driver_id);

-- 3. Enable RLS on referrals table
ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY;

-- Permissive policy for authenticated & anon access (driver app)
DROP POLICY IF EXISTS "Allow all operations for authenticated drivers on referrals" ON public.referrals;
CREATE POLICY "Allow all operations for authenticated drivers on referrals" 
  ON public.referrals FOR ALL 
  USING (true) 
  WITH CHECK (true);

-- 4. Enable Supabase Realtime for referrals table
ALTER PUBLICATION supabase_realtime ADD TABLE public.referrals;

-- 5. Function to generate unique random 4-character alphanumeric code (e.g. EZM7K9P)
CREATE OR REPLACE FUNCTION generate_driver_referral_code(driver_phone TEXT DEFAULT NULL)
RETURNS TEXT AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; -- Excludes ambiguous characters (I, O, 0, 1)
  random_suffix TEXT;
  final_code TEXT;
  exists_count INT := 1;
  i INT;
BEGIN
  WHILE exists_count > 0 LOOP
    random_suffix := '';
    FOR i IN 1..4 LOOP
      random_suffix := random_suffix || SUBSTRING(chars FROM (FLOOR(RANDOM() * LENGTH(chars) + 1))::INT FOR 1);
    END LOOP;
    
    final_code := 'EZM' || random_suffix;
    
    SELECT COUNT(*) INTO exists_count FROM public.drivers WHERE referral_code = final_code;
  END LOOP;
  
  RETURN final_code;
END;
$$ LANGUAGE plpgsql;

-- 6. Helper function to credit referrer's wallet when referred driver is verified (UUID version)
CREATE OR REPLACE FUNCTION reward_referrer_on_verification(p_referred_driver_id UUID)
RETURNS VOID AS $$
DECLARE
  ref_record RECORD;
BEGIN
  -- Find pending referral record for this driver
  SELECT r.*, d.name AS referred_name
  INTO ref_record
  FROM public.referrals r
  JOIN public.drivers d ON d.id = r.referred_driver_id
  WHERE r.referred_driver_id = p_referred_driver_id
    AND r.status = 'pending';

  IF FOUND THEN
    -- A. Mark referral as completed
    UPDATE public.referrals
    SET status = 'completed',
        completed_at = NOW()
    WHERE id = ref_record.id;

    -- B. Credit referrer's wallet with ₹25
    INSERT INTO public.driver_wallets (driver_id, balance, created_at, updated_at)
    VALUES (ref_record.referrer_driver_id, 25.00, NOW(), NOW())
    ON CONFLICT (driver_id) DO UPDATE SET
      balance = public.driver_wallets.balance + 25.00,
      updated_at = NOW();

    -- C. Add transaction log for referrer
    INSERT INTO public.wallet_transactions (
      driver_id,
      type,
      amount,
      description,
      created_at
    ) VALUES (
      ref_record.referrer_driver_id,
      'referral_bonus',
      25.00,
      'Referral Bonus for inviting partner (' || COALESCE(ref_record.referred_name, 'Partner') || ')',
      NOW()
    );
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6b. Helper function overload (TEXT version to handle string ID types gracefully)
CREATE OR REPLACE FUNCTION reward_referrer_on_verification(p_referred_driver_id TEXT)
RETURNS VOID AS $$
BEGIN
  PERFORM reward_referrer_on_verification(p_referred_driver_id::UUID);
EXCEPTION WHEN OTHERS THEN
  NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 7. TRIGGER #1: When driver's referred_by_code is set, insert into referrals table
CREATE OR REPLACE FUNCTION process_new_driver_referral()
RETURNS TRIGGER AS $$
DECLARE
  referrer_id UUID;
BEGIN
  -- Execute when referred_by_code is set or updated
  IF NEW.referred_by_code IS NOT NULL AND NEW.referred_by_code <> '' AND 
     (OLD IS NULL OR OLD.referred_by_code IS NULL OR OLD.referred_by_code <> NEW.referred_by_code) THEN
    
    -- Find referrer driver ID matching referral_code
    SELECT id INTO referrer_id 
    FROM public.drivers 
    WHERE UPPER(referral_code) = UPPER(TRIM(NEW.referred_by_code))
    LIMIT 1;

    -- Ensure referrer exists and is not the same driver
    IF referrer_id IS NOT NULL AND referrer_id <> NEW.id THEN
      INSERT INTO public.referrals (
        referrer_driver_id,
        referred_driver_id,
        referral_code,
        status,
        reward_amount,
        created_at
      ) VALUES (
        referrer_id,
        NEW.id,
        UPPER(TRIM(NEW.referred_by_code)),
        'pending',
        25.00,
        NOW()
      )
      ON CONFLICT (referred_driver_id) DO UPDATE SET
        referrer_driver_id = EXCLUDED.referrer_driver_id,
        referral_code = EXCLUDED.referral_code;

      -- If driver is already verified, trigger immediate wallet reward
      IF NEW.is_verified = true THEN
        PERFORM reward_referrer_on_verification(NEW.id);
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Attach Trigger #1 to drivers table
CREATE TRIGGER trigger_on_driver_referral
  AFTER INSERT OR UPDATE OF referred_by_code ON public.drivers
  FOR EACH ROW
  EXECUTE FUNCTION process_new_driver_referral();


-- 8. TRIGGER #2: When driver is_verified becomes true, process ₹25 wallet reward
CREATE OR REPLACE FUNCTION process_driver_verification_reward()
RETURNS TRIGGER AS $$
BEGIN
  -- Trigger when is_verified becomes true
  IF NEW.is_verified = true AND (OLD IS NULL OR OLD.is_verified IS NULL OR OLD.is_verified = false) THEN
    PERFORM reward_referrer_on_verification(NEW.id);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Attach Trigger #2 to drivers table
CREATE TRIGGER trigger_on_driver_verification
  AFTER INSERT OR UPDATE OF is_verified ON public.drivers
  FOR EACH ROW
  EXECUTE FUNCTION process_driver_verification_reward();


-- 9. POPULATE REFERRAL CODES FOR ALL EXISTING DRIVERS IMMEDIATELY
UPDATE public.drivers
SET referral_code = generate_driver_referral_code(phone)
WHERE referral_code IS NULL OR referral_code = '';
