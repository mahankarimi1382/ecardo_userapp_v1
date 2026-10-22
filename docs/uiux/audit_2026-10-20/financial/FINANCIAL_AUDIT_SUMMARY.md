# Financial Correctness & Truth Audit — Executive TL;DR

**Date:** 2026-10-20 | **Scope:** Financial truth, decimal precision, idempotency, and receipt veracity in `ecardo_userapp_v1`.

### All P0 Critical Findings & One-Line Fixes
1. **FIN-01 (Fabricated Case/Order IDs in Loans, Commercial, Stocks, Travel)**: Secondary modules synthesize fake `LN-`, `INV-`, `ORD-`, `EC-RAIL-` IDs on failure instead of surfacing backend truth.
   - *Fix:* Remove client-side ID synthesis; show explicit error state or await authoritative server reference.
2. **FIN-02 (Canceled Add-Money WebView Celebrated as Paid Deposit)**: Backing out of deposit gateway routes to Success step with celebratory confetti and "PAID" receipt.
   - *Fix:* Route aborted WebView (`paymentResult == null`) to pending/review step, never to `AddMoneySuccessStepSection`.
3. **FIN-03 (Pending Withdrawal Stamped "PAID" on Digital Receipt)**: Backend ledger records withdrawal as `liability:pending_withdraw`, but receipt hardcodes `EcardoReceiptStatus.success` ("PAID").
   - *Fix:* Set `status: EcardoReceiptStatus.pending` in `WithdrawSuccessStepSection` to render `PENDING` watermark.
4. **FIN-04 (Exchange Fallback Rate 95,000 vs Live 188,500 Triggers Slippage Rejection)**: Static benchmark rate in `ExchangeRateManager` conflicts with live market, breaching backend 2% slippage guard.
   - *Fix:* Eliminate hardcoded 95k fallback; require fresh live rate or sync fallback with backend `currencies` table.
5. **FIN-05 (Missing Idempotency Header on Merchant Payment)**: `/user/payment/make` is omitted from `_idempotentEndpointSuffixes`, risking double-debiting on network timeout retries.
   - *Fix:* Add `'/user/payment/make'` to `_idempotentEndpointSuffixes` in `NetworkService.dart`.

### Backend vs Client Responsibility Separation
| Layer | Scope of Responsibility | Required Action |
| :--- | :--- | :--- |
| **Client (Flutter)** | UI button debounce (`isLoading`), Idempotency headers on all money endpoints, timeout warning toasts, truthful receipt status (`pending` vs `success`), correct currency decimal lookup. | Add missing endpoint suffixes, fix Add-Money WebView cancel route, set withdrawal receipt to pending, pass `wallet.code` not `wallet.name`. |
| **Server (Laravel)** | Double-entry ledger commits (`LedgerService`), S-023 Idempotency Middleware deduplication, Slippage Guard enforcement (2%), rate sanity limits, transaction state authority. | Maintain strict 2% slippage check; ensure `expected_rate` validation exception returns actionable error message. |

### Key Deliverables Reference
- Full findings catalog: `docs/uiux/audit_2026-10-20/financial/FINANCIAL_TRUTH_FINDINGS.csv` (20 findings)
- Decimal precision audit: `docs/uiux/audit_2026-10-20/financial/MONEY_FORMATTING_AUDIT.md`
- Double-submit & pending states: `docs/uiux/audit_2026-10-20/financial/DOUBLE_SUBMIT_AND_PENDING_AUDIT.md`