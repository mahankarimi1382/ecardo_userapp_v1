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
import 'package:ecardo_user/src/helper/passcode_helper.dart';
import 'package:ecardo_user/src/presentation/screens/beneficiary/widgets/monogram_avatar.dart';
import 'package:ecardo_user/src/presentation/screens/cash_out/controller/cash_out_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/widgets/withdraw_breakdown_card.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/widgets/withdraw_step_indicator.dart';
import 'package:ecardo_user/src/presentation/widgets/verify_passcode_bottom_sheet.dart';

class CashOutReviewStepSection extends StatefulWidget {
  const CashOutReviewStepSection({super.key});

  @override
  State<CashOutReviewStepSection> createState() =>
      _CashOutReviewStepSectionState();
}

class _CashOutReviewStepSectionState extends State<CashOutReviewStepSection> {
  final GlobalKey<EcardoSwipeButtonState> _swipeKey =
      GlobalKey<EcardoSwipeButtonState>();

  Future<void> _handleConfirmCashOut(BuildContext context) async {
    HapticFeedback.lightImpact();
    final CashOutController controller = Get.find();

    final bioReason = l10nPick(
      context,
      en: 'Authenticate to confirm cash-out to agent',
      fa: 'جهت تأیید تسویه نقدی با نماینده احراز هویت کنید',
      ar: 'التحقق لتأكيد السحب النقدي',
      tr: 'Nakit çekimi onaylamak için doğrulama yapın',
      ru: 'Подтвердите личность для выдачи наличных',
      zh: '请进行身份验证以确认代理提现',
    );

    // Step-up Security: Try biometric first if available
    final biometricService = BiometricAuthService();
    try {
      final isBioEnabled = await biometricService.isEnabled();
      if (isBioEnabled) {
        final bioOk = await biometricService.authenticate(reason: bioReason);
        if (bioOk) {
          // If biometric succeeds, submit with stored/auto passcode
          await controller.cashOut();
          return;
        }
      }
    } catch (_) {
      // Fallback to passcode prompt
    }

    // Step-up Security: Verify Transaction Passcode
    final bool isPasscodeEnabled =
        Get.find<SettingsService>().getSetting("cashout_passcode_status") ==
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
      await controller.cashOut(passcode: verified.toString());
    } else {
      await controller.cashOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final CashOutController controller = Get.find();
    final SettingsService settingsService = Get.find();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final wallet = controller.wallet.value;
    final currency = wallet?.code ?? 'USD';

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: currency,
      siteCurrencyCode: settingsService.getSetting("site_currency") ?? 'USD',
      siteCurrencyDecimals:
          settingsService.getSetting("site_currency_decimals") ?? '2',
      isCrypto: wallet?.isCrypto ?? false,
    );

    final requestedAmount =
        double.tryParse(controller.amountController.text.trim()) ?? 0.0;
    final feeAmount = controller.charge.value;
    final totalAmount = controller.totalAmount.value;
    final agentAid = controller.agentAidController.text.trim();

    return Obx(() {
      if (controller.isCashoutConfigLoading.value) {
        return const Center(child: CommonLoading());
      }

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step Indicator
              WithdrawStepIndicator(
                currentStep: 1,
                onStepTapped: (step) {
                  if (step == 0) controller.currentStep.value = 0;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              Text(
                localizations.cashOutReviewTitle,
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

              // 1. Destination Agent Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.20)
                          : AppColors.lightShadow,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    MonogramAvatar(
                      name: "Agent $agentAid",
                      size: 46,
                      isVerified: true,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${localizations.cashOutReviewAgentAccount}: $agentAid",
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "${localizations.cashOutReviewWallet}: ${wallet?.name ?? ''} ($currency)",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 13,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            l10nPick(
                              context,
                              en: 'Verified',
                              fa: 'تأییدشده',
                              ar: 'تم التحقق',
                              tr: 'Doğrulandı',
                              ru: 'Подтверждено',
                              zh: '已验证',
                            ),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 2. Fee & Payout Breakdown Card
              WithdrawBreakdownCard(
                requestedAmount: requestedAmount,
                feeAmount: feeAmount,
                netPayout: requestedAmount,
                currency: currency,
                decimals: calculateDecimals,
                settlementTime: l10nPick(
                  context,
                  en: 'Instant Agent Payout ⚡',
                  fa: 'تسویه آنی نقدی از نماینده ⚡',
                  ar: 'تسوية نقدية فورية ⚡',
                  tr: 'Anında Nakit ⚡',
                  ru: 'Мгновенная выдача ⚡',
                  zh: '即时代理提现 ⚡',
                ),
                hasFeeError: controller.chargeLoadFailed.value,
                isFeeLoading: controller.isCashoutConfigLoading.value,
              ),

              const SizedBox(height: AppSpacing.md),

              // Total Debited Summary Box
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
                    Text(
                      localizations.cashOutReviewTotalAmount,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      "${totalAmount.toStringAsFixed(calculateDecimals)} $currency",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Step-up Security Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant.withValues(alpha: 0.4)
                        : AppColors.lightSecondaryContainer.withValues(
                            alpha: 0.45,
                          ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined, size: 14, color: accentColor),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10nPick(
                          context,
                          en: 'Protected by eCardo Passcode & Biometric Security',
                          fa: 'تأیید امنیتی با رمز عبور و بیومتریک',
                          ar: 'محمي بكلمة المرور والأمان البيومتري',
                          tr: 'Şifre ve Biyometrik Güvenlik Korumalı',
                          ru: 'Защищено PIN-кодом и биометрией',
                          zh: '受 eCardo 密码与生物识别安全保护',
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

              // Swipe to Confirm Button
              Obx(
                () => EcardoSwipeButton(
                  key: _swipeKey,
                  text: l10nPick(
                    context,
                    en: 'Swipe to Confirm Cash-out',
                    fa: 'بکشید برای تأیید تسویه نقدی',
                    ar: 'اسحب لتأكيد السحب',
                    tr: 'Nakit Çekimi Onaylamak İçin Kaydırın',
                    ru: 'Проведите для подтверждения',
                    zh: '滑动以确认提现',
                  ),
                  loadingText: l10nPick(
                    context,
                    en: 'Processing Cash-out...',
                    fa: 'در حال پردازش درخواست نقدی...',
                    ar: 'جار معالجة السحب...',
                    tr: 'İşleniyor...',
                    ru: 'Обработка...',
                    zh: '正在处理提现...',
                  ),
                  successText: l10nPick(
                    context,
                    en: 'Cash-out Confirmed',
                    fa: 'تسویه نقدی تأیید شد',
                    ar: 'تم تأكيد السحب',
                    tr: 'Onaylandı',
                    ru: 'Подтверждено',
                    zh: '提现已确认',
                  ),
                  isLoading: controller.isCashOutLoading.value,
                  enabled:
                      !controller.chargeLoadFailed.value &&
                      !controller.isCashOutLoading.value,
                  onSwipeComplete: () async {
                    await _handleConfirmCashOut(context);
                    _swipeKey.currentState?.reset();
                  },
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
                text: localizations.cashOutReviewBack,
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
