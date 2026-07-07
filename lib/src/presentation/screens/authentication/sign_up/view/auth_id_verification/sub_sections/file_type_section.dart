import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_up/controller/auth_id_verification_controller.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_up/model/user_kyc_model.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/camera_type_section.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/front_camera_type_section.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/kyc_submission_section.dart';

class FileTypeSection extends StatelessWidget {
  final Fields field;

  const FileTypeSection({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final AuthIdVerificationController controller = Get.find();

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    CommonAppBar(title: localizations.fileTypeBack),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.symmetric(
                                horizontal: 18.w,
                              ),
                              child: Text(
                                field.name ??
                                    localizations.fileTypeNotAvailable,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 24.sp,
                                  color: AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Padding(
                              padding: EdgeInsetsDirectional.symmetric(
                                horizontal: 18.w,
                              ),
                              child: Text(
                                field.instructions ??
                                    localizations.fileTypeNotAvailable,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                  color: AppColors.lightTextTertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Image.asset(
                            PngAssets.splashFrame,
                            height: 250.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Expanded(
                      child: Container(
                        margin: EdgeInsetsDirectional.symmetric(
                          horizontal: 18.w,
                        ),
                        padding: EdgeInsetsDirectional.only(
                          top: 3.h,
                          start: 18.w,
                          end: 18.w,
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
                            SizedBox(height: 40.h),
                            Image.asset(
                              PngAssets.uploadDocumentImage,
                              width: 220.w,
                              height: 220.h,
                            ),
                            SizedBox(height: 50.h),
                            CommonButton(
                              text: localizations.fileTypeChooseFile,
                              width: double.infinity,

                              onPressed: () async {
                                await controller.pickFile(field.name ?? "");
                                final file =
                                    controller.fieldFiles[field.name ?? ""];
                                if (file != null) {
                                  Get.to(() => const KycSubmissionSection());
                                }
                              },
                            ),
                            if (field.validation == "nullable") ...[
                              SizedBox(height: 20.h),
                              CommonButton(
                                backgroundColor: AppColors.transparent,
                                text: localizations.fileTypeSkip,
                                width: 120.w,

                                onPressed: () {
                                  final controller =
                                      Get.find<AuthIdVerificationController>();
                                  final isNullable =
                                      field.validation == "nullable";

                                  if (isNullable) {
                                    controller.skipField(field.name ?? "");

                                    final currentFieldIndex = controller.fields
                                        .indexWhere(
                                          (f) => f.name == field.name,
                                        );

                                    if (currentFieldIndex != -1 &&
                                        currentFieldIndex + 1 <
                                            controller.fields.length) {
                                      final nextField = controller
                                          .fields[currentFieldIndex + 1];

                                      if (nextField.type?.toLowerCase() ==
                                          "camera") {
                                        Get.to(
                                          () => CameraTypeSection(
                                            field: nextField,
                                          ),
                                        );
                                      } else if (nextField.type
                                              ?.toLowerCase() ==
                                          "file") {
                                        Get.to(
                                          () =>
                                              FileTypeSection(field: nextField),
                                        );
                                      } else if (nextField.type
                                              ?.toLowerCase() ==
                                          "front_camera") {
                                        Get.to(
                                          () => FrontCameraTypeSection(
                                            field: nextField,
                                          ),
                                        );
                                      }
                                    } else {
                                      Get.to(
                                        () => const KycSubmissionSection(),
                                      );
                                    }
                                  } else {
                                    Navigator.pop(context, null);
                                  }
                                },

                                borderColor: AppColors.lightPrimary.withValues(
                                  alpha: 0.50,
                                ),
                                borderWidth: 2,
                                textColor: AppColors.lightTextPrimary,
                              ),
                            ],
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
