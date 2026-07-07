import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/cash_out/controller/cash_out_controller.dart';
import 'package:qunzo_user/src/presentation/screens/cash_out/view/sub_sections/cash_out_amount_step_section.dart';
import 'package:qunzo_user/src/presentation/screens/cash_out/view/sub_sections/cash_out_review_step_section.dart';
import 'package:qunzo_user/src/presentation/screens/cash_out/view/sub_sections/cash_out_success_step_section.dart';
import 'package:qunzo_user/src/presentation/screens/cash_out/view/sub_sections/cash_out_wallets_section.dart';

class CashOutScreen extends StatefulWidget {
  const CashOutScreen({super.key});

  @override
  State<CashOutScreen> createState() => _CashOutScreenState();
}

class _CashOutScreenState extends State<CashOutScreen> {
  final CashOutController controller = Get.find();
  final String aidAccount = Get.arguments?['aid_account'] ?? '';

  @override
  void initState() {
    super.initState();
    controller.agentAidController.text = aidAccount;
    controller.fetchWallets();
    controller.fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          Get.offNamed(BaseRoute.navigation);
        }
      },
      child: Scaffold(
        appBar: CommonDefaultAppBar(),
        body: Stack(
          children: [
            Column(
              children: [
                Obx(
                  () => Visibility(
                    visible:
                        controller.currentStep.value == 0 ||
                        controller.currentStep.value == 1,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Obx(
                          () => CommonAppBar(
                            title: localizations.cashOutTitle,
                            backLogicFunction: () async {
                              Get.offNamed(BaseRoute.navigation);
                            },
                            isBackLogicApply: true,
                            rightSideWidget: controller.currentStep.value == 0
                                ? Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      end: 8,
                                    ),
                                    child: IconButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        _buildHistoryNavigation();
                                      },
                                      icon: Icon(Icons.more_vert),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return CommonLoading();
                    }

                    return controller.currentStep.value == 0
                        ? Padding(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 18,
                            ),
                            child: Column(
                              children: [
                                CashOutWalletsSection(),
                                SizedBox(height: 30),
                                CashOutAmountStepSection(),
                              ],
                            ),
                          )
                        : controller.currentStep.value == 1
                        ? CashOutReviewStepSection()
                        : controller.currentStep.value == 2
                        ? CashOutSuccessStepSection()
                        : SizedBox();
                  }),
                ),
              ],
            ),
            Obx(
              () => Visibility(
                visible:
                    controller.isCashOutLoading.value ||
                    controller.isBeneficiaryLoading.value,
                child: CommonLoading(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _buildHistoryNavigation() {
    final localizations = AppLocalizations.of(context)!;

    Get.bottomSheet(
      AnimatedContainer(
        width: double.infinity,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        height: 160,
        margin: const EdgeInsetsDirectional.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(20),
            topEnd: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 40,
              spreadRadius: 0,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  final items = [localizations.cashOutHistory];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.back();

                        if (index == 0) {
                          Get.toNamed(BaseRoute.cashOutHistory);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        child: Text(
                          items[index],
                          style: TextStyle(
                            letterSpacing: 0,
                            color: AppColors.lightTextPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
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
