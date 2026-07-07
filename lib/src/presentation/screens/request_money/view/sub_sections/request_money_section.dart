import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/request_money/controller/request_money_controller.dart';
import 'package:qunzo_user/src/presentation/screens/request_money/view/sub_sections/request_money_amount_step_section.dart';
import 'package:qunzo_user/src/presentation/screens/request_money/view/sub_sections/request_money_review_step_section.dart';
import 'package:qunzo_user/src/presentation/screens/request_money/view/sub_sections/request_money_success_step_section.dart';
import 'package:qunzo_user/src/presentation/screens/request_money/view/sub_sections/request_money_wallet_section.dart';

class RequestMoneySection extends StatelessWidget {
  const RequestMoneySection({super.key});

  @override
  Widget build(BuildContext context) {
    final RequestMoneyController controller = Get.find();

    return Obx(() {
      if (controller.isLoading.value) {
        return CommonLoading();
      }

      return controller.currentStep.value == 0
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    RequestMoneyWalletSection(),
                    SizedBox(height: 30),
                    RequestMoneyAmountStepSection(),
                  ],
                ),
              ),
            )
          : controller.currentStep.value == 1
          ? RequestMoneyReviewStepSection()
          : controller.currentStep.value == 2
          ? RequestMoneySuccessStepSection()
          : SizedBox();
    });
  }
}
