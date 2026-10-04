import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_spacing.dart';
import '../../helper/l10n_pick.dart';

/// Theme-aware Visa card container with consistent border and shadow tokens.
class VisaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;
  final Border? border;

  const VisaCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBg = color ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final effectiveBorder = border ?? Border.all(
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      width: 1,
    );

    final cardWidget = Container(
      margin: margin,
      padding: padding ?? EdgeInsets.all(AppSpacing.lg.r),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
        border: effectiveBorder,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap!();
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }
}

/// Standardized status badge for visa states.
class VisaStatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;

  const VisaStatusBadge({
    super.key,
    required this.status,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg;
    Color fg;
    String label;

    switch (status.toUpperCase()) {
      case 'APPROVED':
        bg = isDark ? AppColors.success.withValues(alpha: 0.2) : AppColors.successContainer;
        fg = AppColors.success;
        label = l10nPick(context, en: 'Approved', fa: 'صادر شد');
        break;
      case 'DELIVERED':
        bg = isDark ? AppColors.success.withValues(alpha: 0.2) : AppColors.successContainer;
        fg = AppColors.success;
        label = l10nPick(context, en: 'Delivered', fa: 'تحویل‌شده');
        break;
      case 'UNDER_REVIEW':
      case 'IN_PROCESS':
        bg = isDark ? AppColors.mutedBlue.withValues(alpha: 0.2) : AppColors.infoContainer;
        fg = isDark ? AppColors.mainSoftBlue : AppColors.lightSecondary;
        label = l10nPick(context, en: 'Under Review', fa: 'در حال بررسی');
        break;
      case 'SUBMITTED_TO_AUTHORITY':
        bg = isDark ? AppColors.mutedBlue.withValues(alpha: 0.2) : AppColors.infoContainer;
        fg = isDark ? AppColors.mainSoftBlue : AppColors.lightSecondary;
        label = l10nPick(context, en: 'At Embassy', fa: 'نزد سفارت / مرجع');
        break;
      case 'AWAITING_DOCUMENTS':
      case 'COMPLEMENT_REQUIRED':
        bg = isDark ? AppColors.warning.withValues(alpha: 0.2) : AppColors.warningContainer;
        fg = AppColors.warning;
        label = l10nPick(context, en: 'Needs Docs', fa: 'نیاز به مدرک');
        break;
      case 'AWAITING_PAYMENT':
        bg = isDark ? AppColors.warning.withValues(alpha: 0.2) : AppColors.warningContainer;
        fg = AppColors.warning;
        label = l10nPick(context, en: 'Awaiting Payment', fa: 'در انتظار پرداخت');
        break;
      case 'REJECTED':
        bg = isDark ? AppColors.error.withValues(alpha: 0.2) : AppColors.errorContainer;
        fg = AppColors.error;
        label = l10nPick(context, en: 'Rejected', fa: 'رد شد');
        break;
      case 'CANCELLED':
        bg = isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground;
        fg = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
        label = l10nPick(context, en: 'Cancelled', fa: 'لغو شد');
        break;
      default:
        bg = isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground;
        fg = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm.w,
        vertical: AppSpacing.xs.h,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: fontSize ?? 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Country flag avatar with fallback icon and rounded corners.
class VisaCountryFlag extends StatelessWidget {
  final String flagUrl;
  final double size;

  const VisaCountryFlag({
    super.key,
    required this.flagUrl,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (flagUrl.isEmpty) {
      return Container(
        width: size.r,
        height: size.r,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.public_rounded,
          size: (size * 0.6).r,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.25),
      child: Image.network(
        flagUrl,
        width: size.r,
        height: (size * 0.7).r,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: size.r,
          height: size.r,
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
          child: Icon(
            Icons.flag_rounded,
            size: (size * 0.6).r,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }
}

/// Creative Multi-Step Visa Status Tracker.
/// Displays an interactive, polished 5-stage progress indicator with
/// animated indicators, milestone checkmarks, step descriptions, and RTL support.
class VisaTimelineWidget extends StatelessWidget {
  final String currentStatus;
  final bool isVertical;

  const VisaTimelineWidget({
    super.key,
    required this.currentStatus,
    this.isVertical = false,
  });

  int _calculateActiveStep() {
    switch (currentStatus.toUpperCase()) {
      case 'DRAFT':
      case 'AWAITING_DOCUMENTS':
      case 'COMPLEMENT_REQUIRED':
        return 1;
      case 'AWAITING_PAYMENT':
        return 2;
      case 'UNDER_REVIEW':
      case 'IN_PROCESS':
        return 3;
      case 'SUBMITTED_TO_AUTHORITY':
        return 4;
      case 'APPROVED':
      case 'DELIVERED':
      case 'REJECTED':
      case 'CANCELLED':
        return 5;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeStep = _calculateActiveStep();
    final isTerminalFailure = currentStatus.toUpperCase() == 'REJECTED' ||
        currentStatus.toUpperCase() == 'CANCELLED';

    final steps = [
      {
        'title': l10nPick(context, en: 'Application', fa: 'ثبت فرم'),
        'desc': l10nPick(context, en: 'Applicant bio & passport', fa: 'ثبت اطلاعات هویتی و گذرنامه'),
        'num': 1,
      },
      {
        'title': l10nPick(context, en: 'Payment', fa: 'پرداخت'),
        'desc': l10nPick(context, en: 'Embassy & platform fees', fa: 'پرداخت هزینه‌های رسمی و کنسولی'),
        'num': 2,
      },
      {
        'title': l10nPick(context, en: 'Doc Audit', fa: 'بررسی مدارک'),
        'desc': l10nPick(context, en: 'Specialist pre-check', fa: 'صحت‌سنجی تخصصی اسناد و ترجمه‌ها'),
        'num': 3,
      },
      {
        'title': l10nPick(context, en: 'At Authority', fa: 'ارسال به مرجع'),
        'desc': l10nPick(context, en: 'Immigration review', fa: 'بررسی نهایی توسط اداره مهاجرت مقصد'),
        'num': 4,
      },
      {
        'title': isTerminalFailure
            ? l10nPick(context, en: 'Declined', fa: 'عدم تایید')
            : l10nPick(context, en: 'Issued', fa: 'صدور روادید'),
        'desc': isTerminalFailure
            ? l10nPick(context, en: 'Decision issued by embassy', fa: 'تصمیم عدم صدور توسط مرجع قانونی')
            : l10nPick(context, en: 'Official E-Visa delivered', fa: 'ویزای الکترونیک صادر و تحویل گردید'),
        'num': 5,
      },
    ];

    if (isVertical) {
      return Container(
        padding: EdgeInsets.all(AppSpacing.lg.r),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          children: List.generate(steps.length, (index) {
            final s = steps[index];
            final stepNum = s['num'] as int;
            final isDone = stepNum < activeStep;
            final isCurrent = stepNum == activeStep;
            final isLast = index == steps.length - 1;

            Color nodeColor;
            Widget nodeChild;

            if (isDone) {
              nodeColor = AppColors.success;
              nodeChild = Icon(Icons.check, color: AppColors.white, size: 14.r);
            } else if (isCurrent) {
              nodeColor = isTerminalFailure ? AppColors.error : AppColors.mutedBlue;
              nodeChild = isTerminalFailure
                  ? Icon(Icons.close_rounded, color: AppColors.white, size: 14.r)
                  : Text(
                      '$stepNum',
                      style: TextStyle(color: AppColors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                    );
            } else {
              nodeColor = isDark ? AppColors.darkBorder : AppColors.lightDivider;
              nodeChild = Text(
                '$stepNum',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.softGray,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 14.r,
                      backgroundColor: nodeColor,
                      child: nodeChild,
                    ),
                    if (!isLast)
                      Container(
                        width: 2.w,
                        height: 36.h,
                        color: isDone
                            ? AppColors.success
                            : (isDark ? AppColors.darkBorder : AppColors.lightDivider),
                      ),
                  ],
                ),
                SizedBox(width: AppSpacing.md.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['title'] as String,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                          color: isCurrent
                              ? (isDark ? AppColors.darkPrimary : AppColors.lightSecondary)
                              : (isDone
                                  ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        s['desc'] as String,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      if (!isLast) SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      );
    }

    // Horizontal Stepper Bar
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.md.h,
        horizontal: AppSpacing.sm.w,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: steps.map((s) {
          final stepNum = s['num'] as int;
          final isDone = stepNum < activeStep;
          final isCurrent = stepNum == activeStep;

          Color circleColor;
          Widget icon;

          if (isDone) {
            circleColor = AppColors.success;
            icon = Icon(Icons.check, color: AppColors.white, size: 14.r);
          } else if (isCurrent) {
            circleColor = isTerminalFailure ? AppColors.error : AppColors.mutedBlue;
            icon = isTerminalFailure
                ? Icon(Icons.close_rounded, color: AppColors.white, size: 14.r)
                : Text(
                    '$stepNum',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  );
          } else {
            circleColor = isDark ? AppColors.darkBorder : AppColors.lightDivider;
            icon = Text(
              '$stepNum',
              style: TextStyle(
                color: isDark ? AppColors.darkTextTertiary : AppColors.softGray,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            );
          }

          return Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 13.r,
                  backgroundColor: circleColor,
                  child: icon,
                ),
                SizedBox(height: AppSpacing.xs.h),
                Text(
                  s['title'] as String,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    color: isCurrent
                        ? (isDark ? AppColors.darkPrimary : AppColors.lightSecondary)
                        : (isDone
                            ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Creative Document Upload Card with status, file type pill,
/// and interactive pick/re-upload triggers.
class VisaDocUploadCard extends StatelessWidget {
  final String title;
  final String? instructions;
  final bool isRequired;
  final File? pickedFile;
  final bool isUploading;
  final bool isAccepted;
  final bool isRejected;
  final String? rejectionNote;
  final VoidCallback onPickFile;

  const VisaDocUploadCard({
    super.key,
    required this.title,
    this.instructions,
    this.isRequired = false,
    this.pickedFile,
    this.isUploading = false,
    this.isAccepted = false,
    this.isRejected = false,
    this.rejectionNote,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color cardBg;
    Color borderColor;

    if (isAccepted) {
      cardBg = isDark ? AppColors.success.withValues(alpha: 0.12) : AppColors.successContainer;
      borderColor = AppColors.success;
    } else if (isRejected) {
      cardBg = isDark ? AppColors.error.withValues(alpha: 0.12) : AppColors.errorContainer;
      borderColor = AppColors.error;
    } else if (pickedFile != null) {
      cardBg = isDark ? AppColors.success.withValues(alpha: 0.08) : AppColors.successContainer.withValues(alpha: 0.6);
      borderColor = AppColors.success;
    } else {
      cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
      borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    }

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.cardGap.h),
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
        border: Border.all(color: borderColor, width: (isAccepted || isRejected || pickedFile != null) ? 1.2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: isAccepted
                    ? AppColors.success
                    : (isRejected
                        ? AppColors.error
                        : (pickedFile != null ? AppColors.success : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground))),
                child: Icon(
                  isAccepted
                      ? Icons.verified_rounded
                      : (isRejected
                          ? Icons.error_outline_rounded
                          : (pickedFile != null ? Icons.check_circle_rounded : Icons.file_upload_outlined)),
                  color: (isAccepted || isRejected || pickedFile != null)
                      ? AppColors.white
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  size: 20.r,
                ),
              ),
              SizedBox(width: AppSpacing.md.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        if (isRequired) ...[
                          SizedBox(width: 4.w),
                          Text('*', style: TextStyle(color: AppColors.error, fontSize: 13.sp)),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),
                    if (pickedFile != null)
                      Text(
                        pickedFile!.path.split('/').last.split('\\').last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else if (instructions != null && instructions!.isNotEmpty)
                      Text(
                        instructions!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              if (isUploading)
                SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.mutedBlue),
                )
              else
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onPickFile();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: pickedFile != null
                        ? (isDark ? AppColors.darkSurfaceVariant : AppColors.lightBorder)
                        : (isDark ? AppColors.darkPrimary : AppColors.lightSecondary),
                    foregroundColor: pickedFile != null
                        ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                        : AppColors.white,
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.xs.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
                  ),
                  child: Text(
                    pickedFile != null
                        ? l10nPick(context, en: 'Change', fa: 'تغییر')
                        : l10nPick(context, en: 'Upload', fa: 'انتخاب فایل'),
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          if (rejectionNote != null && rejectionNote!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.sm.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.error.withValues(alpha: 0.15) : AppColors.errorContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 14.r, color: AppColors.error),
                  SizedBox(width: AppSpacing.xs.w),
                  Expanded(
                    child: Text(
                      '${l10nPick(context, en: 'Note', fa: 'توضیحات کارشناس')}: $rejectionNote',
                      style: TextStyle(fontSize: 11.sp, color: AppColors.error, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
