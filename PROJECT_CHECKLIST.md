# MediRun Project Checklist

Status checked against the current repository on 2026-06-06.

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
- [ ] Driver accounts are not properly linked to specific driver records yet.
- [ ] Driver dashboard currently shows assigned/in-transit deliveries generally, not only the logged-in driver's own route.
- [ ] Old `edit.html` references routes such as `add_driver`, `add_car`, `delete_driver`, and `delete_car`, but those routes are not currently present in `flash.py`.
- [ ] Route simulation is mostly front-end demo logic, not saved real route progress.

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
- [ ] App seed data should be changed from generic New York-style addresses to Paris/inner-suburb medical delivery examples.
- [ ] App should include about 35 realistic regular delivery locations.
- [ ] App should support normal days with 45-50 deliveries and busy Mondays with 55-60 deliveries.

### User Roles

- [x] CEO/Admin role exists.
- [x] Driver role exists.
- [x] CEO/Admin can access management dashboard.
- [ ] Driver should only see their own route.
- [ ] Login/role selection should match the prototype requirement: Admin/Manager plus Driver 1 to Driver 5.
- [ ] Use consistent naming across project: either Admin/Manager or CEO, not both.

### Admin / Manager Dashboard

- [x] CEO dashboard exists.
- [x] CEO can see pending/assigned deliveries.
- [x] CEO can assign a delivery to a vehicle.
- [x] CEO can add emergency deliveries.
- [ ] Dashboard summary cards are incomplete.
- [ ] Add card for today's deliveries.
- [ ] Add card for urgent deliveries.
- [ ] Add card for refrigerated deliveries.
- [ ] Add card for available drivers.
- [ ] Add card for available vehicles.
- [ ] Add card for unassigned deliveries.
- [ ] Add card for late-risk deliveries.
- [ ] Add card for warnings.
- [ ] CEO should be able to select a delivery date.
- [ ] CEO should be able to view delayed and failed deliveries.
- [ ] CEO should see clear explanations for why a delivery is late or risky.

### Deliveries Page

- [ ] Create a separate deliveries page.
- [ ] Show client name.
- [ ] Show client type.
- [ ] Show zone.
- [ ] Show priority.
- [ ] Show deadline.
- [x] Show package size.
- [x] Show refrigerated requirement.
- [x] Show status.
- [ ] Add filter by date.
- [ ] Add filter by priority.
- [ ] Add filter by zone.
- [ ] Add filter by status.
- [ ] Add filter by refrigerated requirement.

### Drivers And Vehicles Page

- [ ] Create a separate drivers and vehicles page route.
- [x] Database has drivers table.
- [x] Database has cars/vehicles table.
- [ ] Seed exactly 5 drivers.
- [ ] Seed exactly 6 vehicles.
- [ ] Show driver availability.
- [ ] Show vehicle availability.
- [ ] Show daily vehicle assignments.
- [ ] Add or restore working add/delete routes for drivers and cars if the edit page is kept.

### Generate Plan Page

- [ ] Create a generate plan page.
- [ ] Add date selector.
- [ ] Add `Generate Today's Delivery Plan` button.
- [ ] Generate route plans from selected date deliveries.
- [ ] Save generated routes.
- [ ] Save generated route stops.

### Plan Results Page

- [ ] Create a plan results page.
- [ ] Show route results per driver.
- [ ] Show assigned vehicle.
- [ ] Show stop order.
- [ ] Show client.
- [ ] Show zone.
- [ ] Show deadline.
- [ ] Show estimated arrival time.
- [ ] Show priority.
- [ ] Show warnings.

### Driver Route Page

- [x] Driver dashboard exists.
- [ ] Show only the logged-in driver's route.
- [ ] Show assigned vehicle from database.
- [ ] Show route date.
- [ ] Show stop order from route stops.
- [ ] Show client name and destination.
- [ ] Show zone.
- [ ] Show deadline.
- [ ] Show priority.
- [x] Show refrigerated requirement.
- [ ] Add working status buttons connected to the database.
- [ ] Driver can update status to in progress.
- [ ] Driver can update status to delivered.
- [ ] Driver can update status to delayed.
- [ ] Driver can update status to failed.

### Planning Algorithm

- [x] Simple vehicle suggestion exists.
- [x] Refrigerated requirement is considered in vehicle suggestion.
- [x] Package size is considered in vehicle suggestion.
- [ ] Implement full greedy daily planning algorithm.
- [ ] Select deliveries by chosen date.
- [ ] Sort urgent deliveries first.
- [ ] Sort refrigerated deliveries before normal compatible deliveries.
- [ ] Sort by earliest deadline.
- [ ] Assign refrigerated deliveries to refrigerated vehicle.
- [ ] Assign Paris/light deliveries to small vans.
- [ ] Assign suburb/heavy deliveries to large vans.
- [ ] Assign one driver to one vehicle for the full day.
- [ ] Estimate travel time using zone-based travel times.
- [ ] Add service time at each stop.
- [ ] Check driver working time.
- [ ] Generate route stops in order.
- [ ] Save route plan to database.
- [ ] Show warnings when planning problems exist.

### Warning System

- [ ] Create a warning model or warning-generation function.
- [ ] Show late delivery risk.
- [ ] Show wrong vehicle type.
- [ ] Show refrigerated delivery not assigned.
- [ ] Show too many stops for one driver.
- [ ] Show driver hours at risk.
- [ ] Show route over 8 hours.
- [ ] Show route over 10 hours.
- [ ] Show unassigned delivery.
- [x] Emergency delivery workflow exists.
- [ ] Show emergency delivery added as a visible warning/event.

### Database Requirements

- [x] Accounts table exists.
- [ ] Rename or map accounts to `users` if matching the TO-DO exactly matters.
- [x] Drivers table exists.
- [x] Cars table exists.
- [ ] Rename or map cars to `vehicles` if matching the TO-DO exactly matters.
- [ ] Clients table missing.
- [x] Deliveries table exists.
- [ ] Daily vehicle assignments table missing.
- [x] Routes table exists.
- [x] Route stops table exists.
- [ ] Zone travel times table missing.
- [ ] Deliveries table needs fields for client name, client type, zone, delivery date, priority, service time, and emergency flag.
- [ ] Delivery status enum should include delayed and failed.

---

## 3. Assessment Grid Checklist

### Contextualize - Company Description

- [x] Describe the company type: small/medium medical delivery company.
- [x] Describe the sector: medical goods delivery.
- [x] Describe the customer base: pharmacies, clinics, hospital.
- [x] Describe the company size through delivery volume, drivers, and vehicles.
- [ ] Add a clear company fact sheet.
- [ ] Add partners and competitors.
- [ ] Add context analysis explaining why the company needs a digital solution.

Deliverable needed:

- [ ] Company fact sheet covering type, size, context analysis, customers, partners, and competitors.

### Contextualize - Technical Ecosystem

- [x] Current technical stack is identified: Flask, HTML/CSS/JS, MySQL, Python.
- [x] Database scripts are included.
- [ ] Explain the client's technical constraints.
- [ ] Compare technical needs with the team's skills.
- [ ] Explain why the chosen tools are suitable for the prototype.
- [ ] Add a functional specifications document.

Deliverable needed:

- [ ] Functional specifications document.

### Contextualize - Client Discussion

- [ ] Add transcript or notes from client discussion.
- [ ] Add participant names.
- [ ] Add summary of discussion.
- [ ] Add action points from discussion.

Deliverable needed:

- [ ] Written transcript of discussions, including participant names.

### Prototype - Inputs, Constraints, And Relationships

- [x] Some problem inputs are identified: deliveries, drivers, vehicles, refrigeration, package size, distance.
- [x] Some constraints are implemented: vehicle availability, fridge requirement, package size.
- [ ] Add full input-parameter list.
- [ ] Add variability: normal day vs busy Monday, urgent deliveries, emergency deliveries.
- [ ] Add relationships/invariants: one driver per vehicle, vehicle kept all day, max driver hours, refrigerated constraint.
- [ ] Add order-of-magnitude/scaling notes: 45-60 deliveries, 35 locations, 5 drivers, 6 vehicles.
- [ ] Implement more of these constraints in the prototype.

Deliverable needed:

- [ ] Functional specifications document with inputs, constraints, relationships, and scaling factors.

### Prototype - Naive Solving Heuristic

- [x] Vehicle suggestion heuristic exists.
- [ ] Full route planning heuristic is not implemented yet.
- [ ] Add written justification of the greedy algorithm.
- [ ] Explain why this is a prototype and not advanced optimization.
- [ ] Add examples showing how deliveries are sorted and assigned.

Deliverable needed:

- [ ] Group report section justifying the heuristic.

### Prototype - Improvements With Generative AI

- [ ] Identify limits of the current prototype.
- [ ] Use AI to compare possible algorithms.
- [ ] Choose a well-known algorithm or improvement path for a future version.
- [ ] Write a PRD for a developer who would take over the project.

Possible improvement directions:

- [ ] Add real map/travel-time API.
- [ ] Add vehicle routing problem optimization.
- [ ] Add better emergency re-routing.
- [ ] Add notifications for drivers.
- [ ] Add proof of delivery.
- [ ] Add analytics dashboard.

Deliverable needed:

- [ ] PRD for the next developer.

### Integrate - Project Management

- [ ] Define clear project objectives.
- [ ] Define success metrics.
- [ ] Create a project management board or planning document.
- [ ] Add timeline or GANTT chart.
- [ ] Add reflective writing about working methods.
- [ ] Add reflective writing about communication methods.

Deliverable needed:

- [ ] Project management tool such as GANTT, Trello, or 4-quadrants board.
- [ ] Reflective writing about work and communication.

### Integrate - Team Roles

- [ ] Create team role table.
- [ ] Add each person's role.
- [ ] Add each person's tasks.
- [ ] Add time spent per person.
- [ ] Make sure each student can explain their own contribution.

Deliverable needed:

- [ ] Table showing each person's role, associated tasks, and time spent.

---

## 4. Suggested Next Direction

- [ ] First, complete the assessment deliverables because they directly affect grading.
- [ ] Second, fix the driver-to-account relationship so driver pages are private and correct.
- [ ] Third, add the missing database fields/tables needed for planning: clients, zones, priorities, service time, daily assignments, and zone travel times.
- [ ] Fourth, implement the generate-plan workflow.
- [ ] Fifth, add warnings and plan results.
- [ ] Sixth, polish the UI and update seed data to match Paris medical delivery context.
