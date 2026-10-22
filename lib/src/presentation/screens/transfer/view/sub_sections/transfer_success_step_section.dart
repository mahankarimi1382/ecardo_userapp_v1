import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/controller/transfer_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/widgets/transfer_success_celebration.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/widgets/withdraw_destination_card.dart';

class TransferSuccessStepSection extends StatefulWidget {
  const TransferSuccessStepSection({super.key});

  @override
  State<TransferSuccessStepSection> createState() =>
      _TransferSuccessStepSectionState();
}

class _TransferSuccessStepSectionState
    extends State<TransferSuccessStepSection> {
  final TransferController controller = Get.find();
  final settingsService = Get.find<SettingsService>();

  /// Returns the trimmed value, or null when the backend did not supply one.
  /// Never synthesize a reference — a fabricated ID on a receipt is
  /// indistinguishable from a real one and misleads support and the user.
  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty || trimmed == 'null')
        ? null
        : trimmed;
  }

  @override
  Widget build(BuildContext context) {
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

    final senderTx =
        controller.successTransferData.value?["sender_transaction"];

    final rawFinalAmount =
        senderTx?["final_amount"] ?? controller.amountController.text;
    final amount = double.tryParse(rawFinalAmount.toString()) ?? 0.0;

    final tnxId = _nonEmpty(senderTx?["tnx"]?.toString());
    final createdAt = senderTx?["created_at"]?.toString() ?? '';
    final description = senderTx?["description"]?.toString() ?? '';
    final rawCharge = senderTx?["charge"];
    final chargeVal =
        double.tryParse(rawCharge?.toString() ?? '0') ??
        controller.charge.value;

    final recipientAccount = controller.recipientUidController.text.trim();
    final maskedRecipientAccount = WithdrawDestinationCard.maskAccountNumber(
      recipientAccount,
    );
    final matchedBeneficiary = controller.findBeneficiaryByAccount(
      recipientAccount,
    );
    final recipientName =
        matchedBeneficiary?.nickname ??
        matchedBeneficiary?.receiver?.name ??
        (maskedRecipientAccount.isNotEmpty
            ? maskedRecipientAccount
            : recipientAccount);

    final senderAccount =
        currentWallet?.accountNo?.trim() ??
        senderTx?["account_number"]?.toString().trim() ??
        senderTx?["from_wallet"]?.toString().trim() ??
        '';
    final maskedSenderAccount = senderAccount.isNotEmpty
        ? WithdrawDestinationCard.maskAccountNumber(senderAccount)
        : null;

    return Obx(() {
      if (controller.isTransferAmountLoading.value) {
        return const CommonLoading();
      }

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),

              // 1. Celebratory Success Animation
              TransferSuccessCelebration(
                title: localization.transferSuccessStepSectionTitle,
                subtitle: l10nPick(
                  context,
                  en: 'Your money was successfully transferred',
                  fa: 'انتقال وجه با موفقیت انجام شد',
                  ar: 'تم تحويل أموالك بنجاح',
                  tr: 'Paranız başarıyla transfer edildi',
                  ru: 'Средства успешно переведены',
                ),
                dateTime: createdAt.isNotEmpty ? createdAt : null,
              ),

              const SizedBox(height: AppSpacing.xl),

              // 2. Ultra-Premium Digital Receipt (Design System)
              EcardoDigitalReceipt(
                title: l10nPick(
                  context,
                  en: 'Transfer Receipt',
                  fa: 'رسید انتقال وجه',
                  ar: 'إيصال التحويل',
                  tr: 'Transfer Makbuzu',
                  ru: 'Квитанция перевода',
                ),
                transactionReference: tnxId,
                formattedTimestamp: createdAt.isNotEmpty ? createdAt : null,
                primaryAmount: amount,
                primaryCurrency: walletCode,
                primaryDecimals: calculateDecimals,
                status: EcardoReceiptStatus.success,
                items: [
                  EcardoReceiptItem(
                    label:
                        localization.transferReviewStepSectionRecipientAccount,
                    value: maskedRecipientAccount.isNotEmpty
                        ? maskedRecipientAccount
                        : recipientAccount,
                    isCopyable: true,
                    copyText: recipientAccount,
                  ),
                  EcardoReceiptItem(
                    label: l10nPick(
                      context,
                      en: 'From Wallet',
                      fa: 'از کیف پول',
                      ar: 'من المحفظة',
                      tr: 'Cüzdandan',
                      ru: 'Из кошелька',
                    ),
                    value:
                        maskedSenderAccount != null &&
                            maskedSenderAccount.isNotEmpty
                        ? '${currentWallet?.name ?? "Wallet"} ($maskedSenderAccount)'
                        : (currentWallet?.name ?? 'Wallet'),
                  ),
                  if (maskedSenderAccount != null &&
                      maskedSenderAccount.isNotEmpty)
                    EcardoReceiptItem(
                      label: l10nPick(
                        context,
                        en: 'Sender Account',
                        fa: 'حساب مبدأ',
                        ar: 'حساب المرسل',
                        tr: 'Gönderen Hesap',
                        ru: 'Счет отправителя',
                      ),
                      value: maskedSenderAccount,
                    ),
                  EcardoReceiptItem(
                    label: l10nPick(
                      context,
                      en: 'To',
                      fa: 'گیرنده',
                      ar: 'إلى',
                      tr: 'Alıcı',
                      ru: 'Получатель',
                    ),
                    value: recipientName,
                  ),
                  EcardoReceiptItem(
                    label: localization.transferSuccessStepSectionPaymentMethod,
                    value: '$walletCode (${currentWallet?.name ?? "Wallet"})',
                  ),
                  if (description.isNotEmpty)
                    EcardoReceiptItem(
                      label: localization.transferSuccessStepSectionName,
                      value: description,
                    ),
                  EcardoReceiptItem(
                    label: l10nPick(
                      context,
                      en: 'Fee / Charge',
                      fa: 'کارمزد انتقال',
                      ar: 'الرسوم',
                      tr: 'Ücret',
                      ru: 'Комиссия',
                    ),
                    amount: chargeVal,
                    currency: walletCode,
                    decimals: calculateDecimals,
                  ),
                  EcardoReceiptItem(
                    label: localization.transferSuccessStepSectionTotalAmount,
                    amount: amount + chargeVal,
                    currency: walletCode,
                    decimals: calculateDecimals,
                    isHighlighted: true,
                    valueColor: isDark
                        ? AppColors.mainSoftBlue
                        : AppColors.deepBlack,
                  ),
                ],
                note: l10nPick(
                  context,
                  en: 'Powered by eCardo Secure Network',
                  fa: 'پردازش‌شده توسط شبکه امن اکاردو',
                  ar: 'مشغل بواسطة شبكة إيكاردو الآمنة',
                  tr: 'eCardo Güvenli Ağı Tarafından Desteklenmektedir',
                  ru: 'На базе защищенной сети eCardo',
                ),
                showBarcode: true,
                showWatermark: true,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // 3. Action Buttons
              CommonButton(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  controller.currentStep.value = 0;
                  controller.clearFields();
                  controller.fetchTransferWallets();
                },
                borderRadius: AppSpacing.radiusLg,
                width: double.infinity,
                height: 52,
                text:
                    localization.transferSuccessStepSectionTransferAgainButton,
              ),
              const SizedBox(height: AppSpacing.md),
              CommonButton(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  Get.find<HomeController>().selectedIndex.value = 0;
                  Get.toNamed(BaseRoute.navigation);
                  await Get.find<HomeController>().loadData();
                },
                borderRadius: AppSpacing.radiusLg,
                width: double.infinity,
                height: 50,
                text: localization.transferSuccessStepSectionBackHomeButton,
                backgroundColor: isDark
                    ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.5)
                    : colorScheme.primary.withValues(alpha: 0.06),
                borderColor: isDark
                    ? colorScheme.outlineVariant.withValues(alpha: 0.4)
                    : colorScheme.primary.withValues(alpha: 0.2),
                borderWidth: 1.5,
                textColor: colorScheme.onSurface,
              ),

              const SizedBox(height: AppSpacing.huge),
            ],
          ),
        ),
      );
    });
  }
}
