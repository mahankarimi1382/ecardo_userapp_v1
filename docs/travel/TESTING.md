# Travel Testing

Updated: July 28, 2026.

## Environment

- Local server SDK: `/root/flutter` (`3.44.6` when inspected).
- CI SDK: Flutter `3.44.0`.
- Use the repository lockfile and configured localization generation.
- If pub/storage connectivity fails, use the documented China mirrors.

## Validation Order

Start narrow, then broaden:

```bash
/root/flutter/bin/flutter pub get
/root/flutter/bin/flutter gen-l10n
/root/flutter/bin/dart format --output=none --set-exit-if-changed lib test
/root/flutter/bin/flutter analyze
/root/flutter/bin/flutter test
/root/flutter/bin/flutter build apk --release
```

Dependency installation and production-affecting operations require the server
approval rules in `OPERATIONS.md`.

## Required Unit Tests

- Defensive money/date/null parsing.
- Raw-to-presentation status mapping, especially unknown values.
- Service capability and data-mode purchase gating.
- Room/night and adult/child fare totals.
- Reservation deadline and expiry transitions.
- Wallet currency selection and shortage choices.
- Search filter/sort state.
- Cancellation estimate version/expiry behavior.

## Required Widget Tests

- Hotel and flight search validation.
- Search summary/edit/cancel.
- Results empty/error/retry and scoped offer loading.
- Room/fare selection.
- Traveler/contact validation.
- Final review acknowledgement.
- Reserve, countdown, expiry, retry, and payment states.
- Paid-pending versus issued artifact behavior.
- QR before PDF on confirmation and purchased pages.
- Cancellation estimate, confirmation, receipt, and refund timeline.

## Integration Matrix

Cover:

- Hotel, flight, and eSIM.
- Catalog and live capability modes.
- Sufficient wallet, insufficient wallet, exchange, add money, no wallet.
- Hold active, expired, price changed.
- Payment failed before charge, processing, received/pending supplier, issued,
  inventory unavailable with funds safe, refunded.
- English, Persian, Arabic, Russian, Chinese.
- RTL/LTR and mixed provider scripts.
- Android and web.

Use sanitized fixtures. Never commit real tokens, contacts, passports, booking
references, provider credentials, or production responses containing PII.

## Web Smoke Tests

- Root and direct-route load/refresh.
- API CORS preflight, including `X-Locale`.
- Correct JavaScript and WASM MIME types.
- No HTML fallback for DDC/module files.
- Firefox and Chromium startup.
- Keyboard/focus behavior.
- Responsive narrow and wide layouts.
- Local resources when CDN access is constrained.

Experimental DWDS hot reload previously crashed Firefox. Test normal web serving
separately from debugging/hot reload.

## CI State

`.github/workflows/flutter.yml` now:

- Fails normally when analysis or Android release build fails.
- Preserves analysis/build logs through `if: always()` artifact upload.
- Reads deployment authorization from `ECARDO_DEPLOY_SECRET`.
- Skips deployment when the secret is unavailable.
- Fails the deployment request on HTTP errors while retaining the existing
  non-blocking deployment step.

The previously embedded credential must still be considered exposed and rotated
in the receiving deployment system.

## Current Coverage

The focused Travel suite covers:

- Raw order status mapping and lifecycle action safety.
- Safe error presentation without raw exception leakage.
- Reservation, payment, and refund idempotency-key reuse across retries.
- Payment-key reset after an expired reservation is explicitly abandoned.
- Mixed-script and neutral-text RTL/LTR direction behavior.

Broader screen-level widget and integration coverage remains incremental work,
especially full search forms, checkout rendering, and backend-driven timelines.
