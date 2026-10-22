# بستهٔ صفر تا صد ارتقای UI/UX برای eCardo (۲۰ اکتبر ۲۰۲۶)

## هدف
این بسته مسیر اجرایی برای تبدیل کل اپ Flutter eCardo به تجربه‌ای مدرن، منسجم، سریع، قابل‌استفاده، دسترس‌پذیر و چندزبانه ارائه می‌کند. این بسته یک طرح اجرا/ممیزی است؛ خودش کد موجود را تغییر نمی‌دهد و هیچ Push/Release/Deploy انجام نشده است.

## Baseline عمومی مشاهده‌شده
- Repository: https://github.com/mahankarimi1382/ecardo_userapp_v1
- در بررسی عمومی GitHub در تاریخ ۲۰۲۶-۱۰-۲۰، آخرین Release تگ‌شدهٔ قابل مشاهده `v1.0.178` است: https://github.com/mahankarimi1382/ecardo_userapp_v1/releases
- `pubspec.yaml` روی `main` در همان تاریخ نسخهٔ `1.0.180+180` را اعلام می‌کند؛ بنابراین نسخهٔ شاخهٔ `main` از آخرین Release تگ‌شده جلوتر است. فاز صفر باید commit SHA و tree دقیق محلی را ثبت کند. من به checkout محلی شما دسترسی ندارم.
- نسخه‌های گزارش‌شدهٔ قبلی، تعداد routeها و تعداد تست‌ها با یکدیگر متفاوت بودند. پیش از اجرا، از checkout واقعی baseline بگیرید و هیچ عددی را از گزارش قدیمی قطعی تلقی نکنید.
- README عمومی ادعا می‌کند Flutter `3.44.6` / Dart `3.12.2`، GetX، Dio، ۹۹ route و ۷۳۱ تست دارد؛ این‌ها ادعاهای اسناد عمومی‌اند و در این بسته شخصاً اجرا نشده‌اند. (README: https://github.com/mahankarimi1382/ecardo_userapp_v1/blob/main/README.md)
- `DESIGN_SYSTEM_GUIDE.md` شامل قواعد اجرایی بسیار مهم است: قبل از کاوش کد `graphify query`؛ عامل‌های موازی نباید `flutter test` را اجرا کنند؛ فقط `flutter analyze` روی محدودهٔ خود؛ تست نهایی باید سریال توسط integrator انجام شود؛ `git checkout` و `git stash` ممنوع؛ فایل‌های token/theme و `common/widgets/design_system/**` مالک اختصاصی دارند. این قواعد بر پرامپت‌های عمومی این بسته مقدم‌اند: https://github.com/mahankarimi1382/ecardo_userapp_v1/blob/main/DESIGN_SYSTEM_GUIDE.md

## استفادهٔ درست از این بسته
1. `00_MASTER_EXECUTION_ROADMAP_FA.md` را بخوانید؛ فاز صفر باید قبل از هر تغییر انجام شود.
2. route inventory دقیق را از کد واقعی بسازید. ماتریس نمونه هرگز جای فهرست واقعی routeها را نمی‌گیرد.
3. `PACKAGE_SHORTLIST.csv` را به معنای نصب یک‌جای تمام packages ندانید؛ هر package نیاز به PoC، بررسی license/maintenance و ADR دارد.
4. هفت فایل کاتالوگ repo در `repo_catalogs/` هر کدام ۵۰ مورد معرفی می‌کنند (۳۵۰ مورد مجموعاً). بسیاری مرجع طراحی/الگو هستند؛ همهٔ آن‌ها در این مرحله commit-by-commit ممیزی نشده‌اند. وجود، مجوز، فعالیت و سازگاری هر مورد را پیش از اقتباس بررسی کنید.
5. ۵۹ مهارت سفارشی Agent Skills در `skills/*/SKILL.md` آماده است؛ آن‌ها را در `.agents/skills/` یا مسیر مورد پشتیبانی ابزار تیم کپی کنید. نصب تمام skills به‌صورت بی‌قید توصیه نمی‌شود؛ ابتدا روی یک شاخه آزمایش کنید.
6. همهٔ agentها باید از مالکیت فایل، منع mock در production، عدم تغییر منطق مالی با تغییر UI و ممنوعیت Push/Release بدون تأیید پیروی کنند.

## فایل‌های اصلی
- `00_MASTER_EXECUTION_ROADMAP_FA.md` — نقشهٔ راه ۱۸۰روزه
- `01_CURRENT_STATE_AND_GAP_AUDIT_FA.md` — baseline و اختلاف‌های باز
- `02_XPAY_AND_COMPETITOR_BENCHMARK_FA.md` — بنچمارک XPay و رقبا
- `03_PAGE_ROUTE_AUDIT_WORKBOOK.csv` — workbook پوشش routeها
- `04_TARGET_DESIGN_SYSTEM_FA.md` — سیستم طراحی هدف
- `05_UIUX_ARCHITECTURE_AND_PAGE_SPECS_FA.md` — معماری صفحات و حالت‌ها
- `06_CRITICAL_FINTECH_FLOWS_FA.md` — جریان‌های مالی بحرانی
- `07_A11Y_RTL_I18N_QA_FA.md` — accessibility و ۶ زبان
- `08_VISUAL_REGRESSION_AND_TEST_PLAN_FA.md` — visual QA/test
- `09_PERFORMANCE_MOTION_AND_POLISH_FA.md` — عملکرد و motion
- `10_AGENT_EXECUTION_PROMPT_FA.md` — پرامپت ایجنت اصلی
- `PACKAGE_SHORTLIST.csv` — کتابخانه‌های پیشنهادی
- `skills/SKILLS_CATALOG.csv` — ۵۹ skill آماده
- `repo_catalogs/ALL_REPOSITORIES_350.csv` — همهٔ ۳۵۰ repository candidate

## منابع اصلی
- Flutter internationalization: https://docs.flutter.dev/ui/internationalization
- Flutter accessibility: https://docs.flutter.dev/ui/accessibility
- Flutter accessibility testing: https://docs.flutter.dev/ui/accessibility/accessibility-testing
- Flutter testing overview: https://docs.flutter.dev/testing/overview
- Flutter integration tests: https://docs.flutter.dev/testing/integration-tests
- Flutter performance profiling: https://docs.flutter.dev/perf/ui-performance
- Flutter DevTools: https://docs.flutter.dev/tools/devtools
- Agent Skills examples: https://github.com/anthropics/skills
- Vercel agent skills: https://github.com/vercel-labs/agent-skills
- XPay commercial UI kit: https://codecanyon.net/item/xpay-mobile-banking-e-wallet-flutter-app/37419851

## قاعدهٔ انتشار
این بسته مجوز Push یا انتشار نمی‌دهد. هیچ Release/Deploy بدون دستور صریح صاحب پروژه مجاز نیست.
