-- ==============================================================================
-- FIX: Update Trigger 1 to ONLY Credit Driver Wallet on Wallet Payment (NOT Cash)
-- ==============================================================================
-- Run this in your Supabase SQL Editor to replace the existing Trigger 1 function.
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.credit_driver_wallet_on_booking_completion()
RETURNS TRIGGER AS $$
DECLARE
    v_total_price NUMERIC(10, 2) := 0.00;
    v_final_earning NUMERIC(10, 2) := 0.00;
    v_is_wallet_payment BOOLEAN := FALSE;
BEGIN
    -- Only trigger when booking status transitions to 'completed'
    IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status <> 'completed') THEN
        IF NEW.driver_id IS NULL THEN
            RETURN NEW;
        END IF;

        -- 1. Check if payment_mode is WALLET (using same structure as Trigger 2)
        IF NEW.payment_mode IS NOT NULL THEN
            IF jsonb_typeof(NEW.payment_mode) = 'object' THEN
                IF LOWER(COALESCE(NEW.payment_mode->>'mode', '')) IN ('wallet', 'customer_wallet', 'wallet payment') OR
                   LOWER(COALESCE(NEW.payment_mode->>'method', '')) IN ('wallet', 'customer_wallet', 'wallet payment') THEN
                    v_is_wallet_payment := TRUE;
                END IF;
            ELSEIF LOWER(NEW.payment_mode::text) LIKE '%wallet%' THEN
                v_is_wallet_payment := TRUE;
            END IF;
        END IF;

        -- 2. If customer selected CASH (or anything other than Wallet), DO NOT credit wallet!
        IF NOT v_is_wallet_payment THEN
            RETURN NEW;
        END IF;

        -- 3. Extract total_price from amount JSONB column
        IF NEW.amount IS NOT NULL AND jsonb_typeof(NEW.amount) = 'object' THEN
            v_total_price := COALESCE(
                (NEW.amount->>'total_price')::NUMERIC,
                (NEW.amount->>'totalPrice')::NUMERIC,
                (NEW.amount->>'total_fare')::NUMERIC,
                (NEW.amount->>'base_fare')::NUMERIC,
                0.00
            );
        ELSIF NEW.amount IS NOT NULL AND jsonb_typeof(NEW.amount) = 'number' THEN
            v_total_price := (NEW.amount::text)::NUMERIC;
        ELSE
            v_total_price := 0.00;
        END IF;

        v_final_earning := v_total_price;

        -- 4. Credit Driver Wallet ONLY for Wallet payments
        IF v_final_earning > 0 THEN
            INSERT INTO public.driver_wallets (driver_id, balance) 
            VALUES (NEW.driver_id, 0.00) 
            ON CONFLICT (driver_id) DO NOTHING;

            UPDATE public.driver_wallets
            SET balance = balance + v_final_earning, updated_at = now()
            WHERE driver_id = NEW.driver_id;

            INSERT INTO public.wallet_transactions (driver_id, amount, type, description, reference_id)
            VALUES (
                NEW.driver_id, 
                v_final_earning, 
                'earning_credit', 
                'Trip Wallet Credit (' || COALESCE(NEW.pickup_address, 'Booking #' || SUBSTRING(NEW.id::text, 1, 8)) || ')',
                NEW.id::text
            );

            INSERT INTO public.driver_notifications (driver_id, title, message, type)
            VALUES (
                NEW.driver_id,
                'Trip Wallet Earnings Credited 💰',
                '₹' || v_final_earning || ' earned from wallet payment has been credited to your wallet.',
                'wallet_credit'
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Re-attach trigger on public.bookings
DROP TRIGGER IF EXISTS trg_credit_driver_wallet_on_booking_completion ON public.bookings;
CREATE TRIGGER trg_credit_driver_wallet_on_booking_completion
    AFTER UPDATE ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION public.credit_driver_wallet_on_booking_completion();
