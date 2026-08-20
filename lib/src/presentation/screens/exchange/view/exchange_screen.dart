import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/controller/exchange_controller.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/view/sub_sections/exchange_amount_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/view/sub_sections/exchange_review_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/view/sub_sections/exchange_success_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/exchange_step_indicator.dart';

/// Exchange screen — full-bleed, German-minimalist layout.
///
/// Hierarchy (top to bottom):
///   1. Transparent AppBar shell (CommonDefaultAppBar) + CommonAppBar
///      row with back button + history menu
///   2. Step indicator — pinned under app bar, always visible
///   3. Step content — fills the remaining viewport with horizontal
///      page transitions (SharedAxisTransition)
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

    return Scaffold(
      // Full-bleed: app bar + step indicator handle their own safe area.
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                // v1.0.21+21 — Add top padding equal to the status bar
                // height so the AppBar row doesn't overlap with the
                // status bar icons. SafeArea(top: false) above means
                // the system status bar insets are NOT applied here,
                // so we apply them manually via MediaQuery.paddingOf.
                // Using EdgeInsetsDirectional only would be wrong here
                // because the status bar is always on TOP regardless
                // of LTR/RTL — so EdgeInsets.only(top:) is correct.
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.paddingOf(context).top,
                  ),
                  child: Column(
                    children: [
                      // Transparent AppBar shell for elevation control
                      const CommonDefaultAppBar(),
                      // Title row + history menu (only on step 0)
                      Obx(
                        () => CommonAppBar(
                          title: localizations.exchangeTitle,
                          rightSideWidget:
                              controller.currentStep.value == 0
                                  ? Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                        end: 8,
                                      ),
                                      child: IconButton(
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        onPressed: _showHistoryMenu,
                                        icon: const Icon(Icons.more_vert),
                                      ),
                                    )
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Step indicator — always visible so the user sees
                      // progress even on Success.
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
        return ExchangeAmountStepSection(key: const ValueKey('amount'));
      case 1:
        return ExchangeReviewStepSection(key: const ValueKey('review'));
      default:
        return ExchangeSuccessStepSection(key: const ValueKey('success'));
    }
  }

  void _showHistoryMenu() {
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
                  final items = [localizations.exchangeHistory];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.back();
                        if (index == 0) {
                          Get.toNamed(BaseRoute.exchangeHistory);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        child: Text(
                          items[index],
                          style: const TextStyle(
                            letterSpacing: 0,
                            color: AppColors.lightTextPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            fontFamily: 'Plus Jakarta Sans',
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

