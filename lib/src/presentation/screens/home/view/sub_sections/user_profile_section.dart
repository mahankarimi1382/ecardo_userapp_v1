import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/tool_bar_section.dart';

/// v1.0.37 (HERO-CARD v2): minimal fintech header —
///   Row 1: user name (hero) + tappable verification tick/level chip
///   Row 2: UID pill (whole pill copies, ripple feedback)
/// The greeting line ("Hello · Good morning") was removed by product
/// decision, and the separate KYC row merged into the name-level chip.
class UserProfileSection extends StatelessWidget {
  const UserProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    final user = homeController.dashboardModel.value.data?.user;

    return Column(
      children: [
        SizedBox(height: 60),
        ToolBarSection(),
        SizedBox(height: 24),
        Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Soft decorative circles — the fintech "hero" texture.
            PositionedDirectional(
              top: -46,
              start: -34,
              child: _decorCircle(150, AppColors.white.withValues(alpha: 0.07)),
            ),
            PositionedDirectional(
              top: 30,
              end: -50,
              child: _decorCircle(120, AppColors.white.withValues(alpha: 0.05)),
            ),
            PositionedDirectional(
              bottom: -70,
              start: 60,
              child: _decorCircle(170, AppColors.lightPrimaryDark.withValues(alpha: 0.35)),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + verification tick/level chip — the KYC indicator
                  // lives exactly here, opposite the name.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          user?.userName ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            letterSpacing: 0,
                            fontSize: 26.sp,
                            height: 1.15,
                            color: AppColors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      _KycStatusBadge(homeController: homeController),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  // UID pill — the whole pill is tappable (copies), with an
                  // explicit copy affordance on the trailing edge.
                  _UidPill(accountNumber: user?.accountNumber ?? ""),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 65),
      ],
    );
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// UID (account number) pill — full-width, generous touch target: tapping
/// anywhere on the pill copies the number (InkWell ripple), with an
/// explicit copy affordance on the trailing edge.
class _UidPill extends StatelessWidget {
  final String accountNumber;

  const _UidPill({required this.accountNumber});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Material(
      color: AppColors.white.withValues(alpha: 0.13),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Clipboard.setData(ClipboardData(text: accountNumber));
          ToastHelper().showSuccessToast(localization.userProfileCopied);
        },
        child: Container(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.tag_rounded,
                  color: AppColors.white.withValues(alpha: 0.85),
                  size: 14,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                localization.userProfileUid,
                style: TextStyle(
                  letterSpacing: 0,
                  fontSize: 11.sp,
                  color: AppColors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  accountNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w800,
                    fontSize: 15.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Icon(
                Icons.copy_rounded,
                size: 16,
                color: AppColors.white.withValues(alpha: 0.85),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The verification indicator opposite the user name: tick/level chip.
/// Tiered (kyc_level) when available — "Level n" with an escalating shield
/// icon; legacy payloads fall back to an icon-only chip. Tapping it opens
/// the verification hub (KYC history).
class _KycStatusBadge extends StatelessWidget {
  final HomeController homeController;

  const _KycStatusBadge({required this.homeController});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final data = homeController.userModel.value.data;
    final level = data?.kycLevel;

    return GestureDetector(
      onTap: () => Get.toNamed(BaseRoute.kycHistory),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.38),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon(level, data?.kyc ?? 0), color: Colors.white, size: 14.sp),
            if (level != null) ...[
              SizedBox(width: 5.w),
              Text(
                localization?.kycUpgradeLevelChip(level) ?? 'Level $level',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ],
            SizedBox(width: 4.w),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.white.withValues(alpha: 0.6),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon(int? level, int legacyKyc) {
    if (level != null) {
      switch (level) {
        case 3:
          return Icons.verified_rounded;
        case 2:
          return Icons.verified_user_rounded;
        case 1:
          return Icons.verified_user_outlined;
        default:
          return Icons.shield_outlined;
      }
    }
    switch (legacyKyc) {
      case 1:
        return Icons.verified_rounded;
      case 2:
        return Icons.hourglass_top_rounded;
      case 3:
        return Icons.error_outline_rounded;
      default:
        return Icons.shield_outlined;
    }
  }
}
