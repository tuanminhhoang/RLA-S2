-- MediRun Database Enhancement
-- Add delivery, route, and emergency management tables
-- Run after 01_create_database.sql through 03_create_fleet_tables.sql

USE medirun_db;

-- Update accounts table to use 'ceo' and 'driver' roles
ALTER TABLE accounts MODIFY status ENUM('ceo', 'driver') NOT NULL DEFAULT 'driver';

-- Enhance cars table with delivery-specific fields
ALTER TABLE cars 
ADD COLUMN size ENUM('small', 'large') NOT NULL DEFAULT 'small' AFTER model,
ADD COLUMN has_fridge BOOLEAN NOT NULL DEFAULT FALSE AFTER size,
ADD COLUMN capacity_kg INT NOT NULL DEFAULT 50 AFTER has_fridge,
ADD COLUMN current_latitude DECIMAL(10, 8) NULL AFTER capacity_kg,
ADD COLUMN current_longitude DECIMAL(11, 8) NULL AFTER current_latitude,
ADD COLUMN current_driver_id INT NULL AFTER current_longitude,
ADD FOREIGN KEY (current_driver_id) REFERENCES drivers(id) ON DELETE SET NULL;

-- Deliveries table - tracks delivery requests
CREATE TABLE deliveries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pickup_address VARCHAR(255) NOT NULL,
  delivery_address VARCHAR(255) NOT NULL,
  package_size ENUM('small', 'large') NOT NULL,
  requires_fridge BOOLEAN NOT NULL DEFAULT FALSE,
  package_weight_kg INT NOT NULL DEFAULT 10,
  status ENUM('pending', 'assigned', 'in_transit', 'delivered', 'cancelled') NOT NULL DEFAULT 'pending',
  assigned_truck_id INT NULL,
  assigned_driver_id INT NULL,
  pickup_time DATETIME NULL,
  delivery_window_start DATETIME NULL,
  delivery_window_end DATETIME NULL,
  actual_delivery_time DATETIME NULL,
  distance_km DECIMAL(10, 2) DEFAULT 0,
  estimated_duration_minutes INT DEFAULT 0,
  notes VARCHAR(500) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (assigned_truck_id) REFERENCES cars(id) ON DELETE SET NULL,
  FOREIGN KEY (assigned_driver_id) REFERENCES drivers(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Routes table - tracks active delivery routes for trucks
CREATE TABLE routes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  truck_id INT NOT NULL,
  driver_id INT NOT NULL,
  status ENUM('planning', 'active', 'completed') NOT NULL DEFAULT 'planning',
  total_distance_km DECIMAL(10, 2) DEFAULT 0,
  total_duration_minutes INT DEFAULT 0,
  current_stop_index INT DEFAULT 0,
  stops_completed INT DEFAULT 0,
  total_stops INT DEFAULT 0,
  start_time DATETIME NULL,
  estimated_end_time DATETIME NULL,
  actual_end_time DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (truck_id) REFERENCES cars(id) ON DELETE CASCADE,
  FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Route stops table - individual delivery stops in a route
CREATE TABLE route_stops (
  id INT AUTO_INCREMENT PRIMARY KEY,
  route_id INT NOT NULL,
  delivery_id INT NOT NULL,
  stop_order INT NOT NULL,
  stop_address VARCHAR(255) NOT NULL,
  stop_latitude DECIMAL(10, 8) NULL,
  stop_longitude DECIMAL(11, 8) NULL,
  estimated_arrival_time DATETIME NULL,
  actual_arrival_time DATETIME NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE,
  FOREIGN KEY (delivery_id) REFERENCES deliveries(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Emergency deliveries table
CREATE TABLE emergency_deliveries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  location_address VARCHAR(255) NOT NULL,
  location_latitude DECIMAL(10, 8) NULL,
  location_longitude DECIMAL(11, 8) NULL,
  package_size ENUM('small', 'large') NOT NULL,
  requires_fridge BOOLEAN NOT NULL DEFAULT FALSE,
  package_weight_kg INT NOT NULL DEFAULT 10,
  priority_level ENUM('high', 'critical') NOT NULL DEFAULT 'high',
  status ENUM('pending', 'assigned', 'in_transit', 'delivered') NOT NULL DEFAULT 'pending',
  assigned_truck_id INT NULL,
  assigned_driver_id INT NULL,
  suggested_truck_id INT NULL,
  requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  assigned_at DATETIME NULL,
  delivered_at DATETIME NULL,
  reason VARCHAR(500) NULL,
  FOREIGN KEY (assigned_truck_id) REFERENCES cars(id) ON DELETE SET NULL,
  FOREIGN KEY (assigned_driver_id) REFERENCES drivers(id) ON DELETE SET NULL,
  FOREIGN KEY (suggested_truck_id) REFERENCES cars(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Driver hours tracking table
CREATE TABLE driver_daily_hours (
  id INT AUTO_INCREMENT PRIMARY KEY,
  driver_id INT NOT NULL,
  work_date DATE NOT NULL,
  hours_worked DECIMAL(4, 2) DEFAULT 0,
  hours_remaining DECIMAL(4, 2) DEFAULT 8,
  status ENUM('active', 'off_duty', 'rest') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_driver_date (driver_id, work_date),
  FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Position tracking table (for simulation purposes)
CREATE TABLE position_history (
  id INT AUTO_INCREMENT PRIMARY KEY,
  truck_id INT NOT NULL,
  driver_id INT NOT NULL,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  route_id INT NULL,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (truck_id) REFERENCES cars(id) ON DELETE CASCADE,
  FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE CASCADE,
  FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE SET NULL
) ENGINE=InnoDB;
