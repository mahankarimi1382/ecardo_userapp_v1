# پرامپت تحویل بین ایجنت‌ها — بعد از Discovery

فقط بعد از عبور از Gateهای مرحلهٔ ۱ این دستورالعمل را اجرا کن.

1. از `DISCOVERY_SUMMARY.md` و `GAP_REGISTER.csv` فهرست مشکلات P0/P1 بساز؛ موارد مبهم را قطعی اعلام نکن.
2. هیچ کدام از عامل‌ها اجازه ندارند scope را «Home و چند صفحه» تفسیر کنند. هر Route ID باید صاحب مشخص داشته باشد.
3. تقسیم کار فقط پس از تولید manifest مالکیت انجام شود. برای هر عامل بنویس: Task IDs، Route IDs، مسیرهای فایل مجاز، فایل‌های ممنوع، upstream contracts، تست لازم، screenshot evidence و معیار پذیرش.
4. ابتدا رفع mismatchها و قراردادهای مشترک مالی/API، بعد P0 امنیتی و صحت، سپس فلوهای بحرانی، بعد همهٔ باقیماندهٔ صفحات طبق فهرست. UI نباید خطای backend را mask کند.
5. از فایل‌های locked در `DESIGN_SYSTEM_GUIDE.md` و `FILE_OWNERSHIP.md` پیروی کن. تغییر اشتراکی بدون handoff ممنوع.
6. هر merge/update نقشه، `graphify update .` و تست‌های مجاز را طبق راهنمای پروژه انجام بده. تست نهایی فقط یک‌بار و سریال توسط integrator.
7. تحویل مرحلهٔ بعد باید proof-based باشد: source SHA، diff، تست، screenshot و open gaps. هیچ push/release/deploy بدون مجوز جدید انجام نده.
