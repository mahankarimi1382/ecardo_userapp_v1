import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/model/beneficiary_model.dart';
import 'package:ecardo_user/src/common/services/biometric_auth_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/passcode_helper.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/make_payment/controller/make_payment_controller.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/transaction_pin/transaction_pin_screen.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/widgets/transfer_path_card.dart';
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
    final MakePaymentController controller = Get.find();
    if (controller.isMakePaymentLoading.value) return;

    HapticFeedback.lightImpact();

    final bioReason = l10nPick(
      context,
      en: 'Authenticate to confirm merchant payment',
      fa: 'جهت تأیید پرداخت به پذیرنده احراز هویت کنید',
      ar: 'التحقق لتأكيد دفع التاجر',
      tr: 'Üye işyeri ödemesini onaylamak için doğrulama yapın',
      ru: 'Подтвердите личность для оплаты мерчанту',
      zh: '请进行身份验证以确认向商户付款',
    );

    final dialogTitle = l10nPick(
      context,
      fa: 'تعیین رمز پرداخت (رمز دوم)',
      en: 'Set Transaction PIN',
      ar: 'تعيين رمز الدفع (PIN)',
    );
    final dialogMiddle = l10nPick(
      context,
      fa: 'برای امنیت حساب و انجام تراکنش‌های پرداخت، ابتدا باید رمز تراکنش خود را تعیین فرمایید.',
      en: 'For security, you must set a 4 to 6 digit transaction PIN before making payments.',
      ar: 'للأمان، يجب تعيين رمز أمان الدفع أولاً قبل إتمام العملية.',
    );
    final dialogConfirm = l10nPick(
      context,
      fa: 'تعیین رمز اکنون',
      en: 'Set PIN Now',
      ar: 'تعيين الرمز الآن',
    );
    final dialogCancel = l10nPick(
      context,
      fa: 'انصراف',
      en: 'Cancel',
      ar: 'إلغاء',
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

    if (isPasscodeEnabled && !hasPasscode) {
      HapticFeedback.mediumImpact();
      Get.defaultDialog(
        title: dialogTitle,
        middleText: dialogMiddle,
        textConfirm: dialogConfirm,
        textCancel: dialogCancel,
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
      _swipeKey.currentState?.reset();
      return;
    }

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

  Beneficiaries? _findMatchedMerchant(
    List<Beneficiaries>? beneficiaries,
    String mid,
  ) {
    if (beneficiaries == null || mid.isEmpty) return null;
    final cleanMid = mid.trim();
    try {
      return beneficiaries.firstWhere(
        (b) => b.accountNumber?.trim() == cleanMid,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final MakePaymentController controller = Get.find();
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
      if (controller.isPaymentSettingsLoading.value) {
        return const CommonLoading();
      }

      final amountNum =
          double.tryParse(controller.amountController.text) ?? 0.0;
      final formattedAmount = amountNum.toStringAsFixed(calculateDecimals);

      final merchantMid = controller.merchantMidController.text.trim();
      final beneficiaries =
          controller.beneficiaryModel.value.data?.beneficiaries;
      final matchedMerchant = _findMatchedMerchant(beneficiaries, merchantMid);
      final merchantDisplayName =
          matchedMerchant?.nickname ??
          matchedMerchant?.receiver?.name ??
          'Merchant ($merchantMid)';

      final isFree =
          controller.charge.value <= 0.0 && !controller.chargeLoadFailed.value;
      final zeroFormatted = (0.0).toStringAsFixed(calculateDecimals);
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
                localization.makePaymentReviewStepSectionTitle,
                style: TextStyle(
                  letterSpacing: -0.2,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 1. Standardized Visual Payment Route Card (Payer Wallet --> Merchant)
              TransferPathCard(
                senderWallet: null,
                customSenderName: currentWallet?.name ?? 'Wallet',
                customSenderCode: walletCode,
                customSenderSymbol: currentWallet?.symbol,
                recipientName: merchantDisplayName,
                recipientUid: merchantMid,
                recipientAvatar: matchedMerchant?.receiver?.avatar,
                isRecipientVerified: matchedMerchant?.receiver != null,
                fromLabel: l10nPick(
                  context,
                  en: 'From Wallet',
                  fa: 'کیف پول مبدأ',
                  ar: 'من المحفظة',
                ),
                toLabel: l10nPick(
                  context,
                  en: 'Merchant',
                  fa: 'پذیرنده',
                  ar: 'التاجر',
                ),
                identifierLabel: 'MID',
                formattedAmount: formattedAmount,
                currencyCode: walletCode,
              ),

              const SizedBox(height: AppSpacing.lg),

              // 2. Glassmorphic Review Breakdown Card
              EcardoGlassCard(
                variant: EcardoGlassVariant.frosted,
                interactive: false,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      context,
                      title: localization.makePaymentReviewStepSectionAmount,
                      content: "$formattedAmount $walletCode",
                      contentColor: isDark
                          ? AppColors.mainSoftBlue
                          : AppColors.deepBlack,
                      isBold: true,
                    ),
                    _buildDivider(colorScheme),
                    _buildSummaryRow(
                      context,
                      title: localization.makePaymentReviewStepSectionWallet,
                      content: currentWallet?.name ?? '—',
                      contentColor: colorScheme.onSurface,
                    ),
                    _buildDivider(colorScheme),
                    _buildSummaryRow(
                      context,
                      title:
                          localization.makePaymentReviewStepSectionMerchantAccount,
                      content: merchantMid,
                      contentColor: colorScheme.onSurface,
                    ),
                    _buildDivider(colorScheme),
                    _buildSummaryRow(
                      context,
                      title: localization.makePaymentReviewStepSectionCharge,
                      content: feeText,
                      contentColor: isFree
                          ? AppColors.success
                          : AppColors.warning,
                      isTag: isFree,
                    ),
                    _buildDivider(colorScheme),
                    _buildSummaryRow(
                      context,
                      title: l10nPick(
                        context,
                        en: 'Payment Settlement',
                        fa: 'تسویه پرداخت',
                        ar: 'تسوية الدفع',
                        tr: 'Ödeme Takası',
                        ru: 'Расчет оплаты',
                        zh: '付款结算',
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
                      title:
                          localization.makePaymentReviewStepSectionTotalAmount,
                      content: totalText,
                      contentColor: colorScheme.primary,
                      isHero: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Security Pill
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

              // 3. Modern Interactive Swipe Button with Step-up Security
              EcardoSwipeButton(
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
              const SizedBox(height: AppSpacing.md),

              // Secondary Back Button
              CommonButton(
                backgroundColor: Colors.transparent,
                borderWidth: 1.5,
                borderColor: colorScheme.outlineVariant.withValues(alpha: 0.5),
                textColor: colorScheme.onSurface.withValues(alpha: 0.8),
                borderRadius: AppSpacing.radiusLg,
                width: double.infinity,
                height: 48,
                text: localization.makePaymentReviewStepSectionBackButton,
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
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: isHero
                    ? FontWeight.w900
                    : isBold
                    ? FontWeight.w800
                    : FontWeight.w700,
                fontSize: isHero ? 17 : 14,
                color: contentColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
