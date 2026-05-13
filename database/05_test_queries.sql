-- MediRun useful test queries
-- Run after all seed and sample delivery scripts.

USE medirun_db;

-- Change this date to test another day.
SET @selected_date = '2026-05-14';

-- Basic table checks
SELECT * FROM drivers;
SELECT * FROM vehicles;
SELECT * FROM clients;
SELECT * FROM deliveries;

-- Counts
SELECT COUNT(*) AS total_drivers FROM drivers;
SELECT COUNT(*) AS total_vehicles FROM vehicles;
SELECT COUNT(*) AS total_clients FROM clients;

SELECT
  @selected_date AS delivery_date,
  COUNT(*) AS total_deliveries
FROM deliveries
WHERE delivery_date = @selected_date;

SELECT
  @selected_date AS delivery_date,
  COUNT(*) AS urgent_deliveries
FROM deliveries
WHERE delivery_date = @selected_date
  AND priority = 'urgent';

SELECT
  @selected_date AS delivery_date,
  COUNT(*) AS refrigerated_deliveries
FROM deliveries
WHERE delivery_date = @selected_date
  AND refrigerated_required = TRUE;

-- Delivery planning view with client information
SELECT
  d.id,
  d.delivery_date,
  c.name AS client_name,
  c.client_type,
  c.zone,
  d.priority,
  d.deadline,
  d.package_size,
  d.refrigerated_required,
  d.service_time_minutes,
  d.status,
  d.is_emergency
FROM deliveries d
JOIN clients c ON c.id = d.client_id
WHERE d.delivery_date = @selected_date
ORDER BY
  FIELD(d.priority, 'urgent', 'normal', 'low'),
  d.deadline IS NULL,
  d.deadline,
  c.zone,
  c.name;

-- Operational summaries
SELECT status, COUNT(*) AS delivery_count
FROM deliveries
GROUP BY status
ORDER BY status;

SELECT priority, COUNT(*) AS delivery_count
FROM deliveries
GROUP BY priority
ORDER BY FIELD(priority, 'urgent', 'normal', 'low');
