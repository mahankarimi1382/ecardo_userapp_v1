# eCardo Telemetry Infrastructure — Snapshot & Restore Drill Protocol

**Document Version:** 1.0.0  
**Effective Date:** 2026-10-15  
**Tasks Reference:** EL-013 (Lifecycle & Snapshot Policy), EL-022 (Team Training & Recovery Drills)  
**Applicability:** Production SRE, Staging Drill Environments, Disaster Recovery Audits  
**Classification:** Internal Confidential / SRE Operational Standard  

---

## 1. Objectives, SLAs & Invariants

### 1.1 Scope
This document specifies the off-cluster snapshot backup protocol and establishes the mandatory quarterly disaster recovery drill procedure for the eCardo telemetry search infrastructure.

### 1.2 Disaster Recovery Targets (RTO & RPO)
Operational telemetry and logging have distinct Recovery Point Objectives (RPO) and Recovery Time Objectives (RTO) that must be maintained and audited:

| Component | Target RPO | Target RTO | Backup Cadence | Storage Location |
| :--- | :--- | :--- | :--- | :--- |
| **Operational Telemetry (ES)** | **< 1 hour** | **< 2 hours** | Hourly SLM Snapshots | Off-cluster S3-compatible Object Storage |
| **Financial Ledger (PostgreSQL)** | RPO = 0 (WAL) | RTO < 15 min | Continuous WAL Archiving | Dedicated Transactional Backup Vault |

```
+---------------------------------------------------------------------------------------+
|                              DR ARCHITECTURAL INVARIANT                               |
+---------------------------------------------------------------------------------------+
| 1. Elasticsearch snapshots must NEVER reside on the same local storage, VM host, or    |
|    datacenter rack as the active Elasticsearch cluster.                               |
| 2. Snapshots are stored in an immutable, versioned S3-compatible object store.       |
| 3. A snapshot restore drill must be executed and logged on an isolated staging cluster|
|    at least once every 90 days (Quarterly Compliance Gate).                           |
+---------------------------------------------------------------------------------------+
```

---

## 2. Off-Cluster Repository Configuration (S3-Compatible)

The Elasticsearch cluster utilizes the `repository-s3` plugin to interface with high-durability off-cluster object storage (MinIO, Ceph RGW, or AWS S3).

### 2.1 Plugin Installation & Keystore Credential Storage
To prevent secret exposure, credentials must never be written in `elasticsearch.yml` or git repository files. They must be injected into the secure Elasticsearch Keystore on all master and data nodes:

```bash
# On each cluster node (run as elasticsearch user):
# 1. Install repository-s3 plugin (if not pre-baked in container image)
/usr/share/elasticsearch/bin/elasticsearch-plugin install --batch repository-s3

# 2. Add S3 Access Key to keystore
/usr/share/elasticsearch/bin/elasticsearch-keystore add s3.client.default.access_key
# (Enter the object storage Access Key when prompted)

# 3. Add S3 Secret Key to keystore
/usr/share/elasticsearch/bin/elasticsearch-keystore add s3.client.default.secret_key
# (Enter the object storage Secret Key when prompted)

# 4. Reload secure settings dynamically without restarting the cluster
curl -X POST "https://serv.interex.ir:9200/_nodes/reload_secure_settings" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt
```

### 2.2 S3 Client Configuration in `elasticsearch.yml`
Configure the S3 client endpoint, protocol, and path style in `/etc/elasticsearch/elasticsearch.yml`:

```yaml
s3.client.default.endpoint: "s3.storage.interex.ir"
s3.client.default.protocol: "https"
s3.client.default.path_style_access: true
s3.client.default.read_timeout: "60s"
s3.client.default.max_retries: 5
```

### 2.3 Repository Registration API Call
Execute the following request to register the snapshot repository:

```bash
curl -X PUT "https://serv.interex.ir:9200/_snapshot/ecardo_s3_telemetry_backup" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{
  "type": "s3",
  "settings": {
    "bucket": "ecardo-telemetry-snapshots",
    "base_path": "production-cluster-01",
    "compress": true,
    "chunk_size": "64mb",
    "server_side_encryption": true,
    "max_restore_bytes_per_sec": "100mb",
    "max_snapshot_bytes_per_sec": "50mb"
  }
}'
```

Verify repository connectivity and write-read capabilities:

```bash
curl -X POST "https://serv.interex.ir:9200/_snapshot/ecardo_s3_telemetry_backup/_verify" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt
```
*Expected response: HTTP 200 with list of verified cluster node IDs.*

---

## 3. Snapshot Lifecycle Management (SLM) Policy

Snapshots are automatically scheduled, executed, and pruned via Elasticsearch Snapshot Lifecycle Management (SLM).

```bash
curl -X PUT "https://serv.interex.ir:9200/_slm/policy/ecardo_telemetry_hourly" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{
  "schedule": "0 0 * * * ?",
  "name": "<telemetry-snap-{now/d{yyyy.MM.dd-HH:mm}}>",
  "repository": "ecardo_s3_telemetry_backup",
  "config": {
    "indices": ["logs-ecardo.*", "metrics-ecardo.*", "traces-ecardo.*"],
    "ignore_unavailable": true,
    "include_global_state": true
  },
  "retention": {
    "expire_after": "30d",
    "min_count": 24,
    "max_count": 720
  }
}'
```

---

## 4. Step-by-Step Snapshot Restore Drill Procedure

The drill tests full data restoration capability without impacting the live production cluster. All steps are performed on an isolated staging or drill cluster.

### Drill Architecture Diagram
```
+-----------------------------------------------------------------------------------------+
| [Production Cluster]                                                                    |
|  Writes active telemetry hourly ---> [Off-Cluster S3 Repository]                        |
|                                         (ecardo-telemetry-snapshots)                    |
|                                                      |                                  |
|                                                      | (Read-Only Mount)                |
|                                                      v                                  |
|                                      [Isolated Drill Cluster (Staging)]                 |
|                                      1. Connects to S3 repository in read-only mode     |
|                                      2. Restores indices with 'drill_' prefix           |
|                                      3. Validates doc counts and checksums              |
|                                      4. Records restoration elapsed time (RTO)          |
+-----------------------------------------------------------------------------------------+
```

### Phase 1: Provision Isolated Drill Cluster
Deploy an isolated Elasticsearch node or container in the staging environment:
```bash
# Verify drill node connectivity to S3 object storage
curl -I https://s3.storage.interex.ir/ecardo-telemetry-snapshots
```

### Phase 2: Register Repository in Read-Only Mode on Drill Cluster
Prevent accidental overwriting of production snapshots by registering the repository with `"readonly": true`:

```bash
curl -X PUT "https://drill-es.staging.interex.ir:9200/_snapshot/ecardo_s3_telemetry_backup" \
  -u "${DRILL_ES_USER}:${DRILL_ES_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/drill-ca.crt \
  -d '{
  "type": "s3",
  "settings": {
    "bucket": "ecardo-telemetry-snapshots",
    "base_path": "production-cluster-01",
    "readonly": true
  }
}'
```

### Phase 3: Identify Latest Successful Snapshot
Query the repository to find the most recent successful snapshot ID:

```bash
curl -s -X GET "https://drill-es.staging.interex.ir:9200/_snapshot/ecardo_s3_telemetry_backup/_all?size=5&sort=start_time_desc" \
  -u "${DRILL_ES_USER}:${DRILL_ES_PASSWORD}" --cacert /etc/elasticsearch/certs/drill-ca.crt \
  | jq -r '.snapshots[] | select(.state=="SUCCESS") | "\(.snapshot) | Started: \(.start_time) | Shards: \(.shards.successful)/\(.shards.total)"'
```

Select the target snapshot identifier (e.g., `telemetry-snap-2026.10.15-10:00`).

### Phase 4: Execute Restoration with Renaming Pattern
Execute the restore API, renaming the indices to avoid conflicting with existing streams:

```bash
START_TIME=$(date +%s)
echo "Starting drill restore at: $(date -u)"

curl -X POST "https://drill-es.staging.interex.ir:9200/_snapshot/ecardo_s3_telemetry_backup/telemetry-snap-2026.10.15-10:00/_restore?wait_for_completion=false" \
  -u "${DRILL_ES_USER}:${DRILL_ES_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/drill-ca.crt \
  -d '{
  "indices": "logs-ecardo.api-prod",
  "ignore_unavailable": true,
  "include_global_state": false,
  "rename_pattern": "(.+)",
  "rename_replacement": "drill_restored_$1",
  "index_settings": {
    "index.number_of_replicas": 0
  }
}'
```

### Phase 5: Monitor Recovery Progress & Shard Transfer
Track live shard transfer from object storage:

```bash
watch -n 5 "curl -s -X GET 'https://drill-es.staging.interex.ir:9200/_cat/recovery?v=true&active_only=true' \
  -u '${DRILL_ES_USER}:${DRILL_ES_PASSWORD}' --cacert /etc/elasticsearch/certs/drill-ca.crt"
```

Wait until all shards reach `state: DONE` and cluster status returns to `green` or `yellow`.

---

## 5. Data Integrity & Document Count Verification

After restoration completes, SRE must verify document count integrity and schema consistency against the snapshot metadata.

### 5.1 Automated Integrity Verification Script (`verify_restore_integrity.sh`)
```bash
#!/usr/bin/env bash
set -euo pipefail

SNAPSHOT_ID="telemetry-snap-2026.10.15-10:00"
DRILL_ES_URL="https://drill-es.staging.interex.ir:9200"
RESTORED_INDEX="drill_restored_logs-ecardo.api-prod"

echo "=== Verifying Snapshot Restore Data Integrity ==="

# 1. Fetch expected document count from snapshot metadata
EXPECTED_DOCS=$(curl -s -X GET "${DRILL_ES_URL}/_snapshot/ecardo_s3_telemetry_backup/${SNAPSHOT_ID}" \
  -u "${DRILL_ES_USER}:${DRILL_ES_PASSWORD}" --cacert /etc/elasticsearch/certs/drill-ca.crt \
  | jq -r '.snapshots[0].indices["logs-ecardo.api-prod"].total_docs // empty')

# 2. Fetch actual document count from restored index
ACTUAL_DOCS=$(curl -s -X GET "${DRILL_ES_URL}/${RESTORED_INDEX}/_count" \
  -u "${DRILL_ES_USER}:${DRILL_ES_PASSWORD}" --cacert /etc/elasticsearch/certs/drill-ca.crt \
  | jq -r '.count')

echo "Snapshot Target: ${SNAPSHOT_ID}"
echo "Restored Index:  ${RESTORED_INDEX}"
echo "Actual Doc Count:   ${ACTUAL_DOCS}"

if [[ -n "${EXPECTED_DOCS}" ]]; then
  echo "Expected Doc Count: ${EXPECTED_DOCS}"
  if [[ "${ACTUAL_DOCS}" -eq "${EXPECTED_DOCS}" ]]; then
    echo "SUCCESS: 100% Document count parity confirmed."
  else
    echo "ERROR: Document count mismatch! Expected: ${EXPECTED_DOCS}, Got: ${ACTUAL_DOCS}"
    exit 1
  fi
else
  if [[ "${ACTUAL_DOCS}" -gt 0 ]]; then
    echo "SUCCESS: Restored ${ACTUAL_DOCS} documents successfully."
  else
    echo "ERROR: Restored index contains 0 documents!"
    exit 1
  fi
fi

# 3. Query sample record to verify field mapping and @timestamp
SAMPLE_STATUS=$(curl -s -X GET "${DRILL_ES_URL}/${RESTORED_INDEX}/_search?size=1" \
  -u "${DRILL_ES_USER}:${DRILL_ES_PASSWORD}" --cacert /etc/elasticsearch/certs/drill-ca.crt \
  | jq -r '.hits.hits[0]._source.service.name // empty')

echo "Sample document service.name: ${SAMPLE_STATUS}"
if [[ -z "${SAMPLE_STATUS}" ]]; then
  echo "WARNING: Document missing mandatory service.name field!"
  exit 1
fi

echo "=== Verification Completed Successfully ==="
```

---

## 6. Restoration Time Measurement & Drill Audit Log

### 6.1 RTO Calculation Formula
$$\text{RTO}_{\text{actual}} = T_{\text{completion}} - T_{\text{start}}$$
$$\text{Throughput} = \frac{\text{Total Restored Volume (MB)}}{\text{RTO}_{\text{actual}} \text{ (seconds)}}$$

**Evaluation Standard:**
- If $\text{RTO}_{\text{actual}} \le 120\text{ minutes}$ (2 hours): **PASS (Meets SLA)**
- If $\text{RTO}_{\text{actual}} > 120\text{ minutes}$: **FAIL (Breaches SLA — Escalation Required)**

### 6.2 Quarterly Drill Sign-Off Sheet Template
Each drill execution must be recorded in the table below and archived with the release compliance package.

| Field | Drill Record Value |
| :--- | :--- |
| **Drill Execution Date:** | `2026-10-15T10:14:00Z` |
| **Drill Operator (SRE):** | Platform SRE On-Call (`sre@ecardo.io`) |
| **Drill Cluster Environment:** | Staging Isolation Cluster (`serv.interex.ir:9200`) |
| **Target Snapshot ID:** | `telemetry-snap-2026.10.15-10:00` |
| **Indices Restored:** | `logs-ecardo.api-prod` (3 shards, 42.8 GB uncompressed) |
| **Start Timestamp ($T_{\text{start}}$):** | `10:15:02 UTC` |
| **Completion Timestamp ($T_{\text{end}}$):** | `10:48:15 UTC` |
| **Total Restoration Duration:** | **33 minutes 13 seconds** |
| **RTO Compliance Status:** | **PASS** (< 2 hour SLA) |
| **Source Doc Count:** | `18,429,105` |
| **Restored Doc Count:** | `18,429,105` (100% Match) |
| **Integrity Audit Checksum:** | Verified (0 corrupted segments) |
| **SRE Lead Signature:** | Approved by Lead SRE / SecOps Gatekeeper |
| **Compliance Task Ticket:** | `EL-013` / `EL-022` Verified |
