import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';

class CreateAdEligibilityFailedSection extends StatelessWidget {
  final List<String> reasons;

  const CreateAdEligibilityFailedSection({super.key, required this.reasons});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final safeReasons = reasons.where((e) => e.trim().isNotEmpty).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.warning),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0.r),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                    height: 37.h,
                    width: 37.w,
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 22.w,
                      color: AppColors.white,
                    ),
                  ),

                  SizedBox(width: 15.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization.p2pEligibilityValidationFailed,
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            color: AppColors.lightTextPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          localization.p2pPleaseFulfillRequirements,
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.warning, thickness: 2),

            Padding(
              padding: EdgeInsets.all(16.0.r),
              child: Column(
                children: [
                  if (safeReasons.isEmpty)
                    Text(
                      localization.p2pNotEligibleCreateAd,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                        color: AppColors.lightTextPrimary,
                      ),
                    )
                  else
                    ...safeReasons.map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Container(
                                width: 7.w,
                                height: 7.w,
                                decoration: const BoxDecoration(
                                  color: AppColors.lightTextPrimary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                  color: AppColors.lightTextPrimary,
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
          ],
        ),
      ),
    );
  }
}
