# Financial Operation Intent & Idempotency Contract

## 1. Invariant

برای هر اقدام مالی که کاربر تأیید کرده است، یک `operation_id` ثابت وجود دارد. retry همان عملیات باید همان ID را استفاده کند. یک اقدام جدید از کاربر، حتی با payload یکسان، `operation_id` جدید می‌گیرد. payload similarity به‌تنهایی مرز امن عملیات نیست.

## 2. Client state machine

```text
DRAFT
  -> CONFIRMED (create durable operation_id)
  -> SUBMITTING
       -> SUCCEEDED (canonical server result)
       -> REJECTED (deterministic 4xx with no commit)
       -> PENDING_UNKNOWN (timeout, connection loss, 5xx, app killed)
PENDING_UNKNOWN
  -> STATUS_RECONCILIATION (same operation_id)
       -> SUCCEEDED / REJECTED / STILL_PENDING / MANUAL_REVIEW
```

قانون: از `PENDING_UNKNOWN` با فشار مجدد دکمه، intent جدید نسازید. ابتدا status endpoint را برای `operation_id` قبلی صدا بزنید. یک CTA جداگانه برای «ایجاد عملیات جدید» فقط پس از تعیین وضعیت قبلی مجاز است.

## 3. Headers and body

- `Idempotency-Key`: UUID تصادفی از intent و پایدار across retry.
- `X-Operation-ID`: همان شناسهٔ intent برای traceability، در صورت توافق API.
- `X-Correlation-ID`: برای trace request; این شناسه با operation ID یا idempotency key یکی نیست.
- `X-Request-ID`: شناسهٔ هر HTTP attempt است؛ نباید تنها منبع identity برای تراکنش باشد.
- Body: مقدار money به minor units integer یا مدل decimal دقیق استاندارد؛ هرگز float binary را مرجع مبلغ قرار ندهید.

Backend باید canonicalize/hash درخواست را ثبت کند؛ اگر همان idempotency key با payload متفاوت استفاده شد، پاسخ deterministic conflict برگرداند و هیچ تراکنشی ثبت نکند.

## 4. Server-side minimum

جدول مفهومی:

- `scope`: tenant/user/account context
- `operation_id`: unique per scope
- `endpoint_or_operation_type`
- `request_hash`
- `state`: accepted/processing/succeeded/rejected/unknown/reversed
- `response_code`, `response_body_ref` (بدون token/PII غیرضروری)
- `created_at`, `updated_at`, `expires_at`
- `ledger_transaction_id` (در صورت ایجاد)

قید unique باید در دیتابیس تراکنشی اعمال شود. ایجاد operation record، ledger mutation و پاسخ قابل بازیابی باید transaction boundary مشخصی داشته باشد. اگر external provider در میان است، outbox/saga/compensation باید نتیجهٔ provider را reconciliation کند.

## 5. Client registry guidance

رجیستری در حافظه با 50 مورد و TTL پنج دقیقه‌ای فقط می‌تواند deduplication کوتاه‌مدت UI باشد، نه ضمانت نهایی تراکنش. حذف entry قدیمی نباید operation intent را فراموش کند. برای intentهای unknown باید storage محلی حداقلی یا بازیابی از backend وجود داشته باشد؛ ذخیرهٔ امن، retention و logout behavior مشخص شوند.

`jsonEncode(data).hashCode` را برای تشخیص intent استفاده نکنید. UUID operation ID مرجع باشد. اگر hash لازم است، از canonical JSON و SHA-256 استفاده کنید و hash را فقط برای جلوگیری از استفادهٔ اشتباه از همان key با payload دیگر به کار ببرید.

## 6. Required tests

1. Double tap همان intent → یک server operation/ledger debit.
2. Timeout قبل از server commit → retry same id resolves once.
3. Server commit، سپس response گم می‌شود → retry/status return همان نتیجه.
4. Server returns 500 after commit → same key, no second debit.
5. App force-kill پس از submit → startup lookup finds same operation.
6. Retry پس از TTL کلاینت → backend status lookup، نه new operation.
7. Registry capacity pressure → unresolved operation محفوظ می‌ماند.
8. Same idempotency key + different body → conflict, no mutation.
9. New user action with identical body → new operation ID.
10. Duplicate webhook/callback → financial result applied once.
11. Deterministic 422 with no operation created → safe recovery path is documented.
12. Multi-currency rounding, amount bounds, fee computation and exchange-rate lock tested server-side.

## 7. Owner sign-off

قبل از بستن `FIN-IDEM-01`, Flutter owner و backend/ledger owner باید قرارداد header، retention سرور، status endpoint، transaction boundary، payload mismatch policy و recovery workflow را امضا کنند. اگر بک‌اند فعلی این قابلیت‌ها را ندارد، تسک به‌عنوان `BLOCKED BY BACKEND` باقی بماند.
