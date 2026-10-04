import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/route_return.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/add_money/controller/add_money_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';

class AddMoneyPendingStepSection extends StatefulWidget {
  const AddMoneyPendingStepSection({super.key});

  @override
  State<AddMoneyPendingStepSection> createState() =>
      _AddMoneyPendingStepSectionState();
}

class _AddMoneyPendingStepSectionState
    extends State<AddMoneyPendingStepSection> {
  final AddMoneyController controller = Get.find();
  double totalAmount = 0.0;
  bool isCalculated = false;

  double parseToDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  void totalCalculate(Map<String, dynamic> transaction) {
    double amount = parseToDouble(transaction["amount"]);
    double charge = parseToDouble(transaction["charge"]);
    totalAmount = amount + charge;
    isCalculated = true;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final data = controller.pendingPaymentData.value;

      if (data == null || data["transaction"] == null) {
        return const CommonLoading();
      }

      final transaction = data["transaction"];
      final payCurrency = transaction["pay_currency"];

      if (!isCalculated) {
        totalCalculate(transaction);
      }

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              // Pending Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      PngAssets.commonPendingIcon,
                      width: 72,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      localization.addMoneyPendingTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Transaction Detail Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                      blurRadius: AppSpacing.md,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDynamicRow(
                      isDark: isDark,
                      title: localization.addMoneyPendingAmount,
                      content:
                          "${double.tryParse(controller.amountController.text)?.toStringAsFixed(controller.gatewayMethod.value!.currencyType! != "crypto" ? 2 : controller.gatewayMethod.value!.currencyDecimals!)} $payCurrency",
                      contentColor: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    _buildDivider(isDark),
                    _buildDynamicRow(
                      isDark: isDark,
                      title: localization.addMoneyPendingTransactionId,
                      content: transaction["tnx"] ?? "",
                      contentColor: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      isCopyable: true,
                    ),
                    _buildDivider(isDark),
                    _buildDynamicRow(
                      isDark: isDark,
                      title: localization.addMoneyPendingWalletName,
                      content: controller.wallet.value!.name!,
                      contentColor: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    _buildDivider(isDark),
                    _buildDynamicRow(
                      isDark: isDark,
                      title: localization.addMoneyPendingPaymentMethod,
                      content: "$payCurrency",
                      contentColor: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    _buildDivider(isDark),
                    _buildDynamicRow(
                      isDark: isDark,
                      title: localization.addMoneyPendingCharge,
                      content:
                          "${parseToDouble(transaction["charge"]).toStringAsFixed(controller.gatewayMethod.value!.currencyType! != "crypto" ? 2 : controller.gatewayMethod.value!.currencyDecimals!)} $payCurrency",
                      contentColor: AppColors.error,
                    ),
                    _buildDivider(isDark),
                    _buildDynamicRow(
                      isDark: isDark,
                      title: localization.addMoneyPendingType,
                      content: transaction["type"] ?? "",
                      contentColor: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    _buildDivider(isDark),
                    _buildDynamicRow(
                      isDark: isDark,
                      title: localization.addMoneyPendingFinalAmount,
                      content:
                          "${totalAmount.toStringAsFixed(controller.gatewayMethod.value!.currencyDecimals!)} $payCurrency",
                      contentColor: AppColors.success,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              CommonButton(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  controller.currentStep.value = 0;
                  controller.clearFields();
                  controller.isLoading.value = true;
                  await controller.fetchWallets();
                  controller.isLoading.value = false;
                },
                width: double.infinity,
                text: localization.addMoneyPendingDepositAgain,
              ),
              const SizedBox(height: AppSpacing.md),
              CommonButton(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  Get.delete<AddMoneyController>();
                  RouteReturn.complete();
                  await Get.find<HomeController>().loadData();
                },
                width: double.infinity,
                text: localization.addMoneyPendingBackHome,
                backgroundColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightPrimary.withValues(alpha: 0.06),
                borderColor: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightPrimary.withValues(alpha: 0.60),
                borderWidth: 1.5,
                textColor: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              const SizedBox(height: AppSpacing.huge),
            ],
          ),
        ),
      );
    });
  }

  static Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Divider(
        height: 1,
        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
      ),
    );
  }

  static Widget _buildDynamicRow({
    required bool isDark,
    required String title,
    required String content,
    required Color contentColor,
    bool isTotal = false,
    bool isCopyable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              fontSize: isTotal ? 16 : 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    content,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
                      fontSize: isTotal ? 17 : 14,
                      color: contentColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
                if (isCopyable) ...[
                  const SizedBox(width: AppSpacing.xs),
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Clipboard.setData(ClipboardData(text: content));
                      ToastHelper().showSuccessToast("Copied to clipboard");
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
