import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';

class NotificationDynamicIcon {
  static String getNotificationIcon(String? type) {
    switch (type) {
      case "user_mail":
        return PngAssets.userMailNotification;
      case "user_manual_deposit_approved":
        return PngAssets.userManualDepositApprovedNotification;
      case "user_manual_deposit_rejected":
        return PngAssets.userManualDepositRejectedNotification;
      case "user_invoice_payment":
        return PngAssets.userInvoicePaymentNotification;
      case "user_request_money":
        return PngAssets.userRequestMoneyNotification;
      case "user_gift_redeemed":
        return PngAssets.userGiftRedeemedNotification;
      case "user_receive_money":
        return PngAssets.userReceiveMoneyNotification;
      case "user_referral_join":
        return PngAssets.userReferralJoinNotification;
      case "user_ticket_reply":
        return PngAssets.userTicketReplyNotification;
      case "user_cash_in":
        return PngAssets.userCashInNotification;
      case "kyc_action":
        return PngAssets.kycActionNotification;
      case "forgot_password":
        return PngAssets.forgotPasswordNotification;
      case "email_verification":
        return PngAssets.emailVerificationNotification;
      case "forgot_password_otp":
        return PngAssets.forgotPasswordNotification;
      case "app_email_verification":
        return PngAssets.appEmailVerificationNotification;
      case "withdraw_approved":
        return PngAssets.withdrawApprovedNotification;
      case "withdraw_rejected":
        return PngAssets.withdrawRejectedNotification;
      case "user_ticket_closed":
        return PngAssets.userTicketClosedNotification;
      case "user_request_money_accepted":
        return PngAssets.userRequestMoneyAcceptedNotification;
      default:
        return PngAssets.userMailNotification;
    }
  }
}
