-- AirBnB Database Sample Data
-- Created: August 30, 2025
-- Description: Sample data for AirBnB-style application database

-- Disable foreign key checks temporarily for easier data insertion
SET FOREIGN_KEY_CHECKS
= 0;

-- Clear existing data (optional - uncomment for clean slate)
-- DELETE FROM Message;
-- DELETE FROM Review;
-- DELETE FROM Payment;
-- DELETE FROM Booking;
-- DELETE FROM Property;
-- DELETE FROM User;

-- Insert sample Users
INSERT INTO User
    (user_id, first_name, last_name, email, password_hash, phone_number, role, created_at)
VALUES
    -- Hosts
    ('550e8400-e29b-41d4-a716-446655440001', 'Alice', 'Johnson', 'alice.johnson@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VJdG4.zzO', '+1-555-0101', 'host', '2024-01-15 10:30:00'),
    ('550e8400-e29b-41d4-a716-446655440002', 'Robert', 'Smith', 'robert.smith@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VJdG4.zzO', '+1-555-0102', 'host', '2024-01-20 14:45:00'),
    ('550e8400-e29b-41d4-a716-446655440003', 'Maria', 'Garcia', 'maria.garcia@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VJdG4.zzO', '+1-555-0103', 'host', '2024-02-01 09:15:00'),
    ('550e8400-e29b-41d4-a716-446655440004', 'David', 'Lee', 'david.lee@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VJdG4.zzO', '+1-555-0104', 'host', '2024-02-10 16:20:00'),
    ('550e8400-e29b-41d4-a716-446655440005', 'Sarah', 'Wilson', 'sarah.wilson@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VJdG4.zzO', '+1-555-0105', 'host', '2024-02-15 11:30:00'),

    -- Guests
    ('550e8400-e29b-41d4-a716-446655440006', 'Michael', 'Brown', 'michael.brown@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VJdG4.zzO', '+1-555-0106', 'guest', '2024-03-01 12:00:00'),
    ('550e8400-e29b-41d4-a716-446655440007', 'Emily', 'Davis', 'emily.davis@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VJdG4.zzO', '+1-555-0107', 'guest', '2024-03-05 13:45:00'),
    ('550e8400-e29b-41d4-a716-446655440008', 'James', 'Miller', 'james.miller@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VJdG4.zzO', '+1-555-0108', 'guest', '2024-03-10 15:30:00'),
    ('550e8400-e29b-41d4-a716-446655440009', 'Jessica', 'Anderson', 'jessica.anderson@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VJdG4.zzO', '+1-555-0109', 'guest', '2024-03-15 17:15:00'),
    ('550e8400-e29b-41d4-a716-446655440010', 'Christopher', 'Taylor', 'chris.taylor@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VJdG4.zzO', '+1-555-0110', 'guest', '2024-03-20 09:45:00'),
    ('550e8400-e29b-41d4-a716-446655440011', 'Amanda', 'Thomas', 'amanda.thomas@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VJdG4.zzO', '+1-555-0111', 'guest', '2024-03-25 11:20:00'),
    ('550e8400-e29b-41d4-a716-446655440012', 'Daniel', 'Jackson', 'daniel.jackson@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VJdG4.zzO', '+1-555-0112', 'guest', '2024-04-01 14:10:00'),

    -- Admins
    ('550e8400-e29b-41d4-a716-446655440013', 'Admin', 'User', 'admin@airbnb.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VJdG4.zzO', '+1-555-9999', 'admin', '2024-01-01 00:00:00');

-- Insert sample Properties
INSERT INTO Property
    (property_id, host_id, name, description, location, pricepernight, created_at, updated_at)
VALUES
    -- Alice's properties
    ('650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'Cozy Downtown Apartment', 'A beautiful 1-bedroom apartment in the heart of the city. Walking distance to restaurants, shops, and public transportation. Perfect for business travelers or couples exploring the city.', 'New York, NY', 150.00, '2024-01-16 10:00:00', '2024-01-16 10:00:00'),
    ('650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'Luxury Penthouse Suite', 'Stunning penthouse with panoramic city views, modern amenities, and a private terrace. Features 3 bedrooms, 2 bathrooms, and a fully equipped kitchen.', 'New York, NY', 450.00, '2024-01-18 11:30:00', '2024-01-18 11:30:00'),

    -- Robert's properties
    ('650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002', 'Beach House Paradise', 'Oceanfront beach house with direct beach access. 4 bedrooms, 3 bathrooms, perfect for families or groups. Includes beach equipment and outdoor grill.', 'Miami, FL', 300.00, '2024-01-22 09:45:00', '2024-01-22 09:45:00'),
    ('650e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440002', 'Modern Studio Loft', 'Stylish studio loft in trendy arts district. High ceilings, exposed brick, and modern furnishings. Great for solo travelers or couples.', 'Miami, FL', 120.00, '2024-01-25 14:20:00', '2024-01-25 14:20:00'),

    -- Maria's properties
    ('650e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440003', 'Mountain Cabin Retreat', 'Rustic cabin nestled in the mountains. 2 bedrooms, fireplace, and hiking trails nearby. Perfect for nature lovers and outdoor enthusiasts.', 'Denver, CO', 180.00, '2024-02-03 16:15:00', '2024-02-03 16:15:00'),
    ('650e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440003', 'Historic Victorian Home', 'Beautifully restored Victorian home with period details and modern conveniences. 3 bedrooms, 2 bathrooms, and charming garden.', 'San Francisco, CA', 250.00, '2024-02-05 12:30:00', '2024-02-05 12:30:00'),

    -- David's properties
    ('650e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440004', 'Urban Industrial Loft', 'Converted warehouse loft with industrial charm. Open floor plan, high ceilings, and modern kitchen. Located in vibrant neighborhood.', 'Chicago, IL', 200.00, '2024-02-12 10:45:00', '2024-02-12 10:45:00'),
    ('650e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440004', 'Lakefront Cottage', 'Charming cottage on pristine lake. 2 bedrooms, dock access, and kayaks included. Peaceful retreat from city life.', 'Chicago, IL', 175.00, '2024-02-14 13:00:00', '2024-02-14 13:00:00'),

    -- Sarah's properties
    ('650e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440005', 'Wine Country Villa', 'Elegant villa surrounded by vineyards. 4 bedrooms, 3 bathrooms, and wine tasting room. Perfect for groups and wine enthusiasts.', 'Napa Valley, CA', 400.00, '2024-02-17 15:30:00', '2024-02-17 15:30:00'),
    ('650e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440005', 'Desert Oasis Adobe', 'Authentic adobe home with desert views. 3 bedrooms, private pool, and outdoor kitchen. Unique southwestern experience.', 'Phoenix, AZ', 220.00, '2024-02-20 11:45:00', '2024-02-20 11:45:00');

-- Insert sample Bookings
INSERT INTO Booking
    (booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at)
VALUES
    -- Confirmed bookings
    ('750e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440006', '2024-04-15', '2024-04-18', 450.00, 'confirmed', '2024-04-01 10:30:00'),
    ('750e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440007', '2024-05-01', '2024-05-07', 1800.00, 'confirmed', '2024-04-10 14:20:00'),
    ('750e8400-e29b-41d4-a716-446655440003', '650e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440008', '2024-05-15', '2024-05-20', 900.00, 'confirmed', '2024-04-25 16:45:00'),
    ('750e8400-e29b-41d4-a716-446655440004', '650e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440009', '2024-06-01', '2024-06-05', 800.00, 'confirmed', '2024-05-15 09:15:00'),
    ('750e8400-e29b-41d4-a716-446655440005', '650e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440010', '2024-06-10', '2024-06-15', 2000.00, 'confirmed', '2024-05-20 11:30:00'),
    ('750e8400-e29b-41d4-a716-446655440006', '650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440011', '2024-07-01', '2024-07-03', 900.00, 'confirmed', '2024-06-15 13:45:00'),
    ('750e8400-e29b-41d4-a716-446655440007', '650e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440012', '2024-07-15', '2024-07-18', 360.00, 'confirmed', '2024-07-01 15:20:00'),
    ('750e8400-e29b-41d4-a716-446655440008', '650e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440006', '2024-08-01', '2024-08-05', 1000.00, 'confirmed', '2024-07-10 17:30:00'),

    -- Pending bookings
    ('750e8400-e29b-41d4-a716-446655440009', '650e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440007', '2024-09-01', '2024-09-05', 700.00, 'pending', '2024-08-15 10:00:00'),
    ('750e8400-e29b-41d4-a716-446655440010', '650e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440008', '2024-09-15', '2024-09-20', 1100.00, 'pending', '2024-08-20 12:15:00'),

    -- Canceled bookings
    ('750e8400-e29b-41d4-a716-446655440011', '650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440009', '2024-05-10', '2024-05-12', 300.00, 'canceled', '2024-04-20 14:30:00'),
    ('750e8400-e29b-41d4-a716-446655440012', '650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440010', '2024-06-20', '2024-06-25', 1500.00, 'canceled', '2024-05-25 16:45:00');

-- Insert sample Payments
INSERT INTO Payment
    (payment_id, booking_id, amount, payment_date, payment_method)
VALUES
    -- Payments for confirmed bookings
    ('850e8400-e29b-41d4-a716-446655440001', '750e8400-e29b-41d4-a716-446655440001', 450.00, '2024-04-01 11:00:00', 'credit_card'),
    ('850e8400-e29b-41d4-a716-446655440002', '750e8400-e29b-41d4-a716-446655440002', 1800.00, '2024-04-10 14:45:00', 'paypal'),
    ('850e8400-e29b-41d4-a716-446655440003', '750e8400-e29b-41d4-a716-446655440003', 900.00, '2024-04-25 17:00:00', 'stripe'),
    ('850e8400-e29b-41d4-a716-446655440004', '750e8400-e29b-41d4-a716-446655440004', 800.00, '2024-05-15 09:30:00', 'credit_card'),
    ('850e8400-e29b-41d4-a716-446655440005', '750e8400-e29b-41d4-a716-446655440005', 2000.00, '2024-05-20 11:45:00', 'paypal'),
    ('850e8400-e29b-41d4-a716-446655440006', '750e8400-e29b-41d4-a716-446655440006', 900.00, '2024-06-15 14:00:00', 'stripe'),
    ('850e8400-e29b-41d4-a716-446655440007', '750e8400-e29b-41d4-a716-446655440007', 360.00, '2024-07-01 15:35:00', 'credit_card'),
    ('850e8400-e29b-41d4-a716-446655440008', '750e8400-e29b-41d4-a716-446655440008', 1000.00, '2024-07-10 17:45:00', 'paypal');

-- Insert sample Reviews
INSERT INTO Review
    (review_id, property_id, user_id, rating, comment, created_at)
VALUES
    -- Reviews for completed stays
    ('950e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440006', 5, 'Amazing apartment! Perfect location and Alice was a wonderful host. Everything was clean and exactly as described. Would definitely stay again!', '2024-04-19 10:30:00'),
    ('950e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440007', 5, 'Incredible beach house! Waking up to ocean views every day was magical. The house had everything we needed for a perfect family vacation. Robert was very responsive and helpful.', '2024-05-08 14:20:00'),
    ('950e8400-e29b-41d4-a716-446655440003', '650e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440008', 4, 'Great mountain retreat! The cabin was cozy and the location was perfect for hiking. Only minor issue was the WiFi was a bit slow, but that might be a blessing in disguise for a nature getaway.', '2024-05-21 16:45:00'),
    ('950e8400-e29b-41d4-a716-446655440004', '650e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440009', 5, 'Loved the industrial loft! The space was unique and stylish. Great neighborhood with lots of restaurants and bars within walking distance. David provided excellent recommendations.', '2024-06-06 09:15:00'),
    ('950e8400-e29b-41d4-a716-446655440005', '650e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440010', 5, 'Wine country villa exceeded all expectations! The property is absolutely stunning and the wine room was a fantastic touch. Perfect for our anniversary celebration.', '2024-06-16 11:30:00'),
    ('950e8400-e29b-41d4-a716-446655440006', '650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440011', 4, 'Luxury penthouse was beautiful with amazing views. Only downside was some noise from the street at night, but the space itself was incredible.', '2024-07-04 13:45:00'),
    ('950e8400-e29b-41d4-a716-446655440007', '650e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440012', 4, 'Nice studio loft in a great area. Clean and well-maintained. Perfect for a short business trip. Would recommend to other solo travelers.', '2024-07-19 15:20:00'),
    ('950e8400-e29b-41d4-a716-446655440008', '650e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440006', 5, 'The Victorian home was absolutely charming! Every detail was perfect and the garden was lovely. Maria was an exceptional host with great local recommendations.', '2024-08-06 17:30:00'),

    -- Additional reviews from different guests for same properties
    ('950e8400-e29b-41d4-a716-446655440009', '650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440007', 4, 'Great downtown location! The apartment was clean and comfortable. Alice responded quickly to all our questions. Minor issue with hot water but was fixed promptly.', '2024-06-15 10:00:00'),
    ('950e8400-e29b-41d4-a716-446655440010', '650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440008', 5, 'Best beach vacation ever! The house was perfect for our group of 8. Direct beach access was amazing. Robert even provided beach chairs and umbrellas!', '2024-07-20 12:15:00');

-- Insert sample Messages
INSERT INTO Message
    (message_id, sender_id, recipient_id, message_body, sent_at)
VALUES
    -- Booking inquiry messages
    ('a50e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440001', 'Hi Alice! I saw your downtown apartment listing and I''m interested in booking for April 15-18. Is it available? Thanks!', '2024-03-30 15:30:00'),
    ('a50e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440006', 'Hi Michael! Yes, those dates are available. The apartment is perfect for exploring the city. Would you like me to send you more details?', '2024-03-30 16:15:00'),
    ('a50e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440001', 'That would be great! Also, is parking available? I''ll be driving in from New Jersey.', '2024-03-30 16:45:00'),
    ('a50e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440006', 'There''s a parking garage two blocks away that offers daily rates. I can send you the details. The subway is also very convenient if you prefer not to drive in the city.', '2024-03-30 17:00:00'),

    -- Pre-arrival messages
    ('a50e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440006', 'Hi Michael! Just wanted to confirm your arrival tomorrow. The key will be in the lockbox by the front door. Code is 1234. Let me know if you need anything!', '2024-04-14 18:30:00'),
    ('a50e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440001', 'Perfect, thank you! We should arrive around 3 PM. Looking forward to staying at your place!', '2024-04-14 19:15:00'),

    -- Beach house booking conversation
    ('a50e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440002', 'Hi Robert! Your beach house looks amazing. We''re a family of 4 looking to stay May 1-7. Do you provide beach equipment?', '2024-04-08 10:00:00'),
    ('a50e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440007', 'Hi Emily! Yes, we provide beach chairs, umbrellas, boogie boards, and snorkeling gear. The house is perfect for families. The kids will love it!', '2024-04-08 11:30:00'),
    ('a50e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440002', 'That sounds perfect! We''d like to book those dates. Also, are there any good restaurants nearby?', '2024-04-08 12:00:00'),
    ('a50e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440007', 'Great! I''ll prepare the booking. There are several excellent seafood restaurants within walking distance. I''ll send you a list of my favorites!', '2024-04-08 12:30:00'),

    -- Mountain cabin inquiry
    ('a50e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440003', 'Hello Maria! I''m interested in your mountain cabin for May 15-20. How are the hiking trails this time of year?', '2024-04-20 14:00:00'),
    ('a50e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440008', 'Hi James! May is perfect for hiking here. The weather is great and all trails are open. I can recommend some beautiful routes based on your experience level.', '2024-04-20 15:30:00'),

    -- Wine country villa booking
    ('a50e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440005', 'Hi Sarah! My partner and I are celebrating our anniversary and your wine villa looks perfect. Are there wine tastings available?', '2024-05-15 16:45:00'),
    ('a50e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440010', 'Congratulations! The villa is perfect for anniversaries. I can arrange private tastings at several nearby wineries. Let me know your preferences!', '2024-05-15 18:00:00'),

    -- Post-stay thank you messages
    ('a50e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440001', 'Hi Alice! Just wanted to thank you again for the wonderful stay. Everything was perfect and your recommendations were spot on!', '2024-04-19 11:00:00'),
    ('a50e8400-e29b-41d4-a716-446655440016', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440006', 'Thank you so much, Michael! You were a wonderful guest. Hope to host you again soon!', '2024-04-19 12:30:00');

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS
= 1;

-- Verify data insertion with sample queries
-- Uncomment these SELECT statements to verify data was inserted correctly

-- SELECT 'Users inserted:' as info, COUNT(*) as count FROM User;
-- SELECT 'Properties inserted:' as info, COUNT(*) as count FROM Property;
-- SELECT 'Bookings inserted:' as info, COUNT(*) as count FROM Booking;
-- SELECT 'Payments inserted:' as info, COUNT(*) as count FROM Payment;
-- SELECT 'Reviews inserted:' as info, COUNT(*) as count FROM Review;
-- SELECT 'Messages inserted:' as info, COUNT(*) as count FROM Message;

/*
Sample Data Summary:
- 13 Users (5 hosts, 7 guests, 1 admin)
- 10 Properties across different locations and price ranges
- 12 Bookings (8 confirmed, 2 pending, 2 canceled)
- 8 Payments for confirmed bookings
- 10 Reviews with varied ratings and detailed comments
- 16 Messages showing realistic guest-host communication

The data reflects real-world usage patterns:
- Multiple bookings per property
- Various payment methods
- Realistic price ranges ($120-$450 per night)
- Diverse locations (NYC, Miami, Denver, San Francisco, Chicago, Napa Valley, Phoenix)
- Authentic guest-host conversations
- Varied review ratings (4-5 stars) with detailed feedback
- Different booking statuses to test business logic
*/
