import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
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
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/widgets/transfer_success_celebration.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/controller/withdraw_controller.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/widgets/withdraw_destination_card.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/widgets/withdraw_step_indicator.dart';

class WithdrawSuccessStepSection extends StatefulWidget {
  const WithdrawSuccessStepSection({super.key});

  @override
  State<WithdrawSuccessStepSection> createState() =>
      _WithdrawSuccessStepSectionState();
}

class _WithdrawSuccessStepSectionState
    extends State<WithdrawSuccessStepSection> {
  final WithdrawController controller = Get.find();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedAccount = controller.withdrawAccount.value;
    final currency =
        controller.successWithdrawData.value?["transaction"]?["pay_currency"] ??
        selectedAccount?.currency ??
        "USD";
    final isCrypto = selectedAccount?.method?.isCrypto ?? false;

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: currency,
      siteCurrencyCode: Get.find<SettingsService>().getSetting(
        "site_currency",
      )!,
      siteCurrencyDecimals: Get.find<SettingsService>().getSetting(
        "site_currency_decimals",
      )!,
      isCrypto: isCrypto,
    );

    final rawAmount =
        controller.successWithdrawData.value?["transaction"]?["final_amount"] ??
        controller.amountController.text;
    final amount = double.tryParse(rawAmount.toString()) ?? 0.0;

    final tnxId = _nonEmpty(
      controller.successWithdrawData.value?["transaction"]?["tnx"]?.toString(),
    );
    final createdAt =
        controller.successWithdrawData.value?["transaction"]?["created_at"]
            ?.toString() ??
        '';
    final charge =
        (double.tryParse(
                  controller
                          .successWithdrawData
                          .value?["transaction"]?["charge"]
                          ?.toString() ??
                      "0",
                ) ??
                0.0)
            .toStringAsFixed(calculateDecimals);

    final destinationName = selectedAccount?.methodName ?? "Bank Account";
    final maskedDestination = WithdrawDestinationCard.maskAccountNumber(
      selectedAccount,
    );
    final settlementTime =
        selectedAccount?.method?.time ??
        l10nPick(
          context,
          en: 'Instant ⚡ (Paya next cycle)',
          fa: 'تسویه آنی ⚡ / پایا سیکل بعدی',
          ar: 'تسوية فورية ⚡ / بايا',
          tr: 'Anında ⚡ / Sonraki döngü',
          ru: 'Мгновенно ⚡ / след. цикл',
          zh: '即时 ⚡ / 下个结算周期',
        );

    final rawStatus =
        controller.successWithdrawData.value?["transaction"]?["status"]
            ?.toString()
            .toLowerCase() ??
        '';
    final receiptStatus =
        (rawStatus == '1' ||
            rawStatus.contains('success') ||
            rawStatus.contains('confirm'))
        ? EcardoReceiptStatus.success
        : EcardoReceiptStatus.pending;

    return Obx(
      () => controller.isWithdrawLoading.value
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
                      title: l10nPick(
                        context,
                        en: 'Withdrawal Request Submitted!',
                        fa: 'درخواست برداشت با موفقیت ثبت شد!',
                        ar: 'تم تقديم طلب السحب بنجاح!',
                        tr: 'Çekim Talebi Başarıyla Alındı!',
                        ru: 'Запрос на вывод успешно отправлен!',
                        zh: '提现请求已成功提交！',
                      ),
                      subtitle: l10nPick(
                        context,
                        en: 'Your payout is being processed according to the settlement schedule',
                        fa: 'مبلغ درخواستی طبق زمان‌بندی تسویه به حساب بانکی شما واریز خواهد شد',
                        ar: 'تتم معالجة السحب وفقاً لجدول التسوية',
                        tr: 'Çekiminiz takas takvimine göre işlenmektedir',
                        ru: 'Выплата обрабатывается по графику зачислений',
                        zh: '您的提现款项将根据结算时间表处理并到账',
                      ),
                      dateTime: createdAt.isNotEmpty ? createdAt : null,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 2. Ultra-Premium Digital Receipt (Design System)
                    EcardoDigitalReceipt(
                      title: l10nPick(
                        context,
                        en: 'Withdrawal Payout Receipt',
                        fa: 'رسید دیجیتال برداشت وجه',
                        ar: 'إيصال سحب الأموال',
                        tr: 'Para Çekme Makbuzu',
                        ru: 'Квитанция о выводе средств',
                        zh: '提现电子凭证',
                      ),
                      transactionReference: tnxId,
                      formattedTimestamp: createdAt.isNotEmpty
                          ? createdAt
                          : null,
                      primaryAmount: amount,
                      primaryCurrency: currency,
                      primaryDecimals: calculateDecimals,
                      status: receiptStatus,
                      note: l10nPick(
                        context,
                        en: 'Funds will be deposited to your destination account per banking network settlement.',
                        fa: 'مبلغ فوق از طریق سامانه پایا/شتاب به حساب ثبت‌شده واریز می‌گردد.',
                        ar: 'سيتم إيداع المبلغ في حسابك وفقاً لجدول التسوية المصرفية.',
                        tr: 'Tutar, banka takas sistemine göre hesabınıza aktarılacaktır.',
                        ru: 'Средства поступят на указанный счет согласно банковскому регламенту.',
                        zh: '款项将根据银行清算网络结算存入您的目标账户。',
                      ),
                      items: [
                        EcardoReceiptItem(
                          label: l10nPick(
                            context,
                            en: 'Destination Account',
                            fa: 'حساب مقصد',
                            ar: 'حساب الوجهة',
                            tr: 'Hedef Hesap',
                            ru: 'Счет назначения',
                            zh: '目标账户',
                          ),
                          value: '$destinationName ($maskedDestination)',
                        ),
                        EcardoReceiptItem(
                          label: l10nPick(
                            context,
                            en: 'Transfer Fee',
                            fa: 'کارمزد انتقال',
                            ar: 'رسوم التحويل',
                            tr: 'Transfer Ücreti',
                            ru: 'Комиссия',
                          ),
                          value: '$charge $currency',
                          valueColor: AppColors.warning,
                        ),
                        EcardoReceiptItem(
                          label: l10nPick(
                            context,
                            en: 'Net Payout to Bank',
                            fa: 'مبلغ خالص دریافتی',
                            ar: 'صافي المبلغ المستلم',
                            tr: 'Net Alınacak Tutar',
                            ru: 'Чистая сумма к зачислению',
                          ),
                          value:
                              '${amount.toStringAsFixed(calculateDecimals)} $currency',
                          isHighlighted: true,
                          valueColor: AppColors.success,
                        ),
                        EcardoReceiptItem(
                          label: l10nPick(
                            context,
                            en: 'Estimated Settlement',
                            fa: 'زمان تخمینی تسویه',
                            ar: 'وقت التسوية',
                            tr: 'Tahmini Takas',
                            ru: 'Время зачисления',
                          ),
                          value: settlementTime,
                        ),
                        if (tnxId != null)
                          EcardoReceiptItem(
                            label: l10nPick(
                              context,
                              en: 'Reference ID',
                              fa: 'کد پیگیری تراکنش',
                              ar: 'رقم المرجع',
                              tr: 'İşlem Referansı',
                              ru: 'Код транзакции',
                            ),
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
                                'eCardo Withdrawal Receipt\n${tnxId != null ? 'Ref: $tnxId\n' : ''}Amount: $amount $currency\nDestination: $destinationName\nStatus: Confirmed',
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
                              tr: 'Referans kodu هنوز mevcut değil',
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
                            en: 'Receipt Reference copied to clipboard',
                            fa: 'کد پیگیری رسید در کلیپ‌بورد کپی شد',
                            ar: 'تم نسخ رقم المرجع إلى الحافظة',
                            tr: 'Makbuz referansı kopyalandı',
                            ru: 'Код квитанции скопирован в буфер',
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // 3. Action CTAs
                    // Withdraw Again Button
                    CommonButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        controller.currentStep.value = 0;
                        controller.clearFields();
                      },
                      width: double.infinity,
                      text: l10nPick(
                        context,
                        en: 'New Withdrawal Request',
                        fa: 'ثبت درخواست برداشت جدید',
                        ar: 'طلب سحب جديد',
                        tr: 'Yeni Çekim Talebi',
                        ru: 'Новый вывод средств',
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Back to Dashboard CTA (Primary CTA)
                    CommonButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        Get.delete<WithdrawController>();
                        await Get.find<HomeController>().loadData();
                        Get.toNamed(BaseRoute.navigation);
                      },
                      width: double.infinity,
                      text: l10nPick(
                        context,
                        en: 'Back to Dashboard',
                        fa: 'بازگشت به داشبورد اصلی',
                        ar: 'العودة إلى لوحة التحكم',
                        tr: 'Ana Sayfaya Dön',
                        ru: 'Вернуться на главную',
                      ),
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
