-- Performance Monitoring and Analysis
-- AirBnB Database - Query Performance Optimization
-- Created: September 6, 2025

-- ================================
-- ENABLE PERFORMANCE MONITORING
-- ================================

-- Enable query profiling
SET profiling = 1;
SET profiling_history_size = 15;

-- Enable slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 0.5;  -- Log queries taking more than 0.5 seconds
SET GLOBAL log_queries_not_using_indexes = 'ON';

-- Enable performance schema for detailed analysis
UPDATE performance_schema.setup_instruments
SET ENABLED = 'YES', TIMED = 'YES'
WHERE NAME LIKE 'statement/%';

UPDATE performance_schema.setup_consumers
SET ENABLED = 'YES'
WHERE NAME LIKE 'events_statements_%';

-- ================================
-- FREQUENTLY USED QUERIES ANALYSIS
-- ================================

-- Query 1: User Authentication (Most Critical)
-- BEFORE OPTIMIZATION
SELECT user_id, first_name, last_name, role, password_hash
FROM User
WHERE email = 'john.doe@example.com';

-- Performance analysis
EXPLAIN FORMAT=JSON
SELECT user_id, first_name, last_name, role, password_hash
FROM User
WHERE email = 'john.doe@example.com';

-- Query 2: Property Search by Location and Price
-- BEFORE OPTIMIZATION
SELECT
    p.property_id,
    p.name,
    p.location,
    p.pricepernight,
    p.description,
    CONCAT(u.first_name, ' ', u.last_name) AS host_name,
    AVG(r.rating) AS avg_rating,
    COUNT(r.review_id) AS review_count
FROM Property p
INNER JOIN User u ON p.host_id = u.user_id
LEFT JOIN Review r ON p.property_id = r.property_id
WHERE p.location LIKE '%New York%'
AND p.pricepernight BETWEEN 100 AND 300
GROUP BY p.property_id, p.name, p.location, p.pricepernight, p.description, u.first_name, u.last_name
HAVING COUNT(r.review_id) >= 5
ORDER BY avg_rating DESC, p.pricepernight ASC
LIMIT 20;

-- Performance analysis
EXPLAIN FORMAT=JSON
SELECT
    p.property_id,
    p.name,
    p.location,
    p.pricepernight,
    CONCAT(u.first_name, ' ', u.last_name) AS host_name,
    AVG(r.rating) AS avg_rating,
    COUNT(r.review_id) AS review_count
FROM Property p
INNER JOIN User u ON p.host_id = u.user_id
LEFT JOIN Review r ON p.property_id = r.property_id
WHERE p.location LIKE '%New York%'
AND p.pricepernight BETWEEN 100 AND 300
GROUP BY p.property_id, p.name, p.location, p.pricepernight, u.first_name, u.last_name
HAVING COUNT(r.review_id) >= 5
ORDER BY AVG(r.rating) DESC, p.pricepernight ASC
LIMIT 20;

-- Query 3: Booking Availability Check
-- BEFORE OPTIMIZATION
SELECT COUNT(*) as conflicting_bookings
FROM Booking b
WHERE b.property_id = 'sample-property-uuid'
AND b.status IN ('confirmed', 'pending')
AND NOT (
    b.end_date <= '2025-12-01' OR
    b.start_date >= '2025-12-15'
);

-- Performance analysis
EXPLAIN FORMAT=JSON
SELECT COUNT(*) as conflicting_bookings
FROM Booking b
WHERE b.property_id = 'sample-property-uuid'
AND b.status IN ('confirmed', 'pending')
AND NOT (
    b.end_date <= '2025-12-01' OR
    b.start_date >= '2025-12-15'
);

-- Query 4: User Dashboard - Recent Bookings
-- BEFORE OPTIMIZATION
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    p.name AS property_name,
    p.location,
    CASE
        WHEN pay.payment_id IS NOT NULL THEN 'Paid'
        ELSE 'Pending'
    END AS payment_status
FROM Booking b
INNER JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.user_id = 'sample-user-uuid'
AND b.created_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
ORDER BY b.created_at DESC;

-- Performance analysis
EXPLAIN FORMAT=JSON
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    p.name AS property_name,
    p.location,
    CASE
        WHEN pay.payment_id IS NOT NULL THEN 'Paid'
        ELSE 'Pending'
    END AS payment_status
FROM Booking b
INNER JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.user_id = 'sample-user-uuid'
AND b.created_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
ORDER BY b.created_at DESC;

-- Query 5: Host Revenue Analytics
-- BEFORE OPTIMIZATION
SELECT
    DATE_FORMAT(b.start_date, '%Y-%m') AS booking_month,
    COUNT(b.booking_id) AS total_bookings,
    SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) AS confirmed_revenue,
    SUM(CASE WHEN b.status = 'canceled' THEN b.total_price ELSE 0 END) AS lost_revenue,
    AVG(b.total_price) AS avg_booking_value
FROM Property p
INNER JOIN Booking b ON p.property_id = b.property_id
WHERE p.host_id = 'sample-host-uuid'
AND b.start_date >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(b.start_date, '%Y-%m')
ORDER BY booking_month DESC;

-- Performance analysis
EXPLAIN FORMAT=JSON
SELECT
    DATE_FORMAT(b.start_date, '%Y-%m') AS booking_month,
    COUNT(b.booking_id) AS total_bookings,
    SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) AS confirmed_revenue,
    AVG(b.total_price) AS avg_booking_value
FROM Property p
INNER JOIN Booking b ON p.property_id = b.property_id
WHERE p.host_id = 'sample-host-uuid'
AND b.start_date >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(b.start_date, '%Y-%m')
ORDER BY booking_month DESC;

-- ================================
-- VIEW QUERY PROFILES
-- ================================

-- Show all profiles
SHOW PROFILES;

-- Get detailed profile for specific query
-- SHOW PROFILE FOR QUERY 1;
-- SHOW PROFILE CPU, BLOCK IO FOR QUERY 2;

-- ================================
-- PERFORMANCE SCHEMA ANALYSIS
-- ================================

-- Top 10 slowest statements
SELECT
    DIGEST_TEXT,
    COUNT_STAR as exec_count,
    AVG_TIMER_WAIT/1000000000 as avg_exec_time_sec,
    MAX_TIMER_WAIT/1000000000 as max_exec_time_sec,
    SUM_TIMER_WAIT/1000000000 as total_exec_time_sec
FROM performance_schema.events_statements_summary_by_digest
ORDER BY AVG_TIMER_WAIT DESC
LIMIT 10;

-- Table I/O statistics
SELECT
    OBJECT_SCHEMA,
    OBJECT_NAME,
    COUNT_READ,
    COUNT_WRITE,
    SUM_TIMER_READ/1000000000 as total_read_time_sec,
    SUM_TIMER_WRITE/1000000000 as total_write_time_sec
FROM performance_schema.table_io_waits_summary_by_table
WHERE OBJECT_SCHEMA = DATABASE()
ORDER BY SUM_TIMER_READ DESC;

-- ================================
-- IDENTIFIED BOTTLENECKS & SOLUTIONS
-- ================================

-- BOTTLENECK 1: User Authentication Query
-- Issue: Full table scan on User table for email lookup
-- Solution: Create optimized index for email

-- Check if index exists
SHOW INDEX FROM User WHERE Key_name = 'idx_user_email_optimized';

-- Create optimized email index if not exists
CREATE INDEX IF NOT EXISTS idx_user_email_optimized ON User(email);

-- BOTTLENECK 2: Property Search Query
-- Issue: Complex GROUP BY with multiple JOINs and sorting
-- Solutions: Multiple optimizations needed

-- Create composite index for property search
CREATE INDEX IF NOT EXISTS idx_property_location_price_optimized
ON Property(location, pricepernight, property_id);

-- Create index for review aggregation
CREATE INDEX IF NOT EXISTS idx_review_property_rating_optimized
ON Review(property_id, rating);

-- Create covering index for property details
CREATE INDEX IF NOT EXISTS idx_property_search_covering
ON Property(location, pricepernight, property_id, name, host_id);

-- BOTTLENECK 3: Booking Availability Check
-- Issue: Complex date range logic and missing composite index
-- Solution: Optimized composite index and query rewrite

-- Create optimized booking availability index
CREATE INDEX IF NOT EXISTS idx_booking_availability_optimized
ON Booking(property_id, status, start_date, end_date);

-- BOTTLENECK 4: User Dashboard Query
-- Issue: Missing composite index for user + date filtering
-- Solution: User-specific composite index

-- Create user dashboard index
CREATE INDEX IF NOT EXISTS idx_booking_user_created_optimized
ON Booking(user_id, created_at, booking_id);

-- BOTTLENECK 5: Host Revenue Analytics
-- Issue: Date function in GROUP BY preventing index usage
-- Solution: Separate date column and optimized index

-- Create host analytics index
CREATE INDEX IF NOT EXISTS idx_booking_host_analytics
ON Booking(property_id, start_date, status, total_price);

-- Create property-host lookup index
CREATE INDEX IF NOT EXISTS idx_property_host_lookup
ON Property(host_id, property_id);

-- ================================
-- OPTIMIZED QUERIES (AFTER IMPROVEMENTS)
-- ================================

-- Optimized Query 1: User Authentication
SELECT user_id, first_name, last_name, role, password_hash
FROM User
WHERE email = 'john.doe@example.com';

-- Optimized Query 2: Property Search (Rewritten for better performance)
SELECT
    sub.property_id,
    sub.name,
    sub.location,
    sub.pricepernight,
    sub.host_name,
    COALESCE(rs.avg_rating, 0) AS avg_rating,
    COALESCE(rs.review_count, 0) AS review_count
FROM (
    SELECT
        p.property_id,
        p.name,
        p.location,
        p.pricepernight,
        CONCAT(u.first_name, ' ', u.last_name) AS host_name
    FROM Property p
    INNER JOIN User u ON p.host_id = u.user_id
    WHERE p.location LIKE '%New York%'
    AND p.pricepernight BETWEEN 100 AND 300
) sub
LEFT JOIN (
    SELECT
        property_id,
        AVG(rating) AS avg_rating,
        COUNT(review_id) AS review_count
    FROM Review
    GROUP BY property_id
    HAVING COUNT(review_id) >= 5
) rs ON sub.property_id = rs.property_id
WHERE rs.review_count >= 5 OR rs.review_count IS NULL
ORDER BY rs.avg_rating DESC, sub.pricepernight ASC
LIMIT 20;

-- Optimized Query 3: Booking Availability Check (Rewritten)
SELECT COUNT(*) as conflicting_bookings
FROM Booking b
WHERE b.property_id = 'sample-property-uuid'
AND b.status IN ('confirmed', 'pending')
AND b.start_date < '2025-12-15'
AND b.end_date > '2025-12-01';

-- Optimized Query 4: User Dashboard (Using optimized index)
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    p.name AS property_name,
    p.location,
    CASE
        WHEN pay.payment_id IS NOT NULL THEN 'Paid'
        ELSE 'Pending'
    END AS payment_status
FROM Booking b
INNER JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.user_id = 'sample-user-uuid'
AND b.created_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
ORDER BY b.created_at DESC;

-- Optimized Query 5: Host Revenue Analytics (Rewritten to avoid DATE_FORMAT in GROUP BY)
SELECT
    booking_month,
    total_bookings,
    confirmed_revenue,
    avg_booking_value
FROM (
    SELECT
        CONCAT(YEAR(b.start_date), '-', LPAD(MONTH(b.start_date), 2, '0')) AS booking_month,
        COUNT(b.booking_id) AS total_bookings,
        SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) AS confirmed_revenue,
        AVG(b.total_price) AS avg_booking_value
    FROM Property p
    INNER JOIN Booking b ON p.property_id = b.property_id
    WHERE p.host_id = 'sample-host-uuid'
    AND b.start_date >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
    GROUP BY YEAR(b.start_date), MONTH(b.start_date)
) monthly_data
ORDER BY booking_month DESC;

-- ================================
-- PERFORMANCE COMPARISON
-- ================================

-- Clear previous profiles
SET profiling = 0;
SET profiling = 1;

-- Test optimized queries
SELECT 'Testing optimized User Authentication' AS test_name;
SELECT user_id FROM User WHERE email = 'test@example.com';

SELECT 'Testing optimized Property Search' AS test_name;
-- Run optimized property search query here

SELECT 'Testing optimized Availability Check' AS test_name;
-- Run optimized availability check here

-- View performance comparison
SHOW PROFILES;

-- ================================
-- INDEX USAGE ANALYSIS
-- ================================

-- Check index usage statistics
SELECT
    s.TABLE_SCHEMA,
    s.TABLE_NAME,
    s.INDEX_NAME,
    s.COLUMN_NAME,
    s.CARDINALITY,
    t.TABLE_ROWS,
    ROUND(s.CARDINALITY / t.TABLE_ROWS * 100, 2) AS selectivity_percent
FROM INFORMATION_SCHEMA.STATISTICS s
JOIN INFORMATION_SCHEMA.TABLES t ON s.TABLE_SCHEMA = t.TABLE_SCHEMA
    AND s.TABLE_NAME = t.TABLE_NAME
WHERE s.TABLE_SCHEMA = DATABASE()
AND s.TABLE_NAME IN ('User', 'Property', 'Booking', 'Review', 'Payment')
ORDER BY s.TABLE_NAME, s.INDEX_NAME, s.SEQ_IN_INDEX;

-- Unused indexes analysis
SELECT
    s.TABLE_SCHEMA,
    s.TABLE_NAME,
    s.INDEX_NAME,
    GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX) AS columns
FROM INFORMATION_SCHEMA.STATISTICS s
LEFT JOIN performance_schema.table_io_waits_summary_by_index_usage i
    ON s.TABLE_SCHEMA = i.OBJECT_SCHEMA
    AND s.TABLE_NAME = i.OBJECT_NAME
    AND s.INDEX_NAME = i.INDEX_NAME
WHERE s.TABLE_SCHEMA = DATABASE()
AND s.NON_UNIQUE = 1  -- Exclude primary keys and unique constraints
AND (i.COUNT_READ IS NULL OR i.COUNT_READ = 0)
GROUP BY s.TABLE_SCHEMA, s.TABLE_NAME, s.INDEX_NAME;

-- ================================
-- MONITORING QUERIES
-- ================================

-- Query to monitor slow queries over time
CREATE VIEW v_slow_query_analysis AS
SELECT
    DATE(FROM_UNIXTIME(UNIX_TIMESTAMP() - TIMER_START/1000000000)) as query_date,
    SUBSTRING(DIGEST_TEXT, 1, 100) as query_snippet,
    COUNT_STAR as execution_count,
    AVG_TIMER_WAIT/1000000000 as avg_duration_sec,
    MAX_TIMER_WAIT/1000000000 as max_duration_sec,
    SUM_ROWS_EXAMINED/COUNT_STAR as avg_rows_examined
FROM performance_schema.events_statements_summary_by_digest
WHERE DIGEST_TEXT IS NOT NULL
AND AVG_TIMER_WAIT/1000000000 > 0.1  -- Only queries taking more than 0.1 seconds
ORDER BY avg_duration_sec DESC;

-- Query to monitor table access patterns
CREATE VIEW v_table_access_patterns AS
SELECT
    OBJECT_NAME as table_name,
    COUNT_READ as read_operations,
    COUNT_WRITE as write_operations,
    SUM_TIMER_READ/1000000000 as total_read_time_sec,
    SUM_TIMER_WRITE/1000000000 as total_write_time_sec,
    ROUND(SUM_TIMER_READ/COUNT_READ/1000000, 2) as avg_read_time_ms,
    ROUND(SUM_TIMER_WRITE/COUNT_WRITE/1000000, 2) as avg_write_time_ms
FROM performance_schema.table_io_waits_summary_by_table
WHERE OBJECT_SCHEMA = DATABASE()
AND COUNT_READ > 0
ORDER BY total_read_time_sec DESC;

-- ================================
-- CLEANUP AND MAINTENANCE
-- ================================

-- Update table statistics after index changes
ANALYZE TABLE User;
ANALYZE TABLE Property;
ANALYZE TABLE Booking;
ANALYZE TABLE Review;
ANALYZE TABLE Payment;

-- Reset performance schema statistics for fresh monitoring
CALL sys.ps_truncate_all_tables(FALSE);

-- Create monitoring procedure
DELIMITER $$

CREATE PROCEDURE MonitorPerformance()
BEGIN
    -- Display current slow queries
    SELECT 'Top 5 Slowest Queries' as report_section;
    SELECT
        SUBSTRING(DIGEST_TEXT, 1, 80) as query_snippet,
        COUNT_STAR as executions,
        ROUND(AVG_TIMER_WAIT/1000000000, 3) as avg_duration_sec
    FROM performance_schema.events_statements_summary_by_digest
    ORDER BY AVG_TIMER_WAIT DESC
    LIMIT 5;

    -- Display table I/O statistics
    SELECT 'Table I/O Statistics' as report_section;
    SELECT * FROM v_table_access_patterns LIMIT 10;

    -- Display index usage
    SELECT 'Index Usage Analysis' as report_section;
    SELECT
        TABLE_NAME,
        INDEX_NAME,
        COUNT_READ as index_reads,
        COUNT_FETCH as index_fetches
    FROM performance_schema.table_io_waits_summary_by_index_usage
    WHERE OBJECT_SCHEMA = DATABASE()
    AND COUNT_READ > 0
    ORDER BY COUNT_READ DESC
    LIMIT 10;
END$$

DELIMITER ;

-- Schedule regular performance monitoring
-- CALL MonitorPerformance();
