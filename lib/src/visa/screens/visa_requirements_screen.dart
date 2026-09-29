import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../helper/l10n_pick.dart';
import '../models/visa_models.dart';
import '../widgets/visa_widgets.dart';
import 'visa_application_screen.dart';

class VisaRequirementsScreen extends StatelessWidget {
  final VisaCatalogItem item;

  const VisaRequirementsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          item.countryName,
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
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        children: [
          // Visa Header Card
          VisaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    VisaCountryFlag(flagUrl: item.countryFlag, size: 44),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${l10nPick(context, en: 'Visa Type', fa: 'نوع ویزا')}: ${item.visaType}',
                            style: TextStyle(fontSize: 11.5.sp, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (item.description.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: const Color(0xFF475569),
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Pricing & Breakdown Card
          VisaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(context, en: 'Fee Breakdown', fa: 'تعرفه و هزینه‌های ویزا'),
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 12.h),
                _priceRow(
                  title: l10nPick(context, en: 'Platform Service Fee', fa: 'هزینه خدمات و بررسی کارشناسی'),
                  amount: '\$${item.serviceFee.toStringAsFixed(2)}',
                  subtitle: l10nPick(context, en: 'Application prep & consultant audit', fa: 'تشکیل پرونده و اعتبارسنجی مدارک'),
                ),
                const Divider(height: 20),
                _priceRow(
                  title: l10nPick(context, en: 'Government & Embassy Fee', fa: 'هزینه رسمی دولتی و صدور مرجع'),
                  amount: '\$${item.govFee.toStringAsFixed(2)}',
                  subtitle: l10nPick(context, en: 'Non-refundable after embassy submission', fa: 'تعرفه قانونی سفارت / اداره مهاجرت'),
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10nPick(context, en: 'Total Amount', fa: 'کل مبلغ پرداختی'),
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      '\$${item.totalFee.toStringAsFixed(2)} ${item.currency}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF7445FF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Required Documents Checklist
          VisaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.fact_check_outlined, color: Color(0xFF7445FF), size: 20),
                    SizedBox(width: 8.w),
                    Text(
                      l10nPick(context, en: 'Required Documents', fa: 'مدارک و پیش‌نیازهای الزامی'),
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                if (item.requiredDocs.isEmpty)
                  Text(
                    l10nPick(context, en: 'Passport scan is required.', fa: 'اسکن پاسپورت با حداقل ۶ ماه اعتبار الزامی است.'),
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  )
                else
                  ...item.requiredDocs.map((doc) => _DocRequirementTile(doc: doc)),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Policy & Rules Card
          VisaCard(
            color: const Color(0xFFF9FAFB),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(context, en: 'Important Guidelines', fa: 'نکات و قوانین مهم'),
                  style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 10.h),
                _bulletPoint(
                  icon: Icons.access_time_rounded,
                  text: '${l10nPick(context, en: 'Estimated Processing Time', fa: 'مدت‌زمان تقریبی صدور')}: ${item.processingDaysMin} ${l10nPick(context, en: 'to', fa: 'تا')} ${item.processingDaysMax} ${l10nPick(context, en: 'business days', fa: 'روز کاری')}',
                ),
                SizedBox(height: 6.h),
                _bulletPoint(
                  icon: Icons.fingerprint_rounded,
                  text: item.needsBiometric
                      ? l10nPick(context, en: 'Biometric appointment is required in person.', fa: 'نیاز به انگشت‌نگاری و حضور در سفارت دارد.')
                      : l10nPick(context, en: '100% online E-Visa, no in-person visit needed.', fa: 'صدور کاملاً آنلاین (E-Visa) بدون نیاز به مراجعه حضوری.'),
                ),
                SizedBox(height: 6.h),
                _bulletPoint(
                  icon: Icons.verified_user_outlined,
                  text: l10nPick(
                    context,
                    en: 'Document revisions allowed up to 3 times before final embassy filing.',
                    fa: 'امکان تا ۳ بار اصلاح و تکمیل مدارک بدون هزینه اضافی.',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30.h),
        ],
      ),
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
            onPressed: () {
              Get.to(() => VisaApplicationScreen(catalog: item));
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
                Text(
                  l10nPick(context, en: 'Start Application', fa: 'شروع درخواست ویزا'),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8.w),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _priceRow({required String title, required String amount, required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(fontSize: 10.5.sp, color: const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
        ),
      ],
    );
  }

  Widget _bulletPoint({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.r, color: const Color(0xFF7445FF)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF334155), height: 1.3),
          ),
        ),
      ],
    );
  }
}

class _DocRequirementTile extends StatelessWidget {
  final VisaRequiredDoc doc;

  const _DocRequirementTile({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: const Icon(Icons.attach_file_rounded, size: 16, color: Color(0xFF475569)),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      doc.title,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    if (doc.required) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          l10nPick(context, en: 'Required', fa: 'الزامی'),
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: const Color(0xFFDC2626),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (doc.instructions.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    doc.instructions,
                    style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
