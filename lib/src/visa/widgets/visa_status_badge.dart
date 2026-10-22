import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Dark-aware, harmonized status badge for Visa applications.
/// Tokenized with [AppColors] for success, warning, error, info, and surface states.
class VisaStatusBadge extends StatelessWidget {
  final String status;
  final String? label;
  final double? fontSize;

  const VisaStatusBadge({
    super.key,
    required this.status,
    this.label,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg;
    Color fg;
    IconData icon;
    String display = label ?? '';

    switch (status.toUpperCase()) {
      case 'APPROVED':
        bg = isDark
            ? AppColors.success.withValues(alpha: 0.18)
            : AppColors.successContainer;
        fg = AppColors.success;
        icon = Icons.check_circle_rounded;
        if (display.isEmpty) {
          display = l10nPick(context, en: 'Approved', fa: 'صادر شد');
        }
        break;
      case 'DELIVERED':
        bg = isDark
            ? AppColors.success.withValues(alpha: 0.18)
            : AppColors.successContainer;
        fg = AppColors.success;
        icon = Icons.task_alt_rounded;
        if (display.isEmpty) {
          display = l10nPick(context, en: 'Delivered', fa: 'تحویل‌شده');
        }
        break;
      case 'UNDER_REVIEW':
      case 'IN_PROCESS':
        bg = isDark
            ? AppColors.info.withValues(alpha: 0.18)
            : AppColors.infoContainer;
        fg = isDark ? AppColors.mainSoftBlue : AppColors.info;
        icon = Icons.hourglass_top_rounded;
        if (display.isEmpty) {
          display = l10nPick(context, en: 'Under Review', fa: 'در حال بررسی');
        }
        break;
      case 'SUBMITTED_TO_AUTHORITY':
        bg = isDark
            ? AppColors.info.withValues(alpha: 0.18)
            : AppColors.infoContainer;
        fg = isDark ? AppColors.mainSoftBlue : AppColors.info;
        icon = Icons.account_balance_rounded;
        if (display.isEmpty) {
          display = l10nPick(
            context,
            en: 'At Authority',
            fa: 'نزد سفارت / مرجع',
          );
        }
        break;
      case 'AWAITING_DOCUMENTS':
      case 'COMPLEMENT_REQUIRED':
        bg = isDark
            ? AppColors.warning.withValues(alpha: 0.18)
            : AppColors.warningContainer;
        fg = AppColors.warning;
        icon = Icons.pending_actions_rounded;
        if (display.isEmpty) {
          display = l10nPick(context, en: 'Needs Docs', fa: 'نیاز به مدرک');
        }
        break;
      case 'AWAITING_PAYMENT':
        bg = isDark
            ? AppColors.warning.withValues(alpha: 0.18)
            : AppColors.warningContainer;
        fg = AppColors.warning;
        icon = Icons.payment_rounded;
        if (display.isEmpty) {
          display = l10nPick(
            context,
            en: 'Awaiting Payment',
            fa: 'در انتظار پرداخت',
          );
        }
        break;
      case 'REJECTED':
      case 'DECLINED':
        bg = isDark
            ? AppColors.error.withValues(alpha: 0.18)
            : AppColors.errorContainer;
        fg = AppColors.error;
        icon = Icons.cancel_rounded;
        if (display.isEmpty) {
          display = l10nPick(context, en: 'Rejected', fa: 'رد شد');
        }
        break;
      case 'CANCELLED':
        bg = isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant;
        fg = isDark ? AppColors.darkTextTertiary : AppColors.softGray;
        icon = Icons.block_rounded;
        if (display.isEmpty) {
          display = l10nPick(context, en: 'Cancelled', fa: 'لغو شد');
        }
        break;
      default:
        bg = isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant;
        fg = isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary;
        icon = Icons.info_outline_rounded;
        if (display.isEmpty) {
          display = status;
        }
    }

    return Semantics(
      label: display,
      container: true,
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.sm.w,
          vertical: AppSpacing.xs.h,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
          border: Border.all(color: fg.withValues(alpha: 0.25), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: (fontSize ?? 11.sp), color: fg),
            SizedBox(width: 4.w),
            Text(
              display,
              style: TextStyle(
                color: fg,
                fontSize: fontSize ?? 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
