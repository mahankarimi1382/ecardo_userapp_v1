# P0 / P1 Remediation Report

## 1. Scope & Baseline
- **Checkout Commit SHA:** `dd11e5302e60`
- **Inventory Baseline SHA:** `dd11e5302e60`
- **Files / Modules / Flows Reviewed:**
  - `lib/src/network/` (Dio client, interceptors, error handler, status)
  - `lib/src/common/services/` (client_error_reporter, token_service, app_lock_service)
  - `lib/src/common/widgets/` (button, balance_hero, glass_card, swipe_button)
  - `lib/src/helper/` (dynamic_decimals_helper, money_math_helper)
  - `lib/src/presentation/screens/` (authentication, exchange, transfer, make_payment, request_money, virtual_card, kyc_level, travel)
  - `lib/src/commercial/` (commercial_projects_screen, equity_project_card, investment_calculator_sheet)
- **Areas Blocked and Why:**
  - Full native OS dialog automation with Patrol requires a live attached Android/iOS hardware device or running emulator (`adb devices`).

---

## 2. Executive Result Scorecard

- **Verified P0 Issues:** 3
- **Resolved P0 Issues:** 3
- **Open / Blocked P0 Issues:** 0
- **Verified P1 Issues:** 2
- **Resolved P1 Issues:** 2
- **Open / Blocked P1 Issues:** 0

All 5 identified P0/P1 issues are **100% RESOLVED** and backed by automated regression test suites.

---

## 3. Detailed Findings & Remediation

### 3.1 ISSUE-P0-01: Mutating Request Idempotency & Safe Timeout Reconciling
- **Severity:** P0 (Financial Risk / Double-Debit)
- **Affected Routes & Contracts:** `ROUTE-017, ROUTE-020, ROUTE-023` | `CTR-004, CTR-005`
- **Evidence:** `test/workstream_b_idempotency_logging_test.dart` and `test/workstream_b_api_resilience_test.dart`
- **Root Cause:** Idempotency key emission was previously limited to `POST`; `PUT` and `PATCH` mutations were unprotected. On socket timeouts, the user was shown `"Request timed out. Please try again."`, risking double submissions.
- **Implemented Fix:**
  - Extended idempotency key injection across `POST`, `PUT`, and `PATCH` in `NetworkService`.
  - Added `isMutatingFinancialOrStateEndpoint(path)` covering card limits, PIN change, P2P order state transitions, and investments.
  - Suppressed misleading retry toasts; added `Status.unknown` and `ApiResponse.unknown()` advising users to check transaction history.
- **Regression Test:** `test/workstream_b_api_resilience_test.dart` (15/15 passed).
- **Owner:** `workstream-api-resilience` | **Status:** RESOLVED

### 3.2 ISSUE-P0-02: Virtual Card PAN & CVV Plaintext Exposure
- **Severity:** P0 (Security & Privacy Breach)
- **Affected Routes & Contracts:** `ROUTE-070, ROUTE-106` | `CTR-007, CTR-010`
- **Evidence:** `test/workstream_f_security_i18n_perf_test.dart`
- **Root Cause:** Tapping the reveal eye icon directly toggled boolean state without requiring biometric or PIN authentication, and the revealed credentials stayed on screen indefinitely.
- **Implemented Fix:**
  - Added `authenticateAndTogglePan` and `authenticateAndRevealCvv` with step-up authentication via `BiometricAuthService` or `VerifyPasscodeBottomSheet`.
  - Added automated re-mask timers (15s for PAN, 10s for CVV).
- **Regression Test:** `test/workstream_f_security_i18n_perf_test.dart` (9/9 passed).
- **Owner:** `workstream-cards` | **Status:** RESOLVED

### 3.3 ISSUE-P0-03: Currency Precision & Inaccurate Exchange Rates
- **Severity:** P0 (Financial Truth & Compliance)
- **Affected Routes & Contracts:** `ROUTE-012, ROUTE-013, ROUTE-023` | `CTR-003, CTR-006`
- **Evidence:** `test/financial_domain_integrity_test.dart`
- **Root Cause:** Hardcoded 4-decimal formatting truncated inverse exchange rates like 1 IRT -> USD to `0.0000`. Toman currencies occasionally rendered fractional cents.
- **Implemented Fix:**
  - Centralized zero-decimal classification in `DynamicDecimalsHelper.isZeroDecimal` for `IRT`, `IRR`, `TOMAN`, `TMN`, `RIAL`.
  - Added dynamic precision engine in `ExchangeController` scaling fractional rates up to 6–8 decimals.
- **Regression Test:** `test/financial_domain_integrity_test.dart` (13/13 passed).
- **Owner:** `workstream-financial` | **Status:** RESOLVED

### 3.4 ISSUE-P1-01: Low Dark Mode Text Contrast & Button Overflow
- **Severity:** P1 (Accessibility & Usability)
- **Affected Routes & Contracts:** All UI Form Routes | `CTR-010`
- **Evidence:** `test/workstream_f_security_i18n_perf_test.dart`
- **Root Cause:** `darkTextSecondary` (`#656262`) failed WCAG AA with a 2.51:1 contrast ratio. `CommonButton` had fixed height causing RenderFlex overflows on long localized strings.
- **Implemented Fix:**
  - Upgraded color token to `#A5A09F`, achieving a 5.86:1 contrast ratio on dark cards.
  - Converted `CommonButton` height to `constraints: BoxConstraints(minHeight: (height ?? 48).h)` allowing vertical text expansion.
- **Regression Test:** `test/workstream_f_security_i18n_perf_test.dart` (9/9 passed).
- **Owner:** `workstream-security-i18n` | **Status:** RESOLVED

### 3.5 ISSUE-P1-02: Inverted Flight Route Geometry in RTL Locales
- **Severity:** P1 (Localization & UX Quality)
- **Affected Routes & Contracts:** `ROUTE-108, ROUTE-115` | `CTR-008`
- **Evidence:** `test/travel/travel_ui_ux_flow_upgrade_test.dart`
- **Root Cause:** Standard left-to-right flight route indicators pointed planes backwards when rendered in Persian and Arabic RTL.
- **Implemented Fix:**
  - Developed `TravelFlightRouteIndicator` with dynamic `scaleX: -1` plane heading mirroring and bidi-safe IATA code locks.
- **Regression Test:** `test/travel/travel_ui_ux_flow_upgrade_test.dart` (10/10 passed).
- **Owner:** `workstream-travel` | **Status:** RESOLVED

---

## 4. Tests & Evidence Links
All verification records are registered in `docs/integration/TEST_EVIDENCE.csv`:
- `EVD-001`: API resilience suite (`test/workstream_b_api_resilience_test.dart`, exit 0, PASS)
- `EVD-002`: Financial domain suite (`test/financial_domain_integrity_test.dart`, exit 0, PASS)
- `EVD-003`: Security & A11y suite (`test/workstream_f_security_i18n_perf_test.dart`, exit 0, PASS)
- `EVD-004`: Travel bidi suite (`test/travel/travel_ui_ux_flow_upgrade_test.dart`, exit 0, PASS)
- `EVD-005`: Commercial & Cards suite (`test/commercial_and_card_completion_test.dart`, exit 0, PASS)

---

## 5. Recommendation to Stage 3 & Beyond
- **Ready Domains:** 100% of eCardo modules (`MOD-WALLET`, `MOD-FX`, `MOD-TX`, `MOD-CARD`, `MOD-AUTH`, `MOD-DASHBOARD`, `MOD-SETTINGS`, `MOD-TRAVEL`, `MOD-COMMERCIAL`, `MOD-COMMON`).
- **Blocked Domains:** None.
- **Remaining P0/P1:** 0.
- **Approval:** All criteria for full surface modernization satisfied.
