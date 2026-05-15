-- RLA / MediRun useful test queries
-- Run after all seed and sample scripts.

USE medirun_db;

SET @selected_date = '2026-05-15';

-- Basic checks
SELECT * FROM trucks;
SELECT * FROM drivers;
SELECT * FROM clients;
SELECT * FROM deliveries;

-- Workflow counts
SELECT COUNT(*) AS total_trucks FROM trucks;
SELECT COUNT(*) AS total_drivers FROM drivers;
SELECT COUNT(*) AS pending_delivery_requests
FROM deliveries
WHERE delivery_date = @selected_date
  AND status = 'pending';

SELECT COUNT(*) AS assigned_deliveries
FROM deliveries
WHERE delivery_date = @selected_date
  AND status = 'assigned';

SELECT COUNT(*) AS frozen_deliveries
FROM deliveries
WHERE delivery_date = @selected_date
  AND frozen_required = TRUE;

SELECT COUNT(*) AS emergency_deliveries
FROM deliveries
WHERE delivery_date = @selected_date
  AND priority = 'emergency';

-- CEO morning assignment queue
SELECT
  d.id,
  d.delivery_date,
  c.name AS client_name,
  c.address,
  c.zone,
  d.priority,
  d.package_size,
  d.frozen_required,
  d.deadline_at,
  d.status,
  d.google_maps_distance_km,
  d.google_maps_eta_minutes
FROM deliveries d
JOIN clients c ON c.id = d.client_id
WHERE d.delivery_date = @selected_date
ORDER BY
  FIELD(d.priority, 'emergency', 'urgent', 'normal'),
  d.deadline_at;

-- Trucks suitable for a frozen emergency package
SELECT *
FROM trucks
WHERE fridge_capable = TRUE
  AND current_status IN ('available', 'assigned', 'on_route');

-- Driver hours remaining
SELECT
  id,
  name,
  max_hours,
  hours_worked,
  max_hours - hours_worked AS hours_remaining,
  current_status,
  assigned_truck_id
FROM drivers
ORDER BY id;

-- Route with stops and ETAs
SELECT
  r.id AS route_id,
  r.route_date,
  t.name AS truck_name,
  dr.name AS driver_name,
  rs.stop_order,
  rs.planned_arrival_at,
  c.name AS client_name,
  d.priority,
  d.package_size,
  d.frozen_required,
  rs.status,
  rs.is_next_stop
FROM routes r
JOIN trucks t ON t.id = r.truck_id
JOIN drivers dr ON dr.id = r.driver_id
JOIN route_stops rs ON rs.route_id = r.id
JOIN deliveries d ON d.id = rs.delivery_id
JOIN clients c ON c.id = d.client_id
WHERE r.route_date = @selected_date
ORDER BY r.id, rs.stop_order;

-- Emergency assignment tracking
SELECT
  e.id,
  e.created_at,
  e.emergency_status,
  d.id AS delivery_id,
  c.name AS emergency_client,
  nearest.name AS nearest_truck,
  assigned.name AS assigned_truck,
  dr.name AS assigned_driver,
  e.distance_to_assigned_truck_km,
  e.decision_notes
FROM emergency_deliveries e
JOIN deliveries d ON d.id = e.delivery_id
JOIN clients c ON c.id = d.client_id
LEFT JOIN trucks nearest ON nearest.id = e.nearest_truck_id
LEFT JOIN trucks assigned ON assigned.id = e.assigned_truck_id
LEFT JOIN drivers dr ON dr.id = e.assigned_driver_id;

-- Latest simulated truck positions
SELECT
  s.truck_id,
  t.name AS truck_name,
  s.route_id,
  s.simulated_at,
  s.latitude,
  s.longitude,
  s.speed_kmh,
  s.current_stop_order
FROM route_simulation s
JOIN trucks t ON t.id = s.truck_id
ORDER BY s.simulated_at DESC, s.truck_id;
