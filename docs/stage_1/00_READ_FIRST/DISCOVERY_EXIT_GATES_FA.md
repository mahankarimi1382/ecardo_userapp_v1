# معیارهای خروج مرحلهٔ ۱ — دروازه‌های پذیرش

## Gate 1 — Integrity / no surprise mutation
- [ ] HEAD SHA، branch و تغییرات از قبل موجود ثبت شده‌اند.
- [ ] هیچ فایل موجود overwrite یا حذف نشده است.
- [ ] هیچ push/tag/release/deploy یا workflow دستی اجرا نشده.
- [ ] هیچ test/transaction مالی واقعی اجرا نشده.

## Gate 2 — Source discovery
- [ ] Graphify query خروجی ثبت‌شده دارد یا blocker دقیق ثبت شده.
- [ ] تمام Dart files با شمارش baseline مقایسه شده‌اند.
- [ ] GetPage entries، navigation methods، dynamic route builders، tabs، overlays و deep links بررسی شده‌اند.
- [ ] manifestها و notification/QR/deep-link entry points بررسی شده‌اند.
- [ ] تمام screen-like classes بررسی یا طبقه‌بندی شده‌اند.
- [ ] endpoint candidates به قرارداد/API inventory نگاشت شده‌اند، یا دلیل unresolved ثبت شده.

## Gate 3 — Traceability
- [ ] هر route record شناسه، source file و status دارد.
- [ ] صفحه‌های candidate با confirmed routes جدا شده‌اند.
- [ ] route duplicates، dangling routes، unreachable candidates و missing target screen بررسی شده‌اند.
- [ ] هر صفحه تا controller/state owner، service/repository، endpoint، model و tests تا جای ممکن trace شده.
- [ ] تمام flowهای مالی در catalog آمده‌اند و اثر واقعی/درخواستی هر کدام مشخص است.

## Gate 4 — Evidence quality
- [ ] هیچ RUNTIME_VERIFIED بدون screenshot/log/test evidence نیست.
- [ ] هیچ PASS بدون شناسهٔ تست و خروجی واقعی نیست.
- [ ] تمام blockers، assumptions و limitations ثبت شده‌اند.
- [ ] تضاد README/pubspec/AGENTS/releases ثبت شده است.
- [ ] گزارش validator بدون schema errors است.

## Gate 5 — Handoff
- [ ] `DISCOVERY_SUMMARY.md` شامل شمارش‌های candidate/source-mapped/runtime-verified/tested/blocked/deferred است.
- [ ] فهرست P0/P1/P2 مرتب‌شده بر اساس شواهد آماده است.
- [ ] فایل‌های مرحلهٔ بعد مشخص شده‌اند: اول P0 صحت/امنیت مالی و API contracts، سپس فلوهای بحرانی و ارتقای سطح تمام صفحات.
- [ ] مالکیت فایل‌ها و محدودهٔ هر عامل مشخص است.

**قبولی مرحله:** هیچ ادعای پوشش ۱۰۰٪ صرفاً از روی شمار Route یا کد source مجاز نیست. Gate ناموفق باید `FAIL` یا `BLOCKED` بماند و به مرحلهٔ ارتقا منتقل نشود مگر برای containment محدودِ یک خطر P0 مستند.
