-- ==============================================================================
-- SQL Migration: Add registration_fee_paid to public.drivers Table
-- EZMoov Partner Application
-- ==============================================================================

-- 1. Add registration_fee_paid column to public.drivers (default: false)
ALTER TABLE public.drivers 
ADD COLUMN IF NOT EXISTS registration_fee_paid BOOLEAN DEFAULT false;

-- Ensure column exists with proper default for existing records if null
UPDATE public.drivers 
SET registration_fee_paid = false 
WHERE registration_fee_paid IS NULL;

-- 2. Index on registration_fee_paid for fast lookup & filtering
CREATE INDEX IF NOT EXISTS idx_drivers_registration_fee_paid 
ON public.drivers (registration_fee_paid);

-- 3. PL/pgSQL Function: pay_driver_registration_fee
-- Activates the partner registration fee status upon successful payment
CREATE OR REPLACE FUNCTION public.pay_driver_registration_fee(p_driver_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_updated_count INT;
BEGIN
    UPDATE public.drivers
    SET 
        registration_fee_paid = true,
        updated_at = now()
    WHERE id = p_driver_id;

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    IF v_updated_count = 1 THEN
        -- Insert a welcome/activation notification
        INSERT INTO public.driver_notifications (driver_id, title, message, type)
        VALUES (
            p_driver_id,
            'Registration Fee Paid 🎉',
            'Your one-time partner registration fee has been successfully verified! You can now activate your daily pass and start accepting ride bookings.',
            'registration_fee_paid'
        );

        RETURN jsonb_build_object(
            'success', true,
            'message', 'Registration fee paid successfully! Partner account is now active.'
        );
    ELSE
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Driver not found.'
        );
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Grant execute permissions on the RPC function
GRANT EXECUTE ON FUNCTION public.pay_driver_registration_fee(UUID) TO anon, authenticated, service_role;

-- ==============================================================================
-- Complete Updated CREATE TABLE Definition for public.drivers:
-- ==============================================================================
/*
CREATE TABLE IF NOT EXISTS public.drivers (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT NOT NULL,
    profile_pic_url TEXT NULL,
    is_online BOOLEAN NULL DEFAULT false,
    is_verified BOOLEAN NULL DEFAULT false,
    is_vehicle_added BOOLEAN NULL DEFAULT false,
    is_documents_uploaded BOOLEAN NULL DEFAULT false,
    is_bank_details_added BOOLEAN NULL DEFAULT false,
    is_vehicle_verified BOOLEAN NULL DEFAULT false,
    is_documents_verified BOOLEAN NULL DEFAULT false,
    is_bank_details_verified BOOLEAN NULL DEFAULT false,
    registration_fee_paid BOOLEAN NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NULL DEFAULT now(),
    rating NUMERIC(3, 2) NULL DEFAULT '0'::numeric,
    current_location JSONB NULL,
    vehicle_type CHARACTER VARYING(100) NULL,
    vehicle_number CHARACTER VARYING(50) NULL,
    selfie_with_vehicle_url TEXT NULL,
    owner_name TEXT NULL,
    address TEXT NULL,
    referral_code TEXT NULL,
    referred_by_code TEXT NULL,
    CONSTRAINT drivers_pkey PRIMARY KEY (id),
    CONSTRAINT drivers_phone_key UNIQUE (phone),
    CONSTRAINT drivers_referral_code_key UNIQUE (referral_code)
);

CREATE INDEX IF NOT EXISTS idx_drivers_phone ON public.drivers USING btree (phone);
CREATE INDEX IF NOT EXISTS idx_drivers_referral_code ON public.drivers USING btree (referral_code);
CREATE INDEX IF NOT EXISTS idx_drivers_registration_fee_paid ON public.drivers USING btree (registration_fee_paid);

CREATE OR REPLACE TRIGGER trg_driver_online_status_login_time
AFTER UPDATE OF is_online ON public.drivers 
FOR EACH ROW WHEN (old.is_online IS DISTINCT FROM new.is_online)
EXECUTE FUNCTION handle_driver_online_status_login_time();

CREATE OR REPLACE TRIGGER trg_prevent_online_without_pass 
BEFORE INSERT OR UPDATE OF is_online ON public.drivers 
FOR EACH ROW
EXECUTE FUNCTION prevent_online_without_pass();

CREATE OR REPLACE TRIGGER trigger_on_driver_referral
AFTER INSERT OR UPDATE OF referred_by_code ON public.drivers 
FOR EACH ROW
EXECUTE FUNCTION process_new_driver_referral();

CREATE OR REPLACE TRIGGER trigger_on_driver_verification
AFTER INSERT OR UPDATE OF is_verified ON public.drivers 
FOR EACH ROW
EXECUTE FUNCTION process_driver_verification_reward();
*/
