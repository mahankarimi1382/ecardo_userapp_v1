import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/services/biometric_auth_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_icon_button.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/passcode_helper.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/make_payment/controller/make_payment_controller.dart';
import 'package:ecardo_user/src/presentation/widgets/verify_passcode_bottom_sheet.dart';

class MakePaymentReviewStepSection extends StatefulWidget {
  const MakePaymentReviewStepSection({super.key});

  @override
  State<MakePaymentReviewStepSection> createState() =>
      _MakePaymentReviewStepSectionState();
}

class _MakePaymentReviewStepSectionState
    extends State<MakePaymentReviewStepSection> {
  final GlobalKey<EcardoSwipeButtonState> _swipeKey =
      GlobalKey<EcardoSwipeButtonState>();

  Future<void> _handleConfirmPayment(BuildContext context) async {
    HapticFeedback.lightImpact();
    final MakePaymentController controller = Get.find();

    final bioReason = l10nPick(
      context,
      en: 'Authenticate to confirm merchant payment',
      fa: 'جهت تأیید پرداخت به پذیرنده احراز هویت کنید',
      ar: 'التحقق لتأكيد دفع التاجر',
      tr: 'Üye işyeri ödemesini onaylamak için doğrulama yapın',
      ru: 'Подтвердите личность для оплаты мерчанту',
      zh: '请进行身份验证以确认向商户付款',
    );

    // Step-up Security: Try biometric first if available
    final biometricService = BiometricAuthService();
    try {
      final isBioEnabled = await biometricService.isEnabled();
      if (isBioEnabled) {
        final bioOk = await biometricService.authenticate(reason: bioReason);
        if (bioOk) {
          await controller.makePayment();
          return;
        }
      }
    } catch (_) {
      // Fallback to passcode prompt
    }

    final bool isPasscodeEnabled =
        Get.find<SettingsService>().getSetting(
          "make_payment_passcode_status",
        ) ==
        "1";

    String? storedPasscode = controller.userModel.value.data?.passcode;
    bool? hasPasscodeFlag = controller.userModel.value.data?.hasPasscode;
    if (storedPasscode == null || storedPasscode.isEmpty) {
      if (Get.isRegistered<HomeController>()) {
        storedPasscode =
            Get.find<HomeController>().userModel.value.data?.passcode;
        hasPasscodeFlag ??=
            Get.find<HomeController>().userModel.value.data?.hasPasscode;
      }
    }
    final hasPasscode = PasscodeHelper.userHasPasscode(
      storedPasscode,
      hasPasscodeFlag,
    );

    if (isPasscodeEnabled && hasPasscode) {
      final dynamic verified = await Get.bottomSheet<dynamic>(
        const VerifyPasscodeBottomSheet(),
      );
      if (verified == null ||
          !PasscodeHelper.isValidFormat(verified.toString())) {
        _swipeKey.currentState?.reset();
        return;
      }
      await controller.makePayment(passcode: verified.toString());
    } else {
      await controller.makePayment();
    }
  }

  @override
  Widget build(BuildContext context) {
    final MakePaymentController controller = Get.find();
    final SettingsService settingsService = Get.find();
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: controller.wallet.value!.code!,
      siteCurrencyCode: settingsService.getSetting("site_currency")!,
      siteCurrencyDecimals: settingsService.getSetting(
        "site_currency_decimals",
      )!,
      isCrypto: controller.wallet.value!.isCrypto!,
    );

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.makePaymentReviewStepSectionTitle,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Glassmorphic review card with fee breakdown
            EcardoGlassCard(
              variant: EcardoGlassVariant.standard,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Column(
                children: [
                  _buildReviewDynamicContent(
                    context,
                    isDark: isDark,
                    title: localization.makePaymentReviewStepSectionAmount,
                    content:
                        "${(double.tryParse(controller.amountController.text) ?? 0.0).toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",
                    contentColor: AppColors.success,
                  ),
                  _buildDivider(isDark),
                  Obx(
                    () => _buildReviewDynamicContent(
                      context,
                      isDark: isDark,
                      title: localization.makePaymentReviewStepSectionWallet,
                      content: controller.wallet.value!.name!,
                      contentColor: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  _buildDivider(isDark),
                  _buildReviewDynamicContent(
                    context,
                    isDark: isDark,
                    title: localization
                        .makePaymentReviewStepSectionMerchantAccount,
                    content: controller.merchantMidController.text,
                    contentColor: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  _buildDivider(isDark),
                  Obx(
                    () => _buildReviewDynamicContent(
                      context,
                      isDark: isDark,
                      title: localization.makePaymentReviewStepSectionCharge,
                      content: controller.chargeLoadFailed.value
                          ? '—'
                          : "${controller.charge.value.toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",
                      contentColor: AppColors.warning,
                      isBadge: true,
                    ),
                  ),
                  _buildDivider(isDark),
                  Obx(
                    () => _buildReviewDynamicContent(
                      context,
                      isDark: isDark,
                      title:
                          localization.makePaymentReviewStepSectionTotalAmount,
                      content: controller.chargeLoadFailed.value
                          ? '—'
                          : "${controller.totalAmount.value.toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",
                      contentColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                      isTotal: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Ultra-Modern Swipe Button
            Obx(
              () => EcardoSwipeButton(
                key: _swipeKey,
                text: l10nPick(
                  context,
                  en: 'Swipe to Confirm Payment',
                  fa: 'برای تأیید پرداخت بکشید',
                  ar: 'اسحب لتأكيد الدفع',
                  tr: 'Ödemeyi Onaylamak İçin Kaydırın',
                  ru: 'Проведите для подтверждения оплаты',
                  zh: '滑动以确认付款',
                ),
                loadingText: l10nPick(
                  context,
                  en: 'Processing...',
                  fa: 'در حال پردازش...',
                  ar: 'جارٍ المعالجة...',
                  tr: 'İşleniyor...',
                  ru: 'Обработка...',
                  zh: '处理中...',
                ),
                successText: l10nPick(
                  context,
                  en: 'Payment Confirmed',
                  fa: 'پرداخت تأیید شد',
                  ar: 'تم تأكيد الدفع',
                  tr: 'Ödeme Onaylandı',
                  ru: 'Оплата подтверждена',
                  zh: '付款已确认',
                ),
                isLoading: controller.isMakePaymentLoading.value,
                onSwipeComplete: () => _handleConfirmPayment(context),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Back button
            CommonIconButton(
              backgroundColor: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightPrimary.withValues(alpha: 0.04),
              borderWidth: 1.5,
              borderColor: isDark
                  ? AppColors.darkBorder
                  : AppColors.lightPrimary.withValues(alpha: 0.30),
              width: double.infinity,
              height: 48,
              text: localization.makePaymentReviewStepSectionBackButton,
              icon: PngAssets.reviewArrowBackCommonIcon,
              iconWidth: 18,
              iconHeight: 18,
              iconAndTextSpace: AppSpacing.sm,
              iconColor: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              textColor: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              onPressed: () {
                HapticFeedback.lightImpact();
                controller.currentStep.value = 0;
              },
            ),
            const SizedBox(height: AppSpacing.huge),
          ],
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

  static Widget _buildReviewDynamicContent(
    BuildContext context, {
    required bool isDark,
    required String title,
    required String content,
    required Color contentColor,
    bool isTotal = false,
    bool isBadge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          isBadge
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: contentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                  ),
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: contentColor,
                    ),
                  ),
                )
              : Text(
                  content,
                  style: TextStyle(
                    fontSize: isTotal ? 16 : 14,
                    fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
                    color: contentColor,
                  ),
                ),
        ],
      ),
    );
  }
}
