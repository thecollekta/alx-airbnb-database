# Advanced SQL Queries - Airbnb Clone Database

This repository contains comprehensive SQL join queries demonstrating advanced database operations for the Airbnb clone project. The queries follow Django best practices and SQL performance optimization standards.

## Table of Contents

- [Overview](#overview)
- [File Structure](#files-structure)
- [Database Schema](#database-schema)
- [Query Categories](#query-categories)
- [Performance Considerations](#performance-considerations)
- [Usage Instructions](#usage-instructions)
- [Best Practices](#best-practices)

## Overview

The `joins_queries.sql` file contains complex SQL queries that demonstrate:

- **INNER JOIN**: Retrieving related data where relationships exist
- **LEFT JOIN**: Including all records from the left table with optional matches
- **FULL OUTER JOIN**: Comprehensive data retrieval including unmatched records
- **Multi-table joins**: Complex business intelligence queries
- **Performance optimization**: Indexed queries and efficient join strategies

The `subqueries.sql` file contains advanced SQL subquery which focus on both correlated and non-correlated subqueries to demonstrate different query optimization techniques and use cases.

- **`aggregations_and_window_functions.sql`**: Comprehensive aggregation and window function operations

The queries demonstrate:

- **JOIN Operations**: Retrieving related data with optimal performance
- **Subqueries**: Both correlated and non-correlated query optimization
- **Aggregations**: COUNT, SUM, AVG with GROUP BY operations
- **Window Functions**: ROW_NUMBER, RANK, DENSE_RANK, NTILE, and analytical functions

## Files Structure

```text
database-adv-script/
├── aggregations_and_window_functions.sql
├── joins_queries.sql
├── README.md
└── subqueries.sql
```

## Database Schema

The exercises use the normalized Airbnb clone database schema with the following key tables:

- **user**: User accounts (guests, hosts, admins)
- **location**: Normalized address data with geospatial coordinates
- **property**: Property listings linked to locations and hosts
- **booking**: Reservation records with status tracking
- **payment**: Payment processing records
- **review**: Property ratings and comments
- **message**: User-to-user messaging system

```text
├── user (guests, hosts, admins)
├── location (normalized address data)
├── property (rental listings)
├── booking (reservations)
├── payment (transaction records)
├── review (user feedback)
└── message (communication)
```

```text
Entity Relationships:
├── user (1:N) → property (host relationship)
├── user (1:N) → booking (guest relationship)
├── location (1:N) → property
├── property (1:N) → booking
├── property (1:N) → review
├── booking (1:1) → payment
└── user (N:N) → message
```

## Query Categories

### 1. JOIN Operations (`joins_queries.sql`)

**INNER JOIN Queries**:

- Basic booking-user relationships
- Multi-table joins with property and location data
- Monthly booking summaries with aggregations

**LEFT JOIN Queries**:

- Properties with optional review data
- Property performance analysis with rating statistics
- Identification of properties needing promotion

**FULL OUTER JOIN Queries**:

- Comprehensive user-booking analysis
- Data integrity verification
- User engagement categorization

### 2. Subqueries (`subqueries.sql`)

**Non-Correlated Subqueries**:

- Properties with high ratings (>4.0)
- Efficient EXISTS alternative implementations
- Single-execution optimization patterns

**Correlated Subqueries**:

- Users with multiple bookings (>3)
- Row-by-row comparison analysis
- Performance-optimized alternatives

### 3. Aggregations and Window Functions (`aggregations_and_window_functions.sql`)

**Aggregation Functions**:

- Total bookings per user with COUNT and GROUP BY
- Booking status breakdown with conditional aggregations
- User engagement categorization
- Revenue and booking value analysis

**Window Functions**:

- **ROW_NUMBER()**: Sequential ranking without ties
- **RANK()**: Ranking with gaps for ties
- **DENSE_RANK()**: Ranking without gaps
- **NTILE()**: Percentile-based grouping
- **PERCENT_RANK()**: Percentile calculations

## Performance Considerations

### Index Strategy

**Primary Indexes for Aggregations**:

```sql
-- Essential indexes for aggregation performance
CREATE INDEX idx_booking_user_id ON booking(user_id);
CREATE INDEX idx_booking_property_id ON booking(property_id);
CREATE INDEX idx_booking_status ON booking(status);
CREATE INDEX idx_booking_start_date ON booking(start_date);
CREATE INDEX idx_review_property_rating ON review(property_id, rating);
```

**Composite Indexes for Window Functions**:

```sql
-- Optimized for partitioned window operations
CREATE INDEX idx_booking_user_date ON booking(user_id, start_date);
CREATE INDEX idx_property_location_host ON property(location_id, host_id);
```

### Query Optimization Techniques

1. **Aggregation Optimization**:
   - Use appropriate GROUP BY clauses
   - Leverage HAVING for post-aggregation filtering
   - Implement conditional aggregations for efficiency

2. **Window Function Optimization**:
   - Use appropriate PARTITION BY clauses
   - Optimize ORDER BY specifications
   - Consider frame specifications for moving calculations

3. **Subquery Optimization**:
   - Prefer EXISTS over IN for large datasets
   - Use correlated subqueries judiciously
   - Consider JOIN alternatives for better performance

### Performance Monitoring

```sql
-- Use EXPLAIN ANALYZE to monitor query performance
EXPLAIN ANALYZE SELECT ...
```

## Usage Instructions

### Prerequisites

1. PostgreSQL database with the Airbnb clone schema
2. Proper user permissions for read operations
3. Sufficient test data for meaningful results:
   - 100+ users (mixed roles)
   - 50+ properties across multiple locations
   - 200+ bookings with varied statuses
   - 100+ reviews with different ratings

### Execution Steps

1. **Clone the repository**:

   ```bash
   git clone https://github.com/your-username/alx-airbnb-database.git
   cd alx-airbnb-database/database-adv-script
   ```

2. **Connect to your database**:

   ```bash
   psql -U your_username -d airbnb_clone_db
   ```

3. **Execute individual queries**:

   ```sql
   -- Copy and paste specific queries from .sql file
   psql -U your_username -d airbnb_clone_db -f joins_queries.sql
   psql -U your_username -d airbnb_clone_db -f subqueries.sql
   psql -U your_username -d airbnb_clone_db -f aggregations_and_window_functions.sql
   ```

4. **Monitor performance**:

   ```sql
   \timing on
   EXPLAIN ANALYZE SELECT ...
   ```

### Performance Testing

```sql
-- Test aggregation performance
EXPLAIN (ANALYZE, BUFFERS) 
SELECT user_id, COUNT(*) FROM booking GROUP BY user_id;

-- Test window function performance
EXPLAIN (ANALYZE, BUFFERS)
SELECT *, ROW_NUMBER() OVER (ORDER BY total_bookings DESC) 
FROM (SELECT property_id, COUNT(*) as total_bookings 
      FROM booking GROUP BY property_id) sub;
```

### Sample Data Requirements

For optimal testing, ensure your database contains:

- At least 10 users (guests and hosts)
- 5+ properties with varied locations
- 10+ bookings with different statuses
- Mixed review coverage (some properties with/without reviews)
- Sample payment and message data

## Best Practices

### SQL Code Standards

1. **Consistent Formatting**:
   - Use uppercase for SQL keywords
   - Indent subqueries and complex expressions
   - Align columns in SELECT statements

2. **Naming Conventions**:
   - Use snake_case for all identifiers
   - Descriptive column aliases
   - Consistent table aliases

3. **Performance Optimization**:
   - Use appropriate window frame specifications
   - Leverage indexes for ORDER BY and PARTITION BY
   - Consider query execution plans

### Window Function Best Practices

1. **Choosing the Right Function**:
   - **ROW_NUMBER()**: When you need unique sequential numbers
   - **RANK()**: When gaps in ranking are acceptable
   - **DENSE_RANK()**: When you need continuous ranking
   - **NTILE()**: For percentile-based analysis

2. **Partition Strategy**:
   - Use PARTITION BY for logical groupings
   - Avoid over-partitioning for performance
   - Consider memory usage with large partitions

3. **Frame Specifications**:

   ```sql
   -- Moving average examples
   AVG(column) OVER (ORDER BY date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
   AVG(column) OVER (ORDER BY date RANGE BETWEEN '1 month' PRECEDING AND CURRENT ROW)
   ```

### Django Integration

When using these queries in Django:

**Complex Joins:**

```python
# Use raw SQL for complex joins
from django.db import connection

def get_booking_analytics():
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT b.booking_id, u.first_name, p.name
            FROM booking b
            INNER JOIN "user" u ON b.user_id = u.user_id
            INNER JOIN property p ON b.property_id = p.property_id
            WHERE b.status = 'confirmed'
        """)
        return cursor.fetchall()
```

**Properties with high ratings:**

```python
from django.db.models import Avg
Property.objects.filter(
    pk__in=Review.objects.values('property')
    .annotate(avg_rating=Avg('rating'))
    .filter(avg_rating__gt=4.0)
    .values('property')
)
```

**Users with multiple bookings:**

```python
from django.db.models import Count
User.objects.annotate(
    booking_count=Count('booking')
).filter(booking_count__gt=3)
```

### Using Raw SQL for Complex Aggregations

```python
from django.db import connection

def get_user_booking_stats():
    """Get comprehensive user booking statistics"""
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT 
                u.user_id,
                u.first_name || ' ' || u.last_name AS full_name,
                COUNT(b.booking_id) AS total_bookings,
                COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) AS confirmed_bookings,
                COALESCE(SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price END), 0) AS total_spent
            FROM "user" u
            LEFT JOIN booking b ON u.user_id = b.user_id
            GROUP BY u.user_id, u.first_name, u.last_name
            ORDER BY total_bookings DESC
        """)
        return cursor.fetchall()
```

### Using Django ORM with Aggregations

```python
from django.db.models import Count, Sum, Avg, Case, When, IntegerField
from django.db.models.functions import Coalesce

# User booking statistics
user_stats = User.objects.annotate(
    total_bookings=Count('booking'),
    confirmed_bookings=Count(
        Case(
            When(booking__status='confirmed', then=1),
            output_field=IntegerField()
        )
    ),
    total_spent=Coalesce(
        Sum(
            Case(
                When(booking__status='confirmed', then='booking__total_price'),
                default=0
            )
        ), 0
    )
).order_by('-total_bookings')
```

### Using Window Functions in Django

```python
from django.db.models import Window, F
from django.db.models.functions import RowNumber

# Property ranking by bookings
properties_ranked = Property.objects.annotate(
    total_bookings=Count('booking'),
    booking_rank=Window(
        expression=RowNumber(),
        order_by=F('total_bookings').desc()
    )
).order_by('booking_rank')
```

### Performance Monitoring in Django

```python
import logging
from django.db import connection

# Enable query logging
logging.basicConfig()
logging.getLogger('django.db.backends').setLevel(logging.DEBUG)

# Monitor query performance
def analyze_query_performance():
    with connection.cursor() as cursor:
        cursor.execute("EXPLAIN ANALYZE SELECT ...")
        analysis = cursor.fetchall()
        return analysis
```

### Query Optimization

1. **Use appropriate join types**:
   - INNER JOIN for required relationships
   - LEFT JOIN for optional relationships
   - FULL OUTER JOIN for comprehensive analysis

2. **Implement proper indexing**:

   ```sql
   -- Create indexes for frequent join columns
   CREATE INDEX idx_custom_join ON table_name(join_column);
   ```

3. **Monitor query performance**:

   ```sql
   -- Regular performance analysis
   EXPLAIN (ANALYZE, BUFFERS) SELECT ...
   -- Enable query timing
   \timing on
   -- Analyze query execution
   EXPLAIN ANALYZE SELECT ...;
   -- Check index usage
   EXPLAIN (FORMAT JSON) SELECT ...;
   ```

### Code Quality Standards

- **Consistent naming**: snake_case for SQL identifiers
- **Proper formatting**: Indented and readable SQL
- **Documentation**: Comments explaining complex logic
- **Error handling**: Appropriate constraint validation

## Troubleshooting

### Common Issues

1. **Performance degradation**:
   - Check index usage with EXPLAIN
   - Consider query restructuring
   - Verify table statistics are up to date

2. **Unexpected results**:
   - Verify join conditions
   - Check for NULL values in join columns
   - Ensure proper data types

3. **Memory issues**:
   - Add LIMIT clauses for large datasets
   - Consider pagination for web applications
   - Use appropriate work_mem settings

4. Complex Logic
   - Break into CTEs (Common Table Expressions) or temporary views

### Common Aggregation Issues

1. **Slow GROUP BY Performance**:
   - Ensure proper indexing on GROUP BY columns
   - Consider partial indexes for filtered aggregations
   - Use HAVING instead of WHERE for post-aggregation filtering

2. **Memory Issues with Large Aggregations**:
   - Increase work_mem setting
   - Consider using CTEs to break down complex queries
   - Use LIMIT for testing large datasets

### Window Function Optimization

1. **Partition Size Management**:

   ```sql
   -- Check partition sizes
   SELECT 
       partition_column,
       COUNT(*) as partition_size
   FROM table_name
   GROUP BY partition_column
   ORDER BY partition_size DESC;
   ```

2. **Frame Specification Optimization**:

   ```sql
   -- Efficient frame specification
   SUM(column) OVER (ORDER BY date ROWS UNBOUNDED PRECEDING)  -- Running total
   AVG(column) OVER (ORDER BY date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)  -- Moving average
   ```

### Performance Tuning

```sql
-- Analyze table statistics
ANALYZE booking;
ANALYZE property;
ANALYZE "user";

-- Check index usage
EXPLAIN (ANALYZE, BUFFERS) SELECT ...

-- Monitor query performance
SELECT 
    query,
    calls,
    total_time,
    mean_time
FROM pg_stat_statements
WHERE query LIKE '%booking%'
ORDER BY total_time DESC;
```

### Debugging Tips

```sql
-- Check join selectivity
SELECT COUNT(*) FROM table1 t1
JOIN table2 t2 ON t1.id = t2.foreign_id;

-- Verify data distribution
SELECT column_name, COUNT(*) 
FROM table_name 
GROUP BY column_name;
```

## Additional Resources

- [PostgreSQL JOIN Documentation](https://www.postgresql.org/docs/current/queries-table-expressions.html)
- [Django Raw SQL Queries](https://docs.djangoproject.com/en/stable/topics/db/sql/)
- [SQL Performance Tuning](https://www.postgresql.org/docs/current/performance-tips.html)
- [PostgreSQL Subquery Documentation](https://www.postgresql.org/docs/17/functions-subquery.html)
- [PostgreSQL Window Functions Documentation](https://www.postgresql.org/docs/current/functions-window.html)
- [PostgreSQL Aggregate Functions](https://www.postgresql.org/docs/current/functions-aggregate.html)
- [Django Aggregation Documentation](https://docs.djangoproject.com/en/stable/topics/db/aggregation/)
- [Django Window Functions](https://docs.djangoproject.com/en/stable/ref/models/expressions/#window-functions)
- [SQL Performance Tuning Guide](https://www.postgresql.org/docs/current/performance-tips.html)

## License

This project is part of the ALX ProDEV Backend Specialization program and follows the associated guidelines and requirements.

---

**Note**: These queries are designed for educational purposes and demonstrate advanced SQL concepts. Always validate performance in your specific environment and adjust as needed for production use.
