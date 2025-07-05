-- Aggregation and Window Functions for Airbnb Clone Database
-- This implements comprehensive aggregation and window function operations
-- Following Django best practices and SQL performance optimization standards

-- Aggregation Queries

-- Basic COUNT aggregation: Total bookings per user
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    COUNT(b.booking_id) AS total_bookings
FROM "user" u
LEFT JOIN booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name, u.email, u.role
ORDER BY total_bookings DESC, u.last_name;

-- Improved aggregation with booking status breakdown
SELECT 
    u.user_id,
    u.first_name || ' ' || u.last_name AS full_name,
    u.email,
    u.role,
    COUNT(b.booking_id) AS total_bookings,
    COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) AS confirmed_bookings,
    COUNT(CASE WHEN b.status = 'pending' THEN 1 END) AS pending_bookings,
    COUNT(CASE WHEN b.status = 'canceled' THEN 1 END) AS canceled_bookings,
    COALESCE(SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price END), 0) AS total_spent,
    COALESCE(AVG(CASE WHEN b.status = 'confirmed' THEN b.total_price END), 0) AS avg_booking_value,
    MIN(b.created_at) AS first_booking_date,
    MAX(b.created_at) AS last_booking_date
FROM "user" u
LEFT JOIN booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name, u.email, u.role
HAVING COUNT(b.booking_id) > 0  -- Only users with bookings
ORDER BY total_bookings DESC, total_spent DESC;

-- User engagement categories based on booking behavior
SELECT 
    booking_category,
    COUNT(*) AS user_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage,
    MIN(total_bookings) AS min_bookings,
    MAX(total_bookings) AS max_bookings,
    AVG(total_bookings) AS avg_bookings
FROM (
    SELECT 
        u.user_id,
        COUNT(b.booking_id) AS total_bookings,
        CASE 
            WHEN COUNT(b.booking_id) = 0 THEN 'No Bookings'
            WHEN COUNT(b.booking_id) BETWEEN 1 AND 2 THEN 'Occasional (1-2)'
            WHEN COUNT(b.booking_id) BETWEEN 3 AND 5 THEN 'Regular (3-5)'
            WHEN COUNT(b.booking_id) BETWEEN 6 AND 10 THEN 'Frequent (6-10)'
            ELSE 'Power User (10+)'
        END AS booking_category
    FROM "user" u
    LEFT JOIN booking b ON u.user_id = b.user_id
    GROUP BY u.user_id
) user_bookings
GROUP BY booking_category
ORDER BY 
    CASE booking_category
        WHEN 'No Bookings' THEN 1
        WHEN 'Occasional (1-2)' THEN 2
        WHEN 'Regular (3-5)' THEN 3
        WHEN 'Frequent (6-10)' THEN 4
        WHEN 'Power User (10+)' THEN 5
    END;

-- Window Functions: Property Rankings

-- Basic window function: Properties ranked by total bookings
SELECT 
    p.property_id,
    p.name AS property_name,
    p.price_per_night,
    l.city,
    l.country,
    host.first_name || ' ' || host.last_name AS host_name,
    COUNT(b.booking_id) AS total_bookings,
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank_with_ties,
    DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS dense_booking_rank
FROM property p
LEFT JOIN booking b ON p.property_id = b.property_id
LEFT JOIN "user" host ON p.host_id = host.user_id
LEFT JOIN location l ON p.location_id = l.location_id
GROUP BY p.property_id, p.name, p.price_per_night, l.city, l.country, host.first_name, host.last_name
ORDER BY total_bookings DESC, p.name;

-- Advanced window functions: Multiple ranking criteria
SELECT 
    p.property_id,
    p.name AS property_name,
    p.price_per_night,
    l.city,
    l.country,
    host.first_name || ' ' || host.last_name AS host_name,
    COUNT(b.booking_id) AS total_bookings,
    COALESCE(SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price END), 0) AS total_revenue,
    COALESCE(AVG(r.rating), 0) AS avg_rating,
    COUNT(r.review_id) AS total_reviews,
    
    -- Ranking by different criteria
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) AS rank_by_bookings,
    ROW_NUMBER() OVER (ORDER BY COALESCE(SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price END), 0) DESC) AS rank_by_revenue,
    ROW_NUMBER() OVER (ORDER BY COALESCE(AVG(r.rating), 0) DESC) AS rank_by_rating,
    
    -- Partitioned rankings by city
    ROW_NUMBER() OVER (PARTITION BY l.city ORDER BY COUNT(b.booking_id) DESC) AS city_rank_by_bookings,
    ROW_NUMBER() OVER (PARTITION BY l.country ORDER BY COUNT(b.booking_id) DESC) AS country_rank_by_bookings,
    
    -- Percentile rankings
    PERCENT_RANK() OVER (ORDER BY COUNT(b.booking_id)) AS booking_percentile,
    NTILE(4) OVER (ORDER BY COUNT(b.booking_id)) AS booking_quartile,
    
    -- Performance indicators
    CASE 
        WHEN COUNT(b.booking_id) = 0 THEN 'No Bookings'
        WHEN NTILE(4) OVER (ORDER BY COUNT(b.booking_id)) = 4 THEN 'Top 25%'
        WHEN NTILE(4) OVER (ORDER BY COUNT(b.booking_id)) = 3 THEN 'Top 50%'
        WHEN NTILE(4) OVER (ORDER BY COUNT(b.booking_id)) = 2 THEN 'Top 75%'
        ELSE 'Bottom 25%'
    END AS performance_tier
FROM property p
LEFT JOIN booking b ON p.property_id = b.property_id
LEFT JOIN "user" host ON p.host_id = host.user_id
LEFT JOIN location l ON p.location_id = l.location_id
LEFT JOIN review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name, p.price_per_night, l.city, l.country, host.first_name, host.last_name
ORDER BY total_bookings DESC, total_revenue DESC;
