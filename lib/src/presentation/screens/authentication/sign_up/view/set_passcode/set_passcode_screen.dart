import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/controller/set_passcode_controller.dart';

/// First-stage mandatory transaction passcode (exactly 4 digits).
/// Cannot be skipped; passcode cannot be disabled later.
class SetPasscodeScreen extends StatefulWidget {
  const SetPasscodeScreen({super.key});

  @override
  State<SetPasscodeScreen> createState() => _SetPasscodeScreenState();
}

class _SetPasscodeScreenState extends State<SetPasscodeScreen> {
  final SetPasscodeController controller = Get.find();

  static final _digitLimit = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(4),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: const CommonDefaultAppBar(),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 0.28.sh,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: ImageFiltered(
                            imageFilter:
                                ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Image.asset(
                              PngAssets.splashFrame,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              PngAssets.appLogo,
                              fit: BoxFit.contain,
                              width: 105.w,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              loc.generatePasscodeTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                letterSpacing: 0,
                                fontWeight: FontWeight.w900,
                                fontSize: 22.sp,
                                color: AppColors.lightTextPrimary,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Padding(
                              padding: EdgeInsetsDirectional.symmetric(
                                horizontal: 24.w,
                              ),
                              child: Text(
                                loc.generatePasscodeSectionDescription,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.sp,
                                  color: AppColors.lightTextTertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(minHeight: 0.72.sh),
                    margin: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
                    padding: EdgeInsetsDirectional.only(
                      top: 24.h,
                      start: 18.w,
                      end: 18.w,
                      bottom: 30.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(30.r),
                        topEnd: Radius.circular(30.r),
                      ),
                      color: AppColors.white,
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 0),
                          blurRadius: 40.r,
                          color: AppColors.black.withValues(alpha: 0.06),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CommonRequiredLabelAndDynamicField(
                          labelText: loc.generatePasscodeLabelPasscode,
                          isLabelRequired: true,
                          dynamicField: Obx(
                            () => CommonTextInputField(
                              hintText: '****',
                              controller: controller.passcodeController,
                              focusNode: controller.passcodeFocusNode,
                              isFocused: controller.isPasscodeFocused.value,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              inputFormatters: _digitLimit,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        CommonRequiredLabelAndDynamicField(
                          labelText: loc.generatePasscodeLabelConfirmPasscode,
                          isLabelRequired: true,
                          dynamicField: Obx(
                            () => CommonTextInputField(
                              hintText: '****',
                              controller: controller.confirmController,
                              focusNode: controller.confirmFocusNode,
                              isFocused: controller.isConfirmFocused.value,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              inputFormatters: _digitLimit,
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h),
                        CommonButton(
                          onPressed: controller.submit,
                          width: double.infinity,
                          text: loc.generatePasscodeButtonConfirm,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => Visibility(
                visible: controller.isLoading.value,
                child: const CommonLoading(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
