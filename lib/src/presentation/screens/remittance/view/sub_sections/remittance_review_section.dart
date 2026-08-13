import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';

/// Step 4: Review all details before submitting.
class RemittanceReviewSection extends StatelessWidget {
  const RemittanceReviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RemittanceController>();
    return Obx(() {
      final q = c.currentQuote.value;
      final m = c.selectedMethod.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review & Confirm', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary)),
          SizedBox(height: 8.h),
          Text('Please review all details before submitting your remittance request.', style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary)),
          SizedBox(height: 20.h),
          _Card('Transfer Details', [
            _Row('Payout Method', m?.name ?? '-'),
            _Row('Send Amount', q?.sendAmount.toStringAsFixed(2) ?? '-'),
            _Row('Exchange Rate', q != null ? '1 = ${q.exchangeRate.toStringAsFixed(4)}' : '-'),
            _Row('Receive Amount', q?.receiveAmount.toStringAsFixed(2) ?? '-'),
            _Row('System Fee', q?.systemFee.toStringAsFixed(2) ?? '-'),
            _Row('Total Payable', q?.totalPayable.toStringAsFixed(2) ?? '-', bold: true),
          ]),
          SizedBox(height: 16.h),
          _Card('Sender', [
            _Row('Name', c.senderNameController.text),
            _Row('Country', c.selectedSenderCountry.value.toUpperCase()),
            _Row('Phone', c.senderPhoneController.text),
            _Row('ID Number', c.senderIdNumberController.text),
            _Row('Type', c.selectedSenderType.value == 'individual' ? 'Individual' : 'Business'),
          ]),
          SizedBox(height: 16.h),
          _Card('Receiver', [
            _Row('Name', c.receiverNameController.text),
            _Row('Country', c.selectedReceiverCountry.value.toUpperCase()),
            _Row('Phone', c.receiverPhoneController.text),
            if (c.receiverBankNameController.text.isNotEmpty) _Row('Bank', c.receiverBankNameController.text),
            if (c.receiverAccountNumberController.text.isNotEmpty) _Row('Account', c.receiverAccountNumberController.text),
            if (c.receiverIbanController.text.isNotEmpty) _Row('IBAN', c.receiverIbanController.text),
            if (c.receiverAlipayController.text.isNotEmpty) _Row('Alipay', c.receiverAlipayController.text),
            if (c.receiverWechatController.text.isNotEmpty) _Row('WeChat', c.receiverWechatController.text),
          ]),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: AppColors.warningContainer, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.warning.withValues(alpha: 0.3))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline, color: AppColors.warning, size: 18.sp),
              SizedBox(width: 8.w),
              Expanded(child: Text('By submitting, you agree to our remittance terms. The rate is locked for 15 minutes. You will need to upload KYC documents and payment receipt after submission.', style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextPrimary))),
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
