# فهرست فایل‌های مورد نیاز برای تحویل در خود مخزن

این چک‌لیست می‌گوید در جریان ادامهٔ کار چه فایل‌هایی باید ساخته/اصلاح شوند؛ به معنی وجود یا اعمال‌شدن آن‌ها در مخزن اصلی نیست.

## Release evidence / audit

- [ ] `docs/release/CURRENT_RELEASE.md` — تنها pointer وضعیت جاری
- [ ] `docs/audit/releases/v1.0.170/RELEASE_EVIDENCE.md` — archive تاریخی بدون ادعای current
- [ ] `docs/audit/releases/v1.0.171/RELEASE_EVIDENCE.md` — شواهد دقیق v1.0.171
- [ ] `docs/audit/FINDINGS.md` — status با SHA/test evidence، نه عبارت کلی resolved
- [ ] `docs/audit/TASKS.md` — sync master backlog، حذف ادعای انجام‌شده بدون evidence
- [ ] `docs/README.md` و ریشه `README.md` — شمار route/module/test فقط از baseline جاری یا لینک به release archive

## Financial safety

- [ ] `docs/architecture/ADR-FIN-IDEM-002.md`
- [ ] `docs/financial/OPERATION_INTENT_CONTRACT.md`
- [ ] `docs/financial/FINANCIAL_E2E_MATRIX.md`
- [ ] Tests: timeout-after-commit, 5xx-after-commit, app restart, TTL, capacity eviction, duplicate callback
- [ ] OpenAPI/API spec for operation status and idempotency mismatch

## Offline queue and security

- [ ] `docs/security/OFFLINE_QUEUE_CONTRACT.md`
- [ ] `docs/security/THREAT_MODEL.md` with DRI and risk acceptance
- [ ] queue schema version, exact route/method registry, TTL/max size/DLQ
- [ ] negative tests for URL injection, sensitive payload, method confusion, retry exhaustion

## CI/release

- [ ] Split read-only quality and release write jobs in existing workflow (not a duplicate workflow)
- [ ] Protected GitHub Environment for release, mirror and production notification
- [ ] `scripts/verify_release_metadata.py` in repo and CI/manual invocation
- [ ] SBOM, artifact SHA-256, signing verification output and provenance record
- [ ] `docs/release/ROLLBACK.md`

## Elasticsearch / data

- [ ] `docs/architecture/DATA-CLASSIFICATION.md` contains canonical approved retention matrix
- [ ] `docs/architecture/EVENT-CATALOG.md` schema is validated by backend ingestion code/tests
- [ ] backend ingest endpoint/OpenAPI, auth/rate limit, redaction, size limits
- [ ] OTel Collector/worker/outbox definitions in owning backend/infra repos
- [ ] versioned ES index templates and ILM definitions, validated in staging
- [ ] `docs/operations/SNAPSHOT-RESTORE-DRILL.md` has real evidence or explicitly marks examples not run
- [ ] load test report with actual throughput, p95/p99, rejection/drop, CPU/heap/disk
- [ ] CI validation that retention numbers are not duplicated inconsistently

## UX/product

- [ ] generated route inventory with module owner
- [ ] 6-locale critical-flow screenshot matrix
- [ ] Accessibility audit with manual TalkBack/VoiceOver evidence
- [ ] actual-device smoke report for payment/transfer/card/app resume flows
