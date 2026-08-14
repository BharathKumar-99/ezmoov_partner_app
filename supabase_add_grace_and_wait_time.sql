-- ============================================================================
-- EZMOOV PARTNER APP: ADD GRACE_TIME & WAIT_TIME (MONETARY WAITING FARE) TO VEHICLE_TYPES
-- ============================================================================

-- 1. Add columns to public.vehicle_types
-- grace_time = free time included in base fare (in minutes)
ALTER TABLE public.vehicle_types ADD COLUMN IF NOT EXISTS grace_time INTEGER DEFAULT 15;
ALTER TABLE public.vehicle_types ADD COLUMN IF NOT EXISTS gracetime INTEGER DEFAULT 15;

-- wait_time = waiting fee rate charged per minute (in ₹)
ALTER TABLE public.vehicle_types ADD COLUMN IF NOT EXISTS wait_time NUMERIC(10, 2) DEFAULT 3.00;
ALTER TABLE public.vehicle_types ADD COLUMN IF NOT EXISTS waittime NUMERIC(10, 2) DEFAULT 3.00;

-- 2. Update default grace time (mins) & wait time fee rate (₹/min) per vehicle type
UPDATE public.vehicle_types SET grace_time = 10, gracetime = 10, wait_time = 2.00, waittime = 2.00 WHERE LOWER(name) LIKE '%2%';
UPDATE public.vehicle_types SET grace_time = 15, gracetime = 15, wait_time = 3.00, waittime = 3.00 WHERE LOWER(name) LIKE '%3%';
UPDATE public.vehicle_types SET grace_time = 15, gracetime = 15, wait_time = 4.00, waittime = 4.00 WHERE LOWER(name) LIKE '%4%';
UPDATE public.vehicle_types SET grace_time = 20, gracetime = 20, wait_time = 5.00, waittime = 5.00 WHERE LOWER(name) LIKE '%8ft%' OR LOWER(name) LIKE '%9ft%';
UPDATE public.vehicle_types SET grace_time = 20, gracetime = 20, wait_time = 6.00, waittime = 6.00 WHERE LOWER(name) LIKE '%10ft%';

-- 3. Reload schema cache for PostgREST
NOTIFY pgrst, 'reload schema';

-- Display table with monetary wait time fare
SELECT 
    id, 
    name, 
    capacity, 
    base_fare, 
    daily_fee, 
    grace_time AS grace_time_mins, 
    wait_time AS wait_fare_rs_per_min, 
    is_active 
FROM public.vehicle_types 
ORDER BY id;
