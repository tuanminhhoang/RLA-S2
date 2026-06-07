# MediRun Project Checklist

Status checked against the current repository on 2026-06-07.

Legend:

- [x] Done or mostly implemented
- [ ] Not done yet

Note: items described as incomplete or needing more work are left unticked.

---

## 1. Current App Implementation

- [x] Flask application exists in `MediRun website/flash.py`.
- [x] Login page exists.
- [x] Register page exists.
- [x] Role-based access exists for CEO and driver users.
- [x] CEO dashboard page exists.
- [x] Driver dashboard page exists.
- [x] Database setup scripts exist.
- [x] Seed data script exists.
- [x] Deliveries table exists.
- [x] Routes table exists.
- [x] Route stops table exists.
- [x] Emergency deliveries table exists.
- [x] Driver hours table exists.
- [x] Vehicle suggestion API exists.
- [x] Emergency vehicle suggestion API exists.
- [x] Delivery assignment API exists.
- [x] Emergency delivery creation API exists.
- [x] Driver accounts are linked to specific driver records in the enhanced schema and seed data.
- [x] Driver dashboard reads only the logged-in driver's manager-confirmed route.
- [x] Old `edit.html` references routes such as `add_driver`, `add_car`, `delete_driver`, and `delete_car`, and compatibility routes now exist in `flash.py`.
- [x] Driver route progress/status updates are saved to the database.

---

## 2. Original TO-DO Requirements

### Company And Scenario

- [x] Project describes the company type and medical delivery context.
- [x] Project describes the main delivery problem.
- [x] Project describes delivery volume.
- [x] Project describes delivery zones.
- [x] Project describes vehicle types.
- [x] Project describes driver rules.
- [x] Project describes delivery priorities.
- [x] Project describes delivery statuses.
- [x] App seed data should be changed from generic New York-style addresses to Paris/inner-suburb medical delivery examples.
- [x] App should include about 35 realistic regular delivery locations.
- [x] App should support normal days with 45-50 deliveries and busy Mondays with 55-60 deliveries.

### User Roles

- [x] CEO/Admin role exists.
- [x] Driver role exists.
- [x] CEO/Admin can access management dashboard.
- [x] Driver should only see their own route.
- [ ] Login/role selection should match the prototype requirement: Admin/Manager plus Driver 1 to Driver 5.
- [x] Use consistent naming across project: either Admin/Manager or CEO, not both.

### Admin / Manager Dashboard

- [x] CEO dashboard exists.
- [x] CEO can see pending/assigned deliveries.
- [x] CEO can assign a delivery to a vehicle.
- [x] CEO can add emergency deliveries.
- [x] Dashboard summary cards are implemented.
- [x] Add card for today's deliveries.
- [x] Add card for urgent deliveries.
- [x] Add card for refrigerated deliveries.
- [x] Add card for available drivers.
- [x] Add card for available vehicles.
- [x] Add card for unassigned deliveries.
- [x] Add card for late-risk deliveries.
- [x] Add card for warnings.
- [x] CEO should be able to select a delivery date.
- [x] CEO should be able to view delayed and failed deliveries.
- [x] CEO should see clear explanations for why a delivery is late or risky.

### Deliveries Page

- [x] Create a separate deliveries page.
- [x] Show client name.
- [x] Show client type.
- [x] Show zone.
- [x] Show priority.
- [x] Show deadline.
- [x] Show package size.
- [x] Show refrigerated requirement.
- [x] Show status.
- [x] Add filter by date.
- [x] Add filter by priority.
- [x] Add filter by zone.
- [x] Add filter by status.
- [x] Add filter by refrigerated requirement.

### Drivers And Vehicles Page

- [x] Create a separate drivers and vehicles page route.
- [x] Database has drivers table.
- [x] Database has cars/vehicles table.
- [x] Seed exactly 5 drivers.
- [x] Seed exactly 6 vehicles.
- [x] Show driver availability.
- [x] Show vehicle availability.
- [x] Show daily vehicle assignments.
- [x] Add or restore working add/delete routes for drivers and cars if the edit page is kept.

### Suggest / Generate Plan Page

- [x] Create a generate plan page.
- [x] Add date selector.
- [x] Add `Suggest Today's Delivery Plan` button.
- [x] Generate draft route suggestions from selected date deliveries.
- [x] Save suggested routes as draft/planning routes.
- [x] Save suggested route stops.
- [x] Keep manager in control instead of automatically publishing assignments to drivers.
- [x] Add manager review step before drivers receive routes.
- [x] Add manager confirmation step to publish routes to drivers.
- [x] Allow manager to adjust suggested driver and vehicle before confirmation.
- [x] Add cancel plan action so the manager can clear a draft/confirmed plan and return to `Suggest Plan`.

### Plan Results Page

- [x] Create a plan results page.
- [x] Show route suggestions per driver.
- [x] Show assigned vehicle.
- [x] Show stop order.
- [x] Show client.
- [x] Show zone.
- [x] Show deadline.
- [x] Show estimated arrival time.
- [x] Show priority.
- [x] Show warnings.
- [x] Show draft/confirmed route status.
- [x] Drivers only see routes after manager confirmation.

### Driver Route Page

- [x] Driver dashboard exists.
- [x] Show only the logged-in driver's route.
- [x] Show assigned vehicle from database.
- [x] Show route date.
- [x] Show stop order from route stops.
- [x] Show client name and destination.
- [x] Show zone.
- [x] Show deadline.
- [x] Show priority.
- [x] Show refrigerated requirement.
- [x] Add working status buttons connected to the database.
- [x] Driver can update status to in progress.
- [x] Driver can update status to delivered.
- [x] Driver can update status to delayed.
- [x] Driver can update status to failed.

### Planning Algorithm

- [x] Simple vehicle suggestion exists.
- [x] Refrigerated requirement is considered in vehicle suggestion.
- [x] Package size is considered in vehicle suggestion.
- [x] Implement full greedy daily planning algorithm.
- [x] Select deliveries by chosen date.
- [x] Sort urgent deliveries first.
- [x] Sort refrigerated deliveries before normal compatible deliveries.
- [x] Sort by earliest deadline.
- [x] Assign refrigerated deliveries to refrigerated vehicle.
- [x] Assign Paris/light deliveries to small vans.
- [x] Assign suburb/heavy deliveries to large vans.
- [x] Suggest one driver to one vehicle for the full day.
- [x] Estimate travel time using zone-based travel times.
- [x] Add service time at each stop.
- [x] Check driver working time.
- [x] Generate route stops in order.
- [x] Save route plan suggestion to database.
- [x] Confirmed route plans update delivery assignment fields.
- [x] Show warnings when planning problems exist.

### Warning System

- [x] Create a warning model or warning-generation function.
- [x] Show late delivery risk.
- [x] Show wrong vehicle type.
- [x] Show refrigerated delivery not assigned.
- [x] Show too many stops for one driver.
- [x] Show driver hours at risk.
- [x] Show route over 8 hours.
- [x] Show route over 10 hours.
- [x] Show unassigned delivery.
- [x] Emergency delivery workflow exists.
- [x] Show emergency delivery added as a visible warning/event.

### Database Requirements

- [x] Accounts table exists.
- [ ] Rename or map accounts to `users` if matching the TO-DO exactly matters.
- [x] Drivers table exists.
- [x] Cars table exists.
- [ ] Rename or map cars to `vehicles` if matching the TO-DO exactly matters.
- [x] Clients table exists.
- [x] Deliveries table exists.
- [x] Daily vehicle assignments table exists.
- [x] Routes table exists.
- [x] Route stops table exists.
- [x] Zone travel times table exists.
- [x] Deliveries table needs fields for client name, client type, zone, delivery date, priority, service time, and emergency flag.
- [x] Delivery status enum should include delayed and failed.

---

## 3. Assessment Grid Checklist

### Contextualize - Company Description

- [x] Describe the company type: small/medium medical delivery company.
- [x] Describe the sector: medical goods delivery.
- [x] Describe the customer base: pharmacies, clinics, hospital.
- [x] Describe the company size through delivery volume, drivers, and vehicles.
- [x] Add a clear company fact sheet.
- [x] Add partners and competitors.
- [x] Add context analysis explaining why the company needs a digital solution.

Deliverable needed:

- [x] Company fact sheet covering type, size, context analysis, customers, partners, and competitors.

### Contextualize - Technical Ecosystem

- [x] Current technical stack is identified: Flask, HTML/CSS/JS, MySQL, Python.
- [x] Database scripts are included.
- [x] Explain the client's technical constraints.
- [x] Compare technical needs with the team's skills.
- [x] Explain why the chosen tools are suitable for the prototype.
- [x] Add a functional specifications document.

Deliverable needed:

- [x] Functional specifications document.

### Contextualize - Client Discussion

- [x] Add transcript or notes from client discussion.
- [ ] Add participant names.
- [x] Add summary of discussion.
- [x] Add action points from discussion.
- [x] Create cleaned client interview notes in `CLIENT_DISCUSSION_NOTES.md`.
- [x] Explain how client answers shaped the prototype decisions.

Deliverable needed:

- [ ] Written transcript of discussions, including participant names.

### Prototype - Inputs, Constraints, And Relationships

- [x] Some problem inputs are identified: deliveries, drivers, vehicles, refrigeration, package size, distance.
- [x] Some constraints are implemented: vehicle availability, fridge requirement, package size.
- [x] Add full input-parameter list.
- [x] Add variability: normal day vs busy Monday, urgent deliveries, emergency deliveries.
- [x] Add relationships/invariants: one driver per vehicle, vehicle kept all day, max driver hours, refrigerated constraint.
- [x] Add order-of-magnitude/scaling notes: 45-60 deliveries, 35 locations, 5 drivers, 6 vehicles.
- [x] Implement more of these constraints in the prototype.

Deliverable needed:

- [x] Functional specifications document with inputs, constraints, relationships, and scaling factors.

### Prototype - Naive Solving Heuristic

- [x] Vehicle suggestion heuristic exists.
- [x] Full route planning heuristic is implemented.
- [x] Add written justification of the greedy algorithm.
- [x] Explain why this is a prototype and not advanced optimization.
- [x] Add examples showing how deliveries are sorted and assigned.

Deliverable needed:

- [x] Group report section justifying the heuristic.

### Prototype - Improvements With Generative AI

- [x] Identify limits of the current prototype.
- [x] Use AI to compare possible algorithms.
- [x] Choose a well-known algorithm or improvement path for a future version.
- [x] Write a PRD for a developer who would take over the project.

Possible improvement directions:

- [ ] Add real map/travel-time API.
- [ ] Add vehicle routing problem optimization.
- [ ] Add better emergency re-routing.
- [ ] Add notifications for drivers.
- [ ] Add proof of delivery.
- [ ] Add analytics dashboard.

Deliverable needed:

- [x] PRD for the next developer.

### Integrate - Project Management

- [x] Define clear project objectives.
- [x] Define success metrics.
- [x] Create a project management board or planning document.
- [ ] Add timeline or GANTT chart.
- [x] Add reflective writing about working methods.
- [x] Add reflective writing about communication methods.

Deliverable needed:

- [ ] Project management tool such as GANTT, Trello, or 4-quadrants board.
- [x] Reflective writing about work and communication.

### Integrate - Team Roles

- [x] Create team role table.
- [x] Add each person's role.
- [x] Add each person's tasks.
- [x] Add time spent per person.
- [x] Make sure each student can explain their own contribution.
- [x] Update `JOB_SPLIT.md` with realistic shared contributions.
- [x] Update `TEAM_ROLES.md` with roles, tasks, evidence, and approximate time spent.
- [x] Show that the team contributed across each other's parts: backend, database, frontend, HTML/CSS, workflow, testing, and presentation.

Deliverable needed:

- [x] Table showing each person's role, associated tasks, and time spent.

### Repository And Documentation Cleanup

- [x] Remove real `.env` file from version control.
- [x] Remove tracked Python cache files from version control.
- [x] Add `.env`, `MediRun website/.env`, `__pycache__/`, `*.pyc`, `venv/`, and `.venv/` to `.gitignore`.
- [x] Rewrite `README.md` as a student RLA prototype README instead of a production-ready claim.
- [x] Add demo accounts and run instructions to the README.
- [x] Add limitations to the README.
- [x] Create/update job split and team roles documentation.

---

## 4. Suggested Next Direction

- [x] First, complete the assessment deliverables because they directly affect grading.
- [x] Second, fix the driver-to-account relationship so driver pages are private and correct.
- [x] Third, add the missing database fields/tables needed for planning: clients, zones, priorities, service time, daily assignments, and zone travel times.
- [x] Fourth, implement the generate-plan workflow.
- [x] Fifth, add warnings and plan results.
- [x] Sixth, polish the UI and update seed data to match Paris medical delivery context.
