# UX جریان‌های مالی حساس

## Transfer / P2P / Withdraw / Exchange / Payment / Gift
پیش از submit حداقل این اطلاعات باید قابل تأیید باشند: حساب مبدأ، گیرنده/مقصد، دارایی و ارز، مبلغ، هزینه‌های جداگانه، مبلغ نهایی، rate/quote expiry در تبدیل، محدودیت و سیاست امنیتی.

## حالات اجباری
- validation failed: inline error با پیشنهاد اصلاح
- passcode required: prompt محدود و کنترل‌شده؛ نه loop
- passcode invalid: تلاش مجدد محدود، clear distinction، server policy authoritative
- timeout/5xx: unknown/reconciling، status lookup پیش از retry؛ operation ID پایدار
- provider unavailable/country not supported: انتخاب را متوقف کن و توضیح بده
- insufficient funds: server validation نهایی؛ client check صرفاً راهنمای UX
- duplicate submit: disable interaction و idempotency سمت سرور
- reversed/refund: وضعیت مجزا از failed

## ممنوع
- optimistic success برای انتقال/صدور کارت/واریز رمزارز
- mock rate/fee/balance/provider eligibility در Release
- retry کور بعد از timeout
- float/double به‌عنوان source of truth مالی
- نمایش آدرس یا QR رمزارز قبل از backend-authenticated assignment
