import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_spacing.dart';
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isApproved = request.isApproved;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          isApproved
              ? l10nPick(context, en: 'E-Visa Issued', fa: 'ویزای الکترونیک صادر شد')
              : l10nPick(context, en: 'Visa Application Decision', fa: 'نتیجه بررسی درخواست ویزا'),
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            size: AppSpacing.iconSm.r,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg.w,
          vertical: AppSpacing.lg.h,
        ),
        children: [
          if (isApproved)
            _buildApprovedSection(context, controller, isDark)
          else
            _buildRejectedSection(context, controller, isDark),
          SizedBox(height: AppSpacing.xxxl.h),
        ],
      ),
    );
  }

  Widget _buildApprovedSection(BuildContext context, VisaController controller, bool isDark) {
    return Column(
      children: [
        // Congratulatory Header Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.xl.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
            gradient: const LinearGradient(
              colors: [AppColors.success, AppColors.mutedBlue],
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.md.r),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 40.r),
              ),
              SizedBox(height: AppSpacing.md.h),
              Text(
                l10nPick(context, en: 'Congratulations!', fa: 'تبریک! ویزای شما صادر گردید'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                ),
              ),
              SizedBox(height: AppSpacing.xs.h),
              Text(
                l10nPick(
                  context,
                  en: 'Your electronic visa has been officially approved and issued by the immigration authority.',
                  fa: 'ویزای الکترونیک شما توسط مرجع قانونی مهاجرت صادر شده و در سیستم ثبت گردید است.',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: AppColors.white.withValues(alpha: 0.92),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg.h),

        // E-Visa Certificate Card
        VisaCard(
          border: Border.all(color: AppColors.success, width: 1.5),
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      VisaCountryFlag(flagUrl: request.countryFlag, size: 36),
                      SizedBox(width: AppSpacing.sm.w),
                      Text(
                        request.countryName,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm.w, vertical: AppSpacing.xs.h),
                    decoration: BoxDecoration(
                      color: AppColors.successContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                    ),
                    child: Text(
                      l10nPick(context, en: 'VALID E-VISA', fa: 'معتبر'),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                height: AppSpacing.xxl,
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
              _certRow(context, l10nPick(context, en: 'Beneficiary Name:', fa: 'نام متقاضی:'), request.applicantName, isDark),
              _certRow(context, l10nPick(context, en: 'Passport Number:', fa: 'شماره گذرنامه:'), request.applicantPassport, isDark),
              _certRow(context, l10nPick(context, en: 'Visa Title:', fa: 'نوع ویزا:'), request.visaTitle, isDark),
              _certRow(context, l10nPick(context, en: 'Case Reference:', fa: 'شماره پرونده:'), request.caseNo, isDark),
              if (request.deliveredAt != null)
                _certRow(context, l10nPick(context, en: 'Issued Date:', fa: 'تاریخ صدور:'), request.deliveredAt!.split('T').first, isDark),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg.h),

        // Download / Open PDF Button
        ElevatedButton.icon(
          onPressed: () async {
            if (request.evisaFilePath != null && request.evisaFilePath!.isNotEmpty) {
              final path = request.evisaFilePath!;
              final file = File(path);
              if (await file.exists()) {
                await OpenFilex.open(file.path);
              } else {
                await OpenFilex.open(path);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10nPick(context, en: 'Preparing official PDF...', fa: 'در حال آماده‌سازی و دانلود فایل PDF ویزا...'),
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            minimumSize: Size(double.infinity, 50.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r)),
            elevation: 0,
          ),
          icon: Icon(Icons.download_rounded, color: AppColors.white, size: AppSpacing.iconSm.r),
          label: Text(
            l10nPick(context, en: 'Download Official E-Visa (PDF)', fa: 'دانلود فایل ویزا الکترونیک (PDF)'),
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppColors.white),
          ),
        ),
        SizedBox(height: AppSpacing.md.h),

        // Confirm Delivery Button
        if (request.status != 'DELIVERED')
          OutlinedButton(
            onPressed: () async {
              HapticFeedback.lightImpact();
              await controller.confirmDelivery(request.caseNo);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.success,
              side: const BorderSide(color: AppColors.success, width: 1.2),
              minimumSize: Size(double.infinity, 46.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
            ),
            child: Text(
              l10nPick(context, en: 'Confirm Delivery', fa: 'تأیید دریافت نهایی ویزا'),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
            ),
          ),
        SizedBox(height: AppSpacing.xl.h),

        // Important Travel Reminders
        VisaCard(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.successContainer.withValues(alpha: 0.6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10nPick(context, en: 'Travel Reminders', fa: 'توصیه‌های مهم سفر'),
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: AppColors.success),
              ),
              SizedBox(height: AppSpacing.sm.h),
              _reminderItem(
                l10nPick(
                  context,
                  en: 'Please print a physical copy of this E-Visa to present at airport immigration check-in.',
                  fa: 'لطفاً نسخه چاپی این ویزا را هنگام بررسی گذرنامه در فرودگاه به همراه داشته باشید.',
                ),
              ),
              _reminderItem(
                l10nPick(
                  context,
                  en: 'Ensure your passport is the exact one submitted in this application and has at least 6 months validity.',
                  fa: 'اطمینان حاصل فرمایید گذرنامه ارائه شده حداقل ۶ ماه اعتبار قانونی داشته باشد.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRejectedSection(BuildContext context, VisaController controller, bool isDark) {
    return Column(
      children: [
        // Rejection Header Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.xl.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.errorContainer,
            border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.md.r),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.highlight_off_rounded, color: AppColors.error, size: 40.r),
              ),
              SizedBox(height: AppSpacing.md.h),
              Text(
                l10nPick(context, en: 'Application Not Approved', fa: 'عدم موافقت با صدور ویزا'),
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w900, color: AppColors.error),
              ),
              SizedBox(height: AppSpacing.xs.h),
              Text(
                l10nPick(
                  context,
                  en: 'The immigration authority has declined this visa request.',
                  fa: 'متأسفانه اداره مهاجرت کشور مقصد با صدور این ویزا موافقت نکرده است.',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5.sp, color: AppColors.error, height: 1.4),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg.h),

        // Rejection Reason Detail Card
        VisaCard(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10nPick(context, en: 'Official Refusal Explanation', fa: 'علت و شرح عدم صدور'),
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.md.r),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Text(
                  request.rejectionReason != null && request.rejectionReason!.isNotEmpty
                      ? request.rejectionReason!
                      : l10nPick(
                          context,
                          en: 'Refusal by immigration department guidelines. No further public details provided by the authority.',
                          fa: 'رد درخواست بر اساس ضوابط امنیتی یا مدارک ناقص صادر شده است.',
                        ),
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg.h),

        // Refund Policy Breakdown
        VisaCard(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10nPick(context, en: 'Refund Statement', fa: 'وضعیت استرداد وجه'),
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),
              Text(
                l10nPick(
                  context,
                  en: 'Per international visa rules, official government & embassy fees paid to authorities are strictly non-refundable once processed. Platform service guarantees apply as per agreement.',
                  fa: 'مطابق مقررات بین‌المللی، هزینه‌های کنسولی دولتی ویزا پس از ثبت در مرجع خارجی غیرقابل استرداد است. خدمات پشتیبانی طبق تعهدات پیگیری خواهد شد.',
                ),
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.xl.h),

        // Appeal / Support Button
        ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
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
            backgroundColor: AppColors.mutedBlue,
            minimumSize: Size(double.infinity, 48.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
            elevation: 0,
          ),
          icon: Icon(Icons.support_agent_rounded, color: AppColors.white, size: AppSpacing.iconSm.r),
          label: Text(
            l10nPick(context, en: 'Contact Visa Specialist / Appeal', fa: 'ثبت اعتراض / تماس با کارشناس'),
            style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800, color: AppColors.white),
          ),
        ),
      ],
    );
  }

  Widget _certRow(BuildContext context, String label, String value, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reminderItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 16.r, color: AppColors.success),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 11.5.sp, color: AppColors.success, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
