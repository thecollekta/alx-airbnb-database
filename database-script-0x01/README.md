# Airbnb Clone Database Schema

## Overview

This directory contains the complete database schema for the Airbnb clone application, designed following PostgreSQL best practices and Third Normal Form (3NF) normalization principles. The schema is fully compatible with Django ORM conventions and implements comprehensive indexing for optimal performance.

---

## Table of Content

[Airbnb Clone Database Schema](#airbnb-clone-database-schema)
[Overview](#overview)
[Files](#files)
[Architecture Decisions](#architecture-decisions)
    - [Normalization (3NF Compliance)](#normalization-3nf-compliance)
    - [Key Design Principles](#key-design-principles)
      - [UUID Primary Keys](#uuid-primary-keys)
      - [Proper Data Types](#proper-data-types)
      - [Comprehensive Constraints](#comprehensive-constraints)
[Database Schema Structure](#database-schema-structure)
    - [Core Table](#core-tables)
      - [User Table](#user-table)
      - [Location Table (Normalized)](#location-table-normalized)
      - [Property Table](#property-table)
      - [Booking Table](#booking-table)
      - [Payment Table](#payment-table)
      - [Review Table](#review-table)
      - [Message Table](#message-table)
[Performance Optimization](#performance-optimization)
    - [indexing Strategy](#indexing-strategy)
      - [Primary Indexes](#primary-indexes)
      - [Query-Specific Indexes](#query-specific-indexes)
      - [Composite Indexes](#composite-indexes)
    - [Automatic Timestamp Management](#automatic-timestamp-management)
[Business Logic Constraints](#business-logic-constraints)
    - [Data Integrity Rules](#data-integrity-rules)
    - [Referential Integrity](#referential-integrity)
---

## Files

- `schema.sql` - Complete database schema with tables, constraints, indexes, and triggers
- `README.md` - This documentation file

## Architecture Decisions

### Normalization (3NF Compliance)

The schema has been normalized to Third Normal Form to eliminate redundancy and ensure data integrity:

1. **Location Normalization**: Extracted location data from the Property table into a separate Location table to eliminate redundant address storage and enable efficient geospatial queries.
2. **Atomic Values**: All attributes contain atomic (indivisible) values with no repeating groups.
3. **Dependency Elimination**: Removed transitive dependencies by properly structuring relationships between entities.

### Key Design Principles

#### UUID Primary Keys

- All tables use UUID primary keys for security, scalability, and distributed system compatibility
- PostgreSQL's `gen_random_uuid()` function provides cryptographically secure UUIDs

#### Proper Data Types

- `VARCHAR` with appropriate length limits for text fields
- `DECIMAL(10,2)` for monetary values to ensure precision
- `TIMESTAMP WITH TIME ZONE` for all timestamp fields
- Custom ENUM types for constrained values (roles, status, payment methods)

#### Comprehensive Constraints

- Foreign key constraints with appropriate cascade/restrict actions
- Check constraints for data validation (ratings, coordinates, dates)
- Unique constraints where business logic requires uniqueness

## Database Schema Structure

### Core Tables

#### User Table

Stores all platform users (guests, hosts, administrators) with role-based access control.

**Key Features:**

- UUID primary key for security
- Email uniqueness constraint
- Role-based enum for access control
- Automatic timestamp tracking

#### Location Table (Normalized)

Centralized location storage supporting geospatial operations.

**Key Features:**

- Separate table to eliminate redundancy
- Latitude/longitude constraints (-90 to 90, -180 to 180)
- Comprehensive address fields
- Geospatial indexing for location-based queries

#### Property Table

Property listings with normalized location references.

**Key Features:**

- References User (host) and Location tables
- Positive price constraint
- Automatic timestamp tracking

#### Booking Table

Booking records linking users to properties with date validation.

**Key Features:**

- Date range validation (start < end, future bookings)
- Status tracking with enum
- Cascade deletion with property/user

#### Payment Table

One-to-one relationship with bookings for payment tracking.

**Key Features:**

- Unique booking_id constraint (1:1 relationship)
- Multiple payment method support
- Positive amount validation

#### Review Table

User reviews for properties with rating constraints.

**Key Features:**

- Rating validation (1-5 scale)
- Links users to reviewed properties
- Automatic timestamp tracking

#### Message Table

Inter-user messaging system.

**Key Features:**

- Self-referencing user relationships
- Prevention of self-messaging
- Timestamp tracking for conversations

## Performance Optimization

### Indexing Strategy

#### Primary Indexes

- All primary keys automatically indexed
- Foreign key columns indexed for join performance

#### Query-Specific Indexes

- Email lookup: `idx_user_email`
- Location searches: `idx_location_city`, `idx_location_country`
- Geospatial queries: `idx_location_coordinates`
- Date range queries: `idx_booking_dates`
- Property searches: `idx_property_price`

#### Composite Indexes

- Booking availability: `idx_booking_property_dates`
- Review aggregation: `idx_review_property_rating`
- Message conversations: `idx_message_conversation`

### Automatic Timestamp Management

Implements PostgreSQL triggers for automatic `updated_at` timestamp management:

- Eliminates manual timestamp tracking
- Ensures consistency across all table updates
- Django-compatible implementation

## Business Logic Constraints

### Data Integrity Rules

1. **Booking Validation**: Start date must be before end date and in the future
2. **Rating Validation**: Reviews must have ratings between 1-5
3. **Geographic Validation**: Coordinates must be within valid ranges
4. **Financial Validation**: All monetary amounts must be positive
5. **Communication Validation**: Users cannot message themselves

### Referential Integrity

- **Cascade Deletions**: User deletion removes associated bookings, reviews, messages
- **Restricted Deletions**: Location deletion prevented if properties exist
- **Orphan Prevention**: All foreign key relationships properly enforced
