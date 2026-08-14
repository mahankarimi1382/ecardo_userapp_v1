import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/model/remittance_model.dart';

/// Step 1: Select payout method + enter amount + see quote.
class RemittanceMethodSection extends StatelessWidget {
  const RemittanceMethodSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RemittanceController>();
    final l = AppLocalizations.of(context)!;

    return Obx(() {
      if (controller.methods.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Text(
              l.remittanceNoMethods,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 14.sp,
              ),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.remittanceSelectPayoutMethod,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          ...controller.methods.map((m) => _MethodCard(
                method: m,
                isSelected: controller.selectedMethod.value?.id == m.id,
                onTap: () => controller.selectMethod(m),
                unknownLabel: l.remittanceUnknownMethod,
              )),
          SizedBox(height: 24.h),
          Text(
            l.remittanceSendAmount,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          CommonTextInputField(
            controller: controller.amountController,
            focusNode: controller.amountFocusNode,
            hintText: l.remittanceEnterAmount,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(() {
            final q = controller.currentQuote.value;
            if (q == null) return const SizedBox.shrink();
            return _QuotePreview(quote: q, controller: controller, l: l);
          }),
        ],
      );
    });
  }
}

class _MethodCard extends StatelessWidget {
  final RemittanceMethod method;
  final bool isSelected;
  final VoidCallback onTap;
  final String unknownLabel;
  const _MethodCard({required this.method, required this.isSelected, required this.onTap, required this.unknownLabel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightPrimaryContainer : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.lightPrimary : AppColors.lightBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w, height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.lightPrimaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.account_balance, color: AppColors.lightPrimary, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.name ?? unknownLabel,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
                  if (method.countryCode != null) ...[
                    SizedBox(height: 2.h),
                    Text(method.countryCode!.toUpperCase(),
                        style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary)),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.lightPrimary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}

class _QuotePreview extends StatelessWidget {
  final dynamic quote;
  final RemittanceController controller;
  final AppLocalizations l;
  const _QuotePreview({required this.quote, required this.controller, required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.lightPrimaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightPrimary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.lock_clock, color: AppColors.lightPrimary, size: 16.sp),
            SizedBox(width: 6.w),
            Obx(() => Text(l.remittanceRateLocked(controller.rateExpiresInSeconds.value),
                style: TextStyle(fontSize: 12.sp, color: AppColors.lightPrimary, fontWeight: FontWeight.w600))),
          ]),
          SizedBox(height: 12.h),
          _Row(l.remittanceExchangeRate, '1 = ${quote.exchangeRate.toStringAsFixed(4)}'),
          SizedBox(height: 6.h),
          _Row(l.remittanceReceiveAmount, quote.receiveAmount.toStringAsFixed(2)),
          SizedBox(height: 6.h),
          _Row(l.remittanceSystemFee, quote.systemFee.toStringAsFixed(2)),
          SizedBox(height: 8.h),
          Divider(color: AppColors.lightBorder, height: 1),
          SizedBox(height: 8.h),
          _Row(l.remittanceTotalPayable, quote.totalPayable.toStringAsFixed(2), bold: true),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _Row(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, color: AppColors.lightTextSecondary, fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
        Text(value, style: TextStyle(fontSize: 13.sp, color: AppColors.lightTextPrimary, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
      ],
    );
  }
}
