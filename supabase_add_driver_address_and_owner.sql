-- ============================================================================
-- EZMOOV PARTNER APP: ADD ADDRESS & OWNER NAME TO DRIVERS & VEHICLES TABLES
-- ============================================================================

-- 1. Add address & owner_name to drivers table
ALTER TABLE public.drivers ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE public.drivers ADD COLUMN IF NOT EXISTS owner_name TEXT;

-- 2. Add owner_name to vehicles table
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS owner_name TEXT;

-- 3. Reload schema cache for PostgREST
NOTIFY pgrst, 'reload schema';

SELECT 
    'Database Migration Success' AS status,
    'Added address and owner_name to drivers & vehicles tables' AS details;
