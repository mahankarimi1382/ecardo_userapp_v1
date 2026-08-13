import 'dart:ui';

class TransactionDynamicColor {
  static Color getTransactionColor(String? type) {
    switch (type) {
      case "Credit":
        return Color(0xFF7D5CFF);
      case "Debit":
        return Color(0xFFA6B28B);
      case "Deposit":
        return Color(0xFF9280FD);
      case "Manual Deposit":
        return Color(0xFFCC66DA);
      case "Withdraw":
        return Color(0xFF00B2FF);
      case "Withdraw Auto":
        return Color(0xFF437D34);
      case "Send Money":
        return Color(0xFF615CFF);
      case "Receive Money":
        return Color(0xFF95BC25);
      case "Request Money":
        return Color(0xFFFFAA00);
      case "Payment":
        return Color(0xFF3AB83A);
      case "Invoice":
        return Color(0xFF78C841);
      case "Referral":
        return Color(0xFF087070);
      case "Signup Bonus":
        return Color(0xFF3AAADA);
      case "Gift Redeemed":
        return Color(0xFFA282FF);
      case "Gift Card":
        return Color(0xFF797979);
      case "Cash In":
        return Color(0xFF2C5671);
      case "Cash In Commission":
        return Color(0xFF799EFF);
      case "Cash Out":
        return Color(0xFFEC4963);
      case "Cashout Commission":
        return Color(0xFFFF9B2F);
      case "Cash Received":
        return Color(0xFF689B8A);
      case "Refund":
        return Color(0xFFB75931);
      case "Exchange":
        return Color(0xFF15916C);
      case "Pay Bill":
        return Color(0xFFBAFFEA);
      default:
        return Color(0xFF7D5CFF);
    }
  }
}
