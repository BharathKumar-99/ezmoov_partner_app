-- ============================================================================
-- EZMOOV PARTNER APP: CREATE SUPABASE STORAGE BUCKETS & PUBLIC POLICIES
-- Run this script in Supabase SQL Editor to enable image uploads
-- ============================================================================

-- 1. Create storage buckets if they do not exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
    ('bookings', 'bookings', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/heic']),
    ('vehicles', 'vehicles', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/heic']),
    ('documents', 'documents', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/heic'])
ON CONFLICT (id) DO UPDATE SET public = true;

-- 2. Drop existing policies to prevent conflicts
DROP POLICY IF EXISTS "Public Read Access for Bookings" ON storage.objects;
DROP POLICY IF EXISTS "Public Upload Access for Bookings" ON storage.objects;
DROP POLICY IF EXISTS "Public Update Access for Bookings" ON storage.objects;

DROP POLICY IF EXISTS "Public Read Access for Vehicles" ON storage.objects;
DROP POLICY IF EXISTS "Public Upload Access for Vehicles" ON storage.objects;
DROP POLICY IF EXISTS "Public Update Access for Vehicles" ON storage.objects;

DROP POLICY IF EXISTS "Public Read Access for Documents" ON storage.objects;
DROP POLICY IF EXISTS "Public Upload Access for Documents" ON storage.objects;
DROP POLICY IF EXISTS "Public Update Access for Documents" ON storage.objects;

-- 3. Add Storage RLS Policies for 'bookings' bucket
CREATE POLICY "Public Read Access for Bookings" ON storage.objects FOR SELECT TO public USING (bucket_id = 'bookings');
CREATE POLICY "Public Upload Access for Bookings" ON storage.objects FOR INSERT TO public WITH CHECK (bucket_id = 'bookings');
CREATE POLICY "Public Update Access for Bookings" ON storage.objects FOR UPDATE TO public USING (bucket_id = 'bookings');

-- 4. Add Storage RLS Policies for 'vehicles' bucket
CREATE POLICY "Public Read Access for Vehicles" ON storage.objects FOR SELECT TO public USING (bucket_id = 'vehicles');
CREATE POLICY "Public Upload Access for Vehicles" ON storage.objects FOR INSERT TO public WITH CHECK (bucket_id = 'vehicles');
CREATE POLICY "Public Update Access for Vehicles" ON storage.objects FOR UPDATE TO public USING (bucket_id = 'vehicles');

-- 5. Add Storage RLS Policies for 'documents' bucket
CREATE POLICY "Public Read Access for Documents" ON storage.objects FOR SELECT TO public USING (bucket_id = 'documents');
CREATE POLICY "Public Upload Access for Documents" ON storage.objects FOR INSERT TO public WITH CHECK (bucket_id = 'documents');
CREATE POLICY "Public Update Access for Documents" ON storage.objects FOR UPDATE TO public USING (bucket_id = 'documents');

NOTIFY pgrst, 'reload schema';
