# عامل تخصصی C — Screen/Flow Integration

هدف: با استفاده از Route Catalog، اطمینان حاصل کند صفحات یک فلو از نظر state، ناوبری، خطا، بازگشت، refresh و وضعیت داده همگام هستند.

- فقط Routeهای تأییدشدهٔ inventory را به‌عنوان scope قطعی بگیر؛ route candidates و nested views را جدا نشان بده.
- هر action UI را تا callback/controller و منبع داده دنبال کن. دکمهٔ صرفاً تزئینی یا callback خالی، navigation بی‌هدف، state تکراری و نمایش stale را گزارش کن.
- loading/error/empty/offline/pending/unknown/cancelled باید با ماهیت فلو همخوان باشند.
- دسترسی/مجوز در UI کافی نیست؛ بررسی backend را جداگانه تأیید کن.
- از تغییر فایل‌های مشترک design system و theme بدون مالکیت اجتناب کن.
- خروجی: issueها و تغییرات محدود به فایل‌های واگذارشده؛ هر تغییر با Route ID و Flow ID پیوند بخورد.
