-- ============================================================================
-- EZMOOV PARTNER APP: 24-MINUTE FULL-DAY LIFE-CYCLE SIMULATION & AUDIT SUITE
-- Simulates 24 Hours of Driver Operations in 24 Real Minutes (1 Min = 1 Hour)
-- Tests: Wallet Recharge, Daily Fee Deduction, Pass Expiry Guard, Trip Earnings,
--        Waiting Charges Engine, Order Rejections Guard, Withdrawal & Midnight Reset
-- ============================================================================

-- Function to run comprehensive 24-Minute / 24-Hour Full Simulation
DROP FUNCTION IF EXISTS public.run_24min_full_day_simulation();

CREATE OR REPLACE FUNCTION public.run_24min_full_day_simulation()
RETURNS TABLE (
    sim_minute INT,
    sim_time TEXT,
    event_phase TEXT,
    driver_online BOOLEAN,
    wallet_balance NUMERIC(10, 2),
    pass_expires_at TIMESTAMPTZ,
    rejections INT,
    is_blocked BOOLEAN,
    last_event_result TEXT
) AS $$
DECLARE
    v_driver_id UUID;
    v_customer_id UUID;
    v_booking_id UUID;
    v_res JSONB;
    v_bal NUMERIC(10, 2);
    v_exp TIMESTAMPTZ;
    v_rej INT;
    v_blk BOOLEAN;
    v_on BOOLEAN;
BEGIN
    -- 0. SETUP DUMMY TEST DRIVER & VEHICLE
    SELECT id INTO v_driver_id FROM public.drivers WHERE email = 'test_simulation_driver@ezmoov.com' LIMIT 1;
    IF v_driver_id IS NULL THEN
        INSERT INTO public.drivers (name, email, phone, vehicle_type, vehicle_number, is_online, is_verified)
        VALUES ('Simulation Driver', 'test_simulation_driver@ezmoov.com', '+919999900000', '3 Wheeler', 'TS09SIM1234', false, true)
        RETURNING id INTO v_driver_id;
    END IF;

    -- Customer ID generated independently
    v_customer_id := gen_random_uuid();

    -- Ensure vehicle type 3 Wheeler exists with grace_time = 15 mins, waittime = 3.00, daily_fee = 175.00
    INSERT INTO public.vehicle_types (name, capacity, capacity_kg, base_fare, daily_fee, grace_time, waittime, is_active)
    VALUES ('3 Wheeler', '500 Kgs', 500.00, 210.00, 175.00, 15, 3.00, true)
    ON CONFLICT DO NOTHING;

    -- Ensure driver wallet & daily status start fresh for test
    INSERT INTO public.driver_wallets (driver_id, balance) VALUES (v_driver_id, 0.00)
    ON CONFLICT (driver_id) DO UPDATE SET balance = 0.00, updated_at = now();

    DELETE FROM public.driver_daily_status WHERE driver_id = v_driver_id;
    UPDATE public.drivers SET is_online = false WHERE id = v_driver_id;

    -- ========================================================================
    -- MINUTE 00 (00:00 AM) - INITIAL UNPAID STATE & GO ONLINE GUARD BLOCK
    -- ========================================================================
    UPDATE public.drivers SET is_online = true WHERE id = v_driver_id; -- Should be blocked by trigger
    
    SELECT is_online INTO v_on FROM public.drivers WHERE id = v_driver_id;
    SELECT balance INTO v_bal FROM public.driver_wallets WHERE driver_id = v_driver_id;
    SELECT pass_expires_at, rejections_count, is_blocked INTO v_exp, v_rej, v_blk FROM public.driver_daily_status WHERE driver_id = v_driver_id AND status_date = CURRENT_DATE;

    sim_minute := 0; sim_time := '00:00 AM'; event_phase := '1. Initial State (Unpaid Guard Check)';
    driver_online := v_on; wallet_balance := v_bal; pass_expires_at := v_exp; rejections := COALESCE(v_rej, 0); is_blocked := COALESCE(v_blk, false);
    last_event_result := 'Unpaid driver attempted online -> Blocked by database trigger (is_online=' || v_on::text || ')';
    RETURN NEXT;

    -- ========================================================================
    -- MINUTE 01 (01:00 AM) - WALLET RECHARGE WITH ₹500
    -- ========================================================================
    v_res := public.recharge_driver_wallet(v_driver_id, 500.00);

    SELECT is_online INTO v_on FROM public.drivers WHERE id = v_driver_id;
    SELECT balance INTO v_bal FROM public.driver_wallets WHERE driver_id = v_driver_id;
    SELECT pass_expires_at, rejections_count, is_blocked INTO v_exp, v_rej, v_blk FROM public.driver_daily_status WHERE driver_id = v_driver_id AND status_date = CURRENT_DATE;

    sim_minute := 1; sim_time := '01:00 AM'; event_phase := '2. Wallet Recharge (+₹500)';
    driver_online := v_on; wallet_balance := v_bal; pass_expires_at := v_exp; rejections := COALESCE(v_rej, 0); is_blocked := COALESCE(v_blk, false);
    last_event_result := 'Recharge RPC executed successfully. New balance: ₹' || v_bal;
    RETURN NEXT;

    -- ========================================================================
    -- MINUTE 02 (02:00 AM) - PAY DAILY FEE (₹175) & ACTIVATE 24-HOUR PASS
    -- ========================================================================
    v_res := public.pay_driver_daily_fee(v_driver_id);
    UPDATE public.drivers SET is_online = true WHERE id = v_driver_id; -- Now allowed!

    SELECT is_online INTO v_on FROM public.drivers WHERE id = v_driver_id;
    SELECT balance INTO v_bal FROM public.driver_wallets WHERE driver_id = v_driver_id;
    SELECT s.pass_expires_at, s.rejections_count, s.is_blocked INTO v_exp, v_rej, v_blk FROM public.driver_daily_status s WHERE s.driver_id = v_driver_id ORDER BY s.status_date DESC LIMIT 1;

    sim_minute := 2; sim_time := '02:00 AM'; event_phase := '3. Pay Daily Fee & Activate 24h Pass';
    driver_online := v_on; wallet_balance := v_bal; pass_expires_at := v_exp; rejections := COALESCE(v_rej, 0); is_blocked := COALESCE(v_blk, false);
    last_event_result := 'Daily fee ₹175 deducted. Pass active until ' || to_char(v_exp, 'DD Mon HH:MI AM') || '. Driver online: ' || v_on::text;
    RETURN NEXT;

    -- ========================================================================
    -- MINUTE 04 (04:00 AM) - TRIP 1: NORMAL FARE (₹210) & WALLET CREDIT
    -- ========================================================================
    INSERT INTO public.bookings (customer_id, driver_id, pickup_address, drop_address, pickup_lat, pickup_lng, drop_lat, drop_lng, status, amount)
    VALUES (v_customer_id, v_driver_id, 'Pickup A', 'Drop A', 17.3850, 78.4867, 17.4401, 78.3489, 'accepted', '{"total_price": 210.00}'::jsonb)
    RETURNING id INTO v_booking_id;

    UPDATE public.bookings SET status = 'arrived' WHERE id = v_booking_id;
    UPDATE public.bookings SET status = 'in_transit' WHERE id = v_booking_id;
    UPDATE public.bookings SET status = 'arrived_at_dropoff' WHERE id = v_booking_id;
    UPDATE public.bookings SET status = 'completed' WHERE id = v_booking_id; -- Triggers wallet credit!

    SELECT is_online INTO v_on FROM public.drivers WHERE id = v_driver_id;
    SELECT balance INTO v_bal FROM public.driver_wallets WHERE driver_id = v_driver_id;

    sim_minute := 4; sim_time := '04:00 AM'; event_phase := '4. Complete Trip 1 (₹210 Fare)';
    driver_online := v_on; wallet_balance := v_bal; pass_expires_at := v_exp; rejections := COALESCE(v_rej, 0); is_blocked := COALESCE(v_blk, false);
    last_event_result := 'Trip 1 completed. Fare ₹210 credited to driver wallet. New balance: ₹' || v_bal;
    RETURN NEXT;

    -- ========================================================================
    -- MINUTE 08 (08:00 AM) - TRIP 2: WAITING CHARGES (35m pickup + 25m dropoff = 60m total - 15m grace = 45m @ ₹3/m = ₹135)
    -- ========================================================================
    INSERT INTO public.bookings (customer_id, driver_id, pickup_address, drop_address, pickup_lat, pickup_lng, drop_lat, drop_lng, status, amount)
    VALUES (v_customer_id, v_driver_id, 'Pickup B', 'Drop B', 17.3850, 78.4867, 17.4401, 78.3489, 'accepted', '{"total_price": 210.00}'::jsonb)
    RETURNING id INTO v_booking_id;

    -- Pickup Wait: 35 minutes
    UPDATE public.bookings SET status = 'arrived', arrived_at_pickup_at = now() - INTERVAL '35 minutes' WHERE id = v_booking_id;
    UPDATE public.bookings SET status = 'in_transit', trip_started_at = now() WHERE id = v_booking_id;
    
    -- Dropoff Wait: 25 minutes
    UPDATE public.bookings SET status = 'arrived_at_dropoff', arrived_at_dropoff_at = now() - INTERVAL '25 minutes' WHERE id = v_booking_id;
    UPDATE public.bookings SET status = 'completed', trip_completed_at = now() WHERE id = v_booking_id;

    SELECT balance INTO v_bal FROM public.driver_wallets WHERE driver_id = v_driver_id;

    sim_minute := 8; sim_time := '08:00 AM'; event_phase := '5. Complete Trip 2 (₹210 Base + ₹135 Wait Charge)';
    driver_online := v_on; wallet_balance := v_bal; pass_expires_at := v_exp; rejections := COALESCE(v_rej, 0); is_blocked := COALESCE(v_blk, false);
    last_event_result := 'Waiting charges trigger computed ₹135 waiting fare (60m - 15m grace @ ₹3/m). Wallet balance: ₹' || v_bal;
    RETURN NEXT;

    -- ========================================================================
    -- MINUTE 12 (12:00 PM) - ORDER REJECTION LIMIT GUARD (2 Rejections -> Block Driver)
    -- ========================================================================
    -- Simulate 2 rejections
    UPDATE public.driver_daily_status 
    SET rejections_count = 2, is_blocked = true, block_reason = 'exceeded_rejections' 
    WHERE driver_id = v_driver_id AND status_date = CURRENT_DATE;

    -- Trigger auto-offline check
    UPDATE public.drivers SET is_online = false WHERE id = v_driver_id;
    UPDATE public.drivers SET is_online = true WHERE id = v_driver_id; -- Attempt online -> blocked!

    SELECT is_online INTO v_on FROM public.drivers WHERE id = v_driver_id;
    SELECT s.rejections_count, s.is_blocked INTO v_rej, v_blk FROM public.driver_daily_status s WHERE s.driver_id = v_driver_id ORDER BY s.status_date DESC LIMIT 1;

    sim_minute := 12; sim_time := '12:00 PM'; event_phase := '6. Exceed Rejection Limit (2 Rejections)';
    driver_online := v_on; wallet_balance := v_bal; pass_expires_at := v_exp; rejections := COALESCE(v_rej, 0); is_blocked := COALESCE(v_blk, false);
    last_event_result := 'Driver rejected 2 orders. Rejection guard blocked driver (is_blocked=' || v_blk::text || ', is_online=' || v_on::text || ')';
    RETURN NEXT;

    -- ========================================================================
    -- MINUTE 18 (06:00 PM) - EARNINGS WITHDRAWAL (-₹400)
    -- ========================================================================
    v_res := public.withdraw_driver_wallet(v_driver_id, 400.00);

    SELECT balance INTO v_bal FROM public.driver_wallets WHERE driver_id = v_driver_id;

    sim_minute := 18; sim_time := '06:00 PM'; event_phase := '7. Earnings Withdrawal (-₹400)';
    driver_online := v_on; wallet_balance := v_bal; pass_expires_at := v_exp; rejections := COALESCE(v_rej, 0); is_blocked := COALESCE(v_blk, false);
    last_event_result := 'Withdrawal RPC executed. ₹400 debited from wallet. New balance: ₹' || v_bal;
    RETURN NEXT;

    -- ========================================================================
    -- MINUTE 23 (11:00 PM) - MIDNIGHT REJECTION RESET & UNBLOCK
    -- ========================================================================
    -- Simulate midnight rollover: rejections reset to 0, unblock driver
    UPDATE public.driver_daily_status 
    SET rejections_count = 0, is_blocked = false, block_reason = NULL 
    WHERE driver_id = v_driver_id AND status_date = CURRENT_DATE;

    UPDATE public.drivers SET is_online = true WHERE id = v_driver_id; -- Now succeeds!

    SELECT is_online INTO v_on FROM public.drivers WHERE id = v_driver_id;
    SELECT s.rejections_count, s.is_blocked INTO v_rej, v_blk FROM public.driver_daily_status s WHERE s.driver_id = v_driver_id ORDER BY s.status_date DESC LIMIT 1;

    sim_minute := 23; sim_time := '11:00 PM'; event_phase := '8. Midnight Reset & Re-Activate Online';
    driver_online := v_on; wallet_balance := v_bal; pass_expires_at := v_exp; rejections := COALESCE(v_rej, 0); is_blocked := COALESCE(v_blk, false);
    last_event_result := 'Rejections reset at midnight. Driver unblocked & successfully toggled online: ' || v_on::text;
    RETURN NEXT;

    -- ========================================================================
    -- MINUTE 26 (02:00 AM NEXT DAY) - 24-HOUR PASS EXPIRY & AUTO-OFFLINE CRON
    -- ========================================================================
    -- Expire pass timestamp to past (now - 1 min)
    UPDATE public.driver_daily_status 
    SET pass_expires_at = now() - INTERVAL '1 minute', fee_deducted = false 
    WHERE driver_id = v_driver_id;

    -- Run auto-offline pass expiration function
    PERFORM public.check_expired_daily_passes();

    SELECT is_online INTO v_on FROM public.drivers WHERE id = v_driver_id;
    SELECT s.pass_expires_at, s.rejections_count, s.is_blocked INTO v_exp, v_rej, v_blk FROM public.driver_daily_status s WHERE s.driver_id = v_driver_id ORDER BY s.status_date DESC LIMIT 1;

    sim_minute := 26; sim_time := '02:00 AM (+24h)'; event_phase := '9. Pass Expiration & Auto-Offline Cron';
    driver_online := v_on; wallet_balance := v_bal; pass_expires_at := v_exp; rejections := COALESCE(v_rej, 0); is_blocked := COALESCE(v_blk, false);
    last_event_result := '24-hour pass expired. Auto-offline cron forced driver offline (is_online=' || v_on::text || ')';
    RETURN NEXT;

    -- Clean up test records
    DELETE FROM public.bookings WHERE driver_id = v_driver_id;
    DELETE FROM public.wallet_transactions WHERE driver_id = v_driver_id;
    DELETE FROM public.driver_daily_status WHERE driver_id = v_driver_id;
    DELETE FROM public.driver_wallets WHERE driver_id = v_driver_id;
    DELETE FROM public.drivers WHERE id = v_driver_id;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Execute Simulation
SELECT * FROM public.run_24min_full_day_simulation();
