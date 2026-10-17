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

All operational logs, traces, and application metrics flow into versioned Elasticsearch Data Streams (`logs-ecardo.*`, `metrics-ecardo.*`, `traces-ecardo.*`). In strict compliance with governance directive **EL-GOV-01**, all index retention and lifecycle transitions are 100% reconciled with the canonical matrix defined in `docs/architecture/DATA-CLASSIFICATION.md`.

### 2.1 Canonical Retention Matrix (EL-GOV-01)

| Data Stream Pattern | Classification / Scope | Retention Period | Storage Lifecycle Phases | Action upon Expiry |
| :--- | :--- | :--- | :--- | :--- |
| **`logs-ecardo.api-prod`** | API Operational Logs | **90 Days** | **Hot:** Days 1–7 (7d duration, rollover at 50GB or 7d, priority 100)<br>**Warm:** Days 8–30 (23d duration, min_age 7d, force merge to 1 segment, priority 50)<br>**Cold:** Days 31–90 (60d duration, min_age 30d, searchable snapshots, priority 20) | **Hard Delete** at Day 91 |
| **`logs-ecardo.security-prod`** | Security & Audit Logs | **180 Days** | **Hot:** Days 1–14 (14d duration, rollover at 50GB or 14d, priority 100)<br>**Warm:** Days 15–60 (46d duration, min_age 14d, force merge to 1 segment, priority 50)<br>**Cold:** Days 61–180 (120d duration, min_age 60d, searchable snapshots, priority 20) | **Hard Delete** at Day 181 |
| **`logs-ecardo.mobile-prod`** | Client Performance Telemetry | **30 Days** | **Hot:** Days 1–7 (7d duration, rollover at 25GB or 7d, priority 100)<br>**Warm:** Days 8–30 (23d duration, min_age 7d, force merge to 1 segment, priority 50)<br>**Cold:** Skipped | **Hard Delete** at Day 31 |
| **`traces-ecardo.app-prod`** / **`traces-ecardo-prod`** | Raw Traces / APM Spans | **14 Days** | **Hot:** Days 1–3 (3d duration, rollover at 25GB or 3d, priority 100)<br>**Warm:** Days 4–14 (11d duration, min_age 3d, force merge to 1 segment, priority 50)<br>**Cold:** Skipped | **Hard Delete** at Day 15 |

```
  +---------------+       +---------------+       +---------------+       +---------------+
  |   HOT PHASE   | ----> |  WARM PHASE   | ----> |  COLD PHASE   | ----> | DELETE PHASE  |
  +---------------+       +---------------+       +---------------+       +---------------+
  | Write & Search|       | Read-Only     |       | Searchable    |       | Irreversible  |
  | API/Mob: 7d   |       | API/Mob: 23d  |       | Snapshots     |       | Purge from    |
  | Sec: 14d      |       | Sec: 46d      |       | API: 60d      |       | Cluster       |
  | Trace: 3d     |       | Trace: 11d    |       | Sec: 120d     |       | Exact Matrix  |
  | Priority: 100 |       | ForceMerge: 1 |       | Priority: 20  |       | SLA Retention |
  +---------------+       +---------------+       +---------------+       +---------------+
```

1. **Hot Phase (Active Ingestion & Real-Time Querying):**
   - **Characteristics:** Shards accept live writes from OpenTelemetry Collectors and backend workers. High NVMe I/O priority.
   - **Rollover Triggers:** 
     - API Logs (`logs-ecardo.api-prod`): `max_primary_shard_size: "50gb"`, `max_age: "7d"`.
     - Security Logs (`logs-ecardo.security-prod`): `max_primary_shard_size: "50gb"`, `max_age: "14d"`.
     - Client Telemetry (`logs-ecardo.mobile-prod`): `max_primary_shard_size: "25gb"`, `max_age: "7d"`.
     - Raw Traces (`traces-ecardo.app-prod`): `max_primary_shard_size: "25gb"`, `max_age: "3d"`.
   - **Index Priority:** 100.
   - **Replicas:** 1 (in production) to guarantee High Availability (HA) against single-node hardware failure.

2. **Warm Phase (Operational Querying & Segment Optimization):**
   - **Trigger:** Shards transition into Warm phase after hot duration:
     - API Logs & Client Telemetry: **7 days** after index creation (`min_age: "7d"`), warm duration **23 days**.
     - Security Logs: **14 days** after index creation (`min_age: "14d"`), warm duration **46 days**.
     - Raw Traces: **3 days** after index creation (`min_age: "3d"`), warm duration **11 days**.
   - **Actions:**
     - Mark index as read-only (`index.blocks.write: true`).
     - Execute `forcemerge` down to **1 segment** (`max_num_segments: 1`) to reclaim deleted Lucene document space and drastically reduce segment memory overhead.
     - Lower index priority to 50.
     - Move index allocation to warm data nodes (`data_warm` tier) if tiered storage is configured.

3. **Cold Phase (Long-Tail Retention & Searchable Snapshots):**
   - **Trigger:** Shards transition into Cold phase:
     - API Logs: **30 days** after index creation (`min_age: "30d"`), cold duration **60 days**.
     - Security Logs: **60 days** after index creation (`min_age: "60d"`), cold duration **120 days**.
     - Client Telemetry & Raw Traces: Skipped (no cold tier; hard delete directly following warm phase).
   - **Actions:**
     - Migrate index to cold tier (`data_cold`) or mount as searchable snapshots backed by S3-compatible object storage.
     - Reduce replicas to 0 if searchable snapshots are enabled (storage engine mounts blocks on-demand from object storage).
     - Lower index priority to 20.

4. **Delete Phase (Compliance Purge):**
   - **Trigger:** Hard retention expiration strictly governed by EL-GOV-01:
     - API Operational Logs (`logs-ecardo.api-prod`): **90 days** (`min_age: "90d"`). Hard delete at Day 91.
     - Security & Audit Logs (`logs-ecardo.security-prod`): **180 days** (`min_age: "180d"`). Hard delete at Day 181.
     - Client Performance Telemetry (`logs-ecardo.mobile-prod`): **30 days** (`min_age: "30d"`). Hard delete at Day 31.
     - Raw Traces / APM Spans (`traces-ecardo.app-prod` / `traces-ecardo-prod`): **14 days** (`min_age: "14d"`). Hard delete at Day 15.
   - **Actions:** Complete irreversible removal of indices and underlying segment files from cluster storage.

### 2.2 Executable ILM Policy Definitions
Run the following API calls via Kibana Dev Tools or `curl` to apply the canonical ILM policies:

#### 1. API Operational Logs Policy (90 Days Retention)
```bash
curl -X PUT "https://serv.interex.ir:9200/_ilm/policy/ecardo_api_ilm_policy" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{
  "policy": {
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "set_priority": { "priority": 100 },
          "rollover": {
            "max_primary_shard_size": "50gb",
            "max_age": "7d"
          }
        }
      },
      "warm": {
        "min_age": "7d",
        "actions": {
          "set_priority": { "priority": 50 },
          "readonly": {},
          "forcemerge": { "max_num_segments": 1 },
          "allocate": { "number_of_replicas": 1 }
        }
      },
      "cold": {
        "min_age": "30d",
        "actions": {
          "set_priority": { "priority": 20 },
          "allocate": { "number_of_replicas": 0 }
        }
      },
      "delete": {
        "min_age": "90d",
        "actions": {
          "delete": { "delete_searchable_snapshot": true }
        }
      }
    }
  }
}'
```

#### 2. Security & Audit Logs Policy (180 Days Retention)
```bash
curl -X PUT "https://serv.interex.ir:9200/_ilm/policy/ecardo_security_ilm_policy" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{
  "policy": {
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "set_priority": { "priority": 100 },
          "rollover": {
            "max_primary_shard_size": "50gb",
            "max_age": "14d"
          }
        }
      },
      "warm": {
        "min_age": "14d",
        "actions": {
          "set_priority": { "priority": 50 },
          "readonly": {},
          "forcemerge": { "max_num_segments": 1 },
          "allocate": { "number_of_replicas": 1 }
        }
      },
      "cold": {
        "min_age": "60d",
        "actions": {
          "set_priority": { "priority": 20 },
          "allocate": { "number_of_replicas": 0 }
        }
      },
      "delete": {
        "min_age": "180d",
        "actions": {
          "delete": { "delete_searchable_snapshot": true }
        }
      }
    }
  }
}'
```

#### 3. Client Performance Telemetry Policy (30 Days Retention)
```bash
curl -X PUT "https://serv.interex.ir:9200/_ilm/policy/ecardo_mobile_ilm_policy" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{
  "policy": {
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "set_priority": { "priority": 100 },
          "rollover": {
            "max_primary_shard_size": "25gb",
            "max_age": "7d"
          }
        }
      },
      "warm": {
        "min_age": "7d",
        "actions": {
          "set_priority": { "priority": 50 },
          "readonly": {},
          "forcemerge": { "max_num_segments": 1 },
          "allocate": { "number_of_replicas": 1 }
        }
      },
      "delete": {
        "min_age": "30d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}'
```

#### 4. Raw Traces / APM Spans Policy (14 Days Retention)
```bash
curl -X PUT "https://serv.interex.ir:9200/_ilm/policy/ecardo_traces_ilm_policy" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{
  "policy": {
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "set_priority": { "priority": 100 },
          "rollover": {
            "max_primary_shard_size": "25gb",
            "max_age": "3d"
          }
        }
      },
      "warm": {
        "min_age": "3d",
        "actions": {
          "set_priority": { "priority": 50 },
          "readonly": {},
          "forcemerge": { "max_num_segments": 1 },
          "allocate": { "number_of_replicas": 1 }
        }
      },
      "delete": {
        "min_age": "14d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}'
```

### 2.3 Index Templates Attaching Canonical ILM Policies
All telemetry streams use composable index templates that enforce data stream creation, mapping strictness, and specific ILM policy assignment:

```bash
# 1. API Logs Template
curl -X PUT "https://serv.interex.ir:9200/_index_template/ecardo_api_logs_template" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{
  "index_patterns": ["logs-ecardo.api-*"],
  "data_stream": {},
  "priority": 500,
  "template": {
    "settings": {
      "index.lifecycle.name": "ecardo_api_ilm_policy",
      "index.number_of_shards": 1,
      "index.number_of_replicas": 1,
      "index.refresh_interval": "5s",
      "index.codec": "best_compression"
    }
  }
}'

# 2. Security Audit Logs Template
curl -X PUT "https://serv.interex.ir:9200/_index_template/ecardo_security_logs_template" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{
  "index_patterns": ["logs-ecardo.security-*"],
  "data_stream": {},
  "priority": 500,
  "template": {
    "settings": {
      "index.lifecycle.name": "ecardo_security_ilm_policy",
      "index.number_of_shards": 1,
      "index.number_of_replicas": 1,
      "index.refresh_interval": "5s",
      "index.codec": "best_compression"
    }
  }
}'

# 3. Client Performance Telemetry Template
curl -X PUT "https://serv.interex.ir:9200/_index_template/ecardo_mobile_logs_template" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{
  "index_patterns": ["logs-ecardo.mobile-*"],
  "data_stream": {},
  "priority": 500,
  "template": {
    "settings": {
      "index.lifecycle.name": "ecardo_mobile_ilm_policy",
      "index.number_of_shards": 1,
      "index.number_of_replicas": 1,
      "index.refresh_interval": "5s",
      "index.codec": "best_compression"
    }
  }
}'

# 4. Raw Traces Template
curl -X PUT "https://serv.interex.ir:9200/_index_template/ecardo_traces_template" \
  -u "${ES_ADMIN_USER}:${ES_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  --cacert /etc/elasticsearch/certs/ca.crt \
  -d '{
  "index_patterns": ["traces-ecardo.*"],
  "data_stream": {},
  "priority": 500,
  "template": {
    "settings": {
      "index.lifecycle.name": "ecardo_traces_ilm_policy",
      "index.number_of_shards": 1,
      "index.number_of_replicas": 1,
      "index.refresh_interval": "5s",
      "index.codec": "best_compression"
    }
  }
}'
```
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
