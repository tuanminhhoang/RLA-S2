# MediRun RLA Presentation Script

## Presentation Setup

Target length: 8 to 10 minutes.

Speakers:

- Victor Oganwo: project opening, technical explanation, heuristic, live demo lead, project management.
- Tuan Minh Hoang: client discussion, requirements, and how the client answers shaped the prototype.
- Bao Duong: workflow review, testing, usability, and demo-flow explanation.

Main demo date:

```text
2026-06-01
```

Demo accounts:

```text
Manager username: manager_demo
Manager password: demo

Driver username: driver1
Driver password: demo
```

## What To Open Before Presenting

Open these before the presentation starts:

- Browser tab: `http://127.0.0.1:5000/login`
- VS Code or GitHub with:
  - `README.md`
  - `CLIENT_DISCUSSION_NOTES.md`
  - `COMPANY_FACT_SHEET.md`
  - `FUNCTIONAL_SPECIFICATIONS.md`
  - `HEURISTIC_JUSTIFICATION.md`
  - `PROJECT_TIMELINE.md`
  - `TEAM_ROLES.md`
  - `PRD_NEXT_VERSION.md`
- Optional: GitHub repository page.

Before opening the website, MySQL must be running and Flask should be started with:

```powershell
cd "MediRun website"
python flash.py
```

Do not open or show `MediRun website/.env` during the presentation.

## Pre-Demo Checklist

- Run `pip install -r requirements.txt`.
- Confirm `cryptography` is installed. It is needed by some MySQL 8 authentication setups used by PyMySQL.
- Confirm `MediRun website/.env` exists locally.
- Confirm MySQL is running.
- Run:

```powershell
python -m py_compile "MediRun website/flash.py"
```

- Start Flask and test:
  - manager login
  - Monday dashboard
  - Review Plan
  - driver1 route page
  - one driver status update button

## 1. Opening / Project Context — Victor

**What to show:** `COMPANY_FACT_SHEET.md` or the first slide with project context.

**Victor says:**

Good morning. Our project is called MediRun. It is a student RLA prototype for a small to medium medical delivery company operating around Paris and the inner suburbs.

The company delivers medical products to pharmacies, clinics, medical centers, and one main hospital. The operational problem is that the manager has to plan many deliveries every day while considering urgent hospital deadlines, refrigerated products, driver working hours, vehicle capacity, and busy Monday volume.

For scale, the company has 5 drivers, 6 vehicles, around 35 regular delivery locations, around 45 to 50 deliveries on a normal day, and around 55 to 60 deliveries on a busy Monday.

Our prototype is not a production GPS system. It is a decision-support dashboard that helps the manager suggest, review, confirm, and monitor delivery plans.

**Assessment grid covered:**

- Company type
- Company size
- Sector
- Customer base
- Context analysis
- Partners and competitors

## 2. Client Discussion And Requirements — Minh

**What to show:** `CLIENT_DISCUSSION_NOTES.md`.

**Minh says:**

For the client discussion, I led the interview and client-notes part, with Victor and Bao supporting. We asked questions about the company activity, vehicles, drivers, customers, time windows, emergency deliveries, costs, delays, and expected tool output.

The most important thing we learned is that the problem is not only routing. It is planning, visibility, warnings, and traceability.

The client told us that the system should not fully decide driver assignments by itself. The website should suggest a plan, but the manager must stay in control. This changed our prototype direction. Instead of automatically publishing routes, MediRun creates draft suggestions first. The manager can review them, adjust the driver or vehicle, and only then confirm the plan for drivers.

We also learned that hospital deliveries must arrive before 9:00, refrigerated deliveries must use the refrigerated vehicle, and emergency deliveries should be flagged but not automatically inserted into routes.

**Assessment grid covered:**

- Client discussion transcript
- Participant names
- Summary of discussion
- Actions taken after the meeting

## 3. Technical Ecosystem And Data Model — Victor

**What to show:** `FUNCTIONAL_SPECIFICATIONS.md`.

**Victor says:**

For the technical ecosystem, we used Python and Flask for the backend, MySQL for the database, PyMySQL for database access, and HTML, CSS, and Jinja templates for the frontend.

This stack fits the project because the prototype needs structured relational data: clients, deliveries, drivers, vehicles, routes, route stops, and daily vehicle assignments. It also allows us to explain the workflow clearly during the demo.

The main input parameters are delivery date, client name and type, zone, priority, deadline, package size, refrigerated requirement, service time, delivery status, emergency flag, driver availability, vehicle availability, vehicle size, and vehicle refrigerated capability.

The main constraints are: one driver keeps one vehicle for the day, refrigerated deliveries require the refrigerated vehicle, urgent deliveries come first, deadlines should be checked against estimated arrival time, and drivers should normally stay under 8 hours with 10 hours as a serious limit.

**Assessment grid covered:**

- Technical tooling
- Functional specifications
- Input parameters
- Variability
- Relationships and invariants
- Scaling factors

## 4. Heuristic And Prototype Logic — Victor

**What to show:** `HEURISTIC_JUSTIFICATION.md`.

**Victor says:**

The prototype uses a simple greedy planning heuristic. We chose this because the goal is a clear student prototype, not a full mathematical vehicle-routing optimizer.

The algorithm works like this:

1. Select pending deliveries for the chosen date.
2. Sort urgent deliveries first.
3. Prioritize refrigerated deliveries.
4. Sort by earliest deadline.
5. Match deliveries to compatible driver and vehicle suggestions.
6. Prefer the refrigerated vehicle for refrigerated deliveries.
7. Prefer small vans for Paris and light deliveries.
8. Prefer large vans for suburb or heavier deliveries.
9. Estimate travel time using zone-to-zone travel times.
10. Add service time at each stop.
11. Save draft route suggestions.
12. Let the manager review and confirm before drivers see the routes.

The system also generates warnings for late delivery risk, wrong vehicle type, refrigerated issues, too many stops, route over 8 hours, route over 10 hours, and unassigned deliveries.

This is explainable and deterministic, which is useful for the RLA prototype.

**Assessment grid covered:**

- Naive solving heuristic
- Constraint handling
- Justification in group report

## 5. Live Demo — Victor Leads, Bao Comments

## Step 1 — Login As Manager

**What to open:** `http://127.0.0.1:5000/login`

Login:

```text
username: manager_demo
password: demo
```

**Victor says:**

I am logging in as the manager. The manager has the full planning view, unlike drivers who only see their confirmed routes.

## Step 2 — Manager Dashboard

**What to click:** open Manager Dashboard for `2026-06-01`.

**Show:**

- today's deliveries
- urgent deliveries
- refrigerated deliveries
- available drivers
- available vehicles
- unassigned
- late risk
- warnings

**Victor says:**

This is Monday, the busy day in our demo. The dashboard separates urgent orders, refrigerated orders, standard orders, delayed or failed deliveries, unassigned deliveries, emergency events, and suggested or confirmed routes.

**Bao says:**

From a workflow point of view, this page is the manager's control center. The idea is that the manager can quickly see what needs attention before opening the detailed plan.

## Step 3 — Weekly Plan

**What to click:** `Weekly Plan`.

**Victor says:**

The weekly plan shows the Monday-to-Sunday view. We use it to show that Monday is busier than the other days, which matches the client discussion.

**Bao says:**

This view is useful in the demo because it shows that the system is not only for one isolated delivery. It supports planning by date and by week.

## Step 4 — Deliveries Page

**What to click:** `Deliveries`.

**Show filters:**

- date
- priority
- zone
- status
- refrigerated requirement

**Victor says:**

This page shows the input parameters used by the system. The manager can filter by date, priority, zone, status, and refrigerated requirement.

## Step 5 — Fleet Page

**What to click:** `Fleet`.

**Show:**

- 5 drivers
- 6 vehicles
- small vans
- large vans
- refrigerated vehicle
- daily assignments after confirmation

**Victor says:**

The fleet page shows the driver and vehicle resources. The client told us vehicles are not interchangeable, so the prototype keeps vehicle constraints visible.

## Step 6 — Review Plan

**What to click:** `Review Plan`.

**Show:**

- confirmed or suggested routes
- driver
- vehicle
- stop order
- ETA
- travel time
- service time
- distance estimate
- warnings

**Victor says:**

This is the plan review page. If the plan is still a draft, the manager can change the suggested driver or vehicle before confirming. After confirmation, drivers can see their routes.

The important client requirement is that the system helps with 80 percent of the planning, but the manager still makes the final decision.

Do not click `Cancel Plan` unless we intentionally want to reset the demo.

**Bao says:**

This page was important for usability because it avoids the system feeling too automatic. The manager can review and trust the plan before drivers receive it.

## Step 7 — Driver View

**What to click:** logout, then login as driver1.

Login:

```text
username: driver1
password: demo
```

**Show:**

- My Route
- assigned vehicle
- stop order
- client
- deadline
- priority
- refrigerated requirement
- travel/service/distance
- status buttons

**Victor says:**

The driver only sees their own manager-confirmed route. This keeps the driver view simple and avoids showing information that belongs to other drivers.

**Bao says:**

The status buttons let the driver update progress: in progress, delivered, delayed, or failed. That supports traceability when the manager needs to explain what happened.

**Assessment grid covered by demo:**

- Implemented constraints
- Prototype relationships
- Manager/driver roles
- Route planning behavior
- Warnings
- User workflow

## 6. Project Management And Team Roles — Bao Then Victor

**What to show:** `PROJECT_TIMELINE.md`, `PROJECT_MANAGEMENT.md`, `TEAM_ROLES.md`, and optionally `JOB_SPLIT.md`.

**Bao says:**

For workflow and testing, I helped check whether the manager and driver pages were understandable. We tested the demo flow from manager login to weekly planning, review plan, and driver route view. I also helped review whether the interface made sense for someone seeing the project for the first time.

**Victor says:**

For project management, we used a checklist and timeline approach. The timeline shows phases: understanding the client problem, collecting requirements, designing the database, building the prototype, adding demo data, implementing the heuristic, testing, and preparing documentation.

For roles, I acted as group leader and focused more on backend, database, planning logic, CSS polish, GitHub, and coordination. Minh led the client interview and helped with HTML/frontend and data requirements. Bao supported workflow review, testing, demo flow, and presentation preparation.

**Assessment grid covered:**

- Project management tool
- GANTT/timeline
- Working method reflection
- Communication method
- Team role table
- Time spent per person

## 7. Future Improvements And AI Use — Victor Or Minh

**What to show:** `PRD_NEXT_VERSION.md`.

**Victor or Minh says:**

The current prototype is intentionally limited. It uses zone-based travel time and a greedy heuristic. With more time, the next version could use real map or traffic APIs, stronger vehicle routing optimization, better emergency rerouting, driver notifications, proof of delivery, and analytics.

For the algorithm improvement, we identified vehicle routing as a classic optimization problem. A future developer could explore Google OR-Tools or another vehicle routing problem approach.

The PRD explains what the next developer should improve and why.

**Assessment grid covered:**

- Areas for improvement with Generative AI
- Well-known algorithm direction
- PRD for next developer

## 8. Closing — All

**Victor says:**

To conclude, MediRun is a decision-support prototype for medical delivery planning. It is not a production GPS system, but it solves the client's main planning problem in a clear first version.

**Minh says:**

The client discussion helped us understand that the manager needs control, not full automation. That is why routes are suggested first and confirmed by the manager.

**Bao says:**

The final workflow helps make Monday mornings calmer, gives drivers clear confirmed routes, and gives the manager better visibility when delays or warnings happen.

## Assessment Grid Coverage Map

| Assessment criterion | What to say/show |
| --- | --- |
| Company description | Show `COMPANY_FACT_SHEET.md`; mention company type, size, sector, customers, partners, competitors. |
| Technical ecosystem | Show `FUNCTIONAL_SPECIFICATIONS.md`; mention Flask, Python, MySQL, PyMySQL, HTML/CSS/Jinja. |
| Client discussion | Show `CLIENT_DISCUSSION_NOTES.md`; mention participants, summary, client clarification, and prototype actions. |
| Inputs, constraints, relationships, scaling | Show dashboard/deliveries/fleet and functional specs; mention delivery date, priority, zone, fridge, drivers, vehicles, 45-60 deliveries. |
| Naive solving heuristic | Show `HEURISTIC_JUSTIFICATION.md`; explain greedy route suggestion and warnings. |
| Future improvements with AI | Show `PRD_NEXT_VERSION.md`; mention OR-Tools, map API, emergency rerouting, notifications, proof of delivery. |
| Project management | Show `PROJECT_TIMELINE.md` and `PROJECT_MANAGEMENT.md`; mention GANTT, project board, objectives, success metrics. |
| Team roles | Show `TEAM_ROLES.md` or `JOB_SPLIT.md`; each member explains their contribution. |

## Backup Answers For Questions

## Why did you not use real GPS?

Because this is a first RLA prototype. The client mainly needed planning support, visibility, and warnings. Zone-based estimates are easier to explain and enough for the prototype.

## Why use a greedy heuristic?

Because it is deterministic, explainable, and matches the way a manager might manually prioritize urgent, refrigerated, and deadline-sensitive deliveries. A future version could use full vehicle routing optimization.

## Why does the manager confirm routes?

The client clarified that the system should not fully decide driver assignments. The manager needs to stay in control because every day is different and drivers know their areas.

## What is the main limitation?

The system does not use real traffic, live GPS, proof of delivery, or full optimization. Those are future improvements.

## How does this match the client need?

It helps the manager plan the day in one place, reduce Monday morning confusion, give drivers clear confirmed routes, and explain delays with warnings and statuses.

## What did each person contribute?

- Victor: group leader, backend, database, planning logic, seed data, CSS polish, GitHub, documentation coordination.
- Minh: client interview lead, client notes, HTML/frontend structure, data modeling support.
- Bao: workflow review, testing, demo flow, presentation support, usability feedback.

## Emergency If The Website Fails

If the live app does not open:

1. Show `README.md` and explain setup.
2. Show `FUNCTIONAL_SPECIFICATIONS.md` for inputs/constraints.
3. Show `HEURISTIC_JUSTIFICATION.md` for algorithm.
4. Show `CLIENT_DISCUSSION_NOTES.md` for client discussion.
5. Show `PROJECT_TIMELINE.md` and `TEAM_ROLES.md` for integration criteria.
6. Explain that the app requires MySQL, `.env`, and dependencies including `cryptography`.

## Final Reminder

Do not submit or display:

```text
MediRun website/.env
```

It contains local database credentials and is intentionally ignored by Git.
