# گزارش نهایی مرحلهٔ ۱: کشف و خط مبنا (Stage 1 Discovery Summary)

- **تاریخ اجرا:** ۲۳ اکتبر ۲۰۲۶ (2026-10-23)
- **مسیر مخزن:** `C:\Users\Lenovo\Desktop\Ecardo\ecardo_userapp_v1`
- **شاخه گیت:** `main`
- **کد هش سرشاخه (Source HEAD SHA):** `dd11e5302e60`
- **نسخه اپلیکیشن (Pubspec Version):** `1.0.181+181`
- **جعبه‌ابزار و کامپایلر:** Flutter 3.44.6 (Channel stable), Dart SDK 3.12.2, Android SDK API 34
- **وضعیت Working Tree پیش از اجرا:** تمیز و همگام با کامیت `dd11e53`
- **اپراتور / هماهنگ‌کننده:** Master Integrator Agent

---

## ۱. کارنامهٔ دروازه‌های خروج (Exit Gates Evaluation)

| گیت کیفی | شرح بررسی | وضعیت | شواهد و ارجاع |
|---|---|---|---|
| **Gate 1: Integrity** | عدم اجرای دستورات مخرب، حفظ فایل‌های موجود و تفکیک مالکیت | **PASS** | Working tree سالم؛ بدون هیچ دستور `reset --hard` یا `checkout` |
| **Gate 2: Source Discovery** | اسکن کامل سورس فلاتر و استخراج تمام نمادها و روت‌ها | **PASS** | استخراج کامل توسط `scan_flutter_app.py` و `app_map_scanner.py` |
| **Gate 3: Traceability** | اتصال تمام نیازمندی‌ها، روت‌ها، کنترلرها و کدهای تست | **PASS** | `docs/app-map/TRACEABILITY_MATRIX.csv` با ۷۴۰ رکورد متصل |
| **Gate 4: Evidence Quality** | اعتبارسنجی کاتالوگ با اسکریپت‌های رسمی و عدم جعل نتایج | **PASS** | خروجی معتبر `validate_app_map.py` و `validate_route_catalog.py` |
| **Gate 5: Handoff** | تهیهٔ مستندات پایه و انتقال امن به مرحلهٔ ۲ | **PASS** | استقرار کامل اسناد در `docs/app-map/` و `docs/stage_1/` |

---

## ۲. شمارش‌های رسمی ممیزی سورس و سطوح تعاملی

| سنجه و شاخص ممیزی | مقدار استخراج‌شده | منبع و نحوهٔ استخراج |
|---|---:|---|
| کل فایل‌های سورس دارت (Dart Files Scanned) | **۹۲۱** | اسکریپت `capture_baseline.py` و `inventory_project_surfaces.py` |
| کاندیداهای مسیر ثبت‌شده (GetPage Route Declarations) | **۱۳۷** | اسکن فایل `routes_handler.dart` و `routes.dart` |
| سطوح تعاملی تاییدشده (Confirmed Accessible Surfaces) | **۷۴۰** | فایل رسمی `ROUTE_CATALOG.csv` |
| کلاس‌های ویجت شناسایی‌شده (Screen / Widget Classes) | **۷۸۹** | تحلیل نمادها در تمام پوشه `lib/` |
| فراخوانی‌های مستقیم ناوبری (Navigation Invocations) | **۶۳۱** | استخراج انواع `Get.to`, `Get.dialog`, `Get.bottomSheet`, `Navigator` |
| جریان‌های تجاری و نقشه فلوها (Business Flows Mapped) | **۱۰** | فایل `docs/uiux/FLOW_UX_COVERAGE.csv` و `BUSINESS_FLOWS.md` |
| سطوح دارای سورس مشخص (Source-Mapped Screens) | **۷۴۰** | ۱۰۰.۰٪ از کل کاتالوگ |
| روت‌های تاییدشده با اسکرین‌شات ران‌تایم (Runtime Verified) | **۲۴** | متصل به ۶۱ اسکرین‌شات دترمینیستیک PNG در `test/test_output/screens/` |
| فایل‌های تست موجود در مخزن (Automated Test Files) | **۱۰۸** | پوشه `test/` شامل ۸۶۳ مورد آزمون خودکار |
| روت‌های با کلاس نامشخص (Unknown Widgets) | **۰** | رفع کامل با تطبیق بسته‌های درون‌خطی در اسکنر |

---

## ۳. عدم انطباق‌های شناسایی‌شده و اصلاحات اعمال‌شده (Reconciliation)

1. **انطباق نسخه:** نسخه در `pubspec.yaml` روی `1.0.181+181` قرار دارد؛ تگ‌های جدید ریلز عمومی تا نسخه ۱۸۱ دریافت و همگام شدند.
2. **رفع روت‌های Unknown:** کدهای توابع `page: () { return Widget(...) }` که پیش‌تر به عنوان UnknownWidget علامت‌گذاری می‌شدند، با به‌روزرسانی رگولار اکسپرشن اسکنر به صورت کامل شناسایی و به کلاس‌های اصلی متصل شدند (`TourDetailScreen`, `EscrowDisputeScreen`, `VisaDetailScreen`).
3. **بایندینگ‌های گمشده:** روت `BaseRoute.appUpdate` فاقد بایندینگ بود که با ایجاد `AppUpdateBinding` در `app_bindings.dart` با کنترلر رسمی خود لینک شد.

---

## ۴. لیست ریسک‌های بحرانی و اقدامات اولیه (P0 / P1 Findings)

| شناسه | اولویت | عنوان ریسک | اثر بیزینسی | اقدام اصلاحی اعمال‌شده |
|---|---|---|---|---|
| **ISSUE-P0-01** | P0 | فقدان Idempotency روی متدهای PUT/PATCH و تکرار در تایم‌اوت | احتمال شارژ مجدد و برداشت دوبار وجه | تزریق کلید به تمامی متدهای جهش‌یافته و سرکوب Retry روی تایم‌اوت‌های مالی |
| **ISSUE-P0-02** | P0 | نمایش آنی شماره کارت و CVV با یک لمس ساده بدون پین | نشت اطلاعات حساس کارت کاربر | الزام احراز هویت بیومتریک/پین و ماسک‌سازی خودکار در ۱۵ ثانیه |
| **ISSUE-P0-03** | P0 | اعشار در مقادیر تومانی و ریالی | عدم تطابق حسابداری و سردرگمی کاربر | یکپارچه‌سازی تابع `isZeroDecimal` در سراسر ماژول‌ها |
| **ISSUE-P1-01** | P1 | کنتراست ضعیف متن تم تیره و سرریز دکمه‌ها | نقض استاندارد دسترسی‌پذیری و کرش چیدمان | ارتقای کنتراست به ۵.۸۶:۱ و اعمال حداقل ارتفاع ۴۸ پوینت |
| **ISSUE-P1-02** | P1 | جهت معکوس هواپیما در زبان‌های راست‌چین | تجربه کاربری ناقص در فارسی و عربی | طراحی ویجت قرینه‌ساز دوجهته `TravelFlightRouteIndicator` |

---

## ۵. آرتیفکت‌ها و مستندات مرحلهٔ ۱

- مستند خط مبنای محلی: `docs/app-map/baseline/BASELINE.json`
- گزارش اسکن سطوح و پسوندها: `docs/app-map/surfaces/PROJECT_SURFACE_REPORT.json`
- کاتالوگ جامع روت‌ها: `docs/app-map/ROUTE_CATALOG.csv`
- ماتریس صفحه و سرویس: `docs/app-map/SCREEN_SERVICE_MATRIX.csv`
- گراف ناوبری اپلیکیشن: `docs/app-map/NAVIGATION_GRAPH.mmd`
- نمایه اسکرین‌شات‌ها: `docs/app-map/SCREENSHOT_INDEX.md`
