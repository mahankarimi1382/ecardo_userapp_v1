# قواعد غیرقابل‌نقض منطق مالی

این سند UX و mobile client را هدف می‌گیرد؛ backend/ledger موجود باید جداگانه بررسی شود. UI جایگزین کنترل‌های سرور، دفترکل یا reconciliation نیست.

## مبلغ و ارز

1. `double` برای محاسبهٔ مبلغ/کارمزد/نرخ/rounding مرجع استفاده نشود. از integer minor units یا decimal دقیق مطابق contract واقعی استفاده کنید.
2. precision و scale از currency/asset metadata معتبر بیاید؛ decimal places را hardcode نکنید.
3. amount parsing از locale presentation جدا باشد: «۱٬۲۳۴٫۵۰» و «1,234.50» باید به ورودی نرمال و بدون ambiguity تبدیل شوند.
4. مقدار نمایشی را دوباره parse نکنید تا submit شود؛ model عددی معتبر نگهداری کنید.
5. منفی، صفر، precision بیش‌ازحد، separatorهای مبهم، overflow و max/min باید قبل submit و در server validation شوند.
6. rounding rule برای هر عملیات/asset صریح و با test برداری پوشش داده شود؛ خاموش round کردن به ضرر کاربر ممنوع.

## Quote و fee

- نرخ، منبع نرخ، زمان ایجاد، expiry و شرایط quote از backend/provider بیاید.
- breakdown میان platform fee، provider fee، network fee، tax/spread (فقط اگر واقعی/موجود است) تفکیک شود.
- نمایش minimum amount، total debit، amount received، fee currency و recipient gets به صورت بی‌ابهام باشد.
- اگر quote منقضی شود، عملیات مجدداً quote و confirmation جدید لازم دارد.
- هیچ fee یا rate fallback در UI/local constants استفاده نشود مگر backend policy رسمی و نسخه‌بندی‌شده آن را تعریف کرده باشد.

## انتقال و اجرای مجدد

- قبل از submit تمام مقصد/مبدا/asset/network/amount/fee/total/quote/recipient برای تأیید قابل مشاهده باشند.
- submit دوگانه از tap، بازگشت صفحه یا درخواست timeout جلوگیری شود.
- timeout = outcome unknown؛ ابتدا status lookup با server transaction reference/idempotency key، سپس فقط در صورت proof مناسب retry.
- statusهای `pending`, `processing`, `unknown`, `reconciling` هرگز به `success` تبدیل نشوند.
- receipt تنها با شناسه/وضعیت/مقادیر معتبر server ساخته شود؛ اطلاعات ساختگی برای ظاهر زیبا ممنوع.

## Balance و دفترکل

- app state ممکن است stale باشد؛ timestamp/refetch و نشانگر stale باید در صورت لازم مشخص باشد.
- optimistic decrement فقط با تصمیم architecture/backend سازگار مجاز است و باید rollback/reconcile policy داشته باشد.
- client هیچ‌گاه balance نهایی یا authorization را تصمیم نمی‌گیرد.
- هر اختلاف balance/status نباید با mutation مخفی سمت کلاینت «اصلاح» شود؛ از authoritative refresh و support/reconciliation flow استفاده شود.

## ارز دیجیتال/شبکه

- asset + network باید جفت معتبر باشد؛ آدرس با chain/network/token و نوع آدرس سازگار باشد.
- آدرس یا QR از منبع authoritative بیاید؛ fallback یا hardcode ممنوع.
- حداقل برداشت/واریز، fee، confirmations، memo/tag و maintenance از backend/provider بیاید.
- شبکهٔ mismatch یا address invalid باید fail-closed باشد.
- هر محتوای clipboard/address باید در confirmation به‌صورت قابل‌بررسی نمایش داده شود.

## احراز هویت و passcode

- client هیچ قانون limit/lockout را مرجع نهایی نمی‌کند؛ server enforce می‌کند.
- missing passcode، incorrect passcode، locked account، expired session و service unavailable خطاهای متفاوت‌اند.
- retry loop یا درخواست رمز بی‌پایان ممنوع؛ resend/attempt counters باید سرور-محور و امن باشند.

## اثبات

برای هر قاعده: unit test دامنه، mapping خطا/وضعیت، widget state test و تست integration در صورت امکان. هر خطای P0 در قواعد بالا مانع تکمیل release خواهد بود.
