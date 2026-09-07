-- ============================================================================
-- EZMOOV PARTNER APP: UPDATE VEHICLE TYPES TABLE & SEED EXACT DATASET
-- ============================================================================

-- 1. Ensure required columns exist on public.vehicle_types
ALTER TABLE public.vehicle_types ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE public.vehicle_types ADD COLUMN IF NOT EXISTS active BOOLEAN DEFAULT true;
ALTER TABLE public.vehicle_types ADD COLUMN IF NOT EXISTS daily_fee NUMERIC(10, 2) DEFAULT 100.00;

-- 2. Clear old catalog/types and insert the exact dataset
TRUNCATE TABLE public.vehicle_types RESTART IDENTITY CASCADE;

INSERT INTO public.vehicle_types (
    name, 
    capacity, 
    capacity_kg, 
    base_fare, 
    daily_fee, 
    is_active, 
    active, 
    icon_name,
    grace_time,
    waittime
) VALUES 
  -- daily_fee = daily recharge amount (₹) | grace_time = free period (mins) | waittime = per-min charge (₹) after grace
  ('2 Wheeler - Bike',  '20 Kgs',   20.00,   100.00,  30.00, true,  true,  'two_wheeler',        20,  1.0),
  ('2 Wheeler - Moped', '20 Kgs',   20.00,   100.00,  30.00, true,  true,  'two_wheeler',        20,  1.5),
  ('3 Wheeler',         '500 Kgs',  500.00,  210.00, 150.00, true,  true,  'electric_rickshaw',  40,  3.0),
  ('4 Wheeler',         '750 Kgs',  750.00,  218.00, 175.00, true,  true,  'local_shipping',     50,  3.5),
  ('4 Wheeler',         '1200 Kgs', 1200.00, 318.00, 236.00, true,  true,  'local_shipping',     80,  4.0),
  ('4 Wheeler',         '1700 Kgs', 1700.00, 380.00, 236.00, true,  true,  'local_shipping',    110,  7.0),
  ('4 Wheeler',         '2000 Kgs', 2000.00, 450.00, 236.00, true,  true,  'local_shipping',    110,  7.5);

-- 3. Reload schema cache for PostgREST
NOTIFY pgrst, 'reload schema';

-- Display populated table results
SELECT 
    id, 
    name, 
    capacity, 
    capacity_kg, 
    base_fare, 
    daily_fee, 
    is_active, 
    icon_name 
FROM public.vehicle_types 
ORDER BY id;
