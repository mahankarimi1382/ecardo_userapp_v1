import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/controller/create_gift_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/view/sub_sections/create_gift_amount_step_section.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/view/sub_sections/create_gift_review_section.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/view/sub_sections/create_gift_success_step_section.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/view/sub_sections/create_gift_wallet_section.dart';

class CreateGiftStepSection extends StatefulWidget {
  const CreateGiftStepSection({super.key});

  @override
  State<CreateGiftStepSection> createState() => _CreateGiftStepSectionState();
}

class _CreateGiftStepSectionState extends State<CreateGiftStepSection> {
  final CreateGiftController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: AppColors.lightPrimary,
            size: 50,
          ),
        );
      }

      return Expanded(
        child: controller.currentStep.value == 0
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      CreateGiftWalletSection(),
                      SizedBox(height: 30),
                      CreateGiftAmountStepSection(),
                    ],
                  ),
                ),
              )
            : controller.currentStep.value == 1
            ? CreateGiftReviewSection()
            : CreateGiftSuccessStepSection(),
      );
    });
  }
}
