# Financial Reconciliation Runbook & Operations Manual

- **Document Identifier:** ECARDO-FIN-REC-001
- **Domain:** Finance Operations, Payment Clearing, Ledger Auditing, SRE
- **Status:** APPROVED & MANDATORY
- **Applies To:** Core Banking Ledger (`ecardo_web_dev`), Payment Gateways, Card Issuers, Reconciliation Daemons
- **Target Audience:** Finance Operations, Site Reliability Engineers (SRE), Payments Engineers, Tier-3 Customer Support
- **Version:** 1.0.0
- **Effective Date:** 2026-10-18
- **Classification:** Highly Confidential — Financial Controls Standard

---

## 1. Principles & The Three-Way Reconciliation Architecture

Financial integrity in eCardo requires continuous, immutable proof that internal accounting mirrors external real-world money movement. An un-reconciled transaction is an active financial risk (loss of funds, double payouts, or regulatory sanction).

### 1.1 The Three Books of Record

Every transaction must balance across three independent systems of record:

```
                  ┌─────────────────────────────────────────┐
                  │       Book 1: Core Double-Entry         │
                  │             Ledger (Internal)           │
                  │   PostgreSQL Append-Only Journal Entries │
                  └────────────────────┬────────────────────┘
                                       │
                      ▲                │                ▲
                      │ 3-Way Match    │ 3-Way Match    │
                      ▼                ▼                ▼
     ┌─────────────────────────────────┐   ┌─────────────────────────────────┐
     │      Book 2: Payment Gateway    │   │      Book 3: Card Issuer /      │
     │            (PSP / Rails)        │   │          Banking Partner        │
     │ ZarinPal, Stripe, Shaparak, etc.│   │ Stripe Issuing, BSI Cards, Epay │
     └─────────────────────────────────┘   └─────────────────────────────────┘
```

1. **Book 1: Internal Double-Entry Ledger (`ecardo_web_dev`):** The authoritative, append-only financial source of truth. Every debit has an exact matching credit. Balances are derived from historical postings and never updated via arbitrary scalar assignment.
2. **Book 2: Payment Gateways & Aggregators:** Authoritative for external deposit inflows, gateway fees, merchant settlements, and P2P gateway checkouts.
3. **Book 3: Card Issuers & Processor Partners:** Authoritative for virtual/physical card issuance authorizations, interchange fees, card loads, JIT funding, and ATM/POS settlements.

### 1.2 The Master Reconciliation Equation

At any evaluation timestamp $T$, the system cash balance must satisfy:

$$\text{Ledger Cash Balance} = \sum \text{Settled Inflows} - \sum \text{Settled Outflows} - \sum \text{Partner Fees} - \sum \text{Issuer Holds} \pm \Delta \text{FX Variance}$$

Any discrepancy where $\Delta \neq 0$ is classified as an exception requiring automatic investigation or immediate human intervention.

---

## 2. Continuous (T+0) Reconciliation & Ingestion Workflows

Continuous reconciliation runs in near real-time (sub-minute latency) to catch failures, dropouts, and race conditions before they propagate into downstream banking cycles.

### 2.1 Webhook Ingestion Engine

External callbacks from gateways and card processors drive near real-time state changes. All incoming webhooks must traverse the following five-stage pipeline:

```
[ Incoming Webhook ]
        │
        ▼
1. Signature Verification (HMAC-SHA256 / RSA + Timestamp within 300s)
        │
        ▼
2. Deduplication Check (Lookup in `provider_webhook_events` by event_id)
        │
        ├── Duplicate ──► [ Return HTTP 200 OK (Idempotent ACK) ]
        │
        ▼ Unique
3. Atomic Ingestion Record (Status: RECEIVED)
        │
        ▼
4. Out-of-Order Sequencer (Evaluate event timestamp vs current entity state)
        │
        ▼
5. Ledger Transition & Balance Mutation (Within DB::transaction())
```

#### Verification Rules:
- **Signature Check:** If the HMAC signature is missing, invalid, or calculated using an expired secret, immediately answer `HTTP 401 Unauthorized`. Never reveal detailed internal validation failures to the caller.
- **Replay Protection:** Webhooks with a header timestamp older than 300 seconds are rejected (`HTTP 400 Bad Request`) to mitigate replay attacks.
- **Deduplication:** The tuple `(provider_code, event_id)` is stored in `provider_webhook_events` with a `UNIQUE` index. A replayed webhook must return `HTTP 200 OK` without re-executing any ledger change.

### 2.2 Out-of-Order Webhook Resolution

In asynchronous networks, completion events may arrive before creation events (e.g., `card.authorized` arriving before `card.created`, or `payment.settled` arriving before `payment.created`).

```
If Incoming Event: `CHARGE_SUCCEEDED`
Current Entity State in DB: `NOT_FOUND` or `DRAFT`

Action:
1. Do not crash or throw unhandled exception.
2. Create entity record in state `AWAITING_ANTECEDENT` or `PRE_AUTHORIZED`.
3. Park event payload in `pending_event_staging`.
4. Trigger Antecedent Fetch Worker (query provider API for parent order).
5. Upon parent resolution, replay parked event in correct chronological sequence.
```

### 2.3 Webhook Dead Letter Queue (DLQ) & Circuit Breaker

- Any webhook failing processing due to transient database lock or downstream timeout is retried with exponential backoff (`30s, 2m, 10m, 30m, 2h`).
- After 5 consecutive failures, the event transitions to `DEAD_LETTER` in table `webhook_dead_letters`.
- An automated alert triggers in PagerDuty / Slack (`#fin-alerts`) whenever DLQ depth exceeds 5 messages.

---

## 3. Status Inquiry Engine & Automated Recovery Patterns

When an outbound call to a payment gateway or card processor times out (TCP timeout, HTTP 504, connection reset), the outcome of the transaction is **AMBIGUOUS**. The system must never guess the outcome.

### 3.1 Status Inquiry State Machine

```
[ Client Mutation Submitted ]
             │
      Transport Timeout / 5xx
             │
             ▼
[ State: UNKNOWN_RECONCILIATION_REQUIRED ]
             │
             ├──► [ User UI: "Processing / Pending Verification" ]
             │    (Funds held, NOT debited twice, Intent LOCKED)
             │
             ▼
[ Status Inquiry Poller / Saga Worker ]
             │
             ├── Query Provider by `merchant_order_id` / `provider_reference`
             │
             ▼
      ┌─────────────────────────────────────────────────────────┐
      │                    Provider Response                    │
      └──────┬──────────────────────┬────────────────────┬──────┘
             │                      │                    │
          SUCCESS                 FAILED              NOT FOUND
             │                      │                    │
             ▼                      ▼                    ▼
     [ Commit Ledger ]      [ Release Hold ]     Wait SLA (15 min)
     [ State: SUCCEEDED ]   [ State: FAILED ]            │
                                                         ▼
                                                [ Re-query once ]
                                                         │
                                             Still 404? Cancel order
                                             [ Release Reservation ]
```

### 3.2 Polling Schedules & Progressive Backoff

The Status Inquiry Daemon runs on a progressive backoff schedule to balance prompt resolution with external rate limit preservation:

| Attempt | Elapsed Time Since Timeout | Polling Frequency | Target Escalation |
|---|---|---|---|
| 1 | 15 seconds | Immediate | Automatic |
| 2 | 45 seconds | +30 seconds | Automatic |
| 3 | 2 minutes | +75 seconds | Automatic |
| 4 | 5 minutes | +3 minutes | Automatic |
| 5 | 15 minutes | +10 minutes | Automatic |
| 6 | 30 minutes | +15 minutes | Automatic |
| 7 | 1 hour | +30 minutes | Alert Warning (Slack) |
| 8 | 4 hours | +3 hours | PagerDuty SEV-3 Ticket |
| Final | 24 hours | Daily Batch | Route to Manual Operations Queue |

### 3.3 Status Inquiry API Contract Matrix

| Domain | Provider | Inquiry Endpoint | Key Lookup Field | Fallback Action on 404 |
|---|---|---|---|---|
| Card Issuance | Stripe Issuing | `GET /v1/issuing/cards/{card_id}` | `card_id` or `metadata[order_id]` | After 15m: Release reservation |
| Card Issuance | BSI Cards | `POST /api/v2/cards/inquiry` | `merchant_transaction_id` | After 30m: Mark cancelled |
| Domestic Gateway | ZarinPal | `POST /pg/v4/payment/verify.json` | `authority` | Verify with merchant portal |
| Domestic Gateway | Shaparak | `POST /api/inquiry/verify` | `RefNum` / `Token` | Check clearing switch |
| Crypto Rails | Nobitex API | `GET /market/orders/status` | `order_id` / `client_id` | Match on blockchain TXID |

---

## 4. Daily Batch Reconciliation Workflow (T+1)

Daily batch reconciliation executes at 02:00 UTC daily for the preceding 24-hour cycle ($D-1$). It verifies aggregate clearing files against internal database transactions.

### 4.1 Ingestion of Settlement & Clearing Files

1. **Automated Retrieval:** SRE SFTP / API workers pull clearing files from partner endpoints (MT940, CAMT.053, CSV statements).
2. **Integrity Validation:** SHA-256 checksums and PGP signatures of incoming settlement files are verified before parsing.
3. **Staging:** Raw records are ingested into table `settlement_batch_raw_records` without transformation.

### 4.2 The 4-Point Tuple Matching Algorithm

The batch reconciliation engine performs automated matching against the core ledger using a strict four-point tuple:

$$\text{Match Tuple} = (\text{internal\_operation\_id}, \text{provider\_reference}, \text{currency}, \text{exact\_minor\_unit\_amount})$$

```sql
-- Core Reconciliation Matching Query (T+1)
SELECT 
    l.operation_id,
    l.amount AS ledger_amount,
    s.amount AS settlement_amount,
    l.currency,
    l.status AS ledger_status,
    s.status AS settlement_status,
    CASE 
        WHEN s.provider_reference IS NULL THEN 'ORPHAN_INTERNAL'
        WHEN l.operation_id IS NULL THEN 'ORPHAN_PROVIDER'
        WHEN l.amount != s.amount THEN 'AMOUNT_MISMATCH'
        WHEN l.currency != s.currency THEN 'CURRENCY_MISMATCH'
        ELSE 'MATCHED'
    END AS reconciliation_result
FROM ledger_transactions l
FULL OUTER JOIN settlement_batch_raw_records s
    ON l.operation_id = s.internal_operation_id
    OR l.provider_reference = s.provider_reference
WHERE l.created_at >= :start_date AND l.created_at < :end_date;
```

### 4.3 Fee & Foreign Exchange (FX) Reconciliation

- **Interchange & Processing Fees:** Quoted provider fees recorded in internal journal tables are compared against actual deductions in the settlement report.
- **Slippage Tolerance:** If fee deviation is $\le 0.05$ USD (or equivalent in IRT/EUR/CNY), the system posts an automated balancing adjustment to `GL-6100-FEE-VARIANCE`.
- **Unacceptable Slippage:** Any deviation $> 0.05$ USD triggers a `FEE_ANOMALY` exception and halts batch sign-off.
- **FX Variance:** For cross-currency card spends and exchanges, exchange rate variations between authorization timestamp and settlement timestamp are posted to `GL-7200-FX-REALIZED-GAIN-LOSS`.

---

## 5. Discrepancy Taxonomy & Step-by-Step Resolution Procedures

When the reconciliation engine detects a delta, it categorizes the incident into one of six standard discrepancy profiles. Operators must execute the exact corresponding resolution procedure.

---

### Discrepancy Profile 1: Unmatched Internal Pending (Orphan Ledger)

- **Description:** Internal ledger shows a transaction in `PROCESSING` or `AWAITING_PROVIDER` older than 30 minutes, but no matching record exists in the provider settlement file.
- **Root Cause:** Network drop before reaching provider, or user abandoned checkout before completing 3D-Secure challenge.
- **Severity:** SEV-3 (Informational / Cleanup)

#### Resolution Procedure:
1. **Automated Check:** Run active status inquiry via API using `merchant_order_id`.
2. **Provider confirms No Record:**
   - Execute internal cancellation transition.
   - Atomically release any wallet reservation or funds hold.
   - Post reverse journal entry: `Dr Wallet Balance (Locked) / Cr Wallet Balance (Available)`.
   - Update transaction state to `CANCELLED_NO_PROVIDER_RECORD`.
3. **Provider confirms Success:**
   - Provider captured the funds, but the webhook was dropped.
   - Force state transition to `SUCCEEDED`.
   - Post credit to user wallet and record settlement audit note.

---

### Discrepancy Profile 2: Orphan Provider Success (Money Captured Externally, Missing Locally)

- **Description:** Provider settlement file contains a captured payment, but the internal ledger contains no matching transaction, or the local order is marked `CANCELLED` / `FAILED`.
- **Root Cause:** User completed external payment after client-side timeout expired, or webhook delivery failed completely during backend maintenance.
- **Severity:** SEV-2 (High Risk — Customer Paid Without Service Delivery)

#### Resolution Procedure:
1. **Locate Customer Account:** Match provider metadata (`user_id`, `email`, `phone_number`, `national_id`).
2. **Validate Funds Clearance:** Confirm provider status is irreversibly `SETTLED`.
3. **Execute Compensatory Ledger Action:**
   ```php
   // Execute via Laravel Artisan Command:
   php artisan finance:reconcile-orphan-success \
       --provider-ref="ch_3M4ABC123XYZ" \
       --user-id=84291 \
       --amount="15000000" \
       --currency="IRT" \
       --reason="Unmatched provider capture recovered via T+1 batch"
   ```
4. **Post Journal Entry:** `Dr Gateway Clearing Receivable / Cr User Wallet (Available)`.
5. **Notify User:** Dispatch automated SMS / in-app notification: *"Your deposit of [Amount] [Currency] has been credited to your wallet following settlement verification."*

---

### Discrepancy Profile 3: Internal Succeeded / Provider Failed or Reversed

- **Description:** Internal ledger credited user wallet or marked a purchase complete, but the provider settlement report classifies the transaction as `FAILED`, `CANCELLED`, or `REVERSED`.
- **Root Cause:** Race condition in optimistic crediting, fraudulent chargeback, or gateway reversal after authorization.
- **Severity:** SEV-1 (Critical — Financial Deficit / Potential Loss of Funds)

#### Resolution Procedure:
1. **Immediate Quarantine:** Place an automated freeze on the affected user account wallet for the exact disputed amount:
   ```sql
   UPDATE user_wallets 
   SET locked_balance = locked_balance + :amount, 
       available_balance = available_balance - :amount 
   WHERE id = :wallet_id;
   ```
2. **Balance Check:**
   - If available balance was insufficient, account enters `NEGATIVE_BALANCE` state.
   - Flag user profile with `RISK_DEFICIT_HOLD`.
3. **Post Reversal Journal Entry:**
   - `Dr User Wallet (Reversal) / Cr Gateway Clearing Receivable`.
4. **Escalate to Fraud & Risk:** Create a high-priority ticket for Tier-3 Risk Operations to determine whether this was a technical glitch or deliberate chargeback fraud.

---

### Discrepancy Profile 4: Card Issuance Ambiguity

- **Description:** User requested a virtual card. Wallet funds were held for the issuance fee and initial load, but the external card issuer API timed out.
- **Root Cause:** Timeout between eCardo backend and Stripe Issuing / BSI Cards / Epay gateway.
- **Severity:** SEV-2 (Card program integrity)

#### Critical Anti-Duplication Rule:
```
NEVER TRIGGER A SECOND CARD CREATION CALL WITHOUT PROVING NO CARD WAS ISSUED.
CREATING A DUPLICATE CARD GENERATES UNRECOVERABLE ISSUER FEES AND DOUBLE-BINDS LIMITS.
```

#### Step-by-Step Resolution:
```
Step 1: Query Card Issuer API using `idempotency_key` and `client_reference_id`.
        ├── Case A: Card Exists at Issuer (Status: ACTIVE / INACTIVE):
        │     - Retrieve card_id, masked PAN, expiration, and provider token.
        │     - Complete local order record (Status: ISSUED).
        │     - Commit the funds hold: Dr Wallet Hold / Cr Issuer Clearing.
        │     - Notify user card is ready for use.
        │
        └── Case B: Card Does NOT Exist at Issuer (404 Not Found):
              - Release user wallet hold immediately.
              - Post reversal: Dr Wallet Hold / Cr Wallet Available.
              - Mark card order record: `FAILED_PROVISIONING`.
              - Show user clear, localized message: "Card creation could not be completed by issuer. Your funds have been released."
```

---

### Discrepancy Profile 5: Duplicate Webhook Callback / Replay

- **Description:** Multiple identical webhooks received for the same financial event across seconds or hours.
- **Root Cause:** Provider retry policy when eCardo acknowledgment was delayed, or network re-transmission.
- **Severity:** SEV-4 (Standard Operational Routine)

#### Resolution Procedure:
1. Lookup incoming `event_id` in `provider_webhook_events`.
2. Check existing record status.
3. If existing record is `PROCESSED`, immediately respond `HTTP 200 OK` with JSON body `{"status": "already_processed"}`.
4. Record duplicate receipt count in monitoring telemetry (`provider_webhook_duplicate_total{provider="stripe"}`).
5. Under zero circumstances execute any ledger posting or state transition.

---

### Discrepancy Profile 6: Exchange Rate / Slippage Anomaly

- **Description:** A currency exchange transaction cleared at an effective rate differing from the locked quote by more than the allowed maximum slippage boundary ($\pm 0.2\%$).
- **Severity:** SEV-3 (Market Risk / Loss of Margin)

#### Resolution Procedure:
1. Calculate delta: $\Delta = |\text{Quoted Amount} - \text{Cleared Amount}|$.
2. Verify timestamp of quote creation vs timestamp of settlement.
3. If delay was caused by internal queue latency, honor quoted rate for customer, post discrepancy to `GL-7210-INTERNAL-SLIPPAGE-EXPENSE`.
4. If discrepancy is due to provider rate manipulation, flag provider adapter for margin review.

---

## 6. Disputed States, Chargebacks, and Customer Inquiries

### 6.1 Dispute Lifecycle State Machine

```
[ Provider Dispute Webhook: `charge.dispute.created` ]
                         │
                         ▼
             [ State: DISPUTE_OPENED ]
                         │
        ├── Place hold on User Wallet (disputed amount + dispute fee)
        │
        ▼
   Evidence Gathering Window (SLA: 48 Hours)
        │ - User KYC documents
        │ - IP logs and Device Session Fingerprint
        │ - Transaction confirmation / OTP logs
        │ - Delivery proof / usage evidence
        │
        ▼
   [ State: EVIDENCE_SUBMITTED ]
        │
   ┌────┴───────────────────────────────────────┐
   │                                            │
[ Outcome: DISPUTE_WON ]              [ Outcome: DISPUTE_LOST ]
   │                                            │
   ▼                                            ▼
Release hold back to user wallet.     Commit loss to Ledger:
Notify user of favorable resolution.  Dr Dispute Loss Expense
                                      Cr Gateway Receivable
```

### 6.2 Customer Service Support Inquiries

When a customer contacts support claiming *"Money was deducted from my bank/wallet, but the transaction shows failed in the app"*:

1. Support Tier-1 looks up the transaction in Admin Console using `operation_id` or mobile number.
2. If status is `UNKNOWN_RECONCILIATION_REQUIRED`:
   - Support must **NOT** advise the customer to retry the payment immediately.
   - Support clicks **"Trigger Priority Status Inquiry"**.
   - Admin console issues immediate live API inquiry to provider.
   - If confirmed: transaction resolves to `SUCCEEDED` within 10 seconds.
   - If rejected: transaction resolves to `FAILED`, funds hold released immediately.

---

## 7. Incident Escalation, SLA Matrix & Operational Auditing

### 7.1 Severity & Response SLA Matrix

| Severity | Definition | Response SLA | Target Resolution SLA | Escalation Target |
|---|---|---|---|---|
| **SEV-1** | Active duplicate debit detected; Aggregate daily reconciliation mismatch $> \$2,500$ USD; Gateway double-posting. | **15 minutes** | **2 hours** | Head of Payments, VP Engineering, Lead SRE, Finance Director |
| **SEV-2** | Provider status inquiry engine stalled; Card issuer provisioning failure $> 5\%$ of orders; Orphan provider captures $> 10$ records. | **30 minutes** | **4 hours** | Senior Payments Engineer, On-call Backend Lead |
| **SEV-3** | Isolated customer dispute; Single orphan transaction; Daily settlement file parsing error with no loss of funds. | **2 hours** | **12 hours** | Payments Operations, Tier-3 Support Specialist |
| **SEV-4** | Duplicate webhook spike without ledger impact; Cosmetic display discrepancies in reconciliation dashboard. | **Next Business Day**| **48 hours** | DevOps / Platform Team |

### 7.2 Audit Trail & Evidence Preservation

To satisfy financial regulatory compliance, AML audits, and external banking partner reviews:

1. **Retention Period:** All reconciliation logs, matching results, exception tickets, and settlement files must be retained in immutable storage for **seven (7) years**.
2. **Audit Attributes:** Every reconciliation adjustment entry must record:
   - `operator_id` (System Daemon UUID or Admin User ID).
   - `authorization_reference` (Approval ticket ID from Jira/Linear).
   - `pre_balance` and `post_balance` snapshots.
   - `reason_code` and cryptographic hash of attached evidence.
3. **No Soft Deletions:** Deleting or altering rows in `reconciliation_cases`, `settlement_batch_raw_records`, or `ledger_transactions` is strictly prevented by database trigger constraints (`ON DELETE RESTRICT` and `BEFORE UPDATE RAISE EXCEPTION`).

---

## 8. SRE Operational Toolkit & Diagnostic Queries

### 8.1 Emergency Health Check Query

```sql
-- Fast Diagnostic: Identify Unreconciled Financial Records Older Than 15 Minutes
SELECT 
    domain,
    status,
    COUNT(*) AS pending_count,
    SUM(amount) AS total_pending_amount,
    MIN(created_at) AS oldest_pending_record
FROM financial_transactions
WHERE status IN ('PROCESSING', 'UNKNOWN_RECONCILIATION_REQUIRED', 'AWAITING_PROVIDER')
  AND created_at < NOW() - INTERVAL '15 minutes'
GROUP BY domain, status;
```

### 8.2 Force Re-Verification Command Line

```bash
# Force batch reconciliation for a specific date
php artisan finance:run-reconciliation --date=2026-10-17 --provider=zarinpal --force-recheck

# Run status inquiry worker in dry-run mode for audit
php artisan finance:status-inquiry-worker --dry-run --limit=100

# Inspect specific operation ID audit trail across all three books
php artisan finance:inspect-transaction --operation-id="550e8400-e29b-41d4-a716-446655440000"
```
