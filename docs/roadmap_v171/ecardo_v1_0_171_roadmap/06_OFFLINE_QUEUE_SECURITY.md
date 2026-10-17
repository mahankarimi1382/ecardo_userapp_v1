# Offline Queue — Security Contract

## تصمیم پیش‌فرض

صف آفلاین برای mutationهای مالی، authentication، KYC، گذرواژه، PIN، OTP، card data و هر payload حساس ممنوع است. برای تغییرات کم‌خطر نیز فقط endpointهایی queueable هستند که از نظر محصول idempotent، non-sensitive و قابل retry باشند.

## شکاف‌های مشاهده‌شده در نسخهٔ فعلی

File: [`offline_request_queue.dart`](https://github.com/mahankarimi1382/ecardo_userapp_v1/blob/main/lib/src/common/services/offline_request_queue.dart)

- allowlist prefix با `endpoint.contains(prefix)` تطبیق داده می‌شود.
- payload از `SharedPreferences` به‌صورت JSON خوانده/نوشته می‌شود.
- method هنگام enqueue ثبت می‌شود، ولی `flush` در کد فعلی `net.post` صدا می‌زند.
- پس از exhausted شدن retries، item می‌تواند با retries=max داخل صف باقی بماند.
- payload schema و TTL/max-age به اندازهٔ کافی محدود نشده‌اند.

## Required design

### 1. Exact route/method tuple

یک constant registry به شکل map استفاده شود:

```text
POST /api/user/settings/profile   -> schema ProfilePreferencesPatchV1
POST /api/setup-fcm                -> schema FcmRegistrationV1
POST /api/change-language/{locale} -> schema ChangeLanguageV1
POST /api/mark-as-read-notification -> schema NotificationReadV1
```

فهرست بالا نمونهٔ پیشنهادی است؛ مسیر واقعی را با `ApiPath` و backend contract تطبیق دهید. کد نهایی باید URL را parse و فقط relative path مجاز با host خالی، query/fragment غیرمنتظره نداشته باشد. مسیر exact بعد از normalization مقایسه شود، نه substring. HTTP method را هم بررسی کنید.

### 2. Payload minimization

- فقط fieldهای موجود در schema مجازند؛ ناشناخته‌ها reject شوند.
- `password`, `pin`, `passcode`, `otp`, `token`, `authorization`, PAN/CVV, bank account, KYC document/image, money amount/recipient و هر financial intent همیشه ممنوع است.
- داده‌های profile مثل email/phone/address نیز PII هستند؛ در صف نگه‌داری آن‌ها باید نیاز واقعی، encryption-at-rest و retention تصویب شود. صرف «غیرمالی» بودن به معنی «غیرحساس» نیست.
- هر log از queue فقط تعداد item، route alias و error category را ثبت کند؛ payload خام ثبت نشود.

### 3. Persistence contract

اگر ذخیرهٔ آفلاین داده لازم است:
- encrypted storage یا رمزنگاری payload با کلید حفاظت‌شدهٔ سیستم‌عامل؛
- queue schema version؛
- max item count، max bytes و max age؛
- clear-on-logout فقط بعد از بررسی نیاز product/security؛
- corruption handling که خطا را metric کند و اطلاعات حساس را چاپ نکند؛
- no secrets in backup/export.

### 4. Retry/DLQ contract

- deterministic 4xx: به‌طور پیش‌فرض retry نشود؛ item failed بشود و دلیل sanitized ثبت شود.
- timeout/connection error: فقط برای endpointی که server-side idempotent است retry شود.
- max retries یا max age بعد از رسیدن به حد، item را از active queue به dead-letter/failed state منتقل کند؛ صف نباید بی‌نهایت item exhausted نگه دارد.
- برای endpointهایی که یک mutation سمت سرور می‌سازند، idempotency key باید از intent پایدار مشتق شود و در سرور حفظ شود.
- manual retry باید به معنای همان operation ID باشد، نه ساخت operation تازه.

### 5. Acceptance tests

- absolute URL با suffix مجاز رد شود.
- URL دارای query/fragment/path traversal یا casing ambiguity رد شود.
- `GET`, `PUT`, `PATCH`, `DELETE` خارج از tuple مجاز رد شوند.
- fieldهای password/PIN/OTP/token/card/amount همیشه reject شوند.
- payload بزرگ یا ناشناخته reject شود.
- retry پس از restart duplicate request نسازد.
- `maxRetries` item را به DLQ منتقل کند.
- flush همزمان دوباره اجرا نشود و duplicate connectivity events باعث request دوبل نشود.
- logout و account switch باعث ارسال دادهٔ user قبلی با credentials کاربر بعدی نشود.
