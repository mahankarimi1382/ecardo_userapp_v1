import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/tool_bar_section.dart';

class UserProfileSection extends StatelessWidget {
  const UserProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final HomeController homeController = Get.find<HomeController>();

    return Column(
      children: [
        SizedBox(height: 60),
        ToolBarSection(),
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(PngAssets.homeUserShape),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting + wish
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.userProfileHello,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontSize: 15,
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    homeController
                            .dashboardModel
                            .value
                            .data
                            ?.info
                            ?.timeWiseWish ??
                        "",
                    style: TextStyle(
                      letterSpacing: 0,
                      fontSize: 15,
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // User name + KYC badge in same row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          homeController.dashboardModel.value.data?.user?.userName ?? "",
                          maxLines: 2,
                          style: TextStyle(
                            letterSpacing: 0,
                            fontSize: 28.sp,
                            color: AppColors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _KycStatusBadge(homeController: homeController),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15),
              // UID with copy button
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 5),
                        child: Text(
                          "${localization.userProfileUid} ${homeController.dashboardModel.value.data!.user!.accountNumber}",
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: homeController
                                .dashboardModel
                                .value
                                .data!
                                .user!
                                .accountNumber!,
                          ),
                        );
                        ToastHelper().showSuccessToast(
                          localization.userProfileCopied,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          PngAssets.copyCommonIcon,
                          width: 20,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // KYC tier row — level progress + tap to verification history.
              // Uses the tiered kyc_level (0..3) when the server provides
              // it; falls back to the legacy int status otherwise.
              SizedBox(height: 10),
              GestureDetector(
                onTap: () => Get.toNamed(BaseRoute.kycHistory),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _kycIcon(
                          homeController.userModel.value.data?.kycLevel ??
                              homeController.userModel.value.data?.kyc ??
                              0,
                          homeController.userModel.value.data?.kycLevel != null,
                        ),
                        color: _kycColor(
                          homeController.userModel.value.data?.kycLevel ??
                              homeController.userModel.value.data?.kyc ??
                              0,
                          homeController.userModel.value.data?.kycLevel != null,
                        ),
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _kycRowLabel(homeController, localization),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _LevelProgressBar(
                        level: homeController.userModel.value.data?.kycLevel,
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: AppColors.white.withValues(alpha: 0.5), size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 65),
      ],
    );
  }

  // ── KYC helpers ──
  //
  // `isTiered` — the server answered with the tiered kyc_level system
  // (0..3). The legacy int field (0 none / 1 verified / 2 pending /
  // 3 rejected) predates the level system and misreports tiered users
  // (fresh signups carry kyc=4), so it is only consulted when the server
  // has not sent kyc_level.

  Color _kycColor(int value, bool isTiered) {
    if (isTiered) return _levelColor(value);
    switch (value) {
      case 1:
        return AppColors.success;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  IconData _kycIcon(int value, bool isTiered) {
    if (isTiered) return _levelIcon(value);
    switch (value) {
      case 1:
        return Icons.verified_user;
      case 2:
        return Icons.hourglass_top;
      case 3:
        return Icons.error_outline;
      default:
        return Icons.shield_outlined;
    }
  }

  String _kycLabel(int kyc, AppLocalizations l) {
    switch (kyc) {
      case 1:
        return l.kycStatusVerified;
      case 2:
        return l.kycStatusPending;
      case 3:
        return l.kycStatusRejected;
      default:
        return l.kycStatusNotSubmitted;
    }
  }

  String _kycRowLabel(
    HomeController homeController,
    AppLocalizations localization,
  ) {
    final data = homeController.userModel.value.data;
    final level = data?.kycLevel;
    if (level != null) {
      return localization.kycUpgradeLevelChip(level);
    }
    return _kycLabel(data?.kyc ?? 0, localization);
  }

  Color _levelColor(int level) {
    switch (level) {
      case 3:
        return AppColors.success;
      case 2:
        return AppColors.success;
      case 1:
        return AppColors.white;
      default:
        return AppColors.warning;
    }
  }

  IconData _levelIcon(int level) {
    switch (level) {
      case 3:
        return Icons.verified;
      case 2:
        return Icons.verified_user;
      case 1:
        return Icons.verified_user_outlined;
      default:
        return Icons.shield_outlined;
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
          width: 14,
          height: 4,
          margin: const EdgeInsetsDirectional.only(end: 3),
          decoration: BoxDecoration(
            color: filled
                ? AppColors.success
                : AppColors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

/// Small badge showing the verification tier next to the user name.
/// Tiered (kyc_level) when available — a "Level n" chip with an escalating
/// shield icon. Legacy payloads fall back to an icon-only status chip
/// (the previous emoji glyphs were non-standard).
class _KycStatusBadge extends StatelessWidget {
  final HomeController homeController;

  const _KycStatusBadge({required this.homeController});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final data = homeController.userModel.value.data;
    final level = data?.kycLevel;

    if (level == null) {
      // Legacy fallback: icon-only chip, no emoji text.
      final kyc = data?.kyc ?? 0;
      final color = _legacyColor(kyc);
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        ),
        child: Icon(_legacyIcon(kyc), color: AppColors.white, size: 14.sp),
      );
    }

    final color = _levelColor(level);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.7), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_levelIcon(level), color: color, size: 13.sp),
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

  Color _legacyColor(int kyc) {
    switch (kyc) {
      case 1:
        return AppColors.success;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  IconData _legacyIcon(int kyc) {
    switch (kyc) {
      case 1:
        return Icons.verified;
      case 2:
        return Icons.hourglass_top;
      case 3:
        return Icons.error;
      default:
        return Icons.shield;
    }
  }

  Color _levelColor(int level) {
    switch (level) {
      case 3:
        return AppColors.success;
      case 2:
        return AppColors.success;
      case 1:
        return AppColors.white;
      default:
        return AppColors.warning;
    }
  }

  IconData _levelIcon(int level) {
    switch (level) {
      case 3:
        return Icons.verified;
      case 2:
        return Icons.verified_user;
      case 1:
        return Icons.verified_user_outlined;
      default:
        return Icons.shield_outlined;
    }
  }
}
