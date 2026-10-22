import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Dark-aware status badge for Escrow transactions.
/// Tokenized with [AppColors] for success, warning, error, and thematic surfaces.
class EscrowStatusBadge extends StatelessWidget {
  final String status;
  final String? label;

  const EscrowStatusBadge({super.key, required this.status, this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg;
    Color text;
    IconData icon;
    String display = label ?? status;

    switch (status) {
      case 'DRAFT':
        bg = isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant;
        text = isDark ? AppColors.darkTextSecondary : AppColors.softGray;
        icon = Icons.edit_note_rounded;
        display = l10nPick(context, fa: 'پیش‌نویس', en: 'Draft');
        break;
      case 'AWAITING_AGREEMENT':
        bg = isDark
            ? AppColors.warning.withValues(alpha: 0.18)
            : AppColors.warningContainer;
        text = AppColors.warning;
        icon = Icons.handshake_outlined;
        display = l10nPick(
          context,
          fa: 'در انتظار تأیید',
          en: 'Awaiting Agreement',
        );
        break;
      case 'AWAITING_PAYMENT':
        bg = isDark
            ? AppColors.warning.withValues(alpha: 0.18)
            : AppColors.warningContainer;
        text = AppColors.warning;
        icon = Icons.payment_rounded;
        display = l10nPick(
          context,
          fa: 'در انتظار پرداخت',
          en: 'Awaiting Payment',
        );
        break;
      case 'FUNDS_HELD':
        bg = isDark
            ? AppColors.info.withValues(alpha: 0.18)
            : AppColors.infoContainer;
        text = AppColors.info;
        icon = Icons.lock_clock_rounded;
        display = l10nPick(
          context,
          fa: 'امان نزد پلتفرم',
          en: 'Funds in Escrow',
        );
        break;
      case 'IN_DELIVERY':
        bg = isDark
            ? AppColors.brandViolet.withValues(alpha: 0.18)
            : AppColors.brandVioletContainer;
        text = isDark ? AppColors.mainSoftBlue : AppColors.brandViolet;
        icon = Icons.local_shipping_outlined;
        display = l10nPick(context, fa: 'در حال ارسال', en: 'In Delivery');
        break;
      case 'DELIVERED':
        bg = isDark
            ? AppColors.lightSecondary.withValues(alpha: 0.18)
            : AppColors.lightSecondaryContainer;
        text = AppColors.lightSecondary;
        icon = Icons.inventory_2_outlined;
        display = l10nPick(context, fa: 'دوره بازرسی', en: 'Inspection Period');
        break;
      case 'RELEASED':
      case 'COMPLETED':
        bg = isDark
            ? AppColors.success.withValues(alpha: 0.18)
            : AppColors.successContainer;
        text = AppColors.success;
        icon = Icons.check_circle_rounded;
        display = l10nPick(context, fa: 'تکمیل و تسویه', en: 'Completed');
        break;
      case 'DISPUTED':
        bg = isDark
            ? AppColors.error.withValues(alpha: 0.18)
            : AppColors.errorContainer;
        text = AppColors.error;
        icon = Icons.gavel_rounded;
        display = l10nPick(context, fa: 'پرونده اختلاف', en: 'Disputed');
        break;
      case 'REFUNDED':
        bg = isDark
            ? AppColors.warning.withValues(alpha: 0.18)
            : AppColors.warningContainer;
        text = AppColors.warning;
        icon = Icons.replay_rounded;
        display = l10nPick(context, fa: 'عودت وجه', en: 'Refunded');
        break;
      case 'CANCELLED':
      case 'EXPIRED':
        bg = isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant;
        text = isDark ? AppColors.darkTextTertiary : AppColors.softGray;
        icon = Icons.cancel_outlined;
        display = status == 'EXPIRED'
            ? l10nPick(context, fa: 'منقضی شده', en: 'Expired')
            : l10nPick(context, fa: 'لغو شده', en: 'Cancelled');
        break;
      default:
        bg = isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant;
        text = isDark ? AppColors.darkTextSecondary : AppColors.softGray;
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(color: text.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: text),
          SizedBox(width: 4.w),
          Text(
            display,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}
