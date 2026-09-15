-- ==========================================================
-- EZMOOV PARTNER APP: REPOPULATE DRIVER UNIQUE_ID (EZMD0001, EZMD0002, ...)
-- ==========================================================

-- 1. Ensure unique_id column exists on public.drivers
ALTER TABLE public.drivers 
ADD COLUMN IF NOT EXISTS unique_id TEXT;

-- 2. Create index on unique_id for fast lookups
CREATE INDEX IF NOT EXISTS idx_drivers_unique_id 
ON public.drivers (unique_id);

-- 3. Create sequence for driver unique IDs if it doesn't exist
CREATE SEQUENCE IF NOT EXISTS driver_unique_id_seq START WITH 1;

-- 4. Repopulate all existing drivers sequentially in order of creation
-- Format: EZMD0001, EZMD0002, EZMD0003, ...
WITH numbered_drivers AS (
    SELECT 
        id, 
        ROW_NUMBER() OVER (ORDER BY created_at ASC NULLS LAST, id ASC) AS rn
    FROM public.drivers
)
UPDATE public.drivers d
SET unique_id = 'EZMD' || LPAD(nd.rn::TEXT, 4, '0')
FROM numbered_drivers nd
WHERE d.id = nd.id;

-- 5. Synchronize sequence with the highest assigned driver number
SELECT setval(
    'driver_unique_id_seq', 
    COALESCE(
        (SELECT MAX(NULLIF(regexp_replace(unique_id, '\D', '', 'g'), '')::BIGINT) 
         FROM public.drivers 
         WHERE unique_id ~* '^EZMD[0-9]+$'),
        0
    ) + 1,
    false
);

-- 6. Trigger function to auto-assign formatted sequential unique_id (EZMD0001, EZMD0002, ...) for new drivers
CREATE OR REPLACE FUNCTION generate_driver_unique_id()
RETURNS TRIGGER AS $$
DECLARE
    next_num BIGINT;
BEGIN
    -- Only auto-generate if unique_id is not explicitly passed
    IF NEW.unique_id IS NULL OR TRIM(NEW.unique_id) = '' THEN
        next_num := nextval('driver_unique_id_seq');
        NEW.unique_id := 'EZMD' || LPAD(next_num::TEXT, 4, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. Attach BEFORE INSERT trigger on drivers table
DROP TRIGGER IF EXISTS trg_set_driver_unique_id ON public.drivers;
CREATE TRIGGER trg_set_driver_unique_id
BEFORE INSERT ON public.drivers
FOR EACH ROW
EXECUTE FUNCTION generate_driver_unique_id();

-- 8. Verify the repopulated drivers
SELECT id, name, phone, unique_id, created_at 
FROM public.drivers 
ORDER BY unique_id ASC;
