# ADR 0005: Payment Provider Abstraction & Idempotent State Machine Protocol

- **Status:** ACCEPTED
- **Date:** 2026-10-15
- **Deciders:** Fintech Engineering Team, Mobile Security Architecture
- **Technical Context:** `ecardo_userapp_v1_audit_roadmap_fa.md` — Section 4 (Phase 2 & Phase 3), Section 7 & Section 8
- **Standard Alignment:** OWASP MASVS-NETWORK, MASVS-AUTH, ISO 4217, ISO 20022 Financial Messaging

---

## 1. Context & Problem Statement

As a multi-currency international super-app, `ecardo_userapp_v1` interfaces with divergent domestic and international payment rails:
1. **Domestic Iranian Rails:** Central Bank of Iran Sheba (IBAN), 16-digit Shetab debit cards, Shaparak IPG redirect webviews (Saman/SEP, Zarinpal, Sadad).
2. **International Rails:** Visa and Mastercard virtual card issuing and balance top-ups (Stripe, BSI Cards), cross-border SWIFT/remittance, and cryptocurrency (USDT, BTC, ETH).
3. **Internal Micro-Financial Services:** P2P escrow trading, commercial equity project funding, collateral guarantees, software license orders, and travel booking.

### Historical Deficiencies Identified During Audit
- **Double-Debit on Network Blips:** When a user submitted a payment and encountered a cellular timeout or transport failure, the in-flight `Idempotency-Key` was immediately evicted from memory. A subsequent tap generated a brand-new key, causing the backend ledger to process a duplicate debit.
- **Unverified Redirect Trust:** In payment WebViews, if the return redirect URL contained `/success`, client code historically treated the transaction as confirmed without verifying state against the backend API ledger.
- **Scattered Provider If-Else Statements:** Hardcoded provider logic and currency assumptions caused regressions when integrating new payment methods.

---

## 2. Architecture Decision

We adopt a decoupled, server-authoritative **Payment Provider Abstraction & Idempotent Protocol** across all monetary modules.

```
+-----------------------------------------------------------------------------------------+
|                                PAYMENT PROTOCOL FLOW                                    |
+-----------------------------------------------------------------------------------------+
|  [Mobile Client Form]                                                                   |
|         │                                                                               |
|         ▼ (Pre-validation: Luhn, Sheba mod-97, limits, zero-decimal rounding)          |
|  [Review Sheet & Rate Lock]                                                             |
|         │                                                                               |
|         ▼ POST with X-Idempotency-Key (UUIDv4 + Path + Payload Fingerprint)             |
|  [Network Layer: Persistent In-Flight Registry]                                         |
|         │                                                                               |
|         ├── HTTP 200/201 ──► [Server Ledger Verified] ──► Release Key & Update Balances |
|         │                                                                               |
|         └── Transport Timeout ──► RETAIN KEY IN REGISTRY                                |
|                                   │                                                     |
|                                   ▼                                                     |
|                      [Pending Verification UX Gate]                                     |
|                      (Poll GET /api/user/payment-status/{tnx} or transactions history)  |
+-----------------------------------------------------------------------------------------+
```

### 2.1 Server as the Sole Source of Financial Truth
1. The mobile client acts strictly as an input collector, client-side pre-validator, and state renderer.
2. The client never calculates final settlement amounts or assumes payment success based on WebView redirect URLs.
3. Every hosted payment gateway execution in `WebViewScreen` queries `GET /api/user/payment-status/{tnx}` with exponential backoff before declaring transaction completion. If the server is unreachable or state is inconclusive, the client reports `pending_verification` and routes the user to transaction history.

### 2.2 Comprehensive Idempotency Key Coverage
1. All money-movement and commitment endpoints are protected under `NetworkService._idempotentEndpointSuffixes`:
   - `/user/transfer`, `/user/cashout`, `/user/pay-bill`, `/user/withdraw`, `/user/exchange`
   - `/user/remittance/store`, `/user/loans/apply`, `/user/loans/repay`, `/user/loans/early-repayment`
   - `/user/escrow/store`, `/user/escrow/pay`, `/user/escrow/release`
   - `/user/stocks/order`, `/user/guarantee/apply`, `/user/guarantee/deposit-margin`
   - `/user/virtual-card/create`, `/user/virtual-card/fund`, `/user/virtual-card/topup`
   - `/user/p2p/create-order`, `/user/p2p/release-order`, `/user/p2p/pay-order`
   - `/user/travel/book`, `/user/travel/order`, `/user/add-money`, `/user/visa/requests`, `/user/card-orders`
2. **Key Retention Policy:** On transport timeouts (`connectionTimeout`, `receiveTimeout`, `sendTimeout`), the in-flight key is **never evicted** from the client registry. Any subsequent retry with identical payload reuses the existing idempotency key, allowing the server middleware to safely collapse duplicate submissions.

### 2.3 Provider Capability Model
Instead of sprinkling `if (country == 'IR')` across presentation widgets, capabilities are governed by a dynamic domain model:
- `canCreateVirtual`, `canRequestPhysical`, `canFundFromIrrWallet`, `canFundFromGateway`
- Capabilities and available payment gateways are delivered via authenticated API configuration endpoints (`/user/add-money/config`, `/user/transfer/config`, `/user/virtual-card/cards-products`).

---

## 3. Consequences & Trade-Offs

### Positive Consequences
- **Zero Double-Debits:** Guaranteed elimination of duplicate ledger charges caused by rapid user tapping or network timeouts.
- **Anti-Fraud & Integrity:** Users cannot spoof transaction completion by manipulating browser URL parameters or intercepting WebView callbacks.
- **Provider Agnostic:** Adding new regional gateways (e.g., UAE Central Bank IPG, Turkish Troy/BKM Express, Russian Mir) requires zero changes to core wallet or ledger logic.

### Mitigations & Trade-Offs
- **Post-Timeout Polling Overhead:** Requires client controllers to handle an intermediate `pending` or `reconciling` state while background polling resolves the final status.
- **Offline Storage Requirement:** Idempotency keys for offline operations require durable local storage with cleanup TTLs (enforced via `OfflineRequestQueue`).

---

## 4. Compliance & Verification Matrix
- **Automated Tests:** Covered by `test/fintech_state_reconciliation_qc_test.dart` and `test/withdraw_modernization_qc_test.dart`.
- **Status:** Verified and enforced across all active financial screens.
