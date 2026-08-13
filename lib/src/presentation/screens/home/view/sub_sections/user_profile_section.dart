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
                            .data!
                            .info!
                            .timeWiseWish ??
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
                          homeController.dashboardModel.value.data!.user!.userName ?? "",
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
              // KYC detail row — shows current step + tap to go to verification
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
                        _kycIcon(homeController.userModel.value.data?.kyc ?? 0),
                        color: _kycColor(homeController.userModel.value.data?.kyc ?? 0),
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _kycLabel(homeController.userModel.value.data?.kyc ?? 0, localization),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  Color _kycColor(int kyc) {
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

  IconData _kycIcon(int kyc) {
    switch (kyc) {
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
}

/// Small badge showing KYC status next to the user name.
class _KycStatusBadge extends StatelessWidget {
  final HomeController homeController;

  const _KycStatusBadge({required this.homeController});

  @override
  Widget build(BuildContext context) {
    final kyc = homeController.userModel.value.data?.kyc ?? 0;
    final color = _color(kyc);
    final icon = _icon(kyc);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.white, size: 14.sp),
          SizedBox(width: 3.w),
          Text(
            _shortLabel(kyc),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _color(int kyc) {
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

  IconData _icon(int kyc) {
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

  String _shortLabel(int kyc) {
    switch (kyc) {
      case 1:
        return '✓';
      case 2:
        return '⏳';
      case 3:
        return '✗';
      default:
        return '!';
    }
  }
}
