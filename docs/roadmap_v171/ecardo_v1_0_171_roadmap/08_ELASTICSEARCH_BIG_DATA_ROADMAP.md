# Elasticsearch & Big Data — برنامهٔ پیاده‌سازی واقع‌گرا

## اصل معماری

Elasticsearch فقط زیرساخت مشتق‌شدهٔ جست‌وجو، structured logs، traces، SRE dashboards و operational diagnostics است. منبع حقیقت برای balance، ledger، payment authorization/finality، exchange locks و KYC authorization همچنان backend و پایگاه دادهٔ تراکنشی خواهد بود.

## وضعیت فعلی شواهد

نسخهٔ ۱٫۰٫۱۷۱ اسنادی مانند `ADR-ELASTICSEARCH-001.md`, `DATA-CLASSIFICATION.md`, `EVENT-CATALOG.md`, `OBSERVABILITY-DATA-FLOW.md`, `ELASTICSEARCH-RUNBOOK.md`, `SNAPSHOT-RESTORE-DRILL.md`, `TELEMETRY-SECURITY-TESTS.md` و `OBSERVABILITY-LOAD-TESTS.md` اضافه کرده است.

**اما:** این اسناد به‌تنهایی وجود deployment واقعی، ingest endpoint، broker, outbox, Collector, dashboards, ILM policy یا backup repository را اثبات نمی‌کنند. برای پیاده‌سازی باید repoهای backend/infra owner شناسایی شوند؛ Flutter app تنها از API خود backend استفاده می‌کند.

## Stage EL-0 — inventory/dependencies

- مشخص کنید backend اصلی کدام repoها و سرویس‌ها هستند و owner هرکدام کیست.
- نسخهٔ Elastic، deployment model، network boundary، secret manager، snapshot storage، data volume، daily ingest bytes و retention constraints را با evidence ثبت کنید.
- قبل از انتخاب Kafka، اندازه‌گیری کنید که transactional outbox + worker/queue موجود کافی هست یا خیر.

**Deliverables:** `docs/observability/DEPLOYMENT_INVENTORY.md`, `docs/observability/OWNERS.md`, baseline traffic report.

## Stage EL-1 — event schema and privacy

- `event.id`, schema version, timestamp, service/version/environment, severity, action/outcome, trace/correlation IDs و sanitized error category تعریف شوند.
- default-deny schema؛ فیلدهای مجاز explicit باشند.
- secrets, authorization headers, raw request/response body, PAN/CVV, PIN/OTP/password, identity documents و raw bank details ممنوع.
- pseudonymous user identifier فقط با privacy approval و retention محدود.
- در gateway هم validation و redaction انجام شود؛ redaction فقط مسئولیت Flutter نباشد.

**Gate:** schema versioning، negative tests و access controls پاس شوند.

## Stage EL-2 — backend ingestion

```text
Flutter ──HTTPS──> eCardo Backend Ingest API
                       ├─ Auth / rate limit / schema validation
                       ├─ PII and secret rejection
                       └─ durable outbox / bounded queue
                                └─ OTel Collector / worker
                                      └─ Elasticsearch private cluster
```

- endpoint نمونهٔ `POST /api/telemetry/events` فقط پس از تعریف و اجرای contract واقعی backend معتبر خواهد بود.
- لاگ telemetry نباید عملیات مالی را block کند. اگر pipeline unavailable شد، eventها در buffer محدود ذخیره یا drop شوند؛ خطای ES نباید transaction response را تغییر دهد.
- correlation IDs برای اتصال traceها استفاده شوند؛ IDs مالی شناسهٔ public قابل حدس یا credential نباشند.

**Deliverables:** API schema/openapi, backend tests, rate-limit policy, outbox monitoring, worker DLQ policy.

## Stage EL-3 — private Elastic cluster

- ES/Kibana/OTel Collector در private network؛ no public ingress برای 9200/9300.
- secret manager؛ service accounts حداقل دسترسی؛ TLS verification و certificate rotation.
- composable templates, explicit mappings, data streams, ILM و index-template tests.
- snapshots خارج از host/cluster; restore drill واقعی؛ RBAC برای support queries.
- dashboards اولیه: API status rates, p95/p99, queue lag, ingest rejections, disk watermark, JVM pressure, cluster health, telemetry drop counts.

## Stage EL-4 — load/failure test

مقدار «5,000 req/s» فعلاً هدف یک تست است، نه ظرفیت اثبات‌شده. مراحل:

1. baseline: 100/250/500 req/s یا متناسب با ترافیک واقعی.
2. ramp-up کنترل‌شده تا نقطهٔ شکست یا هدف مصوب.
3. اندازه‌گیری p50/p95/p99، errors, dropped events, queue lag, CPU, heap, disk, shard count, indexing latency.
4. قطع ES، قطع broker، کند شدن ingest، disk watermark و restart worker را fault-inject کنید.
5. همزمان transaction test staging اجرا شود و نشان دهد تراکنش مالی مستقل از telemetry است.

**Gate:** report قابل تکرار با commit/config/checksum، بار تولید، سخت‌افزار، نسخه‌ها و حدود پذیرفته‌شده.

## Stage EL-5 — operations & compliance

- retention matrix واحد پس از تصویب Legal/Privacy/Security/SRE.
- ILM simulation در staging، سپس deploy approval.
- restore test با snapshot ID، start/end time، dataset counts/checksums، recovery logs و ticket.
- SLO/SLA فقط پس از محاسبه از production SLI و تأیید مالک سرویس معتبر اعلام شود.
- incident runbooks شامل owner/phone/contact واقعی و آزمایش‌شده باشند؛ placeholderهای PagerDuty یا hostnameهای نمونه به عنوان real endpoint به کار نروند.

## حداقل برای MVP

- backend ingest API + authentication/rate-limit/schema validation
- strict event allowlist + masking tests
- outbox/worker یا queue پایدار موجود
- private ES + index template + ILM policy تأییدشده
- 3 dashboard و حداقل alerts
- chaos test برای ES-down و PII-negative suite
- backup/restore evidence

Kafka, lakehouse, warehouse, long-term cold searchable snapshots و ML anomaly detection تا وقتی حجم و نیاز مشخص نشده لازم نیستند.
