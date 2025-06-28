# Airbnb ER Diagram Requirements

## Objective

Entity-Relationship Diagram (ERD) for the core Airbnb system. The ERD represent
entities, attributes, relationships, and constraints described in the database
specification below.

### Table of Contents

[Airbnb ER Diagram Requirements](#airbnb-er-diagram-requirements)
[Entities and Attributes](#entities-and-attributes)
[User](#user)
[Property](#property)
[Booking](#booking)
[Payment](#payment)
[Review](#review)
[Message](#message)
[Relationships](#relationships)
[Airbnb Clone ER Diagram](#airbnb-clone-er-diagram)
[Constraints Summary](#constraints-summary)

---

## Entities and Attributes

### User

- `user_id` (PK, UUID, Indexed)
- `first_name` (VARCHAR, NOT NULL)
- `last_name` (VARCHAR, NOT NULL)
- `email` (VARCHAR, UNIQUE, NOT NULL)
- `password_hash` (VARCHAR, NOT NULL)
- `phone_number` (VARCHAR, NULL)
- `role` (ENUM: guest, host, admin)
- `created_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)

### Property

- `property_id` (PK, UUID, Indexed)
- `host_id` (FK → User.user_id)
- `name` (VARCHAR, NOT NULL)
- `description` (TEXT, NOT NULL)
- `location` (VARCHAR, NOT NULL)
- `pricepernight` (DECIMAL, NOT NULL)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

### Booking

- `booking_id` (PK, UUID, Indexed)
- `property_id` (FK → Property.property_id)
- `user_id` (FK → User.user_id)
- `start_date` (DATE, NOT NULL)
- `end_date` (DATE, NOT NULL)
- `total_price` (DECIMAL, NOT NULL)
- `status` (ENUM: pending, confirmed, canceled)
- `created_at` (TIMESTAMP)

### Payment

- `payment_id` (PK, UUID, Indexed)
- `booking_id` (FK → Booking.booking_id)
- `amount` (DECIMAL, NOT NULL)
- `payment_date` (TIMESTAMP)
- `payment_method` (ENUM: credit_card, paypal, stripe)

### Review

- `review_id` (PK, UUID, Indexed)
- `property_id` (FK → Property.property_id)
- `user_id` (FK → User.user_id)
- `rating` (INT: 1-5)
- `comment` (TEXT, NOT NULL)
- `created_at` (TIMESTAMP)

### Message

- `message_id` (PK, UUID, Indexed)
- `sender_id` (FK → User.user_id)
- `recipient_id` (FK → User.user_id)
- `message_body` (TEXT, NOT NULL)
- `sent_at` (TIMESTAMP)

---

## Relationships

| From     | To       | Type            | Description                        |
| -------- | -------- | --------------- | ---------------------------------- |
| User     | Property | 1:N (host)      | A host can list many properties    |
| User     | Booking  | 1:N             | A guest can make many bookings     |
| Property | Booking  | 1:N             | A property can have many bookings  |
| Booking  | Payment  | 1:1             | Each booking has one payment       |
| User     | Review   | 1:N             | A guest can review many properties |
| Property | Review   | 1:N             | A property can have many reviews   |
| User     | Message  | 1:N (sender)    | A user can send many messages      |
| User     | Message  | 1:N (recipient) | A user can receive many messages   |

---

## Airbnb Clone ER Diagram

### Mermaid ER Diagram

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

    User {
        UUID user_id PK "Indexed"
        VARCHAR first_name "NOT NULL"
        VARCHAR last_name "NOT NULL"
        VARCHAR email "UNIQUE, NOT NULL, Indexed"
        VARCHAR password_hash "NOT NULL"
        VARCHAR phone_number "NULL"
        ENUM role "guest|host|admin, NOT NULL"
        TIMESTAMP created_at "DEFAULT CURRENT_TIMESTAMP"
    }
  
    Property {
        UUID property_id PK "Indexed"
        UUID host_id FK "Indexed"
        VARCHAR name "NOT NULL"
        TEXT description "NOT NULL"
        VARCHAR location "NOT NULL"
        DECIMAL pricepernight "NOT NULL"
        TIMESTAMP created_at "DEFAULT CURRENT_TIMESTAMP"
        TIMESTAMP updated_at "ON UPDATE CURRENT_TIMESTAMP"
    }
  
    Booking {
        UUID booking_id PK "Indexed"
        UUID property_id FK "Indexed"
        UUID user_id FK
        DATE start_date "NOT NULL"
        DATE end_date "NOT NULL"
        DECIMAL total_price "NOT NULL"
        ENUM status "pending|confirmed|canceled, NOT NULL"
        TIMESTAMP created_at "DEFAULT CURRENT_TIMESTAMP"
    }
  
    Payment {
        UUID payment_id PK "Indexed"
        UUID booking_id FK "Indexed"
        DECIMAL amount "NOT NULL"
        TIMESTAMP payment_date "DEFAULT CURRENT_TIMESTAMP"
        ENUM payment_method "credit_card|paypal|stripe, NOT NULL"
    }
  
    Review {
        UUID review_id PK "Indexed"
        UUID property_id FK
        UUID user_id FK
        INTEGER rating "CHECK: 1-5, NOT NULL"
        TEXT comment "NOT NULL"
        TIMESTAMP created_at "DEFAULT CURRENT_TIMESTAMP"
    }
  
    Message {
        UUID message_id PK "Indexed"
        UUID sender_id FK
        UUID recipient_id FK
        TEXT message_body "NOT NULL"
        TIMESTAMP sent_at "DEFAULT CURRENT_TIMESTAMP"
    }
```

### Lucid Chard ER Diagram

![alt text](https://lucid.app/publicSegments/view/d54c101c-eb3a-47fc-8b3f-e462a8da85c0/image.jpeg)

---

## Constraints Summary

`User.email` → UNIQUE

`Review.rating` → CHECK 1 <= rating <= 5

ENUMs for `role`, `status`, `payment_method`

Foreign key constraints across all relational fields

Indexes on all PKs and:

`email` (User)

`property_id` (Property, Booking)

`booking_id` (Booking, Payment)
