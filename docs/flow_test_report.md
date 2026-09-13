<!-- ============================================================
هدف فایل: گزارش تست فلو-به-فلو (Flow-to-Flow Validation) درخت‌کاری اصلاح‌شدهٔ موج Task-10
          اپ کاربر eCardo v1.0.26+26 — اعتبارسنجی استاتیک کد + پروب‌های زندهٔ بک‌اند
اقدام انجام‌شده: ایجنت QA-VALIDATE؛ ردیابی کامل ۷ گروه فلو در کد فعلی (52 فایل تغییر یافته + 1 ویجت جدید)،
          کراس‌چک نمادهای بین-فایلی (dangling reference)، و پروب HTTP زنده روی https://ecardo.ir
          (فقط متد‌های GET عمومی و POST بدون اعتبارنامه؛ هیچ توکن/رمزی ارسال یا چاپ نشده است)
تاریخ: 2026-09-14
روش تست: (۱) ردیابی استاتیک مسیرها در کد — بدون شبیه‌ساز و بدون اجرای flutter/dart (مطابق دستور Lead)؛
          (۲) پروب‌های زندهٔ REST با curl به https://ecardo.ir/api/... (پروب POST /user/pay/generate-otp
          بدون هدر احراز هویت ارسال شد تا فقط «وجود روت» بررسی شود — انتظار 401/422، هرگز 404 نبودن)؛
          (۳) کراس‌چک دستی تک‌تک نمادهای جدید بین فایل‌ها با Grep تعریف‌ها.
          هیچ فایل موجودی ویرایش نشده است؛ خروجی این گزارش تنها فایل جدید این ایجنت است.
============================================================ -->

# 🧪 گزارش QA-VALIDATE: تست فلو-به-فلو موج Task-10 — eCardo User App v1.0.26+26

---

## ۱) خلاصه اجرایی

| # | فلو | نتیجه | شواهد کلیدی (یک خط) |
|---|---|---|---|
| 1 | حواله (Remittance) | ✅ **PASS** | فرم ۵ مرحله‌ای با گارد لودینگ (remittance_screen.dart:97,108-148) → مرور با `formatAmount(currencyId:)` API-محور (remittance_review_section.dart:30-34) → تاریخچه + دیپ‌لینک جزئیات با find-or-put گاردشده (remittance_details.dart:25-28, history:87) |
| 2 | تبدیل ارز (Exchange) | ✅ **PASS** | گارد موجودی v1.0.24 (exchange_controller.dart:484-496)، نرخ قفل‌شدهٔ مرور + ارسال rate/charge/total به سرور (E-3: 771-803)، گارد دابل‌سابمیت (767-769)، فیکس‌های قبلی دست‌نخورده |
| 3 | سفر (Travel) | ✅ **PASS** | گارد `isCheckoutLoading` در رزرو/پرداخت/استرداد (travel_controller.dart:461,492,541)، کلیدهای Idempotency + هدر `Idempotency-Key` (travel_api_repository.dart:204,248,315)، تاریخچه = TravelOrdersScreen |
| 4 | پرداخت قبض ×۶ | ✅ **PASS** | گارد `isSubmitLoading` + `lastBillPaymentResult` + `currentStep=2` در هر ۶ کنترلر (مثلاً airtime_controller.dart:137-162)، ویجت جدید `BillPaymentResultStepSection` در هر ۶ نقطهٔ فراخوانی با آرگومان‌های کامل، کلیدهای l10n موجود (app_en.arb:1257-1264,2260) |
| 5 | شارژ کیف پول / برداشت / کارت مجازی / رمز پویا | ⚠️ **WARNING** | فیکس‌های سمت کلاینت (M-1/M-3/P-1/P-3) همه سالم؛ اما پروب زندهٔ `POST /user/pay/generate-otp` → **404** → فلو «رمز پویا» در عمل با بک‌اند فعلی کار نمی‌کند (بخش ۳ و ۴) |
| 6 | زنجیره احراز هویت (اسپلش ← بیومتریک ← ورود) | ✅ **PASS** (با ۲ هشدار) | گیت ۴ شرطی + تایم‌اوت ۳۰ثانیه‌ای (splash_controller.dart:17,87-140)، همهٔ متدهای SettingsService/BiometricAuthService وجود دارند (کراس‌چک دستی)، `logged_in` پس از 2FA در TwoFactorAuthController ذخیره می‌شود (two_factor_auth_controller.dart:31) |
| 7 | نوتیفیکیشن‌ها | ✅ **PASS** | `POST_NOTIFICATIONS` در مانیفست (AndroidManifest.xml:9) + گیت رانتایم (firebase_messaging_service.dart:105-152)، پیلود `jsonEncode` (266)، روتر تپ `_routeForNotificationType` (372-405) و هر ۳ روت مقصد در routes_handler.dart ثبت‌شده‌اند (157-160, 205-208, 211-214)؛ مسیر app_update دست‌نخورده |
| 8 | کراس‌چک نمادها (۵۲ فایل) | ✅ **PASS** | **هیچ dangling reference پیدا نشد** — تک‌تک نمادهای جدید بین-فایلی تعریف دارند (بخش ۲-ب) |

**نتیجهٔ کلی: ۷/۸ PASS، ۱ WARNING (رمز پویا — ریشه در بک‌اند، نه کلاینت). فیکس‌های موج Task-10 از نظر سازگاری درون-کد سالم‌اند؛ یک روت گم‌شدهٔ بک‌اند و یک نشتی اطلاعات در API تنظیمات، مهم‌ترین یافته‌ها هستند.**

---

## ۲) جدول Goal-به-Goal (۴ معیار × فلوها)

> معیارهای Lead: (الف) بدون کرش/صفحهٔ سفید، (ب) وضعیت‌ها از بک‌اند (بدون مپ هاردکد)، (ج) ردیف تاریخچه پس از تکمیل قابل‌مشاهده، (د) کارمزد/قاعده/سقف/اعشار از API.

### ۲-۱) حواله (Remittance)

| معیار | نتیجه | شواهد file:line |
|---|---|---|
| الف) بدون کرش | ✅ | find-or-put گاردشده در هر ۳ صفحهٔ بدون Binding — remittance_screen.dart:30-32 (M-1)، remittance_details.dart:25-28 (M-2)، remittance_history.dart:25-27؛ آپلود با بررسی وجود فایل قبل از MultipartFile (remittance_controller.dart:437-443,542-547)؛ تایمر نرخ قابل‌لغو (262-286) |
| ب) وضعیت از بک‌اند | ✅ | `RemittanceStatus.fromString` از رشتهٔ سرور + پشتیبانی int/Map (remittance_model.dart:63-110,437-447)؛ مپ فقط «برچسب l10n» است نه تصمیم (controller:753-788) |
| ج) تاریخچه | ✅ | آیکون تاریخچه در appbar (remittance_screen.dart:54-57)؛ `fetchHistory` + صفحه‌بندی (controller:597-636)؛ تپ روی آیتم → `Get.toNamed(remittanceDetails, arguments: uuid)` (remittance_history.dart:87) |
| د) کارمزد/اعشار از API | ✅* | `decimalsForCurrencyId` (controller:711-734) بر پایهٔ `/get-currencies` + `site_currency`/`site_currency_decimals` از SettingsService؛ `formatAmount(amount, {currencyId})` (742-745) در مرور/موفقیت/تاریخچه/جزئیات (review:30-34، success:44-46، history:150,155، details:63-69) |
| *استثنا | ⚠️ جزئی | نرخ تبدیل با `toStringAsFixed(4)` هاردکد نمایش داده می‌شود (review:31، details:66) — TODO ثبت‌شده: API دقت نرخ را نمی‌فرستد (موارد بلاک‌شده ← بخش ۵) |

### ۲-۲) تبدیل ارز (Exchange)

| معیار | نتیجه | شواهد file:line |
|---|---|---|
| الف) بدون کرش | ✅ | گارد دابل‌سابمیت (exchange_controller.dart:767-769)، لغو تایمرها/سابسکریپشن‌ها در onClose (154-177)، فرم‌های null-safe در `fetchWallets` (529-544) |
| ب) وضعیت از بک‌اند | ✅ | `exchangeConfigModel` از `/user/exchange/config` (326-349)؛ کارمزد درصدی/ثابتی از سرور (353-373)؛ `successExchangeData` از پاسخ سرور (814) |
| ج) تاریخچه | ✅ | `currentStep=2` فقط پس از موفقیت (826) → success section از `successExchangeData` (success_step:139,277)؛ ExchangeHistory با پاگینیشن (exchange_history.dart:41-56) + روت ثبت‌شده (routes_handler.dart:327-330) |
| د) کارمزد/سقف/اعشار از API | ✅ | min/max از `exchangeLimit` والِت (446-482,865-871)، اعشار از DynamicDecimalsHelper + تنظیمات (446-454)، گارد موجودی (484-496) — فیکس‌های قبلی (E-1/E-3/balance guard v1.0.24) **دست‌نخورده و فعال** |

### ۲-۳) سفر (Travel)

| معیار | نتیجه | شواهد file:line |
|---|---|---|
| الف) بدون کرش | ✅ | گارد `isCheckoutLoading` در ۳ عملیات (travel_controller.dart:461,492,541)؛ دکمهٔ چک‌اوت با `isLoading` (travel_checkout_screen.dart:302)؛ تست‌های idempotency/safe-error موجود (test/travel/*) |
| ب) وضعیت از بک‌اند | ✅ | سفارش/وضعیت از `TravelOrder` پاسخ سرور (travel_controller.dart:507-514)؛ TravelOrderStatusTest موجود |
| ج) تاریخچه | ✅ | تأییدیه → `Get.off(TravelOrdersScreen)` (travel_confirmation_screen.dart:117)؛ account → TravelOrdersScreen/History (travel_account_screen.dart:83-123)؛ روت‌ها ثبت‌شده (routes_handler.dart:452-466) |
| د) کارمزد/قواعد از API | ✅ | Idempotency-Key در create/pay/refund (travel_api_repository.dart:204,248,315) + کلیدهای per-action در کنترلر (travel_controller.dart:64-67,470-478,502-509,545-554) |

### ۲-۴) پرداخت قبض ×۶ (آیرتایم/برق/اینترنت/بستهٔ داده/کابل/عوارض)

| معیار | نتیجه | شواهد file:line |
|---|---|---|
| الف) بدون کرش | ✅ | دکمهٔ مرور: `Obx` + `isLoading: controller.isSubmitLoading.value` در هر ۶ بخش مرور (airtime_review_step_section.dart:139-155؛ همان الگو در electricity/internet/data_bundle/cable/toll:144)؛ `CommonIconButton.isLoading` تپ را null می‌کند (common_icon_button.dart:48,72) |
| ب) وضعیت از بک‌اند | ✅ | `lastBillPaymentResult = response.data` (airtime_controller.dart:161) و ویجت نتیجه فقط پاسsthrough است: headline=`message`، status=`data['status']` بدون هیچ مپ سمت کلاینت (bill_payment_result_step_section.dart:58-74) |
| ج) تاریخچه | ✅ | `currentStep.value = 2` (controller:162) → ویجت نتیجه با دکمهٔ «تاریخچهٔ پرداخت قبوض» → `Get.toNamed(billPaymentHistory)` (bill_payment_result_step_section.dart:167-171)؛ روت ثبت‌شده (routes_handler.dart:417-421)؛ چیپ وضعیت در تاریخچه از مدل سرور (bill_payment_history_details.dart:69,146-155) |
| د) کارمزد/اعشار از API | ✅ | `reviewCalculate`: اعشار از `site_currency_decimals`، charge/rate با fallback-0 به‌جای `!` (P-2) (airtime_controller.dart:241-283)؛ rate اعشاری با DynamicDecimalsHelper (273-282)؛ همان الگو در ۵ کنترلر دیگر (سطرهای 241-283) |
| ویجت جدید | ✅ | `BillPaymentResultStepSection` در ۶ نقطهٔ فراخوانی: airtime.dart:101، electricity.dart:101، internet.dart:101، data_bundle.dart:101، cable.dart:101، toll.dart:102 — همه ۱۱ آرگومان required پاس داده می‌شود (شامل result/statusLabel/historyButtonLabel/closeButtonLabel/onClose) |
| کلیدهای l10n | ✅ | app_en.arb: `billPaymentHistoryTitle`(1257)، `billPaymentDetailsAmount/Charge/Status`(1261,1262,1264)، `commonClose`(2260)، `airtimeReviewPayableAmountLabel`(1253) |

### ۲-۵) شارژ کیف پول / برداشت / کارت مجازی / رمز پویا

| معیار | نتیجه | شواهد file:line |
|---|---|---|
| الف) بدون کرش | ✅ | Add money: حذف Get.put دوگانه، DI فقط با Binding (add_money_screen.dart:27-31، M-1) + AddMoneyBinding ثبت‌شده (routes_handler.dart:99-102)؛ رمز پویا: `Get.isRegistered<HomeController>()` گاردشده (dynamic_password_screen.dart:26-28، M-2) + گارد `_isLoading` (44، M-3) |
| ب) وضعیت از بک‌اند | ✅ | OTP: `status=='success'` + `data.code/expires_in` از پاسخ (dynamic_password_screen.dart:67-76)؛ کارت مجازی: charge از `card_topup_charge`/`_type` با tryParse امن (virtual_card_details_controller.dart:300-321، P-3) |
| ج) تاریخچه | ✅ | withdraw/add-money history از `/user/transactions` (api_path.dart:76,102)؛ روت‌های history ثبت‌شده (routes_handler.dart:290-330) |
| د) کارمزد از API | ✅ | P-3: درصد/ثابت از تنظیمات سرور + fallback 0 (virtual_card_details_controller.dart:307-319)؛ تنظیمات زنده موجود است (بخش ۳) |
| ⚠️ فلو رمز پویا | ❌ در لایو | endpoint `/api/user/pay/generate-otp` روی بک‌اند وجود ندارد (پروب → 404؛ بخش ۳) — کلاینت درست است، ولی در عمل همیشه toast خطا می‌بیند (`dynamicPasswordServerError` در dynamic_password_screen.dart:86) |

### ۲-۶) زنجیره احراز هویت (AUTH-BIO)

مسیر ردیابی‌شده: splash → connectivity (splash_controller.dart:20-30) → `getLoginCurrentState` (32) → `_tryAutoBiometricLogin` (87-140) با ۴ شرط گیت (loginState:90، biometricEnabled:92-94، savedEmail/Password:96-103، `isBiometricAvailable()`:108-111) + `.timeout(30s, onTimeout:()=>false)` (114-116) → `Get.offNamed(signIn)` (125) → `Get.put(SignInController())` + `biometricEmail/Password` (127-129) → `submitSignIn(useBiometric:true)` (132) → login API (sign_in_controller.dart:105-108) → `registerTokenWithBackend` (FCM: 180-196 ← firebase_messaging_service.dart:192-227) → `fetchUser` (128-178) → home یا `twoFactorAuth` (144-167) → پس از تأیید 2FA، `logged_in` ذخیره (two_factor_auth_controller.dart:29-31) → navigation/signUpStatus (44-51). شکست/انصراف → fallback به signIn/welcome (40-48).

| معیار | نتیجه | شواهد file:line |
|---|---|---|
| الف) بدون کرش/قفل‌شدن کاربر | ✅ | تایم‌اوت ۳۰ ثانیه (17,114-116)؛ try/catch سراسری با fallback (134-139)؛ بیومتریکِ ناموجود → بدون پرامپت به sign-in (108-111) |
| ب) وضعیت از بک‌اند | ✅ | مسیر home/2FA/signUpStatus از `userModel` سرور (sign_in_controller.dart:144-167)؛ شرط 2FA فقط `twoFa==true` سرور (144) |
| ج) رسیدن به خانه/2FA | ✅ | `Get.offAllNamed(navigation)` (159) و `Get.toNamed(twoFactorAuth)` (145)؛ 2FA → `offAllNamed(navigation)` پس از تأیید (two_factor_auth_controller.dart:44-45) |
| د) flags از منطق درست | ✅ | `logged_in` فقط پس از موفقیتِ کامل زنجیره ذخیره می‌شود (A-4): sign_in_controller.dart:40-44,67-71,154-156 + two_factor_auth_controller.dart:29-31 |
| کراس‌چک متدها | ✅ | همهٔ متدهای ارجاع‌شده در splash تعریف دارند: `SettingsService.getLoginCurrentState`(settings_service.dart:78)، `getLoggedInUserEmail`(91)، `getLoggedInUserPassword`(119)، `getBiometricEnableOrDisable`(146)، `currentBiometricKey`(24)؛ `BiometricAuthService.isBiometricAvailable`(biometric_auth_service.dart:106)، `authenticateWithBiometrics`(35)؛ `AppUpdateHelper.maybeAutoPromptForUpdate`(app_update_helper.dart:100)؛ `NetworkService.login`(network_service.dart:317)؛ `submitSignIn({bool useBiometric})` (sign_in_controller.dart:93) |

**⚠️ دو هشدار** (بخش ۴، بند ۳ و ۴): (۱) برای کاربران 2FA هرگز email/password ذخیره نمی‌شود → گیت بیومتریک برایشان فعال نمی‌شود (fail-safe، بدون قفل‌شدن)؛ (۲) `EmailController.onInit()` هنوز `logged_in` را در ابتدای ثبت‌نام می‌نویسد و ناورسانی A-4 را در مسیر sign-up بازتولید می‌کند (فایل پیشینِ تغییرنیافته).

### ۲-۷) نوتیفیکیشن‌ها

| معیار | نتیجه | شواهد file:line |
|---|---|---|
| مجوز + مانیفست | ✅ | `POST_NOTIFICATIONS` (AndroidManifest.xml:9) + گیت رانتایم permission_handler با fallback به FCM (firebase_messaging_service.dart:105-152) |
| Foreground | ✅ | `jsonEncode(data)` به‌جای `toString()` (firebase_messaging_service.dart:259-275) |
| روتر تپ | ✅ | `setNotificationTapHandler` (تعریف: local_notifications_service.dart:22-24؛ ثبت: firebase_messaging_service.dart:76-80)؛ `_onLocalNotificationTap` با jsonDecode مقاوم (300-319)؛ `_routeForNotificationType` (372-405) |
| روت‌های مقصد موجودند | ✅ | `BaseRoute.transactions` → GetPage (routes_handler.dart:156-160)، `supportTickets` (204-208)، `kycHistory` (210-214) — فقط خواندن، بدون تغییر |
| app_update دست‌نخورده | ✅ | مسیر `app_update` زنجیرهٔ اختصاصی خودش را دارد (254-257, 284-287, 327-330, 417-445)؛ فایل‌های app_update_controller/helper/screen در لیست تغییراتِ موج نیستند |

---

## ۲-ب) کراس‌چک نمادها (بالاترین ارزش — هیچ ارجاع معلق نیست)

برای **هر** نمادِ جدیدِ بین-فایلی در ۵۲ فایل اصلاح‌شده + ۱ ویجت جدید، تعریف با Grep پیدا و تطبیق امضا بررسی شد:

| نماد | تعریف (file:line) | فراخوانی‌ها | وضعیت |
|---|---|---|---|
| `RemittanceController.formatAmount(double, {int? currencyId})` | remittance_controller.dart:742-745 | review:30-34، success:44-46، method_section:281-287، history:150,155، details:63-69 | ✅ |
| `RemittanceController.decimalsForCurrencyId(int?)` | remittance_controller.dart:711-734 | داخل formatAmount + همهٔ صفحات | ✅ |
| `BillPaymentResultStepSection({result, amountLabel/Value, chargeLabel/Value, payableLabel/Value, statusLabel, historyButtonLabel, closeButtonLabel, onClose})` | bill_payment_result_step_section.dart:27-56 | ۶ نقطه: airtime/electricity/internet/data_bundle/cable.dart:101-114 و toll.dart:102-115 — همهٔ آرگومان‌های required پاس می‌شوند | ✅ |
| `AirtimeController.lastBillPaymentResult` (+۵ کنترلر دیگر) | airtime_controller.dart:24-25 | view:102 + resetFields:290 | ✅ |
| `ApiPath.generateDynamicPasswordOtpEndpoint` | api_path.dart:83-86 | dynamic_password_screen.dart:63 | ✅ |
| `FirebaseMessagingService.registerTokenWithBackend()` | firebase_messaging_service.dart:192-227 | sign_in_controller.dart:189 + onTokenRefresh:173 | ✅ |
| `LocalNotificationsService.setNotificationTapHandler(fn?)` | local_notifications_service.dart:22-24 | firebase_messaging_service.dart:78-80 | ✅ |
| `TransactionsPopUp._statusKey` | transactions_pop_up.dart:18 | همان فایل:160-181 (M-4: نرمال‌سازی case وضعیت سرور) | ✅ |
| `SettingsService.getLoginCurrentState/getLoggedInUserEmail/getLoggedInUserPassword/getBiometricEnableOrDisable` | settings_service.dart:78/91/119/146 | splash_controller.dart:32,89,96-97,92-93؛ sign_in_controller | ✅ |
| `BiometricAuthService.isBiometricAvailable/authenticateWithBiometrics` | biometric_auth_service.dart:106/35 | splash_controller.dart:108,114-116 | ✅ |
| `SignInController.submitSignIn({bool useBiometric})` + `biometricEmail/biometricPassword` | sign_in_controller.dart:93-126/33-34 | splash_controller.dart:127-132 | ✅ |
| `AppUpdateHelper.maybeAutoPromptForUpdate(ctx)` | app_update_helper.dart:100 | splash_controller.dart:55-60 (UPD-5) | ✅ |
| `NetworkService.login / postMultipart` | network_service.dart:317 / 496 | sign_in_controller؛ remittance+profile+withdraw+2×p2p (P-1) | ✅ |
| `DynamicDecimalsHelper.getDynamicDecimals({currencyCode, siteCurrencyCode, siteCurrencyDecimals, isCrypto})` | dynamic_decimals_helper.dart:2-15 | remittance/exchange/bill/request_money/gift_card — امضا با همهٔ فراخوانی‌ها تطبیق دارد | ✅ |
| `GetPage(replayTicket)` با آرگومان رشته‌ای گاردشده | routes_handler.dart:237-242 (M-6) | از support_tickets با ticketUid | ✅ |
| روت‌های `transactions/supportTickets/kycHistory` | routes_handler.dart:156-214 | `_routeForNotificationType` | ✅ |

**نتیجه: صفر dangling reference.** تنها مورد حاشیه‌ای: `FirebaseMessagingService.attachContext()` (تعریف: firebase_messaging_service.dart:97-99) **هیچ‌جا فراخوانی نمی‌شود** — خطای کامپایل نیست و مسیر جایگزین `Get.context` امن است؛ فقط یعنی `_lastContext` همیشه null می‌ماند و تپِ cold-start تا اولین فریم نادیده گرفته می‌شود (TODO ثبت‌شده در 349-356).

---

## ۳) نتایج پروب‌های زندهٔ بک‌اند (https://ecardo.ir)

| پروب | متد | HTTP | نتیجه |
|---|---|---|---|
| `/api/get-settings-v2?origin=1&t=<cache-buster>` | GET | **200** | ✅ ۲۷۵ تنظیم؛ فیلدهای الزامی همه حاضرند |
| `/api/get-settings` (v1 — کنترل) | GET | **200** | ✅ هم‌اکنون v1.0.26 را سرو می‌کند (مشکل stale CF فعلاً برطرف) |
| هدرهای کش v2 | GET | — | ✅ `cache-control: max-age=0, no-store, private` + `cf-cache-status: BYPASS` (فیکس UPD-2 تأیید) |
| `/api/app-version` | GET | **200** | ✅ `{"version":"1.0.26","force_update":true,"update_url":".../v1.0.26/ecardo_user_v1.0.26.apk"}` |
| `/api/get-currencies` | GET | **200** | ⚠️ ۶ ارز (IRT, RMB, IRR, CNY, USDT, USD)؛ فیلدها: id/code/type/symbol/conversion_rate/status — **فیلد اعشار هر ارز وجود ندارد** |
| `/api/terms-conditions` | GET | **200** | ✅ HTML صفحهٔ شرایط (placeholder) |
| `/api/user/pay/generate-otp` (بدون auth) | POST | **404** | ❌ `{"status":false,"message":"The route api/user/pay/generate-otp could not be found."}` |
| `/api/user/pay-bill` (بدون auth — کنترل) | POST | **401** | ✅ `Unauthenticated.` → ثابت می‌کند روت‌های محافظت‌شده 401 می‌دهند نه 404 |
| `/api/get-bill-countries/airtime` (بدون auth — کنترل) | GET | **401** | ✅ همان الگو |
| `/api/user/remittance/methods` (بدون auth — کنترل) | GET | **401** | ✅ همان الگو |

**گزینهٔ خام JSON (excerpt از settings-v2 — فقط فیلدهای مرتبط):**
```json
{"name":"site_currency","value":"USD"}
{"name":"site_currency_decimals","value":"0"}
{"name":"card_topup_charge","value":"2"}
{"name":"card_topup_charge_type","value":"percentage"}
{"name":"app_version","value":"1.0.26"}
{"name":"app_force_update","value":"1"}
{"name":"app_update_link","value":"https://github.com/mahankarimi1382/ecardo_userapp_v1/releases/download/v1.0.26/ecardo_user_v1.0.26.apk"}
```

**تحلیل پروب‌ها:**
- ✅ ورودی‌های فیکس‌های موج Task-10 روی پروداکشن موجودند: `site_currency_decimals=0` (DynamicDecimalsHelper/P-2)، `card_topup_charge=2%` (P-3)، `app_version/app_update_link/app_force_update` (UPD-2/5) و هدر no-store روی v2.
- ❌ **404 برای `/user/pay/generate-otp`** یعنی روت روی بک‌اند ثبت نشده (روت‌های auth-دار الگو، 401 برمی‌گردانند). فلو رمز پویا تا رفع این مورد در لایو کار نمی‌کند.
- ⚠️ `/get-currencies` هیچ ستون اعشاری (decimals) نمی‌فرستد — دقیقاً همان TODO ثبت‌شده در remittance_controller.dart:707-710؛ تا زمان افزودن، اعشار از `site_currency_decimals` استنتاج می‌شود (برای ارزهای غیر از ارز سایت، ثابت 2/8).
- 🔴 **یافتهٔ امنیتی (خارج از فلوها):** پاسخ عمومی `get-settings-v2` کلیدهای `mail_username`, `mail_password` (کلید API سرویس ایمیل), `mail_host/port/secure` را هم برمی‌گرداند. این یعنی نشتی اعتبارنامهٔ SMTP در یک endpoint بدون احراز هویت. باید سمت سرور فیلتر شود و اعتبارنامه فعلی چرخانده (rotate) شود.

---

## ۴) باگ‌های یافت‌شده (ریشه + فیکس پیشنهادی — فقط گزارش؛ خودم فیکس نکردم)

| # | شدت | شرح | ریشه | فیکس پیشنهادی | مرجع |
|---|---|---|---|---|---|
| 1 | 🔴 CRITICAL (بک‌اند) | فلو «رمز پویا» در لایو کار نمی‌کند: تولید OTP همیشه با خطا مواجه می‌شود | روت `POST api/user/pay/generate-otp` روی سرور ثبت نشده (404 قطعی؛ پروب‌های کنترل 401 دادند) | ثبت روت در بک‌اند زیر middleware auth (همان شکل پیلود `{account_number}` که کلاینت می‌فرستد). کلاینت نیازی به تغییر ندارد | پروب بخش ۳؛ dynamic_password_screen.dart:61-65 |
| 2 | 🔴 CRITICAL (امنیت بک‌اند) | نشتی اعتبارنامهٔ SMTP/کلید API ایمیل در endpoint عمومی تنظیمات | فیلتر کلیدهای حساس در پاسخ `get-settings*` انجام نمی‌شود | حذف کلیدهای `mail_*` (به‌خصوص `mail_password`) از پاسخ عمومی + چرخاندن فوراً اعتبارنامهٔ لو رفته + ممیزی لاگ‌ها | پروب بخش ۳ (excerpt؛ مقدار چاپ نشد) |
| 3 | 🟠 MEDIUM | کاربران 2FA هرگز وارد گیت بیومتریک نمی‌شوند و ایمیل آن‌ها در ورود بعدی prefill نمی‌شود | در `fetchUser` شاخهٔ 2FA (`twoFa==true`) قبل از `Get.toNamed(twoFactorAuth)` برمی‌گردد و بلاک `saveLoggedInUserEmail/Password` را رد می‌کند؛ مسیر 2FA فقط `logged_in` را ذخیره می‌کند | پس از موفقیت `submitTwoFaVerification` (یا در شاخهٔ 2FA قبل از رفتن به صفحهٔ کد) حداقل email (و در صورت سیاستِ مجاز، password) ذخیره شود تا ۴ شرط گیت برای کاربران 2FA هم قابل ارضا باشد | sign_in_controller.dart:144-152؛ two_factor_auth_controller.dart:29-31 |
| 4 | 🟠 MEDIUM (پیشین، ناسازگار با A-4) | ناورسانی معنایی `logged_in` در مسیر ثبت‌نام: با ورودِ صرف به صفحهٔ ایمیل، پرچم «loged in» ذخیره می‌شود | `EmailController.onInit()` بی‌قید و شرط `setLogInState()` را صدا می‌زند — فایل در موج اصلاح نبود و از چشم A-4 افتاد | فراخوانی `setLogInState()` در EmailController حذف و به لحظهٔ تکمیل موفق ثبت‌نام/آن‌بوردینگ منتقل شود؛ تا آن زمان splash با `logged_in` خالی، مسیر welcome را درست انتخاب می‌کند | email_controller.dart:22-27,41-44 |
| 5 | 🟡 LOW | عبارت بی‌اثر (`==` به‌جای `=`) در `loadData()` هر ۶ صفحهٔ قبض | `controller.currentStep.value == 0;` مقایسه است نه انتصاب — ریست مرحله عملاً انجام نمی‌شود | تغییر به `controller.currentStep.value = 0;` در هر ۶ فایل. اثر عملی فعلاً کم است چون Binding هر ورود، کنترلر تازه می‌سازد؛ ولی اگر dayی instance ماندگار شود، کاربر نتیجهٔ قبلی را می‌بیند | airtime.dart:31، electricity.dart:31، internet.dart:31، data_bundle.dart:31، cable.dart:31، toll.dart:32 |
| 6 | 🟡 LOW | نمایش نرخ حواله با دقت هاردکد ۴ اعشار | API دقت نرخ را expose نمی‌کند (TODO آگاهانه) | افزودن فیلد دقت/اعشار به پاسخ quote/show حواله و استفاده از آن؛ تا آن زمان رفتار فعلی (ثابت ۴) قابل‌قبول است | remittance_review_section.dart:31؛ remittance_details.dart:66؛ remittance_controller.dart:707-710 |
| 7 | ⚪ INFO | `attachContext()` هیچ‌جا صدا زده نمی‌شود؛ دیپ‌لینک cold-start نوتیفیکیشن تا اولین فریم نادیده گرفته می‌شود | فراخوانی از app.dart جا افتاده (TODO ثبت‌شده در خود سرویس) | فراخوانی `FirebaseMessagingService.instance().attachContext(context)` در builder ریشه یا پس از اولین فریم | firebase_messaging_service.dart:95-99,345-356 |
| 8 | ⚪ INFO | force-unwrap `serviceData.value!.currency` در بخش مرور قبض | عملاً غیرقابل‌وقوع است چون ورود به مرور بعد از validation است | برای هم‌ترازی با سبک P-2 می‌شود null-safe کرد | airtime_review_step_section.dart:48 (و معادل‌ها) |

---

## ۵) موارد بلاک‌شده / وابسته به بک‌اند

1. **روت `POST /user/pay/generate-otp`** — فلو رمز پویا تا ثبت روت بلاک است (باگ ۱). تست نهایی پس از استقرار: POST بدون auth باید 401/422 بدهد.
2. **شکل دقیق پیلود موفقیت `POST /user/pay-bill`** — کلاینت پاسsthrough بدون مدل تایپ‌دار است (bill_payment_result_step_section.dart:15-19). تا تعیین قرارداد (`data.status`/`data.tnx`)، وضعیت pending/success فقط به‌اندازهٔ چیزی که سرور بفرستد نمایش داده می‌شود.
3. **فیلد decimals در `/get-currencies`** — تا افزودن، اعشار ارزهای غیر از ارز سایت ثابت ۲/۸ است (بند ۶-کم و TODO remittance). تأثیر: نمایش (نه محاسبه) در حواله/تبدیل.
4. **اعتبارسنجی سمت سرور فیلدهای E-3 تبدیل ارز** — کلاینت `rate/total_amount/charge/exchange_amount/exchange_review_rate/rate_locked_at` را می‌فرستد (exchange_controller.dart:786-804)؛ اگر بک‌اند کلیدهای اضافه را نپذیرد (validation سخت‌گیرانه)، submit رد می‌شود. نیاز به تأیید بک‌اند دارد.
5. **فلوهای merchant/agent** — cash_out، make_payment، p2p_trading طبق audit قبلی به اپ مرچنت/پذیرنده وابسته‌اند و خارج از دامنهٔ این تست بودند.
6. **تست اجرایی (runtime)** — شبیه‌ساز در دسترس نبود؛ رفتار واقعی runtime (شامل پرامپت بیومتریک اندروید و FCM real payload) باید در تست دستگاه/CI دنبال شود. پروب‌های احراز هویت‌دار (تاریخچه‌ها، pay-bill موفق) برای پرهیز از هرگونه اعتبارنامه/دیتای واقعی انجام نشد.

---

*پایان گزارش — QA-VALIDATE، موج Task-10، 2026-09-14. خروجی‌های دوباره‌پس‌دهی به Lead: جدول نتیجهٔ فلوها (بخش ۱)، کراس‌چک نمادها (بخش ۲-ب)، خلاصهٔ پروب‌ها (بخش ۳)، باگ‌ها به‌ترتیب شدت (بخش ۴).*

---

<!-- ============================================================
بخش اصلاحیه Lead (بازبینی مجدد، 2026-09-14) — دو یافتهٔ «CRITICAL بک‌اند» رد شدند
اقدام: پروب مجدد زنده توسط Lead انجام شد:
1) رمز پویا: مسیر واقعی کلاینت = baseUrl('https://ecardo.ir/api') + '/pay/generate-otp'
   یعنی /api/pay/generate-otp — پروب زنده: 422 «account number required» ⇒ روت
   زنده و سالم است (قبلاً اشتباهاً با پیشوند /user پروب شده بود که 404 می‌داد).
   routes/api.php:192 همین مسیر را تأیید می‌کند. verdict فلو ۵: WARNING → PASS.
2) افشای mail_password: پروب مجدد get-settings (v1، با و بدون cache-buster) و
   get-settings-v2 ⇒ هیچ کلید حساسی (mail_*/smtp/password/secret) در پاسخ نیست.
   یافته قبلی false-positive (احتمالاً آبجکت کهنهٔ کش). بدون نیاز به هات‌فیکس.
3) فیکس‌های Lead پس از گزارش: no-op `==`→`=` در ۶ ویو قبض؛ ذخیرهٔ اعتبارنامه
   پس از 2FA (پاریتی بیومتریک)؛ رفع error قدیمی SDK-3.47 در kyc_submission.
============================================================ -->
