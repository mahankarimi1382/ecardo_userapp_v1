import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/controller/gift_card_controller.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/view/sub_sections/gift_card_filter_bottom_sheet.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/view/sub_sections/gift_card_history_filter_bottom_sheet.dart';

class GiftCardHeaderSection extends StatelessWidget {
  const GiftCardHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final GiftCardController controller = Get.find<GiftCardController>();
    final localization = AppLocalizations.of(context)!;
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
                title: localization.giftCardHeaderTitle,
                isBackLogicApply: true,
                backLogicFunction: () => Get.back(),
                rightSideWidget: controller.selectedScreen.value == 0 ||
                        controller.selectedScreen.value == 1
                    ? GestureDetector(
                        onTap: controller.selectedScreen.value == 0
                            ? () {
                                HapticFeedback.lightImpact();
                                Get.bottomSheet(const GiftCardFilterBottomSheet());
                              }
                            : () {
                                HapticFeedback.lightImpact();
                                Get.bottomSheet(
                                  const GiftCardHistoryFilterBottomSheet(),
                                );
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            PngAssets.commonGiftFilterIcon,
                            color: isDark ? AppColors.mainSoftBlue : null,
                          ),
                        ),
                      )
                    : null,
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
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          controller.selectedScreen.value = 0;
                          controller.clearInitialData();
                        },
                        width: double.infinity,
                        text: localization.giftCardHeaderTabCards,
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
                        text: localization.giftCardHeaderTabHistory,
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
}
