# گزارش سازگاری شمارش‌ها — Routeهای یکتا در برابر رجیستری سطوح UI

- **تاریخ ثبت:** 2026-10-24
- **ثبت‌کننده:** نویسندهٔ کاتالوگ نسخهٔ دوم (ممیزی ایستا با Python؛ بدون اجرای Flutter)
- **دامنه:** تفکیک مخرج‌های شمارش Route/سطح UI در `ecardo_userapp_v1`، توضیح گزاره‌های قبلی «48/740» و «34/740»، و ثبت تناقض‌های اثبات‌شدهٔ اسناد موجود. خروجی هم‌زمان این ممیزی: `docs/app-map/ROUTE_CATALOG_VERIFIED_2026-10-24.csv` (کاتالوگ ۱۳۷ Route یکتا).
- **کامیت مبنا:** `e01aed24190160d8a07352a2680de854be9a534e` (خوانده‌شده با `git rev-parse HEAD` در همین تاریخ؛ آخرین کامیت 2026-10-23)

> همهٔ اعداد این سند یا در همین ممیزی با پایتون از سورس و CSVها محاسبه شده‌اند (فرمان‌ها در بخش ۹) یا به خط سند ارجاع دارند. Flutter و PHP روی این ماشین نصب نیستند؛ **هیچ اجرای runtime، تست یا بیلدی انجام نشده است** (محدودیت محیط، نه انتخاب روش). هیچ فایل موجودی تغییر نکرده است؛ فقط دو فایل جدید ساخته شد.

---

## ۱. خلاصهٔ یک‌صفحه‌ای

| پرسش | پاسخ کوتاه |
|---|---|
| تعداد Route واقعی (GetPage یکتا) | **۱۳۷** — استخراج مستقل از سورس (بخش ۳) |
| تعداد ردیف رجیستری/کاتالوگ بالادستی | **۷۴۰** — مخرج «سطح UI» است نه Route (بخش ۴) |
| نسبت تورم مخرج | 740 ÷ 137 ≈ **۵٫۴ برابر** |
| گزارهٔ «48 / 740 = 35.0%» | 48/740 = **۶٫۴۹٪**؛ 48/137 = **۳۵٫۰۴٪** → درصد با مخرج ۱۳۷ محاسبه و با مخرج ۷۴۰ نمایش شده (بخش ۵٫۱) |
| گزارهٔ «34 / 740 = 24.8%» | 34/740 = **۴٫۵۹٪**؛ 34/137 = **۲۴٫۸۲٪** → همان الگو (بخش ۵٫۲) |
| مقدار `RUNTIME_VERIFIED` کاتالوگ قدیمی | بی‌شاهد: هر ۱۴۸۰ ارجاع اسکرین‌شات به فایل ناموجود اشاره می‌کند؛ پوشهٔ `evidence/` اصلاً وجود ندارد (بخش ۵٫۳) |
| وضعیت صدق‌پذیر فعلی Routeها | `SOURCE_MAPPED` برای هر ۱۳۷ مورد (نردبان p3، بخش ۷) |

---

## ۲. مخرج‌های تفکیک‌شده — تعریف بستهٔ p3 و مقادیر واقعی

ابزار مرجع شمارش، `audit_registry_consistency.py` بستهٔ p3 است که «تعداد ردیف و شناسه‌های مسیر را جدا می‌شمارد؛ route name و route path را با هم جمع نمی‌کند» (`C:/ec_packs/p3_uiux_backend/06_TOOLS/TOOLS_USAGE_FA.md:10`). این ابزار در همین ممیزی **بازاجرا شد** (بدون `--out`، فقط خروجی چاپی) و خروجی آن با فایل موجود `docs/quality/registry_counts_upstream.json` مو‌به‌مو یکسان است:

| شاخص (فیلد ابزار) | تعریف در کد ابزار | مقدار | معنای درست |
|---|---|---|---|
| `catalog_row_count` | `len(rows)` — `audit_registry_consistency.py:35` | 740 | همهٔ ردیف‌های رجیستری؛ مخرجِ «سطح UI» |
| `unique_normalized_route_path_count` | مقادیر یکتای ستون مسیر پس از نرمال‌سازی `norm_path` (`audit_registry_consistency.py:6-12` و `:36`) | 138 | ۱۳۷ مسیر واقعی + مقدار تحت‌اللفظی `'N/A'` (روی ۶۰۳ ردیف غیر-GetPage) |
| `unique_route_name_count` | مقادیر یکتای ستون `route_name` (`:37`) | 739 | این ستون در رجیستری «نام ویجت صفحه» را نگه می‌دارد (فقط `SplashScreen` دوبار آمده)؛ **شمارش ثابت‌های BaseRoute نیست** |
| `unique_screen_id_or_name_count` | مقادیر یکتای `screen_id` (`:38`) | 740 | شناسهٔ یکتای هر ردیف (صرفاً اثبات یکتایی ردیف‌ها) |
| `entity_type_row_counts` | تفکیک ستون `navigation_type` (`:40`) | GET_PAGE=137، TAB_CHILD=475، BOTTOM_SHEET=52، GET_TO=74، DIALOG=2 | تنها ۱۳۷ ردیف Route واقعی‌اند؛ بقیه تب/شیت/دیالوگ/ناوبری مستقیم‌اند |

منبع مقادیر: بازاجرای ابزار در همین ممیزی (بخش ۹، فرمان ۲) + `docs/quality/registry_counts_upstream.json:2-13`.

هشدار خود ابزار که باید رعایت شود (`audit_registry_consistency.py:41-42`؛ بازتاب در `registry_counts_upstream.json:14-15`):

1. «شمارش نام مسیر و شمارش مسیر نشانگرهای جدا هستند؛ جمعشان نکنید و بدون نگاشت alias بازبینی‌شده یکی را کانونی اعلام نکنید.»
2. «شمارش‌ها اثبات reachability، کیفیت UI، پیاده‌سازی backend، تأیید runtime یا قبولی تست نیستند.»

نکتهٔ تفکیکی مهم: `unique_route_name_count=739` ستون `route_name` رجیستری را می‌شمارد که نام ویجت است؛ شمارش مستقل ثابت‌های `BaseRoute` (ستون `route_constant`) در همین ممیزی **۱۳۷ مقدار یکتای واقعی + ۲ placeholder متنی** (۴۷۵× «N/A (Embedded/Tab)» و ۱۲۸× «N/A (Direct Navigation)») به‌دست داد — یعنی ۱۳۷ ثابت یکتا، بدون هیچ تکرار.

---

## ۳. مخرج واقعی Route = ۱۳۷ (شمارش مستقل از سورس، این ممیزی)

روش: پارسر پایتون با پرانتز متوازن روی `lib/src/app/routes/routes_handler.dart` (فهرست `List<GetPage>` از سطر ۵۰ آغاز می‌شود)، استخراج ثابت‌های `lib/src/app/routes/routes.dart` (پارس چندخطی — ۸ ثابت مقدارشان در خط بعدی است)، حل `RoutesConfig.*` از `lib/src/app/routes/routes_config.dart` (۱۱۴ عضو `static const`)، و اسکن ۸۱۱ فایل dart زیر `lib/` برای یافتن فایل تعریف هر ویجت.

| سنجه | مقدار | شاهد |
|---|---|---|
| بلوک‌های `GetPage(` در routes_handler.dart | ۱۳۷ | پارسر همین ممیزی؛ `grep -c "GetPage(" routes_handler.dart` نیز ۱۳۷ |
| ثابت‌های `static const` در routes.dart | ۱۳۷ | پارس چندخطی همین ممیزی؛ `grep -c "static const" routes.dart` نیز ۱۳۷ |
| نام Route یکتا (`BaseRoute.*`) | ۱۳۷ | صفر تکرار نام |
| مسیر خام یکتا / مسیر نرمال‌شدهٔ یکتا | ۱۳۷ / ۱۳۷ | صفر تکرار مسیر (نرمال‌سازی طبق `audit_registry_consistency.py:6-12`: حذف query/fragment، یک‌سازی اسلش‌ها، حذف اسلش انتهایی جز ریشه) |
| ثابت‌های routes.dart بی‌استفاده | ۰ | هر ۱۳۷ ثابت در handler استفاده شده است |
| ویجت صفحهٔ متمایز | ۱۳۶ | فقط `SplashScreen` روی دو Route ثبت شده است (`root` → `routes.dart:2` و `splash` → `routes.dart:4`؛ هر دو با `page: () => RoutesConfig.splash` در `routes_handler.dart:53` و `:59`) |
| تأیید source_file | ۱۳۷/۱۳۷ | فایل تعریف کلاس ویجت برای هر Route از مسیر importهای فایل ارجاع‌دهنده پیدا و وجودش روی دیسک تأیید شد؛ با ستون `source_file` کاتالوگ قدیمی نیز در هر ۱۳۷ مورد منطبق است |

نتیجه: عدد ۱۳۷ «خروجی محاسبه‌شده از روی کد» است، نه literal — دقیقاً همان الزام `C:/ec_packs/p3_uiux_backend/01_ROADMAP/MASTER_ROADMAP_FA.md:101` («فهرست 137 … را از روی کد دوباره استخراج و به صورت خروجی محاسبه‌شده بنویسید، نه literal ثابت»). هدف فاز ۱ همان بسته نیز «رفع مغالطهٔ 740 ردیف در مقابل تعداد Routeهای یکتا» بوده است (`MASTER_ROADMAP_FA.md:96`).

---

## ۴. رابطهٔ ۷۴۰ و ۱۳۷ — تفکیک نوع موجودیت

۷۴۰ ردیف رجیستری = ۱۳۷ Route واقعی + ۶۰۳ سطح غیر-Route:

| navigation_type (رجیستری) | ردیف | سهم از ۷۴۰ |
|---|---|---|
| GET_PAGE (Route واقعی) | 137 | ۱۸٫۵٪ |
| TAB_CHILD (تب داخل صفحه) | 475 | ۶۴٫۲٪ |
| GET_TO (ناوبری مستقیم بدون نام Route) | 74 | ۱۰٫۰٪ |
| BOTTOM_SHEET | 52 | ۷٫۰٪ |
| DIALOG | 2 | ۰٫۳٪ |
| **جمع** | **740** | ۱۰۰٪ |

- در رجیستری فقط ردیف‌های GET_PAGE مسیر واقعی دارند؛ هر ۶۰۳ ردیف دیگر در ستون `route_path` مقدار تحت‌اللفظی `'N/A'` دارند (شمارش همین ممیزی؛ نمونهٔ GET_TO: ردیف `SCREEN-152` با `EscrowDisputeDecisionScreen`).
- کاتالوگ قدیمی `docs/app-map/ROUTE_CATALOG.csv` (۷۴۱ خط = هدر + ۷۴۰ ردیف داده) همین سطوح را با دسته‌بندی متفاوت نگه می‌دارد: `screen_type` = SCREEN ۲۱۱ (= ۱۳۷ GetPage + ۷۴ ناوبری مستقیم)، TAB_PAGE ۴۷۵، BOTTOM_SHEET ۵۲، DIALOG ۲. مقادیر یکتای ستون مسیر آن ۱۳۹ است = ۱۳۷ مسیر واقعی + دو placeholder متنی «N/A (Embedded/Tab)» (۴۷۵ ردیف) و «N/A (Direct Navigation)» (۱۲۸ ردیف = ۷۴+۵۲+۲).
- ۱۳۷ ردیف اول کاتالوگ قدیمی دقیقاً `ROUTE-001` تا `ROUTE-137` به‌ترتیبِ ظهور در کد است و با ردیف‌های GET_PAGE رجیستری (همان شناسه‌ها، همان ترتیب ثابت‌ها، همان مسیرها) منطبق است — بررسی بیت‌به‌بیت همین ممیزی؛ شناسه‌ها در کاتالوگ جدید نیز حفظ شدند (بخش ۷).

---

## ۵. توضیح گزاره‌های قبلی گزارش پوشش

### ۵.۱ «Upgraded: 48/740 — 35.0%»

- ادعا: `docs/app-map/COVERAGE_REPORT.md:7` («Upgraded Surfaces (v1.0.181): 48 primary financial & travel screens») و `:18` («48 / 740 | **35.0%**»).
- حساب واقعی: 48/740 = **۶٫۴۹٪**. عدد نمایش‌داده‌شده فقط با مخرج ۱۳۷ به‌دست می‌آید: 48/137 = **۳۵٫۰۴٪**. یعنی درصد با مخرج Routeها محاسبه و در همان سطر با مخرج ۷۴۰ نمایش داده شده است (اختلاط مخرج).
- تناقض دوم: کاتالوگِ هم‌مبدا (`ROUTE_CATALOG.csv`) در ستون `upgrade_status` برای **هر ۷۴۰ ردیف** مقدار `UPGRADED` دارد (شمارش `csv.DictReader` همین ممیزی)؛ پس «۴۸ ارتقایافته» با کاتالوگ خود گزارش در تضاد است.

### ۵.۲ «Test Covered: 34/740 — 24.8%»

- ادعا: `COVERAGE_REPORT.md:8` و `:20` («34 / 740 | **24.8%**»).
- حساب واقعی: 34/740 = **۴٫۵۹٪**؛ 34/137 = **۲۴٫۸۲٪** → همان الگوی اختلاط مخرج.
- تناقض دوم: ابزار `validate_screen_registry.py` روی رجیستری بالادستی برای هر ۷۴۰ ردیف `test_status:PASS=740` گزارش می‌کند (خروجی بازاجرا در همین ممیزی، بخش ۹ فرمان ۳)؛ پس «۳۴ تست‌شده» با رجیستری در تضاد است. کدام‌یک درست است را فقط اجرای واقعی تست‌ها — که در این محیط ممکن نیست — می‌تواند تعیین کند.

### ۵.۳ «Runtime Verified: 0» در برابر «RUNTIME_VERIFIED × 740»

- ادعا: `COVERAGE_REPORT.md:6` و `:19` («0 / 740 | 0.0% (Requires safe sandbox backend)»).
- تناقض مستقیم: `ROUTE_CATALOG.csv` در ستون `runtime_status` برای هر ۷۴۰ ردیف مقدار `RUNTIME_VERIFIED` دارد (نمونه: ردیف‌های `ROUTE-001` و `ROUTE-002`). گزارش پوشش و کاتالوگ نمی‌توانند هم‌زمان درست باشند.
- شاهد مستقل علیه مقدار کاتالوگ: هر ۱۴۸۰ ارجاع `screenshot_before`/`screenshot_after` در `ROUTE_CATALOG.csv` (۷۴۰×۲) به فایل‌هایی زیر `evidence/` اشاره می‌کند که **هیچ‌کدام روی دیسک وجود ندارند**؛ پوشهٔ `ecardo_userapp_v1/evidence/` اصلاً ایجاد نشده است (شمارش همین ممیزی: ۱۴۸۰ ارجاع، ۱۴۸۰ ناموجود).
- در این ممیزی نیز هیچ اجرای runtime انجام نشد (Flutter نصب نیست)؛ بنابراین ادعای «صفرِ» گزارش پوشش را مستقلاً تأیید یا رد نمی‌کنیم — فقط تناقض مستند و بی‌شاهد بودن مقدار کاتالوگ ثبت می‌شود. کاتالوگ جدید به همین دلیل **هیچ** مقدار RUNTIME_VERIFIED ندارد.

### ۵.۴ «100.0%» در Discovery/Source Mapping و State Matrix

- `COVERAGE_REPORT.md:16-17` («740 / 740 | 100.0%» ×۲). این درصدها از نظر حسابی درست‌اند اما مخرجشان «سطح UI» است؛ معادل درست برای Routeها ۱۳۷/۱۳۷ است. مشکل اصلی گزارش این دو سطر نیست؛ مشکل، ادعاهای DONE/PASS/RUNTIME_VERIFIED بی‌شاهد است (بخش ۶).

### ۵.۵ گزارش خودش مخرج ۱۳۷ را می‌شناسد

- `COVERAGE_REPORT.md:23`: «execute safe UI sweeps across **all 137 routes**» و `COVERAGE_REPORT.md:24`: «Migrate **remaining 89 secondary screens**» — و ۴۸+۸۹=۱۳۷. یعنی سند درجایی از مخرج درست آگاه است و درجای دیگر از ۷۴۰ استفاده کرده است.

---

## ۶. جدول تناقض‌های اثبات‌شده

| # | گزاره | محل | شاهد مخالف | حکم |
|---|---|---|---|---|
| ۱ | ۴۸ سطح ارتقایافته | `COVERAGE_REPORT.md:7` و `:18` | `upgrade_status=UPGRADED` در هر ۷۴۰ ردیف `ROUTE_CATALOG.csv` | تناقض اثبات‌شده |
| ۲ | 35.0% = 48/740 | `COVERAGE_REPORT.md:18` | 48/740=۶٫۴۹٪؛ 48/137=۳۵٫۰۴٪ | اختلاط مخرج اثبات‌شده |
| ۳ | ۳۴ سطح تست‌شده | `COVERAGE_REPORT.md:8` و `:20` | `test_status=PASS` در هر ۷۴۰ ردیف `SCREEN_UPGRADE_REGISTRY.csv` | تناقض اثبات‌شده |
| ۴ | 24.8% = 34/740 | `COVERAGE_REPORT.md:20` | 34/740=۴٫۵۹٪؛ 34/137=۲۴٫۸۲٪ | اختلاط مخرج اثبات‌شده |
| ۵ | Runtime Verified: 0 | `COVERAGE_REPORT.md:6` و `:19` | `runtime_status=RUNTIME_VERIFIED` در هر ۷۴۰ ردیف `ROUTE_CATALOG.csv` | تناقض اثبات‌شده؛ مقدار کاتالوگ قدیمی بی‌شاهد است (۱۴۸۰ فایل اسکرین‌شات ناموجود) |
| ۶ | ui_status=DONE برای ۷۴۰ ردیف | `SCREEN_UPGRADE_REGISTRY.csv` | خروجی `validate_screen_registry.py`: ۷۴۰ هشدار «ui_status=DONE without before/after screenshot pair» (منطق هشدار: `validate_screen_registry.py:54-57`) | ادعای بی‌شاهد (هشدار ابزار p3) |

---

## ۷. کاتالوگ جدید: `docs/app-map/ROUTE_CATALOG_VERIFIED_2026-10-24.csv`

- ۱۳۷ ردیف = ۱۳۷ Route یکتای نرمال‌شده؛ ساختار ستون‌ها عیناً از قالب p3 (`C:/ec_packs/p3_uiux_backend/03_CATALOG_TEMPLATES/ROUTE_SCREEN_CATALOG_TEMPLATE.csv` سطر ۱؛ ۲۳ ستون).
- `status` همهٔ ردیف‌ها `SOURCE_MAPPED` است — طبق نردبان وضعیت استاندارد `MASTER_ROADMAP_FA.md:79` (`DISCOVERED → SOURCE_MAPPED → UI_AUDITED → CONTRACT_MAPPED → BACKEND_VERIFIED → IMPLEMENTED → TESTED → RUNTIME_VERIFIED → REVIEWED → DONE`): هر ۱۳۷ Route از کد استخراج و به فایل سورس ویجت خود نگاشت شده‌اند (بخش ۳). هیچ `DONE`، `PASS` یا `RUNTIME_VERIFIED`ای ثبت نشده است چون شاهدی برای آن‌ها وجود ندارد (بخش‌های ۵٫۳ و ۶). وضعیت‌های جانبی مجاز بسته (`BLOCKED`, `UNKNOWN`, `OUT_OF_SCOPE`, `DEPRECATED` — `MASTER_ROADMAP_FA.md:81`) نیز برای هیچ Routeای موضوعیت نداشتند.
- سیاست مقداردهی ستون‌ها (provenance):

| ستون | منبع/مبنأ | پوشش |
|---|---|---|
| `entity_id` | `ROUTE-001`…`ROUTE-137` به‌ترتیب ظهور در کد؛ با شناسهٔ ردیف‌های GET_PAGE رجیستری و ۱۳۷ ردیف اول کاتالوگ قدیمی منطبق (برابری ترتیب و مسیر بیت‌به‌بیت تأیید شد) | ۱۳۷/۱۳۷ یکتا |
| `entity_type` | `GET_PAGE` برای همهٔ ردیف‌ها (هر ۱۳۷ ردیف از جنس GetPage‌اند) | ۱۳۷/۱۳۷ |
| `route_name` | `BaseRoute.<ثابت>` از routes_handler.dart (نمونه: `BaseRoute.splash`) | ۱۳۷/۱۳۷ یکتا |
| `normalized_route_path` | مقدار ثابت در routes.dart، نرمال‌شده با قاعدهٔ ابزار p3 | ۱۳۷/۱۳۷ یکتا |
| `screen_id` / `screen_name` | کلاس ویجت صفحه (حل‌شده از routes_config.dart یا ساخت مستقیم در handler) | ۱۳۷ ردیف؛ ۱۳۶ کلاس متمایز |
| `source_file` | فایل تعریف کلاس ویجت (تأیید با اسکن ۸۱۱ فایل dart و زنجیرهٔ import) | ۱۳۷/۱۳۷؛ همه روی دیسک موجودند |
| `controller_or_state_holder` | کلاس(های) binding همان `GetPage` از routes_handler.dart (نقطهٔ ثبت controllerها؛ فهرست کامل controllerها نیست) | ۱۲۵ ردیف؛ ۱۲ Route اصلاً binding ندارند: `welcome`(:63)، `permissionsSettings`(:235)، `privacyPolicy`(:239)، `deviceSessionsSecurity`(:243)، `replayTicket`(:304)، `noInternetConnection`(:423)، `billPayment`(:428)، `getCardInfo`(:489)، `maintenanceMode`(:509)، `upgradeRequired`(:571)، `localeTransition`(:585)، `remittanceTrack`(:897) — شماره‌ها سطر routes_handler.dart |
| `owner` | بازتولید ستون `owner` کاتالوگ قدیمی (join با مسیر) — ادعای بالادستی، مستقلاً راستی‌آزمایی نشده | ۱۳۷/۱۳۷ |
| `commit_sha` / `updated_at` | HEAD گیت در زمان ممیزی / تاریخ سند | ۱۳۷/۱۳۷ |
| `domain`, `parent_shell`, `entry_points`, `scope_status`, `scope_reason`, `priority`, `test_ref`, `before_screenshot`, `after_screenshot`, `runtime_evidence`, `reviewer` | — | عمداً خالی: در این گذر ارزیابی یا شاهدی برای آن‌ها وجود ندارد |

توزیع `owner` روی ۱۳۷ Route (بازتولید از کاتالوگ قدیمی): workstream-financial ۴۲، workstream-travel ۲۲، workstream-ux ۱۷، workstream-auth ۱۶، workstream-settings ۱۵، workstream-commercial ۱۹، workstream-cards ۶.

---

## ۸. محدودیت‌ها و آنچه تأیید نشد

1. **runtime/تست:** Flutter روی این ماشین نصب نیست؛ هیچ اجرای اپ، تست Patrol/widget/unit یا بیلدی انجام نشد. ادعای «Runtime Verified: 0» (`COVERAGE_REPORT.md:6`) مستقلاً تأیید یا رد نشد؛ فقط تناقض آن با کاتالوگ قدیمی ثبت شد.
2. **۷۴۰ هشدار validate:** خروجی عین ابزار `errors=0 warnings=740` بود و همهٔ هشدارها هم‌نوع «ui_status=DONE without before/after screenshot pair»اند. ابزار فقط ۳۰۰ مورد اول را چاپ می‌کند (`validate_screen_registry.py:72-73`)؛ عدد ۷۴۰ از خط خلاصهٔ ابزار است.
3. **source_file:** انطباق ۱۳۷/۱۳۷ با کاتالوگ قدیمی فقط «فایل تعریف ویجت» را تأیید می‌کند، نه کیفیت UI، کامل بودن نگاشت سرویس/API یا رفتار صفحه.
4. **ابزارهای p3 ساختاری‌اند:** «بررسی ساختاری‌اند، نه اثبات runtime یا backend… نتیجهٔ سبز آن‌ها هیچ‌گاه جای integration test و بررسی واقعی server code را نمی‌گیرد» (`TOOLS_USAGE_FA.md:14`).
5. **owner و ستون‌های خالی:** ستون `owner` از کاتالوگ قدیمی کپی و مستقلاً راستی‌آزمایی نشده؛ ۱۱ ستون دیگر عمداً خالی مانده‌اند (بخش ۷).
6. ** گراف پروژه:** طبق قانون ۲ AGENTS.md پیش از کار، کوئری فقط‌خواندنی `python -m graphify query "…"` اجرا شد (۱۹۹٬۹۶۳ نود). چون هیچ ماژول کدی ویرایش نشد و طبق قاعدهٔ این ممیزی هیچ فایل موجودی نباید تغییر کند، از `graphify update` (که فایل‌های گراف موجود را بازمی‌نویسد) صرف‌نظر شد.

---

## ۹. فرمان‌های اجراشده (عیناً، از ریشهٔ `C:/Users/talas/OneDrive/Desktop/ecardo`)

1. `python "C:/Users/talas/AppData/Local/Temp/ecardo_v2_analyze.py"` — پارسر ۱۳۷ GetPage + تطبیق‌ها. خروجی کلیدی: `routes resolved: 137; problems: 0`؛ `unique const names: 137 … duplicate norm paths: []`؛ `unused … -> []`؛ `source_file … match=137 mismatch=0`؛ `screenshot refs: 1480; files NOT existing on disk: 1480`؛ `evidence dir exists: False`.
2. `python "C:/ec_packs/p3_uiux_backend/06_TOOLS/audit_registry_consistency.py" "ecardo_userapp_v1/docs/uiux/SCREEN_UPGRADE_REGISTRY.csv"` — بازاجرا بدون `--out` (بدون نوشتن فایل)؛ خروجی با `docs/quality/registry_counts_upstream.json` یکسان: `catalog_row_count=740`, `unique_normalized_route_path_count=138`, `unique_route_name_count=739`, `unique_screen_id_or_name_count=740`, `entity_type_row_counts={GET_PAGE:137, TAB_CHILD:475, BOTTOM_SHEET:52, GET_TO:74, DIALOG:2}`.
3. `python "C:/ec_packs/p3_uiux_backend/06_TOOLS/validate_screen_registry.py" "ecardo_userapp_v1/docs/uiux/SCREEN_UPGRADE_REGISTRY.csv" --root "ecardo_userapp_v1"` — کد خروج 0؛ خروجی: `catalog_rows=740`, `unique_selected_ids=740`, `duplicate_selected_ids=0`, `status_counts:` (accessibility/behavior/localization/responsive/state_coverage/ui_status)`DONE=740`, `status:SOURCE_MAPPED=740`, `test_status:PASS=740`, `errors=0 warnings=740`.
4. `python "C:/Users/talas/AppData/Local/Temp/ecardo_v2_build.py"` — ساخت و راستی‌آزمایی کاتالوگ جدید (خروجی کلیدی: `header matches template: True`، `data rows: 137`، `status counts: {'SOURCE_MAPPED': 137}`، `source_file missing on disk: none`).
5. `grep -c "static const" ecardo_userapp_v1/lib/src/app/routes/routes.dart` → `137` و `grep -c "GetPage(" ecardo_userapp_v1/lib/src/app/routes/routes_handler.dart` → `137`.
6. `git -C ecardo_userapp_v1 rev-parse HEAD` → `e01aed24190160d8a07352a2680de854be9a534e` (فقط خواندنی؛ طبق قواعد تکلیف هیچ دستور نوشتاری git اجرا نشد).
7. `python -m graphify query "ecardo_userapp_v1 routes GetPage routes_handler routes.dart route catalog"` — کوئری فقط‌خواندنی گراف طبق قانون ۲ AGENTS.md.

---

## ۱۰. جمع‌بندی

مخرج Routeهای یکتای این اپ **۱۳۷** است و مخرج ۷۴۰ متعلق به «سطح UI» (Route + تب + باتم‌شیت + دیالوگ + ناوبری مستقیم) است؛ استفاده از ۷۴۰ به‌عنوان مخرج درصدِ مقادیر شمرده‌شده بر حسب Route، حدود ۵٫۴ برابر تورم مخرج ایجاد می‌کند. درصدهای «35.0%» و «24.8%» در `COVERAGE_REPORT.md:18` و `:20` عملاً با مخرج ۱۳۷ محاسبه و با مخرج ۷۴۰ نمایش داده شده‌اند. کاتالوگ قدیمی و رجیستری بالادستی علاوه بر این، مقادیر `UPGRADED`/`RUNTIME_VERIFIED`/`DONE`/`PASS` را برای همهٔ ۷۴۰ ردیف ثبت کرده‌اند که با شواهد مستقل (نبودِ ۱۴۸۰ فایل اسکرین‌شات ارجاع‌شده، ۷۴۰ هشدار ابزار p3) و با خودِ ارقام گزارش پوشش در تضاد است. کاتالوگ جدید `ROUTE_CATALOG_VERIFIED_2026-10-24.csv` همین ۱۳۷ Route را با بالاترین وضعیتِ قابل‌دفاع (`SOURCE_MAPPED`) و با ارجاع خطی به سورس ثبت می‌کند.
