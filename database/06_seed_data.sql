-- MediRun Seed Data
-- Run after all database tables are created

USE medirun_db;

-- Insert sample accounts (CEO and Drivers)
INSERT INTO accounts (username, password, status) VALUES
('ceo_john', '$2b$12$YourHashedPasswordHere', 'ceo'),
('driver_mike', '$2b$12$YourHashedPasswordHere', 'driver'),
('driver_sarah', '$2b$12$YourHashedPasswordHere', 'driver'),
('driver_alex', '$2b$12$YourHashedPasswordHere', 'driver');

-- Insert sample drivers
INSERT INTO drivers (full_name, license_number, phone_number, status) VALUES
('Michael Johnson', 'DL-2024-0001', '555-0101', 'active'),
('Sarah Williams', 'DL-2024-0002', '555-0102', 'active'),
('Alex Martinez', 'DL-2024-0003', '555-0103', 'active'),
('Emma Brown', 'DL-2024-0004', '555-0104', 'active');

-- Insert sample vehicles with enhanced fields
INSERT INTO cars (plate_number, model, color, size, has_fridge, capacity_kg, current_latitude, current_longitude, status) VALUES
('NA-001', 'Toyota Corolla', 'White', 'small', FALSE, 50, 40.7128, -74.0060, 'available'),
('NA-002', 'Honda Civic', 'Gray', 'small', FALSE, 55, 40.7150, -74.0050, 'available'),
('NA-003', 'Mercedes Sprinter', 'White', 'large', TRUE, 200, 40.7100, -74.0100, 'available'),
('NA-004', 'Ford Transit', 'Blue', 'large', TRUE, 180, 40.7160, -74.0040, 'available'),
('NA-005', 'Toyota Prius', 'Green', 'small', FALSE, 45, 40.7140, -74.0070, 'available');

-- Insert sample deliveries
INSERT INTO deliveries 
(pickup_address, delivery_address, package_size, requires_fridge, package_weight_kg, status, distance_km, estimated_duration_minutes, pickup_time, delivery_window_start, delivery_window_end) 
VALUES
('Central Warehouse', 'Downtown Clinic - 123 Main St', 'small', FALSE, 5, 'pending', 5.2, 15, NOW(), DATE_ADD(NOW(), INTERVAL 1 HOUR), DATE_ADD(NOW(), INTERVAL 3 HOUR)),
('Central Warehouse', 'City Hospital - 456 Oak Avenue', 'large', TRUE, 25, 'pending', 8.5, 25, NOW(), DATE_ADD(NOW(), INTERVAL 2 HOUR), DATE_ADD(NOW(), INTERVAL 4 HOUR)),
('Central Warehouse', 'Medical Center - 789 Pine Road', 'small', TRUE, 12, 'pending', 6.8, 20, NOW(), DATE_ADD(NOW(), INTERVAL 3 HOUR), DATE_ADD(NOW(), INTERVAL 5 HOUR)),
('Central Warehouse', 'Pharmacy Chain - 321 Elm Street', 'large', FALSE, 35, 'pending', 10.2, 30, NOW(), DATE_ADD(NOW(), INTERVAL 4 HOUR), DATE_ADD(NOW(), INTERVAL 6 HOUR)),
('Central Warehouse', 'Urgent Care Center - 555 Oak St', 'small', TRUE, 8, 'pending', 4.5, 13, NOW(), DATE_ADD(NOW(), INTERVAL 1 HOUR), DATE_ADD(NOW(), INTERVAL 2 HOUR));

-- Insert today's driver hours
INSERT INTO driver_daily_hours (driver_id, work_date, hours_worked, hours_remaining, status) VALUES
(1, CURDATE(), 0, 8, 'active'),
(2, CURDATE(), 0, 8, 'active'),
(3, CURDATE(), 0, 8, 'active'),
(4, CURDATE(), 0, 8, 'active');

-- Optional: Insert initial truck positions (at warehouse)
INSERT INTO position_history (truck_id, driver_id, latitude, longitude) VALUES
(1, 1, 40.7128, -74.0060),
(2, 2, 40.7128, -74.0060),
(3, 3, 40.7128, -74.0060),
(4, 4, 40.7128, -74.0060),
(5, 1, 40.7128, -74.0060);
