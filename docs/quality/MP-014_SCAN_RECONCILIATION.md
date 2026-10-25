# MP-014 — آشتی‌دهی شمارش‌های SCAN_REPORT.md با DISCOVERY_SUMMARY.md و اعداد تأییدشدهٔ 2026-10-24

- **تاریخ ثبت:** 2026-10-24
- **ثبت‌کننده:** اعتبارسنج app-map (سشن code-inspection؛ **بدون اجرای Flutter** — ممنوعیت تست/اجرای موازی رعایت شد)
- **تسک:** MP-014 طبق `docs/quality/MASTER_TASK_BACKLOG.csv:14` و `docs/quality/MASTER_PLAN_2026-10-24.md:130` — «آشتی دادن شمارش اسکن: SCAN_REPORT.md (911/146/854/1179) در برابر DISCOVERY_SUMMARY.md:30-34 (921/137/631/789)»
- **مسیر پذیرش انتخابی:** گزینهٔ دوم پذیرش تسک («مستندسازی تفاوت دو اسکنر») + بازشماری مستقل فقط‌خواندنی روی درخت فعلی. اسکنر **دوباره اجرا نشد** چون نوشتنِ مجدد فایل‌های ردیابی‌شدهٔ `docs/app-map/generated/` بدون مجوز تسک، نقض قاعدهٔ حفاظت فایل‌های بالادستی است؛ منطق اسکنر عیناً در حافظه بازسازی و شمارش شد (فرمان‌ها در بخش ۱۰).
- **تغییر فایل‌ها:** هیچ فایل موجودی تغییر نکرد. فقط دو فایل جدید در همین سشن ساخته شد: همین سند و خروجی MP-010 در `docs/app-map/MAP_VALIDATION.json`.
- **گیت:** هیچ دستور نوشتاری git اجرا نشد (قاعدهٔ تسک).
- **گراف (AGENTS.md قانون ۲):** پیش از کار، کوئری فقط‌خواندنی `python -m graphify query "ecardo_userapp_v1 docs app-map ROUTE_CATALOG validate_app_map MAP_VALIDATION scan report"` اجرا شد (۲۰۰٬۰۵۶ نود؛ ۴٬۵۷۵ نتیجه). چون هیچ فایل کدی ویرایش نشد و خروجی‌ها فقط دو سند جدیدند، از `graphify update` صرف‌نظر شد (رویهٔ مشابه و مستند: `docs/quality/CATALOG_COUNT_CONSISTENCY.md:160`).

---

## ۱. خلاصهٔ یک‌صفحه‌ای

| پرسش | پاسخ کوتاه |
|---|---|
| آیا ۹۱۱/۱۴۶/۸۵۴/۱۱۷۹ با ۹۲۱/۱۳۷/۶۳۱/۷۸۹ **تناقض** دارند؟ | **نه — هیچ‌یک.** هر چهار تفاوت با زمانِ اسنپ‌شات، دامنهٔ اسکن، مجموعهٔ متدهای regex و جنس موجودیت آشتی داده شد؛ خطای شمارشی در هیچ‌کدام یافت نشد |
| چرا ۹۱۱ در برابر ۹۲۱؟ | اسکنر stage_۱ در زمان خودش ۱۰ فایل dart کمتر دیده است؛ بازشماری امروز با عین قواعد همان اسکنر روی درخت فعلی = **۹۲۱** |
| چرا ۱۴۶ در برابر ۱۳۷؟ | ۱۴۶ = ۱۳۷ روت واقعی در `routes_handler.dart` + ۹ کاندیدای غیر-روت (۱ `unknownRoute` در `app.dart:72` + ۸ GetPage داربستِ تست در دو فایل `test/`) |
| چرا ۸۵۴ در برابر ۶۳۱؟ | دو مجموعه-متد متفاوت: شمارشِ ۸۵۴ شامل `Get.back`×۳۰۷ و `Navigator.pop`×۷۱ است و دیالوگ/شیت را نمی‌شمارد؛ شمارشِ ۶۳۱ برعکس (دیالوگ/شیت بله، back/pop خیر) و فقط روی `lib/` است |
| چرا ۱۱۷۹ در برابر ۷۸۹؟ | ۱۱۷۹ = همهٔ کاندیداهای نماد (ویجت/کنترلر/سرویس/مدل) در کل مخزن؛ ۷۸۹ = فقط کلاس‌های ویجت در `lib/` |
| عدد مرجع Routeهای یکتا | **۱۳۷** — امروز با سه شاهد مستقل تأیید شد (بخش ۷) |

---

## ۲. جدول اصلی — عدد / منبع / وضعیت سازگاری

| عدد | منبع | وضعیت سازگاری |
|---|---|---|
| **۹۱۱** فایل dart اسکن‌شده | `docs/app-map/generated/SCAN_REPORT.md:4`؛ `generated/SCAN_REPORT.json` (`dart_file_count: 911`) | **آشتی‌پذیر — اسنپ‌شات قدیمی‌تر.** بازشماری امروز با عین قواعد همان اسکنر (`scan_flutter_app.py:13` و `:48`) روی درخت فعلی = **۹۲۱**؛ تفاضل ۱۰ فایل = دقیقاً ۱۰ فایل dart ردیابی‌نشدهٔ ثبت‌شده در `docs/app-map/baseline/BASELINE.json:52` (وجود هر ۱۰ فایل امروز روی دیسک تأیید شد) |
| **۱۴۶** کاندیدای GetPage | `generated/SCAN_REPORT.md:5`؛ `generated/GETPAGE_ROUTE_CANDIDATES.csv` (۱۴۶ ردیف داده) | **سازگار کامل.** ترکیب: ۱۳۷ در `lib/src/app/routes/routes_handler.dart` + ۱ در `lib/src/app/app.dart:72` + ۳ در `test/locale_language_switch_qc_test.dart` + ۵ در `test/notifications_interactive_test.dart`؛ بازاسکن امروز همان ۱۴۶ (هیچ فایل جدید/ویرایش‌شده‌ای GetPage نیفزوده) |
| **۸۵۴** فراخوانی ناوبری | `generated/SCAN_REPORT.md:6`؛ `generated/NAVIGATION_CALL_CANDIDATES.csv` (۸۵۴ ردیف داده) | **آشتی‌پذیر — مجموعه-متد متفاوت + اسنپ‌شات قدیمی.** شامل `Get.back`×۳۰۷ و `Navigator.pop`×۷۱، بدون هیچ دیالوگ/شیت (regex: `scan_flutter_app.py:17`)؛ عدد مقابل ۶۳۱ (`DISCOVERY_SUMMARY.md:34`) با regex مقابل (`tools/app_map_scanner.py:182-187`: دیالوگ/شیت بله، back/pop خیر) و فقط روی `lib/` به‌دست آمده؛ بازاسکن امروز = **۸۶۵** (+۱۱ از ویرایش ۸ فایل تغییرمحلی، فهرست در بخش ۵) |
| **۱۱۷۹** نماد | `generated/SCAN_REPORT.md:7`؛ `generated/DART_SYMBOL_CANDIDATES.csv` (۱۱۷۹ ردیف داده) | **آشتی‌پذیر — جنس موجودیت متفاوت + اسنپ‌شات قدیمی.** همهٔ کاندیداهای نماد در کل مخزن (۱٬۰۸۸ در `lib/` + ۹۱ بیرون)؛ عدد مقابل ۷۸۹ (`DISCOVERY_SUMMARY.md:33`) فقط «کلاس ویجت» در `lib/` است (`app_map_scanner.py:161-177`)؛ بازاسکن امروز = **۱۱۸۹** (+۱۰؛ تفکیک در بخش ۶) |
| **۹۲۱** فایل dart | `docs/stage_1/DISCOVERY_SUMMARY.md:30`؛ `baseline/BASELINE.json:9`؛ `surfaces/PROJECT_SURFACE_REPORT.json` (`dart_file_count: 921`) | **تأیید امروز.** شمارش فعلی = ۹۲۱ = ۸۱۱ در `lib/` + ۱۰۹ در `test/` + ۱ قالب در `docs/uiux/templates/design_token_template.dart` |
| **۱۳۷** اعلان روت GetPage | `DISCOVERY_SUMMARY.md:31` | **تأیید امروز.** `grep -c "GetPage(" lib/src/app/routes/routes_handler.dart` = ۱۳۷؛ `grep -c "static const" lib/src/app/routes/routes.dart` = ۱۳۷؛ ۱۳۷ ردیف در `ROUTE_CATALOG_VERIFIED_2026-10-24.csv` |
| **۶۳۱** فراخوانی ناوبری | `DISCOVERY_SUMMARY.md:34` (توصیف)؛ منطق واقعی: `tools/app_map_scanner.py:182-187` | **تأیید امروز — بازتولید دقیق.** اجرای همان regex روی `lib/` امروز = **۶۳۱** بدون خطا (تفکیک در بخش ۵) |
| **۷۸۹** کلاس ویجت | `DISCOVERY_SUMMARY.md:33`؛ منطق: `tools/app_map_scanner.py:161-177` | **تأیید امروز — بازتولید دقیق.** همان منطق روی `lib/` امروز = **۷۸۹** |
| **۱۳۷ روت یکتا** (مرجع امروز) | `docs/app-map/ROUTE_CATALOG_VERIFIED_2026-10-24.csv`؛ `docs/quality/CATALOG_COUNT_CONSISTENCY.md:16` | **مرجع.** با ۱۳۷ ردیف GET_PAGE رجیستری (`CATALOG_COUNT_CONSISTENCY.md:36`) منطبق است |
| **۷۴۰** سطح UI | `DISCOVERY_SUMMARY.md:32`؛ `docs/app-map/ROUTE_CATALOG.csv` (۷۴۰ ردیف) | **سازگار — مخرجِ «سطح UI» است، نه Route.** ۱۳۷ GET_PAGE + ۴۷۵ TAB_CHILD + ۷۴ GET_TO + ۵۲ BOTTOM_SHEET + ۲ DIALOG (`CATALOG_COUNT_CONSISTENCY.md:36`)؛ شمارش امروز ستون `screen_type` کاتالوگ: SCREEN ۲۱۱ / TAB_PAGE ۴۷۵ / BOTTOM_SHEET ۵۲ / DIALOG ۲ |

> جمع‌بندی وضعیت: **صفر تناقض اثبات‌شده** میان چهار عدد SCAN_REPORT و اعداد DISCOVERY_SUMMARY/اعداد تأییدشدهٔ امروز. خود SCAN_REPORT نیز صراحتاً «فهرست کاندیدا» است نه اثبات کامل‌بودن (`SCAN_REPORT.md:13-17`).

---

## ۳. چرا ۹۱۱ ≠ ۹۲۱ — زمان اسنپ‌شات، نه قاعدهٔ شمارش

- هر دو سند از یک ریشهٔ واحد روی ماشین Lenovo تولید شده‌اند: `C:\Users\Lenovo\Desktop\Ecardo\ecardo_userapp_v1` (`generated/SCAN_REPORT.json:2` و `SCAN_REPORT.md:3`؛ `baseline/BASELINE.json:3`).
- خط‌مبنای BASELINE در `2026-10-23T18:13:53Z` ثبت شده و `dart_files: 921` می‌گوید (`BASELINE.json:2` و `:9`)؛ همان عدد در `surfaces/PROJECT_SURFACE_REPORT.json` و `DISCOVERY_SUMMARY.md:30`.
- اسکنر stage_۱ ۹۱۱ شمرده است؛ یعنی **پیش از** پدید آمدن ۱۰ فایل dart اجرا شده است. تفاضل دقیقاً با ۱۰ فایل dart ردیابی‌نشدهٔ فهرست‌شده در `BASELINE.json:52` منطبق است (همگی امروز روی دیسک تأیید شدند):
  - `lib/src/commercial/screens/commercial_project_details_screen.dart`
  - `lib/src/presentation/screens/transfer/view/widgets/tx_flow_shimmer_skeleton.dart`
  - `lib/src/presentation/screens/transfer/view/widgets/tx_history_shimmer_skeleton.dart`
  - `test/commercial_and_card_completion_test.dart`، `test/exchange_flow_resilience_test.dart`، `test/financial_domain_integrity_test.dart`، `test/transfer_flow_upgrade_test.dart`، `test/travel/travel_ui_ux_flow_upgrade_test.dart`، `test/workstream_b_api_resilience_test.dart`، `test/workstream_f_security_i18n_perf_test.dart`
- **قاعدهٔ استثنا مقصر نیست:** اسکنر `graphify-out` را استثنا می‌کند (`scan_flutter_app.py:13`) اما `find graphify-out -name "*.dart"` = ۰ نتیجه؛ بازشماری امروز با هر دو مجموعه قاعده (با/بدون `graphify-out`) = ۹۲۱.
- **صداقت:** SCAN_REPORT زمان اجرا ندارد؛ جملهٔ «اسکن پیش از پدید آمدن این ۱۰ فایل اجرا شده» استنتاج است — اما استنتاجی با تطابق عددی کامل (۹۱۱ + ۱۰ = ۹۲۱) و بدون رقیب توضیحی دیگری که بتوان از همین ورک‌اسپیس آزمود.

## ۴. چرا ۱۴۶ = ۱۳۷ + ۹ — کاندیدا در برابر اعلان واقعی

ترکیب ۱۴۶ ردیف `GETPAGE_ROUTE_CANDIDATES.csv` (بازشماری این سشن):

| فایل | تعداد | ماهیت |
|---|---:|---|
| `lib/src/app/routes/routes_handler.dart` | ۱۳۷ | رجیستری واقعی روت‌های اپ — منطبق بر ۱۳۷ روت یکتای تأییدشده |
| `lib/src/app/app.dart:72` | ۱ | `unknownRoute: GetPage(` — صفحهٔ مسیر نامعلوم، عضو رجیستری ۱۳۷تایی نیست |
| `test/locale_language_switch_qc_test.dart:110,114,118` | ۳ | GetPage داربست تست |
| `test/notifications_interactive_test.dart:57..73` | ۵ | GetPage داربست تست |
| **جمع** | **۱۴۶** | — |

- `DISCOVERY_SUMMARY.md:31` عدد ۱۳۷ را «کاندیداهای مسیر ثبت‌شده» می‌نامد؛ توصیف دقیق‌ترش «اعلان‌های GetPage در رجیستری» است و با زیرمجموعهٔ ۱۳۷تاییِ همین CSV عیناً منطبق است.
- بازاسکن امروز روی درخت فعلی = همان ۱۴۶؛ یعنی ۱۰ فایل جدید و ویرایش فایل‌های موجود هیچ GetPage‌ای نیفزوده‌اند — پایداری این عدد در دو مقطع تأیید شد.
- نتیجه: **۱۴۶ و ۱۳۷ هر دو درست‌اند با تعریف‌های متفاوت**؛ عدد مرجع «روت یکتا» همان ۱۳۷ است.

## ۵. چرا ۸۵۴ ≠ ۶۳۱ — دو مجموعه-متد regex و دو دامنه

**شمارش ۸۵۴ (SCAN_REPORT؛ regex در `scan_flutter_app.py:17`؛ کل مخزن):** `Get.back` ۳۰۷، `Get.to` ۱۸۵، `Get.toNamed` ۱۸۴، `Navigator.pop` ۷۱، `Get.offAllNamed` ۵۴، `Get.off` ۲۶، `Get.offNamed` ۱۸، `push` ۷، `Get.offAll` ۲ — جمع ۸۵۴؛ ۸۵۰ در `lib/` + ۴ بیرون (`test/`).

**شمارش ۶۳۱ (DISCOVERY_SUMMARY.md:34؛ regex واقعی در `tools/app_map_scanner.py:182-187`؛ فقط `lib/`) — بازتولید دقیق امروز:** `Get.toNamed` ۱۷۵، `Get.to` ۱۶۷، `Get.bottomSheet` ۱۴۶، `Get.offAllNamed` ۵۴، `Get.off` ۲۶، `Get.dialog` ۲۲، `Get.offNamed` ۱۸، `showModalBottomSheet` ۱۴، `showDialog` ۷، `Get.offAll` ۲ — جمع **۶۳۱**.

تفاوت‌های سازه‌ای دو شمارش:

| ویژگی | ۸۵۴ (scan_flutter_app) | ۶۳۱ (app_map_scanner) |
|---|---|---|
| `Get.back` / `Navigator.pop` | ✔ می‌شمارد (۳۷۸ مورد) | ✘ نمی‌شمارد |
| `Get.dialog` / `Get.bottomSheet` / `showDialog` / `showModalBottomSheet` | ✘ نمی‌شمارد (صفر مورد) | ✔ می‌شمارد (۱۸۹ مورد) |
| دامنه | کل مخزن (شامل `test/`) | فقط `lib/` |
| `Navigator.pushAndRemoveUntil` | ✘ | ✔ |

- پس هیچ‌یک زیرمجموعهٔ دیگری نیست؛ هر دو عدد درونی‌سازگار و هر دو تعریف مشروع‌اند. توصیف `DISCOVERY_SUMMARY.md:34` («Get.to, Get.dialog, Get.bottomSheet, Navigator») گویای همین تفاوت است.
- **تفاوت زمانی نیز هست:** بازاسکن امروز با منطق ۸۵۴ = **۸۶۵**. تفاضل +۱۱ دقیقاً از ویرایش ۸ فایل (همگی در فهرست ۲۹ فایل تغییرمحلی `BASELINE.json:52`) ناشی شده است: `equity_project_detail_screen.dart` +۱، `forgot_password_pin_verification.dart` +۱، `two_factor_auth.dart` +۱، `make_payment_review_step_section.dart` +۲، `request_money_review_step_section.dart` +۲، `transfer_amount_step_section.dart` +۲، `transfer_history.dart` +۱، `transfer_received_history.dart` +۱. یعنی اسکنر stage_۱ پیش از آخرین ویرایش‌های این فایل‌ها اجرا شده است.

## ۶. چرا ۱۱۷۹ ≠ ۷۸۹ — کاندیدای نماد در برابر کلاس ویجت

- **۱۱۷۹** = همهٔ کاندیداهای نماد با چهار جنس (`scan_flutter_app.py:73-76`) در کل مخزن: فقط-SCREEN_OR_WIDGET ۸۸۹، فقط-STATE_OWNER ۱۶۱، فقط-DATA_OR_SERVICE ۶۳، فقط-DATA_MODEL ۱۰، و ترکیب‌ها ۵۶ (۲۳+۱۹+۸+۳+۳) — جمع ۱۱۷۹؛ ۱٬۰۸۸ در `lib/` + ۹۱ بیرون.
- **۷۸۹** = فقط کلاس‌های ویجت (یعنی `extends StatelessWidget/statefulWidget/GetView/GetWidget/Widget` — منطق `app_map_scanner.py:161-177`) در `lib/` — امروز دقیقاً بازتولید شد (۷۸۹).
- پس ۷۸۹ زیرمجموعهٔ مفهومیِ تقریبیِ ۱۱۷۹ است ولی با آن برابر نیست و نباید برابر گرفته شود (تازه دامنهٔ ۱۱۷۹ کل مخزن است و ۷۸۹ فقط `lib/`).
- **تفاوت زمانی:** بازاسکن امروز = **۱۱۸۹** (+۱۰): +۶ از فایل‌های جدید (`tx_flow_shimmer_skeleton` +۱، `tx_history_shimmer_skeleton` +۱، `test/exchange_flow_resilience_test` +۱، `test/transfer_flow_upgrade_test` +۲، `test/workstream_b_api_resilience_test` +۱) و +۴ خالص از ویرایش فایل‌های موجود (`commercial_projects_screen` +۱، `travel_widgets` +۲، `virtual_card_security_controls` +۲، `exchange_amount_step_section` −۱).

## ۷. لنگرگاه ۱۳۷ روت یکتا و مخرج ۷۴۰ سطح UI

- **۱۳۷ امروز با سه شاهد مستقل تأیید شد:** (۱) `grep -c "GetPage(" lib/src/app/routes/routes_handler.dart` = ۱۳۷؛ (۲) `grep -c "static const" lib/src/app/routes/routes.dart` = ۱۳۷؛ (۳) `docs/app-map/ROUTE_CATALOG_VERIFIED_2026-10-24.csv` = ۱۳۷ ردیف داده. همچنین زیرمجموعهٔ GET_PAGE فهرست CSV اسکنر = ۱۳۷ و ردیف‌های GET_PAGE رجیستری = ۱۳۷ (`CATALOG_COUNT_CONSISTENCY.md:36`).
- **۷۴۰ = مخرج «سطح UI»** (۱۳۷ روت + ۶۰۳ سطح غیر-روت) — تفکیک کامل در `CATALOG_COUNT_CONSISTENCY.md` بخش ۴؛ شمارش امروز ستون `screen_type` در `ROUTE_CATALOG.csv` همان تفکیک را بازتولید کرد (SCREEN ۲۱۱ = ۱۳۷ GetPage + ۷۴ ناوبری مستقیم؛ TAB_PAGE ۴۷۵؛ BOTTOM_SHEET ۵۲؛ DIALOG ۲).
- **زمینهٔ وضعیت کاتالوگ قدیمی:** در همین روز (MP-013)، `runtime_status` هر ۷۴۰ ردیف `ROUTE_CATALOG.csv` از `RUNTIME_VERIFIED` به `NOT_RUN` تنزل یافت (`docs/quality/MP-013_CHANGELOG.md:35`). اعتبارسنجی MP-010 روی همین وضعیت فعلی اجرا شد (بخش ۹).

## ۸. منبع یگانهٔ حقیقت شمارش (الزام پذیرش MP-014)

پذیرش تسک می‌خواهد «یک سند به‌عنوان منبع یگانهٔ حقیقت شمارش معرفی و بقیه به آن ارجاع داده شده باشند». وضعیت پس از این سند:

1. **مرجع یگانهٔ عدد «روت یکتا»:** `docs/app-map/ROUTE_CATALOG_VERIFIED_2026-10-24.csv` (۱۳۷) به‌همراه تحلیل مخرج‌ها در `docs/quality/CATALOG_COUNT_CONSISTENCY.md`.
2. **مرجع تفکیک ۷۴۰ سطح UI:** همان سند (`CATALOG_COUNT_CONSISTENCY.md` بخش ۴) و رجیستری بالادستی.
3. **این سند (MP-014_SCAN_RECONCILIATION.md)** جدول آشتی‌دهی یگانهٔ اعداد دو اسکنر است: SCAN_REPORT و DISCOVERY_SUMMARY از این پس «اسنپ‌شات تاریخی» تلقی می‌شوند و هر ارجاع به اعدادشان باید از جدول بخش ۲ عبور کند.
4. **چه چیزی انجام نشد:** درج ارجاع متقابل داخل خود `SCAN_REPORT.md` و `DISCOVERY_SUMMARY.md` — چون تسک MP-014 نوشتن فقط همین سند را مجاز کرد و قاعدهٔ غیرقابل مذاکره، ویرایش فایل‌های بالادستی را به «فقط خطوطی که تسک گفته» محدود می‌کند. پیشنهاد: این ارجاع‌ها + سند استاندارد مخرج‌ها (MP-011، `MASTER_TASK_BACKLOG.csv:11`) در تسک جداگانه تصویب و اعمال شود.

## ۹. وضعیت خروجی هم‌زمان MP-010 (زمینهٔ همین سشن)

`python ecardo_userapp_v1/docs/stage_1/02_SCRIPTS/validate_app_map.py --routes ecardo_userapp_v1/docs/app-map/ROUTE_CATALOG.csv --out ecardo_userapp_v1/docs/app-map/MAP_VALIDATION.json` اجرا شد؛ خروجی: `validation=FAIL، rows=740، errors=2221 (۱ MISSING_COLUMNS + ۲۲۲۰ INVALID_STATUS)، warnings=0`، کد خروج ۱. علت: `ROUTE_CATALOG.csv` شش ستون الزامی ابزار را ندارد (`module، route_name، source_mapping_status، implementation_status، test_status، evidence_ref` — الزام در `validate_app_map.py:7`). جزئیات کامل در خود `docs/app-map/MAP_VALIDATION.json` (خروجی عین ابزار، بازتولیدپذیر با همان فرمان).

## ۱۰. محدودیت‌ها و صداقت

1. **هیچ اجرای Flutter/تست/بیلد انجام نشد** (تسک code-inspection بود). همهٔ شمارش‌ها استاتیک‌اند.
2. بازاسکنِ «درخت فعلی» (۹۲۱/۱۴۶/۸۶۵/۱۱۸۹) بازسازی درون‌حافظه‌ای منطق اسکنر با regexهای عین `scan_flutter_app.py:14,17,18` است، نه اجرای خود اسکریپت — تا فایل‌های `generated/` بازنویسی نشوند. CSVهای موجود همچنان تنها سندِ وضعیتِ زمانِ اسکن‌اند.
3. زمان دقیق اجرای اسکنر stage_۱ در هیچ سندی ثبت نیست؛ توالی «اسکن ← پیدایش ۱۰ فایل ← خط‌مبنای ۹۲۱» استنتاج است (با تطابق عددی کامل، بخش ۳).
4. **دو ناهماهنگی خارج از دامنهٔ چهار عدد اصلی مشاهده و ثبت شد (بررسی‌نشده):**
   - `DISCOVERY_SUMMARY.md:38` می‌گوید ۱۰۸ فایل تست؛ سه منبع دیگر ۱۰۹ می‌گویند (`surfaces/TEST_FILE_INVENTORY.csv` = ۱۰۹ ردیف، `BASELINE.json:10` `test_dart_files: 109`، شمارش امروز `find test -name "*.dart"` = ۱۰۹).
   - `DISCOVERY_SUMMARY.md:37` ادعای «۲۴ روت RUNTIME_VERIFIED با ۶۱ اسکرین‌شات» دارد؛ این ادعا بی‌شاهد و متناقض ثبت شده است (`CATALOG_COUNT_CONSISTENCY.md:104-105`؛ تنزل MP-013 در `MP-013_CHANGELOG.md:35`).
5. ستون `owner` و اعداد مشتق از کاتالوگ قدیمی در این سند راستی‌آزمایی مستقل نشده‌اند (خارج از دامنه).
6. `graphify update` اجرا نشد (هیچ فایل کدی تغییر نکرد؛ مستند در سربرگ).

## ۱۱. فرمان‌های اجراشده (عیناً، از ریشهٔ `C:/Users/talas/OneDrive/Desktop/ecardo` یا `ecardo_userapp_v1` طبق توضیح)

1. `python ecardo_userapp_v1/docs/stage_1/02_SCRIPTS/validate_app_map.py --routes ecardo_userapp_v1/docs/app-map/ROUTE_CATALOG.csv --out ecardo_userapp_v1/docs/app-map/MAP_VALIDATION.json` → خروجی JSON: `{"validation": "FAIL", "rows": 740, "errors": 2221, "warnings": 0}`؛ کد خروج ۱.
2. `python -m graphify query "ecardo_userapp_v1 docs app-map ROUTE_CATALOG validate_app_map MAP_VALIDATION scan report"` (فقط‌خواندنی؛ قانون ۲ AGENTS.md).
3. `find lib -name "*.dart" | wc -l` → `811`
4. `grep -c "GetPage(" lib/src/app/routes/routes_handler.dart` → `137`؛ `grep -c "static const" lib/src/app/routes/routes.dart` → `137`
5. شمارش پایتونی CSVها (`csv.DictReader`): `ROUTE_CATALOG_VERIFIED_2026-10-24.csv` = ۱۳۷ ردیف؛ `ROUTE_CATALOG.csv` = ۷۴۰ ردیف؛ `GETPAGE_ROUTE_CANDIDATES.csv` = ۱۴۶؛ `NAVIGATION_CALL_CANDIDATES.csv` = ۸۵۴؛ `DART_SYMBOL_CANDIDATES.csv` = ۱۱۷۹؛ `HTTP_ENDPOINT_CANDIDATES.csv` = ۲؛ `ROUTE_STRING_CANDIDATES.csv` = ۶۳۹؛ `TEST_FILE_INVENTORY.csv` = ۱۰۹.
6. بازاسکن درون‌حافظه‌ای با regexهای عین `scan_flutter_app.py` روی درخت فعلی → `dart=921، getpage=146، nav=865، symbols=1189` (+ تفکیک per-file).
7. بازتولید الگوی `app_map_scanner.py:182-187` روی `lib/` → `631` (تفکیک در بخش ۵)؛ بازتولید منطق کلاس ویجت `app_map_scanner.py:161-177` روی `lib/` → `789`.
8. `find . -name "*.dart" -not -path "./.dart_tool/*" | wc -l` → `921`؛ `find graphify-out -name "*.dart" | wc -l` → `0`؛ `find test -name "*.dart" | wc -l` → `109`.
9. `grep -n "GetPage(" lib/src/app/app.dart` → خط ۷۲ (`unknownRoute: GetPage(`).

---

**جمع‌بندی:** چهار عدد SCAN_REPORT (۹۱۱/۱۴۶/۸۵۴/۱۱۷۹) با DISCOVERY_SUMMARY (۹۲۱/۱۳۷/۶۳۱/۷۸۹) و عدد مرجع امروز (۱۳۷ روت یکتا) **بدون هیچ تناقض باقی‌مانده** آشتی داده شدند: ۹۱۱→۹۲۱ اسنپ‌شات قدیمی‌تر (۱۰ فایل dart جدید)، ۱۴۶ = ۱۳۷ روت واقعی + ۹ کاندیدای غیر-روت، ۸۵۴ در برابر ۶۳۱ دو مجموعه-متد/دامنهٔ متفاوت (هر دو بازتولیدشدنی)، ۱۱۷۹ در برابر ۷۸۹ دو جنس موجودیت/دامنهٔ متفاوت (هر دو بازتولیدشدنی). عدد یگانهٔ مرجع برای «تعداد Route» همان **۱۳۷** است و ۷۴۰ مخرج «سطح UI» می‌ماند.
