-- ==========================================
-- EZMOOV PARTNER APP - WALLET & REJECTION SYSTEM SETUP
-- Perfectly matched to live Supabase Schema (drivers.vehicle_type, vehicles, vehicle_types)
-- ==========================================

-- 1. Create vehicle_types table if not exists (integer primary key id)
CREATE TABLE IF NOT EXISTS public.vehicle_types (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    capacity TEXT NOT NULL,
    capacity_kg NUMERIC(10, 2) DEFAULT 0,
    base_fare NUMERIC(10, 2) DEFAULT 0,
    daily_fee NUMERIC(10, 2) DEFAULT 100.00,
    icon_name TEXT DEFAULT 'local_shipping',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Insert or update default vehicle types with daily fee matrix:
-- 2 Wheeler: ₹100
-- 3 Wheeler / Mini 3W: ₹175
-- 7 feet Tata Ace: ₹200
-- 8 feet Pickup: ₹250
-- 9 feet and 10 feet: ₹270
-- 14 feet and 16 feet: ₹300

INSERT INTO public.vehicle_types (id, name, capacity, capacity_kg, base_fare, daily_fee, icon_name)
VALUES 
    (1, '2 Wheeler', '20kg', 20, 50, 100.00, 'two_wheeler'),
    (2, 'Mini 3W', '90kg', 90, 206, 175.00, 'electric_rickshaw'),
    (3, '3 Wheeler', '500kg', 500, 356, 175.00, 'local_shipping'),
    (4, '7ft Tata Ace', '750kg', 750, 374, 200.00, 'local_shipping'),
    (5, '8ft Pickup', '1,200kg', 1200, 511, 250.00, 'directions_bus'),
    (6, '9-10ft Pickup', '1,700kg', 1700, 612, 270.00, 'fire_truck'),
    (7, '14ft Container', '3,500kg', 3500, 1063, 300.00, 'fire_truck'),
    (8, '16-17ft Open', '6,000kg', 6000, 1733, 300.00, 'agriculture')
ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    capacity = EXCLUDED.capacity,
    capacity_kg = EXCLUDED.capacity_kg,
    base_fare = EXCLUDED.base_fare,
    daily_fee = EXCLUDED.daily_fee,
    icon_name = EXCLUDED.icon_name;

SELECT setval(pg_get_serial_sequence('public.vehicle_types', 'id'), COALESCE(MAX(id), 1)) FROM public.vehicle_types;

ALTER TABLE public.vehicle_types ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read vehicle_types" ON public.vehicle_types;
CREATE POLICY "Allow public read vehicle_types" ON public.vehicle_types FOR SELECT USING (true);


-- 2. Create Driver Wallets Table
CREATE TABLE IF NOT EXISTS public.driver_wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID UNIQUE NOT NULL REFERENCES public.drivers(id) ON DELETE CASCADE,
    balance NUMERIC(10, 2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_driver_wallets_driver_id ON public.driver_wallets (driver_id);


-- 3. Create Wallet Transactions Table
CREATE TABLE IF NOT EXISTS public.wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES public.drivers(id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL,
    type TEXT NOT NULL, -- 'recharge', 'daily_deduction', 'earning_credit', 'commission_deduction', 'settlement'
    description TEXT,
    reference_id TEXT,
    payment_method TEXT DEFAULT 'UPI',
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_wallet_transactions_driver_id ON public.wallet_transactions (driver_id);
CREATE INDEX IF NOT EXISTS idx_wallet_transactions_created_at ON public.wallet_transactions (created_at DESC);


-- 4. Create Driver Daily Status Table
CREATE TABLE IF NOT EXISTS public.driver_daily_status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES public.drivers(id) ON DELETE CASCADE,
    status_date DATE NOT NULL DEFAULT CURRENT_DATE,
    daily_fee NUMERIC(10, 2) DEFAULT 0.00,
    fee_deducted BOOLEAN DEFAULT false,
    rejections_count INT DEFAULT 0,
    is_blocked BOOLEAN DEFAULT false,
    block_reason TEXT, -- 'insufficient_wallet_balance', 'exceeded_rejections'
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT unique_driver_date UNIQUE (driver_id, status_date)
);

CREATE INDEX IF NOT EXISTS idx_driver_daily_status_driver_date ON public.driver_daily_status (driver_id, status_date);


-- 5. Create Driver Notifications Table
CREATE TABLE IF NOT EXISTS public.driver_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES public.drivers(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT DEFAULT 'wallet', -- 'wallet_deduction_success', 'wallet_deduction_failed', 'wallet_recharge', 'rejection_limit'
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_driver_notifications_driver_id ON public.driver_notifications (driver_id);
CREATE INDEX IF NOT EXISTS idx_driver_notifications_created_at ON public.driver_notifications (created_at DESC);

-- Enable RLS
ALTER TABLE public.driver_wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_daily_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_notifications ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DROP POLICY IF EXISTS "Allow public read driver_wallets" ON public.driver_wallets;
DROP POLICY IF EXISTS "Allow public insert driver_wallets" ON public.driver_wallets;
DROP POLICY IF EXISTS "Allow public update driver_wallets" ON public.driver_wallets;

CREATE POLICY "Allow public read driver_wallets" ON public.driver_wallets FOR SELECT USING (true);
CREATE POLICY "Allow public insert driver_wallets" ON public.driver_wallets FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update driver_wallets" ON public.driver_wallets FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Allow public read wallet_transactions" ON public.wallet_transactions;
DROP POLICY IF EXISTS "Allow public insert wallet_transactions" ON public.wallet_transactions;

CREATE POLICY "Allow public read wallet_transactions" ON public.wallet_transactions FOR SELECT USING (true);
CREATE POLICY "Allow public insert wallet_transactions" ON public.wallet_transactions FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public read driver_daily_status" ON public.driver_daily_status;
DROP POLICY IF EXISTS "Allow public insert driver_daily_status" ON public.driver_daily_status;
DROP POLICY IF EXISTS "Allow public update driver_daily_status" ON public.driver_daily_status;

CREATE POLICY "Allow public read driver_daily_status" ON public.driver_daily_status FOR SELECT USING (true);
CREATE POLICY "Allow public insert driver_daily_status" ON public.driver_daily_status FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update driver_daily_status" ON public.driver_daily_status FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Allow public read driver_notifications" ON public.driver_notifications;
DROP POLICY IF EXISTS "Allow public insert driver_notifications" ON public.driver_notifications;
DROP POLICY IF EXISTS "Allow public update driver_notifications" ON public.driver_notifications;

CREATE POLICY "Allow public read driver_notifications" ON public.driver_notifications FOR SELECT USING (true);
CREATE POLICY "Allow public insert driver_notifications" ON public.driver_notifications FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update driver_notifications" ON public.driver_notifications FOR UPDATE USING (true);


-- 6. PL/pgSQL Function: Process 5:00 AM Daily Wallet Deductions
CREATE OR REPLACE FUNCTION public.process_daily_wallet_deductions()
RETURNS JSONB AS $$
DECLARE
    r RECORD;
    v_current_balance NUMERIC(10, 2);
    v_vehicle_fee NUMERIC(10, 2);
    v_processed_count INT := 0;
    v_blocked_count INT := 0;
    v_today DATE := CURRENT_DATE;
BEGIN
    FOR r IN 
        SELECT 
            d.id AS driver_id, 
            d.vehicle_type AS driver_vehicle_type
        FROM public.drivers d
        WHERE d.is_verified = true
    LOOP
        v_vehicle_fee := 100.00;
        
        -- Priority 1: Match by driver's vehicle_type column from drivers table
        IF r.driver_vehicle_type IS NOT NULL AND r.driver_vehicle_type <> '' THEN
            SELECT COALESCE(vt.daily_fee, 100.00) INTO v_vehicle_fee
            FROM public.vehicle_types vt
            WHERE LOWER(vt.name) = LOWER(r.driver_vehicle_type)
               OR LOWER(r.driver_vehicle_type) LIKE '%' || LOWER(vt.name) || '%'
            LIMIT 1;
        END IF;

        -- Priority 2: Fallback fee based on vehicle_type name string matching
        IF v_vehicle_fee IS NULL OR v_vehicle_fee = 100.00 THEN
            IF LOWER(r.driver_vehicle_type) LIKE '%2%' OR LOWER(r.driver_vehicle_type) LIKE '%two%' OR LOWER(r.driver_vehicle_type) LIKE '%bike%' THEN
                v_vehicle_fee := 100.00;
            ELSIF LOWER(r.driver_vehicle_type) LIKE '%mini 3%' OR LOWER(r.driver_vehicle_type) LIKE '%3w%' OR LOWER(r.driver_vehicle_type) LIKE '%rickshaw%' OR LOWER(r.driver_vehicle_type) LIKE '%auto%' THEN
                v_vehicle_fee := 175.00;
            ELSIF LOWER(r.driver_vehicle_type) LIKE '%3%' THEN
                v_vehicle_fee := 175.00;
            ELSIF LOWER(r.driver_vehicle_type) LIKE '%7%' OR LOWER(r.driver_vehicle_type) LIKE '%ace%' OR LOWER(r.driver_vehicle_type) LIKE '%tata%' THEN
                v_vehicle_fee := 200.00;
            ELSIF LOWER(r.driver_vehicle_type) LIKE '%8%' THEN
                v_vehicle_fee := 250.00;
            ELSIF LOWER(r.driver_vehicle_type) LIKE '%9%' OR LOWER(r.driver_vehicle_type) LIKE '%10%' THEN
                v_vehicle_fee := 270.00;
            ELSIF LOWER(r.driver_vehicle_type) LIKE '%14%' OR LOWER(r.driver_vehicle_type) LIKE '%16%' OR LOWER(r.driver_vehicle_type) LIKE '%17%' OR LOWER(r.driver_vehicle_type) LIKE '%container%' THEN
                v_vehicle_fee := 300.00;
            END IF;
        END IF;

        IF v_vehicle_fee IS NULL THEN v_vehicle_fee := 100.00; END IF;

        INSERT INTO public.driver_wallets (driver_id, balance)
        VALUES (r.driver_id, 0.00)
        ON CONFLICT (driver_id) DO NOTHING;

        SELECT balance INTO v_current_balance
        FROM public.driver_wallets
        WHERE driver_id = r.driver_id;

        IF v_current_balance >= v_vehicle_fee THEN
            -- Deduct fee from wallet
            UPDATE public.driver_wallets
            SET balance = balance - v_vehicle_fee, updated_at = now()
            WHERE driver_id = r.driver_id;

            -- Record transaction
            INSERT INTO public.wallet_transactions (driver_id, amount, type, description)
            VALUES (r.driver_id, -v_vehicle_fee, 'daily_deduction', 'Daily Vehicle Platform Fee (' || v_today || ')');

            -- Record status
            INSERT INTO public.driver_daily_status (
                driver_id, status_date, daily_fee, fee_deducted, rejections_count, is_blocked, block_reason
            ) VALUES (
                r.driver_id, v_today, v_vehicle_fee, true, 0, false, NULL
            ) ON CONFLICT (driver_id, status_date) DO UPDATE SET
                daily_fee = EXCLUDED.daily_fee, fee_deducted = true, is_blocked = false, block_reason = NULL, updated_at = now();

            -- ADD SUCCESS NOTIFICATION
            INSERT INTO public.driver_notifications (driver_id, title, message, type)
            VALUES (
                r.driver_id,
                'Daily Fee Deducted Successfully ✅',
                '₹' || v_vehicle_fee || ' daily vehicle platform fee was deducted from your wallet for today (' || v_today || '). You are active to receive orders.',
                'wallet_deduction_success'
            );

            v_processed_count := v_processed_count + 1;
        ELSE
            -- Insufficient balance: Mark blocked
            INSERT INTO public.driver_daily_status (
                driver_id, status_date, daily_fee, fee_deducted, rejections_count, is_blocked, block_reason
            ) VALUES (
                r.driver_id, v_today, v_vehicle_fee, false, 0, true, 'insufficient_wallet_balance'
            ) ON CONFLICT (driver_id, status_date) DO UPDATE SET
                daily_fee = EXCLUDED.daily_fee, fee_deducted = false, is_blocked = true, block_reason = 'insufficient_wallet_balance', updated_at = now();

            -- ADD FAILED DEDUCTION NOTIFICATION
            INSERT INTO public.driver_notifications (driver_id, title, message, type)
            VALUES (
                r.driver_id,
                'Daily Fee Deduction Failed ⚠️',
                'Insufficient wallet balance to deduct ₹' || v_vehicle_fee || ' daily fee. Order allocation is paused. Please recharge your wallet to reactivate orders.',
                'wallet_deduction_failed'
            );

            v_blocked_count := v_blocked_count + 1;
        END IF;
    END LOOP;

    RETURN jsonb_build_object('success', true, 'deducted_count', v_processed_count, 'blocked_count', v_blocked_count, 'date', v_today);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 7. PL/pgSQL Function: Recharge Driver Wallet & Auto-Deduct Pending Fee
DROP FUNCTION IF EXISTS public.recharge_driver_wallet(UUID, NUMERIC);
DROP FUNCTION IF EXISTS public.recharge_driver_wallet(TEXT, NUMERIC);

CREATE OR REPLACE FUNCTION public.recharge_driver_wallet(
    p_driver_id UUID,
    p_amount NUMERIC
)
RETURNS JSONB AS $$
DECLARE
    v_new_balance NUMERIC(10, 2);
    v_today DATE := CURRENT_DATE;
    v_daily_fee NUMERIC(10, 2) := 100.00;
    v_fee_deducted BOOLEAN := false;
    v_rejections INT := 0;
    v_block_reason TEXT;
    v_driver_vehicle_type TEXT;
BEGIN
    IF p_amount < 0 THEN
        RETURN jsonb_build_object('success', false, 'message', 'Invalid recharge amount');
    END IF;

    -- Ensure driver wallet row exists
    INSERT INTO public.driver_wallets (driver_id, balance) VALUES (p_driver_id, 0.00) ON CONFLICT (driver_id) DO NOTHING;

    IF p_amount > 0 THEN
        UPDATE public.driver_wallets
        SET balance = balance + p_amount, updated_at = now()
        WHERE driver_id = p_driver_id RETURNING balance INTO v_new_balance;

        INSERT INTO public.wallet_transactions (driver_id, amount, type, description)
        VALUES (p_driver_id, p_amount, 'recharge', 'Wallet Recharge via Razorpay');

        INSERT INTO public.driver_notifications (driver_id, title, message, type)
        VALUES (
            p_driver_id,
            'Wallet Recharged Successfully 💳',
            '₹' || p_amount || ' added to your wallet. New balance: ₹' || v_new_balance,
            'wallet_recharge'
        );
    ELSE
        SELECT balance INTO v_new_balance FROM public.driver_wallets WHERE driver_id = p_driver_id;
    END IF;

    SELECT fee_deducted, daily_fee, rejections_count, block_reason INTO v_fee_deducted, v_daily_fee, v_rejections, v_block_reason
    FROM public.driver_daily_status WHERE driver_id = p_driver_id AND status_date = v_today;

    IF v_daily_fee IS NULL OR v_daily_fee = 0 THEN
        SELECT d.vehicle_type INTO v_driver_vehicle_type FROM public.drivers d WHERE d.id = p_driver_id LIMIT 1;
        
        IF v_driver_vehicle_type IS NOT NULL AND v_driver_vehicle_type <> '' THEN
            SELECT COALESCE(vt.daily_fee, 100.00) INTO v_daily_fee 
            FROM public.vehicle_types vt 
            WHERE LOWER(vt.name) = LOWER(v_driver_vehicle_type) 
               OR LOWER(v_driver_vehicle_type) LIKE '%' || LOWER(vt.name) || '%'
            LIMIT 1;
        END IF;

        IF v_daily_fee IS NULL OR v_daily_fee = 100.00 THEN
            IF LOWER(v_driver_vehicle_type) LIKE '%2%' OR LOWER(v_driver_vehicle_type) LIKE '%two%' OR LOWER(v_driver_vehicle_type) LIKE '%bike%' THEN
                v_daily_fee := 100.00;
            ELSIF LOWER(v_driver_vehicle_type) LIKE '%mini 3%' OR LOWER(v_driver_vehicle_type) LIKE '%3w%' OR LOWER(v_driver_vehicle_type) LIKE '%rickshaw%' OR LOWER(v_driver_vehicle_type) LIKE '%auto%' THEN
                v_daily_fee := 175.00;
            ELSIF LOWER(v_driver_vehicle_type) LIKE '%3%' THEN
                v_daily_fee := 175.00;
            ELSIF LOWER(v_driver_vehicle_type) LIKE '%7%' OR LOWER(v_driver_vehicle_type) LIKE '%ace%' OR LOWER(v_driver_vehicle_type) LIKE '%tata%' THEN
                v_daily_fee := 200.00;
            ELSIF LOWER(v_driver_vehicle_type) LIKE '%8%' THEN
                v_daily_fee := 250.00;
            ELSIF LOWER(v_driver_vehicle_type) LIKE '%9%' OR LOWER(v_driver_vehicle_type) LIKE '%10%' THEN
                v_daily_fee := 270.00;
            ELSIF LOWER(v_driver_vehicle_type) LIKE '%14%' OR LOWER(v_driver_vehicle_type) LIKE '%16%' OR LOWER(v_driver_vehicle_type) LIKE '%17%' OR LOWER(v_driver_vehicle_type) LIKE '%container%' THEN
                v_daily_fee := 300.00;
            END IF;
        END IF;

        IF v_daily_fee IS NULL THEN v_daily_fee := 100.00; END IF;
    END IF;

    -- Auto-deduct today's daily fee if pending and balance is now sufficient
    IF (v_fee_deducted IS NULL OR v_fee_deducted = false) AND v_new_balance >= v_daily_fee THEN
        UPDATE public.driver_wallets SET balance = balance - v_daily_fee, updated_at = now() WHERE driver_id = p_driver_id RETURNING balance INTO v_new_balance;

        INSERT INTO public.wallet_transactions (driver_id, amount, type, description)
        VALUES (p_driver_id, -v_daily_fee, 'daily_deduction', 'Daily Vehicle Platform Fee (' || v_today || ')');

        INSERT INTO public.driver_daily_status (
            driver_id, status_date, daily_fee, fee_deducted, rejections_count, is_blocked, block_reason
        ) VALUES (
            p_driver_id, v_today, v_daily_fee, true, COALESCE(v_rejections, 0),
            CASE WHEN COALESCE(v_rejections, 0) >= 2 THEN true ELSE false END,
            CASE WHEN COALESCE(v_rejections, 0) >= 2 THEN 'exceeded_rejections' ELSE NULL END
        ) ON CONFLICT (driver_id, status_date) DO UPDATE SET
            fee_deducted = true,
            is_blocked = CASE WHEN public.driver_daily_status.rejections_count >= 2 THEN true ELSE false END,
            block_reason = CASE WHEN public.driver_daily_status.rejections_count >= 2 THEN 'exceeded_rejections' ELSE NULL END,
            updated_at = now();

        INSERT INTO public.driver_notifications (driver_id, title, message, type)
        VALUES (
            p_driver_id,
            'Daily Fee Deducted ✅',
            '₹' || v_daily_fee || ' daily vehicle fee was auto-deducted. You are now active for orders!',
            'wallet_deduction_success'
        );

        v_fee_deducted := true;
    END IF;

    RETURN jsonb_build_object('success', true, 'balance', v_new_balance, 'fee_deducted', COALESCE(v_fee_deducted, false), 'message', 'Wallet recharge processed successfully');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 8. PL/pgSQL Function: Record Order Rejection & Add Notification on Block
DROP FUNCTION IF EXISTS public.record_driver_rejection(UUID);
DROP FUNCTION IF EXISTS public.record_driver_rejection(TEXT);

CREATE OR REPLACE FUNCTION public.record_driver_rejection(p_driver_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_today DATE := CURRENT_DATE;
    v_new_rejections INT := 1;
    v_is_blocked BOOLEAN := false;
    v_block_reason TEXT;
    v_fee_deducted BOOLEAN := false;
    v_daily_fee NUMERIC(10, 2) := 100.00;
BEGIN
    SELECT rejections_count, fee_deducted, daily_fee, is_blocked, block_reason INTO v_new_rejections, v_fee_deducted, v_daily_fee, v_is_blocked, v_block_reason
    FROM public.driver_daily_status WHERE driver_id = p_driver_id AND status_date = v_today;

    v_new_rejections := COALESCE(v_new_rejections, 0) + 1;

    IF v_new_rejections >= 2 THEN
        v_is_blocked := true;
        v_block_reason := 'exceeded_rejections';

        -- ADD REJECTION BLOCK NOTIFICATION
        INSERT INTO public.driver_notifications (driver_id, title, message, type)
        VALUES (
            p_driver_id,
            'Orders Paused for Today ⛔',
            'You rejected 2 orders today. Order allocation has been paused for the remainder of today and will resume tomorrow.',
            'rejection_limit'
        );
    END IF;

    INSERT INTO public.driver_daily_status (
        driver_id, status_date, daily_fee, fee_deducted, rejections_count, is_blocked, block_reason
    ) VALUES (
        p_driver_id, v_today, COALESCE(v_daily_fee, 100.00), COALESCE(v_fee_deducted, false), v_new_rejections, v_is_blocked, v_block_reason
    ) ON CONFLICT (driver_id, status_date) DO UPDATE SET
        rejections_count = EXCLUDED.rejections_count,
        is_blocked = CASE WHEN EXCLUDED.rejections_count >= 2 OR public.driver_daily_status.fee_deducted = false THEN true ELSE public.driver_daily_status.is_blocked END,
        block_reason = CASE 
            WHEN EXCLUDED.rejections_count >= 2 THEN 'exceeded_rejections' 
            WHEN public.driver_daily_status.fee_deducted = false THEN 'insufficient_wallet_balance'
            ELSE NULL 
        END,
        updated_at = now();

    RETURN jsonb_build_object('success', true, 'rejections_count', v_new_rejections, 'is_blocked', v_is_blocked, 'block_reason', v_block_reason);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. PL/pgSQL Function: Make All Drivers Offline (Executed daily at 4:50 AM)
CREATE OR REPLACE FUNCTION public.make_all_drivers_offline()
RETURNS JSONB AS $$
DECLARE
    v_updated_count INT := 0;
BEGIN
    UPDATE public.drivers
    SET is_online = false, updated_at = now()
    WHERE is_online = true;

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    RETURN jsonb_build_object(
        'success', true, 
        'offline_count', v_updated_count, 
        'timestamp', now()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9b. PL/pgSQL Function: Make Inactive Drivers Offline (Executed every 5 minutes)
-- Sets driver is_online = false if updated_at is older than 5 minutes
CREATE OR REPLACE FUNCTION public.make_inactive_drivers_offline()
RETURNS JSONB AS $$
DECLARE
    v_updated_count INT := 0;
BEGIN
    UPDATE public.drivers
    SET is_online = false,
        updated_at = now()
    WHERE is_online = true
      AND (updated_at IS NULL OR updated_at < (now() - INTERVAL '5 minutes'));

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    RETURN jsonb_build_object(
        'success', true, 
        'offline_count', v_updated_count, 
        'timestamp', now()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. PL/pgSQL Function & Trigger: Credit Driver Wallet on Booking Completion
-- Keep v_final_earning directly as total_price from amount JSONB (no commission deductions)
CREATE OR REPLACE FUNCTION public.credit_driver_wallet_on_booking_completion()
RETURNS TRIGGER AS $$
DECLARE
    v_total_price NUMERIC(10, 2) := 0.00;
    v_final_earning NUMERIC(10, 2) := 0.00;
BEGIN
    -- Only trigger when booking status transitions to 'completed'
    IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status <> 'completed') THEN
        IF NEW.driver_id IS NULL THEN
            RETURN NEW;
        END IF;

        -- Extract total_price from amount JSONB column
        IF NEW.amount IS NOT NULL AND jsonb_typeof(NEW.amount) = 'object' THEN
            v_total_price := COALESCE(
                (NEW.amount->>'total_price')::NUMERIC,
                (NEW.amount->>'totalPrice')::NUMERIC,
                (NEW.amount->>'total_fare')::NUMERIC,
                (NEW.amount->>'base_fare')::NUMERIC,
                0.00
            );
        ELSIF NEW.amount IS NOT NULL AND jsonb_typeof(NEW.amount) = 'number' THEN
            v_total_price := (NEW.amount::text)::NUMERIC;
        ELSE
            v_total_price := 0.00;
        END IF;

        -- Keep v_final_earning directly as total_price from amount (no commission deduction)
        v_final_earning := v_total_price;

        IF v_final_earning > 0 THEN
            -- Ensure driver wallet exists
            INSERT INTO public.driver_wallets (driver_id, balance) 
            VALUES (NEW.driver_id, 0.00) 
            ON CONFLICT (driver_id) DO NOTHING;

            -- Credit full trip fare directly to driver wallet
            UPDATE public.driver_wallets
            SET balance = balance + v_final_earning, updated_at = now()
            WHERE driver_id = NEW.driver_id;

            -- Record credit transaction in wallet_transactions
            INSERT INTO public.wallet_transactions (driver_id, amount, type, description, reference_id)
            VALUES (
                NEW.driver_id, 
                v_final_earning, 
                'earning_credit', 
                'Trip Earning Credit (' || COALESCE(NEW.pickup_address, 'Booking #' || SUBSTRING(NEW.id::text, 1, 8)) || ')',
                NEW.id::text
            );

            -- Add earnings notification to driver
            INSERT INTO public.driver_notifications (driver_id, title, message, type)
            VALUES (
                NEW.driver_id,
                'Trip Earnings Credited 💰',
                '₹' || v_final_earning || ' earned from completed trip has been credited to your wallet.',
                'wallet_credit'
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on public.bookings update
DROP TRIGGER IF EXISTS trg_credit_driver_wallet_on_booking_completion ON public.bookings;
CREATE TRIGGER trg_credit_driver_wallet_on_booking_completion
    AFTER UPDATE ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION public.credit_driver_wallet_on_booking_completion();

GRANT EXECUTE ON FUNCTION public.process_daily_wallet_deductions TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.recharge_driver_wallet TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.record_driver_rejection TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.make_all_drivers_offline TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.make_inactive_drivers_offline TO anon, authenticated, service_role;

-- 10. Safe Cron Schedules (Every 5 min Inactive Drivers Offline, 4:50 AM Make Offline & 5:00 AM Wallet Deductions)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
        -- Schedule 5-Minute Cron: Auto-Offline Drivers Inactive for > 5 Minutes
        IF NOT EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'every-5min-auto-offline-inactive-drivers') THEN
            PERFORM cron.schedule(
                'every-5min-auto-offline-inactive-drivers',
                '*/5 * * * *',
                'SELECT public.make_inactive_drivers_offline();'
            );
        END IF;

        -- Schedule 4:50 AM Cron: Make All Drivers Offline
        IF NOT EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'daily-450am-make-drivers-offline') THEN
            PERFORM cron.schedule(
                'daily-450am-make-drivers-offline',
                '50 4 * * *',
                'SELECT public.make_all_drivers_offline();'
            );
        END IF;

        -- Schedule 5:00 AM Cron: Process Daily Wallet Deductions
        IF NOT EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'daily-5am-wallet-deduction') THEN
            PERFORM cron.schedule(
                'daily-5am-wallet-deduction',
                '0 5 * * *',
                'SELECT public.process_daily_wallet_deductions();'
            );
        END IF;
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'pg_cron not available or schedule failed: %', SQLERRM;
END $$;

-- Safe Realtime Publication Enabling for Wallet & Notification Tables
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.driver_wallets; EXCEPTION WHEN OTHERS THEN NULL; END;
        BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.wallet_transactions; EXCEPTION WHEN OTHERS THEN NULL; END;
        BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.driver_daily_status; EXCEPTION WHEN OTHERS THEN NULL; END;
        BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.driver_notifications; EXCEPTION WHEN OTHERS THEN NULL; END;
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Realtime publication notice: %', SQLERRM;
END $$;

-- Force PostgREST schema cache reload
NOTIFY pgrst, 'reload schema';
