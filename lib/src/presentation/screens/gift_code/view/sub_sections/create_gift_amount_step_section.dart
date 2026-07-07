import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/controller/create_gift_controller.dart';

class CreateGiftAmountStepSection extends StatefulWidget {
  const CreateGiftAmountStepSection({super.key});

  @override
  State<CreateGiftAmountStepSection> createState() =>
      _CreateGiftAmountStepSectionState();
}

class _CreateGiftAmountStepSectionState
    extends State<CreateGiftAmountStepSection> {
  final CreateGiftController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: EdgeInsetsDirectional.only(
        start: 20,
        end: 20,
        bottom: 24,
        top: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(30),
          topEnd: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          CommonRequiredLabelAndDynamicField(
            labelText: localizations.createGiftAmount,
            isLabelRequired: true,
            dynamicField: Obx(
              () => CommonTextInputField(
                focusNode: controller.amountFocusNode,
                isFocused: controller.isAmountFocused.value,
                backgroundColor: AppColors.transparent,
                hintText: "",
                controller: controller.amountController,
                keyboardType: TextInputType.number,
              ),
            ),
          ),
          Obx(
            () => Visibility(
              visible: controller.giftWalletsList.isNotEmpty,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(top: 2),
                child: Text(
                  "${localizations.createGiftMin} ${controller.wallet.value!.giftLimit!.min} ${controller.wallet.value!.code} ${localizations.createGiftMax} ${controller.wallet.value!.giftLimit!.max} ${controller.wallet.value!.code}",
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 40),
          CommonButton(
            borderRadius: 16,
            width: double.infinity,

            text: localizations.createGiftButton,
            onPressed: () {
              controller.nextStepWithValidation();
            },
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
