# راهنمای اسکریپت‌ها

## `capture_baseline.py`
Snapshot فرادادهٔ Git، نسخهٔ pubspec، تعداد فایل‌ها و نسخهٔ ابزارها را می‌گیرد. فقط فرمان‌های read-only را اجرا می‌کند و هیچ تست، build، network fetch یا remote action ندارد.

## `scan_flutter_app.py`
اسکنر Regex سبک برای GetPage، callهای ناوبری، کلاس‌های کاندیدای صفحه/controller/service/model و مسیرهای API به شکل literal. نتایج «کاندیدا» هستند و باید با Graphify، route registry و runtime تطبیق داده شوند.

## `inventory_project_surfaces.py`
فهرست فایل‌ها، تست‌های موجود بدون اجرای آن‌ها، دارایی‌ها، ARBها، manifestها و workflow trigger candidates را ثبت می‌کند. عمداً محتوای workflow یا مقدار Secret را چاپ نمی‌کند؛ triggerهایی که پیدا می‌کند باید دستی بازبینی شوند.

## `validate_app_map.py`
Schema و بعضی invariantهای Route Catalog را اعتبارسنجی می‌کند. خالی بودن کاتالوگ شکست است؛ `RUNTIME_VERIFIED` بدون evidence خطاست؛ `PASS` بدون test ref warning است.

اسکریپت‌ها هیچ‌یک به تنهایی ادعای پوشش کامل نمی‌کنند.
