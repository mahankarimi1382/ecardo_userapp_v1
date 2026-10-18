# eCardo Canonical Retention Matrix & Data Lifecycle Policy

- **Document Version:** 1.0.0
- **Status:** APPROVED / CANONICAL COMPLIANCE STANDARD
- **Effective Date:** 2026-10-18
- **Governance Mandate:** EL-GOV-01 / ADR-008
- **Applicable Cluster:** `serv.interex.ir` (Production: 192.168.100.65)
- **Target Repository:** `ecardo_userapp_v1`
- **Applicable Regulations:** Central Bank e-Banking Guidelines, PCI-DSS v4.0 (Req 3 & 10), EU GDPR / UAE PDPL / Turkey KVKK Compliance Alignment

---

## 1. Regulatory Context & Core Retention Philosophy

The eCardo super-platform processes cross-border remittances, digital wallet balances, virtual/physical cards, and high-frequency travel/commerce transactions. In a fintech environment, telemetry and financial records have vastly different legal, compliance, and operational lifecycles.

```
+---------------------------------------------------------------------------------------------------+
|                                   THE RETENTION DICHOTOMY INVARIANT                               |
+---------------------------------------------------------------------------------------------------+
| 1. FINANCIAL LEDGER IS PERMANENT: Core accounting journals, balance transactions, payment finality|
|    records, and KYC approvals are legally binding books of record. They reside in PostgreSQL     |
|    and immutable encrypted archival vaults with a MINIMUM 10-YEAR statutory retention.            |
| 2. TELEMETRY IS EPHEMERAL: Operational search logs, distributed traces, and SRE metrics reside in|
|    Elasticsearch and are strictly governed by automated Index Lifecycle Management (ILM).         |
|    They are subject to IRREVERSIBLE HARD PURGE upon reaching expiration (14 to 180 days).         |
| 3. SEARCH INDEXES ARE NOT LEDGERS: Elasticsearch retention policies NEVER dictate the lifecycle   |
|    of actual financial records. Telemetry indices can be dropped or rebuilt without affecting     |
|    user funds, ledgers, or historical transaction integrity.                                      |
+---------------------------------------------------------------------------------------------------+
```

---

## 2. Canonical Telemetry Retention Matrix

The table below governs all data stream patterns, classification tiers, phase transitions, and hard deletion triggers across the eCardo telemetry platform:

| Data Stream Pattern | Classification Tier | Retention Period | Hot Phase (Write/Active) | Warm Phase (Read-Only/Merged) | Cold Phase (Searchable Snapshot) | Delete Phase (Hard Purge) | ILM Policy Name | Verification API Endpoint |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`logs-ecardo.api-prod`** | Tier 3 (Operational) | **90 Days** | **Days 1–7**<br>Rollover: `50GB` or `7d`<br>Priority: 100 | **Days 8–30**<br>`forcemerge`: 1 seg<br>Replicas: 1, Priority: 50 | **Days 31–90**<br>Searchable snapshots<br>Replicas: 0, Priority: 20 | **Day 91**<br>Hard Purge<br>`delete_snapshot: true` | `ecardo_api_ilm_policy` | `GET logs-ecardo.api-prod/_ilm/explain` |
| **`logs-ecardo.security-prod`** | Tier 3 (Security Audit) | **180 Days** | **Days 1–14**<br>Rollover: `50GB` or `14d`<br>Priority: 100 | **Days 15–60**<br>`forcemerge`: 1 seg<br>Replicas: 1, Priority: 50 | **Days 61–180**<br>Searchable snapshots<br>Replicas: 0, Priority: 20 | **Day 181**<br>Hard Purge<br>`delete_snapshot: true` | `ecardo_security_ilm_policy` | `GET logs-ecardo.security-prod/_ilm/explain` |
| **`logs-ecardo.mobile-prod`** | Tier 3 (Client Telemetry) | **30 Days** | **Days 1–7**<br>Rollover: `25GB` or `7d`<br>Priority: 100 | **Days 8–30**<br>`forcemerge`: 1 seg<br>Replicas: 1, Priority: 50 | *Skipped* (Direct warm-to-delete) | **Day 31**<br>Hard Purge<br>`delete: {}` | `ecardo_mobile_ilm_policy` | `GET logs-ecardo.mobile-prod/_ilm/explain` |
| **`traces-ecardo.*`** | Tier 3 (APM Spans) | **14 Days** | **Days 1–3**<br>Rollover: `25GB` or `3d`<br>Priority: 100 | **Days 4–14**<br>`forcemerge`: 1 seg<br>Replicas: 1, Priority: 50 | *Skipped* (Direct warm-to-delete) | **Day 15**<br>Hard Purge<br>`delete: {}` | `ecardo_traces_ilm_policy` | `GET traces-ecardo.*/_ilm/explain` |
| **`metrics-ecardo.*`** | Tier 3 (Time Series) | **90 Days** | **Days 1–30**<br>Raw 10s intervals<br>Priority: 100 | **Days 31–90**<br>Downsampled 5m rollups<br>Priority: 50 | *Skipped* | **Day 91**<br>Hard Purge<br>`delete: {}` | `ecardo_metrics_ilm_policy` | `GET metrics-ecardo.*/_ilm/explain` |
| **`clickhouse.events_raw`** *(Conditional)* | Tier 3 (Aggregates) | **365 Days** | Partition by month (`toYYYYMM(event_date)`) | TTL policy: move to S3 cold storage after 90 days | N/A | Hard drop partition after 365 days | `TTL event_date + INTERVAL 365 DAY` | `SELECT table, partition FROM system.parts` |
| **`postgresql.ledger_entries`** | Tier 2 (Confidential Core) | **10+ Years** | Primary NVMe SSD Cluster<br>Active ACID Journal | Continuous physical replication to standby nodes | Monthly encrypted cold vault export | NEVER purged via automated TTL | Statutory Legal Mandate | `SELECT COUNT(*) FROM ledger_entries` |

---

## 3. Storage Lifecycle Phases & Optimization Actions

The lifecycle transitions are optimized to balance low query latency for active incidents against storage cost and cluster stability:

```
  +---------------+       +---------------+       +---------------+       +---------------+
  |   HOT PHASE   | ----> |  WARM PHASE   | ----> |  COLD PHASE   | ----> | DELETE PHASE  |
  +---------------+       +---------------+       +---------------+       +---------------+
  | Ingestion     |       | Read-Only     |       | Searchable    |       | Irreversible  |
  | Write Buffer  |       | Segment Merge |       | Snapshots     |       | Automated     |
  | Fast NVMe I/O |       | Zero Deletes  |       | Zero Replicas |       | Disk Purge    |
  | Priority: 100 |       | Priority: 50  |       | Priority: 20  |       | SLA Cleared   |
  +---------------+       +---------------+       +---------------+       +---------------+
```

### 3.1 Hot Phase (Active Ingestion & Triage)
- **Primary Goal:** Maximum write throughput and sub-second query latency for active production incident response.
- **Backing Hardware:** Direct-attached NVMe storage (`data_hot` node tier).
- **Rollover Triggers:** 
  - Primary shard size exceeds **50 GB** (or **25 GB** for mobile/traces).
  - Maximum age reached (3 days for traces, 7 days for API/mobile, 14 days for security).
- **Index Priority:** 100 (ensures shards recover first during cluster restart).
- **High Availability:** 1 replica shard maintained in production at all times.

### 3.2 Warm Phase (Diagnostic Search & Optimization)
- **Primary Goal:** Fast query performance for historical investigations with minimized memory footprint.
- **Actions:**
  - Index marked read-only (`index.blocks.write: true`).
  - **Force Merge:** Segment count consolidated down to **1 segment** (`max_num_segments: 1`). This permanently purges deleted documents, optimizes Lucene inverted indexes, and drastically frees JVM heap memory.
  - Replica count maintained at 1 for fault tolerance.
  - Index priority lowered to 50.

### 3.3 Cold Phase (Long-Tail Regulatory Retention)
- **Primary Goal:** Low-cost retention for compliance and security audit trails without consuming active cluster disk space.
- **Actions:**
  - Indices mounted as **Searchable Snapshots** backed by off-cluster S3 storage (`repository-s3`).
  - Local replicas reduced to **0**, slashing storage consumption by 50%.
  - Local data blocks cached only on-demand during active queries.
  - Index priority lowered to 20.

### 3.4 Delete Phase (Compliance Hard Purge)
- **Primary Goal:** Automated, irreversible data destruction in strict adherence to data minimization standards and privacy laws.
- **Actions:**
  - Backing indices completely deleted from the cluster.
  - Corresponding searchable snapshot metadata unmounted.
  - Storage space immediately reclaimed on data disks.

---

## 4. Critical Implementation Caveat: Self-Managed OTel Data Streams

```
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                                    CRITICAL SRE IMPLEMENTATION WARNING                            !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! As highlighted in Elasticsearch documentation, when running OpenTelemetry data streams in         !
! self-managed / on-premises environments (such as serv.interex.ir), AUTOMATED RETENTION IS NOT     !
! ENABLED BY DEFAULT.                                                                               !
!                                                                                                   !
! Unlike managed Elastic Cloud deployments, an on-premises cluster will continue indexing data      !
! indefinitely until disk space is exhausted (100% capacity) unless:                                !
! 1. An explicit ILM policy is created and registered.                                              !
! 2. Composable Index Templates bind the data stream pattern to that specific policy.               !
! 3. The ILM daemon is actively running and verified via _ilm/status.                              !
!                                                                                                   !
! It is an engineering failure to document retention in Markdown without verifying that the ILM    !
! policy is bound and actively deleting aged shards on the server.                                  !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
```

---

## 5. Telemetry Sanitization & Zero-Retention Secrets Rule

Under data classification governance, **Tier 1 Restricted Secrets** carry a **Zero-Day Retention (Immediate Purge)** mandate. If sensitive data ever leaks into telemetry indices, it must not wait for the standard 14–90 day deletion window.

### 5.1 Zero-Retention Data Items
1. Primary Account Numbers (Full 16-digit PAN).
2. Card Verification Values (CVV, CVV2, CVC).
3. Plaintext Passwords, PINs, Passcodes.
4. One-Time Passwords (OTPs) and SMS verification text.
5. Bearer / JWT Session Tokens and API Secret Keys.
6. Iranian National IDs (Melli Code) and Passport scans.

### 5.2 Emergency Redaction Incident Runbook (Data Contamination)
In the event that unredacted secrets are detected in active Elasticsearch indices:
1. **Immediate Quarantine:** Route traffic through an emergency ingest pipeline with aggressive masking.
2. **Targeted In-Place Update:** Execute an `_update_by_query` with a script masking the contaminated field across matching documents:
   ```bash
   curl -X POST "https://serv.interex.ir:9200/logs-ecardo.api-prod/_update_by_query?conflicts=proceed" \
     -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
     -H "Content-Type: application/json" \
     -d '{
       "script": {
         "source": "ctx._source.message = ctx._source.message.replaceAll(\"[0-9]{16}\", \"[REDACTED_EMERGENCY_PAN]\")",
         "lang": "painless"
       },
       "query": {
         "match_phrase": { "message": "unredacted_marker" }
       }
     }'
   ```
3. **Hard Shard Rollover & Force Merge:** Force an immediate rollover and run `_forcemerge?only_expunge_deletes=true` to permanently purge deleted Lucene blocks from disk.
4. **Issue Post-Mortem:** File a P0 Security Incident and update automated negative CI tests (`scripts/check_no_sensitive_telemetry.py`).

---

## 6. Automated Audit & Compliance Verification Commands

SRE and Platform engineers must execute and log the following verification queries during monthly audits:

### 6.1 Check ILM Daemon Operation
```bash
# Verify ILM service is actively RUNNING
curl -s -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  "https://serv.interex.ir:9200/_ilm/status" | jq .
# Expected Output: { "operation_mode": "RUNNING" }
```

### 6.2 Audit ILM Policy Binding on Data Streams
```bash
# Verify that all active telemetry streams are attached to their canonical policies
curl -s -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  "https://serv.interex.ir:9200/logs-ecardo.*,traces-ecardo.*/_ilm/explain" | \
  jq '.indices[] | {index: .index, policy: .policy, phase: .phase, action: .action, age: .age}'
```

### 6.3 Identify Orphan or Expired Indices
```bash
# List all indices with creation date and disk size, sorted by creation date
curl -s -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  "https://serv.interex.ir:9200/_cat/indices/logs-ecardo.*,traces-ecardo.*?v&h=index,health,status,creation.date.string,pri.store.size,docs.count&s=creation.date:asc"
```

### 6.4 Verify Snapshot Lifecycle Management (SLM) Execution
```bash
# Inspect SLM execution history and verify latest snapshot status
curl -s -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  "https://serv.interex.ir:9200/_slm/policy/ecardo_hourly_telemetry_snapshots" | jq .
```

---

## 7. Compliance Attestation & Verification Schedule

| Audit Milestone | Frequency | Responsible Role | Verification Deliverable |
| :--- | :--- | :--- | :--- |
| **ILM Phase Health Check** | Weekly | SRE On-Call | Verify zero indices stuck in `ERROR` step via `_ilm/explain`. |
| **Snapshot Integrity Check** | Daily (Automated) | Infrastructure Bot | Automated webhook verifying hourly SLM snapshot success. |
| **Telemetry Redaction Scan** | Every CI Build | QA / SecOps | Passing execution of `scripts/check_no_sensitive_telemetry.py`. |
| **Quarterly Restore Drill** | Every 90 Days | Lead Platform Architect | Completed test drill log in `docs/operations/SNAPSHOT-RESTORE-DRILL.md`. |
| **Retention Matrix Legal Review** | Annually | Legal Counsel + Head of SRE | Formally signed compliance attestation and policy updates. |
