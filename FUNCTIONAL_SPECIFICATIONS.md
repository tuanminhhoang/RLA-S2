# MediRun Functional Specifications

## Objective

Build a decision-support prototype that helps a manager plan medical deliveries, review suggested drivers and vehicles, identify risks, confirm the final plan, and give drivers a clear route list.

## Technical Stack

- Backend: Python and Flask.
- Frontend: HTML, CSS, JavaScript, Jinja templates.
- Database: MySQL.
- Data access: PyMySQL.
- Authentication: Flask sessions and Werkzeug password hashing.

## Main Users

## Manager

The manager can:

- View delivery summaries.
- View and filter deliveries.
- View drivers and vehicles.
- Generate draft daily route suggestions.
- View route results before confirming them.
- Adjust suggested driver and vehicle choices.
- Confirm the final plan so drivers can see their routes.
- Add emergency deliveries.
- See warnings and late-risk information.

## Driver

The driver can:

- View only their manager-confirmed route.
- See vehicle and stop information.
- See client, destination, deadline, priority, and refrigerated requirement.
- Update stop status.

## Input Parameters

- Delivery date.
- Client name and type.
- Zone: warehouse, Paris, suburb, hospital.
- Priority: urgent, normal, low.
- Deadline.
- Package size.
- Package weight.
- Refrigerated requirement.
- Service time per stop.
- Driver availability.
- Vehicle availability.
- Vehicle size.
- Vehicle refrigerated capability.
- Zone travel time.

## Constraints And Relationships

- One driver keeps one vehicle for the day.
- Vehicles are not swapped during a route.
- Refrigerated deliveries require a refrigerated vehicle.
- Large packages should use large vehicles.
- Urgent deliveries should be planned before normal and low deliveries.
- Deadlines should be checked against estimated arrival times.
- Driver work should normally stay below 8 hours.
- Driver work above 10 hours is a serious warning.
- Each suggested route is saved with ordered route stops.
- Suggested routes stay in draft/planning status until the manager confirms them.
- Drivers only see confirmed/active routes.

## Scaling Factors

- Normal day: 45 to 50 deliveries.
- Busy Monday: 55 to 60 deliveries.
- Current prototype seed data: smaller demonstration set.
- Regular locations: about 35.
- Drivers: 5.
- Vehicles: 6.

## Current Prototype Limit

The prototype uses zone-based estimated travel times instead of real GPS or map routing. This is intentional for the first version because the project goal is planning support, not real-time navigation.
