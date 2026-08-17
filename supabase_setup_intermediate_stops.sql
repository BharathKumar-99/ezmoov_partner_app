-- ============================================================================
-- EZMOOV INTERMEDIATE STOPS PROGRESS MIGRATION SCRIPT
-- SQL Script for tracking per-stop progress ('stop_X_reached' and 'stop_X_completed')
-- ============================================================================

-- 1. Ensure columns exist on public.bookings
ALTER TABLE public.bookings 
ADD COLUMN IF NOT EXISTS intermediate_stops JSONB DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS stops_charge NUMERIC DEFAULT 0.0;

-- 2. Create RPC Function to atomically update intermediate stop status and booking status
CREATE OR REPLACE FUNCTION public.update_intermediate_stop_status(
    p_booking_id TEXT,
    p_stop_index INT,
    p_stop_status TEXT,
    p_updated_stops JSONB
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_booking_idx INT;
    v_status_str TEXT;
BEGIN
    v_status_str := 'stop_' || p_stop_index::text || '_' || p_stop_status;

    -- Update by integer ID if numeric string, otherwise text
    IF p_booking_id ~ '^[0-9]+$' THEN
        v_booking_idx := p_booking_id::INT;
        UPDATE public.bookings
        SET 
            status = v_status_str,
            intermediate_stops = p_updated_stops,
            updated_at = NOW()
        WHERE id::text = p_booking_id OR idx = v_booking_idx;
    ELSE
        UPDATE public.bookings
        SET 
            status = v_status_str,
            intermediate_stops = p_updated_stops,
            updated_at = NOW()
        WHERE id::text = p_booking_id;
    END IF;
END;
$$;

-- 3. Grant Execution Permissions to public, authenticated, and service_role
GRANT EXECUTE ON FUNCTION public.update_intermediate_stop_status(TEXT, INT, TEXT, JSONB) TO anon, authenticated, service_role;

-- 4. Create Index on intermediate_stops for quick JSON queries
CREATE INDEX IF NOT EXISTS idx_bookings_intermediate_stops ON public.bookings USING gin (intermediate_stops);

-- ============================================================================
-- VERIFICATION QUERY
-- ============================================================================
SELECT id, status, intermediate_stops FROM public.bookings WHERE intermediate_stops IS NOT NULL LIMIT 5;
