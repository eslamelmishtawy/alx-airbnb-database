# ERD Requirements

## Objective
Create an Entity-Relationship (ER) diagram based on the AirBnB-style database specification.

## Instructions
1. Identify all entities and their attributes.
2. Define the relationships between entities (including cardinality).
3. Use Draw.io (diagrams.net) or any ER tool to create a visual diagram.
4. Export/save the diagram as a `.drawio` file (already provided separately).

---

## Entities & Attributes

### User
- **PK**: `user_id` (UUID)
- `first_name` (VARCHAR, NOT NULL)
- `last_name` (VARCHAR, NOT NULL)
- `email` (VARCHAR, UNIQUE, NOT NULL)
- `password_hash` (VARCHAR, NOT NULL)
- `phone_number` (VARCHAR, NULL)
- `role` (ENUM: `guest`, `host`, `admin`, NOT NULL)
- `created_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)

### Property
- **PK**: `property_id` (UUID)
- **FK**: `host_id` → `User(user_id)`
- `name` (VARCHAR, NOT NULL)
- `description` (TEXT, NOT NULL)
- `location` (VARCHAR, NOT NULL)
- `pricepernight` (DECIMAL, NOT NULL)
- `created_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)
- `updated_at` (TIMESTAMP, ON UPDATE CURRENT_TIMESTAMP)

### Booking
- **PK**: `booking_id` (UUID)
- **FK**: `property_id` → `Property(property_id)`
- **FK**: `user_id` → `User(user_id)`
- `start_date` (DATE, NOT NULL)
- `end_date` (DATE, NOT NULL)
- `total_price` (DECIMAL, NOT NULL)
- `status` (ENUM: `pending`, `confirmed`, `canceled`, NOT NULL)
- `created_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)

### Payment
- **PK**: `payment_id` (UUID)
- **FK**: `booking_id` → `Booking(booking_id)`
- `amount` (DECIMAL, NOT NULL)
- `payment_date` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)
- `payment_method` (ENUM: `credit_card`, `paypal`, `stripe`, NOT NULL)

### Review
- **PK**: `review_id` (UUID)
- **FK**: `property_id` → `Property(property_id)`
- **FK**: `user_id` → `User(user_id)`
- `rating` (INTEGER, CHECK 1–5, NOT NULL)
- `comment` (TEXT, NOT NULL)
- `created_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)

### Message
- **PK**: `message_id` (UUID)
- **FK**: `sender_id` → `User(user_id)`
- **FK**: `recipient_id` → `User(user_id)`
- `message_body` (TEXT, NOT NULL)
- `sent_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)

---

## Relationships (Cardinality & Notes)

1. **User (host) → Property**: 1-to-many (`User.user_id` → `Property.host_id`) — *A host owns many properties*.
2. **User (guest) → Booking**: 1-to-many (`User.user_id` → `Booking.user_id`) — *A guest makes many bookings*.
3. **Property → Booking**: 1-to-many (`Property.property_id` → `Booking.property_id`) — *A property has many bookings*.
4. **Booking → Payment**: 1-to-many (`Booking.booking_id` → `Payment.booking_id`) — *A booking can have multiple payments*.
5. **User → Review**: 1-to-many (`User.user_id` → `Review.user_id`) — *A user writes many reviews*.
6. **Property → Review**: 1-to-many (`Property.property_id` → `Review.property_id`) — *A property receives many reviews*.
7. **User → Message (sender)**: 1-to-many (`User.user_id` → `Message.sender_id`) — *A user sends many messages*.
8. **User → Message (recipient)**: 1-to-many (`User.user_id` → `Message.recipient_id`) — *A user receives many messages*.

---

## Diagramming Guidance (Draw.io)
- Use rectangles for entities; list **PK** first, then **FKs**, then other attributes.
- Use crow’s-foot notation for 1-to-many relationships.
- Label edges (e.g., *hosts*, *books*, *has payments*).
- Add a “Constraints & Indexes” note: uniqueness, NOT NULLs, CHECKs, FKs, and recommended indexes.
- Save the diagram as `airbnb_erd_full.drawio` (file already provided).