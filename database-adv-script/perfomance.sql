-- Performance Analysis for Airbnb Database
-- Complex Query Optimization and Analysis
-- Following PostgreSQL best practices and Django ORM patterns

-- 1. Initial Complex Query (Before Optimization)

-- This query retrieves all bookings with comprehensive details
-- including user information, property details, location data, and payment information

-- Initial Complex Query - Comprehensive Booking Details
SELECT
    -- Booking Information
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at as booking_created_at,

-- Guest Information
guest.user_id as guest_id,
guest.first_name as guest_first_name,
guest.last_name as guest_last_name,
guest.email as guest_email,
guest.phone_number as guest_phone,

-- Property Information
p.property_id,
p.name as property_name,
p.description as property_description,
p.price_per_night,

-- Host Information
host.user_id as host_id,
host.first_name as host_first_name,
host.last_name as host_last_name,
host.email as host_email,
host.phone_number as host_phone,

-- Location Information
l.location_id,
l.street_address,
l.city,
l.state_province,
l.country,
l.postal_code,
l.latitude,
l.longitude,

-- Payment Information
pay.payment_id,
pay.amount as payment_amount,
pay.payment_date,
pay.payment_method,

-- Calculated Fields
(b.end_date - b.start_date) as booking_duration,
CASE
    WHEN b.status = 'confirmed' THEN 'Active Booking'
    WHEN b.status = 'pending' THEN 'Awaiting Confirmation'
    WHEN b.status = 'canceled' THEN 'Cancelled'
    ELSE 'Unknown Status'
END as booking_status_display
FROM
    booking b
    INNER JOIN "user" guest ON b.user_id = guest.user_id
    INNER JOIN property p ON b.property_id = p.property_id
    INNER JOIN "user" host ON p.host_id = host.user_id
    INNER JOIN location l ON p.location_id = l.location_id
    LEFT JOIN payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;

-- 2. Performance Analysis Commands

-- Use these commands to analyze query performance

-- Basic EXPLAIN for query structure
EXPLAIN
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    guest.first_name as guest_first_name,
    guest.last_name as guest_last_name,
    p.name as property_name,
    host.first_name as host_first_name,
    host.last_name as host_last_name,
    l.city,
    l.country,
    pay.payment_method
FROM
    booking b
    INNER JOIN "user" guest ON b.user_id = guest.user_id
    INNER JOIN property p ON b.property_id = p.property_id
    INNER JOIN "user" host ON p.host_id = host.user_id
    INNER JOIN location l ON p.location_id = l.location_id
    LEFT JOIN payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;

-- Detailed EXPLAIN with cost analysis
EXPLAIN (
    ANALYZE,
    BUFFERS,
    VERBOSE
)
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    guest.first_name as guest_first_name,
    guest.last_name as guest_last_name,
    p.name as property_name,
    host.first_name as host_first_name,
    host.last_name as host_last_name,
    l.city,
    l.country,
    pay.payment_method
FROM
    booking b
    INNER JOIN "user" guest ON b.user_id = guest.user_id
    INNER JOIN property p ON b.property_id = p.property_id
    INNER JOIN "user" host ON p.host_id = host.user_id
    INNER JOIN location l ON p.location_id = l.location_id
    LEFT JOIN payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;

-- 3. Optimized Queries (After Analysis)

-- Optimized Query 1: Paginated Results with Essential Fields Only
-- Reduces data transfer and improves response time
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    guest.first_name || ' ' || guest.last_name as guest_name,
    p.name as property_name,
    host.first_name || ' ' || host.last_name as host_name,
    l.city || ', ' || l.country as location,
    pay.payment_method
FROM
    booking b
    INNER JOIN "user" guest ON b.user_id = guest.user_id
    INNER JOIN property p ON b.property_id = p.property_id
    INNER JOIN "user" host ON p.host_id = host.user_id
    INNER JOIN location l ON p.location_id = l.location_id
    LEFT JOIN payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC
LIMIT 20
OFFSET
    0;

-- Optimized Query 2: Filtered Results with Proper Indexing
-- Uses existing indexes for better performance
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    guest.first_name || ' ' || guest.last_name as guest_name,
    p.name as property_name,
    l.city,
    l.country
FROM
    booking b
    INNER JOIN "user" guest ON b.user_id = guest.user_id
    INNER JOIN property p ON b.property_id = p.property_id
    INNER JOIN location l ON p.location_id = l.location_id
WHERE
    b.status = 'confirmed'
    AND b.start_date >= CURRENT_DATE
    AND l.country = 'Ghana'
ORDER BY b.start_date ASC;

-- Optimized Query 3: Aggregated Data with Minimal Joins
-- For dashboard/reporting purposes
SELECT
    l.city,
    l.country,
    COUNT(b.booking_id) as total_bookings,
    SUM(b.total_price) as total_revenue,
    AVG(b.total_price) as avg_booking_value,
    COUNT(
        CASE
            WHEN b.status = 'confirmed' THEN 1
        END
    ) as confirmed_bookings,
    COUNT(
        CASE
            WHEN b.status = 'pending' THEN 1
        END
    ) as pending_bookings
FROM
    booking b
    INNER JOIN property p ON b.property_id = p.property_id
    INNER JOIN location l ON p.location_id = l.location_id
WHERE
    b.created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY
    l.city,
    l.country
ORDER BY total_revenue DESC;

-- 4. Specialized Optimization Indexes
-- Additional indexes to improve query performance

-- Composite index for booking queries with date filtering
CREATE INDEX IF NOT EXISTS idx_booking_status_dates ON booking (status, start_date, end_date)
WHERE
    status IN ('confirmed', 'pending');

-- Covering index for booking list queries
CREATE INDEX IF NOT EXISTS idx_booking_list_covering ON booking (
    created_at DESC,
    booking_id,
    property_id,
    user_id,
    status,
    total_price
);

-- Partial index for active bookings
CREATE INDEX IF NOT EXISTS idx_active_bookings ON booking (
    property_id,
    start_date,
    end_date
)
WHERE
    status = 'confirmed';

-- Index for property location queries
CREATE INDEX IF NOT EXISTS idx_property_location_city ON property (location_id) INCLUDE (
    name,
    price_per_night,
    host_id
);

-- Query Optimization Techniques Used

/*
1. **Field Selection Optimization**:
- Removed unnecessary columns from SELECT clause
- Used string concatenation to reduce multiple columns
- Added LIMIT/OFFSET for pagination

2. **JOIN Optimization**:
- Maintained necessary INNER JOINs for data integrity
- Used LEFT JOIN only where nullable relationships exist
- Avoided redundant self-joins

3. **WHERE Clause Optimization**:
- Added filtering conditions to reduce result set early
- Used indexed columns in WHERE clauses
- Applied date range filtering for temporal data

4. **ORDER BY Optimization**:
- Used indexed columns for sorting
- Considered pagination requirements

5. **Index Strategy**:
- Created composite indexes for multi-column queries
- Used partial indexes for filtered queries
- Implemented covering indexes to avoid table lookups

6. **Aggregation Optimization**:
- Used appropriate GROUP BY clauses
- Leveraged conditional aggregation with CASE statements
- Added date filtering for time-based aggregations
*/

-- 6. Django ORM Equivalent Optimizations

/*
For Django developers, here are the equivalent optimizations:

1. **Use select_related() for Foreign Keys**:
Booking.objects.select_related('user', 'property__host', 'property__location')

2. **Use prefetch_related() for Reverse Relations**:
Booking.objects.prefetch_related('payment_set')

3. **Use only() to Limit Fields**:
Booking.objects.only('booking_id', 'start_date', 'end_date', 'total_price')

4. **Use values() for Aggregations**:
Booking.objects.values('property__location__city').annotate(total=Count('booking_id'))

5. **Use database functions**:
from django.db.models import Concat, Value
Booking.objects.annotate(guest_name=Concat('user__first_name', Value(' '), 'user__last_name'))

6. **Use queryset pagination**:
from django.core.paginator import Paginator
paginator = Paginator(queryset, 20)
*/

-- 7. Monitoring and Maintenance

-- Queries to monitor index usage and performance

-- Check index usage statistics
SELECT
    schemaname,
    relname AS tablename,
    indexrelname AS indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE
    schemaname = 'public'
ORDER BY idx_scan DESC;

-- Check table statistics
SELECT
    schemaname,
    relname AS tablename,
    n_tup_ins,
    n_tup_upd,
    n_tup_del,
    n_live_tup,
    n_dead_tup,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables
WHERE
    schemaname = 'public'
ORDER BY n_live_tup DESC;

-- Check slow queries (requires pg_stat_statements extension)
-- SELECT query, calls, total_time, mean_time, rows
-- FROM pg_stat_statements
-- WHERE query LIKE '%booking%'
-- ORDER BY total_time DESC
-- LIMIT 10;