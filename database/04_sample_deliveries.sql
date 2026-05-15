-- RLA / MediRun sample deliveries, planned routes, emergency request,
-- and route simulation data.
-- Run after 03_insert_seed_data.sql.

USE medirun_db;

INSERT INTO deliveries
  (client_id, requested_at, delivery_date, priority, package_size, frozen_required, deadline_at, service_time_minutes, status, google_maps_distance_km, google_maps_eta_minutes, notes)
VALUES
  -- Morning delivery request queue for 2026-05-15.
  (2, '2026-05-15 06:45:00', '2026-05-15', 'urgent', 'large', TRUE, '2026-05-15 08:45:00', 15, 'assigned', 5.80, 24, 'Hospital delivery before 9 AM'),
  (3, '2026-05-15 06:50:00', '2026-05-15', 'urgent', 'small', FALSE, '2026-05-15 09:30:00', 10, 'assigned', 4.20, 18, 'Morning clinic delivery'),
  (7, '2026-05-15 07:00:00', '2026-05-15', 'normal', 'small', FALSE, '2026-05-15 11:00:00', 8, 'assigned', 2.10, 12, 'Pharmacy restock'),
  (8, '2026-05-15 07:05:00', '2026-05-15', 'normal', 'small', TRUE, '2026-05-15 11:30:00', 8, 'assigned', 2.80, 14, 'Frozen medicine'),
  (4, '2026-05-15 07:10:00', '2026-05-15', 'normal', 'large', FALSE, '2026-05-15 12:00:00', 12, 'assigned', 4.90, 20, 'Clinic supplies'),
  (11, '2026-05-15 07:15:00', '2026-05-15', 'normal', 'small', FALSE, '2026-05-15 12:30:00', 8, 'assigned', 8.10, 28, 'Suburb pharmacy'),
  (12, '2026-05-15 07:20:00', '2026-05-15', 'normal', 'large', FALSE, '2026-05-15 13:00:00', 12, 'assigned', 9.50, 32, 'Large pharmacy order'),
  (5, '2026-05-15 07:30:00', '2026-05-15', 'normal', 'small', FALSE, '2026-05-15 13:30:00', 10, 'pending', 7.70, 30, 'Waiting for CEO confirmation'),
  (9, '2026-05-15 07:35:00', '2026-05-15', 'normal', 'small', FALSE, '2026-05-15 14:00:00', 8, 'assigned', 3.20, 16, 'Assigned to small truck'),
  (13, '2026-05-15 07:40:00', '2026-05-15', 'normal', 'small', FALSE, '2026-05-15 14:30:00', 8, 'pending', 7.90, 29, 'Pending assignment'),
  (6, '2026-05-15 07:45:00', '2026-05-15', 'normal', 'large', TRUE, '2026-05-15 15:00:00', 12, 'pending', 10.20, 35, 'Frozen clinic shipment'),
  (10, '2026-05-15 07:50:00', '2026-05-15', 'normal', 'small', FALSE, '2026-05-15 15:30:00', 8, 'pending', 3.80, 18, 'Pending assignment'),

  -- Emergency request for real-time phase.
  (14, '2026-05-15 10:20:00', '2026-05-15', 'emergency', 'small', TRUE, '2026-05-15 11:15:00', 8, 'assigned', 8.70, 26, 'Emergency frozen medicine; add as next stop');

INSERT INTO routes
  (route_date, truck_id, driver_id, route_status, total_distance_km, estimated_total_minutes, current_stop_order, google_maps_polyline, last_recalculated_at)
VALUES
  ('2026-05-15', 1, 1, 'active', 12.40, 95, 1, NULL, '2026-05-15 08:10:00'),
  ('2026-05-15', 4, 3, 'planned', 22.10, 145, 0, NULL, '2026-05-15 08:15:00'),
  ('2026-05-15', 6, 5, 'needs_recalculation', 24.30, 158, 1, NULL, '2026-05-15 10:25:00');

UPDATE trucks
SET current_status = 'on_route'
WHERE id IN (1, 6);

UPDATE trucks
SET current_status = 'assigned'
WHERE id = 4;

UPDATE drivers
SET current_status = 'on_route', hours_worked = 2.25
WHERE id IN (1, 5);

UPDATE drivers
SET current_status = 'assigned', hours_worked = 1.00
WHERE id = 3;

INSERT INTO route_stops
  (route_id, delivery_id, stop_order, planned_arrival_at, status, is_next_stop)
VALUES
  (1, 2, 1, '2026-05-15 09:20:00', 'in_progress', TRUE),
  (1, 3, 2, '2026-05-15 10:10:00', 'assigned', FALSE),
  (1, 9, 3, '2026-05-15 11:00:00', 'assigned', FALSE),
  (2, 5, 1, '2026-05-15 10:30:00', 'assigned', FALSE),
  (2, 6, 2, '2026-05-15 11:45:00', 'assigned', FALSE),
  (2, 7, 3, '2026-05-15 12:40:00', 'assigned', FALSE),
  (3, 1, 1, '2026-05-15 08:35:00', 'assigned', FALSE),
  (3, 13, 2, '2026-05-15 11:05:00', 'assigned', TRUE),
  (3, 4, 3, '2026-05-15 12:10:00', 'assigned', FALSE);

INSERT INTO emergency_deliveries
  (delivery_id, emergency_status, nearest_truck_id, assigned_truck_id, assigned_driver_id, distance_to_assigned_truck_km, required_completion_minutes, decision_notes, created_at)
VALUES
  (13, 'assigned', 6, 6, 5, 3.40, 55, 'Fridge truck selected because emergency package requires frozen transport.', '2026-05-15 10:21:00');

INSERT INTO route_simulation
  (truck_id, route_id, simulated_at, latitude, longitude, speed_kmh, heading_degrees, current_stop_order)
VALUES
  (1, 1, '2026-05-15 10:20:00', 48.8685000, 2.3599000, 28.00, 45, 1),
  (4, 2, '2026-05-15 10:20:00', 48.8425000, 2.3300000, 24.00, 120, 0),
  (6, 3, '2026-05-15 10:20:00', 48.8270000, 2.2800000, 32.00, 90, 1);
