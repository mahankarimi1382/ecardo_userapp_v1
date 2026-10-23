# استاندارد ارتقای Home و Dashboard

## هدف صفحه
کاربر باید سریع بفهمد: پول/حسابش چه وضعی دارد، مهم‌ترین اقدام مجاز چیست، چه تراکنشی نیاز به توجه دارد.

## سلسله‌مراتب پیشنهادی
1. Header امن: greeting/context، profile/notifications، privacy control.
2. Balance hero: total/selected account، currency، hidden balance، updated/stale status.
3. Quick actions با label روشن: Transfer، Exchange، Add funds، Cards؛ فقط اقدامات واقعاً مجاز نمایش داده شوند.
4. Alerts نیازمند اقدام: KYC incomplete، pending/reconciliation، کارت مسدود/منقضی، system maintenance.
5. Recent activity با status، amount، date، source/destination و View all.
6. Insights یا rewards بعد از اطلاعات و actionهای اصلی، نه بالاتر از آن‌ها.

## ریسک‌ها
- balance مجموعی را بدون توضیح بین ارزهای غیرقابل‌جمع نشان ندهید؛ equivalent باید نرخ/زمان/منبع داشته باشد.
- balance قدیمی/آفلاین با برچسب واضح نمایش داده شود.
- اکشن‌های بدون callback یا feature خاموش CTA نشان ندهند.
- هیچ KPI یا نموداری با mock data در build واقعی نباشد.
- privacy toggle به صورت accessible control، نه فقط آیکون.

## حالات لازم
first-time/empty; loading; partial data; stale cache; offline; API error; account locked; KYC restricted; pending transaction alert; success refresh.

## تست پذیرش
- 3-second comprehension test برای موجودی و اقدام اصلی.
- tap targets حداقل 48dp Android/44pt iOS.
- text scaling 200% بدون overflow.
- RTL/LTR و 6 locale.
- screenshot light/dark برای screen sizes تعریف‌شده.
- no mock data/no dead CTA.
