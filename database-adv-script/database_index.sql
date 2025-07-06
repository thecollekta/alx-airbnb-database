-- Database Indexes for Performance Optimization for Airbnb Clone Database
-- Following Django best practices and PostgreSQL optimization patterns

-- Drop all existing indexes created by this script in dependency order
DROP INDEX IF EXISTS idx_booking_summary_covering CASCADE;
DROP INDEX IF EXISTS idx_booking_availability_check CASCADE;
DROP INDEX IF EXISTS idx_booking_active_pending CASCADE;
DROP INDEX IF EXISTS idx_booking_active_confirmed CASCADE;
DROP INDEX IF EXISTS idx_booking_property_status_date CASCADE;
DROP INDEX IF EXISTS idx_booking_user_status_date CASCADE;
DROP INDEX IF EXISTS idx_revenue_by_location CASCADE;
DROP INDEX IF EXISTS idx_user_activity_tracking CASCADE;
DROP INDEX IF EXISTS idx_booking_created_date CASCADE;
DROP INDEX IF EXISTS idx_booking_total_price CASCADE;
DROP INDEX IF EXISTS idx_booking_status_dates CASCADE;
DROP INDEX IF EXISTS idx_booking_status CASCADE;
DROP INDEX IF EXISTS idx_booking_end_date CASCADE;
DROP INDEX IF EXISTS idx_booking_start_date CASCADE;
DROP INDEX IF EXISTS idx_booking_date_range CASCADE;
DROP INDEX IF EXISTS idx_booking_property_id CASCADE;
DROP INDEX IF EXISTS idx_booking_user_id CASCADE;
DROP INDEX IF EXISTS idx_payment_method_date_amount CASCADE;
DROP INDEX IF EXISTS idx_payment_booking_unique CASCADE;
DROP INDEX IF EXISTS idx_payment_amount CASCADE;
DROP INDEX IF EXISTS idx_payment_date CASCADE;
DROP INDEX IF EXISTS idx_payment_method CASCADE;
DROP INDEX IF EXISTS idx_payment_booking_id CASCADE;
DROP INDEX IF EXISTS idx_review_property_analytics CASCADE;
DROP INDEX IF EXISTS idx_review_created_date CASCADE;
DROP INDEX IF EXISTS idx_review_property_rating CASCADE;
DROP INDEX IF EXISTS idx_review_rating CASCADE;
DROP INDEX IF EXISTS idx_review_user_id CASCADE;
DROP INDEX IF EXISTS idx_review_property_id CASCADE;
DROP INDEX IF EXISTS idx_message_recent CASCADE;
DROP INDEX IF EXISTS idx_message_conversation CASCADE;
DROP INDEX IF EXISTS idx_message_thread_recipient_sender CASCADE;
DROP INDEX IF EXISTS idx_message_thread_sender_recipient CASCADE;
DROP INDEX IF EXISTS idx_message_sent_date CASCADE;
DROP INDEX IF EXISTS idx_message_recipient_id CASCADE;
DROP INDEX IF EXISTS idx_message_sender_id CASCADE;
DROP INDEX IF EXISTS idx_property_performance CASCADE;
DROP INDEX IF EXISTS idx_property_search_advanced CASCADE;
DROP INDEX IF EXISTS idx_property_search_composite CASCADE;
DROP INDEX IF EXISTS idx_property_created_date CASCADE;
DROP INDEX IF EXISTS idx_property_name_search CASCADE;
DROP INDEX IF EXISTS idx_property_price_location CASCADE;
DROP INDEX IF EXISTS idx_property_price_range CASCADE;
DROP INDEX IF EXISTS idx_property_location_id CASCADE;
DROP INDEX IF EXISTS idx_property_host_id CASCADE;
DROP INDEX IF EXISTS idx_property_listing_covering CASCADE;
DROP INDEX IF EXISTS idx_property_description_fts CASCADE;
DROP INDEX IF EXISTS idx_property_name_fts CASCADE;
DROP INDEX IF EXISTS idx_property_updated_at CASCADE;
DROP INDEX IF EXISTS idx_location_property_density CASCADE;
DROP INDEX IF EXISTS idx_location_full_address CASCADE;
DROP INDEX IF EXISTS idx_location_country_filter CASCADE;
DROP INDEX IF EXISTS idx_location_postal_lookup CASCADE;
DROP INDEX IF EXISTS idx_location_city_search CASCADE;
DROP INDEX IF EXISTS idx_location_coordinates CASCADE;
DROP INDEX IF EXISTS idx_user_engagement CASCADE;
DROP INDEX IF EXISTS idx_user_profile_covering CASCADE;
DROP INDEX IF EXISTS idx_user_phone CASCADE;
DROP INDEX IF EXISTS idx_user_created_date CASCADE;
DROP INDEX IF EXISTS idx_user_name_search CASCADE;
DROP INDEX IF EXISTS idx_user_role_filter CASCADE;
DROP INDEX IF EXISTS idx_user_email_lookup CASCADE;
DROP INDEX IF EXISTS idx_user_email_unique CASCADE;
DROP INDEX IF EXISTS idx_user_updated_at CASCADE;

-- Primary Performance Indexes

-- User Table Indexes
-- High-usage columns: email (authentication), role (filtering), created_at (sorting)
CREATE INDEX idx_user_email_lookup ON "user"(email) WHERE email IS NOT NULL;
CREATE INDEX idx_user_role_filter ON "user"(role);
CREATE INDEX idx_user_name_search ON "user"(first_name, last_name);
CREATE INDEX idx_user_created_date ON "user"(created_at DESC);

-- Phone number lookup for contact functionality
CREATE INDEX idx_user_phone ON "user"(phone_number) WHERE phone_number IS NOT NULL;

-- Location Table Indexes

-- Geospatial indexes for location-based searches
CREATE INDEX idx_location_coordinates ON location(latitude, longitude) WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
CREATE INDEX idx_location_city_search ON location(city, state_province, country);
CREATE INDEX idx_location_postal_lookup ON location(postal_code);
CREATE INDEX idx_location_country_filter ON location(country);

-- Composite index for address matching
CREATE INDEX idx_location_full_address ON location(street_address, city, postal_code);

-- Property Table Indexes

-- Host-related queries (most frequent)
CREATE INDEX idx_property_host_id ON property(host_id);
CREATE INDEX idx_property_location_id ON property(location_id);

-- Price filtering and sorting (property search)
CREATE INDEX idx_property_price_range ON property(price_per_night);
CREATE INDEX idx_property_price_location ON property(price_per_night, location_id);

-- Property search and listing
CREATE INDEX idx_property_name_search ON property(name);
CREATE INDEX idx_property_created_date ON property(created_at DESC);

-- Composite index for property search with location
CREATE INDEX idx_property_search_composite ON property(location_id, price_per_night, created_at DESC);

-- Booking Table Indexes

-- User booking history (most frequent query)
CREATE INDEX idx_booking_user_id ON booking(user_id);
CREATE INDEX idx_booking_property_id ON booking(property_id);

-- Date range queries for availability checking
CREATE INDEX idx_booking_date_range ON booking(property_id, start_date, end_date);
CREATE INDEX idx_booking_start_date ON booking(start_date);
CREATE INDEX idx_booking_end_date ON booking(end_date);

-- Status filtering (confirmed, pending, canceled)
CREATE INDEX idx_booking_status ON booking(status);
CREATE INDEX idx_booking_status_dates ON booking(status, start_date, end_date);

-- Revenue and analytics queries
CREATE INDEX idx_booking_total_price ON booking(total_price);
CREATE INDEX idx_booking_created_date ON booking(created_at DESC);

-- Composite indexes for complex queries
CREATE INDEX idx_booking_user_status_date ON booking(user_id, status, start_date DESC);
CREATE INDEX idx_booking_property_status_date ON booking(property_id, status, start_date DESC);

-- Partial indexes for active bookings
CREATE INDEX idx_booking_active_confirmed ON booking(property_id, start_date, end_date) 
WHERE status = 'confirmed';

CREATE INDEX idx_booking_active_pending ON booking(property_id, start_date, end_date) 
WHERE status = 'pending';

-- Payment Table Indexes

-- Payment lookup and reporting
CREATE INDEX idx_payment_booking_id ON payment(booking_id);
CREATE INDEX idx_payment_method ON payment(payment_method);
CREATE INDEX idx_payment_date ON payment(payment_date DESC);
CREATE INDEX idx_payment_amount ON payment(amount);

-- Financial reporting composite index
CREATE INDEX idx_payment_method_date_amount ON payment(payment_method, payment_date DESC, amount);

-- Review Table Indexes

-- Property review queries (most frequent)
CREATE INDEX idx_review_property_id ON review(property_id);
CREATE INDEX idx_review_user_id ON review(user_id);

-- Rating filtering and sorting
CREATE INDEX idx_review_rating ON review(rating);
CREATE INDEX idx_review_property_rating ON review(property_id, rating);

-- Review timeline
CREATE INDEX idx_review_created_date ON review(created_at DESC);

-- Composite index for property review analytics
CREATE INDEX idx_review_property_analytics ON review(property_id, rating, created_at DESC);

-- Message Table Indexes (Fixed Implementation)

-- Message threading and conversation queries
CREATE INDEX idx_message_sender_id ON message(sender_id);
CREATE INDEX idx_message_recipient_id ON message(recipient_id);
CREATE INDEX idx_message_sent_date ON message(sent_at DESC);

-- Optimized conversation thread indexes (replaces LEAST/GREATEST version)
CREATE INDEX idx_message_thread_sender_recipient ON message(sender_id, recipient_id, sent_at DESC);
CREATE INDEX idx_message_thread_recipient_sender ON message(recipient_id, sender_id, sent_at DESC);

-- Recent messages lookup
CREATE INDEX idx_message_recent ON message(recipient_id, sent_at DESC);

-- Advanced Composite Indexes for ComplexQueries

-- Property search with location and price filters
CREATE INDEX idx_property_search_advanced ON property(location_id, price_per_night, created_at DESC) 
INCLUDE (name, description);

-- Booking availability checking optimization
CREATE INDEX idx_booking_availability_check ON booking(property_id, start_date, end_date, status) 
WHERE status IN ('confirmed', 'pending');

-- User activity tracking
CREATE INDEX idx_user_activity_tracking ON booking(user_id, created_at DESC, status, total_price);

-- Revenue analysis by location
CREATE INDEX idx_revenue_by_location ON booking(property_id, created_at, total_price, status) 
WHERE status = 'confirmed';

-- Specialized Indexes for Analytics

-- Property performance analytics
CREATE INDEX idx_property_performance ON property(host_id, created_at DESC, price_per_night);

-- User engagement metrics
CREATE INDEX idx_user_engagement ON "user"(role, created_at DESC);

-- Location-based property density
CREATE INDEX idx_location_property_density ON property(location_id, created_at DESC);

-- Full text Search Indexes

-- Property description search (if full-text search is needed)
CREATE INDEX idx_property_description_fts ON property USING gin(to_tsvector('english', description));
CREATE INDEX idx_property_name_fts ON property USING gin(to_tsvector('english', name));

-- Indexes for Frequently Accessed Columns

-- User profile data covering index
CREATE INDEX idx_user_profile_covering ON "user"(user_id) 
INCLUDE (first_name, last_name, email, phone_number, role);

-- Property listing covering index
CREATE INDEX idx_property_listing_covering ON property(property_id) 
INCLUDE (name, price_per_night, location_id, host_id);

-- Booking summary covering index
CREATE INDEX idx_booking_summary_covering ON booking(booking_id) 
INCLUDE (property_id, user_id, start_date, end_date, total_price, status);

-- Constraint Indexes (Performance Improvement)

-- Ensure unique constraint indexes are optimized
CREATE UNIQUE INDEX idx_user_email_unique ON "user"(email) WHERE email IS NOT NULL;
CREATE UNIQUE INDEX idx_payment_booking_unique ON payment(booking_id);

-- Maintenance Indexes

-- Updated timestamp indexes for maintenance operations
CREATE INDEX idx_user_updated_at ON "user"(updated_at DESC);
CREATE INDEX idx_property_updated_at ON property(updated_at DESC);

-- Query Optimization Comments

-- Index usage patterns:
-- 1. Single-column indexes: Fast lookups and filtering
-- 2. Composite indexes: Multi-column queries and sorting
-- 3. Partial indexes: Filtered data subsets
-- 4. Covering indexes: Include frequently accessed columns
-- 5. Expression indexes: Computed values and functions

-- Performance monitoring queries:
-- SELECT schemaname, tablename, indexname, idx_tup_read, idx_tup_fetch 
-- FROM pg_stat_user_indexes ORDER BY idx_tup_read DESC;

-- Index size monitoring:
-- SELECT schemaname, tablename, indexname, pg_size_pretty(pg_relation_size(indexrelid)) 
-- FROM pg_stat_user_indexes ORDER BY pg_relation_size(indexrelid) DESC;

-- Index Maintenance Commands

-- Analyze tables after index creation
ANALYZE "user";
ANALYZE location;
ANALYZE property;
ANALYZE booking;
ANALYZE payment;
ANALYZE review;
ANALYZE message;

EXPLAIN ANALYZE 
SELECT b.property_id, 
       SUM(b.total_price) as total_revenue,
       COUNT(*) as booking_count
FROM booking b
WHERE b.status = 'confirmed'
AND b.created_at >= '2025-01-01'
GROUP BY b.property_id
ORDER BY total_revenue DESC;
-- Update table statistics
-- UPDATE pg_stat_user_tables SET n_tup_ins = n_tup_ins WHERE schemaname = 'public';

-- Performance Validation

-- Verify index usage with EXPLAIN ANALYZE
-- Example queries to test:

-- 1. User authentication query
-- EXPLAIN ANALYZE SELECT * FROM "user" WHERE email = 'efua.danso@gmail.com';

-- 2. Property search by location and price
-- EXPLAIN ANALYZE 
-- SELECT p.*, l.city, l.country 
-- FROM property p 
-- JOIN location l ON p.location_id = l.location_id 
-- WHERE l.city = 'Accra' AND p.price_per_night BETWEEN 100 AND 300;

-- 3. Booking availability check
-- EXPLAIN ANALYZE 
-- SELECT * FROM booking 
-- WHERE property_id = 'sample-uuid' 
-- AND start_date <= '2025-07-15' 
-- AND end_date >= '2025-07-10' 
-- AND status IN ('confirmed', 'pending');

-- 4. User booking history
-- EXPLAIN ANALYZE 
-- SELECT b.*, p.name 
-- FROM booking b 
-- JOIN property p ON b.property_id = p.property_id 
-- WHERE b.user_id = 'sample-uuid' 
-- ORDER BY b.start_date DESC;

-- Monitoring and Maintenance

-- Create monitoring view for index usage
CREATE OR REPLACE VIEW v_index_usage_stats AS
SELECT 
    schemaname,
    relname AS tablename,
    indexrelname AS indexname,
    idx_tup_read,
    idx_tup_fetch,
    idx_tup_read + idx_tup_fetch as total_usage,
    pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY total_usage DESC;

-- Monitor unused indexes
CREATE OR REPLACE VIEW v_unused_indexes AS
SELECT 
    schemaname,
    relname AS tablename,  -- Corrected column name
    indexrelname AS indexname,  -- Corrected column name
    pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
AND idx_tup_read = 0
AND idx_tup_fetch = 0
ORDER BY pg_relation_size(indexrelid) DESC;

-- Comments and Documentation

COMMENT ON INDEX idx_user_email_lookup IS 'Optimizes user authentication queries';
COMMENT ON INDEX idx_booking_date_range IS 'Critical for property availability checking';
COMMENT ON INDEX idx_property_search_composite IS 'Optimizes property search with location and price filters';
COMMENT ON INDEX idx_booking_availability_check IS 'Specialized index for booking availability queries';
COMMENT ON INDEX idx_message_thread_sender_recipient IS 'Optimizes message thread retrieval (A→B direction)';
COMMENT ON INDEX idx_message_thread_recipient_sender IS 'Optimizes message thread retrieval (B→A direction)';
COMMENT ON INDEX idx_review_property_analytics IS 'Supports property rating analytics';