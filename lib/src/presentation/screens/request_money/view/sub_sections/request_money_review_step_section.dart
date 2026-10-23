import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/services/biometric_auth_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/passcode_helper.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/controller/request_money_controller.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/transaction_pin/transaction_pin_screen.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/widgets/transfer_path_card.dart';
import 'package:ecardo_user/src/presentation/widgets/verify_passcode_bottom_sheet.dart';

class RequestMoneyReviewStepSection extends StatefulWidget {
  const RequestMoneyReviewStepSection({super.key});

  @override
  State<RequestMoneyReviewStepSection> createState() =>
      _RequestMoneyReviewStepSectionState();
}

class _RequestMoneyReviewStepSectionState
    extends State<RequestMoneyReviewStepSection> {
  final GlobalKey<EcardoSwipeButtonState> _swipeKey =
      GlobalKey<EcardoSwipeButtonState>();

  Future<void> _handleConfirmRequest(BuildContext context) async {
    final RequestMoneyController controller = Get.find();
    if (controller.isRequestMoneyLoading.value) return;

    HapticFeedback.lightImpact();

    final bioReason = l10nPick(
      context,
      en: 'Authenticate to confirm request money',
      fa: 'جهت تأیید ارسال درخواست پول احراز هویت کنید',
      ar: 'التحقق لتأكيد طلب المال',
      tr: 'Para talebini onaylamak için doğrulama yapın',
      ru: 'Подтвердите личность для запроса средств',
      zh: '请进行身份验证以确认收款请求',
    );

    final dialogTitle = l10nPick(
      context,
      fa: 'تعیین رمز تأیید (رمز دوم)',
      en: 'Set Transaction PIN',
      ar: 'تعيين رمز الأمان (PIN)',
    );
    final dialogMiddle = l10nPick(
      context,
      fa: 'برای امنیت حساب و انجام تراکنش‌های درخواست پول، ابتدا باید رمز تراکنش خود را تعیین فرمایید.',
      en: 'For security, you must set a 4 to 6 digit transaction PIN before requesting money.',
      ar: 'للأمان، يجب تعيين رمز أمان التحويل أولاً قبل إتمام العملية.',
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
          controller.requestMoney();
          return;
        }
      }
    } catch (_) {
      // Fallback to passcode prompt
    }

    final bool isPasscodeEnabled =
        Get.find<SettingsService>().getSetting(
          "request_money_accept_passcode_status",
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
      controller.requestMoney();
    } else {
      controller.requestMoney();
    }
  }

  @override
  Widget build(BuildContext context) {
    final RequestMoneyController controller = Get.find();
    final settingsService = Get.find<SettingsService>();
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

    final amountNum =
        double.tryParse(controller.requestAmountController.text) ?? 0.0;
    final formattedAmount = amountNum.toStringAsFixed(calculateDecimals);
    final recipientUid = controller.recipientUidController.text.trim();
    final noteText = controller.noteController.text.trim();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Text(
              localization.requestMoneyReviewStepSectionTitle,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                letterSpacing: -0.2,
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 1. Standardized Visual Transfer Route Card (Payer UID --> My Wallet)
            TransferPathCard(
              senderWallet: null,
              customSenderName: 'Payer',
              customSenderCode: '',
              customSenderSymbol: 'P',
              recipientName: currentWallet?.name ?? 'Wallet',
              recipientUid: walletCode,
              fromLabel: l10nPick(
                context,
                en: 'Requested From',
                fa: 'درخواست از',
                ar: 'طلب من',
              ),
              toLabel: l10nPick(
                context,
                en: 'Receiving Wallet',
                fa: 'کیف پول مقصد',
                ar: 'محفظة الاستلام',
              ),
              identifierLabel: 'UID',
              formattedAmount: formattedAmount,
              currencyCode: walletCode,
            ),

            const SizedBox(height: AppSpacing.lg),

            // 2. Glassmorphic Review Card
            EcardoGlassCard(
              variant: EcardoGlassVariant.frosted,
              interactive: false,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  _buildSummaryRow(
                    context,
                    title: localization.requestMoneyReviewStepSectionAmount,
                    content: "$formattedAmount $walletCode",
                    contentColor: isDark
                        ? AppColors.mainSoftBlue
                        : AppColors.deepBlack,
                    isBold: true,
                  ),
                  _buildDivider(colorScheme),
                  _buildSummaryRow(
                    context,
                    title: localization.requestMoneyReviewStepSectionWalletName,
                    content: currentWallet?.name ?? '—',
                    contentColor: colorScheme.onSurface,
                  ),
                  _buildDivider(colorScheme),
                  _buildSummaryRow(
                    context,
                    title: localization.requestMoneyReviewStepSectionRecipientUid,
                    content: recipientUid,
                    contentColor: colorScheme.onSurface,
                  ),
                  if (noteText.isNotEmpty) ...[
                    _buildDivider(colorScheme),
                    _buildSummaryRow(
                      context,
                      title: l10nPick(
                        context,
                        en: 'Note',
                        fa: 'یادداشت',
                        ar: 'ملاحظة',
                      ),
                      content: noteText,
                      contentColor: colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ],
                  _buildDivider(colorScheme),
                  _buildSummaryRow(
                    context,
                    title: l10nPick(
                      context,
                      en: 'Settlement',
                      fa: 'نوع تسویه',
                      ar: 'التسوية',
                      tr: 'Takas',
                      ru: 'Расчет',
                      zh: '结算',
                    ),
                    content: l10nPick(
                      context,
                      en: 'Upon Payer Approval ⚡',
                      fa: 'پس از تایید پرداخت‌کننده ⚡',
                      ar: 'عند موافقة الدافع ⚡',
                      tr: 'Ödeyen Onayından Sonra ⚡',
                      ru: 'После подтверждения плательщиком ⚡',
                      zh: '付款人确认后 ⚡',
                    ),
                    contentColor: AppColors.success,
                  ),
                  _buildDivider(colorScheme),
                  _buildSummaryRow(
                    context,
                    title: l10nPick(
                      context,
                      en: 'Total Requested',
                      fa: 'مبلغ کل درخواستی',
                      ar: 'إجمالي المبلغ المطلوب',
                    ),
                    content: "$formattedAmount $walletCode",
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

            // 3. Modern Interactive Swipe Button with Step-up Security
            Obx(
              () => EcardoSwipeButton(
                key: _swipeKey,
                text: l10nPick(
                  context,
                  en: 'Slide to confirm request',
                  fa: 'برای تأیید و ارسال درخواست بکشید',
                  ar: 'اسحب لتأكيد الطلب',
                  tr: 'Talebi onaylamak için kaydırın',
                  ru: 'Проведите для подтверждения запроса',
                  zh: '滑动以确认请求',
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
                  en: 'Request Sent',
                  fa: 'درخواست ارسال شد',
                  ar: 'تم إرسال الطلب',
                  tr: 'Talep Gönderildi',
                  ru: 'Запрос отправлен',
                  zh: '请求已发送',
                ),
                isLoading: controller.isRequestMoneyLoading.value,
                onSwipeComplete: () => _handleConfirmRequest(context),
              ),
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
              text: localization.requestMoneyReviewStepSectionBackButton,
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
