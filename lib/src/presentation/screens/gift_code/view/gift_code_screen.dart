import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/presentation/screens/gift_code/controller/create_gift_controller.dart';
import 'package:ecardo_user/src/presentation/screens/gift_code/controller/gift_code_controller.dart';
import 'package:ecardo_user/src/presentation/screens/gift_code/controller/gift_history_controller.dart';
import 'package:ecardo_user/src/presentation/screens/gift_code/controller/gift_redeem_controller.dart';
import 'package:ecardo_user/src/presentation/screens/gift_code/view/sub_sections/create_gift_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/gift_code/view/sub_sections/gift_code_header_section.dart';
import 'package:ecardo_user/src/presentation/screens/gift_code/view/sub_sections/gift_history.dart';
import 'package:ecardo_user/src/presentation/screens/gift_code/view/sub_sections/gift_redeem_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';

class GiftCodeScreen extends StatefulWidget {
  const GiftCodeScreen({super.key});

  @override
  State<GiftCodeScreen> createState() => _GiftCodeScreenState();
}

class _GiftCodeScreenState extends State<GiftCodeScreen> {
  final GiftCodeController controller = Get.find<GiftCodeController>();
  final GiftRedeemController redeemController = Get.find<GiftRedeemController>();
  final GiftHistoryController giftHistoryController =
      Get.find<GiftHistoryController>();
  final CreateGiftController createGiftController =
      Get.find<CreateGiftController>();
  final HomeController homeController = Get.find();

  @override
  void initState() {
    super.initState();
    clearFields();
  }

  void clearFields() {
    controller.selectedScreen.value = 0;
    redeemController.giftCodeController.clear();
    redeemController.isGiftCodeFocused.value = false;
    createGiftController.currentStep.value = 0;
    createGiftController.amountController.clear();
    createGiftController.isAmountFocused.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: homeController.selectedIndex.value != 2,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && homeController.selectedIndex.value == 2) {
          Get.delete<GiftCodeController>();
          Get.delete<GiftRedeemController>();
          Get.delete<GiftHistoryController>();
          Get.delete<CreateGiftController>();
          homeController.selectedIndex.value = 0;
        }
      },
      child: Obx(
        () => Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          resizeToAvoidBottomInset: false,
          appBar: createGiftController.currentStep.value == 1 ||
                  createGiftController.currentStep.value == 2
              ? CommonDefaultAppBar()
              : null,
          body: Stack(
            children: [
              Container(
                decoration: createGiftController.currentStep.value == 1
                    ? null
                    : BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [AppColors.darkSurface, AppColors.darkBackground]
                              : [AppColors.white, AppColors.lightBackground],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.26, 0.31],
                        ),
                      ),
                child: Column(
                  children: [
                    createGiftController.currentStep.value == 1
                        ? ColoredBox(
                            color: isDark
                                ? AppColors.darkBackground
                                : AppColors.lightBackground,
                            child: Column(
                              children: [
                                const SizedBox(height: AppSpacing.lg),
                                CommonAppBar(
                                  title: localizations.giftCodeTitle,
                                  isBackLogicApply: true,
                                  backLogicFunction: () {
                                    if (homeController.selectedIndex.value == 2) {
                                      Get.delete<GiftCodeController>();
                                      Get.delete<GiftRedeemController>();
                                      Get.delete<GiftHistoryController>();
                                      Get.delete<CreateGiftController>();
                                      homeController.selectedIndex.value = 0;
                                    } else {
                                      Get.delete<GiftCodeController>();
                                      Get.delete<GiftRedeemController>();
                                      Get.delete<GiftHistoryController>();
                                      Get.delete<CreateGiftController>();
                                      Get.back();
                                    }
                                  },
                                ),
                              ],
                            ),
                          )
                        : createGiftController.currentStep.value == 2
                        ? const SizedBox.shrink()
                        : const GiftCodeHeaderSection(),
                    controller.selectedScreen.value == 0
                        ? const SizedBox(height: AppSpacing.xxl)
                        : const SizedBox.shrink(),
                    controller.selectedScreen.value == 0
                        ? const GiftRedeemSection()
                        : controller.selectedScreen.value == 1
                        ? const GiftHistory()
                        : const CreateGiftStepSection(),
                  ],
                ),
              ),
              Visibility(
                visible: redeemController.isGiftRedeemLoading.value ||
                    createGiftController.isCreateGiftLoading.value,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: redeemController.isGiftRedeemLoading.value ? 100 : 0,
                  ),
                  child: const CommonLoading(),
                ),
              ),
            ],
          ),
          floatingActionButton: controller.selectedScreen.value == 1
              ? Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xxl),
                  child: SizedBox(
                    height: 48,
                    child: FloatingActionButton.extended(
                      heroTag: null,
                      elevation: 2,
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        controller.selectedScreen.value = 2;
                        await createGiftController.fetchWallets();
                        await createGiftController.fetchUser();
                      },
                      backgroundColor: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                      foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      icon: Image.asset(
                        PngAssets.addCommonIcon,
                        width: 20,
                        color: isDark ? AppColors.deepBlack : AppColors.white,
                      ),
                      label: Text(
                        localizations.giftCodeCreateGift,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: isDark ? AppColors.deepBlack : AppColors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
