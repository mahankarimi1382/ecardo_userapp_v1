# eCardo Telemetry Infrastructure — Elasticsearch SRE Runbook

**Document Version:** 1.0.0  
**Effective Date:** 2026-10-15  
**Tasks Reference:** EL-018 (Alerting & Runbooks), EL-022 (Team Training & Disaster Recovery)  
**Applicability:** Production & Staging Telemetry Clusters (`serv.interex.ir` / Server Infrastructure)  
**Classification:** Internal Confidential / SRE Operational Standard  

---

## 1. Scope, Ownership & Architecture Invariants

### 1.1 Purpose
This runbook provides Site Reliability Engineers (SRE), Platform Engineers, and On-Call Responders with standardized operating procedures, health alert thresholds, escalation matrices, and automated remediation routines for the eCardo telemetry search cluster (Elasticsearch 8.x).

### 1.2 Core Architectural Invariant
```
+---------------------------------------------------------------------------------------+
|                               CRITICAL FINTECH INVARIANT                              |
+---------------------------------------------------------------------------------------+
| 1. Elasticsearch is EXCLUSIVELY an operational search, logging, and metrics store.   |
| 2. Elasticsearch is NEVER the source of truth for account balances, transaction       |
|    ledgers, exchange rates, wallet limits, KYC statuses, or payment finality.         |
| 3. A complete outage or degradation of Elasticsearch MUST NOT abort, delay, or block  |
|    any user transaction or backend financial ledger commit.                           |
| 4. Client apps (Flutter Web/Android/iOS) NEVER connect directly to Elasticsearch.    |
+---------------------------------------------------------------------------------------+
```

### 1.3 Cluster Topology & Ownership
| Role | Primary Owner | Escalation / Secondary | On-Call Pager |
| :--- | :--- | :--- | :--- |
| **Telemetry Cluster Admin** | Platform / SRE Lead | Infrastructure On-Call | PagerDuty: `sre-telemetry-p0` |
| **Ingestion Pipeline** | Backend Core Team | Data Platform On-Call | PagerDuty: `backend-ingest-p1` |
| **Security & Redaction** | Security Operations (SecOps) | Compliance Officer | PagerDuty: `secops-critical` |

---

## 2. Index Lifecycle Management (ILM) Policies

All operational logs, traces, and application metrics flow into versioned Elasticsearch Data Streams (`logs-ecardo.*`, `metrics-ecardo.*`, `traces-ecardo.*`). The cluster enforces a four-phase Index Lifecycle Management (ILM) policy designed to control memory overhead, optimize search performance, and enforce data retention SLAs.

### 2.1 ILM Phase Specifications

```
  +---------------+       +---------------+       +---------------+       +---------------+
  |   HOT PHASE   | ----> |  WARM PHASE   | ----> |  COLD PHASE   | ----> | DELETE PHASE  |
  +---------------+       +---------------+       +---------------+       +---------------+
  | Write & Search|       | Read-Only     |       | Searchable    |       | Complete      |
  | Rollover:     |       | Age: 14 days  |       | Snapshots     |       | Purge from    |
  |  25 GB or 7 d |       | ForceMerge: 1 |       | Age: 30 days  |       | Cluster       |
  | Priority: 100 |       | Priority: 50  |       | Priority: 20  |       | Age: Ret. SLA |
  +---------------+       +---------------+       +---------------+       +---------------+
```

1. **Hot Phase (Active Ingestion & Real-Time Querying):**
   - **Characteristics:** Shards accept live writes from OpenTelemetry Collectors and backend workers. High NVMe I/O priority.
   - **Rollover Triggers:** Index primary shard size reaches **25 GB** OR elapsed time reaches **7 days**, whichever occurs first (`max_primary_shard_size: "25gb"`, `max_age: "7d"`). Max docs threshold: 50,000,000.
   - **Index Priority:** 100.
   - **Replicas:** 1 (in production) to guarantee High Availability (HA) against single-node hardware failure.

2. **Warm Phase (Operational Querying & Segment Optimization):**
   - **Trigger:** Shards transition into Warm phase **14 days** after rollover (`min_age: "14d"`).
   - **Actions:**
     - Mark index as read-only (`index.blocks.write: true`).
     - Execute `forcemerge` down to **1 segment** (`max_num_segments: 1`) to reclaim deleted Lucene document space and drastically reduce segment memory overhead.
     - Lower index priority to 50.
     - Move index allocation to warm data nodes (`data_warm` tier) if tiered storage is configured.

3. **Cold Phase (Long-Tail Retention & Searchable Snapshots):**
   - **Trigger:** Shards transition into Cold phase **30 days** after rollover (`min_age: "30d"`).
   - **Actions:**
     - Migrate index to cold tier (`data_cold`) or mount as searchable snapshots backed by S3-compatible object storage.
     - Reduce replicas to 0 if searchable snapshots are enabled (storage engine mounts blocks on-demand from object storage).
     - Lower index priority to 20.

4. **Delete Phase (Compliance Purge):**
   - **Trigger:** Hard retention expiration based on data classification:
     - Operational API Logs (`logs-ecardo.api-prod`): **90 days** from rollover.
     - Technical Debug Traces (`traces-ecardo.app-prod`): **30 days** from rollover.
     - Security Audit Logs (`logs-ecardo.security-prod`): **180 days** from rollover (or legal SLA).
     - High-Volume Performance Metrics (`metrics-ecardo.app-prod`): **60 days** from rollover.
   - **Actions:** Complete irreversible removal of indices and underlying segment files from cluster storage.

### 2.2 Executable ILM Policy Definition
Run the following API call via Kibana Dev Tools or `curl` to apply the baseline ILM policy:

```bash
curl -X PUT "https://serv.interex.ir:9200/_ilm/policy/ecardo_telemetry_ilm_policy" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{
  "policy": {
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "set_priority": {
            "priority": 100
          },
          "rollover": {
            "max_primary_shard_size": "25gb",
            "max_age": "7d",
            "max_docs": 50000000
          }
        }
      },
      "warm": {
        "min_age": "14d",
        "actions": {
          "set_priority": {
            "priority": 50
          },
          "readonly": {},
          "forcemerge": {
            "max_num_segments": 1
          },
          "allocate": {
            "number_of_replicas": 1
          }
        }
      },
      "cold": {
        "min_age": "30d",
        "actions": {
          "set_priority": {
            "priority": 20
          },
          "allocate": {
            "number_of_replicas": 0
          }
        }
      },
      "delete": {
        "min_age": "90d",
        "actions": {
          "delete": {
            "delete_searchable_snapshot": true
          }
        }
      }
    }
  }
}'
```

### 2.3 Index Template Attaching the ILM Policy
All telemetry streams use composable index templates that enforce data stream creation, mapping strictness, and ILM assignment:

```bash
curl -X PUT "https://serv.interex.ir:9200/_index_template/ecardo_logs_template" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{
  "index_patterns": ["logs-ecardo.*"],
  "data_stream": {},
  "priority": 500,
  "template": {
    "settings": {
      "index.lifecycle.name": "ecardo_telemetry_ilm_policy",
      "index.number_of_shards": 1,
      "index.number_of_replicas": 1,
      "index.refresh_interval": "5s",
      "index.mapping.total_fields.limit": 1000,
      "index.codec": "best_compression"
    },
    "mappings": {
      "dynamic": "strict",
      "properties": {
        "@timestamp": { "type": "date" },
        "service": {
          "properties": {
            "name": { "type": "keyword" },
            "version": { "type": "keyword" },
            "environment": { "type": "keyword" }
          }
        },
        "event": {
          "properties": {
            "id": { "type": "keyword" },
            "schema_version": { "type": "keyword" },
            "category": { "type": "keyword" },
            "action": { "type": "keyword" },
            "outcome": { "type": "keyword" }
          }
        },
        "trace": {
          "properties": {
            "id": { "type": "keyword" }
          }
        },
        "transaction": {
          "properties": {
            "id": { "type": "keyword" }
          }
        },
        "http": {
          "properties": {
            "request": {
              "properties": {
                "method": { "type": "keyword" }
              }
            },
            "response": {
              "properties": {
                "status_code": { "type": "short" }
              }
            }
          }
        },
        "log": {
          "properties": {
            "level": { "type": "keyword" },
            "logger": { "type": "keyword" }
          }
        },
        "message": { "type": "text" }
      }
    }
  }
}'
```

---

## 3. Shard Sizing & Allocation Strategy

Improper shard sizing is the primary contributor to JVM heap exhaustion, cluster instability, and search latency degradation.

### 3.1 Shard Sizing Rules
1. **Target Shard Size:** All primary shards for time-series logs and metrics must be targeted between **20 GB and 40 GB** before rollover.
2. **Prevent Over-Sharding on Low-Volume Streams:**
   - Small streams (e.g., `logs-ecardo.security-prod`, `metrics-ecardo.app-prod`) generate < 2 GB per day.
   - Rule: Configure exactly **1 primary shard** (`"number_of_shards": 1`). Do NOT split low-volume streams into multi-shard patterns.
3. **Cluster Shard Count Capacity Limit:**
   - Invariant: Maximum allowable open shards per node is **20 shards per GB of configured JVM heap**.
   - Example: A node with 16 GB heap must NOT host more than `16 * 20 = 320` total shards (primary + replica).
   - Exceeding this threshold forces cluster state update delays, leading to master node disconnects.

### 3.2 Inspecting Shard Sizing & Distribution
Run the following inspection commands during routine shifts:

```bash
# Check top 15 largest shards by disk store size
curl -s -X GET "https://serv.interex.ir:9200/_cat/shards?v=true&s=store:desc" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt | head -n 16

# Check shard count per node against memory threshold
curl -s -X GET "https://serv.interex.ir:9200/_cat/allocation?v=true&h=node,shards,disk.percent,disk.used,disk.avail" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt
```

---

## 4. SRE Health Alert Thresholds & Monitoring Matrix

The following table establishes explicit alerting rules. Metrics must be scraped by Prometheus / OpenTelemetry Collector and evaluated via Alertmanager.

| Alert Name | Metric / Condition | Evaluation Window | Severity | Action & Escalation |
| :--- | :--- | :--- | :--- | :--- |
| **ClusterStatusRed** | `elasticsearch_cluster_health_status{color="red"} == 1` | Immediate (0s) | **SEV-1 (P0 Pager)** | Primary shard unassigned. Data loss risk. Page on-call immediately. |
| **ClusterStatusYellow** | `elasticsearch_cluster_health_status{color="yellow"} == 1` | 5 minutes | **SEV-2 (P1 Ticket)** | Replica shards unassigned. Loss of HA. Verify disk/node allocation. |
| **JVMHeapCritical** | `elasticsearch_jvm_memory_used_bytes{area="heap"} / elasticsearch_jvm_memory_max_bytes{area="heap"} > 0.85` | 3 minutes | **SEV-1 (P0 Pager)** | Heap > 85%. Stop heavy aggregations, scale ingest workers down. |
| **JVMHeapWarning** | `elasticsearch_jvm_memory_used_bytes{area="heap"} / elasticsearch_jvm_memory_max_bytes{area="heap"} > 0.75` | 10 minutes | **SEV-3 (P2 Ticket)** | Heap > 75%. Investigate fielddata cache and segment count. |
| **DiskLowWatermark** | `elasticsearch_filesystem_data_used_percent > 85` | 5 minutes | **SEV-2 (P1 Ticket)** | Shard allocation halted on node. Execute rollover or cleanup. |
| **DiskHighWatermark** | `elasticsearch_filesystem_data_used_percent > 90` | 2 minutes | **SEV-1 (P0 Pager)** | Shard relocation initiated. Emergency retention truncation required. |
| **DiskFloodStage** | `elasticsearch_filesystem_data_used_percent > 95` | Immediate | **SEV-1 (P0 Pager)** | Read-only block activated. Ingest halted. Run emergency disk runbook. |
| **BulkIndexingRejections** | `rate(elasticsearch_thread_pool_rejected_count{name="write"}[1m]) > 0` | 1 minute | **SEV-1 (P0 Pager)** | Write thread pool exhausted. Backpressure propagating to workers. |

### 4.1 Prometheus Alertmanager Rules (`elasticsearch_alerts.yml`)
```yaml
groups:
  - name: elasticsearch_telemetry_alerts
    rules:
      - alert: ElasticsearchClusterRed
        expr: elasticsearch_cluster_health_status{color="red"} == 1
        for: 0m
        labels:
          severity: critical
          tier: telemetry
        annotations:
          summary: "Elasticsearch Cluster RED: Unassigned primary shards"
          description: "Cluster has unassigned primary shards on {{ $labels.instance }}. Immediate data ingestion failure."
          runbook_url: "docs/operations/ELASTICSEARCH-RUNBOOK.md#51-procedure-for-cluster-red"

      - alert: ElasticsearchJVMHeapCritical
        expr: (elasticsearch_jvm_memory_used_bytes{area="heap"} / elasticsearch_jvm_memory_max_bytes{area="heap"}) > 0.85
        for: 3m
        labels:
          severity: critical
          tier: telemetry
        annotations:
          summary: "Elasticsearch JVM Heap > 85% on {{ $labels.node }}"
          description: "Node {{ $labels.node }} heap usage is critical ({{ $value | humanizePercentage }}). Risk of OOM freeze."
          runbook_url: "docs/operations/ELASTICSEARCH-RUNBOOK.md#52-procedure-for-jvm-heap-exhaustion"

      - alert: ElasticsearchDiskWatermarkHigh
        expr: elasticsearch_filesystem_data_used_percent > 85
        for: 5m
        labels:
          severity: warning
          tier: telemetry
        annotations:
          summary: "Elasticsearch Disk usage > 85% on {{ $labels.node }}"
          description: "Node {{ $labels.node }} reached 85% disk watermark. Shard allocation disabled."
          runbook_url: "docs/operations/ELASTICSEARCH-RUNBOOK.md#53-procedure-for-disk-watermark-breach"

      - alert: ElasticsearchWriteRejected
        expr: rate(elasticsearch_thread_pool_rejected_count{name="write"}[1m]) > 0
        for: 1m
        labels:
          severity: critical
          tier: telemetry
        annotations:
          summary: "Elasticsearch Bulk Indexing Write Rejections"
          description: "Write thread pool is saturated; {{ $value }} rejected tasks/sec on {{ $labels.node }}."
          runbook_url: "docs/operations/ELASTICSEARCH-RUNBOOK.md#54-procedure-for-bulk-rejected-threads"
```

---

## 5. Runbook Escalation Procedures & Standard Operating Procedures (SOPs)

### 5.1 Procedure for Cluster Status RED
1. **Assess Impact:** Determine which index and shard numbers are unassigned:
   ```bash
   curl -s -X GET "https://serv.interex.ir:9200/_cat/shards?v=true&h=index,shard,prirep,state,unassigned.reason" \
     -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt | grep UNASSIGNED
   ```
2. **Diagnose Unassigned Reason:**
   ```bash
   curl -s -X GET "https://serv.interex.ir:9200/_cluster/allocation/explain?pretty" \
     -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt
   ```
3. **Remediation Actions:**
   - **Case A: Node rejoined but shards did not auto-recover:**
     ```bash
     # Trigger cluster reroute retry
     curl -X POST "https://serv.interex.ir:9200/_cluster/reroute?retry_failed=true" \
       -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt
     ```
   - **Case B: Corrupt disk or missing node storage:**
     If primary shard data is permanently lost on disk, check if a replica exists or restore the damaged index from the latest off-cluster snapshot (refer to `docs/operations/SNAPSHOT-RESTORE-DRILL.md`).

### 5.2 Procedure for JVM Heap Exhaustion (> 85%)
1. **Identify Node and Running Tasks:**
   ```bash
   # List long-running or resource-intensive tasks
   curl -s -X GET "https://serv.interex.ir:9200/_tasks?detailed=true&actions=*search*,*reindex*,*forcemerge*" \
     -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt
   ```
2. **Cancel Runaway Queries:**
   ```bash
   # Cancel specific query task ID
   curl -X POST "https://serv.interex.ir:9200/_tasks/<TASK_ID>/_cancel" \
     -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt
   ```
3. **Clear Fielddata & Cache:**
   ```bash
   curl -X POST "https://serv.interex.ir:9200/_cache/clear?fielddata=true&query=true&request=true" \
     -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt
   ```
4. **Temporary Ingestion Throttle:**
   If heap remains > 85%, throttle backend OpenTelemetry batch size or temporarily pause non-critical debug streams (`traces-ecardo.*`) to allow JVM Garbage Collection to complete.

### 5.3 Procedure for Disk Watermark Breach (> 85% / > 90% / > 95%)
1. **Identify Bloated Indices:**
   ```bash
   curl -s -X GET "https://serv.interex.ir:9200/_cat/indices?v=true&s=store.size:desc" \
     -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt | head -n 20
   ```
2. **Force Emergency Rollover on Active Streams:**
   ```bash
   curl -X POST "https://serv.interex.ir:9200/logs-ecardo.api-prod/_rollover" \
     -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt
   ```
3. **Emergency Truncation of Expired Indices:**
   Identify non-critical trace indices older than 14 days and execute deletion:
   ```bash
   # Delete obsolete historical debug index
   curl -X DELETE "https://serv.interex.ir:9200/.ds-traces-ecardo.app-prod-2026.09.*" \
     -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt
   ```
4. **Unblock Flood-Stage Read-Only Lock:**
   Once disk usage drops below 85%, remove the index write block:
   ```bash
   curl -X PUT "https://serv.interex.ir:9200/*/_settings" \
     -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
     -H "Content-Type: application/json" \
     --cacert /etc/elasticsearch/certs/ca.crt \
     -d '{
       "index.blocks.read_only_allow_delete": null
     }'
   ```

### 5.4 Procedure for Bulk Rejected Threads (`write.rejected > 0`)
1. **Check Thread Pool Saturation:**
   ```bash
   curl -s -X GET "https://serv.interex.ir:9200/_cat/thread_pool/write?v=true&h=host,name,active,queue,rejected,completed" \
     -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" --cacert /etc/elasticsearch/certs/ca.crt
   ```
2. **Relax Index Refresh Interval (Fast Mitigation):**
   Temporarily increase refresh interval from 5s to 30s across all active logs to reduce Lucene merge overhead:
   ```bash
   curl -X PUT "https://serv.interex.ir:9200/logs-ecardo.*/_settings" \
     -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
     -H "Content-Type: application/json" \
     --cacert /etc/elasticsearch/certs/ca.crt \
     -d '{
       "index.refresh_interval": "30s"
     }'
   ```
3. **Drop Replica Temporarily (Emergency Catch-up):**
   ```bash
   curl -X PUT "https://serv.interex.ir:9200/logs-ecardo.*/_settings" \
     -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
     -H "Content-Type: application/json" \
     --cacert /etc/elasticsearch/certs/ca.crt \
     -d '{
       "number_of_replicas": 0
     }'
   ```
   *Note: Revert replica count to 1 as soon as the queue backlog clears.*

---

## 6. Escalation Protocol & Incident Sign-Off

```
[Level 1: Telemetry Support / SRE On-Call]
   |  Trigger: Alert firing > 5m or Unacknowledged SEV-2
   v
[Level 2: Platform Lead / Senior SRE]
   |  Trigger: SEV-1 (Cluster RED, Disk Flood Stage, Data Leak) > 15m unresolved
   v
[Level 3: Core Architect / SecOps Officer]
   |  Trigger: Complete telemetry partition or security incident
```

1. **Incident Post-Mortem Requirement:** Any SEV-1 incident requires a blameless post-mortem document completed within 48 hours of resolution.
2. **Verification Evidence:** Before resolving any pager ticket, the engineer must paste the output of `GET _cluster/health` showing `status: green` and zero unassigned shards into the incident ticket.
