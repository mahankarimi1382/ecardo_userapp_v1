import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';

class TransactionDynamicIcon {
  static String getTransactionIcon(String? type) {
    switch (type) {
      case "Credit":
        return PngAssets.creditCardTransaction;
      case "Debit":
        return PngAssets.debitCardTransaction;
      case "Deposit":
        return PngAssets.depositTransaction;
      case "Manual Deposit":
        return PngAssets.manualDepositTransaction;
      case "Withdraw":
        return PngAssets.withdrawTransaction;
      case "Withdraw Auto":
        return PngAssets.withdrawAutoTransaction;
      case "Send Money":
        return PngAssets.sendMoneyTransaction;
      case "Receive Money":
        return PngAssets.receiveMoneyTransaction;
      case "Request Money":
        return PngAssets.requestMoneyTransaction;
      case "Payment":
        return PngAssets.paymentTransaction;
      case "Invoice":
        return PngAssets.invoiceTransaction;
      case "Referral":
        return PngAssets.referralTransaction;
      case "Signup Bonus":
        return PngAssets.signupBonusTransaction;
      case "Gift Redeemed":
        return PngAssets.giftRedeemedTransaction;
      case "Gift Card":
        return PngAssets.giftCardTransaction;
      case "Cash In":
        return PngAssets.cashInTransaction;
      case "Cash In Commission":
        return PngAssets.cashInCommissionTransaction;
      case "Cash Out":
        return PngAssets.cashOutTransaction;
      case "Cashout Commission":
        return PngAssets.cashOutCommissionTransaction;
      case "Cash Received":
        return PngAssets.cashReceivedTransaction;
      case "Refund":
        return PngAssets.refundTransaction;
      case "Exchange":
        return PngAssets.exchangeTransaction;
      case "Pay Bill":
        return PngAssets.payBillTransaction;
      default:
        return PngAssets.creditCardTransaction;
    }
  }
}
