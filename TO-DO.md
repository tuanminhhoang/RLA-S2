# MediRun RLA — Project To-Do

## Project Summary

MediRun is a medical delivery planning dashboard for a small/medium delivery company operating around Paris and the inner suburbs.

The company delivers medical goods such as medicines, medical supplies, documents, and temperature-sensitive products to pharmacies, clinics, and one main hospital.

The goal of the project is to help the manager organize daily deliveries by assigning deliveries to drivers and vehicles, generating route plans, showing warnings, and giving drivers a clear list of their tasks.

This is not a full GPS or real-time tracking system. It is a decision-support prototype that helps with planning, visibility, and traceability.

---

## Main Problem

The company currently faces problems such as:

- Too many deliveries to organize manually.
- Monday mornings are especially stressful.
- Some deliveries are urgent and must respect strict time windows.
- Medical goods cannot stay in a vehicle for more than 24 hours.
- Drivers have limited working hours.
- Vehicles have different capacities and uses.
- Refrigerated deliveries require a special refrigerated vehicle.
- Emergency deliveries can appear during the day.
- The manager needs to understand why a delivery is late or risky.

---

## Company Information

### Delivery Volume

- Normal day: around 45 to 50 deliveries.
- Busy Monday: around 55 to 60 deliveries.

### Delivery Locations

The company has around 35 regular delivery locations:

- 1 main hospital.
- 6 clinics / medical centers.
- 15 pharmacies in Paris.
- 13 pharmacies in the inner suburbs.

For the project, we will use fake but realistic names such as:

- Central Hospital
- Clinique Montparnasse
- Pharmacy Paris 12
- Pharmacy Suburb A

---

## Zones

The company thinks in simple operational zones:

- Warehouse
- Paris
- Inner suburbs / petite couronne
- Hospital as a special high-priority case

For the first version, we will use estimated travel times between zones instead of real GPS.

Example:

- Warehouse to Paris: 30 min
- Paris to Paris: 20 min
- Paris to Suburb: 40 min
- Suburb to Suburb: 30 min
- Suburb to Warehouse: 25 min

---

## Vehicles

The company has 6 vehicles:

### 3 Small Vans

- Best for Paris city routes.
- Agile in traffic.
- Easier to park.
- Good for light medical parcels.
- Around 30 stops per day.
- Around 80 km range.

### 2 Large Vans

- Best for suburbs and heavier loads.
- Higher capacity.
- Less practical in dense Paris traffic.
- Used for longer routes with fewer stops.

### 1 Refrigerated Vehicle

- Used only for temperature-sensitive deliveries.
- Similar capacity to a small van.
- Main limitation is availability.
- If it is already assigned, no other vehicle can replace it for refrigerated deliveries.

---

## Drivers

The company has 5 drivers.

Driver rules:

- Each driver usually works an 8-hour shift.
- Maximum legal working time is 10 hours if really necessary.
- Drivers usually leave between 7:30 and 8:00.
- The hospital route may leave earlier because it must arrive before 9:00.
- Drivers normally return to the warehouse at the end of the route.
- Each driver keeps one vehicle for the whole day.
- Vehicles are not swapped during the day.

For the project, we can use:

- Driver 1
- Driver 2
- Driver 3
- Driver 4
- Driver 5

No real names are needed.

---

## Delivery Priorities

The company uses 3 priority levels:

### Urgent

Examples:

- Hospital deliveries.
- Emergency calls.
- Strict morning deadline deliveries.
- Time-critical medical products.

### Normal

Examples:

- Regular pharmacy restocking.
- Standard clinic deliveries.

### Low

Examples:

- Flexible deliveries.
- Non-critical items that can be pushed later if the day becomes difficult.

---

## Delivery Statuses

We will use simple operational statuses:

- Pending
- Assigned
- In progress
- Delivered
- Delayed
- Failed

Meaning:

- Pending: delivery exists but has not been planned yet.
- Assigned: assigned to a driver and vehicle.
- In progress: driver is on the road.
- Delivered: completed successfully.
- Delayed: at risk or past its time window but still expected.
- Failed: could not be delivered because of client unavailable, wrong product, closed location, etc.

---

## Delivery Data Fields

Each delivery should store:

- Delivery ID
- Client name
- Client type
- Zone
- Delivery date
- Priority
- Deadline
- Package size
- Refrigerated required: yes/no
- Service time
- Status
- Emergency: yes/no

---

## User Roles

The website will have 2 roles:

## 1. Admin / Manager

The admin can see and manage everything.

Admin features:

- See all deliveries.
- See all drivers.
- See all vehicles.
- Select a delivery date.
- Generate a daily delivery plan.
- View generated routes.
- Add emergency deliveries.
- See warnings.
- See delayed or failed deliveries.
- Track delivery status.
- Understand why a delivery is late or risky.

## 2. Driver

The driver only sees their own route.

Driver features:

- See today’s assigned vehicle.
- See assigned route.
- See stops in order.
- See client name and destination.
- See priority and deadline.
- See refrigerated yes/no.
- Update status:
  - In progress
  - Delivered
  - Delayed
  - Failed

Drivers should not see other drivers’ routes because it would be distracting.

---

## Website Pages

## Basic Pages Needed First

### 1. Login / Role Selection Page

Simple prototype login.

Options:

- Admin
- Driver 1
- Driver 2
- Driver 3
- Driver 4
- Driver 5

No complex authentication required for the first version.

---

### 2. Admin Dashboard

Shows summary cards:

- Today’s deliveries
- Urgent deliveries
- Refrigerated deliveries
- Available drivers
- Available vehicles
- Unassigned deliveries
- Late-risk deliveries
- Warnings

---

### 3. Deliveries Page

Shows a table of deliveries:

- Client
- Client type
- Zone
- Priority
- Deadline
- Package size
- Refrigerated required
- Status

Possible filters:

- Date
- Priority
- Zone
- Status
- Refrigerated required

---

### 4. Drivers & Vehicles Page

Shows:

- 5 drivers
- 6 vehicles
- Driver availability
- Vehicle availability
- Daily vehicle assignments

---

### 5. Generate Plan Page

Admin selects a date and clicks:

`Generate Today’s Delivery Plan`

The system then creates daily routes.

---

### 6. Plan Results Page

Shows route results per driver:

- Driver
- Vehicle
- Stop order
- Client
- Zone
- Deadline
- Estimated arrival time
- Priority
- Warnings

---

### 7. Driver Route Page

Shows only the logged-in driver’s route:

- Date
- Assigned vehicle
- Stop order
- Client
- Zone
- Deadline
- Priority
- Refrigerated required
- Status buttons

---

## Planning Algorithm

We will use a simple greedy algorithm, not advanced optimization.

Basic logic:

1. Select deliveries for the chosen date.
2. Sort deliveries by:
   - urgent first
   - refrigerated deliveries
   - earliest deadline
3. Assign refrigerated deliveries to the refrigerated vehicle.
4. Assign Paris/light deliveries to small vans.
5. Assign suburb/heavy deliveries to large vans.
6. Assign one driver to one vehicle for the full day.
7. Estimate travel time using zone-based estimates.
8. Add service time at each stop.
9. Check driver working time.
10. Generate route stops.
11. Save the route plan.
12. Show warnings if there are problems.

---

## Warnings

The system should show warnings for:

- Late delivery risk.
- Wrong vehicle type.
- Refrigerated delivery not assigned.
- Too many stops for one driver.
- Driver hours at risk.
- Route over 8 hours.
- Route over 10 hours.
- Unassigned delivery.
- Emergency delivery added.

---

## Database Tables

Minimum database tables:

```text
users
drivers
vehicles
clients
deliveries
daily_vehicle_assignments
routes
route_stops
zone_travel_times