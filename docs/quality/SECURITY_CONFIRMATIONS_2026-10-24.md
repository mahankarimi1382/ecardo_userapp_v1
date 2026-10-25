# SECURITY_CONFIRMATIONS_2026-10-24.md — تأیید امنیتی مستقل یافته‌های ممیزی بک‌اند

| موضوع | مقدار |
|---|---|
| تاریخ | ۲۰۲۶-۱۰-۲۴ |
| نوع | **code-inspection — راستی‌آزمایی مستقل روی یافته‌های `docs/backend-audit/BACKEND_GAPS.csv` (GAP-001..GAP-007)**. هیچ درخواست HTTP، تست نفوذی، exploit یا فیکس اجرا/اعمال نشد. |
| مخزن | ecardo-backend (SHA پین ممیزی: `04a7ec8601fff2c6a2a8ed67773ddbb6718be415`) + راستی‌آزمایی نمونه‌ای روی working tree همین ورک‌اسپیس در تاریخ ۲۰۲۶-۱۰-۲۴ |
| وضعیت اجرا | **هیچ تغییری در کد اعمال نشد** — همهٔ بخش‌های «حداقلِ فیکس» صرفاً توصیه‌اند (طبق قواعد این اجرا: code-inspection فقط). |
| فایل‌های مرتبط | `docs/backend-audit/BACKEND_GAPS.csv` (گپ‌های نگاشت‌شده)؛ `docs/backend-audit/CAPABILITY_STATUS.md` §۸؛ `docs/backend-audit/FEATURE_BACKEND_COVERAGE.csv` (ردیف‌های F-DEP-*) |

---

## SEC-1 — `/status/success` عمومی؛ اعتبار کیف فقط با decrypt بدون تأیید درگاه

- **Verdict تأیید مستقل:** confirmed — **severity: high**
- **نگاشت:** GAP-001 (BACKEND_GAPS.csv)؛ ردیف پوشش F-DEP-015
- **شواهد (مسیر:خط):**
  - `ecardo-backend/routes/web.php:17-20` — گروه عمومی `status` با `Route::match(['get','post'], '/success', 'success')` (بازخوانی مستقیم در همین سشن: خطوط ۱۶-۲۲ دیده شد؛ success در خط ۱۸، cancel در خط ۱۹).
  - `ecardo-backend/app/Http/Controllers/StatusController.php:18-25` — `success()` مقدار `Crypt::decryptString($request->reftrn)` را بدون هیچ تأیید درگاهی به `paymentSuccess` می‌دهد (بازخوانی مستقیم ۱۴-۲۶ در همین سشن).
  - `ecardo-backend/app/Traits/Payment.php:113-159` — `paymentSuccess` با `Txn::update` و گارد alreadySuccess کیف را شارژ می‌کند (ثبت ممیزی قبلی؛ در این سشن بازخوانی نشد).
  - رشتهٔ encrypt شده در URL برای پرداخت‌کننده قابل دیدن ساخته می‌شود (`app/Livewire/Payment/SandboxPayment.php:27` — ثبت ممیزی قبلی) و صفحهٔ ساخت لینک موفق امضاشده (`routes/payment.php:53-59` — بازخوانی مستقیم: کامنت SECURITY FIX + گیت `app()->environment('local','dev','development','staging')` در خط ۵۸، روت در خط ۵۹) فقط local شده است؛ خود endpoint کماکان عمومی است.
- **حداقلِ فیکس (توصیه — اعمال نشد):** `/status/success` را display-only کنید — در `StatusController::success` به‌جای `return self::paymentSuccess($depositTnx);` فقط وضعیت txn را برگردانید و هر تغییر وضعیت/شارژ را به مسیرهای IPN دارای امضای راستی‌آزمایی‌شده (`IpnController`) یا verify سمت-سرور با API درگاه (مثلاً retrieve session استرایپ قبل از Success) منتقل کنید؛ برای درگاه‌هایی که IPN ندارند، قبل از `Txn::update` وضعیت پرداخت را از API خود درگاه استعلام بزنید. به‌عنوان لایهٔ مکمل حداقلی: `Route::match(['get'],...)` (حذف POST) و افزودن `->middleware('throttle:10,1')` روی گروه `routes/web.php:17-20`.
- **تست پذیرش پس از فیکس:** reftrn معتبرِ بدون پرداخت واقعی در تست منفی باید wallet را شارژ نکند.

## SEC-2 — IPN بدون سکرت fail-open

- **Verdict تأیید مستقل:** nuanced — **severity: high**
- **نگاشت:** GAP-002 (و ردیف جدید GAP-015 از ممیزی MP-023)
- **شواهد (مسیر:خط):**
  - `ecardo-backend/app/Http/Controllers/Frontend/IpnController.php:45-54` — `ensureVerified`: وقتی نه `IPN_SECRET_*` و نه `ipn_secret` درگاه تنظیم باشد، تابع `return null` می‌دهد و هیت فقط بر اساس فیلد status پردازش می‌شود (بازخوانی مستقیم ۳۶-۷۲ در همین سشن: کامنت ۳۶-۴۴، شاخهٔ بدون-سکرت ۵۰-۵۴، شاخهٔ `default => false` فقط با سکرت در ~۷۱).
  - کامنت کد خودش تصریح می‌کند هر ده درگاه امروز dormant هستند (status=0، بدون credential) — یعنی محافظت فعلی به عدم فعال‌بودن درگاه‌ها وابسته است.
- **چرا nuanced و نه plain confirmed:** شاخهٔ `default => false` (fail-closed وقتی سکرت هست) با SECURITY FIX 2026-10-01 درست شده و رفتار fail-open فقط در حالت «درگاه فعال بدون سکرت» رخ می‌دهد؛ ریسک واقعیِ امروز مشروط به فعال‌سازی درگاه بدون سکرت است، اما همین سناریو (فعال‌سازی عملیاتی فراموش‌شده) از مسیر پنل ادمین ممکن است.
- **حداقلِ فیکس (توصیه — اعمال نشد):** شاخهٔ بدون-سکرت را fail-closed کنید: در `IpnController.php` به‌جای `return null` در خط ۵۳، برای درگاه‌های غیر-dormant پاسخ 422/400 با پیام «gateway verification not configured» برگردانید (یا حداقل اگر gateway فعال است (status!=0) رد شود و فقط درگاه dormant مستثنا بماند). ضمناً وِرایفای سرور-سمت (re-fetch از API درگاه) را برای همهٔ handlerها الزامی کنید تا امنیت به وجود سکرت وابسته نباشد.
- **تست پذیرش پس از فیکس:** IPN بدون سکرت با payload جعلی باید رد شود؛ فعال‌سازی درگاه بدون سکرت باید بلاک/هشدار شود.

## SEC-3 — IPNهای بدون امضا / binding ضعیف (mollie / perfectmoney / binance / coinremitter)

- **Verdict تأیید مستقل:** confirmed — **severity: high**
- **نگاشت:** GAP-003
- **شواهد (مسیر:خط):**
  - `IpnController.php:148-159` — `mollieIpn`: payment از `Mollie::api()->payments()->get($request->id)` وریفای می‌شود اما `reftrn` تراکنش از خود درخواست (`$request->reftrn`) گرفته می‌شود نه از payment وریفای‌شده (بازخوانی مستقیم ۱۴۶-۱۶۰ در همین سشن)؛ در `modules/Payment/Mollie/MollieTxn.php:24-25` شناسهٔ txn صرفاً در `webhookUrl` کوئری‌استرینگ حمل می‌شود (بازخوانی مستقیم grep در همین سشن) — قابل جعل در بدنهٔ وب‌هوک.
  - `IpnController.php:161-188` — `perfectMoneyIpn` هیچ چک V2_HASH ندارد و فقط decrypt می‌کند (ثبت ممیزی قبلی؛ در این سشن بازخوانی نشد).
  - `IpnController.php:322-333` (coinremitter) و `:366-378` (binance) — در نبود سکرت مستقیم به فیلد status/bizStatus اعتماد می‌کنند (ثبت ممیزی قبلی؛ منطق ensureVerified این سشن بازخوانی شد).
- **حداقلِ فیکس (توصیه — اعمال نشد):**
  - **(الف) mollie** — هنگام create، شناسهٔ txn را در metadata پرداخت ذخیره کنید (`MollieTxn.php`) و در controller به‌جای `$request->reftrn` از metadata همان آبجکت fetch-شده بخوانید + amount/currency را با txn مقیاس کنید.
  - **(ب) perfectMoney** — V2_HASH را با `hash_hmac` مطابق مستندات PM (ترتیب فیلدها + Alternate Passphrase از credentials) قبل از `paymentSuccess` اعتبارسنجی کنید و PAYMENT_ID فرم را همسو با انتظار controller کنید (هر دو plaintext یا هر دو encrypted).
  - **(ج) coinremitter/binance** — به‌جای اعتماد به status، پس از دریافت webhook وضعیت را با فراخوانی API درگاه re-fetch و verify کنید (یا درگاه را تا پیاده‌سازی امضا بسته نگه دارید).
- **تست پذیرش پس از فیکس:** وب‌هوک با امضای غلط/بدون binding باید رد شود؛ شناسهٔ تراکنش فقط از پاسخ وریفای‌شده بیاید.

## SEC-4 — OTP بدون throttle + ثبت تکراری `api/pay/*` با دو middleware stack

- **Verdict تأیید مستقل:** confirmed — **severity: high**
- **نگاشت:** GAP-004 (و ردیف جدید GAP-014 از ممیزی MP-023)؛ ردیف‌های پوشش F-DEP-011..014
- **شواهد (مسیر:خط):** — همه در همین سشن بازخوانی مستقیم شد:
  - `ecardo-backend/routes/payment.php:84-87` — چهار ثبت POST در گروه **web بدون throttle**: `api/pay/verify-uid` (:84)، `api/pay/generate-otp` (:85)، `api/pay/request-otp` (:86)، `api/pay/verify-wallet` (:87)؛ خطوط GET `:88-90` (rates/gateways/qr-status) فقط همین‌جا هستند.
  - `ecardo-backend/routes/api.php:238,242-243` — همان مسیرها در گروه api **با throttle**: `pay/verify-wallet` throttle:10,1 (:238)، `pay/verify-uid` throttle:10,1 (:242)، `pay/generate-otp` throttle:5,1 (:243)؛ `request-otp` هیچ نسخهٔ throttled ندارد و controller هم throttle نمی‌کند (`ProPaymentController.php:230` — ثبت ممیزی قبلی).
  - دو middleware stack برای یک URL → برندهٔ ران‌تایم به ترتیب ثبت روت‌ها حساس است؛ **`php artisan route:list` در این اجرا اجرا نشد** (تقدم ران‌تایم UNKNOWN — فقط inspection). اجرای تأییدی باید روی سرور انجام شود (قانون ۱ `AGENTS.md`: هیچ وابستگی به PC کاربر).
  - کد خام OTP: مسیر `generateOtp` کد را در پاسخ برمی‌گرداند (مواد ممیزی؛ `PaymentOtpService.php:108-109` در همین سشن بازخوانی شد: کامنت «Does NOT return the code to web clients» فقط برای `generateAndNotify` است).
- **حداقلِ فیکس (توصیه — اعمال نشد):**
  1. حذف جراحی خطوط ۸۴-۸۷ `routes/payment.php` (ثبت‌های دوگانهٔ POST `api/pay/verify-uid|generate-otp|request-otp|verify-wallet`) تا نسخه‌های throttle دار `api.php` واحد و برنده باشند؛ روت‌های GET خطوط ۸۸-۹۰ که فقط در payment.php هستند بمانند.
  2. انتقال ثبت `pay/request-otp` به `routes/api.php` با `->middleware('throttle:5,1')`.
  3. برای بستن ریشه‌ای خطر: کد خام OTP در `generateOtp` فقط پشت `auth:sanctum` (کاربرِ خودِ حساب) برگردد — مسیر وب همان `requestOtp`/`generateAndNotify` را استفاده کند که کد را فقط FCM می‌فرستد (`PaymentOtpService.php:110-153` — بازخوانی مستقیم ۱۰۸-۱۵۵ در همین سشن).
  4. پس از اعمال، با `php artisan route:list` **روی سرور** عدم تداخل را تأیید کنید.
- **تست پذیرش پس از فیکس:** درخواست‌های متوالی به هر پنج مسیر api/pay/* باید 429 بگیرند؛ پاسخ OTP بدون auth نباید کد خام داشته باشد.

## SEC-5 — سکرت هاردکد `ecardo-email-secret-2026` (fallback در چند نقطه)

- **Verdict تأیید مستقل:** confirmed — **severity: high**
- **نگاشت:** GAP-005 (سکرت InternalTravelNotify) + GAP-006 (اشتراک با کنترل maintenance)
- **شواهد (مسیر:خط):**
  - `ecardo-backend/app/Http/Controllers/Api/InternalTravelNotifyController.php:20` — `env('INTERNAL_NOTIFY_SECRET', env('TRAVEL_INTERNAL_SECRET', 'ecardo-email-secret-2026'))` و همان fallback در `:67` (بازخوانی مستقیم ۱۸-۲۲ و ۶۵-۶۸ در همین سشن).
  - `ecardo-backend/app/Http/Controllers/Api/GithubDeployWebhookController.php:191` — همان رشتهٔ پیش‌فرض در هدر `X-Email-Secret` هنگام ارسال (بازخوانی مستقیم ۱۸۸-۱۹۳ در همین سشن).
  - `app/Http/Controllers/Api/MaintenanceControlController.php:34` — سکرت کنترل maintenance از `config('deploy.secret')`/GITHUB_DEPLOY_SECRET (ثبت GAP-006؛ در این سشن بازخوانی نشد).
  - چون مقدار در تاریخچهٔ سورس لو رفته، هر مصرف‌کننده‌ای که env ست نشده باشد با این رشتهٔ عمومی قابل جعل است (push به دستگاه‌های FCM کاربران / کنترل حالت سرویس).
- **حداقلِ فیکس (توصیه — اعمال نشد):** fallback هاردکد را کامل حذف کنید: در `:20` و `:67` و `GithubDeployWebhookController.php:191` مقدار را الزامی از env بخوانید و در نبودش fail-closed رفتار کنید (throw/403 یا غیرفعال‌شدن ارسال با log error) — هرگز رشتهٔ پیش‌فرض نداشته باشید. چون مقدار در تاریخچهٔ سورس لو رفته، **سکرت جدید تصادفی (مثلاً 32+ بایت) تولید و در env همهٔ سرویس‌های مصرف‌کننده (backend و edge worker ecardo.ir) هم‌زمان چرخش شود**.
- **تست پذیرش پس از فیکس:** بدون env → endpoint باید 403/خطا بدهد؛ سکرت قدیمی باید رد شود.

---

## جمع‌بندی نگاشت

| SEC | Verdict | Severity | گپ نگاشت‌شده | ردیف پوشش |
|---|---|---|---|---|
| SEC-1 | confirmed | high | GAP-001 | F-DEP-015 |
| SEC-2 | nuanced | high | GAP-002 (+GAP-015) | F-DEP-018..023, F-DEP-036 |
| SEC-3 | confirmed | high | GAP-003 | F-DEP-027, F-DEP-022 |
| SEC-4 | confirmed | high | GAP-004 (+GAP-014) | F-DEP-011..014, F-DEP-034 |
| SEC-5 | confirmed | high | GAP-005 + GAP-006 | — (خارج از دامنهٔ اپ کاربر) |

## راستی‌آزمایی این سشن (فرمان‌های اجراشده)

- `sed -n` بازخوانی خطی: `routes/web.php:16-22`، `StatusController.php:14-26`، `PaymentOtpService.php:108-155`، `GithubDeployWebhookController.php:188-193`، `InternalTravelNotifyController.php:18-22,65-68`، `IpnController.php:36-72,146-160`، `routes/payment.php:53-71,80-91`، `routes/api.php:236-244`، `MelliTxn.php:54-68`، `AlipayTxn.php:33-45`، `MollieTxn.php` (grep reftrn/metadata) — همگی با خروجی منطبق بر مواد.
- `grep -n` روی `modules/Payment/Mollie/MollieTxn.php` برای `reftrn|metadata|isPaid`.
- **اجر نشد:** `php artisan route:list` (SEC-4 — باید روی سرور اجرا شود، قانون ۱ `AGENTS.md`)؛ تست‌های منفی/429/امضای جعلی؛ هرگونه پچ.

*این سند نتیجهٔ بازبینی کد است؛ اجرای هر فیکس نیازمند تسک جداگانه با تست‌های منفی خودکار است.*
