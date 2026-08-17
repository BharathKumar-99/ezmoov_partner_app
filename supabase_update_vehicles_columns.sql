-- ============================================================================
-- EZMOOV PARTNER APP: UPDATE PUBLIC.VEHICLES TABLE COLUMNS
-- ============================================================================

-- Add new columns to public.vehicles table if they do not exist
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS owner_name TEXT;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS vehicle_type_id INTEGER;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS vehicle_type TEXT;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS body_type TEXT;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS fuel_type TEXT;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS city_of_operation TEXT;

-- Foreign key constraints (optional / safe additions if not present)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'vehicles_vehicle_type_id_fkey'
    ) THEN
        ALTER TABLE public.vehicles 
        ADD CONSTRAINT vehicles_vehicle_type_id_fkey 
        FOREIGN KEY (vehicle_type_id) REFERENCES public.vehicle_types (id);
    END IF;
END $$;

-- Create index on vehicle_type_id for faster queries
CREATE INDEX IF NOT EXISTS idx_vehicles_vehicle_type_id ON public.vehicles USING btree (vehicle_type_id);

-- Reload PostgREST schema cache
NOTIFY pgrst, 'reload schema';
