import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../helper/l10n_pick.dart';
import '../controllers/visa_controller.dart';
import '../models/visa_models.dart';
import '../widgets/visa_widgets.dart';

class VisaResultScreen extends StatelessWidget {
  final VisaRequestModel request;

  const VisaResultScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<VisaController>()
        ? Get.find<VisaController>()
        : Get.put(VisaController());

    final isApproved = request.isApproved;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          isApproved
              ? l10nPick(context, en: 'E-Visa Issued', fa: 'ویزای الکترونیک صادر شد')
              : l10nPick(context, en: 'Visa Application Decision', fa: 'نتیجه بررسی درخواست ویزا'),
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
          if (isApproved)
            _buildApprovedSection(context, controller)
          else
            _buildRejectedSection(context, controller),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildApprovedSection(BuildContext context, VisaController controller) {
    return Column(
      children: [
        // Congratulatory Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: const LinearGradient(
              colors: [Color(0xFF0F9D58), Color(0xFF34A853)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF0F9D58), size: 40),
              ),
              SizedBox(height: 12.h),
              Text(
                l10nPick(context, en: 'Congratulations!', fa: 'تبریک! ویزای شما صادر گردید'),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              SizedBox(height: 4.h),
              Text(
                l10nPick(
                  context,
                  en: 'Your electronic visa has been officially approved and issued by the immigration authority.',
                  fa: 'ویزای الکترونیک شما توسط مرجع قانونی صادر و در سیستم ثبت شده است.',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5.sp, color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // E-Visa Certificate Card
        VisaCard(
          border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
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
                      Text(
                        request.countryName,
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      l10nPick(context, en: 'VALID E-VISA', fa: 'معتبر'),
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w900, color: const Color(0xFF16A34A)),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              _certRow(l10nPick(context, en: 'Beneficiary Name:', fa: 'نام دارنده ویزا:'), request.applicantName),
              _certRow(l10nPick(context, en: 'Passport Number:', fa: 'شماره گذرنامه:'), request.applicantPassport),
              _certRow(l10nPick(context, en: 'Visa Title:', fa: 'عنوان ویزا:'), request.visaTitle),
              _certRow(l10nPick(context, en: 'Case Reference:', fa: 'شماره پرونده:'), request.caseNo),
              if (request.deliveredAt != null)
                _certRow(l10nPick(context, en: 'Issued Date:', fa: 'تاریخ صدور:'), request.deliveredAt!.split('T').first),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Download Button
        ElevatedButton.icon(
          onPressed: () async {
            if (request.evisaFilePath != null && request.evisaFilePath!.isNotEmpty) {
              final uri = Uri.parse(request.evisaFilePath!);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10nPick(context, en: 'Downloading official PDF...', fa: 'در حال آماده‌سازی و دانلود فایل PDF ویزا...'),
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F9D58),
            minimumSize: Size(double.infinity, 50.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            elevation: 0,
          ),
          icon: const Icon(Icons.download_rounded, color: Colors.white),
          label: Text(
            l10nPick(context, en: 'Download Official E-Visa (PDF)', fa: 'دانلود فایل ویزا الکترونیک (PDF)'),
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
        SizedBox(height: 12.h),

        // Confirm Delivery Button
        if (request.status != 'DELIVERED')
          OutlinedButton(
            onPressed: () async {
              await controller.confirmDelivery(request.caseNo);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F9D58),
              side: const BorderSide(color: Color(0xFF0F9D58)),
              minimumSize: Size(double.infinity, 46.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
            ),
            child: Text(
              l10nPick(context, en: 'Confirm Delivery', fa: 'تأیید نهایی دریافت ویزا'),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
            ),
          ),
        SizedBox(height: 20.h),

        // Important Travel Reminders
        VisaCard(
          color: const Color(0xFFF0FDF4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10nPick(context, en: 'Travel Reminders', fa: 'توصیه‌های مهم سفر'),
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: const Color(0xFF166534)),
              ),
              SizedBox(height: 8.h),
              _reminderItem(l10nPick(context, en: 'Please print a physical copy of this E-Visa to present at airport immigration check-in.', fa: 'لطفاً یک نسخه چاپی رنگی از این ویزا را هنگام تحویل بار در فرودگاه به همراه داشته باشید.')),
              _reminderItem(l10nPick(context, en: 'Ensure your passport is the exact one submitted in this application and has at least 6 months validity.', fa: 'اطمینان حاصل فرمایید گذرنامه همراه شما دقیقاً منطبق بر مشخصات ثبت‌شده در این ویزا باشد.')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRejectedSection(BuildContext context, VisaController controller) {
    return Column(
      children: [
        // Rejection Header Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            color: const Color(0xFFFEE2E2),
            border: Border.all(color: const Color(0xFFFCA5A5)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.highlight_off_rounded, color: Color(0xFFDC2626), size: 40),
              ),
              SizedBox(height: 12.h),
              Text(
                l10nPick(context, en: 'Application Not Approved', fa: 'عدم موافقت با صدور ویزا'),
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w900, color: const Color(0xFF991B1B)),
              ),
              SizedBox(height: 6.h),
              Text(
                l10nPick(
                  context,
                  en: 'The immigration authority has declined this visa request.',
                  fa: 'متأسفانه اداره مهاجرت کشور مقصد با صدور این درخواست موافقت نکرده است.',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF7F1D1D)),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Rejection Reason Detail Card
        VisaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10nPick(context, en: 'Official Refusal Explanation', fa: 'علت و شرح عدم صدور'),
                style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 10.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  request.rejectionReason != null && request.rejectionReason!.isNotEmpty
                      ? request.rejectionReason!
                      : l10nPick(
                          context,
                          en: 'Refusal by immigration department guidelines. No further public details provided by the authority.',
                          fa: 'رد درخواست بر اساس ضوابط امنیتی یا مدارک ناقص اداره مهاجرت کشور مقصد اعلام شده است.',
                        ),
                  style: TextStyle(fontSize: 12.5.sp, color: const Color(0xFF334155), height: 1.4),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Refund Policy Breakdown
        VisaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10nPick(context, en: 'Refund Statement', fa: 'وضعیت استرداد وجه'),
                style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 10.h),
              Text(
                l10nPick(
                  context,
                  en: 'Per international visa rules, official government & embassy fees paid to authorities are strictly non-refundable once processed. Platform service guarantees apply as per agreement.',
                  fa: 'مطابق مقررات بین‌المللی کنسولی، هزینه‌های دولتی ویزا پس از ثبت در مرجع غیرقابل استرداد است. خدمات بررسی اولیه طبق تعهدات بیمه ویزا بررسی خواهد شد.',
                ),
                style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF64748B), height: 1.35),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),

        // Appeal / Support Button
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10nPick(
                    context,
                    en: 'An expert visa consultant has been assigned to your case ticket.',
                    fa: 'درخواست بازبینی شما به کارشناس ارشد ویزا ارجاع شد.',
                  ),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7445FF),
            minimumSize: Size(double.infinity, 48.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          ),
          icon: const Icon(Icons.support_agent_rounded, color: Colors.white),
          label: Text(
            l10nPick(context, en: 'Contact Visa Specialist / Appeal', fa: 'ثبت درخواست تجدیدنظر / تماس با کارشناس'),
            style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _certRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B))),
          Text(value, style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _reminderItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF16A34A)),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF166534), height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
