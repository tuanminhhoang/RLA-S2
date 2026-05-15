-- RLA / MediRun table creation script
-- Run after 01_create_database.sql.
-- This schema follows docs/WORKFLOW.md and docs/WORKFLOW.html:
-- morning assignment, truck filtering, driver hours, route stops,
-- emergency handling, and simple route simulation.

USE medirun_db;

-- Drop child tables first to keep foreign key constraints valid.
DROP TABLE IF EXISTS route_simulation;
DROP TABLE IF EXISTS emergency_deliveries;
DROP TABLE IF EXISTS route_stops;
DROP TABLE IF EXISTS routes;
DROP TABLE IF EXISTS deliveries;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS trucks;

CREATE TABLE trucks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  truck_size ENUM('small', 'large') NOT NULL,
  fridge_capable BOOLEAN DEFAULT FALSE,
  max_stops INT NOT NULL,
  range_km INT NOT NULL,
  current_status ENUM('available', 'assigned', 'on_route', 'returning', 'maintenance') DEFAULT 'available',
  current_location_label VARCHAR(100) DEFAULT 'Warehouse',
  current_lat DECIMAL(10, 7) NULL,
  current_lng DECIMAL(10, 7) NULL
) ENGINE=InnoDB;

CREATE TABLE drivers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  shift_start TIME NOT NULL,
  shift_end TIME NOT NULL,
  max_hours DECIMAL(4, 2) NOT NULL DEFAULT 8.00,
  hours_worked DECIMAL(4, 2) NOT NULL DEFAULT 0.00,
  current_status ENUM('available', 'assigned', 'on_route', 'returning', 'off_shift') DEFAULT 'available',
  current_location_label VARCHAR(100) DEFAULT 'Warehouse',
  current_lat DECIMAL(10, 7) NULL,
  current_lng DECIMAL(10, 7) NULL,
  assigned_truck_id INT NULL,
  CONSTRAINT fk_drivers_assigned_truck
    FOREIGN KEY (assigned_truck_id) REFERENCES trucks(id)
) ENGINE=InnoDB;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(100) NOT NULL,
  role ENUM('ceo', 'driver') NOT NULL,
  driver_id INT NULL,
  CONSTRAINT fk_users_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(id)
) ENGINE=InnoDB;

CREATE TABLE clients (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  client_type ENUM('hospital', 'clinic', 'pharmacy', 'warehouse') NOT NULL,
  address VARCHAR(255) NOT NULL,
  zone ENUM('Warehouse', 'Paris', 'Suburb', 'Hospital') NOT NULL,
  latitude DECIMAL(10, 7) NULL,
  longitude DECIMAL(10, 7) NULL,
  preferred_time_window VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE deliveries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  client_id INT NOT NULL,
  requested_at DATETIME NOT NULL,
  delivery_date DATE NOT NULL,
  priority ENUM('normal', 'urgent', 'emergency') NOT NULL DEFAULT 'normal',
  package_size ENUM('small', 'large') NOT NULL,
  frozen_required BOOLEAN DEFAULT FALSE,
  deadline_at DATETIME NULL,
  service_time_minutes INT DEFAULT 10,
  status ENUM('pending', 'assigned', 'in_progress', 'delivered', 'delayed', 'failed') DEFAULT 'pending',
  google_maps_distance_km DECIMAL(6, 2) NULL,
  google_maps_eta_minutes INT NULL,
  notes VARCHAR(255) NULL,
  CONSTRAINT fk_deliveries_client
    FOREIGN KEY (client_id) REFERENCES clients(id)
) ENGINE=InnoDB;

CREATE TABLE routes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  route_date DATE NOT NULL,
  truck_id INT NOT NULL,
  driver_id INT NOT NULL,
  route_status ENUM('planned', 'active', 'completed', 'needs_recalculation', 'cancelled') DEFAULT 'planned',
  start_location_label VARCHAR(100) DEFAULT 'Warehouse',
  total_distance_km DECIMAL(7, 2) DEFAULT 0.00,
  estimated_total_minutes INT DEFAULT 0,
  current_stop_order INT DEFAULT 0,
  google_maps_polyline TEXT NULL,
  last_recalculated_at DATETIME NULL,
  CONSTRAINT fk_routes_truck
    FOREIGN KEY (truck_id) REFERENCES trucks(id),
  CONSTRAINT fk_routes_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(id)
) ENGINE=InnoDB;

CREATE TABLE route_stops (
  id INT AUTO_INCREMENT PRIMARY KEY,
  route_id INT NOT NULL,
  delivery_id INT NOT NULL,
  stop_order INT NOT NULL,
  planned_arrival_at DATETIME NULL,
  actual_arrival_at DATETIME NULL,
  status ENUM('assigned', 'in_progress', 'delivered', 'delayed', 'failed') DEFAULT 'assigned',
  is_next_stop BOOLEAN DEFAULT FALSE,
  delay_reason VARCHAR(255) NULL,
  CONSTRAINT fk_route_stops_route
    FOREIGN KEY (route_id) REFERENCES routes(id),
  CONSTRAINT fk_route_stops_delivery
    FOREIGN KEY (delivery_id) REFERENCES deliveries(id),
  CONSTRAINT uq_route_stop_order UNIQUE (route_id, stop_order),
  CONSTRAINT uq_route_delivery UNIQUE (delivery_id)
) ENGINE=InnoDB;

CREATE TABLE emergency_deliveries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  delivery_id INT NOT NULL UNIQUE,
  emergency_status ENUM('new', 'evaluating_trucks', 'assigned', 'resolved', 'failed') DEFAULT 'new',
  nearest_truck_id INT NULL,
  assigned_truck_id INT NULL,
  assigned_driver_id INT NULL,
  distance_to_assigned_truck_km DECIMAL(6, 2) NULL,
  required_completion_minutes INT NULL,
  decision_notes TEXT NULL,
  created_at DATETIME NOT NULL,
  resolved_at DATETIME NULL,
  CONSTRAINT fk_emergency_deliveries_delivery
    FOREIGN KEY (delivery_id) REFERENCES deliveries(id),
  CONSTRAINT fk_emergency_deliveries_nearest_truck
    FOREIGN KEY (nearest_truck_id) REFERENCES trucks(id),
  CONSTRAINT fk_emergency_deliveries_assigned_truck
    FOREIGN KEY (assigned_truck_id) REFERENCES trucks(id),
  CONSTRAINT fk_emergency_deliveries_assigned_driver
    FOREIGN KEY (assigned_driver_id) REFERENCES drivers(id)
) ENGINE=InnoDB;

CREATE TABLE route_simulation (
  id INT AUTO_INCREMENT PRIMARY KEY,
  truck_id INT NOT NULL,
  route_id INT NULL,
  simulated_at DATETIME NOT NULL,
  latitude DECIMAL(10, 7) NOT NULL,
  longitude DECIMAL(10, 7) NOT NULL,
  speed_kmh DECIMAL(5, 2) NOT NULL,
  heading_degrees INT NULL,
  current_stop_order INT DEFAULT 0,
  CONSTRAINT fk_route_simulation_truck
    FOREIGN KEY (truck_id) REFERENCES trucks(id),
  CONSTRAINT fk_route_simulation_route
    FOREIGN KEY (route_id) REFERENCES routes(id)
) ENGINE=InnoDB;
