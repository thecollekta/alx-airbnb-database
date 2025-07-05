-- Advanced SQL Join Queries for Airbnb Clone Database
-- This implements complex join operations with proper indexing and performance optimization
-- It also flows Django best practices and SQL standards

-- INNER JOIN: Retrieve all bookings with their respective users

-- Basic INNER JOIN - All bookings with user information
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.user_id,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number
FROM booking b
INNER JOIN "user" u ON b.user_id = u.user_id
ORDER BY b.created_at DESC;

-- Improved INNER JOIN - Bookings with user and property details
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.first_name || ' ' || u.last_name AS guest_name,
    u.email AS guest_email,
    p.name AS property_name,
    p.price_per_night,
    l.city,
    l.country
FROM booking b
INNER JOIN "user" u ON b.user_id = u.user_id
INNER JOIN property p ON b.property_id = p.property_id
INNER JOIN location l ON p.location_id = l.location_id
WHERE b.status = 'confirmed'
ORDER BY b.start_date DESC;

-- Advanced INNER JOIN with aggregations - Monthly booking summary
SELECT 
    DATE_TRUNC('month', b.start_date) AS booking_month,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS total_revenue,
    AVG(b.total_price) AS avg_booking_value,
    COUNT(DISTINCT u.user_id) AS unique_guests
FROM booking b
INNER JOIN "user" u ON b.user_id = u.user_id
WHERE b.status = 'confirmed'
  AND b.start_date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', b.start_date)
ORDER BY booking_month DESC;

-- 2. LEFT JOIN: Retrieve all properties and their reviews (including properties with no reviews)

-- Basic LEFT JOIN - All properties with review information
SELECT 
    p.property_id,
    p.name AS property_name,
    p.description,
    p.price_per_night,
    r.review_id,
    r.rating,
    r.comment,
    r.created_at AS review_date
FROM property p
LEFT JOIN review r ON p.property_id = r.property_id
ORDER BY p.name, r.created_at DESC;

-- Improved LEFT JOIN - Properties with aggregated review statistics
SELECT 
    p.property_id,
    p.name AS property_name,
    p.price_per_night,
    l.city,
    l.country,
    host.first_name || ' ' || host.last_name AS host_name,
    COUNT(r.review_id) AS total_reviews,
    COALESCE(ROUND(AVG(r.rating::numeric), 2), 0) AS avg_rating,
    COALESCE(MAX(r.created_at), NULL) AS last_review_date,
    CASE 
        WHEN COUNT(r.review_id) = 0 THEN 'No Reviews'
        WHEN AVG(r.rating::numeric) >= 4.5 THEN 'Excellent'
        WHEN AVG(r.rating::numeric) >= 4.0 THEN 'Very Good'
        WHEN AVG(r.rating::numeric) >= 3.5 THEN 'Good'
        WHEN AVG(r.rating::numeric) >= 3.0 THEN 'Average'
        ELSE 'Below Average'
    END AS rating_category
FROM property p
LEFT JOIN review r ON p.property_id = r.property_id
LEFT JOIN "user" host ON p.host_id = host.user_id
LEFT JOIN location l ON p.location_id = l.location_id
GROUP BY p.property_id, p.name, p.price_per_night, l.city, l.country, host.first_name, host.last_name
ORDER BY avg_rating DESC NULLS LAST, total_reviews DESC;

-- Properties without any reviews (potential target for promotion)
SELECT 
    p.property_id,
    p.name AS property_name,
    p.price_per_night,
    l.city,
    l.country,
    host.first_name || ' ' || host.last_name AS host_name,
    p.created_at AS property_created
FROM property p
LEFT JOIN review r ON p.property_id = r.property_id
LEFT JOIN "user" host ON p.host_id = host.user_id
LEFT JOIN location l ON p.location_id = l.location_id
WHERE r.review_id IS NULL
ORDER BY p.created_at DESC;

-- 3. FULL OUTER JOIN: Retrieve all users and all bookings

-- Basic FULL OUTER JOIN - All users and all bookings
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status
FROM "user" u
FULL OUTER JOIN booking b ON u.user_id = b.user_id
ORDER BY u.created_at DESC, b.created_at DESC;

-- Improved FULL OUTER JOIN - User activity analysis
SELECT 
    COALESCE(u.user_id::text, 'ORPHANED_BOOKING') AS user_identifier,
    COALESCE(u.first_name || ' ' || u.last_name, 'Unknown User') AS user_name,
    COALESCE(u.email, 'N/A') AS user_email,
    COALESCE(u.role::text, 'N/A') AS user_role,
    COALESCE(b.booking_id::text, 'NO_BOOKING') AS booking_identifier,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    CASE 
        WHEN u.user_id IS NULL THEN 'Orphaned Booking'
        WHEN b.booking_id IS NULL THEN 'User Without Booking'
        ELSE 'Active User'
    END AS user_booking_status
FROM "user" u
FULL OUTER JOIN booking b ON u.user_id = b.user_id
ORDER BY 
    CASE 
        WHEN u.user_id IS NULL THEN 1  -- Orphaned bookings first
        WHEN b.booking_id IS NULL THEN 2  -- Users without bookings
        ELSE 3  -- Active users
    END,
    COALESCE(b.created_at, u.created_at) DESC;  -- Fixed date ordering

-- User engagement analysis with FULL OUTER JOIN
SELECT 
    engagement_type,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM (
    SELECT 
        CASE 
            WHEN u.user_id IS NULL THEN 'Orphaned Booking'
            WHEN b.booking_id IS NULL THEN 'User Without Booking'
            ELSE 'Active User'
        END AS engagement_type
    FROM "user" u
    FULL OUTER JOIN booking b ON u.user_id = b.user_id
) engagement_analysis
GROUP BY engagement_type
ORDER BY count DESC;
