# Travel Change Log

Record user-facing Travel changes, API changes, migrations, deployments,
validation, and rollback information here.

## August 3, 2026 — Guided Destination Discovery

- Replaced free-form hotel city and flight airport entry with searchable
  bottom-sheet selectors following the standard travel-booking discovery flow.
- Added popular hotel cities, popular airports, IATA/city/airport matching, and
  debounced search backed by the authoritative master catalog.
- Deployed the public suggestions endpoint without a service restart, reload,
  migration, cache clear, or configuration change.
- Validation: both Flutter copies analyze cleanly, both 18-test Travel suites
  pass, and live hotel/flight suggestion requests return HTTP 200.
- Rollback: `/root/ecardo-travel-suggestions-backup-20260803`.

## August 3, 2026 — Batch Completion and Web Preview

- Completed the documented communication-foundation frontend batch.
- Added benchmark-derived search/compare/review/pay guidance, real successful
  search history, and up-to-three hotel/flight offer comparison.
- Adapted nested backend-localized values to the selected app language while
  preserving provider facts and avoiding mock or inferred inventory data.
- Kept reservation, payment, and refund idempotency keys stable across safe
  retries, and reset payment keys only when an expired hold is abandoned.
- Added focused lifecycle, safe-error, idempotency, and RTL/LTR widget tests.
- Completed localization generation without untranslated-key warnings.
- Synchronized the authoritative Travel implementation into the disposable web
  preview and validated analysis, tests, localization coverage, and web build.
- Connected authenticated primary-traveler/contact loading and reuse in both
  checkout clients, with profile updates before flight reservation.
- Deployed exact flight passenger-manifest enforcement and encrypted traveler
  snapshots to the production Travel backend.

## July 28, 2026 — Communication Foundation Implementation

- Added explicit payment, supplier-confirmation, issued, cancellation, refund,
  expired, and unknown order states.
- Preserved raw backend order status and stopped unknown states from appearing
  completed or exposing vouchers/actions.
- Grouped purchased bookings by lifecycle and kept QR before PDF for issued
  artifacts.
- Preserved hotel/flight search criteria, added editable result summaries,
  result counts, retry/edit empty states, and per-offer loading.
- Added checkout progress, explicit review acknowledgement, visible hold
  countdown, and explicit expired-reservation restart.
- Added focused lifecycle mapping and capability tests.
- Generated localization classes; new English keys still require Persian,
  Arabic, Russian, and Chinese translation.
- Validation: focused Flutter tests pass; targeted Travel analysis has no
  compile errors and retains existing lint warnings.

## July 28, 2026 — Comparison and Booking Discovery

- Added hotel sorting by normalized same-currency price and rating.
- Added hotel rating filters, active chips, reset, and visible/total counts.
- Added flight sorting by normalized price, departure, and parseable duration.
- Added explicit-only airline, cabin, and refundability filters.
- Added purchased-booking search and lifecycle filter chips.
- Preserved upcoming-flight fallback, scoped loading, pull-to-refresh, and
  QR-before-PDF behavior.
- Generated localization keys for comparison controls.
- Validation: the complete Flutter test suite passes and Travel analysis has no
  errors.

## July 28, 2026 — CI, Checkout, and eSIM Communication

- Made Flutter analysis and Android release build fail CI on errors while
  preserving uploaded logs.
- Removed the embedded deployment credential and switched deployment to the
  `ECARDO_DEPLOY_SECRET` GitHub secret with an unavailable-secret skip.
- Cleaned all repository analyzer findings; `flutter analyze --no-pub` reports
  no issues.
- Migrated checkout beneficiary selection to Flutter `RadioGroup`.
- Added a detailed final review using authoritative product, booking, wallet,
  and total data.
- Added clearer eSIM destination results, package comparison, compatibility
  warning, and pending-versus-ready activation messaging.
- Did not fabricate install QR, SM-DP+, or activation credentials.

## July 28, 2026 — Documentation Baseline

- Re-audited the Flutter implementation, backend routes, migrations, scheduler,
  bootstrap capabilities, CI, and preview history.
- Deep-researched current public SnappTrip hotel, flight, tracking, policy,
  cancellation, and recovery workflows.
- Replaced stale handoff, API, roadmap, and task claims.
- Added workflow, UX gap, testing, operations, and decision documentation.
- No production services, backend files, database, or application behavior were
  changed by this documentation update.

## July 27, 2026 — Travel Booking Expansion

- Added room-level hotel selection, passenger fare-aware flight layouts,
  beneficiary selection, timed reservation, wallet/exchange flow, shared
  navigation, RTL/LTR handling, QR/PDF vouchers, and refund request UI.
- Backend backup: `/root/ecardo-travel-deploy-backup-20260727-173018`.
- The backup contains no database dump.

## Entry Template

```text
Date:
Environment:
Flutter commit:
Backend revision/deployment:
User-visible change:
API/migration/scheduler change:
Validation:
Known issues:
Rollback:
Owner/next task:
```
