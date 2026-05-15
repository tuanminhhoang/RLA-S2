-- RLA / MediRun seed data
-- Run after 02_create_tables.sql.

USE medirun_db;

INSERT INTO trucks
  (name, truck_size, fridge_capable, max_stops, range_km, current_status, current_location_label, current_lat, current_lng)
VALUES
  ('Small Truck 1', 'small', FALSE, 10, 180, 'available', 'Warehouse', 48.8566000, 2.3522000),
  ('Small Truck 2', 'small', FALSE, 10, 180, 'available', 'Warehouse', 48.8566000, 2.3522000),
  ('Small Truck 3', 'small', FALSE, 10, 180, 'available', 'Warehouse', 48.8566000, 2.3522000),
  ('Large Truck 1', 'large', FALSE, 14, 260, 'available', 'Warehouse', 48.8566000, 2.3522000),
  ('Large Truck 2', 'large', FALSE, 14, 260, 'available', 'Warehouse', 48.8566000, 2.3522000),
  ('Fridge Truck 1', 'large', TRUE, 12, 220, 'available', 'Warehouse', 48.8566000, 2.3522000);

INSERT INTO drivers
  (name, shift_start, shift_end, max_hours, hours_worked, current_status, current_location_label, current_lat, current_lng, assigned_truck_id)
VALUES
  ('Driver 1', '07:00:00', '15:00:00', 8.00, 0.00, 'available', 'Warehouse', 48.8566000, 2.3522000, 1),
  ('Driver 2', '07:30:00', '15:30:00', 8.00, 0.00, 'available', 'Warehouse', 48.8566000, 2.3522000, 2),
  ('Driver 3', '08:00:00', '16:00:00', 8.00, 0.00, 'available', 'Warehouse', 48.8566000, 2.3522000, 4),
  ('Driver 4', '08:30:00', '16:30:00', 8.00, 0.00, 'available', 'Warehouse', 48.8566000, 2.3522000, 5),
  ('Driver 5', '09:00:00', '17:00:00', 8.00, 0.00, 'available', 'Warehouse', 48.8566000, 2.3522000, 6);

INSERT INTO users (username, password, role, driver_id) VALUES
  ('ceo', 'ceo123', 'ceo', NULL),
  ('driver1', 'driver123', 'driver', 1),
  ('driver2', 'driver123', 'driver', 2),
  ('driver3', 'driver123', 'driver', 3),
  ('driver4', 'driver123', 'driver', 4),
  ('driver5', 'driver123', 'driver', 5);

INSERT INTO clients
  (name, client_type, address, zone, latitude, longitude, preferred_time_window)
VALUES
  ('Warehouse Paris Centre', 'warehouse', '1 Rue de Livraison, 75001 Paris', 'Warehouse', 48.8566000, 2.3522000, '06:00-18:00'),
  ('Saint-Louis Hospital', 'hospital', '1 Avenue Claude Vellefaux, 75010 Paris', 'Hospital', 48.8742000, 2.3689000, '07:30-09:00'),
  ('Clinique Montparnasse', 'clinic', '10 Boulevard du Montparnasse, 75015 Paris', 'Paris', 48.8421000, 2.3219000, '09:00-12:00'),
  ('Clinique Bastille', 'clinic', '8 Rue de la Roquette, 75011 Paris', 'Paris', 48.8530000, 2.3690000, '09:00-12:00'),
  ('Clinique Neuilly Sante', 'clinic', '22 Avenue Charles de Gaulle, 92200 Neuilly-sur-Seine', 'Suburb', 48.8848000, 2.2685000, '10:00-13:00'),
  ('Clinique Boulogne Medicale', 'clinic', '31 Rue de Billancourt, 92100 Boulogne-Billancourt', 'Suburb', 48.8397000, 2.2399000, '10:00-13:00'),
  ('Pharmacie Rivoli', 'pharmacy', '99 Rue de Rivoli, 75001 Paris', 'Paris', 48.8606000, 2.3376000, '09:00-13:00'),
  ('Pharmacie Opera', 'pharmacy', '5 Avenue de l Opera, 75002 Paris', 'Paris', 48.8706000, 2.3322000, '09:00-13:00'),
  ('Pharmacie Republique', 'pharmacy', '12 Place de la Republique, 75011 Paris', 'Paris', 48.8674000, 2.3636000, '09:00-13:00'),
  ('Pharmacie Voltaire', 'pharmacy', '70 Boulevard Voltaire, 75011 Paris', 'Paris', 48.8590000, 2.3790000, '09:00-13:00'),
  ('Pharmacie Levallois Centre', 'pharmacy', '42 Rue du President Wilson, 92300 Levallois-Perret', 'Suburb', 48.8932000, 2.2879000, '09:30-13:30'),
  ('Pharmacie Boulogne Republique', 'pharmacy', '65 Avenue Jean Baptiste Clement, 92100 Boulogne-Billancourt', 'Suburb', 48.8352000, 2.2414000, '09:30-13:30'),
  ('Pharmacie Issy Corentin', 'pharmacy', '14 Rue Ernest Renan, 92130 Issy-les-Moulineaux', 'Suburb', 48.8249000, 2.2735000, '09:30-13:30'),
  ('Pharmacie Montrouge Mairie', 'pharmacy', '2 Avenue de la Republique, 92120 Montrouge', 'Suburb', 48.8172000, 2.3219000, '10:00-14:00');
