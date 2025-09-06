-- Database Indexes for Performance Optimization
-- AirBnB Database - High-Usage Column Indexes
-- Created: September 6, 2025

-- Note: Some indexes may already exist in the schema.sql file
-- This file contains comprehensive indexing strategy for high-usage columns

-- =================
-- USER TABLE INDEXES
-- =================

-- Primary key index (automatically created)
-- CREATE INDEX idx_user_id ON User(user_id);

-- High-usage column indexes
CREATE INDEX IF NOT EXISTS idx_user_email ON User(email);
CREATE INDEX IF NOT EXISTS idx_user_role ON User(role);
CREATE INDEX IF NOT EXISTS idx_user_created_at ON User(created_at);

-- Composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_user_role_created_at ON User(role, created_at);
CREATE INDEX IF NOT EXISTS idx_user_name_search ON User(first_name, last_name);

-- ===================
-- PROPERTY TABLE INDEXES
-- ===================

-- Primary key index (automatically created)
-- CREATE INDEX idx_property_id ON Property(property_id);

-- Foreign key and high-usage column indexes
CREATE INDEX IF NOT EXISTS idx_property_host_id ON Property(host_id);
CREATE INDEX IF NOT EXISTS idx_property_location ON Property(location);
CREATE INDEX IF NOT EXISTS idx_property_price ON Property(pricepernight);
CREATE INDEX IF NOT EXISTS idx_property_created_at ON Property(created_at);

-- Composite indexes for common search patterns
CREATE INDEX IF NOT EXISTS idx_property_location_price ON Property(location, pricepernight);
CREATE INDEX IF NOT EXISTS idx_property_host_location ON Property(host_id, location);
CREATE INDEX IF NOT EXISTS idx_property_price_created_at ON Property(pricepernight, created_at);

-- Full-text search index for property name and description (if needed)
-- CREATE FULLTEXT INDEX idx_property_search ON Property(name, description);

-- ===================
-- BOOKING TABLE INDEXES
-- ===================

-- Primary key index (automatically created)
-- CREATE INDEX idx_booking_id ON Booking(booking_id);

-- Foreign key indexes
CREATE INDEX IF NOT EXISTS idx_booking_property_id ON Booking(property_id);
CREATE INDEX IF NOT EXISTS idx_booking_user_id ON Booking(user_id);

-- High-usage column indexes
CREATE INDEX IF NOT EXISTS idx_booking_status ON Booking(status);
CREATE INDEX IF NOT EXISTS idx_booking_start_date ON Booking(start_date);
CREATE INDEX IF NOT EXISTS idx_booking_end_date ON Booking(end_date);
CREATE INDEX IF NOT EXISTS idx_booking_created_at ON Booking(created_at);

-- Composite indexes for complex queries
CREATE INDEX IF NOT EXISTS idx_booking_property_dates ON Booking(property_id, start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_booking_user_status ON Booking(user_id, status);
CREATE INDEX IF NOT EXISTS idx_booking_status_dates ON Booking(status, start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_booking_property_status ON Booking(property_id, status);

-- Date range optimization index
CREATE INDEX IF NOT EXISTS idx_booking_date_range ON Booking(start_date, end_date, status);

-- ===================
-- REVIEW TABLE INDEXES
-- ===================

-- Primary key index (automatically created)
-- CREATE INDEX idx_review_id ON Review(review_id);

-- Foreign key indexes
CREATE INDEX IF NOT EXISTS idx_review_property_id ON Review(property_id);
CREATE INDEX IF NOT EXISTS idx_review_user_id ON Review(user_id);

-- High-usage column indexes
CREATE INDEX IF NOT EXISTS idx_review_rating ON Review(rating);
CREATE INDEX IF NOT EXISTS idx_review_created_at ON Review(created_at);

-- Composite indexes
CREATE INDEX IF NOT EXISTS idx_review_property_rating ON Review(property_id, rating);
CREATE INDEX IF NOT EXISTS idx_review_property_created_at ON Review(property_id, created_at);

-- ===================
-- PAYMENT TABLE INDEXES
-- ===================

-- Primary key index (automatically created)
-- CREATE INDEX idx_payment_id ON Payment(payment_id);

-- Foreign key and high-usage column indexes
CREATE INDEX IF NOT EXISTS idx_payment_booking_id ON Payment(booking_id);
CREATE INDEX IF NOT EXISTS idx_payment_method ON Payment(payment_method);
CREATE INDEX IF NOT EXISTS idx_payment_date ON Payment(payment_date);

-- Composite indexes
CREATE INDEX IF NOT EXISTS idx_payment_method_date ON Payment(payment_method, payment_date);
CREATE INDEX IF NOT EXISTS idx_payment_booking_date ON Payment(booking_id, payment_date);

-- ===================
-- MESSAGE TABLE INDEXES
-- ===================

-- Primary key index (automatically created)
-- CREATE INDEX idx_message_id ON Message(message_id);

-- Foreign key indexes
CREATE INDEX IF NOT EXISTS idx_message_sender_id ON Message(sender_id);
CREATE INDEX IF NOT EXISTS idx_message_recipient_id ON Message(recipient_id);
CREATE INDEX IF NOT EXISTS idx_message_sent_at ON Message(sent_at);

-- Composite indexes for conversation queries
CREATE INDEX IF NOT EXISTS idx_message_conversation ON Message(sender_id, recipient_id, sent_at);
CREATE INDEX IF NOT EXISTS idx_message_recipient_date ON Message(recipient_id, sent_at);

-- =================================
-- SPECIALIZED PERFORMANCE INDEXES
-- =================================

-- Index for property search by location and price range
CREATE INDEX IF NOT EXISTS idx_property_location_price_range ON Property(location, pricepernight, created_at);

-- Index for finding available properties (complex booking overlap queries)
CREATE INDEX IF NOT EXISTS idx_booking_availability_check ON Booking(property_id, status, start_date, end_date);

-- Index for user activity analysis
CREATE INDEX IF NOT EXISTS idx_user_activity ON User(role, created_at);

-- Index for revenue analysis
CREATE INDEX IF NOT EXISTS idx_booking_revenue ON Booking(status, total_price, created_at);

-- Index for host performance analysis
CREATE INDEX IF NOT EXISTS idx_property_host_performance ON Property(host_id, created_at);

-- ===============================
-- ANALYZE TABLE COMMANDS
-- ===============================

-- Update table statistics for query optimizer
ANALYZE TABLE User;
ANALYZE TABLE Property;
ANALYZE TABLE Booking;
ANALYZE TABLE Review;
ANALYZE TABLE Payment;
ANALYZE TABLE Message;

-- ===============================
-- NOTES AND RECOMMENDATIONS
-- ===============================

/*
Index Strategy Notes:

1. Primary Key Indexes: Automatically created, provide unique identification
2. Foreign Key Indexes: Essential for JOIN operations
3. Single Column Indexes: For WHERE clause filtering and ORDER BY operations
4. Composite Indexes: For complex queries with multiple WHERE conditions
5. Date Range Indexes: Optimized for booking availability queries

Performance Considerations:
- Indexes speed up SELECT operations but slow down INSERT/UPDATE/DELETE
- Monitor index usage with SHOW INDEX FROM table_name
- Remove unused indexes periodically
- Consider index selectivity (unique values vs total rows)
- Composite index column order matters (most selective first)

Query Patterns Optimized:
- User authentication (email lookup)
- Property search by location and price
- Booking availability checks
- Revenue and performance analytics
- Message conversation retrieval
- Review aggregations by property
*/

-- ===============================
-- PERFORMANCE TESTING WITH EXPLAIN ANALYZE
-- ===============================

-- Test 1: User authentication query performance
-- Before index
EXPLAIN ANALYZE
SELECT user_id, first_name, last_name, role
FROM User
WHERE email = 'test@example.com';

-- After adding idx_user_email index
-- CREATE INDEX IF NOT EXISTS idx_user_email ON User(email);
EXPLAIN ANALYZE
SELECT user_id, first_name, last_name, role
FROM User
WHERE email = 'test@example.com';

-- Test 2: Property search performance
-- Before composite index
EXPLAIN ANALYZE
SELECT property_id, name, pricepernight
FROM Property
WHERE location LIKE '%New York%'
AND pricepernight BETWEEN 100 AND 300;

-- After adding idx_property_location_price index
EXPLAIN ANALYZE
SELECT property_id, name, pricepernight
FROM Property
WHERE location LIKE '%New York%'
AND pricepernight BETWEEN 100 AND 300;

-- Test 3: Booking availability check performance
-- Before optimization
EXPLAIN ANALYZE
SELECT COUNT(*)
FROM Booking
WHERE property_id = 'sample-property-uuid'
AND status IN ('confirmed', 'pending')
AND start_date <= '2025-12-31'
AND end_date >= '2025-09-01';

-- After adding idx_booking_availability_optimized index
EXPLAIN ANALYZE
SELECT COUNT(*)
FROM Booking
WHERE property_id = 'sample-property-uuid'
AND status IN ('confirmed', 'pending')
AND start_date <= '2025-12-31'
AND end_date >= '2025-09-01';

-- Test 4: Complex JOIN query performance
-- Before optimization
EXPLAIN ANALYZE
SELECT
    u.first_name, u.last_name,
    p.name AS property_name,
    b.start_date, b.end_date
FROM User u
JOIN Booking b ON u.user_id = b.user_id
JOIN Property p ON b.property_id = p.property_id
WHERE u.role = 'guest'
AND b.status = 'confirmed'
ORDER BY b.created_at DESC
LIMIT 100;

-- After adding all relevant indexes
EXPLAIN ANALYZE
SELECT
    u.first_name, u.last_name,
    p.name AS property_name,
    b.start_date, b.end_date
FROM User u
JOIN Booking b ON u.user_id = b.user_id
JOIN Property p ON b.property_id = p.property_id
WHERE u.role = 'guest'
AND b.status = 'confirmed'
ORDER BY b.created_at DESC
LIMIT 100;
