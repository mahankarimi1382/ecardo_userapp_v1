# Auth، Security و KYC UX

## Auth / OTP / Passcode
- step indicator و هدف هر مرحله واضح باشد؛ timer واقعی باشد؛ resend rate limit را پنهان نکند.
- خطای OTP، PIN اشتباه، PIN تنظیم‌نشده، حساب قفل، session expired و server unavailable پیام و مسیر recovery متفاوت داشته باشند.
- password/OTP/PIN هیچ‌وقت در analytics, crash logs, screenshot artifacts یا local queue قرار نگیرند.
- biometric UI با قابلیت واقعی دستگاه و policy backend هماهنگ باشد؛ toggle صرفاً ظاهری نباشد.

## Session & risky action
- قبل از انتقال پرریسک، identity و مقصد و مبلغ مجدداً تأیید شوند.
- در session expiry فرم‌های حساس به‌شکل ایمن پاک یا draft غیرحساس ذخیره شود.
- بعد از برگشت از background، قفل طبق threat model و policy واقعی اعمال شود.

## KYC
- فهرست مدارک، دلیل نیاز، فرمت/اندازه فایل، stateهای uploaded/reviewing/needs-correction/approved/rejected واضح باشد.
- upload قابل بازیابی باشد؛ duplicate submission و فقدان شبکه مدارک را دوبار ثبت نکند.
- feedback درباره رد مدرک actionable، امن و بدون افشای PII باشد.

## Security settings
- هر تنظیم توضیح دهد چه چیزی تغییر می‌کند و چه محدودیتی دارد.
- freeze/logout/revoke actions تأیید و receipt/audit reference داشته باشند.
- تغییرات امنیتی با پیام‌های مستقل از رنگ و با screen reader قابل فهم باشند.
