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
      appBar: CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Visibility(
                visible: controller.currentStep.value == 0 ||
                    controller.currentStep.value == 1,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Obx(
                      () => CommonAppBar(
                        title: localizations.exchangeTitle,
                        rightSideWidget: controller.currentStep.value == 0
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
                  ],
                ),
              ),
              // Step indicator — always visible so the user sees progress
              // even on Success.
              Obx(
                () => ExchangeStepIndicator(
                  currentStep: controller.currentStep.value,
                ),
              ),
              Expanded(
                child: Obx(
                  () => controller.isLoading.value
                      ? CommonLoading()
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
    );
  }

  /// Step transitions use SharedAxisTransition from the `animations`
  /// package — horizontal axis for forward navigation (Amount → Review →
  /// Success), which matches the left-to-right swipe pattern users
  /// expect from step indicators.
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
    // Keying each step by its index forces PageTransitionSwitcher to
    // rebuild when the step changes — without a key it would treat the
    // widget as "the same" and skip the animation.
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
