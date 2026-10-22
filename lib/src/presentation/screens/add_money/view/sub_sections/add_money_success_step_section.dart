import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/route_return.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/add_money/controller/add_money_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/widgets/transfer_success_celebration.dart';

class AddMoneySuccessStepSection extends StatefulWidget {
  const AddMoneySuccessStepSection({super.key});

  @override
  State<AddMoneySuccessStepSection> createState() =>
      _AddMoneySuccessStepSectionState();
}

class _AddMoneySuccessStepSectionState
    extends State<AddMoneySuccessStepSection> {
  final AddMoneyController controller = Get.find();
  final SettingsService settingsService = Get.find();

  /// Trimmed value, or null when the backend did not supply one. Never
  /// synthesize a reference — a fabricated ID on a receipt is indistinguishable
  /// from a real one and misleads both the user and support.
  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty || trimmed == 'null')
        ? null
        : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentWallet = controller.wallet.value;
    final payCurrency = (controller.successPaymentData.value?["pay_currency"] ?? currentWallet?.code ?? "USD").toString();

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: currentWallet?.code ?? 'USD',
      siteCurrencyCode: settingsService.getSetting("site_currency") ?? 'USD',
      siteCurrencyDecimals: settingsService.getSetting(
        "site_currency_decimals",
      ) ?? '2',
      isCrypto: currentWallet?.isCrypto ?? false,
    );

    final rawAmount = controller.successPaymentData.value?["amount"] ?? controller.amountController.text;
    final amount = double.tryParse(rawAmount.toString()) ?? 0.0;
    final rawCharge = controller.successPaymentData.value?["charge"];
    final chargeVal = double.tryParse(rawCharge?.toString() ?? '0') ?? 0.0;
    final tnxId = _nonEmpty(controller.successPaymentData.value?["tnx"]?.toString());
    final txType = controller.successPaymentData.value?["type"]?.toString() ?? 'Deposit';

    return Obx(
      () => controller.isPaymentLoading.value
          ? const CommonLoading()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),

                    // 1. Celebratory Success Animation
                    TransferSuccessCelebration(
                      title: localization.addMoneySuccessTitle,
                      subtitle: l10nPick(
                        context,
                        en: 'Deposit completed successfully',
                        fa: 'افزایش موجودی با موفقیت انجام شد',
                        ar: 'تم شحن الرصيد بنجاح',
                        tr: 'Para yatırma işlemi başarıyla tamamlandı',
                        ru: 'Пополнение успешно выполнено',
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 2. Ultra-Premium Digital Receipt (Design System)
                    EcardoDigitalReceipt(
                      title: l10nPick(
                        context,
                        en: 'Deposit Receipt',
                        fa: 'رسید افزایش موجودی',
                        ar: 'إيصال الإيداع',
                        tr: 'Yatırma Makbuzu',
                        ru: 'Квитанция пополнения',
                      ),
                      transactionReference: tnxId,
                      primaryAmount: amount,
                      primaryCurrency: payCurrency,
                      primaryDecimals: calculateDecimals,
                      status: EcardoReceiptStatus.success,
                      items: [
                        EcardoReceiptItem(
                          label: l10nPick(
                            context,
                            en: 'Wallet Name',
                            fa: 'نام کیف پول',
                            ar: 'اسم المحفظة',
                            tr: 'Cüzdan Adı',
                            ru: 'Название кошелька',
                          ),
                          value: currentWallet?.name ?? 'Wallet',
                        ),
                        EcardoReceiptItem(
                          label: l10nPick(
                            context,
                            en: 'Payment Method',
                            fa: 'روش پرداخت',
                            ar: 'طريقة الدفع',
                            tr: 'Ödeme Yöntemi',
                            ru: 'Способ оплаты',
                          ),
                          value: controller.gatewayMethod.value?.formattedName ?? payCurrency,
                        ),
                        EcardoReceiptItem(
                          label: localization.addMoneySuccessTransactionType,
                          value: txType,
                        ),
                        EcardoReceiptItem(
                          label: localization.addMoneySuccessCharge,
                          amount: chargeVal,
                          currency: payCurrency,
                          decimals: calculateDecimals,
                        ),
                        EcardoReceiptItem(
                          label: localization.addMoneySuccessFinalAmount,
                          amount: amount + chargeVal,
                          currency: payCurrency,
                          decimals: calculateDecimals,
                          isHighlighted: true,
                          valueColor: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
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
                        controller.isLoading.value = true;
                        await controller.fetchWallets();
                        controller.isLoading.value = false;
                      },
                      width: double.infinity,
                      text: localization.addMoneySuccessAddMoneyAgain,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CommonButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        Get.delete<AddMoneyController>();
                        RouteReturn.complete();
                        await Get.find<HomeController>().loadData();
                      },
                      width: double.infinity,
                      text: localization.addMoneySuccessBackHome,
                      backgroundColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightPrimary.withValues(alpha: 0.06),
                      borderColor: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightPrimary.withValues(alpha: 0.25),
                      textColor: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightPrimary,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
    );
  }
}
