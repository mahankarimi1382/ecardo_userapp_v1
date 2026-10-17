# Observability Data Flow Architecture & Telemetry Pipeline

- **Document Version:** 1.0.0
- **Status:** APPROVED
- **Date:** 2026-10-15
- **Task Reference:** Section 23.3, 26, 27 (Tasks EL-008, EL-009, EL-010, EL-011, EL-017) of `ecardo_userapp_v1_audit_roadmap_fa_FIXED.md`
- **Applicable Services:** Flutter Mobile & Web Client (`ecardo_userapp_v1`), eCardo API Gateway, Outbox Workers, OpenTelemetry Collector, Elasticsearch Cluster

---

## 1. Executive Summary & Pipeline Objectives

This document specifies the end-to-end data flow for telemetry, distributed tracing, structured logs, and audit events within the eCardo ecosystem. 

The observability architecture is engineered around four core tenets:
1. **Zero Client Leakage:** The Flutter client application never communicates directly with internal storage clusters; all telemetry routes through an authenticated, rate-limited backend gateway.
2. **Transactional Integrity via Outbox:** Critical financial state transitions produce audit events inside primary database transactions, guaranteeing that audit telemetry is never lost or orphaned during crashes.
3. **Strict Bounded Resource Consumption:** Intelligent sampling captures 100% of anomalies while sampling high-volume benign traffic at 1%, eliminating unnecessary network and indexing overhead.
4. **Asynchronous Non-Blocking Resilience:** Multi-tiered circuit breakers and dropping rules ensure that telemetry backpressure never stalls mobile UI threads or backend financial commit paths.

---

## 2. End-to-End Pipeline Topology

The diagram below illustrates the complete lifecycle of telemetry signals from edge client devices and backend microservices into dedicated Elasticsearch Data Streams:

```
+-------------------------------------------------------------------------------------------------------+
|                                        EDGE & CLIENT LAYER                                            |
|                                                                                                       |
|  +-------------------------------------------------------------------------------------------------+  |
|  | Flutter Client Application (ecardo_userapp_v1)                                                  |  |
|  |   • UI Actions / Network Events / Exceptions                                                    |  |
|  |   • Client Ring Buffer (In-Memory, max 200 events)                                              |  |
|  |   • Local Offline Spool (SQLite/Hive, encrypted, max 1,000 events / 2 MB)                       |  |
|  |   • Background Flush Timer (Every 30s OR batch >= 20 events)                                    |  |
|  +-------------------------------------------------------------------------------------------------+  |
+-------------------------------------------------------------------------------------------------------+
                                                   |
                                                   | HTTPS / TLS 1.3 (Bearer Token / Installation ID)
                                                   | POST /api/telemetry/events (Max 64 KB, Rate Limited)
                                                   v
+-------------------------------------------------------------------------------------------------------+
|                                    INGESTION & GATEWAY LAYER                                          |
|                                                                                                       |
|  +-------------------------------------------------------------------------------------------------+  |
|  | eCardo API Gateway (Telemetry Ingestion Endpoint)                                               |  |
|  |   • Token-Bucket Rate Limiter (10 req/min/device, burst: 25)                                    |  |
|  |   • JSON Schema Envelope Validator (Strict ECS 1.0.0 compliance)                                |  |
|  |   • Edge PII Redaction Filter (Regex regexes for PAN, PIN, Passwords, Tokens)                   |  |
|  |   • Non-blocking OTLP Forwarder                                                                 |  |
|  +-------------------------------------------------------------------------------------------------+  |
+-------------------------------------------------------------------------------------------------------+
                |                                                                  |
                | OTLP / gRPC (Port 4317)                                          | Core Business Calls
                v                                                                  v
+-----------------------------------+             +-----------------------------------------------------+
|   OPENTELEMETRY COLLECTOR POOL    |             | BACKEND TRANSACTIONAL CORE (PHP / Laravel)          |
|                                   |             |                                                     |
| Receivers:                        |             | 1. Execute Financial Business Logic                 |
|   • otlp (gRPC :4317, HTTP :4318) |             | 2. DB Transaction Begin                             |
|   • filelog (API & Worker nodes)  |             |    • Update Ledger & Balances                       |
|                                   |             |    • INSERT INTO transactional_outbox (Event)       |
| Processors:                       |             | 3. DB Transaction Commit (ACID Guaranteed)          |
|   • memory_limiter (Hard cap 80%) |             +-----------------------------------------------------+
|   • batch (500 items / 1000ms)    |                                        |
|   • redaction (Regex scrub)       |                                        | Transactional Outbox Table
|   • tail_sampling (100% / 1%)     |                                        v
|                                   |             +-----------------------------------------------------+
| Exporters:                        |             | OUTBOX RELAY WORKER (Daemon / CDC Engine)           |
|   • elasticsearch (Bulk API)      |             |   • Polling: SELECT ... FOR UPDATE SKIP LOCKED       |
|   • debug / prometheus (Metrics)  |             |   • Acknowledged publish to Internal Message Queue  |
+-----------------------------------+             +-----------------------------------------------------+
                |                                                            |
                | Bulk Indexing Protocol                                     | Async Message Stream
                v                                                            v
+-------------------------------------------------------------------------------------------------------+
|                                   STORAGE & SEARCH LAYER (ELASTICSEARCH)                              |
|                                                                                                       |
|  +--------------------------------+   +-------------------------------+   +------------------------+  |
|  | logs-ecardo.mobile-prod        |   | logs-ecardo.api-prod          |   | logs-ecardo.security-  |  |
|  | (Client Diagnostics / 14-Day)  |   | (API Access & Error / 30-Day) |   | prod (Audit / 90-Day)  |  |
|  +--------------------------------+   +-------------------------------+   +------------------------+  |
|                                                                                                       |
|  +-------------------------------------------------------------------------------------------------+  |
|  | traces-ecardo-prod (OpenTelemetry Distributed APM Traces / 7-Day)                               |  |
|  +-------------------------------------------------------------------------------------------------+  |
+-------------------------------------------------------------------------------------------------------+
                                                   |
                                                   v
+-------------------------------------------------------------------------------------------------------+
|                                  OPERATIONS & VISUALIZATION LAYER                                     |
|                                                                                                       |
|  +--------------------------------+   +-------------------------------+   +------------------------+  |
|  | Kibana SRE Dashboards          |   | Authorized Support Portal     |   | Alertmanager / Pager   |  |
|  | (p50/p95/p99 Latency, Errors)  |   | (Correlation ID Lookup)       |   | (Slack, SMS, OpsGenie) |  |
|  +--------------------------------+   +-------------------------------+   +------------------------+  |
+-------------------------------------------------------------------------------------------------------+
```

---

## 3. Client-Side Telemetry Subsystem (Flutter)

The Flutter mobile application (`ecardo_userapp_v1`) runs on constrained client environments (Android, iOS, Web). The client telemetry architecture guarantees zero UI jank and strict local containment.

### 3.1 Local Buffer and Persistence Architecture
1. **In-Memory Ring Buffer:** High-speed, lock-free circular buffer residing in application memory. Capacity: 200 events. If the application is active and network is healthy, events drain directly from memory.
2. **Encrypted Disk Spool (Offline Fallback):** If the device loses internet connectivity or the telemetry API returns backpressure:
   - Events spill over to a localized SQLite / Hive spool stored in the app sandbox.
   - **Storage Cap:** Hard limit of 2.0 Megabytes or 1,000 serialized events.
   - **FIFO Eviction:** When the 2.0 MB disk cap is breached, the oldest events are discarded first, preserving recent error breadcrumbs.
3. **Background Isolate Processing:** Telemetry serialization (JSON encoding) and disk writing run inside a dedicated background worker isolate (`compute` / `Isolate.spawn`) to ensure the Flutter UI raster thread never drops below 60/120 FPS.

### 3.2 Dispatch Triggers and Batching Policy
Events are transmitted to the backend gateway under two deterministic conditions:
- **Batch Size Watermark:** Buffered events reach 20 items.
- **Temporal Flush Timer:** A recurring 30-second periodic timer triggers a flush if any events are pending.
- **App Lifecycle Transition:** When the app transitions from `AppLifecycleState.resumed` to `AppLifecycleState.paused` or `detached`, an immediate asynchronous flush is executed.

---

## 4. Ingestion Gateway Specification (`/api/telemetry/events`)

The backend API gateway provides a single, hardened entry point for all mobile telemetry.

### 4.1 Endpoint Contract
- **Method:** `POST`
- **URI:** `https://ecardo.ir/api/telemetry/events` (or `/api/v1/telemetry/events`)
- **Headers:**
  - `Content-Type: application/json`
  - `Content-Encoding: gzip` (optional, recommended for batches > 5 KB)
  - `Authorization: Bearer <JWT>` (or `X-Installation-ID: <UUIDv4>` for pre-login unauthenticated events)
  - `X-Correlation-ID: <UUIDv4>`

### 4.2 Traffic Controls and Rate Limiting
- **Token-Bucket Rate Limiter:** Enforced by API Gateway Redis store.
  - Limit: 10 flush requests per minute per device/IP.
  - Burst Allowance: Up to 25 events per batch.
  - Exceeded Behavior: Returns `HTTP 429 Too Many Requests` with a `Retry-After: 60` header.
- **Payload Constraints:**
  - Individual event size limit: 8 KB.
  - Total batch payload limit: 64 KB uncompressed. Payloads exceeding this are rejected immediately with `HTTP 413 Payload Too Large`.

### 4.3 Validation and Ingestion Pipeline
1. **Schema Validation:** Ingestion middleware parses the payload against the canonical JSON Schema defined in `EVENT-CATALOG.md`. Malformed events are rejected with `HTTP 422 Unprocessable Entity`.
2. **Edge Redaction Pass:** Request headers, URLs, and string fields are scanned using compiled regex filters. Any matching credit card numbers (PANs), Iranian National IDs, passwords, or bearer tokens are masked before handoff to the OpenTelemetry Collector.
3. **OTLP Handoff:** Validated, sanitized batches are converted to OTLP JSON/Protobuf log records and pushed asynchronously over gRPC (port 4317) to the OpenTelemetry Collector cluster.

---

## 5. Transactional Outbox Pattern for Core Domain & Financial Events

Client-side mobile telemetry cannot be relied upon for critical regulatory or business audit trails because mobile devices may be offline, manipulated, or experience sudden process termination. 

For critical domain events (e.g., wallet debit, fiat remittance transfer, card state change), eCardo implements the **Transactional Outbox Pattern** directly within the backend database transaction.

### 5.1 Outbox Sequence Diagram

```
Application Service            Primary Database               Outbox Relayer Worker         OpenTelemetry / ES
        |                             |                                 |                           |
        | 1. Begin Transaction        |                                 |                           |
        |---------------------------->|                                 |                           |
        | 2. UPDATE balances          |                                 |                           |
        | 3. INSERT INTO ledger       |                                 |                           |
        | 4. INSERT INTO outbox_table |                                 |                           |
        |---------------------------->|                                 |                           |
        | 5. COMMIT                   |                                 |                           |
        |---------------------------->|                                 |                           |
        | (Transaction Closed)        |                                 |                           |
        |                             |                                 |                           |
        |                             | 6. SELECT ... FOR UPDATE        |                           |
        |                             |    SKIP LOCKED (Batch 100)      |                           |
        |                             |<--------------------------------|                           |
        |                             | 7. Return Pending Events        |                           |
        |                             |-------------------------------->|                           |
        |                             |                                 | 8. Publish to Pipeline    |
        |                             |                                 |-------------------------->|
        |                             | 9. UPDATE outbox_table          |                           |
        |                             |    SET status = 'PROCESSED'     |                           |
        |                             |<--------------------------------|                           |
```

### 5.2 Outbox Table Schema Definition
The transactional outbox table resides within the primary PostgreSQL / MySQL relational database:

```sql
CREATE TABLE transactional_outbox (
    id BIGSERIAL PRIMARY KEY,
    event_id VARCHAR(36) NOT NULL UNIQUE,       -- UUIDv4 for deduplication
    aggregate_type VARCHAR(64) NOT NULL,        -- e.g., 'Wallet', 'Card', 'Remittance'
    aggregate_id VARCHAR(64) NOT NULL,          -- e.g., 'wlt_98a72f01'
    event_type VARCHAR(64) NOT NULL,            -- e.g., 'financial_flow_commit'
    payload JSONB NOT NULL,                     -- Sanitized ECS-compliant JSON
    status VARCHAR(16) NOT NULL DEFAULT 'PENDING', -- 'PENDING', 'PROCESSING', 'PROCESSED', 'FAILED'
    retry_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP WITH TIME ZONE NULL
);

CREATE INDEX idx_outbox_pending ON transactional_outbox (created_at) WHERE status = 'PENDING';
```

### 5.3 Reliability Guarantees
- **At-Least-Once Delivery:** Events are only marked `PROCESSED` once the ingestion collector acknowledges successful reception.
- **Idempotent Ingestion:** The downstream consumer and Elasticsearch indexers use `event.id` as the Elasticsearch document `_id` (`PUT /<data-stream>/_create/<event.id>`), guaranteeing that duplicated outbox dispatches never create duplicate documents in Elasticsearch.

---

## 6. OpenTelemetry Collector Pipeline & Routing

The OpenTelemetry Collector operates as a stateless cluster positioned between backend services/gateways and the storage destinations.

### 6.1 Collector Pipeline Configuration

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  # 1. Prevent Collector OOM by dropping non-critical telemetry under memory pressure
  memory_limiter:
    check_interval: 1s
    limit_percentage: 80
    spike_limit_percentage: 20

  # 2. Batching to optimize bulk indexing throughput to Elasticsearch
  batch:
    send_batch_size: 500
    timeout: 1000ms
    send_batch_max_size: 1000

  # 3. Secondary defense-in-depth sanitization of sensitive values
  redaction:
    allowed_keys: []
    ignored_keys: ["correlation_id", "trace.id"]
    blocked_values:
      - "(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|603799[0-9]{10})" # PAN Regex
      - "[0-9]{4,6}" # Potential OTP codes in unclassified text

  # 4. Tail sampling processor (Sampling rule logic)
  tail_sampling:
    decision_wait: 10s
    expected_new_traces_per_sec: 2000
    policies:
      # 100% of errors and failures
      - name: drop_errors_sample_all
        type: status_code
        status_code: { status_codes: [ ERROR ] }
      # 100% of slow traces (> 1500ms)
      - name: sample_slow_traces
        type: latency
        latency: { threshold_ms: 1500 }
      # 1% probabilistic sampling for successful traces
      - name: sample_benign_traffic
        type: probabilistic
        probabilistic: { sampling_percentage: 1.0 }

exporters:
  elasticsearch:
    endpoints: ["https://es-node-01.internal:9200", "https://es-node-02.internal:9200"]
    tls:
      ca_file: /etc/otel/certs/root-ca.pem
      cert_file: /etc/otel/certs/collector.crt
      key_file: /etc/otel/certs/collector.key
    # Routing to dedicated Data Streams based on log category
    logs_dynamic_index:
      enabled: true
    mapping:
      mode: ecs

service:
  pipelines:
    logs:
      receivers: [otlp]
      processors: [memory_limiter, redaction, batch]
      exporters: [elasticsearch]
    traces:
      receivers: [otlp]
      processors: [memory_limiter, tail_sampling, batch]
      exporters: [elasticsearch]
```

### 6.2 Target Data Streams
Telemetry logs are dispatched into explicit, environment-isolated data streams:
- `logs-ecardo.mobile-prod`: Sanitized client diagnostic and session events.
- `logs-ecardo.api-prod`: Structured HTTP request, middleware, and application logs.
- `logs-ecardo.security-prod`: Authenticated audit trails, privilege escalations, and auth failures.
- `traces-ecardo-prod`: Distributed APM spans and performance metrics.

---

## 7. Sampling Strategy Matrix

To maintain high observability fidelity while controlling indexing costs and network utilization, telemetry ingestion applies a differentiated sampling model:

| Signal Category | Scope / Criteria | Sampling Rate | Implementation Mechanism |
| :--- | :--- | :--- | :--- |
| **Application Crashes & Panics** | Unhandled Flutter/Dart exceptions, OS fatal crashes | **100%** | Client Error Handler (Always sent) |
| **HTTP 5xx Server Errors** | Gateway timeouts (504), Internal server errors (500, 502) | **100%** | API Gateway & Collector Status Policy |
| **Security & Auth Failures** | HTTP 401 Unauthorized, 403 Forbidden, 429 Rate Limited | **100%** | Gateway Security Logger & Collector |
| **Failed Financial Flows** | Any `financial_flow_commit` resulting in `failure` | **100%** | Backend Outbox & Ingestion Pipeline |
| **Tail Latency Spikes** | Any request taking longer than 1,500ms | **100%** | OpenTelemetry Collector Tail Sampler |
| **Routine Health Checks** | Probes (`GET /health`, `GET /liveness`) | **0%** (Suppressed) | Ingest Filter (Never indexed in ES) |
| **Benign HTTP 200 GET Queries** | High-volume read endpoints (Banners, Rates, Config) | **1.0%** | Collector Probabilistic Head Sampler |
| **Routine Client Screen Views** | Standard navigation events without errors | **5.0%** | Mobile Telemetry Controller |

---

## 8. Dropping, Backpressure, and Circuit-Breaker Rules

System components must degrade gracefully when downstream observability infrastructure experiences saturation, lag, or complete failure.

### 8.1 Mobile Client Circuit Breaker
The Flutter mobile application maintains an internal state-machine circuit breaker for telemetry transmission:

```
    [ CLOSED ]  <--- (Reset after 5 mins of successful calls) ---+
         |                                                       |
         | 3 consecutive network timeouts (>3000ms)              |
         | OR HTTP 503 / 429 responses                           |
         v                                                       |
     [ OPEN ]  ==================================================+
         | (Telemetry flushing paused for 5 minutes)
         | All generated events drop silently to preserve memory
         v
    [ HALF-OPEN ] (After 5 minutes: send single trial batch)
```

1. **Closed State (Normal):** Telemetry is buffered and flushed normally according to batch and timer triggers.
2. **Open State (Tripped):** If 3 consecutive flush requests fail or time out (> 3,000ms), the circuit breaker trips to OPEN.
   - For a cooldown period of **5 minutes**, all client-side telemetry flushing is suspended.
   - Non-critical events are discarded immediately from the memory ring buffer.
   - **Zero User Impact:** The user experience, checkout process, and app responsiveness remain entirely unaffected. No error toasts or alerts are displayed to the user.
3. **Half-Open State (Trial):** After the 5-minute cooldown, the client sends a single probe batch of 1 event. If successful, the circuit resets to CLOSED; if it fails, the circuit re-opens for another 10 minutes.

### 8.2 Ingestion Gateway Backpressure
If the OpenTelemetry Collector pool or internal queue reaches high watermark capacity:
- The API Gateway returns `HTTP 429 Too Many Requests` with `Retry-After: 120`.
- Gateways shed incoming telemetry traffic while maintaining full throughput for transactional routes (`/api/v1/payments`, `/api/v1/transfers`).

### 8.3 Backend Worker Outbox Circuit Breaker
The Outbox Relayer daemon monitors the ingestion queue lag and Elasticsearch indexing latency:
- **Normal:** Elasticsearch bulk response latency < 500ms. Outbox relayer dispatches 100 events/sec.
- **Throttled:** If indexing latency exceeds 2,000ms or Elasticsearch returns `es_rejected_execution_exception` (HTTP 429):
  - Outbox relayer reduces batch size to 25 events.
  - Introduces exponential backoff sleep (1s, 2s, 4s, up to 60s max).
  - Events remain safely persisted inside `transactional_outbox` in the relational database.
  - Zero database records are lost. Once Elasticsearch recovers, the relayer drains the backlog.

### 8.4 OpenTelemetry Collector Memory Limiter Dropping
The OpenTelemetry Collector enforces strict memory boundaries:
- **Soft Limit (75% RAM):** The collector initiates proportional dropping of probabilistic 1% benign GET traces.
- **Hard Limit (85% RAM):** The collector drops incoming client logs, emits an alert metric (`otelcol_processor_dropped_records_total`), and frees JVM/Go heap allocations.
- **Isolation Guarantee:** Even if the collector drops 100% of telemetry under extreme load, core banking APIs continue normal processing.
