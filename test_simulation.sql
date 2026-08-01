-- =========================================================
-- EZMOOV CUSTOMER BOOKING SIMULATION SQL SCRIPT
-- Run this in Supabase SQL Editor to simulate customer actions!
-- =========================================================

-- 1. SIMULATE CUSTOMER CREATING A RIDE REQUEST
-- This will trigger the Incoming Ride Pop-Up Modal in all online partner apps!
INSERT INTO public.bookings (
    customer_id,
    customer_name,
    pickup_address,
    drop_address,
    pickup_lat,
    pickup_lng,
    drop_lat,
    drop_lng,
    pickup_location,
    drop_location,
    status,
    fare,
    otp,
    created_at,
    updated_at
) VALUES (
    'cust_simulated_99',
    'Priya Sundaram',
    'Koramangala 4th Block, Bengaluru',
    'HSR Layout Sector 1, Bengaluru',
    12.9352,
    77.6245,
    12.9121,
    77.6446,
    ST_SetSRID(ST_MakePoint(77.6245, 12.9352), 4326)::geography,
    ST_SetSRID(ST_MakePoint(77.6446, 12.9121), 4326)::geography,
    'searching',
    280.00,
    '9824',
    now(),
    now()
);

-- 2. CHECK ACTIVE SEARCHING BOOKINGS
SELECT id, customer_id, pickup_address, status, fare, created_at 
FROM public.bookings 
WHERE status = 'searching' 
ORDER BY created_at DESC;
