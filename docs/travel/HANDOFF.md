# Travel Handoff

## Work Completed

The previous partial Travel widgets were replaced with a feature-based mini-app. The new implementation provides design-aligned home, hotel, flight, eSIM, wallet checkout, confirmation, bookings, travelers, account, personal-information navigation, and combined history experiences.

The intentional first-party gateway `https://trip.ecardo.ir/api/v1` is preserved in `TravelApiRepository`. It is the public eCardo edge API; downstream provider configuration remains outside Flutter. Flutter now consumes `/travel/bootstrap` and the normalized `/travel/services/{service}/search` routes for hotel, flight, and eSIM discovery. Service visibility, order, labels, descriptions, presentation content, field hints, and mock/live mode come from the backend.

Hotel, flight, and eSIM search controls are editable. Hotel search submits destination, dates, rooms, adults, and children. Flight search submits origin, destination, departure date, adults, and children. eSIM search submits the selected country code. Results no longer depend on hardcoded Tehran, Istanbul, or Turkey values.

The Travel wallet display now selects the shared default wallet, falling back to the IRR wallet only when no default is marked. Returning from add money and completing a payment refreshes both the shared wallets and user state.

Mock-mode offers can be browsed but cannot be purchased. This deliberately removes the previous fake flight/eSIM success path and also prevents demo hotel offers from reaching wallet checkout. A purchase becomes available only when the corresponding backend service is marked live and a supported wallet purchase route exists.

`BaseRoute.travel` now uses `TravelBinding`, so `TravelController` follows the application's established GetX route lifecycle instead of being created inside a widget build.

Static review confirmed no `git diff --check` errors. The live bootstrap and normalized search endpoints were checked read-only on July 26, 2026.

The first release build reached Dart compilation and exposed an ambiguous `Response` import between Dio and GetX in `TravelApiRepository`. The GetX import now hides `Response`, leaving the repository's typed response explicitly resolved to Dio. The release build must be rerun in CI to confirm the next build stage.

Travel personal information opens the authenticated profile editor at `BaseRoute.profileSettings`; the signup-only `BaseRoute.personalInfo` route is intentionally not used.

## Files Changed

- `lib/src/app/routes/routes_config.dart`
- `lib/src/app/routes/routes_handler.dart`
- `lib/src/app/bindings/app_bindings.dart`
- `lib/l10n/app_en.arb`
- `lib/src/presentation/screens/travel/core/`
- `lib/src/presentation/screens/travel/home/`
- `lib/src/presentation/screens/travel/hotels/`
- `lib/src/presentation/screens/travel/flights/`
- `lib/src/presentation/screens/travel/esim/`
- `lib/src/presentation/screens/travel/bookings/`
- `lib/src/presentation/screens/travel/travelers/`
- `lib/src/presentation/screens/travel/account/`
- `lib/src/presentation/screens/travel/shared/`
- `docs/travel/`

## Known Limitations

- Hotel, flight, and eSIM discovery use normalized gateway responses. The currently deployed bootstrap marks all three services as `mock`, so purchasing is intentionally unavailable.
- Live order history, token exchange, hotel booking, and hotel wallet payment remain connected, but checkout is gated while the hotel service is in mock mode.
- Destination, date, room, guest, origin, passenger-count, and eSIM country controls are editable. Autocomplete datasets and filters remain product follow-ups.
- Saved travelers are hidden from the account hub until backend persistence endpoints are available. No fake personal traveler records are shown.
- My hotels, My flights, and My eSIMs use filtered views of one normalized order collection; server-side pagination and filters remain a backend follow-up.
- Voucher/ticket downloads, QR codes, and secure eSIM installation values require backend artifacts.
- English is the complete initial Travel locale; Persian, Arabic, Russian, and Chinese translations remain pending.
- Generated localization Dart files were intentionally not modified.
- The first CI/build step must regenerate localizations from `lib/l10n/app_en.arb` before compilation because generated localization Dart files are tracked but were intentionally not edited manually.
- The latest CI release build stopped at the now-fixed Dio/GetX `Response` import conflict; a post-fix release build has not yet run.

## Exact Next Steps

1. Connect flight and eSIM wallet purchase payloads after the backend publishes stable request/response schemas and marks those services live.
2. Connect saved-traveler and combined activity endpoints.
3. Add destination and airport autocomplete datasets, filters, and offer revalidation.
4. Translate Travel ARB keys for all supported locales.
5. Add automated tests and run the repository's Flutter generation/analyze/build workflow in CI.
6. Perform RTL/LTR device QA against every supplied design page.

## Commands Intentionally Not Run

- `flutter gen-l10n`
- `flutter analyze`
- `flutter test`
- `flutter build`
- Any other Flutter command
- `git push`
- Package installation commands
- Production service restart or reload commands

No production service, FASTPANEL configuration, website deployment, ownership, permission, secret, dependency, Git remote, or Git index changes were made.
