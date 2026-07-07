import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/settings/controller/two_factor_authentication_controller.dart';

class Disable2FaSection extends StatelessWidget {
  const Disable2FaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final TwoFactorAuthenticationController controller = Get.find();
    final localization = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsetsDirectional.symmetric(horizontal: 18),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization.disable2FaSectionTitle,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: 0,
              color: AppColors.lightTextPrimary,
            ),
          ),
          Divider(color: AppColors.lightTextTertiary.withValues(alpha: 0.15)),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                localization.disable2FaSectionDescription,
                style: TextStyle(
                  letterSpacing: 0,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextTertiary,
                ),
              ),
              Text(
                "*",
                style: TextStyle(
                  letterSpacing: 0,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Obx(
            () => CommonTextInputField(
              focusNode: controller.disable2FaFocusNode,
              isFocused: controller.isDisable2FaFocused.value,
              hintText: "",
              controller: controller.disable2FaController,
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(height: 20),
          CommonButton(
            borderRadius: 10,
            width: double.infinity,
            text: localization.disable2FaSectionDisableButton,
            onPressed: () async {
              if (controller.disable2FaController.text.isEmpty) {
                ToastHelper().showErrorToast(
                  localization.disable2FaSectionPasswordRequired,
                );
              } else {
                await controller.submitDisableTwoFa();
              }
            },
          ),
        ],
      ),
    );
  }
}
