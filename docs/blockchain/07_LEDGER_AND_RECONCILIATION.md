# 07. Double-Entry Ledger & Triple Reconciliation Architecture

## 1. Core Financial Principles & Non-Negotiable Invariants

The integrity of customer funds, institutional treasury balances, and external network settlements within eCardo is governed by an immutable **Double-Entry Bookkeeping Core**.

### 1.1 Non-Negotiable Financial Invariants
1. **The Double-Entry Equation:** For every journal entry and within every distinct asset denomination, the algebraic sum of debits and credits must balance to exactly zero:
   $$\sum \text{Debits} = \sum \text{Credits}$$
2. **Strict Integer Minor-Unit Representation:** All financial values are stored and calculated as 64-bit signed integers (`BIGINT`) in their smallest divisible minor unit (e.g., satoshis, wei, sun, cents). Floating-point data types (`FLOAT`, `DOUBLE`, `REAL`) are strictly banned from all ledger schemas, APIs, and computation pipelines.
3. **Absolute Append-Only Immutability:** Ledger records are permanent. SQL `UPDATE`, `DELETE`, or `TRUNCATE` statements on ledger journal tables are physically prevented by database-level triggers and role permissions. Errors or reversals are resolved exclusively through new compensating journal entries referencing the original `journal_entry_id`.
4. **Stable Operation Identity & Idempotency:** Every financial intent maintains a deterministic, server-assigned `operation_id` and client-provided `idempotency_key` across network retries, timeouts, and system reboots.
5. **No Synthetic Balance Synthesis:** Balances are not stored as arbitrary modifiable integers; a wallet's authoritative balance is the deterministic projection of all its historical debit and credit journal lines.

---

## 2. Standardized Chart of Accounts (CoA)

To maintain transparent separation between platform equity, operational expenses, and customer funds held in fiduciary custody, the system organizes accounts into standard categories:

```text
+-----------------------------------------------------------------------------------+
|                            eCardo Chart of Accounts (CoA)                         |
+-----------------------------------------------------------------------------------+
| Account Code       | Account Type  | Normal Balance | Description                 |
|--------------------+---------------+----------------+-----------------------------|
| 1000-TREASURY-COLD | Asset         | Debit          | Offline Vault Cold Reserves |
| 1100-TREASURY-HOT  | Asset         | Debit          | Online Operational Hot Pool |
| 1200-SETTLE-CLEAR  | Asset         | Debit          | In-Transit Clearing House   |
| 2000-CUST-AVAIL    | Liability     | Credit         | Customer Available Funds    |
| 2100-CUST-RESERVE  | Liability     | Credit         | Funds Locked in Active Tx   |
| 4000-REV-PLATFORM  | Revenue       | Credit         | Platform Service Fee Earned |
| 5000-EXP-NETWORK   | Expense       | Debit          | Blockchain Gas/Energy Cost  |
| 5100-EXP-PROVIDER  | Expense       | Debit          | Third-Party Rail Fees Paid  |
| 9000-DISPUTE-SUSP  | Liability     | Credit         | Quarantined Exception Funds |
+-----------------------------------------------------------------------------------+
```

### 2.1 Double-Entry Example: External USDT Withdrawal (100 USDT, 2.50 Fee)
- **Phase 1: Reserve Funds (Quote Accepted)**
  - `DEBIT  2000-CUST-AVAIL` : 102,650,000 minor units (102.65 USDT)
  - `CREDIT 2100-CUST-RESERVE`: 102,650,000 minor units
- **Phase 2: On-Chain Settlement Finalized**
  - `DEBIT  2100-CUST-RESERVE`: 102,650,000 minor units
  - `CREDIT 1100-TREASURY-HOT` : 100,000,000 minor units (Transferred on-chain)
  - `CREDIT 4000-REV-PLATFORM` :     150,000 minor units (Platform Fee)
  - `CREDIT 5000-EXP-NETWORK`  :   2,500,000 minor units (Reimbursed Network Gas)
- **Result:** Debits = 102,650,000 | Credits = 102,650,000 (Net zero discrepancy)

---

## 3. Transaction State Machine & Life Cycle

Every financial movement follows an explicit, verifiable state machine designed to tolerate network partitions, timeouts, and delayed confirmations:

```text
  [ Client Intent ]
          |
          v
   +--------------+
   |   CREATED    | (Intent initiated with client idempotency key)
   +--------------+
          |
          v
   +--------------+
   |    QUOTED    | (Fee quote generated with strict TTL & max_fee)
   +--------------+
          |
          v
   +--------------+
   |  AUTHORIZED  | (Biometric Step-Up or Dual Approval verified)
   +--------------+
          |
          v
   +--------------+
   |   RESERVED   | (Funds moved from Available to Reserved Liability)
   +--------------+
          |
          v
   +--------------+
   |  SUBMITTED   | (Signed payload broadcast to blockchain relayer / bank)
   +--------------+
          |
          v
   +-----------------------+
   | PENDING_CONFIRMATION  | (Awaiting block confirmations / finality depth)
   +-----------------------+
          |
          +-------------------------------+-------------------------------+
          |                               |                               |
    [Finality Reached]             [Execution Dropped]              [Discrepancy]
          v                               v                               v
   +--------------+               +------------------+           +--------------------------+
   |  FINALIZED   |               | FAILED_CONFIRMED |           | RECONCILIATION_REQUIRED  |
   | (Settled)    |               | (Funds Released) |           | (Human Review Queue)     |
   +--------------+               +------------------+           +--------------------------+
```

### 3.1 Failure & Exception State Definitions
- **`REJECTED_BEFORE_COMMIT`:** Intent failed policy, sanctions, or velocity checks prior to balance reservation. Zero financial impact.
- **`FAILED_CONFIRMED`:** Downstream network or bank confirmed non-execution (e.g., transaction reverted on-chain). Reserved funds are atomically restored to `CUST-AVAIL`.
- **`EXPIRED`:** Quote TTL elapsed before the client completed authorization.
- **`RECONCILIATION_REQUIRED`:** Network status is ambiguous, or on-chain execution parameters differ from the local journal intent. Automatically locks further operations on the affected record and alerts Operations.
- **`REVERSED`:** Compensating entries posted to reverse a previously settled transaction due to dispute, court order, or formal refund.

---

## 4. Triple Reconciliation Architecture

eCardo implements a robust **Triple Reconciliation Model** operating across three independent nodes of truth:

```text
+---------------------------------------------------------------------------------------------------+
|                                 Triple Reconciliation Architecture                                |
+---------------------------------------------------------------------------------------------------+
                                                  |
           +--------------------------------------+--------------------------------------+
           |                                                                             |
           v                                                                             v
+-------------------------------------+                               +-------------------------------------+
|               NODE 1                |                               |               NODE 2                |
|       Local walet-ecardo            |         Loop 1 Sync           |       Central MariaDB Ledger        |
|          Edge SQLite                |<=============================>|            (ecardoq192)             |
|     (Host: [WALLET_NODE_HOST]:8000)     |   (Continuous Journal Sync)   |     (Host: [CORE_BACKEND_HOST])          |
|  - Microsecond Sequencing Engine    |                               |  - Canonical System of Record       |
|  - Cryptographic Signer & HSM Link  |                               |  - Account Chart & User Balances    |
|  - Local Outbox & Digest Anchor     |                               |  - Audit History & Financial P&L    |
+-------------------------------------+                               +-------------------------------------+
           |                                                                             |
           |                                                                             |
           | Loop 2 On-Chain Proof                                                       | Loop 3 Omnibus Solvency
           | (Receipts & Confirmations)                                                  | (Liabilities vs Reserves)
           +--------------------------------------+--------------------------------------+
                                                  |
                                                  v
                               +-------------------------------------+
                               |               NODE 3                |
                               |    External Blockchain Explorers    |
                               |           & Node RPCs               |
                               | (TRON Grid / Mainnet / EVM Nodes)   |
                               |  - On-chain Transaction Hashes      |
                               |  - Block Height & Finality Depth    |
                               |  - Cold/Warm/Hot Physical Balances  |
                               +-------------------------------------+
```

### 4.1 Node Roles & Systems of Record
1. **Node 1: Local `walet-ecardo` SQLite Ledger (Edge Node)**
   - **Host:** `[WALLET_NODE_HOST]` (accessed via secure internal gateway `[CORE_BACKEND_HOST]`).
   - **Role:** High-speed edge execution, BIP-44 key derivation (`m/44'/195'/0'/0/i`), deterministic transaction sequencing, and hardware signer interface.
   - **Storage:** High-concurrency SQLite WAL mode with local double-entry integrity checks.
2. **Node 2: Central MariaDB Ledger (`ecardoq192`)**
   - **Host:** `[CORE_BACKEND_HOST]` (MariaDB 10.6.27 database `ecardoq192`).
   - **Role:** The overarching canonical financial System of Record (SoR) for all accounts, user entities, multi-asset journals, and compliance records.
3. **Node 3: External On-Chain Explorers & Blockchain RPCs**
   - **Providers:** Native full nodes, TRON Grid API, EVM RPC endpoints, and third-party block explorer indexers.
   - **Role:** The definitive, immutable external physical truth for asset transfers that cross the perimeter of the platform.

---

## 5. The Three Reconciliation Loops

Reconciliation runs autonomously across three decoupled feedback loops:

```text
+---------------------------------------------------------------------------------------------------+
| Loop 1: Real-Time Edge-to-Central Synchronization (Continuous Stream)                             |
| Invariant: JournalSequence_walet-ecardo == JournalSequence_ecardoq192                             |
| - walet-ecardo streams signed journal events via transactional outbox to central MariaDB.         |
| - Central MariaDB validates sequence integrity, non-zero debit/credit sums, and balances.        |
| - Drift tolerance: 0 milliseconds tolerance on sequence; max 5000ms network lag before alert.     |
+---------------------------------------------------------------------------------------------------+
                                                  |
                                                  v
+---------------------------------------------------------------------------------------------------+
| Loop 2: Batch On-Chain Settlement Verification (Every Block / 60 Seconds)                         |
| Invariant: RecordedTxHash is mined, confirmed with depth >= 19, and gas_spent <= max_fee.        |
| - Indexer interrogates blockchain nodes for pending hashes.                                       |
| - Verifies transaction receipt status: 0x1 (Success) vs 0x0 (Revert).                             |
| - Records exact on-chain fee consumption into 5000-EXP-NETWORK.                                   |
| - Resolves PENDING_CONFIRMATION -> FINALIZED.                                                     |
+---------------------------------------------------------------------------------------------------+
                                                  |
                                                  v
+---------------------------------------------------------------------------------------------------+
| Loop 3: Periodic Omnibus Solvency & Vault Audit (Hourly & Daily Genesis Snapshot)                 |
| Invariant: Balance_Cold + Balance_Warm + Balance_Hot >= Balance_CustomerLiabilities               |
| - Queries external node RPC for absolute on-chain balances across all platform custody addresses. |
| - Sums all 2000-CUST-AVAIL and 2100-CUST-RESERVE liabilities across ecardoq192.                   |
| - Solvency Ratio: (Total Custody Reserves / Total Customer Liabilities) must be >= 100.00%.      |
| - If Solvency Ratio < 100.00%, immediate Severity 1 Alert triggers and freezes withdrawals.       |
+---------------------------------------------------------------------------------------------------+
```

---

## 6. Discrepancy & Exception Queue Management

When an invariant check fails across any of the three nodes, the discrepancy is enqueued immediately into the **Ledger Exception Management Engine**.

### 6.1 Exception Incident Record Schema

```json
{
  "exception_id": "exc-20261018-00492",
  "severity": "CRITICAL",
  "category": "ON_CHAIN_AMOUNT_MISMATCH",
  "mismatch_details": {
    "operation_id": "op-payout-9921448",
    "ledger_amount_minor": 100000000,
    "on_chain_amount_minor": 98000000,
    "delta_minor": -2000000,
    "asset_id": "USDT",
    "chain_id": "TRON_MAINNET",
    "tx_hash": "a1b2c3d4e5f67890123456789abcdef0123456789abcdef0123456789abcdef0"
  },
  "source_node": "walet-ecardo ([WALLET_NODE_HOST])",
  "target_node": "TRON_GRID_RPC",
  "assigned_owner": "sec-ops-team@ecardo.io",
  "suggested_action": "HOLD_RECIPIENT_AND_POST_ADJUSTMENT",
  "four_eyes_required": true,
  "status": "OPEN",
  "created_at": "2026-10-18T15:20:10.104Z"
}
```

### 6.2 Severity Levels & Escalation Matrix

| Severity | Definition | Automated Action | SLA for Human Resolution |
| :--- | :--- | :--- | :--- |
| **`CRITICAL`** | Balance discrepancy > $1,000, double-spend detected, or solvency ratio < 100%. | Automatic platform payout pause; freeze affected wallets. | < 15 Minutes (24/7 On-Call) |
| **`HIGH`** | On-chain gas deviation > 20% or confirmation timeout > 60 minutes. | Hold individual transaction in `RECONCILIATION_REQUIRED`. | < 1 Hour |
| **`MEDIUM`** | Loop 1 replication delay between MariaDB and SQLite > 30 seconds. | Divert traffic to read-replica; alert DBA team. | < 4 Hours |
| **`LOW`** | Display dust rounding discrepancy (< 10 minor units). | Automatically route to `9000-DISPUTE-SUSP` rounding bucket. | < 24 Hours |

### 6.3 Resolution Governance (Four-Eyes Mandate)
- Resolving an exception ticket that adjusts ledger balances requires **two distinct authorized principals**:
  1. Primary Investigator (Risk Analyst / Wallet Operator) proposing the compensating journal adjustment.
  2. Secondary Authorizer (Finance Director / Head of Security) reviewing on-chain tx receipts and approving the adjustment.
- Direct database editing to "force balance agreement" is physically blocked by database constraints.

---

## 7. Strict Prohibitions & Anti-Patterns

To maintain institutional compliance and bank-grade assurance, the following anti-patterns are strictly forbidden:

1. **Client-Side Balance Trust:** The mobile client (Flutter app) or Web panel cache must never be treated as authoritative for available balances. Balances must always be validated server-side within an active transaction.
2. **Premature Balance Crediting:** Customer accounts must never be credited for incoming deposits until the blockchain indexer confirms that the transaction has reached **full finality depth** (minimum 19 blocks on TRON; 64 blocks on Ethereum Proof-of-Stake).
3. **Using Elasticsearch as a Ledger:** Elasticsearch is an observability and full-text search projection engine only. It is **never** to be used as a source of financial truth, a balance lookup store, or an accounting ledger.
4. **Silent Retries on Unknown States:** In the event of network timeouts (HTTP 504 / Connection Drop) during payout submission, the system must **never** synthesize a new transaction or blindly retry. It must query the transaction submitter status by `operation_id` to determine whether the transaction was broadcast before attempting recovery.
5. **Deleting or Truncating Ledger Rows:** Dropping, editing, or truncating any row in `ledger_journals` or `ledger_entries` is classified as a critical security incident.
