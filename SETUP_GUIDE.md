# MediRun - Medical Delivery Management System

A Flask-based web application for managing pharmaceutical deliveries with real-time tracking and emergency response capabilities.

## System Overview

MediRun is a delivery assignment and management system designed for a medical delivery company. It features two distinct user roles:

- **CEO**: Manages delivery assignments in the morning (Phase 1) and handles emergency deliveries (Phase 2)
- **Driver**: Tracks assigned deliveries and simulates real-time route tracking

## Features

### Phase 1: Morning Assignment
- CEO views pending delivery requests
- System suggests the best vehicles based on:
  - Package size (small/large)
  - Temperature requirements (fridge/frozen goods)
  - Vehicle capacity
- CEO assigns deliveries to trucks
- Drivers view their daily assignments

### Phase 2: Real-time Tracking & Emergency Management
- View all active deliveries in transit
- Route simulation with progress tracking
- Driver hours monitoring
- Emergency delivery button with automatic vehicle suggestions based on proximity
- Assign emergency deliveries to nearest available vehicles

## Requirements

- Python 3.8+
- MySQL/MariaDB
- Flask
- pymysql
- python-dotenv
- Werkzeug (for password hashing)

## Installation

### 1. Clone or Download the Project
```bash
cd d:\code\RLA-S2
```

### 2. Install Python Dependencies
```bash
pip install -r requirements.txt
```

### 3. Set Up MySQL Database

Create a `.env` file in the `MediRun website` folder:
```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=medirun_db
SECRET_KEY=your-secret-key-here
```

### 4. Initialize Database

Run the SQL scripts in order:
```bash
mysql -u root -p < database/01_create_database.sql
mysql -u root -p < database/02_create_accounts.sql
mysql -u root -p < database/03_create_fleet_tables.sql
mysql -u root -p < database/04_enhance_database.sql
mysql -u root -p < database/06_seed_data.sql
```

## Running the Application

```bash
cd "MediRun website"
python flash.py
```

The application will start on `http://localhost:5000`

## Default Test Accounts

### CEO Account
- **Username**: ceo_john
- **Password**: (set in seed data - update as needed)
- **Role**: CEO

### Driver Accounts
- **Username**: driver_mike, driver_sarah, driver_alex
- **Password**: (set in seed data - update as needed)
- **Role**: Driver

## Database Schema

### Core Tables

- **accounts**: User credentials and roles (ceo, driver)
- **drivers**: Driver information and licenses
- **cars**: Vehicle fleet with capacity and features
- **deliveries**: Individual delivery requests
- **routes**: Route management for active deliveries
- **route_stops**: Individual stops within a route
- **emergency_deliveries**: Emergency delivery requests
- **driver_daily_hours**: Daily hours tracking per driver
- **position_history**: GPS position history (for simulation)

### Key Fields

**Cars Table Enhancements:**
- `size`: small or large vehicle
- `has_fridge`: Refrigeration capability
- `capacity_kg`: Maximum weight capacity
- `current_latitude/longitude`: Current position
- `current_driver_id`: Assigned driver

## System Architecture

### CEO Dashboard Features
1. **View Pending Deliveries**
   - Lists all unassigned delivery requests
   - Shows package details and requirements

2. **Vehicle Suggestions**
   - Recommends best-fit vehicles based on:
     - Package size matching
     - Fridge requirements
     - Vehicle availability and capacity

3. **Assignment Interface**
   - Click "Assign Vehicle" on any delivery
   - Select from ranked vehicle suggestions
   - Confirms and records assignment

4. **Emergency Delivery System**
   - "Emergency" button triggers new delivery modal
   - System suggests nearest available vehicles
   - One-click assignment to selected vehicle

### Driver Dashboard Features
1. **Phase 1: Assignment View**
   - Shows today's assigned deliveries
   - Displays pickup and delivery addresses
   - Shows package requirements

2. **Phase 2: Real-time Tracking**
   - Current vehicle and route information
   - Driver hours tracking (max 8 hours/day)
   - Route progress with upcoming stops
   - Route simulation controls
   - Active deliveries list

### Route Simulation
- Constant speed calculation (40 km/h average)
- Simulates driver progress along route
- Updates position and ETA in real-time
- Tracks hours worked automatically

## API Endpoints

All endpoints require authentication based on user role.

### CEO Endpoints
- `GET /api/deliveries` - Get pending deliveries
- `POST /api/suggest-vehicle` - Get vehicle suggestions for a delivery
- `POST /api/assign-delivery` - Assign delivery to truck
- `POST /api/emergency-suggestion` - Get vehicle suggestions for emergency
- `POST /api/create-emergency` - Create emergency delivery

## ETA Calculation

ETAs are calculated using:
- Distance between pickup and delivery locations (Haversine formula)
- Average speed of 40 km/h
- Formula: `ETA (minutes) = (distance_km / 40) * 60`

Example:
- 50 km distance = 75 minutes (1 hour 15 minutes)
- 10 km distance = 15 minutes

## Vehicle Matching Logic

When assigning a delivery, the system:
1. Filters vehicles by size requirement
2. Checks fridge capability if needed
3. Verifies vehicle availability
4. Ranks by capacity (largest suitable first)
5. Shows top 5 recommendations

## Emergency Response Logic

When an emergency delivery is triggered:
1. CEO provides location and package details
2. System finds all vehicles within reasonable distance
3. Calculates ETA from each vehicle to emergency location
4. Filters by fridge requirement
5. Sorts by distance (nearest first)
6. Displays top 5 options with distances and ETAs
7. CEO selects and assigns to nearest available vehicle

## File Structure

```
MediRun website/
├── flash.py                    # Main Flask application
├── requirements.txt            # Python dependencies
├── templates/
│   ├── base.html              # Base template
│   ├── login.html             # Login page
│   ├── register.html          # Registration page
│   ├── ceo_dashboard.html     # CEO dashboard
│   └── driver_dashboard.html  # Driver dashboard
└── static/
    ├── base/                  # Base CSS
    ├── login/                 # Login CSS & JS
    ├── register/              # Register CSS & JS
    └── dashboard/
        ├── ceo.css            # CEO dashboard styles
        └── driver.css         # Driver dashboard styles

database/
├── 01_create_database.sql     # Database creation
├── 02_create_accounts.sql     # Accounts table
├── 03_create_fleet_tables.sql # Drivers and vehicles
├── 04_enhance_database.sql    # Delivery tables
└── 06_seed_data.sql           # Sample data
```

## Key Constants

Located in `flash.py`:
- `AVERAGE_SPEED_KMH`: 40 km/h (for ETA calculation)
- `MAX_DRIVER_HOURS`: 8 hours per day
- `WAREHOUSE_LAT`: 40.7128 (default warehouse latitude)
- `WAREHOUSE_LON`: -74.0060 (default warehouse longitude)

## Phase Switching

Both CEO and Driver dashboards have a **Phase Toggle** button:
- **Phase 1**: Morning Assignment Operations
- **Phase 2**: Real-time Tracking & Emergency Management
- Switch between phases at any time for demonstration purposes

## Security Notes

- Passwords are hashed using Werkzeug's `generate_password_hash`
- Session management for user authentication
- Role-based access control (CEO-only endpoints)
- CSRF protection through Flask sessions (recommended to add Flask-WTF)

## Future Enhancements

- Integration with real Google Maps API
- Real GPS tracking from actual vehicles
- Push notifications for drivers
- Customer delivery notifications
- Analytics and reporting dashboard
- Multiple warehouse support
- Dynamic pricing based on distance and urgency
- Driver performance metrics

## Troubleshooting

### Database Connection Error
- Verify MySQL is running
- Check `.env` file credentials
- Ensure database and tables are created

### Import Errors
- Run `pip install -r requirements.txt`
- Verify Python version is 3.8+

### "Role mismatch" errors
- Clear browser cookies and re-login
- Check that account status is 'ceo' or 'driver'

### Vehicle Suggestions Empty
- Verify vehicles exist in database
- Check that vehicles have `current_latitude/longitude` set
- Ensure vehicles have `status = 'available'`

## License

Internal Use Only

## Contact & Support

For support or questions, contact the development team.
