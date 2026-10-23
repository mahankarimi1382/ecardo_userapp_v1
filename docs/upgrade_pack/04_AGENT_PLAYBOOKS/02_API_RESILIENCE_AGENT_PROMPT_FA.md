# عامل B — API integration و resilience

فقط scope فایل‌های تعیین‌شده را تغییر بده. قرارداد واقعی backend را از کد/docs/tests استخراج کن؛ payload یا status را حدس نزن. API error mapping، timeouts، cancellation، stale state، pagination، session refresh، request ID و safe logging را بررسی کن. POST مالی را خودکار retry نکن مگر backend contract، idempotency و test proof داشته باشد. Timeout بعد از submit را unknown/reconciling مدیریت کن. از GetX/Dio موجود استفاده کن مگر ADR و PoC تصویب شود. برای هر تغییر tests و contract matrix update کن؛ هیچ راز یا PII لاگ نکن؛ push/deploy نکن.
