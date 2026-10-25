# برنامهٔ استاد اجرای بستهٔ p3_uiux_backend — eCardo

- **تاریخ تنظیم:** 2026-10-24
- **مأخذ ورودی:** بستهٔ `C:/ec_packs/p3_uiux_backend/` (گوارش‌شده)، وضعیت اجرای p1/p2، حقیقت کاتالوگ (audit_registry_consistency.py + validate_screen_registry.py)، ممیزی بک‌اند برنچ `feat/uiux-v180-backend`، خط مبنا سشن جاری
- **اتصال به خط مبنا (اندازه‌گیری‌شده در همین سشن):**
  - کاربراپ: SHA `e01aed24190160d8a07352a2680de854be9a534e`، شاخهٔ `main`، `git status --porcelain | wc -l` = **32** هنگام تنظیم برنامه و **98** در بازبینی همان روز (95 modified + 3 untracked — سشن فعال در حال تغییر صفحات مالی transfer/withdraw/exchange/request_money است؛ SHA و نسخهٔ pubspec.yaml:6 = 1.0.182+182 بدون تغییر) — این عدد نوسانی است و ملاک، اندازه‌گیری روز اجراست
  - بک‌اند: SHA `04a7ec8601fff2c6a2a8ed67773ddbb6718be415`، شاخهٔ `feat/uiux-v180-backend`، dirty = **6** (`git -C ecardo-backend status --porcelain` در همین سشن: 5 فایل modified — TransferMoneyController.php، TransferMoneyService.php، AddMoneyController.php، GatewaySandbox.php، resources/views/gateway/sandbox-done.blade.php — + 1 untracked graphify-out/). ثبت اولیهٔ «dirty=1» نادرست بود و با بازبین مستقل تصحیح شد؛ عدد dirty در هر دو ریپو نوسانی است و ملاک، عدد واقعیِ روزِ اجراست (MP-002/MP-007).
  - نسخهٔ pubspec: `1.0.182+182` (فایل `ecardo_userapp_v1/pubspec.yaml`، خط version — با sed خطوط 1-8 خوانده شد)
  - گراف: `python -m graphify query "TransferScreen"` از ریشهٔ ورک‌اسپیس → خروج 0، «Graph: graphify-out/graph.json (199963 nodes) … 28 nodes found»

> **این سند فقط برنامه است.** هیچ تسکی با این سند DONE نمی‌شود؛ وضعیت واقعی فقط در `MASTER_TASK_BACKLOG.csv` هم‌بستهٔ همین سشن (همین پوشه) و با شاهد قابل بازتولید تغییر می‌کند. این فایل و CSV هم‌بسته‌اش **فایل‌های جدید**‌اند و هیچ فایل موجودی تغییر نکرده است.

---

## ۱. خلاصهٔ اجرایی

بستهٔ p3_uiux_backend یک برنامهٔ ۱۲فازی (فاز ۰ تا ۱۱) با ۶ گیت الزامی (A تا F) و ۱۲۷ تسک الگوست. این سند همان فازبندی را **با واقعیت امروز** تطبیق می‌دهد. سه واقعیت امروز که شکل برنامه را تعیین می‌کنند:

1. **مخرج کاتالوگ حل شده ولی اسناد هنوز ناسازگارند.** شمارش مستقل: ۱۳۷ Route یکتا (`grep -c 'GetPage(' lib/src/app/routes/routes_handler.dart` = 137؛ تأیید در همین سشن) در برابر ۷۴۰ ردیف رجیستری که «سطح UI» است نه Route (تفکیک در `docs/quality/registry_counts_upstream.json`: 137 GET_PAGE + 475 TAB_CHILD + 74 GET_TO + 52 BOTTOM_SHEET + 2 DIALOG = 740). اما `docs/app-map/COVERAGE_REPORT.md` هنوز درصدهایی دارد که با مخرج ۱۳۷ محاسبه و با مخرج ۷۴۰ نمایش داده شده‌اند (خطوط 18-20: 35.0% و 24.8%؛ در حالی که 48/740=6.5% و 34/740=4.6% است) و کاتالوگ‌ها همهٔ ۷۴۰ ردیف را UPGRADED/RUNTIME_VERIFIED/DONE/PASS ثبت کرده‌اند که با ادعاهای ۴۸/۳۴/۰ همان گزارش در تضاد مستقیم است.
2. **دو فلو مالی حیاتی (Transfer/Exchange) از دو سمت پیوسته اثبات شده‌اند** با نقص‌های صادقانهٔ ثبت‌شده: فیلد passcode انتقال در بک‌اند پردازش نمی‌شود و دو endpoint تاریخچهٔ اختصاصی در کلاینت بلااستفاده‌اند.
3. **زیرساخت اجرا ناقص اما کافی برای شروع است:** Flutter 3.44.6 روی `D:/ecardo-toolchain/flutter` موجود است (تأیید با `flutter --version` در همین سشن)، PHP محلی نصب نیست (تست ران‌تایم بک‌اند محلی ممکن نیست)، گراف graphify ساخته شده و کوئری فعال است، و push/release/deploy فقط با دستور صریح کاربر انجام می‌شود.

**نتیجه:** فازهای ۰ تا ۲ (حدود ۸ تا ۱۴ روز) با جزئیات تسک‌به‌تسک در بخش ۴ و CSV هم‌بسته آمادهٔ اجرای فوری‌اند؛ فازهای ۳ تا ۱۱ سطح برنامه‌اند و پس از Gate B به تفصیل باز می‌شوند. هیچ چیزی در فاز ۰ به کد محصول دست نمی‌زند؛ ریسک خراب‌کردن تغییرهای موجود (۳۲ فایل dirty) با قانون «فقط فایل جدید، بدون دستور git نوشتاری» مهار شده است.

---

## ۲. وضعیت فعلی

### ۲.۱ انجام‌شده‌های p1/p2 (مأخذ: گزارش وضعیت اجرای p1/p2 — ورودی این درخواست؛ وجود فایل‌ها در همین سشن re-verified شد)

| خروجی | مسیر | وضعیت راستی‌آزمایی این سشن |
|---|---|---|
| Baseline | `docs/app-map/baseline/BASELINE.md` + `.json` (SHA dd11e5302e60، نسخهٔ 1.0.181+181) | ✅ فایل موجود (525 خط) — اما یک نسخه عقب‌تر از pubspec فعلی 1.0.182 |
| Scan | `docs/app-map/generated/SCAN_REPORT.md` + ۵ CSV کاندید | ✅ موجود (طبق گزارش p1: 911 فایل/146 GetPage/854 ناوبری/1179 نماد) |
| کاتالوگ‌ها | `docs/app-map/ROUTE_CATALOG.csv`، `SCREEN_SERVICE_MATRIX.csv`، `TRACEABILITY_MATRIX.csv` — هرکدام ۷۴۱ خط = ۷۴۰ رکورد | ✅ wc -l = 741 برای هر دو CSV بررسی‌شده |
| Surfaces | ۷ خروجی inventory در `docs/app-map/surfaces/` | طبق گزارش p1/p2 |
| Summary | `docs/stage_1/DISCOVERY_SUMMARY.md` — 5 گیت PASS | ✅ موجود (70 خط) |
| قراردادها | `docs/integration/CONTRACT_REGISTRY.csv` — 10 قرارداد CTR-001..010 CONFIRMED | ✅ 11 خط (wc -l) |
| شواهد تست | `docs/integration/TEST_EVIDENCE.csv` — 5 رکورد PASS با SHA dd11e53 | طبق گزارش p1/p2 (اجرای مجدد flutter ممکن نبود) |
| رجیستری UI/UX | `docs/uiux/SCREEN_UPGRADE_REGISTRY.csv` — 740 سطر | ✅ 741 خط (wc -l) |
| اسکیل‌ها | 8 اسکیل p2 + 59 اسکیل در `.agents/skills/` | طبق گزارش p1/p2 |

### ۲.۲ خروجی‌های غایب (تعریف‌شده ولی هرگز تولیدنشده)

- `docs/app-map/MAP_VALIDATION.json` — **MISSING (تأیید در همین سشن با بررسی وجود فایل)**؛ مسیر دقیق تعریف‌شده در `C:/ec_packs/p1_stage1/00_READ_FIRST/PHASE_1_EXECUTION_ORDER_FA.md:56`؛ در عین حال `DISCOVERY_SUMMARY.md:21` از «خروجی معتبر validate_app_map.py» حرف می‌زند که شاهدش موجود نیست.
- `FLOW_CATALOG.csv` پرشده — فقط قالب خالی ۱خطی در `docs/stage_1/03_TEMPLATES/`؛ جانشین بخشی: `docs/app-map/BUSINESS_FLOWS.md` و `docs/uiux/FLOW_UX_COVERAGE.csv` (10 فلو).
- `GAP_REGISTER.csv` پرشده — فقط قالب خالی؛ جانشین بخشی: `docs/app-map/UNREACHABLE_AND_MISSING.md`.
- `EVIDENCE_LEDGER.csv` پرشده — فقط قالب خالی (wc -l = 1، تأیید همین سشن)؛ جانشین بخشی: `docs/integration/TEST_EVIDENCE.csv` (5 رکورد).
- `LOCAL_BASELINE.md/.json` با نام تعریف‌شدهٔ بسته — محتوا با نام دیگر (BASELINE) اجرا شده: «غایبِ نام، حاضرِ محتوا».

### ۲.۳ موارد منقضی/ناسازگار

| # | مورد | شاهد |
|---|---|---|
| S1 | `ecardo_userapp_v1/AGENTS.md:17` هنوز «1.0.41+41» می‌گوید | ✅ sed -n '17p' در همین سشن: `1.0.41+41 — آخرین ریلز عمومی: userapp-v1.0.40` در برابر pubspec `1.0.182+182` |
| S2 | `docs/stage_1/DISCOVERY_SUMMARY.md:65,66` دو مسیر شاهد غیرواقعی ارجاع می‌دهد (`LOCAL_BASELINE.json`، `SURFACES_INVENTORY.json`) | مأخذ: گزارش p1/p2 |
| S3 | `docs/uiux/BASELINE.md:4-5` روی 1.0.180/HEAD a3b6010 ایستاده (دو نسخه عقب) | مأخذ: گزارش p1/p2 |
| S4 | شمار «Runtime Verified» سه مقدار متناقض: ۲۴ (`DISCOVERY_SUMMARY.md:37`) / ۰ (`COVERAGE_REPORT.md:6`) / ۷۴۰ (ستون runtime_status همهٔ ردیف‌های ROUTE_CATALOG.csv) | ✅ COVERAGE_REPORT.md:6 خوانده شد: «Runtime Verified Surfaces: 0 (Pending Patrol…)» |
| S5 | شمارش اسکن ناسازگار: SCAN_REPORT (911/146/854/1179) در برابر DISCOVERY_SUMMARY:30-34 (921/137/631/789) | مأخذ: گزارش p1/p2 |
| S6 | ادعاهای flutter analyze/test در `docs/integration/STAGE_2_HANDOFF.md` روی این ماشین قابل راستی‌آزمایی نبود | مأخذ: گزارش p1/p2 (Flutter آن موقع نصب نبود؛ اکنون toolchain موجود است ولی تست سریال فقط توسط Integrator) |

### ۲.۴ حقیقت کاتالوگ — مغالطهٔ مخرج (حل‌شده، ولی هنوز در اسناد پخش)

- **۱۳۷ Route یکتا** (تأیید همین سشن: `grep -c 'GetPage(' lib/src/app/routes/routes_handler.dart` = 137؛ گزارش ابزارها: routes.dart دقیقاً ۱۳۷ ثابت، صفر تکرار name/path پس از نرمال‌سازی).
- **۷۴۰ ردیف = سطح UI:** `docs/quality/registry_counts_upstream.json` (خوانده‌شده در همین سشن): GET_PAGE=137، TAB_CHILD=475، GET_TO=74، BOTTOM_SHEET=52، DIALOG=2. تورم مخرج ≈ ۵.۴ برابر.
- **آشتی‌دادن ۷۳۹/۱۳۸ با ۱۳۷ (بازبین I8):** شمارش‌های `unique_route_name_count=739` و `unique_normalized_route_path_count=138` در `registry_counts_upstream.json` مربوط به ردیف‌های رجیستریِ ۷۴۰تایی است (نام SplashScreen دو بار در رجیستری؛ مسیر نرمال‌شده = ۱۳۷ مسیر BaseRoute + مقدار تحت‌اللفظی 'N/A')؛ ادعای «صفر تکرار name/path» در متن‌های ممیزی دربارهٔ ۱۳۷ تعریف GetPage در `routes_handler.dart` است، نه ردیف‌های رجیستری — دو شمارش دو منبع متفاوت‌اند. فیلد `important_limitation` همان JSON می‌گوید بدون بازبینی نگاشت route-alias هیچ‌کدام canonical اعلام نشود؛ MP-011 موظف به رفع این limitation پیش از canon اعلام‌کردن ۱۳۷ است.
- **اختلاط مخرج در COVERAGE_REPORT.md:** خط 7 ادعای 48 ارتقایافته، خط 18 جدول «48 / 740 | 35.0%» — در حالی که 48/137=35.04%؛ همین الگو برای 34 (خط 8 و 20: «34 / 740 | 24.8%» در برابر 34/137=24.82%). خود گزارش در خطوط 23-24 از «137 routes» و «89 secondary screens» (48+89=137) صحبت می‌کند.
- **تناقض وضعیت‌ها:** ROUTE_CATALOG.csv همهٔ ۷۴۰ ردیف UPGRADED/RUNTIME_VERIFIED؛ SCREEN_UPGRADE_REGISTRY.csv همهٔ ۷۴۰ ردیف DONE/PASS (validate_screen_registry.py: errors=0، ۷۴۰ هشدار «ui_status=DONE without before/after screenshot pair») در برابر ادعاهای ۴۸/۳۴/۰ گزارش پوشش. در این سشن هیچ اجرای ران‌تایم انجام نشد، پس هیچ‌کدام از سه مقدار به‌تنهایی «حقیقت ران‌تایم» نیستند؛ فقط تناقض مستند است (تسک MP-013/MP-015).

### ۲.۵ حقیقت بک‌اند — ممیزی شاخهٔ `feat/uiux-v180-backend` (SHA 04a7ec86…)

- **Transfer: BACKEND_IMPLEMENTED.** زنجیره: Route `/transfer_route` (`routes.dart:63` — تأیید همین سشن) → `routes_handler.dart:177-178` → TransferScreen → `transfer_controller.dart` با POST `/user/transfer` (بدنهٔ account_number/amount/wallet_id/passcode — خطوط 433-448، تأیید همین سشن) ↔ بک‌اند `routes/api/user.php:124` (kyc.feature:transfer + idempotency + throttle:60,1) → `TransferMoneyService::transferMoney` (:23-88) با DB::beginTransaction، lockForUpdate، دو رکورد Txn و لجر دوبل (:295-340).
- **Exchange: BACKEND_IMPLEMENTED.** Route `/exchange_route` (`routes.dart:69` — تأیید همین سشن) → POST `/user/exchange` ↔ `routes/api/user.php:157` → `ExchangeService::exchange` (:19-98) با slippage guard ±2٪ (:41-49)، validateTransactionPasscode (:108-129)، اسکوپ user_id روی UserWallet (:162-181، رفع IDOR).
- **نقص‌های صادقانه:** (۱) passcode انتقال فقط کلاینت‌ساید است؛ (۲) `/user/transfer/history` و `/user/exchange/history`+`{id}` در بک‌اند روت شده‌اند ولی کلاینت تاریخچه را از `/user/transactions?type=…` می‌خواند و ثابت‌های اختصاصی (`api_path.dart:111,123`) بلااستفاده‌اند؛ (۳) نرخ زندهٔ نمایشی از سرویس بیرونی fee.ecardo.ir می‌آید نه از `/api/user/exchange/rate`.
- **ریسک‌های امنیتی بک‌اند با شاهد (مأخذ: ممیزی بک‌اند — ورودی این درخواست):** fail-open بودن IPN بدون سکرت (`IpnController.php:45-54`)، `/status/success` فقط با decrypt (`StatusController.php:18-25` + `Payment.php:113-159` بدون تأیید درگاه)، OTP بدون throttle + ثبت تکراری `/api/pay/*` (`routes/payment.php:84-88` در برابر `api.php:238-243`)، سکرت هاردکد `InternalTravelNotifyController.php:20`، اشتراک سکرت deploy با maintenance (`MaintenanceControlController.php:34`)، GatewaySandbox که تراکنش واقعی را بدون درگاه Success می‌کند (`GatewaySandbox.php:124-163`)، `/site-cron` عمومی (`routes/web.php:37`).
- **محدودیت ممیزی:** PHP محلی نصب نیست؛ `php artisan route:list` و تست ران‌تایم اجرا نشد؛ همهٔ نگاشت‌ها کدخوانی است و تقدم روت‌های تکراری `/api/pay/*` در ران‌تایم نامعلوم ماند.
- **هشدار اعتبار استنادهای خطی (بازبین I1):** دو فایل استنادشدهٔ این بخش — `TransferMoneyService.php` و `GatewaySandbox.php` — در لحظهٔ ممیزی جزو فایل‌های dirty working tree بک‌اند بودند (اندازه‌گیری 2026-10-24: 6 مورد)؛ بنابراین تطابق شماره خط‌های §2.5 و تسک‌های MP-021/MP-112/MP-113 با SHA پین‌شدهٔ 04a7ec86 تضمین‌شده نیست. الزام: MP-007 در روز اجرا re-baseline می‌گیرد و تمام استنادهای خطی به SHA/working tree همان روز مقید می‌شوند. (استناد `Txn.php:41` = `$transaction->save();` در 2026-10-24 بازتأیید شد.)

---

## ۳. قیدهای محیطی (الزامی برای همهٔ فازها)

| # | قید | مبنا/وضعیت |
|---|---|---|
| E1 | Flutter **3.44.6 stable** روی `D:/ecardo-toolchain/flutter` موجود است | ✅ `flutter --version` در همین سشن: «Flutter 3.44.6 • channel stable» |
| E2 | **تست موازی flutter در worktree مشترک ممنوع**؛ تست جامع نهایی فقط سریال و فقط توسط Integrator | `MASTER_ROADMAP_FA.md:57`، `README_FA.md:23` |
| E3 | `analyze` فقط روی فایل‌های تحت مالکیت سشن | `MASTER_ROADMAP_FA.md:57` |
| E4 | PHP محلی نصب نیست → `php artisan route:list`، تست PHP و هر اجرای ران‌تایم بک‌اند **محلی ممکن نیست**؛ یا روی سرور اجرا شود یا به‌صورت BLOCKED با تصمیم کاربر ثبت شود | نتیجهٔ محیط این سشن |
| E5 | بک‌اند فقط محلی است (repo لوکال `../ecardo-backend`)؛ sandbox/کِردنشیل اجرایی به تصمیم کاربر | ممیزی بک‌اند |
| E6 | گراف graphify ساخته شده و کوئری فعال است؛ پیش از هر تغییر کد query/affected و پس از هر تغییر کد `python -m graphify update .` الزامی | AGENTS.md قانون ۲؛ ✅ کوئری در همین سشن exit=0 (199963 نود) |
| E7 | push/release/deploy فقط با دستور صریح کاربر | `README_FA.md:25`، `MASTER_ROADMAP_FA.md:58` |
| E8 | دستورات مخرب git (checkout/stash/reset/clean) و حذف تغییرات سشن‌های دیگر ممنوع؛ ۳۲ فایل dirty موجود باید دست‌نخورده بماند | `MASTER_ROADMAP_FA.md:56`، `README_FA.md:22` |
| E9 | فایل‌های Design System قفل‌شده (app_colors.dart, app_spacing.dart, light_theme.dart, dark_theme.dart, common/widgets/design_system/**) بدون اجازهٔ مالک تغییر نمی‌کنند | `README_FA.md:24` |
| E10 | هیچ DONE/PASS بدون شاهد قابل بازتولید (مسیر فایل + خط یا خروجی دستور) | `MASTER_ROADMAP_FA.md:49` |
| E11 | Backend truth wins؛ mock/fake/hardcoded success فقط در test/demo با build-time guard دور از production | `MASTER_ROADMAP_FA.md:53,54` |

**مأخذ فایل‌های حاکمیتی (بازبین I2):** `MASTER_ROADMAP_FA.md` و `README_FA.md` در ریپو وجود ندارند و فقط در بستهٔ p3 هستند: `C:/ec_packs/p3_uiux_backend/01_ROADMAP/MASTER_ROADMAP_FA.md` (قواعد ۱-۱۰، خطوط 49-58 — تأیید محتوا در 2026-10-24) و `C:/ec_packs/p3_uiux_backend/00_START_HERE/README_FA.md` (خطوط 20-26 — تأیید محتوا). همهٔ ارجاع‌های این سند و CSV به خطوط همین فایل‌های بسته است. همین قاعده برای سایر فایل‌های بسته‌ای (مثل `EXECUTION_GATES_FA.md` و `PHASE_1_EXECUTION_ORDER_FA.md` در p1/p3) نیز برقرار است؛ `ECARDO_HANDOFF.md` در ریپو موجود است (`ecardo_agent_toolkit/ECARDO_HANDOFF.md`، بخش ۶ در خط 108). مجری داخل ریپو یا این دو فایل حاکمیتی را به‌صورت فایل جدید در docs/quality کپی می‌کند (با ثبت مأخذ) یا مسیر بسته را در سشن در دسترس دارد.

---

## ۴. فازبندی ۰ تا ۱۱

> قرارداد برچسب‌گذاری: این برنامه فازها را **F0 تا F11** می‌نامد که یک‌به‌یک با فازهای ۰ تا ۱۱ رودمپ p3 تطبیق دارند. (بستهٔ p3 در بک‌لاگ الگوی خودش F0–F10 با دو زیرگروه F10 استفاده کرده بود؛ همین ناهماهنگیِ ثبت‌شده با این قرارداد رفع می‌شود.) جزئیات کامل هر تسک (ID، وابستگی، مالک، معیار Done، شاهد) در `MASTER_TASK_BACKLOG.csv` هم‌بسته است.

### فاز 0 — حفاظت workspace و خط مبنای واقعی (F0، ۱–۲ روز)

**هدف:** هیچ چیز خراب نشود و هر ادعای بعدی به یک خط مبنا بچسبد. اجرا: فقط خواندن/ساخت فایل جدید؛ صفر دستور git نوشتاری.

| ID | تسک | مالک | وابستگی |
|---|---|---|---|
| MP-001 | خواندن قواعد ورک‌اسپیس و مالکیت فایل‌ها (AGENTS.md قوانین ۱-۲؛ ECARDO_HANDOFF.md بخش ۶؛ AGENT_FILE_OWNERSHIP.csv) و شناسایی فایل‌های قفل DS | Coordinator | — |
| MP-002 | ثبت snapshot خط مبنا (branch/SHA/فهرست dirty/نسخه) در فایل جدید تاریخ‌دار؛ هر تغییر از پیش‌ موجود صاحب داشته باشد | Coordinator | MP-001 |
| MP-003 | یکسان‌سازی حقیقت نسخه (pubspec 1.0.182+182 در برابر AGENTS.md:17=1.0.41 و BASELINEهای 1.0.181/1.0.180) — جدول نسخه؛ بدون replace کورکورانه | Coordinator | MP-002 |
| MP-004 | استحکام حفاظت workspace: مستند دستورات ممنوع، وجود patch پشتیبان (`userapp-local-work-backup-2026-10-24.patch` در ریشهٔ ورک‌اسپیس — تأیید ls)، دیسیپلین EVIDENCE_LEDGER | Coordinator | MP-001 |
| MP-005 | راستی‌آزمایی گراف: کوئری نمونه exit=0 (199963 نود)؛ **یافتهٔ این سشن:** مسیر نودهای گراف با پیشوند `ecardo-platform/apps/ecardo_userapp_v1/...` است نه ریشهٔ فعلی ریپو — تصمیم re-extract با `--code-only` یا ثبت عدم‌تطبیق | Coordinator | MP-002 |
| MP-006 | ممیزی توانایی محیط: Flutter 3.44.6 در D:/ecardo-toolchain (تأییدشده)، نبود PHP، قواعد تست سریال/مالکیت‌دار، منع push | Coordinator | MP-002 |
| MP-007 | تأیید دسترسی بک‌اند و **re-baseline در روز اجرا**: repo محلی روی SHA 04a7ec86/برنچ feat/uiux-v180-backend (تأییدشده؛ dirty=6 در 2026-10-24: 5 modified + untracked graphify-out/) → وضعیت VERIFIED؛ ثبت عدد واقعی dirtyِ روز اجرا؛ مقیدکردن استنادهای خطی ممیزی (§2.5، MP-021/112/113) به SHA همان روز؛ صاحب credential های sandbox؛ بدون کپی سکرت در docs | Coordinator | MP-002 |
| MP-008 | **بازبینی خروج فاز 0** (پیش‌شرط Gate A) | Coordinator | MP-003..007 |

### فاز 1 — حقیقت‌سنجی کاتالوگ صفحات (F1، ۳–۵ روز)

**هدف:** یک مخرجِ واحد و قابل دفاع برای «Route» و یک مخرج جدا برای «سطح UI»، و رفع شش ناسازگاری ثبت‌شدهٔ S1–S6.

| ID | تسک | مالک | وابستگی |
|---|---|---|---|
| MP-010 | تولید `docs/app-map/MAP_VALIDATION.json` با `validate_app_map.py --out …` (غایبِ تأییدشده) | Route Catalog Auditor | MP-008 |
| MP-011 | تصویب مخرج‌های استاندارد: ۱۳۷ Route یکتا + تفکیک ۷۴۰ سطح UI (137/475/74/52/2)؛ انتشار سند COUNTS_STANDARD (فایل جدید) | Route Catalog Auditor | MP-010 |
| MP-012 | اصلاح `COVERAGE_REPORT.md` — درصدهای 35.0%/24.8% با مخرج اشتباه نمایش داده شده‌اند؛ بازانتشار با مخرج سازگار (پچ با اجازهٔ مالک یا نسخهٔ جدید) | Route Catalog Auditor | MP-011 |
| MP-013 | رفع تناقض وضعیت‌ها: UPGRADED/RUNTIME_VERIFIED/DONE/PASS روی همهٔ ۷۴۰ ردیف دو کاتالوگ در برابر ۴۸/۳۴/۰؛ تنزل به SOURCE_MAPPED/PENDING با دیسپوزیشن، بدون از دست دادن تاریخچه — **فقط با اجازهٔ مالک فایل یا با نسخهٔ جدید تاریخ‌دار** (۱۴۸۰ ردیف متعلق به سشن‌های p1/p2 است؛ E8 و ECARDO_HANDOFF.md بخش ۶) | Route Catalog Auditor | MP-011 |
| MP-014 | آشتی دادن شمارش اسکن (911/146/854/1179 در برابر 921/137/631/789) با re-scan روی SHA فعلی یا مستندسازی تفاوت دو اسکنر | Route Catalog Auditor | MP-011 |
| MP-015 | حقیقت Runtime-Verified: تعیین عدد واقعی با sweep ران‌تایم روی ۱۳۷ روت — **ابزار `tools/patrol` غایب است** (ls/find در 2026-10-24: نیست؛ ادعای COVERAGE_REPORT.md:23 بی‌شاهد بود؛ تنها `.agents/skills/patrol-native-e2e` به‌عنوان skill موجود است) → ساخت ابزار sweep یا استفادهٔ دیسپوزیشن‌دار از skill؛ منوط به backend sandbox (E4/E5) | QA Visual Integration Agent | MP-013 |
| MP-015A | اسکرین‌شات خط مبنا روی اپ واقعی (بند ۴ گیت A — بازبین I4): capture مجموعهٔ خط مبنا از صفحات کلیدی روی emulator/دستگاه در دسترس و ثبت در manifest جدید؛ اگر اجرای اپ ممکن نشد، BLOCKED با دیسپوزیشن صریح — گیت A با آن دیسپوزیشن قابل بستن است | QA Visual Integration Agent | MP-008 |
| MP-016 | پر کردن `FLOW_CATALOG.csv` (قالب خالی؛ ادغام BUSINESS_FLOWS.md + FLOW_UX_COVERAGE.csv) | Route Catalog Auditor | MP-011 |
| MP-017 | پر کردن `GAP_REGISTER.csv` (شامل یافته‌های S1-S6 و نقص‌های ۲.۵) | Route Catalog Auditor | MP-011،MP-013 |
| MP-018 | اصلاح ارجاع‌های منقضی DISCOVERY_SUMMARY.md:65-66 و تصمیم refresh دو BASELINE کهنه (S1,S2,S3) | Coordinator | MP-003 |
| MP-019 | **گیت A — حقیقت Discovery** | Coordinator | MP-010..015،MP-015A،MP-017،MP-018 |

### فاز 2 — ممیزی UI→Logic→API→Backend (F2، ۴–۷ روز)

**هدف:** برای هر قابلیت حیاتی، وضعیت واقعی (BACKEND_IMPLEMENTED / CLIENT_ONLY / MOCK_ONLY / UNKNOWN) با شاهد handler و persistence سمت سرور؛ جداسازی mock/demo از production.

| ID | تسک | مالک | وابستگی |
|---|---|---|---|
| MP-020 | تعریف شِمای ممیزی و واژگان وضعیت + قالب ردیف به‌ازای هر Route از ۱۳۷ | Backend Parity Auditor | MP-019 |
| MP-021 | ثبت ممیزی Transfer (verdict فعلی: BACKEND_IMPLEMENTED + دو gap: passcode بی‌مصرف سمت سرور، history بلااستفاده) — استنادهای خطی در روز اجرا به SHA جاری بک‌اند مقید شوند (TransferMoneyService.php جزو dirty working tree است؛ هشدار §2.5) | Backend Parity Auditor | MP-020 |
| MP-022 | ثبت ممیزی Exchange (BACKEND_IMPLEMENTED + gap: نرخ از fee.ecardo.ir، exchange/history بلااستفاده) | Backend Parity Auditor | MP-020 |
| MP-023 | ممیزی Deposit/Add-money (AddMoney/Epay/ProPay/پرداخت‌های ایرانی/IPNها/`/status/success`) | Backend Parity Auditor | MP-020 |
| MP-024 | ممیزی Withdraw (user/agent/merchant + اکشن ادمین actionNow) | Backend Parity Auditor | MP-020 |
| MP-025 | ممیزی Cards (VirtualCards + Epay cards) | Backend Parity Auditor | MP-020 |
| MP-026 | ممیزی KYC (Kyc/KycLevel + alias + promote ادمین) | Backend Parity Auditor | MP-020 |
| MP-027 | ممیزی P2P و دامنه‌های باقی‌مانده (Bill/Travel/auth/OTP/profile/notifications/support) | Backend Parity Auditor | MP-020 |
| MP-028 | جداسازی mock/demo از production (ساختار: GatewaySandbox، SandboxPayment، مسیرهای تستی) با الزام build-time guard | Backend Parity Auditor | MP-021..027 |
| MP-029 | همگام‌سازی CONTRACT_REGISTRY (schema/error/authz/idempotency هر قابلیت حیاتی؛ پشتیبانی کلاینت Idempotency-Key در network_service.dart:1156-1159 تأییدشده) | API Contract Test Agent | MP-021..024 |
| MP-030 | دیسپوزیشن passcode انتقال و endpointهای بلااستفاده (تصمیم محصول: پیاده‌سازی سمت سرور یا حذف فیلد/سیم‌کشی یا deprecate) | Coordinator + Backend Parity Auditor | MP-021،MP-022 |
| MP-031 | **گیت B — حقیقت Backend parity** | Coordinator | MP-028..030 |

### فاز 3 — سیستم طراحی واحد (F3، ۱–۲ هفته) — سطح برنامه

تبدیل ظاهر موفق Home به token های semantic و patternهای مالی قابل استفاده در کل اپ؛ Home مرجع کیفیت است نه الگوی کپی‌شدنی به هر context (قاعدهٔ `MASTER_ROADMAP_FA.md:50`). فایل‌های قفل DS فقط با اجازهٔ مالک (E9). تسک‌ها: MP-040 (inventory توکن/pattern از Home)، MP-041 (ارزیابی reuse با COMPONENT_ADOPTION_MATRIX)، MP-042 (spec توکن semantic + patternهای مالی: کارمزد، حالت نامعلوم، قالب مبالغ)، MP-043 (spec چهار صفحهٔ pilot)، MP-044 (**گیت C**). وابستگی ریشه: MP-019.

### فاز 4 — Pilot واقعی (F4، ۱ هفته) — سطح برنامه

چهار فلو مرجع با spec/screenshot/tests/امضای reviewer: MP-050 (Home/Balance)، MP-051 (Wallet Detail)، MP-052 (Transfer Review — مدیریت ایمن کارمزد و نتیجهٔ نامعلوم: timeout هیچ‌گاه success/failure قطعی فرض نمی‌شود؛ retry با Idempotency-Key)، MP-053 (Receipt — فقط status مرجع سرور)، MP-054 (تست سریال + جفت اسکرین‌شات قبل/بعد)، MP-055 (**گیت D**). وابستگی ریشه: MP-044 (+MP-029 برای قرارداد idempotency).

### فاز 5 — هستهٔ مالی (F5، ۲–۳ هفته) — سطح برنامه

فلوی end-to-end جدا برای Transfer/Exchange/Deposit/Withdraw با state machine سرور-محور: MP-060 (Transfer + idempotency/reconciliation کلاینت)، MP-061 (Exchange + قرارداد expected_rate/slippage)، MP-062 (Deposit + نمایش pending تا تأیید سرور/IPN)، MP-063 (Withdraw + وضعیت‌های ادمین)، MP-064A (**خنثی‌سازی/گیت‌کردن GatewaySandbox در محیط تست پیش از هر شواهد E2E — بازبین I7**: در غیر این صورت «موفقیتِ» ثبت‌شده می‌تواند آرتیفکت auto-success باشد)، MP-064 (سیاست واحد timeout/reconciliation + سناریوهای تست مالی بستهٔ p3)، MP-065 (شواهد E2E روی sandbox — منوط به E4/E5 و مشروط به MP-064A). وابستگی ریشه: MP-055.

### فاز 6 — Wallet/Accounts/Cards/Crypto/Activity (F6، ۲–۳ هفته) — سطح برنامه

MP-070 (حالت‌های واقعی provider: loading/empty/error برای لیست کیف‌پول‌ها)، MP-071 (کارت‌ها: issue/topup/freeze با وضعیت واقعی CardController، بدون mock success)، MP-072 (آدرس رمزارز از سرور + وضعیت IPN-محور)، MP-073 (وحدت تاریخچه: `/user/transactions?type=*` در برابر endpointهای اختصاصی — خروجی MP-030). وابستگی ریشه: MP-055.

### فاز 7 — Identity/KYC/Profile/Security/Support/Notifications (F7، ۲ هفته) — سطح برنامه

MP-080 (auth/OTP/biometric با مجوز سمت سرور)، MP-081 (KYC submit/status/history بر پایهٔ قرارداد KycLevel)، MP-082 (profile/امنیت با PII minimization)، MP-083 (support/notifications). وابستگی ریشه: MP-055.

### فاز 8 — Consistency rollout روی تمام Routeها (F8، ۳–۶ هفته؛ پس از Pilot) — سطح برنامه

مهاجرت موجی روی ۱۳۷ روت با batchهای ۵–۱۰تایی domain-محور: MP-090 (طرح batch با owner/ID/وابستگی/تست/rollback)، MP-091 (موج ۱: دامنه‌های مالی)، MP-092 (موج ۲: هویت/KYC/پروفایل/پشتیبانی)، MP-093 (موج ۳: دامنه‌های ثانویه شامل Travel/Bills)، MP-094 (ممیزی دیسپوزیشن صفحات تغییرنکرده)، MP-095 (**گیت E**). وابستگی ریشه: MP-055 و MP-013.

### فاز 9 — Localization/RTL-LTR/Accessibility/Responsive (F9، ۱–۲ هفته) — سطح برنامه

MP-100 (پوشش localeهای واقعی فلوهای checkout)، MP-101 (text scaling/semantics)، MP-102 (ماتریس responsive)، MP-103 (ماتریس اسکرین‌شات مسیرهای مالی حیاتی)، MP-104 (تکمیل ACCESSIBILITY_I18N_MATRIX). وابستگی ریشه: MP-095.

### فاز 10 — Backend contract/integration/security/resilience/observability (F10، ۲–۳ هفته) — سطح برنامه

MP-110 (contract test با sandbox — اجرای PHP منوط به E4/E5)، MP-111 (تست‌های authorization منفی — نقطهٔ شروع موجود: `tests/Feature/Api/HighRiskRoutesTest.php` در repo بک‌اند)، MP-112 (سخت‌سازی IPN: fail-open بدون سکرت، binding ضعیف mollie/perfectMoney، اعتماد به status در binance/coinremitter)، MP-113 (اصلاح `/status/success`، throttle/رفع ثبت تکراری OTP، سکرت هاردکد و اشتراک سکرت deploy، گیت GatewaySandbox، محافظت `/site-cron`)، MP-114 (راستی‌آزمایی idempotency/reconciliation سمت سرور)، MP-115 (لاگ PII-safe). تغییرات ریپوی بک‌اند فقط با تأیید کاربر و push ممنوع مگر با دستور صریح (E7). وابستگی ریشه: MP-031 و MP-065.

### فاز 11 — Regression/performance/release evidence (F11، ۱–۲ هفته) — سطح برنامه

MP-120 (تست سریال کامل توسط Integrator مقید به SHA دقیق)، MP-121 (regression تصویری + سنجه‌های performance)، MP-122 (گزارش نهایی شواهد: P0 باز = 0، parity همهٔ قابلیت‌های حیاتی معلوم، blocker/ریسک پذیرفته‌شده قابل مشاهده)، MP-123 (**گیت F** — بدون push/release/deploy بدون اجازهٔ صریح کاربر). وابستگی ریشه: MP-095 و MP-104 و MP-115.

---

## ۵. گیت‌های A تا F (معیار پذیرش)

| گیت | معیار پذیرش (مأخذ: EXECUTION_GATES_FA.md — گوارش بستهٔ p3) | تسک دروازه |
|---|---|---|
| **A — حقیقت Discovery** | Baseline SHA و tree ثبت؛ taxonomy Route/screen/surface نرمال؛ مخرج‌های شمارش درست و بازتولیدپذیر؛ screenshot baseline روی اپ واقعی (تغذیه‌کننده: **MP-015A**؛ BLOCKED-پذیر فقط با دیسپوزیشن صریح — بازبین I4)؛ دسترسی backend تأیید یا BLOCKED | MP-019 |
| **B — حقیقت Backend parity** | همهٔ قابلیت‌ها به controller/repository/API نگاشت شده؛ handler و persistence برای قابلیت‌های حیاتی؛ قرارداد schema/error/authz/idempotency مستند؛ mock/demo جدا از production | MP-031 |
| **C — تأیید Design system** | token و patternهای Home ثبت؛ کامپوننت‌های موجود ارزیابی؛ مالکیت فایل‌های قفل رعایت؛ spec چهار صفحهٔ pilot تأیید | MP-044 |
| **D — Pass شدن Pilot** | Home/Balance و Wallet Detail تأیید؛ Transfer Review کارمزد/نتیجهٔ نامعلوم را ایمن مدیریت کند؛ Receipt از status مرجع؛ screenshot قبل/بعد + تست + امضای reviewer | MP-055 |
| **E — مهاجرت batch** | هر batch دارای owner/ID/وابستگی/تست/rollback؛ هیچ DONE بدون evidence؛ صفحات تغییرنکرده ممیزی و دارای دیسپوزیشن | MP-095 |
| **F — آمادگی Release** | P0 باز = 0؛ parity برای قابلیت‌های حیاتی معلوم؛ regression کامل سریال مقید به SHA دقیق؛ blocker/ریسک پذیرفته‌شده قابل مشاهده؛ هیچ اقدام دوردست بدون تأیید کاربر | MP-123 |

---

## ۶. وابستگی‌ها و ترتیب

**ستون فقرات (بحرانی):** MP-001 → MP-002 → MP-008 → MP-010 → MP-011 → MP-013 → MP-019 (Gate A) → MP-020 → MP-021..027 → MP-028/029/030 → MP-031 (Gate B) → MP-044 (Gate C) → MP-055 (Gate D) → [F5..F7 موازی] → MP-090..095 (Gate E) → MP-100..104 → MP-110..115 → MP-123 (Gate F).

**مسیرهای موازی مجاز (با مالکیت فایل جدا و بدون تداخل سشن طبق ECARDO_HANDOFF.md بخش ۶):**
- از MP-019 به بعد: F3 (طراحی) می‌تواند با ادامهٔ F2 در دامنه‌های ثانویه هم‌زمان شود.
- از MP-055 به بعد: F5/F6/F7 سه track موازی‌اند (مالکیت: Financial Integrity / UIUX Consistency / Backend Parity).
- MP-110..115 (بک‌اند) مستقل از F9 است اما به MP-031 و تصمیم محیط اجرای PHP (E4/E5) وابسته است.

**نقاط تصمیم کاربر (مسدودهای بالقوه):** (۱) اجرای PHP/sandbox برای MP-015 و MP-110 — محلی ممکن نیست؛ (۲) دیسپوزیشن passcode و endpointهای بلااستفاده (MP-030)؛ (۳) هر push/release/deploy (E7).

---

## ۷. ریسک‌ها و مسدودها

| # | ریسک/مسدود | شاهد | اثر | کنترل |
|---|---|---|---|---|
| R1 | فایل‌های dirty کاربراپ در حال رشدند: 32 هنگام تنظیم برنامه → **98** در بازبینی همان روز (95 modified شامل صفحات مالی transfer/withdraw/exchange/request_money — سشن فعال) | `git status --porcelain | wc -l` = 32 سپس 98 (اندازه‌گیری‌های 2026-10-24) | خراب‌شدن کار موازی و جابه‌جایی مبنای استناد بین جلسات | E8؛ MP-002 صاحب هر تغییر را ثبت می‌کند؛ هر سشن پیش از شروع re-baseline بگیرد |
| R2 | کاتالوگ‌ها وضعیت‌های اثبات‌نشدهٔ DONE/PASS/RUNTIME_VERIFIED دارند و مبنای برنامه‌ریزی F8 هستند | ۲.۴ | اتکا به دادهٔ غلط | MP-013 تنزل کنترل‌شده؛ Gate A اجازهٔ F8 نمی‌دهد تا اصلاح شود |
| R3 | PHP محلی نیست → تست ران‌تایم بک‌اند و route:list ممکن نیست؛ تقدم روت‌های تکراری `/api/pay/*` نامعلوم | ۲.۵ + E4 | Gate B/F ناقص | ثبت صریح BLOCKED + اجرای سرور-محور با تصمیم کاربر (قانون ۱ AGENTS.md: اجرا روی سرور) |
| R4 | ریسک‌های امنیتی باز بک‌اند (IPN fail-open، /status/success، OTP، سکرت‌ها، sandbox، site-cron) | ۲.۵ | پول در معرض | فاز 10 (MP-112/113)؛ تا آن زمان هیچ تسکی این مسیرها را production-facing نمی‌کند — **توجه:** این کنترل فقط production-facing بودن را پوشش می‌دهد نه اعتبار شواهد تست را؛ اعتبار شواهد E2E مالی پیش از MP-064A (خنثی‌سازی GatewaySandbox در محیط تست) معتبر نیست (بازبین I7) |
| R5 | ناهماهنگی مسیر نودهای گراف با ریشهٔ ریپو (`ecardo-platform/apps/...`) | خروجی کوئری همین سشن | کوئری‌های impact ممکن است مسیر اشتباه بدهند | MP-005: تصمیم re-extract |
| R6 | ادعاهای تست p2 (analyze/test 100%) بازتولیدنشده | S6 | اعتماد کاذب به سبز بودن | E10؛ MP-120 تست سریال تازه مقید به SHA |
| R7 | Flutter از D:/ecardo-toolchain؛ وابسته به محیط/شل: در شل تنظیم‌کننده و در شل بازبین (2026-10-24) `command -v flutter` به D:/ecardo-toolchain/flutter/bin/flutter حل شد، ولی این تضمین سراسری نیست | E1 | شکست اسکریپت‌های تست در شل متفاوت | MP-006 مسیر مطلق toolchain را مستند می‌کند؛ اسکریپت‌ها مسیر مطلق به‌کار ببرند |
| R8 | تورم دامنه: ۷۴۰ سطح UI × batchهای F8 می‌تواند برنامه را منفجر کند | ۲.۴ | تأخیر فاز ۸ | batch بندی روی ۱۳۷ روت (نه ۷۴۰ ردیف) + موج‌بندی F8 |

---

## ۸. ناشناخته‌های صادقانهٔ ثبت‌شده (این سشن)

1. **هیچ اجرای runtime انجام نشد** — نه flutter run/emulator، نه PHP. پس ادعای «۰ runtime-verified» تأیید یا رد نشد؛ فقط تناقضش مستند شد.
2. **`php artisan route:list` اجرا نشد** (PHP نصب نیست)؛ تقدم روت‌های تکراری `/api/pay/*` بین `routes/api.php` و `routes/payment.php` در ران‌تایم نامعلوم است.
3. **تعداد dirty نوسانی است و ثبت اولیهٔ بک‌اند غلط بود:** کاربراپ ۲۹ (ورودی درخواست) ↔ ۳۲ (تنظیم برنامه) ↔ ۹۸ (بازبینی همان روز؛ سشن فعال روی صفحات مالی)؛ بک‌اند «۱» (ثبت اولیه) ↔ **۶** (اندازه‌گیری بازبین و این سشن: 5 modified + graphify-out/). ملاک، عددِ ثبت‌شدهٔ روز اجراست (MP-002/MP-007).
4. **ادعای `tools/patrol` در COVERAGE_REPORT.md:23 بی‌شاهد بود:** ابزار در ریپو غایب است (ls/find در 2026-10-24)؛ تنها `.agents/skills/patrol-native-e2e` به‌عنوان skill موجود است — MP-015 این را به‌عنوان آرتیفکت غایب با دیسپوزیشن ثبت می‌کند.
5. **شمار دقیق تست‌های p2 (863 تست پاس) قابل راستی‌آزمایی نبود** و در این برنامه به‌عنوان claim تلقی می‌شود تا MP-120 بازتولیدش کند.
6. **نقش‌های مالک در CSV** از هشت فایل `02_AGENT_PROMPTS` بستهٔ p3 گرفته شد (MASTER_COORDINATOR + 7 عامل تخصصی)؛ تطبیق نقش‌به-نفر با Coordinator است.
7. **ناهماهنگی F0–F10 بستهٔ p3 با فازهای ۰–۱۱ رودمپ** (F11 وجود نداشت) — با قرارداد این سند (F0..F11 یک‌به‌یک) رفع شد؛ CSV هم‌بسته از همین قرارداد استفاده می‌کند.
8. **استناد `Txn.php:41` در 2026-10-24 بازتأیید شد** (sed -n '38,44p' → خط 41 = `$transaction->save();` در `app/Facades/Txn/Txn.php` بک‌اند)؛ ولی بقیهٔ استنادهای خطی دو فایل dirty (TransferMoneyService.php، GatewaySandbox.php) باید در روز اجرا مقید به SHA شوند.
9. **اجرای مجدد کوئری گراف در شل بازبین انجام نشد**؛ ادعای «28 نود» مربوط به اجرای سشن تنظیم‌کننده است (شمار نود 199963 و پیشوند مسیرها در نمونه‌ها سازگار بودند).
