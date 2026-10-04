import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/passcode_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/transaction_pin/transaction_pin_screen.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/controller/transfer_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/widgets/transfer_path_card.dart';
import 'package:ecardo_user/src/presentation/widgets/verify_passcode_bottom_sheet.dart';

class TransferReviewStepSection extends StatefulWidget {
  const TransferReviewStepSection({super.key});

  @override
  State<TransferReviewStepSection> createState() =>
      _TransferReviewStepSectionState();
}

class _TransferReviewStepSectionState extends State<TransferReviewStepSection> {
  final GlobalKey<EcardoSwipeButtonState> _swipeKey =
      GlobalKey<EcardoSwipeButtonState>();

  @override
  Widget build(BuildContext context) {
    final TransferController controller = Get.find();
    final SettingsService settingsService = Get.find();
    final localization = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final currentWallet = controller.wallet.value;
    final walletCode = currentWallet?.code ?? 'USD';

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: walletCode,
      siteCurrencyCode: settingsService.getSetting("site_currency") ?? 'USD',
      siteCurrencyDecimals:
          settingsService.getSetting("site_currency_decimals") ?? '2',
      isCrypto: currentWallet?.isCrypto ?? false,
    );

    return Obx(() {
      if (controller.isTransferConfigLoading.value) {
        return const CommonLoading();
      }

      final amountNum = double.tryParse(controller.amountController.text) ?? 0.0;
      final formattedAmount = amountNum.toStringAsFixed(calculateDecimals);

      final recipientUid = controller.recipientUidController.text.trim();
      final matchedBeneficiary = controller.findBeneficiaryByAccount(recipientUid);
      final recipientDisplayName = matchedBeneficiary?.nickname ??
          matchedBeneficiary?.receiver?.name ??
          'Recipient';

      final isFree = controller.charge.value <= 0.0 && !controller.chargeLoadFailed.value;
      final feeText = controller.chargeLoadFailed.value
          ? '—'
          : isFree
              ? 'Free (0.00 $walletCode)'
              : "${controller.charge.value.toStringAsFixed(calculateDecimals)} $walletCode";

      final totalText = controller.chargeLoadFailed.value
          ? '—'
          : "${controller.totalAmount.value.toStringAsFixed(calculateDecimals)} $walletCode";

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xs),
              Text(
                localization.transferReviewStepSectionTitle,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  letterSpacing: -0.2,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 1. Premium Visual Transfer Route Card (Sender -> Recipient)
              TransferPathCard(
                senderWallet: currentWallet,
                recipientName: recipientDisplayName,
                recipientUid: recipientUid,
                recipientAvatar: matchedBeneficiary?.receiver?.avatar,
                isRecipientVerified: matchedBeneficiary?.receiver != null,
                formattedAmount: formattedAmount,
                currencyCode: walletCode,
              ),

              const SizedBox(height: AppSpacing.lg),

              // 2. Glassmorphic Summary Box
              EcardoGlassCard(
                variant: EcardoGlassVariant.frosted,
                interactive: false,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      context,
                      title: localization.transferReviewStepSectionAmount,
                      content: "$formattedAmount $walletCode",
                      contentColor: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                      isBold: true,
                    ),
                    _buildDivider(colorScheme),
                    _buildSummaryRow(
                      context,
                      title: localization.transferReviewStepSectionWallet,
                      content: currentWallet?.name ?? '—',
                      contentColor: colorScheme.onSurface,
                    ),
                    _buildDivider(colorScheme),
                    _buildSummaryRow(
                      context,
                      title: localization.transferReviewStepSectionRecipientAccount,
                      content: recipientUid,
                      contentColor: colorScheme.onSurface,
                    ),
                    _buildDivider(colorScheme),
                    _buildSummaryRow(
                      context,
                      title: localization.transferReviewStepSectionCharge,
                      content: feeText,
                      contentColor: isFree ? AppColors.success : AppColors.error,
                      isTag: isFree,
                    ),
                    if (currentWallet?.conversionRate != null &&
                        currentWallet!.conversionRate!.isNotEmpty) ...[
                      _buildDivider(colorScheme),
                      _buildSummaryRow(
                        context,
                        title: 'Exchange Rate',
                        content: '1 $walletCode ≈ ${currentWallet.conversionRate}',
                        contentColor: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ],
                    _buildDivider(colorScheme),
                    _buildSummaryRow(
                      context,
                      title: 'Estimated Arrival',
                      content: 'Instant ⚡',
                      contentColor: AppColors.success,
                    ),
                    _buildDivider(colorScheme),
                    _buildSummaryRow(
                      context,
                      title: localization.transferReviewStepSectionTotalAmount,
                      content: totalText,
                      contentColor: colorScheme.primary,
                      isHero: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Security pill
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.4)
                        : colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 13,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Protected by eCardo Secure Passcode',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // 3. Swipe to Confirm Button (Design System)
              EcardoSwipeButton(
                key: _swipeKey,
                text: 'Swipe to Confirm Transfer',
                onSwipeComplete: () async {
                  await _triggerPasscodeAndTransfer(context, controller);
                },
                isLoading: controller.isTransferAmountLoading.value,
              ),

              const SizedBox(height: AppSpacing.md),

              // Back button
              CommonButton(
                backgroundColor: Colors.transparent,
                borderWidth: 1.5,
                borderColor: colorScheme.outlineVariant.withValues(alpha: 0.5),
                textColor: colorScheme.onSurface.withValues(alpha: 0.8),
                borderRadius: AppSpacing.radiusLg,
                width: double.infinity,
                height: 48,
                text: localization.transferReviewStepSectionBackButton,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  controller.currentStep.value = 0;
                },
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _triggerPasscodeAndTransfer(
    BuildContext context,
    TransferController controller,
  ) async {
    // Check if user has set a transaction passcode
    String? storedPasscode = controller.userModel.value.data?.passcode;
    if (storedPasscode == null || storedPasscode.isEmpty) {
      if (Get.isRegistered<HomeController>()) {
        storedPasscode = Get.find<HomeController>().userModel.value.data?.passcode;
      }
    }

    final hasPasscode = PasscodeHelper.userHasPasscode(storedPasscode);

    if (!hasPasscode) {
      HapticFeedback.mediumImpact();
      Get.defaultDialog(
        title: l10nPick(
          context,
          fa: 'تعیین رمز انتقال وجه (رمز دوم)',
          en: 'Set Transaction PIN',
          ar: 'تعيين رمز التحويل (PIN)',
        ),
        middleText: l10nPick(
          context,
          fa: 'برای امنیت حساب و انجام تراکنش‌های انتقال، ابتدا باید رمز انتقال وجه (۴ تا ۶ رقم) خود را تعیین فرمایید.',
          en: 'For security, you must set a 4 to 6 digit transaction PIN before transferring money.',
          ar: 'للأمان، يجب تعيين رمز أمان التحويل أولاً قبل إتمام العملية.',
        ),
        textConfirm: l10nPick(
          context,
          fa: 'تعیین رمز اکنون',
          en: 'Set PIN Now',
          ar: 'تعيين الرمز الآن',
        ),
        textCancel: l10nPick(
          context,
          fa: 'انصراف',
          en: 'Cancel',
          ar: 'إلغاء',
        ),
        buttonColor: AppColors.lightPrimary,
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back();
          Get.to(() => const TransactionPinScreen());
        },
      );
      return;
    }

    final String? verified = await Get.bottomSheet<String>(
      const VerifyPasscodeBottomSheet(),
    );
    if (verified == null || !PasscodeHelper.isValidFormat(verified)) {
      return;
    }
    await controller.transferAmount(passcode: verified);
  }

  Widget _buildDivider(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Divider(
        height: 1,
        color: colorScheme.outlineVariant.withValues(alpha: 0.25),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String title,
    required String content,
    required Color contentColor,
    bool isBold = false,
    bool isHero = false,
    bool isTag = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            letterSpacing: 0,
            fontWeight: isHero ? FontWeight.w800 : FontWeight.w600,
            fontSize: isHero ? 16 : 14,
            color: colorScheme.onSurface.withValues(alpha: isHero ? 0.9 : 0.6),
          ),
        ),
        if (isTag)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.successContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: contentColor,
              ),
            ),
          )
        else
          Flexible(
            child: Text(
              content,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                letterSpacing: 0,
                fontWeight: isHero
                    ? FontWeight.w900
                    : isBold
                        ? FontWeight.w800
                        : FontWeight.w700,
                fontSize: isHero ? 18 : 14,
                color: contentColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
