import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_spacing.dart';
import '../../helper/l10n_pick.dart';
import '../models/visa_models.dart';
import '../widgets/visa_widgets.dart';
import 'visa_application_screen.dart';

class VisaRequirementsScreen extends StatelessWidget {
  final VisaCatalogItem item;

  const VisaRequirementsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          item.countryName,
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
          // Visa Header Card
          VisaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    VisaCountryFlag(flagUrl: item.countryFlag, size: 44),
                    SizedBox(width: AppSpacing.md.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${l10nPick(context, en: 'Visa Type', fa: 'نوع روادید')}: ${item.visaType}',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (item.description.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.md.h),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg.h),

          // Pricing & Breakdown Card
          VisaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(context, en: 'Fee Breakdown', fa: 'تعرفه و هزینه‌های ویزا'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.md.h),
                _priceRow(
                  isDark: isDark,
                  title: l10nPick(context, en: 'Platform Service Fee', fa: 'هزینه خدمات و بررسی تخصصی'),
                  amount: '\$${item.serviceFee.toStringAsFixed(2)}',
                  subtitle: l10nPick(context, en: 'Application prep & consultant audit', fa: 'تشکیل پرونده و اعتبارسنجی مدارک'),
                ),
                Divider(
                  height: AppSpacing.xl,
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
                _priceRow(
                  isDark: isDark,
                  title: l10nPick(context, en: 'Government & Embassy Fee', fa: 'تعرفه رسمی دولتی و صدور مرجع'),
                  amount: '\$${item.govFee.toStringAsFixed(2)}',
                  subtitle: l10nPick(context, en: 'Non-refundable after embassy submission', fa: 'غیرقابل استرداد پس از ثبت در مرجع صادرکننده'),
                ),
                Divider(
                  height: AppSpacing.xl,
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10nPick(context, en: 'Total Amount', fa: 'مجموع کل پرداختی'),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      '\$${item.totalFee.toStringAsFixed(2)} ${item.currency}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg.h),

          // Required Documents Checklist
          VisaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.fact_check_outlined,
                      color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                      size: AppSpacing.iconSm.r,
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    Text(
                      l10nPick(context, en: 'Required Documents', fa: 'مدارک و پیش‌نیازهای لازم'),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md.h),
                if (item.requiredDocs.isEmpty)
                  Text(
                    l10nPick(context, en: 'Passport scan is required.', fa: 'اسکن گذرنامه با حداقل ۶ ماه اعتبار الزامی است.'),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  )
                else
                  ...item.requiredDocs.map((doc) => _DocRequirementTile(doc: doc, isDark: isDark)),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg.h),

          // Policy & Rules Card
          VisaCard(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(context, en: 'Important Guidelines', fa: 'نکات و ضوابط ضروری'),
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                _bulletPoint(
                  isDark: isDark,
                  icon: Icons.access_time_rounded,
                  text: '${l10nPick(context, en: 'Estimated Processing Time', fa: 'مدت‌زمان تقریبی صدور')}: ${item.processingDaysMin} ${l10nPick(context, en: 'to', fa: 'تا')} ${item.processingDaysMax} ${l10nPick(context, en: 'business days', fa: 'روز کاری')}',
                ),
                SizedBox(height: AppSpacing.xs.h),
                _bulletPoint(
                  isDark: isDark,
                  icon: Icons.fingerprint_rounded,
                  text: item.needsBiometric
                      ? l10nPick(context, en: 'Biometric appointment is required in person.', fa: 'نیاز به انگشت‌نگاری و حضور در سفارت دارد.')
                      : l10nPick(context, en: '100% online E-Visa, no in-person visit needed.', fa: 'صددرصد آنلاین (E-Visa) بدون نیاز به مراجعه حضوری.'),
                ),
                SizedBox(height: AppSpacing.xs.h),
                _bulletPoint(
                  isDark: isDark,
                  icon: Icons.verified_user_outlined,
                  text: l10nPick(
                    context,
                    en: 'Document revisions allowed up to 3 times before final embassy filing.',
                    fa: 'امکان تا ۳ بار ویرایش و اصلاح مدارک قبل از ارسال پرونده به اداره مهاجرت.',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xxxl.h),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg.w,
          vertical: AppSpacing.md.h,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Get.to(() => VisaApplicationScreen(catalog: item));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
              foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10nPick(context, en: 'Start Application', fa: 'شروع ثبت درخواست ویزا'),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: AppSpacing.sm.w),
                const Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _priceRow({
    required bool isDark,
    required String title,
    required String amount,
    required String subtitle,
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
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _bulletPoint({
    required bool isDark,
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16.r,
          color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
        ),
        SizedBox(width: AppSpacing.sm.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11.5.sp,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _DocRequirementTile extends StatelessWidget {
  final VisaRequiredDoc doc;
  final bool isDark;

  const _DocRequirementTile({required this.doc, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
            ),
            child: Icon(
              Icons.attach_file_rounded,
              size: 16.r,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        doc.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    if (doc.required) ...[
                      SizedBox(width: AppSpacing.xs.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.error.withValues(alpha: 0.2) : AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          l10nPick(context, en: 'Required', fa: 'الزامی'),
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
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
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
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
