-- ================================================================
-- Supabase Schema: driver_login_time & Automated Online Tracking Trigger
-- EZMoov Partner Application - Driver Login Hours & Performance
-- ================================================================

-- 1. Create Table: driver_login_time
CREATE TABLE IF NOT EXISTS public.driver_login_time (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES public.drivers(id) ON DELETE CASCADE,
    start_time TIMESTAMPTZ DEFAULT now(),
    end_time TIMESTAMPTZ,
    total_time TEXT,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Ensure start_time is nullable for pre-allocated records
ALTER TABLE public.driver_login_time ALTER COLUMN start_time DROP NOT NULL;

-- 2. Create Indexes for fast querying by driver & date
CREATE INDEX IF NOT EXISTS idx_driver_login_time_driver_date 
    ON public.driver_login_time (driver_id, date);

CREATE INDEX IF NOT EXISTS idx_driver_login_time_start_time 
    ON public.driver_login_time (driver_id, start_time DESC);

-- 3. Enable Row Level Security (RLS)
ALTER TABLE public.driver_login_time ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies
DROP POLICY IF EXISTS "Allow authenticated read driver_login_time" ON public.driver_login_time;
CREATE POLICY "Allow authenticated read driver_login_time"
    ON public.driver_login_time
    FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Allow authenticated insert driver_login_time" ON public.driver_login_time;
CREATE POLICY "Allow authenticated insert driver_login_time"
    ON public.driver_login_time
    FOR INSERT
    WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated update driver_login_time" ON public.driver_login_time;
CREATE POLICY "Allow authenticated update driver_login_time"
    ON public.driver_login_time
    FOR UPDATE
    USING (true);

DROP POLICY IF EXISTS "Allow authenticated delete driver_login_time" ON public.driver_login_time;
CREATE POLICY "Allow authenticated delete driver_login_time"
    ON public.driver_login_time
    FOR DELETE
    USING (true);

-- 5. Trigger Function: handle_driver_online_status_login_time
-- Robustly handles:
--  • Cold starts & initial online toggles
--  • Multiple sessions per day
--  • Orphaned pre-allocated records (start_time IS NULL, end_time IS NULL)
--  • Redundant & no-op status updates
--  • Overnight shifts & past date boundaries
CREATE OR REPLACE FUNCTION public.handle_driver_online_status_login_time()
RETURNS TRIGGER AS $$
DECLARE
    v_open_session_id UUID;
    v_open_session_start TIMESTAMPTZ;
    v_duration INTERVAL;
    v_hours INT;
    v_minutes INT;
    v_total_str TEXT;
BEGIN
    -- 1. WHEN is_online IS CHANGED TO TRUE
    IF (NEW.is_online = true AND (OLD.is_online IS DISTINCT FROM true)) THEN
        -- Check if an unclosed session already exists for today
        SELECT id INTO v_open_session_id
        FROM public.driver_login_time
        WHERE driver_id = NEW.id
          AND date = CURRENT_DATE
          AND end_time IS NULL
        ORDER BY created_at DESC
        LIMIT 1;

        IF v_open_session_id IS NOT NULL THEN
            -- Unclosed record exists (e.g. orphaned with missing start_time or active): populate/refresh start_time
            UPDATE public.driver_login_time
            SET start_time = COALESCE(start_time, now()),
                updated_at = now()
            WHERE id = v_open_session_id;
        ELSE
            -- No unclosed record for today -> Insert new active session
            INSERT INTO public.driver_login_time (
                driver_id,
                start_time,
                end_time,
                total_time,
                date,
                created_at,
                updated_at
            ) VALUES (
                NEW.id,
                now(),
                NULL,
                NULL,
                CURRENT_DATE,
                now(),
                now()
            );
        END IF;
    END IF;

    -- 2. WHEN is_online IS CHANGED TO FALSE
    IF (NEW.is_online = false AND (OLD.is_online IS DISTINCT FROM false)) THEN
        -- Check for the active open session (including overnight shifts from previous days)
        SELECT id, start_time INTO v_open_session_id, v_open_session_start
        FROM public.driver_login_time
        WHERE driver_id = NEW.id
          AND end_time IS NULL
        ORDER BY created_at DESC, start_time DESC
        LIMIT 1;

        -- If an active session is found, close it and compute total duration
        IF v_open_session_id IS NOT NULL THEN
            v_open_session_start := COALESCE(v_open_session_start, now());
            v_duration := now() - v_open_session_start;
            v_hours := FLOOR(EXTRACT(EPOCH FROM v_duration) / 3600);
            v_minutes := FLOOR((EXTRACT(EPOCH FROM v_duration) % 3600) / 60);

            IF v_hours > 0 THEN
                v_total_str := CONCAT(v_hours, ' hrs ', v_minutes, ' mins');
            ELSE
                v_total_str := CONCAT(v_minutes, ' mins');
            END IF;

            UPDATE public.driver_login_time
            SET end_time = now(),
                total_time = v_total_str,
                updated_at = now()
            WHERE id = v_open_session_id;
        END IF;
        -- If no active session found, do nothing (no-op)
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Attach Trigger to public.drivers table
DROP TRIGGER IF EXISTS trg_driver_online_status_login_time ON public.drivers;
CREATE TRIGGER trg_driver_online_status_login_time
    AFTER UPDATE OF is_online ON public.drivers
    FOR EACH ROW
    WHEN (OLD.is_online IS DISTINCT FROM NEW.is_online)
    EXECUTE FUNCTION public.handle_driver_online_status_login_time();
