# مرحلهٔ ۱ eCardo — کشف واقعی، خط مبنا و نقشهٔ صفحات

**هدف:** پیش از بازطراحی یا تغییر منطق، از checkout واقعی eCardo یک نقشهٔ قابل‌ممیزی بسازیم: Git/نسخه، همهٔ کاندیداهای Route، صفحه‌ها، Controllerها، سرویس‌ها، APIها، فلوها، وضعیت‌های UI، تست‌ها و موارد جاافتاده.

خط مبنای عمومی قابل‌استناد در `04_PUBLIC_BASELINE/PUBLIC_BASELINE_2026-10-23_FA.md` قرار دارد؛ خط مبنای محلی باید از checkout واقعی تولید شود.

## محدودهٔ این مرحله

این مرحله Discovery-only است. در این فاز منطق مالی یا UI را بازنویسی نکنید. مجاز است گزارش‌ها و مستندات جدید در `docs/app-map/` اضافه شوند. تغییر سورس اپ تنها برای رفع مشکل بحرانیِ اثبات‌شده و با مجوز صریح مالک انجام شود.

## اجرای ایمن

1. از checkout واقعی پروژه استفاده کنید؛ هیچ‌گاه روی کپی ناشناخته یا branch اشتباه نتیجه‌گیری نکنید.
2. دستورهای محلی را بخوانید: `AGENTS.md`, `DESIGN_SYSTEM_GUIDE.md`, `FILE_OWNERSHIP.md`, `PRE_PUSH_CHECK.md` و فایل `START-HERE.md` که در دستورهای پروژه به آن اشاره شده است. اگر فایل/مسیر محیطی وجود ندارد، BLOCKED ثبت کنید و دستور را جعل نکنید.
3. طبق قانون پروژه قبل از کاوش گستردهٔ سورس اجرا کنید:

   ```bash
   python -m graphify query "map all eCardo screens routes navigation flows and trace each screen to controller service API tests; identify unmapped and unreachable features"
   ```

   اگر فرمان یا `graphify-out/graph.json` در checkout فعلی موجود نیست، خطا/نسخه/مسیر را ثبت کنید و فقط بعد از ثبت blocker از اسکن ایستا استفاده کنید.
4. ابزارهای این بسته را اجرا کنید (Python 3.10+):

   ```bash
   python3 02_SCRIPTS/capture_baseline.py --root /path/to/ecardo_userapp_v1 --out /tmp/ecardo-baseline
   python3 02_SCRIPTS/scan_flutter_app.py --root /path/to/ecardo_userapp_v1 --out /tmp/ecardo-scan
   ```

   اسکریپت‌ها فقط خواندن/گزارش انجام می‌دهند. اسکنر regex کاندیدا تولید می‌کند؛ AST/runtime completeness proof نیست.
5. از خروجی‌ها و شواهد خود checkout فایل‌های قالب در `03_TEMPLATES/` را پر کنید. نه اینکه قالب خام را به‌عنوان نتیجه اعلام کنید.
6. کاتالوگ نهایی را بررسی کنید:

   ```bash
   python3 02_SCRIPTS/validate_app_map.py --routes /path/to/ROUTE_CATALOG.csv --out /tmp/app-map-validation.json
   ```

7. فقط گزارش‌ها/نقشه‌های بررسی‌شده را به `docs/app-map/` انتقال دهید. فایل‌های تولیدی باید تاریخ، SHA منبع، ابزار، محدودیت‌ها و شناسهٔ شواهد داشته باشند. ابزار `capture_baseline.py` را نیز برای snapshot محلی اجرا کنید؛ خروجی پیش‌فرض آن خارج از checkout و در `/tmp/ecardo-baseline` است.

## الزامات ایمنی

- `git checkout`, `git stash`, `git reset --hard` و حذف/بازنویسی تغییرات موجود ممنوع.
- هیچ `git push`, tag, Release, Deploy یا اجرای workflow دستی انجام نشود.
- از اجرای تست‌های موازی روی working tree مشترک خودداری شود؛ مطابق راهنمای مخزن، تست نهایی را integrator به‌صورت سریال اجرا می‌کند. مرحلهٔ فعلی هیچ تستی اجرا نمی‌کند.
- هیچ پرداخت/انتقال/صدور کارت واقعی انجام ندهید. فقط sandbox/mock برای تست runtime در مرحلهٔ بعد.
- هر ادعا باید شواهد داشته باشد. `DISCOVERED`، `SOURCE_MAPPED`، `RUNTIME_VERIFIED` و `TESTED` مفاهیم جدا هستند.
- مقادیر secrets، کلیدها، توکن‌ها، شمارهٔ کامل کارت، OTP، passcode و PII را در خروجی نیاورید.

## خروجی مورد انتظار

در انتهای مرحله حداقل فایل‌های زیر در `docs/app-map/` وجود داشته باشد:

- `LOCAL_BASELINE.md` و `LOCAL_BASELINE.json`
- `generated/SCAN_REPORT.md`, `generated/SCAN_REPORT.json` و CSVهای کاندیدا
- `ROUTE_CATALOG.csv`
- `SCREEN_SERVICE_MATRIX.csv`
- `FLOW_CATALOG.csv`
- `GAP_REGISTER.csv`
- `TRACEABILITY_MATRIX.csv`
- `DISCOVERY_SUMMARY.md`
- `EVIDENCE_LEDGER.csv`

مستندات باید معلوم کنند چه چیزی کشف، تأیید، مسدود یا هنوز نامعلوم است. عدد کلی Route به‌تنهایی کافی نیست.
