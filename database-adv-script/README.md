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

## Files Structure

```text
database-adv-script/
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

## Query Categories

### 1. INNER JOIN Queries

**Purpose**: Retrieve data where relationships must exist between tables.

**Key Queries**:

- Basic booking-user relationships
- Improved booking details with property and location
- Monthly booking summaries with aggregations

**Use Cases**:

- Active booking reports
- Revenue analysis
- Guest activity tracking

### 2. LEFT JOIN Queries

**Purpose**: Retrieve all records from the primary table with optional related data.

**Key Queries**:

- All properties with their reviews (including properties without reviews)
- Property performance analysis with rating statistics
- Identification of properties needing promotion

**Use Cases**:

- Property listing completeness
- Review coverage analysis
- Marketing opportunity identification

### 3. FULL OUTER JOIN Queries

**Purpose**: Comprehensive data retrieval including unmatched records from both tables.

**Key Queries**:

- All users and all bookings (including orphaned data)
- User engagement analysis
- Data integrity verification

**Use Cases**:

- Data quality assurance
- User behavior analysis
- System audit reports

### 4. Non-Correlated Subqueries

**Characteristics:**

- Inner query executes once independently
- Result is used by outer query
- Generally more efficient for large datasets
- Can be cached by query optimizer

**Key Query:**

- Find all properties where the average rating is greater than 4.0

**Use Cases**:

- Find properties with an average rating above a threshold.

### 5. Correlated Subqueries

**Characteristics:**

- Inner query references outer query columns
- Executes once for each outer query row
- Useful for row-by-row comparisons
- May require careful indexing for performance

**Key Query:**

- Find users who have made more than 3 bookings

**Use Cases**:

- To identify power users — e.g., users with more than 3 bookings.

## Performance Considerations

### Index Usage

The queries are optimized to leverage existing indexes:

```sql
-- Key indexes for join performance
idx_booking_user_id
idx_property_location
idx_review_property_rating
idx_location_city_country
```

### Query Optimization Strategies

1. **Selective Filtering**: WHERE clauses applied before joins
2. **Appropriate Join Types**: Matching join type to business requirements
3. **Aggregation Efficiency**: GROUP BY operations optimized for index usage
4. **NULL Handling**: Proper COALESCE usage for data completeness

### Performance Monitoring

```sql
-- Use EXPLAIN ANALYZE to monitor query performance
EXPLAIN ANALYZE SELECT ...
```

## Usage Instructions

### Prerequisites

1. PostgreSQL database with the Airbnb clone schema
2. Proper user permissions for read operations
3. Sufficient test data for meaningful results

### Execution Steps

1. **Clone the repository**:

   ```bash
   git clone https://github.com/your-username/alx-airbnb-database.git
   cd alx-airbnb-database/database-adv-script
   ```

2. **Connect to your database**:

   ```bash
   psql -U your_username -d airbnb_clone_db -f joins_queries.sql
   ```

3. **Execute individual queries**:

   ```sql
   -- Copy and paste specific queries from joins_queries.sql
   ```

### Sample Data Requirements

For optimal testing, ensure your database contains:

- At least 10 users (guests and hosts)
- 5+ properties with varied locations
- 10+ bookings with different statuses
- Mixed review coverage (some properties with/without reviews)
- Sample payment and message data

## Best Practices

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

## License

This project is part of the ALX ProDEV Backend Specialization program and follows the associated guidelines and requirements.

---

**Note**: These queries are designed for educational purposes and demonstrate advanced SQL concepts. Always validate performance in your specific environment and adjust as needed for production use.
