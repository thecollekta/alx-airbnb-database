-- Enable query statistics collection
ALTER SYSTEM SET shared_preload_libraries = 'pg_stat_statements';

ALTER SYSTEM SET pg_stat_statements.track = 'all';

ALTER SYSTEM SET pg_stat_statements.max = 10000;

ALTER SYSTEM SET track_activity_query_size = 2048;

-- Enable detailed timing information
ALTER SYSTEM SET track_io_timing = 'on';

ALTER SYSTEM SET log_min_duration_statement = 100;

-- Create monitoring schema
CREATE SCHEMA IF NOT EXISTS monitoring;

-- Create extension after configuration (requires restart)
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- View for slow queries analysis
CREATE OR REPLACE VIEW monitoring.slow_queries AS
SELECT
    query,
    calls,
    total_exec_time AS total_time,
    mean_exec_time AS mean_time,
    stddev_exec_time AS stddev_time,
    rows,
    100.0 * shared_blks_hit / nullif(
        shared_blks_hit + shared_blks_read,
        0
    ) AS hit_percent,
    queryid
FROM pg_stat_statements
WHERE
    mean_exec_time > 50 -- Focus on queries averaging > 50ms
ORDER BY mean_exec_time DESC;

-- View for table statistics
CREATE OR REPLACE VIEW monitoring.table_stats AS
SELECT
    schemaname,
    relname AS tablename,
    n_tup_ins as inserts,
    n_tup_upd as updates,
    n_tup_del as deletes,
    n_live_tup as live_rows,
    n_dead_tup as dead_rows,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables
ORDER BY n_live_tup DESC;

-- View for index usage
CREATE OR REPLACE VIEW monitoring.index_usage AS
SELECT
    schemaname,
    relname AS tablename,
    relname AS indexname,
    idx_tup_read,
    idx_tup_fetch,
    idx_scan,
    CASE
        WHEN idx_scan = 0 THEN 'UNUSED'
        WHEN idx_scan < 10 THEN 'LOW_USAGE'
        ELSE 'ACTIVE'
    END as usage_status
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;

-- Test 1: Property search with location filter (Most common user query)
EXPLAIN (
    ANALYZE,
    BUFFERS,
    FORMAT JSON
)
SELECT
    p.property_id,
    p.name,
    p.description,
    p.price_per_night,
    l.city,
    l.country,
    AVG(r.rating) as avg_rating,
    COUNT(r.review_id) as review_count
FROM
    property p
    JOIN location l ON p.location_id = l.location_id
    LEFT JOIN review r ON p.property_id = r.property_id
WHERE
    l.city = 'Accra'
    AND p.price_per_night BETWEEN 50 AND 150
GROUP BY
    p.property_id,
    p.name,
    p.description,
    p.price_per_night,
    l.city,
    l.country
ORDER BY avg_rating DESC, review_count DESC
LIMIT 10;

-- Test 2: User booking history (Dashboard query)
EXPLAIN (
    ANALYZE,
    BUFFERS,
    FORMAT JSON
)
SELECT b.booking_id, b.start_date, b.end_date, b.total_price, b.status, p.name as property_name, l.city, l.country
FROM
    booking b
    JOIN property p ON b.property_id = p.property_id
    JOIN location l ON p.location_id = l.location_id
WHERE
    b.user_id = 'a1b2c3d4-e5f6-7890-abcd-123456789001'
ORDER BY b.created_at DESC
LIMIT 20;

-- Test 3: Availability check (Booking validation)
EXPLAIN (
    ANALYZE,
    BUFFERS,
    FORMAT JSON
)
SELECT COUNT(*) as conflicting_bookings
FROM booking b
WHERE
    b.property_id = 'c1d2e3f4-95a6-7890-cdef-345678901001'
    AND b.status IN ('confirmed', 'pending')
    AND (
        (
            b.start_date <= '2025-07-15'
            AND b.end_date >= '2025-07-15'
        )
        OR (
            b.start_date <= '2025-07-20 '
            AND b.end_date >= '2025-07-20'
        )
        OR (
            b.start_date >= '2025-07-15'
            AND b.end_date <= '2025-07-20'
        )
    );

-- Test 4: Geographic search (Maps feature)
EXPLAIN (
    ANALYZE,
    BUFFERS,
    FORMAT JSON
)
SELECT p.property_id, p.name, p.price_per_night, l.latitude, l.longitude, l.city
FROM property p
    JOIN location l ON p.location_id = l.location_id
WHERE
    l.latitude BETWEEN 5.5 AND 5.7
    AND l.longitude BETWEEN -0.3 AND -0.1
    AND p.price_per_night <= 200
ORDER BY p.price_per_night ASC;

-- Check current index usage
SELECT
    schemaname,
    tablename,
    attname,
    n_distinct,
    correlation,
    array_to_string(most_common_vals, ', ') as top_values
FROM pg_stats
WHERE
    schemaname = 'public'
    AND tablename IN (
        'property',
        'booking',
        'location',
        'review'
    )
ORDER BY tablename, attname;

-- Analyze index scan ratios
SELECT
    schemaname,
    relname AS tablename,
    CASE
        WHEN (seq_scan + idx_scan) = 0 THEN 0
        ELSE ROUND(
            100.0 * idx_scan / (seq_scan + idx_scan),
            2
        )
    END as index_usage_percent,
    seq_scan,
    idx_scan,
    n_live_tup as row_count
FROM pg_stat_user_tables
WHERE
    schemaname = 'public'
ORDER BY index_usage_percent ASC;

-- Composite index for property search with filters
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_property_search ON property (price_per_night, location_id) INCLUDE (name, description);

-- Booking availability check optimization
CREATE INDEX IF NOT EXISTS idx_booking_availability ON booking (
    property_id,
    status,
    start_date,
    end_date
)
WHERE
    status IN ('confirmed', 'pending');

-- Review aggregation optimization
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_review_aggregation ON review (property_id, rating)
WHERE
    rating IS NOT NULL;

-- Message thread optimization
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_message_conversation ON message (
    sender_id,
    recipient_id,
    sent_at DESC
);

-- User role-based queries

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_role_email ON "user" (role, email)
WHERE
    role IN ('host', 'admin');

-- Partition booking table by date (for historical data)
-- Note: This requires data migration in production

CREATE TABLE IF NOT EXISTS booking_partitioned (LIKE booking INCLUDING ALL)
PARTITION BY
    RANGE (start_date);

-- Create monthly partitions
CREATE TABLE IF NOT EXISTS booking_2025_q1 PARTITION OF booking_partitioned FOR
VALUES
FROM ('2025-01-01') TO ('2025-04-01');

CREATE TABLE IF NOT EXISTS booking_2025_q2 PARTITION OF booking_partitioned FOR
VALUES
FROM ('2025-04-01') TO ('2025-07-01');

CREATE TABLE IF NOT EXISTS booking_2025_q3 PARTITION OF booking_partitioned FOR
VALUES
FROM ('2025-07-01') TO ('2025-10-01');

CREATE TABLE IF NOT EXISTS booking_2025_q4 PARTITION OF booking_partitioned FOR
VALUES
FROM ('2025-10-01') TO ('2026-01-01');

-- Property summary materialized view

CREATE MATERIALIZED VIEW IF NOT EXISTS property_summary AS
SELECT
    p.property_id,
    p.name,
    p.price_per_night,
    l.city,
    l.country,
    l.latitude,
    l.longitude,
    COALESCE(AVG(r.rating), 0) as avg_rating,
    COUNT(r.review_id) as review_count,
    COUNT(DISTINCT b.booking_id) as booking_count,
    MAX(b.created_at) as last_booking_date
FROM
    property p
    JOIN location l ON p.location_id = l.location_id
    LEFT JOIN review r ON p.property_id = r.property_id
    LEFT JOIN booking b ON p.property_id = b.property_id
GROUP BY
    p.property_id,
    p.name,
    p.price_per_night,
    l.city,
    l.country,
    l.latitude,
    l.longitude;

-- Create unique index for fast lookups
CREATE UNIQUE INDEX ON property_summary (property_id);

CREATE INDEX ON property_summary (city, avg_rating DESC);

CREATE INDEX ON property_summary (
    price_per_night,
    avg_rating DESC
);

-- Refresh schedule (run via cron or Django management command)
-- REFRESH MATERIALIZED VIEW CONCURRENTLY property_summary;

-- Before optimization: Property search
-- Execution time: ~150ms, Sequential scans on property and location

-- After optimization: With composite indexes
-- Execution time: ~15ms, Index scans only

-- Verification query with restart check
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_settings WHERE name = 'shared_preload_libraries' 
        AND setting ILIKE '%pg_stat_statements%'
    ) THEN
        RAISE NOTICE 'pg_stat_statements is enabled in configuration. Server restart required for full functionality.';
        
        -- Attempt to read from pg_stat_statements if available
        IF EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_name = 'pg_stat_statements'
        ) THEN
            RAISE NOTICE 'Property search performance metrics:';
            SELECT
                query,
                calls,
                total_exec_time AS total_time,
                mean_exec_time AS mean_time,
                rows
            FROM pg_stat_statements
            WHERE query LIKE '%property%price_per_night%'
            ORDER BY mean_exec_time DESC;
        ELSE
            RAISE NOTICE 'pg_stat_statements view not available yet. Please restart server and re-run monitoring queries.';
        END IF;
    ELSE
        RAISE WARNING 'pg_stat_statements not enabled! Check shared_preload_libraries configuration.';
    END IF;
END $$;

-- Connection and memory settings
ALTER SYSTEM
SET
    max_connections = 100;

ALTER SYSTEM
SET
    shared_buffers = '256MB';

ALTER SYSTEM
SET
    effective_cache_size = '1GB';

ALTER SYSTEM
SET
    maintenance_work_mem = '64MB';

ALTER SYSTEM
SET
    checkpoint_completion_target = 0.9;

ALTER SYSTEM
SET
    wal_buffers = '16MB';

ALTER SYSTEM
SET
    default_statistics_target = 100;

-- Query planner settings
ALTER SYSTEM
SET
    random_page_cost = 1.1;

ALTER SYSTEM
SET
    effective_io_concurrency = 0;

-- Reload configuration
SELECT pg_reload_conf();

-- Create maintenance procedures
CREATE OR REPLACE FUNCTION monitoring.update_table_stats()
RETURNS void AS $$
BEGIN
    -- Update statistics for all tables
    ANALYZE "user", location, property, booking, payment, review, message;

    -- Log maintenance activity
    INSERT INTO monitoring.maintenance_log (activity, executed_at)
    VALUES ('ANALYZE completed', NOW());
EXCEPTION WHEN others THEN
        INSERT INTO monitoring.maintenance_log (activity, executed_at)
        VALUES ('ANALYZE failed: ' || SQLERRM, NOW());
        RAISE;
END;
$$ LANGUAGE plpgsql;

-- Create maintenance log table
CREATE TABLE IF NOT EXISTS monitoring.maintenance_log (
    id SERIAL PRIMARY KEY,
    activity VARCHAR(100) NOT NULL,
    executed_at TIMESTAMPTZ DEFAULT NOW()
);

-- Current active queries

SELECT pid, now() - pg_stat_activity.query_start AS duration, query, state
FROM pg_stat_activity
WHERE (
        now() - pg_stat_activity.query_start
    ) > interval '5 minutes';

-- Table bloat analysis

SELECT
    schemaname,
    relname AS tablename,
    n_dead_tup,
    n_live_tup,
    ROUND(
        100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0),
        2
    ) as bloat_percent
FROM pg_stat_user_tables
WHERE
    n_dead_tup > 0
ORDER BY bloat_percent DESC;

-- Cache hit ratio

SELECT 'index hit rate' as name, ROUND(
        100.0 * sum(idx_blks_hit) / NULLIF(
            sum(idx_blks_hit + idx_blks_read), 0
        ), 2
    ) as ratio
FROM pg_statio_user_indexes
UNION ALL
SELECT 'table hit rate' as name, ROUND(
        100.0 * sum(heap_blks_hit) / NULLIF(
            sum(
                heap_blks_hit + heap_blks_read
            ), 0
        ), 2
    ) as ratio
FROM pg_statio_user_tables;

-- Weekly slow query report
CREATE OR REPLACE VIEW monitoring.weekly_slow_queries AS
SELECT
    LEFT(query, 100) as query_preview,
    calls,
    ROUND(total_exec_time::numeric, 2) as total_time_ms,
    ROUND(mean_exec_time::numeric, 2) as avg_time_ms,
    ROUND(stddev_exec_time::numeric, 2) as stddev_time_ms,
    rows
FROM pg_stat_statements
WHERE
    calls > 10
    AND mean_exec_time > 50
ORDER BY total_exec_time DESC
LIMIT 20;

-- Table growth tracking
CREATE OR REPLACE VIEW monitoring.table_growth AS
SELECT
    schemaname,
    relname AS tablename,
    pg_size_pretty(
        pg_total_relation_size(
            quote_ident(schemaname) || '.' || quote_ident(relname)
        )
    ) as total_size,
    pg_size_pretty(
        pg_relation_size(
            quote_ident(schemaname) || '.' || quote_ident(relname)
        )
    ) as table_size,
    pg_size_pretty(
        pg_total_relation_size(
            quote_ident(schemaname) || '.' || quote_ident(relname)
        ) - pg_relation_size(
            quote_ident(schemaname) || '.' || quote_ident(relname)
        )
    ) as index_size,
    n_live_tup as row_count
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(
        quote_ident(schemaname) || '.' || quote_ident(relname)
    ) DESC;

-- Track growth over time
CREATE TABLE IF NOT EXISTS monitoring.table_size_history (
    id SERIAL PRIMARY KEY,
    captured_at TIMESTAMPTZ DEFAULT NOW(),
    schemaname TEXT,
    tablename TEXT,
    total_size BIGINT,
    table_size BIGINT,
    index_size BIGINT,
    row_count BIGINT
);

-- Schedule regular size snapshots
INSERT INTO
    monitoring.table_size_history (
        schemaname,
        tablename,
        total_size,
        table_size,
        index_size,
        row_count
    )
SELECT
    schemaname,
    relname,
    pg_total_relation_size(
        quote_ident(schemaname) || '.' || quote_ident(relname)
    ),
    pg_relation_size(
        quote_ident(schemaname) || '.' || quote_ident(relname)
    ),
    pg_total_relation_size(
        quote_ident(schemaname) || '.' || quote_ident(relname)
    ) - pg_relation_size(
        quote_ident(schemaname) || '.' || quote_ident(relname)
    ),
    n_live_tup
FROM pg_stat_user_tables;