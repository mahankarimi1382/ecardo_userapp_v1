import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
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

  String localizedTitle(BuildContext context) {
    if (id == 'eq-001') {
      return l10nPick(
        context,
        fa: 'هاب پایانه‌های پرداخت و حواله منطقه‌ای اکاردو',
        en: 'eCardo Regional Remittance Node & Payment Terminal Hub',
        ar: 'مركز إيكاردو الإقليمي للتحويل ومحطات الدفع',
        zh: 'eCardo 区域汇款节点与支付终端枢纽',
      );
    }
    if (id == 'eq-002') {
      return l10nPick(
        context,
        fa: 'میکروگرید انرژی خورشیدی پاک (فاز ۲)',
        en: 'Solar Clean Energy Micro-Grid Phase 2',
        ar: 'الشبكة الصغيرة للطاقة الشمسية النظيفة (المرحلة 2)',
        zh: '太阳能清洁能源微电网二期',
      );
    }
    if (id == 'eq-003') {
      return l10nPick(
        context,
        fa: 'شبکه لجستیک زنجیره سرد هوشمند کشاورزی',
        en: 'Smart Agri-Tech Cold Chain Logistics Network',
        ar: 'شبكة لوجستيات سلسلة التبريد الزراعية الذكية',
        zh: '智慧农业冷链物流网络',
      );
    }
    return title;
  }

  String localizedSector(BuildContext context) {
    final s = sector.toLowerCase();
    return l10nPick(
      context,
      fa: s.contains('clean') || s.contains('energy')
          ? 'انرژی پاک و زیرساخت'
          : s.contains('agri')
          ? 'کشاورزی و زنجیره تأمین'
          : 'فین‌تک و پرداخت',
      en: sector,
      ar: s.contains('clean') || s.contains('energy')
          ? 'الطاقة النظيفة والبنية التحتية'
          : s.contains('agri')
          ? 'الزراعة وسلسلة الإمداد'
          : 'التكنولوجيا المالية والمدفوعات',
      zh: s.contains('clean') || s.contains('energy')
          ? '清洁能源与基础设施'
          : s.contains('agri')
          ? '农业与供应链'
          : '金融科技与支付',
    );
  }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.lg.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with sector badge & yield highlight (ROI Chip)
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg.w,
              AppSpacing.lg.h,
              AppSpacing.lg.w,
              AppSpacing.sm.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary)
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusSm.r,
                      ),
                    ),
                    child: Text(
                      project.localizedSector(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm.w),
                // Glowing ROI Chip
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusSm.r,
                      ),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          color: AppColors.success,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            '${l10nPick(context, en: 'Illustrative — ', fa: 'نمونه — ', ar: 'توضيحي — ', zh: '示例 — ')}${project.annualYieldPercent.toStringAsFixed(1)}% p.a.',
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
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.localizedTitle(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 13.sp,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        project.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.md.h),

          // Progress Bar & Funding Numbers (Progress Meter)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
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
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    Flexible(
                      child: Text(
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                // Smooth rounded Progress Meter
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs.r),
                  child: LinearProgressIndicator(
                    value: project.progressRatio,
                    minHeight: 7.h,
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightBorder.withValues(alpha: 0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '${l10nPick(context, en: 'Sample raised', fa: 'نمونه جذب‌شده', ar: 'تم جمع نموذجي', zh: '示例已募集')}: ${project.currency} ${_formatCompact(project.raisedAmount)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    Flexible(
                      child: Text(
                        '${l10nPick(context, en: 'Sample target', fa: 'نمونه هدف', ar: 'الهدف النموذجي', zh: '示例目标')}: ${project.currency} ${_formatCompact(project.targetAmount)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.md.h),
          Divider(
            height: 1,
            color: isDark
                ? AppColors.darkDivider
                : AppColors.lightBorder.withValues(alpha: 0.6),
          ),

          // Bottom Bar: Min Ticket & Invest Button
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg.w,
              vertical: AppSpacing.md.h,
            ),
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
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
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
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.md.w),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onInvestTap();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary,
                    foregroundColor: isDark
                        ? AppColors.deepBlack
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusSm.r,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg.w,
                      vertical: AppSpacing.sm.h,
                    ),
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
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                    ),
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
