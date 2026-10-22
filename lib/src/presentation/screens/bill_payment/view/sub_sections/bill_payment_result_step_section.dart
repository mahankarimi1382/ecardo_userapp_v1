import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/app_event_bus.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/widgets/transfer_success_celebration.dart';

/// Neo-Fintech Bill Payment Result Step with Celebration & Digital Receipt.
class BillPaymentResultStepSection extends StatefulWidget {
  const BillPaymentResultStepSection({
    super.key,
    required this.result,
    required this.amountLabel,
    required this.amountValue,
    required this.chargeLabel,
    required this.chargeValue,
    required this.payableLabel,
    required this.payableValue,
    required this.statusLabel,
    required this.historyButtonLabel,
    required this.closeButtonLabel,
    required this.onClose,
  });

  /// Raw backend response body of the last successful pay-bill call
  final Map<String, dynamic>? result;

  final String amountLabel;
  final String amountValue;
  final String chargeLabel;
  final String chargeValue;
  final String payableLabel;
  final String payableValue;
  final String statusLabel;
  final String historyButtonLabel;
  final String closeButtonLabel;
  final VoidCallback onClose;

  @override
  State<BillPaymentResultStepSection> createState() =>
      _BillPaymentResultStepSectionState();
}

class _BillPaymentResultStepSectionState
    extends State<BillPaymentResultStepSection> {
  @override
  void initState() {
    super.initState();
    // Auto-refresh balances and transactions on completion
    AppEventBus.emit(BalanceChangedEvent(sourceModule: 'bill_payment'));
  }

  String? get _headline {
    final message = widget.result?['message']?.toString();
    return (message == null || message.isEmpty) ? null : message;
  }

  String? get _statusText {
    final data = widget.result?['data'];
    if (data is Map) {
      final status = data['status']?.toString();
      if (status != null && status.isNotEmpty && status != 'null') {
        return status;
      }
    }
    return null;
  }

  /// Backend reference, or null when the gateway response did not carry one.
  /// Null renders the receipt's localized "awaiting server reference" state —
  /// never fabricate an ID that support would treat as real.
  String? get _referenceCode {
    final data = widget.result?['data'];
    if (data is Map) {
      final tnx = data['tnx'] ?? data['transaction_id'] ?? data['id'];
      final trimmed = tnx?.toString().trim();
      if (trimmed != null && trimmed.isNotEmpty && trimmed != 'null') {
        return trimmed;
      }
    }
    return null;
  }

  EcardoReceiptStatus get _receiptStatus {
    final status = _statusText?.toLowerCase() ?? '';
    if (status.contains('fail') || status.contains('reject')) {
      return EcardoReceiptStatus.failed;
    }
    if (status.contains('pend') || status.contains('process')) {
      return EcardoReceiptStatus.pending;
    }
    return EcardoReceiptStatus.success;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final title = _headline ??
        l10nPick(
          context,
          en: 'Bill Payment Submitted',
          fa: 'پرداخت قبض با موفقیت ثبت شد',
          ar: 'تم تقديم دفع الفاتورة بنجاح',
          tr: 'Fatura ödemesi gönderildi',
          ru: 'Оплата счета зарегистрирована',
          zh: '账单支付已提交',
        );

    final subtitle = l10nPick(
      context,
      en: 'Your utility payment request has been processed securely.',
      fa: 'درخواست پرداخت قبض شما با موفقیت در سیستم پردازش شد.',
      ar: 'تمت معالجة طلب سداد الفاتورة بأمان.',
      tr: 'Fatura ödeme talebiniz güvenle işlendi.',
      ru: 'Ваш платеж успешно обработан.',
      zh: '您的账单支付请求已安全处理。',
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),

            // 1. Celebratory Success Animation
            TransferSuccessCelebration(
              title: title,
              subtitle: subtitle,
            ),

            const SizedBox(height: AppSpacing.xl),

            // 2. Ultra-Premium Digital Receipt (Design System)
            EcardoDigitalReceipt(
              title: l10nPick(
                context,
                en: 'Bill Payment Receipt',
                fa: 'رسید پرداخت قبوض',
                ar: 'إيصال دفع الفاتورة',
                tr: 'Fatura Ödeme Makbuzu',
                ru: 'Квитанция оплаты счета',
                zh: '账单支付凭证',
              ),
              transactionReference: _referenceCode,
              status: _receiptStatus,
              items: [
                EcardoReceiptItem(
                  label: widget.amountLabel,
                  value: widget.amountValue,
                ),
                EcardoReceiptItem(
                  label: widget.chargeLabel,
                  value: widget.chargeValue,
                ),
                EcardoReceiptItem(
                  label: widget.payableLabel,
                  value: widget.payableValue,
                  isHighlighted: true,
                  valueColor: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                ),
                if (_statusText != null)
                  EcardoReceiptItem(
                    label: widget.statusLabel,
                    value: _statusText!,
                    valueColor: _receiptStatus == EcardoReceiptStatus.success
                        ? AppColors.success
                        : AppColors.warning,
                  ),
              ],
              note: l10nPick(
                context,
                en: 'Authoritative status is recorded in your Bill Payment History.',
                fa: 'وضعیت تسویه نهایی در تاریخچه پرداخت قبوض قابل رهگیری است.',
                ar: 'يتم تسجيل الحالة المعتمدة في سجل دفع الفواتير.',
                tr: 'Nihai durum Fatura Ödeme Geçmişinizde kaydedilir.',
                ru: 'Окончательный статус отображается в истории платежей.',
                zh: '最终状态记录在您的账单支付历史记录中。',
              ),
              showBarcode: true,
              showWatermark: true,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // 3. Action Buttons
            CommonButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Get.toNamed(BaseRoute.billPaymentHistory);
              },
              borderRadius: AppSpacing.radiusLg,
              width: double.infinity,
              height: 52,
              text: widget.historyButtonLabel,
            ),
            const SizedBox(height: AppSpacing.md),
            CommonButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onClose();
              },
              borderRadius: AppSpacing.radiusLg,
              width: double.infinity,
              height: 50,
              text: widget.closeButtonLabel,
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
  }
}
