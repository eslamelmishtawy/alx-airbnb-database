# Advanced SQL Guide for the AirBnB Database

Your hands-on reference for writing fast, correct SQL over the User, Property, Booking, Review, Payment, and Message tables. Each section explains the concept, how to apply it, sample outputs (as tables), common mistakes, and how to verify performance.

Contents

- Aggregations and Window Functions
- Joins (INNER, LEFT, FULL OUTER workaround)
- Subqueries (filters and pre-aggregation)
- Indexing Strategy (single, composite, covering)
- Query Optimization Patterns
- Monitoring and Diagnosis
- Partitioning Strategy and Maintenance
- Quick Reference Cheat Sheets

Note on compatibility: Examples target MySQL 8.0+. FULL OUTER JOIN isn’t supported directly in MySQL—use UNION-based workaround. SHOW PROFILE is deprecated in 8.0; use Performance Schema.

## Aggregations and Window Functions

What it is

- Aggregations combine multiple rows into one row per group using functions like COUNT, SUM, AVG, MIN, MAX with GROUP BY and optional HAVING.
- Window functions compute per-row analytics across a set of related rows (a "window") using OVER (PARTITION BY ... ORDER BY ...), without collapsing rows.

When to use

- Aggregations: produce one row per group (totals, averages, counts).
- Window functions: compute metrics across related rows without collapsing the results (rankings, running totals, moving averages, percentiles).

### A1) Total bookings per user (aggregation)

Input (sample rows)
| User.user_id | first_name | last_name | email | role |
|--------------|------------|-----------|-------------------|-------|
| U-102 | Jane | Miller | jane@example.com | guest |
| U-007 | John | Smith | john@example.com | guest |
| U-555 | Host | Admin | host@example.com | host |

| Booking.booking_id | user_id | property_id | status    |
| ------------------ | ------- | ----------- | --------- |
| B-9001             | U-102   | P-1         | confirmed |
| B-9051             | U-102   | P-3         | canceled  |
| B-7777             | U-007   | P-2         | confirmed |

Query
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

Output
| user_id | user_name | email | role | total_bookings |
|--------:|--------------|---------------------|-------|----------------|
| U-102 | Jane Miller | jane@example.com | guest | 12 |
| U-007 | John Smith | john@example.com | guest | 7 |
| U-555 | Host Admin | host@example.com | host | 0 |

How to apply

1. JOIN User u LEFT JOIN Booking b ON u.user_id = b.user_id to keep users with 0 bookings.
2. GROUP BY user-level columns you SELECT (id, name, email, role).
3. COUNT(b.booking_id).

Common mistake → wrong results

- Doing INNER JOIN instead of LEFT JOIN will drop users with no bookings (they’ll be missing from the result).

Verify

- SUM(total_bookings) across all users equals COUNT(Booking.booking_id).
- EXPLAIN shows index usage on Booking.user_id.

### A2) Monthly booking revenue (aggregation)

Goal: monthly bookings and revenue for confirmed bookings.

Input (sample rows)
| Booking.booking_id | start_date | total_price | status |
|--------------------|------------|-------------|-----------|
| B-1 | 2025-09-01 | 120.00 | confirmed |
| B-2 | 2025-09-05 | 200.00 | confirmed |
| B-3 | 2025-08-14 | 150.00 | canceled |

Query
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

Output
| booking_year | booking_month | monthly_bookings | monthly_revenue | avg_booking_value |
|-------------:|--------------:|-----------------:|----------------:|------------------:|
| 2025 | 9 | 1,245 | 182,350.00 | 146.50 |
| 2025 | 8 | 1,102 | 165,925.00 | 150.52 |

Pitfall

- WHERE uses functions on date columns (e.g., DATE(start_date)) → prevents index/range scan. Prefer range predicates on the raw column.

### A3) Rankings and percentiles (window functions)

Use cases

- Global rank: RANK() or ROW_NUMBER() OVER (ORDER BY COUNT(bookings) DESC)
- Per-location rank: RANK() OVER (PARTITION BY location ORDER BY COUNT(bookings) DESC)
- Percentiles/segments: PERCENT_RANK(), NTILE(4)

Input (aggregated per property)
| property_id | property_name | location | total_bookings |
|-------------|---------------|-----------|----------------|
| P-881 | City Loft | New York | 142 |
| P-992 | Cozy Studio | New York | 142 |
| P-100 | Canal View | Amsterdam | 139 |

Query (rank by total_bookings)
SELECT
property_id,
property_name,
location,
total_bookings,
RANK() OVER (ORDER BY total_bookings DESC) AS rank,
DENSE_RANK() OVER (ORDER BY total_bookings DESC) AS dense_rank
FROM (
SELECT p.property_id, p.name AS property_name, p.location,
COUNT(b.booking_id) AS total_bookings
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.location
) x
ORDER BY rank;

Output (properties ranked by bookings)
| property_id | property_name | location | total_bookings | rank | dense_rank |
|------------:|---------------|------------|----------------|-----:|-----------:|
| P-881 | City Loft | New York | 142 | 1 | 1 |
| P-992 | Cozy Studio | New York | 142 | 1 | 1 |
| P-100 | Canal View | Amsterdam | 139 | 3 | 2 |

Pitfall

- Grouping then ranking: Remember window functions work on the grouped result if you use COUNT() in SELECT with GROUP BY. If you need rank per property per location, ensure the GROUP BY includes property and location and the window has PARTITION BY location.

### A4) Running totals and moving averages (window functions)

Patterns

- Running total by day: SUM(daily_count) OVER (ORDER BY booking_date)
- 7-day moving average: AVG(daily_count) OVER (PARTITION BY property_id ORDER BY booking_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)

Input (daily counts)
| booking_date | daily_bookings |
|--------------|----------------|
| 2025-09-01 | 38 |
| 2025-09-02 | 41 |
| 2025-09-03 | 33 |

Query (running total)
SELECT
booking_date,
daily_bookings,
SUM(daily_bookings) OVER (ORDER BY booking_date) AS running_total
FROM (
SELECT DATE(b.created_at) AS booking_date,
COUNT(\*) AS daily_bookings
FROM Booking b
WHERE b.status = 'confirmed'
GROUP BY DATE(b.created_at)
) d
ORDER BY booking_date;

Output (running totals)
| booking_date | daily_bookings | running_total |
|--------------|----------------|---------------|
| 2025-09-01 | 38 | 38 |
| 2025-09-02 | 41 | 79 |
| 2025-09-03 | 33 | 112 |

Pitfall

- Using RANGE instead of ROWS frame may aggregate unexpected peers (same order values). Prefer ROWS for time series.

Verify

- For a given date range, running_total(last day) equals SUM(daily_bookings) over the range.

## Joins (INNER, LEFT, FULL OUTER workaround)

What it is

- A JOIN combines rows from two tables based on a related key. INNER JOIN keeps matched rows only. LEFT JOIN keeps all left-side rows. MySQL does not have FULL OUTER JOIN natively.

When to use

- INNER JOIN: only matched rows (most common for related data).
- LEFT JOIN: keep all left rows even if the right is missing (e.g., users with no bookings).
- FULL OUTER JOIN: not in MySQL; emulate with UNION of LEFT and RIGHT joins.

Example: Users and their bookings

Input
| User.user_id | first_name | last_name |
|--------------|------------|-----------|
| U-102 | Jane | Miller |
| U-555 | Host | Admin |

| Booking.booking_id | user_id |
| ------------------ | ------- |
| B-9001             | U-102   |
| B-9051             | U-102   |

Query (INNER JOIN)
SELECT u.user_id, CONCAT(u.first_name,' ',u.last_name) AS user_name, b.booking_id
FROM User u
INNER JOIN Booking b ON b.user_id = u.user_id;

Output (only matched)
| user_id | user_name | booking_id |
|--------:|-------------|------------|
| U-102 | Jane Miller | B-9001 |
| U-102 | Jane Miller | B-9051 |

Query (LEFT JOIN)
SELECT u.user_id, CONCAT(u.first_name,' ',u.last_name) AS user_name, b.booking_id
FROM User u
LEFT JOIN Booking b ON b.user_id = u.user_id
ORDER BY u.user_id, b.booking_id;

Output (users with no bookings included)
| user_id | user_name | booking_id |
|--------:|-------------|------------|
| U-102 | Jane Miller | B-9001 |
| U-102 | Jane Miller | B-9051 |
| U-555 | Host Admin | NULL |

FULL OUTER JOIN (workaround)

- MySQL approach: (Users LEFT JOIN Bookings) UNION ALL (Users RIGHT JOIN Bookings) filtered to remove duplicates.

Pitfalls

- Filtering a LEFT JOINed table in WHERE (e.g., WHERE b.status = 'confirmed') turns it into an INNER JOIN. Move such filters to the ON clause or keep NULL-safe checks.
- Join explosion: Joining Property to Review then counting property rows inflates counts. Aggregate reviews first, join after.

## Subqueries (filters and pre-aggregation)

What it is

- A subquery is a SELECT nested inside another query. Use it to filter (IN/EXISTS) or to pre-aggregate before joining to avoid row multiplication.

Use cases

- Filter by aggregated property (e.g., properties with AVG(rating) > 4): WHERE p.property_id IN (SELECT property_id FROM Review GROUP BY property_id HAVING AVG(rating) > 4)
- Pre-aggregate in a subquery, then JOIN to avoid row multiplication.

Input (reviews)
| review_id | property_id | rating |
|-----------|-------------|--------|
| R-1 | P-100 | 5 |
| R-2 | P-100 | 4 |
| R-3 | P-881 | 5 |
| R-4 | P-881 | 5 |

Query (filter by aggregated property)
SELECT p.property_id, p.name AS property_name, p.location, p.pricepernight,
CONCAT(u.first_name,' ',u.last_name) AS host_name
FROM Property p
JOIN User u ON p.host_id = u.user_id
WHERE p.property_id IN (
SELECT r.property_id
FROM Review r
GROUP BY r.property_id
HAVING AVG(r.rating) > 4.0
)
ORDER BY p.name;

Output (properties with avg rating > 4)
| property_id | property_name | location | pricepernight | host_name |
|------------:|---------------|-----------|---------------|-------------|
| P-100 | Canal View | Amsterdam | 120 | Annabel Lee |
| P-881 | City Loft | New York | 225 | Mark Owen |

Pitfall

- Using the subquery but also joining Review in outer query reintroduces duplication; ensure you either use the subquery alone or alias and JOIN only the aggregated result.

## Indexing Strategy

What it is

- An index is a data structure that accelerates lookups, joins, and ordering on specific columns at the cost of slower writes and extra storage.

Why indexes

- Faster lookups, joins, sorting, and range filters at the cost of slower writes and storage overhead.

Core patterns (from `database_index.sql`)

- Single-column: email, status, created_at, foreign keys.
- Composite: (location, pricepernight), (property_id, start_date, end_date), (user_id, status), etc.
- Covering: include SELECT columns to avoid table lookups when practical.

Design heuristics

- Order columns: equality predicates first, then range, then ORDER BY/GROUP BY columns.
- Query must use the leftmost index prefix to benefit.
- Avoid functions on indexed columns in WHERE.

Example I1: Email lookup (authentication)

Input
| user_id | email | first_name | last_name |
|---------|--------------------|------------|-----------|
| U-1 | a@example.com | Ann | A |
| U-2 | john@example.com | John | S |
| U-3 | z@example.com | Zoe | Z |

Query
SELECT user_id, first_name, last_name, role
FROM User
WHERE email = 'john@example.com';

Output
| user_id | first_name | last_name |
|---------|------------|-----------|
| U-2 | John | S |

Expected EXPLAIN (before index)
| table | type | key | rows | Extra |
|-------|------|------|-------|---------------|
| User | ALL | NULL | 10000 | Using where |

Expected EXPLAIN (after index on User(email))
| table | type | key | rows | Extra |
|-------|------|----------------|------|-------------|
| User | ref | idx_user_email | 1 | Using index |

Example I2: Property search by location + price

Input (abbrev.)
| property_id | location | pricepernight |
|-------------|----------|---------------|
| P-1 | New York | 180 |
| P-2 | New York | 260 |
| P-3 | Paris | 220 |

Query
SELECT property_id, name, pricepernight
FROM Property
WHERE location = 'New York' AND pricepernight BETWEEN 100 AND 300
ORDER BY pricepernight;

Expected EXPLAIN (with composite (location, pricepernight))
| table | type | key | rows | Extra |
|---------|-------|------------------------------|------|---------------------|
| Property| range | idx_property_location_price | 80 | Using where |

Pitfalls

- Over-indexing slows writes and consumes storage. Periodically remove unused indexes (see monitoring section).
- LIKE '%term' on B-Tree can’t use index prefix—consider FULLTEXT for natural language search.

Verify

- EXPLAIN (or EXPLAIN ANALYZE) shows type ref/range instead of ALL; no filesort if ordering matches index.
- performance_schema.table_io_waits_summary_by_index_usage shows reads on target index.

## Query Optimization Patterns

Key tactics

- Select only needed columns (avoid SELECT \*).
- Filter as early as possible; keep predicates sargable (no functions on indexed columns).
- Reduce JOINs; pre-aggregate heavy children (e.g., Review) before joining.
- Use cursor-based pagination (WHERE id > last_seen) instead of OFFSET for large pages.
- Rewrite logic for date overlaps: NOT (end <= x OR start >= y) → start < y AND end > x.

Before/after example (availability check)

Wrong (less selective and harder to optimize)
| Predicate |
|--------------------------------------------------|
| NOT (end_date <= '2025-12-01' OR start_date >= '2025-12-15') |

Right (sargable and index-friendly)
| Predicate |
|------------------------------------|
| start_date < '2025-12-15' AND end_date > '2025-12-01' |

Expected effect

- With index on (property_id, status, start_date, end_date), EXPLAIN type improves to range with low rows examined.

Concrete flow (Input → Query → Output)

Input
| booking_id | property_id | status | start_date | end_date |
|------------|-------------|-----------|------------|------------|
| B-1 | P-9 | confirmed | 2025-12-02 | 2025-12-05 |
| B-2 | P-9 | pending | 2025-12-10 | 2025-12-12 |
| B-3 | P-9 | canceled | 2025-12-20 | 2025-12-22 |

Query (correct, index-friendly)
SELECT COUNT(\*) AS conflicting
FROM Booking b
WHERE b.property_id = 'P-9'
AND b.status IN ('confirmed','pending')
AND b.start_date < '2025-12-15'
AND b.end_date > '2025-12-01';

Output
| conflicting |
|-------------|
| 2 |

## Monitoring and Diagnosis

What it is

- Techniques and server features to find slow queries, understand execution plans, and validate improvements (Slow Query Log, Performance Schema, EXPLAIN/ANALYZE).

What to enable

- Slow query log: SET GLOBAL slow_query_log = 'ON'; SET GLOBAL long_query_time = 0.5;
- Performance Schema: enable relevant instruments/consumers.

What to inspect

- Top digests: performance_schema.events_statements_summary_by_digest (order by AVG/MAX timers).
- TABLE I/O: performance_schema.table_io_waits_summary_by_table.
- Index usage: performance_schema.table_io_waits_summary_by_index_usage.

Example: “Bad” vs “Good” EXPLAIN for a search

Bad
| table | type | key | rows | Extra |
|---------|------|------|-------|-----------------------------------------|
| Property| ALL | NULL | 5000 | Using where; Using temporary; Filesort |

Good
| table | type | key | rows | Extra |
|---------|-------|-----------------------------|------|--------------|
| Property| range | idx_property_location_price | 100 | Using where |

Pitfalls

- SHOW PROFILE is deprecated in MySQL 8.0; rely on Performance Schema and EXPLAIN ANALYZE (8.0.18+).

## Partitioning Strategy and Maintenance

What it is

- Partitioning splits a large table into smaller physical pieces based on a key (here, start_date) so date-filtered queries scan fewer partitions and maintenance is faster.

Why partition

- Prune scans on time-based queries; speed maintenance (drop/archive old partitions instantly); improve scalability.

Design used (`partitioning.sql` / `partition_performance.md`)

- RANGE by YEAR(start_date)\*100 + MONTH(start_date)
- Monthly for recent years; quarterly for future; p_future catch-all
- PK includes partition column: PRIMARY KEY (booking_id, start_date)

Example: EXPLAIN PARTITIONS for a September 2025 query

Expected
| partitions | type | rows | Extra |
|------------|-------|-------|-------------|
| p_2025_09 | range | 25000 | Using where |

Wrong usage

- Queries without start_date filters will touch many partitions (or all), losing the benefit.
- Functions on start_date in WHERE can prevent pruning.

Maintenance tips

- Add future partitions proactively (see stored procedure in `partitioning.sql`).
- Drop old partitions instead of DELETE for archival.
- Monitor partition sizes via INFORMATION_SCHEMA.PARTITIONS.

## Quick Reference Cheat Sheets

Index design

- Equality → Range → Order/Group column order in composite indexes.
- Covering indexes for hot reads; remove unused indexes regularly.
- Avoid functions on indexed columns in WHERE; precompute if needed.

Window functions

- ROW_NUMBER: unique rank; RANK: ties with gaps; DENSE_RANK: ties without gaps.
- Running total: SUM(x) OVER (ORDER BY d)
- 7-day MA: AVG(x) OVER (PARTITION BY id ORDER BY d ROWS 6 PRECEDING)

Joins

- LEFT JOIN keeps unmatched left rows; WHERE filters on right can nullify it—use ON for right-side filters.
- MySQL: FULL OUTER JOIN via UNION of LEFT and RIGHT joins.

Partitioning

- PK must include partition key; always filter by partition key for pruning.
- Validate with EXPLAIN PARTITIONS.

Monitoring

- Use Performance Schema digest tables for top slow patterns.
- Validate plans with EXPLAIN (and ANALYZE if available).

---

Need examples tailored to your live data? Identify a slow query and I’ll propose the exact index, rewrite, and an EXPLAIN validation checklist.
