-- Airbnb Clone Database Schema

-- This script creates the complete database schema for the Airbnb clone application
-- Following 3NF normalization principles and PostgreSQL best practices
-- It is compatible with Django ORM conventions


-- Drop existing tables if they exist (in reverse dependency order)
DROP TABLE IF EXISTS message CASCADE;
DROP TABLE IF EXISTS review CASCADE;
DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS booking CASCADE;
DROP TABLE IF EXISTS property CASCADE;
DROP TABLE IF EXISTS location CASCADE;
DROP TABLE IF EXISTS "user" CASCADE;

-- Drop existing types if they exist
DROP TYPE IF EXISTS user_role_enum CASCADE;
DROP TYPE IF EXISTS booking_status_enum CASCADE;
DROP TYPE IF EXISTS payment_method_enum CASCADE;


-- Custom Types (ENUMS)

-- User roles enumeration
CREATE TYPE user_role_enum AS ENUM ('guest', 'host', 'admin');

-- Booking status enumeration
CREATE TYPE booking_status_enum AS ENUM ('pending', 'confirmed', 'canceled');

-- Payment method enumeration
CREATE TYPE payment_method_enum AS ENUM ('credit_card', 'paypal', 'stripe');


-- Tables


-- User table
CREATE TABLE "user" (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    role user_role_enum NOT NULL DEFAULT 'guest',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Location table (normalized from Property)
CREATE TABLE location (
    location_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Property table
CREATE TABLE property (
    property_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    host_id UUID NOT NULL,
    location_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    pricepernight DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    CONSTRAINT fk_property_host 
        FOREIGN KEY (host_id) REFERENCES "user"(user_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_property_location 
        FOREIGN KEY (location_id) REFERENCES location(location_id) 
        ON DELETE RESTRICT
);

-- Booking table
CREATE TABLE booking (
    booking_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status booking_status_enum NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    CONSTRAINT fk_booking_property 
        FOREIGN KEY (property_id) REFERENCES property(property_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_booking_user 
        FOREIGN KEY (user_id) REFERENCES "user"(user_id) 
        ON DELETE CASCADE
);

-- Payment table
CREATE TABLE payment (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID UNIQUE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    payment_method payment_method_enum NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    CONSTRAINT fk_payment_booking 
        FOREIGN KEY (booking_id) REFERENCES booking(booking_id) 
        ON DELETE CASCADE
);

-- Review table
CREATE TABLE review (
    review_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    rating INTEGER NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    CONSTRAINT fk_review_property 
        FOREIGN KEY (property_id) REFERENCES property(property_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_review_user 
        FOREIGN KEY (user_id) REFERENCES "user"(user_id) 
        ON DELETE CASCADE
);

-- Message table
CREATE TABLE message (
    message_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL,
    recipient_id UUID NOT NULL,
    message_body TEXT NOT NULL,
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    CONSTRAINT fk_message_sender 
        FOREIGN KEY (sender_id) REFERENCES "user"(user_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_message_recipient 
        FOREIGN KEY (recipient_id) REFERENCES "user"(user_id) 
        ON DELETE CASCADE
);


-- Constraints


-- Location constraints
ALTER TABLE location ADD CONSTRAINT check_latitude 
    CHECK (latitude IS NULL OR (latitude >= -90 AND latitude <= 90));

ALTER TABLE location ADD CONSTRAINT check_longitude 
    CHECK (longitude IS NULL OR (longitude >= -180 AND longitude <= 180));

-- Review rating constraint
ALTER TABLE review ADD CONSTRAINT check_rating 
    CHECK (rating >= 1 AND rating <= 5);

-- Booking date constraints
ALTER TABLE booking ADD CONSTRAINT check_booking_dates 
    CHECK (start_date < end_date);

ALTER TABLE booking ADD CONSTRAINT check_future_booking 
    CHECK (start_date >= CURRENT_DATE);

-- Payment amount constraint
ALTER TABLE payment ADD CONSTRAINT check_payment_amount 
    CHECK (amount > 0);

-- Property price constraint
ALTER TABLE property ADD CONSTRAINT check_price_positive 
    CHECK (pricepernight > 0);

-- Message constraint (prevent self-messaging)
ALTER TABLE message ADD CONSTRAINT check_different_users 
    CHECK (sender_id != recipient_id);


-- Indexes for Performance Optimization


-- User table indexes
CREATE INDEX idx_user_email ON "user"(email);
CREATE INDEX idx_user_role ON "user"(role);
CREATE INDEX idx_user_created_at ON "user"(created_at);

-- Location table indexes
CREATE INDEX idx_location_city ON location(city);
CREATE INDEX idx_location_country ON location(country);
CREATE INDEX idx_location_coordinates ON location(latitude, longitude);
CREATE INDEX idx_location_full_address ON location(city, state_province, country);

-- Property table indexes
CREATE INDEX idx_property_host ON property(host_id);
CREATE INDEX idx_property_location ON property(location_id);
CREATE INDEX idx_property_price ON property(pricepernight);
CREATE INDEX idx_property_created_at ON property(created_at);

-- Booking table indexes
CREATE INDEX idx_booking_property ON booking(property_id);
CREATE INDEX idx_booking_user ON booking(user_id);
CREATE INDEX idx_booking_dates ON booking(start_date, end_date);
CREATE INDEX idx_booking_status ON booking(status);
CREATE INDEX idx_booking_created_at ON booking(created_at);

-- Payment table indexes
CREATE INDEX idx_payment_booking ON payment(booking_id);
CREATE INDEX idx_payment_date ON payment(payment_date);
CREATE INDEX idx_payment_method ON payment(payment_method);

-- Review table indexes
CREATE INDEX idx_review_property ON review(property_id);
CREATE INDEX idx_review_user ON review(user_id);
CREATE INDEX idx_review_rating ON review(rating);
CREATE INDEX idx_review_created_at ON review(created_at);

-- Message table indexes
CREATE INDEX idx_message_sender ON message(sender_id);
CREATE INDEX idx_message_recipient ON message(recipient_id);
CREATE INDEX idx_message_sent_at ON message(sent_at);

-- Composite indexes for common queries
CREATE INDEX idx_booking_property_dates ON booking(property_id, start_date, end_date);
CREATE INDEX idx_review_property_rating ON review(property_id, rating);
CREATE INDEX idx_message_conversation ON message(sender_id, recipient_id, sent_at);


-- Triggers for Automatic Timestamp Updates


-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to all tables with updated_at columns
CREATE TRIGGER update_user_updated_at 
    BEFORE UPDATE ON "user" 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_location_updated_at 
    BEFORE UPDATE ON location 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_property_updated_at 
    BEFORE UPDATE ON property 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_booking_updated_at 
    BEFORE UPDATE ON booking 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payment_updated_at 
    BEFORE UPDATE ON payment 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_review_updated_at 
    BEFORE UPDATE ON review 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_message_updated_at 
    BEFORE UPDATE ON message 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Comments for Documentation


COMMENT ON TABLE "user" IS 'Users of the platform (guests, hosts, admins)';
COMMENT ON TABLE location IS 'Normalized location data for properties';
COMMENT ON TABLE property IS 'Properties available for booking';
COMMENT ON TABLE booking IS 'Booking records linking users to properties';
COMMENT ON TABLE payment IS 'Payment records for bookings (1:1 with booking)';
COMMENT ON TABLE review IS 'User reviews for properties';
COMMENT ON TABLE message IS 'Messages between users';

-- Column comments for complex fields
COMMENT ON COLUMN location.latitude IS 'Latitude coordinate (decimal degrees, -90 to 90)';
COMMENT ON COLUMN location.longitude IS 'Longitude coordinate (decimal degrees, -180 to 180)';
COMMENT ON COLUMN review.rating IS 'Property rating on a scale of 1-5';
COMMENT ON COLUMN booking.total_price IS 'Total calculated price for the booking period';


-- end of schema
