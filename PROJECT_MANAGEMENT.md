# MediRun Project Management

## Objective

Deliver a working prototype that helps a medical delivery manager suggest, review, confirm, and monitor daily routes while drivers view and update their confirmed stops.

## Success Metrics

- Manager can create a draft daily route suggestion.
- Manager can review, adjust, confirm, cancel, or replan a route suggestion.
- Routes are saved in the database.
- Each route has ordered stops.
- Drivers only see their own route.
- Refrigerated and large-package constraints are considered.
- Warnings are visible when constraints are at risk.
- Assessment documents explain the company, constraints, heuristic, and team work.

## Current Work Board

## Done

- Flask app exists.
- Login and registration exist.
- Manager and driver roles exist.
- Database scripts exist.
- Vehicle suggestion exists.
- Emergency delivery workflow exists.
- Daily route suggestion has been added.
- Manager review/confirm/cancel workflow has been added.
- Driver-specific route view has been added.
- Paris medical demo data has been added.
- Assessment documentation has been updated.

## In Progress

- Final demo flow testing.
- Preparing the final presentation.
- Checking that the local `.env` file is removed before any zipped submission.

## Next

- Run the final manager and driver demo flow.
- Add screenshots to slides if needed.
- Make sure each team member can explain the full project flow.

## Timeline And GANTT

The project timeline and GANTT-style planning table are documented in `PROJECT_TIMELINE.md`.

## Courses And Skills Used

The project used knowledge from several courses and skill areas:

- AI for Software Engineering: helped the team structure requirements, compare possible improvements, and use AI support for documentation and prototype direction.
- Intermediate Python: supported the Flask backend, database connection logic, route generation functions, and debugging.
- Algorithms: helped with the greedy planning heuristic, priority sorting, route ordering, and constraint checks.
- Databases: supported the MySQL schema, relationships between deliveries/drivers/vehicles/routes, and seed data organization.

## Communication Method

The team should keep a shared checklist and update it after each work session. Any change to the algorithm or database should be written down so every member can explain the project direction.

## Reflection Prompt

Each student should write a short paragraph answering:

- What did I work on?
- What problem did I face?
- How did I communicate it to the team?
- What would I improve next time?
