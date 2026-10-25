# CAPABILITY_STATUS.md — وضعیت قابلیت‌های P0 بک‌اند (ecardo_userapp_v1)

| موضوع | مقدار |
|---|---|
| تاریخ ممیزی | 2026-10-24 |
| **نوع ممیزی** | **code-inspection (بازبینی کد) — sandbox/E2E اجرا نشده است.** هیچ درخواست HTTP واقعی، تست قرارداد، تست یکپارچگی یا تست منفی امنیتی در این ممیزی اجرا نشد. |
| `backend_repo` | **ecardo-backend@feat/uiux-v180-backend — SHA `04a7ec8601fff2c6a2a8ed67773ddbb6718be415`** (تأیید در همین سشن با `git rev-parse HEAD` و `git branch --show-current`) |
| `client_repo` | ecardo_userapp_v1 (Flutter) |
| محدودیت محیط | Flutter و PHP روی ماشین ممیز نصب نیستند؛ فقط خواندن فایل، grep و git خواندنی مجاز بود. تمام ادعاها با «مسیر فایل:شماره خط» سند شده‌اند. |
| فایل‌های هم‌نشین | `FEATURE_BACKEND_COVERAGE.csv` (۶۰ ردیف) • `API_CONTRACT_REGISTER.csv` (۱۴ ردیف P0 مالی) • `BACKEND_GAPS.csv` (۹ ردیف: ۸ گپ OPEN + ۱ تأیید مثبت) |

---

## ۱. روش راستی‌آزمایی (چه چیزی در همین سشن انجام شد)

- **بازخوانی مستقیم کد بک‌اند** در SHA فوق: `routes/api/user.php` (کامل)، `routes/payment.php` (کامل)، `routes/web.php:1-45`، `routes/api.php` (بخش‌های ۱۴–۵۳، ۱۹۵–۲۷۹، ۳۶۰–۴۱۵)، `routes/api/agent.php`، `routes/api/merchant.php`، `routes/admin.php:209-215`، `bootstrap/app.php:1-60`، `modules/Addons/VirtualCards/routes/web.php`، کنترلرهای `TransferMoneyController`، `ExchangeController`، `AddMoneyController`، `CashoutController`، `WithdrawController`، `StatusController`، `IpnController` (بخش‌های کلیدی)، `ProPaymentController` (خطوط متدها)، `GeneralController` (خطوط متدها)، `EpayController` (خطوط متدها)، `KycController` (خطوط متدها)، `CardController` (خطوط متدها)، `BeneficiaryController`/`WithdrawAccountController` (خطوط متدها)، سرویس‌های `TransferMoneyService`، `ExchangeService`، `AddMoneyService` (validate)، `CashoutService` (validateCashout)، `GatewaySandbox`، `GatewayWebhookProcessor`، `ApiResponseTrait`، منابع `TransferResource`/`ExchangeResource`، و `app/Traits/Payment.php:108-162`.
- **بازخوانی نمونه‌ای سمت کلاینت**: `api_path.dart`، `network_service.dart`، `routes.dart`، `transfer_controller.dart`، `exchange_controller.dart`، `transfer_history_controller.dart`، `fee_ecardo_rate_source.dart`، `epay_card_controller.dart` + grep کل `lib/` برای callerهای `transferHistoryEndpoint`، `exchangeHistoryEndpoint` و `epay`.
- **grep تأییدی**: نبودِ هرگونه `passcode` در `TransferMoneyController.php` و `TransferMoneyService.php` (خروجی خالی — exit 1).
- **اجرایی که انجام نشد** (و در CSVها `NOT_RUN` علامت خورده): تست sandbox، تست E2E، تست قرارداد، تست یکپارچگی، تست‌های منفی امنیتی (cross-user، امضای IPN جعلی و…). اجرای PHP/Flutter روی این ماشین ممکن نبود؛ صحتِ اجراییِ کد فقط با کدخوانی سند شده است.

---

## ۲. جدول خلاصهٔ قابلیت‌های P0

| قابلیت | دامنه | Verdict | مبنای verdict |
|---|---|---|---|
| انتقال وجه (Transfer) | transfer | **BACKEND_IMPLEMENTED** | فلوی کامل دو سمت (کلاینت↔بک‌اند) با شواهد مسیر:خط — §۳ |
| تبدیل ارز (Exchange) | exchange | **BACKEND_IMPLEMENTED** | فلوی کامل دو سمت با شواهد مسیر:خط — §۴ |
| واریز (Deposit/Add-money/Cashout/IPN) | deposit | **NOT_ASSESSED (این اجرا)** | فقط ثبت روت‌ها و هندلرها + قواعد اعتبارسنجی add-money/cashout در `FEATURE_BACKEND_COVERAGE.csv`؛ فلوی سرتاسری کلاینت راستی‌آزمایی نشد. گپ‌های امنیتی دامنه در `BACKEND_GAPS.csv`. |
| برداشت (Withdraw) | withdraw | **NOT_ASSESSED (این اجرا)** | هندلر `WithdrawController` کامل کدخوانی شد (روت، اعتبارسنجی، اسکوپ مالکیت، lockForUpdate، لجر) و قراردادش در `API_CONTRACT_REGISTER.csv` سند شد؛ اما فلوی UI سمت کلاینت در این اجرا trace نشد. |
| کارت‌های مجازی (Cards) | cards | **NOT_ASSESSED (این اجرا)** | فقط ثبت روت‌ها و خطوط هندلر (ماژول VirtualCards + ePay) در `FEATURE_BACKEND_COVERAGE.csv`. |
| KYC | kyc | **NOT_ASSESSED (این اجرا)** | فقط ثبت روت‌ها و خطوط هندلر در `FEATURE_BACKEND_COVERAGE.csv`. |

> قابلیت‌های NOT_ASSESSED در این سند یعنی «در این اجرا فلوی سرتاسری‌شان راستی‌آزمایی نشد» — نه اینکه پیاده نشده‌اند. ادعای پیاده‌شدن فقط برای transfer و exchange با شواهد دو سمت ثبت می‌شود.

---

## ۳. انتقال وجه (Transfer) — verdict: BACKEND_IMPLEMENTED

**خلاصه (fa):** فلو «انتقال وجه» در هر دو سمت کامل و پیوسته است. مسیر کلاینت: Route «/transfer_route» (`routes.dart:63`) با هندلر (`routes_handler.dart:177-178`) به صفحهٔ TransferScreen (`routes_config.dart:163`) می‌رسد که TransferController را Get.put می‌کند (`transfer_screen.dart:37`) و در استپ تأیید، transferAmount را صدا می‌زند (`transfer_review_step_section.dart:350`). کنترلر سه endpoint را از طریق NetworkService (Dio در `network_service.dart:30`؛ get:1086، post:1163) با baseUrl «https://ecardo.ir/api» (`api_path.dart:3`) فراخوانی می‌کند: `GET /user/transfer/config` (خط 152)، `GET /user/transfer/lookup-recipient` (خط 209) و `POST /user/transfer` با بدنهٔ account_number/amount/wallet_id/passcode (خطوط 433-448). در بک‌اند، prefix «api/user» (`bootstrap/app.php:29-32`) به routeهای `user.php:121-125` می‌رسد که همان سه endpoint را به TransferMoneyController@config/store/lookupRecipient وصل می‌کند؛ store سرویس `TransferMoneyService::transferMoney` (خط 23-88) را صدا می‌زند که در تراکنش دیتابیسی با lockForUpdate، دو رکورد Transaction ارسال/دریافت (`Txn.php:41`)، کاهش/افزایش موجودی کیف‌پول و ثبت لجر دوبل (خطوط 295-340) را اتمیک انجام می‌دهد.

### ۳.۱ شواهد سمت بک‌اند (بازخوانی‌شده در SHA 04a7ec8601)

- **Prefix**: `bootstrap/app.php:29-32` — `Route::prefix('api/user')` با middleware `auth:sanctum`, `app.version` → `routes/api/user.php`.
- **Routes** (`routes/api/user.php:121-125`): `122` GET transfer/config → `config`؛ `123` GET transfer/lookup-recipient → `lookupRecipient` (throttle:60,1)؛ `124` POST transfer/ → `store` (kyc.feature:transfer + idempotency + throttle:60,1)؛ `125` GET transfer/history → `history`.
- **Controller** (`app/Http/Controllers/Api/TransferMoneyController.php`): `config()` 25-57 (تنظیمات transfer_minimum/maximum/daily_limit/charge/charge_type از setting())؛ `store()` 59-77 → validateTransfer (خط 61) سپس transferMoney (خط 67)، پاسخ TransferResource برای sender_transaction + receiver_transaction (73-76)؛ `history()` 79-115 (paginate از getTransferHistory)؛ `lookupRecipient()` 222-248 (`User::user()->where('account_number')` خط 232؛ پاسخ name/account_number/avatar/is_verified).
- **منطق/پایداری داده** (`app/Services/TransferMoneyService.php`): `transferMoney` 23-88 — `DB::beginTransaction` (28)، `lockForUpdate` روی کیف فرستنده یا کاربر (33-35)، checkAvailability KYC (38)، findRecipient (44)، calculateTransferAmounts + charge (50, 133-168)، validateDailyLimit (56)، validateSenderBalance (62)، processTransfer (68)، commit (74) / rollBack (78). `processTransfer` 255-346: Txn->new ارسال SendMoney (259-274) و دریافت ReceiveMoney (276-291)، کاهش/افزایش موجودی کیف (295, 304؛ مسیر کیف پیش‌فرض 307-309)، ثبت دوبل LedgerService (312-340، fail-loud با re-throw). `validateTransfer` 406-442 (account_number exists:users، amount numeric gt:0). `getTransferHistory` 444-470 (فیلتر TxnType SendMoney/ReceiveMoney محدود به user_id).
- **شاهد پایداری**: `app/Facades/Txn/Txn.php:20-44` — ساخت `App\Models\Transaction` و `$transaction->save()` (خط 41).

### ۳.۲ شواهد سمت کلاینت (ecardo_userapp_v1)

- Route: `lib/src/app/routes/routes.dart:63` — `BaseRoute.transfer = "/transfer_route"`؛ هندلر `routes_handler.dart:177-178`؛ صفحهٔ `routes_config.dart:163` = TransferScreen.
- Screen: `lib/src/presentation/screens/transfer/view/transfer_screen.dart:37` (Get.put کنترلر)؛ خطوط 48-51 فراخوانی fetchTransferWallets/fetchTransferConfig/fetchBeneficiary در init. تریگر ثبت: `sub_sections/transfer_review_step_section.dart:350` `await controller.transferAmount()` (retry پس‌کد در :414). Binding: `app_bindings.dart:290-293`.
- Controller: `transfer_controller.dart` — fetchTransferConfig GET `ApiPath.transferConfigEndpoint` (151-153)؛ lookupRecipient GET `.../lookup-recipient?account_number=…` (207-210، debounce در 90-96)؛ transferAmount POST `ApiPath.userTransferEndpoint` با بدنهٔ {account_number, amount, wallet_id, passcode?} (433-448).
- Dio: `api_path.dart:3` baseUrl `https://ecardo.ir/api`؛ `:109` '/user/transfer/config'؛ `:110` '/user/transfer'. `network_service.dart:30` `final Dio _dio = Dio();`؛ get در :1086؛ post در :1163-1174. URLهای نهایی: `GET https://ecardo.ir/api/user/transfer/config`، `GET …/api/user/transfer/lookup-recipient`، `POST …/api/user/transfer` — همگی با روت‌های بک‌اند (`user.php:122-124`) تطبیق داده شد.

### ۳.۳ نکات صادقانهٔ این قابلیت

1. **passcode در مسیر transfer بک‌اند پردازش نمی‌شود**: کلاینت فیلد passcode می‌فرستد (`transfer_controller.dart:440-443`) اما grep در `TransferMoneyController.php` و `TransferMoneyService.php` هیچ پردازشی نشان نداد (اجرای grep در همین سشن، خروجی خالی). فیلدِ صرفاً کلاینت‌محور است (برخلاف exchange که passcode سمت سرور چک می‌شود — `ExchangeService.php:108-129`).
2. **GET /user/transfer/history در بک‌اند روت شده (`user.php:125`) ولی اپ هیچ caller ای ندارد** (grep کل `lib/`؛ ثابت `transferHistoryEndpoint` فقط در `api_path.dart:111` تعریف شده). تاریخچهٔ انتقال اپ از `GET /user/transactions?type=Send Money` می‌آید (`transfer_history_controller.dart:84-87`).

---

## ۴. تبدیل ارز (Exchange) — verdict: BACKEND_IMPLEMENTED

**خلاصه (fa):** فلو تبدیل ارز در هر دو سمت به‌طور کامل پیاده‌سازی و با شاهد مسیر:خط ردیابی شد. زنجیرهٔ کلاینت: دکمه‌های صفحهٔ اصلی (`action_button_section.dart:54`) → Route `/exchange_route` (`routes.dart:69`) با ExchangeBinding (`routes_handler.dart:199-203`) → صفحهٔ ExchangeScreen (`routes_config.dart:169`) که ExchangeController را Get.find می‌کند (`exchange_screen.dart:36`) → دکمهٔ تأیید در مرحلهٔ Review (`exchange_review_step_section.dart:421-425`) → `exchangeWallet()` در کنترلر (`exchange_controller.dart:658`) که در خط 699-701 از طریق NetworkService.post، فراخوانی Dio واقعی `_dio.post` (`network_service.dart:1163-1174`) را به `POST /user/exchange` (`api_path.dart:122`، baseUrl در `api_path.dart:3`) می‌فرستد؛ URL نهایی `https://ecardo.ir/api/user/exchange` دقیقاً با روت بک‌اند (`user.php:157` → `ExchangeController@store` خط 55 → `ExchangeService::exchange` خط 19 با تراکنش DB، lockForUpdate، ثبت Transaction و لجر دولدر LedgerService) تطبیق کامل دارد.

### ۴.۱ شواهد سمت بک‌اند (بازخوانی‌شده در SHA 04a7ec8601)

- **Mount**: `bootstrap/app.php:29-32` با prefix «api/user» + middleware «api, auth:sanctum, app.version».
- **Routes** (`routes/api/user.php:153-160`): `154` GET exchange/config؛ `155` GET exchange/rate (throttle:30,1)؛ `156` POST exchange/calculate (throttle:30,1)؛ `157` POST exchange/ (kyc.feature:exchange + idempotency + throttle:60,1)؛ `158` GET exchange/history؛ `159` GET exchange/{id}.
- **Controller** (`app/Http/Controllers/Api/ExchangeController.php`): `config()` 24-53؛ `store()` 55-73 (validateExchange سپس exchange، پاسخ ExchangeResource)؛ `history()` 75-109 (Validator 77-84 + paginate 98)؛ `show()` 111-127؛ `getExchangeRate()` 167-209 (`CurrencyService::convert` خط 188؛ ارز ناموجود → 422 در 180-184).
- **منطق/پایداری داده** (`app/Services/ExchangeService.php`): `exchange()` 19-98 با `DB::beginTransaction` 61 / commit 67 / rollBack 92؛ slippage guard نرخ (±2٪) 41-49؛ `validateTransactionPasscode` (EX-04، ضد بایپس) 108-129؛ `checkAvailability` 131-146؛ `calculateExchangeAmounts` 148-211 با اسکوپ user_id روی UserWallet (رفع IDOR/EX-01، خطوط 162-164 و 179-181)؛ گارد شارژ `guardCharge` 232-244؛ سقف روزانه `validateDailyLimit` 285-324؛ `processExchange` 348-462: lockForUpdate روی کاربر 351 و کیف‌ها 365-386، re-check موجودی داخل تراکنش 353-377، decrement/increment 362/376/380/391، `Transaction::create` 395-408 (TxnType::Exchange، TxnStatus::Success)، لجر دوبطرفه LedgerService (exchange_out/exchange_in) 411-456؛ `validateExchange` 493-539؛ `getExchangeHistory` 541-556 (فیلتر user_id + TxnType::Exchange).
- **Endpointهای جانبی فلو**: `/api/user/transactions` → `user.php:34` → `DashboardController@transactions` (فیلتر type با default که type=Exchange را می‌گیرد)؛ `/api/convert/...` → `api.php:210` → `GeneralController@convertCurrency` (`GeneralController.php:549`).

### ۴.۲ شواهد سمت کلاینت (ecardo_userapp_v1)

- ورود فلو: `Get.toNamed(BaseRoute.exchange)` در `presentation/screens/home/view/sub_sections/action_button_section.dart:54`.
- Route: `routes.dart:69` («/exchange_route») → `routes_handler.dart:199-203` → `routes_config.dart:169` = ExchangeScreen (`exchange_screen.dart:36`).
- تریگر تأیید (Swipe): `exchange_review_step_section.dart:421-425` → `controller.exchangeWallet()`.
- Controller: `exchange_controller.dart` — `exchangeWallet()` 658-805؛ ساخت requestBody 682-695 (شامل amount/from_wallet/to_wallet/expected_rate/passcode)؛ فراخوانی 699-701: `NetworkService().post(endpoint: ApiPath.exchangeWalletEndpoint)` → `POST /user/exchange` (`api_path.dart:122`) → URL کامل `https://ecardo.ir/api/user/exchange`.
- Dio: `network_service.dart:1125` → `_dio.post` 1163-1174 (هدر Idempotency-Key در 1156-1159).
- endpointهای پشتیبان فلو: `GET /user/exchange/config` (`exchange_controller.dart:279-281` ← `api_path.dart:121`)، `GET /user/wallets?exchange` (خط 452-454 ← `api_path.dart:65`)، `GET /convert/{amount}/{to}/{sep}/{from}` برای نرخ تبدیل (380-386 ← `api_path.dart:28-34`)، `GET /convert` برای کارمزد (342-347)، `GET /get-currencies` (544-546).
- **نرخ زندهٔ نمایشی از سرویس خارجی fee.ecardo.ir می‌آید، نه از ecardo-backend**: `FeeEcardoRateSource` — `GET https://fee.ecardo.ir/api/v1/rates` (`fee_ecardo_rate_source.dart:92` برای baseUrl و `:153` برای مسیر `/api/v1/rates`). endpoint اختصاصی بک‌اند `GET /api/user/exchange/rate` در اپ کاربر مصرف نمی‌شود.

### ۴.۳ نکات صادقانهٔ این قابلیت

1. نرخ زندهٔ نمایشی از fee.ecardo.ir است (خارج از ecardo-backend) — `fee_ecardo_rate_source.dart:92,153`.
2. ثابت `exchangeHistoryEndpoint=/user/exchange/history` در کلاینت تعریف شده (`api_path.dart:123`) ولی **بلااستفاده است** (grep کل `lib/`)؛ اپ تاریخچه را از `/user/transactions?type=Exchange` می‌خواند (`exchange_history_controller.dart:79-82`) در حالی که `GET /api/user/exchange/history` و `{id}` در بک‌اند موجودند.
3. کلاینت فیلدهای اضافه (rate، total_amount، charge و…) در بدنهٔ POST می‌فرستد که بک‌اند فقط `expected_rate` (slippage guard، خطوط 41-49) و `passcode` (108-129) را مصرف می‌کند.
4. صحتِ اجرایی کد با کدخوانی سند شده؛ **هیچ تستی اجرا نشد** و هیچ فایلی تغییر نکرد.

---

## ۵. گپ‌ها و ریسک‌ها (خلاصه)

۹ ردیف در `BACKEND_GAPS.csv` — هر ۹ مورد با بازخوانی کد در SHA `04a7ec8601...` تأیید شدند (status = CONFIRMED_IN_CODE):

| شناسه | اولویت | موضوع |
|---|---|---|
| GAP-001 | P0 | `/status/success` عمومی؛ اعتبار فقط با decrypt بدون تأیید درگاه |
| GAP-002 | P0 | IPN fail-open در نبود سکرت (`IpnController.php:45-54`) |
| GAP-003 | P0 | IPNهای بدون امضا/با binding ضعیف (mollie/perfectmoney/binance/coinremitter) |
| GAP-004 | P0 | OTP بدون throttle + ثبت تکراری api/pay/* با دو middleware stack |
| GAP-005 | P1 | سکرت هاردکد `ecardo-email-secret-2026` در InternalTravelNotifyController |
| GAP-006 | P1 | اشتراک سکرت deploy گیت‌هاب با کنترل maintenance (Artisan down/up) |
| GAP-007 | P0 | Gateway sandbox: Success کردن تراکنش واقعی بدون auth با گیتِ setting + token |
| GAP-008 | P1 | `/site-cron` عمومی فقط با throttle:60,1 |
| GAP-009 | P2 | **تأیید مثبت**: auth:admin روی گروه‌های ادمین API + webhook گیت‌هاب fail-closed |

## ۶. تصحیح دادهٔ اینونتوری (ثبت برای شفافیت)

مسیر روت‌های ePay در اینونتوری ورودی ممیزی `/api/user/epay/...` ثبت شده بود؛ ثبت واقعی در `routes/api.php:249` زیر prefix صرفِ `epay` است یعنی مسیر درست **`/api/epay/...`** است. کلاینت نیز همین را صدا می‌زند (`api_path.dart:56-58`: '/epay/cards'، '/epay/cards/issue'، '/epay/cards/topup'؛ مصرف‌کننده: `epay_card_controller.dart:31,53,90`). در `FEATURE_BACKEND_COVERAGE.csv` مسیر اصلاح‌شده ثبت و مغایرت در ستون blocker درج شده است. برای `epay/deposit/*` هیچ مصرف‌کننده‌ای در ecardo_userapp_v1 یافت نشد (grep کل `lib/`).

---

*این سند صرفاً نتیجهٔ بازبینی کد است؛ برای هر claim اجرایی (تست قرارداد، E2E، تست منفی امنیتی) باید اجرای مجزا و مکمل انجام شود — ستون‌های `sandbox_test`/`contract_test_ref`/`integration_test_ref` در CSVها همه `NOT_RUN` هستند.*

---

## ۷. نتایج ممیزی‌های دامنه‌ای MP-023..MP-027 (ادغام ۲۰۲۶-۱۰-۲۴)

> این بخش در ادغام ۲۰۲۶-۱۰-۲۴ (تسک‌های MP-023..MP-029) به این سند **افزوده شد**؛ بندهای ۱-۶ دست‌نخورده ماندند. **verdictهای این بخش جایگزین وضعیت «NOT_ASSESSED (این اجرا)» جدول §۲ برای دامنه‌های deposit/withdraw/cards/kyc می‌شوند** (transfer/exchange در §۳/§۴ بدون تغییر معتبرند). منبع: مواد ممیزی تسک (خروجی ایجنت‌های ممیز MP-023..MP-027) + راستی‌آزمایی نمونه‌ای خطی در همین سشن ادغام (§۹). شمارش جدید فایل‌های هم‌نشین پس از این ادغام: `FEATURE_BACKEND_COVERAGE.csv` **۱۰۹ ردیف** (+۴۹)، `API_CONTRACT_REGISTER.csv` **۲۷ ردیف** (+۱۳)، `BACKEND_GAPS.csv` **۵۷ ردیف** (+۴۸).

### ۷.۱ واریز/Add-money (MP-023) — verdict کل: BACKEND_IMPLEMENTED (با ۲ مورد CLIENT_ONLY و ۱ مورد MOCK_ONLY)

| قابلیت | Verdict | شاهد کلیدی (مسیر:خط) |
|---|---|---|
| لیست متدهای واریز GET /user/add-money?currency= | BACKEND_IMPLEMENTED | user.php:49 → AddMoneyController.php:45-68 |
| ثبت واریز خودکار POST /user/add-money (JSON → redirect_url) | BACKEND_IMPLEMENTED | AddMoneyController.php:16-43 → AddMoneyService.php:24-191 |
| ثبت واریز دستی POST /user/add-money (multipart با manual_data) | BACKEND_IMPLEMENTED | AddMoneyService.php:56,133-159 |
| تاریخچهٔ واریز GET /user/transactions?type=all-deposit | BACKEND_IMPLEMENTED | user.php:34 → DashboardController.php:76-107 |
| راستی‌آزمایی وضعیت پرداخت GET /user/payment-status/{tnx} (S-024) | BACKEND_IMPLEMENTED | user.php:109 → PaymentStatusController.php:21-105؛ کلاینت web_view_screen.dart:182 |
| درگاه میزبان ProPay و OTP (/pro-pay/* و /api/pay/*) | BACKEND_IMPLEMENTED | payment.php:80-90 → ProPaymentController.php؛ caller کلاینت dynamic_password_screen.dart:80-83 |
| درگاه‌های ایرانی شاپرک (melli/saman/pasargad/ipg) + IPN | BACKEND_IMPLEMENTED | payment.php:35-37 → IpnController.php:441/475/502 |
| IPN جهانی درگاه‌ها (/ipn/* شامل crypto و چینی) | BACKEND_IMPLEMENTED | payment.php:14-28 → IpnController.php (با ریسک fail-open — SEC-2) |
| کارت‌های Epay/PayCardo (لیست/صدور/شارژ) | BACKEND_IMPLEMENTED | api.php:251-253 → EpayController.php:34/49/71 → EpayService.php:116-272 |
| واریز کیف Epay (/epay/deposit/wallets، methods، store) | BACKEND_IMPLEMENTED | api.php:256-258 → EpayController.php:118-283 (بدون caller در Flutter) |
| آدرس واریز رمزارز TRON/USDT | BACKEND_IMPLEMENTED | user.php:43 → CryptoWalletController.php:38-90؛ کلاینت crypto_deposit_bottom_sheet.dart:156-162 |
| شارژ کارت با کیف/درگاه IRR | BACKEND_IMPLEMENTED | VirtualCards web.php:21-22 → CardController.php:80/138 → CardOrderService::topUp:175-289 |
| گیت امنیتی واریز: پین‌کد تراکنش/بیومتریک در مرحلهٔ تأیید | **CLIENT_ONLY** | add_money_review_step_section.dart:50-97؛ AddMoneyService بدون passcode؛ deposit_passcode_status فقط اطلاع‌رسانی (GeneralController.php:167) |
| پرداخت سندباکس درگاه (شبیه‌سازی موفق/ناموفق) | **MOCK_ONLY** | payment.php:53-71 (test-payment env-gated؛ china-payment بدون گارد env)؛ MelliTxn.php:58-66 mode=test |
| کیف‌ها برای انتخاب واریز GET /user/wallets | BACKEND_IMPLEMENTED | user.php:39 → WalletController.php:21 |

### ۷.۲ Withdraw/برداشت (MP-024) — verdict کل: BACKEND_IMPLEMENTED (هر ۱۰ قابلیت)

| قابلیت | Verdict | شاهد کلیدی |
|---|---|---|
| ثبت درخواست برداشت — user app | BACKEND_IMPLEMENTED | user.php:150 → WithdrawController.php:25 (Validator :40-43؛ IDOR :52-53؛ Transaction :125) |
| ثبت برداشت — agent app | BACKEND_IMPLEMENTED | agent.php:73 (بدون throttle — GAP-027) |
| ثبت برداشت — merchant app | BACKEND_IMPLEMENTED | merchant.php:75 (بدون throttle — GAP-027) |
| لیست/جستجو/صفحه‌بندی حساب‌های برداشت | BACKEND_IMPLEMENTED | user.php:147 → WithdrawAccountController.php:115 |
| ایجاد حساب برداشت (فرم داینامیک + آپلود فایل) | BACKEND_IMPLEMENTED | WithdrawAccountController.php:154 (store) |
| ویرایش حساب برداشت | BACKEND_IMPLEMENTED | :205 (update)؛ کلاینت POST+_method=put |
| حذف حساب برداشت | BACKEND_IMPLEMENTED | :219 (destroy) |
| دریافت متدهای برداشت (بر پایهٔ ارز کیف) | BACKEND_IMPLEMENTED | user.php:144 → :247 |
| تاریخچهٔ برداشت (فیلتر status/txn) | BACKEND_IMPLEMENTED | user.php:34 → DashboardController.php:76 (گپ چیپ Failed→Pending — GAP-026) |
| پنل ادمین: pending + actionNow (تأیید/رد) | BACKEND_IMPLEMENTED | admin.php:210-213 → Backend/WithdrawController.php:214/254/262 |

### ۷.۳ کارت‌ها (MP-025) — verdict کل: BACKEND_IMPLEMENTED برای ۹ فلو؛ **CLIENT_ONLY برای سقف/PIN/تعویض و کلید پرداخت اینترنتی**

| قابلیت | Verdict | شاهد کلیدی |
|---|---|---|
| لیست کارت‌های مجازی | BACKEND_IMPLEMENTED | VirtualCards web.php:18 → CardController.php:96-101؛ کلاینت virtual_card_controller.dart:34-66 |
| صدور کارت legacy | BACKEND_IMPLEMENTED | store :103-115 → CardService.php:20,34؛ کلاینت create_virtual_card_controller.dart:697-758 |
| سفارش کارت محصول‌محور (issue) | BACKEND_IMPLEMENTED | web.php:16 → CardOrderService::create:30-170؛ کلاینت createIrrCard:390-483 |
| جزئیات کارت + BsiCards | BACKEND_IMPLEMENTED | show :117-123 + alias web.php:20؛ کلاینت :339-388 |
| freeze/unfreeze کارت | BACKEND_IMPLEMENTED | updateStatus :125-136 → BsiCards.php:80-94 (HTTP واقعی)؛ کلاینت :169-190,391-428 |
| topup کارت | BACKEND_IMPLEMENTED | irr-topup/topup :80-94/138-160 → CardOrderService::topUp:175-289؛ کلاینت :431-597 |
| تراکنش‌های کارت | BACKEND_IMPLEMENTED | transactions :162-206؛ کلاینت virtual_card_transaction_controller.dart:17-79 |
| درخواست کارت فیزیکی | BACKEND_IMPLEMENTED | فلگ request_physical در card-orders (CardOrderService.php:83-89,436)؛ روت اختصاصی web.php:32 بدون caller |
| کارت‌های Epay/PayCardo | BACKEND_IMPLEMENTED | EpayService::issueFromWallet:116-198 / topupFromWallet:203-260 (DB::transaction) |
| سقف خرید/PIP/تعویض کارت | **CLIENT_ONLY** | spending-limits/change-pin/replace در هیچ route بک‌اند نیستند (grep خالی — §۹) → 404 همیشگی |
| کلید پرداخت اینترنتی کارت | **CLIENT_ONLY** | toggleOnlinePayments فقط RxBool محلی؛ بدون فیلد در CardController.php:536-574 |
| AddMoney/Withdraw/KYC/P2P/Bill/auth (تأیید متقاطع ممیز کارت‌ها) | BACKEND_IMPLEMENTED | همان §۷.۱/۷.۲/۷.۴/۷.۵؛ مواد MP-025 |
| Travel اپ موبایل | **API_DECLARED_ONLY** | travel_api_repository.dart:12 → سرویس جدای trip.ecardo.ir خارج از ecardo-backend |

### ۷.۴ KYC (MP-026) — verdict کل: BACKEND_IMPLEMENTED (هر ۶ قابلیت)

| قابلیت | Verdict | شاهد کلیدی |
|---|---|---|
| kyc.index — GET /user/kyc?for=user | BACKEND_IMPLEMENTED | user.php:184 → KycController.php:25 |
| kyc.submit_legacy — POST /user/kyc (multipart) | BACKEND_IMPLEMENTED | KycController.php:41 |
| kyc.history — GET /user/kyc/history | BACKEND_IMPLEMENTED | user.php:182 → :143 (submitted_data :146-152) |
| kyc.rejected_data — GET /user/kyc/rejected-data | BACKEND_IMPLEMENTED | user.php:183 → :163 |
| kyc_level levels/status/submit | BACKEND_IMPLEMENTED | user.php:208-213 → KycLevelController.php:34/92/133 (+badge :80-86 بدون caller) |
| kyc.settings_gating (kyc.feature/kyc.level) | BACKEND_IMPLEMENTED | EnsureKycFeature.php:19؛ CheckKycLevel.php:39؛ fail-open تایل‌ها عمدی (GAP-043) |

### ۷.۵ P2P و دامنه‌های باقی (MP-027)

| قابلیت | Verdict | شاهد کلیدی |
|---|---|---|
| P2P (admin_p2p و سمت کاربر) | BACKEND_IMPLEMENTED | P2PTrading web.php:16-62 (PluginGuard + api/user/p2p)؛ کلاینت api_path.dart:218-257 |
| Bill (Flutterwave) | BACKEND_IMPLEMENTED | api.php:216 + user.php:59-61 → BillController → BillService.php:39 (گپ‌های GAP-050/051) |
| Travel (هتل/پرواز/eSIM سفر + taxi) | BACKEND_IMPLEMENTED (سمت وب) | api.php:287-324 + modules/Addons/Travel؛ اپ موبایل → API_DECLARED_ONLY (سرویس جدا §۷.۳) |
| auth/OTP (login، OTP بی‌رمز، 2FA، forgot/reset) | BACKEND_IMPLEMENTED | api.php:51-178؛ گپ 2FA data.token — GAP-054 |
| profile (تنظیمات کاربر) | BACKEND_IMPLEMENTED | user.php:171 → SettingsController.php:25 (گپ GAP-056) |
| notifications (لیست و خواندن) | BACKEND_IMPLEMENTED | GeneralController.php:529-547 (پارامتر مردهٔ for=user — GAP-055) |

گپ‌های تفصیلی هر دامنه در `BACKEND_GAPS.csv` ردیف‌های GAP-010..GAP-057 ثبت شده‌اند.

---

## ۸. تأیید امنیتی مستقل ۲۰۲۶-۱۰-۲۴ (SEC-1..SEC-5)

راستی‌آزمایی مستقل امنیتی روی یافته‌های `BACKEND_GAPS.csv` (GAP-001..GAP-007) انجام شد — **صرفاً code-inspection؛ هیچ فیکسی اعمال نشد** (توصیه‌ها ثبت شدند). جزئیات کامل شواهد و حداقلِ فیکس هر مورد در `ecardo_userapp_v1/docs/quality/SECURITY_CONFIRMATIONS_2026-10-24.md`.

| شناسه | موضوع | Verdict تأیید مستقل | Severity | نگاشت گپ |
|---|---|---|---|---|
| SEC-1 | `/status/success` عمومی؛ اعتبار کیف فقط با decrypt بدون تأیید درگاه | **confirmed** | high | GAP-001 |
| SEC-2 | IPN بدون سکرت fail-open (`IpnController.php:45-54`) | **nuanced** | high | GAP-002 (+GAP-015) |
| SEC-3 | IPNهای بدون امضا/binding ضعیف (mollie/perfectmoney/binance/coinremitter) | **confirmed** | high | GAP-003 |
| SEC-4 | OTP بدون throttle + ثبت تکراری api/pay/* با دو middleware stack | **confirmed** | high | GAP-004 (+GAP-014) |
| SEC-5 | سکرت هاردکد `ecardo-email-secret-2026` (fallback در InternalTravelNotifyController/GithubDeployWebhookController) | **confirmed** | high | GAP-005/GAP-006 |

نکتهٔ اجرایی SEC-4: تأیید نهایی عدم تداخل روت‌ها باید با `php artisan route:list` **روی سرور** انجام شود (نه PC کاربر — قانون ۱ `AGENTS.md`)؛ در این ادغام اجرا نشد (§۹).

---

## ۹. یادداشت‌های ادغام ۲۰۲۶-۱۰-۲۴ (راستی‌آزمایی این سشن)

۱. **راستی‌آزمایی نمونه‌ای خطی** — در همین سشن ادغام، این موارد با `sed`/`grep` مستقیماً بازخوانی و تأیید شدند: `routes/api/user.php:49,142-150,182-184,208-213`؛ `AddMoneyService.php:130-140`؛ `WithdrawController.php:25,38-44,52-53`؛ `routes/api/agent.php:64-73`؛ `routes/api/merchant.php:68-75`؛ `modules/Addons/VirtualCards/routes/web.php:14-32`؛ grep سراسری `spending-limits`/`change-pin`/`replace` در `routes/`+`app/`+`modules/` (خروجی خالی — تأیید CLIENT_ONLY)؛ `IpnController.php:36-72,146-160`؛ `routes/payment.php:53-71,80-91`؛ `routes/api.php:236-244`؛ `routes/web.php:16-22`؛ `MelliTxn.php:54-68`؛ `AlipayTxn.php:33-45`؛ `MollieTxn.php:24-25`؛ `P2PTrading/routes/web.php:16-33,43-62`؛ `BillService.php:29-32,66-80`؛ `StatusController.php:14-26`؛ `PaymentOtpService.php:108-155`؛ `GithubDeployWebhookController.php:188-193`؛ `InternalTravelNotifyController.php:18-22,65-68`؛ `KycLevelController.php:13-21,78-88`؛ `GeneralController.php:165-173,529-547`؛ سمت کلاینت: `network_service.dart:89,209-211,311-316,352-355`، `api_path.dart:3,56-58,75-76,101-106`، `virtual_card_details_controller.dart:77,98,130`، `virtual_card_security_controls.dart:2005,2368`، `add_money_review_step_section.dart:50-60`، `withdraw_controller.dart:78-88,331-332`، `crypto_deposit_bottom_sheet.dart:152-166`، `web_view_screen.dart:80-88,182`، `travel_api_repository.dart:10-14`، `taxi_api_service.dart:288-298,353-360`، `demo_account_service.dart:1042-1061`، `two_factor_auth_controller.dart:48-54`.
۲. **دو تصحیح خطی نسبت به مواد تسک**: در `modules/Addons/VirtualCards/routes/web.php` روت‌های freeze/unfreeze در **خطوط ۲۸-۲۹** (مواد: 30-31) و physical-request در **خط ۳۲** (مواد: 34) هستند — در ردیف‌های F-CRD-015/018 و GAP-034 تصحیح و ثبت شد.
۳. **اجراهای انجام‌نشده**: `php artisan route:list` (تقدم روت‌های تکراری — باید روی سرور اجرا شود، قانون ۱ `AGENTS.md`)؛ همهٔ تست‌های sandbox/E2E/قرارداد/امنیتی (ستون‌های `sandbox_test`/`contract_test_ref`/`integration_test_ref` همچنان `NOT_RUN`)؛ بازخوانی `vendor/` (GAP-028)؛ مخزن `ecardo-travel` (GAP-036).
۴. **تغییر فایل‌ها در این ادغام**: فقط ۵ فایل مستند — `FEATURE_BACKEND_COVERAGE.csv` (+۴۹ ردیف)، `API_CONTRACT_REGISTER.csv` (+۱۳ ردیف)، `BACKEND_GAPS.csv` (+۴۸ ردیف)، همین فایل (افزودن §۷-§۹)، `docs/integration/CONTRACT_REGISTRY.csv` (ویرایش جراحی ۴ ردیف + ۳ ردیف جدید — MP-029) و فایل جدید `docs/quality/SECURITY_CONFIRMATIONS_2026-10-24.md`. هیچ فایلی در `lib/` و هیچ کدی تغییر نکرد (پس نیاز به `python -m graphify update .` بابت تغییر کد پیش نیامد — قانون ۲ `AGENTS.md`).
