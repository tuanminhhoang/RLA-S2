-- Link accounts to driver records
-- Run after 01_create_database.sql through 03_create_fleet_tables.sql

USE medirun_db;

-- Add driver_id to accounts so accounts can map to drivers table
ALTER TABLE accounts
ADD COLUMN driver_id INT NULL AFTER status;

-- Add foreign key if not exists (safe to run repeatedly in dev)
ALTER TABLE accounts
ADD CONSTRAINT fk_accounts_driver_id FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE SET NULL;

-- Optional: set some example mappings for seed accounts if drivers exist
-- UPDATE accounts a JOIN drivers d ON a.username = d.full_name SET a.driver_id = d.id;
