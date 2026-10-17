# eCardo Telemetry Infrastructure — Operational Incident Response Playbooks

**Document Version:** 1.0.0  
**Effective Date:** 2026-10-15  
**Tasks Reference:** EL-018 (Alerting, Runbooks & Escalation)  
**Applicability:** Production Telemetry Cluster, OpenTelemetry Collectors, Ingestion Workers  
**Classification:** Internal Confidential / SRE Operational Standard  

---

## 1. Incident Management Framework

### 1.1 Incident Command Structure
During a telemetry incident, the SRE team operates under standard Incident Command System (ICS):

| Role | Responsibility | Designation |
| :--- | :--- | :--- |
| **Incident Commander (IC)** | Leads triage, authorizes emergency index deletions, directs escalation. | Primary SRE On-Call |
| **Operations Lead (Ops)** | Executes diagnostic commands, adjusts worker concurrency, patches pipelines. | Platform / DevOps Engineer |
| **Communications Lead** | Updates status page, notifies Product/Fintech Leads, logs timeline. | Engineering Manager |
| **Security Liaison (SecOps)** | Mandatory for Scenario C (PII / Secret Ingestion) incidents. | Lead Security Engineer |

### 1.2 Severity Classification Matrix
| Severity | Description | Response SLA | Pager Channel |
| :--- | :--- | :--- | :--- |
| **SEV-1 (Critical)** | Active PII/credential leak, cluster flood-stage read-only lock, or complete ingest failure. | **< 5 minutes** | PagerDuty: `sre-telemetry-p0` |
| **SEV-2 (High)** | Ingestion lag > 50,000 events, bulk rejections > 0, disk usage > 90%. | **< 15 minutes** | PagerDuty: `sre-telemetry-p1` |
| **SEV-3 (Moderate)** | Single worker node crash, non-critical stream delay, replica unassigned. | **< 60 minutes** | Slack: `#ops-telemetry-alerts` |

```
+---------------------------------------------------------------------------------------+
|                              FINANCIAL ISOLATION MANDATE                              |
+---------------------------------------------------------------------------------------+
| Even during a SEV-1 Telemetry incident, financial transactions, database commits,      |
| user balance operations, and payment gateway responses must proceed unaffected.      |
| Under no circumstances should backend API traffic be throttled or halted to "save"    |
| the telemetry or logging cluster. Drop telemetry before dropping transactions.       |
+---------------------------------------------------------------------------------------+
```

---

## 2. Playbook A: High Ingestion Lag & Queue Backlog

### 2.1 Symptoms & Triggers
- **Alert:** `TelemetryIngestionLagHigh` firing continuously for > 3 minutes.
- **Queue Depth:** Kafka / Outbox / Redis consumer queue exceeds 50,000 unprocessed events.
- **Latency:** Ingestion end-to-end latency ($T_{\text{indexed}} - T_{\text{emitted}}$) exceeds 60 seconds (target: < 5s).
- **Client Impact:** Dashboards in Kibana lag behind real-time user activity.

### 2.2 Triage & Root Cause Identification
Execute diagnostics in sequence:

```bash
# 1. Inspect write thread pool rejections and queue depth on Elasticsearch
curl -s -X GET "https://serv.interex.ir:9200/_cat/thread_pool/write?v=true&h=host,name,active,queue,rejected,completed" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt

# 2. Inspect OpenTelemetry Collector export buffer queue status
curl -s http://localhost:8888/metrics | grep "otelcol_exporter_queue_size"

# 3. Check consumer worker CPU utilization and active task count
ps aux | grep "telemetry-worker"
```

**Diagnostic Flowchart:**
- If `rejected > 0` on Elasticsearch $\rightarrow$ Elasticsearch indexing bottleneck (Proceed to Section 2.3).
- If `rejected == 0` and worker CPU is 100% $\rightarrow$ Ingestion worker CPU starvation (Proceed to Section 2.4).
- If Collector memory buffer is near capacity $\rightarrow$ Collector exporter backpressure (Proceed to Section 2.5).

### 2.3 Mitigation: Elasticsearch Indexing Optimization
Relieve cluster indexing load by relaxing Lucene commit frequency and temporarily shedding replica synchronization:

```bash
# Step 1: Extend refresh interval from 5s to 30s across all active log streams
curl -X PUT "https://serv.interex.ir:9200/logs-ecardo.*/_settings" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{
    "index.refresh_interval": "30s"
  }'

# Step 2: If backlog is critical (> 200,000 docs), temporarily drop replicas to 0 during recovery
curl -X PUT "https://serv.interex.ir:9200/logs-ecardo.*/_settings" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{
    "index.number_of_replicas": 0
  }'
```

### 2.4 Mitigation: Worker Scaling & Bulk Batch Tuning
Scale consumer workers horizontally and optimize batch boundaries:
1. **Scale Worker Processes:**
   ```bash
   # Scale telemetry consumer instances from 2 to 6
   docker-compose -f /opt/ecardo/telemetry/docker-compose.yml up -d --scale telemetry-worker=6
   ```
2. **Tune Batch Sizing in Worker Config:**
   - Increase bulk document count: `BULK_SIZE=2000` (up from 500).
   - Set bulk payload target: `BULK_BYTES=8MB` (max 10MB per HTTP request).
   - Flush timeout: `FLUSH_INTERVAL=2000ms`.

### 2.5 Restoration of Normal Settings
Once queue backlog drops below 1,000 events:
```bash
# Revert refresh interval to standard 5s
curl -X PUT "https://serv.interex.ir:9200/logs-ecardo.*/_settings" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{ "index.refresh_interval": "5s" }'

# Restore replica redundancy to 1
curl -X PUT "https://serv.interex.ir:9200/logs-ecardo.*/_settings" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{ "index.number_of_replicas": 1 }'
```

---

## 3. Playbook B: Disk High Watermark Breach & Flood Stage

### 3.1 Symptoms & Triggers
- **Alert:** `ElasticsearchDiskWatermarkHigh` (> 90%) or `ElasticsearchDiskFloodStage` (> 95%).
- **Error:** Backend workers log `cluster_block_exception [FORBIDDEN/12/index read-only / allow delete (api)]`.
- **Impact:** Cluster blocks all new document writes across all indices. Ingestion stops completely.

### 3.2 Triage & Root Cause Identification
```bash
# 1. Identify disk usage per node and available bytes
curl -s -X GET "https://serv.interex.ir:9200/_cat/allocation?v=true&h=node,shards,disk.percent,disk.used,disk.avail" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt

# 2. Identify top 10 largest individual indices
curl -s -X GET "https://serv.interex.ir:9200/_cat/indices?v=true&s=store.size:desc" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt | head -n 11

# 3. Check why ILM failed to delete old indices
curl -s -X GET "https://serv.interex.ir:9200/logs-ecardo.api-prod*/_ilm/explain" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt | jq -r '.indices[] | select(.step_info.type=="illegal_argument_exception" or .failed_step!=null)'
```

### 3.3 Emergency Step-by-Step Remediation

#### Step 1: Trigger Emergency Rollover
Force active hot streams to roll over immediately to prevent new writes from concentrating on the bloated shard:
```bash
curl -X POST "https://serv.interex.ir:9200/logs-ecardo.api-prod/_rollover" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt

curl -X POST "https://serv.interex.ir:9200/traces-ecardo.app-prod/_rollover" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt
```

#### Step 2: Emergency Retention Truncation (Data Purge)
Free disk space by deleting obsolete debug trace and metric data streams starting with the oldest:
```bash
# Purge trace indices older than 14 days
curl -X DELETE "https://serv.interex.ir:9200/.ds-traces-ecardo.app-prod-2026.09.*" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt

# Purge metric indices older than 30 days
curl -X DELETE "https://serv.interex.ir:9200/.ds-metrics-ecardo.app-prod-2026.08.*" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt
```

#### Step 3: Remove Flood-Stage Read-Only Lock
Once disk usage drops below 85%, remove the index read-only block:
```bash
curl -X PUT "https://serv.interex.ir:9200/*/_settings" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{
    "index.blocks.read_only_allow_delete": null
  }'
```

#### Step 4: Verify Allocation & Ingestion Resumption
```bash
# Check cluster health returns to green/yellow
curl -s -X GET "https://serv.interex.ir:9200/_cluster/health?pretty" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt
```

---

## 4. Playbook C: Accidental PII / Secret Ingestion (Security Incident)

### 4.1 Symptoms & Triggers
- **Incident Classification:** **SEV-1 (Security Incident)**.
- **Triggers:**
  - Automated redaction scan discovers unmasked PAN (card number), JWT token, user OTP, password, or national ID in logs.
  - Engineer or Support operator spots sensitive credentials in Kibana discovery panel.

```
+---------------------------------------------------------------------------------------+
|                               LEGAL & COMPLIANCE CLOCK                                |
+---------------------------------------------------------------------------------------+
| Ingestion of unredacted cardholder data (PCI-DSS) or user authentication tokens      |
| requires immediate containment within 15 minutes and complete eradication within 4    |
| hours. SecOps Officer must be notified within 30 minutes of discovery.                |
+---------------------------------------------------------------------------------------+
```

### 4.2 Step-by-Step Eradication Protocol

```
+-----------------------------------------------------------------------------------------+
| [Phase 1: Containment (<15m)]  --> Temporary query filter / Kibana field masking        |
| [Phase 2: Hotfix Ingest (<30m)] --> Update Ingest Pipeline Grok/Gsub redaction rules    |
| [Phase 3: Targeted Delete]    --> Delete tainted documents via _delete_by_query         |
| [Phase 4: Expunge Deletes]    --> Force merge with only_expunge_deletes=true            |
| [Phase 5: Post-Mortem]        --> Add pattern to negative test suite & notify SecOps   |
+-----------------------------------------------------------------------------------------+
```

#### Phase 1: Immediate Ingest Pipeline Hotfix (< 15 Minutes)
Prevent any further ingestion of the leaking pattern by applying an emergency regex gsub processor to the ingest pipeline:

```bash
curl -X PUT "https://serv.interex.ir:9200/_ingest/pipeline/ecardo_emergency_redaction_pipeline" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{
  "description": "Emergency PII/Credential Redaction Pipeline",
  "processors": [
    {
      "gsub": {
        "field": "message",
        "pattern": "(bearer\\s+[A-Za-z0-9-_=]+\\.[A-Za-z0-9-_=]+\\.[A-Za-z0-9-_.+/=]+)",
        "replacement": "bearer <redacted_jwt>",
        "ignore_missing": true
      }
    },
    {
      "gsub": {
        "field": "message",
        "pattern": "(\\b(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|603799[0-9]{10})\\b)",
        "replacement": "<redacted_pan>",
        "ignore_missing": true
      }
    },
    {
      "gsub": {
        "field": "message",
        "pattern": "(otp[\"'\':\\s=]+)[0-9]{5,6}",
        "replacement": "$1<redacted_otp>",
        "ignore_missing": true
      }
    }
  ]
}'
```

Link the emergency pipeline to the active index template:
```bash
curl -X PUT "https://serv.interex.ir:9200/_index_template/ecardo_logs_template" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{
  "index_patterns": ["logs-ecardo.*"],
  "data_stream": {},
  "priority": 600,
  "template": {
    "settings": {
      "index.default_pipeline": "ecardo_emergency_redaction_pipeline"
    }
  }
}'
```

#### Phase 2: Targeted Deletion via `_delete_by_query`
Execute a background deletion task targeting only the contaminated documents:

```bash
# Execute asynchronous delete-by-query matching leaked pattern
TASK_ID=$(curl -s -X POST "https://serv.interex.ir:9200/logs-ecardo.api-prod/_delete_by_query?wait_for_completion=false&slices=5" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{
  "query": {
    "bool": {
      "should": [
        { "regexp": { "message": ".*(bearer\\s+ey[A-Za-z0-9_-]+).*" } },
        { "regexp": { "message": ".*(603799[0-9]{10}|502229[0-9]{10}).*" } }
      ],
      "minimum_should_match": 1
    }
  }
}' | jq -r '.task')

echo "Delete by query started with Task ID: ${TASK_ID}"
```

Monitor completion of the deletion task:
```bash
curl -s -X GET "https://serv.interex.ir:9200/_tasks/${TASK_ID}" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt | jq '{completed: .completed, deleted: .task.status.deleted}'
```

#### Phase 3: Segment Expungement (Physical Purge from Disk)
In Lucene, `_delete_by_query` marks documents as deleted in segment tombstones, but the raw text remains in segment files until merged. SRE must force segment expungement:

```bash
curl -X POST "https://serv.interex.ir:9200/logs-ecardo.api-prod/_forcemerge?only_expunge_deletes=true&max_num_segments=1" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt
```

#### Phase 4: Clean Re-indexing (If Total Reconstruction Required)
If deletion created critical gap in non-sensitive operational metadata, reindex from tainted stream into clean target with transformation:

```bash
curl -X POST "https://serv.interex.ir:9200/_reindex" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{
  "source": {
    "index": ".ds-logs-ecardo.api-prod-2026.10.15-000001"
  },
  "dest": {
    "index": "reindexed-logs-ecardo.api-prod-clean",
    "pipeline": "ecardo_emergency_redaction_pipeline"
  }
}'
```

#### Phase 5: Verification & Post-Incident Action
1. **Assert Zero Residual Matches:**
   ```bash
   curl -s -X GET "https://serv.interex.ir:9200/logs-ecardo.api-prod/_search" \
     -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
     -H "Content-Type: application/json" \
     --cacert /etc/elasticsearch/certs/ca.crt \
     -d '{
     "query": {
       "regexp": { "message": ".*(603799[0-9]{10}|502229[0-9]{10}).*" }
     }
   }' | jq '.hits.total.value'
   # Must return 0 hits
   ```
2. **Snapshot Invalidation:** If an off-cluster snapshot occurred during the leak window, identify and delete the snapshot via SLM to avoid storing unencrypted cardholder/PII data.
3. **Automated Test Matrix Update:** The incident pattern must be codified as an automated test case in `docs/testing/TELEMETRY-SECURITY-TESTS.md` before resolving the incident ticket.
