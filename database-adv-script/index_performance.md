# Database Index Performance Analysis

## Overview

This document analyzes the performance impact of database indexes on high-usage columns in the AirBnB database schema. We'll examine query performance before and after adding indexes using EXPLAIN and ANALYZE commands.

## High-Usage Columns Identified

### User Table

- **user_id**: Primary key, used in JOINs
- **email**: Authentication queries, unique lookups
- **role**: Filtering users by type (guest, host, admin)
- **created_at**: Sorting and date range queries

### Property Table

- **property_id**: Primary key, used in JOINs
- **host_id**: Foreign key, JOIN operations
- **location**: Geographic filtering and search
- **pricepernight**: Price range filtering and sorting
- **created_at**: Temporal sorting and filtering

### Booking Table

- **booking_id**: Primary key, used in JOINs
- **property_id**: Foreign key, JOIN operations
- **user_id**: Foreign key, JOIN operations
- **start_date/end_date**: Date range queries for availability
- **status**: Filtering by booking status
- **created_at**: Temporal sorting

## Performance Test Queries

### Query 1: User Authentication (Before Index)

```sql
EXPLAIN SELECT user_id, first_name, last_name, role
FROM User
WHERE email = 'user@example.com';
```

**Expected Results Without Index:**

- Type: ALL (Full table scan)
- Rows: ~10000 (entire table)
- Cost: High

**Expected Results With Index (idx_user_email):**

- Type: ref
- Rows: 1
- Cost: Low
- Key: idx_user_email

### Query 2: Property Search by Location and Price (Before Index)

```sql
EXPLAIN SELECT property_id, name, pricepernight
FROM Property
WHERE location = 'New York'
AND pricepernight BETWEEN 100 AND 300
ORDER BY pricepernight;
```

**Expected Results Without Index:**

- Type: ALL
- Rows: ~5000 (entire Property table)
- Using filesort: Yes
- Cost: High

**Expected Results With Composite Index (idx_property_location_price):**

- Type: range
- Rows: ~50-100 (filtered results)
- Using filesort: No
- Key: idx_property_location_price

### Query 3: Booking Availability Check (Before Index)

```sql
EXPLAIN SELECT booking_id
FROM Booking
WHERE property_id = 'property-uuid'
AND status IN ('confirmed', 'pending')
AND start_date <= '2025-12-31'
AND end_date >= '2025-09-01';
```

**Expected Results Without Index:**

- Type: ALL
- Rows: ~20000 (entire Booking table)
- Cost: Very High

**Expected Results With Composite Index (idx_booking_availability_check):**

- Type: range
- Rows: ~5-20 (highly filtered)
- Key: idx_booking_availability_check

### Query 4: JOIN Performance Test (Before Index)

```sql
EXPLAIN SELECT
    u.first_name, u.last_name,
    p.name AS property_name,
    b.start_date, b.end_date
FROM User u
JOIN Booking b ON u.user_id = b.user_id
JOIN Property p ON b.property_id = p.property_id
WHERE u.role = 'guest'
AND b.status = 'confirmed'
ORDER BY b.created_at DESC;
```

**Expected Results Without Indexes:**

- Multiple table scans
- Nested loop joins
- Using temporary and filesort
- Very high cost

**Expected Results With Indexes:**

- Index seeks for all JOINs
- Using index for ORDER BY
- Significantly reduced cost

## Performance Metrics to Monitor

### Before Index Implementation

```sql
-- Check current query performance
SET profiling = 1;

-- Run test queries
SELECT user_id FROM User WHERE email = 'test@example.com';
SELECT * FROM Property WHERE location = 'New York' AND pricepernight < 200;

-- View performance
SHOW PROFILES;
```

### After Index Implementation

```sql
-- Apply indexes from database_index.sql
SOURCE database_index.sql;

-- Re-run same queries
SET profiling = 1;
SELECT user_id FROM User WHERE email = 'test@example.com';
SELECT * FROM Property WHERE location = 'New York' AND pricepernight < 200;

SHOW PROFILES;
```

## Expected Performance Improvements

### Single Column Lookups

- **Email lookup**: 99% improvement (O(log n) vs O(n))
- **Status filtering**: 80-90% improvement
- **Date range queries**: 70-85% improvement

### JOIN Operations

- **Foreign key JOINs**: 90-95% improvement
- **Multi-table queries**: 85-92% improvement

### Complex Queries

- **Location + Price search**: 80-90% improvement
- **Availability checks**: 95-98% improvement
- **Aggregation queries**: 60-80% improvement

## Index Maintenance Considerations

### Storage Impact

- Each index requires additional disk space (typically 10-30% of table size)
- Composite indexes are larger than single-column indexes

### Write Performance Impact

- INSERT operations: 5-15% slower per index
- UPDATE operations: 3-10% slower when indexed columns change
- DELETE operations: 5-12% slower per index

### Monitoring Commands

```sql
-- Check index usage
SELECT
    TABLE_NAME,
    INDEX_NAME,
    SEQ_IN_INDEX,
    COLUMN_NAME,
    CARDINALITY
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'airbnb_db'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- Analyze index effectiveness
SHOW INDEX FROM User;
SHOW INDEX FROM Property;
SHOW INDEX FROM Booking;
```

## Optimization Recommendations

### High Priority Indexes

1. **idx_user_email**: Critical for authentication
2. **idx_booking_property_dates**: Essential for availability checks
3. **idx_property_location_price**: Core search functionality

### Medium Priority Indexes

1. **idx_booking_user_status**: User dashboard queries
2. **idx_review_property_rating**: Property analytics
3. **idx_payment_booking_date**: Financial reporting

### Monitoring Strategy

1. Regular EXPLAIN analysis of slow queries
2. Monitor index hit ratios
3. Identify and remove unused indexes
4. Update table statistics regularly with ANALYZE TABLE

## Conclusion

Proper indexing on high-usage columns can provide dramatic performance improvements, especially for:

- Authentication queries (99% improvement)
- Property search operations (80-90% improvement)
- Booking availability checks (95-98% improvement)
- Multi-table JOIN operations (85-95% improvement)

The trade-off in write performance (5-15% slower) is typically acceptable given the substantial read performance gains in a read-heavy application like AirBnB.
