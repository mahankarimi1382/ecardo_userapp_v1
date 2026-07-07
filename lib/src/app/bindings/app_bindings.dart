import 'package:get/get.dart';
import 'package:qunzo_user/src/presentation/screens/bill_payment/controller/bill_payment_history_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/controller/gift_card_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/controller/gift_card_history_controller.dart';
import 'package:qunzo_user/src/presentation/screens/payment_links/controller/payment_links_controller.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/virtual_card_details_controller.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/virtual_card_transaction_controller.dart';

import '../../common/controller/country_controller.dart';
import '../../common/controller/register_fields_controller.dart';
import '../../presentation/screens/add_money/controller/add_money_controller.dart';
import '../../presentation/screens/add_money/controller/add_money_history_controller.dart';
import '../../presentation/screens/authentication/forgot_password/controller/forgot_password_controller.dart';
import '../../presentation/screens/authentication/forgot_password/controller/forgot_password_pin_verification_controller.dart';
import '../../presentation/screens/authentication/forgot_password/controller/reset_password_controller.dart';
import '../../presentation/screens/authentication/sign_in/controller/sign_in_controller.dart';
import '../../presentation/screens/authentication/sign_in/controller/two_factor_auth_controller.dart';
import '../../presentation/screens/authentication/sign_up/controller/auth_id_verification_controller.dart';
import '../../presentation/screens/authentication/sign_up/controller/email_controller.dart';
import '../../presentation/screens/authentication/sign_up/controller/personal_info_controller.dart';
import '../../presentation/screens/authentication/sign_up/controller/set_up_password_controller.dart';
import '../../presentation/screens/authentication/sign_up/controller/sign_up_status_controller.dart';
import '../../presentation/screens/authentication/sign_up/controller/verify_email_controller.dart';
import '../../presentation/screens/authentication/splash/controller/splash_controller.dart';
import '../../presentation/screens/beneficiary/controller/create_beneficiary_controller.dart';
import '../../presentation/screens/beneficiary/controller/update_beneficiary_controller.dart';
import '../../presentation/screens/bill_payment/controller/airtime_controller.dart';
import '../../presentation/screens/bill_payment/controller/cable_controller.dart';
import '../../presentation/screens/bill_payment/controller/data_bundle_controller.dart';
import '../../presentation/screens/bill_payment/controller/electricity_controller.dart';
import '../../presentation/screens/bill_payment/controller/internet_controller.dart';
import '../../presentation/screens/bill_payment/controller/toll_controller.dart';
import '../../presentation/screens/cash_out/controller/cash_out_controller.dart';
import '../../presentation/screens/cash_out/controller/cash_out_history_controller.dart';
import '../../presentation/screens/exchange/controller/exchange_controller.dart';
import '../../presentation/screens/exchange/controller/exchange_history_controller.dart';
import '../../presentation/screens/gift_code/controller/create_gift_controller.dart';
import '../../presentation/screens/gift_code/controller/gift_code_controller.dart';
import '../../presentation/screens/gift_code/controller/gift_history_controller.dart';
import '../../presentation/screens/gift_code/controller/gift_redeem_controller.dart';
import '../../presentation/screens/gift_code/controller/gift_redeem_history_controller.dart';
import '../../presentation/screens/home/controller/home_controller.dart';
import '../../presentation/screens/home/controller/wallet_details_controller.dart';
import '../../presentation/screens/make_payment/controller/make_payment_controller.dart';
import '../../presentation/screens/make_payment/controller/make_payment_history_controller.dart';
import '../../presentation/screens/p2p/controller/p2p_controller.dart';
import '../../presentation/screens/p2p/sub_category/payment_account/controller/payment_account_controller.dart';
import '../../presentation/screens/qr_code/controller/qr_code_controller.dart';
import '../../presentation/screens/referral/controller/referral_controller.dart';
import '../../presentation/screens/referral/controller/referral_tree_controller.dart';
import '../../presentation/screens/referral/controller/referred_friends_controller.dart';
import '../../presentation/screens/request_money/controller/received_request_controller.dart';
import '../../presentation/screens/request_money/controller/request_money_controller.dart';
import '../../presentation/screens/request_money/controller/request_money_history_controller.dart';
import '../../presentation/screens/settings/controller/add_new_ticket_controller.dart';
import '../../presentation/screens/settings/controller/change_password_controller.dart';
import '../../presentation/screens/settings/controller/id_verification_controller.dart';
import '../../presentation/screens/settings/controller/kyc_history_controller.dart';
import '../../presentation/screens/settings/controller/notification_controller.dart';
import '../../presentation/screens/settings/controller/profile_settings_controller.dart';
import '../../presentation/screens/settings/controller/reply_ticket_controller.dart';
import '../../presentation/screens/settings/controller/support_ticket_controller.dart';
import '../../presentation/screens/settings/controller/two_factor_authentication_controller.dart';
import '../../presentation/screens/transactions/controller/transactions_controller.dart';
import '../../presentation/screens/transfer/controller/transfer_controller.dart';
import '../../presentation/screens/transfer/controller/transfer_history_controller.dart';
import '../../presentation/screens/transfer/controller/transfer_received_history_controller.dart';
import '../../presentation/screens/virtual_card/controller/create_virtual_card_controller.dart';
import '../../presentation/screens/virtual_card/controller/virtual_card_controller.dart';
import '../../presentation/screens/wallets/controller/create_new_wallet_controller.dart';
import '../../presentation/screens/wallets/controller/wallets_controller.dart';
import '../../presentation/screens/withdraw/controller/create_withdraw_account_controller.dart';
import '../../presentation/screens/withdraw/controller/edit_withdraw_account_controller.dart';
import '../../presentation/screens/withdraw/controller/withdraw_account_controller.dart';
import '../../presentation/screens/withdraw/controller/withdraw_controller.dart';
import '../../presentation/screens/withdraw/controller/withdraw_history_controller.dart';

class SplashBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}

class SignInBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignInController>(() => SignInController());
  }
}

class TwoFactorAuthBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TwoFactorAuthController>(() => TwoFactorAuthController());
  }
}

class EmailBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmailController>(() => EmailController());
  }
}

class VerifyEmailBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VerifyEmailController>(() => VerifyEmailController());
  }
}

class ForgotPasswordBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
  }
}

class ForgotPasswordPinVerificationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordPinVerificationController>(
      () => ForgotPasswordPinVerificationController(),
    );
  }
}

class ResetPasswordBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResetPasswordController>(() => ResetPasswordController());
  }
}

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

class RegisterFieldsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterFieldsController>(() => RegisterFieldsController());
  }
}

class CountryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CountryController>(() => CountryController());
  }
}

class WalletsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletsController>(() => WalletsController());
  }
}

class CreateNewWalletBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateNewWalletController>(() => CreateNewWalletController());
  }
}

class TransactionsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionsController>(() => TransactionsController());
  }
}

class QrCodeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QrCodeController>(() => QrCodeController());
  }
}

class AddMoneyBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddMoneyController>(() => AddMoneyController());
  }
}

class MakePaymentBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MakePaymentController>(() => MakePaymentController());
  }
}

class RequestMoneyBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RequestMoneyController>(() => RequestMoneyController());
  }
}

class ReceivedRequestMoneyBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReceivedRequestController>(() => ReceivedRequestController());
  }
}

class CashOutBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CashOutController>(() => CashOutController());
  }
}

class WithdrawBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WithdrawController>(() => WithdrawController());
  }
}

class WithdrawAccountBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WithdrawAccountController>(() => WithdrawAccountController());
  }
}

class TransferBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransferController>(() => TransferController());
  }
}

class CreateWithdrawAccountBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateWithdrawAccountController>(
      () => CreateWithdrawAccountController(),
    );
  }
}

class EditWithdrawAccountBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditWithdrawAccountController>(
      () => EditWithdrawAccountController(),
    );
  }
}

class GiftCodeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GiftCodeController>(() => GiftCodeController());
  }
}

class GiftRedeemBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GiftRedeemController>(() => GiftRedeemController());
  }
}

class CreateGiftBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateGiftController>(() => CreateGiftController());
  }
}

class GiftHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GiftHistoryController>(() => GiftHistoryController());
  }
}

class ExchangeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExchangeController>(() => ExchangeController());
  }
}

class ProfileSettingsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileSettingsController>(() => ProfileSettingsController());
  }
}

class ChangePasswordBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChangePasswordController>(() => ChangePasswordController());
  }
}

class IDVerificationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IdVerificationController>(() => IdVerificationController());
  }
}

class KycHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KycHistoryController>(() => KycHistoryController());
  }
}

class ReferralBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReferralController>(() => ReferralController());
  }
}

class TwoFactorAuthenticationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TwoFactorAuthenticationController>(
      () => TwoFactorAuthenticationController(),
    );
  }
}

class NotificationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}

class SupportTicketBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportTicketController>(() => SupportTicketController());
  }
}

class AddNewTicketBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddNewTicketController>(() => AddNewTicketController());
  }
}

class ReplyTicketBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReplyTicketController>(() => ReplyTicketController());
  }
}

class ReferredFriendsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReferredFriendsController>(() => ReferredFriendsController());
  }
}

class ReferralTreeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReferralTreeController>(() => ReferralTreeController());
  }
}

class SetUpPasswordBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SetUpPasswordController>(() => SetUpPasswordController());
  }
}

class PersonalInfoBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PersonalInfoController>(() => PersonalInfoController());
  }
}

class AuthIdVerificationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthIdVerificationController>(
      () => AuthIdVerificationController(),
    );
  }
}

class SignUpStatusBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignUpStatusController>(() => SignUpStatusController());
  }
}

class WalletDetailsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletDetailsController>(() => WalletDetailsController());
  }
}

class AddMoneyHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddMoneyHistoryController>(() => AddMoneyHistoryController());
  }
}

class MakePaymentHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MakePaymentHistoryController>(
      () => MakePaymentHistoryController(),
    );
  }
}

class TransferHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransferHistoryController>(() => TransferHistoryController());
  }
}

class TransferReceivedHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransferReceivedHistoryController>(
      () => TransferReceivedHistoryController(),
    );
  }
}

class CashOutHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CashOutHistoryController>(() => CashOutHistoryController());
  }
}

class WithdrawHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WithdrawHistoryController>(() => WithdrawHistoryController());
  }
}

class ExchangeHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExchangeHistoryController>(() => ExchangeHistoryController());
  }
}

class RequestMoneyHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RequestMoneyHistoryController>(
      () => RequestMoneyHistoryController(),
    );
  }
}

class GiftRedeemHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GiftRedeemHistoryController>(
      () => GiftRedeemHistoryController(),
    );
  }
}

class CreateBeneficiaryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateBeneficiaryController>(
      () => CreateBeneficiaryController(),
    );
  }
}

class UpdateBeneficiaryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpdateBeneficiaryController>(
      () => UpdateBeneficiaryController(),
    );
  }
}

class AirtimeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AirtimeController>(() => AirtimeController());
  }
}

class ElectricityBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ElectricityController>(() => ElectricityController());
  }
}

class InternetBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InternetController>(() => InternetController());
  }
}

class DataBundleBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DataBundleController>(() => DataBundleController());
  }
}

class CableBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CableController>(() => CableController());
  }
}

class TollBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TollController>(() => TollController());
  }
}

class VirtualCardBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VirtualCardController>(() => VirtualCardController());
  }
}

class CreateNewCardBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateVirtualCardController>(
      () => CreateVirtualCardController(),
    );
  }
}

class VirtualCardDetailsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VirtualCardDetailsController>(
      () => VirtualCardDetailsController(),
    );
  }
}

class BillPaymentHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BillPaymentHistoryController>(
      () => BillPaymentHistoryController(),
    );
  }
}

class VirtualCardTransactionBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VirtualCardTransactionController>(
      () => VirtualCardTransactionController(),
    );
  }
}

class PaymentLinksBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentLinksController>(() => PaymentLinksController());
  }
}

class GiftCardBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GiftCardController>(() => GiftCardController());
  }
}

class GiftCardHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GiftCardHistoryController>(() => GiftCardHistoryController());
  }
}

class P2pBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<P2pController>(() => P2pController());
    Get.lazyPut<PaymentAccountController>(() => PaymentAccountController());
  }
}
