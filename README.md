# MediRun RLA Prototype

MediRun is a student RLA prototype for a medical delivery planning dashboard. It is designed for a small/medium delivery company operating around Paris and the inner suburbs.

The prototype helps a manager organize daily and weekly medical deliveries by suggesting route plans, showing warnings, letting the manager adjust driver and vehicle choices, and giving drivers a clear list of stops after the manager confirms the plan.

This is not a production system. It is not a real GPS tracking platform. It uses simple zone-based travel times and a greedy planning heuristic so the project can be explained clearly in an RLA demo.

## Project Goal

The goal is to support a manager who needs to plan medical deliveries under constraints such as:

- urgent hospital deliveries
- strict delivery deadlines
- refrigerated deliveries
- limited driver working hours
- different vehicle capacities
- busy Monday delivery volume
- emergency deliveries during the day

The system also gives each driver a private route page so they only see their own manager-confirmed stops.

## Main Features

- Manager login and driver login.
- Manager dashboard with separated sections for:
  - urgent orders
  - refrigerated orders
  - standard orders
  - delayed or failed deliveries
  - unassigned deliveries
  - emergency events
  - suggested routes
- Weekly planning view.
- Deliveries page with filters.
- Fleet page for drivers and vehicles.
- Suggest Plan page.
- Plan Results page showing draft route suggestions, route stops, ETA, travel time, service time, distance estimate, and warnings.
- Manager review controls for changing the suggested driver or vehicle before confirmation.
- Confirm Plan button so drivers only receive routes after manager approval.
- Driver route page showing only the logged-in driver's confirmed stops.
- Driver status updates:
  - in progress
  - delivered
  - delayed
  - failed
- Paris/inner-suburb demo seed data:
  - 35 regular delivery locations
  - 5 drivers
  - 6 vehicles
  - busy Monday schedule
  - normal weekday schedules

## Technology

- Python
- Flask
- MySQL
- PyMySQL
- HTML/CSS/Jinja templates

## Setup

### 1. Install Python Dependencies

```powershell
pip install -r requirements.txt
```

### 2. Create The Environment File

Create this file:

```text
MediRun website/.env
```

Use this format:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=medirun_db
SECRET_KEY=medi-run-secret-key
```

Do not commit this file. It is ignored by `.gitignore`.

### 3. Load The Database

From the project root, run:

```powershell
.\setup_database.ps1
```

If your MySQL executable is not in the default location, pass the path:

```powershell
.\setup_database.ps1 -MysqlPath "C:\xampp\mysql\bin\mysql.exe"
```

The setup script loads the SQL files in the correct order and creates the demo week data.

### 4. Run The Flask App

```powershell
cd "MediRun website"
python flash.py
```

Open:

```text
http://127.0.0.1:5000/login
```

## Demo Accounts

Manager:

```text
username: manager_demo
password: demo
```

Drivers:

```text
username: driver1
password: demo
```

```text
username: driver2
password: demo
```

```text
username: driver3
password: demo
```

```text
username: driver4
password: demo
```

```text
username: driver5
password: demo
```

## Suggested Demo Flow

1. Login as `manager_demo`.
2. Open the Weekly Plan page.
3. Open Monday to show the busy delivery day.
4. Suggest the plan for Monday.
5. Open Plan Results to review draft routes per driver.
6. Adjust a suggested driver or vehicle if needed.
7. Confirm the plan so drivers can see their routes.
8. Logout.
9. Login as `driver1`.
10. Open My Week or My Route.
11. Update a stop status.

## Important Limitations

- This is a student prototype, not a production application.
- Route planning is greedy and explainable, not mathematically optimal.
- The system suggests route assignments; the manager makes the final decision.
- Travel time and distance are estimated from operational zones, not real road data.
- There is no live GPS tracking.
- There are no push notifications.
- Emergency deliveries are visible, but the system does not fully re-optimize all existing routes after an emergency.
- Proof of delivery, analytics, and real map integration are future improvements.
- Passwords in seed data are simple demo passwords and should not be used in a real deployment.

## Useful Files

- `TO-DO.md` - original project brief
- `PROJECT_CHECKLIST.md` - implementation checklist
- `database/04_enhance_database.sql` - main schema
- `database/06_seed_data.sql` - Paris medical delivery demo data
- `MediRun website/flash.py` - Flask backend
- `MediRun website/templates/` - HTML templates
- `MediRun website/static/` - CSS and frontend assets
- `COMPANY_FACT_SHEET.md` - assessment context document
- `FUNCTIONAL_SPECIFICATIONS.md` - functional specification
- `HEURISTIC_JUSTIFICATION.md` - route planning explanation
- `TEAM_ROLES.md` - team role template
