# UX مشخصات عملیات مالی

شامل Transfer، P2P، Request Money، Exchange، Withdraw، Cash Out، Make Payment و Gift.

## الگوی مشترک
1. انتخاب منبع/حساب/ارز.
2. ورود مبلغ با precision و currency واضح.
3. انتخاب گیرنده/مقصد یا asset/network.
4. دریافت quote و محاسبه server-side.
5. صفحهٔ review: مقدار اصلی، feeها، total debit، recipient receives، نرخ/زمان quote، مقصد و هشدار برگشت‌ناپذیری.
6. احراز هویت/Passcode فقط مطابق policy معتبر backend.
7. submit با operation ID پایدار.
8. نمایش submitted/pending/confirmed/failed/unknown؛ اگر پاسخ مبهم است، status lookup نه retry کور.
9. receipt با reference و امکان مشاهدهٔ وضعیت.

## Exchange
- نرخ خرید/فروش، timestamp، expiry، fee/spread، round rules و receive amount آشکار باشد.
- quote expired → refresh + تأیید مجدد، هرگز rate قدیمی silent استفاده نشود.
- اگر passcode setting unavailable است، policy authoritative server بررسی شود؛ به‌جای حدس‌زدن، flow امن/fail-closed و پیام recovery تعریف شود.
- `422 passcode` باید با error code machine-readable تفکیک شود: missing, wrong, not-set, locked, expired policy. هیچ retry loop خودکاری بدون سقف نباشد.

## Transfer/withdraw/cashout
- مقصد و مالکیت آن قبل از تأیید نمایان باشد.
- هزینه‌های ثابت/درصدی/شبکه جدا نمایش داده شوند.
- پس از timeout، درخواست جدید نسازید تا وضعیت intent قبلی روشن شود.
- در برداشت به بانک، زمان تقریبی فقط اگر backend تامین کرده نمایش داده شود.

## پرداخت و گیفت
- merchant/recipient/total/fee/refundability واضح باشد.
- request money از transfer خارج از نظر state و authorization نگه داشته شود.
- double submit با idempotency و disable شدن دکمه مهار شود.

## حالت‌های آزمون
valid input; invalid precision; min/max; fee change; rate expired; policy missing; passcode wrong; passcode locked; network offline; response lost; 4xx; 5xx; duplicate event; session expired; recipient changed; insufficient funds.
