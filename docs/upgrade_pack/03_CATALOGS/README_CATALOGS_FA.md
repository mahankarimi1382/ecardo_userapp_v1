# راهنمای کاتالوگ‌ها

این CSVها برای traceability طراحی شده‌اند. ماتریس `EXPECTED_MODULES.csv` یک فهرست دامنهٔ مورد انتظار برای کشف است و به معنی اثبات وجود تمام ویژگی‌ها در checkout فعلی نیست. `ROUTE_CATALOG_TEMPLATE.csv` باید فقط از سورس و runtime واقعی پر شود.

- `EXPECTED_MODULES.csv`: فهرست دامنه‌های قابل بررسی؛ وضعیت اولیه `DISCOVERY_REQUIRED`.
- `ROUTE_CATALOG_TEMPLATE.csv`: هر route/screen/overlay یافته‌شده یک ردیف.
- `CROSS_MODULE_CONTRACTS.csv`: مالکیت داده و قراردادهای هماهنگی بین بخش‌ها.
- `INTEGRATION_TEST_MATRIX.csv`: سناریوهای پایه برای تکمیل بر اساس قابلیت‌های واقعی.
- `TRACEABILITY_MATRIX_TEMPLATE.csv`: لینک requirement → module → route → code → tests → evidence.
- `TASK_BACKLOG.csv`: کارهای قابل‌ردیابی و معیار Done.
- `AGENT_FILE_OWNERSHIP.csv`: الگوی تخصیص فایل؛ با ownership محلی پروژه تطبیق داده شود.
- `DONE_DEFINITION.csv`: تعریف وضعیت‌های خروجی و gateهای پایان.

`DISCOVERY_REQUIRED` را به‌معنای نقص قطعی محصول تفسیر نکن. فقط می‌گوید وجود/پیاده‌سازی/قابلیت باید در repo هدف بررسی شود.
