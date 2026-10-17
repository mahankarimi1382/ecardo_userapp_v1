# نقشهٔ راه اصلی از v1.0.171 به بعد

## اصل راهبردی

به جای انباشتن قابلیت‌های جدید، ابتدا صحت عملیات مالی و شواهد release را قابل‌اعتماد کنید؛ سپس resilience، امنیت، UX و زیرساخت داده را به‌صورت مرحله‌ای کامل کنید. کار باید بر اساس ریسک و وابستگی انجام شود، نه بر اساس تعداد تسک‌های بسته‌شده.

## فازها و دروازه‌های عبور

### Phase 0 — Freeze, evidence, baseline
**هدف:** ثبت وضعیت غیرقابل ابهام `v1.0.171` و جلوگیری از تکرار ادعاهای قدیمی.
- Freeze release artifacts، tag و SHA؛ دانلود artifactهای #612 و record کردن checksum.
- اجرای مجدد `flutter --version`, `dart --version`, `flutter pub get`, `flutter analyze`, `flutter test` روی exact tag.
- استخراج تعداد واقعی تست‌ها از log؛ رفع اختلاف 646/682.
- جدا کردن release evidence تاریخی 170 از پروندهٔ 171.
- گرفتن inventory واقعی `routes`, `modules`, `controllers`, `API paths`, `test files` با script reproducible.

**Gate:** همهٔ مدارک دارای SHA، run URL و زمان‌اند؛ هیچ سند جاری ادعای release 170 را به‌عنوان وضعیت 171 ندارد.

### Phase 1 — Financial safety P0
**هدف:** حذف احتمال تولید کلید جدید برای intent نامعلوم و اثبات duplicate suppression.
- طراحی `FinancialOperationIntent` در کلاینت با UUID پایدار و lifecycle `created → submitting → pending_unknown → succeeded/failed/cancelled`.
- ارسال همان `operationId` در تمام retries برای یک intent.
- تعریف contract سمت سرور: unique idempotency record بر اساس user/tenant + operation ID + endpoint; payload hash mismatch رد شود.
- نگهداری status/result پاسخ نهایی در backend؛ endpoint استعلام وضعیت.
- integration tests روی duplicate POST، timeout بعد از commit، HTTP 500 بعد از commit، retry پس از restart و retry بعد از TTL.

**Gate:** هیچ سناریوی timeout/5xx/force close نمی‌تواند یک intent را به debit دوم تبدیل کند؛ این مورد در integration test با database واقعی/transactional test ثابت شود.

### Phase 2 — Offline queue, session, credential lifecycle
**هدف:** فقط عملیات بی‌خطر و قابل تکرار در صف بماند و خروج از حساب fail-closed باشد.
- Route/method allowlist دقیق و normalized.
- Schema-based payload allowlist، حذف داده حساس و PII غیرضروری؛ encryption-at-rest یا عدم ذخیرهٔ payload حساس.
- اضافه‌کردن queue version, TTL, max count/bytes, dead-letter state, retry policy و UI support recovery.
- تست queue corruption، app restart، offline-to-online، duplicate flush و logout.
- بررسی `KeychainAccessibility.first_unlock` بر مبنای policy؛ بررسی خطای secure storage هنگام save/delete/migration.
- تعریف واحد رفتار cold start، app resume، inactivity, PIN/biometric failure و logout.

**Gate:** هیچ token/password/PIN/OTP/card data/financial intent در صف آفلاین نیست؛ خروج امن در همهٔ مسیرها تست شده است.

### Phase 3 — CI/CD and release governance
**هدف:** هر artifact قابل ردیابی و انتشار فقط با مجوز صریح باشد.
- split `quality/test`, `build`, `release`, `mirror`, `server notify` jobs.
- permissions کمینه؛ job عادی read-only و release فقط tag/environment محافظت‌شده.
- تغییر auto-release-on-main به tag/dispatch کنترل‌شده با approval، مگر owner تصمیم مستند دیگری داشته باشد.
- فرمت changed-files بدون سرکوب خطای diff؛ base/head failure باید fail شود.
- ارتقای actionهای deprecated و pin کردن runnerها.
- تولید SBOM، dependency/license report، artifact SHA-256، signing verification و provenance.

**Gate:** pull request نمی‌تواند artifact عمومی منتشر کند یا webhook production را فراخوانی کند؛ release evidence برای commit/tag واحد است.

### Phase 4 — API contracts and backend reconciliation
**هدف:** اثبات توافق کلاینت و سرور.
- تأیید نسخهٔ قرارداد `funding_source` برای کارت (`irr_wallet`/`gateway`) با backend owner.
- تست staging با پاسخ‌های 2xx، 4xx، 5xx، timeout، webhook دیررس، duplicate callback و eventual reconciliation.
- برای transfer/withdraw/exchange/P2P/card funding، state machineهای pending/settled/failed/reversed مشخص شوند.
- قیمت/کارمزد/نرخ در سمت سرور canonical باشد؛ اپ فقط نمایش‌دهنده باشد.

**Gate:** هر flow پولی test report با API version، environment، synthetic account و reconciliation evidence دارد.

### Phase 5 — UX, accessibility, localization
**هدف:** پوشش ۹۹ route و تمام حالت‌ها، نه فقط widgetهای مجزا.
- Route registry و screen ownership خودکار شود.
- matrix برای شش locale `fa/ar/en/ru/tr/zh`، RTL/LTR، dark/light، font scaling، offline، loading/error/empty/pending/success.
- تست task-based کاربر برای login, KYC, transfer, withdrawal, exchange, virtual card, payment return و travel booking.
- Golden screenshots با baseline ثبت‌شده؛ تغییر عمدهٔ UI نیازمند review انسانی.
- TalkBack/VoiceOver، semantic labels، focus traversal، contrast و touch targets.

**Gate:** هیچ blocker دسترس‌پذیری در عملیات مالی حیاتی؛ screenshot diffs بازبینی شده؛ خطاهای clipping/RTL حل شده‌اند.

### Phase 6 — Elasticsearch/Observability MVP
**هدف:** telemetry عملیاتی قابل جست‌وجو بدون وابستگی مسیر مالی به ES.
- تعیین owners و repo محل اجرای backend ingest + infra.
- قرارداد event catalog، schema versioning، authentication/rate limit/payload size.
- outbox یا queue backend برای reliability؛ OTel Collector و Elasticsearch در private network.
- data masking در source و ingest؛ allowlist fields؛ security negative tests.
- نگهداری کوتاه و کمینه؛ retention policy واحد پس از تأیید قانونی.
- graceful degradation: ES down نمی‌تواند response پرداخت/ledger را تغییر دهد.

**Gate:** no direct client-to-ES; failed ES produces no financial-flow regression; redaction tests and load report are evidence-backed.

### Phase 7 — SRE, disaster recovery, scale
**هدف:** اجرای واقعی runbookها.
- Cluster topology/resource estimate بر مبنای ingestion volume واقعی.
- deploy templates, ILM, dashboards, alerts and RBAC in staging.
- load test مرحله‌ای، نه فقط هدف ثابت 5,000 req/s؛ ثبت capacity curve.
- snapshot/restore واقعی و signed evidence؛ RTO/RPO اهداف پیشنهادی تا زمان اندازه‌گیری.
- tabletop تمرین incidentهای PII leak, ingestion lag, watermark, index mapping rejection, ES outage.

**Gate:** یک restore drill و load test با artifact/evidence کامل، owner sign-off و نتیجهٔ قابل تکرار.

### Phase 8 — iOS release
**هدف:** برداشتن وضعیت BLOCKED با شواهد امضای واقعی.
- Apple Team ID، provisioning profiles، distribution certificates و CI secrets از owner تهیه شود.
- build signed در macOS runner؛ بررسی entitlements/privacy usage descriptions و Firebase iOS.
- نصب و smoke test روی device/TestFlight.
- ثبت artifact checksum، signing details و rollback path.

**Gate:** signed artifact installable و smoke tests pass؛ تا آن زمان iOS release به‌عنوان blocked باقی بماند.

## ترتیب اجرای کوتاه‌مدت

1. `REL-DOC-01` — بازسازی evidence و current release pointer.
2. `FIN-IDEM-01` — پایدارسازی operation ID و وضعیت unknown در backend.
3. `FIN-IDEM-02/03` — fingerprint و تست 5xx/restart/TTL.
4. `SEC-OFF-01/02` — queue allowlist، payload schema و DLQ.
5. `SEC-KEYCHAIN-01` — save/delete/migration failure paths.
6. `CI-PRIV-01` — permission split و release approval.
7. `API-CARD-01` — staging integration برای صدور کارت/پس‌کد.
8. `EL-GOV-01` — canonical retention policy.
9. `EL-EVIDENCE-01/EL-IMPL-01` — verify or relabel operations docs; implement backend/infra in correct repos.
10. `UX-I18N-01` — دستگاه‌های واقعی و تست تصویری/کاربر.

## خارج از scope تا زمان اثبات نیاز

- گسترش Big Data به Kafka/Data Lake یا معماری چندکلاستری پیش از ثبت ingestion volume و SLI.
- استفاده از Elasticsearch برای balance, ledger, payment authorization, KYC status یا تصمیم‌های مالی.
- redesign پرریسک همهٔ UIها پیش از داشتن baseline و test matrix.
- علامت‌گذاری یک finding به‌عنوان resolved صرفاً بر پایهٔ سند، کامنت یا unit test بدون شواهد متناظر.
