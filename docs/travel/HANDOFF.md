# eCardo Travel Development Handoff

Updated: July 28, 2026.

## Current State

The Travel mini-app is implemented in the main Android repository and consumes
the first-party gateway at `https://trip.ecardo.ir/api/v1`. The August 3, 2026
working tree contains the completed communication-foundation batch pending
review and commit.

Implemented:

- Hotel, flight, and eSIM discovery.
- Provider-neutral offer details.
- Hotel room selection and flight fare detail.
- Beneficiary choice.
- Reserve-then-pay workflow with timed reservation.
- Matching-currency wallet, Add Money, Exchange, and Create Wallet routing.
- Purchased bookings, rich QR/PDF voucher, cancellation/refund request.
- Shared Travel navigation and mixed-script RTL/LTR handling.
- Generated localization classes for English, Persian, Arabic, Russian, and
  Chinese with complete key coverage.
- Explicit safe order states, lifecycle grouping, scoped recovery, staged
  checkout review, stable retry idempotency, and focused automated tests.
- One-way and round-trip flight search with cabin, adult, child, and infant
  criteria; round trips select and price outbound and return offers separately.
- Per-passenger identity capture and required booking notification contact,
  forwarded to the catalog-order contract before wallet reservation.
- Authenticated primary-traveler and phone reuse, with profile updates before
  flight reservation.

Backend-dependent or later work:

- Server-normalized search suggestions, recent searches, and maps.
- Reusable saved-traveler CRUD and server-driven variations of passenger fields.
- Authoritative cancellation eligibility, refund estimate, and event timeline.
- Saved companion persistence and combined wallet/travel activity.
- Robust eSIM installation and activation.
- Meaningful automated Travel tests.

## Code Map

- Binding: `lib/src/app/bindings/app_bindings.dart`
- Routes: `lib/src/app/routes/routes.dart`
- Controller: `lib/src/presentation/screens/travel/core/controller/travel_controller.dart`
- Repository interface: `lib/src/presentation/screens/travel/core/data/travel_repository.dart`
- API repository: `lib/src/presentation/screens/travel/core/data/travel_api_repository.dart`
- Models: `lib/src/presentation/screens/travel/core/models/travel_models.dart`
- Checkout: `lib/src/presentation/screens/travel/bookings/travel_checkout_screen.dart`
- Orders/vouchers: `lib/src/presentation/screens/travel/bookings/`
- Hotels, flights, eSIM: sibling feature directories under the Travel root.

## Backend State

Production root: `/var/www/fastuser/data/www/travel-origin.ecardo.ir`.

The service-domain migrations are applied. On July 28, 2026, public bootstrap
returned HTTP 200. Hotel and flight reported `data_mode: catalog` with
`search`, `offer_details`, and `catalog_checkout`.

Scheduled backend work:

- `travel:reservations:expire` every minute.
- `travel:hotel:reconcile --minutes=5` every five minutes.
- `travel:settlements:generate` daily.

Rollback files: `/root/ecardo-travel-deploy-backup-20260727-173018`.
This backup does not include a database dump.

## Web Preview History

- Development copy: `/root/ecardo_webapp`
- LAN URL: `http://192.168.100.65:8091`
- Public proxy: `https://flutter.ecardo.ir`
- Flutter SDK: `/root/flutter` (`3.44.6`, Dart `3.12.2` when inspected)
- CI Flutter: `3.44.0`
- China mirrors:
  - `PUB_HOSTED_URL=https://pub.flutter-io.cn`
  - `FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn`

Experimental web hot reload was disabled after a Firefox/DWDS `_JsonMap`
injected-client crash. The preview used local web resources, skipped unsupported
Firebase messaging/local-notification initialization, and added safe root and
unknown routes for GetX.

If DDC assets return HTML with MIME errors, a stale or not-yet-ready development
server is usually answering the port. Verify port ownership, terminate the old
process group, and wait for “lib/main.dart is being served” before loading.

CORS was configured to allow the LAN/public preview origins and `X-Locale`.
Reverify it rather than assuming it survived later deployment changes.

## Known Correctness Risks

1. Refund UI can request review but cannot show authoritative eligibility,
   penalty, amount, or timing.
2. `TravelTraveler` and `TravelBookingDetails` are insufficient for real
   passenger and multi-room guest workflows.
3. The previously embedded deployment credential must still be rotated in the
   receiving system even though CI now reads `ECARDO_DEPLOY_SECRET`.

## Recommended Continuation

Continue with backend contracts in [ROADMAP.md](ROADMAP.md), particularly
normalized suggestions, traveler/contact schemas, cancellation eligibility,
order events, and secure eSIM artifacts. Do not fabricate these facts in
Flutter while the contracts are unavailable.
