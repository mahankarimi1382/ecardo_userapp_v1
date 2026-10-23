# eCardo — بستهٔ جامع کشف، یکپارچه‌سازی و ارتقای کل اپلیکیشن

**تاریخ تهیه: ۲۳ اکتبر ۲۰۲۶**

این بسته برای پروژهٔ Flutter eCardo (`https://github.com/mahankarimi1382/ecardo_userapp_v1`) طراحی شده است. هدف آن فقط بهتر کردن UI نیست؛ باید تمام صفحه‌ها، Routeها، سرویس‌ها، منطق مالی، APIها، وضعیت‌ها، امنیت، تست‌ها و ارتباط ماژول‌ها شناسایی، مستند، یکپارچه و ارتقا داده شوند.

## چیزی که این بسته هست و نیست

- **هست:** نقشهٔ اجرای مرحله‌ای، قواعد معماری و قراردادهای ادغام، ماتریس ماژول‌ها، تست‌پلن، فهرست کارها، پرامپت عامل اصلی و عامل‌های تخصصی، قالب‌های مستندات و اسکریپت پایهٔ کشف سورس Flutter.
- **نیست:** گزارشِ اجرای کامل روی checkout فعلی یا اثبات اینکه تعداد مشخصی Route در مخزن وجود دارد. اسکنر باید در checkout واقعی اجرا شود و نتایجش توسط سورس، تست و اجرای برنامه reconciled شوند.
- **هیچ کد اپلیکیشن، GitHub، Release یا Deploy در این بسته تغییر داده نشده است.** اسکریپت‌ها و اسناد باید ابتدا روی یک checkout واقعی و با رعایت قواعد پروژه استفاده شوند.

## شروع سریع

1. `01_MASTER_PLAN/01_MASTER_ROADMAP_FULL_APP_FA.md` را بخوان.
2. پیش از هر بررسی سورس، طبق `DESIGN_SYSTEM_GUIDE.md` خود پروژه `graphify query "map all eCardo routes and trace screen -> controller -> service -> API dependencies"` را اجرا کن؛ اگر Graphify یا گراف آماده نیست، وضعیت را صریح ثبت کن.
3. در checkout واقعی اجرا کن:

   ```bash
   python3 scripts/scan_flutter_app.py --root . --out docs/app-map/generated
   ```

4. خروجی اسکنر را با Route table، navigation calls، همهٔ `lib/`, `test/`, `integration_test/`, `assets/`, ARBها، deep links و مسیرهای runtime مقایسه کن. خروجی regex ابزار «کاندیدا» است، نه proof of completeness.
5. فایل‌های خالی/قالبی `03_CATALOGS/ROUTE_CATALOG_TEMPLATE.csv` و `TRACEABILITY_MATRIX_TEMPLATE.csv` را از شواهد checkout واقعی پر کن.
6. فقط بعد از تکمیل baseline و P0 findings شروع به ارتقا کن. هر task باید به Route/Module ID وصل شود و هر تغییر تست رگرسیون متناسب داشته باشد.
7. تست نهایی را طبق قواعد پروژه، سریال توسط integrator اجرا کن؛ ایجنت‌های موازی `flutter test` اجرا نکنند.
8. هیچ Push/Tag/Release/Deploy بدون دستور صریح صاحب پروژه انجام نده.

## ساختار بسته

- `01_MASTER_PLAN/` — نقشهٔ راه اصلی تا مرحلهٔ اثبات پوشش کل محصول.
- `02_ARCHITECTURE_AND_CONTRACTS/` — معماری پیشنهادی بدون مهاجرت اجباری از GetX/Dio، قراردادهای API و قواعد مالی.
- `03_CATALOGS/` — ماتریس ماژول‌ها، قرارداد بین ماژول‌ها، ماتریس تست و backlog قابل‌ردیابی.
- `04_AGENT_PLAYBOOKS/` — پرامپت هماهنگ‌کننده و عامل‌های تخصصی.
- `05_TEMPLATES/` — قالب page/flow spec، ADR، bug، integration contract و گزارش نهایی.
- `06_SCRIPTS/` — اسکنر پایه و اعتبارسنج کاتالوگ Routeها.
- `07_BENCHMARKS/` — مطالعهٔ الگوهای xMoney/xPortal، XPay، Wise و Revolut بدون کپی برند/کد.
- `08_REFERENCES/` — بستهٔ UI/UX قبلی، کاتالوگ ۳۵۰ ریپازیتوری و فهرست پکیج‌ها/مهارت‌ها.
- `09_AGENT_SKILLS/` — هشت Skill واقعی با دستورالعمل تخصصی برای ایجنت‌ها.

## قانون صداقت در پوشش

هر صفحه/جریان یکی از این وضعیت‌ها را می‌گیرد: `DISCOVERED`, `SOURCE_MAPPED`, `RUNTIME_VERIFIED`, `UPGRADED`, `REGRESSION_TESTED`, `BLOCKED`, `DEPRECATED`. «کامل» فقط وقتی ثبت می‌شود که مدرک منطبق با checkout/SHA، تست و اجرای واقعی موجود باشد. وجود فایل Dart یا سبز بودن تحلیل استاتیک به‌تنهایی کافی نیست.

## نکته دربارهٔ الهام از Xmony

در منابع عمومی، محصول رسمیِ دقیق با املای «Xmony» قابل تأیید نشد؛ نزدیک‌ترین موردِ مستند، `xMoney` و سوپر‌اپ `xPortal` است. این بسته از آن‌ها صرفاً برای تحلیل الگوهای محصول مالی/کیف پول/کارت الهام می‌گیرد. اگر منظور محصول دیگری با نام Xmony است، نام یا لینک رسمی آن باید در benchmark جایگزین شود؛ در این نسخه نام را بی‌دلیل معادل قطعی تلقی نکرده‌ایم.

## قاعدهٔ پذیرش Dependency

کاتالوگ‌ها فهرست اکتشاف/الهام هستند، نه فهرست نصب. هر dependency باید license، maintenance، امنیت، سازگاری با Flutter/Dart/Gradle فعلی، حجم باینری، تداخل با وابستگی فعلی و PoC قابل‌اندازه‌گیری داشته باشد. GetX/Dio و معماری فعلی فقط برای مد روز بودن تعویض نشوند.
