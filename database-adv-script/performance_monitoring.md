# Database Performance Monitoring and Optimization

## Overview

This document provides comprehensive performance monitoring and optimization strategies for the Airbnb clone database. Following Django best practices and PostgreSQL optimization techniques, we'll analyze query performance, identify bottlenecks, and implement targeted improvements.

## Current Performance Analysis

### Query Performance Baseline

Based on the actual query execution analysis from `performance_monitoring.sql`, here are the current performance metrics:

#### Test Query: Property Search with Location Filter

```sql
SELECT
    p.property_id,
    p.name,
    p.description,
    p.price_per_night,
    l.city,
    l.country,
    AVG(r.rating) as avg_rating,
    COUNT(r.review_id) as review_count
FROM property p
JOIN location l ON p.location_id = l.location_id
LEFT JOIN review r ON p.property_id = r.property_id
WHERE l.city = 'Accra'
    AND p.price_per_night BETWEEN 50 AND 150
GROUP BY p.property_id, p.name, p.description, p.price_per_night, l.city, l.country
ORDER BY avg_rating DESC, review_count DESC
LIMIT 10;
```

**Current Performance Metrics:**

- **Total Execution Time**: 0.153ms (Excellent)
- **Planning Time**: 0.754ms (High - 5x execution time)
- **Buffer Cache Hit Ratio**: 100% (Optimal)
- **Rows Returned**: 4 properties
- **Disk I/O**: 0 (All data in memory)

### Performance Issues Identified

1. **High Planning Overhead**: Planning time (0.754ms) is significantly higher than execution time (0.153ms)
2. **Sequential Scans with Filtering**:
   - Property table: 3 out of 10 rows filtered (30% waste)
   - Location table: 7 out of 12 rows filtered (58% waste)

### Query Execution Plan Analysis

The query execution follows this pattern:

1. **Limit** (0.086-0.087ms) - Final result limiting
2. **Sort** (0.085-0.086ms) - Ordering by avg_rating DESC, review_count DESC  
3. **Aggregate** (0.077-0.079ms) - GROUP BY with AVG and COUNT
4. **Nested Loop** (0.052-0.069ms) - LEFT JOIN with reviews
5. **Hash Join** (0.045-0.049ms) - INNER JOIN property with location
6. **Sequential Scans** on property and location tables

## Performance Monitoring Setup

### 1. Enable Query Performance Tracking

```sql
-- Enable query statistics collection
ALTER SYSTEM SET shared_preload_libraries = 'pg_stat_statements';
ALTER SYSTEM SET pg_stat_statements.track = 'all';
ALTER SYSTEM SET pg_stat_statements.max = 10000;
ALTER SYSTEM SET track_activity_query_size = 2048;

-- Enable detailed timing information
ALTER SYSTEM SET track_io_timing = 'on';
ALTER SYSTEM SET log_min_duration_statement = 100; -- Log queries > 100ms

-- Restart required for shared_preload_libraries
-- SELECT pg_reload_conf();
```

### 2. Create Performance Monitoring Views

```sql
-- Create monitoring schema
CREATE SCHEMA IF NOT EXISTS monitoring;

-- View for planning time analysis (based on actual findings)
CREATE OR REPLACE VIEW monitoring.planning_overhead AS
SELECT
    query,
    calls,
    total_time,
    mean_time,
    -- Calculate planning overhead ratio
    CASE 
        WHEN mean_time > 0 THEN 
            ROUND(100.0 * (total_time - mean_time) / mean_time, 2)
        ELSE 0 
    END as planning_overhead_percent,
    queryid
FROM pg_stat_statements
WHERE calls > 5
ORDER BY planning_overhead_percent DESC;

-- View for slow queries analysis
CREATE OR REPLACE VIEW monitoring.slow_queries AS
SELECT
    query,
    calls,
    total_time,
    mean_time,
    stddev_time,
    rows,
    100.0 * shared_blks_hit / NULLIF(shared_blks_hit + shared_blks_read, 0) AS hit_percent,
    queryid
FROM pg_stat_statements
WHERE mean_time > 50  -- Focus on queries averaging > 50ms
ORDER BY mean_time DESC;

-- View for sequential scan analysis
CREATE OR REPLACE VIEW monitoring.sequential_scans AS
SELECT
    schemaname,
    relname as tablename,
    seq_scan,
    seq_tup_read,
    idx_scan,
    CASE 
        WHEN seq_scan > 0 AND idx_scan > 0 THEN 
            ROUND(100.0 * seq_scan / (seq_scan + idx_scan), 2)
        WHEN seq_scan > 0 THEN 100.0
        ELSE 0.0
    END as seq_scan_percent,
    n_live_tup as total_rows
FROM pg_stat_user_tables
WHERE seq_scan > 0
ORDER BY seq_scan_percent DESC;

-- View for table statistics
CREATE OR REPLACE VIEW monitoring.table_stats AS
SELECT
    schemaname,
    tablename,
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
    tablename,
    indexname,
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
```

## Critical Performance Optimizations

### 1. Address Sequential Scan Issues

Based on the analysis, these indexes are immediately needed:

```sql
-- Priority 1: Location city filter (58% rows filtered)
CREATE INDEX CONCURRENTLY idx_location_city_lookup 
ON location (city) 
INCLUDE (location_id, country);

-- Priority 2: Property price range filter (30% rows filtered)  
CREATE INDEX CONCURRENTLY idx_property_price_range
ON property (price_per_night, location_id)
INCLUDE (property_id, name, description);

-- Priority 3: Composite index for the full query path
CREATE INDEX CONCURRENTLY idx_property_search_optimized
ON property (location_id, price_per_night)
INCLUDE (property_id, name, description);

-- Priority 4: Review aggregation optimization
CREATE INDEX CONCURRENTLY idx_review_property_rating
ON review (property_id, rating)
WHERE rating IS NOT NULL;
```

### 2. Reduce Planning Time Overhead

The planning time (0.754ms) is 5x the execution time. Address this with:

```sql
-- Increase statistics target for frequently queried columns
ALTER TABLE location ALTER COLUMN city SET STATISTICS 1000;
ALTER TABLE property ALTER COLUMN price_per_night SET STATISTICS 1000;
ALTER TABLE property ALTER COLUMN location_id SET STATISTICS 1000;

-- Update statistics immediately
ANALYZE location (city);
ANALYZE property (price_per_night, location_id);
```

### 3. Query-Specific Optimizations

```sql
-- Create a specialized index for the exact query pattern
CREATE INDEX CONCURRENTLY idx_property_location_price_summary
ON property (location_id, price_per_night)
INCLUDE (property_id, name, description);

-- Create covering index for location lookups
CREATE INDEX CONCURRENTLY idx_location_city_complete
ON location (city)
INCLUDE (location_id, country, latitude, longitude);
```

## Expected Performance Improvements

### Before Optimization (Current State)

- **Total Query Time**: 0.153ms
- **Planning Time**: 0.754ms (High overhead)
- **Sequential Scans**: 2 tables with significant filtering
- **Cache Hit Ratio**: 100% (Good)

### After Optimization (Projected)

- **Total Query Time**: 0.08-0.12ms (20-30% improvement)
- **Planning Time**: 0.15-0.30ms (60-80% improvement)
- **Sequential Scans**: Eliminated through targeted indexes
- **Cache Hit Ratio**: 100% (Maintained)

## Performance Monitoring Dashboard Queries

### 1. Real-time Performance Metrics

```sql
-- Current query performance analysis
SELECT
    query,
    calls,
    total_time,
    mean_time,
    ROUND(100.0 * stddev_time / NULLIF(mean_time, 0), 2) as cv_percent,
    rows
FROM pg_stat_statements
WHERE query LIKE '%property%location%'
    AND calls > 1
ORDER BY mean_time DESC;

-- Planning overhead analysis
SELECT
    'Planning Overhead' as metric,
    COUNT(*) as queries_affected,
    AVG(total_time - mean_time) as avg_planning_time
FROM pg_stat_statements
WHERE (total_time - mean_time) > mean_time * 0.5  -- Planning > 50% of total
    AND calls > 5;

-- Sequential scan impact
SELECT
    schemaname,
    relname as tablename,
    seq_scan as sequential_scans,
    seq_tup_read as rows_scanned,
    ROUND(seq_tup_read::numeric / NULLIF(seq_scan, 0), 0) as avg_rows_per_scan,
    n_live_tup as total_rows,
    ROUND(100.0 * seq_tup_read / NULLIF(n_live_tup * seq_scan, 0), 2) as scan_efficiency
FROM pg_stat_user_tables
WHERE seq_scan > 0
ORDER BY seq_tup_read DESC;
```

### 2. Buffer Cache Analysis

```sql
-- Cache hit ratio by table
SELECT
    schemaname,
    relname as tablename,
    heap_blks_read as disk_reads,
    heap_blks_hit as cache_hits,
    ROUND(100.0 * heap_blks_hit / NULLIF(heap_blks_hit + heap_blks_read, 0), 2) as cache_hit_ratio
FROM pg_statio_user_tables
WHERE heap_blks_hit + heap_blks_read > 0
ORDER BY cache_hit_ratio ASC;

-- Index cache performance
SELECT
    schemaname,
    relname as tablename,
    indexrelname as indexname,
    idx_blks_read as disk_reads,
    idx_blks_hit as cache_hits,
    ROUND(100.0 * idx_blks_hit / NULLIF(idx_blks_hit + idx_blks_read, 0), 2) as cache_hit_ratio
FROM pg_statio_user_indexes
WHERE idx_blks_hit + idx_blks_read > 0
ORDER BY cache_hit_ratio ASC;
```

## Implementation Strategy

### Phase 1: Immediate Optimizations (Week 1)

1. **Create critical indexes** for location.city and property.price_per_night
2. **Update table statistics** with higher precision
3. **Monitor query performance** changes

### Phase 2: Advanced Optimizations (Week 2-3)

1. **Implement composite indexes** for complex queries
2. **Create materialized views** for frequently accessed aggregations
3. **Set up automated monitoring** and alerting

### Phase 3: Long-term Monitoring (Ongoing)

1. **Weekly performance reviews** using monitoring views
2. **Monthly index usage analysis** and cleanup
3. **Quarterly performance baseline updates**

## Django ORM Optimization

### 1. QuerySet Optimization for Current Query

```python
# Current problematic pattern
properties = Property.objects.filter(
    location__city='Accra',
    price_per_night__range=(50, 150)
).annotate(
    avg_rating=Avg('reviews__rating'),
    review_count=Count('reviews')
).order_by('-avg_rating', '-review_count')[:10]

# Optimized version with select_related
properties = Property.objects.select_related('location').filter(
    location__city='Accra',
    price_per_night__range=(50, 150)
).annotate(
    avg_rating=Avg('reviews__rating'),
    review_count=Count('reviews')
).order_by('-avg_rating', '-review_count')[:10]
```

### 2. Database Connection Optimization

```python
# settings.py - Optimize for current low-latency performance
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'airbnb_clone_db',
        'USER': 'your_user',
        'PASSWORD': 'your_password',
        'HOST': 'localhost',
        'PORT': '5432',
        'OPTIONS': {
            'MAX_CONNS': 20,
            'CONN_MAX_AGE': 60,  # Short-lived connections for low latency
        },
    }
}
```

## Performance Monitoring Script

```sql
-- Save as current_performance_report.sql
\echo '=== CURRENT DATABASE PERFORMANCE REPORT ==='
\echo
\echo '1. QUERY PERFORMANCE SUMMARY'
SELECT
    COUNT(*) as total_queries,
    ROUND(AVG(mean_time), 3) as avg_execution_time_ms,
    ROUND(MAX(mean_time), 3) as max_execution_time_ms,
    COUNT(*) FILTER (WHERE mean_time > 1) as queries_over_1ms
FROM pg_stat_statements;

\echo
\echo '2. PLANNING OVERHEAD ANALYSIS'
SELECT * FROM monitoring.planning_overhead LIMIT 5;

\echo
\echo '3. SEQUENTIAL SCAN ANALYSIS'
SELECT * FROM monitoring.sequential_scans;

\echo
\echo '4. CACHE HIT RATIOS'
SELECT
    'Buffer Cache' as cache_type,
    ROUND(100.0 * sum(heap_blks_hit) / NULLIF(sum(heap_blks_hit + heap_blks_read), 0), 2) as hit_ratio
FROM pg_statio_user_tables
UNION ALL
SELECT
    'Index Cache' as cache_type,
    ROUND(100.0 * sum(idx_blks_hit) / NULLIF(sum(idx_blks_hit + idx_blks_read), 0), 2) as hit_ratio
FROM pg_statio_user_indexes;

\echo
\echo '5. TABLE SCAN EFFICIENCY'
SELECT
    relname as table_name,
    seq_scan,
    idx_scan,
    ROUND(100.0 * idx_scan / NULLIF(seq_scan + idx_scan, 0), 1) as index_usage_percent
FROM pg_stat_user_tables
WHERE seq_scan + idx_scan > 0
ORDER BY index_usage_percent ASC;
```

## Key Recommendations

1. **Immediate Action Required**: Create indexes for location.city and property.price_per_night to eliminate sequential scans
2. **Planning Time**: Increase statistics target for frequently filtered columns
3. **Monitoring**: Set up automated alerts for planning time > 5x execution time
4. **Performance Target**: Aim for total query time < 0.1ms and planning time < 0.2ms

## Success Metrics

- **Planning Time Reduction**: From 0.754ms to < 0.3ms
- **Total Query Time**: From 0.153ms to < 0.1ms  
- **Sequential Scans**: Eliminate filtering on property (30% waste) and location (58% waste)
- **Cache Hit Ratio**: Maintain 100% hit ratio
- **Index Usage**: Achieve > 90% index scan ratio for filtered queries

This updated analysis reflects the actual performance characteristics of your database and provides targeted optimizations based on real execution plan data.
