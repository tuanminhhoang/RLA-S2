# Client Discussion Notes — MediRun

## 1. Purpose of the Interview

The goal of the interview was to understand how the medical delivery company actually organizes its daily work. We wanted to turn a business problem that was first described in a general way into something structured enough to model in a prototype.

The discussion helped us identify the important operational constraints: delivery volume, vehicles, drivers, urgent deliveries, refrigerated products, time windows, and the type of visibility the manager needs when something goes wrong.

## 2. Main Questions Asked

## Company Activity

- What does the company deliver?
- What type of customers does the company serve?
- Where does the company operate?
- Where do drivers start and end their routes?
- Are there special customers that need different treatment?

## Vehicles

- How many vehicles does the company have?
- Are all vehicles the same?
- Which vehicles are best for Paris?
- Which vehicles are best for suburbs or heavier loads?
- How are refrigerated deliveries handled?
- Can vehicles be swapped during the day?

## Drivers

- How many drivers are available?
- What are normal driver working hours?
- What is the legal maximum working time?
- When do drivers usually leave the warehouse?
- Do drivers use GPS or fixed routes?
- Should drivers see all routes or only their own?

## Customers And Delivery Process

- Who receives the deliveries?
- What happens when a driver arrives?
- How long does a stop usually take?
- Are hospital deliveries different from pharmacy or clinic deliveries?

## Time Windows

- How many deliveries have strict time windows?
- Which deliveries are the most urgent?
- What happens with hospital deliveries?
- Are pharmacy deliveries flexible?

## Emergency Deliveries

- Can same-day emergency deliveries appear?
- Who can request them?
- Should the system automatically insert emergencies into routes?
- What should the manager see when an emergency is added?

## Costs

- What are the main monthly costs?
- Is fuel optimization the main objective?
- How important is avoiding late deliveries compared with cost?

## Delays And Traceability

- What causes delays?
- Who is responsible when something is late?
- What does the manager need when a client complains?
- What delivery statuses should be tracked?

## Expected Tool Output

- What should the manager see after planning?
- What should drivers see?
- What warnings should the system show?
- What would make the tool successful for the client?
- Should the system assign drivers automatically, or should it suggest a plan for the manager to approve?

## 3. Important Client Answers

## Company Activity

The company delivers medical products to pharmacies, clinics, medical centers, and one main hospital. It operates around Paris and the inner suburbs, also described as the petite couronne.

Drivers start from a small warehouse where products arrive early in the morning. After finishing their routes, drivers usually return to the warehouse to return the vehicle and paperwork.

The hospital is a special case because it has a strict early morning delivery window.

## Delivery Volume

The company usually handles around 45 to 50 deliveries on a normal day. Monday is busier, with around 55 to 60 deliveries.

The company has around 35 regular delivery locations. The stable base includes:

- 1 main hospital
- 6 clinics or medical centers
- 15 pharmacies in Paris
- 13 pharmacies in the inner suburbs

Real client names and addresses should not be used in the prototype. Fake but realistic names are preferred.

## Vehicles

The company has 6 vehicles in total.

There are 3 small vans. They are best for Paris city routes because they are more agile in traffic and easier to park. They are used for light parcels, boxes, and documents. A small van can do around 30 stops per day and has around 80 km range.

There are 2 large vans. They are better for suburbs and heavier loads because they have more capacity. They are less practical in dense Paris traffic and are usually used for longer routes with fewer stops.

There is 1 refrigerated vehicle. It is only for temperature-sensitive products and has capacity similar to a small van. Its main constraint is availability. No other vehicle can replace it for refrigerated deliveries.

Vehicles are not interchangeable during the day. One driver keeps one vehicle for the whole day.

## Drivers

There are 5 drivers in total. Drivers usually work 8-hour shifts. The legal maximum is 10 hours if necessary, but overtime should be avoided.

Drivers usually leave between 7:30 and 8:00. The hospital route may leave earlier to meet the before-9:00 deadline.

Drivers mostly use GPS and experience. They only call customers if there is a problem.

For the prototype, Driver 1 to Driver 5 is enough. Real driver names are not needed.

## Customers And Delivery Process

Customers are mainly pharmacies, clinics, and one hospital.

Pharmacies and clinics usually expect the driver. The driver goes to reception or storage, gets a signature or confirmation, and leaves.

Hospital delivery is more structured and goes to a specific reception point.

Approximate service times are:

- pharmacies: around 5 to 10 minutes
- clinics: slightly longer
- hospital: around 15 minutes

## Time Windows And Priorities

About 30% of deliveries have strict time windows. The hospital delivery must arrive before 9:00.

Other deliveries are more flexible, but pharmacies often prefer avoiding lunch or receiving before the afternoon rush.

The priority levels are:

- Urgent: hospital deliveries, emergency calls, strict morning deadlines, and time-critical products
- Normal: regular pharmacy restocking and normal clinic deliveries
- Low: flexible non-critical deliveries that can be pushed later if needed

## Temperature-Sensitive Deliveries

There are usually 6 to 10 temperature-sensitive deliveries per day. These must use the refrigerated vehicle.

If refrigerated capacity is exceeded, the manager may resequence the day, delay low-priority deliveries, or do a second trip.

## Emergency Deliveries

Emergency same-day requests can happen. They can come from the hospital or pharmacies.

Emergency deliveries should be added and flagged. The system should not automatically insert them into a route. Instead, it should show which drivers or routes could be affected, and the manager should make the final decision.

## Costs

The main monthly costs are approximately:

- driver salaries: around 12000 to 14000 euros per month
- fuel: around 1500 to 2000 euros per month
- vehicles: around 3000 to 3500 euros per month
- overtime or exceptional days: a few hundred euros in a bad month
- total operational cost: around 18000 to 22000 euros per month

Cost matters, but avoiding late deliveries is more important.

## Delays And Traceability

There is no automatic financial penalty for drivers. If a delay is the driver's fault, the manager discusses it with them. If the customer is unavailable or closed, it is not the driver's fault. If emergency requests cause a delay, the company accepts responsibility.

The manager mainly needs visibility and traceability. When a client complains, the manager wants to quickly explain why something was late.

Possible delay reasons include:

- traffic
- emergency delivery interruption
- hospital priority
- client unavailable
- door closed
- wrong instructions
- overloaded route
- driver hours at risk

The delivery statuses are:

- Pending
- Assigned
- In progress
- Delivered
- Delayed
- Failed

## Data Known Before Planning

Before planning, the company knows:

- client name
- client type
- zone
- delivery date
- priority
- deadline
- package size
- refrigerated yes/no
- service time
- status
- emergency yes/no

## Daily Planning

Each delivery belongs to one date. The manager thinks in terms of today's deliveries or tomorrow's deliveries. The admin/manager should be able to select a date, especially Monday, and generate the plan for that day.

The client clarified that the system should not fully decide driver assignments on its own. The preferred approach is that the website suggests route plans and suggested drivers, then the manager reviews and adjusts them if needed. This is especially important on Mondays because the manager wants help getting most of the plan ready quickly, but still needs to stay in control.

The zones are:

- Warehouse
- Paris
- Suburb / petite couronne
- Hospital as a special high-priority case

For the first prototype, zone-based travel estimates should be used instead of real GPS.

## Expected Output

The expected output is:

- clear daily route suggestion per driver
- manager overview
- warnings
- suggested or confirmed driver
- suggested or confirmed vehicle
- stop order
- estimated arrival time
- delivery status
- delay reasons

The warnings should include:

- late delivery risk
- wrong vehicle type
- refrigerated delivery not assigned
- too many stops for one driver
- driver hours at risk
- route over 8 hours
- route over 10 hours
- unassigned deliveries
- emergency delivery added

## Optimization Priority

The client priority is:

1. Avoid late deliveries, especially hospital deliveries.
2. Avoid overloading the same driver.
3. Fuel cost is secondary.

## Success Criteria

The client would consider the tool successful if:

- Monday mornings are calmer.
- The manager can plan the day in one place.
- Drivers know exactly what they are doing.
- The manager is not rewriting routes three times before 9:00.
- There are fewer phone calls.
- Delays can be explained clearly.
- The manager trusts the tool even on a bad Monday.

## 4. What We Understood

We understood that the problem is not only about finding a route. It is also about planning, visibility, warnings, and traceability.

The manager needs an overview and control. They need to see what is urgent, what is risky, which deliveries are suggested or confirmed, and why a delivery might become late.

The driver does not need to see everything. The driver needs a simple route execution page with their own stops, deadlines, and status updates.

We also understood that a perfect GPS route is not required for the first version. The important part is making the daily planning logic clear and usable for a demo.

## 5. Decisions Made From the Interview

The interview affected the prototype in these ways:

- We created two user roles: manager/admin and driver.
- We included database tables for drivers, vehicles, clients, deliveries, routes, route stops, and zone travel times.
- We used the delivery statuses: Pending, Assigned, In progress, Delivered, Delayed, and Failed.
- We used zone-based travel times instead of real GPS.
- We made route generation work by selected date.
- We changed the plan workflow so generated routes are draft suggestions first.
- We added a manager review and confirmation step before drivers receive routes.
- We allowed the manager to adjust suggested drivers and vehicles.
- We added a refrigerated vehicle rule because no other vehicle can replace it.
- We added an emergency flag and emergency event visibility.
- We added warnings for late risk, wrong vehicle type, refrigerated delivery problems, route overload, driver hours, unassigned deliveries, and emergency deliveries.
- We added a driver route page so each driver only sees their own confirmed route.

## 6. Assumptions

- Fake realistic client names are used.
- Real addresses and real client names are not used.
- The first prototype does not use real GPS.
- Travel time is estimated by zone.
- One driver keeps one vehicle for the whole day.
- Route assignments are suggested by the prototype and confirmed by the manager.
- The manager decides emergency changes instead of the system automatically changing routes.
- The prototype is decision-support software, not production software.

## 7. Final Summary

The interview helped us transform an informal business problem into a structured delivery planning prototype. It showed that MediRun should not only generate routes, but also help the manager understand priorities, risks, vehicle constraints, driver workload, and delay reasons.

The final prototype direction is therefore focused on daily planning, route visibility, warnings, and simple driver execution.
