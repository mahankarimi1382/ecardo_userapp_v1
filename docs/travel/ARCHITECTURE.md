# eCardo Travel Architecture

## Purpose

eCardo Travel is a mini-app inside the main eCardo Flutter application. It reuses the authenticated user, main wallet balance, personal information, saved travelers, localization, and GetX navigation conventions. It does not connect directly to travel providers.

## Module Boundaries

- `travel/core`: domain models, repository interfaces, mock repository, and shared controller state.
- `travel/home`: Travel dashboard and service entry points.
- `travel/hotels`: hotel search, results, and details.
- `travel/flights`: flight search, results, and passenger/fare review.
- `travel/esim`: eSIM introduction and package selection.
- `travel/bookings`: wallet checkout, booking lists, vouchers, tickets, and activation details.
- `travel/travelers`: saved traveler presentation.
- `travel/account`: account hub and combined travel/wallet history.
- `travel/shared`: design tokens, responsive cards, fields, formatting, and product helpers.

The existing `BaseRoute.travel` route remains the single super-app entry. `TravelBinding` owns the feature controller lifecycle, and feature screens use GetX widget navigation internally so unrelated app routes remain unchanged.

## Data and Repository Layers

Widgets depend on `TravelController`, which depends on the `TravelRepository` interface. `TravelApiRepository` targets the first-party public gateway at `https://trip.ecardo.ir/api/v1`. `HybridTravelRepository` uses that gateway for the currently exposed hotel catalog, orders, token exchange, booking creation, and wallet payment flows; realistic mock data remains behind the same interface for flight, eSIM, saved-traveler, and combined-history capabilities that the gateway does not expose yet.

Provider payloads must be translated by the eCardo backend into the domain shapes represented by:

- `TravelOffer`
- `TravelEsimPackage`
- `TravelTraveler`
- `TravelOrder`
- `TravelActivity`
- `TravelMoney`

`trip.ecardo.ir` is an intentional first-party eCardo API boundary, not a supplier endpoint. Flutter must never branch on downstream provider names, provider URLs, provider status codes, or provider-specific price fields.

## Localization and Direction

Visible interface copy is represented by keys in `lib/l10n/app_en.arb`. English is the complete initial Travel locale. Other locale ARBs can be translated incrementally through the repository's normal localization workflow.

Screens inherit locale direction from the application. Direction-aware padding and alignment use `EdgeInsetsDirectional`, `AlignmentDirectional`, and `PositionedDirectional`. Prices, booking references, airport codes, passport values, routes, and times use explicit LTR direction where required.

Generated localization Dart files are not edited manually.

## Wallet Checkout

Travel checkout always selects the main eCardo wallet and reads its balance from the shared `HomeController`.

The intended live sequence is:

1. Request or revalidate a normalized offer through `trip.ecardo.ir`.
2. Create a booking/payment intent with an idempotency key.
3. Display the backend-confirmed total and selected main wallet.
4. Submit wallet payment once.
5. Poll or retrieve the resulting order.
6. Render a voucher, ticket, or eSIM activation artifact.

The checkout controller blocks duplicate taps and reuses an active idempotency key until the request succeeds. If the wallet balance is insufficient, checkout routes to `BaseRoute.addMoney` and refreshes its local balance display when the user returns.

Live hotel catalog, order history, booking creation, and wallet payment never fall back to mock records. Booking creation also verifies that the authoritative payable amount and currency still match the displayed gateway offer before wallet capture. Failures remain failures and are shown to the user.

Travel access tokens are cached only until shortly before the gateway-provided expiration time. Payment responses must reach an explicit paid/booked/completed state before Flutter presents success.

Flutter totals are presentation values only. The live backend must remain authoritative for availability, pricing, taxes, currency, payment, and order status.

## Backend-Driven UI Principles

- Bootstrap responses should control feature availability, ordering, badges, supported destinations, and operational messages.
- Search schemas should provide normalized field constraints and selectable values.
- Offer responses should contain normalized display blocks, pricing, policies, and permitted actions.
- Action identifiers should be stable eCardo action keys, not provider URLs.
- Remote image URLs may be returned only from trusted eCardo-normalized content.
- Unknown optional fields must be ignored safely.
- New provider capabilities should be mapped server-side without requiring provider logic in Flutter.
