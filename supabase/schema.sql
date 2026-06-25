-- Miombo Analytics Pro - Schema Supabase
-- Execute ce SQL dans l'interface SQL de Supabase (SQL Editor > New Query)

-- ============================================================
-- 1. Table: zones (zones de surveillance)
-- ============================================================
CREATE TABLE IF NOT EXISTS zones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    name TEXT NOT NULL,
    lat DECIMAL(10, 6) NOT NULL,
    lng DECIMAL(10, 6) NOT NULL,
    radius_km DECIMAL(8, 2) NOT NULL DEFAULT 28,
    polygon_geojson JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 2. Table: alerts (alertes générées)
-- ============================================================
CREATE TABLE IF NOT EXISTS alerts (
    id TEXT PRIMARY KEY,
    user_id UUID,
    zone_id UUID REFERENCES zones(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('fire', 'flood', 'deforestation', 'ndvi_drop', 'weather')),
    severity TEXT NOT NULL CHECK (severity IN ('critical', 'high', 'medium', 'low')),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    lat DECIMAL(10, 6),
    lng DECIMAL(10, 6),
    read BOOLEAN DEFAULT FALSE,
    notified_email BOOLEAN DEFAULT FALSE,
    notified_webhook BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 3. Table: alert_rules (règles d'alerte configurables)
-- ============================================================
CREATE TABLE IF NOT EXISTS alert_rules (
    id TEXT PRIMARY KEY,
    user_id UUID,
    zone_id UUID REFERENCES zones(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    rule_type TEXT NOT NULL CHECK (rule_type IN ('fire', 'flood', 'deforestation', 'ndvi_drop')),
    threshold DECIMAL(4, 3) NOT NULL DEFAULT 0.7,
    notify_email BOOLEAN DEFAULT FALSE,
    email_address TEXT,
    notify_webhook BOOLEAN DEFAULT FALSE,
    webhook_url TEXT,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 4. Table: analysis_results (résultats d'analyse en cache)
-- ============================================================
CREATE TABLE IF NOT EXISTS analysis_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    zone_id UUID REFERENCES zones(id) ON DELETE CASCADE,
    analysis_type TEXT NOT NULL,
    satellite TEXT,
    parameters JSONB,
    result_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '24 hours')
);

-- ============================================================
-- 5. Table: reports (rapports générés)
-- ============================================================
CREATE TABLE IF NOT EXISTS reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    zone_id UUID REFERENCES zones(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    format TEXT NOT NULL CHECK (format IN ('json', 'csv', 'md', 'pdf', 'docx')),
    sections JSONB,
    download_url TEXT,
    file_size_bytes INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- INDEX pour performances
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_alerts_user_read ON alerts(user_id, read);
CREATE INDEX IF NOT EXISTS idx_alerts_created ON alerts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_alerts_severity ON alerts(severity);
CREATE INDEX IF NOT EXISTS idx_analysis_zone_type ON analysis_results(zone_id, analysis_type);
CREATE INDEX IF NOT EXISTS idx_reports_user ON reports(user_id, created_at DESC);

-- ============================================================
-- ROW LEVEL SECURITY (sécurité multi-utilisateur)
-- ============================================================
ALTER TABLE zones ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE alert_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- Policy: les utilisateurs ne voient que leurs propres données
CREATE POLICY "Users can only access their own zones"
    ON zones FOR ALL
    USING (user_id = auth.uid());

CREATE POLICY "Users can only access their own alerts"
    ON alerts FOR ALL
    USING (user_id = auth.uid());

CREATE POLICY "Users can only access their own rules"
    ON alert_rules FOR ALL
    USING (user_id = auth.uid());

CREATE POLICY "Users can only access their own reports"
    ON reports FOR ALL
    USING (user_id = auth.uid());

-- ============================================================
-- REALTIME: activer les changements temps réel sur alerts
-- ============================================================
-- Dans Supabase: Database > Replication > supabase_realtime > ajouter les tables
-- OU exécuter:
-- ALTER PUBLICATION supabase_realtime ADD TABLE alerts;
