# MediRun Next Version PRD

## Product Goal

Improve MediRun from a planning prototype into a stronger delivery operations tool with better route optimization, emergency handling, and proof of delivery.

## Users

- Manager: plans routes, monitors risks, handles emergencies.
- Driver: follows assigned route and updates delivery status.

## Current Limitations

- Travel time is zone-based, not road-based.
- Route generation is greedy, not globally optimized.
- Emergency deliveries are created but do not automatically recalculate existing routes.
- Driver location is simulated, not real.
- Proof of delivery is not captured.

## Proposed Improvements

## 1. Real Travel Times

Integrate a map or routing API to estimate travel times using road distance and traffic.

## 2. Vehicle Routing Optimization

Replace or extend the greedy heuristic with a vehicle routing problem approach. A future developer could explore Google OR-Tools for route optimization.

## 3. Emergency Re-Routing

When an emergency arrives, the system should identify the closest suitable vehicle and update that driver's route.

## 4. Driver Notifications

Notify a driver when a route changes or an emergency stop is added.

## 5. Proof Of Delivery

Allow drivers to upload a photo, signature, or note after a successful delivery.

## Success Criteria

- Route plans reduce late-risk warnings.
- Emergency assignment suggests a suitable vehicle in under 5 seconds.
- Drivers can complete all status updates from mobile.
- Manager can explain why a route was generated.
- The system keeps an auditable history of route changes.
