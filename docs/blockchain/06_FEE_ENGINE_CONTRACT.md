# 06. Fee Engine Contract & Transfer Specifications

## 1. Product Vision & Transfer Categorization

A core competitive differentiator of the eCardo financial platform is **Instant, Zero-Fee Transfers** between ecosystem participants, paired with a transparent, predictable, and mathematically capped fee structure for external payouts and cross-network transfers.

### 1.1 Strict Transfer Typology
The system segregates transactions into six distinct categories, each subject to specific risk profiles, ledger mechanics, and fee settlement rules:

```text
                                +---------------------------------------+
                                |          eCardo Transfer Types        |
                                +---------------------------------------+
                                                    |
         +--------------------+---------------------+--------------------+--------------------+
         |                    |                     |                    |                    |
         v                    v                     v                    v                    v
+------------------+ +------------------+ +------------------+ +------------------+ +------------------+
| INTERNAL_ECARDO  | |EXTERNAL_SAME_CHAIN| |   CROSS_CHAIN    | |   BANK_PAYOUT    | |   CARD_FUNDING   |
| (Peer-to-Peer)   | | (TRC20 / EVM)    | | (Bridge Engine)  | | (ACH / SEPA / P2P| | (Card Issuance /  |
| Fee to User: $0  | | Transparent Quote| | Dynamic Protocol | | Provider Gateway | | Balance Top-Up)  |
+------------------+ +------------------+ +------------------+ +------------------+ +------------------+
                                                    |
                                                    v
                                         +--------------------+
                                         |    FX_EXCHANGE     |
                                         | (Currency / Crypto |
                                         | Transparent Spread)|
                                         +--------------------+
```

1. **`INTERNAL_ECARDO`:** Movement between two eCardo accounts within the platform. Guaranteed **0% fee to the customer**.
2. **`EXTERNAL_SAME_CHAIN`:** On-chain withdrawal to an external self-custody or exchange address on the native blockchain (e.g., TRON TRC20, Ethereum, Polygon).
3. **`CROSS_CHAIN`:** Asset bridging across heterogeneous chains (e.g., TRC20 USDT to Arbitrum USDC). Involves liquidity provider fees and cross-chain messaging fees.
4. **`BANK_PAYOUT`:** Withdrawal to external banking infrastructure (SEPA, SWIFT, domestic IBAN, or local settlement rails).
5. **`CARD_FUNDING` / `CARD_ISSUANCE`:** Transfer from user wallet to prepaid/debit card partner funding accounts.
6. **`FX_EXCHANGE`:** Conversion between fiat and crypto or between different currencies. Features transparent quote locks and separated spreads.

---

## 2. Zero-Fee Internal Transfer Specification

### 2.1 The Principle of Zero Customer Fee
**"Zero Fee" signifies that the customer is charged exactly zero minor units for the transfer:**
$$\text{CustomerFee} = 0$$

It does **not** imply that computing, network gas, or database infrastructure are free. eCardo absorbs all underlying operational overhead.

### 2.2 Execution Modes: Dual Architecture

```text
+-----------------------------------------------------------------------------------+
|                        INTERNAL_ECARDO Execution Pipeline                         |
+-----------------------------------------------------------------------------------+
| Mode A: Ledger-Only Settlement (Default Instant Path)                             |
| - Double-Entry Ledger records Debit from Sender and Credit to Receiver           |
| - Settlement latency: < 50ms                                                      |
| - On-chain gas cost: $0.00                                                        |
| - Cryptographic proof: Included in daily platform Merkle tree                     |
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
| Mode B: Platform-Sponsored On-Chain Anchor (Audit & Settlement)                  |
| - Relayer Pool (Treasury Hot Wallet) submits transaction to blockchain            |
| - Network Energy / Gas is 100% sponsored by platform relayer account              |
| - Sender and Receiver accounts update atomically via transactional outbox         |
+-----------------------------------------------------------------------------------+
```

### 2.3 Platform Sponsorship Economics & Anti-Abuse Controls
To prevent denial-of-service (DoS) attacks, automated sybil spamming, and platform relayer exhaustion:
1. **Daily User Quotas:** Each verified user receives up to **50 free internal transfers per rolling 24-hour window**.
2. **Minimum Transfer Amount:** Transfers below threshold (e.g., 1.00 USDT or equivalent) are blocked to prevent dust spam.
3. **Relayer Reserve Reservoir:** The platform maintains a dedicated TRON Energy / Gas sponsorship pool. If pool reserves drop below 20%, transfers automatically fallback to Mode A (Internal Ledger-Only) with delayed on-chain batch checkpointing.
4. **Velocity Gate:** Max 3 internal transfers per 60 seconds per user account.

---

## 3. Dynamic External Fee Calculation Engine

For external transfers, the platform computes an all-inclusive, transparent fee breakdown. Hard-coded fee numbers are strictly prohibited.

### 3.1 Canonical Fee Formula
All calculations operate strictly in **integer minor units** (e.g., 1 USDT = $1,000,000$ minor units for 6 decimals):

$$\text{TotalDebit} = \text{Amount} + \text{NetworkFee} + \text{ProviderFee} + \text{PlatformFee} + \text{FXSpread} + \text{Tax}$$

Where:
- **`Amount`:** Principal transfer amount requested by user.
- **`NetworkFee`:** Dynamic blockchain network gas/energy estimate queried from node oracle, plus a configurable volatility safety margin (e.g., +15%).
- **`ProviderFee`:** Exact fee passed through from banking provider, bridge protocol, or card issuer.
- **`PlatformFee`:** Value-added service charge calculated via tiered basis points (bps) with strict floor and cap limits:
  $$\text{PlatformFee} = \min\left(\text{CapFee}, \max\left(\text{FloorFee}, \frac{\text{Amount} \times \text{BPS}}{10\,000}\right)\right)$$
- **`FXSpread`:** Transparent foreign exchange markup, applicable only when currency conversion is performed.
- **`Tax`:** Value Added Tax or regulatory levies where legally mandated by jurisdiction.

### 3.2 Floating-Point Arithmetic Prohibition
Floating-point data types (`float`, `double` in C++/Dart/PHP) are strictly banned from financial logic to eliminate IEEE 754 precision drift.
- All monetary arithmetic uses integer arithmetic on minor units.
- Rounding mode: **Half-Up Rounding** applied only once at the final step of minor-unit calculation.

---

## 4. Fee Quote Contract Specification

Prior to executing any non-internal transfer, the client must obtain an authoritative cryptographic Fee Quote from the backend. The client cannot author, adjust, or tamper with fee structures.

### 4.1 JSON Fee Quote Schema

```json
{
  "quote_id": "qt-7f92a10b-88e2-41d3-9bc1-1209384756ab",
  "operation_id": "op-ext-9921448",
  "transfer_type": "EXTERNAL_SAME_CHAIN",
  "asset_id": "USDT",
  "chain_id": "TRON_MAINNET",
  "amount_minor": 100000000,
  "amount_scale": 6,
  "fee_breakdown": {
    "network_fee_minor": 2500000,
    "provider_fee_minor": 0,
    "platform_fee_minor": 150000,
    "fx_spread_minor": 0,
    "tax_minor": 0
  },
  "total_fee_minor": 2650000,
  "total_debit_minor": 102650000,
  "net_recipient_receives_minor": 100000000,
  "fee_policy_version": "v2026.10.1",
  "max_fee_minor": 3500000,
  "quoted_at": "2026-10-18T15:00:00Z",
  "expires_at": "2026-10-18T15:01:30Z",
  "ttl_seconds": 90,
  "quote_hash": "c8f2a1b9d4e5f60718293a4b5c6d7e8f90123456789abcdef0123456789abcde"
}
```

### 4.2 Quote Lifecycle & State Transitions

```text
               +----------------------------------------------------+
               |                      ISSUED                        |
               | (Server calculates breakdown, stores in Redis TTL) |
               +----------------------------------------------------+
                                         |
                       +-----------------+-----------------+
                       |                                   |
         [User Accepts within TTL]               [TTL Expires (> 90s)]
                       v                                   v
               +---------------+                   +---------------+
               |   ACCEPTED    |                   |    EXPIRED    |
               | (Funds Lock)  |                   | (Void/Dead)   |
               +---------------+                   +---------------+
                       |                                   |
         +-------------+-------------+                     v
         |                           |             [Client Must Re-Quote]
 [Tx Submitted]              [Execution Fail]
         v                           v
+-----------------+         +-----------------+
|    CAPTURED     |         |    RELEASED     |
| (Ledger Settled)|         | (Reserve Return)|
+-----------------+         +-----------------+
```

### 4.3 Time-To-Live (TTL) & Expiration Rules
1. **On-Chain Crypto Transfers:** TTL is restricted to **60 to 90 seconds** due to network gas volatility and mempool price fluctuations.
2. **Fiat & Bank Transfers:** TTL is set to **300 seconds (5 minutes)**.
3. **Hard Expiration Enforcement:** When `expires_at` is surpassed, any execution request referencing `quote_id` will be rejected by the server with HTTP 410 `QUOTE_EXPIRED`. The mobile app must prompt the user to review the updated quote.

### 4.4 Fee Cap & Slippage Guard (`max_fee_minor`)
- The quote contract embeds `max_fee_minor`. This establishes the non-negotiable upper bound of fees the customer agrees to pay.
- If at the time of on-chain broadcast, network congestion drives the estimated gas above `max_fee_minor`, the transaction **must not be broadcast**. It is halted, the reserved funds are released, and the user is notified with `FEE_SLIPPAGE_EXCEEDED`.
- **Under-estimation Refund Policy:** If the actual on-chain transaction consumes less gas than quoted (`actual_gas < quoted_network_fee`), the surplus is credited back to the customer's available balance during reconciliation.

---

## 5. Balance Reservation & Idempotency Safeguards

To prevent double-spending and race conditions when users execute transfers across multiple tabs or unstable mobile connections:

### 5.1 The Two-Phase Reservation Pattern
1. **Phase 1: Reserve on Accept**
   - Upon client acceptance of the quote, the backend executes an atomic database operation:
     $$\text{Balance}_{\text{available}} \leftarrow \text{Balance}_{\text{available}} - \text{TotalDebit}$$
     $$\text{Balance}_{\text{reserved}} \leftarrow \text{Balance}_{\text{reserved}} + \text{TotalDebit}$$
   - The transaction state transitions to `RESERVED`.
2. **Phase 2: Finalize or Release**
   - **On Success:** Once the transaction is broadcast and receives initial network confirmation:
     $$\text{Balance}_{\text{reserved}} \leftarrow \text{Balance}_{\text{reserved}} - \text{TotalDebit}$$
     Double-entry ledger journal entries record the asset transfer and fee settlement.
   - **On Failure / Rejection:** If the transaction fails, times out, or is rejected:
     $$\text{Balance}_{\text{reserved}} \leftarrow \text{Balance}_{\text{reserved}} - \text{TotalDebit}$$
     $$\text{Balance}_{\text{available}} \leftarrow \text{Balance}_{\text{available}} + \text{TotalDebit}$$
     Funds are immediately restored to the user with zero loss.

### 5.2 Idempotency Key Binding
- Every transfer request requires a unique `Idempotency-Key` (UUIDv4) supplied by the client.
- The server stores the `(idempotency_key, operation_id, quote_id, payload_hash)` tuple in a high-speed lock cache.
- Re-submitting the exact same request during network retries returns the identical status without duplicating charges.
- Submitting conflicting parameters with an existing idempotency key triggers an immediate HTTP 409 `IDEMPOTENCY_CONFLICT`.

---

## 6. Edge Cases & Error Handling Matrix

| Scenario | System Behavior | Financial Ledger Action | User Experience |
| :--- | :--- | :--- | :--- |
| **Insufficient Balance at Commit** | Rejected immediately with code `INSUFFICIENT_FUNDS`. | No ledger impact. | Prompt to top up balance. |
| **Quote Expired during Biometrics**| Server rejects submission (`QUOTE_EXPIRED`). | Reserved funds released. | Displays updated quote modal. |
| **Network Fee Surges > Max Cap** | Transaction broadcast aborted (`FEE_SLIPPAGE_EXCEEDED`). | Reserved balance restored. | Notified of network spike. |
| **Destination Address Blacklisted** | Blocked by AML screening before broadcast. | No funds deducted. | Error: "Invalid or unsupported destination address." |
| **Provider Timeout / 504 Gateway** | State machine moves to `PENDING_CONFIRMATION`. | Funds remain `RESERVED`. | Spinner: "Processing transfer; checking status." |
| **Concurrent Spend from 2 Devices** | Database row-level locking (`SELECT ... FOR UPDATE`). | Second transaction fails. | First succeeds; second receives `INSUFFICIENT_FUNDS`. |
| **On-Chain Tx Dropped from Mempool**| Re-check engine confirms non-inclusion after 1 hour. | Compensating journal reversal. | Funds restored to available balance. |
| **Duplicate Webhook Delivery** | Handled idempotently via `provider_tx_id` unique key. | Ignored on second delivery. | No duplicate balance updates. |
