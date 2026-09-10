-- ==============================================================================
-- SQL Migration: Driver Ride Actions Tracking (Accept / Deny History & Stats)
-- EZMoov Partner Application
-- ==============================================================================

-- 1. Create Table: driver_ride_actions
-- Tracks every time a driver accepts or denies/declines a ride request with timestamp,
-- booking details, location, and reason. Primary key id is an auto-incrementing integer (BIGINT).
CREATE TABLE IF NOT EXISTS public.driver_ride_actions (
    id BIGSERIAL PRIMARY KEY,
    driver_id UUID NOT NULL REFERENCES public.drivers(id) ON DELETE CASCADE,
    booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
    action TEXT NOT NULL CHECK (action IN ('accepted', 'declined', 'denied', 'timeout', 'cancelled')),
    action_time TIMESTAMPTZ NOT NULL DEFAULT now(),
    
    -- Additional ride & context info
    pickup_address TEXT,
    drop_address TEXT,
    fare NUMERIC(10, 2),
    vehicle_type_id TEXT,
    customer_id TEXT,
    customer_name TEXT,
    reason TEXT,
    response_time_seconds INT,
    driver_lat DOUBLE PRECISION,
    driver_lng DOUBLE PRECISION,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Ensure all columns exist if table already existed
ALTER TABLE public.driver_ride_actions ADD COLUMN IF NOT EXISTS pickup_address TEXT;
ALTER TABLE public.driver_ride_actions ADD COLUMN IF NOT EXISTS drop_address TEXT;
ALTER TABLE public.driver_ride_actions ADD COLUMN IF NOT EXISTS fare NUMERIC(10, 2);
ALTER TABLE public.driver_ride_actions ADD COLUMN IF NOT EXISTS vehicle_type_id TEXT;
ALTER TABLE public.driver_ride_actions ADD COLUMN IF NOT EXISTS customer_id TEXT;
ALTER TABLE public.driver_ride_actions ADD COLUMN IF NOT EXISTS customer_name TEXT;
ALTER TABLE public.driver_ride_actions ADD COLUMN IF NOT EXISTS reason TEXT;
ALTER TABLE public.driver_ride_actions ADD COLUMN IF NOT EXISTS response_time_seconds INT;
ALTER TABLE public.driver_ride_actions ADD COLUMN IF NOT EXISTS driver_lat DOUBLE PRECISION;
ALTER TABLE public.driver_ride_actions ADD COLUMN IF NOT EXISTS driver_lng DOUBLE PRECISION;
ALTER TABLE public.driver_ride_actions ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;

-- 2. Indexes for high-performance querying
CREATE INDEX IF NOT EXISTS idx_driver_ride_actions_driver_id 
    ON public.driver_ride_actions (driver_id);

CREATE INDEX IF NOT EXISTS idx_driver_ride_actions_booking_id 
    ON public.driver_ride_actions (booking_id);

CREATE INDEX IF NOT EXISTS idx_driver_ride_actions_driver_action 
    ON public.driver_ride_actions (driver_id, action);

CREATE INDEX IF NOT EXISTS idx_driver_ride_actions_driver_time 
    ON public.driver_ride_actions (driver_id, action_time DESC);

CREATE INDEX IF NOT EXISTS idx_driver_ride_actions_created_at 
    ON public.driver_ride_actions (created_at DESC);

-- 3. Enable Row Level Security (RLS)
ALTER TABLE public.driver_ride_actions ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies
DROP POLICY IF EXISTS "Allow read driver_ride_actions" ON public.driver_ride_actions;
CREATE POLICY "Allow read driver_ride_actions"
    ON public.driver_ride_actions
    FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Allow insert driver_ride_actions" ON public.driver_ride_actions;
CREATE POLICY "Allow insert driver_ride_actions"
    ON public.driver_ride_actions
    FOR INSERT
    WITH CHECK (true);

DROP POLICY IF EXISTS "Allow update driver_ride_actions" ON public.driver_ride_actions;
CREATE POLICY "Allow update driver_ride_actions"
    ON public.driver_ride_actions
    FOR UPDATE
    USING (true);

DROP POLICY IF EXISTS "Allow delete driver_ride_actions" ON public.driver_ride_actions;
CREATE POLICY "Allow delete driver_ride_actions"
    ON public.driver_ride_actions
    FOR DELETE
    USING (true);

-- 5. Enable Supabase Realtime
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' 
          AND schemaname = 'public' 
          AND tablename = 'driver_ride_actions'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.driver_ride_actions;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END $$;

-- 6. RPC Function: record_driver_ride_action
-- Records an accept/deny action with automatic fallback lookup of booking details from amount/bookings
CREATE OR REPLACE FUNCTION public.record_driver_ride_action(
    p_driver_id UUID,
    p_booking_id UUID,
    p_action TEXT,
    p_reason TEXT DEFAULT NULL,
    p_pickup_address TEXT DEFAULT NULL,
    p_drop_address TEXT DEFAULT NULL,
    p_fare NUMERIC DEFAULT NULL,
    p_vehicle_type_id TEXT DEFAULT NULL,
    p_customer_id TEXT DEFAULT NULL,
    p_customer_name TEXT DEFAULT NULL,
    p_response_time_seconds INT DEFAULT NULL,
    p_driver_lat DOUBLE PRECISION DEFAULT NULL,
    p_driver_lng DOUBLE PRECISION DEFAULT NULL,
    p_metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS JSONB AS $$
DECLARE
    v_new_id BIGINT;
    v_action_time TIMESTAMPTZ := now();
    v_pickup TEXT := p_pickup_address;
    v_drop TEXT := p_drop_address;
    v_fare NUMERIC(10, 2) := p_fare;
    v_veh_type TEXT := p_vehicle_type_id;
    v_cust_id TEXT := p_customer_id;
    v_cust_name TEXT := p_customer_name;
    v_norm_action TEXT := LOWER(TRIM(p_action));
BEGIN
    -- Normalize action names ('accept' -> 'accepted', 'deny'/'decline'/'rejected' -> 'declined')
    IF v_norm_action IN ('accept', 'accepted') THEN
        v_norm_action := 'accepted';
    ELSIF v_norm_action IN ('deny', 'denied', 'decline', 'declined', 'reject', 'rejected') THEN
        v_norm_action := 'declined';
    ELSIF v_norm_action IN ('timeout', 'expired') THEN
        v_norm_action := 'timeout';
    ELSIF v_norm_action IN ('cancel', 'cancelled') THEN
        v_norm_action := 'cancelled';
    ELSE
        v_norm_action := 'declined';
    END IF;

    -- If booking info missing and booking_id provided, safely fetch from bookings table
    IF p_booking_id IS NOT NULL AND (v_pickup IS NULL OR v_drop IS NULL OR v_fare IS NULL) THEN
        BEGIN
            SELECT 
                b.pickup_address, 
                b.drop_address, 
                b.vehicle_type_id, 
                b.customer_id, 
                b.customer_name,
                CASE 
                    WHEN b.amount IS NOT NULL AND jsonb_typeof(to_jsonb(b.amount)) = 'object' THEN 
                        COALESCE(
                            (to_jsonb(b.amount)->>'total_price')::NUMERIC, 
                            (to_jsonb(b.amount)->>'totalPrice')::NUMERIC,
                            (to_jsonb(b.amount)->>'fare')::NUMERIC,
                            0.00
                        )
                    WHEN b.amount IS NOT NULL AND jsonb_typeof(to_jsonb(b.amount)) = 'number' THEN
                        (to_jsonb(b.amount))::NUMERIC
                    ELSE 0.00
                END
            INTO 
                v_pickup, v_drop, v_veh_type, v_cust_id, v_cust_name, v_fare
            FROM public.bookings b
            WHERE b.id = p_booking_id;
        EXCEPTION WHEN OTHERS THEN
            NULL;
        END;
    END IF;

    -- Insert record
    INSERT INTO public.driver_ride_actions (
        driver_id,
        booking_id,
        action,
        action_time,
        pickup_address,
        drop_address,
        fare,
        vehicle_type_id,
        customer_id,
        customer_name,
        reason,
        response_time_seconds,
        driver_lat,
        driver_lng,
        metadata,
        created_at
    ) VALUES (
        p_driver_id,
        p_booking_id,
        v_norm_action,
        v_action_time,
        v_pickup,
        v_drop,
        v_fare,
        v_veh_type,
        v_cust_id,
        v_cust_name,
        p_reason,
        p_response_time_seconds,
        p_driver_lat,
        p_driver_lng,
        COALESCE(p_metadata, '{}'::jsonb),
        v_action_time
    )
    RETURNING id INTO v_new_id;

    RETURN jsonb_build_object(
        'success', true,
        'id', v_new_id,
        'action', v_norm_action,
        'action_time', v_action_time,
        'driver_id', p_driver_id,
        'booking_id', p_booking_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. RPC Function: get_driver_ride_stats
-- Computes acceptance counts, denial counts, total requests, and acceptance rate % for a driver
CREATE OR REPLACE FUNCTION public.get_driver_ride_stats(p_driver_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_total_requests INT := 0;
    v_accepted_count INT := 0;
    v_declined_count INT := 0;
    v_timeout_count INT := 0;
    v_cancelled_count INT := 0;
    v_today_total INT := 0;
    v_today_accepted INT := 0;
    v_today_declined INT := 0;
    v_acceptance_rate NUMERIC(5, 2) := 0.00;
BEGIN
    -- Overall stats
    SELECT 
        COUNT(*),
        COUNT(*) FILTER (WHERE action = 'accepted'),
        COUNT(*) FILTER (WHERE action IN ('declined', 'denied')),
        COUNT(*) FILTER (WHERE action = 'timeout'),
        COUNT(*) FILTER (WHERE action = 'cancelled')
    INTO 
        v_total_requests,
        v_accepted_count,
        v_declined_count,
        v_timeout_count,
        v_cancelled_count
    FROM public.driver_ride_actions
    WHERE driver_id = p_driver_id;

    -- Today's stats
    SELECT 
        COUNT(*),
        COUNT(*) FILTER (WHERE action = 'accepted'),
        COUNT(*) FILTER (WHERE action IN ('declined', 'denied'))
    INTO 
        v_today_total,
        v_today_accepted,
        v_today_declined
    FROM public.driver_ride_actions
    WHERE driver_id = p_driver_id
      AND action_time >= date_trunc('day', now());

    -- Acceptance Rate Calculation
    IF v_total_requests > 0 THEN
        v_acceptance_rate := ROUND(((v_accepted_count::NUMERIC / v_total_requests::NUMERIC) * 100.0), 2);
    ELSE
        v_acceptance_rate := 100.00;
    END IF;

    RETURN jsonb_build_object(
        'driver_id', p_driver_id,
        'total_requests', v_total_requests,
        'accepted_count', v_accepted_count,
        'declined_count', v_declined_count,
        'timeout_count', v_timeout_count,
        'cancelled_count', v_cancelled_count,
        'acceptance_rate', v_acceptance_rate,
        'today_total', v_today_total,
        'today_accepted', v_today_accepted,
        'today_declined', v_today_declined
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. View: driver_ride_action_summary
CREATE OR REPLACE VIEW public.driver_ride_action_summary AS
SELECT 
    d.id AS driver_id,
    d.name AS driver_name,
    d.phone AS driver_phone,
    COUNT(a.id) AS total_requests,
    COUNT(a.id) FILTER (WHERE a.action = 'accepted') AS accepted_count,
    COUNT(a.id) FILTER (WHERE a.action IN ('declined', 'denied')) AS declined_count,
    COUNT(a.id) FILTER (WHERE a.action = 'timeout') AS timeout_count,
    CASE 
        WHEN COUNT(a.id) > 0 THEN 
            ROUND((COUNT(a.id) FILTER (WHERE a.action = 'accepted')::NUMERIC / COUNT(a.id)::NUMERIC) * 100.0, 2)
        ELSE 100.00 
    END AS acceptance_rate,
    MAX(a.action_time) AS last_action_time
FROM public.drivers d
LEFT JOIN public.driver_ride_actions a ON a.driver_id = d.id
GROUP BY d.id, d.name, d.phone;

-- 9. Atomic Driver Acceptance Function: accept_booking_request
CREATE OR REPLACE FUNCTION public.accept_booking_request(
    p_booking_id UUID,
    p_driver_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_updated_count INT;
    v_driver_name TEXT;
    v_driver_phone TEXT;
    v_vehicle_plate TEXT;
    v_pickup_address TEXT;
    v_drop_address TEXT;
    v_fare NUMERIC(10, 2);
    v_veh_type TEXT;
    v_cust_id TEXT;
    v_cust_name TEXT;
BEGIN
    -- Fetch driver and vehicle info
    SELECT d.name, d.phone, COALESCE(v.vehicle_number, 'KA 03 EX 5493')
    INTO v_driver_name, v_driver_phone, v_vehicle_plate
    FROM public.drivers d
    LEFT JOIN public.vehicles v ON v.driver_id = d.id
    WHERE d.id = p_driver_id;

    -- Safely fetch booking info using amount JSONB (no reliance on non-existent fare column)
    BEGIN
        SELECT 
            b.pickup_address, 
            b.drop_address, 
            b.vehicle_type_id, 
            b.customer_id, 
            b.customer_name,
            CASE 
                WHEN b.amount IS NOT NULL AND jsonb_typeof(to_jsonb(b.amount)) = 'object' THEN 
                    COALESCE(
                        (to_jsonb(b.amount)->>'total_price')::NUMERIC, 
                        (to_jsonb(b.amount)->>'totalPrice')::NUMERIC,
                        (to_jsonb(b.amount)->>'fare')::NUMERIC,
                        0.00
                    )
                WHEN b.amount IS NOT NULL AND jsonb_typeof(to_jsonb(b.amount)) = 'number' THEN
                    (to_jsonb(b.amount))::NUMERIC
                ELSE 0.00
            END
        INTO 
            v_pickup_address, v_drop_address, v_veh_type, v_cust_id, v_cust_name, v_fare
        FROM public.bookings b
        WHERE b.id = p_booking_id;
    EXCEPTION WHEN OTHERS THEN
        v_pickup_address := NULL;
        v_drop_address := NULL;
        v_veh_type := NULL;
        v_cust_id := NULL;
        v_cust_name := NULL;
        v_fare := NULL;
    END;

    -- Atomic Lock: UPDATE only if status is STILL 'searching'
    UPDATE public.bookings
    SET 
        status = 'accepted',
        driver_id = p_driver_id,
        driver_name = v_driver_name,
        driver_phone = v_driver_phone,
        vehicle_plate = v_vehicle_plate,
        accepted_at = now(),
        updated_at = now()
    WHERE id = p_booking_id
      AND status = 'searching';

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    IF v_updated_count = 1 THEN
        -- Record successful accept action in driver_ride_actions
        BEGIN
            INSERT INTO public.driver_ride_actions (
                driver_id,
                booking_id,
                action,
                action_time,
                pickup_address,
                drop_address,
                fare,
                vehicle_type_id,
                customer_id,
                customer_name,
                created_at
            ) VALUES (
                p_driver_id,
                p_booking_id,
                'accepted',
                now(),
                v_pickup_address,
                v_drop_address,
                v_fare,
                v_veh_type,
                v_cust_id,
                v_cust_name,
                now()
            );
        EXCEPTION WHEN OTHERS THEN
            -- Logging error shouldn't block booking acceptance
            NULL;
        END;

        RETURN jsonb_build_object(
            'success', true, 
            'message', 'Booking accepted successfully!'
        );
    ELSE
        RETURN jsonb_build_object(
            'success', false, 
            'message', 'Ride already taken by another driver.'
        );
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. Grant Permissions
GRANT ALL ON TABLE public.driver_ride_actions TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE public.driver_ride_actions_id_seq TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.record_driver_ride_action TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.get_driver_ride_stats TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.accept_booking_request TO anon, authenticated, service_role;
