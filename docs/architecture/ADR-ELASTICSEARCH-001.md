# ADR-ELASTICSEARCH-001: Architectural Role, Non-Financial Boundary, and Graceful Degradation of Elasticsearch

- **Status:** ACCEPTED
- **Date:** 2026-10-15
- **Task Reference:** Task EL-003 (Roadmap Sections 23.1, 23.2, 27, 28, 30)
- **Deciders:** Chief Systems Architect, Head of Observability & SRE, Principal Security Architect, Core Financial Engineering Lead
- **Consulted:** Mobile Platform Guild, Backend Architecture Guild, Data Governance & Compliance Guild
- **Informed:** Infrastructure Operations, Product Management, Quality Assurance Guild
- **Applicable Services:** `ecardo_userapp_v1` (Flutter iOS, Android, Web), eCardo API Gateway, Backend Microservices (PHP/Laravel, Go), Observability Pipelines

---

## 1. Context and Problem Statement

The eCardo super-platform encompasses cross-border remittances, multi-currency digital wallets, card issuing, travel bookings, and merchant commerce. As the volume of distributed transactions, background jobs, and concurrent mobile application clients scales, engineering requires centralized search, low-latency distributed tracing, and real-time operational observability across heterogeneous services.

In enterprise fintech architectures, search engines like Elasticsearch are frequently misapplied beyond their operational scope. Organizations occasionally route transactional queries, account balance calculations, or user authorization lookups through search indexes to bypass database query latency or simplify full-text filtering. 

Such misarchitectures introduce catastrophic failure vectors:
1. **Eventual Consistency Hazards:** Elasticsearch relies on Lucene segment flushes and cluster replication, leading to refresh intervals (typically 1 to 5 seconds). Querying balance or pending authorizations against an eventually consistent index causes double-spending, race conditions, and ledger divergence.
2. **Cluster Failure Cascades:** If the search cluster experiences network partitioning, garbage collection pauses, or node recovery rebalances, operational outages can cascade into financial transaction failures, trapping user funds or rejecting valid payments.
3. **Perimeter Compromise:** Allowing mobile or web clients direct access to Elasticsearch exposes cluster ports, credentials, and internal schemas, violating OWASP MASVS and PCI-DSS requirements.

eCardo requires a formal, immutable Architecture Decision Record (ADR) establishing the absolute technical boundaries, authorized use cases, client isolation perimeter, and graceful degradation guarantees for Elasticsearch.

---

## 2. Non-Negotiable Boundary: Source of Truth Invariant

### 2.1 The Invariant Statement
**Elasticsearch is NEVER the system of record or source of truth for financial, ledger, or authorization state within the eCardo ecosystem.**

Under no circumstances may any software component, backend service, or client application treat Elasticsearch as the authoritative record for:
- Account balances and multi-currency wallet totals.
- Ledger entries, double-entry bookkeeping journals, and audit trails.
- Payment authorizations, payment gateway callbacks, or settlement states.
- Fund transfers (P2P, Sheba/ACH, SWIFT, card-to-card).
- Fiat withdrawals, cash deposits, or crypto custodial settlements.
- Order books, exchange rate locks, and trade matching engines.
- User KYC verification status, sanctions screening, or tier authorizations.

### 2.2 Relational Transactional Authority
The sole authoritative source of truth for all transactional, financial, and authorization records remains the primary relational database system (PostgreSQL / MySQL engine).
- **ACID Guarantees:** All debit and credit movements must be executed within serializable or read-committed ACID transactions utilizing strict relational foreign keys, row-level locks (`SELECT ... FOR UPDATE`), and immutable write-ahead logging (WAL).
- **Read-Your-Own-Writes:** Client balance views and transfer authorizations must query the relational database or a transactional cache directly synchronized via database transaction boundaries.
- **Derived Read Models:** Any representation of financial transactions within Elasticsearch is strictly a downstream, asynchronous projection (read-only copy) built exclusively for human troubleshooting and operational support.

---

## 3. Core Authorized Use Cases

Elasticsearch is deployed strictly as an auxiliary operational telemetry, structured log analysis, and diagnostic search platform.

```
+-------------------------------------------------------------------------+
|                  AUTHORIZED ELASTICSEARCH CAPABILITIES                   |
+-------------------------------------------------------------------------+
| 1. Operational Log Indexing    | Structured JSON logs from API and workers|
| 2. Distributed Tracing & APM  | W3C trace context, latency, span analysis|
| 3. SRE Health Metrics         | Error rates, p50/p95/p99 latency, SLA/SLO|
| 4. Support Troubleshooting    | Correlation ID lookup with sanitized PII |
| 5. Diagnostic Alerting        | Anomaly detection on error rates and lag |
+-------------------------------------------------------------------------+
```

### 3.1 Structured Operational Log Indexing
Ingestion of structured JSON logs generated by backend API servers, background queue workers, and edge proxies. Logs conform strictly to the Elastic Common Schema (ECS), providing searchable metadata such as log level, calling class, component name, and execution duration.

### 3.2 APM Tracing and Distributed Correlation
Collection and indexing of OpenTelemetry spans and trace events. Enables site reliability engineers (SRE) and backend developers to trace a single user action from the Flutter mobile client through the API gateway, microservice calls, database queries, and external payment aggregators using unique identifiers:
- `trace.id`: Hexadecimal distributed trace context.
- `correlation_id`: Opaque UUIDv4 passed through HTTP headers (`X-Correlation-ID`) across inter-service boundaries.

### 3.3 SRE Metrics and Fleet Health Monitoring
Aggregation of operational telemetry to compute service level indicators (SLIs) and evaluate service level objectives (SLOs):
- HTTP status code distributions (ratio of 2xx vs. 4xx vs. 5xx).
- Endpoint latency percentiles (p50, p95, p99).
- Background queue lag, consumer throughput, and database connection pool saturation.

### 3.4 Authorized Customer Support Search
Customer support agents and operations personnel may query operational logs to troubleshoot user-reported issues (e.g., locating an error message associated with a failed top-up attempt) subject to strict constraints:
- Queries must be executed via an authenticated internal support gateway.
- Search queries must target `correlation_id` or pseudonymous identifiers (`pseudonymous_user_id`), never raw personal credentials or unmasked card numbers.
- Results are subject to server-side role-based access control (RBAC).

---

## 4. Flutter Client Isolation Perimeter

```
+------------------+       HTTPS / TLS 1.3        +--------------------+
|   Flutter App    | ---------------------------> | eCardo Backend API |
| (iOS / Android)  |   POST /api/telemetry/events |  (Ingest Gateway)  |
+------------------+                              +--------------------+
         |                                                  |
         | DIRECT CONNECTION                                | OTLP / gRPC
         | STRICTLY PROHIBITED                              v
         | (No credentials, no ports)             +--------------------+
         v                                        |   OTel Collector   |
  XXXXXXXXXXXXXXXX                                +--------------------+
  X ElasticsearchX                                          | Bulk Index
  X   Cluster    X <----------------------------------------+
  XXXXXXXXXXXXXXXX
```

### 4.1 Absolute Direct Connection Prohibition
The Flutter client application (`ecardo_userapp_v1`), whether running on Android, iOS, or Web, must NEVER establish a direct TCP or HTTP connection to the Elasticsearch cluster, Kibana, or the OpenTelemetry Collector.

1. **Zero Credential Exposure:** No Elasticsearch credentials, API keys, basic authentication secrets, or cluster host URLs may ever be compiled into application binaries, bundled into assets, or delivered via remote config.
2. **Network Perimeter Enforcement:** Elasticsearch clusters operate within isolated private VPC subnets. Ports 9200 (REST HTTP) and 9300 (Transport) must be firewalled from all public ingress traffic and accessible solely by the OpenTelemetry Collector and designated internal ingestion workers.

### 4.2 Authenticated Ingestion Gateway
All client-side telemetry must route exclusively through the eCardo Backend API ingestion gateway endpoint:
`POST /api/telemetry/events`

The ingestion gateway acts as an enforcement boundary implementing:
- **Authentication:** Verification of active, signed JWT bearer tokens or validated device installation signatures.
- **Rate Limiting:** Token-bucket rate limiting (e.g., maximum 10 flush requests per minute per device, burst allowance of 25 events).
- **Payload Validation:** Strict validation against the event schema envelope (`EVENT-CATALOG.md`), rejecting payloads exceeding 64 KB.
- **Edge Sanitization:** Immediate redaction of prohibited keys and PII patterns before events are forwarded to message brokers or collectors.

---

## 5. Graceful Degradation and System Resilience

### 5.1 Service Tiering Classification
The eCardo system operates under an explicit availability tier hierarchy:
- **Tier 0 (Core Financial & Auth):** User Login, Multi-Factor Authentication, Ledger Operations, Payment Execution, Card Management. Availability target: 99.999%.
- **Tier 3 (Operational Observability):** Elasticsearch Log Indexing, Trace Visualization, Kibana Dashboards, Telemetry Analytics. Availability target: 99.0%.

Under no architectural circumstance may a Tier-3 system failure degrade, slow, or interrupt a Tier-0 business flow.

### 5.2 Failure Scenarios and System Response

| Failure Scenario | State of Elasticsearch | Core Backend & Mobile App Behavior |
| :--- | :--- | :--- |
| **Total Cluster Outage** | Unreachable (Connection Refused / 503) | **Normal Operation:** All financial transactions, wallet transfers, and client logins complete successfully. Telemetry is buffered in bounded local queues or dropped. Zero user-facing errors. |
| **Indexing Latency Spike / GC Pause** | Response times > 10,000ms | **Normal Operation:** Backend API fire-and-forget logging triggers circuit breakers. Collector buffers to disk; client telemetry drops non-essential spans. |
| **Cluster Ingestion Saturation (HTTP 429)** | Influx rate exceeds indexing capacity | **Normal Operation:** Backpressure is absorbed by the OpenTelemetry Collector memory limiter and bounded backend outbox workers. Telemetry events are sampled down; financial transactions proceed unaffected. |
| **Search Index Corruption / Red Cluster** | Index status RED | **Normal Operation:** Kibana alerts trigger on-call SREs. Operational search is temporarily unavailable. Transactional ledger operations continue unabated. |

### 5.3 Asynchronous Non-Blocking Logging Invariant
1. **Fire-and-Forget / Asynchronous Dispatch:** Telemetry emission from core transactional paths must be completely decoupled from the HTTP request-response cycle. Telemetry is emitted to in-memory non-blocking ring buffers or background daemon queues.
2. **No Synchronous Search Reads:** No endpoint in the core transactional path (e.g., `POST /api/v1/payments/transfer`, `POST /api/v1/auth/login`) may execute an Elasticsearch query to compute a business decision or validate input state.
3. **Drop Over Block Policy:** If internal telemetry buffers reach their configured capacity limits during an Elasticsearch degradation event, the buffer must drop excess telemetry packets and increment a dropped-event counter (`telemetry_events_dropped_total`), rather than applying backpressure to the calling business threads.

---

## 6. Architecture Governance and Verification

To guarantee adherence to this ADR throughout the software lifecycle, the following controls are mandatory:

1. **Automated Static Code Analysis:**
   - CI pipelines run static analysis checking for Elasticsearch client SDK imports (`@elastic/elasticsearch`, `elasticsearch`, `elastic-apm-node`, `es_client`) inside the Flutter client codebase (`lib/`) and core financial backend services. Any import outside authorized observability adapters fails the build.
2. **Network Security Verification:**
   - Periodic automated network scans verify that ports 9200 and 9300 reject all traffic originating outside the trusted backend Kubernetes cluster.
3. **Chaos Engineering & Resilience Tests:**
   - Pre-release resilience drills (Task EL-017) periodically simulate Elasticsearch cluster termination while executing simulated user logins and fund transfers. Verification requires zero transaction failures and zero response latency deviations on financial endpoints.

---

## 7. Consequences and Trade-offs

### 7.1 Positive Consequences
- **Financial Integrity Preserved:** Isolates the transactional core from search engine quirks, ensuring zero risk of double spending or split-brain accounting.
- **Maximum Availability:** Complete resilience against observability infrastructure downtime.
- **Clean Compliance Posture:** Adheres strictly to PCI-DSS v4.0 requirement 3 (protection of stored cardholder data) and OWASP MASVS network/storage controls.
- **Clear Engineering Boundaries:** Eliminates team confusion regarding where business logic and persistence belong.

### 7.2 Negative Consequences and Mitigations
- **Operational Lag:** Operations dashboards and customer support search tools exhibit an ingestion lag (typically 500ms to 3s). Support workflows must be trained to recognize eventual consistency windows.
- **Dual Pipeline Maintenance:** Requires maintaining both the primary relational schema and corresponding Elasticsearch index templates and mapping files.
