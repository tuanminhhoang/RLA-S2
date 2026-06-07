# Tuan Minh Hoang — Personal Project Journey

## Project

MediRun — EPITA RLA medical delivery planning prototype

## My Role

For this project, I contributed mainly to the client interview, client notes, frontend/HTML structure, data modeling support, and workflow review. I helped the group understand what the client actually needed and how those needs should appear in the prototype.

My role was important because MediRun depended on translating informal client answers into clear requirements. I worked with Victor and Bao to make sure the final prototype was not just a technical demo, but something connected to the real medical delivery workflow.

## How I Started

At the beginning, the team needed to understand the company and the delivery problem properly. I helped lead the client interview side by preparing and asking questions about the company activity, drivers, vehicles, delivery volume, time windows, emergency deliveries, and expected output.

The goal was to collect enough operational detail so the prototype could be realistic and not too generic.

## What I Worked On

## Client Interview And Notes

I helped lead the client discussion and organize the information into useful project requirements. The interview helped us understand that the company delivers medical products to pharmacies, clinics, medical centers, and one hospital around Paris and the inner suburbs.

From the discussion, we identified important facts such as:

- normal days have around 45 to 50 deliveries
- busy Mondays have around 55 to 60 deliveries
- the company has 5 drivers and 6 vehicles
- one vehicle is refrigerated and must be used for temperature-sensitive deliveries
- the hospital has a strict morning deadline
- the manager needs visibility and control, not full automation

This information shaped the database, route logic, dashboard sections, and documentation.

## Frontend And HTML Structure

I contributed to the frontend side, especially around page structure and how the interface should support the manager and driver workflows.

The project needed pages that were understandable during a demo, including:

- manager dashboard
- weekly plan
- deliveries page
- fleet page
- suggested plan review page
- driver route page
- driver week page

I helped think through how these pages should be organized so the manager can move through the system logically.

## Data Modeling Support

I helped connect the client answers to the data needed by the prototype. The client discussion showed that the system needed to track clients, delivery zones, priorities, time windows, refrigerated requirements, package size, service time, status, and emergency flags.

These details helped the group decide what fields were needed in the database and what information should appear in the dashboard.

## Workflow Review With Bao

I also worked with Bao on reviewing the workflow. We looked at whether the app flow made sense from the manager's point of view:

- choose a date
- review deliveries
- suggest a plan
- adjust the suggested plan
- confirm the plan
- let drivers see confirmed routes

This helped make the final prototype easier to explain and more realistic.

## What I Learned

This project helped me understand that client interviews are not just about collecting random answers. The answers need to be translated into system features, database fields, and user flows.

I learned that:

- good questions help reveal the real problem
- the client often needs visibility and control more than full automation
- frontend pages should match the user's workflow
- data modeling depends on understanding real operations
- documentation is important because it explains why the prototype was built this way

## Problems I Faced

One challenge was making sure the client information was detailed enough to support the project. The first idea could have become too simple, but the interview gave us constraints like refrigerated deliveries, hospital deadlines, driver hours, and emergency requests.

Another challenge was making the interface feel understandable. The system has several pages, so the sidebar and page structure needed to help users know where to go next.

## How I Worked With The Team

The team discussed the project direction together. Victor worked more on backend, database, planning logic, and coordination. Bao supported workflow review, testing, and presentation preparation.

I focused more on the client interview, client notes, frontend/HTML structure, and data requirements, but we also helped each other across the project.

## Final Reflection

My main contribution was helping the group understand the client problem and turn it into a realistic prototype direction. The client discussion made MediRun stronger because it showed that the system should suggest routes but still let the manager make final decisions.

If I had more time, I would improve the frontend further by making the pages even clearer and adding more visual indicators for plan status, warnings, and driver workload.
