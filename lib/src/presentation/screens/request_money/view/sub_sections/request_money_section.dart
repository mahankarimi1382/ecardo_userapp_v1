import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/controller/request_money_controller.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/view/sub_sections/request_money_amount_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/view/sub_sections/request_money_review_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/view/sub_sections/request_money_success_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/view/sub_sections/request_money_wallet_section.dart';

class RequestMoneySection extends StatelessWidget {
  const RequestMoneySection({super.key});

  @override
  Widget build(BuildContext context) {
    final RequestMoneyController controller = Get.find();

    return Obx(() {
      if (controller.isLoading.value) {
        return const CommonLoading();
      }

      return controller.currentStep.value == 0
          ? SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: const [
                  SizedBox(height: AppSpacing.md),
                  RequestMoneyWalletSection(),
                  SizedBox(height: AppSpacing.lg),
                  RequestMoneyAmountStepSection(),
                  SizedBox(height: AppSpacing.xxl),
                ],
              ),
            )
          : controller.currentStep.value == 1
          ? const RequestMoneyReviewStepSection()
          : controller.currentStep.value == 2
          ? const RequestMoneySuccessStepSection()
          : const SizedBox.shrink();
    });
  }
}
