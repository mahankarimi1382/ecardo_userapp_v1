# Travel Tasks

## Completed

- [x] Inspect existing Travel implementation and route integration.
- [x] Review supplied design images and HTML screen titles.
- [x] Preserve the intentional `trip.ecardo.ir` first-party gateway while removing provider-shaped widget logic.
- [x] Create feature-based Travel module structure.
- [x] Add normalized domain models and repository interface.
- [x] Add realistic mock data behind the repository boundary.
- [x] Connect the live hotel catalog, order history, token exchange, booking creation, and wallet payment routes.
- [x] Implement hotel search, results, details, checkout, and voucher flow.
- [x] Implement flight search, results, passenger review, checkout, and ticket flow.
- [x] Implement eSIM introduction, package, checkout, and activation flow.
- [x] Implement filtered hotel/flight/eSIM bookings, saved travelers, account hub, personal-info link, and combined history.
- [x] Implement repository-backed mock saved traveler add/edit actions.
- [x] Reuse existing app bars, button, GetX, localization, and ScreenUtil conventions.
- [x] Add complete initial English Travel localization keys.
- [x] Add durable Travel documentation.
- [x] Validate ARB JSON, localization coverage, import targets, old provider remnants, and diff whitespace.

## Pending Backend

- [x] Confirm deployed gateway endpoint paths and token-exchange behavior.
- [x] Implement the initial `TravelApiRepository`.
- [x] Enforce server-authoritative checkout totals using the deployed order response.
- [x] Connect idempotent hotel booking and wallet payment endpoints.
- [ ] Add a dedicated offer-revalidation endpoint when exposed by the gateway.
- [x] Connect deployed hotel order-history endpoint.
- [ ] Connect future multi-traveler and combined activity endpoints.
- [x] Refresh the shared user wallet balance after returning from add money.
- [ ] Add secure voucher, ticket, and eSIM artifact actions.

## Pending Product and QA

- [ ] Translate Travel keys in `app_fa.arb`, `app_ar.arb`, `app_ru.arb`, and `app_zh.arb`.
- [ ] Confirm exact editable destination, guest, passenger, and filter interactions.
- [x] Integrate the existing date picker for live hotel booking dates.
- [ ] Confirm empty, loading, expired-offer, and payment-failure designs.
- [ ] Add automated repository, widget, RTL/LTR, and checkout idempotency tests.
- [ ] Run localization generation, Flutter analysis, build, and device QA in CI.
- [ ] Validate release behind the Travel addon flag.
