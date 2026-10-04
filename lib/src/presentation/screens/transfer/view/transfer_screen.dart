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
import 'package:ecardo_user/src/presentation/screens/beneficiary/controller/create_beneficiary_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/controller/transfer_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/sub_sections/transfer_amount_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/sub_sections/transfer_review_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/sub_sections/transfer_success_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/sub_sections/transfer_wallet_section.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/widgets/transfer_step_indicator.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  // M-1 — Get.put is LOAD-BEARING here, not a redundant duplicate:
  // TransferBinding only `lazyPut`s the controller, and navigation_screen
  // deletes it every time the user leaves the transfer tab — the registry
  // entry is already gone when the tab is re-entered, so a plain
  // Get.find() would crash. The view re-registration is what keeps the
  // bottom-nav tab lifecycle working (GetX `put` returns the registered
  // instance when one exists, so both entry paths stay consistent).
  final TransferController controller = Get.put(TransferController());
  final HomeController homeController = Get.find();

  @override
  void initState() {
    super.initState();
    if (!controller.isInitialized.value) {
      controller.currentStep.value = 0;
      controller.clearFields();
      controller.isRecipientUidFocused.value = false;
      controller.isAmountFocused.value = false;
      controller.fetchTransferWallets();
      controller.fetchUser();
      controller.fetchTransferConfig();
      controller.fetchBeneficiary();
      controller.isInitialized.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    if (localization == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        if (controller.currentStep.value == 1) {
          controller.currentStep.value = 0;
          return;
        }

        if (homeController.selectedIndex.value == 1) {
          Get.delete<TransferController>();
          Get.delete<CreateBeneficiaryController>();
          homeController.selectedIndex.value = 0;
        } else {
          Get.delete<TransferController>();
          Get.delete<CreateBeneficiaryController>();
          Get.back();
        }
      },
      child: Scaffold(
        appBar: CommonDefaultAppBar(),
        resizeToAvoidBottomInset: false,
        backgroundColor: colorScheme.surface,
        body: Stack(
          children: [
            Column(
              children: [
                // Top Navigation Bar
                Obx(
                  () => Visibility(
                    visible: controller.currentStep.value == 0 ||
                        controller.currentStep.value == 1,
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.sm),
                        CommonAppBar(
                          title: localization.transferScreenTitle,
                          rightSideWidget: controller.currentStep.value == 0
                              ? Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    end: AppSpacing.sm,
                                  ),
                                  child: IconButton(
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      _buildHistoryNavigation();
                                    },
                                    icon: Icon(
                                      Icons.more_vert_rounded,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                )
                              : null,
                          isBackLogicApply: true,
                          backLogicFunction: () {
                            if (controller.currentStep.value == 1) {
                              HapticFeedback.lightImpact();
                              controller.currentStep.value = 0;
                              return;
                            }
                            if (homeController.selectedIndex.value == 1) {
                              Get.delete<TransferController>();
                              Get.delete<CreateBeneficiaryController>();
                              homeController.selectedIndex.value = 0;
                            } else {
                              Get.delete<TransferController>();
                              Get.delete<CreateBeneficiaryController>();
                              Get.back();
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        // Sleek Multi-Step Indicator
                        TransferStepIndicator(
                          currentStep: controller.currentStep.value,
                          steps: const ['Amount', 'Review', 'Success'],
                          onStepTapped: (stepIndex) {
                            if (stepIndex < controller.currentStep.value) {
                              HapticFeedback.lightImpact();
                              controller.currentStep.value = stepIndex;
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ),
                  ),
                ),

                // Multi-Step Content Area
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const CommonLoading();
                    }

                    if (controller.currentStep.value == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Column(
                          children: const [
                            TransferWalletSection(),
                            SizedBox(height: AppSpacing.md),
                            Expanded(
                              child: TransferAmountStepSection(),
                            ),
                          ],
                        ),
                      );
                    } else if (controller.currentStep.value == 1) {
                      return const TransferReviewStepSection();
                    } else if (controller.currentStep.value == 2) {
                      return const TransferSuccessStepSection();
                    }
                    return const SizedBox.shrink();
                  }),
                ),
              ],
            ),

            // Fullscreen Loading Overlay
            Obx(
              () => Visibility(
                visible: controller.isTransferAmountLoading.value ||
                    controller.isBeneficiaryLoading.value,
                child: Container(
                  color: (isDark ? Colors.black : Colors.white)
                      .withValues(alpha: 0.65),
                  child: const CommonLoading(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _buildHistoryNavigation() {
    final localization = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    Get.bottomSheet(
      AnimatedContainer(
        width: double.infinity,
        duration: AppDurations.normal,
        curve: Curves.easeOutQuart,
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(AppSpacing.radiusXl),
            topEnd: Radius.circular(AppSpacing.radiusXl),
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : AppColors.lightShadow)
                  .withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 40,
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
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _HistoryMenuItem(
                    icon: Icons.history_rounded,
                    title: localization.transferHistoryTransferHistory,
                    onTap: () {
                      Get.back();
                      Get.toNamed(BaseRoute.transferHistory);
                    },
                  ),
                  _HistoryMenuItem(
                    icon: Icons.call_received_rounded,
                    title: localization.transferHistoryReceivedHistory,
                    onTap: () {
                      Get.back();
                      Get.toNamed(BaseRoute.transferReceivedHistory);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _HistoryMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
