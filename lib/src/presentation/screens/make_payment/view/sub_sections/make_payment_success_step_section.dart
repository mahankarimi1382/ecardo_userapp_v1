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
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/make_payment/controller/make_payment_controller.dart';

class MakePaymentSuccessStepSection extends StatefulWidget {
  const MakePaymentSuccessStepSection({super.key});

  @override
  State<MakePaymentSuccessStepSection> createState() =>
      _MakePaymentSuccessStepSectionState();
}

class _MakePaymentSuccessStepSectionState
    extends State<MakePaymentSuccessStepSection> {
  final MakePaymentController controller = Get.find();
  final settingsService = Get.find<SettingsService>();
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    totalCalculate();
  }

  void totalCalculate() {
    final amountRaw =
        controller.successPaymentData.value?["transaction"]?["amount"];
    final chargeRaw =
        controller.successPaymentData.value?["transaction"]?["charge"];

    double amount = double.tryParse(amountRaw.toString()) ?? 0.0;
    double charge = double.tryParse(chargeRaw.toString()) ?? 0.0;

    totalAmount = amount + charge;
  }

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

    return Obx(
      () => controller.isMakePaymentLoading.value
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
                            localization.makePaymentSuccessStepSectionTitle,
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
                                .makePaymentSuccessStepSectionAmount,
                            content:
                                "${double.tryParse(controller.amountController.text)?.toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",
                            contentColor: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                          _buildDivider(isDark),
                          _buildDynamicRow(
                            isDark: isDark,
                            title: localization
                                .makePaymentSuccessStepSectionTransactionId,
                            content:
                                "${controller.successPaymentData.value?["transaction"]?["tnx"] ?? ''}",
                            contentColor: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                            isCopyable: true,
                          ),
                          _buildDivider(isDark),
                          Obx(
                            () => _buildDynamicRow(
                              isDark: isDark,
                              title: localization
                                  .makePaymentSuccessStepSectionWalletName,
                              content: controller.wallet.value!.name!,
                              contentColor: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          _buildDivider(isDark),
                          Obx(
                            () => _buildDynamicRow(
                              isDark: isDark,
                              title: localization
                                  .makePaymentSuccessStepSectionPaymentMethod,
                              content: controller.wallet.value!.code!,
                              contentColor: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          _buildDivider(isDark),
                          Obx(
                            () => _buildDynamicRow(
                              isDark: isDark,
                              title: localization
                                  .makePaymentSuccessStepSectionCharge,
                              content:
                                  "${(double.tryParse(controller.successPaymentData.value?["transaction"]?["charge"]?.toString() ?? "0") ?? 0.0).toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",
                              contentColor: AppColors.warning,
                            ),
                          ),
                          _buildDivider(isDark),
                          _buildDynamicRow(
                            isDark: isDark,
                            title:
                                localization.makePaymentSuccessStepSectionType,
                            content:
                                "${controller.successPaymentData.value?["transaction"]?["type"] ?? ''}",
                            contentColor: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                          _buildDivider(isDark),
                          Obx(
                            () => _buildDynamicRow(
                              isDark: isDark,
                              title: localization
                                  .makePaymentSuccessStepSectionFinalAmount,
                              content:
                                  "${totalAmount.toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",
                              contentColor: AppColors.success,
                              isTotal: true,
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
                        controller.isLoading.value = true;
                        await controller.fetchWallets();
                        controller.isLoading.value = false;
                      },
                      width: double.infinity,
                      text: localization
                          .makePaymentSuccessStepSectionPaymentAgainButton,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CommonButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        Get.delete<MakePaymentController>();
                        Get.toNamed(BaseRoute.navigation);
                        await Get.find<HomeController>().loadData();
                      },
                      width: double.infinity,
                      text: localization
                          .makePaymentSuccessStepSectionBackHomeButton,
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
