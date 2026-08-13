-- ==========================================
-- EZMOOV PARTNER APP (DRIVER APP) SUPABASE SETUP
-- ==========================================

-- 1. Enable PostGIS extension for geographical locations
CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA extensions;

-- 2. Create Drivers Table
CREATE TABLE IF NOT EXISTS public.drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT UNIQUE NOT NULL,
    profile_pic_url TEXT,
    is_online BOOLEAN DEFAULT false,
    current_location GEOGRAPHY(Point, 4326),
    is_verified BOOLEAN DEFAULT false,
    is_vehicle_added BOOLEAN DEFAULT false,
    is_documents_uploaded BOOLEAN DEFAULT false,
    is_bank_details_added BOOLEAN DEFAULT false,
    is_vehicle_verified BOOLEAN DEFAULT false,
    is_documents_verified BOOLEAN DEFAULT false,
    is_bank_details_verified BOOLEAN DEFAULT false,
    rating NUMERIC(3, 2) DEFAULT 5.00,
    selfie_with_vehicle_url TEXT,
    owner_name TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Ensure selfie_with_vehicle_url and owner_name exist on drivers table
ALTER TABLE public.drivers ADD COLUMN IF NOT EXISTS selfie_with_vehicle_url TEXT;
ALTER TABLE public.drivers ADD COLUMN IF NOT EXISTS owner_name TEXT;

-- Spatial index on drivers current location for fast proximity queries
CREATE INDEX IF NOT EXISTS idx_drivers_current_location 
ON public.drivers USING GIST (current_location);

-- Index on phone for fast lookup during login/signup
CREATE INDEX IF NOT EXISTS idx_drivers_phone 
ON public.drivers (phone);

-- 3. Create Vehicles Table
CREATE TABLE IF NOT EXISTS public.vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES public.drivers(id) ON DELETE CASCADE,
    vehicle_number TEXT NOT NULL,
    rc_number TEXT NOT NULL,
    rc_pic_url TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Index on driver_id
CREATE INDEX IF NOT EXISTS idx_vehicles_driver_id 
ON public.vehicles (driver_id);

-- 4. Create Documents Table (All 9 Required Verification Documents)
CREATE TABLE IF NOT EXISTS public.documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES public.drivers(id) ON DELETE CASCADE,
    aadhaar_url TEXT DEFAULT '',
    driving_license_url TEXT DEFAULT '',
    vehicle_rc_url TEXT DEFAULT '',
    pan_card_url TEXT DEFAULT '',
    insurance_url TEXT DEFAULT '',
    puc_url TEXT DEFAULT '',
    permit_url TEXT DEFAULT '',
    fitness_url TEXT DEFAULT '',
    police_clearance_url TEXT DEFAULT '',
    status TEXT DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Ensure all 9 document URL columns exist if table already exists
ALTER TABLE public.documents ADD COLUMN IF NOT EXISTS aadhaar_url TEXT DEFAULT '';
ALTER TABLE public.documents ADD COLUMN IF NOT EXISTS driving_license_url TEXT DEFAULT '';
ALTER TABLE public.documents ADD COLUMN IF NOT EXISTS vehicle_rc_url TEXT DEFAULT '';
ALTER TABLE public.documents ADD COLUMN IF NOT EXISTS pan_card_url TEXT DEFAULT '';
ALTER TABLE public.documents ADD COLUMN IF NOT EXISTS insurance_url TEXT DEFAULT '';
ALTER TABLE public.documents ADD COLUMN IF NOT EXISTS puc_url TEXT DEFAULT '';
ALTER TABLE public.documents ADD COLUMN IF NOT EXISTS permit_url TEXT DEFAULT '';
ALTER TABLE public.documents ADD COLUMN IF NOT EXISTS fitness_url TEXT DEFAULT '';
ALTER TABLE public.documents ADD COLUMN IF NOT EXISTS police_clearance_url TEXT DEFAULT '';

-- Index on driver_id
CREATE INDEX IF NOT EXISTS idx_documents_driver_id 
ON public.documents (driver_id);

-- 5. Create Bank Details Table
CREATE TABLE IF NOT EXISTS public.bank_details (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES public.drivers(id) ON DELETE CASCADE,
    account_holder_name TEXT NOT NULL,
    bank_name TEXT NOT NULL,
    account_number TEXT NOT NULL,
    ifsc_code TEXT NOT NULL,
    upi_id TEXT,
    passbook_pic_url TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Index on driver_id
CREATE INDEX IF NOT EXISTS idx_bank_details_driver_id 
ON public.bank_details (driver_id);

-- 6. Create Driver Ratings Table
CREATE TABLE IF NOT EXISTS public.driver_ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES public.drivers(id) ON DELETE CASCADE,
    trip_id TEXT,
    customer_name TEXT DEFAULT 'Customer',
    rating NUMERIC(2, 1) NOT NULL CHECK (rating >= 1.0 AND rating <= 5.0),
    review_comment TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Index on driver_id
CREATE INDEX IF NOT EXISTS idx_driver_ratings_driver_id 
ON public.driver_ratings (driver_id);

-- 7. Create Bookings Table
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id TEXT NOT NULL,
    customer_name TEXT DEFAULT 'Customer',
    pickup_address TEXT NOT NULL,
    drop_address TEXT NOT NULL,
    pickup_lat DOUBLE PRECISION NOT NULL,
    pickup_lng DOUBLE PRECISION NOT NULL,
    drop_lat DOUBLE PRECISION NOT NULL,
    drop_lng DOUBLE PRECISION NOT NULL,
    status TEXT DEFAULT 'searching', -- 'searching', 'accepted', 'arrived', 'in_progress', 'completed', 'cancelled'
    fare NUMERIC(10, 2) NOT NULL,
    driver_id UUID REFERENCES public.drivers(id),
    driver_name TEXT,
    driver_phone TEXT,
    vehicle_plate TEXT,
    driver_lat DOUBLE PRECISION,
    driver_lng DOUBLE PRECISION,
    vehicle_type_id TEXT,
    otp TEXT,
    customer_phone TEXT,
    pickup_url TEXT,
    pod_url TEXT,
    cancellation_reason TEXT,
    accepted_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);


-- Index on status and customer_id
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings (status);
CREATE INDEX IF NOT EXISTS idx_bookings_customer_id ON public.bookings (customer_id);

-- 8. Trigger to automatically compute and update average driver rating
CREATE OR REPLACE FUNCTION update_driver_average_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.drivers
    SET rating = (
        SELECT COALESCE(ROUND(AVG(rating)::numeric, 1), 5.0)
        FROM public.driver_ratings
        WHERE driver_id = NEW.driver_id
    )
    WHERE id = NEW.driver_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_update_driver_rating
AFTER INSERT OR UPDATE ON public.driver_ratings
FOR EACH ROW
EXECUTE FUNCTION update_driver_average_rating();

-- 9. PostgreSQL RPC Function for Atomic Driver Acceptance
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
BEGIN
    -- Fetch driver and vehicle info
    SELECT d.name, d.phone, COALESCE(v.vehicle_number, 'KA 03 EX 5493')
    INTO v_driver_name, v_driver_phone, v_vehicle_plate
    FROM public.drivers d
    LEFT JOIN public.vehicles v ON v.driver_id = d.id
    WHERE d.id = p_driver_id;

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

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.accept_booking_request TO anon, authenticated, service_role;

-- 10. Row Level Security (RLS) Policies
ALTER TABLE public.drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bank_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Drivers policies
CREATE POLICY "Allow public read drivers" ON public.drivers FOR SELECT USING (true);
CREATE POLICY "Allow public insert drivers" ON public.drivers FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update drivers" ON public.drivers FOR UPDATE USING (true);

-- Vehicles policies
CREATE POLICY "Allow public read vehicles" ON public.vehicles FOR SELECT USING (true);
CREATE POLICY "Allow public insert vehicles" ON public.vehicles FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update vehicles" ON public.vehicles FOR UPDATE USING (true);

-- Documents policies
CREATE POLICY "Allow public read documents" ON public.documents FOR SELECT USING (true);
CREATE POLICY "Allow public insert documents" ON public.documents FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update documents" ON public.documents FOR UPDATE USING (true);

-- Bank Details policies
CREATE POLICY "Allow public read bank_details" ON public.bank_details FOR SELECT USING (true);
CREATE POLICY "Allow public insert bank_details" ON public.bank_details FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update bank_details" ON public.bank_details FOR UPDATE USING (true);

-- Ratings policies
CREATE POLICY "Allow public read driver_ratings" ON public.driver_ratings FOR SELECT USING (true);
CREATE POLICY "Allow public insert driver_ratings" ON public.driver_ratings FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update driver_ratings" ON public.driver_ratings FOR UPDATE USING (true);

-- Bookings policies
CREATE POLICY "Allow public read bookings" ON public.bookings FOR SELECT USING (true);
CREATE POLICY "Allow public insert bookings" ON public.bookings FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update bookings" ON public.bookings FOR UPDATE USING (true);

-- Enable Supabase Realtime publication for public.bookings
ALTER PUBLICATION supabase_realtime ADD TABLE public.bookings;

-- 11. Storage Buckets Setup
INSERT INTO storage.buckets (id, name, public) 
VALUES ('profile', 'profile', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public) 
VALUES ('vehicles', 'vehicles', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public) 
VALUES ('documents', 'documents', true)
ON CONFLICT (id) DO NOTHING;

-- Storage Policies
CREATE POLICY "Public Read Access Profile Bucket" 
ON storage.objects FOR SELECT USING (bucket_id = 'profile');
CREATE POLICY "Public Insert Access Profile Bucket" 
ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'profile');

CREATE POLICY "Public Read Access Vehicles Bucket" 
ON storage.objects FOR SELECT USING (bucket_id = 'vehicles');
CREATE POLICY "Public Insert Access Vehicles Bucket" 
ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'vehicles');

CREATE POLICY "Public Read Access Documents Bucket" 
ON storage.objects FOR SELECT USING (bucket_id = 'documents');
CREATE POLICY "Public Insert Access Documents Bucket" 
ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'documents');

-- 12. Create Driver Payouts Table
CREATE TABLE IF NOT EXISTS public.driver_payouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES public.drivers(id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL,
    bank_name TEXT,
    account_number TEXT,
    status TEXT DEFAULT 'processed', -- 'processed', 'pending', 'failed'
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Index on driver_id
CREATE INDEX IF NOT EXISTS idx_driver_payouts_driver_id 
ON public.driver_payouts (driver_id);

-- RLS Policies for driver_payouts
ALTER TABLE public.driver_payouts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read driver_payouts" ON public.driver_payouts FOR SELECT USING (true);
CREATE POLICY "Allow public insert driver_payouts" ON public.driver_payouts FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update driver_payouts" ON public.driver_payouts FOR UPDATE USING (true);

-- ==========================================
-- 13. MIGRATION SNIPPET FOR EXISTING TABLES
-- (Run this if you already created the tables previously)
-- ==========================================
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS customer_phone TEXT;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS pickup_url TEXT;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS pod_url TEXT;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;


