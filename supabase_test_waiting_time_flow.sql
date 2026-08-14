-- ============================================================================
-- EZMOOV PARTNER APP: HARD TEST FOR WAITING TIME & CHARGES CALCULATOR TRIGGER
-- Tests Pickup Arrival, Trip Start, Dropoff Arrival & Dropoff Completion Flow
-- ============================================================================

-- Ensure waiting time columns exist
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS arrived_at_pickup_at TIMESTAMPTZ;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS trip_started_at TIMESTAMPTZ;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS arrived_at_dropoff_at TIMESTAMPTZ;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS trip_completed_at TIMESTAMPTZ;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS pickup_wait_seconds INTEGER DEFAULT 0;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS dropoff_wait_seconds INTEGER DEFAULT 0;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS total_wait_minutes INTEGER DEFAULT 0;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS grace_time_minutes INTEGER DEFAULT 15;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS chargeable_wait_minutes INTEGER DEFAULT 0;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS wait_fee_per_min NUMERIC(10, 2) DEFAULT 0.00;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS waiting_charges NUMERIC(10, 2) DEFAULT 0.00;


-- Function to simulate full booking waiting time calculation test
DROP FUNCTION IF EXISTS public.run_waiting_time_simulation();

CREATE OR REPLACE FUNCTION public.run_waiting_time_simulation()
RETURNS TABLE (
    step_name TEXT,
    booking_status TEXT,
    pickup_wait_mins INT,
    dropoff_wait_mins INT,
    total_wait_mins INT,
    grace_time_mins INT,
    chargeable_mins INT,
    wait_fee_rate NUMERIC(10, 2),
    calculated_waiting_charge NUMERIC(10, 2)
) AS $$
DECLARE
    v_driver_id UUID;
    v_booking_id UUID;
    v_customer_id UUID;
BEGIN
    -- 1. Setup Test Driver & Customer
    SELECT id INTO v_driver_id FROM public.drivers LIMIT 1;
    SELECT id INTO v_customer_id FROM public.customers LIMIT 1;
    IF v_customer_id IS NULL THEN v_customer_id := gen_random_uuid(); END IF;

    -- Ensure a test vehicle type exists with grace_time = 50 mins and waittime = 2.00
    INSERT INTO public.vehicle_types (name, capacity, capacity_kg, base_fare, daily_fee, grace_time, waittime, is_active)
    VALUES ('Test 3W', '500 Kgs', 500.00, 210.00, 175.00, 50, 2.00, true)
    ON CONFLICT DO NOTHING;

    -- Create dummy booking
    INSERT INTO public.bookings (
        customer_id, driver_id, pickup_address, drop_address, pickup_lat, pickup_lng, drop_lat, drop_lng, status
    ) VALUES (
        v_customer_id, v_driver_id, '123 Pickup St', '456 Drop Rd', 17.3850, 78.4867, 17.4401, 78.3489, 'accepted'
    ) RETURNING id INTO v_booking_id;

    -- STEP 1: Driver Arrives at Pickup (35 mins ago)
    UPDATE public.bookings 
    SET status = 'arrived', arrived_at_pickup_at = now() - INTERVAL '35 minutes'
    WHERE id = v_booking_id;

    step_name := '1. Arrived at Pickup';
    booking_status := 'arrived';
    pickup_wait_mins := 0; dropoff_wait_mins := 0; total_wait_mins := 0; grace_time_mins := 50; chargeable_mins := 0; wait_fee_rate := 2.00; calculated_waiting_charge := 0.00;
    RETURN NEXT;

    -- STEP 2: Driver Starts Trip ('in_transit')
    UPDATE public.bookings 
    SET status = 'in_transit', trip_started_at = now()
    WHERE id = v_booking_id;

    SELECT pickup_wait_seconds / 60 INTO pickup_wait_mins FROM public.bookings WHERE id = v_booking_id;
    step_name := '2. Trip In Transit';
    booking_status := 'in_transit';
    RETURN NEXT;

    -- STEP 3: Driver Arrives at Drop-off (25 mins ago)
    UPDATE public.bookings 
    SET status = 'arrived_at_dropoff', arrived_at_dropoff_at = now() - INTERVAL '25 minutes'
    WHERE id = v_booking_id;

    step_name := '3. Arrived at Drop-off';
    booking_status := 'arrived_at_dropoff';
    RETURN NEXT;

    -- STEP 4: Driver Unloads & Completes Trip ('drop_complete')
    UPDATE public.bookings 
    SET status = 'drop_complete', trip_completed_at = now()
    WHERE id = v_booking_id;

    SELECT 
        pickup_wait_seconds / 60,
        dropoff_wait_seconds / 60,
        total_wait_minutes,
        grace_time_minutes,
        chargeable_wait_minutes,
        wait_fee_per_min,
        waiting_charges
    INTO 
        pickup_wait_mins,
        dropoff_wait_mins,
        total_wait_mins,
        grace_time_mins,
        chargeable_mins,
        wait_fee_rate,
        calculated_waiting_charge
    FROM public.bookings 
    WHERE id = v_booking_id;

    step_name := '4. Drop Complete (Calculation)';
    booking_status := 'drop_complete';
    RETURN NEXT;

    -- Clean up test booking
    DELETE FROM public.bookings WHERE id = v_booking_id;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Execute Simulation
SELECT * FROM public.run_waiting_time_simulation();
