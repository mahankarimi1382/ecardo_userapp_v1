import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
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
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/cash_out/controller/cash_out_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/widgets/transfer_success_celebration.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/widgets/withdraw_step_indicator.dart';

class CashOutSuccessStepSection extends StatefulWidget {
  const CashOutSuccessStepSection({super.key});

  @override
  State<CashOutSuccessStepSection> createState() =>
      _CashOutSuccessStepSectionState();
}

class _CashOutSuccessStepSectionState extends State<CashOutSuccessStepSection> {
  /// Trimmed value, or null when the backend did not supply one. Never
  /// synthesize a reference — a fabricated ID on a receipt is indistinguishable
  /// from a real one and misleads both the user and support.
  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty || trimmed == 'null')
        ? null
        : trimmed;
  }

  final CashOutController controller = Get.find();
  final settingsService = Get.find<SettingsService>();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final wallet = controller.wallet.value;
    final currency = wallet?.code ?? "USD";

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: currency,
      siteCurrencyCode: settingsService.getSetting("site_currency") ?? 'USD',
      siteCurrencyDecimals:
          settingsService.getSetting("site_currency_decimals") ?? '2',
      isCrypto: wallet?.isCrypto ?? false,
    );

    final rawAmount =
        controller.successCashOutData.value?["final_amount"] ??
        controller.amountController.text;
    final amount = double.tryParse(rawAmount.toString()) ?? 0.0;

    final tnxId = _nonEmpty(
      controller.successCashOutData.value?["tnx"]?.toString(),
    );
    final createdAt =
        controller.successCashOutData.value?["created_at"]?.toString() ?? '';
    final rawCharge = controller.successCashOutData.value?["charge"];
    final chargeStr =
        (double.tryParse(rawCharge?.toString() ?? '0') ??
                controller.charge.value)
            .toStringAsFixed(calculateDecimals);
    final agentAid = controller.agentAidController.text.trim();

    return Obx(
      () => controller.isCashOutLoading.value
          ? const CommonLoading()
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                ),
                child: Column(
                  children: [
                    // Step Indicator (Completed: Step 2)
                    const WithdrawStepIndicator(currentStep: 2),

                    const SizedBox(height: AppSpacing.md),

                    // 1. Celebratory Success Animation Header
                    TransferSuccessCelebration(
                      title: localizations.cashOutSuccessTitle,
                      subtitle: l10nPick(
                        context,
                        en: 'Agent payout processed successfully',
                        fa: 'تسویه نقدی با نماینده با موفقیت انجام شد',
                        ar: 'تمت معالجة السحب النقدي بنجاح',
                        tr: 'Nakit çekim işlemi başarıyla tamamlandı',
                        ru: 'Выдача наличных успешно подтверждена',
                      ),
                      dateTime: createdAt.isNotEmpty ? createdAt : null,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 2. Ultra-Premium Digital Receipt (Design System)
                    EcardoDigitalReceipt(
                      title: l10nPick(
                        context,
                        en: 'Agent Cash-Out Receipt',
                        fa: 'رسید تسویه نقدی نماینده',
                        ar: 'إيصال السحب النقدي',
                        tr: 'Temsilci Nakit Çekim Makbuzu',
                        ru: 'Квитанция о выдаче наличных',
                      ),
                      transactionReference: tnxId,
                      formattedTimestamp: createdAt.isNotEmpty
                          ? createdAt
                          : null,
                      primaryAmount: amount,
                      primaryCurrency: currency,
                      primaryDecimals: calculateDecimals,
                      status: EcardoReceiptStatus.success,
                      note: l10nPick(
                        context,
                        en: 'Cash paid out directly by authorized eCardo agent.',
                        fa: 'مبلغ نقدی مستقیماً توسط نماینده مجاز اکاردو تحویل داده شد.',
                        ar: 'تم استلام المبلغ نقداً من وكيل إيكاردو المعتمد.',
                        tr: 'Nakit tutar yetkili temsilci tarafından teslim edildi.',
                        ru: 'Наличные выданы авторизованным агентом eCardo.',
                      ),
                      items: [
                        EcardoReceiptItem(
                          label: localizations.cashOutReviewAgentAccount,
                          value: 'AID: $agentAid',
                        ),
                        EcardoReceiptItem(
                          label: localizations.cashOutSuccessWalletName,
                          value: wallet?.name ?? '',
                        ),
                        EcardoReceiptItem(
                          label: localizations.cashOutSuccessCharge,
                          value: '$chargeStr $currency',
                          valueColor: AppColors.warning,
                        ),
                        EcardoReceiptItem(
                          label: localizations.cashOutSuccessFinalAmount,
                          value:
                              '${amount.toStringAsFixed(calculateDecimals)} $currency',
                          isHighlighted: true,
                          valueColor: AppColors.success,
                        ),
                        if (tnxId != null)
                          EcardoReceiptItem(
                            label: localizations.cashOutSuccessTransactionId,
                            value: tnxId,
                            isCopyable: true,
                            copyText: tnxId,
                          ),
                      ],
                      onShare: () {
                        HapticFeedback.lightImpact();
                        SharePlus.instance.share(
                          ShareParams(
                            text:
                                'eCardo Cash-Out Receipt\n${tnxId != null ? 'Ref: $tnxId\n' : ''}Amount: $amount $currency\nAgent: $agentAid\nStatus: Completed',
                          ),
                        );
                      },
                      onDownload: () {
                        if (tnxId == null) {
                          ToastHelper().showWarningToast(
                            l10nPick(
                              context,
                              en: 'Reference code is not available yet',
                              fa: 'کد پیگیری هنوز در دسترس نیست',
                              ar: 'رمز المرجع غير متوفر بعد',
                              tr: 'Referans kodu henüz mevcut değil',
                              ru: 'Код квитанции пока недоступен',
                              zh: '单号暂不可用',
                            ),
                          );
                          return;
                        }
                        HapticFeedback.lightImpact();
                        Clipboard.setData(ClipboardData(text: tnxId));
                        ToastHelper().showSuccessToast(
                          l10nPick(
                            context,
                            en: 'Transaction reference copied',
                            fa: 'شناسه تراکنش در کلیپ‌بورد کپی شد',
                            ar: 'تم نسخ رقم المرجع',
                            tr: 'İşlem referansı kopyalandı',
                            ru: 'Код транзакции скопирован',
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // 3. Action CTAs
                    CommonButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        controller.currentStep.value = 0;
                        controller.clearFields();
                        await controller.fetchWallets();
                      },
                      width: double.infinity,
                      text: localizations.cashOutSuccessCashOutAgain,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    CommonButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        Get.delete<CashOutController>();
                        await Get.find<HomeController>().loadData();
                        Get.toNamed(BaseRoute.navigation);
                      },
                      width: double.infinity,
                      text: localizations.cashOutSuccessBackHome,
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
