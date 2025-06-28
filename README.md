# ALX Airbnb Database Project

Welcome to the **ALX Airbnb Clone Database** project. A foundational database modeling and architecture exercise designed to capture the core functionality of a rental platform like Airbnb.

This project explores real-world database concepts including entity modeling, constraints, indexing, and normalization using PostgreSQL. It aligns with the ALX SE ProDEV curriculum and industry-standard best practices for relational database design.

## Project Objectives

- Design a comprehensive Entity-Relationship Diagram (ERD) for an Airbnb-like platform
- Apply database normalization principles to achieve Third Normal Form (3NF)
- Implement proper constraints, indexes, and relationships
- Follow Django and PostgreSQL best practices
- Create scalable database architecture for real-world applications

---

## Table of Contents

[ALX Airbnb Database Project](#alx-airbnb-database-project)
[Project Overview](#project-objectives)
[Database Features](#database-features)
[Key Relationships](#key-relationships)
[Project Structure](#project-structure)
[License](#license)

---

## Database Features

- **Users:** Guest, Host, and Admin role management
- **Properties:** Property listings with normalized location data
- **Bookings:** Reservation system with status tracking
- **Payments:** Transaction handling with multiple payment methods
- **Reviews:** Rating and feedback system
- **Messages:** Communication between users

## Key Relationships

One-to-Many: User → Properties, User → Bookings, Property → Reviews
One-to-One: Booking → Payment
Many-to-Many: User ↔ Messages (sender/recipient)

## Project Structure

```text
alx-airbnb-database/
├── ERD/
│   └── requirements.md   # ER diagram
├── normalization.md    # Normalization of schema report
├── README.md             # Project overview
```

## License

This project is part of the ALX SE ProDEV curriculum and is intended for educational purposes.
