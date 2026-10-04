import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/controller/exchange_controller.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/view/sub_sections/exchange_amount_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/view/sub_sections/exchange_review_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/view/sub_sections/exchange_success_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/exchange_design_tokens.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/exchange_step_indicator.dart';

/// Exchange screen — full-bleed, German-minimalist fintech layout.
///
/// Hierarchy (top to bottom):
///   1. Non-leading AppBar shell + CommonAppBar (single back button)
///      row with back button + history menu on Step 0.
///   2. Step indicator — pinned under app bar, always visible.
///   3. Step content — fills the remaining viewport with horizontal
///      page transitions (SharedAxisTransition).
class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final ExchangeController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final bgColor = ExchangeDesignTokens.screenBackground(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.paddingOf(context).top,
                  ),
                  child: Column(
                    children: [
                      // Title row + history menu (only on step 0)
                      Obx(
                        () => CommonAppBar(
                          title: localizations.exchangeTitle,
                          isBackLogicApply: controller.currentStep.value > 0,
                          backLogicFunction: controller.currentStep.value > 0
                              ? () => controller.backToAmountStep()
                              : null,
                          rightSideWidget: controller.currentStep.value == 0
                              ? Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    end: AppSpacing.sm,
                                  ),
                                  child: Tooltip(
                                    message: l10nPick(
                                      context,
                                      en: 'Exchange history',
                                      fa: 'تاریخچه تبدیل',
                                    ),
                                    child: IconButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 44,
                                        minHeight: 44,
                                      ),
                                      onPressed: _showHistoryMenu,
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: ExchangeDesignTokens.textPrimary(
                                          context,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Step indicator — always visible so user sees progress
                      Obx(
                        () => ExchangeStepIndicator(
                          currentStep: controller.currentStep.value,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => controller.isLoading.value
                        ? const CommonLoading()
                        : _buildStepContent(),
                  ),
                ),
              ],
            ),
            Obx(
              () => Visibility(
                visible: controller.isExchangeWalletLoading.value,
                child: const CommonLoading(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Step transitions use SharedAxisTransition from the `animations`
  /// package — horizontal axis for forward navigation.
  Widget _buildStepContent() {
    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
      child: _stepWidget(controller.currentStep.value),
    );
  }

  Widget _stepWidget(int step) {
    switch (step) {
      case 0:
        return const ExchangeAmountStepSection(key: ValueKey('amount'));
      case 1:
        return const ExchangeReviewStepSection(key: ValueKey('review'));
      default:
        return const ExchangeSuccessStepSection(key: ValueKey('success'));
    }
  }

  void _showHistoryMenu() {
    final localizations = AppLocalizations.of(context)!;
    final isDark = ExchangeDesignTokens.isDark(context);

    HapticFeedback.lightImpact();

    Get.bottomSheet(
      AnimatedContainer(
        width: double.infinity,
        duration: AppSpacing.normal,
        curve: Curves.easeOutQuart,
        height: 160,
        margin: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: ExchangeDesignTokens.cardSurface(context),
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(AppSpacing.radiusXl),
            topEnd: Radius.circular(AppSpacing.radiusXl),
          ),
          border: Border.all(
            color: ExchangeDesignTokens.cardBorder(context),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : AppColors.black.withValues(alpha: 0.08),
              blurRadius: 40,
              spreadRadius: 0,
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
                color: ExchangeDesignTokens.textPrimary(context)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  final items = [localizations.exchangeHistory];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Get.back();
                        if (index == 0) {
                          Get.toNamed(BaseRoute.exchangeHistory);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 20,
                              color: ExchangeDesignTokens.textPrimary(context),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              items[index],
                              style: TextStyle(
                                letterSpacing: 0,
                                color: ExchangeDesignTokens.textPrimary(context),
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                fontFamily: 'Plus Jakarta Sans',
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
