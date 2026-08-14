-- ============================================================================
-- EZMOOV PARTNER APP: HARD TEST SUITE FOR DRIVER DAILY FEE & ONLINE GUARD
-- Enforces 24-Hour Daily Pass at Database Level & Tests All Scenarios
-- ============================================================================

-- Ensure required columns exist
ALTER TABLE public.driver_daily_status ADD COLUMN IF NOT EXISTS pass_expires_at TIMESTAMPTZ;

-- Drop function if exists to avoid signature conflict
DROP FUNCTION IF EXISTS public.check_expired_daily_passes();

CREATE OR REPLACE FUNCTION public.check_expired_daily_passes()
RETURNS INTEGER AS $$
DECLARE
    v_count INTEGER := 0;
BEGIN
    UPDATE public.drivers d
    SET is_online = false, updated_at = now()
    FROM public.driver_daily_status s
    WHERE d.id = s.driver_id
      AND d.is_online = true
      AND (s.pass_expires_at IS NULL OR s.pass_expires_at <= now());
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.prevent_online_without_pass()
RETURNS TRIGGER AS $$
DECLARE
    v_pass_expires_at TIMESTAMPTZ;
    v_is_blocked BOOLEAN := false;
    v_rejections INTEGER := 0;
BEGIN
    IF NEW.is_online = true THEN
        SELECT pass_expires_at, COALESCE(is_blocked, false), COALESCE(rejections_count, 0)
        INTO v_pass_expires_at, v_is_blocked, v_rejections
        FROM public.driver_daily_status
        WHERE driver_id = NEW.id;

        IF v_is_blocked = true OR v_rejections >= 2 OR v_pass_expires_at IS NULL OR v_pass_expires_at <= now() THEN
            NEW.is_online := false;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_prevent_online_without_pass ON public.drivers;

CREATE TRIGGER trg_prevent_online_without_pass
BEFORE INSERT OR UPDATE OF is_online ON public.drivers
FOR EACH ROW
EXECUTE FUNCTION public.prevent_online_without_pass();


-- ============================================================================
-- PL/SQL HARD TEST SUITE FUNCTION (Returns Test Results as Table)
-- ============================================================================
DROP FUNCTION IF EXISTS public.run_daily_fee_hard_test();

CREATE OR REPLACE FUNCTION public.run_daily_fee_hard_test()
RETURNS TABLE (
    test_case TEXT,
    description TEXT,
    verification_result JSONB
) AS $$
DECLARE
    v_driver_id UUID;
    v_pay_res1 JSONB;
    v_pay_res2 JSONB;
    v_recharge_res JSONB;
    v_cron_count INTEGER;
    v_is_online1 BOOLEAN;
    v_is_online2 BOOLEAN;
    v_is_online3 BOOLEAN;
    v_is_online4 BOOLEAN;
    v_bal1 NUMERIC(10, 2);
    v_bal2 NUMERIC(10, 2);
    v_pass_exp TIMESTAMPTZ;
BEGIN
    -- 1. Get or create test driver
    SELECT id INTO v_driver_id FROM public.drivers LIMIT 1;
    IF v_driver_id IS NULL THEN
        INSERT INTO public.drivers (name, phone, is_online) 
        VALUES ('Test Driver', '+919999900000', false) 
        RETURNING id INTO v_driver_id;
    END IF;

    -- Reset state for Test 1
    INSERT INTO public.driver_wallets (driver_id, balance) 
    VALUES (v_driver_id, 0.00) 
    ON CONFLICT (driver_id) DO UPDATE SET balance = 0.00;
    
    UPDATE public.drivers SET is_online = false WHERE id = v_driver_id;
    DELETE FROM public.driver_daily_status WHERE driver_id = v_driver_id;

    -- TEST 1: Pay daily fee with 0 balance & attempt online switch
    SELECT public.pay_driver_daily_fee(v_driver_id) INTO v_pay_res1;
    UPDATE public.drivers SET is_online = true WHERE id = v_driver_id;
    SELECT is_online INTO v_is_online1 FROM public.drivers WHERE id = v_driver_id;

    test_case := 'TEST 1';
    description := 'Unpaid / ₹0 Balance Guard';
    verification_result := jsonb_build_object(
        'pay_daily_fee_response', v_pay_res1,
        'db_trigger_blocked_online', NOT v_is_online1,
        'driver_is_online', v_is_online1
    );
    RETURN NEXT;

    -- TEST 2: Recharge ₹500, Pay Fee ₹100 & Activate 24-Hr Pass
    SELECT public.recharge_driver_wallet(v_driver_id, 500.00) INTO v_recharge_res;
    SELECT public.pay_driver_daily_fee(v_driver_id) INTO v_pay_res2;
    UPDATE public.drivers SET is_online = true WHERE id = v_driver_id;
    SELECT is_online INTO v_is_online2 FROM public.drivers WHERE id = v_driver_id;
    SELECT balance INTO v_bal1 FROM public.driver_wallets WHERE driver_id = v_driver_id;

    test_case := 'TEST 2';
    description := 'Recharge ₹500, Pay Fee ₹100 & Activate 24-Hr Pass';
    verification_result := jsonb_build_object(
        'pay_fee_response', v_pay_res2,
        'wallet_balance_after_fee', v_bal1,
        'driver_is_online_success', v_is_online2
    );
    RETURN NEXT;

    -- TEST 3: Expire Pass, Auto-Offline Cron & Re-Block Guard
    UPDATE public.driver_daily_status 
    SET pass_expires_at = now() - INTERVAL '1 minute' 
    WHERE driver_id = v_driver_id;

    SELECT public.check_expired_daily_passes() INTO v_cron_count;
    SELECT is_online INTO v_is_online3 FROM public.drivers WHERE id = v_driver_id;

    -- Attempt to force online while pass is expired
    UPDATE public.drivers SET is_online = true WHERE id = v_driver_id;
    SELECT is_online INTO v_is_online4 FROM public.drivers WHERE id = v_driver_id;

    test_case := 'TEST 3';
    description := 'Pass Expiration, Auto-Offline Cron & Re-Block Guard';
    verification_result := jsonb_build_object(
        'cron_auto_offlined_drivers_count', v_cron_count,
        'is_online_after_cron', v_is_online3,
        'trigger_blocked_forced_online', NOT v_is_online4
    );
    RETURN NEXT;

    -- TEST 4: Re-Pay Daily Fee (₹100) & Go Online Successfully
    SELECT public.pay_driver_daily_fee(v_driver_id) INTO v_pay_res2;
    UPDATE public.drivers SET is_online = true WHERE id = v_driver_id;
    SELECT is_online INTO v_is_online4 FROM public.drivers WHERE id = v_driver_id;
    SELECT balance INTO v_bal2 FROM public.driver_wallets WHERE driver_id = v_driver_id;
    SELECT pass_expires_at INTO v_pass_exp FROM public.driver_daily_status WHERE driver_id = v_driver_id;

    test_case := 'TEST 4';
    description := 'Re-Pay Daily Fee (₹100) & Go Online Successfully';
    verification_result := jsonb_build_object(
        'repay_fee_response', v_pay_res2,
        'final_wallet_balance', v_bal2,
        'final_is_online', v_is_online4,
        'new_pass_expires_at', v_pass_exp
    );
    RETURN NEXT;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Execute Hard Test Suite
SELECT * FROM public.run_daily_fee_hard_test();
