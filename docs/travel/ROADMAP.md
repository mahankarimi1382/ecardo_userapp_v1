# Travel Roadmap

## Completed

- Replaced the partial Travel widgets while preserving the intentional first-party `trip.ecardo.ir` gateway boundary.
- Added feature-based folders and normalized domain models.
- Added a repository interface and isolated remaining traveler-only demo data.
- Added `TravelApiRepository` for bootstrap, normalized service discovery, order, token-exchange, booking, and wallet-payment contracts.
- Added design-aligned hotel, flight, and eSIM flows.
- Added default-main-wallet selection, insufficient-balance routing, duplicate-tap protection, and shared wallet refresh.
- Removed fake flight/eSIM purchases and gated every mock-mode service from checkout.
- Removed fake traveler records from the connected account flow.
- Preserved `BaseRoute.travel` and unrelated route definitions.
- Added complete initial English localization keys.
- Added architecture, screen map, API contract, tasks, and handoff documentation.
- Completed static ARB, localization-key, import-target, remnant, and whitespace validation.

## Current Phase

- Backend contract review with the eCardo API team.
- Translation of Travel keys for Persian, Arabic, Russian, and Chinese.

## Backend Dependencies

- Live-mode bootstrap configuration for each purchasable service.
- Stable offer-revalidation endpoints and purchase payload schemas.
- Flight and eSIM booking/payment endpoints; deployed hotel booking and wallet payment are connected.
- Order artifact endpoints for vouchers, tickets, and eSIM installation.
- Shared traveler CRUD and combined activity endpoint.
- Optional shared wallet refresh event; checkout currently refreshes the shared user after add-money return.

## Future Phases

1. Connect live flight and eSIM wallet purchasing when stable payload schemas are published.
2. Replace saved-traveler and combined-history mock content.
3. Add destination autocomplete, traveler selection, and filters.
4. Add order type/status filters and secure artifact download/share actions.
5. Add unit, widget, golden, RTL/LTR, repository contract, and checkout idempotency tests.
6. Run Flutter generation, analysis, build, and device QA in CI after approval.
7. Release behind the existing Travel addon flag with monitoring and rollback controls.
