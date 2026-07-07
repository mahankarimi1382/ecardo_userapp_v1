import 'package:get/get.dart';

import '../bindings/app_bindings.dart';
import 'routes.dart';
import 'routes_config.dart';

List<GetPage> routesHandler = [
  GetPage(
    name: BaseRoute.splash,
    page: () => RoutesConfig.splash,
    binding: SplashBinding(),
  ),

  GetPage(name: BaseRoute.welcome, page: () => RoutesConfig.welcome),

  GetPage(
    name: BaseRoute.signIn,
    page: () => RoutesConfig.signIn,
    binding: SignInBinding(),
  ),

  GetPage(
    name: BaseRoute.twoFactorAuth,
    page: () => RoutesConfig.twoFactorAuth,
    binding: TwoFactorAuthBinding(),
  ),

  GetPage(
    name: BaseRoute.email,
    page: () => RoutesConfig.email,
    binding: EmailBinding(),
  ),

  GetPage(
    name: BaseRoute.verifyEmail,
    page: () => RoutesConfig.verifyEmail,
    binding: VerifyEmailBinding(),
  ),

  GetPage(
    name: BaseRoute.forgotPassword,
    page: () => RoutesConfig.forgotPassword,
    binding: ForgotPasswordBinding(),
  ),

  GetPage(
    name: BaseRoute.resetPassword,
    page: () => RoutesConfig.resetPassword,
    binding: ResetPasswordBinding(),
  ),

  GetPage(
    name: BaseRoute.forgotPasswordPinVerification,
    page: () => RoutesConfig.forgotPasswordPinVerification,
    binding: ForgotPasswordPinVerificationBinding(),
  ),

  GetPage(
    name: BaseRoute.navigation,
    page: () => RoutesConfig.navigation,
    bindings: [
      HomeBinding(),
      TransferBinding(),
      GiftCodeBinding(),
      CreateGiftBinding(),
      GiftRedeemBinding(),
      GiftHistoryBinding(),
    ],
  ),

  GetPage(
    name: BaseRoute.wallets,
    page: () => RoutesConfig.wallets,
    binding: WalletsBinding(),
  ),

  GetPage(
    name: BaseRoute.createNewWallet,
    page: () => RoutesConfig.createNewWallet,
    binding: CreateNewWalletBinding(),
  ),

  GetPage(
    name: BaseRoute.qrCode,
    page: () => RoutesConfig.qrCode,
    binding: QrCodeBinding(),
  ),

  GetPage(
    name: BaseRoute.addMoney,
    page: () => RoutesConfig.addMoney,
    binding: AddMoneyBinding(),
  ),

  GetPage(
    name: BaseRoute.makePayment,
    page: () => RoutesConfig.makePayment,
    binding: MakePaymentBinding(),
  ),

  GetPage(
    name: BaseRoute.requestMoney,
    page: () => RoutesConfig.requestMoney,
    bindings: [RequestMoneyBinding(), ReceivedRequestMoneyBinding()],
  ),

  GetPage(
    name: BaseRoute.giftCode,
    page: () => RoutesConfig.giftCode,
    bindings: [
      GiftCodeBinding(),
      GiftRedeemBinding(),
      CreateGiftBinding(),
      GiftHistoryBinding(),
    ],
  ),

  GetPage(
    name: BaseRoute.transfer,
    page: () => RoutesConfig.transfer,
    binding: TransferBinding(),
  ),

  GetPage(
    name: BaseRoute.cashOut,
    page: () => RoutesConfig.cashOut,
    binding: CashOutBinding(),
  ),

  GetPage(
    name: BaseRoute.withdraw,
    page: () => RoutesConfig.withdraw,
    bindings: [
      WithdrawBinding(),
      WithdrawAccountBinding(),
      CreateWithdrawAccountBinding(),
      EditWithdrawAccountBinding(),
    ],
  ),

  GetPage(
    name: BaseRoute.exchange,
    page: () => RoutesConfig.exchange,
    binding: ExchangeBinding(),
  ),

  GetPage(
    name: BaseRoute.transactions,
    page: () => RoutesConfig.transactions,
    binding: TransactionsBinding(),
  ),

  GetPage(
    name: BaseRoute.referral,
    page: () => RoutesConfig.referral,
    binding: ReferralBinding(),
  ),

  GetPage(
    name: BaseRoute.referredFriends,
    page: () => RoutesConfig.referredFriends,
    binding: ReferredFriendsBinding(),
  ),

  GetPage(
    name: BaseRoute.referralTree,
    page: () => RoutesConfig.referralTree,
    binding: ReferralTreeBinding(),
  ),

  GetPage(
    name: BaseRoute.profileSettings,
    page: () => RoutesConfig.profileSettings,
    binding: ProfileSettingsBinding(),
  ),

  GetPage(
    name: BaseRoute.changePassword,
    page: () => RoutesConfig.changePassword,
    binding: ChangePasswordBinding(),
  ),

  GetPage(
    name: BaseRoute.twoFactorAuthentication,
    page: () => RoutesConfig.twoFactorAuthentication,
    binding: TwoFactorAuthenticationBinding(),
  ),

  GetPage(
    name: BaseRoute.notifications,
    page: () => RoutesConfig.notifications,
    binding: NotificationBinding(),
  ),

  GetPage(
    name: BaseRoute.supportTickets,
    page: () => RoutesConfig.supportTickets,
    binding: SupportTicketBinding(),
  ),

  GetPage(
    name: BaseRoute.kycHistory,
    page: () => RoutesConfig.kycHistory,
    binding: KycHistoryBinding(),
  ),

  GetPage(
    name: BaseRoute.addNewTicket,
    page: () => RoutesConfig.addNewTicket,
    binding: AddNewTicketBinding(),
  ),

  GetPage(
    name: BaseRoute.giftHistory,
    page: () => RoutesConfig.giftHistory,
    binding: GiftHistoryBinding(),
  ),

  GetPage(
    name: BaseRoute.idVerification,
    page: () => RoutesConfig.idVerification,
    binding: IDVerificationBinding(),
  ),

  GetPage(
    name: BaseRoute.signUpStatus,
    page: () => RoutesConfig.signUpStatus,
    binding: SignUpStatusBinding(),
  ),

  GetPage(
    name: BaseRoute.setUpPassword,
    page: () => RoutesConfig.setUpPassword,
    binding: SetUpPasswordBinding(),
  ),

  GetPage(
    name: BaseRoute.personalInfo,
    page: () => RoutesConfig.personalInfo,
    bindings: [
      PersonalInfoBinding(),
      RegisterFieldsBinding(),
      CountryBinding(),
    ],
  ),

  GetPage(
    name: BaseRoute.authIdVerification,
    page: () => RoutesConfig.authIdVerification,
    binding: AuthIdVerificationBinding(),
  ),

  GetPage(
    name: BaseRoute.walletsDetails,
    page: () => RoutesConfig.walletDetails,
    binding: WalletDetailsBinding(),
  ),

  GetPage(
    name: BaseRoute.addMoneyHistory,
    page: () => RoutesConfig.addMoneyHistory,
    binding: AddMoneyHistoryBinding(),
  ),

  GetPage(
    name: BaseRoute.makePaymentHistory,
    page: () => RoutesConfig.makePaymentHistory,
    binding: MakePaymentHistoryBinding(),
  ),

  GetPage(
    name: BaseRoute.transferHistory,
    page: () => RoutesConfig.transferHistory,
    binding: TransferHistoryBinding(),
  ),

  GetPage(
    name: BaseRoute.transferReceivedHistory,
    page: () => RoutesConfig.transferReceivedHistory,
    binding: TransferReceivedHistoryBinding(),
  ),

  GetPage(
    name: BaseRoute.cashOutHistory,
    page: () => RoutesConfig.cashOutHistory,
    binding: CashOutHistoryBinding(),
  ),

  GetPage(
    name: BaseRoute.withdrawHistory,
    page: () => RoutesConfig.withdrawHistory,
    binding: WithdrawHistoryBinding(),
  ),

  GetPage(
    name: BaseRoute.exchangeHistory,
    page: () => RoutesConfig.exchangeHistory,
    binding: ExchangeHistoryBinding(),
  ),

  GetPage(
    name: BaseRoute.requestMoneyHistory,
    page: () => RoutesConfig.requestMoneyHistory,
    binding: RequestMoneyHistoryBinding(),
  ),

  GetPage(
    name: BaseRoute.giftRedeemHistory,
    page: () => RoutesConfig.giftRedeemHistory,
    binding: GiftRedeemHistoryBinding(),
  ),

  GetPage(
    name: BaseRoute.createBeneficiary,
    page: () => RoutesConfig.createBeneficiary,
    binding: CreateBeneficiaryBinding(),
  ),

  GetPage(
    name: BaseRoute.updateBeneficiary,
    page: () => RoutesConfig.updateBeneficiary,
    binding: UpdateBeneficiaryBinding(),
  ),

  GetPage(
    name: BaseRoute.noInternetConnection,
    page: () => RoutesConfig.noInternetConnection,
  ),

  GetPage(name: BaseRoute.billPayment, page: () => RoutesConfig.billPayment),

  GetPage(
    name: BaseRoute.airtime,
    page: () => RoutesConfig.airtime,
    binding: AirtimeBinding(),
  ),

  GetPage(
    name: BaseRoute.electricity,
    page: () => RoutesConfig.electricity,
    binding: ElectricityBinding(),
  ),

  GetPage(
    name: BaseRoute.internet,
    page: () => RoutesConfig.internet,
    binding: InternetBinding(),
  ),

  GetPage(
    name: BaseRoute.dataBundle,
    page: () => RoutesConfig.dataBundle,
    binding: DataBundleBinding(),
  ),

  GetPage(
    name: BaseRoute.cable,
    page: () => RoutesConfig.cable,
    binding: CableBinding(),
  ),

  GetPage(
    name: BaseRoute.toll,
    page: () => RoutesConfig.toll,
    binding: TollBinding(),
  ),

  GetPage(
    name: BaseRoute.virtualCard,
    page: () => RoutesConfig.virtualCard,
    binding: VirtualCardBinding(),
  ),

  GetPage(
    name: BaseRoute.createVirtualCard,
    page: () => RoutesConfig.createVirtualCard,
    binding: CreateNewCardBinding(),
  ),

  GetPage(
    name: BaseRoute.virtualCardDetails,
    page: () => RoutesConfig.virtualCardDetails,
    binding: VirtualCardDetailsBinding(),
  ),

  GetPage(
    name: BaseRoute.billPaymentHistory,
    page: () => RoutesConfig.billPaymentHistory,
    binding: BillPaymentHistoryBinding(),
  ),
  GetPage(name: BaseRoute.getCardInfo, page: () => RoutesConfig.getCardInfo),

  GetPage(
    name: BaseRoute.virtualCardTransaction,
    page: () => RoutesConfig.virtualCardTransaction,
    binding: VirtualCardTransactionBinding(),
  ),

  GetPage(
    name: BaseRoute.paymentLinks,
    page: () => RoutesConfig.paymentLinks,
    binding: PaymentLinksBinding(),
  ),

  GetPage(
    name: BaseRoute.giftCard,
    page: () => RoutesConfig.giftCard,
    bindings: [GiftCardBinding(), GiftCardHistoryBinding()],
  ),

  GetPage(
    name: BaseRoute.maintenanceMode,
    page: () => RoutesConfig.maintenanceMode,
  ),

  GetPage(
    name: BaseRoute.p2pTrading,
    page: () => RoutesConfig.p2pTrading,
    binding: P2pBinding(),
  ),
];
