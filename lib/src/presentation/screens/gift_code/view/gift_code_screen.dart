import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/controller/create_gift_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/controller/gift_code_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/controller/gift_history_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/controller/gift_redeem_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/view/sub_sections/create_gift_step_section.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/view/sub_sections/gift_code_header_section.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/view/sub_sections/gift_history.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/view/sub_sections/gift_redeem_section.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';

class GiftCodeScreen extends StatefulWidget {
  const GiftCodeScreen({super.key});

  @override
  State<GiftCodeScreen> createState() => _GiftCodeScreenState();
}

class _GiftCodeScreenState extends State<GiftCodeScreen> {
  final GiftCodeController controller = Get.put(GiftCodeController());
  final GiftRedeemController redeemController = Get.put(GiftRedeemController());
  final GiftHistoryController giftHistoryController = Get.put(
    GiftHistoryController(),
  );
  final CreateGiftController createGiftController = Get.put(
    CreateGiftController(),
  );
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
          resizeToAvoidBottomInset: false,
          appBar:
              createGiftController.currentStep.value == 1 ||
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
                          colors: [AppColors.white, AppColors.lightBackground],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.26, 0.31],
                        ),
                      ),
                child: Column(
                  children: [
                    createGiftController.currentStep.value == 1
                        ? ColoredBox(
                            color: AppColors.lightBackground,
                            child: Column(
                              children: [
                                SizedBox(height: 16),
                                CommonAppBar(
                                  title: localizations.giftCodeTitle,
                                  isBackLogicApply: true,
                                  backLogicFunction: () {
                                    if (homeController.selectedIndex.value ==
                                        2) {
                                      Get.delete<GiftCodeController>();
                                      Get.delete<GiftRedeemController>();
                                      Get.delete<GiftHistoryController>();
                                      Get.delete<CreateGiftController>();
                                      homeController.selectedIndex.value = 0;
                                    } else if (homeController
                                            .selectedIndex
                                            .value ==
                                        2) {
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
                        ? SizedBox.shrink()
                        : GiftCodeHeaderSection(),
                    controller.selectedScreen.value == 0
                        ? SizedBox(height: 30)
                        : SizedBox.shrink(),
                    controller.selectedScreen.value == 0
                        ? GiftRedeemSection()
                        : controller.selectedScreen.value == 1
                        ? GiftHistory()
                        : CreateGiftStepSection(),
                  ],
                ),
              ),
              Visibility(
                visible:
                    redeemController.isGiftRedeemLoading.value ||
                    createGiftController.isCreateGiftLoading.value,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: redeemController.isGiftRedeemLoading.value ? 100 : 0,
                  ),
                  child: CommonLoading(),
                ),
              ),
            ],
          ),
          floatingActionButton: controller.selectedScreen.value == 1
              ? Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 40),
                  child: SizedBox(
                    height: 48,
                    width: 140,
                    child: FloatingActionButton(
                      heroTag: null,
                      elevation: 0,
                      onPressed: () async {
                        controller.selectedScreen.value = 2;
                        await createGiftController.fetchWallets();
                        await createGiftController.fetchUser();
                      },
                      backgroundColor: AppColors.lightPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(PngAssets.addCommonIcon, width: 22),
                          SizedBox(width: 5),
                          Text(
                            localizations.giftCodeCreateGift,
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 15.5,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ),
      ),
    );
  }
}
