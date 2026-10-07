// DATA: REAL | MOCK | PLACEHOLDER | NOT-IMPLEMENTED
// UI design components for eCardo Travel Experiences (Boat, Dining, Local)
// Follows WCAG 2.2 AA accessibility, RTL+LTR safe, light & dark theme tokenized.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../models/experience_contracts.dart';

/// Accessible, cached network image with placeholder shimmer and fallback icon.
class ExperienceNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final IconData fallbackIcon;
  final String? semanticLabel;

  const ExperienceNetworkImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.fallbackIcon = Icons.image_outlined,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final validUrl = imageUrl != null &&
        imageUrl!.trim().isNotEmpty &&
        (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'));

    final placeholder = Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkCard : AppColors.greyLight.withValues(alpha: 0.3),
      highlightColor: isDark ? AppColors.darkSurface : AppColors.white,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
    );

    final fallbackWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(borderRadius.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Center(
        child: Icon(
          fallbackIcon,
          size: (height * 0.35).clamp(20.0, 48.0).sp,
          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        ),
      ),
    );

    if (!validUrl) {
      return Semantics(
        label: semanticLabel ?? 'تصویر موجود نیست',
        image: true,
        child: fallbackWidget,
      );
    }

    return Semantics(
      label: semanticLabel ?? 'تصویر خدمت',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius.r),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: width,
          height: height,
          fit: BoxFit.cover,
          placeholder: (_, _) => placeholder,
          errorWidget: (_, _, _) => fallbackWidget,
        ),
      ),
    );
  }
}

/// Shimmer skeleton list simulating catalog card loading.
class ExperienceCatalogSkeleton extends StatelessWidget {
  final int itemCount;

  const ExperienceCatalogSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w, vertical: AppSpacing.md.h),
      itemCount: itemCount,
      itemBuilder: (_, _) {
        return Shimmer.fromColors(
          baseColor: isDark ? AppColors.darkCard : const Color(0xFFE2E8F0),
          highlightColor: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
          child: Container(
            margin: EdgeInsets.only(bottom: AppSpacing.lg.h),
            height: 180.h,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radius.r),
            ),
          ),
        );
      },
    );
  }
}

/// Offline warning banner with auto-refresh retry action.
class ExperienceOfflineBanner extends StatelessWidget {
  final VoidCallback onRetry;

  const ExperienceOfflineBanner({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: 8.h),
      color: AppColors.warning.withValues(alpha: 0.15),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 16.sp, color: AppColors.warning),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              l10nPick(
                context,
                fa: 'اتصال اینترنت قطع است — نمایش کاتالوگ آفلاین',
                en: 'Offline mode — displaying cached experiences',
                ar: 'وضع غير متصل — عرض البيانات المخزنة',
              ),
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              onRetry();
            },
            style: TextButton.styleFrom(
              minimumSize: const Size(44, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10nPick(context, fa: 'تلاش مجدد', en: 'Retry', ar: 'إعادة المحاولة'),
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Accessible empty state view with reset action.
class ExperienceEmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onReset;

  const ExperienceEmptyView({
    super.key,
    this.icon = Icons.search_off_rounded,
    required this.title,
    required this.subtitle,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.xl.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.xl.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightSurfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48.sp, color: AppColors.greyLight),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
                foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                elevation: 0,
                minimumSize: Size(140.w, 44.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                onReset();
              },
              child: Text(
                l10nPick(context, fa: 'حذف فیلترها و مشاهده همه', en: 'Clear Filters & Show All'),
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Accessible error state view with retry action.
class ExperienceErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ExperienceErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48.sp, color: AppColors.error),
            SizedBox(height: 12.h),
            Text(
              l10nPick(context, fa: 'خطا در برقراری ارتباط', en: 'Connection Error'),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10nPick(context, fa: 'تلاش مجدد', en: 'Retry')),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(120.w, 44.h),
                backgroundColor: AppColors.lightPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                onRetry();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Cancellation confirmation bottom sheet showing penalty & matching-wallet refund calculation.
Future<bool?> showExperienceCancellationSheet({
  required BuildContext context,
  required String bookingId,
  required String title,
  required ExperienceRefundCalculation calculation,
  required Future<bool> Function(String reason) onConfirmCancellation,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl.r)),
    ),
    builder: (ctx) {
      String selectedReason = 'تغییر برنامه سفر (Change of Travel Plans)';

      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl.w,
              AppSpacing.lg.h,
              AppSpacing.xl.w,
              MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.greyLight,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'درخواست لغو رزرو و استرداد وجه',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                SizedBox(height: 16.h),

                // Refund details card
                Container(
                  padding: EdgeInsets.all(AppSpacing.md.r),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      _refundRow(
                        'مبلغ پرداخت‌شده:',
                        '${calculation.originalAmount.toStringAsFixed(0)} ${calculation.currency}',
                        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        isDark,
                      ),
                      SizedBox(height: 8.h),
                      _refundRow(
                        'جریمه کنسلی:',
                        '- ${calculation.penaltyAmount.toStringAsFixed(0)} ${calculation.currency}',
                        AppColors.error,
                        isDark,
                      ),
                      const Divider(),
                      _refundRow(
                        'مبلغ قابل استرداد به کیف پول:',
                        '+ ${calculation.refundableAmount.toStringAsFixed(0)} ${calculation.refundDestinationWalletCurrency}',
                        AppColors.success,
                        isDark,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                Text(
                  calculation.policySummary,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16.h),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 44.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('انصراف'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 44.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx, true);
                          await onConfirmCancellation(selectedReason);
                        },
                        child: const Text(
                          'تأیید و لغو بلیت',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _refundRow(String label, String value, Color valueColor, bool isDark,
    {bool isBold = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 11.5.sp,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: isBold ? 14.sp : 12.sp,
          fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
          color: valueColor,
        ),
      ),
    ],
  );
}
