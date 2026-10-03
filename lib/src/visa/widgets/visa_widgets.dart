import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/constants/app_colors.dart';
import '../../helper/l10n_pick.dart';

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
    final cardWidget = Container(
      margin: margin,
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: color ?? AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: border ?? Border.all(color: AppColors.lightBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightShadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }
}

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
    Color bg;
    Color fg;
    String label;

    switch (status.toUpperCase()) {
      case 'APPROVED':
        bg = AppColors.successContainer;
        fg = AppColors.success;
        label = l10nPick(context, en: 'Approved', fa: 'صادر شد');
        break;
      case 'DELIVERED':
        bg = AppColors.successContainer;
        fg = AppColors.success;
        label = l10nPick(context, en: 'Delivered', fa: 'تحویل‌شده');
        break;
      case 'UNDER_REVIEW':
      case 'IN_PROCESS':
        bg = AppColors.infoContainer;
        fg = AppColors.lightSecondary;
        label = l10nPick(context, en: 'Under Review', fa: 'در حال بررسی');
        break;
      case 'SUBMITTED_TO_AUTHORITY':
        bg = AppColors.infoContainer;
        fg = AppColors.lightSecondary;
        label = l10nPick(context, en: 'At Embassy', fa: 'نزد سفارت / مرجع');
        break;
      case 'AWAITING_DOCUMENTS':
      case 'COMPLEMENT_REQUIRED':
        bg = AppColors.warningContainer;
        fg = AppColors.warning;
        label = l10nPick(context, en: 'Needs Docs', fa: 'نیاز به مدرک');
        break;
      case 'AWAITING_PAYMENT':
        bg = AppColors.warningContainer;
        fg = AppColors.warning;
        label = l10nPick(context, en: 'Awaiting Payment', fa: 'در انتظار پرداخت');
        break;
      case 'REJECTED':
        bg = AppColors.errorContainer;
        fg = AppColors.error;
        label = l10nPick(context, en: 'Rejected', fa: 'رد شد');
        break;
      case 'CANCELLED':
        bg = AppColors.lightBackground;
        fg = AppColors.lightTextSecondary;
        label = l10nPick(context, en: 'Cancelled', fa: 'لغو شد');
        break;
      default:
        bg = AppColors.lightBackground;
        fg = AppColors.lightTextSecondary;
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.r),
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
    if (flagUrl.isEmpty) {
      return Container(
        width: size.r,
        height: size.r,
        decoration: const BoxDecoration(
          color: AppColors.lightBackground,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.public, size: (size * 0.6).r, color: AppColors.lightTextSecondary),
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
          color: AppColors.lightBackground,
          child: Icon(Icons.flag, size: (size * 0.6).r, color: AppColors.lightTextSecondary),
        ),
      ),
    );
  }
}

class VisaTimelineWidget extends StatelessWidget {
  final String currentStatus;

  const VisaTimelineWidget({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    int activeStep = 0;
    switch (currentStatus.toUpperCase()) {
      case 'DRAFT':
      case 'AWAITING_DOCUMENTS':
      case 'COMPLEMENT_REQUIRED':
        activeStep = 1;
        break;
      case 'AWAITING_PAYMENT':
        activeStep = 2;
        break;
      case 'UNDER_REVIEW':
      case 'IN_PROCESS':
        activeStep = 3;
        break;
      case 'SUBMITTED_TO_AUTHORITY':
        activeStep = 4;
        break;
      case 'APPROVED':
      case 'DELIVERED':
      case 'REJECTED':
      case 'CANCELLED':
        activeStep = 5;
        break;
    }

    final steps = [
      {'title': l10nPick(context, en: 'Application', fa: 'ثبت فرم'), 'num': 1},
      {'title': l10nPick(context, en: 'Payment', fa: 'پرداخت'), 'num': 2},
      {'title': l10nPick(context, en: 'Review', fa: 'بررسی مدارک'), 'num': 3},
      {'title': l10nPick(context, en: 'Embassy', fa: 'ارسال به مرجع'), 'num': 4},
      {'title': l10nPick(context, en: 'Result', fa: 'نتیجه ویزا'), 'num': 5},
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16.r),
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
            icon = const Icon(Icons.check, color: Colors.white, size: 14);
          } else if (isCurrent) {
            circleColor = AppColors.lightSecondary;
            icon = Text(
              '$stepNum',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            );
          } else {
            circleColor = AppColors.lightDivider;
            icon = Text(
              '$stepNum',
              style: TextStyle(
                color: Colors.white,
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
                SizedBox(height: 6.h),
                Text(
                  s['title'] as String,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    color: isCurrent
                        ? AppColors.lightSecondary
                        : (isDone ? AppColors.lightTextPrimary : AppColors.lightTextSecondary),
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
