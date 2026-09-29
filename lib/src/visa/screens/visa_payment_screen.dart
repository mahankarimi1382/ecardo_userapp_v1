import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../helper/l10n_pick.dart';
import '../controllers/visa_controller.dart';
import '../models/visa_models.dart';
import '../widgets/visa_widgets.dart';
import 'visa_detail_screen.dart';

class VisaPaymentScreen extends StatelessWidget {
  final VisaRequestModel request;

  const VisaPaymentScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<VisaController>()
        ? Get.find<VisaController>()
        : Get.put(VisaController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          l10nPick(context, en: 'Visa Payment', fa: 'پرداخت هزینه ویزا'),
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final isPaying = controller.isPaying.value;

        return Stack(
          children: [
            ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              children: [
                // Case & Destination Summary
                VisaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              VisaCountryFlag(flagUrl: request.countryFlag, size: 36),
                              SizedBox(width: 10.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request.countryName,
                                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    request.visaTitle,
                                    style: TextStyle(fontSize: 11.5.sp, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          VisaStatusBadge(status: request.status),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10nPick(context, en: 'Case Tracking No.', fa: 'شماره پیگیری پرونده:'),
                            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
                          ),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              request.caseNo,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF7445FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10nPick(context, en: 'Applicant Name:', fa: 'نام متقاضی:'),
                            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
                          ),
                          Text(
                            request.applicantName,
                            style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Payment Breakdown Card (Two clear rows)
                VisaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(context, en: 'Fee Breakdown', fa: 'ریز هزینه‌های قابل پرداخت'),
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 14.h),

                      // Row 1: Service Fee
                      _costItem(
                        context,
                        title: l10nPick(context, en: '1. Platform Service Fee', fa: '۱. هزینه خدمات و کارشناسی پلتفرم'),
                        subtitle: l10nPick(context, en: 'Application audit, translation check, and tracking', fa: 'بررسی مدارک، فرم‌بندی و پیگیری اختصاصی'),
                        amount: '\$${request.serviceFee.toStringAsFixed(2)}',
                      ),
                      const Divider(height: 24),

                      // Row 2: Gov Fee
                      _costItem(
                        context,
                        title: l10nPick(context, en: '2. Embassy & Government Fee', fa: '۲. هزینه رسمی دولتی و سفارت'),
                        subtitle: l10nPick(context, en: 'Official immigration authority fee for issuance', fa: 'تعرفه مستقیم مراجع مهاجرتی کشور مقصد'),
                        amount: '\$${request.govFee.toStringAsFixed(2)}',
                      ),
                      const Divider(height: 24),

                      // Total Row
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10nPick(context, en: 'Total Amount to Pay:', fa: 'کل مبلغ قابل پرداخت:'),
                              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              '\$${request.totalFee.toStringAsFixed(2)} ${request.currency}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF7445FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Payment Method Card
                VisaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(context, en: 'Payment Method', fa: 'روش پرداخت'),
                        style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFF7445FF), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEFEDFF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF7445FF)),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10nPick(context, en: 'eCardo Multi-Currency Wallet', fa: 'کیف پول ارزی eCardo'),
                                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    l10nPick(context, en: 'Instant debit with double-entry ledger lock', fa: 'کسر آنی و مطمئن با ضمانت استرداد'),
                                    style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF7445FF)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Security & Refund Policy Note
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.security_rounded, color: Color(0xFF059669), size: 20),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            en: 'Protection Guarantee: If documents are rejected during our consultant pre-review, your payment will be refunded 100% to your wallet.',
                            fa: 'ضمانت بازگشت وجه: در صورت عدم تأیید مدارک در مرحله پیش‌بررسی کارشناسان، وجه پرداختی به طور کامل به کیف پول شما مسترد خواهد شد.',
                          ),
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: const Color(0xFF065F46),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),

            if (isPaying)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      }),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () async {
              final ok = await controller.payForRequest(request.caseNo);
              if (ok) {
                Get.off(() => VisaDetailScreen(caseNo: request.caseNo));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7445FF),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8.w),
                Text(
                  '${l10nPick(context, en: 'Pay', fa: 'پرداخت')} \$${request.totalFee.toStringAsFixed(2)} ${request.currency}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _costItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String amount,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
        ),
      ],
    );
  }
}
