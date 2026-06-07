# Project Timeline And GANTT — MediRun RLA

## Purpose

This document explains how the MediRun prototype work was organized over the project period. The timeline is approximate and is written for the RLA assessment rather than as an exact time log.

The project was developed in phases: understanding the client problem, translating the interview into requirements, building the database and prototype, testing the workflow, and preparing the final documentation/demo.

## Team Roles Used In The Timeline

- Victor Oganwo — group leader, backend/database, planning logic, CSS polish, GitHub/repository coordination.
- Tuan Minh Hoang — client interview lead, client notes, HTML/frontend structure, data modeling support.
- Bao Duong — workflow review, testing, demo flow, presentation support, usability feedback.

The work was discussed as a team. Each member had a main focus, but the team also reviewed and tested each other's parts.

## Timeline Overview

| Phase | Period | Main objective | Main contributors | Output |
| --- | --- | --- | --- | --- |
| 1. Project understanding | Early project period | Understand the RLA brief and choose a realistic operational problem. | All team members, led by Victor | Project idea: medical delivery planning dashboard. |
| 2. Client discussion and requirements | Early to mid project period | Ask operational questions and identify constraints. | Minh led, with Victor and Bao supporting | Client discussion notes, delivery volume, vehicles, drivers, priorities, time windows. |
| 3. Data model and database direction | Mid project period | Convert client answers into tables and fields. | Victor led, Minh supported data requirements | Database scripts for accounts, drivers, vehicles, clients, deliveries, routes, route stops, assignments. |
| 4. Core prototype structure | Mid project period | Build login, manager view, driver view, and basic workflow. | Victor led backend; Minh supported frontend; Bao reviewed workflow | Flask app, manager dashboard, driver dashboard, basic pages. |
| 5. Realistic demo data | Mid to late project period | Replace generic data with Paris/inner-suburb medical delivery scenario. | Victor led seed/demo data; Minh helped validate client realism | 35 regular locations, 5 drivers, 6 vehicles, busy Monday and normal weekday data. |
| 6. Planning heuristic | Late project period | Implement explainable route suggestion logic. | Victor led planning logic; team reviewed behavior | Greedy route suggestion, refrigerated rules, urgent sorting, travel/service estimates, warnings. |
| 7. Manager-controlled workflow | Late project period | Adjust the prototype after client clarification that the system should suggest, not fully decide. | Victor implemented; team discussed direction | Draft route suggestions, manager review, edit driver/vehicle, confirm plan, cancel plan. |
| 8. UI and workflow polish | Late project period | Make the app easier to demo and understand. | Victor and Minh on frontend/CSS/HTML; Bao and Minh on workflow review | Sidebar navigation, weekly plan, clearer pages, driver route page, delayed/failed visibility. |
| 9. Testing and debugging | Final project period | Check database setup, login, manager flow, driver flow, and route status updates. | All team members | Tested demo flow from manager login to driver route status update. |
| 10. Documentation and final preparation | Final project period | Prepare assessment documents and clean repository. | Victor led docs/repo; Minh led client notes; Bao supported presentation/demo review | README, checklist, functional spec, heuristic justification, client notes, team roles, job split, timeline. |

## GANTT-Style View

Legend: `X` = main work period, `.` = light review/support.

| Task / Phase | Week 1 | Week 2 | Week 3 | Week 4 | Week 5 | Week 6 |
| --- | --- | --- | --- | --- | --- | --- |
| Understand RLA brief and choose project direction | X | . | . | . | . | . |
| Client interview questions and discussion notes | X | X | . | . | . | . |
| Requirements and constraint analysis | . | X | X | . | . | . |
| Database schema and data model | . | X | X | . | . | . |
| Login, roles, and basic Flask pages | . | . | X | X | . | . |
| Manager dashboard and deliveries/fleet pages | . | . | X | X | . | . |
| Driver route page and status updates | . | . | . | X | X | . |
| Paris medical delivery seed data | . | . | X | X | X | . |
| Greedy route suggestion algorithm | . | . | . | X | X | . |
| Warnings, ETA, service time, distance estimates | . | . | . | X | X | . |
| Manager review/confirm/cancel plan workflow | . | . | . | . | X | X |
| UI polish and sidebar workflow | . | . | . | X | X | X |
| Testing and debugging | . | . | . | . | X | X |
| Documentation and checklist updates | . | X | . | X | X | X |
| Final demo preparation | . | . | . | . | . | X |

## Simple Project Board

## Done

- Client problem identified: medical delivery planning around Paris and inner suburbs.
- Client interview notes cleaned and linked to prototype decisions.
- Manager and driver roles implemented.
- Database scripts created and extended.
- Demo data created for realistic medical delivery locations.
- Busy Monday and normal week schedule added.
- Route suggestion algorithm implemented.
- Manager review, confirm, replan, and cancel plan workflow added.
- Driver route page limited to manager-confirmed routes.
- Warning system added for late risk, refrigerated deliveries, vehicle fit, and driver hours.
- README, functional specifications, heuristic justification, team roles, job split, and checklist updated.

## In Review / Final Check

- Run the full demo flow before presentation.
- Check that each team member can explain their own contribution.
- Check that the local `.env` file is removed before zipped submission.

## Future Improvements

- Real map or traffic API.
- Better vehicle routing optimization.
- Stronger emergency rerouting support.
- Driver notifications.
- Proof of delivery.
- Analytics dashboard.

## Work Method Reflection

The team used a practical checklist approach instead of a formal project management platform. This matched the project size because the main challenge was keeping the prototype aligned with the RLA assessment and the client interview information.

The most important communication point was agreeing that MediRun should be a decision-support tool. After the client clarification, the team changed the workflow so the system suggests routes but the manager stays in control. This made the final prototype closer to the real operational need.

## Final Project Management Summary

MediRun was completed through repeated small phases: understand the problem, model the data, build the prototype, test the workflow, and update the documentation. The team did not work in completely separate blocks; instead, members reviewed each other's work and adjusted the prototype as the client requirements became clearer.
