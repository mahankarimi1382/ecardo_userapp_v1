import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../models/escrow_models.dart';

/// Dark-aware status badge for Escrow transactions.
class EscrowStatusBadge extends StatelessWidget {
  final String status;
  final String? label;

  const EscrowStatusBadge({
    super.key,
    required this.status,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg;
    Color text;
    IconData icon;
    String display = label ?? status;

    switch (status) {
      case 'DRAFT':
        bg = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9);
        text = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
        icon = Icons.edit_note_rounded;
        display = l10nPick(context, fa: 'پیش‌نویس', en: 'Draft');
        break;
      case 'AWAITING_AGREEMENT':
        bg = isDark ? const Color(0xFF2E2211) : const Color(0xFFFEF3C7);
        text = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
        icon = Icons.handshake_outlined;
        display = l10nPick(context, fa: 'در انتظار تأیید', en: 'Awaiting Agreement');
        break;
      case 'AWAITING_PAYMENT':
        bg = isDark ? const Color(0xFF332014) : const Color(0xFFFFEDD5);
        text = isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C);
        icon = Icons.payment_rounded;
        display = l10nPick(context, fa: 'در انتظار پرداخت', en: 'Awaiting Payment');
        break;
      case 'FUNDS_HELD':
        bg = isDark ? const Color(0xFF132838) : const Color(0xFFE0F2FE);
        text = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
        icon = Icons.lock_clock_rounded;
        display = l10nPick(context, fa: 'امان نزد پلتفرم', en: 'Funds in Escrow');
        break;
      case 'IN_DELIVERY':
        bg = isDark ? const Color(0xFF261D36) : const Color(0xFFF3E8FF);
        text = isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA);
        icon = Icons.local_shipping_outlined;
        display = l10nPick(context, fa: 'در حال ارسال', en: 'In Delivery');
        break;
      case 'DELIVERED':
        bg = isDark ? const Color(0xFF122C2A) : const Color(0xFFCCFBF1);
        text = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488);
        icon = Icons.inventory_2_outlined;
        display = l10nPick(context, fa: 'دوره بازرسی', en: 'Inspection Period');
        break;
      case 'RELEASED':
      case 'COMPLETED':
        bg = isDark ? const Color(0xFF132B1F) : const Color(0xFFDCFCE7);
        text = isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
        icon = Icons.check_circle_rounded;
        display = l10nPick(context, fa: 'تکمیل و تسویه', en: 'Completed');
        break;
      case 'DISPUTED':
        bg = isDark ? const Color(0xFF36181B) : const Color(0xFFFEE2E2);
        text = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
        icon = Icons.gavel_rounded;
        display = l10nPick(context, fa: 'پرونده اختلاف', en: 'Disputed');
        break;
      case 'REFUNDED':
        bg = isDark ? const Color(0xFF36182C) : const Color(0xFFFCE7F3);
        text = isDark ? const Color(0xFFF472B6) : const Color(0xFFDB2777);
        icon = Icons.replay_rounded;
        display = l10nPick(context, fa: 'عودت وجه', en: 'Refunded');
        break;
      case 'CANCELLED':
      case 'EXPIRED':
        bg = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9);
        text = isDark ? AppColors.darkTextTertiary : const Color(0xFF94A3B8);
        icon = Icons.cancel_outlined;
        display = status == 'EXPIRED'
            ? l10nPick(context, fa: 'منقضی شده', en: 'Expired')
            : l10nPick(context, fa: 'لغو شده', en: 'Cancelled');
        break;
      default:
        bg = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9);
        text = isDark ? AppColors.darkTextSecondary : const Color(0xFF475569);
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(
          color: text.withValues(alpha: 0.25),
          width: 0.8,
        ),
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

/// Six-stage visual milestone stepper for Escrow contracts.
class EscrowMilestoneStepper extends StatelessWidget {
  final String currentStatus;

  const EscrowMilestoneStepper({
    super.key,
    required this.currentStatus,
  });

  int _currentStepIndex() {
    switch (currentStatus) {
      case 'DRAFT':
        return 0;
      case 'AWAITING_AGREEMENT':
        return 1;
      case 'AWAITING_PAYMENT':
      case 'FUNDS_HELD':
        return 2;
      case 'IN_DELIVERY':
        return 3;
      case 'DELIVERED':
        return 4;
      case 'RELEASED':
      case 'COMPLETED':
        return 5;
      case 'DISPUTED':
        return 4; // Inspection phase dispute
      case 'REFUNDED':
      case 'CANCELLED':
      case 'EXPIRED':
        return 0;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeStep = _currentStepIndex();

    final steps = [
      {'title': l10nPick(context, fa: 'پیش‌نویس', en: 'Draft'), 'icon': Icons.description_outlined},
      {'title': l10nPick(context, fa: 'توافق طرفین', en: 'Agreement'), 'icon': Icons.handshake_outlined},
      {'title': l10nPick(context, fa: 'قفل امانی وجه', en: 'Funded'), 'icon': Icons.lock_clock_outlined},
      {'title': l10nPick(context, fa: 'ارسال کالا', en: 'Shipped'), 'icon': Icons.local_shipping_outlined},
      {'title': l10nPick(context, fa: 'بازرسی کالا', en: 'Inspection'), 'icon': Icons.fact_check_outlined},
      {'title': l10nPick(context, fa: 'تسویه نهایی', en: 'Settled'), 'icon': Icons.verified_rounded},
    ];

    final primaryAccent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final inactiveColor = isDark ? AppColors.darkOutline : AppColors.lightOutlineVariant;

    return Container(
      padding: EdgeInsetsDirectional.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10nPick(context, fa: 'مراحل انجام معامله امانی', en: 'Escrow Deal Progress'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: primaryAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '${activeStep + 1} / ${steps.length}',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w900,
                    color: primaryAccent,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                final lineIndex = index ~/ 2;
                final isPassed = lineIndex < activeStep;
                return Expanded(
                  child: Container(
                    height: 2.5.h,
                    color: isPassed ? primaryAccent : inactiveColor,
                  ),
                );
              }

              final stepIndex = index ~/ 2;
              final isCompleted = stepIndex < activeStep;
              final isCurrent = stepIndex == activeStep;

              Color circleBg;
              Color circleBorder;
              Color iconColor;

              if (isCompleted) {
                circleBg = primaryAccent;
                circleBorder = primaryAccent;
                iconColor = isDark ? AppColors.deepBlack : AppColors.white;
              } else if (isCurrent) {
                circleBg = primaryAccent.withValues(alpha: 0.15);
                circleBorder = primaryAccent;
                iconColor = primaryAccent;
              } else {
                circleBg = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC);
                circleBorder = inactiveColor;
                iconColor = isDark ? AppColors.darkTextTertiary : const Color(0xFF94A3B8);
              }

              return Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: circleBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: circleBorder, width: isCurrent ? 2 : 1),
                ),
                child: Center(
                  child: Icon(
                    isCompleted
                        ? Icons.check_rounded
                        : (steps[stepIndex]['icon'] as IconData),
                    size: 14.sp,
                    color: iconColor,
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  steps[activeStep]['title'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: primaryAccent,
                  ),
                ),
              ),
              if (activeStep < steps.length - 1)
                Expanded(
                  child: Text(
                    '${l10nPick(context, fa: 'مرحله بعد: ', en: 'Next: ')}${steps[activeStep + 1]['title']}',
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Counterparty monogram badge with stylized initials.
class EscrowCounterpartyAvatar extends StatelessWidget {
  final String name;
  final String role;
  final bool isBuyer;

  const EscrowCounterpartyAvatar({
    super.key,
    required this.name,
    required this.role,
    this.isBuyer = true,
  });

  String get _initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(' ');
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return trimmed.length > 1 ? trimmed.substring(0, 2) : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isBuyer
        ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
        : (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
          ),
          child: Center(
            child: Text(
              _initials,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextSecondary,
                  fontSize: 10.sp,
                ),
              ),
              Text(
                name.isNotEmpty ? name : '...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Dark-aware timeline widget for Escrow events.
class EscrowTimelineWidget extends StatelessWidget {
  final List<EscrowEventModel> events;

  const EscrowTimelineWidget({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
          child: Text(
            l10nPick(context, fa: 'تاریخچه رویدادی ثبت نشده است.', en: 'No events logged yet.'),
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextSecondary,
            ),
          ),
        ),
      );
    }

    final activeColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final inactiveLine = isDark ? AppColors.darkOutline : AppColors.lightOutlineVariant;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
      itemBuilder: (ctx, i) {
        final ev = events[i];
        final isLast = i == events.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: isLast ? activeColor : inactiveLine,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.darkSurface : AppColors.white,
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2.w,
                    height: 38.h,
                    color: inactiveLine,
                  ),
              ],
            ),
            SizedBox(width: AppSpacing.md.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ev.action.isNotEmpty ? ev.action : ev.toStatus,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: isLast ? FontWeight.w900 : FontWeight.w700,
                          color: isLast ? activeColor : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        ),
                      ),
                      if (ev.createdAt != null)
                        Text(
                          '${ev.createdAt!.hour.toString().padLeft(2, "0")}:${ev.createdAt!.minute.toString().padLeft(2, "0")}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextSecondary,
                          ),
                        ),
                    ],
                  ),
                  if (ev.reason != null && ev.reason!.isNotEmpty)
                    Padding(
                      padding: EdgeInsetsDirectional.only(top: 2.h),
                      child: Text(
                        ev.reason!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  Text(
                    '${l10nPick(context, fa: 'توسط: ', en: 'By: ')}${ev.actorRole}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Shimmer skeleton loader for Escrow deal cards and detail views.
class EscrowSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const EscrowSkeletonLoader({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2B2B29) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF383835) : const Color(0xFFF1F5F9);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.md.h),
        itemBuilder: (_, _) => Container(
          padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                    ),
                  ),
                  Container(
                    width: 80.w,
                    height: 22.h,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md.h),
              Container(
                width: double.infinity,
                height: 18.h,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),
              Container(
                width: 180.w,
                height: 14.h,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                ),
              ),
              SizedBox(height: AppSpacing.md.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 120.w,
                    height: 22.h,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                    ),
                  ),
                  Container(
                    width: 70.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
