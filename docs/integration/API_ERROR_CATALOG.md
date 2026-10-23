# eCardo API Error Catalog & Normalization Reference

This catalog maps all HTTP response status codes, error codes, and exception types across eCardo backend services to safe, user-friendly client representations, eliminating raw SQL leaks and stack traces.

| HTTP Code | Error Key / Type | User-Facing Localized Behavior | Safe Action CTA | Logging Policy |
|---|---|---|---|---|
| **400** | `BAD_REQUEST` | فیلدهای ارسالی ناقص یا نامعتبر هستند. | بازبینی فیلدها | پیام در فرمت لاگ امن بدون اطلاعات کاربری |
| **401** | `UNAUTHORIZED` | نشست کاربری شما منقضی شده است. | ورود مجدد | تلاش برای Single-flight Token Refresh؛ در صورت شکست هدایت به Login |
| **403** | `FORBIDDEN` | دسترسی به این بخش نیازمند ارتقای سطح احراز هویت است. | ارتقای سطح KYC | نمایش بج سطح مورد نیاز بدون مسدودسازی برنامه |
| **404** | `NOT_FOUND` | رکورد، کاربر یا تراکنش مورد نظر یافت نشد. | بازگشت به فهرست | پیام واضح عدم وجود آیتم |
| **409** | `RATE_EXPIRED` | نرخ ارز یا کارمزد تغییر یافته یا منقضی شده است. | دریافت پیش‌فاکتور جدید | بنر هشدار نوسان نرخ و غیرفعال‌سازی دکمه پرداخت |
| **422** | `VALIDATION_ERROR` | استخراج پیام اولین فیلد نامعتبر (از طریق `fieldErrors`) | تصحیح فیلد مشخص | لاگ فیلدهای نامعتبر بدون مقادیر ورودی رمز و پین |
| **429** | `TOO_MANY_REQUESTS` | تعداد درخواست‌های شما بیش از حد مجاز است. لطفاً کمی صبر کنید. | غیرفعال‌سازی موقت CTA | ثبت زمان انقضای محدودیت نرخ (Rate Limit Window) |
| **500** | `SERVER_ERROR` | خطایی در پردازش رخ داده است. لطفاً دقایقی دیگر تلاش کنید. | تلاش مجدد | **پالایش کامل SQL، PDOException و مسیرهای داخلی سرور** |
| **502** | `BAD_GATEWAY` | سرویس‌های بانکی یا ارتباطی موقتاً در دسترس نیستند. | تلاش مجدد | عدم نمایش نام درگاه یا زیرساخت خارجی |
| **503** | `SERVICE_UNAVAILABLE`| سرویس در حال به‌روزرسانی است. | تلاش مجدد بعد از مدتی | نمایش صفحه یا بنر حالت نگهداری موقت |
| **504** | `GATEWAY_TIMEOUT` | وضعیت تراکنش نامشخص است. لطفاً پیش از تلاش دوباره، تاریخچه را بررسی کنید. | استعلام وضعیت تراکنش | **انتقال به وضعیت Status.unknown؛ ممنوعیت اکشن Retry کور** |
| **TIMEOUT**| `Socket / Timeout` | زمان ارتباط با سرور پایان یافت. وضعیت در حال بررسی است. | بررسی تاریخچه حساب | **حفظ کلید Idempotency تا ۵ دقیقه و جلوگیری از تکرار خودکار** |
