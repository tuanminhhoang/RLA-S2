-- MediRun Seed Data
-- Run after all database tables are created.
-- This creates a realistic demo week based on TO-DO.md:
-- 35 regular locations, 5 drivers, 6 vehicles, busy Monday, normal weekdays.

USE medirun_db;

SET @week_monday = DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY);

INSERT INTO accounts (id, username, password, status) VALUES
(1, 'manager_demo', 'demo', 'ceo'),
(2, 'driver1', 'demo', 'driver'),
(3, 'driver2', 'demo', 'driver'),
(4, 'driver3', 'demo', 'driver'),
(5, 'driver4', 'demo', 'driver'),
(6, 'driver5', 'demo', 'driver');

INSERT INTO drivers (id, account_id, full_name, license_number, phone_number, status) VALUES
(1, 2, 'Driver 1', 'MED-DRV-001', '+33 6 10 00 00 01', 'active'),
(2, 3, 'Driver 2', 'MED-DRV-002', '+33 6 10 00 00 02', 'active'),
(3, 4, 'Driver 3', 'MED-DRV-003', '+33 6 10 00 00 03', 'active'),
(4, 5, 'Driver 4', 'MED-DRV-004', '+33 6 10 00 00 04', 'active'),
(5, 6, 'Driver 5', 'MED-DRV-005', '+33 6 10 00 00 05', 'active');

INSERT INTO cars
(id, plate_number, model, color, size, has_fridge, capacity_kg, current_latitude, current_longitude, status)
VALUES
(1, 'MR-001', 'Renault Kangoo', 'White', 'small', FALSE, 80, 48.8566, 2.3522, 'available'),
(2, 'MR-002', 'Peugeot Partner', 'White', 'small', FALSE, 80, 48.8566, 2.3522, 'available'),
(3, 'MR-003', 'Citroen Berlingo', 'Blue', 'small', FALSE, 75, 48.8566, 2.3522, 'available'),
(4, 'MR-004', 'Renault Master', 'White', 'large', FALSE, 220, 48.8566, 2.3522, 'available'),
(5, 'MR-005', 'Mercedes Sprinter', 'Grey', 'large', FALSE, 240, 48.8566, 2.3522, 'available'),
(6, 'MR-006', 'Renault Kangoo Frigo', 'White', 'small', TRUE, 90, 48.8566, 2.3522, 'available');

-- 35 regular delivery locations:
-- 1 hospital, 6 clinics/medical centers, 15 Paris pharmacies, 13 inner-suburb pharmacies.
INSERT INTO clients (id, name, client_type, zone, address) VALUES
(1, 'Central Hospital', 'hospital', 'hospital', '47 Boulevard de l Hopital, 75013 Paris'),
(2, 'Clinique Montparnasse', 'clinic', 'paris', '26 Rue du Montparnasse, 75014 Paris'),
(3, 'Clinique Bastille', 'clinic', 'paris', '12 Rue de la Roquette, 75011 Paris'),
(4, 'Medical Center Belleville', 'clinic', 'paris', '8 Rue de Belleville, 75020 Paris'),
(5, 'Clinique Saint-Lazare', 'clinic', 'paris', '15 Rue Saint-Lazare, 75009 Paris'),
(6, 'Clinique Neuilly', 'clinic', 'suburb', '4 Avenue Charles de Gaulle, 92200 Neuilly-sur-Seine'),
(7, 'Clinique Vincennes', 'clinic', 'suburb', '22 Avenue de Paris, 94300 Vincennes'),
(8, 'Pharmacy Paris 01', 'pharmacy', 'paris', '10 Rue de Rivoli, 75001 Paris'),
(9, 'Pharmacy Paris 02', 'pharmacy', 'paris', '18 Rue Vivienne, 75002 Paris'),
(10, 'Pharmacy Paris 03', 'pharmacy', 'paris', '7 Rue de Bretagne, 75003 Paris'),
(11, 'Pharmacy Paris 04', 'pharmacy', 'paris', '22 Rue Saint-Antoine, 75004 Paris'),
(12, 'Pharmacy Paris 05', 'pharmacy', 'paris', '18 Rue Monge, 75005 Paris'),
(13, 'Pharmacy Paris 06', 'pharmacy', 'paris', '9 Rue de Rennes, 75006 Paris'),
(14, 'Pharmacy Paris 07', 'pharmacy', 'paris', '82 Rue de Grenelle, 75007 Paris'),
(15, 'Pharmacy Paris 08', 'pharmacy', 'paris', '34 Avenue des Champs-Elysees, 75008 Paris'),
(16, 'Pharmacy Paris 09', 'pharmacy', 'paris', '15 Rue Saint-Lazare, 75009 Paris'),
(17, 'Pharmacy Paris 10', 'pharmacy', 'paris', '3 Rue de Magenta, 75010 Paris'),
(18, 'Pharmacy Paris 11', 'pharmacy', 'paris', '12 Rue Oberkampf, 75011 Paris'),
(19, 'Pharmacy Paris 12', 'pharmacy', 'paris', '44 Avenue Daumesnil, 75012 Paris'),
(20, 'Pharmacy Paris 15', 'pharmacy', 'paris', '90 Rue de Vaugirard, 75015 Paris'),
(21, 'Pharmacy Paris 17', 'pharmacy', 'paris', '6 Rue de Courcelles, 75017 Paris'),
(22, 'Pharmacy Paris 18', 'pharmacy', 'paris', '19 Rue Ordener, 75018 Paris'),
(23, 'Pharmacy Boulogne A', 'pharmacy', 'suburb', '3 Rue Jean Jaures, 92100 Boulogne-Billancourt'),
(24, 'Pharmacy Boulogne B', 'pharmacy', 'suburb', '55 Route de la Reine, 92100 Boulogne-Billancourt'),
(25, 'Pharmacy Saint-Denis', 'pharmacy', 'suburb', '9 Rue de Paris, 93200 Saint-Denis'),
(26, 'Pharmacy Montreuil', 'pharmacy', 'suburb', '14 Rue de Vincennes, 93100 Montreuil'),
(27, 'Pharmacy Ivry', 'pharmacy', 'suburb', '31 Avenue Georges Gosnat, 94200 Ivry-sur-Seine'),
(28, 'Pharmacy Clichy', 'pharmacy', 'suburb', '20 Boulevard Jean Jaures, 92110 Clichy'),
(29, 'Pharmacy Levallois', 'pharmacy', 'suburb', '41 Rue de la Gare, 92300 Levallois-Perret'),
(30, 'Pharmacy Courbevoie', 'pharmacy', 'suburb', '6 Avenue Marceau, 92400 Courbevoie'),
(31, 'Pharmacy Nanterre', 'pharmacy', 'suburb', '21 Rue Gabriel Peri, 92000 Nanterre'),
(32, 'Pharmacy Aubervilliers', 'pharmacy', 'suburb', '5 Avenue Victor Hugo, 93300 Aubervilliers'),
(33, 'Pharmacy Charenton', 'pharmacy', 'suburb', '28 Rue de Paris, 94220 Charenton-le-Pont'),
(34, 'Pharmacy Montrouge', 'pharmacy', 'suburb', '11 Avenue de la Republique, 92120 Montrouge'),
(35, 'Pharmacy Pantin', 'pharmacy', 'suburb', '17 Avenue Jean Lolive, 93500 Pantin');

INSERT INTO zone_travel_times (from_zone, to_zone, estimated_minutes) VALUES
('warehouse', 'warehouse', 0),
('warehouse', 'paris', 30),
('warehouse', 'suburb', 35),
('warehouse', 'hospital', 25),
('paris', 'warehouse', 30),
('paris', 'paris', 20),
('paris', 'suburb', 40),
('paris', 'hospital', 20),
('suburb', 'warehouse', 25),
('suburb', 'paris', 40),
('suburb', 'suburb', 30),
('suburb', 'hospital', 35),
('hospital', 'warehouse', 25),
('hospital', 'paris', 20),
('hospital', 'suburb', 35),
('hospital', 'hospital', 10);

CREATE TEMPORARY TABLE demo_numbers (n INT PRIMARY KEY);

INSERT INTO demo_numbers (n) VALUES
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),
(11),(12),(13),(14),(15),(16),(17),(18),(19),(20),
(21),(22),(23),(24),(25),(26),(27),(28),(29),(30),
(31),(32),(33),(34),(35),(36),(37),(38),(39),(40),
(41),(42),(43),(44),(45),(46),(47),(48),(49),(50),
(51),(52),(53),(54),(55),(56),(57),(58),(59),(60);

-- Monday: very busy morning, 60 deliveries.
INSERT INTO deliveries
(client_id, pickup_address, delivery_address, zone, delivery_date, priority, deadline,
 package_size, requires_fridge, package_weight_kg, service_time_minutes, emergency,
 status, distance_km, estimated_duration_minutes, notes)
SELECT
  c.id,
  'MediRun Warehouse',
  c.address,
  c.zone,
  @week_monday,
  CASE
    WHEN c.client_type = 'hospital' OR n.n IN (2, 3, 11, 23, 37, 52, 58, 59, 60) THEN 'urgent'
    WHEN MOD(n.n, 5) = 0 THEN 'low'
    ELSE 'normal'
  END,
  TIMESTAMP(
    @week_monday,
    CASE
      WHEN c.client_type = 'hospital' THEN '09:00:00'
      WHEN n.n IN (2, 3, 11, 23, 37, 52, 58, 59, 60) THEN '10:30:00'
      WHEN MOD(n.n, 5) = 0 THEN '17:30:00'
      ELSE '14:30:00'
    END
  ),
  CASE WHEN (c.zone = 'suburb' AND MOD(n.n, 4) = 0) OR (c.client_type = 'clinic' AND MOD(n.n, 3) = 0) THEN 'large' ELSE 'small' END,
  CASE WHEN c.client_type = 'hospital' OR MOD(n.n, 7) = 0 OR n.n IN (11, 19, 27, 43, 58, 59) THEN TRUE ELSE FALSE END,
  CASE WHEN (c.zone = 'suburb' AND MOD(n.n, 4) = 0) THEN 45 WHEN c.client_type = 'clinic' THEN 18 ELSE 6 + MOD(n.n, 8) END,
  CASE WHEN c.client_type = 'hospital' THEN 15 WHEN (c.zone = 'suburb' AND MOD(n.n, 4) = 0) THEN 15 ELSE 8 + MOD(n.n, 5) END,
  CASE WHEN n.n IN (58, 59, 60) THEN TRUE ELSE FALSE END,
  'pending',
  CASE WHEN c.zone = 'hospital' THEN 7.0 WHEN c.zone = 'paris' THEN 4.0 + MOD(n.n, 8) WHEN c.zone = 'suburb' THEN 9.0 + MOD(n.n, 7) ELSE 0 END,
  CASE WHEN c.zone = 'hospital' THEN 25 WHEN c.zone = 'paris' THEN 30 WHEN c.zone = 'suburb' THEN 40 ELSE 0 END,
  CASE WHEN n.n IN (58, 59, 60) THEN 'Monday emergency delivery added during morning planning.' ELSE NULL END
FROM demo_numbers n
JOIN clients c ON c.id = 1 + MOD(n.n - 1, 35)
WHERE n.n <= 60;

-- Tuesday to Friday: normal operating days, 45-50 deliveries.
INSERT INTO deliveries
(client_id, pickup_address, delivery_address, zone, delivery_date, priority, deadline,
 package_size, requires_fridge, package_weight_kg, service_time_minutes, emergency,
 status, distance_km, estimated_duration_minutes, notes)
SELECT
  c.id,
  'MediRun Warehouse',
  c.address,
  c.zone,
  DATE_ADD(@week_monday, INTERVAL d.day_offset DAY),
  CASE
    WHEN c.client_type = 'hospital' OR MOD(n.n + d.day_offset, 13) = 0 THEN 'urgent'
    WHEN MOD(n.n + d.day_offset, 6) = 0 THEN 'low'
    ELSE 'normal'
  END,
  TIMESTAMP(
    DATE_ADD(@week_monday, INTERVAL d.day_offset DAY),
    CASE
      WHEN c.client_type = 'hospital' THEN '09:00:00'
      WHEN MOD(n.n + d.day_offset, 13) = 0 THEN '11:00:00'
      WHEN MOD(n.n + d.day_offset, 6) = 0 THEN '17:00:00'
      ELSE '15:00:00'
    END
  ),
  CASE WHEN (c.zone = 'suburb' AND MOD(n.n, 4) = 0) OR (c.client_type = 'clinic' AND MOD(n.n, 4) = 0) THEN 'large' ELSE 'small' END,
  CASE WHEN c.client_type = 'hospital' OR MOD(n.n + d.day_offset, 8) = 0 THEN TRUE ELSE FALSE END,
  CASE WHEN (c.zone = 'suburb' AND MOD(n.n, 4) = 0) THEN 42 WHEN c.client_type = 'clinic' THEN 16 ELSE 5 + MOD(n.n, 9) END,
  CASE WHEN c.client_type = 'hospital' THEN 15 WHEN (c.zone = 'suburb' AND MOD(n.n, 4) = 0) THEN 15 ELSE 8 + MOD(n.n, 5) END,
  CASE WHEN d.day_offset = 3 AND n.n = d.delivery_count THEN TRUE ELSE FALSE END,
  'pending',
  CASE WHEN c.zone = 'hospital' THEN 7.0 WHEN c.zone = 'paris' THEN 4.0 + MOD(n.n, 8) WHEN c.zone = 'suburb' THEN 9.0 + MOD(n.n, 7) ELSE 0 END,
  CASE WHEN c.zone = 'hospital' THEN 25 WHEN c.zone = 'paris' THEN 30 WHEN c.zone = 'suburb' THEN 40 ELSE 0 END,
  CASE WHEN d.day_offset = 3 AND n.n = d.delivery_count THEN 'Emergency delivery added during the day.' ELSE NULL END
FROM (
  SELECT 1 AS day_offset, 48 AS delivery_count
  UNION ALL SELECT 2, 46
  UNION ALL SELECT 3, 50
  UNION ALL SELECT 4, 45
) d
JOIN demo_numbers n ON n.n <= d.delivery_count
JOIN clients c ON c.id = 1 + MOD((n.n + (d.day_offset * 7)) - 1, 35);

-- Saturday: light catch-up schedule for the weekly demo.
INSERT INTO deliveries
(client_id, pickup_address, delivery_address, zone, delivery_date, priority, deadline,
 package_size, requires_fridge, package_weight_kg, service_time_minutes, emergency,
 status, distance_km, estimated_duration_minutes, notes)
SELECT
  c.id,
  'MediRun Warehouse',
  c.address,
  c.zone,
  DATE_ADD(@week_monday, INTERVAL 5 DAY),
  CASE WHEN c.client_type = 'hospital' THEN 'urgent' WHEN MOD(n.n, 5) = 0 THEN 'low' ELSE 'normal' END,
  TIMESTAMP(DATE_ADD(@week_monday, INTERVAL 5 DAY), CASE WHEN c.client_type = 'hospital' THEN '09:30:00' ELSE '13:00:00' END),
  CASE WHEN c.zone = 'suburb' AND MOD(n.n, 4) = 0 THEN 'large' ELSE 'small' END,
  CASE WHEN c.client_type = 'hospital' OR MOD(n.n, 6) = 0 THEN TRUE ELSE FALSE END,
  CASE WHEN c.zone = 'suburb' AND MOD(n.n, 4) = 0 THEN 40 ELSE 7 + MOD(n.n, 6) END,
  CASE WHEN c.client_type = 'hospital' THEN 15 ELSE 8 + MOD(n.n, 4) END,
  FALSE,
  'pending',
  CASE WHEN c.zone = 'hospital' THEN 7.0 WHEN c.zone = 'paris' THEN 4.0 + MOD(n.n, 8) WHEN c.zone = 'suburb' THEN 9.0 + MOD(n.n, 7) ELSE 0 END,
  CASE WHEN c.zone = 'hospital' THEN 25 WHEN c.zone = 'paris' THEN 30 WHEN c.zone = 'suburb' THEN 40 ELSE 0 END,
  'Saturday light catch-up schedule.'
FROM demo_numbers n
JOIN clients c ON c.id = 1 + MOD(n.n - 1, 35)
WHERE n.n <= 24;

-- Driver hours for the full demo week.
INSERT INTO driver_daily_hours (driver_id, work_date, hours_worked, hours_remaining, status)
SELECT d.id, DATE_ADD(@week_monday, INTERVAL days.day_offset DAY), 0, 8, 'active'
FROM drivers d
JOIN (
  SELECT 0 AS day_offset UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL
  SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
) days;

INSERT INTO position_history (truck_id, driver_id, latitude, longitude) VALUES
(1, 1, 48.8566, 2.3522),
(2, 2, 48.8566, 2.3522),
(3, 3, 48.8566, 2.3522),
(4, 4, 48.8566, 2.3522),
(5, 5, 48.8566, 2.3522),
(6, 1, 48.8566, 2.3522);

DROP TEMPORARY TABLE demo_numbers;
