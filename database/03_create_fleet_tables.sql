-- MediRun fleet management tables
-- Run after 01_create_database.sql and 02_create_accounts.sql.

USE medirun_db;

DROP TABLE IF EXISTS cars;
DROP TABLE IF EXISTS drivers;

CREATE TABLE drivers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  license_number VARCHAR(50) UNIQUE NOT NULL,
  phone_number VARCHAR(25) NULL,
  status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE cars (
  id INT AUTO_INCREMENT PRIMARY KEY,
  plate_number VARCHAR(20) UNIQUE NOT NULL,
  model VARCHAR(100) NOT NULL,
  color VARCHAR(50) NULL,
  status ENUM('available', 'in_use', 'maintenance') NOT NULL DEFAULT 'available',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
