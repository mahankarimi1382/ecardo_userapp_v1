# eCardo User App (v1) — Financial Flows & Transaction Logic Specification

**Document Version:** 1.0.0  
**Date:** 2026-10-14  
**Audit Context:** `ecardo_userapp_v1_audit_roadmap_fa.md` — Phase 2 & Section 5  
**Codebase Verification SHA:** `d56ab71d293ca1c7ec29b63863ecbc40ca9c8d67`

---

## 1. Overview & Financial Tenets

In accordance with Phase 2 of the audit roadmap:
> **Core Principle:** The backend server is the single source of truth for all monetary balances, exchange rates, transaction fees, and state transitions. The mobile client acts strictly as an input collector, client-side validation guard, and state renderer. The client never calculates final settlement amounts or assumes transaction success without server confirmation.

---

## 2. Precision & Money Representation Model

### 2.1 Current Implementation Analysis
- **Core Helper:** `lib/src/helper/money_math_helper.dart`
- **Methodology:** Implements scaled integer arithmetic using `BigInt` with a scaling factor of $10^8$ (`defaultScale = 100,000,000`).
- **Mathematical Safety:**
  - Addition (`MoneyMathHelper.add`), subtraction (`MoneyMathHelper.subtract`), and percentage charge calculations (`MoneyMathHelper.calculatePercentCharge`) convert floating-point values into scaled integers before computing, completely eliminating IEEE-754 binary floating-point drift (e.g. avoiding `0.1 + 0.2 = 0.30000000000000004`).
- **Dynamic Decimals (`lib/src/helper/dynamic_decimals_helper.dart`):**
  - Adapts decimal places per asset:
    - Fiat currencies (IRR / Toman): 0 decimals.
    - Standard Fiat (USD, EUR, AED, TRY, CNY): 2 decimals.
    - Cryptocurrencies (BTC, ETH): 8 decimals; USDT/TRX: 4–6 decimals.

---

## 3. Transaction State Machine Matrix

Every monetary operation conforms to the canonical fintech lifecycle:

```
[Created / Draft]
       │
       ▼
[Client Review & Locked Quote]
       │
       ▼ (Submit + Idempotency-Key)
[Processing / In-Flight] ──(Network Timeout)──► [Pending / Ambiguous Verification]
       │                                                         │
       ├────────────────────────┬────────────────────────────────┤
       ▼                        ▼                                ▼
  [Succeeded]               [Failed]                        [Cancelled / Expired]
```

### 3.1 Status Definitions
| State | Client UI Representation | Allow User Retry? | Backend Consequence |
| :--- | :--- | :--- | :--- |
| `created` | Form filled, pre-validation active | Yes | No financial side effects |
| `processing` | Full-screen or button loading, button disabled | No (Locked) | Request in flight or locked in DB transaction |
| `pending` | Amber status badge, explanation banner | No (Poll status) | Funds locked in escrow or awaiting gateway confirmation |
| `succeeded` | Green receipt, confetti, balance updated | No | Ledger credited/debited permanently |
| `failed` | Red error banner with user-friendly message | Yes (New key) | Funds released back or not deducted |
| `cancelled` | Grey status badge | Yes | Order closed |
| `reversed` / `refunded` | Blue badge, refund details in receipt | No | Ledger entry reversed with reference ID |

---

## 4. Financial Flows Specification

### 4.1 Flow 1: Deposit / Add Money (`/add_money`)
1. **Input:** User selects source currency wallet and amount.
2. **Quote & Limits:** `fetchAddMoneyConfig()` loads min/max deposit limits and fee percentages from server.
3. **Gateway Initiation:** `POST /api/user/add-money` -> returns gateway redirect URL `pro-pay/{tnx}`.
4. **WebView Execution:** Handled by hardened `WebViewScreen` (`lib/src/presentation/widgets/web_view_screen.dart`):
   - Scrapes transaction ID `tnx` from URL.
   - Polls official server verification endpoint: `GET /api/user/payment-status/{tnx}` (up to 3 retries with 1.2s exponential backoff).
   - Only marks success when server returns `{ data: { success: true } }`.
5. **State Broadcast:** Emits `BalanceChangedEvent(sourceModule: 'add_money')` over `AppEventBus` to refresh wallet balances instantly across all active screens.

### 4.2 Flow 2: Internal Transfer (`/transfer`)
1. **Recipient Lookup:** User enters recipient account number / phone / UID.
2. **Wallet Selection:** User chooses source wallet (defaults to national currency, e.g., IRT).
3. **Fee Calculation:** `_calculateCharge()` calculates network and service fee via `MoneyMathHelper`.
4. **Passcode Gate:** If 2FA or transaction PIN is enabled, `VerifyPasscodeBottomSheet` prompts for 4-digit PIN.
5. **Submission:**
   - Client double-tap locked via `isTransferAmountLoading.value = true`.
   - Network layer automatically injects `Idempotency-Key` and `X-Idempotency-Key` based on path, query, and payload fingerprint (`NetworkService:220-239`).
   - Endpoint: `POST /api/user/transfer`.
6. **Result Handling:** Shows receipt with masked recipient data; emits `BalanceChangedEvent`.

### 4.3 Flow 3: Currency Exchange (`/exchange`)
1. **Pair Selection:** From Wallet $\to$ To Wallet.
2. **Live Rate Streaming & Drift Protection:**
   - Managed by `ExchangeRateManager` (`lib/src/presentation/screens/exchange/service/exchange_rate_manager.dart`).
   - In Step 1 (Review): rate is locked (`lockedReviewRate`), and entry timestamp is recorded (`reviewEnteredAt`).
   - If market rate drifts beyond tolerance, `isReviewRateStale` turns `true`, displaying an in-app warning banner and requiring explicit re-confirmation.
3. **Submission:**
   - Sends `amount`, `from_wallet`, `to_wallet`, `rate`, `expected_rate`, `rate_locked_at`.
   - Endpoint: `POST /api/user/exchange` (covered by `_idempotentEndpointSuffixes`).

### 4.4 Flow 4: Withdrawal / Cash-Out (`/withdraw`, `/cash_out`)
1. **Destination Types:**
   - Iranian Sheba (IBAN): Format validated with regex `^IR[0-9]{24}$`.
   - 16-Digit Iranian Bank Card: Luhn algorithm validation and masking (only showing digits 1-6 and 13-16 in UI: `6037-99**-****-1234`).
   - Crypto Address: Network selection (TRC20, ERC20, BTC) with address format validation.
2. **Fee & Payout Preview:** Shows deduction amount, fee, and net received amount.
3. **Submission:** `POST /api/user/withdraw` (idempotent, button disabled on tap).

### 4.5 Flow 5: P2P Trading & Escrow (`/p2p`, `/escrow`)
1. **Order Creation:** Locked funds transferred to platform escrow.
2. **Payment Proof:** Buyer uploads receipt via chat.
3. **Asset Release Gate:**
   - Client NEVER releases assets locally.
   - Release requires server endpoint: `POST /api/user/p2p/release-order` or `/user/escrow/release`.
   - Server validates order state is `paid` and caller is the legitimate seller.

---

## 5. Security & Idempotency Safeguards

1. **Automatic Idempotency Key Injection:**
   All 23 money-moving endpoints are listed in `NetworkService._idempotentEndpointSuffixes`. Any POST to these endpoints automatically receives an `Idempotency-Key` header with payload fingerprinting.
2. **In-Flight Key Registry:**
   Re-taps of the exact same request within the network window reuse the same key, ensuring the backend idempotent middleware de-duplicates the request.
3. **Post-Timeout Reconciliation:**
   In case of a network timeout after a financial submission, the app must not declare definitive failure. Recommended UI pattern: show "Transaction in Progress / Verification Pending" and poll `GET /api/user/transactions/{id}` before prompting the user to try again.
