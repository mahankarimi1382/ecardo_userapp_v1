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
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/controller/transfer_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/widgets/transfer_success_celebration.dart';

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

    final rawFinalAmount = senderTx?["final_amount"] ??
        controller.amountController.text;
    final amount = double.tryParse(rawFinalAmount.toString()) ?? 0.0;

    final tnxId = senderTx?["tnx"]?.toString() ?? 'TRX-ECAR-${DateTime.now().millisecondsSinceEpoch}';
    final createdAt = senderTx?["created_at"]?.toString() ?? '';
    final description = senderTx?["description"]?.toString() ?? '';
    final rawCharge = senderTx?["charge"];
    final chargeVal = double.tryParse(rawCharge?.toString() ?? '0') ?? controller.charge.value;

    final recipientAccount = controller.recipientUidController.text.trim();
    final matchedBeneficiary = controller.findBeneficiaryByAccount(recipientAccount);
    final recipientName = matchedBeneficiary?.nickname ??
        matchedBeneficiary?.receiver?.name ??
        recipientAccount;

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
                subtitle: 'Your money was successfully transferred',
                dateTime: createdAt.isNotEmpty ? createdAt : null,
              ),

              const SizedBox(height: AppSpacing.xl),

              // 2. Ultra-Premium Digital Receipt (Design System)
              EcardoDigitalReceipt(
                title: 'Transfer Receipt',
                transactionReference: tnxId,
                formattedTimestamp: createdAt.isNotEmpty ? createdAt : null,
                primaryAmount: amount,
                primaryCurrency: walletCode,
                primaryDecimals: calculateDecimals,
                status: EcardoReceiptStatus.success,
                items: [
                  EcardoReceiptItem(
                    label: localization.transferReviewStepSectionRecipientAccount,
                    value: recipientAccount,
                    isCopyable: true,
                    copyText: recipientAccount,
                  ),
                  EcardoReceiptItem(
                    label: 'From Wallet',
                    value: currentWallet?.name ?? 'Wallet',
                  ),
                  EcardoReceiptItem(
                    label: 'To',
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
                    label: 'Fee / Charge',
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
                    valueColor: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                  ),
                ],
                note: 'Powered by eCardo Secure Network',
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
                text: localization.transferSuccessStepSectionTransferAgainButton,
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
