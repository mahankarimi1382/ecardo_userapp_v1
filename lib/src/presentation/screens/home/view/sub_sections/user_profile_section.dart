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

/// v1.0.36 (HERO-CARD): the greeting header redesigned to fintech standard —
/// compact greeting line, prominent name, glassy tiered-verification chip,
/// a clean UID pill and a verification progress row. The decorative PNG
/// shape was replaced with soft circles + a brand gradient, so the card
/// reads like a modern wallet app instead of a stretched bitmap.
class UserProfileSection extends StatelessWidget {
  const UserProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final HomeController homeController = Get.find<HomeController>();
    final user = homeController.dashboardModel.value.data?.user;

    return Column(
      children: [
        SizedBox(height: 60),
        ToolBarSection(),
        SizedBox(height: 22),
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
                  // Greeting — one compact line: "Hello · Good morning"
                  Text(
                    _greetingLine(homeController, localization),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontSize: 13.sp,
                      color: AppColors.white.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Name + verification tier chip
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user?.userName ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            letterSpacing: 0,
                            fontSize: 24.sp,
                            color: AppColors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      _KycStatusBadge(homeController: homeController),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // UID pill
                  _UidPill(accountNumber: user?.accountNumber ?? ""),
                  SizedBox(height: 10.h),
                  // Verification progress row
                  _KycProgressRow(homeController: homeController),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 65),
      ],
    );
  }

  String _greetingLine(
    HomeController homeController,
    AppLocalizations localization,
  ) {
    final wish =
        homeController.dashboardModel.value.data?.info?.timeWiseWish ?? "";
    final hello = localization.userProfileHello;
    if (wish.isEmpty) return hello;
    return "$hello  ·  $wish";
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// UID (account number) pill — label, value and copy action in one clean
/// glassy row. Material icons only, consistent with the rest of the app.
class _UidPill extends StatelessWidget {
  final String accountNumber;

  const _UidPill({required this.accountNumber});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.tag_rounded, color: AppColors.white.withValues(alpha: 0.7), size: 15),
          SizedBox(width: 6.w),
          Text(
            localization.userProfileUid,
            style: TextStyle(
              letterSpacing: 0,
              fontSize: 11.sp,
              color: AppColors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              accountNumber,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                letterSpacing: 0.3,
                fontWeight: FontWeight.w800,
                fontSize: 14.sp,
                color: AppColors.white,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: accountNumber));
              ToastHelper().showSuccessToast(localization.userProfileCopied);
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.copy_rounded,
                size: 14,
                color: AppColors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Verification tier row — icon, localized level label, 3-segment progress
/// and a chevron. Taps through to the KYC history/verification hub.
/// Renders the tiered kyc_level when the server provides it; falls back to
/// the legacy int status otherwise.
class _KycProgressRow extends StatelessWidget {
  final HomeController homeController;

  const _KycProgressRow({required this.homeController});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final data = homeController.userModel.value.data;
    final level = data?.kycLevel;

    return GestureDetector(
      onTap: () => Get.toNamed(BaseRoute.kycHistory),
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              _icon(level, data?.kyc ?? 0),
              color: Colors.white,
              size: 15,
            ),
            SizedBox(width: 7.w),
            Expanded(
              child: Text(
                _label(level, data?.kyc ?? 0, localization),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.white.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _LevelProgressBar(level: level),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.white.withValues(alpha: 0.55),
              size: 18,
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
        return Icons.verified_user_rounded;
      case 2:
        return Icons.hourglass_top_rounded;
      case 3:
        return Icons.error_outline_rounded;
      default:
        return Icons.shield_outlined;
    }
  }

  String _label(int? level, int legacyKyc, AppLocalizations localization) {
    if (level != null) return localization.kycUpgradeLevelChip(level);
    switch (legacyKyc) {
      case 1:
        return localization.kycStatusVerified;
      case 2:
        return localization.kycStatusPending;
      case 3:
        return localization.kycStatusRejected;
      default:
        return localization.kycStatusNotSubmitted;
    }
  }
}

/// Three-segment progress for the tiered verification level (0..3).
/// Hidden entirely for legacy payloads without kyc_level.
class _LevelProgressBar extends StatelessWidget {
  final int? level;

  const _LevelProgressBar({required this.level});

  @override
  Widget build(BuildContext context) {
    final current = level;
    if (current == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < current;
        return Container(
          width: 16,
          height: 4,
          margin: const EdgeInsetsDirectional.only(end: 3),
          decoration: BoxDecoration(
            color: filled
                ? Colors.white
                : AppColors.white.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

/// Small badge showing the verification tier next to the user name — a
/// glassy "Level n" pill. Legacy payloads fall back to an icon-only chip.
class _KycStatusBadge extends StatelessWidget {
  final HomeController homeController;

  const _KycStatusBadge({required this.homeController});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final data = homeController.userModel.value.data;
    final level = data?.kycLevel;

    if (level == null) {
      final kyc = data?.kyc ?? 0;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(_legacyIcon(kyc), color: AppColors.white, size: 14.sp),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_levelIcon(level), color: Colors.white, size: 13.sp),
          SizedBox(width: 4.w),
          Text(
            localization?.kycUpgradeLevelChip(level) ?? 'Level $level',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  IconData _legacyIcon(int kyc) {
    switch (kyc) {
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

  IconData _levelIcon(int level) {
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
}
