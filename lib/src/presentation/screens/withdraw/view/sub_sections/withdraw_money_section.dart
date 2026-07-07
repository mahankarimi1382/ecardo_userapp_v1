import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/controller/withdraw_controller.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/view/sub_sections/withdraw_amount_step_section.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/view/sub_sections/withdraw_review_step_section.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/view/sub_sections/withdraw_success_step_section.dart';

class WithdrawMoneySection extends StatefulWidget {
  const WithdrawMoneySection({super.key});

  @override
  State<WithdrawMoneySection> createState() => _WithdrawMoneySectionState();
}

class _WithdrawMoneySectionState extends State<WithdrawMoneySection> {
  final WithdrawController controller = Get.find();

  @override
  void initState() {
    super.initState();
    if (controller.currentStep.value == 0) {
      controller.clearFields();
      controller.fetchWithdrawAccounts();
      controller.fetchUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return controller.currentStep.value == 0
        ? WithdrawAmountStepSection()
        : controller.currentStep.value == 1
        ? WithdrawReviewStepSection()
        : controller.currentStep.value == 2
        ? WithdrawSuccessStepSection()
        : SizedBox();
  }
}
