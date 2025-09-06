-- Performance Analysis Queries
-- AirBnB Database - Query Optimization Study
-- Created: September 6, 2025

-- ================================
-- INITIAL QUERY (UNOPTIMIZED)
-- ================================

-- Query 1: Initial comprehensive query retrieving all booking details
-- This query retrieves ALL bookings with user, property, and payment details
SELECT
    -- Booking details
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at AS booking_created_at,

    -- User details
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role,
    u.created_at AS user_created_at,

    -- Property details
    p.property_id,
    p.name AS property_name,
    p.description,
    p.location,
    p.pricepernight,
    p.created_at AS property_created_at,
    p.updated_at AS property_updated_at,

    -- Host details (from property)
    h.user_id AS host_id,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    h.role AS host_role,

    -- Payment details
    pay.payment_id,
    pay.amount,
    pay.payment_date,
    pay.payment_method

FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN User h ON p.host_id = h.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;

-- ================================
-- PERFORMANCE ANALYSIS COMMANDS
-- ================================

-- Analyze the initial query performance
EXPLAIN SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at AS booking_created_at,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role,
    u.created_at AS user_created_at,
    p.property_id,
    p.name AS property_name,
    p.description,
    p.location,
    p.pricepernight,
    p.created_at AS property_created_at,
    p.updated_at AS property_updated_at,
    h.user_id AS host_id,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    h.role AS host_role,
    pay.payment_id,
    pay.amount,
    pay.payment_date,
    pay.payment_method
FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN User h ON p.host_id = h.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;

-- ================================
-- OPTIMIZED QUERIES
-- ================================

-- Query 2: Optimized version with reduced columns and better indexing
SELECT
    -- Essential booking details only
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,

    -- Essential user details
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email AS guest_email,

    -- Essential property details
    p.name AS property_name,
    p.location,
    p.pricepernight,

    -- Essential host details
    CONCAT(h.first_name, ' ', h.last_name) AS host_name,

    -- Payment status (optimized)
    CASE
        WHEN pay.payment_id IS NOT NULL THEN 'Paid'
        ELSE 'Pending'
    END AS payment_status,
    pay.amount AS payment_amount

FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN User h ON p.host_id = h.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.created_at >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)  -- Only recent bookings
ORDER BY b.created_at DESC
LIMIT 1000;  -- Limit results for pagination

-- Query 3: Further optimized with subquery for specific use case
-- Get recent bookings with payment status (most common use case)
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    p.name AS property_name,
    p.location,
    (SELECT COUNT(*) FROM Payment WHERE booking_id = b.booking_id) > 0 AS is_paid
FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
WHERE b.status IN ('confirmed', 'pending')
AND b.created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTHS)
ORDER BY b.created_at DESC
LIMIT 100;

-- Query 4: Optimized query with conditional joins based on requirements
-- Only join payment table when payment information is actually needed
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.first_name,
    u.last_name,
    p.name AS property_name,
    p.location
FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
WHERE b.status = 'confirmed'
ORDER BY b.created_at DESC;

-- Query 5: Paginated query for large datasets
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    p.name AS property_name,
    p.location,
    COALESCE(pay.amount, 0) AS payment_amount
FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.booking_id > 'last_seen_booking_id'  -- Cursor-based pagination
ORDER BY b.booking_id
LIMIT 50;

-- ================================
-- PERFORMANCE COMPARISON QUERIES
-- ================================

-- Test query execution time
SET profiling = 1;

-- Run original query
SELECT COUNT(*) FROM (
    SELECT b.booking_id
    FROM Booking b
    INNER JOIN User u ON b.user_id = u.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    INNER JOIN User h ON p.host_id = h.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
) AS original_query;

-- Run optimized query
SELECT COUNT(*) FROM (
    SELECT b.booking_id
    FROM Booking b
    INNER JOIN User u ON b.user_id = u.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    WHERE b.created_at >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
    LIMIT 1000
) AS optimized_query;

-- View performance comparison
SHOW PROFILES;

-- ================================
-- INDEX RECOMMENDATIONS
-- ================================

-- Indexes that should exist for optimal performance
-- (These may already be in database_index.sql)

-- For the main query joins
CREATE INDEX IF NOT EXISTS idx_booking_user_id ON Booking(user_id);
CREATE INDEX IF NOT EXISTS idx_booking_property_id ON Booking(property_id);
CREATE INDEX IF NOT EXISTS idx_property_host_id ON Property(host_id);
CREATE INDEX IF NOT EXISTS idx_payment_booking_id ON Payment(booking_id);

-- For the WHERE clauses in optimized queries
CREATE INDEX IF NOT EXISTS idx_booking_created_at ON Booking(created_at);
CREATE INDEX IF NOT EXISTS idx_booking_status ON Booking(status);

-- Composite indexes for complex queries
CREATE INDEX IF NOT EXISTS idx_booking_status_created_at ON Booking(status, created_at);
CREATE INDEX IF NOT EXISTS idx_booking_created_status_id ON Booking(created_at, status, booking_id);

-- ================================
-- ANALYZE COMMANDS
-- ================================

-- Update table statistics for better query planning
ANALYZE TABLE Booking;
ANALYZE TABLE User;
ANALYZE TABLE Property;
ANALYZE TABLE Payment;

-- ================================
-- MONITORING QUERIES
-- ================================

-- Check slow query log for problematic queries
-- SET GLOBAL slow_query_log = 'ON';
-- SET GLOBAL long_query_time = 1;

-- Monitor index usage
SELECT
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    CARDINALITY
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME IN ('Booking', 'User', 'Property', 'Payment')
ORDER BY TABLE_NAME, INDEX_NAME;
