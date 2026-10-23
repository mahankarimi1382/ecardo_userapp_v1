# راه‌اندازی در repo واقعی

1. این بسته را به‌صورت فایل/branch مستندات وارد workspace کن؛ لازم نیست همهٔ reference docs را یک‌باره وارد production app کنی.
2. دستورهای پروژه را بخوان و اولویت بالاترشان را حفظ کن.
3. در ابتدا فقط اسکریپت scanner، outputs و catalog docs را اجرا/تولید کن. برای اصلاح production code تا تایید baseline و task/file ownership صبر کن؛ به‌جز containment محدود P0.
4. بعد از discovery، backlog را به issue/task واقعی تبدیل کن: route IDs، allowed files، dependencies، owner، tests و done evidence.
5. برای هر agent فقط prompt مربوط و taskهای مربوط را بده؛ master prompt به‌تنهایی برای هر agent کافی نیست چون ownership باید مشخص باشد.
6. Integrator همهٔ خروجی‌ها را merge/review می‌کند؛ یک test runner در انتها تمام تست‌های نهایی را سریال اجرا می‌کند.
7. مستندات به‌روزرسانی شوند اما هیچ Push/Release/Deploy بدون درخواست مستقل صاحب پروژه انجام نشود.
