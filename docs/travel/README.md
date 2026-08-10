# eCardo Travel Documentation

Updated: July 28, 2026.

This directory is the durable handoff for the Travel mini-app inside the main
eCardo Flutter application. It covers hotels, flights, eSIM, wallet checkout,
reservations, purchased bookings, vouchers, cancellation, and refunds.

## Start Here

Read in this order:

1. [HANDOFF.md](HANDOFF.md) — current state, repositories, environments, and next work.
2. [CURRENT_WORKFLOWS.md](CURRENT_WORKFLOWS.md) — what users can do today.
3. [SNAPPTRIP_RESEARCH.md](SNAPPTRIP_RESEARCH.md) — verified benchmark research.
4. [BENCHMARK_WORKFLOWS.md](BENCHMARK_WORKFLOWS.md) — SnappTrip/Flytoday workflow adaptation.
5. [UX_GAP_ANALYSIS.md](UX_GAP_ANALYSIS.md) — gaps between the current app and the desired workflow.
6. [ROADMAP.md](ROADMAP.md) — phased delivery plan.
7. [TASKS.md](TASKS.md) — implementation-ready backlog and acceptance criteria.
8. [API_CONTRACT.md](API_CONTRACT.md) — deployed and proposed backend contracts.
9. [ARCHITECTURE.md](ARCHITECTURE.md) and [SCREEN_MAP.md](SCREEN_MAP.md) — code and screen maps.
10. [TESTING.md](TESTING.md), [OPERATIONS.md](OPERATIONS.md), and [DECISIONS.md](DECISIONS.md).
11. [CHANGELOG.md](CHANGELOG.md) — travel-specific implementation history.

## Sources of Truth

- Main Flutter repository: `/root/ecardo_userapp_v1`
- Authoritative branch: `main`
- Baseline commit: `cdacde4`; current batch updated August 3, 2026
- Travel Flutter root: `lib/src/presentation/screens/travel/`
- Public API gateway: `https://trip.ecardo.ir/api/v1`
- Production backend root: `/var/www/fastuser/data/www/travel-origin.ecardo.ir`
- Disposable web-development copy: `/root/ecardo_webapp`
- Flutter SDK on this server: `/root/flutter`

Changes intended for Android must land in `/root/ecardo_userapp_v1`.
`/root/ecardo_webapp` is not a second product or authoritative repository.

## Product Rules

- The backend is authoritative for price, currency, availability, rules,
  reservation deadlines, cancellation eligibility, penalties, refundable
  amount, scarcity, and order status.
- Do not fabricate supplier facts, guarantees, discounts, refund times, or
  voucher data.
- Reuse interaction principles from benchmark products; do not copy their
  branding, text, layouts, or visual identity.
- Prefer clearer communication and recovery over adding more disconnected
  screens.
- All visible strings must be localized and all flows must work in RTL and LTR.
