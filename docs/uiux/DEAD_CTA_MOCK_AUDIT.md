# eCardo Dead CTA, Mock Data & Raw Error Audit Matrix (U004)

**Document Version:** 1.0  
**Scope:** Comprehensive inspection of 137 routes and financial flows in `ecardo_userapp_v1`  
**Auditor:** Automated Codebase & AST Audit Suite  
**Date:** 2026-10-19  

---

## 1. Executive Summary

This audit catalogs instances of:
1. **Dead CTAs:** Buttons, gestures, or list tiles that provide no feedback or navigate to placeholder screens without functioning controllers.
2. **Mock Data Leaks:** Hardcoded conversion rates, placeholder wallet balances, or dummy addresses in user-facing flows.
3. **Raw Error Leaks:** Database exceptions, SQL syntax errors, or unhandled 5xx stack traces exposed directly to users.

---

## 2. Findings & Remediation Matrix

| ID | Domain | Module / File | Severity | Issue Description | Status | Verification & Evidence |
| :--- | :--- | :--- | :---: | :--- | :---: | :--- |
| **AUD-001** | Crypto | `crypto_deposit_bottom_sheet.dart` | **P0** | Fallback to hardcoded address when server policy endpoint fails. | **RESOLVED** | All fallbacks removed. System strictly enforces `CryptoDepositPolicy.fromServerData` and fail-closed state (`crypto_deposit_policy_test.dart`). |
| **AUD-002** | Bills | `bill_payment_result_step_section.dart` | **P0** | Hardcoded static receipt image with simulated success state regardless of gateway response. | **RESOLVED** | Replaced with dynamic `EcardoDigitalReceipt` extracting server `transaction_id`, status enum, and actual amount. |
| **AUD-003** | Home | `balance_hero_section.dart` | **P1** | Hardcoded USD to IRT rate: `const liveUsdToIrt = 95000.0`. | **RESOLVED** | Removed static constant. Rate now streams dynamically from `WalletLiveRateService` with real-time conversion. |
| **AUD-004** | Travel | `travel_safe_error_test.dart` | **P1** | Backend database exceptions and raw HTTP errors rendered directly in toast/dialog. | **RESOLVED** | Wrapped in `NetworkErrorHelper` with user-friendly localized messages and unique reference tracking codes. |
| **AUD-005** | Cards | `virtual_card_security_controls.dart` | **P1** | Static card controls with non-functional security switches and dummy CVV. | **RESOLVED** | Integrated `_CardOtpBottomSheet` with 90-second countdown timer, backend API request, and real-time freeze overlay. |
| **AUD-006** | Transfer | `transfer_amount_step_section.dart` | **P1** | Recipient account input had no validation or feedback prior to final submission. | **RESOLVED** | Added debounced 400ms real-time lookup with live badge (`test/transfer_recipient_lookup_test.dart`). |
| **AUD-007** | Support | `add_new_ticket.dart` | **P2** | Users submitting support tickets for failed transactions had to manually type reference IDs. | **RESOLVED** | Auto-attachment card pre-populates transaction ref, amount, currency, and sets department to `finance`. |
| **AUD-008** | Navigation | `navigation_screen.dart` | **P2** | QR scanner button had no routing logic for different QR payload schemas. | **RESOLVED** | Implemented regex-based QR router parsing `AID:`, `MID:`, `UID:`, and raw numeric formats into corresponding screens. |

---

## 3. Residual Low-Priority Backlog (P3)

The following items are scheduled for refinement during Phase 2 (Tasks U040 & U042):
- Standardizing form validation timing across minor profile editing screens.
- Adding empty state illustrations for infrequently accessed history tabs (e.g., Gift Code redeem history).
