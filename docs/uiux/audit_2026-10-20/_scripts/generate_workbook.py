import csv
import os
import sys

sys.stdout.reconfigure(encoding="utf-8")

os.makedirs("docs/uiux/audit_2026-10-20", exist_ok=True)

with open("../_inbox/ecardo_uiux_zero_to_excellence_2026-10-20/ecardo_uiux_zero_to_excellence_2026-10-20/03_PAGE_ROUTE_AUDIT_WORKBOOK.csv", encoding="utf-8-sig") as f:
    template_rows = list(csv.DictReader(f))

mapping = {
    "HOME-001": {
        "route": "BaseRoute.navigation",
        "screen": "lib/src/presentation/screens/home/view/home_screen.dart",
        "ctrl": "HomeController, SettingsService, WalletLiveRateService",
        "api": "/user/dashboard, /auth/user/get, /get-settings",
        "owner": "core/dashboard",
        "status": "VERIFIED",
        "before": "test_output/screens/home__light.png",
        "after": "test_output/screens/home__dark.png",
        "findings": "Multi-currency hero integrates WalletLiveRateService with fallback rate 95000.0. Quick actions route correctly. Tab lazy loading active."
    },
    "WAL-001": {
        "route": "BaseRoute.wallets",
        "screen": "lib/src/presentation/screens/wallets/view/wallets_screen.dart",
        "ctrl": "WalletsController",
        "api": "/user/wallets, /get-currencies",
        "owner": "fintech/accounts",
        "status": "VERIFIED",
        "before": "test_output/screens/wallets__light.png",
        "after": "test_output/screens/wallets__empty.png",
        "findings": "Empty, error, and loaded states covered by golden tests. Real-time rate conversion and privacy mode toggle working."
    },
    "WAL-002": {
        "route": "BaseRoute.walletsDetails",
        "screen": "lib/src/presentation/screens/home/view/sub_sections/wallet_details/wallet_details.dart",
        "ctrl": "WalletsController, HomeController",
        "api": "/user/wallets",
        "owner": "fintech/accounts",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Displays wallet transaction history, balance breakdown, and address/account identifiers. Lacks dedicated golden test."
    },
    "WAL-003": {
        "route": "BaseRoute.createNewWallet",
        "screen": "lib/src/presentation/screens/wallets/view/create_new_wallet/create_new_wallet.dart",
        "ctrl": "CreateNewWalletController",
        "api": "/user/wallets",
        "owner": "fintech/accounts",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Supports currency selection and wallet creation. Form validation and failure handling implemented."
    },
    "WAL-004": {
        "route": "BaseRoute.walletsDetails",
        "screen": "lib/src/presentation/screens/home/view/sub_sections/wallet_details/wallet_details.dart",
        "ctrl": "WalletsController",
        "api": "N/A (Managed via default wallet toggle)",
        "owner": "fintech/accounts",
        "status": "NO_DIRECT_ACTION",
        "before": "",
        "after": "",
        "findings": "Backend does not expose a wallet delete/archive endpoint; users toggle default wallet status instead."
    },
    "CARD-001": {
        "route": "BaseRoute.virtualCard",
        "screen": "lib/src/presentation/screens/virtual_card/view/virtual_card_screen.dart",
        "ctrl": "VirtualCardController",
        "api": "/user/cards, /get-card-providers",
        "owner": "fintech/cards",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Embedded in navigation shell as tab index 2 and accessible as independent route. Provider card carousel and status badges functional."
    },
    "CARD-002": {
        "route": "BaseRoute.virtualCardDetails",
        "screen": "lib/src/presentation/screens/virtual_card/view/virtual_card_details/virtual_card_details.dart",
        "ctrl": "VirtualCardDetailsController",
        "api": "/user/bsicards/cards/details, /user/cards/update-status",
        "owner": "fintech/cards",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Integrated CardFreezeOverlay and _CardOtpBottomSheet with 90s countdown for secure CVV display (AUD-005 verified)."
    },
    "CARD-003": {
        "route": "BaseRoute.createVirtualCard",
        "screen": "lib/src/presentation/screens/virtual_card/view/create_virtual_card/create_virtual_card.dart",
        "ctrl": "CreateVirtualCardController",
        "api": "/user/card-products, /user/card-orders",
        "owner": "fintech/cards",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Multi-step virtual card issuance wizard with card template preview and funding wallet selection."
    },
    "CARD-004": {
        "route": "BaseRoute.virtualCardDetails",
        "screen": "lib/src/presentation/screens/virtual_card/widgets/virtual_card_security_controls.dart",
        "ctrl": "VirtualCardDetailsController",
        "api": "/user/cards/update-status",
        "owner": "fintech/cards",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Tactile freeze toggle backed by API call with frosted blur feedback. Tested in virtual_card_modernization_test.dart."
    },
    "CARD-005": {
        "route": "BaseRoute.virtualCardDetails",
        "screen": "lib/src/presentation/screens/virtual_card/view/sub_sections/virtual_card_top_up_amount_section.dart",
        "ctrl": "VirtualCardDetailsController",
        "api": "/user/cards/balance/topup, /user/cards/{id}/irr-topup",
        "owner": "fintech/cards",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Safe charge calculation handles missing backend settings without crashing (TODO lead noted at L399)."
    },
    "TRF-001": {
        "route": "BaseRoute.transfer",
        "screen": "lib/src/presentation/screens/transfer/view/transfer_screen.dart",
        "ctrl": "TransferController",
        "api": "/user/transfer/config, /user/transfer",
        "owner": "fintech/transfers",
        "status": "VERIFIED",
        "before": "test_output/screens/transfer_review_step__light.png",
        "after": "test_output/screens/transfer_success_step__dark.png",
        "findings": "Debounced 400ms recipient lookup badge (AUD-006). Review step and success celebration screen verified."
    },
    "TRF-002": {
        "route": "BaseRoute.remittance",
        "screen": "lib/src/presentation/screens/remittance/view/remittance_screen.dart",
        "ctrl": "RemittanceController",
        "api": "/user/remittance/methods, /user/remittance/quote, /user/remittance/store",
        "owner": "fintech/remittance",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Multi-step flow for international payouts. Inactive payout methods trigger hardcoded unlocalized Coming Soon snackbar."
    },
    "TRF-003": {
        "route": "BaseRoute.p2pTrading",
        "screen": "lib/src/presentation/screens/p2p/view/p2p_view.dart",
        "ctrl": "P2pController",
        "api": "/user/p2p/marketplace, /user/p2p/orders, /user/p2p/payment-methods",
        "owner": "fintech/p2p",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Full P2P marketplace with order book, escrow dispute flow, chat messaging, and verified trader application."
    },
    "TRF-004": {
        "route": "BaseRoute.requestMoney",
        "screen": "lib/src/presentation/screens/request_money/view/request_money_screen.dart",
        "ctrl": "RequestMoneyController",
        "api": "/user/request-money, /user/request-money/history",
        "owner": "fintech/transfers",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Dynamic decimals applied. QR code request sharing and history list fully wired."
    },
    "EXC-001": {
        "route": "BaseRoute.exchange",
        "screen": "lib/src/presentation/screens/exchange/view/exchange_screen.dart",
        "ctrl": "ExchangeController, ExchangeRateService",
        "api": "/user/exchange/config",
        "owner": "fintech/exchange",
        "status": "VERIFIED",
        "before": "test_output/screens/exchange__amount__light.png",
        "after": "test_output/screens/exchange__review__light.png",
        "findings": "Interactive swap widget with inverse quote calculation and countdown timer for quote expiry."
    },
    "EXC-002": {
        "route": "BaseRoute.exchange",
        "screen": "lib/src/presentation/screens/exchange/view/sub_sections/exchange_swap_review_step_section.dart",
        "ctrl": "ExchangeController",
        "api": "/user/exchange",
        "owner": "fintech/exchange",
        "status": "VERIFIED",
        "before": "test_output/screens/exchange__review__dark.png",
        "after": "test_output/screens/exchange__success__light.png",
        "findings": "Review modal requires transaction passcode verification if enabled. Enforces freshness check on rates."
    },
    "WDR-001": {
        "route": "BaseRoute.withdraw",
        "screen": "lib/src/presentation/screens/withdraw/view/withdraw_screen.dart",
        "ctrl": "WithdrawController, WithdrawAccountController",
        "api": "/user/withdraw-accounts, /user/withdraw",
        "owner": "fintech/withdraw",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Withdraw destination bank/card account management with dynamic fee calculation and passcode verification."
    },
    "CASH-001": {
        "route": "BaseRoute.cashOut",
        "screen": "lib/src/presentation/screens/cash_out/view/cash_out_screen.dart",
        "ctrl": "CashOutController",
        "api": "/user/cashout/config, /user/cashout",
        "owner": "fintech/cashout",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Supports Agent ID (AID) pre-fill from QR scanner (AUD-008). Validates agent account status prior to execution."
    },
    "PAY-001": {
        "route": "BaseRoute.makePayment",
        "screen": "lib/src/presentation/screens/make_payment/view/make_payment_screen.dart",
        "ctrl": "MakePaymentController",
        "api": "/user/payment/settings, /user/payment/make",
        "owner": "fintech/payments",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Merchant ID (MID) QR scanning pre-populates merchant checkout details. Dynamic currency converter supported."
    },
    "GFT-001": {
        "route": "BaseRoute.giftCode",
        "screen": "lib/src/presentation/screens/gift_code/view/gift_code_screen.dart",
        "ctrl": "GiftCodeController, CreateGiftController, GiftRedeemController",
        "api": "/user/gifts/config, /user/gifts, /user/gifts/redeem",
        "owner": "services/gifts",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Allows generating redeemable gift voucher codes with optional passcode and direct redemption tab."
    },
    "BIL-001": {
        "route": "BaseRoute.billPayment",
        "screen": "lib/src/presentation/screens/bill_payment/view/bill_payment_screen.dart",
        "ctrl": "BillPaymentController",
        "api": "/get-bill-countries, /user/pay-bill/services, /user/pay-bill",
        "owner": "services/bills",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Categorized utility payment hub (airtime, electricity, internet, toll, cable). AUD-002 dynamic receipt verified."
    },
    "QR-001": {
        "route": "BaseRoute.qrCode",
        "screen": "lib/src/presentation/screens/qr_code/view/qr_code_screen.dart",
        "ctrl": "QrCodeController",
        "api": "/user/qrcode",
        "owner": "core/qr",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Floating action button triggers QR scanner. Routes AID to CashOut, MID to MakePayment, UID to Transfer (AUD-008)."
    },
    "CRY-001": {
        "route": "BaseRoute.wallets",
        "screen": "lib/src/presentation/screens/wallets/view/wallets_screen.dart",
        "ctrl": "WalletsController",
        "api": "/user/wallets",
        "owner": "crypto/core",
        "status": "VERIFIED",
        "before": "test_output/screens/wallets__light.png",
        "after": "test_output/screens/wallets__dark.png",
        "findings": "Crypto wallets (BTC, USDT) separated by isCrypto flag. Strict formatting via dynamic decimals."
    },
    "CRY-002": {
        "route": "BaseRoute.wallets",
        "screen": "lib/src/presentation/screens/wallets/widgets/crypto_deposit_bottom_sheet.dart",
        "ctrl": "WalletsController",
        "api": "/user/wallets/deposit-policy (simulated fail-closed)",
        "owner": "crypto/deposit",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Strict fail-closed policy verified (AUD-001). Never falls back to hardcoded address or client cache."
    },
    "CRY-003": {
        "route": "BaseRoute.transactions",
        "screen": "lib/src/presentation/screens/transactions/view/transactions_screen.dart",
        "ctrl": "TransactionsController",
        "api": "/user/transactions",
        "owner": "crypto/transactions",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Real-time push notification updates KYC and balance upon deposit confirmation. Displays pending/complete states."
    },
    "CRY-004": {
        "route": "BaseRoute.withdraw",
        "screen": "lib/src/presentation/screens/withdraw/view/withdraw_screen.dart",
        "ctrl": "WithdrawController",
        "api": "/user/withdraw",
        "owner": "crypto/withdraw",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Tron TRC-20 address validator tested in tron_address_validator_test.dart. Network fee preview enforced."
    },
    "ACT-001": {
        "route": "BaseRoute.transactions",
        "screen": "lib/src/presentation/screens/transactions/view/transactions_screen.dart",
        "ctrl": "TransactionsController",
        "api": "/user/transactions",
        "owner": "activity/history",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Filterable transaction stream (all, transfer, exchange, deposit, withdraw) with infinite scroll pagination."
    },
    "ACT-002": {
        "route": "BaseRoute.transactions",
        "screen": "lib/src/presentation/screens/transactions/view/sub_sections/transaction_details_bottom_sheet.dart",
        "ctrl": "TransactionsController",
        "api": "/user/transactions/{id}",
        "owner": "activity/details",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Modal bottom sheet displays authoritative status badge, fee breakdown, transaction ID, and timestamp."
    },
    "ACT-003": {
        "route": "BaseRoute.transactions",
        "screen": "lib/src/presentation/screens/transactions/view/sub_sections/transaction_details_bottom_sheet.dart",
        "ctrl": "TransactionsController",
        "api": "N/A (SharePlus client integration)",
        "owner": "activity/share",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Shares sanitized text receipt without exposing authentication tokens or unmasked sensitive account numbers."
    },
    "ACT-004": {
        "route": "BaseRoute.transactions",
        "screen": "lib/src/presentation/screens/transactions/view/transactions_screen.dart",
        "ctrl": "TransactionsController",
        "api": "/user/transactions/export (client filter)",
        "owner": "activity/export",
        "status": "PARTIAL",
        "before": "",
        "after": "",
        "findings": "In-app date filtering available. Direct PDF/CSV file export is not yet wired to a server-side generator."
    },
    "AUT-001": {
        "route": "BaseRoute.welcome",
        "screen": "lib/src/presentation/screens/authentication/welcome/view/welcome_screen.dart",
        "ctrl": "none",
        "api": "none",
        "owner": "auth/onboarding",
        "status": "VERIFIED",
        "before": "test_output/screens/welcome__light.png",
        "after": "test_output/screens/welcome__dark.png",
        "findings": "Onboarding carousel with light/dark/RTL golden test coverage. Action buttons navigate to SignIn and SignUp."
    },
    "AUT-002": {
        "route": "BaseRoute.signIn",
        "screen": "lib/src/presentation/screens/authentication/sign_in/view/sign_in_screen.dart",
        "ctrl": "SignInController",
        "api": "/auth/user/login, /auth/user/login-otp/request",
        "owner": "auth/login",
        "status": "VERIFIED",
        "before": "test_output/screens/signin__light.png",
        "after": "test_output/screens/signin__dark.png",
        "findings": "Dual mode: Password-based and passwordless Email OTP login (Wave-1). Biometric login prompt on supported hardware."
    },
    "AUT-003": {
        "route": "BaseRoute.email",
        "screen": "lib/src/presentation/screens/authentication/sign_up/view/email/email_screen.dart",
        "ctrl": "EmailController, SignUpController",
        "api": "/get-register-fields/user, /auth/user/register",
        "owner": "auth/registration",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Dynamic registration fields fetched from backend. Multi-step registration flow: Email -> Verify -> Personal Info -> Password."
    },
    "AUT-004": {
        "route": "BaseRoute.verifyEmail",
        "screen": "lib/src/presentation/screens/authentication/sign_up/view/verify_email/verify_email_screen.dart",
        "ctrl": "VerifyEmailController",
        "api": "/auth/user/send-verify-email, /auth/user/validate-verify-email",
        "owner": "auth/otp",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Countdown timer for OTP resend with rate-limit handling and clear error feedback."
    },
    "AUT-005": {
        "route": "BaseRoute.forgotPassword",
        "screen": "lib/src/presentation/screens/authentication/forgot_password/view/forgot_password_screen.dart",
        "ctrl": "ForgotPasswordController",
        "api": "/auth/user/forgot-password, /auth/user/reset-verify-otp, /auth/user/reset-password",
        "owner": "auth/recovery",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "3-stage password recovery: Email prompt -> PIN verification -> Reset password input."
    },
    "AUT-006": {
        "route": "BaseRoute.setUpPassword",
        "screen": "lib/src/presentation/screens/authentication/sign_up/view/set_up_password/set_up_password_screen.dart",
        "ctrl": "SetUpPasswordController",
        "api": "/user/passcode/change",
        "owner": "security/passcode",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "6-digit transaction PIN setup with re-entry confirmation. Dead constant BaseRoute.setPasscode was cleaned up in v1.0.88."
    },
    "AUT-007": {
        "route": "BaseRoute.signIn (embedded widget)",
        "screen": "lib/src/presentation/widgets/verify_passcode.dart",
        "ctrl": "PasscodeService",
        "api": "/user/passcode/verify",
        "owner": "security/passcode",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Passcode state machine verified in passcode_resilience_state_machine_test.dart. Exponential backoff on failed attempts."
    },
    "AUT-008": {
        "route": "BaseRoute.signIn",
        "screen": "lib/src/presentation/screens/authentication/sign_in/view/sign_in_screen.dart",
        "ctrl": "SignInController, BiometricService",
        "api": "/auth/user/login",
        "owner": "security/biometric",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Hardware biometric gate with local_auth. Safe fallback to email OTP or password if biometrics cancelled."
    },
    "KYC-001": {
        "route": "BaseRoute.idVerification",
        "screen": "lib/src/presentation/screens/settings/view/id_verification/id_verification.dart",
        "ctrl": "IdVerificationController, KycLevelController",
        "api": "/user/kyc, /user/kyc-level/status, /user/kyc-level/levels",
        "owner": "compliance/kyc",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Dynamic tier level card (Tier 0 to Tier 3) showing transaction limits and required verification steps."
    },
    "KYC-002": {
        "route": "BaseRoute.kycSubmitWizard",
        "screen": "lib/src/presentation/screens/kyc_level/view/kyc_submit_wizard.dart",
        "ctrl": "KycSubmitWizardController",
        "api": "/user/kyc-level/submit",
        "owner": "compliance/kyc",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Multi-step wizard with camera/gallery image picker, client-side image compression, and progress indicator."
    },
    "KYC-003": {
        "route": "BaseRoute.kycHistory",
        "screen": "lib/src/presentation/screens/settings/view/id_verification/kyc_history/kyc_history.dart",
        "ctrl": "KycHistoryController",
        "api": "/user/kyc/history, /user/kyc/rejected-data",
        "owner": "compliance/kyc",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Displays historical verification submissions, approval timestamps, and specific rejection reasons with retry option."
    },
    "NOT-001": {
        "route": "BaseRoute.notifications",
        "screen": "lib/src/presentation/screens/settings/view/notifications/notifications.dart",
        "ctrl": "NotificationsController, NotificationHistoryService",
        "api": "/get-notifications, /mark-as-read-notification",
        "owner": "notifications/center",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Interactive notification list with swipe-to-dismiss, mark-all-as-read, unread counter badge, and dynamic event icons."
    },
    "NOT-002": {
        "route": "BaseRoute.navigation (via FCM payload)",
        "screen": "lib/src/common/services/firebase_messaging_service.dart",
        "ctrl": "FirebaseMessagingService",
        "api": "/setup-fcm",
        "owner": "notifications/push",
        "status": "PARTIAL_DEFECT",
        "before": "",
        "after": "",
        "findings": "FCM notification payload routing works in-app, but OS-level deep linking (<intent-filter>) is missing from AndroidManifest.xml."
    },
    "PRO-001": {
        "route": "BaseRoute.profileSettings",
        "screen": "lib/src/presentation/screens/settings/view/profile_settings/profile_settings.dart",
        "ctrl": "ProfileSettingsController",
        "api": "/user/settings/profile",
        "owner": "profile/user",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Profile avatar upload, personal details editing, and localized validation."
    },
    "SET-001": {
        "route": "BaseRoute.navigation (Settings tab)",
        "screen": "lib/src/presentation/screens/settings/view/settings_screen.dart",
        "ctrl": "LocaleThemeService",
        "api": "/get-languages, /change-language/{code}",
        "owner": "settings/i18n",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Supports 6 languages (en, fa, ar, tr, ru, zh). Uses BaseRoute.localeTransition waypoint to prevent release-mode crash."
    },
    "SET-002": {
        "route": "BaseRoute.navigation (Settings tab)",
        "screen": "lib/src/presentation/screens/settings/view/settings_screen.dart",
        "ctrl": "LocaleThemeService",
        "api": "N/A (Local shared preferences persistence)",
        "owner": "settings/theme",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Seamless light/dark mode switching persisted across sessions. Dark theme flash on boot resolved."
    },
    "SET-003": {
        "route": "BaseRoute.permissionsSettings",
        "screen": "lib/src/presentation/screens/settings/view/permissions_settings_screen.dart",
        "ctrl": "PermissionFlowService",
        "api": "N/A (OS Permissions API)",
        "owner": "settings/privacy",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Granular permission status overview (camera, storage, biometric, notification)."
    },
    "SET-004": {
        "route": "BaseRoute.deviceSessionsSecurity",
        "screen": "lib/src/presentation/screens/settings/view/security/device_sessions_security_screen.dart",
        "ctrl": "DeviceSessionsSecurityController",
        "api": "/user/settings/sessions, /user/settings/sessions/revoke",
        "owner": "settings/security",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Active device sessions list with IP, location, device model, and remote revocation button."
    },
    "SUP-001": {
        "route": "BaseRoute.supportTickets",
        "screen": "lib/src/presentation/screens/settings/view/support_tickets/support_tickets.dart",
        "ctrl": "SupportTicketsController",
        "api": "/user/ticket",
        "owner": "support/tickets",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Support ticket list with search, status filtering (open, answered, closed), and ticket replay navigation."
    },
    "SUP-002": {
        "route": "BaseRoute.addNewTicket",
        "screen": "lib/src/presentation/screens/settings/view/support_tickets/add_new_ticket/add_new_ticket.dart",
        "ctrl": "AddNewTicketController",
        "api": "/user/ticket",
        "owner": "support/tickets",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Auto-attachment card pre-populates transaction ref, amount, and department (AUD-007). File attachment support included."
    },
    "RWD-001": {
        "route": "BaseRoute.referral",
        "screen": "lib/src/presentation/screens/referral/view/referral_screen.dart",
        "ctrl": "ReferralController",
        "api": "/user/referral/info, /user/referral/direct, /user/referral/tree",
        "owner": "services/referral",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Multi-tier affiliate tree visualization and direct referral list with link copy/share buttons."
    },
    "SRV-001": {
        "route": "BaseRoute.travel",
        "screen": "lib/src/presentation/screens/travel/home/travel_home_screen.dart",
        "ctrl": "TravelController, TravelApiRepository",
        "api": "https://trip.ecardo.ir/api/v1/travel/bootstrap",
        "owner": "services/travel",
        "status": "PARTIAL_MOCK",
        "before": "",
        "after": "",
        "findings": "Core services (Flight, Hotel, eSIM, Taxi) operational. Sub-services (Boat, Dining, Local) rely on mock catalog datasets."
    },
    "SRV-002": {
        "route": "BaseRoute.airtime",
        "screen": "lib/src/presentation/screens/bill_payment/view/airtime/airtime.dart",
        "ctrl": "BillPaymentController",
        "api": "/user/pay-bill/services, /user/pay-bill",
        "owner": "services/bills",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Mobile recharge with operator auto-detection, package selection, and instant wallet debit."
    },
    "SYS-001": {
        "route": "BaseRoute.noInternetConnection",
        "screen": "lib/src/presentation/widgets/no_internet_connection.dart",
        "ctrl": "ConnectivityService",
        "api": "N/A (Connectivity Plus)",
        "owner": "system/network",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Full-screen offline gate with retry button. Offline request queue tested in offline_request_queue_test.dart."
    },
    "SYS-002": {
        "route": "lib/src/helper/network_error_helper.dart",
        "screen": "lib/src/helper/network_error_helper.dart",
        "ctrl": "NetworkService",
        "api": "/user/payment-status/{tnx}",
        "owner": "system/network",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Wraps raw 5xx/database exceptions into localized user-friendly errors with tracking reference (AUD-004)."
    },
    "SYS-003": {
        "route": "BaseRoute.maintenanceMode",
        "screen": "lib/src/presentation/widgets/maintenance_mode.dart",
        "ctrl": "SettingsService",
        "api": "/get-settings (site_maintenance_mode)",
        "owner": "system/maintenance",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "System-wide maintenance screen triggered when site_maintenance_mode setting is active."
    },
    "SYS-004": {
        "route": "lib/src/helper/network_error_helper.dart",
        "screen": "lib/src/helper/network_error_helper.dart",
        "ctrl": "NetworkService",
        "api": "N/A",
        "owner": "system/errors",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Sanitizes error logs and dialogue text, preventing database schema or token leakage."
    },
    "SYS-005": {
        "route": "BaseRoute.wallets",
        "screen": "lib/src/presentation/screens/wallets/view/wallets_screen.dart",
        "ctrl": "WalletsController",
        "api": "/user/wallets",
        "owner": "system/ux",
        "status": "VERIFIED",
        "before": "test_output/screens/wallets__empty.png",
        "after": "test_output/screens/wallets__empty_rtl.png",
        "findings": "Clean empty illustration with action button to create wallet or explore services."
    },
    "SYS-006": {
        "route": "BaseRoute.navigation",
        "screen": "lib/src/presentation/screens/home/view/home_screen.dart",
        "ctrl": "HomeController",
        "api": "/user/dashboard",
        "owner": "system/ui",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Shimmer skeleton placeholders render during initial data fetching across dashboard and wallets."
    },
    "SYS-007": {
        "route": "BaseRoute.permissionsSettings",
        "screen": "lib/src/presentation/screens/settings/view/permissions_settings_screen.dart",
        "ctrl": "PermissionFlowService",
        "api": "N/A (OS Permissions API)",
        "owner": "system/permissions",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Provides direct button to open system app settings if permissions permanently denied."
    },
    "SYS-008": {
        "route": "BaseRoute.signIn",
        "screen": "lib/src/network/service/token_service.dart",
        "ctrl": "TokenService, SignInController",
        "api": "/auth/user/refresh, /auth/user/logout",
        "owner": "system/session",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Automatic JWT refresh interceptor with fail-safe redirect to signIn on 401 unauthenticated."
    },
    "SYS-009": {
        "route": "BaseRoute.navigation",
        "screen": "lib/src/app/navigation/navigation_screen.dart",
        "ctrl": "none",
        "api": "N/A",
        "owner": "accessibility",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "ScreenUtilInit baseline 390x844 responsive scaling. Text overflow protected with ellipsis and flexible containers."
    },
    "SYS-010": {
        "route": "BaseRoute.wallets",
        "screen": "lib/src/presentation/screens/wallets/view/wallets_screen.dart",
        "ctrl": "WalletsController",
        "api": "/user/wallets",
        "owner": "localization",
        "status": "VERIFIED",
        "before": "test_output/screens/wallets__rtl.png",
        "after": "test_output/screens/welcome__rtl.png",
        "findings": "Verified in wallet_card_rtl_test.dart and auth_screenshot_test.dart. Card numbers and currency codes preserve LTR in Persian/Arabic."
    },
    "SYS-011": {
        "route": "BaseRoute.navigation",
        "screen": "lib/src/app/navigation/navigation_screen.dart",
        "ctrl": "LocaleThemeService",
        "api": "N/A",
        "owner": "theming",
        "status": "VERIFIED",
        "before": "test_output/screens/home__dark.png",
        "after": "test_output/screens/transfer_review_step__dark.png",
        "findings": "Comprehensive dark theme palette (AppColors.darkSurface, darkBackground). Dark mode boot flash fixed."
    },
    "SYS-012": {
        "route": "BaseRoute.navigation",
        "screen": "lib/src/app/navigation/navigation_screen.dart",
        "ctrl": "none",
        "api": "N/A",
        "owner": "responsive",
        "status": "PARTIAL",
        "before": "",
        "after": "",
        "findings": "Optimized primarily for portrait mobile (390x844). Landscape orientation permitted in AndroidManifest but layouts not responsive-split."
    },
    "SYS-013": {
        "route": "BaseRoute.navigation",
        "screen": "lib/src/common/widgets/design_system/ecardo_balance_hero.dart",
        "ctrl": "none",
        "api": "N/A",
        "owner": "accessibility",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Entrance animations use gentle 600ms cubic curves; respects system animation scale."
    },
    "SYS-014": {
        "route": "BaseRoute.navigation",
        "screen": "lib/src/app/navigation/navigation_screen.dart",
        "ctrl": "none",
        "api": "N/A",
        "owner": "accessibility",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "Semantics labels added to key icons, FAB scanner tooltip, and cards (e.g. room_selection_screen Semantics widget)."
    },
    "SYS-015": {
        "route": "BaseRoute.signIn",
        "screen": "lib/src/presentation/screens/authentication/sign_in/view/sign_in_screen.dart",
        "ctrl": "SignInController",
        "api": "N/A",
        "owner": "accessibility",
        "status": "FUNCTIONAL",
        "before": "",
        "after": "",
        "findings": "TextInputAction.next and focus nodes wired across login, signup, and transfer input forms."
    },
    "SYS-016": {
        "route": "BaseRoute.noInternetConnection",
        "screen": "lib/src/presentation/widgets/no_internet_connection.dart",
        "ctrl": "ConnectivityService",
        "api": "N/A",
        "owner": "reliability",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Real-time stream listens to wifi/cellular changes; auto-dismisses offline screen on reconnection."
    },
    "SYS-017": {
        "route": "BaseRoute.signIn",
        "screen": "lib/src/presentation/screens/authentication/sign_in/controller/sign_in_controller.dart",
        "ctrl": "SignInController",
        "api": "/auth/user/login",
        "owner": "security",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Handles HTTP 429 Too Many Requests with countdown timer and lockout warning toast."
    },
    "SYS-018": {
        "route": "BaseRoute.transfer",
        "screen": "lib/src/presentation/screens/transfer/controller/transfer_controller.dart",
        "ctrl": "TransferController",
        "api": "/user/transfer/config",
        "owner": "fintech/transfers",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Strict fail-closed: transfer button disabled until server fee structure is returned from /user/transfer/config."
    },
    "SYS-019": {
        "route": "BaseRoute.virtualCard",
        "screen": "lib/src/presentation/screens/virtual_card/controller/virtual_card_controller.dart",
        "ctrl": "VirtualCardController",
        "api": "/get-card-providers",
        "owner": "fintech/cards",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Filters card provider availability by country code and displays explicit ineligibility banner."
    },
    "SYS-020": {
        "route": "BaseRoute.navigation",
        "screen": "lib/src/app/app.dart",
        "ctrl": "AppUpdateController",
        "api": "/setup-fcm, /get-settings (app_version)",
        "owner": "release",
        "status": "VERIFIED",
        "before": "",
        "after": "",
        "findings": "Impeller disabled on Android to avoid Vulkan resume black-screen bug. In-app APK self-update flow verified."
    }
}

fieldnames = [
    "audit_id",
    "page_or_flow_group",
    "priority",
    "feature_domain",
    "key_audit_focus",
    "required_test_types",
    "actual_route_fill_from_checkout",
    "screen_file",
    "controller_service",
    "api_endpoint",
    "owner",
    "status",
    "before_screenshot",
    "after_screenshot",
    "findings"
]

out_rows = []
for r in template_rows:
    aid = r["audit_id"]
    m = mapping.get(aid, {})
    out_row = {
        "audit_id": aid,
        "page_or_flow_group": r["page_or_flow_group"],
        "priority": r["priority"],
        "feature_domain": r["feature_domain"],
        "key_audit_focus": r["key_audit_focus"],
        "required_test_types": r["required_test_types"],
        "actual_route_fill_from_checkout": m.get("route", ""),
        "screen_file": m.get("screen", ""),
        "controller_service": m.get("ctrl", ""),
        "api_endpoint": m.get("api", ""),
        "owner": m.get("owner", ""),
        "status": m.get("status", "TODO"),
        "before_screenshot": m.get("before", ""),
        "after_screenshot": m.get("after", ""),
        "findings": m.get("findings", "")
    }
    out_rows.append(out_row)

out_path = "docs/uiux/audit_2026-10-20/03_PAGE_ROUTE_AUDIT_WORKBOOK_COMPLETED.csv"
with open(out_path, "w", encoding="utf-8-sig", newline="") as f:
    w = csv.DictWriter(f, fieldnames=fieldnames)
    w.writeheader()
    w.writerows(out_rows)

print(f"Successfully wrote {len(out_rows)} rows to {out_path}")
