import 'dart:ui' show FontFeature;
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

/// Account ID strip — premium, bank-app style: monospace number, subtle
/// gradient glass, clear copy affordance (tap anywhere).
class _UidPill extends StatelessWidget {
  final String accountNumber;

  const _UidPill({required this.accountNumber});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    // Group digits for readability when purely numeric (e.g. 12 345 678).
    final display = _formatAccountId(accountNumber);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Clipboard.setData(ClipboardData(text: accountNumber));
          ToastHelper().showSuccessToast(localization.userProfileCopied);
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.white.withValues(alpha: 0.18),
                AppColors.white.withValues(alpha: 0.08),
              ],
            ),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.22),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    color: AppColors.white.withValues(alpha: 0.16),
                  ),
                  child: Icon(
                    Icons.fingerprint_rounded,
                    size: 20,
                    color: AppColors.white.withValues(alpha: 0.92),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.userProfileUid.toUpperCase(),
                        style: TextStyle(
                          letterSpacing: 1.2,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white.withValues(alpha: 0.55),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        display,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w800,
                          fontSize: 16.sp,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 16,
                    color: AppColors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatAccountId(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return s;
    if (!RegExp(r'^[0-9]+$').hasMatch(s) || s.length < 6) return s;
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
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
      onTap: () => Get.toNamed(BaseRoute.idVerification),
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
