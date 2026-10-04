import 'package:ecardo_user/src/commercial/bindings/commercial_binding.dart';
import 'package:ecardo_user/src/commercial/screens/commercial_projects_screen.dart';
import 'package:ecardo_user/src/commercial/screens/equity_project_detail_screen.dart';
import 'package:ecardo_user/src/commercial/screens/equity_invest_checkout_screen.dart';
import 'package:ecardo_user/src/commercial/screens/my_investments_screen.dart';
import 'package:ecardo_user/src/commercial/widgets/equity_project_card.dart';
import 'package:ecardo_user/src/escrow/bindings/escrow_binding.dart';
import 'package:ecardo_user/src/escrow/models/escrow_models.dart';
import 'package:ecardo_user/src/escrow/screens/escrow_create_screen.dart';
import 'package:ecardo_user/src/escrow/screens/escrow_detail_screen.dart';
import 'package:ecardo_user/src/escrow/screens/escrow_dispute_screen.dart';
import 'package:ecardo_user/src/escrow/screens/escrow_payment_screen.dart';
import 'package:ecardo_user/src/escrow/screens/escrow_shipment_screen.dart';
import 'package:ecardo_user/src/loan/screens/loan_detail_screen.dart';
import 'package:ecardo_user/src/rental/bindings/rental_binding.dart';
import 'package:ecardo_user/src/rental/models/rental_models.dart';
import 'package:ecardo_user/src/rental/screens/rental_detail_screen.dart';
import 'package:ecardo_user/src/rental/screens/rental_voucher_screen.dart';
import 'package:ecardo_user/src/guarantee/screens/guarantee_detail_screen.dart';
import 'package:ecardo_user/src/tour/bindings/tour_binding.dart';
import 'package:ecardo_user/src/tour/models/tour_model.dart';
import 'package:ecardo_user/src/tour/screens/tour_book_screen.dart';
import 'package:ecardo_user/src/tour/screens/tour_detail_screen.dart';
import 'package:ecardo_user/src/tour/screens/tour_payment_screen.dart';
import 'package:ecardo_user/src/tour/screens/tour_voucher_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/boat/bindings/boat_binding.dart';
import 'package:ecardo_user/src/presentation/screens/travel/boat/models/boat_models.dart';
import 'package:ecardo_user/src/presentation/screens/travel/boat/screens/boat_catalog_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/boat/screens/boat_voucher_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/local/bindings/local_experience_binding.dart';
import 'package:ecardo_user/src/presentation/screens/travel/local/models/local_experience_models.dart';
import 'package:ecardo_user/src/presentation/screens/travel/local/screens/local_catalog_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/local/screens/local_voucher_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/dining/bindings/dining_binding.dart';
import 'package:ecardo_user/src/presentation/screens/travel/dining/models/dining_models.dart';
import 'package:ecardo_user/src/presentation/screens/travel/dining/screens/dining_catalog_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/dining/screens/dining_order_pass_screen.dart';
import 'package:get/get.dart';

import '../bindings/app_bindings.dart';
import 'routes.dart';
import '../../presentation/screens/kyc_level/kyc_level_binding.dart';
import '../../presentation/screens/remittance/binding/remittance_binding.dart';
import '../../presentation/screens/kyc_level/view/kyc_submit_wizard.dart';
import '../../presentation/screens/settings/view/support_tickets/replay_ticket/replay_ticket.dart';
import '../../visa/screens/visa_detail_screen.dart';
import 'routes_config.dart';

List<GetPage> routesHandler = [
  GetPage(
    name: BaseRoute.root,
    page: () => RoutesConfig.splash,
    binding: SplashBinding(),
  ),

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

  // WAVE-1: passwordless sign-in with a 6-digit email code.
  GetPage(
    name: BaseRoute.emailOtpLogin,
    page: () => RoutesConfig.emailOtpLogin,
    binding: EmailOtpLoginBinding(),
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
      VirtualCardBinding(),
      GiftCodeBinding(),
      CreateGiftBinding(),
      GiftRedeemBinding(),
      GiftHistoryBinding(),
      KycLevelBinding(),
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
    name: BaseRoute.permissionsSettings,
    page: () => RoutesConfig.permissionsSettings,
  ),
  GetPage(
    name: BaseRoute.privacyPolicy,
    page: () => RoutesConfig.privacyPolicy,
  ),
  GetPage(
    name: BaseRoute.deviceSessionsSecurity,
    page: () => RoutesConfig.deviceSessionsSecurity,
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

  // M-6 (v1.0.27) — BaseRoute.replayTicket was a dead constant: the
  // ReplayTicket screen (settings/support_tickets/replay_ticket) exists and
  // is opened directly via `Get.to(() => ReplayTicket(ticketUid: ...))` from
  // support_tickets.dart, but the named route had no GetPage, so any
  // Get.toNamed(BaseRoute.replayTicket) silently fell through to
  // unknownRoute (splash). Registered here to complete the unfinished
  // section ("تکمیل بخش ناتمام").
  //
  // The ticket UID is supplied via route arguments, mirroring the widget's
  // required `ticketUid` constructor parameter; navigation without
  // arguments degrades gracefully (empty uid → server-side not-found toast)
  // instead of crashing. No binding is needed: ReplyTicketController is
  // registered by the screen itself (Get.put in its State). The page widget
  // is built inline instead of via RoutesConfig because routes_config.dart
  // is outside this fix's file scope.
  GetPage(
    name: BaseRoute.replayTicket,
    page: () => ReplayTicket(
      ticketUid: Get.arguments is String ? Get.arguments as String : '',
    ),
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
  GetPage(
    name: BaseRoute.travel,
    page: () => RoutesConfig.travel,
    binding: TravelBinding(),
  ),
  GetPage(
    name: BaseRoute.travelHistory,
    page: () => RoutesConfig.travelHistory,
    binding: TravelBinding(),
  ),
  GetPage(
    name: BaseRoute.travelAccount,
    page: () => RoutesConfig.travelAccount,
    binding: TravelBinding(),
  ),
  GetPage(
    name: BaseRoute.dynamicPassword,
    page: () => RoutesConfig.dynamicPassword,
    binding: DynamicPasswordBinding(),
  ),

  // Remittance Routes (v1.0.4+5)
  GetPage(
    name: BaseRoute.remittance,
    page: () => RoutesConfig.remittance,
    binding: RemittanceBinding(),
  ),
  GetPage(
    name: BaseRoute.remittanceHistory,
    page: () => RoutesConfig.remittanceHistory,
    binding: RemittanceBinding(),
  ),
  GetPage(
    name: BaseRoute.remittanceDetails,
    page: () => RoutesConfig.remittanceDetails,
    binding: RemittanceBinding(),
  ),

  // KYC Level Routes (v1.0.5)
  GetPage(
    name: BaseRoute.kycSubmitWizard,
    // phase2-fix: read target_level from route arguments — the wizard used
    // to show level-2 documents for EVERY upgrade level.
    page: () {
      final args = Get.arguments;
      final parsed = args is Map
          ? int.tryParse('${args['target_level'] ?? ''}')
          : null;
      return KycSubmitWizard(targetLevel: parsed ?? 2);
    },
    binding: KycLevelBinding(),
  ),
  GetPage(
    name: BaseRoute.upgradeRequired,
    page: () => RoutesConfig.upgradeRequired,
  ),

  // App self-update (v1.0.8+8)
  GetPage(
    name: BaseRoute.appUpdate,
    page: () => RoutesConfig.appUpdate,
  ),

  // Tours Routes
  GetPage(
    name: BaseRoute.tourHome,
    page: () => RoutesConfig.tourHome,
    binding: TourBinding(),
  ),
  GetPage(
    name: BaseRoute.tourMatch,
    page: () => RoutesConfig.tourMatch,
    binding: TourBinding(),
  ),
  GetPage(
    name: BaseRoute.tourMyBookings,
    page: () => RoutesConfig.tourMyBookings,
    binding: TourBinding(),
  ),
  GetPage(
    name: BaseRoute.tourDetail,
    page: () {
      final args = Get.arguments;
      final tourId = args is Map
          ? int.tryParse('${args['tourId'] ?? args['id'] ?? ''}')
          : (args is int ? args : null);
      return TourDetailScreen(tourId: tourId ?? 1);
    },
    binding: TourBinding(),
  ),
  GetPage(
    name: BaseRoute.tourBook,
    page: () {
      final tour = Get.arguments as TourModel;
      return TourBookScreen(tour: tour);
    },
    binding: TourBinding(),
  ),
  GetPage(
    name: BaseRoute.tourPayment,
    page: () {
      final args = Get.arguments;
      final bookingId = args is Map
          ? int.tryParse('${args['bookingId'] ?? args['id'] ?? ''}')
          : (args is int ? args : null);
      return TourPaymentScreen(bookingId: bookingId ?? 1);
    },
    binding: TourBinding(),
  ),
  GetPage(
    name: BaseRoute.tourVoucher,
    page: () {
      final args = Get.arguments;
      if (args is TourBookingModel) {
        return TourVoucherScreen(booking: args);
      }
      final bookingId = args is Map
          ? int.tryParse('${args['bookingId'] ?? args['id'] ?? ''}')
          : (args is int ? args : null);
      return TourVoucherScreen(
        booking: TourBookingModel(
          id: bookingId ?? 1,
          bookingNo: 'TR-${bookingId ?? 1}',
          tourTitle: 'تور گردشگری',
          tourCity: 'تهران',
          travelersCount: 1,
          basePrice: 0.0,
          totalPrice: 0.0,
          currency: 'USD',
          status: 'confirmed',
          statusLabel: 'تأییدشده',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
    },
    binding: TourBinding(),
  ),

  // Escrow Routes
  GetPage(
    name: BaseRoute.escrowHome,
    page: () => RoutesConfig.escrowHome,
    binding: EscrowBinding(),
  ),
  GetPage(
    name: BaseRoute.escrowDetail,
    page: () {
      final args = Get.arguments;
      final orderId = args is Map
          ? int.tryParse('${args['orderId'] ?? args['id'] ?? ''}')
          : (args is int ? args : null);
      return EscrowDetailScreen(orderId: orderId ?? 1);
    },
    binding: EscrowBinding(),
  ),
  GetPage(
    name: BaseRoute.escrowCreate,
    page: () => const EscrowCreateScreen(),
    binding: EscrowBinding(),
  ),
  GetPage(
    name: BaseRoute.escrowPayment,
    page: () {
      final order = Get.arguments as EscrowOrderModel;
      return EscrowPaymentScreen(order: order);
    },
    binding: EscrowBinding(),
  ),
  GetPage(
    name: BaseRoute.escrowShipment,
    page: () {
      final args = Get.arguments;
      final orderId = args is Map
          ? int.tryParse('${args['orderId'] ?? args['id'] ?? ''}')
          : (args is int ? args : null);
      return EscrowShipmentScreen(orderId: orderId ?? 1);
    },
    binding: EscrowBinding(),
  ),
  GetPage(
    name: BaseRoute.escrowDispute,
    page: () {
      final args = Get.arguments;
      final orderId = args is Map
          ? int.tryParse('${args['orderId'] ?? args['id'] ?? ''}')
          : (args is int ? args : null);
      return EscrowDisputeScreen(orderId: orderId ?? 1);
    },
    binding: EscrowBinding(),
  ),
  // Visa Routes
  GetPage(
    name: BaseRoute.visaHome,
    page: () => RoutesConfig.visaHome,
    binding: VisaBinding(),
  ),
  GetPage(
    name: BaseRoute.visaDetail,
    page: () {
      final args = Get.arguments;
      final caseNo = args is Map
          ? (args['caseNo']?.toString() ?? '')
          : (args is String ? args : '');
      return VisaDetailScreen(caseNo: caseNo);
    },
    binding: VisaBinding(),
  ),
  GetPage(
    name: BaseRoute.visaList,
    page: () => RoutesConfig.visaList,
    binding: VisaBinding(),
  ),
  GetPage(
    name: BaseRoute.visaIntro,
    page: () => RoutesConfig.visaIntro,
    binding: VisaBinding(),
  ),

  // Stock Trading Routes
  GetPage(
    name: BaseRoute.stockHome,
    page: () => RoutesConfig.stockHome,
    binding: StockBinding(),
  ),
  GetPage(
    name: BaseRoute.stockIntro,
    page: () => RoutesConfig.stockIntro,
    binding: StockBinding(),
  ),
  GetPage(
    name: BaseRoute.stockOrder,
    page: () => RoutesConfig.stockOrder,
    binding: StockBinding(),
  ),
  GetPage(
    name: BaseRoute.stockConfirm,
    page: () => RoutesConfig.stockConfirm,
    binding: StockBinding(),
  ),
  GetPage(
    name: BaseRoute.stockTracking,
    page: () => RoutesConfig.stockTracking,
    binding: StockBinding(),
  ),

  // Loan & Credit Routes
  GetPage(
    name: BaseRoute.loanHome,
    page: () => RoutesConfig.loanHome,
    binding: LoanBinding(),
  ),
  GetPage(
    name: BaseRoute.loanDetail,
    page: () {
      final args = Get.arguments;
      final caseId = args is Map
          ? int.tryParse('${args['caseId'] ?? args['id'] ?? ''}')
          : (args is int ? args : null);
      return LoanDetailScreen(caseId: caseId ?? 0);
    },
    binding: LoanBinding(),
  ),
  GetPage(
    name: BaseRoute.loanIntro,
    page: () => RoutesConfig.loanIntro,
    binding: LoanBinding(),
  ),
  GetPage(
    name: BaseRoute.loanApplication,
    page: () => RoutesConfig.loanApplication,
    binding: LoanBinding(),
  ),
  GetPage(
    name: BaseRoute.loanConfirm,
    page: () => RoutesConfig.loanConfirm,
    binding: LoanBinding(),
  ),
  GetPage(
    name: BaseRoute.loanTracking,
    page: () => RoutesConfig.loanTracking,
    binding: LoanBinding(),
  ),

  // Car Rental Routes
  GetPage(
    name: BaseRoute.rentalHome,
    page: () => RoutesConfig.rentalHome,
    binding: RentalBinding(),
  ),

  // Bank Guarantee Routes
  GetPage(
    name: BaseRoute.guaranteeHome,
    page: () => RoutesConfig.guaranteeHome,
    binding: GuaranteeBinding(),
  ),
  GetPage(
    name: BaseRoute.guaranteeDetail,
    page: () {
      final args = Get.arguments;
      final caseId = args is Map
          ? int.tryParse('${args['caseId'] ?? args['id'] ?? ''}')
          : (args is int ? args : null);
      return GuaranteeDetailScreen(caseId: caseId ?? 0);
    },
    binding: GuaranteeBinding(),
  ),
  GetPage(
    name: BaseRoute.guaranteeIntro,
    page: () => RoutesConfig.guaranteeIntro,
    binding: GuaranteeBinding(),
  ),
  GetPage(
    name: BaseRoute.guaranteeApplication,
    page: () => RoutesConfig.guaranteeApplication,
    binding: GuaranteeBinding(),
  ),
  GetPage(
    name: BaseRoute.guaranteeConfirm,
    page: () => RoutesConfig.guaranteeConfirm,
    binding: GuaranteeBinding(),
  ),
  GetPage(
    name: BaseRoute.guaranteeTracking,
    page: () => RoutesConfig.guaranteeTracking,
    binding: GuaranteeBinding(),
  ),

  GetPage(
    name: BaseRoute.rentalDetail,
    page: () {
      final args = Get.arguments;
      final bookingId = args is Map
          ? int.tryParse('${args['bookingId'] ?? args['id'] ?? ''}')
          : (args is int ? args : null);
      return RentalDetailScreen(bookingId: bookingId ?? 0);
    },
    binding: RentalBinding(),
  ),
  GetPage(
    name: BaseRoute.rentalVoucher,
    page: () {
      final booking = Get.arguments as RentalBookingModel;
      return RentalVoucherScreen(booking: booking);
    },
    binding: RentalBinding(),
  ),

  // Remittance Track Routes
  GetPage(
    name: BaseRoute.remittanceTrack,
    page: () => RoutesConfig.remittanceTrack,
  ),

  // License Store Routes
  GetPage(
    name: BaseRoute.licenseStore,
    page: () => RoutesConfig.licenseStore,
    binding: LicenseBinding(),
  ),
  GetPage(
    name: BaseRoute.licenseMyLicenses,
    page: () => RoutesConfig.licenseMyLicenses,
    binding: LicenseBinding(),
  ),
  GetPage(
    name: BaseRoute.licenseIntro,
    page: () => RoutesConfig.licenseIntro,
    binding: LicenseBinding(),
  ),

  // Commercial & Equity Projects Full Flow Routes
  GetPage(
    name: BaseRoute.commercialProjects,
    page: () => const CommercialProjectsScreen(),
    binding: CommercialBinding(),
  ),
  GetPage(
    name: BaseRoute.commercialProjectDetail,
    page: () {
      final args = Get.arguments;
      final projectId = args is Map
          ? (args['projectId']?.toString() ?? 'eq-001')
          : (args?.toString() ?? 'eq-001');
      return EquityProjectDetailScreen(projectId: projectId);
    },
    binding: CommercialBinding(),
  ),
  GetPage(
    name: BaseRoute.commercialInvestCheckout,
    page: () {
      final project = Get.arguments as EquityProjectItem;
      return EquityInvestCheckoutScreen(project: project);
    },
    binding: CommercialBinding(),
  ),
  GetPage(
    name: BaseRoute.commercialMyInvestments,
    page: () => const MyInvestmentsScreen(),
    binding: CommercialBinding(),
  ),

  // Marine & Boat Experience Routes
  GetPage(
    name: BaseRoute.boatCatalog,
    page: () => const BoatCatalogScreen(),
    binding: BoatBinding(),
  ),
  GetPage(
    name: BaseRoute.boatVoucher,
    page: () {
      final booking = Get.arguments as BoatBookingModel;
      return BoatVoucherScreen(booking: booking);
    },
    binding: BoatBinding(),
  ),

  // Local Experience & City Guide Routes
  GetPage(
    name: BaseRoute.localCatalog,
    page: () => const LocalCatalogScreen(),
    binding: LocalExperienceBinding(),
  ),
  GetPage(
    name: BaseRoute.localVoucher,
    page: () {
      final booking = Get.arguments as LocalBookingModel;
      return LocalVoucherScreen(booking: booking);
    },
    binding: LocalExperienceBinding(),
  ),

  // Travel Dining & In-Transit Food Routes
  GetPage(
    name: BaseRoute.diningCatalog,
    page: () => const DiningCatalogScreen(),
    binding: DiningBinding(),
  ),
  GetPage(
    name: BaseRoute.diningOrderPass,
    page: () {
      final order = Get.arguments as DiningOrderModel;
      return DiningOrderPassScreen(order: order);
    },
    binding: DiningBinding(),
  ),
];
