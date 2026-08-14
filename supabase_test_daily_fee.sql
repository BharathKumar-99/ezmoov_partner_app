-- ============================================================================
-- EZMOOV PARTNER APP: 24-HOUR DAILY FEE & ONLINE GUARD SIMULATION TEST SCRIPT
-- Returns tabular SELECT results directly in Supabase SQL Editor 'Results' grid
-- ============================================================================

-- Ensure driver_daily_status has pass_expires_at column
ALTER TABLE public.driver_daily_status ADD COLUMN IF NOT EXISTS pass_expires_at TIMESTAMPTZ;

WITH test_driver AS (
    SELECT id AS driver_id FROM public.drivers LIMIT 1
),
-- Test Case 1: Attempt to pay daily fee with 0 balance
zero_balance_test AS (
    SELECT 
        d.driver_id,
        -- Reset wallet balance to 0 for test
        (UPDATE public.driver_wallets SET balance = 0.00 WHERE driver_id = d.driver_id) AS reset_op,
        -- Attempt daily fee payment with 0 balance
        public.pay_driver_daily_fee(d.driver_id) AS insufficient_pay_res
    FROM test_driver d
),
-- Test Case 2: Recharge wallet with ₹500 and pay daily fee (₹100)
recharge_op AS (
    SELECT 
        z.driver_id,
        public.recharge_driver_wallet(z.driver_id, 500.00) AS recharge_res
    FROM zero_balance_test z
),
successful_pay_test AS (
    SELECT 
        r.driver_id,
        r.recharge_res,
        public.pay_driver_daily_fee(r.driver_id) AS pay_success_res
    FROM recharge_op r
),
-- Test Case 3: Verify pass expiration check (check_expired_daily_passes)
expiry_sim AS (
    SELECT 
        s.driver_id,
        s.pay_success_res,
        -- Set driver online & set pass expired 1 min ago
        (UPDATE public.drivers SET is_online = true WHERE id = s.driver_id) AS set_online_op,
        (UPDATE public.driver_daily_status SET pass_expires_at = now() - INTERVAL '1 minute' WHERE driver_id = s.driver_id) AS set_expired_op,
        -- Run pass expiration check
        public.check_expired_daily_passes() AS expired_check_res
    FROM successful_pay_test s
),
-- Fetch final driver online status after cron check
final_driver_status AS (
    SELECT 
        e.driver_id,
        e.pay_success_res,
        e.expired_check_res,
        d.is_online AS final_is_online,
        dw.balance AS final_wallet_balance,
        s.pass_expires_at AS current_pass_expiry
    FROM expiry_sim e
    JOIN public.drivers d ON d.id = e.driver_id
    JOIN public.driver_wallets dw ON dw.driver_id = e.driver_id
    JOIN public.driver_daily_status s ON s.driver_id = e.driver_id
)
SELECT 
    'Test 1: Insufficient Balance' AS test_name,
    'Attempt pay daily fee with ₹0 balance' AS action,
    (SELECT insufficient_pay_res FROM zero_balance_test) AS result
UNION ALL
SELECT 
    'Test 2: Successful Payment & 24-Hr Pass Activation' AS test_name,
    'Recharge ₹500 & Pay ₹100 Daily Fee' AS action,
    pay_success_res AS result
FROM final_driver_status
UNION ALL
SELECT 
    'Test 3: Pass Expiry Auto-Offline Cron' AS test_name,
    'Set pass expired & run check_expired_daily_passes()' AS action,
    jsonb_build_object(
        'cron_res', expired_check_res,
        'driver_is_online_after_expiry', final_is_online,
        'final_wallet_balance', final_wallet_balance,
        'pass_expires_at', current_pass_expiry
    ) AS result
FROM final_driver_status;
