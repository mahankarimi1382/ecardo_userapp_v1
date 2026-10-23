# سیاست انتخاب مخزن و package

کاتالوگ شامل ۳۵۰ repository entry (۷ دسته × ۵۰) است. این تعداد به معنی نصب ۳۵۰ dependency نیست. بخش زیادی صرفاً مرجع بصری، design system غیر-Flutter، app exemplar یا skill catalog هستند.

## امتیازدهی ۰–۵ برای هر گزینه
- وظیفه‌ای که حل می‌کند/شکاف واقعی eCardo
- آخرین commit/release و issue response
- license قابل استفادهٔ تجاری
- سازگاری با Flutter/Dart فعلی و platform targets
- امنیت و dependency tree
- accessibility/i18n/RTL quality
- bundle size/startup/perf impact
- پوشش تست/مستندات/API stability
- خطر vendor lock-in / هزینه نگهداری

## تصمیم
- Adopt: فقط پس از ADR + PoC + tests + approved license.
- Reference: ایده/behavior را بررسی کنید، نه کد را وارد کنید.
- Reject: license مشکل‌دار، نگهداری ضعیف، platform/API incompatible، duplicate capability.
- Defer: شکاف هنوز با اندازه‌گیری ثابت نشده است.
