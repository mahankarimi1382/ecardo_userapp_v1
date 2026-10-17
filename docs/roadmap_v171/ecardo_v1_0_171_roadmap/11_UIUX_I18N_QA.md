# UI/UX, Accessibility & Localization QA Matrix

## Route inventory

The repository documentation reports 99 application routes and six locales (`fa`, `ar`, `en`, `ru`, `tr`, `zh`). Treat those as current inventory claims until generated from code and checked against the route registry. Create a machine-readable route-to-feature inventory and assign each critical route to a product owner.

## Critical journey checklist

- onboarding/login, OTP, 2FA, forgot/reset password, logout and session expiry
- KYC flow and document upload
- wallet balance, hide balance, recent transactions, transaction detail and filters
- transfer, withdraw, deposit/top-up, exchange quote/lock/confirmation
- virtual card create/fund/freeze/unfreeze and card-order status
- gateway payment and app resume after returning from browser/webview
- P2P create/pay/release/dispute
- bills, gifts, request money and remittance
- support ticket and attachment handling
- travel search/book/paid/pending/cancelled states
- settings, change language, notifications, app update and maintenance state

## Test dimensions

| Dimension | Required coverage |
|---|---|
| Locale | `fa`, `ar`, `en`, `ru`, `tr`, `zh` |
| Direction | RTL for Persian/Arabic; LTR for other supported locales; isolate numbers/IDs/dates correctly |
| Theme | light and dark |
| Text scale | default, 1.3×, 1.6×/platform accessibility scale; remove arbitrary cap unless justified |
| Screen | compact Android, standard Android, large Android/tablet if supported, current iPhone and older supported iOS |
| Network | normal, high latency, offline, reconnect, packet drop, 401/422/429/500/503 |
| State | initial, loading, empty, partial, pending, success, failure, disabled, retry, session expired |
| Accessibility | TalkBack, VoiceOver, semantics, focus order, contrast, touch target, reduced motion |
| Financial correctness | shown amount/fee/rate/recipient must match canonical server response before and after submit |

## UX rules for money-moving screens

1. Before confirmation display amount, currency, source, destination, fee, exchange rate if applicable, total debit, and irreversibility/expected timing.
2. Once submitted, disable duplicate interaction or make repeat interaction reuse the same operation intent.
3. Timeout/5xx must display `Status pending / checking`, not a fabricated failure or success.
4. Retry and cancel are different actions; cancel is only shown when backend supports a safe cancellation transition.
5. Always display server-confirmed operation status and a support/correlation reference.
6. Color alone must not indicate success/failure.
7. No secrets or financial payloads in client analytics; telemetry is opt-in/consent-aware where required.

## Visual regression procedure

- Capture golden screens from a known CI/device image and fixed synthetic data.
- Review every pixel-diff for critical screens; do not auto-accept all new baselines.
- Record viewport, OS, font/rendering version, locale, theme and test data.
- Add screenshots for error/offline/pending states, not just happy paths.
- Check test stability before enforcing global threshold.

## Acceptance

No critical journey is `DONE` with just one golden file or a successful widget build. Require flow-level functional test plus responsive/i18n/a11y evidence.
