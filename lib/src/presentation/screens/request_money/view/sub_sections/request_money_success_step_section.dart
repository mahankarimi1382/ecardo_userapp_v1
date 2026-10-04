import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/controller/request_money_controller.dart';

class RequestMoneySuccessStepSection extends StatefulWidget {
  const RequestMoneySuccessStepSection({super.key});

  @override
  State<RequestMoneySuccessStepSection> createState() =>
      _RequestMoneySuccessStepSectionState();
}

class _RequestMoneySuccessStepSectionState
    extends State<RequestMoneySuccessStepSection> {
  final RequestMoneyController controller = Get.find();
  final SettingsService settingsService = Get.find();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: controller.wallet.value!.name!,
      siteCurrencyCode: settingsService.getSetting("site_currency")!,
      siteCurrencyDecimals: settingsService.getSetting(
        "site_currency_decimals",
      )!,
      isCrypto: controller.wallet.value!.isCrypto!,
    );

    final dynamic requestData = controller.successPaymentData.value?["request"];
    final double successChargeValue =
        double.tryParse(requestData?["charge"]?.toString() ?? '') ?? 0.0;
    final double successFinalAmountValue =
        double.tryParse(requestData?["final_amount"]?.toString() ?? '') ?? 0.0;

    return Obx(
      () => controller.isRequestMoneyLoading.value
          ? const CommonLoading()
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    // Success Hero Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xl,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.success.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXl,
                        ),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            PngAssets.commonSuccessIcon,
                            width: 72,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            localization.requestMoneySuccessStepSectionTitle,
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
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? AppColors.darkShadow
                                : AppColors.lightShadow,
                            blurRadius: AppSpacing.md,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildDynamicRow(
                            isDark: isDark,
                            title: localization
                                .requestMoneySuccessStepSectionAmount,
                            content:
                                "${double.tryParse(controller.requestAmountController.text)?.toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",
                            contentColor: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                          _buildDivider(isDark),
                          _buildDynamicRow(
                            isDark: isDark,
                            title: localization
                                .requestMoneySuccessStepSectionRecipientName,
                            content:
                                "${controller.successPaymentData.value?["request"]?["recipient"]?["name"] ?? ''}",
                            contentColor: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                          _buildDivider(isDark),
                          _buildDynamicRow(
                            isDark: isDark,
                            title: localization
                                .requestMoneySuccessStepSectionRequestWalletName,
                            content:
                                "${controller.successPaymentData.value?["request"]?["requester_wallet_currency_name"] ?? ''}",
                            contentColor: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                          _buildDivider(isDark),
                          _buildDynamicRow(
                            isDark: isDark,
                            title: localization
                                .requestMoneySuccessStepSectionCharge,
                            content:
                                "${successChargeValue.toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",
                            contentColor: AppColors.warning,
                          ),
                          _buildDivider(isDark),
                          _buildDynamicRow(
                            isDark: isDark,
                            title: localization
                                .requestMoneySuccessStepSectionFinalAmount,
                            content:
                                "${successFinalAmountValue.toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",
                            contentColor: AppColors.success,
                            isTotal: true,
                          ),
                          _buildDivider(isDark),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  localization
                                      .requestMoneySuccessStepSectionStatus,
                                  style: TextStyle(
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusFull,
                                    ),
                                    border: Border.all(
                                      color: AppColors.warning.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                    color: AppColors.warning.withValues(
                                      alpha: 0.08,
                                    ),
                                  ),
                                  child: Text(
                                    () {
                                      final status = (controller
                                                  .successPaymentData
                                                  .value?["request"]?["status"] ??
                                              "")
                                          .toString()
                                          .toLowerCase();
                                      return status.isNotEmpty
                                          ? status[0].toUpperCase() +
                                              status.substring(1)
                                          : "";
                                    }(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0,
                                      fontSize: 12,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                        await controller.fetchWallets();
                      },
                      width: double.infinity,
                      text: localization
                          .requestMoneySuccessStepSectionRequestAgainButton,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CommonButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        Get.delete<RequestMoneyController>();
                        Get.toNamed(BaseRoute.navigation);
                        await Get.find<HomeController>().loadData();
                      },
                      width: double.infinity,
                      text: localization
                          .requestMoneySuccessStepSectionBackHomeButton,
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
            ),
    );
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
        ],
      ),
    );
  }
}
