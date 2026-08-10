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
    final controller = Get.find<RemittanceController>();

    return Obx(() {
      final quote = controller.currentQuote.value;
      final method = controller.selectedMethod.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Confirm',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please review all details before submitting your remittance request.',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.lightTextSecondary,
            ),
          ),
          SizedBox(height: 20.h),

          // Quote summary
          _ReviewCard(
            title: 'Transfer Details',
            children: [
              _ReviewRow(
                label: 'Payout Method',
                value: method?.name ?? '-',
              ),
              _ReviewRow(
                label: 'Send Amount',
                value: quote?.sendAmount.toStringAsFixed(2) ?? '-',
              ),
              _ReviewRow(
                label: 'Exchange Rate',
                value: quote != null
                    ? '1 = ${quote.exchangeRate.toStringAsFixed(4)}'
                    : '-',
              ),
              _ReviewRow(
                label: 'Receive Amount',
                value: quote?.receiveAmount.toStringAsFixed(2) ?? '-',
              ),
              _ReviewRow(
                label: 'System Fee',
                value: quote?.systemFee.toStringAsFixed(2) ?? '-',
              ),
              _ReviewRow(
                label: 'Total Payable',
                value: quote?.totalPayable.toStringAsFixed(2) ?? '-',
                isBold: true,
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Sender info
          _ReviewCard(
            title: 'Sender',
            children: [
              _ReviewRow(
                label: 'Name',
                value: controller.senderNameController.text,
              ),
              _ReviewRow(
                label: 'Country',
                value: controller.selectedSenderCountry.value.toUpperCase(),
              ),
              _ReviewRow(
                label: 'Phone',
                value: controller.senderPhoneController.text,
              ),
              _ReviewRow(
                label: 'ID Number',
                value: controller.senderIdNumberController.text,
              ),
              _ReviewRow(
                label: 'Type',
                value: controller.selectedSenderType.value ==
                        'individual'
                    ? 'Individual'
                    : 'Business',
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Receiver info
          _ReviewCard(
            title: 'Receiver',
            children: [
              _ReviewRow(
                label: 'Name',
                value: controller.receiverNameController.text,
              ),
              _ReviewRow(
                label: 'Country',
                value: controller.selectedReceiverCountry.value.toUpperCase(),
              ),
              _ReviewRow(
                label: 'Phone',
                value: controller.receiverPhoneController.text,
              ),
              if (controller.receiverBankNameController.text.isNotEmpty)
                _ReviewRow(
                  label: 'Bank',
                  value: controller.receiverBankNameController.text,
                ),
              if (controller.receiverAccountNumberController.text.isNotEmpty)
                _ReviewRow(
                  label: 'Account',
                  value: controller.receiverAccountNumberController.text,
                ),
              if (controller.receiverIbanController.text.isNotEmpty)
                _ReviewRow(
                  label: 'IBAN',
                  value: controller.receiverIbanController.text,
                ),
              if (controller.receiverAlipayController.text.isNotEmpty)
                _ReviewRow(
                  label: 'Alipay',
                  value: controller.receiverAlipayController.text,
                ),
              if (controller.receiverWechatController.text.isNotEmpty)
                _ReviewRow(
                  label: 'WeChat',
                  value: controller.receiverWechatController.text,
                ),
            ],
          ),

          SizedBox(height: 20.h),
          // Terms notice
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    color: Colors.amber[800], size: 18.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'By submitting, you agree to our remittance terms. The rate is locked for 15 minutes. You will need to upload KYC documents and payment receipt after submission.',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.amber[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _ReviewCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ReviewCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _ReviewRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.lightTextSecondary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.lightTextPrimary,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
