-- ============================================================================
-- EZMOOV PARTNER APP: VEHICLES TABLE SCHEMA UPDATE
-- ============================================================================

-- 1. Ensure public.vehicles table has required columns
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS vehicle_type_id TEXT;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS vehicle_type TEXT;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS owner_name TEXT;

-- 2. Ensure drivers table has vehicle_type column
ALTER TABLE public.drivers ADD COLUMN IF NOT EXISTS vehicle_type TEXT;
ALTER TABLE public.drivers ADD COLUMN IF NOT EXISTS owner_name TEXT;

-- 3. Create index on driver_id for fast lookups
CREATE INDEX IF NOT EXISTS idx_vehicles_driver_id ON public.vehicles USING btree (driver_id);

-- 4. Reload schema cache for PostgREST
NOTIFY pgrst, 'reload schema';

SELECT 
    'Vehicles Schema Update Success' AS status,
    'Updated public.vehicles and public.drivers with vehicle_type_id, vehicle_type, and owner_name' AS details;
