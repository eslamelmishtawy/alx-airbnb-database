-- Table Partitioning Implementation for Booking Table
-- AirBnB Database - Performance Optimization through Partitioning
-- Created: September 6, 2025

-- ================================
-- PARTITIONING STRATEGY OVERVIEW
-- ================================

/*
Partitioning Strategy: Range Partitioning by start_date
- Monthly partitions for the past 2 years
- Quarterly partitions for older data
- Future partitions for upcoming bookings

Benefits:
1. Partition pruning for date range queries
2. Parallel query execution across partitions
3. Easier maintenance (drop old partitions)
4. Improved backup/restore performance
*/

-- ================================
-- BACKUP EXISTING DATA (SAFETY)
-- ================================

-- Create backup of existing Booking table
CREATE TABLE Booking_backup AS SELECT * FROM Booking;

-- ================================
-- DROP EXISTING FOREIGN KEYS
-- ================================

-- Need to drop foreign key constraints temporarily for partitioning
ALTER TABLE Payment DROP FOREIGN KEY fk_payment_booking;
ALTER TABLE Review DROP FOREIGN KEY fk_review_property;

-- ================================
-- CREATE PARTITIONED BOOKING TABLE
-- ================================

-- Drop existing table (after backup)
DROP TABLE IF EXISTS Booking;

-- Create new partitioned Booking table
CREATE TABLE Booking (
    booking_id CHAR(36) NOT NULL,
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Primary key must include partition column
    PRIMARY KEY (booking_id, start_date),

    -- Indexes for performance
    INDEX idx_booking_property_id (property_id),
    INDEX idx_booking_user_id (user_id),
    INDEX idx_booking_status (status),
    INDEX idx_booking_created_at (created_at),
    INDEX idx_booking_end_date (end_date),

    -- Composite indexes
    INDEX idx_booking_property_dates (property_id, start_date, end_date),
    INDEX idx_booking_user_status (user_id, status),
    INDEX idx_booking_status_dates (status, start_date, end_date),

    -- Check constraints
    CONSTRAINT chk_booking_dates CHECK (end_date > start_date),
    CONSTRAINT chk_total_price CHECK (total_price > 0)
)
PARTITION BY RANGE (YEAR(start_date) * 100 + MONTH(start_date)) (
    -- Historical partitions (2023)
    PARTITION p_2023_01 VALUES LESS THAN (202302),
    PARTITION p_2023_02 VALUES LESS THAN (202303),
    PARTITION p_2023_03 VALUES LESS THAN (202304),
    PARTITION p_2023_04 VALUES LESS THAN (202305),
    PARTITION p_2023_05 VALUES LESS THAN (202306),
    PARTITION p_2023_06 VALUES LESS THAN (202307),
    PARTITION p_2023_07 VALUES LESS THAN (202308),
    PARTITION p_2023_08 VALUES LESS THAN (202309),
    PARTITION p_2023_09 VALUES LESS THAN (202310),
    PARTITION p_2023_10 VALUES LESS THAN (202311),
    PARTITION p_2023_11 VALUES LESS THAN (202312),
    PARTITION p_2023_12 VALUES LESS THAN (202401),

    -- Current year partitions (2024)
    PARTITION p_2024_01 VALUES LESS THAN (202402),
    PARTITION p_2024_02 VALUES LESS THAN (202403),
    PARTITION p_2024_03 VALUES LESS THAN (202404),
    PARTITION p_2024_04 VALUES LESS THAN (202405),
    PARTITION p_2024_05 VALUES LESS THAN (202406),
    PARTITION p_2024_06 VALUES LESS THAN (202407),
    PARTITION p_2024_07 VALUES LESS THAN (202408),
    PARTITION p_2024_08 VALUES LESS THAN (202409),
    PARTITION p_2024_09 VALUES LESS THAN (202410),
    PARTITION p_2024_10 VALUES LESS THAN (202411),
    PARTITION p_2024_11 VALUES LESS THAN (202412),
    PARTITION p_2024_12 VALUES LESS THAN (202501),

    -- Future partitions (2025)
    PARTITION p_2025_01 VALUES LESS THAN (202502),
    PARTITION p_2025_02 VALUES LESS THAN (202503),
    PARTITION p_2025_03 VALUES LESS THAN (202504),
    PARTITION p_2025_04 VALUES LESS THAN (202505),
    PARTITION p_2025_05 VALUES LESS THAN (202506),
    PARTITION p_2025_06 VALUES LESS THAN (202507),
    PARTITION p_2025_07 VALUES LESS THAN (202508),
    PARTITION p_2025_08 VALUES LESS THAN (202509),
    PARTITION p_2025_09 VALUES LESS THAN (202510),
    PARTITION p_2025_10 VALUES LESS THAN (202511),
    PARTITION p_2025_11 VALUES LESS THAN (202512),
    PARTITION p_2025_12 VALUES LESS THAN (202601),

    -- Future partitions (2026 and beyond)
    PARTITION p_2026_Q1 VALUES LESS THAN (202604),
    PARTITION p_2026_Q2 VALUES LESS THAN (202607),
    PARTITION p_2026_Q3 VALUES LESS THAN (202610),
    PARTITION p_2026_Q4 VALUES LESS THAN (202701),

    -- Catch-all for future dates
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- ================================
-- RESTORE DATA FROM BACKUP
-- ================================

-- Insert data back into partitioned table
INSERT INTO Booking
SELECT * FROM Booking_backup;

-- ================================
-- RECREATE FOREIGN KEY CONSTRAINTS
-- ================================

-- Add foreign key constraints back
ALTER TABLE Booking
ADD CONSTRAINT fk_booking_property
    FOREIGN KEY (property_id) REFERENCES Property(property_id)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Booking
ADD CONSTRAINT fk_booking_user
    FOREIGN KEY (user_id) REFERENCES User(user_id)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Recreate Payment table foreign key
ALTER TABLE Payment
ADD CONSTRAINT fk_payment_booking
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- ================================
-- PERFORMANCE TEST QUERIES
-- ================================

-- Query 1: Date range query (should use partition pruning)
-- Test query for current month bookings
EXPLAIN PARTITIONS
SELECT
    booking_id,
    property_id,
    user_id,
    start_date,
    end_date,
    total_price,
    status
FROM Booking
WHERE start_date >= '2025-09-01'
AND start_date < '2025-10-01';

-- Query 2: Multi-month date range query
EXPLAIN PARTITIONS
SELECT
    COUNT(*) as booking_count,
    SUM(total_price) as total_revenue,
    AVG(total_price) as avg_booking_value
FROM Booking
WHERE start_date >= '2025-07-01'
AND start_date < '2025-10-01'
AND status = 'confirmed';

-- Query 3: Year-over-year comparison
EXPLAIN PARTITIONS
SELECT
    YEAR(start_date) as booking_year,
    MONTH(start_date) as booking_month,
    COUNT(*) as monthly_bookings,
    SUM(total_price) as monthly_revenue
FROM Booking
WHERE start_date >= '2024-01-01'
AND start_date < '2026-01-01'
GROUP BY YEAR(start_date), MONTH(start_date)
ORDER BY booking_year, booking_month;

-- Query 4: Recent bookings query (most common use case)
EXPLAIN PARTITIONS
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status,
    b.total_price
FROM Booking b
WHERE b.start_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
AND b.status IN ('confirmed', 'pending')
ORDER BY b.start_date DESC
LIMIT 100;

-- ================================
-- PARTITION MAINTENANCE COMMANDS
-- ================================

-- View partition information
SELECT
    PARTITION_NAME,
    PARTITION_EXPRESSION,
    PARTITION_DESCRIPTION,
    TABLE_ROWS,
    DATA_LENGTH,
    INDEX_LENGTH
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_NAME = 'Booking'
AND TABLE_SCHEMA = DATABASE()
ORDER BY PARTITION_ORDINAL_POSITION;

-- Add new future partition (example for 2027)
ALTER TABLE Booking
ADD PARTITION (
    PARTITION p_2027_Q1 VALUES LESS THAN (202704)
);

-- Drop old partition (example - be careful!)
-- ALTER TABLE Booking DROP PARTITION p_2023_01;

-- Reorganize partition to optimize
-- ALTER TABLE Booking REORGANIZE PARTITION p_future INTO (
--     PARTITION p_2027_Q2 VALUES LESS THAN (202707),
--     PARTITION p_2027_Q3 VALUES LESS THAN (202710),
--     PARTITION p_2027_Q4 VALUES LESS THAN (202801),
--     PARTITION p_future VALUES LESS THAN MAXVALUE
-- );

-- ================================
-- PERFORMANCE MONITORING
-- ================================

-- Enable partition pruning monitoring
SET SESSION optimizer_prune_level = 1;
SET SESSION optimizer_search_depth = 62;

-- Check partition pruning effectiveness
EXPLAIN PARTITIONS
SELECT * FROM Booking
WHERE start_date BETWEEN '2025-08-01' AND '2025-08-31';

-- Monitor partition sizes
SELECT
    PARTITION_NAME,
    TABLE_ROWS,
    ROUND(DATA_LENGTH / 1024 / 1024, 2) AS DATA_SIZE_MB,
    ROUND(INDEX_LENGTH / 1024 / 1024, 2) AS INDEX_SIZE_MB,
    ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS TOTAL_SIZE_MB
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_NAME = 'Booking'
AND TABLE_SCHEMA = DATABASE()
AND PARTITION_NAME IS NOT NULL
ORDER BY PARTITION_ORDINAL_POSITION;

-- ================================
-- BENCHMARK QUERIES
-- ================================

-- Benchmark 1: Large date range aggregation
SET profiling = 1;

-- Non-partitioned equivalent query time
SELECT COUNT(*), SUM(total_price)
FROM Booking_backup
WHERE start_date >= '2024-01-01' AND start_date < '2025-01-01';

-- Partitioned query time
SELECT COUNT(*), SUM(total_price)
FROM Booking
WHERE start_date >= '2024-01-01' AND start_date < '2025-01-01';

SHOW PROFILES;

-- Benchmark 2: Recent data queries
SET profiling = 1;

-- Non-partitioned
SELECT * FROM Booking_backup
WHERE start_date >= '2025-08-01'
ORDER BY start_date DESC LIMIT 1000;

-- Partitioned
SELECT * FROM Booking
WHERE start_date >= '2025-08-01'
ORDER BY start_date DESC LIMIT 1000;

SHOW PROFILES;

-- ================================
-- CLEANUP
-- ================================

-- Drop backup table after verification
-- DROP TABLE Booking_backup;

-- Update table statistics
ANALYZE TABLE Booking;

-- ================================
-- AUTOMATED PARTITION MANAGEMENT
-- ================================

-- Stored procedure to add monthly partitions automatically
DELIMITER $$

CREATE PROCEDURE AddMonthlyPartition(IN target_year INT, IN target_month INT)
BEGIN
    DECLARE partition_name VARCHAR(20);
    DECLARE next_value INT;
    DECLARE sql_stmt TEXT;

    -- Calculate partition name and value
    SET partition_name = CONCAT('p_', target_year, '_', LPAD(target_month, 2, '0'));
    SET next_value = target_year * 100 + target_month + 1;

    -- Handle year rollover
    IF target_month = 12 THEN
        SET next_value = (target_year + 1) * 100 + 1;
    END IF;

    -- Create the partition
    SET sql_stmt = CONCAT(
        'ALTER TABLE Booking ADD PARTITION (',
        'PARTITION ', partition_name, ' VALUES LESS THAN (', next_value, ')',
        ')'
    );

    SET @sql = sql_stmt;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

END$$

DELIMITER ;

-- Example usage: Add partition for March 2027
-- CALL AddMonthlyPartition(2027, 3);

-- ================================
-- PARTITION PRUNING VERIFICATION
-- ================================

-- Verify partition pruning is working
SELECT
    'Partition Pruning Test' AS test_name,
    COUNT(*) as matching_rows
FROM Booking
WHERE start_date = '2025-09-15';

-- Check which partitions are accessed
EXPLAIN PARTITIONS
SELECT COUNT(*)
FROM Booking
WHERE start_date BETWEEN '2025-09-01' AND '2025-09-30';

/*
Expected output should show only p_2025_09 partition being accessed,
confirming that partition pruning is working effectively.
*/
