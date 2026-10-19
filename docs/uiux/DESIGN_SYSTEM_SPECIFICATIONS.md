# eCardo Design System & Architecture Specifications (U051–U068)

**Document Version:** 1.0  
**Status:** Approved Standard  
**Date:** 2026-10-19  

---

## 1. Status Badge & Banner System (U052)

A unified status taxonomy across all financial operations ensures consistent user comprehension:

| Status Token | Visual Style (Dark / Light) | Icon | Semantics & Rule |
| :--- | :--- | :--- | :--- |
| **Success** | Emerald Glow (`#00D563`) / Pill container | `Icons.check_circle_rounded` | Final settlement confirmed by backend. |
| **Pending** | Amber Alert (`#F59E0B`) / Glass border | `Icons.hourglass_top_rounded` | Never display celebration or green badge. Show tracking ID. |
| **Failed** | Crimson Alert (`#EF4444`) / Error border | `Icons.cancel_rounded` | Explain exact failure reason and provide safe retry action. |
| **Reconciling** | Soft Cyan / Cobalt (`#3B82F6`) | `Icons.sync_rounded` | On-chain confirmations in progress (e.g. TRON 19 blocks). |
| **Frozen** | Frosted Ice (`#60A5FA`) / Neon Ice border | `Icons.ac_unit_rounded` | Card or account frozen. All transactions declined. |

---

## 2. Fee Breakdown & Quote Summary Shared Pattern (U053)

All money movements (Transfer, Cash Out, Exchange, Remittance) adhere to the standardized 5-row breakdown card (`EcardoGlassCard` variant):

1. **Gross / Source Amount:** Explicit currency symbol + amount.
2. **Transfer / Gateway Fee:** Transparently state fee amount or display `Free (رایگان)` in Emerald.
3. **Exchange Rate (if applicable):** Display guaranteed rate with live countdown timer.
4. **Estimated Settlement Time:** (e.g., `Instant (آنی ⚡)` or `1-3 Banking Days`).
5. **Net / Total Debit:** Prominent bold headline with final debit amount.

---

## 3. PII & Secret Redaction Policy (U057)

In compliance with financial privacy regulations and automated test integrity:
- **Logging Filter:** All HTTP logs, error reporters, and analytical telemetry must pass through the PII sanitizer (`workstream_b_idempotency_logging_test.dart`).
- **Keys Redacted:** `password`, `token`, `bearer`, `cvv`, `pin`, `private_key`, `seed_phrase`, `secret`.
- **Card Numbers:** Masked to show only the last 4 digits (`•••• •••• •••• 4242`).

---

## 4. Third-Party License & Asset Compliance (U058)

- **XPay Benchmark Compliance:** All layouts inspired by the XPay Flutter UI kit are clean-room reimplementations built on top of eCardo's native GetX architecture, `AppColors`, and `AppSpacing` tokens.
- **Zero Asset Infringement:** No copyrighted icons, proprietary images, or mock datasets from third-party repositories have been checked into the codebase. All icons utilize Material Icons and custom SVGs.

---

## 5. UI/UX Release Gate Checklist (U060)

Prior to deploying any new tag to staging or production:
1. `flutter analyze` passes with 0 errors and 0 warnings.
2. 100% of unit, widget, and screenshot tests pass without failures.
3. No raw SQL or unformatted backend exception strings are exposed in UI dialogs.
4. Bidirectional RTL rendering verified for Persian (`fa`) and Arabic (`ar`).
5. All financial amounts adhere to explicit decimal precision rules.
6. Local git working tree is clean and committed.
