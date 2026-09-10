-- ==============================================================================
-- SQL Migration: Create partner_app_config Table
-- EZMoov Partner Application
-- ==============================================================================

-- 1. Create the partner_app_config table
CREATE TABLE IF NOT EXISTS public.partner_app_config (
    id SERIAL PRIMARY KEY,
    version TEXT NOT NULL DEFAULT '1.0.0',
    is_maintenance BOOLEAN DEFAULT false,
    force_update BOOLEAN DEFAULT false,
    update_url TEXT DEFAULT 'https://play.google.com/store/apps/details?id=com.ezmoov.partner',
    update_title TEXT DEFAULT 'Update Available',
    update_message TEXT DEFAULT 'A new version of EZMoov Partner is available. Please update the app to continue.',
    min_version TEXT DEFAULT '1.0.0',
    registration_fee NUMERIC(10, 2) DEFAULT 499.00,
    is_free_driver_login BOOLEAN DEFAULT false,
    maintenance_title TEXT DEFAULT 'App Under Maintenance',
    maintenance_message TEXT DEFAULT 'We are currently undergoing scheduled maintenance. Please check back shortly.',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2. Trigger to maintain updated_at on record updates
CREATE OR REPLACE FUNCTION public.set_partner_app_config_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_partner_app_config_updated_at ON public.partner_app_config;
CREATE TRIGGER trg_partner_app_config_updated_at
BEFORE UPDATE ON public.partner_app_config
FOR EACH ROW
EXECUTE FUNCTION set_partner_app_config_updated_at();

-- 3. Seed initial default row if not exists
INSERT INTO public.partner_app_config (
    id,
    version,
    is_maintenance,
    force_update,
    update_url,
    update_title,
    update_message,
    min_version,
    registration_fee,
    is_free_driver_login,
    maintenance_title,
    maintenance_message
) VALUES (
    1,
    '1.0.0',
    false,
    false,
    'https://play.google.com/store/apps/details?id=com.ezmoov.partner',
    'Update Available',
    'A new version of EZMoov Partner is available. Please update the app to continue.',
    '1.0.0',
    499.00,
    false,
    'App Under Maintenance',
    'We are currently undergoing scheduled maintenance. Please check back shortly.'
) ON CONFLICT (id) DO NOTHING;

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.partner_app_config ENABLE ROW LEVEL SECURITY;

-- Allow public read access (for both authenticated drivers and unauthenticated guests)
DROP POLICY IF EXISTS "Allow public read access on partner_app_config" ON public.partner_app_config;
CREATE POLICY "Allow public read access on partner_app_config"
ON public.partner_app_config
FOR SELECT
TO anon, authenticated
USING (true);

-- Allow service_role full control
DROP POLICY IF EXISTS "Allow service role full access on partner_app_config" ON public.partner_app_config;
CREATE POLICY "Allow service role full access on partner_app_config"
ON public.partner_app_config
FOR ALL
TO service_role
USING (true);

-- 5. Add to Supabase Realtime Publication for instant live config sync
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' 
        AND tablename = 'partner_app_config'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.partner_app_config;
    END IF;
EXCEPTION
    WHEN others THEN NULL;
END $$;

-- 6. Helper RPC Function to fetch latest partner app config
CREATE OR REPLACE FUNCTION public.get_partner_app_config()
RETURNS JSONB AS $$
DECLARE
    v_config RECORD;
BEGIN
    SELECT * INTO v_config 
    FROM public.partner_app_config 
    ORDER BY id ASC 
    LIMIT 1;

    IF FOUND THEN
        RETURN to_jsonb(v_config);
    ELSE
        RETURN jsonb_build_object(
            'id', 1,
            'version', '1.0.0',
            'is_maintenance', false,
            'force_update', false,
            'update_url', 'https://play.google.com/store/apps/details?id=com.ezmoov.partner',
            'update_title', 'Update Available',
            'update_message', 'A new version of EZMoov Partner is available. Please update the app to continue.',
            'min_version', '1.0.0',
            'registration_fee', 499.00,
            'is_free_driver_login', false,
            'maintenance_title', 'App Under Maintenance',
            'maintenance_message', 'We are currently undergoing scheduled maintenance. Please check back shortly.'
        );
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.get_partner_app_config() TO anon, authenticated, service_role;
