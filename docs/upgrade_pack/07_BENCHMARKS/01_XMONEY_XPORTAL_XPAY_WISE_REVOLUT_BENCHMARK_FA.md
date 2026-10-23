# بنچمارک محصولی eCardo: xMoney/xPortal، XPay، Wise، Revolut

## تفسیر نام Xmony
در جست‌وجوی منابع عمومی قابل استناد، نام دقیق «Xmony» به‌عنوان محصول مالی مستقل به‌طور مطمئن تأیید نشد. این سند به‌صورت شفاف xMoney و xPortal را به‌عنوان نزدیک‌ترین محصول مستند بررسی می‌کند. اگر مالک محصول لینک دیگری منظور دارد، benchmark باید از روی URL صحیح اصلاح شود.

## xMoney / xPortal
منبع رسمی پشتیبانی xMoney محصول xMoney را راهکار پرداخت Web3 با پشتیبانی fiat و crypto معرفی می‌کند و xPortal را یک superapp با crypto wallet و debit card توصیف می‌کند. این برای eCardo الهام در انسجام میان identity/account, wallet, payment, card و asset surfaces است؛ نه مدرک دربارهٔ implementation داخلی یا کیفیت UX هر صفحه.

**الگوهای قابل ارزیابی برای eCardo:**
- مسیر یکپارچه میان کیف پول، دارایی، کارت، پرداخت و فعالیت.
- مرزبندی روشن میان محصول پرداخت، کیف پول و featureهای Web3.
- معرفی state و eligibility قبل از هدایت به یک عملیات پولی.
- طراحی navigation بر اساس taskهای کاربر به‌جای فهرست سرویس‌های نامرتبط.

**چیزی که کپی نمی‌شود:** برند/لوگو، illustration، متن محصول، assets اختصاصی، page layout دقیق یا کد مالکیتی.

منبع: https://support.xmoney.com/en/articles/7944050-about-the-applications-products-and-services

## XPay commercial Flutter template
صفحهٔ CodeCanyon برای `XPay - Mobile Banking E Wallet Flutter App` از AppDevsX نسخهٔ `v4.0.0` در ۲۸ ژانویهٔ ۲۰۲۶ را در version history نمایش می‌دهد و صفحه در ۲۹ ژانویهٔ ۲۰۲۶ به‌روزرسانی شده بود. این مرجع را برای breadth صفحات/فلو و checklist قابلیت‌ها در نظر بگیر، نه به‌عنوان تضمین کد production یا معیار استاندارد امنیت.

- پیش از reuse کد، مجوز تجاری، scope مجاز و محدودیت redistribution را بررسی کن.
- سورس/assetهای template را بدون مجوز وارد repo نکن.
- تمام منطق مالی، API و امنیت آن باید مستقل ممیزی شود؛ template UI به‌معنی integration واقعی نیست.

منبع: https://codecanyon.net/item/xpay-mobile-banking-e-wallet-flutter-app/37419851

## Wise / Revolut — الگوبرداری از clarity و task completion
از محصولات مالی جاافتاده برای بررسی الگوها استفاده شود: شفافیت کارمزد و نرخ پیش از تأیید، تفکیک حساب/کارت/انتقال، status tracking، تاریخچهٔ قابل جست‌وجو و کنترل‌های امنیتی قابل فهم. قبل از ادعای مشخص دربارهٔ یک feature یا سیاست، از صفحهٔ رسمی جاری همان محصول و منطقهٔ مربوط evidence بگیر؛ availability و شرایط بانک/کشور متفاوت‌اند.

لینک‌های مرجع برای ارزیابی رسمی (نه اثبات یک رفتار مشخص):
- Revolut: https://www.revolut.com/
- Wise: https://wise.com/

## جدول معیار مقایسه

| بُعد | سؤال برای eCardo | Evidence موردنیاز |
|---|---|---|
| Task completion | چند قدم واقعی تا انجام task؟ | task study + screen recording با consent |
| Fee transparency | total debit و receive amount قبل submit روشن است؟ | review-screen audit + API contract |
| Status clarity | pending/unknown/failure/success تفاوت قابل درک دارد؟ | state matrix + tests |
| Product integration | کارت/کیف پول/تراکنش/رسید به هم متصل‌اند؟ | cross-module trace + runtime walkthrough |
| Security UX | sensitive action confirmation و recovery روشن است؟ | threat model + usability test |
| Localization | RTL، ارز/تاریخ و متن طولانی درست‌اند؟ | screenshot matrix + formatting tests |
| Trust | منبع نرخ/fee/status مشخص است؟ | API data lineage + evidence report |
| Accessibility | کنترل‌ها با screen reader و text scale کار می‌کنند؟ | automated + manual audit |

## معیار تصمیم‌گیری

هر ایدهٔ مرجع به یکی از سه وضعیت می‌رود: `ADOPT_PATTERN`, `ADAPT_WITH_ECARD0_BRAND`, `REJECT`. تصمیم باید با user problem، compatibility، test و ADR متکی باشد؛ «چون اپ دیگر دارد» برای افزودن feature کافی نیست.
