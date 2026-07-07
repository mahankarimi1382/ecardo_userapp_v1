class ApiPath {
  // Base Endpoints
  static const String baseUrl = 'https://ecardo.ir/api';

  // Common Endpoints
  static const String countriesEndpoint = '/get-countries';
  static const String getSettingsEndpoint = '/get-settings';
  static const String languagesEndpoint = '/get-languages';
  static const String termsAndConditionsEndpoint = '/terms-conditions';
  static const String getSetupFcm = '/setup-fcm';
  static const String getTransactionsTypesAndStatusEndpoint =
      '/get-transaction-types-and-statuses';

  static String translationEndpoint({required String languageCode}) =>
      '/change-language/$languageCode';

  static String getConverterEndpoint({
    required String amount,
    required String currencyCode,
    bool? isThousandSeparatorRemove = true,
  }) => '/convert/$amount/$currencyCode/$isThousandSeparatorRemove';

  static String getCurrencyToCurrencyConverterEndpoint({
    required String amount,
    required String toCurrencyCode,
    bool? isThousandSeparatorRemove = true,
    required String? fromCurrencyCode,
  }) =>
      '/convert/$amount/$toCurrencyCode/$isThousandSeparatorRemove/$fromCurrencyCode';

  // Authentication Endpoints
  static const String loginEndpoint = '/auth/user/login';
  static const String twoFaEndpoint = '/auth/user/2fa/verify';
  static const String getRegisterFieldsEndpoint = '/get-register-fields/user';
  static const String registerEndpoint = '/auth/user/register';
  static const String verifyEmailEndpoint = '/auth/user/send-verify-email';
  static const String validateVerifyEmailEndpoint =
      '/auth/user/validate-verify-email';
  static const String forgotPasswordEndpoint = '/auth/user/forgot-password';
  static const String personalInfoEndpoint = '/auth/user/personal-info-update';
  static const String resetVerifyOtpEndpoint = '/auth/user/reset-verify-otp';
  static const String resetPasswordEndpoint = '/auth/user/reset-password';
  static const String logoutEndpoint = '/auth/user/logout';
  static const String kycRejectedEndpoint = '/user/kyc/rejected-data';

  // Dashboard Endpoints
  static const String dashboardEndpoint = '/user/dashboard';
  static const String userEndpoint = '/auth/user/get';

  // Wallets Endpoints
  static const String walletsEndpoint = '/user/wallets';
  static const String currenciesEndpoint = '/get-currencies';

  // Transactions Endpoints
  static const String transactionsEndpoint = '/user/transactions';

  // QR Code Endpoints
  static const String qrCodeEndpoint = '/user/qrcode';

  // Add Money Endpoints
  static const String getGatewayMethodsEndpoint = '/user/add-money';
  static const String postAddMoneyEndpoint = '/user/add-money';

  // Add Money Transactions History Endpoints
  static const String addMoneyHistoryEndpoint = '/user/transactions';

  // Make Payment Endpoints
  static const String paymentSettingsEndpoint = '/user/payment/settings';
  static const String makePaymentEndpoint = '/user/payment/make';
  static const String paymentHistoryEndpoint = '/user/payment/history';

  // Request Money Endpoints
  static const String requestMoneyEndpoint = '/user/request-money';
  static const String requestMoneyHistoryEndpoint =
      '/user/request-money/history';
  static const String receivedRequestEndpoint = '/user/request-money/history';

  // Cash Out Endpoints
  static const String cashOutConfigEndpoint = '/user/cashout/config';
  static const String userCashOutEndpoint = '/user/cashout';
  static const String userCashOutHistoryEndpoint = '/user/cashout/history';

  // Withdraw Endpoints
  static const String withdrawAccountEndpoint = '/user/withdraw-accounts';
  static const String withdrawEndpoint = '/user/withdraw';
  static const String withdrawHistoryEndpoint = '/user/transactions';
  static const String withdrawMethodsEndpoint =
      '/user/withdraw-accounts/methods/list';
  static const String withdrawAccountCreateEndpoint = '/user/withdraw-accounts';

  // Transfer Endpoints
  static const String transferConfigEndpoint = '/user/transfer/config';
  static const String userTransferEndpoint = '/user/transfer';
  static const String transferHistoryEndpoint = '/user/transfer/history';

  // Gift Code Endpoints
  static const String giftRedeemEndpoint = '/user/gifts/redeem';
  static const String giftConfigEndpoint = '/user/gifts/config';
  static const String createGiftEndpoint = '/user/gifts';
  static const String giftHistoryEndpoint = '/user/gifts/history';
  static const String giftRedeemHistoryEndpoint = '/user/gifts/redeem/history';

  // Exchange Endpoints
  static const String exchangeConfigEndpoint = '/user/exchange/config';
  static const String exchangeWalletEndpoint = '/user/exchange';
  static const String exchangeHistoryEndpoint = '/user/exchange/history';

  // Profile Settings Endpoints
  static const String updateProfileEndpoint = '/user/settings/profile';

  // Change Password Endpoints
  static const String changePasswordEndpoint = '/user/settings/change-password';

  // Id Verification Endpoints
  static const String userKycEndpoint = '/user/kyc';
  static const String kycHistoryEndpoint = '/user/kyc/history';

  // Referral Endpoints
  static const String referralInfoEndpoint = '/user/referral/info';
  static const String referralFriendsEndpoint = '/user/referral/direct';
  static const String referralTreeEndpoint = '/user/referral/tree';

  // Security Settings Endpoints
  static const String twoFaGenerateQRCodeEndpoint =
      '/user/settings/2fa/generate';
  static const String enableTwoFaEndpoint = '/user/settings/2fa/enable';
  static const String disableTwoFaEndpoint = '/user/settings/2fa/disable';
  static const String passcodeActiveEndpoint = '/user/passcode';
  static const String changePasscodeEndpoint = '/user/passcode/change';
  static const String disablePasscodeEndpoint = '/user/passcode/disable';
  static const String verifyPasscodeEndpoint = '/user/passcode/verify';

  // Notifications Endpoints
  static const String markAsReadNotificationEndpoint =
      '/mark-as-read-notification';
  static const String getNotificationsEndpoint = '/get-notifications';

  // Support Ticket Endpoints
  static const String supportTicketsEndpoint = '/user/ticket';

  // Beneficiary Endpoints
  static const String beneficiaryEndpoint = '/user/beneficiaries';

  // Bill Payments
  static const String getBillCountriesEndpoint = '/get-bill-countries';
  static const String getPayBillServicesEndpoint = '/user/pay-bill/services';
  static const String payBillEndpoint = '/user/pay-bill';
  static const String payBillHistoryEndpoint = '/user/pay-bill/history';

  // Virtual Cards
  static const String getVirtualCardsEndpoint = '/user/cards';
  static const String getVirtualCardBsiProviderDetailsEndpoint =
      '/user/bsicards/cards/details';
  static const String postUpdateStatusEndpoint = '/user/cards/update-status';
  static const String postCardBalanceTopUpEndpoint =
      '/user/cards/balance/topup';
  static const String getCardProvidersEndpoint = '/get-card-providers';
  static const String getCardHoldersEndpoint = '/user/cardholders';
  static const String getCardTransactionEndpoint = '/user/cards/transactions';

  // Payment Links Endpoints
  static const String paymentLinksEndpoint = '/user/payment-links/history';
  static const String createPaymentLinksEndpoint = '/user/payment-links/create';

  // Gift Card Endpoints
  static const String getGiftCardProductsEndpoint = '/user/gift-cards/products';
  static const String getGiftCardProductDetailsEndpoint =
      '/user/gift-cards/product-details';
  static const String postGiftCardOrderEndpoint =
      '/user/gift-cards/product/order';
  static const String getGiftCardCountriesEndpoint =
      '/user/gift-cards/countries';
  static const String getGiftCardCategoriesEndpoint =
      '/user/gift-cards/categories';
  static const String getGiftCardPurchasedHistoryEndpoint =
      '/user/gift-cards/purchased-history';

  // p2p Endpoints
  static const String p2pMarketPlaceEndpoint = '/user/p2p/marketplace';
  static const String paymentAccountEndpoint = '/user/p2p/payment-accounts';
  static const String paymentMethodEndpoint = '/user/p2p/payment-methods';
  static const String highestOrderPriceEndpoint =
      '/user/p2p/ads/highest-order-price';
  static const String createAdEndpoint = '/user/p2p/ads';
  static const String getAdsEndpoint = '/user/p2p/ads';

  static String updateAdStatusEndpoint({required String adId}) =>
      '/user/p2p/ads/$adId/status-update';

  static String getMyOrdersEndPoint = '/user/p2p/orders';
  static String adsEligibilityEndPoint = '/user/p2p/ads/eligibility';

  static String orderMessageEndpoint({required String orderId}) =>
      '/user/p2p/orders/$orderId/messages';

  static String adPaymentMethodEndpoint({required String adId}) =>
      '/user/p2p/ads/$adId/payment-methods';

  static String cancelAdEndpoint({required String id}) =>
      '/user/p2p/orders/$id/cancel';

  static String markPaidEndpoint({required String id}) =>
      '/user/p2p/orders/$id/mark-paid';

  static String disputeOrderEndpoint({required String id}) =>
      '/user/p2p/orders/$id/dispute';

  static String releaseOrderEndpoint({required String id}) =>
      '/user/p2p/orders/$id/release';
  static String verifiedStatusEndPoint =
      '/user/p2p/verified-trader-application/status';
  static String applyVerificationEndPoint =
      '/user/p2p/verified-trader-application/apply';
}
