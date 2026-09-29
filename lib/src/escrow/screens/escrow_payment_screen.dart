import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../controllers/escrow_controller.dart';
import '../models/escrow_models.dart';

class EscrowPaymentScreen extends StatefulWidget {
  final EscrowOrderModel order;

  const EscrowPaymentScreen({super.key, required this.order});

  @override
  State<EscrowPaymentScreen> createState() => _EscrowPaymentScreenState();
}

class _EscrowPaymentScreenState extends State<EscrowPaymentScreen> {
  final EscrowController controller = Get.find<EscrowController>();
  String _selectedMethod = 'wallet';

  void _handlePay() async {
    final ok = await controller.payIntoEscrow(widget.order.id);
    if (ok) {
      Get.back();
      Get.snackbar(
        l10nPick(context, fa: 'پرداخت موفق', en: 'Payment Success'),
        l10nPick(context, fa: 'وجه با موفقیت به حساب امانی واریز گردید.', en: 'Funds deposited into escrow successfully.'),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deal = widget.order;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          l10nPick(context, fa: 'پرداخت به حساب امانی', en: 'Pay into Escrow'),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.lightTextPrimary),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Summary Card
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    '${deal.totalEscrowAmount.toStringAsFixed(0)} ${deal.currency}',
                    style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.amber.shade900),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    l10nPick(context, fa: 'مبلغ قابل پرداخت جهت قفل در حساب امانی', en: 'Total Amount to Deposit in Escrow'),
                    style: TextStyle(fontSize: 11.sp, color: Colors.amber.shade800),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('مبلغ کالا: ${deal.amount.toStringAsFixed(0)} ${deal.currency}', style: TextStyle(fontSize: 11.sp)),
                      Text('کارمزد امانی: ${deal.feeAmount.toStringAsFixed(0)} ${deal.currency}', style: TextStyle(fontSize: 11.sp)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            Text(
              l10nPick(context, fa: 'انتخاب منبع پرداخت:', en: 'Choose Payment Source:'),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),

            // Wallet Radio
            RadioListTile<String>(
              value: 'wallet',
              groupValue: _selectedMethod,
              activeColor: AppColors.lightPrimary,
              title: Text(l10nPick(context, fa: 'کیف پول eCardo (کسر مستقیم)', en: 'eCardo Wallet (Instant)')),
              subtitle: Text(l10nPick(context, fa: 'پرداخت امن و بدون کارمزد بانکی', en: 'No gateway fees')),
              onChanged: (v) => setState(() => _selectedMethod = v!),
            ),

            // Gateway Radio
            RadioListTile<String>(
              value: 'gateway',
              groupValue: _selectedMethod,
              activeColor: AppColors.lightPrimary,
              title: Text(l10nPick(context, fa: 'درگاه پرداخت اینترنتی بانکی', en: 'Online Bank Gateway')),
              subtitle: Text(l10nPick(context, fa: 'پرداخت با کلیه کارت‌های عضو شتاب', en: 'All debit/credit cards')),
              onChanged: (v) => setState(() => _selectedMethod = v!),
            ),

            const Spacer(),

            // Guarantee Notice
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16.r)),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: Colors.blue.shade700, size: 24.w),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      l10nPick(
                        context,
                        fa: 'تضمین صد درصدی پلتفرم: وجه واریزی تا زمان تایید رضایت شما از کالا، هرگز به فروشنده تحویل داده نخواهد شد.',
                        en: '100% Platform Guarantee: Funds will never be released until your full satisfaction.',
                      ),
                      style: TextStyle(fontSize: 10.sp, color: Colors.blue.shade900, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Submit Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                    onPressed: controller.isActionLoading.value ? null : _handlePay,
                    child: controller.isActionLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            l10nPick(context, fa: 'تایید و واریز به حساب امانی', en: 'Confirm & Deposit'),
                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}