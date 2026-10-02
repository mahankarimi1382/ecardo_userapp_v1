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
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    project.sector,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up_rounded, color: AppColors.success, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        '${project.annualYieldPercent.toStringAsFixed(1)}% p.a.',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                    ],
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
                    Text(
                      project.location,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.lightTextTertiary,
                        fontWeight: FontWeight.w500,
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
                    Text(
                      '${project.progressPercent}% funded',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lightPrimary,
                      ),
                    ),
                    Text(
                      '${project.daysLeft} days left',
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
                    Text(
                      'Raised: ${project.currency} ${_formatCompact(project.raisedAmount)}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                    Text(
                      'Target: ${project.currency} ${_formatCompact(project.targetAmount)}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTextSecondary,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10nPick(
                        context,
                        en: 'Min. Ticket',
                        fa: 'حداقل ورود',
                        ar: 'الحد الأدنى',
                        zh: '起投金额',
                      ),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.lightTextTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${project.currency} ${_formatCompact(project.minInvestment)}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
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
                      en: 'Invest Now',
                      fa: 'سرمایه‌گذاری',
                      ar: 'استثمر الآن',
                      zh: '立即投资',
                    ),
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
