# بنچمارک XPay و محصولات مشابه

## XPay دقیقاً کدام محصول است؟
در این تحقیق، مرجع اصلی XPay محصول تجاری «XPay - Mobile Banking E Wallet Flutter App» از AppDevsX در CodeCanyon است: https://codecanyon.net/item/xpay-mobile-banking-e-wallet-flutter-app/37419851. صفحهٔ فعلی فروشنده در زمان بررسی می‌گوید 70+ screen، مدیریت وضعیت با GetX، چندزبانه/RTL، send/transfer، withdraw/deposit، QR، bills، transaction log، support و profile؛ تاریخ نسخهٔ v4.0.0 آن 28 ژانویهٔ 2026 و Last Update صفحه 29 ژانویهٔ 2026 است. این محصول تجاری است و license باید پیش از reuse بررسی شود. چند محصول متفاوت «XPay» نام دارند؛ اگر منظور کیت دیگری است، آن را با این مورد یکی ندانید. این برنامه از XPay به‌عنوان coverage/interaction benchmark استفاده می‌کند، نه اجازهٔ کپی UI/assets و نه تأیید اینکه تمام قابلیت‌های محصول با بک‌اند تولیدی eCardo سازگارند.

## قواعد بنچمارک
- از هر محصول فقط task مشخصی را مقایسه کنید: نمایش balance، شروع transfer، بررسی fee، کارت، recovery از خطا، transaction status.
- از برند، asset، متن یا layout pixel-identical کپی نکنید؛ الگوها را به هویت eCardo بازطراحی کنید.
- Screenshot را با date/device/locale/theme/flow ثبت کنید؛ نمره بدون evidence پذیرفته نیست.

## ماتریس محصولات
| محصول | جریان‌های قابل مطالعه | ارزش برای eCardo | محدودیت/احتیاط |
|---|---|---|---|
| XPay Flutter UI Kit | dashboard, transfer, request, bills, cards, statements | پوشش صفحه و composition | تجاری؛ مجوز لازم؛ ممکن است UI نمونه باشد نه backend واقعی |
| Wise | چندارزی، exchange quote و fee clarity | شفافیت نرخ/هزینه | قابلیت‌ها حسب بازار متفاوت است |
| Revolut | dashboard چندخدمتی، cards و spending controls | grouping سرویس‌ها و home personalization | خطر پیچیدگی بیش‌ازحد |
| Monzo | account/budget/pots | هدف‌های مالی و بودجه‌بندی | قابلیت‌ها/بازارهای خاص |
| N26 | account/card activity | سادگی ناوبری حساب و کارت | بازار/محصول متفاوت |
| PayPal | send/request/payment status | تأیید گیرنده و receipts | rail و سیاست‌های پرداخت متفاوت |
| Coinbase/Kraken | crypto asset/network, fee, confirmation | وضوح network/asset و اخطارها | custodian و قابلیت منطقه‌ای متفاوت |
| Trust Wallet/MetaMask | address, chain, signature context | network correctness و confirmation | self-custody با cloud custodial یکسان نیست |

## رتبه‌بندی مؤلفه‌های مرجع
برای هر جریان، امتیاز ۱ تا ۵ در این معیارها: task discoverability، information hierarchy، fee clarity، user control، error prevention، recovery clarity، accessibility، locale quality، visual consistency، perceived performance. هر نمره باید screenshot و توضیح داشته باشد.
