# Travel Handoff

## Work Completed

The previous partial Travel widgets were replaced with a feature-based mini-app. The new implementation provides design-aligned home, hotel, flight, eSIM, wallet checkout, confirmation, bookings, travelers, account, personal-information navigation, and combined history experiences.

The intentional first-party gateway `https://trip.ecardo.ir/api/v1` is preserved in `TravelApiRepository`. It is the public eCardo edge API; downstream provider configuration remains outside Flutter. `HybridTravelRepository` uses live hotel catalog, order, token-exchange, booking, and wallet-payment routes and uses mock data only for gateway capabilities that are not yet exposed.

`BaseRoute.travel` now uses `TravelBinding`, so `TravelController` follows the application's established GetX route lifecycle instead of being created inside a widget build.

Static review confirmed valid JSON in all existing ARB files, complete coverage for all used Travel localization keys in the English template, no missing local import/export targets, no old provider/path remnants, and no `git diff --check` errors.

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

- Flights, eSIM, saved travelers, and combined history remain mock-backed until their normalized gateway endpoints are exposed.
- Live hotel catalog, order history, booking creation, and wallet payment never show mock fallback records or a fake live success.
- Hotel dates are editable with the existing date picker; the current deployed catalog filter is Tehran (`THR`). Destination, room, guest, passenger, and filter selectors remain product follow-ups.
- Saved traveler add/edit actions work against the mock repository; backend validation and persistence remain pending.
- My hotels, My flights, and My eSIMs use filtered views of one normalized order collection; server-side pagination and filters remain a backend follow-up.
- Voucher/ticket downloads, QR codes, and secure eSIM installation values require backend artifacts.
- English is the complete initial Travel locale; Persian, Arabic, Russian, and Chinese translations remain pending.
- Generated localization Dart files were intentionally not modified.
- The first CI/build step must regenerate localizations from `lib/l10n/app_en.arb` before compilation because generated localization Dart files are tracked but were intentionally not edited manually.

## Exact Next Steps

1. Expand `TravelApiRepository` for flight, eSIM, saved-traveler, and activity endpoints as they are exposed.
2. Add richer bootstrap, destination search, and offer-revalidation responses to the gateway.
3. Add editable destination, room, guest, passenger, and filter controls.
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
