import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/presentation/screens/payment_links/controller/payment_links_controller.dart';
import 'package:ecardo_user/src/presentation/screens/payment_links/view/sub_sections/payment_links_history_filter_bottom_sheet.dart';

class PaymentLinksHeaderSection extends StatelessWidget {
  const PaymentLinksHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final PaymentLinksController controller = Get.find();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Image.asset(PngAssets.headerFrame),
        Column(
          children: [
            const SizedBox(height: 60),
            Obx(
              () => CommonAppBar(
                title: localizations.paymentLinksAppBarTitle,
                isBackLogicApply: true,
                backLogicFunction: () => Get.back(),
                rightSideWidget: controller.selectedScreen.value == 0
                    ? InkWell(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Get.bottomSheet(
                            const PaymentLinksHistoryFilterBottomSheet(),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          margin: const EdgeInsetsDirectional.only(
                            end: AppSpacing.page,
                          ),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: Image.asset(
                            PngAssets.commonGiftFilterIcon,
                            color: isDark ? AppColors.warmWhite : null,
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
                        text: localizations.paymentLinksTabList,
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
                        text: localizations.paymentLinksTabCreate,
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
}
