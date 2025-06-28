# ALX Airbnb Database

A robust PostgreSQL database implementation for an Airbnb clone application, designed with Django ORM compatibility and following industry best practices.

## Overview

This database system supports a full-featured Airbnb clone with user management, property listings, booking system, payments, reviews, and messaging functionality. The schema is normalized to 3NF (Third Normal Form) and optimized for performance with comprehensive indexing and constraints.

---

## Table of Content

[ALX Airbnb Database](#alx-airbnb-database)
[Overview](#overview)
[Database Architecture](#database-architecture)
    - [Schema Design Principles](#schema-design-principles)
    - [Entity Relationship Overview](#entity-relationship-overview)
[Database Schema](#database-schema)
    - [User Table](#user-table)
    - [Location Table](#location-table)
    - [Property Table](#property-table)
    - [Booking Table](#booking-table)
    - [Payment Table](#payment-table)
    - [Review Table](#review-table)
    - [Message Table](#message-table)
[Data Integrity and Constraints](#data-integrity-and-constraints)
    - [Business Logic Constraints](#business-logic-constraints)
    - [Data Relationships](#data-relationships)
[Performance Optimization](#performance-optimization)
    - [Indexing Strategy](#indexing-strategy)
      - [Single Column Indexes](#single-column-indexes)
      - [Composite Indexes](#composite-indexes)
    - [Query Optimization Features](#query-optimization-features)
[Installation and Setup](#installation-and-setup)
    - [Prerequisites](#prerequisites)
    - [Database Setup](#database-setup)
    - [Verification](#verification)
[Sample Data Overview](#sample-data-overview)
[License](#license)

---

## Database Architecture

### Schema Design Principles

- **3NF Normalization**: Eliminates data redundancy and ensures data integrity
- **Django ORM Compatibility**: Follows Django naming conventions and patterns
- **PostgreSQL Optimization**: Leverages PostgreSQL-specific features like UUIDs, ENUMs, and triggers
- **Security-First Approach**: Implements proper constraints and validation at the database level

### Entity Relationship Overview

The database consists of 7 core entities with the following relationships:

```
User (1:N) → Property (Host relationship)
User (1:N) → Booking (Guest relationship)
User (1:N) → Review (Author relationship)
User (1:N) → Message (Sender/Recipient relationships)

Location (1:N) → Property
Property (1:N) → Booking
Property (1:N) → Review

Booking (1:1) → Payment
```

## Database Schema

### Core Tables

#### User Table

Manages all platform users with role-based access control.

```sql
- user_id (UUID, Primary Key)
- first_name, last_name (VARCHAR)
- email (VARCHAR, UNIQUE)
- password_hash (VARCHAR)
- phone_number (VARCHAR, Optional)
- role (ENUM: guest, host, admin)
- created_at, updated_at (TIMESTAMP)
```

#### Location Table

Normalized location data supporting multiple properties per location.

```sql
- location_id (UUID, Primary Key)
- street_address, city, state_province, country (VARCHAR)
- postal_code (VARCHAR, Optional)
- latitude, longitude (DECIMAL, Optional)
- created_at, updated_at (TIMESTAMP)
```

#### Property Table

Property listings with host and location relationships.

```sql
- property_id (UUID, Primary Key)
- host_id (UUID, Foreign Key → User)
- location_id (UUID, Foreign Key → Location)
- name (VARCHAR)
- description (TEXT)
- pricepernight (DECIMAL)
- created_at, updated_at (TIMESTAMP)
```

#### Booking Table

Booking records linking guests to properties with date validation.

```sql
- booking_id (UUID, Primary Key)
- property_id (UUID, Foreign Key → Property)
- user_id (UUID, Foreign Key → User)
- start_date, end_date (DATE)
- total_price (DECIMAL)
- status (ENUM: pending, confirmed, canceled)
- created_at, updated_at (TIMESTAMP)
```

#### Payment Table

Payment records with 1:1 relationship to bookings.

```sql
- payment_id (UUID, Primary Key)
- booking_id (UUID, UNIQUE Foreign Key → Booking)
- amount (DECIMAL)
- payment_date (TIMESTAMP)
- payment_method (ENUM: credit_card, paypal, stripe)
- created_at, updated_at (TIMESTAMP)
```

#### Review Table

User reviews for properties with rating validation.

```sql
- review_id (UUID, Primary Key)
- property_id (UUID, Foreign Key → Property)
- user_id (UUID, Foreign Key → User)
- rating (INTEGER, 1-5)
- comment (TEXT)
- created_at, updated_at (TIMESTAMP)
```

#### Message Table

Inter-user messaging system with self-referencing prevention.

```sql
- message_id (UUID, Primary Key)
- sender_id (UUID, Foreign Key → User)
- recipient_id (UUID, Foreign Key → User)
- message_body (TEXT)
- sent_at (TIMESTAMP)
- created_at, updated_at (TIMESTAMP)
```

## Data Integrity and Constraints

### Business Logic Constraints

- **Date Validation**: Booking end dates must be after start dates
- **Future Bookings**: Bookings cannot be made for past dates
- **Rating Bounds**: Review ratings are constrained to 1-5 scale
- **Positive Amounts**: Prices and payments must be positive values
- **Coordinate Validation**: Latitude (-90 to 90) and longitude (-180 to 180) bounds
- **Self-Message Prevention**: Users cannot send messages to themselves

### Data Relationships

- **Cascade Deletes**: User deletion cascades to their bookings, reviews, and messages
- **Restrict Deletes**: Location deletion is restricted if properties exist
- **Unique Constraints**: Email addresses and booking-payment relationships are unique

## Performance Optimization

### Indexing Strategy

#### Single Column Indexes

- User: email, role, created_at
- Location: city, country, coordinates
- Property: host_id, location_id, price, created_at
- Booking: property_id, user_id, status, created_at
- Payment: booking_id, payment_date, method
- Review: property_id, user_id, rating, created_at
- Message: sender_id, recipient_id, sent_at

#### Composite Indexes

- **Booking Date Range**: (property_id, start_date, end_date)
- **Property Ratings**: (property_id, rating)
- **Message Conversations**: (sender_id, recipient_id, sent_at)
- **Location Search**: (city, state_province, country)

### Query Optimization Features

- **Automatic Timestamps**: Triggers maintain updated_at columns
- **UUID Performance**: Primary keys use PostgreSQL's gen_random_uuid()
- **Enum Types**: Reduce storage and improve query performance
- **Strategic Indexing**: Covers common query patterns and join operations

## Installation and Setup

### Prerequisites

- PostgreSQL 17+
- Database user with CREATE privileges
- Optional: pgAdmin or similar GUI tool

### Database Setup

1. **Create Database**

   ```bash
   createdb airbnb_clone_db
   ```

2. **Connect to Database**

   ```bash
   psql -d airbnb_clone_db -U your_username
   ```

3. **Execute Schema Script**

   ```sql
   \i schema.sql
   ```

4. **Load Sample Data**

   ```sql
   \i seed.sql
   ```

### Verification

Verify the installation by checking table counts:

```sql
-- Check if all tables were created
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Verify sample data
SELECT 
    (SELECT COUNT(*) FROM "user") as users,
    (SELECT COUNT(*) FROM location) as locations,
    (SELECT COUNT(*) FROM property) as properties,
    (SELECT COUNT(*) FROM booking) as bookings,
    (SELECT COUNT(*) FROM payment) as payments,
    (SELECT COUNT(*) FROM review) as reviews,
    (SELECT COUNT(*) FROM message) as messages;
```

Expected output:

```
users | locations | properties | bookings | payments | reviews | messages
------|-----------|------------|----------|----------|---------|----------
  12  |    12     |     10     |    10    |    5     |    7    |    5
```

## Sample Data Overview

The seed data includes realistic Ghanaian-context sample data:

### Users (12 total)

- **5 Guests**: Kwame Asante, Akosua Mensah, Kofi Appiah, Ama Osei, Yaw Boateng
- **5 Hosts**: Efua Danso, Kwaku Owusu, Abena Adjei, Nana Gyamfi, Kwesi Ampofo
- **2 Admins**: Akwasi Frimpong, Adwoa Sarpong

### Locations (12 total)

- **Accra** (5): Ring Road East, Cantonments, East Legon, Airport Area, Osu
- **Kumasi** (3): KNUST Campus, Adum, Asokwa
- **Cape Coast** (2): Castle Area, UCC Campus
- **Other** (2): Tamale, Ho

### Properties (10 total)

Diverse property types ranging from ₵35-₵180 per night:

- Luxury villas and executive apartments
- Family homes and cultural experiences
- Student accommodations and safari bases
- Beach houses and business suites

### Bookings & Transactions

- **10 Bookings**: Mix of confirmed, pending, and canceled states
- **5 Payments**: Multiple payment methods (credit_card, paypal, stripe)
- **7 Reviews**: Ratings from 3-5 stars with detailed feedback
- **5 Messages**: Host-guest communications

## License

This project is part of the ALX SE ProDEV curriculum and is intended for educational purposes.
