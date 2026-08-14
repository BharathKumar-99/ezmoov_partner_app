-- ============================================================================
-- EZMOOV PARTNER APP: COMPLETE WALLET & WITHDRAWAL SIMULATION TEST SCRIPT
-- Returns result table directly in Supabase SQL Editor 'Results' grid
-- ============================================================================

-- Safely add missing columns to driver_payouts table
ALTER TABLE public.driver_payouts ADD COLUMN IF NOT EXISTS payout_method TEXT DEFAULT 'Bank Transfer';
ALTER TABLE public.driver_payouts ADD COLUMN IF NOT EXISTS reference_id TEXT;
ALTER TABLE public.driver_payouts ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();

WITH test_driver AS (
    SELECT id AS driver_id FROM public.drivers LIMIT 1
),
step1_recharge AS (
    SELECT 
        d.driver_id,
        public.recharge_driver_wallet(d.driver_id, 1000.00) AS recharge_res
    FROM test_driver d
),
step2_fee AS (
    SELECT 
        s.driver_id,
        s.recharge_res,
        public.pay_driver_daily_fee(s.driver_id) AS fee_res
    FROM step1_recharge s
),
step3_withdraw AS (
    SELECT 
        sf.driver_id,
        sf.recharge_res,
        sf.fee_res,
        public.withdraw_driver_wallet(sf.driver_id, 300.00) AS withdraw_res
    FROM step2_fee sf
),
step4_status AS (
    SELECT 
        sw.driver_id,
        sw.recharge_res,
        sf.fee_res,
        sw.withdraw_res,
        (sw.withdraw_res->>'payout_id')::UUID AS payout_id,
        public.update_payout_status((sw.withdraw_res->>'payout_id')::UUID, 'completed') AS status_res
    FROM step3_withdraw sw
    CROSS JOIN step2_fee sf
)
SELECT 
    'Step 1' AS step,
    'Driver Setup & Wallet Recharge (₹1000)' AS action,
    recharge_res AS result
FROM step4_status
UNION ALL
SELECT 
    'Step 2' AS step,
    'Pay Daily Fee (₹100) - Activate 24-Hr Pass' AS action,
    fee_res AS result
FROM step4_status
UNION ALL
SELECT 
    'Step 3' AS step,
    'Withdraw Wallet Funds (₹300) [Status: Created]' AS action,
    withdraw_res AS result
FROM step4_status
UNION ALL
SELECT 
    'Step 4' AS step,
    'Advance Payout Progress to Completed 🟢' AS action,
    status_res AS result
FROM step4_status;
