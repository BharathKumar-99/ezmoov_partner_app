-- ============================================================================
-- EZMOOV PARTNER APP: AUTOMATED WAITING TIME & CHARGES CALCULATOR
-- Records Pickup Arrival & Dropoff Arrival Timestamps, Computes Grace Time & Waiting Fee
-- ============================================================================

-- 1. Ensure required waiting time columns exist on public.bookings
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


-- 2. PL/pgSQL Function: Calculate Booking Waiting Time & Charges
CREATE OR REPLACE FUNCTION public.calculate_booking_waiting_time()
RETURNS TRIGGER AS $$
DECLARE
    v_grace_time INT := 15;
    v_wait_fee NUMERIC(10, 2) := 3.00;
    v_pickup_sec INT := 0;
    v_dropoff_sec INT := 0;
    v_total_min INT := 0;
    v_chargeable_min INT := 0;
    v_wait_charge NUMERIC(10, 2) := 0.00;
BEGIN
    -- 1. Status 'arrived': Set pickup arrival timestamp
    IF NEW.status = 'arrived' AND (OLD.status IS NULL OR OLD.status != 'arrived') THEN
        NEW.arrived_at_pickup_at := COALESCE(NEW.arrived_at_pickup_at, now());
    END IF;

    -- 2. Status 'in_transit': Set trip start timestamp and compute pickup wait duration
    IF NEW.status = 'in_transit' AND (OLD.status IS NULL OR OLD.status != 'in_transit') THEN
        NEW.trip_started_at := COALESCE(NEW.trip_started_at, now());
        IF NEW.arrived_at_pickup_at IS NOT NULL THEN
            NEW.pickup_wait_seconds := GREATEST(0, EXTRACT(EPOCH FROM (NEW.trip_started_at - NEW.arrived_at_pickup_at))::INT);
        END IF;
    END IF;

    -- 3. Status 'arrived_at_dropoff': Set dropoff arrival timestamp
    IF NEW.status = 'arrived_at_dropoff' AND (OLD.status IS NULL OR OLD.status != 'arrived_at_dropoff') THEN
        NEW.arrived_at_dropoff_at := COALESCE(NEW.arrived_at_dropoff_at, now());
    END IF;

    -- 4. Status 'drop_complete' or 'completed': Compute dropoff wait duration & calculate total waiting charge
    IF (NEW.status = 'drop_complete' OR NEW.status = 'completed') AND 
       (OLD.status IS NULL OR (OLD.status != 'drop_complete' AND OLD.status != 'completed')) THEN
        
        NEW.trip_completed_at := COALESCE(NEW.trip_completed_at, now());

        -- Compute dropoff wait seconds
        IF NEW.arrived_at_dropoff_at IS NOT NULL THEN
            NEW.dropoff_wait_seconds := GREATEST(0, EXTRACT(EPOCH FROM (NEW.trip_completed_at - NEW.arrived_at_dropoff_at))::INT);
        END IF;

        -- Fetch grace_time and waittime from vehicle_types table for the driver's vehicle
        SELECT COALESCE(vt.grace_time, 15), COALESCE(vt.waittime, 3.00)
        INTO v_grace_time, v_wait_fee
        FROM public.vehicles v
        JOIN public.vehicle_types vt ON (v.vehicle_type_id::text = vt.id::text OR LOWER(v.vehicle_type) = LOWER(vt.name))
        WHERE v.driver_id::text = NEW.driver_id::text
        LIMIT 1;

        -- Fallback defaults if vehicle query returns null
        IF v_grace_time IS NULL THEN v_grace_time := 15; END IF;
        IF v_wait_fee IS NULL THEN v_wait_fee := 3.00; END IF;

        v_pickup_sec := COALESCE(NEW.pickup_wait_seconds, 0);
        v_dropoff_sec := COALESCE(NEW.dropoff_wait_seconds, 0);

        -- Total waiting duration in minutes (ceiling of total seconds / 60)
        v_total_min := CEIL((v_pickup_sec + v_dropoff_sec) / 60.0)::INT;

        -- Chargeable waiting minutes after deducting grace_time
        IF v_total_min > v_grace_time THEN
            v_chargeable_min := v_total_min - v_grace_time;
            v_wait_charge := ROUND((v_chargeable_min * v_wait_fee)::numeric, 2);
        ELSE
            v_chargeable_min := 0;
            v_wait_charge := 0.00;
        END IF;

        -- Update booking waiting time & charges columns
        NEW.total_wait_minutes := v_total_min;
        NEW.grace_time_minutes := v_grace_time;
        NEW.chargeable_wait_minutes := v_chargeable_min;
        NEW.wait_fee_per_min := v_wait_fee;
        NEW.waiting_charges := v_wait_charge;

        RAISE NOTICE 'Calculated Waiting Charge: Total Wait: % min, Grace: % min, Chargeable: % min @ ₹%/min = ₹%',
            v_total_min, v_grace_time, v_chargeable_min, v_wait_fee, v_wait_charge;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 3. Attach trigger BEFORE UPDATE on public.bookings
DROP TRIGGER IF EXISTS trg_calculate_booking_waiting_time ON public.bookings;

CREATE TRIGGER trg_calculate_booking_waiting_time
BEFORE INSERT OR UPDATE ON public.bookings
FOR EACH ROW
EXECUTE FUNCTION public.calculate_booking_waiting_time();

GRANT EXECUTE ON FUNCTION public.calculate_booking_waiting_time TO anon, authenticated, service_role;

NOTIFY pgrst, 'reload schema';
