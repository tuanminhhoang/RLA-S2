-- MediRun seed data
-- Run after 02_create_tables.sql.

USE medirun_db;

INSERT INTO drivers (name, shift_start, shift_end, max_hours, available) VALUES
  ('Driver 1', '07:00:00', '15:00:00', 8, TRUE),
  ('Driver 2', '07:30:00', '15:30:00', 8, TRUE),
  ('Driver 3', '08:00:00', '16:00:00', 8, TRUE),
  ('Driver 4', '08:30:00', '16:30:00', 8, TRUE),
  ('Driver 5', '09:00:00', '17:00:00', 8, TRUE);

INSERT INTO vehicles (name, vehicle_type, capacity_stops, range_km, best_zone, refrigerated, available) VALUES
  ('Small Van 1', 'small_van', 10, 180, 'Paris', FALSE, TRUE),
  ('Small Van 2', 'small_van', 10, 180, 'Paris', FALSE, TRUE),
  ('Small Van 3', 'small_van', 10, 180, 'Suburb', FALSE, TRUE),
  ('Large Van 1', 'large_van', 14, 260, 'Suburb', FALSE, TRUE),
  ('Large Van 2', 'large_van', 14, 260, 'Paris', FALSE, TRUE),
  ('Refrigerated Van', 'refrigerated', 12, 220, 'Hospital', TRUE, TRUE);

INSERT INTO users (username, password, role, driver_id) VALUES
  ('admin', 'admin123', 'admin', NULL),
  ('driver1', 'driver123', 'driver', 1),
  ('driver2', 'driver123', 'driver', 2),
  ('driver3', 'driver123', 'driver', 3),
  ('driver4', 'driver123', 'driver', 4),
  ('driver5', 'driver123', 'driver', 5);

INSERT INTO clients (name, client_type, zone, preferred_time_window) VALUES
  ('Saint-Louis Hospital', 'hospital', 'Hospital', '07:30-09:00'),
  ('Clinique Montparnasse', 'clinic', 'Paris', '09:00-12:00'),
  ('Clinique Bastille', 'clinic', 'Paris', '09:00-12:00'),
  ('Clinique Neuilly Sante', 'clinic', 'Suburb', '10:00-13:00'),
  ('Clinique Boulogne Medicale', 'clinic', 'Suburb', '10:00-13:00'),
  ('Clinique Vincennes Est', 'clinic', 'Suburb', '10:00-13:00'),
  ('Clinique Saint-Denis Nord', 'clinic', 'Suburb', '10:00-13:00'),
  ('Pharmacie Rivoli', 'pharmacy', 'Paris', '09:00-13:00'),
  ('Pharmacie Opera', 'pharmacy', 'Paris', '09:00-13:00'),
  ('Pharmacie Republique', 'pharmacy', 'Paris', '09:00-13:00'),
  ('Pharmacie Voltaire', 'pharmacy', 'Paris', '09:00-13:00'),
  ('Pharmacie Italie 13', 'pharmacy', 'Paris', '10:00-14:00'),
  ('Pharmacie Grenelle', 'pharmacy', 'Paris', '10:00-14:00'),
  ('Pharmacie Ternes', 'pharmacy', 'Paris', '10:00-14:00'),
  ('Pharmacie Belleville', 'pharmacy', 'Paris', '10:00-14:00'),
  ('Pharmacie Nation', 'pharmacy', 'Paris', '11:00-15:00'),
  ('Pharmacie Convention', 'pharmacy', 'Paris', '11:00-15:00'),
  ('Pharmacie Auteuil', 'pharmacy', 'Paris', '11:00-15:00'),
  ('Pharmacie Luxembourg', 'pharmacy', 'Paris', '11:00-15:00'),
  ('Pharmacie Passy', 'pharmacy', 'Paris', '12:00-16:00'),
  ('Pharmacie Jourdain', 'pharmacy', 'Paris', '12:00-16:00'),
  ('Pharmacie Montmartre', 'pharmacy', 'Paris', '12:00-16:00'),
  ('Pharmacie Levallois Centre', 'pharmacy', 'Suburb', '09:30-13:30'),
  ('Pharmacie Boulogne Republique', 'pharmacy', 'Suburb', '09:30-13:30'),
  ('Pharmacie Issy Corentin', 'pharmacy', 'Suburb', '09:30-13:30'),
  ('Pharmacie Montrouge Mairie', 'pharmacy', 'Suburb', '10:00-14:00'),
  ('Pharmacie Ivry Port', 'pharmacy', 'Suburb', '10:00-14:00'),
  ('Pharmacie Saint-Ouen Garibaldi', 'pharmacy', 'Suburb', '10:00-14:00'),
  ('Pharmacie Pantin Eglise', 'pharmacy', 'Suburb', '10:30-14:30'),
  ('Pharmacie Vincennes Chateau', 'pharmacy', 'Suburb', '10:30-14:30'),
  ('Pharmacie Clichy Mairie', 'pharmacy', 'Suburb', '11:00-15:00'),
  ('Pharmacie Montreuil Croix', 'pharmacy', 'Suburb', '11:00-15:00'),
  ('Pharmacie Nanterre Universite', 'pharmacy', 'Suburb', '11:30-15:30'),
  ('Pharmacie Creteil Soleil', 'pharmacy', 'Suburb', '11:30-15:30'),
  ('Pharmacie Aubervilliers Centre', 'pharmacy', 'Suburb', '12:00-16:00');

INSERT INTO zone_travel_times (from_zone, to_zone, estimated_minutes) VALUES
  ('Warehouse', 'Paris', 25),
  ('Warehouse', 'Suburb', 35),
  ('Warehouse', 'Hospital', 30),
  ('Paris', 'Paris', 18),
  ('Paris', 'Suburb', 30),
  ('Paris', 'Hospital', 22),
  ('Suburb', 'Paris', 30),
  ('Suburb', 'Suburb', 24),
  ('Suburb', 'Hospital', 28),
  ('Hospital', 'Paris', 22),
  ('Hospital', 'Suburb', 28),
  ('Hospital', 'Hospital', 15),
  ('Paris', 'Warehouse', 25),
  ('Suburb', 'Warehouse', 35),
  ('Hospital', 'Warehouse', 30);
