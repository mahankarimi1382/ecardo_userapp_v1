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
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/controller/withdraw_controller.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/widgets/withdraw_breakdown_card.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/widgets/withdraw_destination_card.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/widgets/withdraw_step_indicator.dart';
import 'package:ecardo_user/src/presentation/widgets/verify_passcode_bottom_sheet.dart';

class WithdrawReviewStepSection extends StatefulWidget {
  const WithdrawReviewStepSection({super.key});

  @override
  State<WithdrawReviewStepSection> createState() =>
      _WithdrawReviewStepSectionState();
}

class _WithdrawReviewStepSectionState extends State<WithdrawReviewStepSection> {
  final GlobalKey<EcardoSwipeButtonState> _swipeKey =
      GlobalKey<EcardoSwipeButtonState>();

  Future<void> _handleConfirmWithdraw(BuildContext context) async {
    HapticFeedback.lightImpact();
    final WithdrawController controller = Get.find();

    // If user has passcode configured as "0" (no security set)
    if (controller.userModel.value.data?.passcode == "0") {
      await controller.submitWithdraw();
      return;
    }

    // Pre-resolve localized string before async boundaries
    final authReason = l10nPick(
      context,
      en: 'Authenticate to confirm withdrawal',
      fa: 'جهت تأیید برداشت وجه احراز هویت کنید',
      ar: 'تحقق من الهوية لتأكيد السحب',
      tr: 'Çekimi onaylamak için kimlik doğrulaması yapın',
      ru: 'Подтвердите личность для вывода средств',
    );

    // Step-up Security: Attempt Biometric first if enabled
    final biometricService = BiometricAuthService();
    try {
      final isBiometricEnabled = await biometricService.isEnabled();
      if (isBiometricEnabled) {
        final authenticated = await biometricService.authenticate(
          reason: authReason,
        );
        if (authenticated) {
          await controller.submitWithdraw();
          return;
        }
      }
    } catch (_) {
      // Fallback to passcode bottom sheet
    }

    // Step-up Security: Verify Transaction Passcode
    final bool isPasscodeEnabled =
        Get.find<SettingsService>().getSetting("withdraw_passcode_status") == "1";

    if (isPasscodeEnabled) {
      final dynamic verified = await Get.bottomSheet<dynamic>(
        const VerifyPasscodeBottomSheet(),
      );
      final isVerified = verified != null &&
          verified != false &&
          (verified is! String || verified.isNotEmpty);
      if (!isVerified) {
        _swipeKey.currentState?.reset();
        return;
      }
      final passcode = verified is String ? verified : null;
      await controller.submitWithdraw(passcode: passcode);
    } else {
      await controller.submitWithdraw();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final WithdrawController controller = Get.find();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final selectedAccount = controller.withdrawAccount.value;
    final currency = selectedAccount?.currency ?? "";
    final isCrypto = selectedAccount?.method?.isCrypto ?? false;

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: currency,
      siteCurrencyCode: Get.find<SettingsService>().getSetting(
        "site_currency",
      )!,
      siteCurrencyDecimals: Get.find<SettingsService>().getSetting(
        "site_currency_decimals",
      )!,
      isCrypto: isCrypto,
    );

    final requestedAmount =
        double.tryParse(controller.amountController.text.trim()) ?? 0.0;
    final formattedTotal = controller.chargeLoadFailed.value
        ? '—'
        : "${controller.totalAmount.value.toStringAsFixed(calculateDecimals)} $currency";

    return Obx(() {
      if (controller.isChargeConverterLoading.value) {
        return const Center(child: CommonLoading());
      }

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step Indicator (Amount -> Review -> Success)
              WithdrawStepIndicator(
                currentStep: 1,
                onStepTapped: (step) {
                  if (step == 0) controller.currentStep.value = 0;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Title
              Text(
                l10nPick(
                  context,
                  en: 'Review Payout Details',
                  fa: 'بررسی و تأیید نهایی برداشت',
                  ar: 'مراجعة وتأكيد السحب',
                  tr: 'Çekim Detaylarını İnceleyin',
                  ru: 'Проверка деталей вывода',
                ),
                style: TextStyle(
                  letterSpacing: -0.2,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 1. Receiver Destination Card
              if (selectedAccount != null) ...[
                Text(
                  l10nPick(
                    context,
                    en: 'Destination Account',
                    fa: 'حساب بانکی مقصد',
                    ar: 'الحساب المصرفي الوجهة',
                    tr: 'Hedef Banka Hesabı',
                    ru: 'Счет назначения',
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                WithdrawDestinationCard(
                  account: selectedAccount,
                  mode: WithdrawCardMode.review,
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // 2. Fee & Payout Breakdown Card
              WithdrawBreakdownCard(
                requestedAmount: requestedAmount,
                feeAmount: controller.calculatedCharge.value,
                netPayout: requestedAmount,
                currency: currency,
                decimals: calculateDecimals,
                settlementTime: selectedAccount?.method?.time,
                hasFeeError: controller.chargeLoadFailed.value,
                isFeeLoading: controller.isChargeConverterLoading.value,
              ),

              const SizedBox(height: AppSpacing.md),

              // Total Amount Debited Box
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                      : AppColors.lightSurfaceVariant.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization.withdrawReviewStepSectionTotalAmount,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10nPick(
                            context,
                            en: 'Debited from your eCardo balance',
                            fa: 'مبلغ کل کسرشده از موجودی کیف پول',
                            ar: 'المخصوم من رصيد المحفظة',
                            tr: 'Cüzdanınızdan düşülecek toplam',
                            ru: 'Спишется с баланса eCardo',
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextTertiary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      formattedTotal,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 3. Step-up Security Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant.withValues(alpha: 0.4)
                        : AppColors.lightSecondaryContainer
                            .withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: accentColor,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10nPick(
                          context,
                          en: 'Protected by eCardo Passcode & Biometric Security',
                          fa: 'تأیید امنیتی دومرحله‌ای با رمز عبور و بیومتریک',
                          ar: 'محمي بكلمة المرور والأمان البيومتري',
                          tr: 'Şifre ve Biyometrik Güvenlik Korumalı',
                          ru: 'Защищено PIN-кодом и биометрией',
                        ),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // 4. Swipe to Confirm Button (Design System)
              Obx(() => EcardoSwipeButton(
                    key: _swipeKey,
                    text: l10nPick(
                      context,
                      en: 'Swipe to Confirm Payout',
                      fa: 'بکشید برای تأیید و ثبت برداشت',
                      ar: 'اسحب لتأكيد السحب',
                      tr: 'Çekimi Onaylamak İçin Kaydırın',
                      ru: 'Проведите для подтверждения',
                    ),
                    loadingText: l10nPick(
                      context,
                      en: 'Processing Withdrawal...',
                      fa: 'در حال پردازش برداشت وجه...',
                      ar: 'جار معالجة السحب...',
                      tr: 'Çekim İşleniyor...',
                      ru: 'Обработка вывода...',
                    ),
                    successText: l10nPick(
                      context,
                      en: 'Payout Confirmed',
                      fa: 'برداشت تأیید شد',
                      ar: 'تم تأكيد السحب',
                      tr: 'Çekim Onaylandı',
                      ru: 'Вывод подтвержден',
                    ),
                    isLoading: controller.isWithdrawLoading.value,
                    enabled: !controller.chargeLoadFailed.value &&
                        !controller.isWithdrawLoading.value,
                    onSwipeComplete: () async {
                      await _handleConfirmWithdraw(context);
                      _swipeKey.currentState?.reset();
                    },
                  )),

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
                text: localization.withdrawReviewStepSectionBackButton,
                icon: PngAssets.reviewArrowBackCommonIcon,
                iconWidth: 16,
                iconHeight: 16,
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
    });
  }
}
