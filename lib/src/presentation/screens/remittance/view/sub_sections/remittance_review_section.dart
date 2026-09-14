import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';

/// Step 4: Review all details before submitting.
class RemittanceReviewSection extends StatelessWidget {
  const RemittanceReviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RemittanceController>();
    final l = AppLocalizations.of(context)!;
    return Obx(() {
      final q = c.currentQuote.value;
      final m = c.selectedMethod.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.remittanceReviewConfirm, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary)),
          SizedBox(height: 8.h),
          Text(l.remittanceReviewHint, style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary)),
          SizedBox(height: 20.h),
          _Card(l.remittancePayoutDetails, [
            _Row(l.remittanceSelectPayoutMethod, m?.name ?? '-'),
            // M-7 — decimals now come from DynamicDecimalsHelper via the
            // controller (API-driven); falls back to 2 like before.
            _Row(l.remittanceSendAmount, q == null ? '-' : c.formatAmount(q.sendAmount, currencyId: q.sendCurrencyId)),
            _Row(l.remittanceExchangeRate, q != null ? '1 = ${q.exchangeRate.toStringAsFixed(4)}' : '-'), // TODO(lead): exchange-rate precision is not exposed by the quote API — 4 kept as-is.
            _Row(l.remittanceReceiveAmount, q == null ? '-' : c.formatAmount(q.receiveAmount, currencyId: q.receiveCurrencyId)),
            _Row(l.remittanceSystemFee, q == null ? '-' : c.formatAmount(q.systemFee, currencyId: q.sendCurrencyId)),
            _Row(l.remittanceTotalPayable, q == null ? '-' : c.formatAmount(q.totalPayable, currencyId: q.sendCurrencyId), bold: true),
          ]),
          SizedBox(height: 16.h),
          _Card(l.remittanceReviewSender, [
            _Row(l.remittanceSenderName, c.senderNameController.text),
            _Row(l.remittanceSelectCountry, c.selectedSenderCountry.value.toUpperCase()),
            _Row(l.remittanceSenderPhone, c.senderPhoneController.text),
            _Row(l.remittanceSenderIdNumber, c.senderIdNumberController.text),
            _Row(l.remittanceSenderTypeIndividual, c.selectedSenderType.value == 'individual' ? l.remittanceSenderTypeIndividual : l.remittanceSenderTypeBusiness),
          ]),
          SizedBox(height: 16.h),
          _Card(l.remittanceReviewReceiver, [
            _Row(l.remittanceReceiverName, c.receiverNameController.text),
            _Row(l.remittanceSelectCountry, c.selectedReceiverCountry.value.toUpperCase()),
            _Row(l.remittanceReceiverPhone, c.receiverPhoneController.text),
            if (c.receiverBankNameController.text.isNotEmpty) _Row(l.remittanceBankName, c.receiverBankNameController.text),
            if (c.receiverAccountNumberController.text.isNotEmpty) _Row(l.remittanceAccountNumber, c.receiverAccountNumberController.text),
            if (c.receiverIbanController.text.isNotEmpty) _Row(l.remittanceIban, c.receiverIbanController.text),
            if (c.receiverAlipayController.text.isNotEmpty) _Row(l.remittanceAlipayAccount, c.receiverAlipayController.text),
            if (c.receiverWechatController.text.isNotEmpty) _Row(l.remittanceWechatAccount, c.receiverWechatController.text),
            // Task-12 — dynamic payout-method fields (swift / shaba_number /
            // usdt_address / card_number and any future mapped fields) are
            // now shown on the review step so the user can verify the
            // payout details before submitting.
            for (final field in c.selectedMethodFields) ...[
              Builder(builder: (_) {
                final ctl = c.methodFieldController(field.name);
                final value = ctl?.text.trim() ?? '';
                if (value.isEmpty) return const SizedBox.shrink();
                return _Row(c.localizedFieldLabel(field), value);
              }),
            ],
          ]),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: AppColors.warningContainer, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.warning.withValues(alpha: 0.3))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline, color: AppColors.warning, size: 18.sp),
              SizedBox(width: 8.w),
              Expanded(child: Text(l.remittanceTermsNotice, style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextPrimary))),
            ]),
          ),
        ],
      );
    });
  }
}

class _Card extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Card(this.title, this.children);

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(color: AppColors.lightSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary)),
          SizedBox(height: 12.h),
          ...children,
        ]),
      );
}

class _Row extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _Row(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary)),
          SizedBox(width: 12.w),
          Expanded(child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextPrimary, fontWeight: bold ? FontWeight.w700 : FontWeight.w500))),
        ]),
      );
}
