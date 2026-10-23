# بنچمارک XPay و اپلیکیشن‌های مالی مشابه

## XPay مشخص‌شده برای این بررسی
منبع: https://afgprogrammer.com/ui-kits/flutter-xpay-fintech-digital-wallet-ui-kit
طبق صفحهٔ فروشنده، این Flutter UI kit دارای 44 screen در 14 ماژول، بیش از 35 route، تم روشن/تاریک، dashboard، account list/detail، contacts، transfer/request money، QR، exchange، card list/add، budgets، invoices، notifications، profile، rewards و settings است. مهم‌تر اینکه صفحهٔ فروشنده می‌گوید داده‌ها mock هستند و API، پرداخت واقعی، QR scanner و biometric باید به سرویس واقعی وصل شوند.

## چه چیزهایی از XPay قرض بگیریم — به‌عنوان الگو نه کد
- پوشش screen journey و page inventory نسبتاً جامع.
- اجزای قابل‌بازتولید و الگوی موفقیت مشترک.
- واضح بودن transaction history، filter chips، state badges و account details.
- ایجاد budget/invoice و reward flows به‌عنوان ماژول‌های مستقل.
- پوشش Light/Dark از ابتدا.

## چه چیزهایی را کپی/انتقال ندهیم
- GoRouter kit نباید سبب مهاجرت اجباری از GetX شود.
- mock data و UI-only success نباید وارد flows واقعی شود.
- فرم افزودن کارت با دریافت PAN/CVV توسط اپ نباید به عنوان الگوی ذخیره کارت واقعی کپی شود؛ از tokenization/issuer flow موردتأیید استفاده شود.
- پالت یا کارت‌های بصری XPay عیناً کپی نشوند؛ برند، assets، فاصله‌ها و هویت اختصاصی eCardo حفظ شود و مجوز assetها رعایت شود.
- 44 screen آن را coverage benchmark بدانید، نه معیار کافی برای 99 route eCardo.

## مقایسه محصولی
| مرجع | الگوهای UX برای بررسی | چه چیزی برای eCardo مفید است | محدودیت |
|---|---|---|---|
| XPay Flutter UI Kit | 44 screen، onboarding، accounts، payments، exchange، cards، budgets، invoices | پوشش صفحات و الگوهای reusable | mock data؛ نیازمند license و backend |
| Wise | شفافیت exchange quote، هزینه و transfer flow | fee/rate clarity و summary پیش از تأیید | دسترس‌پذیری features بسته به کشور/محصول |
| Revolut | dashboard چندخدمتی، cards، spending controls | گروه‌بندی سرویس‌ها و quick actions | قابلیت‌های زیاد ممکن است پیچیدگی ایجاد کند |
| Monzo Pots | تفکیک هدف/بودجه و موجودی | sub-wallet/goal metaphor اگر با محصول تطابق دارد | محصول/قابلیت‌ها منطقه‌ای است |
| N26 | حساب، کارت و بینش مالی | ساده‌سازی account navigation | دسترسی بازار و features منطقه‌ای |
| PayPal | send/request money و status tracking | تأیید گیرنده، رسید و status clarity | payment rails متفاوت |
| Coinbase / Kraken | انتخاب دارایی/شبکه و crypto warnings | asset/network clarity و confirmation | الگوی UI به معنی تأیید سرویس یا صلاحیت بازار نیست |
| Trust Wallet / MetaMask | آدرس، chain selection، fee/gas و signing context | تفکیک شبکه/دارایی و هشدار اشتباه شبکه | self-custody متفاوت با cloud custodial eCardo |

## معیار تحلیل screenshot
برای هر flow، 1–5 امتیاز برای discoverability، hierarchy، وضوح مبلغ، clarity هزینه، error recovery، loading/pending feedback، accessibility، locale، cognitive load و visual consistency ثبت کنید. هر امتیاز باید همراه screenshot و توضیح باشد؛ امتیاز کلی بدون evidence ثبت نشود.

## یادداشت license
XPay UI kit تجاری است و باید license فعلی قبل از خرید/استفاده بررسی شود. حتی با مجوز، integration و بازطراحی مستقل لازم است. کد یا تصاویر kit را بدون مجوز در repository قرار ندهید.
