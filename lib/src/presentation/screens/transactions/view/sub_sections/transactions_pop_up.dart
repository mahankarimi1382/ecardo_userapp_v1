import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/presentation/screens/transactions/model/transactions_model.dart';

class TransactionsPopUp extends StatelessWidget {
  final Transactions transaction;

  const TransactionsPopUp({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 340,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(end: 8),
                      child: Text(
                        transaction.description ?? "",
                        style: TextStyle(
                          letterSpacing: 0,
                          fontSize: 18,
                          color: AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Image.asset(
                      PngAssets.closeCommonIcon,
                      width: 25,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              _buildDynamicSection(
                context,
                title: localization.transactionsPopupDate,
                content: transaction.createdAt ?? "",
                contentColor: AppColors.lightTextPrimary,
              ),
              SizedBox(height: 16),
              Divider(
                height: 0,
                color: AppColors.black.withValues(alpha: 0.10),
              ),
              SizedBox(height: 16),
              _buildDynamicSection(
                context,
                title: localization.transactionsPopupTransactionId,
                content: transaction.tnx ?? "",
                contentColor: AppColors.lightTextPrimary,
              ),
              SizedBox(height: 16),
              Divider(
                height: 0,
                color: AppColors.black.withValues(alpha: 0.10),
              ),
              SizedBox(height: 16),
              _buildDynamicSection(
                context,
                title: localization.transactionsPopupWalletName,
                content: transaction.walletType ?? "",
                contentColor: AppColors.lightTextPrimary,
              ),
              SizedBox(height: 16),
              Divider(
                height: 0,
                color: AppColors.black.withValues(alpha: 0.10),
              ),
              SizedBox(height: 16),
              _buildDynamicSection(
                context,
                title: localization.transactionsPopupAmount,
                content:
                    "${transaction.isPlus == true ? "+" : "-"}${transaction.amount}",
                contentColor: transaction.isPlus == true
                    ? AppColors.success
                    : AppColors.error,
              ),
              SizedBox(height: 16),
              Divider(
                height: 0,
                color: AppColors.black.withValues(alpha: 0.10),
              ),
              SizedBox(height: 16),
              _buildDynamicSection(
                context,
                title: localization.transactionsPopupCharge,
                content: "-${transaction.charge}",
                contentColor: AppColors.error,
              ),
              SizedBox(height: 16),
              Divider(
                height: 0,
                color: AppColors.black.withValues(alpha: 0.10),
              ),
              SizedBox(height: 16),
              _buildDynamicSection(
                context,
                title: localization.transactionsPopupFinalAmount,
                content:
                    "${transaction.isPlus == true ? "+" : "-"}${transaction.finalAmount}",
                contentColor: transaction.isPlus == true
                    ? AppColors.success
                    : AppColors.error,
              ),
              SizedBox(height: 16),
              Divider(
                height: 0,
                color: AppColors.black.withValues(alpha: 0.10),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localization.transactionsPopupStatus,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightTextPrimary,
                      fontSize: 12,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: transaction.status == "Success"
                            ? AppColors.success.withValues(alpha: 0.2)
                            : transaction.status == "Pending"
                            ? AppColors.warning.withValues(alpha: 0.2)
                            : AppColors.error.withValues(alpha: 0.2),
                      ),
                      color: transaction.status == "Success"
                          ? AppColors.success.withValues(alpha: 0.05)
                          : transaction.status == "Pending"
                          ? AppColors.warning.withValues(alpha: 0.05)
                          : AppColors.error.withValues(alpha: 0.05),
                    ),
                    child: Text(
                      textAlign: TextAlign.center,
                      transaction.status ?? "",
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: transaction.status == "Success"
                            ? AppColors.success
                            : transaction.status == "Pending"
                            ? AppColors.warning
                            : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicSection(
    BuildContext context, {
    required String title,
    required String content,
    Color? contentColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w500,
            color: AppColors.lightTextPrimary,
            fontSize: 2,
          ),
        ),
        Text(
          content,
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w500,
            color: contentColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
