# قرارداد وضعیت، خطا و API

## حداقل API contract dossier برای هر endpoint

- method/path/version و feature owner
- auth/scopes/permissions/KYC requirements
- request schema، currency/amount semantics، validation constraints
- response schema و nullable/optional fields
- success status و business status جداگانه
- backend error codes → semantic error category → localized key/action
- idempotency support/key lifecycle
- timeout/retry policy و rate limit
- pagination/order/filter consistency
- caching/ETag/freshness and invalidation
- correlation ID و safe logging rules
- mock/test fixtures و contract tests

## تفکیک HTTP و business status

HTTP 200 الزاماً به معنی transaction success نیست؛ response ممکن است `pending`, `rejected`, `requires_action` یا `unknown` برگرداند. از سوی دیگر، HTTP timeout به معنی آن نیست که سرور عملیات را دریافت نکرده. UI باید status business را از مدل پاسخ بگیرد و نتیجهٔ نامعلوم را با status lookup حل کند.

## Retry matrix (قاعدهٔ محافظه‌کارانه)

| عملیات | retry خودکار؟ | رفتار امن |
|---|---|---|
| GET/list/read | در صورت سیاست شبکه و idempotence، محدود | backoff و حفظ query state |
| دریافت quote | ممکن است quote تازه لازم باشد | quote قدیمی را به submit منتقل نکن |
| POST مالی | به‌طور پیش‌فرض خیر | idempotency/status lookup سپس تصمیم |
| تغییر card state | فقط با پشتیبانی idempotency یا status check | ابتدا وضعیت فعلی را بخوان |
| ساخت support ticket | بدون idempotency خیر | lookup یا duplicate detection |
| OTP send/resend | فقط طبق cooldown/limit سرور | timer UI جای policy سرور نیست |
| upload KYC/document | وابسته به upload contract | retry با upload ID/checkpoint اگر پشتیبانی شود |

## نمایش stale/offline

- timestamp تازه‌بودن داده را ذخیره کن اگر در contract موجود است.
- offline بودن را با خطا یا stale label واقعی معرفی کن.
- فقط عملیات read-only که policy اجازه می‌دهد ممکن است از cache استفاده کند.
- عملیات مالی offline submit نشود، مگر سیستم backend/local queue رسمی، auditشده و مورد تأیید داشته باشد؛ این فرض را از روی UI نساز.
