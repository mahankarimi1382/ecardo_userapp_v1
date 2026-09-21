
## به‌روزرسانی 1.0.51 — بستن تسک‌های باز چت

| تسک | وضعیت |
|-----|--------|
| بیومتریک بدون ذخیرهٔ پسورد (token-first) | ✅ |
| پاک‌سازی پسورد legacy بعد از unlock موفق | ✅ |
| tryParse! باقی‌مانده add_money / withdraw | ✅ |
| روت‌های مرده invoice* | ✅ حذف ثابت‌ها |
| P2pBinding برای shell اصلی | ✅ |
| NotFound / RemittanceBinding / StatusLabel / P2P vs Escrow / Travel redesign | ✅ در ۱.۰.۴۸–۵۰ |
| Sentry/pinning | عمداً خارج (نیاز DSN/cert پروداکشن) |
| Admin app version-by-version | خارج از این ریپو (userapp) |


<!-- ============================================================
هدف فایل: نقشه کامل فلوهای اپ (Route Map + وضعیت) — eCardo user app
آخرین بازبینی: 2026-09-21 | نسخه کد: 1.0.49 (پس از UI-QC 1.0.48 + sprint A/B/C)
نکته: جدول روت‌های تفصیلی زیر ممکن است هنوز برچسب‌های 1.0.26 داشته باشد؛
وضعیت‌های تأییدشدهٔ جدید در بخش «به‌روزرسانی 1.0.49» در ابتدای سند آمده است.
============================================================ -->

# به‌روزرسانی ممیزی — 1.0.49 (2026-09-21)

## تثبیت‌شده از 1.0.46→1.0.48
- Rate Alert مرده مخفی؛ StatusLabelHelper روی فیلترها/جزئیات؛ توست ۲FA محلی
- Publish CI وقتی Release از قبل وجود دارد؛ ریلیز public + notify سرور برای v1.0.48

## 1.0.49 (این موج)
- داشبورد کسب‌وکار: کاشی **P2P Trading** جدا از **Escrow Services** (خاموش/notBuilt)
- safe-parse مبالغ add_money / gift (حذف `tryParse(...)!`)
- پاک‌سازی پسورد بیومتریک از Rx بعد از لاگین
- unknownRoute → NotFoundScreen (نه اسپلش)
- Binding برای remittance + kycSubmitWizard
- تست واحد StatusLabelHelper

## باقی‌مانده (عمداً خارج از این موج)
- حذف کامل ذخیرهٔ پسورد بیومتریک (نیاز به مدل سشن/refresh-only)
- certificate pinning، Sentry/Crashlytics با DSN پروداکشن
- DI یکدست همهٔ Get.putهای P2P (تدریجی)

---

# 🗺️ نقشه کامل فلوهای اپ eCardo (User App) — خروجی APP-SCAN

## (الف) خلاصه آماری

| مورد | مقدار |
|---|---|
| تعداد روت‌های ثبت‌شده (GetPage) | **79** |
| محل ثبت روت‌ها | `lib/src/app/routes/routes_handler.dart` (ثبت‌نام ثابت‌ها: `lib/src/app/routes/routes.dart`، نگاشت صفحه: `lib/src/app/routes/routes_config.dart`) |
| ✅ کامل | **64** |
| ⚠️ ناقص / کارا ولی با ایراد | **12** |
| ❌ خالی یا کرش‌پرور | **0** |
| 🔗 وابسته به ایجنت/مرچنت/طرف مقابل | **3** (cash_out، make_payment، p2p_trading) |
| روت‌های «ثبت‌نشده ولی تعریف‌شده» (ثابت مرده) | 5 مورد: `invoice`, `createInvoice`, `updateInvoice`, `invoiceDetails`, `replayTicket` (`routes.dart:47-52,88,92`) |

منطق برچسب‌گذاری: «کامل» یعنی فرم → اعتبارسنجی → مرور (Review) → فراخوانی API → موفق/در انتظار → تاریخچهٔ قابل‌مشاهده. «ناقص» یعنی یکی از حلقه‌ها ضعیف/مفقود است (ریسک دابل‌سابمیت، bypass شبکه، force-unwrap، نبود binding مستقل، ...).

---

## (ب) جدول کامل روت‌ها (79 روت)

> مسیرهای «فایل صفحه» نسبت به `lib/src/presentation/screens/` خلاصه شده‌اند. «Binding» از `routes_handler.dart` استخراج شده.

| # | Route | فایل صفحه | Binding | وضعیت | شواهد (file:line) | توضیح | ایجنت پیشنهادی |
|---|---|---|---|---|---|---|---|
| 1 | `/` (root) | authentication/splash/view/splash_screen.dart | SplashBinding | ✅ | splash_screen.dart:116-122,137 | ورکر ever() در dispose آزاد می‌شود (فیکس v1.0.24 تأیید شد) | — |
| 2 | `/splash_route` | همان اسپلش | SplashBinding | ✅ | همان بالا | روت تکراری root | — |
| 3 | `/welcome_route` | authentication/welcome/view/welcome_screen.dart | — | ✅ | صفحهٔ معرفی ثابت | — | — |
| 4 | `/sign_in_route` | authentication/sign_in/view/sign_in_screen.dart | SignInBinding | ✅ | sign_in_controller.dart:134-159; sign_in_screen.dart:297-377 | بای‌پس 2FA فیکس شد (شرط `twoFa==true`)؛ دکمهٔ بیومتریک با آیکون `fingerprintCommonIcon` و ترتیب گیت صحیح (ذخیرهٔ اطلاعات → فعال‌بودن → prompt) | — |
| 5 | `/two_factor_auth_route` | authentication/sign_in/view/sub_sections/two_factor_auth.dart | TwoFactorAuthBinding | ✅ | two_factor_auth_controller.dart:28-46 | روتینگ درست به navigation یا signUpStatus بر اساس onboarding | — |
| 6 | `/email_route` | authentication/sign_up/view/email/email_screen.dart | EmailBinding | ✅ | email_controller.dart:55 | — | — |
| 7 | `/verify_email_route` | authentication/sign_up/view/verify_email/verify_email_screen.dart | VerifyEmailBinding | ✅ | verify_email_controller.dart:54-79 | — | — |
| 8 | `/forgot_password_route` | authentication/forgot_password/view/forgot_password_screen.dart | ForgotPasswordBinding | ✅ | forgot_password_controller.dart | — | — |
| 9 | `/reset_password_route` | authentication/forgot_password/view/sub_sections/reset_password.dart | ResetPasswordBinding | ✅ | reset_password_controller.dart | — | — |
| 10 | `/forgot_password_pin_verification_route` | authentication/forgot_password/view/sub_sections/forgot_password_pin_verification.dart | ForgotPasswordPinVerificationBinding | ✅ | forgot_password_pin_verification_controller.dart | — | — |
| 11 | `/navigation_route` | app/navigation/navigation_screen.dart | [Home, Transfer, GiftCode, CreateGift, GiftRedeem, GiftHistory, KycLevel] | ✅ | navigation_screen.dart:56-71,93-138,185-221 | بات‌نِیو + QR اسکنر (AID/MID/UID) + گیت‌های تنظیماتی + cleanup کنترلرها | — |
| 12 | `/wallets_route` | wallets/view/wallets_screen.dart | WalletsBinding | ✅ | wallets_controller.dart:23,47 | چند-ارزی، حذف کیف پول | — |
| 13 | `/create_new_wallet_route` | wallets/view/create_new_wallet/create_new_wallet.dart | CreateNewWalletBinding | ✅ | create_new_wallet_controller.dart | — | — |
| 14 | `/qr_code_route` | qr_code/view/qr_code_screen.dart | QrCodeBinding | ✅ | qr_code_controller.dart:32,50 | نمایش QR کاربر | — |
| 15 | `/add_money_route` | add_money/view/add_money_screen.dart | AddMoneyBinding | ✅ | add_money_controller.dart:210,249,294; review_step:49-107 | گیت‌وی واقعی، manual multipart از postMultipart (فیکس v1.0.24)، گارد دابل‌سابمیت، decimals از `currency_decimals` | — |
| 16 | `/make_payment_route` | make_payment/view/make_payment_screen.dart | MakePaymentBinding | 🔗 | make_payment_controller.dart:182,276-280 | گارد + گارد موجودی؛ تسویهٔ نهایی به مرچنت (MID) سمت مرچنت است | PAYMENT-FIX (پایش) |
| 17 | `/request_money_route` | request_money/view/request_money_screen.dart | [RequestMoney, ReceivedRequestMoney] | ✅ | request_money_controller.dart:201-233; received_request.dart:234 | درخواست + پذیرش درخواست دریافتی؛ DynamicDecimalsHelper | — |
| 18 | `/gift_code_route` | gift_code/view/gift_code_screen.dart | [GiftCode, GiftRedeem, CreateGift, GiftHistory] | ✅ | gift_code_screen.dart:27-32 | ۴ زیرفلو (ساخت/ریدیم/تاریخچه)؛ اما Get.put در view (M-1) | MODULE-FIX |
| 19 | `/transfer_route` | transfer/view/transfer_screen.dart | TransferBinding | ✅ | transfer_controller.dart:239-243,260 | گارد موجودی v1.0.24 + گارد دابل‌سابمیت | — |
| 20 | `/cash_out_route` | cash_out/view/cash_out_screen.dart | CashOutBinding | 🔗 | cash_out_controller.dart:232-245,278-308 | سمت کاربر کامل (گارد موجودی، decimals)؛ وابسته به پردازش ایجنت (agent_number/AID) | PAYMENT-FIX (پایش) |
| 21 | `/withdraw_route` | withdraw/view/withdraw_screen.dart | [Withdraw, WithdrawAccount, CreateWithdrawAccount, EditWithdrawAccount] | ⚠️ | create_withdraw_account_controller.dart:199-208; edit_withdraw_account_controller.dart:131 | هستهٔ برداشت کامل؛ اما ساخت/ویرایش حساب برداشت با `dio.Dio()` خام بدون timeout/refresh | PAYMENT-FIX |
| 22 | `/exchange_route` | exchange/view/exchange_screen.dart | ExchangeBinding | ✅ | exchange_controller.dart:287-307,484-496,766-804; exchange_rate_service.dart:35-99 | گارد موجودی، قفل/کهنگی نرخ، LiveRateBadge، debounce، idempotency؛ سرویس نرخ با stale-flag | — |
| 23 | `/transactions_route` | transactions/view/transactions_screen.dart | TransactionsBinding | ✅ | transactions_controller.dart + filter bottom sheet | فیلتر/صفحه‌بندی واقعی | — |
| 24 | `/referral_route` | referral/view/referral_screen.dart | ReferralBinding | ✅ | referral_controller.dart:22 | — | — |
| 25 | `/referred_friends_route` | referral/view/referred_friends/referred_friends.dart | ReferredFriendsBinding | ✅ | referred_friends_controller.dart | — | — |
| 26 | `/referral_tree_route` | referral/view/referral_tree/referral_tree.dart | ReferralTreeBinding | ✅ | referral_tree_controller.dart | — | — |
| 27 | `/profile_settings_route` | settings/view/profile_settings/profile_settings.dart | ProfileSettingsBinding | ⚠️ | profile_settings_controller.dart:258-… | آپدیت پروفایل (multipart) با `dio.Dio()` خام بدون timeout؛ فیکس جنسیت v1.0.24 موجود | PAYMENT-FIX |
| 28 | `/change_password_route` | settings/view/change_password/change_password.dart | ChangePasswordBinding | ✅ | change_password_controller.dart | — | — |
| 29 | `/two_factor_authentication_route` | settings/view/two_factor_authentication/two_factor_authentication.dart | TwoFactorAuthenticationBinding | ✅ | sub_sections کامل (enable/disable/change/passcode) | — | — |
| 30 | `/notifications_route` | settings/view/notifications/notifications.dart | NotificationBinding | ✅ | notification_controller.dart + notifications_model | لیست واقعی؛ ⚠️ تپ پوش→صفحهٔ مرتبط در لایهٔ FCM نیست (AUTH-B3) | AUTH-BIO |
| 31 | `/support_tickets_route` | settings/view/support_tickets/support_tickets.dart | SupportTicketBinding | ✅ | support_ticket_controller.dart | — | — |
| 32 | `/kyc_history_route` | settings/view/id_verification/kyc_history/kyc_history.dart | KycHistoryBinding | ✅ | kyc_history_controller.dart:26; kyc_history.dart:105-120 | وضعیت از بک‌اند (pending/approved/rejected) | — |
| 33 | `/add_new_ticket_route` | settings/view/support_tickets/add_new_ticket/add_new_ticket.dart | AddNewTicketBinding | ✅ | add_new_ticket_controller.dart:73 (فیکس v1.0.24) | — | — |
| 34 | `/gift_history_route` | gift_code/view/sub_sections/gift_history.dart | GiftHistoryBinding | ✅ | gift_history_controller.dart:55-104 | فیلتر + صفحه‌بندی | — |
| 35 | `/id_verification_route` | settings/view/id_verification/id_verification.dart | IDVerificationBinding | ✅ | id_verification.dart:74-75 | هدایت به KYC Level wizard | — |
| 36 | `/sign_up_status_route` | authentication/sign_up/view/sign_up_status/sign_up_status_screen.dart | SignUpStatusBinding | ✅ | sign_up_status_controller.dart:28-75 | — | — |
| 37 | `/set_up_password_route` | authentication/sign_up/view/set_up_password/set_up_password_screen.dart | SetUpPasswordBinding | ✅ | set_up_password_controller.dart:58 | — | — |
| 38 | `/personal_info_route` | authentication/sign_up/view/personal_info/personal_info_screen.dart | [PersonalInfo, RegisterFields, Country] | ✅ | personal_info_controller.dart:125-170 | — | — |
| 39 | `/auth_id_verification_route` | authentication/sign_up/view/auth_id_verification/auth_id_verification_screen.dart | AuthIdVerificationBinding | ✅ | auth_id_verification_controller.dart:85-88 | آپلود multipart از postMultipart (فیکس v1.0.24) | — |
| 40 | `/wallet_details_route` | home/view/sub_sections/wallet_details/wallet_details.dart | WalletDetailsBinding | ✅ | wallet_details_controller.dart | — | — |
| 41 | `/add_money_history_route` | add_money/view/add_money_history/add_money_history.dart | AddMoneyHistoryBinding | ✅ | add_money_history_controller.dart:55-196 | فیلتر/صفحه‌بندی/وضعیت بک‌اند | — |
| 42 | `/make_payment_history_route` | make_payment/view/make_payment_history/make_payment_history.dart | MakePaymentHistoryBinding | ✅ | make_payment_history_controller.dart:54-196 | — | — |
| 43 | `/transfer_history_route` | transfer/view/transfer_history/transfer_history.dart | TransferHistoryBinding | ✅ | transfer_history_controller.dart:54-196 | — | — |
| 44 | `/transfer_received_history_route` | transfer/view/transfer_received_history/transfer_received_history.dart | TransferReceivedHistoryBinding | ✅ | transfer_received_history_controller.dart:54-196 | — | — |
| 45 | `/cash_out_history_route` | cash_out/view/cash_out_history/cash_out_history.dart | CashOutHistoryBinding | ✅ | cash_out_history_controller.dart:54-196 | — | — |
| 46 | `/withdraw_history_route` | withdraw/view/withdraw_history/withdraw_history.dart | WithdrawHistoryBinding | ✅ | withdraw_history_controller.dart:54-196 | — | — |
| 47 | `/exchange_history_route` | exchange/view/exchange_history/exchange_history.dart | ExchangeHistoryBinding | ✅ | exchange_history_controller.dart:54-196 | — | — |
| 48 | `/request_money_history_route` | request_money/view/request_money_history/request_money_history.dart | RequestMoneyHistoryBinding | ✅ | request_money_history_controller.dart:55-203؛ ولی details:86,93 force-unwrap | ⚠️ جزئی در صفحهٔ جزئیات | MODULE-FIX |
| 49 | `/gift_redeem_history_route` | gift_code/view/gift_redeem_history/gift_redeem_history.dart | GiftRedeemHistoryBinding | ✅ | gift_redeem_history_controller.dart:46-170 | — | — |
| 50 | `/create_beneficiary_route` | beneficiary/view/create_beneficiary/create_beneficiary_screen.dart | CreateBeneficiaryBinding | ✅ | create_beneficiary_screen.dart:24 (Get.put در view) | — | MODULE-FIX |
| 51 | `/update_beneficiary_route` | beneficiary/view/update_beneficiary/update_beneficiary_screen.dart | UpdateBeneficiaryBinding | ✅ | update_beneficiary_screen.dart:27 (Get.put در view) | — | MODULE-FIX |
| 52 | `/no_internet_connection` | presentation/widgets/no_internet_connection.dart | — | ✅ | صفحهٔ ابزار | — | — |
| 53 | `/bill_payment_route` | bill_payment/view/bill_payment_screen.dart | — (هاب بدون کنترلر؛ عمدی) | ✅ | bill_payment_screen.dart:19-25 | منوی ۶ سرویس | — |
| 54 | `/airtime_route` | bill_payment/view/airtime/airtime.dart | AirtimeBinding | ⚠️ | airtime_controller.dart:128-151,233-244; airtime_review_step_section.dart:140 | گارد دابل‌سابمیت و گارد موجودی ندارد؛ `serviceData.value!.charge!` force-unwrap؛ state «pending» بیل پنل هندل نمی‌شود | PAYMENT-FIX |
| 55 | `/electricity_route` | bill_payment/view/electricity/electricity.dart | ElectricityBinding | ⚠️ | همان الگوی airtime | همان ایرادها | PAYMENT-FIX |
| 56 | `/internet_route` | bill_payment/view/internet/internet.dart | InternetBinding | ⚠️ | همان الگو | همان ایرادها | PAYMENT-FIX |
| 57 | `/data_bundle_route` | bill_payment/view/data_bundle/data_bundle.dart | DataBundleBinding | ⚠️ | همان الگو | همان ایرادها | PAYMENT-FIX |
| 58 | `/cable_route` | bill_payment/view/cable/cable.dart | CableBinding | ⚠️ | همان الگو | همان ایرادها | PAYMENT-FIX |
| 59 | `/tool_route` (toll) | bill_payment/view/toll/toll.dart | TollBinding | ⚠️ | همان الگو | همان ایرادها | PAYMENT-FIX |
| 60 | `/virtual_card_route` | virtual_card/view/virtual_card_screen.dart | VirtualCardBinding | ✅ | virtual_card_controller.dart:33 | — | — |
| 61 | `/create_virtual_card_route` | virtual_card/view/create_virtual_card/create_virtual_card.dart | CreateNewCardBinding | ✅ | create_virtual_card_controller.dart:363-404 | IRR card + provider/holder + WebView پرداخت | — |
| 62 | `/virtual_card_details_route` | virtual_card/view/virtual_card_details/virtual_card_details.dart | VirtualCardDetailsBinding | ⚠️ | virtual_card_details_controller.dart:296-315 در برابر :367-434 | top-up قراردادی کامل (funding/wallet/gateway + گارد موجودی v1.0.24)؛ اما `reviewCalculate()` هنوز `getSetting(...)!` را force-unwrap می‌کند | PAYMENT-FIX |
| 63 | `/bill_payment_history_route` | bill_payment/view/bill_payment_history/bill_payment_history.dart | BillPaymentHistoryBinding | ✅ | bill_payment_history_controller.dart:22-74 | — | — |
| 64 | `/get_card_info_route` | virtual_card/view/get_card_info/get_card_info.dart | — | ✅ | صفحهٔ راهنما | — | — |
| 65 | `/virtual_card_transaction_route` | virtual_card/view/virtual_card_transaction/virtual_card_transaction.dart | VirtualCardTransactionBinding | ✅ | virtual_card_transaction_controller.dart:17-48; virtual_card_transaction.dart:86-87 | وضعیت از بک‌اند (Success/Pending) | — |
| 66 | `/payment_links_route` | payment_links/view/payment_links_screen.dart | PaymentLinksBinding | ✅ | payment_links_controller.dart:108-251 | ساخت لینک + تاریخچه + فیلتر + صفحه‌بندی | — |
| 67 | `/gift_card_route` | gift_card/view/gift_card_screen.dart | [GiftCard, GiftCardHistory] | ✅ | gift_card_controller.dart:168-350; history:46-175 | خرید + تاریخچه/فیلتر؛ `toStringAsFixed(2)` در review (gift_card_review_details_section.dart:100-159) | MODULE-FIX |
| 68 | `/maintenance_mode_route` | presentation/widgets/maintenance_mode.dart | — | ✅ | صفحهٔ ابزار (503) | — | — |
| 69 | `/p2p_trading_route` | p2p/view/p2p_view.dart | P2pBinding | 🔗 | p2p_controller.dart:361-445; p2p_order_details_screen.dart:25; my_order/chat | مارکت‌پلیس/سفارش/چت کامل؛ اما نهایی‌شدن سفارش به طرف مقابل وابسته است؛ Get.put در تب‌ها (p2p_view.dart:809-823) | MODULE-FIX |
| 70 | `/travel_route` | travel/home/travel_home_screen.dart | TravelBinding | ✅ | travel_controller.dart:76-575; travel_api_repository.dart:9-26 | فلو کامل هتل/پرواز/eSIM: جست‌وجو → نتایج → جزئیات → چک‌اوت (idempotency) → تأیید → سفارش‌ها؛ API واقعی `trip.ecardo.ir` با timeout 8s/30s | نیازمند داده بک‌اند سفر |
| 71 | `/travel_history_route` | travel/account/travel_history_screen.dart | TravelBinding | ✅ | travel_widgets.dart:161-173; travel_orders_screen.dart:11 | — | — |
| 72 | `/travel_account_route` | travel/account/travel_account_screen.dart | TravelBinding | ✅ | travel_account_screen.dart:14 | — | — |
| 73 | `/dynamic_password_route` | dynamic_password/view/dynamic_password_screen.dart | **بدون Binding** | ⚠️ | dynamic_password_screen.dart:20,49-52,194-197 | `Get.find<HomeController>()` بدون binding (کرش در ورود مستقیم/دیپ‌لینک)؛ endpoint هاردکد `'/pay/generate-otp'` خارج از ApiPath؛ دکمهٔ regenerate بدون گارد لودینگ | MODULE-FIX |
| 74 | `/remittance_route` | remittance/view/remittance_screen.dart | **بدون Binding** (Get.put در view) | ✅ | remittance_controller.dart:38-100,219-288,499-595,577; remittance_screen.dart:22 | فلو کامل: متد → کوئری با تایمر ۱۵دقیقه → ساخت → آپلود مدارک (postMultipart) → تاریخچه صفحه‌بندی‌شده؛ مبالغ با `toStringAsFixed(2)` هاردکد (remittance_controller.dart:694) | MODULE-FIX |
| 75 | `/remittance_history_route` | remittance/view/remittance_history/remittance_history.dart | **بدون Binding** (Get.put) | ✅ | remittance_history.dart:17,136-141 | — | MODULE-FIX |
| 76 | `/remittance_details_route` | remittance/view/remittance_details/remittance_details.dart | **بدون Binding** | ⚠️ | remittance_details.dart:16 (`Get.find<RemittanceController>()`) | اگر بدون عبور از صفحهٔ اصلی باز شود → GetX «"RemittanceController" not found» | MODULE-FIX |
| 77 | `/kyc_submit_wizard_route` | kyc_level/view/kyc_submit_wizard.dart | **بدون Binding** | ⚠️ | kyc_submit_wizard.dart:29; kyc_level_binding.dart:14 | کنترلر فقط از binding صفحهٔ navigation ثبت می‌شود؛ ورود مستقیم/دیپ‌لینک → کرش find | MODULE-FIX |
| 78 | `/upgrade_required_route` | kyc_level/view/upgrade_required_screen.dart | — | ✅ | upgrade_required_screen.dart:11 | صفحهٔ اطلاع‌رسانی سطح KYC | — |
| 79 | `/app_update_route` | app_update/view/app_update_screen.dart | — (کنترلر در main با `permanent: true`) | ✅ | main.dart:48-51; app_update_controller.dart:276-303 | دانلود APK با progress + نصب؛ Dio دانلود بدون timeout (کم‌اهمیت) | — |

### روت‌های تعریف‌شده ولی ثبت‌نشده (ثابت مرده)
`BaseRoute.invoice`، `BaseRoute.createInvoice`، `BaseRoute.updateInvoice`، `BaseRoute.invoiceDetails` (`routes.dart:47-52,92`) و `BaseRoute.replayTicket` (`routes.dart:88` — صفحهٔ ReplayTicket با `Get.to(() => ReplayTicket(...))` باز می‌شود: `support_tickets.dart:316`). هیچ GetPage‌ای برای آن‌ها وجود ندارد؛ اگر کدی با `Get.toNamed(BaseRoute.replayTicket)` فراخوانی شود به unknownRoute (اسپلش!) می‌رود.

---

## (ج) یافته‌های تاییدشده «از قبل فیکس شده» (دوباره فیکس نکنید ✅)

1. **splash orphaned ever()** — فیکس شده: ورکر ذخیره و در dispose آزاد می‌شود (`splash_screen.dart:116-122,137`).
2. **sign_in 2FA bypass** — فیکس شده: شرط `twoFa == true` بدون وابستگی به تنظیم محلی (`sign_in_controller.dart:134-159`)؛ فلو 2FA هم onboarding-aware است (`two_factor_auth_controller.dart:28-46`).
3. **web_view_screen برگشت پرداخت** — فیکس S-024: وضعیت از `payment-status/{tnx}` سرور (۳ تلاش)، اسکرپ فقط fallback و کاملاً try/catch، گارد `_redirectProcessed` (`web_view_screen.dart:80-143`).
4. **network_service** — timeoutها (15s/30s/30s)، صف refresh با fail-سریعِ null، هدر `X-App-Version` واقعی (بدون هاردکد)، Idempotency-Key برای POSTهای پولی، لاگ توکن/پسورد redact شده، هندل 426 فورس‌آپدیت (`network_service.dart:33-50,83-101,107-108,128-151,266-292,325-335,353-358`).
5. **گاردهای دابل‌سابمیت و موجودی** — در add_money (210,249)، exchange (768)، cash_out (280)، transfer (260)، make_payment (182) و گارد موجودی در exchange/cash_out/transfer/make_payment/virtual-card-topup (v1.0.24).
6. **آپلودهای multipart** — add_money manual (add_money_controller.dart:294)، KYC ثبت‌نام (auth_id_verification_controller.dart:85)، KYC Level S-019 (kyc_level_controller.dart:58-99) همه از `NetworkService.postMultipart`.
7. **exchange** — گارد موجودی (484-496)، قفل نرخ + watcher کهنگی (287-307)، debounce 300ms (686-699)، سرویس نرخ زنده با stale/disconnect (exchange_rate_service.dart:35-99)؛ نمایش نرخ زنده در amount step (exchange_amount_step_section.dart:86-92).
8. **kyc_level_binding** — `permanent: true` حذف شده (kyc_level_binding.dart:8-14).
9. **قفل زبان/جنسیت پروفایل** — فیکس overwrite جنسیت (profile_settings_controller.dart:269-291).
10. **drawrs/settings** — `catch (_) {}` ساکت در drawer_section.dart:344 به fail-closed تبدیل شده.
11. **AppUpdate** — `maybeAutoPromptForUpdate` بعد از اسپلش صدا زده می‌شود (splash_controller.dart:30-40) + هندل 426 سرور.

---

## (د) گروه‌بندی یافته‌ها به تفکیک ایجنت (دستور کار پیشنهادی)

### 🔧 MODULE-FIX (معماری/GetX/ناسازگاری UI)
| کد | یافته | شواهد | «کامل» یعنی |
|---|---|---|---|
| M-1 | ثبت کنترلر با `Get.put` داخل view (≈۲۵ نقطه) به‌موازات bindingهای موجود — DI دوگانه و ناسازگار | gift_code_screen.dart:27-32؛ transfer_screen.dart:25؛ add_money_screen.dart:27؛ p2p_view.dart:809-823؛ travel_widgets.dart:59؛ remittance_screen.dart:22؛ remittance_history.dart:17؛ beneficiary screens:24,27؛ my_order/my_ads/create_ad/apply_verification screens | حذف Get.put از viewها و اتکا به binding؛ یا حذف bindingهای بلااستفاده — یک قرارداد واحد |
| M-2 | روت بدون Binding که به `Get.find` کنترلرِ روتِ دیگر تکیه دارد | dynamic_password_screen.dart:20 (HomeController)؛ kyc_submit_wizard.dart:29 (KycLevelController)؛ remittance_details.dart:16 (RemittanceController) | Binding اختصاصی برای هر ۳ روت یا مقاوم‌سازی find با `Get.isRegistered` |
| M-3 | DynamicPassword: endpoint هاردکد `'/pay/generate-otp'` خارج از ApiPath + دکمهٔ regenerate بدون گارد لودینگ (دابل‌کلیک → چند OTP همزمان) | dynamic_password_screen.dart:50,194-197 | انتقال به ApiPath + گارد `if (_isLoading) return` |
| M-4 | مطابقت رشته‌ای وضعیت‌ها با کِیسینگ ناسازگار ("Success"/"Pending" در تراکنش‌ها، "pending"/"approved" در KYC) | transactions_pop_up.dart:153-174؛ virtual_card_transaction.dart:86-87؛ kyc_history.dart:105-120 | نگاشت case-insensitive یا enum مشترک از types_and_status_model |
| M-5 | Feature «Rate Alert» صرفاً UI بی‌اثر با TODO بک‌اند | rate_alert_placeholder.dart:71; exchange_amount_step_section.dart:142-155 | اتصال به endpoint یا پنهان‌سازی تا آماده شدن |
| M-6 | توکن‌های مردهٔ روت (invoice* و replayTicket) در routes.dart | routes.dart:47-52,88,92 | حذف یا ثبت GetPage (در صورت لزوم فلو فاکتور) |
| M-7 | مبالغ remittance/gift_card با `toStringAsFixed(2)` هاردکد به‌جای DynamicDecimalsHelper / decimals بک‌اند | remittance_controller.dart:694؛ remittance_history.dart:136-141؛ remittance_review_section.dart:28-32؛ gift_card_review_details_section.dart:100-159 | استفاده از decimals ارز (`site_currency_decimals` / `currency_decimals`) مثل request_money |
| M-8 | force-unwrapهای `double.tryParse(x!)!` در صفحات جزئیات request_money | request_money_history_details.dart:86,93؛ received_request_details.dart:84,91؛ accept_request_dropdown.dart:111؛ request_money_success_step_section.dart:131,144 | safe-parse با fallback |
| M-9 | کنترلر AppUpdate با `permanent: true` (تنها مورد باقیمانده؛ عمدی اما مستند شود) | main.dart:48-51 | قابل قبول؛ فقط در صورت حذف سرویس، آزاد شود |

### 💳 PAYMENT-FIX (پول‌سازها/آپلود/gateway)
| کد | یافته | شواهد | «کامل» یعنی |
|---|---|---|---|
| P-1 | ۶ کنترلر با `dio.Dio()` خام (بدون timeout/401-refresh/Idempotency-Key) — bypass لایهٔ شبکه | create_withdraw_account_controller.dart:199؛ edit_withdraw_account_controller.dart:131؛ profile_settings_controller.dart:258؛ apply_verification_controller.dart:309؛ add_payment_method_controller.dart:209؛ edit_payment_account_controller.dart:108 | مهاجرت به `NetworkService.postMultipart` (الگوی فیکس‌شدهٔ add_money:291-297) |
| P-2 | شش سرویس Bill Payment: بدون گارد دابل‌سابمیت در کنترلر و دکمه، بدون گارد موجودی، force-unwrap `charge!/rate!`، بدون state «pending» (فقط toast+reset) | airtime_controller.dart:128-151,233-244؛ airtime_review_step_section.dart:140؛ همین الگو در electricity/internet/data_bundle/cable/toll | گارد `if (isSubmitLoading.isTrue) return`، گارد موجودی مثل transfer، safe-parse، و نمایش وضعیت pending بک‌اند + ورود به bill_payment_history |
| P-3 | `reviewCalculate()` کارت مجازی: `getSetting("card_topup_charge")!` و `double.tryParse(...)!` کرش‌پرور (validateAmountStep همان فایل safe شده اما این تابع نه) | virtual_card_details_controller.dart:300-312 در برابر 367-434 | safe-parse با default 0 |
| P-4 | `localization!` force-unwrap در بلوک‌های catch شبکه — اگر context در دسترس نباشد، خودِ هندلر خطا کرش می‌کند | network_service.dart:350,407,427,456,497,526,555,587,609,637,648,731-757 | استفاده از getter امن `localization?.x ?? fallback` (الگوی biometric_auth_service.dart:17-21) |
| P-5 | Remittance: `Get.find` در دیتیل + ثبت در view (پوشش M-2/M-1) و decimals هاردکد (پوشش M-7) | remittance_details.dart:16؛ remittance_controller.dart:694 | — |
| P-6 | دانلود APK بدون timeout (فقط کم‌اهمیت؛ progress دارد) | app_update_controller.dart:276-287 | `receiveTimeout` مناسب |

### 🔐 AUTH-BIO (احراز هویت/بیومتریک/نوتیفیکیشن)
| کد | یافته | شواهد | «کامل» یعنی |
|---|---|---|---|
| A-1 | اعلان `POST_NOTIFICATIONS` در AndroidManifest صراحتاً ثبت نشده (پلاگین firebase_messaging معمولاً merge می‌کند اما نبودِ خط صریح = ریسک در اندروید 13+) و گیت runtime مجزا قبل از requestPermission وجود ندارد | android/app/src/main/AndroidManifest.xml:4-20؛ firebase_messaging_service.dart:91-101 | افزودن `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` + flow توضیح/دنباله‌گیری Permission |
| A-2 | تپ نوتیف → صفحهٔ مرتبط فقط برای `app_update` پیاده شده؛ سایر پوش‌ها (تراکنش/تیکت/KYC) فقط toast محلی؛ نوتیف لوکال اصلاً handler تپ ندارد (`onDidReceiveNotificationResponse` تنظیم نشده) و payload آن `data.toString()` است (بدون قرارداد دیپ‌لینک) | firebase_messaging_service.dart:158-167؛ local_notifications_service.dart:32-47,50-74 | نقشهٔ `type → BaseRoute` در `_onMessageOpenedApp` + ثبت handler تپ لوکال + payload ساختاریافته |
| A-3 | توکن FCM تازه فقط محلی ذخیره می‌شود؛ ثبت سمت بک‌اند فقط هنگام login بعدی (postFcmNotification) | firebase_messaging_service.dart:111-114؛ sign_in_controller.dart:172-211 | ارسال توکن جدید به `getSetupFcm` در `onTokenRefresh` (یا sync بعد از ورود خودکار) |
| A-4 | «logged_in» در onInitِ SignInController قبل از موفقیت ذخیره می‌شود (اسپلش همیشه به signIn می‌رود؛ بی‌ضرر اما معنای state مخدوش) | sign_in_controller.dart:65-67 | ذخیره پس از موفقیت fetchUser |
| A-5 | بیومتریک: گیت سالم است ولی در لایهٔ view (onTap)؛ آیکون `fingerprintCommonIcon` درست است | sign_in_screen.dart:302-344,370-373 | اختیاری: انتقال منطق به کنترلر |
| A-6 | مجوزهای پرریسک manifest: `QUERY_ALL_PACKAGES` (ریسک سیاست پلی‌استور) و نبود متادیتای `default_notification_channel_id` برای FCM | AndroidManifest.xml:19-20 | حذف/محدودسازی queries + افزودن متادیتای کانال |

---

## (هـ) نقاط خالی و ناتمام (همهٔ ⚠️/❌ با شواهد دقیق)

1. **Bill Payment ×6 (airtime/electricity/internet/data_bundle/cable/toll) — ⚠️** تنها ماژول پولی بدون گارد دابل‌سابمیت/موجودی. شواهد: `airtime_controller.dart:128-151` (submit بدون early-return) و `airtime_review_step_section.dart:140` (دکمه بدون بررسی isLoading)؛ `airtime_controller.dart:233-244` (`charge!`/`rate!`). «کامل» = گاردهای هم‌تراز transfer_controller.dart:260 + safe-parse + نمایش وضعیت pending سرور.
2. **Withdraw (ساخت/ویرایش حساب برداشت) — ⚠️** `create_withdraw_account_controller.dart:199-208` و `edit_withdraw_account_controller.dart:131` با `dio.Dio()` خام: بی‌timeout، بی‌401-refresh، بی‌Idempotency-Key. «کامل» = مهاجرت به postMultipart.
3. **Profile Settings (آپلود آواتار) — ⚠️** `profile_settings_controller.dart:258` همان bypass.
4. **P2P apply_verification / payment_account (add/edit) — ⚠️** `apply_verification_controller.dart:309`، `add_payment_method_controller.dart:209`، `edit_payment_account_controller.dart:108` همان bypass.
5. **Virtual Card Details — ⚠️** `virtual_card_details_controller.dart:300-312` force-unwrap تنظیمات کارمزد (بقیهٔ فایل safe شده). 
6. **Dynamic Password — ⚠️** بدون binding (`routes_handler.dart:444-447`)، `Get.find<HomeController>()` (`dynamic_password_screen.dart:20`)، endpoint هاردکد (`:50`)، regenerate بدون گارد (`:194-197`). «کامل» = binding مستقل + ApiPath + گارد + (اختیاری) تاریخچهٔ OTPها.
7. **Remittance Details / KYC Submit Wizard — ⚠️** ورود مستقیم با روت → `Get.find` کرش می‌کند (`remittance_details.dart:16`، `kyc_submit_wizard.dart:29`).
8. **Rate Alert — ⚠️ (UI بی‌اثر)** `rate_alert_placeholder.dart:71` TODO بک‌اند؛ در amount step نمایش داده می‌شود (`exchange_amount_step_section.dart:142-155`).
9. **Remittance/Gift Card decimals — ⚠️** `remittance_controller.dart:694` و `gift_card_review_details_section.dart:100-159` هاردکد ۲ رقم؛ برخلاف request_money/add_money که DynamicDecimalsHelper دارند (`dynamic_decimals_helper.dart:1-16`).
10. **Request Money Details force-unwrap — ⚠️** `request_money_history_details.dart:86,93`، `received_request_details.dart:84,91`، `accept_request_dropdown.dart:111`، `request_money_success_step_section.dart:131,144`.
11. **Push tap-routing — ⚠️ (AUTH-BIO)** فقط `app_update` مسیریابی می‌شود (`firebase_messaging_service.dart:158-167`)؛ تپ نوتیف لوکال بی‌عمل (`local_notifications_service.dart:32`).
12. **POST_NOTIFICATIONS — ⚠️ (AUTH-BIO)** `AndroidManifest.xml:4-20` فاقد اجزای صریح اندروید 13+.
13. **❌ خالی/کرش‌پرور:** هیچ صفحهٔ اسکلت خالی یا فلو کاملاً شکسته یافت نشد. نزدیک‌ترین ریسک‌های کرش همان force-unwrapهای بندهای 5 و 10 و `localization!` های `network_service.dart` (P-4) هستند که در مسیر خطا فعال می‌شوند.
14. **🔗 وابسته به بیرون:** cash_out (`cash_out_controller.dart:283-295` — agent_number؛ تسویه با ایجنت)، make_payment (MID؛ تأیید سمت پذیرنده)، P2P (طرف مقابل سفارش/چت `p2p_order_details_screen.dart`). همهٔ تاریخچه‌ها دادهٔ واقعی بک‌اند را می‌خوانند و وضعیت از سرور می‌آید؛ دادهٔ خارج از کلاینت قابل راستی‌آزمایی نیست («نیازمند داده بک‌اند»).
15. **Travel — ✅ (نیازمند داده بک‌اند سفر):** بوت‌استرپ/سرویس‌ها/قابلیت خرید از `trip.ecardo.ir/api/v1` با timeout و idempotency (`travel_api_repository.dart:9-26`، `travel_controller.dart:455-534`)؛ فلو هتل/پرواز/eSIM → چک‌اوت → واچر → سفارش‌ها کامل است.

---

## (و) یادداشت‌های معماری (خلاصه برای Lead)
- **GetX DI دوگانه:** bindingهای `routes_handler` در چند ماژول عملاً دور زده می‌شوند چون viewها خودشان `Get.put` می‌کنند (M-1). رفتار فعلی کار می‌کند ولی cleanup و تست‌پذیری را خراب می‌کند.
- **قرارداد شبکه یک‌پارچه نیست:** `NetworkService` سخت‌گیر و کامل است اما ۶ نقطهٔ multipart آن را bypass می‌کنند (P-1) و یک endpoint هاردکد خارج ApiPath وجود دارد (M-3).
- **Routing:** unknownRoute به اسپلش می‌رود (`app.dart:56-60`) — بهتر است صفحهٔ not-found اختصاصی باشد؛ روت‌های ثابت مرده M-6 نیز مرتبط است.
- **Idempotency سمت کلاینت فقط برای ۶ endpoint** (`network_service.dart:43-50`)؛ `pay-bill` پوشش داده شده اما گاردهای UI بیل‌پنل همچنان ضعیف‌اند (P-2).
- هیچ secret/token در این سند منتشر نشده است.
