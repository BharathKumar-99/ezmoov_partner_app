-- SQL Migration: Fix Supabase Realtime for Driver Wallet tables
-- Run this SQL in your Supabase SQL Editor to enable full row payload delivery on UPDATE/INSERT

-- 1. Set REPLICA IDENTITY FULL for complete row payload on UPDATE events
ALTER TABLE public.driver_wallets REPLICA IDENTITY FULL;
ALTER TABLE public.wallet_transactions REPLICA IDENTITY FULL;
ALTER TABLE public.driver_daily_status REPLICA IDENTITY FULL;
ALTER TABLE public.driver_payouts REPLICA IDENTITY FULL;

-- 2. Add tables to supabase_realtime publication
ALTER PUBLICATION supabase_realtime ADD TABLE public.driver_wallets;
ALTER PUBLICATION supabase_realtime ADD TABLE public.wallet_transactions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.driver_daily_status;
ALTER PUBLICATION supabase_realtime ADD TABLE public.driver_payouts;
