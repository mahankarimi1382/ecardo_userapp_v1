import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/presentation/screens/gift_code/controller/create_gift_controller.dart';
import 'package:ecardo_user/src/presentation/screens/gift_code/controller/gift_code_controller.dart';
import 'package:ecardo_user/src/presentation/screens/gift_code/controller/gift_history_controller.dart';
import 'package:ecardo_user/src/presentation/screens/gift_code/controller/gift_redeem_controller.dart';
import 'package:ecardo_user/src/presentation/screens/gift_code/view/sub_sections/gift_history_filter_bottom_sheet.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';

class GiftCodeHeaderSection extends StatelessWidget {
  const GiftCodeHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final GiftCodeController controller = Get.find<GiftCodeController>();
    final HomeController homeController = Get.find<HomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Image.asset(
          PngAssets.headerFrame,
          color: isDark ? AppColors.darkSurfaceVariant.withValues(alpha: 0.3) : null,
          errorBuilder: (_, _, _) => const SizedBox(height: 140),
        ),
        Column(
          children: [
            const SizedBox(height: 60),
            Obx(
              () => CommonAppBar(
                title: localizations.giftCodeHeaderTitle,
                isBackLogicApply: true,
                backLogicFunction: () {
                  if (homeController.selectedIndex.value == 2) {
                    Get.delete<GiftCodeController>();
                    Get.delete<GiftRedeemController>();
                    Get.delete<GiftHistoryController>();
                    Get.delete<CreateGiftController>();
                    homeController.selectedIndex.value = 0;
                  } else if (homeController.selectedIndex.value == 0) {
                    Get.delete<GiftCodeController>();
                    Get.delete<GiftRedeemController>();
                    Get.delete<GiftHistoryController>();
                    Get.delete<CreateGiftController>();
                    Get.back();
                  }
                },
                rightSideWidget: controller.selectedScreen.value == 1
                    ? GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Get.bottomSheet(const GiftHistoryFilterBottomSheet());
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          margin: const EdgeInsetsDirectional.only(end: AppSpacing.lg),
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : AppColors.white,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                          child: Image.asset(
                            PngAssets.commonGiftFilterIcon,
                            color: isDark ? AppColors.mainSoftBlue : null,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsetsDirectional.only(end: AppSpacing.lg),
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          tooltip: 'Options',
                          onPressed: () => _buildHistoryNavigation(context, isDark),
                          icon: Icon(
                            Icons.more_vert,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.lg),
              child: Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: CommonButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          controller.selectedScreen.value = 0;
                        },
                        width: double.infinity,
                        text: localizations.giftCodeHeaderGiftRedeem,
                        fontSize: 15,
                        backgroundColor: controller.selectedScreen.value == 0
                            ? (isDark ? AppColors.mainSoftBlue : AppColors.deepBlack)
                            : (isDark ? AppColors.darkCard : AppColors.white),
                        textColor: controller.selectedScreen.value == 0
                            ? (isDark ? AppColors.deepBlack : AppColors.white)
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary.withValues(alpha: 0.8)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: CommonButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          controller.selectedScreen.value = 1;
                        },
                        width: double.infinity,
                        text: localizations.giftCodeHeaderMyGift,
                        fontSize: 15,
                        backgroundColor: controller.selectedScreen.value != 0
                            ? (isDark ? AppColors.mainSoftBlue : AppColors.deepBlack)
                            : (isDark ? AppColors.darkCard : AppColors.white),
                        textColor: controller.selectedScreen.value != 0
                            ? (isDark ? AppColors.deepBlack : AppColors.white)
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary.withValues(alpha: 0.8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _buildHistoryNavigation(BuildContext context, bool isDark) {
    final localizations = AppLocalizations.of(context)!;
    Get.bottomSheet(
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(AppSpacing.radiusXl),
            topEnd: Radius.circular(AppSpacing.radiusXl),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkTextSecondary.withValues(alpha: 0.4)
                      : AppColors.lightTextPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                leading: Icon(
                  Icons.receipt_long_rounded,
                  color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                ),
                title: Text(
                  localizations.giftCodeHeaderGiftRedeemHistory,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                ),
                onTap: () {
                  Get.back();
                  Get.toNamed(BaseRoute.giftRedeemHistory);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
