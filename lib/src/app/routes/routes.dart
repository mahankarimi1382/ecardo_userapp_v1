class BaseRoute {
  static const String root = "/";

  static const String splash = "/splash_route";

  /// Lightweight waypoint used by LocaleThemeService.setLanguage() to clear
  /// the navigation stack BEFORE applying a locale (prevents the release
  /// full-tree-rebuild crash) without replaying the SplashScreen.
  static const String localeTransition = "/locale_transition_route";

  static const noInternetConnection = '/no_internet_connection';

  static const String welcome = "/welcome_route";

  static const String signIn = "/sign_in_route";

  // WAVE-1: passwordless sign-in with a 6-digit email code.
  static const String emailOtpLogin = "/email_otp_login_route";

  static const String twoFactorAuth = "/two_factor_auth_route";

  static const String email = "/email_route";

  static const String walletsDetails = "/wallet_details_route";

  static const String verifyEmail = "/verify_email_route";

  static const String forgotPassword = "/forgot_password_route";

  static const String forgotPasswordPinVerification =
      "/forgot_password_pin_verification_route";

  static const String resetPassword = "/reset_password_route";

  static const String navigation = "/navigation_route";

  static const String setUpPassword = "/set_up_password_route";

  // v1.0.88 — removed dead constant setPasscode:
  // never used via GetPage or Get.toNamed; screen is opened with
  // Get.off(() => const SetPasscodeScreen()) directly.

  static const String personalInfo = "/personal_info_route";

  static const String authIdVerification = "/auth_id_verification_route";

  static const String wallets = "/wallets_route";

  static const String createNewWallet = "/create_new_wallet_route";

  static const String qrCode = "/qr_code_route";

  static const String signUpStatus = "/sign_up_status_route";

  static const String addMoney = "/add_money_route";

  static const String makePayment = "/make_payment_route";

  static const String requestMoney = "/request_money_route";

  static const String giftCode = "/gift_code_route";

  static const String transfer = "/transfer_route";

  static const String cashOut = "/cash_out_route";

  static const String withdraw = "/withdraw_route";

  static const String exchange = "/exchange_route";

  static const String transactions = "/transactions_route";

  // SERVICES HUB — dedicated page hosting the financial / travel / business
  // service grids + the recent-transactions card moved off the dashboard.
  static const String services = "/services_route";

  static const String referral = "/referral_route";

  static const String referredFriends = "/referred_friends_route";

  static const String referralTree = "/referral_tree_route";

  static const String profileSettings = "/profile_settings_route";
  static const String permissionsSettings = "/permissions_settings_route";
  static const String privacyPolicy = "/privacy_policy_route";
  static const String deviceSessionsSecurity = "/device_sessions_security_route";

  static const String changePassword = "/change_password_route";

  static const String twoFactorAuthentication =
      "/two_factor_authentication_route";

  static const String notifications = "/notifications_route";

  static const String supportTickets = "/support_tickets_route";

  static const String kycHistory = "/kyc_history_route";

  static const String addNewTicket = "/add_new_ticket_route";

  static const String replayTicket = "/replay_ticket_route";

  static const String giftHistory = "/gift_history_route";

  static const String idVerification = "/id_verification_route";

  static const String addMoneyHistory = "/add_money_history_route";

  static const String makePaymentHistory = "/make_payment_history_route";

  static const String transferHistory = "/transfer_history_route";

  static const String transferReceivedHistory =
      "/transfer_received_history_route";

  static const String cashOutHistory = "/cash_out_history_route";

  static const String withdrawHistory = "/withdraw_history_route";

  static const String exchangeHistory = "/exchange_history_route";

  static const String requestMoneyHistory = "/request_money_history_route";

  static const String giftRedeemHistory = "/gift_redeem_history_route";

  static const String createBeneficiary = "/create_beneficiary_route";

  static const String updateBeneficiary = "/update_beneficiary_route";

  static const String billPayment = "/bill_payment_route";

  static const String airtime = "/airtime_route";

  static const String electricity = "/electricity_route";

  static const String internet = "/internet_route";

  static const String dataBundle = "/data_bundle_route";

  static const String cable = "/cable_route";

  static const String toll = "/toll_route";

  static const String virtualCard = "/virtual_card_route";

  static const String createVirtualCard = "/create_virtual_card_route";

  static const String virtualCardDetails = "/virtual_card_details_route";

  static const String billPaymentHistory = "/bill_payment_history_route";

  static const String getCardInfo = "/get_card_info_route";

  static const String virtualCardTransaction =
      "/virtual_card_transaction_route";

  static const String paymentLinks = "/payment_links_route";

  static const String giftCard = "/gift_card_route";

  static const String maintenanceMode = "/maintenance_mode_route";

  static const String p2pTrading = "/p2p_trading_route";
  static const String travel = "/travel_route";
  static const String travelHistory = "/travel_history_route";
  static const String travelAccount = "/travel_account_route";
  static const String dynamicPassword = "/dynamic_password_route";

  static const String remittance = "/remittance_route";
  static const String remittanceHistory = "/remittance_history_route";
  static const String remittanceDetails = "/remittance_details_route";

  static const String kycSubmitWizard = "/kyc_submit_wizard_route";
  static const String upgradeRequired = "/upgrade_required_route";

  static const String appUpdate = "/app_update_route";

  // Tours (تورهای مسافرتی)
  static const String tourHome = "/tour_home_route";
  static const String tourDetail = "/tour_detail_route";
  static const String tourMatch = "/tour_match_route";
  static const String tourMyBookings = "/tour_my_bookings_route";
  static const String tourBook = "/tour_book_route";
  static const String tourPayment = "/tour_payment_route";
  static const String tourVoucher = "/tour_voucher_route";

  // Escrow (معامله امانی)
  static const String escrowHome = "/escrow_home_route";
  static const String escrowDetail = "/escrow_detail_route";
  static const String escrowCreate = "/escrow_create_route";
  static const String escrowPayment = "/escrow_payment_route";
  static const String escrowShipment = "/escrow_shipment_route";
  static const String escrowDispute = "/escrow_dispute_route";
  // Visa Service Routes
  static const String visaHome = "/visa_home_route";
  static const String visaDetail = "/visa_detail_route";
  static const String visaList = "/visa_list_route";

  // Stock Trading (بورس‌های بین‌المللی)
  static const String stockHome = "/stock_home_route";
  static const String loanHome = "/loan_home_route";
  static const String loanDetail = "/loan_detail_route";
  static const String rentalHome = "/rental_home_route";
  static const String rentalVoucher = "/rental_voucher_route";
  static const String guaranteeHome = "/guarantee_home_route";
  static const String rentalDetail = "/rental_detail_route";
  static const String guaranteeDetail = "/guarantee_detail_route";
  static const String remittanceTrack = "/remittance_track_route";
  // License Store Service
  static const String licenseStore = "/license_store_route";
  static const String licenseMyLicenses = "/license_my_licenses_route";

  // Specialized Financial Services Full Flow Routes
  static const String loanIntro = "/loan_intro_route";
  static const String loanApplication = "/loan_application_route";
  static const String loanConfirm = "/loan_confirm_route";
  static const String loanTracking = "/loan_tracking_route";

  static const String guaranteeIntro = "/guarantee_intro_route";
  static const String guaranteeApplication = "/guarantee_application_route";
  static const String guaranteeConfirm = "/guarantee_confirm_route";
  static const String guaranteeTracking = "/guarantee_tracking_route";

  static const String stockIntro = "/stock_intro_route";
  static const String stockOrder = "/stock_order_route";
  static const String stockConfirm = "/stock_confirm_route";
  static const String stockTracking = "/stock_tracking_route";

  static const String visaIntro = "/visa_intro_route";
  static const String licenseIntro = "/license_intro_route";
  static const String commercialProjects = "/commercial_projects_route";
  static const String commercialProjectDetail = "/commercial_project_detail_route";
  static const String commercialInvestCheckout = "/commercial_invest_checkout_route";
  static const String commercialMyInvestments = "/commercial_my_investments_route";

  // Marine & Boat Experience Routes
  static const String boatCatalog = "/boat_catalog_route";
  static const String boatVoucher = "/boat_voucher_route";

  // Local Experience & City Guide Routes
  static const String localCatalog = "/local_catalog_route";
  static const String localVoucher = "/local_voucher_route";

  // Travel Dining & In-Transit Food Routes
  static const String diningCatalog = "/dining_catalog_route";
  static const String diningOrderPass = "/dining_order_pass_route";
}
