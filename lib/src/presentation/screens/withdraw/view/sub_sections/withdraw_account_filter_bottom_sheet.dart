import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/controller/withdraw_account_controller.dart';

class WithdrawAccountFilterBottomSheet extends StatefulWidget {
  const WithdrawAccountFilterBottomSheet({super.key});

  @override
  State<WithdrawAccountFilterBottomSheet> createState() =>
      _WithdrawAccountFilterBottomSheetState();
}

class _WithdrawAccountFilterBottomSheetState
    extends State<WithdrawAccountFilterBottomSheet> {
  final WithdrawAccountController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      height: 280,
      margin: EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(20),
          topEnd: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            spreadRadius: 0,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: SingleChildScrollView(
          child: Column(
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
              const SizedBox(height: 30),
              CommonRequiredLabelAndDynamicField(
                labelText: localization.withdrawAccountFilterMethodName,
                isLabelRequired: false,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: "",
                    controller: controller.methodNameController,
                    focusNode: controller.methodNameFocusNode,
                    isFocused: controller.isMethodNameFocused.value,
                    keyboardType: TextInputType.text,
                  ),
                ),
              ),
              SizedBox(height: 40),
              CommonButton(
                onPressed: () {
                  controller.fetchDynamicWithdrawAccounts();
                  controller.methodNameController.clear();
                  Get.back();
                },
                width: double.infinity,

                text: localization.withdrawAccountFilterApplyButton,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
