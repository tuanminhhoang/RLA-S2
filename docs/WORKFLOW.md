# RLA Delivery Assignment System - Workflow

## Overview
A delivery assignment and real-time emergency management system for a pharmaceutical delivery company.

---

## Phase 1: Morning Assignment (Before 9 AM)

```mermaid
graph TD
    A["CEO Accesses System<br/>(Before 9 AM)"] --> B["View List of<br/>All Delivery Requests"]
    B --> C["CEO Selects a Delivery"]
    C --> D["System Fetches Route<br/>from Google Maps API<br/>- Distance<br/>- ETA<br/>- Path"]
    D --> E["System Analyzes Package"]
    E --> E1["Package Size:<br/>Small/Large"]
    E --> E2["Temperature:<br/>Frozen/Not"]
    D --> F["System Filters Available Trucks"]
    F --> F1["Match truck size<br/>to package"]
    F --> F2["Match fridge capability<br/>to package requirement"]
    E1 --> F
    E2 --> F
    F --> G["Rank Trucks by Suitability<br/>- Route fit<br/>- Driver hours remaining"]
    G --> H["Suggest Best Truck<br/>to CEO"]
    H --> I{"CEO Confirms?"}
    I -->|No| J{"Try Another<br/>Truck?"}
    J -->|Yes| H
    J -->|No| C
    I -->|Yes| K["Assign Delivery to Truck"]
    K --> L["Update Driver's Route"]
    L --> M["Delivery Status: ASSIGNED"]
    M --> N{"More Deliveries?"}
    N -->|Yes| C
    N -->|No| O["All Assignments Complete<br/>System Ready for Day"]
    O --> P["Update Simulated Positions<br/>All trucks start from warehouse"]
```

---

## Phase 2: Real-Time Tracking & Emergency Management

```mermaid
graph TD
    A["System Running<br/>Tracking All Trucks"] --> B["GPS Simulation:<br/>Constant speed based on route"]
    B --> C["Update Truck Positions<br/>Every X seconds"]
    C --> D{"Emergency Delivery<br/>Request Arrives?"}
    D -->|No| C
    D -->|Yes| E["Extract Emergency Details<br/>- Location<br/>- Package requirements<br/>- Priority"]
    E --> F["Calculate Distance<br/>from ALL trucks to<br/>Emergency Location"]
    F --> G{"Emergency Package<br/>Requires Frozen?"}
    G -->|Yes| H["Filter: Only trucks<br/>WITH fridge"]
    G -->|No| I["Consider ALL trucks"]
    H --> J["Find Nearest Truck<br/>to Emergency"]
    I --> J
    J --> K["Check Driver's<br/>Remaining Hours"]
    K --> L{"Driver has<br/>Hours Left<br/>≤ Time to Complete?"}
    L -->|Yes| M["Assign to this Truck"]
    L -->|No| N["Check 2nd Nearest Truck"]
    N --> O{"Can 2nd Truck<br/>Accept?"}
    O -->|Yes| P["Assign to 2nd Truck"]
    O -->|No| Q["Check 3rd+ Trucks"]
    Q --> R{"Any Truck on Route<br/>Can Accept?"}
    R -->|Yes| M
    R -->|No| S["All Trucks Unavailable"]
    S --> T["Recall Nearest Truck<br/>from Warehouse<br/>to Warehouse"]
    T --> U["Truck Returns to Warehouse"]
    U --> V["Replace Driver or<br/>Use Fresh Driver"]
    V --> W["Assign Emergency to<br/>This Truck"]
    M --> X["Add Emergency as<br/>NEXT STOP"]
    P --> X
    W --> X
    X --> Y["Recalculate Route<br/>with Google Maps API"]
    Y --> Z["Update Route ETA"]
    Z --> AA["Update All Stakeholders<br/>- Driver<br/>- CEO Dashboard"]
    AA --> C
```

---

## Data Flow Architecture

```mermaid
graph LR
    CEO["CEO Dashboard<br/>(Assignment)"]
    DELIVERY["Delivery Requests<br/>Queue"]
    TRUCKS["Trucks Database<br/>- ID, Size, Fridge"]
    DRIVERS["Drivers Database<br/>- Hours, Location"]
    ROUTES["Routes Database<br/>- Stops, ETAs"]
    MAPS["Google Maps API<br/>- Route calc<br/>- ETA"]
    SIM["Position Simulator<br/>- Constant speed"]
    EMERGENCY["Emergency Requests"]
    MONITOR["Monitoring Dashboard<br/>(Real-time tracking)"]
    
    CEO -->|Selects| DELIVERY
    DELIVERY --> MAPS
    MAPS -->|Route & ETA| ROUTES
    TRUCKS -->|Filter| ROUTES
    DRIVERS -->|Check hours| ROUTES
    ROUTES -->|Assign| DRIVERS
    DRIVERS -->|Current location| SIM
    SIM -->|Updates position| MONITOR
    EMERGENCY -->|Calculate distance| SIM
    SIM -->|Find nearest| DRIVERS
    EMERGENCY -->|Assign| ROUTES
```

---

## Database Requirements (To Be Designed)

Based on this workflow, you'll need tables for:

1. **Deliveries** - Request details, package specs, status
2. **Trucks** - ID, size, fridge capability, current status
3. **Drivers** - ID, hours worked, current position, assigned truck
4. **Routes** - Delivery stops, ETAs, current progress
5. **EmergencyDeliveries** - Emergency request tracking
6. **RouteSimulation** - Current positions, timestamps (can be in-memory)

---

## Key System Constraints

- ⏰ All assignments must complete **before 9 AM**
- 🚗 Maximum **8 hours** driving per driver per day
- 📍 Position updates use **constant speed simulation** (not real GPS)
- 🔄 Emergency delivery becomes **next immediate stop** (not queued)
- ❌ **One truck per delivery** (no splitting)
- 🧊 **Fridge matching required** for frozen medicines

---

## Next Steps

1. Design the database schema based on these requirements
2. Build the CEO dashboard for morning assignments
3. Implement Google Maps API integration
4. Create the position simulator
5. Build emergency delivery handler
6. Create monitoring dashboard
