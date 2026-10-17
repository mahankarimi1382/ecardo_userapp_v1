# ممیزی کامل نسخهٔ فعلی — eCardo User App v1.0.171

**تاریخ:** 2026-10-17  
**Scope:** بررسی منبع عمومی GitHub، فایل‌های کلیدی Flutter، CI/CD، اسناد معماری/امنیت/Elasticsearch و اسناد انتشار.  
**نتیجهٔ کلی:** `CONTINUE WITH BLOCKING REMEDIATIONS` — نسخه پیشرفت قابل توجهی دارد، اما مستندات انتشار، idempotency پایدار، حریم خصوصی صف آفلاین و پذیرش عملیاتی Elasticsearch به شواهد و اصلاح تکمیلی نیاز دارند.

## 1. نسخه و CI

| مورد | نتیجهٔ مشاهده‌شده | تفسیر |
|---|---|---|
| `pubspec.yaml` | `1.0.171+171` | نسخهٔ کد در branch اصلی |
| تگ Release | `v1.0.171` | صفحهٔ Releases، نسخه را در 17 اکتبر 2026 منتشرشده نشان می‌دهد |
| کامیت Release | `25028235b92cd9c026454df64c88cef44fda9ce6` | commit `2502823` عمدتاً اسناد release/architecture/operations را اضافه یا اصلاح می‌کند |
| کامیت قبلی کد | `5a4abe6` | اصلاحات نشست، صف PIN، شبکه، کارت و پس‌کد در این نقطه انجام شده‌اند |
| Android Build #611 | موفق، commit `2502823` روی `main` | CI green برای جریان branch |
| Android Build #612 | موفق، commit `2502823` روی tag `v1.0.171` | CI green برای جریان tag/release |
| Web Build #228 | موفق، commit `2502823` روی `main` | build وب موفق گزارش شده |
| iOS | مدرک build و signing نهایی در این بررسی به طور مستقل تأیید نشد | تا دریافت artifact، provisioning و گزارش runner مک، `BLOCKED/UNVERIFIED` نگه دارید |

منابع: [Release page](https://github.com/mahankarimi1382/ecardo_userapp_v1/releases)، [Commit 2502823](https://github.com/mahankarimi1382/ecardo_userapp_v1/commit/25028235b92cd9c026454df64c88cef44fda9ce6)، [Actions برای 2502823](https://github.com/mahankarimi1382/ecardo_userapp_v1/actions?query=commit%3A2502823).

### وضعیت تست‌ها

- گزارش قبلی ۶۸۲ تست موفق و `flutter analyze` بدون مشکل را گزارش کرده است.
- README ریشه هنوز از «646 test suite» و ۶۴۶ تست صحبت می‌کند.
- `docs/audit/BASELINE.md` در خروجی فرمان `+682` را ثبت می‌کند، اما در جملهٔ بعد هنوز می‌گوید suite شامل ۶۴۶ تست است.
- `docs/audit/RELEASE_EVIDENCE.md` و `RELEASE_CHECKLIST.md` همچنان نسخهٔ `1.0.170+170`، SHA قدیمی `5a4abe6`، رابطهٔ قدیمی `ahead of de37b1e` و حتی عبارت «هنوز push نشده» را دارند. این ادعا با release عمومی `v1.0.171` هماهنگ نیست.

**نتیجه:** CI نسخهٔ ۱۷۱ موفق دیده شده؛ ولی محتوای سند فعلی به‌طور قابل اعتماد ثابت نمی‌کند تعداد دقیق تست‌های اجراشده در همین SHA چقدر بوده است. فایل‌های evidence باید به‌صورت immutable برای هر release نگهداری شوند و یک فایل `CURRENT_RELEASE.md` مرجع وضعیت جاری باشد.

## 2. موارد مثبت که باید حفظ شوند

1. نسخهٔ کد فعلی `TokenService` توکن bearer را از طریق `FlutterSecureStorage` نگهداری می‌کند، وضعیت آمادگی بارگذاری توکن دارد و حذف legacy token را هم تلاش می‌کند.
2. `OfflineRequestQueue` در نسخهٔ فعلی دیگر مسیر تغییر گذرواژه را در allowlist ندارد و endpointهای مجاز را محدودتر کرده است.
3. `NetworkService` برای پاسخ‌های موفق و خطاهای 4xx/5xx، idempotency lifecycle را از هم تفکیک می‌کند و در کد فعلی تلاش می‌کند کلید را در timeout، قطع اتصال و 5xx حفظ کند.
4. log sanitizer برای پوشاندن تعدادی از کلیدهای حساس از جمله password، PIN، OTP، PAN و token نوشته شده است.
5. نسخهٔ ۱٫۰٫۱۷۱ اسناد Architecture Decision Record، data classification، event catalog، observability flow، runbook و تست‌های طراحی‌شده برای telemetry را اضافه کرده است.

این موارد پیشرفت ساختاری‌اند؛ با این حال وجود کد یا سند به‌تنهایی اثبات اجرای موفق در محیط واقعی نیست.

## 3. یافته‌های با اولویت بالا

### P0 — FIN-IDEM-01: پایان TTL نباید به معنی «تراکنش جدید» تلقی شود

فایل: [`network_service.dart`](https://github.com/mahankarimi1382/ecardo_userapp_v1/blob/main/lib/src/network/service/network_service.dart#L227-L305) و [`workstream_b_idempotency_logging_test.dart`](https://github.com/mahankarimi1382/ecardo_userapp_v1/blob/main/test/workstream_b_idempotency_logging_test.dart#L182-L219).

رجیستری کلاینت ۵ دقیقه TTL دارد و تست فعلی صراحتاً انتظار دارد پس از ۵ دقیقه و یک ثانیه کلید تازه تولید شود. این برای آزادسازی حافظه قابل فهم است، اما اگر نتیجهٔ تراکنش قبلی نامعلوم بماند، retry بعد از TTL می‌تواند از دید سرور یک عملیات جدید به نظر برسد. پاک شدن entry محلی نباید به معنی پاک شدن intent مالی باشد.

**اصلاح لازم:** شناسهٔ عملیات باید در زمان ساخت intent مالی تولید، ذخیره و تا تعیین وضعیت نهایی نگهداری شود. بعد از timeout/5xx، صفحه باید `PENDING/UNKNOWN` نشان دهد و وضعیت همان intent را از بک‌اند استعلام کند؛ ایجاد intent جدید فقط با اقدام صریح و تأییدشدهٔ کاربر انجام شود. ضمانت نهایی duplicate suppression باید در بک‌اند و پایگاه دادهٔ تراکنشی باشد.

### P1 — FIN-IDEM-02: fingerprint با `hashCode` یک قرارداد مالی پایدار نیست

`_payloadFingerprint` از `jsonEncode(data).hashCode` استفاده می‌کند. این مقدار برای شناسایی intent حساس به collision است و canonicalization/پایداری در طول چرخهٔ برنامه تضمین‌شده‌ای فراهم نمی‌کند. بهتر است اصلاً هویت intent از fingerprint payload استنتاج نشود.

**اصلاح لازم:** `operationId` تصادفی و پایدار از UI/service intent ساخته شود، در همهٔ retryها استفاده شود و سرور آن را با scope کاربر، endpoint، payload hash و پاسخ نهایی ثبت کند. اگر fingerprint کمکی لازم است، از JSON canonical و SHA-256 استفاده شود، نه `hashCode`.

### P1 — FIN-IDEM-03: پوشش تست برای 5xx کامل نیست

در `test/workstream_b_idempotency_logging_test.dart` نام تست «HTTP 422 or 500» را دارد، ولی کد موجود در آن بخش عملاً status 422 را اجرا و آزادشدن کلید را بررسی می‌کند؛ سناریوی 500 در آن تست پیاده نشده است. کد فعلی تلاش می‌کند 5xx را مبهم فرض کند، پس باید تستی اضافه شود که retry با همان `operationId` در 500 و timeout حفظ شود.

**معیار پذیرش:** تست unit و integration ثابت کند `422` کلید موقت همان تلاش را آزاد می‌کند، ولی `500`, timeout و قطع اتصال همان intent را حفظ می‌کنند؛ سپس تست contract ثابت کند بک‌اند حتی در اثر retry نتواند debit را دوباره اجرا کند.

### P1 — SEC-OFF-01: صف آفلاین هنوز باید دقیق‌تر و حداقلی شود

فایل: [`offline_request_queue.dart`](https://github.com/mahankarimi1382/ecardo_userapp_v1/blob/main/lib/src/common/services/offline_request_queue.dart).

- payload هر درخواست به شکل JSON در `SharedPreferences` ذخیره می‌شود.
- بررسی `isQueueable` از `endpoint.contains(allowlistedPrefix)` استفاده می‌کند، نه تطبیق دقیق path و method.
- payload به‌خودی‌خود بر اساس field classification بررسی نمی‌شود؛ مسیر profile می‌تواند شامل PII باشد.
- `flush` همهٔ itemها را با `net.post` ارسال می‌کند، درحالی‌که ساختار item فیلد `method` هم دارد.
- پس از رسیدن `retries` به حداکثر، item همچنان در صف باقی می‌ماند؛ سیاست DLQ/انقضا/پاکسازی و نمایش وضعیت نهایی کافی نیست.

**اصلاح لازم:** route را normalize کنید؛ absolute URI، host، query و fragment غیرمجاز را رد کنید؛ روش HTTP را نیز allowlist کنید؛ payload را با schema مشخص و فقط فیلدهای غیرحساس validate کنید؛ برای queue storage، encryption-at-rest یا حذف صف‌بندی هر PII غیرضروری را اعمال کنید؛ max age، schema version، DLQ و ابزار مشاهده/پاکسازی بنویسید.

### P1 — SEC-KEYCHAIN-01: ادعا و رفتار iOS Keychain باید همسو شوند

فایل [`token_service.dart`](https://github.com/mahankarimi1382/ecardo_userapp_v1/blob/main/lib/src/network/service/token_service.dart#L20-L38) `KeychainAccessibility.first_unlock` را انتخاب کرده و توضیح کنار آن می‌گوید «not when locked». سیاست `AfterFirstUnlock` پس از اولین unlock پس از boot قابل دسترس می‌ماند؛ بنابراین کامنت و سطح واقعی دسترسی را باید دوباره همسو کرد.

همچنین `clearToken()` اگر حذف secure storage شکست بخورد، `false` برمی‌گرداند. تمام callerها باید این نتیجه را بررسی کنند و خروج را «موفق» اعلام نکنند، درحالی‌که token روی storage باقی مانده باشد.

**اصلاح لازم:** با تهدیدمدل محصول، سطح Keychain را انتخاب کنید (برای مثال سیاستی مبتنی بر unlock/passcode، با درنظرگرفتن نیازهای background). تست ذخیره، بارگذاری، مهاجرت، حذف موفق و حذف ناموفق در iOS و Android اضافه شود.

### P1 — CI-PRIV-01: مجوز write در job ساخت بیش از نیاز است

فایل [`flutter.yml`](https://github.com/mahankarimi1382/ecardo_userapp_v1/blob/main/.github/workflows/flutter.yml#L16-L24) برای job عمومی build، `contents: write` می‌خواهد. خود workflow این مورد را بیش‌ازحد گسترده توصیف کرده است. job build/test باید read-only باشد و فقط job انتشار روی tag یا workflow کنترل‌شده مجوز write داشته باشد.

**اصلاح لازم:** jobهای `quality`, `build`, `release`, `mirror` و `notify` از یکدیگر جدا شوند؛ برای هرکدام کمترین `permissions` تعریف شود؛ انتشار از environment حفاظت‌شده و با approval انجام شود.

### P1 — REL-DOC-01: سند release جاری stale است

`docs/README.md` به عنوان پروندهٔ رسمی release به اسناد نسخهٔ ۱٫۰٫۱۷۰ ارجاع می‌دهد، درحالی‌که release صفحهٔ GitHub نسخهٔ `v1.0.171` روی `2502823` را نشان می‌دهد. سند قبلی ادعا دارد push هنوز صورت نگرفته و release 170 آینده است؛ این ادعا اکنون تاریخی است، نه وضعیت جاری.

**اصلاح لازم:** اسناد v1.0.170 را به پوشهٔ archive نسخهٔ خودش منتقل کنید، شواهد واقعی v1.0.171 را در پروندهٔ immutable جداگانه ثبت کنید و `docs/release/CURRENT_RELEASE.md` را به مرجع واحد تبدیل کنید. تعداد تست باید از log همان run استخراج شود.

### P1 — EL-GOV-01: retention policy در دو سند متناقض است

`DATA-CLASSIFICATION.md` برای API logs مدت ۳۰ روز، security logs مدت ۹۰ روز و traces مدت ۷ روز تعیین می‌کند؛ `ELASTICSEARCH-RUNBOOK.md` برای API logs ۹۰ روز، security ۱۸۰ روز و traces ۳۰ روز را می‌نویسد. قبل از اعمال ILM این اختلاف باید رفع شود.

**اصلاح لازم:** یک جدول retention مرجع با تأیید Security, Legal/Compliance, Product owner و SRE تعریف شود. دیگر اسناد به آن ارجاع دهند؛ از کپی کردن سیاست‌های تکراری با اعداد جداگانه اجتناب شود.

### P1 — EL-EVIDENCE-01: ادعای DR/SLI باید به شواهد اجرایی متصل شود

`SNAPSHOT-RESTORE-DRILL.md` نتیجه‌ای شامل ۱۸٬۴۲۹٬۱۰۵ سند بازیابی‌شده، زمان بازیابی ۳۳ دقیقه و checksum موفق را نوشته است؛ اما در سند، شناسهٔ artifact/log، snapshot ID، cluster/build version، تاریخ/محیط دقیق و ticket قابل پیگیری مشخص نیست. همین‌طور اهدافی مانند core 99.999% و telemetry 99.0% به عنوان targets آمده‌اند، نه نتایج اندازه‌گیری.

**اصلاح لازم:** اگر تمرین واقعی بوده، evidence واقعی و redacted به سند لینک شود. در غیر این صورت جدول نتیجه با `EXAMPLE / NOT RUN` جایگزین شود. SLOها تا محاسبه از telemetry واقعی و تصویب owner فقط `proposed target` باقی بمانند.

### P1 — EL-IMPL-01: معماری Elasticsearch سند شده اما استقرار آن از مخزن اپ تأیید نمی‌شود

نسخهٔ ۱٫۰٫۱۷۱ ADR، data flow، event catalog، runbook و test plan دارد. این‌ها تصمیم و برنامه‌اند؛ در مخزن Flutter دیده‌شدن سندها اثبات نمی‌کند که backend ingest endpoint، OpenTelemetry Collector، broker، ILM policy، secret vault، private network یا cluster سلامت production آماده است.

**اصلاح لازم:** کار را به repoهای owner بک‌اند و زیرساخت توزیع کنید و برای هر سرویس evidence واقعی بنویسید: deployment SHA, config checksum, index template, ILM policy, alert rule, dashboard, privacy tests, load-test report و restore drill.

### P2 — CI-MAINT-01: اقدام‌های GitHub و runnerها باید به‌روز/قابل پیش‌بینی شوند

صفحهٔ CI هشدار مربوط به Node.js 20 و `setup-java@v4` نشان داده است؛ workflow وب نیز از `ubuntu-latest` استفاده می‌کند و runner migration نزدیک است. actionها را با بررسی compatibility به نسخه‌های پشتیبانی‌شده ارتقا دهید و runner وب را pin کنید یا migration را در branch آزمایشی اعتبارسنجی کنید.

### P2 — UX-I18N-01: کیفیت visual/UX هنوز از public source قابل تأیید نهایی نیست

وجود ۹۹ route، شش locale و تست‌های widget/golden نقطهٔ شروع خوبی است؛ اما بررسی حاضر اپ را روی device اجرا نکرده و همهٔ حالت‌ها/flowهای مالی و locale را به‌صورت بصری اجرا نکرده است. خروجی UI را فقط پس از screenshot comparison و تست کاربر نهایی تأیید کنید.

## 4. نکات مهم در اسناد Elasticsearch

- Runbook از endpointهایی مثل `serv.interex.ir:9200` و مسیر S3 شبیه محیط واقعی نام می‌برد. این آدرس‌ها و وجود certificate/secret/role باید از owner زیرساخت تأیید شوند؛ commandها را بدون تأیید روی production اجرا نکنید.
- Retention اعداد در اسناد متناقض است و باید پیش از ILM deployment حل شود.
- 5,000 req/s در تست load، هدف برنامهٔ آزمون است، نه نتیجهٔ اثبات‌شده؛ گزارش باید بار، داده، runner، نسخه، latency p95/p99، drop rate، error rate و منابع را ثبت کند.
- Elasticsearch نباید مرجع ماندهٔ حساب، دفترکل، authorization، payment finality یا KYC باشد.
- کلاینت Flutter نباید مستقیماً به ES/Kibana/OTel Collector وصل شود یا credential آن را نگهداری کند.
- privacy regexها به‌تنهایی کافی نیستند؛ schema allowlist، redaction، access control و negative tests نیز لازم‌اند.

## 5. حکم نهایی

**وضعیت نسخه:** `CI GREEN — RELEASE EVIDENCE / FINANCIAL INTEGRATION NEEDS HARDENING`.

وجود release و CI سبز مثبت است؛ ولی قبل از ادعای «آمادهٔ عرضهٔ عمومی مالی» باید P0/P1 های ثبت‌شده بسته شوند، وضعیت نتیجهٔ نامعلوم تراکنش در بک‌اند اثبات شود، release docs تصحیح شوند، و زیرساخت Elasticsearch از مستندات به سرویس واقعی با evidence قابل تکرار برسد.

**محدودیت ممیزی:** سورس را نتوانستم در این محیط clone و اجرای Flutter را مستقلاً انجام دهم؛ API زنده، بک‌اند، cluster و device واقعی را آزمایش نکردم. یافته‌های وابسته به محیط اجرا باید در staging بازتولید شوند.
