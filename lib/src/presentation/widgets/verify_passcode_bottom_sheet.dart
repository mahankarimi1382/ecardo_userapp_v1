import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/controller/verify_passcode_controller.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';

class VerifyPasscodeBottomSheet extends StatefulWidget {
  const VerifyPasscodeBottomSheet({super.key});

  @override
  State<VerifyPasscodeBottomSheet> createState() =>
      _VerifyPasscodeBottomSheetState();
}

class _VerifyPasscodeBottomSheetState extends State<VerifyPasscodeBottomSheet> {
  final VerifyPasscodeController controller = Get.put(
    VerifyPasscodeController(),
  );

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
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
                width: 45,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localization!.verifyPasscodeTitle,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Image.asset(
                      PngAssets.closeCommonIcon,
                      width: 28,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.white,
                      AppColors.lightTextPrimary.withValues(alpha: 0.1),
                      AppColors.white,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CommonRequiredLabelAndDynamicField(
                labelText: localization.verifyPasscodeLabelPasscode,
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: "",
                    controller: controller.passcodeController,
                    focusNode: controller.passcodeFocusNode,
                    isFocused: controller.isPasscodeFocused.value,
                    keyboardType: TextInputType.text,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Obx(
                () => CommonButton(
                  backgroundColor: controller.isPasscodeVerifyLoading.value
                      ? AppColors.lightTextPrimary.withValues(alpha: 0.1)
                      : AppColors.lightPrimary,
                  isLoading: controller.isPasscodeVerifyLoading.value,
                  text: localization.verifyPasscodeButtonConfirm,
                  onPressed: controller.isPasscodeVerifyLoading.value
                      ? null
                      : () async {
                          final success = await controller
                              .submitPasscodeVerify();
                          if (success) {
                            Get.back(result: true);
                          }
                        },
                  borderRadius: 10,
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
