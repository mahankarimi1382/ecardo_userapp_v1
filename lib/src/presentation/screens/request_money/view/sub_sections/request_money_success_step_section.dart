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
import 'package:ecardo_user/src/presentation/screens/request_money/controller/request_money_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/widgets/transfer_success_celebration.dart';

class RequestMoneySuccessStepSection extends StatefulWidget {
  const RequestMoneySuccessStepSection({super.key});

  @override
  State<RequestMoneySuccessStepSection> createState() =>
      _RequestMoneySuccessStepSectionState();
}

class _RequestMoneySuccessStepSectionState
    extends State<RequestMoneySuccessStepSection> {
  final RequestMoneyController controller = Get.find();
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
    final walletCode = currentWallet?.code ?? 'USD';

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: walletCode,
      siteCurrencyCode: settingsService.getSetting("site_currency")!,
      siteCurrencyDecimals: settingsService.getSetting(
        "site_currency_decimals",
      )!,
      isCrypto: currentWallet?.isCrypto ?? false,
    );

    final dynamic requestData = controller.successPaymentData.value?["request"];
    final double successChargeValue =
        double.tryParse(requestData?["charge"]?.toString() ?? '') ?? 0.0;
    final double successFinalAmountValue =
        double.tryParse(requestData?["final_amount"]?.toString() ?? '') ?? 0.0;
    final double reqAmount =
        double.tryParse(controller.requestAmountController.text) ?? 0.0;

    final String recipientName =
        (requestData?["recipient"]?["name"] ?? controller.recipientUidController.text).toString();

    return Obx(
      () => controller.isRequestMoneyLoading.value
          ? const CommonLoading()
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),

                    // 1. Success Animation Header
                    TransferSuccessCelebration(
                      title: localization.requestMoneySuccessStepSectionTitle,
                      subtitle: l10nPick(
                        context,
                        en: 'Request sent to recipient',
                        fa: 'درخواست با موفقیت برای مخاطب ارسال شد',
                        ar: 'تم إرسال الطلب إلى المستلم',
                        tr: 'Talep alıcıya gönderildi',
                        ru: 'Запрос отправлен получателю',
                        zh: '请求已成功发送至对方',
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // 2. Modern Digital Receipt
                    EcardoDigitalReceipt(
                      title: l10nPick(
                        context,
                        en: 'Money Request Receipt',
                        fa: 'رسید درخواست وجه',
                        ar: 'إيصال طلب المال',
                        tr: 'Para Talebi Dekontu',
                        ru: 'Квитанция запроса средств',
                        zh: '收款请求凭证',
                      ),
                      // `MoneyRequestResource` exposes `id` (and no `tnx`); use
                      // the server id when present and show a pending label
                      // otherwise. Never invent a reference.
                      transactionReference: _nonEmpty(requestData?["tnx"]?.toString()) ??
                          _nonEmpty(requestData?["id"]?.toString()),
                      status: EcardoReceiptStatus.success,
                      items: [
                        EcardoReceiptItem(
                          label: localization.requestMoneySuccessStepSectionRecipientName,
                          value: recipientName,
                        ),
                        EcardoReceiptItem(
                          label: localization.requestMoneySuccessStepSectionRequestWalletName,
                          value: currentWallet?.name ?? walletCode,
                        ),
                        EcardoReceiptItem(
                          label: localization.requestMoneySuccessStepSectionAmount,
                          amount: reqAmount,
                          currency: walletCode,
                          decimals: calculateDecimals,
                        ),
                        EcardoReceiptItem(
                          label: localization.requestMoneySuccessStepSectionCharge,
                          amount: successChargeValue,
                          currency: walletCode,
                          decimals: calculateDecimals,
                        ),
                        EcardoReceiptItem(
                          label: localization.requestMoneySuccessStepSectionFinalAmount,
                          amount: successFinalAmountValue > 0
                              ? successFinalAmountValue
                              : reqAmount + successChargeValue,
                          currency: walletCode,
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
                        zh: '由 eCardo 安全网络支持',
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
                        await controller.fetchWallets();
                      },
                      width: double.infinity,
                      text: localization.requestMoneySuccessStepSectionRequestAgainButton,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CommonButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        Get.delete<RequestMoneyController>();
                        Get.toNamed(BaseRoute.navigation);
                        await Get.find<HomeController>().loadData();
                      },
                      width: double.infinity,
                      text: localization.requestMoneySuccessStepSectionBackHomeButton,
                      backgroundColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightPrimary.withValues(alpha: 0.06),
                      borderColor: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightPrimary.withValues(alpha: 0.60),
                      borderWidth: 1.5,
                      textColor: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    const SizedBox(height: AppSpacing.huge),
                  ],
                ),
              ),
            ),
    );
  }
}
