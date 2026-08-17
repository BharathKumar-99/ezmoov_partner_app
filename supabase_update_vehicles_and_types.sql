-- ============================================================================
-- EZMOOV PARTNER APP: VEHICLES & VEHICLE TYPES SCHEMA UPDATE SCRIPT
-- ============================================================================

-- 1. Create or Update public.vehicle_types Table
CREATE TABLE IF NOT EXISTS public.vehicle_types (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    capacity TEXT,
    capacity_kg NUMERIC(10, 2),
    base_fare NUMERIC(10, 2),
    daily_fee NUMERIC(10, 2) DEFAULT 100.00,
    icon_name TEXT DEFAULT 'local_shipping',
    is_active BOOLEAN DEFAULT true,
    active BOOLEAN DEFAULT true,
    grace_time INT DEFAULT 15,
    waittime INT DEFAULT 30,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Ensure all columns exist on public.vehicle_types
ALTER TABLE public.vehicle_types ADD COLUMN IF NOT EXISTS capacity_kg NUMERIC(10, 2);
ALTER TABLE public.vehicle_types ADD COLUMN IF NOT EXISTS daily_fee NUMERIC(10, 2) DEFAULT 100.00;
ALTER TABLE public.vehicle_types ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE public.vehicle_types ADD COLUMN IF NOT EXISTS active BOOLEAN DEFAULT true;
ALTER TABLE public.vehicle_types ADD COLUMN IF NOT EXISTS grace_time INT DEFAULT 15;
ALTER TABLE public.vehicle_types ADD COLUMN IF NOT EXISTS waittime INT DEFAULT 30;

-- 2. Populate / Update vehicle_types with exact dataset
INSERT INTO public.vehicle_types (id, name, capacity, capacity_kg, base_fare, daily_fee, icon_name, is_active, active, grace_time, waittime)
VALUES 
  (1, '2 Wheeler',    '20 Kgs',   20.00,   100.00, 100.00, 'two_wheeler',       false, false, 10,  2),
  (2, '3 Wheeler',    '500 Kgs',  500.00,  210.00, 175.00, 'electric_rickshaw',  true,  true,  50,  3),
  (4, '4 Wheeler',    '750 Kgs',  750.00,  218.00, 200.00, 'local_shipping',    true,  true,  60,  3),
  (5, '8 Ft Vehicle', '1200 Kgs', 1200.00, 318.00, 250.00, 'local_shipping',    true,  true,  90,  4),
  (6, '9 Ft Vehicle', '1700 Kgs', 1700.00, 380.00, 270.00, 'local_shipping',    true,  true,  120, 5),
  (7, '10 Ft Vehicle','2000 Kgs', 2000.00, 450.00, 270.00, 'local_shipping',    true,  true,  120, 6)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  capacity = EXCLUDED.capacity,
  capacity_kg = EXCLUDED.capacity_kg,
  base_fare = EXCLUDED.base_fare,
  daily_fee = EXCLUDED.daily_fee,
  icon_name = EXCLUDED.icon_name,
  is_active = EXCLUDED.is_active,
  active = EXCLUDED.active,
  grace_time = EXCLUDED.grace_time,
  waittime = EXCLUDED.waittime;

-- 3. Create or Update public.vehicles Table
CREATE TABLE IF NOT EXISTS public.vehicles (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  driver_id UUID NOT NULL,
  vehicle_number TEXT NOT NULL,
  rc_number TEXT NOT NULL,
  rc_pic_url TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NULL DEFAULT now(),
  owner_name TEXT NULL,
  vehicle_type_id INTEGER NULL,
  vehicle_type TEXT NULL,
  body_type TEXT NULL,
  fuel_type TEXT NULL,
  city_of_operation TEXT NULL,
  CONSTRAINT vehicles_pkey PRIMARY KEY (id),
  CONSTRAINT vehicles_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES drivers (id) ON DELETE CASCADE,
  CONSTRAINT vehicles_vehicle_type_fkey FOREIGN KEY (vehicle_type) REFERENCES vehicle_types (name),
  CONSTRAINT vehicles_vehicle_type_id_fkey FOREIGN KEY (vehicle_type_id) REFERENCES vehicle_types (id)
) TABLESPACE pg_default;

-- Add any missing columns to public.vehicles
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS owner_name TEXT;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS vehicle_type_id INTEGER;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS vehicle_type TEXT;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS body_type TEXT;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS fuel_type TEXT;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS city_of_operation TEXT;

-- 4. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_vehicles_driver_id ON public.vehicles USING btree (driver_id) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_vehicles_vehicle_type_id ON public.vehicles USING btree (vehicle_type_id) TABLESPACE pg_default;

-- 5. Notify PostgREST to reload schema
NOTIFY pgrst, 'reload schema';
