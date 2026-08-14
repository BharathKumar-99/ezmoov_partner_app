-- ============================================================================
-- EZMOOV PARTNER APP: BACKEND AUTOMATIC OFFLINE GUARD & EXPIRE TRIGGER
-- Enforces 24-Hour Daily Pass at the Database Level
-- ============================================================================

-- 1. Ensure driver_daily_status has pass_expires_at column
ALTER TABLE public.driver_daily_status ADD COLUMN IF NOT EXISTS pass_expires_at TIMESTAMPTZ;

-- 2. Drop existing function to allow changing return type cleanly
DROP FUNCTION IF EXISTS public.check_expired_daily_passes();

-- Function to auto-offline drivers with expired passes
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


-- 3. Database BEFORE UPDATE Trigger to STRICTLY prevent drivers from going online if pass is expired
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

        -- If no daily status record exists, or pass expired, or rejections >= 2, FORCE is_online = false!
        IF v_is_blocked = true OR v_rejections >= 2 OR v_pass_expires_at IS NULL OR v_pass_expires_at <= now() THEN
            NEW.is_online := false;
            RAISE NOTICE 'Backend Guard: Blocked driver % from going online (Pass expired / unpaid / rejections limit).', NEW.id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Attach trigger to public.drivers table
DROP TRIGGER IF EXISTS trg_prevent_online_without_pass ON public.drivers;

CREATE TRIGGER trg_prevent_online_without_pass
BEFORE INSERT OR UPDATE OF is_online ON public.drivers
FOR EACH ROW
EXECUTE FUNCTION public.prevent_online_without_pass();


-- 4. Schedule 1-Minute Cron Job (Auto-Offlines Expired Passes Every 60 Seconds)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
        -- Remove old jobs if exist
        BEGIN PERFORM cron.unschedule('every-5min-auto-offline-expired-passes'); EXCEPTION WHEN OTHERS THEN NULL; END;
        BEGIN PERFORM cron.unschedule('every-1min-auto-offline-expired-passes'); EXCEPTION WHEN OTHERS THEN NULL; END;

        -- Schedule 1-minute auto-offline check
        PERFORM cron.schedule(
            'every-1min-auto-offline-expired-passes',
            '* * * * *',
            'SELECT public.check_expired_daily_passes();'
        );
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'pg_cron schedule notice: %', SQLERRM;
END $$;

GRANT EXECUTE ON FUNCTION public.check_expired_daily_passes TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.prevent_online_without_pass TO anon, authenticated, service_role;

NOTIFY pgrst, 'reload schema';
