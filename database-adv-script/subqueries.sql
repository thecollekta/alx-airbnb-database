-- Advanced Subqueries for Airbnb Clone Database

-- Non Correlated Subqueries

-- Find all properties where the average rating is greater than 4.0
-- Non-correlated subquery: Inner query executes once and returns property IDs
SELECT 
    p.property_id,
    p.name,
    p.price_per_night,
    l.city,
    l.country
FROM property p
JOIN location l ON p.location_id = l.location_id
WHERE p.property_id IN (
    SELECT r.property_id
    FROM review r
    GROUP BY r.property_id
    HAVING AVG(r.rating) > 4.0
)
ORDER BY p.name;

-- Alternative approach using EXISTS for efficiency
SELECT 
    p.property_id,
    p.name,
    p.price_per_night,
    l.city,
    l.country
FROM property p
JOIN location l ON p.location_id = l.location_id
WHERE EXISTS (
    SELECT 1
    FROM review r
    WHERE r.property_id = p.property_id
    GROUP BY r.property_id
    HAVING AVG(r.rating) > 4.0
)
ORDER BY p.name;

-- Correlated Subqueries

-- Find users who have made more than 3 bookings
-- Correlated subquery: Inner query executes for each row in the outer query
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role
FROM "user" u
WHERE (
    SELECT COUNT(*)
    FROM booking b
    WHERE b.user_id = u.user_id
) > 3
ORDER BY u.last_name, u.first_name;

-- Alternative using EXISTS for better performance
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role
FROM "user" u
WHERE EXISTS (
    SELECT 1
    FROM booking b
    WHERE b.user_id = u.user_id
    GROUP BY b.user_id
    HAVING COUNT(*) > 3
)
ORDER BY u.last_name, u.first_name;