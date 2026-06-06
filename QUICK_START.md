# MediRun Quick Start Guide

## Getting Started in 5 Minutes

### Step 1: Database Setup (First Time Only)

```bash
# Navigate to project directory
cd d:\code\RLA-S2

# Run MySQL scripts in order
mysql -u root -p < database/01_create_database.sql
mysql -u root -p < database/02_create_accounts.sql
mysql -u root -p < database/03_create_fleet_tables.sql
mysql -u root -p < database/04_enhance_database.sql
mysql -u root -p < database/06_seed_data.sql
```

### Step 2: Configure Environment

Create `.env` file in `MediRun website` folder:
```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=medirun_db
SECRET_KEY=your-secret-key-12345
```

### Step 3: Install Dependencies

```bash
pip install -r requirements.txt
```

### Step 4: Run the Application

```bash
cd "MediRun website"
python flash.py
```

Visit: `http://localhost:5000`

---

## Testing the System

### 1. Register a New Account

**Via Web Interface:**
- Click "Register" on login page
- Choose account type: **CEO** or **Driver**
- Create username and password
- Click "Register"

### 2. Test CEO Dashboard

**Login as CEO:**
- Username: `ceo_john`
- Password: (use seed data password)

**OR register as CEO manually**

#### Phase 1: Morning Assignment
1. Click **"Phase 1: Morning Assignment"** tab
2. View "Pending Deliveries" list on left
3. Click "Assign Vehicle" on any delivery
4. System shows top 5 vehicle suggestions
5. Click vehicle to select, then "Assign This Vehicle"
6. Delivery moves to "assigned" status

#### Phase 2: Emergency Management
1. Click **"Phase 2: Real-time Tracking"** tab
2. Click **"🚨 Emergency Delivery"** button
3. Fill in emergency details:
   - Location: "Emergency Location Name"
   - Package Size: Small or Large
   - Check "Requires Refrigeration" if needed
   - Weight: 10 kg (or adjust)
4. Click "Get Vehicle Suggestions"
5. System shows available vehicles sorted by distance
6. Select a vehicle (radio button)
7. Click "Assign Emergency"
8. Emergency is created and assigned

### 3. Test Driver Dashboard

**Login as Driver:**
- Username: `driver_mike`
- Password: (use seed data password)

**OR register as Driver manually**

#### Phase 1: Assignment View
1. See "Today's Scheduled Deliveries"
2. View all deliveries assigned to you by CEO
3. Check package requirements and delivery windows

#### Phase 2: Real-time Tracking
1. Click **"Phase 2: Real-time Tracking"** tab
2. View route information:
   - Current Vehicle Plate
   - Current Location
   - Hours Worked / Max Hours
   - Total Stops Today
3. See "Current Stop" details
4. View "Upcoming Stops" list

#### Route Simulation
1. Click "Start Route Simulation"
2. Watch as progress updates:
   - Current location changes
   - Hours worked increases
   - Stop completion updates
3. Click "Mark as Completed" to move to next stop
4. Use "Pause" to pause simulation
5. Use "Stop" to reset

---

## Demo Workflow

### Complete End-to-End Test (10 minutes)

#### As CEO:
1. Login as CEO
2. View 5 pending deliveries
3. Assign 2-3 deliveries to different vehicles using suggestions
4. Trigger an emergency delivery (🚨 button)
5. Assign emergency to nearest vehicle
6. Switch to Phase 2 to monitor

#### As Driver:
1. Logout as CEO
2. Login as driver_mike
3. Check assigned deliveries in Phase 1
4. Switch to Phase 2
5. Start route simulation
6. Watch vehicle tracking
7. Stop simulation

---

## Testing Different Scenarios

### Scenario 1: Small Package, No Fridge
**CEO Flow:**
1. Select delivery "Downtown Clinic - 123 Main St" (Small package, no fridge)
2. System suggests small vehicles without fridge requirement
3. Best choice: Toyota Corolla (NA-001) or Honda Civic (NA-002)

### Scenario 2: Large Package with Fridge
**CEO Flow:**
1. Select delivery "City Hospital - 456 Oak Avenue" (Large, requires fridge)
2. System suggests large vehicles with refrigeration
3. Best choices: Mercedes Sprinter (NA-003) or Ford Transit (NA-004)

### Scenario 3: Emergency - Urgent Medical Delivery
**CEO Flow:**
1. Click 🚨 Emergency button
2. Fill in: Emergency Location, Small package, Requires Fridge ✓
3. Click "Get Vehicle Suggestions"
4. System calculates distance from each vehicle
5. Select nearest vehicle with fridge capability
6. Assign emergency

---

## Key Features to Test

### ✅ Vehicle Suggestion Algorithm
- Small packages exclude large vehicles
- Fridge requirement filters vehicles appropriately
- Capacity is considered
- Ranking by suitability

### ✅ Distance Calculation
- Emergency suggestions show distance in km
- ETA calculated based on 40 km/h average
- Correct sorting by nearest first

### ✅ Phase Switching
- Toggle between Phase 1 and Phase 2
- All data persists when switching
- Smooth animations

### ✅ Role-Based Access
- CEO can only see CEO dashboard
- Drivers can only see Driver dashboard
- Admin endpoints deny non-CEO access

### ✅ Route Simulation
- Starts, pauses, stops correctly
- Hours accumulate properly
- Location updates show progress
- Upcoming stops display

---

## Sample Data

### Vehicles Available (at warehouse)
- NA-001: Toyota Corolla (Small, No Fridge, 50kg)
- NA-002: Honda Civic (Small, No Fridge, 55kg)
- NA-003: Mercedes Sprinter (Large, **Fridge**, 200kg)
- NA-004: Ford Transit (Large, **Fridge**, 180kg)
- NA-005: Toyota Prius (Small, No Fridge, 45kg)

### Pending Deliveries
1. Downtown Clinic - Small, no fridge
2. City Hospital - Large, **fridge required**
3. Medical Center - Small, **fridge required**
4. Pharmacy Chain - Large, no fridge
5. Urgent Care - Small, **fridge required**

### Drivers
- Michael Johnson (driver_mike)
- Sarah Williams (driver_sarah)
- Alex Martinez (driver_alex)
- Emma Brown (4th driver)

---

## Common Issues & Solutions

### "Module not found" Error
```bash
pip install -r requirements.txt
```

### "Database connection refused"
- Check MySQL is running
- Verify `.env` credentials
- Run database setup scripts

### "Page blank or won't load"
- Check browser console (F12) for JavaScript errors
- Verify templates are in correct location
- Clear browser cache

### "Vehicle suggestions empty"
- Verify vehicles exist: `SELECT COUNT(*) FROM cars;`
- Check positions are set: `SELECT * FROM cars WHERE current_latitude IS NOT NULL;`

### "Can't login"
- Verify account exists in database
- Check password is correct
- Try registering new account instead

---

## Password Hashing

If you need to set test passwords manually, use:

```python
from werkzeug.security import generate_password_hash

# Generate hash for password
password_hash = generate_password_hash("testpassword123")
print(password_hash)
```

Then update database:
```sql
UPDATE accounts SET password = 'PASTE_HASH_HERE' WHERE username = 'ceo_john';
```

---

## Next Steps

- Explore both dashboards
- Test vehicle suggestion accuracy
- Verify emergency assignment logic
- Check route simulation progress
- Test phase switching
- Try different user roles

Enjoy testing MediRun! 🚗💊
