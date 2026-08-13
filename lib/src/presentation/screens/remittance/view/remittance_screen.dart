import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/view/sub_sections/remittance_method_section.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/view/sub_sections/remittance_sender_section.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/view/sub_sections/remittance_receiver_section.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/view/sub_sections/remittance_review_section.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/view/sub_sections/remittance_success_section.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/view/sub_sections/remittance_stepper.dart';

/// RemittanceScreen — main screen for international money transfer.
/// 5-step flow: Method+Amount → Sender → Receiver → Review → Success+Upload
class RemittanceScreen extends StatelessWidget {
  const RemittanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RemittanceController());

    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
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
        title: Text('International Remittance', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary)),
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
        return Column(children: [
          RemittanceStepper(currentStep: controller.currentStep.value),
          Expanded(child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: _buildStep(controller),
          )),
          _buildBottomButton(controller),
        ]);
      }),
    );
  }

  Widget _buildStep(RemittanceController c) {
    switch (c.currentStep.value) {
      case 0: return const RemittanceMethodSection();
      case 1: return const RemittanceSenderSection();
      case 2: return const RemittanceReceiverSection();
      case 3: return const RemittanceReviewSection();
      case 4: return const RemittanceSuccessSection();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildBottomButton(RemittanceController c) {
    return Obx(() {
      final step = c.currentStep.value;
      final loading = c.isQuoteLoading.value || c.isSubmitLoading.value || c.isUploadLoading.value;
      String text;
      VoidCallback? onPressed;

      switch (step) {
        case 0:
          text = 'Get Quote';
          onPressed = loading ? null : () async {
            if (await c.requestQuote()) c.nextStep();
          };
          break;
        case 1:
          text = 'Continue';
          onPressed = () {
            if (c.senderNameController.text.isNotEmpty &&
                c.senderPhoneController.text.isNotEmpty &&
                c.senderIdNumberController.text.isNotEmpty &&
                c.selectedSenderCountry.value.isNotEmpty) {
              c.nextStep();
            } else {
              Get.snackbar('Error', 'Please complete all sender fields', snackPosition: SnackPosition.BOTTOM);
            }
          };
          break;
        case 2:
          text = 'Continue';
          onPressed = () {
            if (c.receiverNameController.text.isNotEmpty &&
                c.receiverPhoneController.text.isNotEmpty &&
                c.selectedReceiverCountry.value.isNotEmpty) {
              c.nextStep();
            } else {
              Get.snackbar('Error', 'Please complete all receiver fields', snackPosition: SnackPosition.BOTTOM);
            }
          };
          break;
        case 3:
          text = 'Submit Request';
          onPressed = loading ? null : () async {
            if (await c.createRemittance()) c.nextStep();
          };
          break;
        case 4:
          text = loading ? 'Uploading...' : 'Upload Documents';
          onPressed = loading ? null : () async {
            if (await c.uploadDocuments()) Get.offAllNamed(BaseRoute.navigation);
          };
          break;
        default:
          text = 'Continue';
          onPressed = null;
      }

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: loading && step != 4
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(text, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      );
    });
  }
}
