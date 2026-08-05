# eCardo Travel Architecture

## Purpose

eCardo Travel is a mini-app inside the main eCardo Flutter application. It reuses the authenticated user, main wallet, personal information, localization, and GetX navigation conventions. It does not connect directly to travel providers.

## Module Boundaries

- `travel/core`: domain models, repository interface, first-party API repository, and shared controller state.
- `travel/home`: Travel dashboard and service entry points.
- `travel/hotels`: hotel search, results, and details.
- `travel/flights`: flight search, results, and passenger/fare review.
- `travel/esim`: eSIM introduction and package selection.
- `travel/bookings`: wallet checkout, booking lists, vouchers, tickets, and activation details.
- `travel/travelers`: dormant saved-traveler presentation for a future persistence contract.
- `travel/account`: account hub and combined travel/wallet history.
- `travel/shared`: design tokens, responsive cards, fields, formatting, and product helpers.

The existing `BaseRoute.travel` route remains the single super-app entry. `TravelBinding` owns the feature controller lifecycle, and feature screens use GetX widget navigation internally so unrelated app routes remain unchanged.

## Data and Repository Layers

Widgets depend on `TravelController`, which depends on the `TravelRepository` interface. `TravelApiRepository` targets the first-party public gateway at `https://trip.ecardo.ir/api/v1`. Bootstrap and normalized hotel, flight, and eSIM searches always come from this gateway. Flutter does not contain provider selection or provider response conversion logic. Saved travelers remain hidden until a persistence endpoint exists.

Provider payloads must be translated by the eCardo backend into the domain shapes represented by:

- `TravelOffer`
- `TravelEsimPackage`
- `TravelTraveler`
- `TravelOrder`
- `TravelActivity`
- `TravelMoney`

`trip.ecardo.ir` is an intentional first-party eCardo API boundary, not a supplier endpoint. Flutter must never branch on downstream provider names, provider URLs, provider status codes, or provider-specific price fields.

## Localization and Direction

Visible interface copy belongs in the locale ARBs. Generated localization
classes exist for English, Persian, Arabic, Russian, and Chinese, but many
Travel values in non-English locales remain untranslated English. Generated
localization Dart files are not edited manually.

Screens inherit locale direction from the application. Direction-aware padding
and alignment use directional Flutter APIs. Provider-originated mixed-script
text uses first-strong-character direction detection. Prices, booking
references, airport codes, passport values, routes, and times use explicit LTR
direction where required.

## Wallet Checkout

Travel checkout selects a wallet whose currency matches the offer. It does not
fall back to a default or IRR wallet for a different-currency purchase.

The intended live sequence is:

1. Load normalized offer details through `trip.ecardo.ir`.
2. Create a timed reservation with an idempotency key.
3. Verify the backend-confirmed total and currency.
4. Display the reservation deadline and matching-currency wallet.
5. Submit wallet payment once.
6. Retrieve the resulting order.
7. Render a confirmed artifact only when the backend status supports it.

The checkout controller blocks duplicate taps and reuses an active idempotency key until the request succeeds. If the wallet balance is insufficient, checkout routes to `BaseRoute.addMoney` and refreshes both shared wallet and user state when the user returns.

Services marked `mock` by bootstrap can be browsed but cannot reach checkout.
Catalog services require `catalog_checkout` or `sandbox_purchase`; live
services require an explicit purchase capability. Booking creation verifies
that authoritative amount and currency still match the displayed offer before
wallet capture.

Travel access tokens are cached only until shortly before gateway-provided
expiration. Payment receipt and artifact issuance are separate states. Flutter
must communicate pending supplier confirmation instead of treating every
wallet capture as a confirmed booking.

Flutter totals are presentation values only. The live backend must remain authoritative for availability, pricing, taxes, currency, payment, and order status.

## Backend-Driven UI Principles

- Bootstrap responses should control feature availability, ordering, badges, supported destinations, and operational messages.
- Search schemas should provide normalized field constraints and selectable values.
- Offer responses should contain normalized display blocks, pricing, policies, and permitted actions.
- Action identifiers should be stable eCardo action keys, not provider URLs.
- Remote image URLs may be returned only from trusted eCardo-normalized content.
- Unknown optional fields must be ignored safely.
- New provider capabilities should be mapped server-side without requiring provider logic in Flutter.
