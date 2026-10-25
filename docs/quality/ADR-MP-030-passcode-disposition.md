# ADR — تکلیف passcode انتقال وجه (MP-030)

- **وضعیت:** پیشنهادی — منتظر تصمیم صاحب پروژه
- **تاریخ:** 2026-10-24
- **تصمیم‌گیرنده:** صاحب پروژه (مالک محصول)
- **مرجع:** GATE_ASSESSMENT_2026-10-24.md (پرسش باز MP-030)، BACKEND_GAPS.csv، CAPABILITY_STATUS.md

## زمینه

راستی‌آمایی مستقل زنجیرهٔ کامل فلوهای مالی (فاز ۰-۲ بستهٔ p3) نشان داد:

- **کلاینت** در فلوهای Transfer و Exchange (و واریز) فیلد `passcode` را به سرور می‌فرستد:
  - Transfer: `lib/src/presentation/screens/transfer/controller/transfer_controller.dart:433-448` (بدنهٔ `{account_number, amount, wallet_id, passcode?}`)
  - Exchange: `lib/src/presentation/screens/exchange/controller/exchange_controller.dart:682-701`
- **بک‌اند** فقط در Exchange آن را می‌سنجد: `app/Services/ExchangeService.php:108-129` (`validateTransactionPasscode` — EX-04، ضدبایپس).
- در مسیر Transfer هیچ بررسی passcode وجود ندارد (`TransferMoneyController.php` و `TransferMoneyService.php` — جستجوی سراسری بی‌نتیجه) و در واریز، flag فقط از `get-settings` اعلام می‌شود و سمت سرور اعمال نمی‌شود (`AddMoneyService.php:119-191`).

یعنی امروز «تأیید دومرحله‌ای تراکنش» در حالت‌های مختلف یا تزئینی است یا فقط در Exchange واقعی — ناهماهنگی امنیتی و تجربهٔ کاربری.

## گزینه‌ها

### گزینهٔ A — پیاده‌سازی سمت سرور (پیشنهاد)
`validateTransactionPasscode` (همان پیاده‌سازی اثبات‌شدهٔ ExchangeService) در `TransferMoneyService::transferMoney` پیش از `processTransfer` و در مسیرهای واریزِ حساس اعمال شود؛ کلاینت دست‌نخورده می‌ماند چون از قبل فیلد را می‌فرستد.
- **مزیت:** یکدستی امنیتی با Exchange؛ تغییر کلاینت صفر؛ سد واقعی در برابر دستگاهِ ربوده‌شده.
- **هزینه/ریسک:** تغییر رفتار برای کاربرانی که passcode ندارند (نیاز به مسیر خطای واضح)؛ تست رگرسیون سناریوهای Transfer؛ bump نسخه و QC طبق قواعد ریپو.

### گزینهٔ B — حذف فیلد از کلاینت
فیلد `passcode` از requestهای Transfer/واریز حذف شود؛ احراز هویت session کافی تلقی شود.
- **مزیت:** ساده‌تر؛ صادقانه‌تر از وضعیت فعلی (ادعای نادرستِ «تأیید دومرحله‌ای» حذف می‌شود).
- **هزینه/ریسک:** سطح امنیت Transfer از Exchange پایین‌تر می‌ماند؛ برای اپ مالی، حذف لایهٔ تأیید تراکنش خلاف الگوی رقبا (Wise/Revolut) است.

### گزینهٔ C — موکول به بازبینی محصول (وضعیت فعلی)
MP-030 در `BLOCKED` می‌ماند.

## توصیه

**گزینهٔ A.** پیاده‌سازی کوچک است (یک فراخوانی سرویس موجود)، کلاینت از قبل سازگار است و ناهماهنگی امنیتی را دقیقاً در جایی می‌بندد که بستهٔ p3 «رفع CTAهای بی‌عملکرد و success نمایشی» می‌خواهد. اجرا مشمول همان قواعد فیکس بک‌اند است: فقط با مجوز صریح صاحب پروژه، commit محلی، بدون push.

## پیامدها

- گزینهٔ A: تسک به backlog (فاز ۲) اضافه می‌شود؛ پس از اعمال، `FLOW_CATALOG.csv` و `BACKEND_GAPS.csv` به‌روز شوند + تست رگرسیون Transfer الزامی.
- گزینهٔ B: تغییر کلاینت مستلزم هماهنگی با ۲۹ فایل تغییرمحلی موجود و bump نسخهٔ userapp است.
