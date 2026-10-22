# پرامپت اجرایی ایجنت اصلی UI/UX eCardo

هدف: اجرای نقشهٔ راه کامل روی checkout محلی واقعی و ارتقای تمام صفحات به تجربه‌ای واحد، مدرن و کاربرپسند.

## ممنوعیت‌ها
- هیچ Push, Tag, Release یا Deploy انجام نده؛ حتی اگر workflow سبز باشد.
- هیچ mock success، fee، rate، balance، provider eligibility یا crypto address به Release وارد نکن.
- بدون ADR و PoC dependency جدید اضافه نکن؛ GetX/Dio یا ساختار موجود را فقط برای مد روز بودن جایگزین نکن.
- چند agent را بدون مالکیت فایل روی design tokens، router، shared component یا golden baseline هم‌زمان فعال نکن.

## شروع
1. خواندن AGENTS.md, FILE_OWNERSHIP.md, DESIGN_SYSTEM_GUIDE.md و PRE_PUSH_CHECK.md. این دستورها بر همهٔ قواعد عمومی این پرامپت مقدم‌اند.
2. مطابق guide پروژه، قبل از کاوش سورس `graphify query "<سؤال دقیق>"` اجرا کن.
3. در working tree مشترک `git checkout`, `git stash` و `reset --hard` ممنوع‌اند؛ تغییرات sessionهای دیگر را حفظ کن.
4. عامل‌های موازی `flutter test` اجرا نکنند؛ هر عامل فقط `flutter analyze` روی محدودهٔ خودش بزند، تست نهایی را integrator سریال اجرا کند.
5. فایل‌های token/theme و `common/widgets/design_system/**` قفل/مالک اختصاصی دارند؛ برای تغییرشان handoff بگیر.
4. خواندن baseline و دستورات ایجنت را کامل کن.
2. ثبت `git status`, SHA، version، Flutter/Dart، CI و Release baseline.
3. استخراج routeهای واقعی و تکمیل `03_PAGE_ROUTE_AUDIT_WORKBOOK.csv`.
4. گرفتن screenshots و ثبت شکاف‌ها پیش از تغییر.
5. گزارش P0/P1/P2، dependencies و plan را قبل از redesign بزرگ بنویس.

## تقسیم کار
A. Route/UI audit + dead CTA and mock data; B. design system/tokens; C. financial flows; D. accessiblity/locales; E. golden/E2E/perf; integrator تنها merge owner.

## اجرای فازها
ابتدا چهار pilot (Home, Wallet Details, Transfer Review, Transaction Receipt)، سپس تمام پولی، حساب/کارت/crypto، auth/profile/support، localization/accessibility و در انتها motion/performance polish. هر صفحه spec و acceptance gate دارد.

## پس از تغییر
- مطابق دستور موجود در پروژه، `graphify update .` را اجرا کن یا اگر ابزار/محیط در دسترس نیست، آن را `BLOCKED` ثبت کن.

## Done یعنی
- قبل/بعد تصویر مستند؛
- test و exit code؛
- تمام stateهای لازم؛
- شش زبان و themeها در صفحه حیاتی؛
- دسترس‌پذیری و dynamic text بررسی؛
- هیچ mock یا financial fake؛
- گزارش فایل‌های تغییرکرده و risk؛
- هیچ انتشار ریموت.
