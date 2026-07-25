# Travel Roadmap

## Completed

- Replaced the partial Travel widgets while preserving the intentional first-party `trip.ecardo.ir` gateway boundary.
- Added feature-based folders and normalized domain models.
- Added a repository interface and realistic mock repository.
- Added `TravelApiRepository` for the live hotel, order, token-exchange, booking, and wallet-payment contract.
- Added design-aligned hotel, flight, and eSIM flows.
- Added main-wallet checkout with insufficient-balance routing and duplicate-tap protection.
- Added voucher, ticket, activation, filtered hotel/flight/eSIM booking lists, travelers, account, and activity screens.
- Added repository-backed mock traveler create and edit behavior.
- Preserved `BaseRoute.travel` and unrelated route definitions.
- Added complete initial English localization keys.
- Added architecture, screen map, API contract, tasks, and handoff documentation.
- Completed static ARB, localization-key, import-target, remnant, and whitespace validation.

## Current Phase

- Backend contract review with the eCardo API team.
- Translation of Travel keys for Persian, Arabic, Russian, and Chinese.

## Backend Dependencies

- Expanded bootstrap/configuration endpoint for the redesigned mini-app.
- Normalized flight and hotel search/revalidation endpoints beyond the current hotel-offer catalog.
- Normalized eSIM destination/package endpoint.
- Flight and eSIM booking/payment endpoints; deployed hotel booking and wallet payment are connected.
- Order artifact endpoints for vouchers, tickets, and eSIM installation.
- Shared traveler CRUD and combined activity endpoint.
- Optional shared wallet refresh event; checkout currently refreshes the shared user after add-money return.

## Future Phases

1. Expand `TravelApiRepository` as new gateway endpoints are exposed.
2. Replace remaining flight, eSIM, saved-traveler, and combined-history mock content.
3. Add editable destination/guest/passenger controls, traveler selection, and filters.
4. Add order type/status filters and secure artifact download/share actions.
5. Add unit, widget, golden, RTL/LTR, repository contract, and checkout idempotency tests.
6. Run Flutter generation, analysis, build, and device QA in CI after approval.
7. Release behind the existing Travel addon flag with monitoring and rollback controls.
