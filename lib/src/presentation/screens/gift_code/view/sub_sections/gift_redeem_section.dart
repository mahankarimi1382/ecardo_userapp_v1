import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/controller/gift_redeem_controller.dart';

class GiftRedeemSection extends StatefulWidget {
  const GiftRedeemSection({super.key});

  @override
  State<GiftRedeemSection> createState() => _GiftRedeemSectionState();
}

class _GiftRedeemSectionState extends State<GiftRedeemSection> {
  final GiftRedeemController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Expanded(
      child: Container(
        margin: EdgeInsetsDirectional.symmetric(horizontal: 18),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              CommonRequiredLabelAndDynamicField(
                labelText: localizations.giftRedeemGiftCode,
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    isFocused: controller.isGiftCodeFocused.value,
                    focusNode: controller.giftCodeFocusNode,
                    backgroundColor: AppColors.transparent,
                    hintText: "",
                    keyboardType: TextInputType.text,
                    controller: controller.giftCodeController,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              CommonButton(
                onPressed: () async {
                  if (controller.giftCodeController.text.isNotEmpty) {
                    await controller.giftCodeRedeem();
                  } else {
                    ToastHelper().showErrorToast(
                      localizations.giftRedeemValidation,
                    );
                  }
                },
                width: double.infinity,

                text: localizations.giftRedeemButton,
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
