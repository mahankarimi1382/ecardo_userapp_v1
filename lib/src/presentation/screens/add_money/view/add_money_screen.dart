import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/app/routes/route_return.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_wallet_bottom_sheet.dart';
import 'package:ecardo_user/src/presentation/screens/add_money/controller/add_money_controller.dart';
import 'package:ecardo_user/src/presentation/screens/add_money/model/gateway_methods_model.dart';
import 'package:ecardo_user/src/presentation/screens/add_money/view/sub_sections/add_money_amount_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/add_money/view/sub_sections/add_money_pending_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/add_money/view/sub_sections/add_money_review_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/add_money/view/sub_sections/add_money_success_step_section.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final AddMoneyController controller = Get.find<AddMoneyController>();
  final String walletId = Get.arguments?["wallet_id"] ?? "";

  @override
  void initState() {
    super.initState();
    walletId.isNotEmpty
        ? controller.findWallet(walletIdQuery: walletId.toString())
        : loadData();
  }

  Future<void> loadData() async {
    controller.isLoading.value = true;
    await controller.fetchWallets();
    await controller.fetchUser();
    controller.isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          RouteReturn.complete();
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
                            title: localizations.addMoneyTitle,
                            backLogicFunction: () async {
                              RouteReturn.complete();
                            },
                            isBackLogicApply: true,
                            rightSideWidget: controller.currentStep.value == 0
                                ? Semantics(
                                    label: localizations.addMoneyHistoryTitle,
                                    button: true,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSm,
                                      ),
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        Get.toNamed(BaseRoute.addMoneyHistory);
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                          end: AppSpacing.page,
                                          start: AppSpacing.sm,
                                          top: AppSpacing.sm,
                                          bottom: AppSpacing.sm,
                                        ),
                                        child: Image.asset(
                                          PngAssets.commonHistoryIcon,
                                          width: AppSpacing.iconLg,
                                          color: isDark
                                              ? AppColors.warmWhite
                                              : null,
                                        ),
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

                    if (controller.walletsList.isEmpty ||
                        controller.wallet.value == null) {
                      return Center(
                        child: EcardoEmptyState(
                          title: localizations.addMoneyWalletsNotFound,
                          description: localizations.allControllerLoadError,
                          primaryActionLabel:
                              localizations.noInternetConnectionRetryButton,
                          onPrimaryAction: loadData,
                        ),
                      );
                    }

                    return controller.currentStep.value == 0
                        ? Padding(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: AppSpacing.page,
                            ),
                            child: Column(
                              children: [
                                _buildWallet(isDark),
                                const SizedBox(height: AppSpacing.xxl),
                                const AddMoneyAmountStepSection(),
                              ],
                            ),
                          )
                        : controller.currentStep.value == 1
                        ? const AddMoneyReviewStepSection()
                        : controller.currentStep.value == 2
                        ? controller.gatewayMethod.value!.type == "auto"
                            ? const AddMoneySuccessStepSection()
                            : const AddMoneyPendingStepSection()
                        : const SizedBox.shrink();
                  }),
                ),
              ],
            ),
            Obx(
              () => Visibility(
                visible:
                    controller.isGatewayMethodsLoading.value ||
                    controller.isPaymentLoading.value,
                child: const CommonLoading(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWallet(bool isDark) {
    final localization = AppLocalizations.of(context)!;
    final currentWallet = controller.wallet.value!;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      onTap: () {
        HapticFeedback.lightImpact();
        Get.bottomSheet(
          CommonDropdownWalletBottomSheet(
            notFoundText: localization.addMoneyWalletsNotFound,
            dropdownItems: controller.walletsList,
            bottomSheetHeight: 450,
            currentlySelectedValue: currentWallet.name,
            onItemSelected: (value) async {
              final selectedWallet = controller.walletsList.firstWhere(
                (w) => w.name == value,
              );
              controller.wallet.value = selectedWallet;
              controller.gatewayMethod.value = GatewayMethodsData();
              controller.gatewayController.clear();
              controller.dynamicFieldControllers.clear();
              controller.selectedImages.clear();
              await controller.fetchGatewayMethods(isSetUpLoading: true);
            },
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF1E2836),
                    const Color(0xFF151C26),
                  ]
                : [
                    AppColors.deepBlack,
                    const Color(0xFF2A2A28),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder
                : AppColors.mainSoftBlue.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: AppSpacing.md,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  width: AppSpacing.iconLg,
                  height: AppSpacing.iconLg,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: currentWallet.isDefault == true ||
                          currentWallet.icon == null ||
                          currentWallet.icon!.isEmpty
                      ? Text(
                          currentWallet.symbol ?? currentWallet.code ?? r'$',
                          style: const TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppColors.white,
                          ),
                        )
                      : ClipOval(
                          child: Image.network(
                            currentWallet.icon!,
                            width: AppSpacing.iconLg,
                            height: AppSpacing.iconLg,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                currentWallet.symbol ?? r'$',
                                style: const TextStyle(
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.white,
                                ),
                              );
                            },
                          ),
                        ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    currentWallet.name ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentWallet.code ?? "",
                        style: const TextStyle(
                          color: AppColors.warmWhite,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.warmWhite,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              localization.addMoneyBalance,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.warmWhite.withValues(alpha: 0.70),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    "${currentWallet.formattedBalance} ${currentWallet.code}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      letterSpacing: -0.5,
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
