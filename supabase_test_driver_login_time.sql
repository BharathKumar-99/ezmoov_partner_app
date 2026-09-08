-- ============================================================================
-- EZMOOV PARTNER APP: DRIVER_LOGIN_TIME TRIGGER AUTOMATED TEST SUITE
-- Tests all 5 scenarios & returns a clear tabular PASS/FAIL report
-- ============================================================================

DO $$
DECLARE
    v_test_driver_id UUID;
    v_rec RECORD;
    v_count INT;
    v_start_time TIMESTAMPTZ;
    v_end_time TIMESTAMPTZ;
    v_total_time TEXT;
    v_res_1_1 TEXT := 'FAIL';
    v_res_1_2 TEXT := 'FAIL';
    v_res_2_1 TEXT := 'FAIL';
    v_res_2_2 TEXT := 'FAIL';
    v_res_3_1 TEXT := 'FAIL';
    v_res_4_1 TEXT := 'FAIL';
    v_res_4_2 TEXT := 'FAIL';
    v_res_5_1 TEXT := 'FAIL';
    v_res_5_2 TEXT := 'FAIL';
BEGIN
    -- Create Temporary Table to Store Test Results
    CREATE TEMP TABLE IF NOT EXISTS temp_login_trigger_test_results (
        scenario_id TEXT PRIMARY KEY,
        scenario_name TEXT NOT NULL,
        status TEXT NOT NULL,
        details TEXT NOT NULL
    ) ON COMMIT DROP;

    -- 0. Get or Create a Dedicated Test Driver
    SELECT id INTO v_test_driver_id
    FROM public.drivers
    WHERE phone = '+919999900001'
    LIMIT 1;

    IF v_test_driver_id IS NULL THEN
        INSERT INTO public.drivers (
            name,
            email,
            phone,
            is_online,
            is_verified,
            is_vehicle_added,
            is_documents_uploaded,
            is_bank_details_added
        ) VALUES (
            'Trigger Test Driver',
            'triggertest@ezmoov.com',
            '+919999900001',
            false,
            true,
            true,
            true,
            true
        ) RETURNING id INTO v_test_driver_id;
    END IF;

    -- Clean any existing test login records for this driver
    DELETE FROM public.driver_login_time WHERE driver_id = v_test_driver_id;
    UPDATE public.drivers SET is_online = false WHERE id = v_test_driver_id;

    -- ========================================================================
    -- 1. FRESH DRIVER & INITIAL TOGGLE (COLD START)
    -- ========================================================================

    -- Scenario 1.1: First-time Online Toggle (No prior records for today)
    UPDATE public.drivers SET is_online = true WHERE id = v_test_driver_id;

    SELECT COUNT(*), start_time, end_time, total_time 
    INTO v_count, v_start_time, v_end_time, v_total_time
    FROM public.driver_login_time 
    WHERE driver_id = v_test_driver_id AND date = CURRENT_DATE
    GROUP BY start_time, end_time, total_time;

    IF v_count = 1 AND v_start_time IS NOT NULL AND v_end_time IS NULL THEN
        v_res_1_1 := 'PASS';
    END IF;
    INSERT INTO temp_login_trigger_test_results VALUES (
        '1.1',
        'First-time Online Toggle (Cold Start)',
        v_res_1_1,
        format('Rows: %s, start_time: %s, end_time: %s', v_count, v_start_time, v_end_time)
    );

    -- Scenario 1.2: Immediate Offline Toggle
    PERFORM pg_sleep(1); -- sleep 1s to ensure non-zero interval
    UPDATE public.drivers SET is_online = false WHERE id = v_test_driver_id;

    SELECT COUNT(*), start_time, end_time, total_time 
    INTO v_count, v_start_time, v_end_time, v_total_time
    FROM public.driver_login_time 
    WHERE driver_id = v_test_driver_id AND date = CURRENT_DATE
    GROUP BY start_time, end_time, total_time;

    IF v_count = 1 AND v_end_time IS NOT NULL AND v_total_time IS NOT NULL THEN
        v_res_1_2 := 'PASS';
    END IF;
    INSERT INTO temp_login_trigger_test_results VALUES (
        '1.2',
        'Immediate Offline Toggle',
        v_res_1_2,
        format('Rows: %s, end_time: %s, total_time: %s', v_count, v_end_time, v_total_time)
    );

    -- ========================================================================
    -- 2. RE-LOGGING ON THE SAME DAY (MULTIPLE SESSIONS)
    -- ========================================================================

    -- Scenario 2.1: Go Online with Completed Previous Session Today
    UPDATE public.drivers SET is_online = true WHERE id = v_test_driver_id;

    SELECT COUNT(*) INTO v_count
    FROM public.driver_login_time 
    WHERE driver_id = v_test_driver_id AND date = CURRENT_DATE;

    SELECT COUNT(*) INTO v_rec
    FROM public.driver_login_time 
    WHERE driver_id = v_test_driver_id AND date = CURRENT_DATE AND end_time IS NULL;

    IF v_count = 2 AND v_rec.count = 1 THEN
        v_res_2_1 := 'PASS';
    END IF;
    INSERT INTO temp_login_trigger_test_results VALUES (
        '2.1',
        'Go Online with Completed Previous Session Today',
        v_res_2_1,
        format('Total rows today: %s, Open sessions: %s', v_count, v_rec.count)
    );

    -- Scenario 2.2: Second Offline Toggle of the Day
    PERFORM pg_sleep(1);
    UPDATE public.drivers SET is_online = false WHERE id = v_test_driver_id;

    SELECT COUNT(*) INTO v_rec
    FROM public.driver_login_time 
    WHERE driver_id = v_test_driver_id AND date = CURRENT_DATE AND end_time IS NULL;

    SELECT COUNT(*) INTO v_count
    FROM public.driver_login_time 
    WHERE driver_id = v_test_driver_id AND date = CURRENT_DATE AND end_time IS NOT NULL;

    IF v_rec.count = 0 AND v_count = 2 THEN
        v_res_2_2 := 'PASS';
    END IF;
    INSERT INTO temp_login_trigger_test_results VALUES (
        '2.2',
        'Second Offline Toggle of the Day',
        v_res_2_2,
        format('Completed sessions today: %s, Open sessions: %s', v_count, v_rec.count)
    );

    -- ========================================================================
    -- 3. EDGE CASE: EXISTING RECORD WITH MISSING START_TIME
    -- ========================================================================

    -- Scenario 3.1: Go Online with Orphaned Pre-allocated Record
    -- Clean today's records for a fresh test of this edge case
    DELETE FROM public.driver_login_time WHERE driver_id = v_test_driver_id AND date = CURRENT_DATE;
    UPDATE public.drivers SET is_online = false WHERE id = v_test_driver_id;

    -- Insert orphaned record with start_time IS NULL and end_time IS NULL
    INSERT INTO public.driver_login_time (
        driver_id,
        start_time,
        end_time,
        total_time,
        date
    ) VALUES (
        v_test_driver_id,
        NULL,
        NULL,
        NULL,
        CURRENT_DATE
    );

    -- Driver goes online
    UPDATE public.drivers SET is_online = true WHERE id = v_test_driver_id;

    SELECT COUNT(*), MAX(start_time), MAX(end_time)
    INTO v_count, v_start_time, v_end_time
    FROM public.driver_login_time 
    WHERE driver_id = v_test_driver_id AND date = CURRENT_DATE;

    IF v_count = 1 AND v_start_time IS NOT NULL AND v_end_time IS NULL THEN
        v_res_3_1 := 'PASS';
    END IF;
    INSERT INTO temp_login_trigger_test_results VALUES (
        '3.1',
        'Go Online with Orphaned Pre-allocated Record',
        v_res_3_1,
        format('Total rows: %s (No duplicates), populated start_time: %s', v_count, v_start_time)
    );

    -- ========================================================================
    -- 4. DEFENSIVE & NO-OP EDGE CASES
    -- ========================================================================

    -- Close active session from 3.1
    UPDATE public.drivers SET is_online = false WHERE id = v_test_driver_id;

    -- Scenario 4.1: Going Offline without an Active Online Session
    SELECT COUNT(*) INTO v_count FROM public.driver_login_time WHERE driver_id = v_test_driver_id;
    -- Redundant offline update
    UPDATE public.drivers SET is_online = false WHERE id = v_test_driver_id;
    SELECT COUNT(*) INTO v_rec FROM public.driver_login_time WHERE driver_id = v_test_driver_id;

    IF v_count = v_rec.count THEN
        v_res_4_1 := 'PASS';
    END IF;
    INSERT INTO temp_login_trigger_test_results VALUES (
        '4.1',
        'Going Offline without Active Online Session (No-Op)',
        v_res_4_1,
        format('Row count unchanged: %s', v_count)
    );

    -- Scenario 4.2: Redundant Online Update
    UPDATE public.drivers SET is_online = true WHERE id = v_test_driver_id;
    SELECT COUNT(*), MAX(start_time) INTO v_count, v_start_time 
    FROM public.driver_login_time WHERE driver_id = v_test_driver_id AND date = CURRENT_DATE AND end_time IS NULL;

    -- Redundant online update (TRUE -> TRUE)
    UPDATE public.drivers SET is_online = true WHERE id = v_test_driver_id;
    SELECT COUNT(*), MAX(start_time) INTO v_rec, v_end_time 
    FROM public.driver_login_time WHERE driver_id = v_test_driver_id AND date = CURRENT_DATE AND end_time IS NULL;

    IF v_count = 1 AND v_rec.count = 1 AND v_start_time = v_end_time THEN
        v_res_4_2 := 'PASS';
    END IF;
    INSERT INTO temp_login_trigger_test_results VALUES (
        '4.2',
        'Redundant Online Update (No-Op)',
        v_res_4_2,
        format('Open sessions: %s, Start time unchanged: %s', v_rec.count, v_start_time)
    );

    -- ========================================================================
    -- 5. DATE BOUNDARY & OVERNIGHT EDGE CASES
    -- ========================================================================

    -- Clean slate for date boundary tests
    DELETE FROM public.driver_login_time WHERE driver_id = v_test_driver_id;
    UPDATE public.drivers SET is_online = false WHERE id = v_test_driver_id;

    -- Scenario 5.1: Going Online when Past Dates exist
    -- Insert completed record for yesterday
    INSERT INTO public.driver_login_time (
        driver_id,
        start_time,
        end_time,
        total_time,
        date
    ) VALUES (
        v_test_driver_id,
        now() - INTERVAL '1 day' - INTERVAL '4 hours',
        now() - INTERVAL '1 day',
        '4 hrs 0 mins',
        CURRENT_DATE - INTERVAL '1 day'
    );

    -- Go online today
    UPDATE public.drivers SET is_online = true WHERE id = v_test_driver_id;

    SELECT COUNT(*) INTO v_count
    FROM public.driver_login_time 
    WHERE driver_id = v_test_driver_id AND date = CURRENT_DATE AND end_time IS NULL;

    IF v_count = 1 THEN
        v_res_5_1 := 'PASS';
    END IF;
    INSERT INTO temp_login_trigger_test_results VALUES (
        '5.1',
        'Going Online when Past Dates exist',
        v_res_5_1,
        format('Brand new row created for CURRENT_DATE: %s', v_count)
    );

    -- Scenario 5.2: Going Offline when an Active Session started on Previous Date (Overnight shift)
    DELETE FROM public.driver_login_time WHERE driver_id = v_test_driver_id;
    
    -- Insert open overnight session started yesterday at 10 PM
    INSERT INTO public.driver_login_time (
        driver_id,
        start_time,
        end_time,
        total_time,
        date
    ) VALUES (
        v_test_driver_id,
        now() - INTERVAL '8 hours',
        NULL,
        NULL,
        CURRENT_DATE - INTERVAL '1 day'
    );

    -- Driver is set to online matching the open session, then goes offline today
    UPDATE public.drivers SET is_online = true WHERE id = v_test_driver_id;
    UPDATE public.drivers SET is_online = false WHERE id = v_test_driver_id;

    SELECT COUNT(*), MAX(end_time), MAX(total_time)
    INTO v_count, v_end_time, v_total_time
    FROM public.driver_login_time 
    WHERE driver_id = v_test_driver_id AND date = (CURRENT_DATE - INTERVAL '1 day') AND end_time IS NOT NULL;

    IF v_count = 1 AND v_end_time IS NOT NULL AND v_total_time IS NOT NULL THEN
        v_res_5_2 := 'PASS';
    END IF;
    INSERT INTO temp_login_trigger_test_results VALUES (
        '5.2',
        'Going Offline on Overnight Shift (Cross-Midnight)',
        v_res_5_2,
        format('Closed overnight session: %s, calculated total_time: %s', v_count, v_total_time)
    );

    -- Clean up test records
    DELETE FROM public.driver_login_time WHERE driver_id = v_test_driver_id;
    UPDATE public.drivers SET is_online = false WHERE id = v_test_driver_id;
END $$;

-- Query and display test results table
SELECT 
    scenario_id AS "Scenario",
    scenario_name AS "Test Case Description",
    CASE 
        WHEN status = 'PASS' THEN '✅ PASS'
        ELSE '❌ FAIL'
    END AS "Status",
    details AS "Verification Details"
FROM temp_login_trigger_test_results
ORDER BY scenario_id;
