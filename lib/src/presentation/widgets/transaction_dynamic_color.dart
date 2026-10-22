import 'package:flutter/material.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';

class TransactionDynamicColor {
  static Color getTransactionColor(String? type) {
    switch (type) {
      case "Credit":
        return AppColors.brandViolet;
      case "Debit":
        return AppColors.darkSurfaceVariant;
      case "Deposit":
        return AppColors.mainSoftBlue;
      case "Manual Deposit":
        return AppColors.brandVioletDeep;
      case "Withdraw":
        return AppColors.info;
      case "Withdraw Auto":
        return AppColors.mutedBlue;
      case "Send Money":
        return AppColors.brandViolet;
      case "Receive Money":
        return AppColors.success;
      case "Request Money":
        return AppColors.warning;
      case "Payment":
        return AppColors.success;
      case "Invoice":
        return AppColors.info;
      case "Referral":
        return AppColors.mutedBlue;
      case "Signup Bonus":
        return AppColors.info;
      case "Gift Redeemed":
        return AppColors.mainSoftBlue;
      case "Gift Card":
        return AppColors.darkSurfaceVariant;
      case "Cash In":
        return AppColors.success;
      case "Cash In Commission":
        return AppColors.mainSoftBlue;
      case "Cash Out":
        return AppColors.error;
      case "Cashout Commission":
        return AppColors.warning;
      case "Cash Received":
        return AppColors.mutedBlue;
      case "Refund":
        return AppColors.warning;
      case "Exchange":
        return AppColors.mutedBlue;
      case "Pay Bill":
        return AppColors.warning;
      default:
        return AppColors.brandViolet;
    }
  }
}
