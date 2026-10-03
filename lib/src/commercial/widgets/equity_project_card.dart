import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

class EquityProjectItem {
  final String id;
  final String title;
  final String sector;
  final String currency;
  final double targetAmount;
  final double raisedAmount;

  /// Sample figure only. Equity crowdfunding is NOT live and no API supplies
  /// this number — every surface that shows it must label it as illustrative.
  final double annualYieldPercent;
  final double minInvestment;
  final int daysLeft;
  final String location;
  final String? imageUrl;

  const EquityProjectItem({
    required this.id,
    required this.title,
    required this.sector,
    required this.currency,
    required this.targetAmount,
    required this.raisedAmount,
    required this.annualYieldPercent,
    required this.minInvestment,
    required this.daysLeft,
    required this.location,
    this.imageUrl,
  });

  double get progressRatio =>
      targetAmount > 0 ? (raisedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  int get progressPercent => (progressRatio * 100).round();
}

class EquityProjectCard extends StatelessWidget {
  final EquityProjectItem project;
  final VoidCallback onInvestTap;

  const EquityProjectCard({
    super.key,
    required this.project,
    required this.onInvestTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.lightTextPrimary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with sector badge & yield highlight
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.lightPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      project.sector,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightPrimary,
                      ),
                    ),
                  ),
                ),
<<<<<<< HEAD
                SizedBox(width: 8.w),
=======
>>>>>>> origin/main
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_up_rounded, color: AppColors.success, size: 14.sp),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
<<<<<<< HEAD
                            '${l10nPick(context, en: 'Illustrative — ', fa: 'نمونه — ', ar: 'توضيحي — ', zh: '示例 — ')}${project.annualYieldPercent.toStringAsFixed(1)}% p.a.',
=======
                            '${project.annualYieldPercent.toStringAsFixed(1)}% p.a.',
>>>>>>> origin/main
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Title & Location
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.lightTextPrimary,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 13.sp, color: AppColors.lightTextTertiary),
                    SizedBox(width: 4.w),
<<<<<<< HEAD
                    Expanded(
=======
                    Flexible(
>>>>>>> origin/main
                      child: Text(
                        project.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.lightTextTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // Progress Bar & Funding Numbers
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        l10nPick(
                          context,
                          // No funding round exists behind this project, so a
                          // "77% funded" bar would be a fabricated progress claim.
                          en: 'Sample progress',
                          fa: 'پیشرفت نمونه',
                          ar: 'التقدم النموذجي',
                          zh: '示例进度',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lightPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      // Sample value: there is no live funding round behind
                      // this project, so a countdown would be a fabricated
                      // urgency promise.
                      l10nPick(
                        context,
                        en: 'Sample project',
                        fa: 'پروژه نمونه',
                        ar: 'مشروع نموذجي',
                        zh: '示例项目',
                      ),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: LinearProgressIndicator(
                    value: project.progressRatio,
                    minHeight: 7.h,
                    backgroundColor: AppColors.lightBorder.withValues(alpha: 0.5),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.lightPrimary),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
<<<<<<< HEAD
                        '${l10nPick(context, en: 'Sample raised', fa: 'نمونه جذب‌شده', ar: 'تم جمع نموذجي', zh: '示例已募集')}: ${project.currency} ${_formatCompact(project.raisedAmount)}',
=======
                        'Raised: ${project.currency} ${_formatCompact(project.raisedAmount)}',
>>>>>>> origin/main
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
<<<<<<< HEAD
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        '${l10nPick(context, en: 'Sample target', fa: 'نمونه هدف', ar: 'الهدف النموذجي', zh: '示例目标')}: ${project.currency} ${_formatCompact(project.targetAmount)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
=======
                    Flexible(
                      child: Text(
                        'Target: ${project.currency} ${_formatCompact(project.targetAmount)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
>>>>>>> origin/main
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),
          Divider(height: 1, color: AppColors.lightBorder.withValues(alpha: 0.6)),

          // Bottom Bar: Min Ticket & Invest Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: 'Sample min. ticket',
                          fa: 'حداقل ورود نمونه',
                          ar: 'الحد الأدنى النموذجي',
                          zh: '示例起投金额',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.lightTextTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          '${project.currency} ${_formatCompact(project.minInvestment)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onInvestTap();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    elevation: 0,
                  ),
                  child: Text(
                    l10nPick(
                      context,
                      // Opens the illustrative calculator, not a live order.
                      en: 'Preview',
                      fa: 'پیش‌نمایش',
                      ar: 'معاينة',
                      zh: '预览',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCompact(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    }
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
