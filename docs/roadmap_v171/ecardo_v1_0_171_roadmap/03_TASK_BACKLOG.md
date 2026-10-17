# Master Task Backlog — نسخهٔ 1.0.171+

**قاعده:** هیچ تسکی `DONE` نیست مگر artifact شواهد، commit/PR، تست مرتبط و owner وجود داشته باشد. Status پیش‌فرض همهٔ تسک‌ها `TODO / NEEDS VERIFICATION` است؛ حتی اگر بخشی از code موجود باشد.

## P0 — release blockers

| ID | تسک | Owner | وابستگی | معیار پذیرش |
|---|---|---|---|---|
| FIN-IDEM-01 | Operation ID پایدار برای intent مالی | Backend + Flutter | API owner/financial flows | یک intent بعد از timeout/5xx/restart/retry/TTL فقط یک debit نهایی دارد؛ server record و integration test موجود است |
| FIN-IDEM-02 | endpoint استعلام status/result برای pending-unknown | Backend | FIN-IDEM-01 | کلاینت قبل از ساخت intent جدید وضعیت intent قبلی را استعلام می‌کند |
| FIN-IDEM-03 | آزمون duplicate POST و duplicate provider callback | Backend QA | FIN-IDEM-01 | دو درخواست/دو callback یک نتیجهٔ مالی واحد تولید می‌کند |
| REL-DOC-01 | اصلاح release evidence نسخهٔ جاری | Release manager | run artifacts/tag | `CURRENT_RELEASE.md` version/SHA/tag/Run URLs را منطبق ثبت می‌کند؛ 170 به archive منتقل شده |
| SEC-OFF-01 | سخت‌سازی route/method allowlist صف آفلاین | Flutter security | queue tests | فقط method+normalized exact path از schema مجاز queueable است؛ absolute URI و unknown path رد می‌شوند |
| SEC-OFF-02 | ممنوعیت payload حساس و PII در queue | Flutter security + privacy | SEC-OFF-01 | تست ثابت می‌کند password/PIN/OTP/token/card/financial data enqueue نمی‌شود |

## P1 — امنیت، مالی و انتشار

| ID | تسک | Owner | وابستگی | معیار پذیرش |
|---|---|---|---|---|
| FIN-IDEM-04 | حذف `hashCode` به‌عنوان هویت intent | Flutter core | FIN-IDEM-01 | UUID operation ID پایدار؛ fingerprint canonical SHA-256 فقط برای mismatch detection |
| FIN-IDEM-05 | اصلاح تست misnamed «422 or 500» | QA | FIN-IDEM-01 | تست واقعی 500، timeout، connection reset و 422 با assertions جداگانه |
| FIN-IDEM-06 | رفتار کلید پس از TTL/capacity | Flutter + backend | FIN-IDEM-01 | unresolved intent با local eviction کلید/intent جدید نمی‌سازد؛ backend status lookup حل را تضمین می‌کند |
| SEC-OFF-03 | Queue TTL, max size, schema version و DLQ | Flutter core | SEC-OFF-01 | itemهای exhausted dead-letter و قابل مشاهده/پاک‌سازی‌اند؛ item نامحدود باقی نمی‌ماند |
| SEC-OFF-04 | روش HTTP queueed ذخیره و اجرا شود یا POST-only شود | Flutter core | SEC-OFF-01 | enqueue method غیرمجاز رد می‌شود؛ flush با method اشتباه replay نمی‌کند |
| SEC-TOKEN-01 | Keychain accessibility policy review | Mobile security | threat model | comment/config و نیازهای background همسو؛ iOS test روی locked/unlocked states وجود دارد |
| SEC-TOKEN-02 | failure-mode برای secure storage save/delete/migration | Mobile security | SEC-TOKEN-01 | اگر save/delete شکست خورد، UI موفقیت کاذب نشان نمی‌دهد؛ session state و telemetry امن تست شده‌اند |
| SEC-LOCK-01 | تعریف cold-start/auto-lock policy | Product security | threat model | تصمیم محصولی ثبت شده؛ launch/resume/inactivity/failed PIN تست خودکار و دستگاه دارد |
| CI-PRIV-01 | جداکردن read-only CI از release write permissions | DevEx | pipeline design | build/test روی PR `contents: read`; release job مجزای `contents: write` با tag/environment guard |
| CI-REL-02 | حذف انتشار خودکار بدون approval از main | Release engineering | CI-PRIV-01 | main push بدون approval artifact عمومی یا production webhook منتشر نمی‌کند |
| CI-FMT-01 | changed-files format gate fail-closed | DevEx | workflow | شکست diff/base/head موجب fail می‌شود؛ فایل‌ها به‌صورت quoted/nul-delimited پردازش می‌شوند |
| CI-ACT-01 | ارتقای actionهای deprecated و pin runner | DevEx | pipeline test branch | هیچ Node20/setup-java v4 deprecation warning مرتبط باقی نیست یا mitigation مستند دارد |
| API-CARD-01 | تست قرارداد funding source کارت در staging | Backend + Flutter QA | staging account | wallet→`irr_wallet` و gateway→`gateway`؛ پاسخ 422، موفقیت و reconciliation مستند است |
| API-PIN-01 | تکمیل تست همهٔ جریان‌های passcode | Flutter + backend QA | backend staging | withdraw/gift/request-money/transfer/exchange/purchase هر کدام موفق/ناموفق/passcode missing تست دارند |
| API-REC-01 | reconciliation flow برای payment/card/transfer | Backend | API contracts | pending/success/failed/reversed و webhook duplicate پوشش داده شده‌اند |
| EL-GOV-01 | یکسان‌کردن retention matrix | SRE + Privacy/Legal | owner signoff | DATA-CLASSIFICATION و runbook تنها به یک canonical matrix ارجاع می‌دهند |
| EL-EVIDENCE-01 | اثبات یا relabel کردن restore drill | SRE | backup cluster | snapshot ID، environment, log, timestamp, checksum, ticket و signer وجود دارد؛ در غیر این صورت نمونه اعلام شده |
| EL-IMPL-01 | ثبت وضعیت واقعی backend ingest/OTel/ES | Backend + SRE | infra access | هر جزء deployed/not deployed/blocked با repo, deployment SHA و evidence مشخص است |
| EL-SEC-01 | negative tests برای telemetry PII redaction | Backend security | ingest endpoint | PAN, national ID, auth headers, email/phone/token and nested data leakage tests pass |
| UX-I18N-01 | UI/flow audit واقعی روی device | QA + Design | devices | screenshot matrix و defect log برای 6 locale, RTL/LTR, dark/light, large text, offline states موجود است |
| IOS-REL-01 | اثبات signed iOS release | iOS/release owner | Team ID/cert/provisioning | macOS build, signature, TestFlight/device smoke, artifact checksum and evidence dossier |

## P2 — کیفیت و scale

| ID | تسک | Owner | معیار پذیرش |
|---|---|---|---|
| TEST-INV-01 | ساخت baseline خودکار routes/modules/test inventory | QA automation | artifact خروجی هر release و diff قابل مقایسه |
| TEST-FIN-02 | property-based tests برای money rounding/FX fees | Financial QA | edge cases decimals, overflow, inverse rates and rounding covered |
| TEST-E2E-01 | E2E harness برای top 10 critical journeys | QA | deterministic mock/staging matrix، no flaky critical tests |
| UX-A11Y-01 | accessibility test for critical screens | Design QA | screen reader, focus, contrast, touch target tests with documented exceptions |
| CI-SBOM-01 | SBOM/dependency/license report | DevSecOps | artifact attach to release; no untriaged high-risk dependency |
| CI-PROV-01 | attach checksums and provenance | Release engineer | SHA-256 of every released artifact and commit/run metadata published |
| EL-LOAD-01 | load test from baseline to capacity curve | SRE | report includes achieved req/s, p95/p99, errors, CPU/heap/disk and config; 5k req/s not assumed a priori |
| EL-ILM-01 | ILM and mappings in staging, then production-approved rollout | SRE | conflict-free policy, retention signoff, snapshot restore tested |
| EL-SLO-01 | establish SLO from measured SLI | Product/SRE | targets reviewed against recent production data and budget |
| UX-PERF-01 | device performance budget | Mobile | startup, jank, memory, network, size baselines with target per device tier |

## P3 — توسع با نیاز اثبات‌شده

| ID | تسک | شرط شروع |
|---|---|---|
| DATA-LAKE-01 | بررسی Kafka/Data Lake/Warehouse | فقط پس از baseline ingestion و نیاز تحلیلی که با outbox+worker برطرف نمی‌شود |
| ML-OPS-01 | anomaly detection/ML در telemetry | داده کافی، privacy approval و تعریف operational response وجود داشته باشد |
| APP-ARCH-01 | بازآرایی بزرگ معماری GetX/feature modules | baseline, ADR, migration plan و regression matrix تصویب شده باشد |

## الگوی status

- `TODO`: هنوز شروع نشده.
- `IN_PROGRESS`: owner مشخص، PR یا branch فعال.
- `BLOCKED`: وابستگی/credential/backend/device missing و نام آن ثبت شده.
- `DONE`: معیار پذیرش پاس شده و evidence link ثبت شده.
- `WONT_DO`: با دلیل فنی یا محصولی و owner approval ثبت شود.
