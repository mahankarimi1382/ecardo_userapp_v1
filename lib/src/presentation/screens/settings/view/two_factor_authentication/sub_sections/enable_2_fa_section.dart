import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/settings/controller/two_factor_authentication_controller.dart';

class Enable2FaSection extends StatelessWidget {
  const Enable2FaSection({super.key});

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
            localization.enable2FaSectionTitle,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: AppColors.lightTextPrimary,
              letterSpacing: 0,
            ),
          ),
          Divider(color: AppColors.lightTextTertiary.withValues(alpha: 0.15)),
          Column(
            children: [
              SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: Text(
                  textAlign: TextAlign.center,
                  localization.enable2FaSectionDescription,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0,
                    color: AppColors.lightTextTertiary,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: SvgPicture.string(controller.qrCode.toString()),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                localization.enable2FaSectionPinLabel,
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
              focusNode: controller.enable2FaFocusNode,
              isFocused: controller.isEnable2FaFocused.value,
              backgroundColor: AppColors.white,
              hintText: "",
              controller: controller.enable2FaController,
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(height: 20),
          CommonButton(
            width: double.infinity,
            borderRadius: 10,
            text: localization.enable2FaSectionEnableButton,
            onPressed: () async {
              if (controller.enable2FaController.text.isEmpty) {
                ToastHelper().showErrorToast(
                  localization.enable2FaSectionPinRequired,
                );
              } else {
                await controller.submitEnableTwoFa();
              }
            },
          ),
        ],
      ),
    );
  }
}
