# برنامهٔ اجرایی ۳۰ روز اول

## روزهای ۱–۳: امن‌سازی و baseline
- [ ] دستورات پروژه و مالکیت فایل‌ها خوانده شد.
- [ ] SHA/branch/status/version/toolchain ثبت شد.
- [ ] Graphify query اجرا شد یا ابزار نبودنش `BLOCKED` ثبت شد.
- [ ] تغییرات قبل از شروع تفکیک شد و هیچ چیزی reset/stash/checkout نشد.

## روزهای ۴–۷: discovery
- [ ] اسکنر `scan_flutter_app.py` اجرا و artifacts تولید شد.
- [ ] Route declarations + navigation call candidates بازبینی شدند.
- [ ] کلاس‌های صفحه/overlay/tab/flow/controller/service/repository/model در ماتریس ثبت شدند.
- [ ] همهٔ assets/ARB/tests/permissions/deep links بررسی شدند.

## روزهای ۸–۱۰: runtime reconciliation
- [ ] routeها در debug/test environment پیمایش شدند.
- [ ] screenshot و evidence برای مسیرهای مهم ثبت شد.
- [ ] unreachable/dynamic/protected routes با دلیل ثبت شدند.
- [ ] کاتالوگ از منبع سورس و runtime با هم reconciled شد.

## روزهای ۱۱–۱۵: integration map
- [ ] مالکیت داده و منبع حقیقت هر ماژول ثبت شد.
- [ ] state/status/error contract تصویب شد.
- [ ] money precision, fee, quote, idempotency and unknown outcome rules ثبت شد.
- [ ] P0/P1 findings و dependency DAG ایجاد شد.

## روزهای ۱۶–۲۰: pilot architecture and UI
- [ ] Home, Wallet Details, Transfer Review, Receipt page specs آماده‌اند.
- [ ] design system موجود بررسی و ownership lockها حفظ شد.
- [ ] API state mapping و no-op CTA audit اجرا شد.
- [ ] minimum integration tests برای flowهای حیاتی طراحی شد.

## روزهای ۲۱–۲۵: اولین اصلاحات امن
- [ ] P0 مالی/امنیتی قبل از polish حل شد.
- [ ] network/error mapping مشترک به‌صورت سازگار اصلاح شد.
- [ ] pilot pages به shared components واقعی وصل شدند.
- [ ] regressions فقط توسط ownerهای مشخص تست شدند.

## روزهای ۲۶–۳۰: evidence gate
- [ ] runtime screenshot + test evidence ثبت شد.
- [ ] route catalog اختلاف نهایی با source scan ندارد یا اختلاف‌ها مستندند.
- [ ] هر تغییر در matrix و graph refresh شده است.
- [ ] هیچ ادعای «همهٔ صفحات کامل‌اند» بدون count/evidence ارائه نشده است.
- [ ] برنامهٔ ۶۰ روز بعد بر اساس یافته‌های واقعی به‌روزرسانی شد.
