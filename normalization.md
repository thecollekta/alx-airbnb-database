# Database Normalization Analysis

## Objective

This is to ensure that the Airbnb database adheres to **Third Normal Form (3NF)** by
identifying and removing redundancies and improving the integrity of the schema.

---

## Table of Content

[Database Normalization Analysis](#database-normalization-analysis)
[Objective](#objective)
[Normalization Overview](#normalization-overview)
[Normalization Steps Applied](#normalization-steps-applied)
[Constraints and Indexes](#constraints-and-indexes)
    - [Updated Constraints](#updated-constraints)
    - [Recommended Indexes](#recommended-indexes)

---

## Normalization Overview

Database normalization is a systematic approach to organizing data to minimize redundancy and dependency. The normalization process involves several normal forms:

**1NF (First Normal Form):** Eliminates repeating groups
**2NF (Second Normal Form):** Eliminates partial dependencies
**3NF (Third Normal Form):** Eliminates transitive dependencies

### Normalization Steps Applied

**Step 1: First Normal Form (1NF) Compliance**
Status: Compliant
All tables satisfy 1NF requirements:

- Each column contains atomic (indivisible) values
- No repeating groups or arrays
- Each row is unique with primary keys defined

**Analysis:**

- User table: All attributes are atomic
- Property table: All attributes are atomic
- All other tables maintain atomic values

**Step 2: Second Normal Form (2NF) Compliance**
Status: Compliant
All tables satisfy 2NF requirements:

Already in 1NF
All non-key attributes are fully functionally dependent on primary keys
No partial dependencies exist

**Analysis:**

- All tables use UUID primary keys (single-attribute keys)
- No composite keys present, eliminating partial dependency concerns
- All non-key attributes depend entirely on their respective primary keys

**Step 3: Third Normal Form (3NF) Analysis and Improvements**
Status: Requires Optimization

Issues Identified:

1. **Location Data in Property Table**

   - Issue: The location field stores address as a single VARCHAR
   - Problem: Violates 3NF due to potential transitive dependencies
   - Solution: Normalize location data
2. **User Role Management**

   - Issue: Role stored as ENUM directly in User table
   - Consideration: For future scalability, role permissions might need normalization

Normalization Improvements Applied:

1. **Location Normalization**
   **Before:**

```sql
PROPERTY {
    property_id UUID PK
    host_id UUID FK
    name VARCHAR
    description TEXT
    location VARCHAR  -- Problematic field
    pricepernight DECIMAL
    created_at TIMESTAMP
    updated_at TIMESTAMP
}
```

**After:**

```sql
-- New Location table
LOCATION {
    location_id UUID PK
    street_address VARCHAR NOT NULL
    city VARCHAR NOT NULL
    state_province VARCHAR NOT NULL
    country VARCHAR NOT NULL
    postal_code VARCHAR
    latitude DECIMAL(9,8)
    longitude DECIMAL(7,8)
    created_at TIMESTAMP
}

-- Updated Property table
PROPERTY {
    property_id UUID PK
    host_id UUID FK
    location_id UUID FK  -- Foreign key to Location
    name VARCHAR NOT NULL
    description TEXT NOT NULL
    pricepernight DECIMAL NOT NULL
    created_at TIMESTAMP
    updated_at TIMESTAMP
}
```

**Benefits:**

- Eliminates redundant location storage
- Enables efficient location-based queries
- Supports geospatial operations
- Maintains data consistency

2. **User Role Management Enhancement**

**Current Implementation:**

```sql
USER {
    user_id UUID PK
    role ENUM(guest, host, admin)  -- Simple but limited
}
```

**Recommended for Scale (Future Enhancements):**

```sql
-- Role table expansion
ROLE {
    role_id UUID PK
    role_name VARCHAR UNIQUE NOT NULL
    description TEXT
    created_at TIMESTAMP
}

-- User-Role relationship
USER {
    user_id UUID PK
    role_id UUID FK  -- References Role table
    VARCHAR first_name
    VARCHAR last_name
    VARCHAR email UNIQUE
    VARCHAR password_hash
    VARCHAR phone_number
    ENUM role
    TIMESTAMP created_at
}
```

**Normalized Schema (Final)**
Updated Entity Relationships

```mermaid
    erDiagram
    USER ||--o{ PROPERTY : hosts
    USER ||--o{ BOOKING : makes
    PROPERTY ||--o{ BOOKING : contains
    BOOKING ||--|| PAYMENT : has
    USER ||--o{ REVIEW : writes
    PROPERTY ||--o{ REVIEW : receives
    USER ||--o{ MESSAGE : sends
    USER ||--o{ MESSAGE : receives
    LOCATION ||--o{ PROPERTY : locates

    USER {
        UUID user_id PK
        VARCHAR first_name
        VARCHAR last_name
        VARCHAR email UNIQUE
        VARCHAR password_hash
        VARCHAR phone_number
        ENUM role
        TIMESTAMP created_at
    }

    LOCATION {
        UUID location_id PK
        VARCHAR street_address
        VARCHAR city
        VARCHAR state_province
        VARCHAR country
        VARCHAR postal_code
        DECIMAL latitude
        DECIMAL longitude
        TIMESTAMP created_at
    }

    PROPERTY {
        UUID property_id PK
        UUID host_id FK
        UUID location_id FK
        VARCHAR name
        TEXT description
        DECIMAL pricepernight
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    BOOKING {
        UUID booking_id PK
        UUID property_id FK
        UUID user_id FK
        DATE start_date
        DATE end_date
        DECIMAL total_price
        ENUM status
        TIMESTAMP created_at
    }

    PAYMENT {
        UUID payment_id PK
        UUID booking_id FK
        DECIMAL amount
        TIMESTAMP payment_date
        ENUM payment_method
    }

    REVIEW {
        UUID review_id PK
        UUID property_id FK
        UUID user_id FK
        INTEGER rating
        TEXT comment
        TIMESTAMP created_at
    }

    MESSAGE {
        UUID message_id PK
        UUID sender_id FK
        UUID recipient_id FK
        TEXT message_body
        TIMESTAMP sent_at
    }
```

### Constraints and Indexes

#### Updated Constraints

```sql
-- Location constraints
ALTER TABLE location ADD CONSTRAINT check_latitude 
    CHECK (latitude >= -90 AND latitude <= 90);
ALTER TABLE location ADD CONSTRAINT check_longitude 
    CHECK (longitude >= -180 AND longitude <= 180);

-- Existing constraints maintained
ALTER TABLE review ADD CONSTRAINT check_rating 
    CHECK (rating >= 1 AND rating <= 5);
```

#### Recommended Indexes

```sql
-- Location-based indexes
CREATE INDEX idx_location_city ON location(city);
CREATE INDEX idx_location_country ON location(country);
CREATE INDEX idx_location_coordinates ON location(latitude, longitude);

-- Existing indexes maintained
CREATE INDEX idx_user_email ON user(email);
CREATE INDEX idx_property_host ON property(host_id);
CREATE INDEX idx_booking_property ON booking(property_id);
CREATE INDEX idx_booking_user ON booking(user_id);
```
