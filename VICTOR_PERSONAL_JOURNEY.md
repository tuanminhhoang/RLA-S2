# Victor Oganwo — Personal Project Journey

## Project

MediRun — EPITA RLA medical delivery planning prototype

## My Role

For this project, I acted as the group leader and one of the main contributors. My role was to help guide the project direction, keep the prototype aligned with the RLA assessment, and make sure the technical work connected properly with the client problem.

I worked mostly on the backend, database direction, planning logic, seed/demo data, documentation direction, GitHub organization, and some frontend/CSS improvements. Even though each team member had a main focus, we discussed the project as a team and helped review each other's work.

## How I Started

At the beginning, the project idea was still broad. We knew we needed a realistic RLA prototype, but we had to turn the client problem into something structured enough to build.

The first important step was understanding that the company did not only need a simple delivery list. The real problem was daily planning: urgent deliveries, refrigerated products, driver hours, vehicle constraints, and the stress of busy Monday mornings.

From there, I helped shape MediRun into a decision-support dashboard for a medical delivery manager.

## What I Worked On

## Project Direction

I helped define the main idea of MediRun as a medical delivery planning dashboard. The goal was not to build a perfect production system, but to create a clear prototype that could show how a manager can plan deliveries, review routes, and give drivers confirmed stops.

I also helped keep the project realistic by connecting the features to the client discussion and the assessment grid.

## Backend And Flask App

I worked on the Flask backend and the main application routes. This included manager pages, driver pages, login behavior, route planning pages, and status update logic.

One important part was making sure the manager and driver roles were separated properly. The manager needed to see the full planning view, while drivers should only see their own confirmed routes.

## Database And Demo Data

I worked on the database direction and helped structure the data needed for the prototype. This included deliveries, clients, drivers, vehicles, routes, route stops, daily vehicle assignments, and travel time estimates.

I also worked on the demo seed data so the project would feel more realistic. Instead of generic data, the project uses a Paris and inner-suburb medical delivery scenario with pharmacies, clinics, a hospital, 5 drivers, 6 vehicles, and a busy Monday schedule.

## Planning Logic

I helped implement the route suggestion logic. The algorithm is a simple greedy heuristic, which fits the project because it is explainable and realistic for a student prototype.

The logic considers:

- urgent deliveries first
- refrigerated deliveries
- package size
- vehicle compatibility
- driver workload
- service time
- estimated travel time
- deadline risk

The system also shows warnings when a route may create problems.

## Client Clarification And Workflow Change

One of the biggest changes came after confirming with the client that the system should not fully assign drivers automatically.

The client wanted the website to suggest a plan, but the manager should stay in control. This changed the direction of the workflow.

After that, I helped change the prototype so it now works like this:

- the system suggests draft routes
- the manager reviews them
- the manager can change the driver or vehicle
- the manager confirms the final plan
- drivers only see confirmed routes
- the manager can cancel or replan if needed

This made the project more realistic and closer to the client's actual need.

## Frontend And CSS

I also worked on frontend polish, especially CSS layout and spacing. The first versions of some pages felt too cramped, so I helped make the dashboard, plan review page, buttons, and sidebar easier to use and present.

The sidebar navigation became important because the app had several pages, and the manager needed to move between dashboard, weekly plan, deliveries, fleet, and plan review without confusion.

## Documentation And Repository Work

I helped organize the GitHub repository and keep the documentation updated. This included the README, checklist, implementation notes, team roles, client discussion notes, timeline, and project management documents.

I also helped clean the repository before submission by making sure real environment files and cache files were not pushed.

## What I Learned

This project helped me understand that building a useful prototype is not only about writing code. The bigger challenge is understanding the client's real workflow and translating it into a system that makes sense.

I learned that:

- a prototype should match the user's real decision process
- automatic assignment is not always the best answer
- managers often need control, visibility, and warnings more than full automation
- database structure affects how easy it is to build features later
- a clear demo flow is just as important as the code
- documentation matters because it explains why the project was built this way

## Problems I Faced

One challenge was connecting the database, backend, and frontend together without making the system too complicated. The route planning logic had to create useful suggestions, but also stay simple enough to explain.

Another challenge was fixing the MySQL setup and environment file issue. The `.env` file was needed locally but should not be pushed to GitHub because it contains private database credentials.

The client clarification about driver assignment also forced us to rethink the workflow. At first, the system assigned drivers more automatically. After the clarification, the workflow became better because it turned MediRun into a decision-support tool instead of a system that removes the manager's control.

## How I Worked With The Team

The project was discussed as a group. Minh helped lead the client interview and supported the frontend/HTML side. Bao helped with workflow review, testing, and checking that the demo flow made sense.

Even though I handled more of the backend, database, and coordination work, the final project direction came from group discussion. We gave feedback on each other's parts and tested the prototype together.

## Final Reflection

Overall, MediRun became a stronger project because it focused on the real planning problem instead of only showing routes. The final version supports the manager with route suggestions, warnings, review controls, and confirmed driver routes.

My biggest contribution was helping turn the idea into a working prototype with a clear backend, database, planning workflow, demo data, and documentation. I also learned how important it is to adjust the system when new client information changes the best solution.

If I had more time, I would improve the project by adding a real map API, better route optimization, proof of delivery, and stronger emergency rerouting. But for the RLA prototype, I think the current version explains the problem clearly and shows a realistic first solution.
