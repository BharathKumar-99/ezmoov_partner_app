-- ==========================================
-- EZMOOV PARTNER APP - CRON JOB SIMULATION SCRIPT
-- Demonstrating the 4:50 AM Offline Cron Job and 5:00 AM Daily Wallet Deduction Cron Job
-- ==========================================

-- STEP 0: CLEANUP PREVIOUS TEST SIMULATION DATA
DELETE FROM public.wallet_transactions WHERE description LIKE '%[SIMULATION]%';
DELETE FROM public.driver_notifications WHERE title LIKE '%[SIMULATION]%' OR message LIKE '%[SIMULATION]%';

-- STEP 1: CREATE TEST DRIVERS (Simulating Initial State prior to 4:50 AM)
DO $$
DECLARE
    v_driver_a UUID;
    v_driver_b UUID;
    v_driver_c UUID;
    v_today DATE := CURRENT_DATE;
BEGIN
    RAISE NOTICE '==================================================';
    RAISE NOTICE 'STARTING 4:50 AM & 5:00 AM CRON JOB SIMULATION';
    RAISE NOTICE '==================================================';

    -- Fetch 3 driver IDs or insert dummy drivers if none exist
    SELECT id INTO v_driver_a FROM public.drivers WHERE is_verified = true LIMIT 1;
    
    IF v_driver_a IS NULL THEN
        INSERT INTO public.drivers (name, email, phone, is_online, is_verified, vehicle_type)
        VALUES ('Test Driver A (Bike)', 'drivera@test.com', '+919999900001', true, true, '2 Wheeler')
        RETURNING id INTO v_driver_a;

        INSERT INTO public.drivers (name, email, phone, is_online, is_verified, vehicle_type)
        VALUES ('Test Driver B (Tata Ace)', 'driverb@test.com', '+919999900002', true, true, '7ft Tata Ace')
        RETURNING id INTO v_driver_b;

        INSERT INTO public.drivers (name, email, phone, is_online, is_verified, vehicle_type)
        VALUES ('Test Driver C (Mini 3W)', 'driverc@test.com', '+919999900003', false, true, 'Mini 3W')
        RETURNING id INTO v_driver_c;
    END IF;

    RAISE NOTICE '1. Initial State before 4:50 AM:';
    RAISE NOTICE '   - Drivers set to ONLINE: Driver A, Driver B';
    RAISE NOTICE '   - Drivers set to OFFLINE: Driver C';

    -- STEP 2: RUN CRON JOB 1 (4:50 AM) - Make All Drivers Offline
    RAISE NOTICE '--------------------------------------------------';
    RAISE NOTICE '2. EXECUTING 4:50 AM CRON JOB (daily-450am-make-drivers-offline)...';
    PERFORM public.make_all_drivers_offline();
    RAISE NOTICE '   ✅ 4:50 AM Cron Job Complete: All active drivers have been set to is_online = false.';

    -- STEP 3: RUN CRON JOB 2 (5:00 AM) - Process Daily Wallet Deductions
    RAISE NOTICE '--------------------------------------------------';
    RAISE NOTICE '3. EXECUTING 5:00 AM CRON JOB (daily-5am-wallet-deduction)...';
    PERFORM public.process_daily_wallet_deductions();
    RAISE NOTICE '   ✅ 5:00 AM Cron Job Complete: Daily fees processed, statuses recorded, notifications dispatched.';

    RAISE NOTICE '==================================================';
    RAISE NOTICE 'CRON JOB SIMULATION FINISHED SUCCESSFULLY';
    RAISE NOTICE '==================================================';
END $$;

-- DISPLAY SIMULATION RESULTS
SELECT 
    d.id AS driver_id,
    d.name AS driver_name,
    d.vehicle_type,
    d.is_online AS is_online_after_450am_cron,
    COALESCE(w.balance, 0.00) AS wallet_balance,
    s.daily_fee,
    s.fee_deducted,
    s.is_blocked,
    s.block_reason
FROM public.drivers d
LEFT JOIN public.driver_wallets w ON w.driver_id = d.id
LEFT JOIN public.driver_daily_status s ON s.driver_id = d.id AND s.status_date = CURRENT_DATE
ORDER BY d.created_at DESC
LIMIT 5;
