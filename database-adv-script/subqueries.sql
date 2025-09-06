-- SQL Aggregation and Window Functions Queries
-- Objective: Use SQL aggregation and window functions to analyze data

-- Query 1: Find the total number of bookings made by each user
-- Using COUNT function and GROUP BY clause
SELECT
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS user_name,
    u.email,
    u.role,
    COUNT(b.booking_id) AS total_bookings
FROM User u
    LEFT JOIN Booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name, u.email, u.role
ORDER BY total_bookings DESC, u.first_name;

-- Query 2: Rank properties based on total number of bookings using ROW_NUMBER
-- Using window function ROW_NUMBER() to rank properties
SELECT
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    CONCAT(h.first_name, ' ', h.last_name) AS host_name,
    COUNT(b.booking_id) AS total_bookings,
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank
FROM Property p
    LEFT JOIN Booking b ON p.property_id = b.property_id
    LEFT JOIN User h ON p.host_id = h.user_id
GROUP BY p.property_id, p.name, p.location, p.pricepernight, h.first_name, h.last_name
ORDER BY booking_rank;

-- Query 3: Rank properties based on total number of bookings using RANK
-- Using window function RANK() to rank properties (allows for ties)
SELECT
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    CONCAT(h.first_name, ' ', h.last_name) AS host_name,
    COUNT(b.booking_id) AS total_bookings,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank
FROM Property p
    LEFT JOIN Booking b ON p.property_id = b.property_id
    LEFT JOIN User h ON p.host_id = h.user_id
GROUP BY p.property_id, p.name, p.location, p.pricepernight, h.first_name, h.last_name
ORDER BY booking_rank, p.name;

-- Bonus Query 4: Advanced window function - Rank properties by bookings within each location
SELECT
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    CONCAT(h.first_name, ' ', h.last_name) AS host_name,
    COUNT(b.booking_id) AS total_bookings,
    RANK() OVER (PARTITION BY p.location ORDER BY COUNT(b.booking_id) DESC) AS location_rank,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS overall_rank
FROM Property p
    LEFT JOIN Booking b ON p.property_id = b.property_id
    LEFT JOIN User h ON p.host_id = h.user_id
GROUP BY p.property_id, p.name, p.location, p.pricepernight, h.first_name, h.last_name
ORDER BY p.location, location_rank;

-- Bonus Query 5: User booking statistics with percentage of total bookings
SELECT
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS user_name,
    u.role,
    COUNT(b.booking_id) AS total_bookings,
    ROUND(
        (COUNT(b.booking_id) * 100.0 / SUM(COUNT(b.booking_id)) OVER ()),
        2
    ) AS percentage_of_total_bookings,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS user_rank
FROM User u
    LEFT JOIN Booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name, u.role
HAVING COUNT(b.booking_id) > 0
ORDER BY total_bookings DESC;
