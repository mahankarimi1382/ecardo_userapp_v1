# استاندارد stateهای صفحه

برای هر route یک جدول state بنویسید. حداقل موارد زیر را بررسی کنید:

| State | رفتار UI | محدودیت مالی/امنیتی |
|---|---|---|
| Initial | skeleton یا placeholder ساختاری | مبلغ جعلی/صفر به‌عنوان مقدار واقعی نمایش داده نشود |
| Loading | progress واضح، CTA duplicate-blocked | timeout policy و cancelability روشن |
| Empty | توضیح معنی‌دار و CTA واقعی | action تنها اگر backend اجازه می‌دهد |
| Partial | داده‌های موجود + stale/missing indicator | اطلاعات قدیمی با current مخلوط نشود |
| Offline | cached data با زمان آخرین همگام‌سازی | عملیات مالی حساس queue نشود مگر قرارداد امن/مجاز باشد |
| Validation error | field-level متن واضح | raw exception یا stack trace نمایش داده نشود |
| 401/session expired | re-auth امن و بازگشت controlled | draft حساس پاک یا محافظت شود |
| 403/ineligible | توضیح دسترسی/صلاحیت و مسیر درخواست | محدودیت backend دور زده نشود |
| 409/conflict | reconcile state/refresh | submit دوباره کورکورانه انجام نشود |
| 422 domain error | پیام قابل اقدام + error code map | passcode loop یا retry نامحدود ممنوع |
| 429/rate limit | زمان انتظار اگر سرور می‌دهد | resend/submit تا قبل از زمان مجاز disabled |
| 5xx/timeout | Unknown/reconciling برای عملیات مالی | تا status lookup، تراکنش جدید نسازید |
| Pending | status واقعی و آخرین به‌روزرسانی | سبز/Success نمایش داده نشود |
| Success | فقط confirmation server | receipt با ID و دادهٔ authoritative |
| Failure/reversed | دلیل قابل فهم و next step | failure ambiguous با decline قطعی اشتباه نشود |
| Feature unavailable | maintenance/ineligible توضیح داده شود | provider/endpoint خیالی/Mock ارائه نشود |

## Design requirements
- خطا با عنوان قابل فهم، دلیل کوتاه و اقدام بعدی.
- Retry action تنها با callback و semantics مشخص.
- focus به خطا/عنوان تغییر کند؛ screen reader پیام را بخواند.
- هر state در screenshot/widget test و حالت‌های حساس در integration test پوشش داده شود.
