-- MediRun table creation script
-- Run after 01_create_database.sql.

USE medirun_db;

-- Drop child tables first to keep foreign key constraints valid.
DROP TABLE IF EXISTS route_stops;
DROP TABLE IF EXISTS routes;
DROP TABLE IF EXISTS daily_vehicle_assignments;
DROP TABLE IF EXISTS deliveries;
DROP TABLE IF EXISTS zone_travel_times;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS vehicles;
DROP TABLE IF EXISTS drivers;

CREATE TABLE drivers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  shift_start TIME NOT NULL,
  shift_end TIME NOT NULL,
  max_hours INT NOT NULL,
  available BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE vehicles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  vehicle_type ENUM('small_van', 'large_van', 'refrigerated') NOT NULL,
  capacity_stops INT NOT NULL,
  range_km INT NOT NULL,
  best_zone VARCHAR(50) NOT NULL,
  refrigerated BOOLEAN DEFAULT FALSE,
  available BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(100) NOT NULL,
  role ENUM('admin', 'driver') NOT NULL,
  driver_id INT NULL,
  CONSTRAINT fk_users_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(id)
) ENGINE=InnoDB;

CREATE TABLE clients (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  client_type ENUM('hospital', 'clinic', 'pharmacy') NOT NULL,
  zone ENUM('Warehouse', 'Paris', 'Suburb', 'Hospital') NOT NULL,
  preferred_time_window VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE deliveries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  client_id INT NOT NULL,
  delivery_date DATE NOT NULL,
  priority ENUM('urgent', 'normal', 'low') NOT NULL,
  deadline TIME NULL,
  package_size ENUM('small', 'medium', 'large') NOT NULL,
  refrigerated_required BOOLEAN DEFAULT FALSE,
  service_time_minutes INT DEFAULT 10,
  status ENUM('pending', 'assigned', 'in_progress', 'delivered', 'delayed', 'failed') DEFAULT 'pending',
  is_emergency BOOLEAN DEFAULT FALSE,
  CONSTRAINT fk_deliveries_client
    FOREIGN KEY (client_id) REFERENCES clients(id)
) ENGINE=InnoDB;

CREATE TABLE daily_vehicle_assignments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  assignment_date DATE NOT NULL,
  driver_id INT NOT NULL,
  vehicle_id INT NOT NULL,
  CONSTRAINT fk_daily_vehicle_assignments_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(id),
  CONSTRAINT fk_daily_vehicle_assignments_vehicle
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
) ENGINE=InnoDB;

CREATE TABLE routes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  route_date DATE NOT NULL,
  driver_id INT NOT NULL,
  vehicle_id INT NOT NULL,
  estimated_total_minutes INT DEFAULT 0,
  status ENUM('valid', 'warning', 'invalid') DEFAULT 'valid',
  warning TEXT NULL,
  CONSTRAINT fk_routes_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(id),
  CONSTRAINT fk_routes_vehicle
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
) ENGINE=InnoDB;

CREATE TABLE route_stops (
  id INT AUTO_INCREMENT PRIMARY KEY,
  route_id INT NOT NULL,
  delivery_id INT NOT NULL,
  stop_order INT NOT NULL,
  estimated_arrival_time TIME NULL,
  status ENUM('assigned', 'in_progress', 'delivered', 'delayed', 'failed') DEFAULT 'assigned',
  delay_reason VARCHAR(255) NULL,
  CONSTRAINT fk_route_stops_route
    FOREIGN KEY (route_id) REFERENCES routes(id),
  CONSTRAINT fk_route_stops_delivery
    FOREIGN KEY (delivery_id) REFERENCES deliveries(id)
) ENGINE=InnoDB;

CREATE TABLE zone_travel_times (
  id INT AUTO_INCREMENT PRIMARY KEY,
  from_zone ENUM('Warehouse', 'Paris', 'Suburb', 'Hospital') NOT NULL,
  to_zone ENUM('Warehouse', 'Paris', 'Suburb', 'Hospital') NOT NULL,
  estimated_minutes INT NOT NULL
) ENGINE=InnoDB;
