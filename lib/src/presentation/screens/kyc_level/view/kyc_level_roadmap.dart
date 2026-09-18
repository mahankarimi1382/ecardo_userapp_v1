import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/model/kyc_level_model.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/view/kyc_labels.dart';

/// KycLevelRoadmap — نمایش بصری سطوح KYC به‌صورت کارت‌های افقی
///
/// هر کارت شامل:
///   - شماره سطح + آیکون
///   - نام سطح
///   - وضعیت (✓ تکمیل‌شده / ⏳ فعلی / 🔒 قفل / ⚠ ردشده)
///   - مدارک لازم (اگر قابل دسترسی یا فعلی است)
///
/// استفاده:
///   KycLevelRoadmap()  — در صفحه‌ی ID Verification یا Settings
class KycLevelRoadmap extends StatelessWidget {
  final VoidCallback? onLevelTap;

  const KycLevelRoadmap({super.key, this.onLevelTap});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<KycLevelController>();
    final localization = AppLocalizations.of(context);

    return Obx(() {
      if (controller.isLoading.value && controller.levels.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.levels.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Text(
              localization?.kycRoadmapTitle ?? 'Verification roadmap',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // لیست سطوح
          ...controller.levels.map((level) => _LevelCard(
                level: level,
                onTap: onLevelTap,
              )),

          // دکمه‌ی ادامه‌ی احراز هویت (اگر سطح بعدی موجود است)
          if (controller.nextLevel != null && !controller.isPending) ...[
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: onLevelTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPrimary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    localization?.kycRoadmapContinueForLevel(
                          controller.nextLevel!.level,
                        ) ??
                        'Continue verification — level ${controller.nextLevel!.level}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // پیام در حال بررسی
          if (controller.isPending) ...[
            SizedBox(height: 12.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 18.w),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.warningContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.hourglass_top, color: AppColors.warning, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      localization?.kycRoadmapPending ??
                          'Your documents are under review. This usually takes 1–2 business days.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // پیام رد شدن
          if (controller.isRejected) ...[
            SizedBox(height: 12.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 18.w),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _rejectedText(localization, controller),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }

  /// Rejection message: server reason when present, localized guidance
  /// otherwise — both halves localized.
  String _rejectedText(AppLocalizations? localization,
      KycLevelController controller) {
    final title = localization?.kycRoadmapRejectedTitle ??
        'Your verification was rejected.';
    final reason = controller.status.value?.rejectionReason;
    if (reason != null && reason.isNotEmpty) return '$title $reason';
    return '$title ${localization?.kycRoadmapRejectedAction ?? "Please resubmit your documents."}';
  }
}

/// کارت یک سطح KYC
class _LevelCard extends StatelessWidget {
  final KycLevel level;
  final VoidCallback? onTap;

  const _LevelCard({required this.level, this.onTap});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final color = Color(level.colorValue);
    final statusColor = _statusColor(level, color);
    final statusIcon = _statusIcon(level);

    return GestureDetector(
      onTap: level.isAvailable ? onTap : null,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h, left: 18.w, right: 18.w),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: level.isLocked ? AppColors.lightBackground : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: level.isCurrent ? color : AppColors.lightBorder,
            width: level.isCurrent ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // شماره سطح / آیکون وضعیت
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: statusColor, width: 2),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),

            // اطلاعات سطح
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'سطح ${level.level}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      // badge وضعیت
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _statusLabel(level, localization),
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    level.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: level.isLocked
                          ? AppColors.lightTextHint
                          : AppColors.lightTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (level.description.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      level.description,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.lightTextSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  // مدارک لازم (فقط برای سطح فعلی یا قابل دسترسی)
                  if ((level.isCurrent || level.isAvailable) &&
                      level.requiredDocs.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 4.w,
                      runSpacing: 4.h,
                      children: level.requiredDocs.map((doc) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.lightBackground,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            // v1.1 (KYC-DOC): shared localized helper —
                            // unknown per-country keys render readably,
                            // never crash.
                            KycDocLabels.label(localization, doc),
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: AppColors.lightTextSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  // v1.1 (KYC-LIM): per-level transaction limits — rendered
                  // from the server's limits map for the next actionable
                  // level. No local capping logic: enforcement stays
                  // server-side and its errors flow through the unified
                  // KYC error contract.
                  if (level.isAvailable && level.limits.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    _LimitsSection(localization: localization, level: level),
                  ],
                ],
              ),
            ),

            // آیکون قفل / فلش
            if (level.isLocked)
              Icon(Icons.lock_outline, color: AppColors.lightTextHint, size: 18.sp)
            else if (level.isAvailable)
              Icon(Icons.chevron_right, color: color, size: 22.sp),
          ],
        ),
      ),
    );
  }

  Color _statusColor(KycLevel level, Color levelColor) {
    if (level.isCompleted) return AppColors.success;
    if (level.isCurrent) return levelColor;
    if (level.isAvailable) return AppColors.info;
    return AppColors.lightTextHint;
  }

  IconData _statusIcon(KycLevel level) {
    if (level.isCompleted) return Icons.check_circle;
    if (level.isCurrent) return Icons.play_circle;
    if (level.isAvailable) return Icons.lock_open;
    return Icons.lock;
  }

  String _statusLabel(KycLevel level, AppLocalizations? localization) {
    if (level.isCompleted) {
      return localization?.kycRoadmapStatusCompleted ?? 'Completed';
    }
    if (level.isCurrent) {
      return localization?.kycRoadmapStatusCurrent ?? 'Current';
    }
    if (level.isAvailable) {
      return localization?.kycRoadmapStatusAvailable ?? 'Ready to upgrade';
    }
    return localization?.kycRoadmapStatusLocked ?? 'Locked';
  }
}

/// v1.1 (KYC-LIM): per-level limits section — generalizes the classic
/// min/max display pattern to every limit key the server defines.
class _LimitsSection extends StatelessWidget {
  final AppLocalizations? localization;
  final KycLevel level;

  const _LimitsSection({required this.localization, required this.level});

  @override
  Widget build(BuildContext context) {
    final rows = KycLimitLabels.rows(localization, level.limits);
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization?.kycLimitsSectionTitle ?? 'Transaction limits',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Wrap(
            spacing: 4.w,
            runSpacing: 4.h,
            children: rows
                .map(
                  (row) => Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.lightBorder),
                    ),
                    child: Text(
                      row.measureLabel == null
                          ? '${row.groupLabel}: ${row.value}'
                          : '${row.groupLabel} — ${row.measureLabel}: ${row.value}',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
