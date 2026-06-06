-- MediRun Database Enhancement
-- Run after 01_create_database.sql through 03_create_fleet_tables.sql.

USE medirun_db;

ALTER TABLE accounts MODIFY status ENUM('ceo', 'driver') NOT NULL DEFAULT 'driver';

ALTER TABLE drivers
ADD COLUMN account_id INT NULL AFTER id,
ADD CONSTRAINT fk_drivers_account
  FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE SET NULL;

ALTER TABLE cars
ADD COLUMN size ENUM('small', 'large') NOT NULL DEFAULT 'small' AFTER model,
ADD COLUMN has_fridge BOOLEAN NOT NULL DEFAULT FALSE AFTER size,
ADD COLUMN capacity_kg INT NOT NULL DEFAULT 50 AFTER has_fridge,
ADD COLUMN current_latitude DECIMAL(10, 8) NULL AFTER capacity_kg,
ADD COLUMN current_longitude DECIMAL(11, 8) NULL AFTER current_latitude,
ADD COLUMN current_driver_id INT NULL AFTER current_longitude,
ADD CONSTRAINT fk_cars_current_driver
  FOREIGN KEY (current_driver_id) REFERENCES drivers(id) ON DELETE SET NULL;

DROP TABLE IF EXISTS position_history;
DROP TABLE IF EXISTS driver_daily_hours;
DROP TABLE IF EXISTS emergency_deliveries;
DROP TABLE IF EXISTS route_stops;
DROP TABLE IF EXISTS routes;
DROP TABLE IF EXISTS daily_vehicle_assignments;
DROP TABLE IF EXISTS deliveries;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS zone_travel_times;

CREATE TABLE clients (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  client_type ENUM('hospital', 'clinic', 'pharmacy') NOT NULL,
  zone ENUM('warehouse', 'paris', 'suburb', 'hospital') NOT NULL,
  address VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE deliveries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  client_id INT NULL,
  pickup_address VARCHAR(255) NOT NULL DEFAULT 'MediRun Warehouse',
  delivery_address VARCHAR(255) NOT NULL,
  zone ENUM('warehouse', 'paris', 'suburb', 'hospital') NOT NULL DEFAULT 'paris',
  delivery_date DATE NOT NULL,
  priority ENUM('urgent', 'normal', 'low') NOT NULL DEFAULT 'normal',
  deadline DATETIME NULL,
  package_size ENUM('small', 'large') NOT NULL DEFAULT 'small',
  requires_fridge BOOLEAN NOT NULL DEFAULT FALSE,
  package_weight_kg INT NOT NULL DEFAULT 10,
  service_time_minutes INT NOT NULL DEFAULT 10,
  emergency BOOLEAN NOT NULL DEFAULT FALSE,
  status ENUM('pending', 'assigned', 'in_transit', 'delivered', 'delayed', 'failed', 'cancelled') NOT NULL DEFAULT 'pending',
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
  FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE SET NULL,
  FOREIGN KEY (assigned_truck_id) REFERENCES cars(id) ON DELETE SET NULL,
  FOREIGN KEY (assigned_driver_id) REFERENCES drivers(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE daily_vehicle_assignments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  assignment_date DATE NOT NULL,
  driver_id INT NOT NULL,
  vehicle_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_assignment_date_driver (assignment_date, driver_id),
  UNIQUE KEY unique_assignment_date_vehicle (assignment_date, vehicle_id),
  FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE CASCADE,
  FOREIGN KEY (vehicle_id) REFERENCES cars(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE routes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  route_date DATE NOT NULL,
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
  warning_text VARCHAR(500) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (truck_id) REFERENCES cars(id) ON DELETE CASCADE,
  FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE route_stops (
  id INT AUTO_INCREMENT PRIMARY KEY,
  route_id INT NOT NULL,
  delivery_id INT NOT NULL,
  stop_order INT NOT NULL,
  stop_address VARCHAR(255) NOT NULL,
  stop_latitude DECIMAL(10, 8) NULL,
  stop_longitude DECIMAL(11, 8) NULL,
  travel_minutes INT NOT NULL DEFAULT 0,
  service_minutes INT NOT NULL DEFAULT 0,
  estimated_distance_km DECIMAL(10, 2) NOT NULL DEFAULT 0,
  estimated_arrival_time DATETIME NULL,
  actual_arrival_time DATETIME NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  warning_text VARCHAR(500) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE,
  FOREIGN KEY (delivery_id) REFERENCES deliveries(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE emergency_deliveries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  location_address VARCHAR(255) NOT NULL,
  location_latitude DECIMAL(10, 8) NULL,
  location_longitude DECIMAL(11, 8) NULL,
  package_size ENUM('small', 'large') NOT NULL,
  requires_fridge BOOLEAN NOT NULL DEFAULT FALSE,
  package_weight_kg INT NOT NULL DEFAULT 10,
  priority_level ENUM('high', 'critical') NOT NULL DEFAULT 'high',
  status ENUM('pending', 'assigned', 'in_transit', 'delivered', 'failed') NOT NULL DEFAULT 'pending',
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

CREATE TABLE zone_travel_times (
  id INT AUTO_INCREMENT PRIMARY KEY,
  from_zone ENUM('warehouse', 'paris', 'suburb', 'hospital') NOT NULL,
  to_zone ENUM('warehouse', 'paris', 'suburb', 'hospital') NOT NULL,
  estimated_minutes INT NOT NULL,
  UNIQUE KEY unique_zone_pair (from_zone, to_zone)
) ENGINE=InnoDB;
