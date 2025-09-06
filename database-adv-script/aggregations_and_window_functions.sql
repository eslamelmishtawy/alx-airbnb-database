-- Aggregations and Window Functions Queries
-- AirBnB Database - SQL Aggregation and Window Function Analysis
-- Created: September 6, 2025

-- ================================
-- AGGREGATION QUERIES
-- ================================

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

-- Query 2: Total revenue by property
SELECT
    p.property_id,
    p.name AS property_name,
    p.location,
    COUNT(b.booking_id) AS total_bookings,
    SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) AS total_revenue,
    AVG(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE NULL END) AS avg_booking_value
FROM Property p
    LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.location
ORDER BY total_revenue DESC;

-- Query 3: Monthly booking statistics
SELECT
    YEAR(b.start_date) AS booking_year,
    MONTH(b.start_date) AS booking_month,
    COUNT(b.booking_id) AS monthly_bookings,
    SUM(b.total_price) AS monthly_revenue,
    AVG(b.total_price) AS avg_booking_value
FROM Booking b
WHERE b.status = 'confirmed'
GROUP BY YEAR(b.start_date), MONTH(b.start_date)
ORDER BY booking_year DESC, booking_month DESC;

-- ================================
-- WINDOW FUNCTION QUERIES
-- ================================

-- Query 4: Rank properties based on total number of bookings using ROW_NUMBER
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

-- Query 5: Rank properties based on total number of bookings using RANK
-- (Allows for ties in ranking)
SELECT
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    CONCAT(h.first_name, ' ', h.last_name) AS host_name,
    COUNT(b.booking_id) AS total_bookings,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank,
    DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS dense_booking_rank
FROM Property p
    LEFT JOIN Booking b ON p.property_id = b.property_id
    LEFT JOIN User h ON p.host_id = h.user_id
GROUP BY p.property_id, p.name, p.location, p.pricepernight, h.first_name, h.last_name
ORDER BY booking_rank, p.name;

-- Query 6: Properties ranked within each location
SELECT
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    RANK() OVER (PARTITION BY p.location ORDER BY COUNT(b.booking_id) DESC) AS location_rank,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS overall_rank
FROM Property p
    LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.location, p.pricepernight
ORDER BY p.location, location_rank;

-- Query 7: Running total of bookings by date
SELECT
    DATE(b.created_at) AS booking_date,
    COUNT(b.booking_id) AS daily_bookings,
    SUM(COUNT(b.booking_id)) OVER (ORDER BY DATE(b.created_at)) AS running_total_bookings
FROM Booking b
WHERE b.status = 'confirmed'
GROUP BY DATE(b.created_at)
ORDER BY booking_date;

-- Query 8: User ranking by booking frequency with percentiles
SELECT
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS user_name,
    COUNT(b.booking_id) AS total_bookings,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank,
    PERCENT_RANK() OVER (ORDER BY COUNT(b.booking_id)) AS booking_percentile,
    NTILE(4) OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_quartile
FROM User u
    LEFT JOIN Booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name
HAVING COUNT(b.booking_id) > 0
ORDER BY total_bookings DESC;

-- Query 9: Property performance with moving averages
SELECT
    p.property_id,
    p.name AS property_name,
    DATE(b.created_at) AS booking_date,
    COUNT(b.booking_id) AS daily_bookings,
    AVG(COUNT(b.booking_id)) OVER (
        PARTITION BY p.property_id
        ORDER BY DATE(b.created_at)
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS seven_day_avg_bookings
FROM Property p
    INNER JOIN Booking b ON p.property_id = b.property_id
WHERE b.status = 'confirmed'
GROUP BY p.property_id, p.name, DATE(b.created_at)
ORDER BY p.property_id, booking_date;

-- Query 10: Revenue analysis with window functions
SELECT
    YEAR(b.start_date) AS booking_year,
    MONTH(b.start_date) AS booking_month,
    SUM(b.total_price) AS monthly_revenue,
    LAG(SUM(b.total_price)) OVER (ORDER BY YEAR(b.start_date), MONTH(b.start_date)) AS previous_month_revenue,
    SUM(b.total_price) - LAG(SUM(b.total_price)) OVER (ORDER BY YEAR(b.start_date), MONTH(b.start_date)) AS revenue_change,
    ROUND(
        ((SUM(b.total_price) - LAG(SUM(b.total_price)) OVER (ORDER BY YEAR(b.start_date), MONTH(b.start_date))) /
         LAG(SUM(b.total_price)) OVER (ORDER BY YEAR(b.start_date), MONTH(b.start_date))) * 100, 2
    ) AS revenue_change_percent
FROM Booking b
WHERE b.status = 'confirmed'
GROUP BY YEAR(b.start_date), MONTH(b.start_date)
ORDER BY booking_year, booking_month;
