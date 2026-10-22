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
import 'package:ecardo_user/src/presentation/screens/make_payment/controller/make_payment_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/widgets/transfer_success_celebration.dart';

class MakePaymentSuccessStepSection extends StatefulWidget {
  const MakePaymentSuccessStepSection({super.key});

  @override
  State<MakePaymentSuccessStepSection> createState() =>
      _MakePaymentSuccessStepSectionState();
}

class _MakePaymentSuccessStepSectionState
    extends State<MakePaymentSuccessStepSection> {
  final MakePaymentController controller = Get.find();
  final settingsService = Get.find<SettingsService>();
  double totalAmount = 0.0;

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
  void initState() {
    super.initState();
    totalCalculate();
  }

  void totalCalculate() {
    final amountRaw =
        controller.successPaymentData.value?["transaction"]?["amount"];
    final chargeRaw =
        controller.successPaymentData.value?["transaction"]?["charge"];

    double amount = double.tryParse(amountRaw.toString()) ?? 0.0;
    double charge = double.tryParse(chargeRaw.toString()) ?? 0.0;

    totalAmount = amount + charge;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentWallet = controller.wallet.value;
    final walletCode = currentWallet?.code ?? 'USD';

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: walletCode,
      siteCurrencyCode: settingsService.getSetting("site_currency") ?? 'USD',
      siteCurrencyDecimals:
          settingsService.getSetting("site_currency_decimals") ?? '2',
      isCrypto: currentWallet?.isCrypto ?? false,
    );

    final txData = controller.successPaymentData.value?["transaction"];
    final rawAmount = txData?["amount"] ?? controller.amountController.text;
    final amount = double.tryParse(rawAmount.toString()) ?? 0.0;
    final rawCharge = txData?["charge"];
    final chargeVal =
        double.tryParse(rawCharge?.toString() ?? '0') ??
        controller.charge.value;

    final tnxId = _nonEmpty(txData?["tnx"]?.toString());
    final createdAt = txData?["created_at"]?.toString() ?? '';
    final merchantMid = controller.merchantMidController.text.trim();

    return Obx(
      () => controller.isMakePaymentLoading.value
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
                      title: localization.makePaymentSuccessStepSectionTitle,
                      subtitle: l10nPick(
                        context,
                        en: 'Payment successfully processed',
                        fa: 'پرداخت به پذیرنده با موفقیت انجام شد',
                        ar: 'تمت معالجة الدفع بنجاح',
                        tr: 'Ödeme başarıyla işlendi',
                        ru: 'Оплата успешно проведена',
                        zh: '向商户付款已成功处理',
                      ),
                      dateTime: createdAt.isNotEmpty ? createdAt : null,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 2. Ultra-Premium Digital Receipt (Design System)
                    EcardoDigitalReceipt(
                      title: l10nPick(
                        context,
                        en: 'Merchant Payment Receipt',
                        fa: 'رسید پرداخت به پذیرنده',
                        ar: 'إيصال دفع التاجر',
                        tr: 'Üye İşyeri Ödeme Makbuzu',
                        ru: 'Квитанция оплаты мерчанту',
                        zh: '商户付款凭证',
                      ),
                      transactionReference: tnxId,
                      formattedTimestamp: createdAt.isNotEmpty
                          ? createdAt
                          : null,
                      primaryAmount: amount,
                      primaryCurrency: walletCode,
                      primaryDecimals: calculateDecimals,
                      status: EcardoReceiptStatus.success,
                      items: [
                        EcardoReceiptItem(
                          label: l10nPick(
                            context,
                            en: 'Merchant Account',
                            fa: 'حساب پذیرنده',
                            ar: 'حساب التاجر',
                            tr: 'Üye İşyeri Hesabı',
                            ru: 'Счет мерчанта',
                            zh: '商户账户',
                          ),
                          value: merchantMid,
                          isCopyable: true,
                          copyText: merchantMid,
                        ),
                        EcardoReceiptItem(
                          label: localization
                              .makePaymentSuccessStepSectionWalletName,
                          value: currentWallet?.name ?? 'Wallet',
                        ),
                        EcardoReceiptItem(
                          label: localization
                              .makePaymentSuccessStepSectionPaymentMethod,
                          value:
                              '$walletCode (${currentWallet?.name ?? "Wallet"})',
                        ),
                        EcardoReceiptItem(
                          label:
                              localization.makePaymentSuccessStepSectionCharge,
                          amount: chargeVal,
                          currency: walletCode,
                          decimals: calculateDecimals,
                        ),
                        EcardoReceiptItem(
                          label: localization
                              .makePaymentSuccessStepSectionFinalAmount,
                          amount: totalAmount > 0
                              ? totalAmount
                              : amount + chargeVal,
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
                        zh: '由 eCardo 安全网络支持',
                      ),
                      showBarcode: true,
                      showWatermark: true,
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // 3. Action Buttons
                    CommonButton(
                      text: localization
                          .makePaymentSuccessStepSectionBackHomeButton,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        controller.clearFields();
                        Get.find<HomeController>().loadData();
                        Get.offAllNamed(BaseRoute.navigation);
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
    );
  }
}
