import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/presentation/screens/cash_out/controller/cash_out_controller.dart';
import 'package:ecardo_user/src/presentation/screens/cash_out/view/sub_sections/cash_out_amount_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/cash_out/view/sub_sections/cash_out_review_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/cash_out/view/sub_sections/cash_out_success_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/cash_out/view/sub_sections/cash_out_wallets_section.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          Get.offNamed(BaseRoute.navigation);
        }
      },
      child: Scaffold(
        appBar: const CommonDefaultAppBar(),
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
                        const SizedBox(height: AppSpacing.lg),
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
                                      end: AppSpacing.sm,
                                    ),
                                    child: IconButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      tooltip: localizations.cashOutHistory,
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        _buildHistoryNavigation(isDark);
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
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const CommonLoading();
                    }

                    if (controller.cashOutWalletsList.isEmpty ||
                        controller.wallet.value == null) {
                      return Center(
                        child: EcardoEmptyState(
                          title: localizations.cashOutWalletsNotFound,
                          description: localizations.allControllerLoadError,
                          primaryActionLabel:
                              localizations.noInternetConnectionRetryButton,
                          onPrimaryAction: () {
                            controller.fetchWallets();
                            controller.fetchUser();
                          },
                        ),
                      );
                    }

                    return controller.currentStep.value == 0
                        ? const Padding(
                            padding: EdgeInsetsDirectional.symmetric(
                              horizontal: AppSpacing.page,
                            ),
                            child: Column(
                              children: [
                                CashOutWalletsSection(),
                                SizedBox(height: AppSpacing.xxl),
                                CashOutAmountStepSection(),
                              ],
                            ),
                          )
                        : controller.currentStep.value == 1
                        ? const CashOutReviewStepSection()
                        : controller.currentStep.value == 2
                        ? const CashOutSuccessStepSection()
                        : const SizedBox.shrink();
                  }),
                ),
              ],
            ),
            Obx(
              () => Visibility(
                visible:
                    controller.isCashOutLoading.value ||
                    controller.isBeneficiaryLoading.value,
                child: const CommonLoading(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _buildHistoryNavigation(bool isDark) {
    final localizations = AppLocalizations.of(context)!;

    Get.bottomSheet(
      AnimatedContainer(
        width: double.infinity,
        duration: AppDurations.normal,
        curve: Curves.easeOutQuart,
        height: 160,
        margin: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
        ),
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
                  final items = [localizations.cashOutHistory];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Get.back();
                        if (index == 0) {
                          Get.toNamed(BaseRoute.cashOutHistory);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
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
