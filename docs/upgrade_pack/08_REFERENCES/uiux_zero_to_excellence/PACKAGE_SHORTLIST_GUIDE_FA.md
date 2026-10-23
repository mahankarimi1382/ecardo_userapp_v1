# راهنمای کتابخانه‌های پیشنهادی eCardo

`PACKAGE_SHORTLIST.csv` فهرست candidateهای اجرایی است، نه دستور نصب یک‌جای پکیج‌ها. ستون `public_main_pubspec_status` بر اساس pubspec عمومی `main` در تاریخ ۲۰ اکتبر ۲۰۲۶ اضافه شده؛ checkout محلی ممکن است متفاوت باشد.

## قوانین انتخاب
1. نیاز UX را از baseline ثابت کنید؛ package فقط وقتی افزوده شود که widget/framework داخلی شکاف مستند داشته باشد.
2. `get`/GetX، Dio، ScreenUtil، shimmer، lottie، SVG و image caching در pubspec عمومی فعلی دیده می‌شوند؛ برای این‌ها ابتدا integration و usage coverage را بهتر کنید، نه اینکه نسخهٔ دوم جایگزین اضافه کنید.
3. State management یا navigation را صرفاً به دلیل trending بودن عوض نکنید. هر مهاجرت یک ADR، PoC، پشتیبانی همهٔ routeهای وابسته و rollback plan نیاز دارد.
4. package موجود در pubspec لزوماً در تمام صفحات درست استفاده نشده؛ هدف، governance/coverage است نه صرفاً dependency count.
5. قبل از adopt، release فعلی، Dart/Flutter constraints، platform support، license، transitive dependencies، issue/advisoryها، API stability و app-size/performance را کنترل کنید.
