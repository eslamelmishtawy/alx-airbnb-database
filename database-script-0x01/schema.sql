-- AirBnB Database Schema
-- Crea-- Create Property table
CREATE TABLE IF NOT EXISTS Property (d: August 28, 2025
-- Description: Complete database schema for AirBnB-style application

-- Enable UUID extension (for PostgreSQL)
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop tables if they exist (in reverse order of dependencies)
-- WARNING: Uncomment these lines only for development/testing environments
-- These commands will DELETE ALL DATA in the tables!

-- DROP TABLE IF EXISTS Message;
-- DROP TABLE IF EXISTS Review;
-- DROP TABLE IF EXISTS Payment;
-- DROP TABLE IF EXISTS Booking;
-- DROP TABLE IF EXISTS Property;
-- DROP TABLE IF EXISTS User;

-- Alternative: Use CREATE TABLE IF NOT EXISTS for production safety
-- This approach won't recreate existing tables, preserving data

-- Create User table
CREATE TABLE IF NOT EXISTS User (
    user_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NULL,
    role ENUM('guest', 'host', 'admin') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Property table
CREATE TABLE Property
(
    property_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    host_id CHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(255) NOT NULL,
    pricepernight DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ON
    UPDATE CURRENT_TIMESTAMP,

    -- Foreign key constraint
    CONSTRAINT fk_property_host
    FOREIGN KEY
    (host_id)
        REFERENCES User
    (user_id)
        ON
    DELETE CASCADE
        ON
    UPDATE CASCADE
);

    -- Create Booking table
    CREATE TABLE IF NOT EXISTS Booking (
    booking_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Foreign key constraints
    CONSTRAINT fk_booking_property
        FOREIGN KEY
    (property_id)
        REFERENCES Property
    (property_id)
        ON
    DELETE CASCADE
        ON
    UPDATE CASCADE,

    CONSTRAINT fk_booking_user
        FOREIGN KEY
    (user_id)
        REFERENCES User
    (user_id)
        ON
    DELETE CASCADE
        ON
    UPDATE CASCADE,

    -- Check constraints
    CONSTRAINT chk_booking_dates
        CHECK
    (end_date > start_date),

    CONSTRAINT chk_total_price
        CHECK
    (total_price > 0)
);

    -- Create Payment table
    CREATE TABLE IF NOT EXISTS Payment (
    payment_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    booking_id CHAR(36) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('credit_card', 'paypal', 'stripe') NOT NULL,

    -- Foreign key constraint
    CONSTRAINT fk_payment_booking
        FOREIGN KEY
    (booking_id)
        REFERENCES Booking
    (booking_id)
        ON
    DELETE CASCADE
        ON
    UPDATE CASCADE,

    -- Check constraint
    CONSTRAINT chk_payment_amount
        CHECK
    (amount > 0)
);

    -- Create Review table
    CREATE TABLE IF NOT EXISTS Review
    (
        review_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
        property_id CHAR(36) NOT NULL,
        user_id CHAR(36) NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

        -- Foreign key constraints
        CONSTRAINT fk_review_property
        FOREIGN KEY (property_id)
        REFERENCES Property(property_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

        CONSTRAINT fk_review_user
        FOREIGN KEY (user_id)
        REFERENCES User(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

        -- Check constraint for rating
        CONSTRAINT chk_rating_range
        CHECK (rating >= 1 AND rating <= 5)
    );

    -- Create Message table
    CREATE TABLE IF NOT EXISTS Message
    (
        message_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
        sender_id CHAR(36) NOT NULL,
        recipient_id CHAR(36) NOT NULL,
        message_body TEXT NOT NULL,
        sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

        -- Foreign key constraints
        CONSTRAINT fk_message_sender
        FOREIGN KEY (sender_id)
        REFERENCES User(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

        CONSTRAINT fk_message_recipient
        FOREIGN KEY (recipient_id)
        REFERENCES User(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

        -- Check constraint to prevent self-messaging
        CONSTRAINT chk_different_users
        CHECK (sender_id != recipient_id)
    );

    -- Create indexes for optimal performance

    -- User table indexes
    CREATE INDEX idx_user_email ON User(email);
    CREATE INDEX idx_user_role ON User(role);
    CREATE INDEX idx_user_created_at ON User(created_at);

    -- Property table indexes
    CREATE INDEX idx_property_host_id ON Property(host_id);
    CREATE INDEX idx_property_location ON Property(location);
    CREATE INDEX idx_property_price ON Property(pricepernight);
    CREATE INDEX idx_property_created_at ON Property(created_at);

    -- Booking table indexes
    CREATE INDEX idx_booking_property_id ON Booking(property_id);
    CREATE INDEX idx_booking_user_id ON Booking(user_id);
    CREATE INDEX idx_booking_status ON Booking(status);
    CREATE INDEX idx_booking_dates ON Booking(start_date, end_date);
    CREATE INDEX idx_booking_created_at ON Booking(created_at);

    -- Payment table indexes
    CREATE INDEX idx_payment_booking_id ON Payment(booking_id);
    CREATE INDEX idx_payment_method ON Payment(payment_method);
    CREATE INDEX idx_payment_date ON Payment(payment_date);

    -- Review table indexes
    CREATE INDEX idx_review_property_id ON Review(property_id);
    CREATE INDEX idx_review_user_id ON Review(user_id);
    CREATE INDEX idx_review_rating ON Review(rating);
    CREATE INDEX idx_review_created_at ON Review(created_at);

    -- Message table indexes
    CREATE INDEX idx_message_sender_id ON Message(sender_id);
    CREATE INDEX idx_message_recipient_id ON Message(recipient_id);
    CREATE INDEX idx_message_sent_at ON Message(sent_at);

    -- Composite indexes for common query patterns
    CREATE INDEX idx_booking_property_dates ON Booking(property_id, start_date, end_date);
    CREATE INDEX idx_review_property_rating ON Review(property_id, rating);
    CREATE INDEX idx_message_conversation ON Message(sender_id, recipient_id, sent_at);

    -- Additional constraints and business rules

    -- Add unique constraint to prevent duplicate reviews from same user for same property
    ALTER TABLE Review
ADD CONSTRAINT uk_user_property_review
UNIQUE (user_id, property_id);

    -- Add constraint to ensure booking dates don't overlap for the same property
    -- Note: This would typically be enforced at application level or with triggers
    -- as it's complex to enforce with simple CHECK constraints

    DELIMITER $$

    -- Trigger to automatically update Property.updated_at timestamp
    CREATE TRIGGER tr_property_updated_at
    BEFORE
    UPDATE ON Property
    FOR EACH ROW
    BEGIN
        SET NEW
        .updated_at = CURRENT_TIMESTAMP;
    END$$

DELIMITER ;

    -- Sample data validation views (optional)

    -- View to check booking conflicts
    CREATE VIEW v_booking_conflicts
    AS
        SELECT
            b1.booking_id as booking1_id,
            b2.booking_id as booking2_id,
            b1.property_id,
            b1.start_date as booking1_start,
            b1.end_date as booking1_end,
            b2.start_date as booking2_start,
            b2.end_date as booking2_end
        FROM Booking b1
            JOIN Booking b2 ON b1.property_id = b2.property_id
                AND b1.booking_id != b2.booking_id
                AND b1.status IN ('confirmed', 'pending')
                AND b2.status IN ('confirmed', 'pending')
                AND (
        (b1.start_date <= b2.end_date AND b1.end_date >= b2.start_date)
    );

    -- View for property statistics
    CREATE VIEW v_property_stats
    AS
        SELECT
            p.property_id,
            p.name,
            p.host_id,
            COUNT(DISTINCT b.booking_id) as total_bookings,
            COUNT(DISTINCT r.review_id) as total_reviews,
            AVG(r.rating) as average_rating,
            SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) as total_revenue
        FROM Property p
            LEFT JOIN Booking b ON p.property_id = b.property_id
            LEFT JOIN Review r ON p.property_id = r.property_id
        GROUP BY p.property_id, p.name, p.host_id;

    -- View for user activity summary
    CREATE VIEW v_user_activity
    AS
        SELECT
            u.user_id,
            u.first_name,
            u.last_name,
            u.role,
            COUNT(DISTINCT CASE WHEN u.role = 'host' THEN p.property_id END) as properties_owned,
            COUNT(DISTINCT CASE WHEN u.role IN ('guest', 'host') THEN b.booking_id END) as bookings_made,
            COUNT(DISTINCT r.review_id) as reviews_written,
            COUNT(DISTINCT m_sent.message_id) as messages_sent,
            COUNT(DISTINCT m_received.message_id) as messages_received
        FROM User u
            LEFT JOIN Property p ON u.user_id = p.host_id
            LEFT JOIN Booking b ON u.user_id = b.user_id
            LEFT JOIN Review r ON u.user_id = r.user_id
            LEFT JOIN Message m_sent ON u.user_id = m_sent.sender_id
            LEFT JOIN Message m_received ON u.user_id = m_received.recipient_id
        GROUP BY u.user_id, u.first_name, u.last_name, u.role;

-- Comments for documentation
/*
Schema Notes:
1. UUID data type is represented as CHAR(36) for compatibility across different MySQL versions
2. All tables include proper foreign key constraints with CASCADE options
3. Check constraints ensure data integrity (rating 1-5, positive prices, valid date ranges)
4. Comprehensive indexing strategy for optimal query performance
5. Unique constraint prevents duplicate reviews from same user for same property
6. Views provide useful business intelligence and conflict detection
7. Trigger maintains updated_at timestamp automatically
8. All timestamps use DEFAULT CURRENT_TIMESTAMP for consistency
9. Text fields use appropriate sizes (VARCHAR for shorter fields, TEXT for longer content)
10. ENUM types restrict values to valid options only
*/
