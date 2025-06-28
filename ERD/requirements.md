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

    PROPERTY {
        UUID property_id PK
        UUID host_id FK
        VARCHAR name
        TEXT description
        VARCHAR location
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
