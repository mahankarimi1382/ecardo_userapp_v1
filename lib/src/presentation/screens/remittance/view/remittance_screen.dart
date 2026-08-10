import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/model/remittance_model.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/view/sub_sections/remittance_method_section.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/view/sub_sections/remittance_sender_section.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/view/sub_sections/remittance_receiver_section.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/view/sub_sections/remittance_review_section.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/view/sub_sections/remittance_success_section.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/view/sub_sections/remittance_stepper.dart';

/// RemittanceScreen — main screen for international money transfer.
///
/// Stepper with 5 steps:
///   0: Method & Amount
///   1: Sender Info
///   2: Receiver Info
///   3: Review & Submit
///   4: Success
class RemittanceScreen extends StatelessWidget {
  const RemittanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = Get.put(RemittanceController());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.lightTextPrimary),
          onPressed: () {
            if (controller.currentStep.value > 0) {
              controller.previousStep();
            } else {
              Get.back();
            }
          },
        ),
        title: Text(
          'International Remittance',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.lightTextPrimary),
            onPressed: () => Get.toNamed(BaseRoute.remittanceHistory),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isMethodsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Stepper indicator
            RemittanceStepper(currentStep: controller.currentStep.value),

            // Step content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: _buildStepContent(controller, localization),
              ),
            ),

            // Bottom action button
            _buildBottomButton(controller, localization),
          ],
        );
      }),
    );
  }

  Widget _buildStepContent(
    RemittanceController controller,
    AppLocalizations localization,
  ) {
    switch (controller.currentStep.value) {
      case 0:
        return const RemittanceMethodSection();
      case 1:
        return const RemittanceSenderSection();
      case 2:
        return const RemittanceReceiverSection();
      case 3:
        return const RemittanceReviewSection();
      case 4:
        return const RemittanceSuccessSection();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomButton(
    RemittanceController controller,
    AppLocalizations localization,
  ) {
    return Obx(() {
      final step = controller.currentStep.value;
      final isLoading = controller.isQuoteLoading.value ||
          controller.isSubmitLoading.value ||
          controller.isUploadLoading.value;

      String buttonText;
      VoidCallback? onPressed;

      switch (step) {
        case 0:
          buttonText = 'Get Quote';
          onPressed = isLoading
              ? null
              : () async {
                  final ok = await controller.requestQuote();
                  if (ok) {
                    controller.nextStep();
                  }
                };
          break;
        case 1:
          buttonText = 'Continue';
          onPressed = () {
            if (_validateSender(controller)) {
              controller.nextStep();
            }
          };
          break;
        case 2:
          buttonText = 'Continue';
          onPressed = () {
            if (_validateReceiver(controller)) {
              controller.nextStep();
            }
          };
          break;
        case 3:
          buttonText = 'Submit Request';
          onPressed = isLoading
              ? null
              : () async {
                  final ok = await controller.createRemittance();
                  if (ok) {
                    // Auto-advance to allow document upload
                    controller.nextStep();
                  }
                };
          break;
        case 4:
          buttonText = 'Upload Documents';
          onPressed = isLoading
              ? null
              : () async {
                  final ok = await controller.uploadDocuments();
                  if (ok) {
                    Get.offAllNamed(BaseRoute.navigation);
                  }
                };
          break;
        default:
          buttonText = 'Continue';
          onPressed = null;
      }

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: CommonButton(
            text: isLoading && step == 4
                ? 'Uploading...'
                : isLoading
                    ? 'Please wait...'
                    : buttonText,
            onPressed: onPressed,
            height: 50.h,
            borderRadius: 12,
          ),
        ),
      );
    });
  }

  bool _validateSender(RemittanceController controller) {
    if (controller.senderNameController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter sender name');
      return false;
    }
    if (controller.senderPhoneController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter sender phone');
      return false;
    }
    if (controller.senderIdNumberController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter sender ID number');
      return false;
    }
    if (controller.selectedSenderCountry.value.isEmpty) {
      Get.snackbar('Error', 'Please select sender country');
      return false;
    }
    return true;
  }

  bool _validateReceiver(RemittanceController controller) {
    if (controller.receiverNameController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter receiver name');
      return false;
    }
    if (controller.receiverPhoneController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter receiver phone');
      return false;
    }
    if (controller.selectedReceiverCountry.value.isEmpty) {
      Get.snackbar('Error', 'Please select receiver country');
      return false;
    }
    return true;
  }
}
