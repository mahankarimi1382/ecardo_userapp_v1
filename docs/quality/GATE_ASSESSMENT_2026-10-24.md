# ارزیابی گیت‌های A و B بستهٔ p3_uiux_backend — 2026-10-24

| موضوع | مقدار |
|---|---|
| تاریخ ارزیابی | 2026-10-24 |
| ارزیاب | ارزیاب گیت (سشن code-inspection؛ بدون اجرای Flutter/PHP) |
| شیء ارزیابی | گیت A — حقیقت Discovery (MP-019) و گیت B — حقیقت Backend parity (MP-031) طبق `docs/quality/MASTER_PLAN_2026-10-24.md:199-200` |
| کامیت مبنا کاربراپ | `e01aed24190160d8a07352a2680de854be9a534e` (تأیید امروز با `git rev-parse HEAD`؛ شاخه `main`؛ `git status --porcelain | wc -l` = 116 — رشد از ۲۹ مبنایی به‌دلیل کار مستند سشن‌های دیگر، ثبت‌شده در `BACKLOG_STATUS_2026-10-24.md:87`) |
| وضعیت ریپوی بک‌اند در لحظهٔ ارزیابی | HEAD فعلی **`7a1ae8a0ae0a5551da18d53f6ebb4af320a4d160`**، شاخه `feat/uiux-v180-backend`، dirty = 6 (۵ modified + untracked `graphify-out/`) — **۶ کامیت جلوتر از SHA مبنای ثبت‌شدهٔ `04a7ec86`** (جزئیات در §۱.۵) |
| روش | فقط خواندن فایل + grep/sed + git فقط‌خواندنی (rev-parse/branch/status/log/diff/merge-base) + پارس CSV با پایتون. **هیچ دستور نوشتاری git، هیچ اجرای Flutter/PHP، هیچ تغییری در ۲۹ فایل dirty یا `lib/` انجام نشد.** تنها اثر این سشن: همین فایل جدید. |

> هر ادعای این سند یا به «مسیر فایل:خط» ارجاع دارد یا به فرمانی که عیناً در همین سشن اجرا شد (فهرست در §۵). وضعیت تسک‌های MP-019 و MP-031 در `MASTER_TASK_BACKLOG.csv` توسط این ارزیابی تغییر نکرد (TODO ماندند) — امضای بستن گیت با مالک چک‌لیست است؛ این سند ورودی آن امضاست.

---

## ۰. خلاصهٔ یک‌صفحه‌ای

| گیت | حکم | یک‌خطی |
|---|---|---|
| **A — حقیقت Discovery** | ✅ **قابل بستن با دیسپوزیشن** (۴ بند PASS + ۱ بند BLOCKED با دیسپوزیشن صریحِ مجاز طبق خود معیار گیت) | خط مبنا/تاکسونومی/مخرج ۱۳۷ همگی با شاهد بازتولید شدند؛ فقط screenshot خط مبنا (MP-015A) و sweep ران‌تایم (MP-015) با دیسپوزیشن صریح BLOCKED‌اند — همان مسیری که `MASTER_PLAN_2026-10-24.md:199` برای گیت A مجاز اعلام کرده است |
| **B — حقیقت Backend parity** | ❌ **قابل بستن نیست** | نگاشت/مستندسازی قابلیت‌ها و قراردادها کامل است (code-inspection)، اما: جداسازی mock از production در کد ناقص است (GAP-007/P0 و GAP-019/P1 باز)، MP-030 منتظر تصمیم محصول است، و همهٔ تست‌های قرارداد/یکپارچگی NOT_RUN‌اند (MP-110/MP-111 بلاک روی محیط اجرای PHP) |

---

## ۱. گیت A — حقیقت Discovery (MP-019)

معیار مرجع: `MASTER_PLAN_2026-10-24.md:199` و ردیف MP-019 در `MASTER_TASK_BACKLOG.csv` (خط ۲۰ فایل؛ وضعیت TODO).

### ۱.۱ بند ۱ — Baseline SHA و tree ثبت شده؟ — **PASS**

- `docs/quality/BASELINE.md:16-21`: SHA `e01aed24190160d8a07352a2680de854be9a534e`، شاخه `main`، dirty=۲۹، نسخه `1.0.182+182` (تأیید `pubspec.yaml:6` در همین سشن: `version: 1.0.182+182`)؛ ارجاع به فهرست کامل ۲۹ فایل در `WORKSPACE_PROTECTION.md` (قاعدهٔ ۱، خط ۱۰؛ جدول ۲۹ ردیفی فایل‌های dirty).
- نسخهٔ ماشین‌خوان: `docs/quality/baseline.json:2-6`.
- راستی‌آزمایی امروز (اجرای این ارزیاب): `git rev-parse HEAD` → `e01aed24190160d8a07352a2680de854be9a534e` و `git branch --show-current` → `main` — **SHA و شاخه همچنان همان خط مبناست**؛ dirty امروز ۱۶ مورد است (اختلاف با ۲۹ مبنایی، اثر کار مستند سشن‌های دیگر همان روز است — `BACKLOG_STATUS_2026-10-24.md:87`؛ فایل‌های `docs/quality/` همگی untracked‌اند یعنی CSV/اسناد گیت جزو dirty مبنایی نبودند).
- پشتیبان: `userapp-local-work-backup-2026-10-24.patch` با ۲۹ مورد diff (`BASELINE.md:66`).

### ۱.۲ بند ۲ — taxonomy نرمال؟ — **PASS**

- استاندارد مخرج‌ها سند شد: MP-011 DONE با شاهد `docs/quality/CATALOG_COUNT_CONSISTENCY.md` (کل سند؛ خلاصهٔ §۱ در خطوط ۱۴-۲۳، تعریف تفکیک در §۲ خطوط ۲۸-۴۵).
- تفکیک مقیاس‌پذیر: ۷۴۰ ردیف رجیستری بالادستی = GET_PAGE 137 + TAB_CHILD 475 + GET_TO 74 + BOTTOM_SHEET 52 + DIALOG 2 (`docs/quality/registry_counts_upstream.json:2-13`؛ بازتولید در `CATALOG_COUNT_CONSISTENCY.md:36`).
- کاتالوگ تجدیدنظرشدهٔ ۱۳۷تایی با taxonomy سالم: `docs/quality/registry_counts.json` (خوانده‌شده در همین سشن): `catalog_row_count=137`، `unique_normalized_route_path_count=137`، `unique_route_name_count=137`، `unique_screen_id_or_name_count=136` (فقط SplashScreen روی دو روت — `CATALOG_COUNT_CONSISTENCY.md:60`)، همهٔ ردیف‌ها `SOURCE_MAPPED` (`:133`).
- آشتی‌دادن ۷۳۹/۱۳۸ رجیستری بالادستی با ۱۳۷ کاتالوگ جدید سند شده (`CATALOG_COUNT_CONSISTENCY.md:66` — بازبین I8 ممیزی قبلی) و محدودیت canonical اعلام‌کردن پیش از بازبینی alias در `registry_counts.json:9-10` ثبت است.

### ۱.۳ بند ۳ — مخرج‌ها بازتولیدپذیر (۱۳۷)؟ — **PASS (بازتولیدشده در همین سشن)**

فرمان‌های عیناً اجراشده توسط این ارزیاب (2026-10-24، از ریشهٔ `ecardo_userapp_v1`):

1. `grep -c "GetPage(" lib/src/app/routes/routes_handler.dart` → خروجی: **137**
2. `grep -c "static const" lib/src/app/routes/routes.dart` → خروجی: **137**

این همان فرمان شاهد `CATALOG_COUNT_CONSISTENCY.md:170` است که امروز عیناً همان نتیجه را داد؛ عدد ۱۳۷ literal نیست و از کد بازتولید می‌شود.

### ۱.۴ بند ۴ — screenshot خط مبنا روی اپ واقعی (MP-015A)؟ — **BLOCKED با دیسپوزیشن صریح (مجاز طبق معیار گیت)**

- وضعیت MP-015A در `MASTER_TASK_BACKLOG.csv` (ردیف ۱۶ فایل): **BLOCKED**.
- دلیل ثبت‌شده (`BACKLOG_STATUS_2026-10-24.md:63`): «دستگاه موبایل/امولاتور اندروید فعال نیست و دسترسی staging/sandbox نداریم — فقط desktop/windows و مرورگر موجود است؛ اسکرین‌شات خط مبنا روی اپ واقعی ممکن نشد.»
- خود معیار گیت A این بند را «BLOCKED-پذیر فقط با دیسپوزیشن صریح» تعریف کرده (`MASTER_PLAN_2026-10-24.md:199`؛ هم‌نظر با شرح تسک MP-015A در همان فایل خط ۱۳۲ و ردیف CSV: «گیت A با این دیسپوزیشن قابل بستن است؛ هیچ ادعای captured بدون فایل تصویری نیست»).
- مرتبط: MP-015 (sweep ران‌تایم ۱۳۷ روت) نیز BLOCKED — ابزار `tools/patrol` در ریپو غایب است؛ غیبت در شرح خود تسک CSV ثبت شده و تنها `.agents/skills/patrol-native-e2e` موجود است (`BACKLOG_STATUS_2026-10-24.md:62`). **هیچ عدد Runtime-Verified بدون اجرا درج نشده است** — کاتالوگ تجدیدنظرشده همهٔ ۱۳۷ ردیف را `SOURCE_MAPPED` ثبت کرده (`CATALOG_COUNT_CONSISTENCY.md:133`).

### ۱.۵ بند ۵ — دسترسی بک‌اند (✅ محلی)؟ — **PASS (VERIFIED محلی) با یک هشدار رانش SHA**

- MP-007 DONE با شاهد `BASELINE.md:28` (repo `ecardo-backend`، SHA `04a7ec8601fff2c6a2a8ed67773ddbb6718be415`، شاخه `feat/uiux-v180-backend`).
- راستی‌آزمایی امروز (اجرای این ارزیاب): repo محلی در `ecardo/ecardo-backend` قابل خواندن است؛ `git branch --show-current` → `feat/uiux-v180-backend`؛ dirty=6 (۵ فایل modified — `AddMoneyController.php`، `TransferMoneyController.php`، `GatewaySandbox.php`، `TransferMoneyService.php`، `resources/views/gateway/sandbox-done.blade.php` — + untracked `graphify-out/`)؛ عین ۶ مورد ثبت‌شده در `MASTER_PLAN_2026-10-24.md:7`.
- **هشدار رانش SHA (یافتهٔ جدید این ارزیابی):** HEAD فعلی بک‌اند `7a1ae8a0ae0a5551da18d53f6ebb4af320a4d160` است — ۶ کامیت جلوتر از SHA مبنای `04a7ec86` (`git rev-list --count 04a7ec86..HEAD` → 6؛ همه در 2026-10-24 بین ۱۲:۱۶ تا ۱۴:۴۰ +0330 با امضای agent-financial-ui-rtl: `512b3a9`، `3baa8f3`، `1c1180d`، `44e749a`، `b30e8d2`، `7a1ae8a` — موضوع: provision کیف پیش‌فرض در ثبت‌نام، backfill، repair ledger، ops:check). SHA مبنا ancestorِ HEAD است (merge-base تأیید شد). فایل‌های تغییریافتهٔ این ۶ کامیت (`git diff --stat 04a7ec86..HEAD`): `RegisterController.php`، `WalletController.php`، `WalletResource.php`، `LedgerService.php`، + ۳ کامند جدید در `app/Console/Commands/` — **هیچ‌کدام از ۵ فایل dirty بالا و هیچ‌کدام از فایل‌های استنادی §۳/§۴ ممیزی Transfer/Exchange نیستند**؛ اما استنادهای خطی ممیزی به `04a7ec86` پین شده‌اند (`CAPABILITY_STATUS.md:7,42,68,97`) و طبق قاعدهٔ MP-007 (`MASTER_PLAN_2026-10-24.md:117`) و هشدار I1 (`:77`)، بستن گیت باید این رانش را ثبت کند. این ارزیابی ثبتش کرد؛ تصمیم re-pin به SHA روز اجرا با مالک گیت است (سؤال باز ۴ در §۴).

### حکم گیت A

**قابل بستن.** چهار بند اول با شاهد قابل بازتولید بسته شده‌اند و بند screenshot دقیقاً از مسیر دیسپوزیشنی‌ای بسته می‌شود که خود معیار گیت (`MASTER_PLAN_2026-10-24.md:199`) و شرح MP-015A (`:132` و ردیف CSV) صریحاً مجاز اعلام کرده‌اند. پیش‌نیاز شکلی باقی‌مانده: امضای چک‌لیست MP-019 توسط مالک آن (Coordinator) — وضعیت CSV هنوز TODO است و این سند ورودی آن امضاست. یادآوری: MP-008 (چک‌لیست خروج فاز ۰) نیز TODO است (`BACKLOG_STATUS_2026-10-24.md:74`) و پیش‌شرط شکلی MP-019 به‌شمار می‌رود.

---

## ۲. گیت B — حقیقت Backend parity (MP-031)

معیار مرجع: `MASTER_PLAN_2026-10-24.md:200` و ردیف MP-031 در `MASTER_TASK_BACKLOG.csv` (خط ۳۲ فایل؛ وضعیت TODO). ورودی‌های دامنه‌ای طبق اعلان تسک: ممیزی‌های MP-023 (واریز، ۱۵ verdict)، MP-024 (برداشت، ۱۰)، MP-025 (کارت‌ها + تأیید متقاطع، ۱۸)، MP-026 (KYC، ۶)، MP-027 (P2P و باقی، ۶) — جمع ۵۵ verdict اعلانی؛ به‌علاوه ۵ راستی‌آزمایی امنیتی مستقل (SEC-1..SEC-5).

### ۲.۱ بند ۱ — همهٔ قابلیت‌ها نگاشت شده‌اند؟ — **PASS (در سطح قابلیت؛ code-inspection)**

- `docs/backend-audit/FEATURE_BACKEND_COVERAGE.csv`: **۱۰۹ ردیف داده** (wc -l = 110 با هدر؛ پارس پایتون همین سشن) با تفکیک دامنه: TRF 5، EXC 7، DEP 43، WDR 17، CRD 21، KYC 9، P2P 1، BIL 1، TRV 2، AUT 1، PRF 1، NTF 1. ستون‌های هر ردیف شامل controller/repository/api_path/server_handler/authz_rule/persistence است (هدر CSV خوانده‌شده در همین سشن).
- جدول‌های verdict دامنه‌ای در `docs/backend-audit/CAPABILITY_STATUS.md` §۷: §۷.۱ Deposit = ۱۵ ردیف (خطوط 127-143)، §۷.۲ Withdraw = ۱۰ ردیف (147-158)، §۷.۳ Cards = ۱۳ ردیف (162-176)، §۷.۴ KYC = ۶ ردیف (180-187)، §۷.۵ P2P/باقی = ۶ ردیف (191-198).
- **نکتهٔ صادقانهٔ تطابق اعداد:** اعلان تسک برای ممیزی کارت‌ها ۱۸ verdict گفته است؛ جدول ادغامی §۷.۳ سیزده ردیف دارد که ردیف ۱۲ آن (خط ۱۷۵) جمع‌بند تأییدهای متقاطع دامنه‌های AddMoney/Withdraw/KYC/P2P/Bill/auth است. یعنی ۱۸→۱۳ در ادغام فشرده شده است؛ تفکیک عددی ۱۸ از مواد خام ممیز در این ارزیابی جداگانه بازتولید نشد (فقط جمع ردیف‌های ادغامی = ۵۰ در برابر جمع اعلانی ۵۵). تضاد محتوایی نیست؛ اختلاف سطح تجمیع است و ثبت شد.
- دامنهٔ Travel اپ موبایل صریحاً `API_DECLARED_ONLY` ثبت شده (سرویس جدای trip.ecardo.ir خارج از ecardo-backend — `CAPABILITY_STATUS.md:176`).

### ۲.۲ بند ۲ — handler/persistence برای قابلیت‌های حیاتی؟ — **PASS (کدخوانی؛ بدون اجرا)**

- Transfer: `TransferMoneyService::transferMoney` 23-88 با beginTransaction/lockForUpdate/commit-rollback و لجر دوبل 295-340؛ persistence با `Txn.php:41` (`$transaction->save();` — بازتأیید 2026-10-24 طبق `MASTER_PLAN_2026-10-24.md:245`) — `CAPABILITY_STATUS.md:40,47-48`.
- Exchange: `ExchangeService::exchange` 19-98 با تراکنش DB، slippage guard 41-49، passcode سرور 108-129، اسکوپ user_id کیف‌ها 162-181 — `CAPABILITY_STATUS.md:66,73`.
- Withdraw: `WithdrawController.php:25` (Validator :40-43؛ اسکوپ مالکیت :52-53؛ Transaction :125) — `CAPABILITY_STATUS.md:149`.
- Deposit/Add-money: `AddMoneyController.php:16-43` → `AddMoneyService.php:24-191` — `CAPABILITY_STATUS.md:130-131`.
- محدودیت ثبت‌شده در خود سند ممیزی: **code-inspection است؛ هیچ sandbox/E2E اجرا نشد** (`CAPABILITY_STATUS.md:6`) و ستون‌های تست در CSVها همه `NOT_RUN`‌اند (تأیید پارس پایتون: ۲۷/۲۷ ردیف قرارداد `contract_test_ref = NOT_RUN — code-inspection`).

### ۲.۳ بند ۳ — قرارداد schema/error/authz/idempotency مستند؟ — **PASS (مستندسازی؛ تست‌ها NOT_RUN)**

- `docs/backend-audit/API_CONTRACT_REGISTER.csv`: **۲۷ ردیف داده** (wc -l = 28) با ستون‌های `request_schema_ref`، `response_schema_ref`، `success_codes`، `error_codes`، `auth_required`، `roles_or_ownership`، `idempotency_policy`، `retry_policy`، `rate_limit` (هدر خوانده‌شده در همین سشن).
- نمونه‌های راستی‌آزمایی‌شده با پارس پایتون (این سشن): `C-TRF-003` (POST /api/user/transfer) و `C-EXC-004` (POST /api/user/exchange) و `C-WDR-001` (POST /api/user/withdraw) همگی «middleware idempotency (لاراول) + هدر Idempotency-Key/X-Idempotency-Key» ثبت شده‌اند؛ `C-DEP-002` (POST /api/user/add-money) صادقانه «middleware ندارد روی store» ثبت شده است. authz هر ردیف با مسیر:خط سند شده (نمونه: `TransferMoneyService.php:415-423` برای مالکیت wallet_id در C-TRF-003).
- پشتیبان سمت کلاینت: هدر Idempotency-Key در `network_service.dart:1156-1159` (`MASTER_PLAN_2026-10-24.md:153`).
- `docs/integration/CONTRACT_REGISTRY.csv` به‌روزرسانی MP-029 (ویرایش جراحی ۴ ردیف + ۳ ردیف جدید — `CAPABILITY_STATUS.md:225`؛ امروز ۱۴ خط = هدر + ۱۳ ردیف تأیید شد).
- **محدودیت:** مستندسازی قرارداد فقط با کدخوانی است؛ اجرای contract test روی sandbox انجام نشده (MP-110 BLOCKED — §۳).

### ۲.۴ بند ۴ — mock از production جدا؟ — **FAIL به‌مثابه جداسازی فیزیکی (نگاشت/مستندسازی: PASS)**

- نگاشت کامل مسیرهای mock/sandbox انجام شد: ۶۳ ارجاع mock/sandbox در `FEATURE_BACKEND_COVERAGE.csv` (grep -ci امروز: 63؛ هم‌عدد ادعای `BACKLOG_STATUS_2026-10-24.md:55`)؛ ساختار GatewaySandbox/SandboxPayment در ممیزی MP-028 سند شده (`CAPABILITY_STATUS.md:123`).
- **اما جداسازی واقعی در کد ناقص است و گپ‌های باز دارد:**
  1. **GAP-007 (P0)** — GatewaySandbox تراکنش واقعی را بدون درگاه Success می‌کند؛ گیت فقط setting + token است (`BACKEND_GAPS.csv` ردیف GAP-007 — بازخوانی پایتون همین سشن؛ وضعیت OPEN — CONFIRMED_IN_CODE).
  2. **GAP-019 (P1)** — `ChinaPaymentController` صفحهٔ شبیه‌سازی پرداخت است و برخلاف test-payment **گارد env ندارد** (`CAPABILITY_STATUS.md:142`؛ ردیف GAP-019 با dependencies=MP-028 — بازخوانی همین سشن)؛ الزام build-time guard (قید E11، `MASTER_PLAN_2026-10-24.md:95`) پیاده نشده و تسک‌های اصلاحی آن (MP-112/MP-113) TODO هستند.
  3. MelliTxn mode=test (`MelliTxn.php:58-66` — `CAPABILITY_STATUS.md:142`).
- بنابراین این بند در معیار «mock/demo جدا از production» فقط در مؤلفهٔ «شناخت و نگاشت» بسته است؛ در مؤلفهٔ «جدا بودن مؤثر» باز است و مسدودکنندهٔ گیت B است.

### ۲.۵ بند الحاقی معیار CSV — «آمار پوشش وضعیت‌های ۱۳۷ روت ثبت شده»؟ — **ناقص (PARTIAL)**

معیار MP-031 در `MASTER_TASK_BACKLOG.csv` علاوه بر چهار بند ask، «آمار پوشش وضعیت‌های ۱۳۷ روت» را هم می‌خواهد. موجود: آمار سطح قابلیت (§۲.۱ بالا) و وضعیت یکنواخت `SOURCE_MAPPED` برای ۱۳۷ روت در کاتالوگ (`CATALOG_COUNT_CONSISTENCY.md:133`)؛ اما یک جدول تجمیعی «per-route parity status» که هر یک از ۱۳۷ روت را به verdict قابلیت/دامنهٔ متصلش مقید کند، در هیچ آرتیفکتی یافت نشد (جستجوی همین سشن در `docs/backend-audit/` و `docs/quality/`). ثبت شد به‌عنوان نقیصهٔ شکلی قابل ترمیم در ادغام بعدی.

### حکم گیت B

**قابل بستن نیست.** بند ۴ (جداسازی mock) به‌مثابه واقعیت کد باز است (GAP-007/GAP-019؛ گارد build-time پیاده نشده)، MP-030 (دیسپوزیشن passcode و endpointهای بلااستفاده) BLOCKED روی تصمیم محصول است، و صحت اجرایی قراردادها هنوز تست نشده (MP-110/MP-111 BLOCKED). این حکم هم‌راستا با یادداشت پیشین کتابدار backlog است: «MP-031 (گیت B) به‌دلیل BLOCKED بودن MP-030 بسته نمی‌شود» (`BACKLOG_STATUS_2026-10-24.md:74`) — این ارزیابی علاوه بر MP-030، GAP-007/GAP-019 و NOT_RUN بودن تست‌ها را نیز مسدودکننده ثبت می‌کند.

---

## ۳. مسدودکننده‌های گیت B (فهرست صریح)

1. **MP-030 BLOCKED (ورودی انسانی):** تصمیم محصول دربارهٔ passcode انتقال (پیاده‌سازی سمت سرور در برابر حذف فیلد کلاینت) و سیم‌کشی/deprecate ثابت‌های بلااستفادهٔ `api_path.dart:111,123` و مصرف `/user/exchange/rate` — مواد تصمیم آماده است (`CAPABILITY_STATUS.md:59-60,84,89`)؛ ثبت‌شده در `BACKLOG_STATUS_2026-10-24.md:64` و ردیف CSV MP-030.
2. **جداسازی mock/production ناقص:** GAP-007 (P0) و GAP-019 (P1) باز؛ build-time guard قید E11 پیاده نشده؛ اصلاح نیازمند مجوز اجرای فیکس‌های MP-112/MP-113 روی بک‌اند است (هر دو TODO در CSV).
3. **تست‌های قرارداد/یکپارچگی/امنیتی همه NOT_RUN:** MP-110 و MP-111 BLOCKED روی محیط اجرای PHP روی سرور (قانون ۱ `AGENTS.md` ریشه — سرویس‌دهی روی PC شخصی ممنوع؛ PHP محلی نصب نیست — `BASELINE.md:57`). تقدم ران‌تایم روت‌های تکراری `/api/pay/*` نیز فقط با `php artisan route:list` روی سرور تعیین‌پذیر است (`SECURITY_CONFIRMATIONS_2026-10-24.md:57`، SEC-4).
4. **(نقص شکلی)** آمار per-route parity برای ۱۳۷ روت هنوز به‌صورت جدول تجمیعی ثبت نشده (§۲.۵).

---

## ۴. سؤالات باز برای صاحب پروژه

1. **MP-030 — تصمیم passcode:** passcode انتقال سمت سرور پیاده شود یا فیلد کلاینت حذف شود؟ ثابت‌های بلااستفادهٔ `api_path.dart:111,123` سیم‌کشی یا deprecate شوند؟ `/user/exchange/rate` جای fee.ecardo.ir را بگیرد؟ (مواد: `CAPABILITY_STATUS.md:59-60,84,89`؛ گپ‌های متناظر در `docs/app-map/GAP_REGISTER.csv`.)
2. **مجوز اجرای فیکس‌های MP-112/MP-113 روی بک‌اند:** hardening IPN (SEC-2/SEC-3)، اصلاح `/status/success` (SEC-1)، throttle/رفع ثبت تکراری OTP (SEC-4)، گیت‌کردن GatewaySandbox و گارد env برای ChinaPayment (GAP-007/GAP-019)، محافظت `/site-cron` — تغییر ریپوی بک‌اند فقط با تأیید صریح شما (E7، `MASTER_PLAN_2026-10-24.md:91`).
3. **فراهم‌سازی sandbox برای MP-110/MP-111 (و پیش‌نیاز MP-015/MP-015A):** محیط اجرای PHP روی سرور (serv.interex.ir / 192.168.100.65 طبق قانون ۱ `AGENTS.md`) + credential بدون کپی سکرت در docs (قاعدهٔ MP-007).
4. **تصمیم re-pin رانش SHA بک‌اند:** خط مبنا `04a7ec86` را نگه داریم یا به HEAD فعلی `7a1ae8a0` (۶ کامیت agent-financial-ui-rtl در 2026-10-24) re-baseline شود؟ استنادهای خطی ممیزی (§۳/§۴ `CAPABILITY_STATUS.md`) به SHA پین‌شده مقیدند.
5. **MP-015A:** دستگاه/امولاتور اندروید یا staging فراهم شود، یا دیسپوزیشن BLOCKED فعلی رسماً پذیرفته و بند ۴ گیت A با همان بسته شود؟

---

## ۵. فرمان‌های عیناً اجراشده در این ارزیابی (همه فقط-خواندنی)

از ریشهٔ `ecardo_userapp_v1` مگر خلافش ذکر شود:

1. `grep -c "GetPage(" lib/src/app/routes/routes_handler.dart` → **137**
2. `grep -c "static const" lib/src/app/routes/routes.dart` → **137**
3. `sed -n '6p' pubspec.yaml` → `version: 1.0.182+182`
4. `git rev-parse HEAD` → `e01aed24190160d8a07352a2680de854be9a534e`؛ `git branch --show-current` → `main`؛ `git status --porcelain | wc -l` → **116**
5. در `ecardo-backend`: `git rev-parse HEAD` → `7a1ae8a0ae0a5551da18d53f6ebb4af320a4d160`؛ `git branch --show-current` → `feat/uiux-v180-backend`؛ `git status --porcelain | wc -l` → **6**؛ `git status --porcelain` (فهرست ۵ فایل + graphify-out/)
6. `git rev-list --count 04a7ec8601fff2c6a2a8ed67773ddbb6718be415..HEAD` → **6**؛ `git log --format=…` همان بازه (۶ کامیت فهرست‌شده در §۱.۵)؛ `git merge-base --is-ancestor 04a7ec86… HEAD` → true؛ `git diff --stat 04a7ec86..HEAD` (۷ فایل: RegisterController، WalletController، WalletResource، LedgerService، + ۳ کامند جدید)
7. `wc -l` روی CSVها: `MASTER_TASK_BACKLOG.csv` = 79 (۷۸ ردیف داده)؛ `FEATURE_BACKEND_COVERAGE.csv` = 110؛ `API_CONTRACT_REGISTER.csv` = 28؛ `BACKEND_GAPS.csv` = 58؛ `GAP_REGISTER.csv` = 16؛ `FLOW_CATALOG.csv` = 18؛ `CONTRACT_REGISTRY.csv` = 14
8. پارس پایتون `csv.DictReader`: وضعیت backlog → `{'DONE': 25, 'TODO': 48, 'BLOCKED': 5}`؛ MP-110/111/015/015A/030 = BLOCKED و MP-112/113/008/019/031 = TODO؛ تفکیک دامنهٔ ۱۰۹ ردیف coverage (§۲.۱)؛ ۲۷ ردیف قرارداد با `contract_test_ref` و `status` یکنواخت NOT_RUN/DOCUMENTED؛ ردیف‌های GAP-007/GAP-019
9. `grep -c -i "mock\|sandbox" FEATURE_BACKEND_COVERAGE.csv` → **63**
10. `sed -n '16,24p' docs/app-map/COVERAGE_REPORT.md` (درصدها با مخرج ۱۳۷ + توضیح تجزیهٔ ۷۴۰)؛ `sed -n '63,67p' docs/stage_1/DISCOVERY_SUMMARY.md` (ارجاع‌های اصلاح‌شده)؛ `ls -la docs/app-map/MAP_VALIDATION.json` → 633,978 بایت

## ۶. یادداشت‌های صداقت

- این ارزیابی code-inspection است؛ هیچ Flutter/PHP/تست اجرا نشد (ممنوعیت تست/اجرای موازی رعایت شد). صحت اجرایی کدهای بک‌اند در این سشن اثبات‌نشده و فقط استناد کدخوانی ممیزی‌های قبلی بازتاب داده شده است.
- عدد ۱۸ verdict ممیزی کارت‌ها (اعلان تسک) در جدول ادغامی §۷.۳ به ۱۳ ردیف فشرده شده؛ بازتولید تفکیک ۱۸ از مواد خام در این سشن انجام نشد (§۲.۱).
- تطابق بیت‌به‌بیت فهرست ۲۹ فایل dirty فعلی با جدول `WORKSPACE_PROTECTION.md` جداگانه راستی‌آزمایی نشد (dirty امروز ۱۱۶ است؛ تحلیل تفاضل خارج از دامنهٔ این ارزیابی بود).
- تنها اثر دیسکی این سشن همین فایل جدید است؛ هیچ فایل ردیابی‌شده، فایل dirty بالادستی، یا فایلی در `lib/` تغییر نکرد؛ هیچ دستور git نوشتاری اجرا نشد.
