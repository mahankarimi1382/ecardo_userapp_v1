# eCardo Travel Development Handoff

Updated on July 26, 2026.

## July 27, 2026 Expanded Booking Workflow

The Flutter source now uses explicit hotel room selection instead of treating a
hotel catalog result as the purchased product. Room price is calculated as:

```text
room nightly price × room count × night count
```

Flight checkout now uses adult and child fare components and preserves airline,
flight number, airports, departure/arrival time, cabin, baggage, segments, and
cancellation rules in cards, details, orders, and generated vouchers.

Catalog checkout is split into reservation and payment steps. The backend
returns `payment_due_at`; Flutter shows a countdown and pays the existing order
instead of creating another one. The service configuration exposes a
`reservation_hold_minutes` value from 5 through 60 minutes. Travel Origin runs
`travel:reservations:expire` every minute and marks unpaid expired reservations
failed/expired. Catalog mode still does not claim to lock supplier inventory;
live providers must implement and release their own supplier reservation.

Checkout supports purchasing for the signed-in customer or another named
beneficiary. The beneficiary and selected room are stored in the order product
snapshot. Wallet checkout automatically targets the offer currency and suggests
the best funded different-currency wallet as the exchange source when the
matching wallet is short.

All Travel screens share the same footer, including a direct main-app Home
action. Provider-originated Persian/Arabic, Latin/Cyrillic, and Chinese strings
use first-strong-character direction detection so mixed supplier content does
not inherit the wrong paragraph direction.

Confirmed hotel and flight records can generate a downloadable PDF voucher from
the confirmation page or booking history. The file includes order details and a
QR payload containing the eCardo Travel order identity and amount.

Production backend/admin backup:

```text
/root/ecardo-travel-deploy-backup-20260727-173018
```

Flutter CI must still run localization generation, formatting, analysis, tests,
and builds. The server does not have Flutter or Dart installed.

## Scope Completed

This change completes the requested Flutter-side Travel navigation, locale
propagation, provider-detail rendering, upcoming-flight discovery, wallet
selection, wallet return navigation, and catalog/sandbox checkout integration.
It also adds the supporting production Travel Origin API route and enables the
explicit `catalog_checkout` capability for the Hotel and Flight service
records.

Flutter remains a consumer of the first-party gateway:

```text
https://trip.ecardo.ir/api/v1
```

It does not read provider files directly and does not perform a supplier
purchase. Catalog checkout captures the authoritative catalog price from the
matching eCardo wallet and leaves the order pending manual admin confirmation.

## Persistent Travel Navigation

`TravelPage` owns a shared `TravelBottomNavigation` footer with three root
sections:

- Dashboard: `BaseRoute.travel`
- History: `BaseRoute.travelHistory`
- Account: `BaseRoute.travelAccount`

Every screen built with `TravelPage` receives the toolbar by default. Detail
and checkout screens can still supply their fixed action footer; `TravelPage`
stacks that action above the persistent Travel toolbar instead of replacing it.

Root tab changes use `Get.offNamed()`. This removes only the current Travel
screen and does not clear the entire application stack, so the user can still
leave Travel through the normal app navigation. Detail-to-root navigation does
not retain the detail screen as the immediate back destination, which is the
desired tab behavior.

## Locale Propagation

Flutter now sends the active two-letter language code for:

- Travel bootstrap
- Hotel search
- Flight search and upcoming-flight discovery
- eSIM search
- Offer details

Discovery requests send both:

```text
locale=<Get.locale.languageCode>
X-Locale: <Get.locale.languageCode>
```

The backend resolver now normalizes mixed-case and regional values. Examples:

```text
en-US -> en
fa_IR -> fa
AR-sa -> ar
```

Unsupported languages still fall back to Persian because that is the existing
Travel Origin policy.

### Translation Limitations

- Only English Travel Flutter strings are currently complete.
- The ARB directory contains `en`, `ar`, `fa`, `ru`, and `zh`, but the checked-in
  generated Flutter localization classes currently contain only English and
  Arabic. Flutter localization generation was intentionally not run.
- Provider/master JSON may contain only Persian or a single source language.
- Some English backend admin translation records contain Persian strings inside
  nested presentation data such as `home_hero`.
- Provider information can match the selected app language only when that
  provider supplies the language or an admin translation exists.
- No missing provider or admin translations were invented in this change.

## Complete Offer Details

`TravelOffer` now preserves provider-neutral detail structures:

```text
product
attributes
policies
actions
pricingComponents
```

`TravelRepository.getOfferDetails()` retrieves:

```text
GET /travel/services/{service}/offers/{offerId}
```

Hotel and flight result taps load the authoritative detail response before
opening the detail view. If detail loading fails, the summary offer remains
available rather than presenting a blank page.

Hotel details defensively render all available provider data:

- Main image and image gallery
- Full provider description
- Address and coordinate affordance
- Minimum and maximum prices
- Pricing components
- Amenities and features
- Room name, type, capacity, extra capacity, and description
- Bed information
- Breakfast/board indicators
- Room price and currency
- Room images
- Review/rating summary
- Provider attributes
- Policies
- Source update timestamp

No provider field is assumed to exist. Empty sections are omitted. The previous
hardcoded hotel description, Wi-Fi/breakfast claims, times, and cancellation
copy are no longer used as hotel facts.

The coordinate affordance copies the provider latitude/longitude and exposes it
with a map icon. A dedicated mapping dependency was not introduced.

## Upcoming Flights

`TravelFlightSearch` route, destination, and date fields are nullable.
`getUpcomingFlights()` submits an empty flight criteria object.

The Flight search screen automatically loads upcoming flights when opened and
shows the nearest available catalog departures below the form. Selecting one
loads its offer details and opens the normal Flight detail screen.

Exact route/date search remains available. If an exact query returns no
results, the results view also exposes the previously loaded upcoming flights
instead of appearing broken.

Travel Origin now:

- Applies `departure_time >= current Tehran time`
- Allows origin and destination independently
- Allows both route fields to be omitted
- Allows the date to be omitted
- Orders results by departure time, then adult price
- Never fabricates a flight

An exact date remains an exact filter. Upcoming results are the discoverable
fallback, not a fabricated match.

## Currency-Specific Wallet Checkout

`TravelController` now provides:

```text
walletForCurrency(currency)
walletBalanceFor(currency)
```

Matching is case-insensitive. Checkout uses `offer.total.currency`; it no
longer silently uses the default wallet or an IRR fallback.

Checkout behavior:

1. If the matching wallet exists and has enough balance, pay from it.
2. If it exists but is insufficient, offer Add Money and Exchange.
3. Add Money receives the matching `wallet_id`.
4. Exchange receives `to_currency` so its controller preselects the required
   destination wallet and selects a funded source wallet when possible.
5. If no matching wallet exists, direct the user to the existing Create Wallet
   workflow.
6. Wallet/user data refresh after returning to checkout.

The backend wallet bridge already transmits amount and currency. The main
eCardo wallet backend remains responsible for selecting the user's wallet with
that currency.

## Return-Route Contract

The reusable `RouteReturn` helper reads:

```dart
{
  'returnRoute': BaseRoute.travel,
}
```

Add Money and Exchange success/back actions use `Get.back()` when their
originating route remains on the stack. Otherwise they replace the current
route with `returnRoute`. Without a supplied return route, the previous main
application behavior remains `BaseRoute.navigation`.

Travel entry points pass the contract from:

- Travel home
- Travel account
- Travel checkout

Successful and pending Add Money result pages also honor it.

## Catalog/Sandbox Purchases

Flutter permits catalog checkout only when the backend service explicitly
advertises either:

```text
catalog_checkout
sandbox_purchase
```

`data_mode == catalog` alone is not enough. Live services continue to recognize
the existing purchase/book/booking/checkout capabilities.

Catalog offers use:

```text
POST /catalog-orders
POST /orders/{order}/pay
```

The create request sends the service, offer ID, hotel dates/counts when
applicable, and available booking metadata. It does not submit a trusted price.

Travel Origin:

- Requires an authenticated customer
- Verifies the service is enabled
- Verifies the explicit catalog checkout capability
- Verifies `master_json` is the configured provider
- Re-reads the offer from `MasterTravelCatalog`
- Uses only authoritative pricing and currency
- Validates hotel dates
- Does not require a traveler profile merely for sandbox checkout
- Stores the normalized offer in `product_snapshot`
- Marks the snapshot `catalog_sandbox` and `manual_confirmation`
- Reuses `Quoted -> PendingPayment`
- Reuses `PaymentService` and the wallet bridge
- Reuses the existing wallet and order idempotency layers
- Ends successful capture at `PaidPendingAdminApproval`
- Does not call a supplier or claim that catalog availability is live

The production Hotel and Flight service records were updated through the
existing `capabilities` field:

```text
["search", "offer_details", "catalog_checkout"]
```

This remains editable in the existing Travel admin capability editor; there is
no hidden data-mode-based enablement.

Order creation uses a stable idempotency key. Each payment attempt uses a new
key so the app can retry after HTTP 402; the create endpoint replays the
existing order instead of creating a duplicate.

## Backend Files Changed

Production application:

```text
/var/www/fastuser/data/www/travel-origin.ecardo.ir
```

Changed:

- `app/Http/Controllers/Api/V1/TravelServiceController.php`
- `app/Http/Controllers/Api/V1/CatalogOrderController.php`
- `app/Services/MasterTravelCatalog.php`
- `app/Services/CatalogOrderService.php`
- `routes/api.php`
- `docs/openapi.yaml`

No migration, dependency install, cache clear, build, service restart,
FASTPANEL change, or supplier purchase was performed.

## Validation And CI

Allowed local validation is limited to:

- `git diff --check`
- PHP syntax checks
- Laravel route inspection
- Read-only API calls
- Ownership/permission inspection

The Flutter SDK is unavailable on this server. Do not run:

```text
flutter gen-l10n
flutter analyze
flutter test
flutter build
```

Git CI must regenerate/check localization output and compile the app. Pay
special attention to the provider-detail widgets and generated localization
coverage because no Flutter tooling was run locally.

## Remaining Work

- Translation team must complete Travel ARB content for Persian, Arabic,
  Russian, and Chinese.
- Flutter CI must regenerate localization classes so all configured locales are
  actually supported.
- Admins must replace Persian nested values in English Travel presentation
  translations.
- Providers or content administrators must supply non-Persian hotel/flight
  master content when localized provider details are required.
- A real supplier flow must revalidate availability and price before any future
  live purchase capability is enabled.
- Catalog orders require the existing manual admin confirmation workflow after
  wallet capture.
- Map launching can be added later with the application's preferred mapping
  package; this change avoids adding a dependency.

## Operational Safety

No Nginx, Apache, PHP-FPM, FASTPANEL, PM2, MariaDB, Redis, DNS, or mail service
was restarted or reloaded. No FASTPANEL configuration was modified. No
production secrets were read or copied.
