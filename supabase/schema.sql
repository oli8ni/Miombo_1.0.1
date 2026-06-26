-- ============================================================
-- Miombo Analytics Pro - Schema Supabase
-- Copie ce bloc ENTIER dans SQL Editor > New query > RUN
-- ============================================================

-- 1) TABLE : zones
CREATE TABLE IF NOT EXISTS zones (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID,
    name TEXT NOT NULL DEFAULT 'Nouvelle zone',
    lat DECIMAL(10, 6) NOT NULL DEFAULT -11.0,
    lng DECIMAL(10, 6) NOT NULL DEFAULT 27.0,
    radius_km DECIMAL(8, 2) NOT NULL DEFAULT 28,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2) TABLE : alerts
CREATE TABLE IF NOT EXISTS alerts (
    id TEXT PRIMARY KEY,
    user_id UUID,
    zone_id UUID REFERENCES zones(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    severity TEXT NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    lat DECIMAL(10, 6),
    lng DECIMAL(10, 6),
    read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3) TABLE : alert_rules
CREATE TABLE IF NOT EXISTS alert_rules (
    id TEXT PRIMARY KEY,
    user_id UUID,
    zone_id UUID REFERENCES zones(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    rule_type TEXT NOT NULL,
    threshold DECIMAL(4, 3) NOT NULL DEFAULT 0.7,
    notify_email BOOLEAN DEFAULT FALSE,
    email_address TEXT,
    notify_webhook BOOLEAN DEFAULT FALSE,
    webhook_url TEXT,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4) TABLE : analysis_results
CREATE TABLE IF NOT EXISTS analysis_results (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    zone_id UUID REFERENCES zones(id) ON DELETE CASCADE,
    analysis_type TEXT NOT NULL,
    result_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5) TABLE : reports
CREATE TABLE IF NOT EXISTS reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID,
    zone_id UUID REFERENCES zones(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    format TEXT NOT NULL DEFAULT 'json',
    sections JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- VERIFICATION : s'assurer que les tables existent
-- ============================================================
SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;
