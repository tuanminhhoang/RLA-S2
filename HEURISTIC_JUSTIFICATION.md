# MediRun Heuristic Justification

## Chosen Approach

The prototype uses a simple greedy planning heuristic.

This means the system makes practical local decisions in a clear order instead of trying to solve a full vehicle routing optimization problem.

## Why This Fits The Prototype

The project is a decision-support prototype. The goal is to show that the system can structure the manager's planning work, not to produce mathematically optimal routes or remove the manager's control.

A greedy heuristic is suitable because:

- It is easy to explain.
- It is deterministic.
- It works with simple zone travel times.
- It can be implemented and tested quickly.
- It reflects how a manager might manually prioritize deliveries.

## Algorithm Logic

1. Select pending deliveries for the chosen date.
2. Sort deliveries by priority.
3. Prioritize refrigerated deliveries.
4. Sort by earliest deadline.
5. Match each delivery to a compatible driver and vehicle assignment.
6. Prefer refrigerated vehicles for refrigerated deliveries.
7. Prefer small vans for Paris/light deliveries.
8. Prefer large vans for suburb/heavy deliveries.
9. Estimate travel time using zone-to-zone travel times.
10. Add service time at each stop.
11. Save draft route suggestions and ordered route stops.
12. Let the manager review and adjust suggested drivers or vehicles.
13. Confirm the plan before drivers can see their assigned routes.
14. Generate warnings when deadlines, vehicle rules, or driver hours are at risk.

## Warning Examples

- Late delivery risk.
- Refrigerated delivery not assigned correctly.
- Wrong vehicle type.
- Too many stops for one vehicle.
- Route over 8 hours.
- Route over 10 hours.
- Unassigned delivery.

## Future Improvement

A future version could use a known vehicle routing problem algorithm or integrate a routing API. That would allow the system to consider exact road distances, traffic, and route re-optimization after emergencies.
