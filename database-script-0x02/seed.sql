-- Airbnb Clone Database Seed Data
-- This script populates the database with realistic sample data using Ghanaian names
-- Following PostgreSQL best practices and Django ORM conventions
-- Compatible with the normalized 3NF schema structure

-- Clear existing data (in reverse dependency order)
TRUNCATE TABLE message CASCADE;
TRUNCATE TABLE review CASCADE;
TRUNCATE TABLE payment CASCADE;
TRUNCATE TABLE booking CASCADE;
TRUNCATE TABLE property CASCADE;
TRUNCATE TABLE location CASCADE;
TRUNCATE TABLE "user" CASCADE;

-- Reset sequences if needed (PostgreSQL handles UUIDs automatically)

-- Begin transaction for data consistency
BEGIN;

-- Insert sample users with Ghanaian names
INSERT INTO "user" (user_id, first_name, last_name, email, password_hash, phone_number, role, created_at) VALUES
-- Guests
('a1b2c3d4-e5f6-7890-abcd-123456789001', 'Kwame', 'Asante', 'kwame.asante@gmail.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewfHzGYWMqKzXxjG', '+233244123456', 'guest', '2024-01-15 10:30:00+00'),
('a1b2c3d4-e5f6-7890-abcd-123456789002', 'Akosua', 'Mensah', 'akosua.mensah@gmail.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewfHzGYWMqKzXxjG', '+233201987654', 'guest', '2024-01-20 14:45:00+00'),
('a1b2c3d4-e5f6-7890-abcd-123456789003', 'Kofi', 'Appiah', 'kofi.appiah@yahoo.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewfHzGYWMqKzXxjG', '+233208765432', 'guest', '2024-02-01 09:15:00+00'),
('a1b2c3d4-e5f6-7890-abcd-123456789004', 'Ama', 'Osei', 'ama.osei@hotmail.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewfHzGYWMqKzXxjG', '+233245678901', 'guest', '2024-02-10 16:20:00+00'),
('a1b2c3d4-e5f6-7890-abcd-123456789005', 'Yaw', 'Boateng', 'yaw.boateng@gmail.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewfHzGYWMqKzXxjG', '+233509876543', 'guest', '2024-02-15 11:30:00+00'),

-- Hosts
('a1b2c3d4-e5f6-7890-abcd-123456789006', 'Efua', 'Danso', 'efua.danso@gmail.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewfHzGYWMqKzXxjG', '+233244567890', 'host', '2023-12-01 08:00:00+00'),
('a1b2c3d4-e5f6-7890-abcd-123456789007', 'Kwaku', 'Owusu', 'kwaku.owusu@outlook.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewfHzGYWMqKzXxjG', '+233206543210', 'host', '2023-11-15 12:45:00+00'),
('a1b2c3d4-e5f6-7890-abcd-123456789008', 'Abena', 'Adjei', 'abena.adjei@gmail.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewfHzGYWMqKzXxjG', '+233551234567', 'host', '2023-10-20 15:30:00+00'),
('a1b2c3d4-e5f6-7890-abcd-123456789009', 'Nana', 'Gyamfi', 'nana.gyamfi@yahoo.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewfHzGYWMqKzXxjG', '+233207890123', 'host', '2023-09-10 10:15:00+00'),
('a1b2c3d4-e5f6-7890-abcd-123456789010', 'Kwesi', 'Ampofo', 'kwesi.ampofo@gmail.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewfHzGYWMqKzXxjG', '+233246789012', 'host', '2023-08-25 13:20:00+00'),

-- Admins  
('a1b2c3d4-e5f6-7890-abcd-123456789011', 'Akwasi', 'Frimpong', 'admin@airbnbgh.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewfHzGYWMqKzXxjG', '+233302123456', 'admin', '2023-06-01 07:00:00+00'),
('a1b2c3d4-e5f6-7890-abcd-123456789012', 'Adwoa', 'Sarpong', 'support@airbnbgh.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewfHzGYWMqKzXxjG', '+233302654321', 'admin', '2023-06-15 09:30:00+00');

-- Insert location data for Ghanaian cities
INSERT INTO location (location_id, street_address, city, state_province, country, postal_code, latitude, longitude, created_at) VALUES
-- Accra locations
('b1c2d3e4-f5g6-7890-bcde-234567890001', 'Ring Road East', 'Accra', 'Greater Accra', 'Ghana', 'GA-001', 5.6037, -0.1870, '2023-12-01 10:00:00+00'),
('b1c2d3e4-f5g6-7890-bcde-234567890002', 'Cantonments Road', 'Accra', 'Greater Accra', 'Ghana', 'GA-002', 5.5633, -0.1728, '2023-12-01 10:15:00+00'),
('b1c2d3e4-f5g6-7890-bcde-234567890003', 'East Legon', 'Accra', 'Greater Accra', 'Ghana', 'GA-003', 5.6311, -0.1681, '2023-12-01 10:30:00+00'),
('b1c2d3e4-f5g6-7890-bcde-234567890004', 'Airport Residential Area', 'Accra', 'Greater Accra', 'Ghana', 'GA-004', 5.6056, -0.1719, '2023-12-01 10:45:00+00'),
('b1c2d3e4-f5g6-7890-bcde-234567890005', 'Osu', 'Accra', 'Greater Accra', 'Ghana', 'GA-005', 5.5553, -0.1804, '2023-12-01 11:00:00+00'),

-- Kumasi locations
('b1c2d3e4-f5g6-7890-bcde-234567890006', 'KNUST Campus', 'Kumasi', 'Ashanti', 'Ghana', 'AK-001', 6.6745, -1.5716, '2023-12-01 11:15:00+00'),
('b1c2d3e4-f5g6-7890-bcde-234567890007', 'Adum', 'Kumasi', 'Ashanti', 'Ghana', 'AK-002', 6.6981, -1.6241, '2023-12-01 11:30:00+00'),
('b1c2d3e4-f5g6-7890-bcde-234567890008', 'Asokwa', 'Kumasi', 'Ashanti', 'Ghana', 'AK-003', 6.6906, -1.6559, '2023-12-01 11:45:00+00'),

-- Cape Coast locations
('b1c2d3e4-f5g6-7890-bcde-234567890009', 'Cape Coast Castle Area', 'Cape Coast', 'Central', 'Ghana', 'CP-001', 5.1053, -1.2466, '2023-12-01 12:00:00+00'),
('b1c2d3e4-f5g6-7890-bcde-234567890010', 'University of Cape Coast', 'Cape Coast', 'Central', 'Ghana', 'CP-002', 5.1069, -1.2915, '2023-12-01 12:15:00+00'),

-- Tamale location
('b1c2d3e4-f5g6-7890-bcde-234567890011', 'Central Market Area', 'Tamale', 'Northern', 'Ghana', 'NR-001', 9.4034, -0.8424, '2023-12-01 12:30:00+00'),

-- Ho location
('b1c2d3e4-f5g6-7890-bcde-234567890012', 'Ho Technical University Area', 'Ho', 'Volta', 'Ghana', 'VR-001', 6.6070, 0.4720, '2023-12-01 12:45:00+00');

-- Insert properties
INSERT INTO property (property_id, host_id, location_id, name, description, pricepernight, created_at) VALUES
-- Efua's properties
('c1d2e3f4-g5h6-7890-cdef-345678901001', 'a1b2c3d4-e5f6-7890-abcd-123456789006', 'b1c2d3e4-f5g6-7890-bcde-234567890001', 'Luxury Villa in Ring Road East', 'Beautiful 4-bedroom villa with modern amenities, swimming pool, and 24/7 security. Perfect for business travelers and families visiting Accra.', 180.00, '2023-12-02 10:00:00+00'),
('c1d2e3f4-g5h6-7890-cdef-345678901002', 'a1b2c3d4-e5f6-7890-abcd-123456789006', 'b1c2d3e4-f5g6-7890-bcde-234567890002', 'Cantonments Executive Apartment', 'Spacious 2-bedroom apartment in the heart of Cantonments. Walking distance to embassies and high-end restaurants.', 120.00, '2023-12-02 11:00:00+00'),

-- Kwaku's properties
('c1d2e3f4-g5h6-7890-cdef-345678901003', 'a1b2c3d4-e5f6-7890-abcd-123456789007', 'b1c2d3e4-f5g6-7890-bcde-234567890003', 'East Legon Family Home', 'Cozy 3-bedroom family home with garden and parking. Quiet neighborhood perfect for families and professionals.', 95.00, '2023-11-20 14:30:00+00'),
('c1d2e3f4-g5h6-7890-cdef-345678901004', 'a1b2c3d4-e5f6-7890-abcd-123456789007', 'b1c2d3e4-f5g6-7890-bcde-234567890006', 'KNUST Campus Lodge', 'Student-friendly accommodation near KNUST campus. Shared facilities and study areas available.', 35.00, '2023-11-20 15:00:00+00'),

-- Abena's properties
('c1d2e3f4-g5h6-7890-cdef-345678901005', 'a1b2c3d4-e5f6-7890-abcd-123456789008', 'b1c2d3e4-f5g6-7890-bcde-234567890004', 'Airport City Business Suite', 'Modern 1-bedroom suite near Kotoka International Airport. Ideal for business travelers with airport shuttle service.', 85.00, '2023-10-25 09:15:00+00'),
('c1d2e3f4-g5h6-7890-cdef-345678901006', 'a1b2c3d4-e5f6-7890-abcd-123456789008', 'b1c2d3e4-f5g6-7890-bcde-234567890009', 'Cape Coast Beach House', 'Charming beach house with ocean view. Perfect for weekend getaways and cultural tourism near Cape Coast Castle.', 110.00, '2023-10-25 10:00:00+00'),

-- Nana's properties
('c1d2e3f4-g5h6-7890-cdef-345678901007', 'a1b2c3d4-e5f6-7890-abcd-123456789009', 'b1c2d3e4-f5g6-7890-bcde-234567890005', 'Osu Night Life Apartment', 'Vibrant 2-bedroom apartment in Osu. Close to Oxford Street nightlife, restaurants, and La Beach.', 75.00, '2023-09-15 16:45:00+00'),
('c1d2e3f4-g5h6-7890-cdef-345678901008', 'a1b2c3d4-e5f6-7890-abcd-123456789009', 'b1c2d3e4-f5g6-7890-bcde-234567890007', 'Kumasi Cultural Hub', 'Traditional Ghanaian home in Adum, Kumasi. Experience authentic Ashanti culture and visit Manhyia Palace nearby.', 65.00, '2023-09-15 17:30:00+00'),

-- Kwesi's properties
('c1d2e3f4-g5h6-7890-cdef-345678901009', 'a1b2c3d4-e5f6-7890-abcd-123456789010', 'b1c2d3e4-f5g6-7890-bcde-234567890010', 'UCC Student Lodge', 'Affordable accommodation for students and researchers visiting University of Cape Coast. Study facilities available.', 45.00, '2023-08-30 12:00:00+00'),
('c1d2e3f4-g5h6-7890-cdef-345678901010', 'a1b2c3d4-e5f6-7890-abcd-123456789010', 'b1c2d3e4-f5g6-7890-bcde-234567890011', 'Tamale Safari Base', 'Gateway to Northern Ghana wildlife. Perfect base for Mole National Park visits with local tour guide services.', 55.00, '2023-08-30 13:15:00+00');

-- Insert bookings with realistic date ranges
INSERT INTO booking (booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at) VALUES
-- Confirmed bookings (past and current)
('d1e2f3g4-h5i6-7890-defg-456789012001', 'c1d2e3f4-g5h6-7890-cdef-345678901001', 'a1b2c3d4-e5f6-7890-abcd-123456789001', '2024-03-15', '2024-03-20', 900.00, 'confirmed', '2024-02-20 10:30:00+00'),
('d1e2f3g4-h5i6-7890-defg-456789012002', 'c1d2e3f4-g5h6-7890-cdef-345678901003', 'a1b2c3d4-e5f6-7890-abcd-123456789002', '2024-04-01', '2024-04-07', 665.00, 'confirmed', '2024-03-01 14:45:00+00'),
('d1e2f3g4-h5i6-7890-defg-456789012003', 'c1d2e3f4-g5h6-7890-cdef-345678901006', 'a1b2c3d4-e5f6-7890-abcd-123456789003', '2024-05-10', '2024-05-13', 330.00, 'confirmed', '2024-04-15 09:20:00+00'),
('d1e2f3g4-h5i6-7890-defg-456789012004', 'c1d2e3f4-g5h6-7890-cdef-345678901002', 'a1b2c3d4-e5f6-7890-abcd-123456789004', '2024-06-20', '2024-06-25', 600.00, 'confirmed', '2024-05-25 16:10:00+00'),
('d1e2f3g4-h5i6-7890-defg-456789012005', 'c1d2e3f4-g5h6-7890-cdef-345678901007', 'a1b2c3d4-e5f6-7890-abcd-123456789005', '2024-07-01', '2024-07-04', 225.00, 'confirmed', '2024-06-10 11:35:00+00'),

-- Pending bookings (future)
('d1e2f3g4-h5i6-7890-defg-456789012006', 'c1d2e3f4-g5h6-7890-cdef-345678901005', 'a1b2c3d4-e5f6-7890-abcd-123456789001', '2024-08-15', '2024-08-18', 255.00, 'pending', '2024-07-20 08:45:00+00'),
('d1e2f3g4-h5i6-7890-defg-456789012007', 'c1d2e3f4-g5h6-7890-cdef-345678901008', 'a1b2c3d4-e5f6-7890-abcd-123456789002', '2024-09-05', '2024-09-10', 325.00, 'pending', '2024-08-01 13:20:00+00'),
('d1e2f3g4-h5i6-7890-defg-456789012008', 'c1d2e3f4-g5h6-7890-cdef-345678901010', 'a1b2c3d4-e5f6-7890-abcd-123456789003', '2024-10-12', '2024-10-16', 220.00, 'pending', '2024-09-15 15:50:00+00'),

-- Canceled bookings
('d1e2f3g4-h5i6-7890-defg-456789012009', 'c1d2e3f4-g5h6-7890-cdef-345678901004', 'a1b2c3d4-e5f6-7890-abcd-123456789004', '2024-05-25', '2024-05-30', 175.00, 'canceled', '2024-04-20 12:15:00+00'),
('d1e2f3g4-h5i6-7890-defg-456789012010', 'c1d2e3f4-g5h6-7890-cdef-345678901009', 'a1b2c3d4-e5f6-7890-abcd-123456789005', '2024-06-15', '2024-06-18', 135.00, 'canceled', '2024-05-10 10:25:00+00');

-- Insert payments for confirmed bookings
INSERT INTO payment (payment_id, booking_id, amount, payment_date, payment_method, created_at) VALUES
('e1f2g3h4-i5j6-7890-efgh-567890123001', 'd1e2f3g4-h5i6-7890-defg-456789012001', 900.00, '2024-02-20 10:45:00+00', 'credit_card', '2024-02-20 10:45:00+00'),
('e1f2g3h4-i5j6-7890-efgh-567890123002', 'd1e2f3g4-h5i6-7890-defg-456789012002', 665.00, '2024-03-01 15:00:00+00', 'paypal', '2024-03-01 15:00:00+00'),
('e1f2g3h4-i5j6-7890-efgh-567890123003', 'd1e2f3g4-h5i6-7890-defg-456789012003', 330.00, '2024-04-15 09:35:00+00', 'stripe', '2024-04-15 09:35:00+00'),
('e1f2g3h4-i5j6-7890-efgh-567890123004', 'd1e2f3g4-h5i6-7890-defg-456789012004', 600.00, '2024-05-25 16:25:00+00', 'credit_card', '2024-05-25 16:25:00+00'),
('e1f2g3h4-i5j6-7890-efgh-567890123005', 'd1e2f3g4-h5i6-7890-defg-456789012005', 225.00, '2024-06-10 11:50:00+00', 'paypal', '2024-06-10 11:50:00+00');

-- Insert reviews for completed stays
INSERT INTO review (review_id, property_id, user_id, rating, comment, created_at) VALUES
('f1g2h3i4-j5k6-7890-fghi-678901234001', 'c1d2e3f4-g5h6-7890-cdef-345678901001', 'a1b2c3d4-e5f6-7890-abcd-123456789001', 5, 'Exceptional stay! The villa was luxurious and well-maintained. Efua was very responsive and helpful. The location is perfect for business meetings in Accra. Highly recommend!', '2024-03-22 14:30:00+00'),
('f1g2h3i4-j5k6-7890-fghi-678901234002', 'c1d2e3f4-g5h6-7890-cdef-345678901003', 'a1b2c3d4-e5f6-7890-abcd-123456789002', 4, 'Great family home in a quiet area. The kids loved the garden. Kwaku provided excellent local recommendations. Only minor issue was the Wi-Fi could be stronger in the bedrooms.', '2024-04-09 11:15:00+00'),
('f1g2h3i4-j5k6-7890-fghi-678901234003', 'c1d2e3f4-g5h6-7890-cdef-345678901006', 'a1b2c3d4-e5f6-7890-abcd-123456789003', 5, 'Amazing beach house with stunning ocean views! Perfect for a relaxing weekend. Abena arranged a wonderful tour of Cape Coast Castle. The house was clean and well-equipped.', '2024-05-15 16:45:00+00'),
('f1g2h3i4-j5k6-7890-fghi-678901234004', 'c1d2e3f4-g5h6-7890-cdef-345678901002', 'a1b2c3d4-e5f6-7890-abcd-123456789004', 4, 'Excellent location in Cantonments. The apartment was modern and comfortable. Walking distance to many embassies and restaurants. Efua was quick to respond to our queries.', '2024-06-27 09:20:00+00'),
('f1g2h3i4-j5k6-7890-fghi-678901234005', 'c1d2e3f4-g5h6-7890-cdef-345678901007', 'a1b2c3d4-e5f6-7890-abcd-123456789005', 3, 'Good location for nightlife enthusiasts. The apartment was adequate but could use some updates. Nana was friendly and provided good area recommendations. La Beach was lovely.', '2024-07-06 12:30:00+00'),
('f1g2h3i4-j5k6-7890-fghi-678901234006', 'c1d2e3f4-g5h6-7890-cdef-345678901001', 'a1b2c3d4-e5f6-7890-abcd-123456789002', 5, 'Second time staying here and it was perfect again! Efua maintains the property excellently. The security and facilities are top-notch. Will definitely book again for future Accra visits.', '2024-07-10 18:45:00+00'),
('f1g2h3i4-j5k6-7890-fghi-678901234007', 'c1d2e3f4-g5h6-7890-cdef-345678901008', 'a1b2c3d4-e5f6-7890-abcd-123456789003', 4, 'Wonderful cultural experience in Kumasi! The traditional home gave us authentic Ghanaian vibes. Nana shared great stories about Ashanti culture. The market visits were amazing.', '2024-06-20 15:20:00+00');

-- Insert messages between users
INSERT INTO message (message_id, sender_id, recipient_id, message_body, sent_at, created_at) VALUES
-- Guest inquiries to hosts
('g1h2i3j4-k5l6-7890-ghij-789012345001', 'a1b2c3d4-e5f6-7890-abcd-123456789001', 'a1b2c3d4-e5f6-7890-abcd-123456789006', 'Hi Efua, I am interested in booking your Ring Road villa for March 15-20. Is it available? Also, do you provide airport pickup service?', '2024-02-19 14:30:00+00', '2024-02-19 14:30:00+00'),
('g1h2i3j4-k5l6-7890-ghij-789012345002', 'a1b2c3d4-e5f6-7890-abcd-123456789006', 'a1b2c3d4-e5f6-7890-abcd-123456789001', 'Hello Kwame! Yes, the villa is available for those dates. I can arrange airport pickup for an additional GH₵50. The villa has all modern amenities including high-speed Wi-Fi and a swimming pool. Shall I send you the booking details?', '2024-02-19 16:45:00+00', '2024-02-19 16:45:00+00'),
('g1h2i3j4-k5l6-7890-ghij-789012345003', 'a1b2c3d4-e5f6-7890-abcd-123456789001', 'a1b2c3d4-e5f6-7890-abcd-123456789006', 'Perfect! Yes, please send the booking details. The airport pickup would be great. Looking forward to staying at your beautiful property.', '2024-02-19 17:15:00+00', '2024-02-19 17:15:00+00'),

-- More guest-host communications
('g1h2i3j4-k5l6-7890-ghij-789012345004', 'a1b2c3d4-e5f6-7890-abcd-123456789002', 'a1b2c3d4-e5f6-7890-abcd-123456789007', 'Hi Kwaku, my family and I are planning to visit Accra in April. Your East Legon home looks perfect for us. Are there good schools nearby for a short visit with our children?', '2024-02-28 10:20:00+00', '2024-02-28 10:20:00+00'),
('g1h2i3j4-k5l6-7890-ghij-789012345005', 'a1b2c3d4-e5f6-7890-abcd-123456789007', 'a1b2c3d4-e5f6-7890-abcd-123456789002', 'Hello Akosua! Yes, there are excellent international schools in East Legon. The area is very family-friendly with parks and shopping centers nearby. I can provide a list of recommended places for families. When are you planning to visit?', '2024-02-28 12:35:00+00', '2024-02-28

-- end of schema