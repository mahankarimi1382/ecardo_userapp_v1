# 12. Data Governance, Telemetry Redaction & Event Taxonomy

- **Document Identifier:** DG-DOC-12  
- **Governance Version:** 1.0.0  
- **Status:** APPROVED & MANDATORY  
- **Date:** 2026-10-18  
- **Target Repository:** `ecardo_userapp_v1` & eCardo Core Platform  
- **Applicable Domains:** Flutter Mobile App (`ecardo_userapp_v1`), API Gateway, Backend Microservices (Laravel Octane), Dedicated Blockchain Host (`walet-ecardo`), OpenTelemetry Collector, Elasticsearch / Kibana  
- **Lead Authority:** Data Governance, Cryptographic Security & Financial Compliance Guilds  

---

## 1. Executive Summary & Governance Charter

This document establishes the binding data governance, telemetry classification, strict secret redaction, and event taxonomy standards for all cryptographic, wallet, and financial operations within the eCardo ecosystem.

### 1.1 Non-Negotiable Source of Truth Invariant
**Elasticsearch and the OpenTelemetry observability pipeline are strictly operational search, diagnostic, and distributed tracing facilities. They are NEVER the system of record or source of truth for financial balances, double-entry ledger journals, or user authorization states.**

1. **Transactional Authority:** The sole authoritative source of truth for all account balances, journal entries, and fiat/crypto liabilities is the primary relational ACID ledger (`ecardoq192` on MariaDB) synchronized with cryptographic confirmations from the blockchain gateway (`walet-ecardo` on `192.168.200.57`).
2. **Zero-Trust Observability:** Telemetry and search pipelines must operate under a zero-trust model where no downstream logging component or search cluster receives or stores unmasked secrets, private keys, or raw personal identifiable information (PII).
3. **Fail-Closed Redaction:** If an ingestion pipeline processor fails to apply redaction rules, the ingestion pipeline must discard the payload rather than permit unredacted ingestion into persistent search indices.

---

## 2. Four-Tier Enterprise Data Classification Framework

All data fields processed across mobile clients, backend services, network streams, and logging collectors are categorized into four distinct classification tiers:

```text
+---------------------------------------------------------------------------------------------------+
| Tier 4: Restricted Cryptographic & Authentication Secrets (Zero Persistent Logs / Zero Ingestion)  |
| - Private Keys (secp256k1, ED25519) | Seed Phrases / Mnemonics | Extended Keys (xprv)              |
| - HSM PINs / Vault KEKs | Bearer Tokens | Passwords | User Passcodes / PINs | CVV2 | OTP Codes    |
+---------------------------------------------------------------------------------------------------+
                                                  |
                                                  v
+---------------------------------------------------------------------------------------------------+
| Tier 3: Confidential Financial & KYC Data (Encrypted Storage / Strict Masking in Telemetry)       |
| - Full Primary Account Numbers (PAN) | Full Iranian Sheba / IBAN | National ID / Passport Scans  |
| - Raw Unmasked Balance Payloads | Biometric Templates | User Residential Addresses                 |
+---------------------------------------------------------------------------------------------------+
                                                  |
                                                  v
+---------------------------------------------------------------------------------------------------+
| Tier 2: Internal Pseudonymous Telemetry (Permitted in OTel & Elasticsearch under Schema)          |
| - Request ID (UUIDv4) | Operation ID (Stable Business Intent) | Trace ID / Span ID                |
| - Tokenized Wallet Reference (wallet_id) | Public Blockchain Addresses | Chain Transaction Hashes |
| - Error Reason Codes | RPC Latency | Confirmation Status | Fee Quote Identifiers                   |
+---------------------------------------------------------------------------------------------------+
                                                  |
                                                  v
+---------------------------------------------------------------------------------------------------+
| Tier 1: Public & System Metadata (Freely Allowable for Metrics and Monitoring)                    |
| - App Version (e.g. 1.0.174+174) | Platform (Android, iOS, Web) | Locale (fa, en, ar)            |
| - Network State (Cellular, WiFi) | HTTP Status Codes (200, 422, 500) | Route Names (Sanitized)     |
+---------------------------------------------------------------------------------------------------+
```

### 2.1 Tier Specification Matrix

| Data Tier | Classification Level | Description & Examples | Authorized Storage Locations | Telemetry & Search Index Rules |
| :--- | :--- | :--- | :--- | :--- |
| **Tier 4** | **Restricted Secrets** | Private keys, mnemonic seed phrases, BIP-32/44 `xprv`, Vault Transit keys, HSM credentials, OAuth bearer tokens, user account passwords, mobile 4-digit passcodes/PINs, credit card CVV/CVV2, OTP tokens, raw unencrypted signature payloads. | Secure Enclave / Android Keystore (mobile client); HashiCorp Vault Transit Engine (`walet-ecardo`). | **ABSOLUTELY FORBIDDEN.** Must never appear in application memory beyond transient signing execution, never written to disk logs, never transmitted to OpenTelemetry, and never indexed in Elasticsearch. |
| **Tier 3** | **Confidential Financial/KYC** | 16-digit card PANs, Iranian Sheba (`IR...`), international IBANs, national identification numbers, passport numbers, KYC identity documents, raw payment payload dumps, account balance totals. | Primary relational database (`ecardoq192`) with AES-256 field-level encryption; dedicated encrypted object storage for KYC. | **MASKED ONLY.** Telemetry may only store masked or tokenized representations (e.g., PAN masked to `603799******1234`, Sheba masked to `IR**...****3401`). Raw KYC documents and unmasked balances are blocked from ingestion. |
| **Tier 2** | **Pseudonymous Telemetry** | `request_id`, `operation_id`, `trace_id`, `span_id`, tokenized `wallet_id`, public chain addresses (`0x...`, `T...`), transaction hashes (`tx_hash`), block heights, RPC response times, error classification enums, fee quote IDs. | OpenTelemetry Collector, Elasticsearch indices (`traces-*`, `logs-*`, `audit-*`), Prometheus, Redis streams. | **AUTHORIZED UNDER RIGID SCHEMA.** Must strictly conform to index mapping templates. Dynamic mapping explosion is blocked. |
| **Tier 1** | **Public Metadata** | Application version (`1.0.174+174`), build number, operating system architecture, sanitized route paths (e.g. `/transfer_screen`), HTTP response codes, latency buckets. | Elasticsearch, Prometheus, Grafana, public status pages. | **FREELY PERMITTED.** Used for global platform health dashboards, error rate alerts, and SLO tracking. |

---

## 3. Strict Telemetry Redaction Architecture

Data redaction is enforced at every hop in the telemetry pipeline: on the mobile client, at the API Gateway, inside backend microservices, and within the OpenTelemetry Collector before data reaches Elasticsearch.

```text
+-----------------------+      HTTPS (TLS 1.3)      +-----------------------+
|  Flutter Client (v1)  | ------------------------> |   API Gateway / WAF   |
|  - Client Sanitizer   |                           |  - Header Stripping   |
|  - Dio Interceptor    |                           |  - Payload Scrubbing  |
+-----------------------+                           +-----------------------+
                                                                |
                                                                v
+-----------------------+     gRPC (mTLS Encrypted) +-----------------------+
|  Elasticsearch Cluster| <------------------------ | OpenTelemetry Collect |
|  - Explicit Mappings  |                           |  - redactionprocessor |
|  - ILM Retention      |                           |  - transformprocessor |
+-----------------------+                           +-----------------------+
```

### 3.1 Mobile Client Redaction Layer (`ecardo_userapp_v1`)
The Flutter client implements strict recursive redaction inside its network logging and telemetry interceptors (`lib/src/network/service/network_service.dart` and `offline_request_queue.dart`):

1. **Recursive Multi-Case Sanitization:** Every JSON payload, query parameter, and diagnostic breadcrumb is recursively scanned against a case-insensitive blocklist supporting `snake_case`, `camelCase`, `kebab-case`, and `PascalCase`.
2. **Blocked Sensitive Keys:**
   ```text
   password, pin, app_pin, passcode, seed, mnemonic, private_key, secret, 
   token, access_token, refresh_token, authorization, pan, cvv, cvv2, 
   card_number, national_code, otp, signature, key_ref, xprv, raw_tx,
   biometric_token, session_secret, shared_secret, recovery_phrase, salt
   ```
3. **Zero Error Body Leakage:** On HTTP 4xx and 5xx responses, error interceptors are forbidden from dumping raw response bodies to system log consoles. Only sanitized error messages, HTTP status codes, and server `request_id` values are captured.
4. **Verification Proof:** Verified in automated regression suite `test/workstream_b_idempotency_logging_test.dart` and security invariant tests in `test/reaudit_security_invariants_test.dart`.

### 3.2 OpenTelemetry Collector Redaction Configuration
The OpenTelemetry Collector deployed at `serv.interex.ir` executes inline stream redaction prior to sending data to Elasticsearch:

```yaml
# /etc/otelcol/config.yaml (Redaction Pipeline Excerpt)
processors:
  redaction:
    allow_all_keys: false
    blocked_values:
      # Hex-encoded private key pattern (64 hex characters)
      - "(?i)[0-9a-f]{64}"
      # 16-digit credit/debit card numbers
      - "\\b(?:\\d[ -]*?){13,16}\\b"
      # Iranian Sheba numbers (IR followed by 24 digits)
      - "(?i)IR\\d{24}"
      # BIP-39 mnemonic phrase detector (3+ consecutive dictionary words)
      - "\\b(?:abandon|ability|able|about|above|absent|absorb|abstract|absurd|abuse|access|accident|account|accuse|achieve|acid|acoustic|acquire|across|act|action|actor|actress|actual)\\b"
    allowed_keys:
      - "event_id"
      - "event_name"
      - "event_version"
      - "occurred_at"
      - "environment"
      - "service"
      - "request_id"
      - "operation_id"
      - "trace_id"
      - "resource_ref"
      - "status"
      - "reason_code"
      - "latency_ms"
      - "chain_id"
      - "tx_hash"
      - "app_version"
      - "platform"

  transform:
    log_statements:
      - context: log
        statements:
          # Scrub Authorization and Bearer tokens
          - replace_pattern(attributes["http.request.headers.authorization"], "Bearer .*", "Bearer [REDACTED]")
          - replace_pattern(attributes["http.request.headers.cookie"], ".*", "[REDACTED]")
          # Tokenize or mask sensitive parameters
          - replace_all_patterns(attributes, "value", "(?i)password|pin|seed|mnemonic", "[REDACTED]")
```

### 3.3 Transactional Outbox Pattern for Audit Events
To ensure business transactions and their corresponding audit events remain synchronized without data loss:
1. When a wallet state changes or a financial transfer executes, the service writes both the business entity record and an audit event to the `transactional_outbox` table within the **same MariaDB transaction**.
2. A resilient background publisher daemon reads committed outbox entries, enforces pseudonymous schema formatting, and pushes the event to the streaming queue.
3. If an observability downstream component suffers an outage, database commits are never rolled back; outbox records simply queue until the collector recovers, guaranteeing zero dropped financial audit trails.

---

## 4. Standardized Event Taxonomy

All domain, wallet, transfer, chain, and operational events emitted across eCardo must conform to the unified RFC 8785 canonical JSON envelope.

### 4.1 Canonical Envelope Specification

```json
{
  "event_id": "c1f7b8e2-4d3a-4e8b-9a1c-5d6e7f8a9b0c",
  "event_name": "wallet.transfer.status_changed",
  "event_version": 1,
  "occurred_at": "2026-10-18T14:30:00.123456Z",
  "environment": "production",
  "service": "transfer-orchestrator",
  "request_id": "req-9f8e7d6c-5b4a-3210",
  "operation_id": "op-fin-20261018-8839210",
  "trace_id": "4bf92f3577b34da6a3ce929d0e0e4736",
  "resource_ref": "wal-usr-99281a8b",
  "status": "pending_confirmation",
  "reason_code": "CHAIN_CONFIRMATION_PENDING"
}
```

### 4.2 Envelope Field Definitions

| Field Name | Type | Constraint | Description |
| :--- | :--- | :--- | :--- |
| `event_id` | String (UUIDv4) | Required, Immutable | Unique identifier for this discrete event emission. |
| `event_name` | String | Required | Hierarchical dot-notated event name (e.g. `domain.entity.action`). |
| `event_version` | Integer | Required, >= 1 | Schema version of the event payload. |
| `occurred_at` | String (ISO-8601 UTC) | Required | Microsecond-precision UTC timestamp of the occurrence. |
| `environment` | String | Enum | Execution environment: `production`, `staging`, `testnet`, `local`. |
| `service` | String | Enum | Originating microservice: `wallet-service`, `transfer-orchestrator`, `blockchain-gateway`, `signer-daemon`, `fee-engine`. |
| `request_id` | String | Required | Ephemeral HTTP/gRPC request identifier per network attempt. |
| `operation_id` | String | Required, Stable | Stable business intent identifier preserved across all retries, restarts, and background jobs. |
| `trace_id` | String (Hex 32) | Required | W3C distributed trace identifier linking all spans across tiers. |
| `resource_ref` | String | Required | Tokenized pseudonymous entity identifier (e.g. `wal-usr-99281a8b`). No direct customer PII. |
| `status` | String | Enum | Current state of the entity: `created`, `reserved`, `pending`, `confirmed`, `failed`, `reversed`. |
| `reason_code` | String | Required | Standardized machine-readable enum explaining the status transition. |

### 4.3 Domain Event Groups Registry

The following table catalogs all authorized event types within the eCardo blockchain, wallet, and financial infrastructure:

| Event Group | Event Name | Trigger Condition & Description | Permitted Attributes |
| :--- | :--- | :--- | :--- |
| **`wallet.*`** | `wallet.created` | New HD custodial wallet address provisioned for user. | `wallet_id`, `chain_id`, `derivation_index`, `address` |
| | `wallet.activated` | Wallet transitions from provisioning to active status. | `wallet_id`, `activation_source` |
| | `wallet.frozen` | Wallet administrative lock applied (AML/risk review). | `wallet_id`, `risk_tier`, `reason_code` |
| | `wallet.unfrozen` | Wallet administrative lock lifted after compliance review. | `wallet_id`, `approver_id`, `reason_code` |
| | `wallet.closed` | Wallet voluntarily closed by user or legal instruction. | `wallet_id`, `settlement_status` |
| | `wallet.key_rotation_requested` | Cryptographic key rotation initiated for custody domain. | `domain_id`, `old_key_ref`, `new_key_ref` |
| | `wallet.recovery_started` | Formal custodial account recovery procedure initiated. | `recovery_id`, `step_up_level`, `case_id` |
| | `wallet.recovery_completed` | Custodial account recovery successfully finalized. | `recovery_id`, `outcome` |
| **`transfer.*`** | `transfer.intent_created` | User submits money or token transfer intent. | `operation_id`, `asset`, `amount_scale` |
| | `transfer.quote_created` | Real-time fee and exchange rate quote bound to transfer. | `quote_id`, `expires_at`, `fee_scale` |
| | `transfer.authorized` | Passcode / MFA validation confirmed for transfer. | `operation_id`, `auth_method` |
| | `transfer.reserved` | Double-entry journal reserve recorded against liability. | `journal_entry_id`, `reserved_amount` |
| | `transfer.submitted` | Transaction broadcast to blockchain RPC network. | `tx_hash`, `nonce`, `chain_id` |
| | `transfer.status_changed` | Block confirmation count progressed. | `tx_hash`, `confirmations`, `block_height` |
| | `transfer.finalized` | Finality threshold reached; ledger marked finalized. | `tx_hash`, `finality_block`, `journal_entry_id` |
| | `transfer.reconciliation_required` | On-chain status diverges from internal ledger expectation. | `mismatch_id`, `expected_status`, `actual_status` |
| | `transfer.reversed` | Unconfirmed/failed transfer safely rolled back. | `operation_id`, `reversal_journal_id` |
| **`fee.*`** | `fee.quote_expired` | User failed to submit within fee quote TTL window. | `quote_id`, `expired_at` |
| | `fee.quote_rejected_max_fee` | Estimated on-chain network fee exceeds platform cap. | `quote_id`, `estimated_fee`, `max_fee_cap` |
| | `fee.policy_changed` | Platform fee structure or subsidy updated by admin. | `policy_version`, `effective_date` |
| **`signer.*`** | `signer.request_approved` | Signing policy engine permits transaction signature. | `request_id`, `key_ref`, `policy_id` |
| | `signer.request_denied` | Signing policy engine blocks request (limit/whitelist). | `request_id`, `rejection_reason` |
| | `signer.unavailable` | Vault Transit or HSM communication timeout. | `request_id`, `hsm_status` |
| **`chain.*`** | `chain.validator_lagging` | Private or public node block lag exceeds threshold. | `chain_id`, `lag_blocks`, `node_endpoint` |
| | `chain.rpc_unavailable` | Blockchain RPC endpoint failed health check probe. | `chain_id`, `rpc_endpoint`, `error_category` |
| | `chain.finality_delayed` | Network confirmation taking longer than standard window. | `chain_id`, `elapsed_seconds` |
| | `chain.reorg_detected` | Chain reorganization encountered affecting transaction. | `chain_id`, `depth`, `reorg_block` |
| | `chain.tx_rejected` | Node rejected transaction from mempool (gas/nonce). | `tx_hash`, `rejection_code` |
| **`card.*`** | `card.order_created` | Virtual or physical card order initiated. | `card_id`, `provider_code`, `currency` |
| | `card.provider_unavailable` | External card issuing partner API returned 5xx/timeout. | `provider_code`, `latency_ms` |
| | `card.order_pending` | Card provisioning submitted to payment card network. | `card_id`, `external_order_ref` |
| | `card.issued` | Card successfully created and bound to funding wallet. | `card_id`, `expiry_mmyy`, `funding_wallet_id` |
| | `card.funding_reconciled` | Card authorization matched against wallet funding ledger. | `authorization_id`, `cleared_amount` |
| **`security.*`** | `security.authorization_denied` | Invalid PIN/passcode threshold reached (lockout). | `user_id`, `failed_attempts`, `lockout_until` |
| | `security.step_up_failed` | High-value transfer secondary challenge failed. | `operation_id`, `challenge_type` |
| | `security.admin_change_requested` | Critical configuration change submitted for approval. | `change_ticket_id`, `initiator_id` |
| | `security.admin_change_approved` | Dual-control sign-off executed by secondary admin. | `change_ticket_id`, `approver_id` |
| **`reconciliation.*`** | `reconciliation.mismatch_detected` | Triple-ledger verification encountered numeric delta. | `case_id`, `delta_amount`, `asset`, `scope` |
| | `reconciliation.case_resolved` | Ledger exception analyzed, adjusted, and sign-off recorded. | `case_id`, `resolution_type`, `adjuster_id` |

---

## 5. Index Lifecycle Management (ILM) & Retention Policies

Elasticsearch data streams and indices are governed by rigid Index Lifecycle Management (ILM) policies to prevent unbounded disk usage, ensure predictable query performance, and satisfy statutory financial compliance regulations.

### 5.1 Dynamic Mapping Explosion Prevention
To eliminate Lucene memory pressure and mapping explosion:
1. Dynamic mapping is explicitly disabled (`numeric_detection: false`, `dynamic: strict` on root objects).
2. All index mappings must be deployed via declarative index templates version-controlled in the infrastructure repository.
3. Unrecognized fields injected into logs or traces result in immediate ingestion rejection.

### 5.2 ILM Retention Matrix

```text
[Hot Phase] -------------> [Warm Phase] -------------> [Cold Phase] -------------> [Delete Phase]
Active Write & Fast SSD    Read-Only Optimized        Sparse Storage / Queryable  Permanent Purge
```

| Index Category | Target Data Stream | Hot Phase | Warm Phase | Cold Phase | Retention / Delete |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Application & Diagnostics** | `logs-ecardo-app-*` | 7 Days (Rollover at 25GB or 7d) | 16 Days (Shrink, Force Merge to 1 segment) | 7 Days (Frozen read-only) | **Purged at Day 30** |
| **Distributed Traces** | `traces-ecardo-*` | 3 Days (Rollover at 50GB or 3d) | 4 Days (Sampling & Downsampling) | None | **Purged at Day 7** |
| **Security & Auth Step-Up** | `security-ecardo-*` | 30 Days (Rollover at 10GB or 30d) | 60 Days (Read-only, compressed) | None | **Purged at Day 90** |
| **Financial Audit Telemetry** | `audit-ecardo-events-*` | 30 Days (Rollover at 20GB or 30d) | 60 Days (Read-only, compressed) | 275 Days (Cold queryable snapshot) | **Moved to Snapshot Archive at Day 365** (Preserved 7 years) |

### 5.3 Snapshot & Disaster Recovery Policy
1. **Automated Snapshot Schedule:** Full cluster snapshots are taken daily at 02:00 UTC using the Elasticsearch Snapshot Repository plugin.
2. **Storage Isolation:** Snapshots are written to a physically and logically isolated backup host (`backup.interex.ir`) with dedicated, write-once credentials.
3. **Recovery Drills:** Semi-annual disaster recovery restore drills are mandatory. Restores are executed to a synthetic test cluster, validating index integrity and verifying zero data corruption per `docs/operations/SNAPSHOT-RESTORE-DRILL.md`.

---

## 6. Regulatory Compliance, Audits & Verification

### 6.1 Regulatory Alignment
- **PCI-DSS v4.0 Requirement 3:** Protect stored cardholder data. Raw PANs, card verification codes (CVV2), and PIN blocks are never stored in telemetry or search indices.
- **ISO/IEC 27001:2022 Control 8.15 & 8.24:** Logging and monitoring activities must be protected against tampering and unauthorized PII disclosure.
- **Fintech Data Residency:** All audit trails, telemetry streams, and transaction metadata remain hosted exclusively on sovereign enterprise servers (`serv.interex.ir` and internal clusters), completely free from unauthorized foreign cloud dependencies.

### 6.2 Automated CI Negative Testing Gate
Prior to merging any pull request affecting logging, networking, or telemetry:
1. Automated security tests (`test/workstream_b_idempotency_logging_test.dart` and `test/reaudit_security_invariants_test.dart`) inject synthetic Tier 4 payloads (simulated private keys, seeds, raw passwords, unmasked PANs) into client and backend loggers.
2. The test suite asserts that every sensitive key is replaced with `[REDACTED]` and that no raw secret string appears anywhere in output streams or memory dumps.
3. A failure in redaction triggers an immediate, non-bypassable CI build break.
