import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/gift_code/controller/create_gift_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';

class CreateGiftSuccessStepSection extends StatefulWidget {
  const CreateGiftSuccessStepSection({super.key});

  @override
  State<CreateGiftSuccessStepSection> createState() =>
      _CreateGiftSuccessStepSectionState();
}

class _CreateGiftSuccessStepSectionState
    extends State<CreateGiftSuccessStepSection> {
  final CreateGiftController controller = Get.find();
  final SettingsService settingsService = Get.find();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final wallet = controller.wallet.value;
    final walletCode = wallet?.code ?? 'USD';

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: walletCode,
      siteCurrencyCode: settingsService.getSetting("site_currency") ?? 'USD',
      siteCurrencyDecimals:
          settingsService.getSetting("site_currency_decimals") ?? '2',
      isCrypto: wallet?.isCrypto ?? false,
    );

    return Obx(() {
      if (controller.isCreateGiftLoading.value) {
        return const CommonLoading();
      }

      final giftData = controller.successCreateGiftData.value?["gift"];
      final rawCode = giftData?["code"]?.toString().trim() ?? '';
      final amount =
          double.tryParse(giftData?["amount"]?.toString() ?? '') ?? 0.0;
      final charge =
          double.tryParse(giftData?["charge"]?.toString() ?? '') ?? 0.0;
      final finalAmount =
          double.tryParse(giftData?["final_amount"]?.toString() ?? '') ?? 0.0;
      final currency = giftData?["currency"]?.toString() ?? walletCode;

      String formattedDate = '';
      final rawCreatedAt = giftData?["created_at"]?.toString();
      if (rawCreatedAt != null && rawCreatedAt.isNotEmpty) {
        try {
          formattedDate = DateFormat(
            "dd MMM yyyy, hh:mm a",
          ).format(DateTime.parse(rawCreatedAt));
        } catch (_) {
          formattedDate = rawCreatedAt;
        }
      }

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              // Success Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage(PngAssets.pendingAndSuccessFrame),
                    fit: BoxFit.contain,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(PngAssets.commonSuccessIcon, width: 72),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      localizations.createGiftSuccessTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
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

              // Prominent Gift Code Card with Copy Action
              if (rawCode.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.brandVioletContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(
                      color: isDark
                          ? AppColors.brandVioletDeep
                          : AppColors.brandViolet.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: 'GIFT VOUCHER CODE',
                          fa: 'کد هدیه تولیدشده',
                          ar: 'رمز قسيمة الهدية',
                          tr: 'Hediye Kupon Kodu',
                          ru: 'Код подарочного ваучера',
                          zh: '礼品券兑换码',
                        ),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: isDark
                              ? AppColors.mainSoftBlue
                              : AppColors.brandViolet,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SelectableText(
                        rawCode,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: isDark
                              ? AppColors.warmWhite
                              : AppColors.brandVioletDeep,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      InkWell(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Clipboard.setData(ClipboardData(text: rawCode));
                          ToastHelper().showSuccessToast(
                            l10nPick(
                              context,
                              en: 'Gift code copied to clipboard',
                              fa: 'کد هدیه در کلیپ‌بورد کپی شد',
                              ar: 'تم نسخ رمز الهدية',
                              tr: 'Hediye kodu kopyalandı',
                              ru: 'Код подарка скопирован',
                              zh: '礼品码已复制',
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs + 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.copy_rounded,
                                size: 14,
                                color: isDark
                                    ? AppColors.mainSoftBlue
                                    : AppColors.brandViolet,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                l10nPick(
                                  context,
                                  en: 'Copy Code',
                                  fa: 'کپی کد هدیه',
                                  ar: 'نسخ الرمز',
                                  tr: 'Kodu Kopyala',
                                  ru: 'Копировать',
                                  zh: '复制代码',
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.mainSoftBlue
                                      : AppColors.brandViolet,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Breakdown Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      title: localizations.createGiftSuccessAmount,
                      content:
                          "${amount.toStringAsFixed(calculateDecimals)} $currency",
                      contentColor: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Divider(
                      height: 1,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildSummaryRow(
                      title: localizations.createGiftSuccessCharge,
                      content:
                          "${charge.toStringAsFixed(calculateDecimals)} $currency",
                      contentColor: AppColors.error,
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Divider(
                      height: 1,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildSummaryRow(
                      title: localizations.createGiftSuccessFinalAmount,
                      content:
                          "${finalAmount.toStringAsFixed(calculateDecimals)} $currency",
                      contentColor: AppColors.success,
                      isDark: isDark,
                    ),
                    if (formattedDate.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Divider(
                        height: 1,
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildSummaryRow(
                        title: localizations.createGiftSuccessCreatedAt,
                        content: formattedDate,
                        contentColor: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        isDark: isDark,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Action Buttons
              CommonButton(
                onPressed: () async {
                  controller.currentStep.value = 0;
                  controller.clearFields();
                },
                width: double.infinity,
                text: localizations.createGiftSuccessCreateAgain,
              ),
              const SizedBox(height: AppSpacing.md),
              CommonButton(
                onPressed: () async {
                  Get.toNamed(BaseRoute.navigation);
                  Get.find<HomeController>().selectedIndex.value = 0;
                  await Get.find<HomeController>().loadData();
                },
                width: double.infinity,
                text: localizations.createGiftSuccessBackHome,
                backgroundColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                borderColor: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
                textColor: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSummaryRow({
    required String title,
    required String content,
    required Color contentColor,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          content,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: contentColor,
          ),
        ),
      ],
    );
  }
}
