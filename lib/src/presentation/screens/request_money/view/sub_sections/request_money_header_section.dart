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
import 'package:ecardo_user/src/presentation/screens/request_money/controller/request_money_controller.dart';

class RequestMoneyHeaderSection extends StatelessWidget {
  const RequestMoneyHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final RequestMoneyController controller = Get.find();
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Image.asset(PngAssets.headerFrame),
        Column(
          children: [
            const SizedBox(height: 60),
            Obx(
              () => CommonAppBar(
                title: localization.requestMoneyHeaderSectionTitle,
                backLogicFunction: () async {
                  Get.offNamed(BaseRoute.navigation);
                },
                isBackLogicApply: true,
                rightSideWidget: controller.currentStep.value == 0
                    ? Padding(
                        padding: const EdgeInsetsDirectional.only(
                          end: AppSpacing.sm,
                        ),
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          tooltip: localization.requestMoneyHeaderSectionHistory,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _buildHistoryNavigation(context, isDark);
                          },
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: isDark
                                ? AppColors.warmWhite
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
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
                        text: localization
                            .requestMoneyHeaderSectionRequestMoneyButton,
                        fontSize: 14.5,
                        backgroundColor: controller.selectedScreen.value == 0
                            ? (isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary)
                            : (isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.white),
                        textColor: controller.selectedScreen.value == 0
                            ? (isDark
                                ? AppColors.deepBlack
                                : AppColors.white)
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary.withValues(alpha: 0.8)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: CommonButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          controller.selectedScreen.value = 1;
                        },
                        width: double.infinity,
                        text: localization
                            .requestMoneyHeaderSectionReceivedRequestButton,
                        fontSize: 14.5,
                        backgroundColor: controller.selectedScreen.value != 0
                            ? (isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary)
                            : (isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.white),
                        textColor: controller.selectedScreen.value != 0
                            ? (isDark
                                ? AppColors.deepBlack
                                : AppColors.white)
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
    final localization = AppLocalizations.of(context)!;

    Get.bottomSheet(
      AnimatedContainer(
        width: double.infinity,
        duration: AppDurations.normal,
        curve: Curves.easeOutQuart,
        height: 160,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(AppSpacing.radiusXl),
            topEnd: Radius.circular(AppSpacing.radiusXl),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: AppSpacing.xxl,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkTextSecondary.withValues(alpha: 0.3)
                    : AppColors.lightTextPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  final items = [localization.requestMoneyHeaderSectionHistory];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Get.back();
                        if (index == 0) {
                          Get.toNamed(BaseRoute.requestMoneyHistory);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.page,
                          vertical: AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: AppSpacing.iconSm,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              items[index],
                              style: TextStyle(
                                letterSpacing: 0,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
