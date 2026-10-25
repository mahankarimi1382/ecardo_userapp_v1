import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
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

      final amountNum =
          double.tryParse(controller.amountController.text) ?? 0.0;
      final formattedAmount = _formatAmount(amountNum, calculateDecimals);

      final recipientUid = controller.recipientUidController.text.trim();
      final matchedBeneficiary = controller.findBeneficiaryByAccount(
        recipientUid,
      );
      final recipientDisplayName =
          matchedBeneficiary?.nickname ??
          matchedBeneficiary?.receiver?.name ??
          'Recipient';

      final isFree =
          controller.charge.value <= 0.0 && !controller.chargeLoadFailed.value;
      final zeroFormatted = _formatAmount(0.0, calculateDecimals);
      final feeText = controller.chargeLoadFailed.value
          ? '—'
          : isFree
          ? l10nPick(
              context,
              en: 'Free ($zeroFormatted $walletCode)',
              fa: 'رایگان ($zeroFormatted $walletCode)',
              ar: 'مجاني ($zeroFormatted $walletCode)',
              tr: 'Ücretsiz ($zeroFormatted $walletCode)',
              ru: 'Бесплатно ($zeroFormatted $walletCode)',
              zh: '免费 ($zeroFormatted $walletCode)',
            )
          : "${_formatAmount(controller.charge.value, calculateDecimals)} $walletCode";

      final totalText = controller.chargeLoadFailed.value
          ? '—'
          : "${_formatAmount(controller.totalAmount.value, calculateDecimals)} $walletCode";

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
                      contentColor: isDark
                          ? AppColors.mainSoftBlue
                          : AppColors.deepBlack,
                      isBold: true,
                      isNumeric: true,
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
                      title: localization
                          .transferReviewStepSectionRecipientAccount,
                      content: recipientUid,
                      contentColor: colorScheme.onSurface,
                      isNumeric: true,
                    ),
                    _buildDivider(colorScheme),
                    _buildSummaryRow(
                      context,
                      title: localization.transferReviewStepSectionCharge,
                      content: feeText,
                      contentColor: isFree
                          ? AppColors.success
                          : AppColors.error,
                      isTag: isFree,
                      isNumeric: true,
                    ),
                    if (currentWallet?.conversionRate != null &&
                        currentWallet!.conversionRate!.isNotEmpty) ...[
                      _buildDivider(colorScheme),
                      _buildSummaryRow(
                        context,
                        title: l10nPick(
                          context,
                          en: 'Exchange Rate',
                          fa: 'نرخ تبدیل',
                          ar: 'سعر الصرف',
                          tr: 'Döviz Kuru',
                          ru: 'Курс обмена',
                          zh: '汇率',
                        ),
                        content:
                            '1 $walletCode ≈ ${currentWallet.conversionRate}',
                        contentColor: colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                        isNumeric: true,
                      ),
                    ],
                    _buildDivider(colorScheme),
                    _buildSummaryRow(
                      context,
                      title: l10nPick(
                        context,
                        en: 'Estimated Arrival',
                        fa: 'زمان تقریبی رسیدن',
                        ar: 'الوقت المقدر للوصول',
                        tr: 'Tahmini Varış',
                        ru: 'Ориентировочное время',
                        zh: '预计到账时间',
                      ),
                      content: l10nPick(
                        context,
                        en: 'Instant ⚡',
                        fa: 'آنی ⚡',
                        ar: 'فوري ⚡',
                        tr: 'Anında ⚡',
                        ru: 'Мгновенно ⚡',
                        zh: '即时 ⚡',
                      ),
                      contentColor: AppColors.success,
                    ),
                    _buildDivider(colorScheme),
                    _buildSummaryRow(
                      context,
                      title: localization.transferReviewStepSectionTotalAmount,
                      content: totalText,
                      contentColor: colorScheme.primary,
                      isHero: true,
                      isNumeric: true,
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
                        ? colorScheme.surfaceContainerHigh.withValues(
                            alpha: 0.4,
                          )
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
                        l10nPick(
                          context,
                          en: 'Protected by eCardo Secure Passcode',
                          fa: 'محافظت‌شده با رمز امنیتی eCardo',
                          ar: 'محمي برمز المرور الآمن لـ eCardo',
                          tr: 'eCardo Güvenli Parola ile Korunuyor',
                          ru: 'Защищено безопасным паролем eCardo',
                          zh: '受 eCardo 安全密码保护',
                        ),
                        style: TextStyle(
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
                text: l10nPick(
                  context,
                  en: 'Swipe to Confirm Transfer',
                  fa: 'برای تایید انتقال به راست بکشید',
                  ar: 'اسحب لتأكيد التحويل',
                  tr: 'Transferi Onaylamak İçin Kaydır',
                  ru: 'Проведите для подтверждения перевода',
                  zh: '滑动以确认转账',
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
                  en: 'Confirmed',
                  fa: 'تایید شد',
                  ar: 'تم التأكيد',
                  tr: 'Onaylandı',
                  ru: 'Подтверждено',
                  zh: '已确认',
                ),
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
    if (controller.isTransferAmountLoading.value) return;

    final bool isPasscodeSettingEnabled =
        Get.find<SettingsService>().getSetting(
          "transfer_money_passcode_status",
        ) ==
        "1";

    if (!isPasscodeSettingEnabled) {
      await controller.transferAmount();
      return;
    }

    // Check if user has set a transaction passcode
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
        textCancel: l10nPick(context, fa: 'انصراف', en: 'Cancel', ar: 'إلغاء'),
        buttonColor: AppColors.lightPrimary,
        confirmTextColor: Colors.white,
        onConfirm: () async {
          Get.back();
          await Get.to(() => const TransactionPinScreen());
          await controller.fetchUser();
          if (Get.isRegistered<HomeController>()) {
            await Get.find<HomeController>().fetchUser();
          }
        },
      );
      return;
    }

    final dynamic verified = await Get.bottomSheet<dynamic>(
      const VerifyPasscodeBottomSheet(),
    );
    if (verified == null ||
        !PasscodeHelper.isValidFormat(verified.toString())) {
      return;
    }
    await controller.transferAmount(passcode: verified.toString());
  }

  /// Display formatting aligned with the design-system money widgets
  /// (EcardoDigitalReceipt / EcardoBalanceHero): en_US grouping, no symbol.
  static String _formatAmount(double value, int decimals) {
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: '',
      decimalDigits: decimals,
    ).format(value).trim();
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
    bool isNumeric = false,
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
              // Amounts / UIDs stay LTR-isolated inside the RTL layout.
              textDirection: isNumeric ? TextDirection.ltr : null,
              style: TextStyle(
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
