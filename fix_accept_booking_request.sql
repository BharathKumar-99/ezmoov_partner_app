-- ==============================================================================
-- Quick Fix: Update accept_booking_request and record_driver_ride_action
-- Fixes: column "fare" does not exist (safely parses amount JSONB column)
-- Run this script in your Supabase SQL Editor.
-- ==============================================================================

-- 1. Create or update driver_ride_actions table
CREATE TABLE IF NOT EXISTS public.driver_ride_actions (
    id BIGSERIAL PRIMARY KEY,
    driver_id UUID NOT NULL REFERENCES public.drivers(id) ON DELETE CASCADE,
    booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
    action TEXT NOT NULL CHECK (action IN ('accepted', 'declined', 'denied', 'timeout', 'cancelled')),
    action_time TIMESTAMPTZ NOT NULL DEFAULT now(),
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

-- Ensure all columns exist
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

-- 2. Fixed accept_booking_request function
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

    -- Safely fetch booking info from amount JSONB / bookings table
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

-- 3. Fixed record_driver_ride_action function
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

-- 4. Grant Permissions
GRANT ALL ON TABLE public.driver_ride_actions TO anon, authenticated, service_role;
GRANT USAGE, SELECT ON SEQUENCE public.driver_ride_actions_id_seq TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.record_driver_ride_action TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.accept_booking_request TO anon, authenticated, service_role;
