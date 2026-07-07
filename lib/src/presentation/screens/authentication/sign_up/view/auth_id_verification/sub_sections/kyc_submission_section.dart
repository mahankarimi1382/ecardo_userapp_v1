import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/button/common_icon_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_up/controller/auth_id_verification_controller.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_up/model/user_kyc_model.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/back_camera_capture.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/camera_type_section.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/file_type_section.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/front_camera_capture.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/front_camera_type_section.dart';
import 'package:qunzo_user/src/presentation/widgets/dynamic_attachment_preview.dart';

class KycSubmissionSection extends StatefulWidget {
  const KycSubmissionSection({super.key});

  @override
  State<KycSubmissionSection> createState() => _KycSubmissionSectionState();
}

class _KycSubmissionSectionState extends State<KycSubmissionSection> {
  final AuthIdVerificationController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) {
        controller.currentFieldIndex.value = 0;
        controller.fields.clear();
        controller.fieldFiles.clear();
        Get.toNamed(
          BaseRoute.signUpStatus,
          arguments: {"is_login_state": true},
        );
      },
      child: Scaffold(
        appBar: CommonDefaultAppBar(),
        body: Stack(
          children: [
            Obx(() {
              return Column(
                children: [
                  const SizedBox(height: 16),
                  CommonAppBar(
                    title: localizations.kycSubmissionIdVerification,
                    isBackLogicApply: true,
                    backLogicFunction: () {
                      controller.currentFieldIndex.value = 0;
                      controller.fields.clear();
                      controller.fieldFiles.clear();
                      Get.toNamed(
                        BaseRoute.signUpStatus,
                        arguments: {"is_login_state": true},
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 18,
                        ),
                        child: Column(
                          children: [
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: controller.fields.length,
                              itemBuilder: (context, index) {
                                final field = controller.fields[index];
                                final file =
                                    controller.fieldFiles[field.name ?? ""];

                                if (file == null) {
                                  return const SizedBox.shrink();
                                }

                                return Column(
                                  children: [
                                    _buildFieldWidget(
                                      field,
                                      context,
                                      index,
                                      file,
                                    ),
                                    const SizedBox(height: 30),
                                  ],
                                );
                              },
                            ),
                            _buildActionButton(),
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
            Obx(
              () => Visibility(
                visible: controller.isLoading.value,
                child: CommonLoading(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final localizations = AppLocalizations.of(context)!;
    bool allFieldsProcessed = true;
    Fields? nextUnprocessedField;

    for (var field in controller.fields) {
      if (!controller.isFieldProcessed(field.name ?? "")) {
        allFieldsProcessed = false;
        nextUnprocessedField ??= field;
      }
    }

    return CommonButton(
      width: double.infinity,

      text: allFieldsProcessed
          ? localizations.kycSubmissionSubmit
          : localizations.kycSubmissionNext,
      onPressed: () async {
        if (allFieldsProcessed) {
          await controller.submitIdVerification();
          return;
        }

        if (nextUnprocessedField != null) {
          final result = await _navigateToFieldScreen(nextUnprocessedField);

          if (result != null) {
            controller.fieldFiles[nextUnprocessedField.name ?? ""] = result;

            controller.currentFieldIndex.value = controller.fields.indexOf(
              nextUnprocessedField,
            );
          }
        }
      },
    );
  }

  Future<dynamic> _navigateToFieldScreen(Fields field) async {
    switch (field.type?.toLowerCase()) {
      case 'camera':
        return await Get.to(() => CameraTypeSection(field: field));
      case 'file':
        return await Get.to(() => FileTypeSection(field: field));
      case 'front_camera':
        return await Get.to(() => FrontCameraTypeSection(field: field));
      default:
        return null;
    }
  }

  Widget _buildFieldWidget(
    Fields field,
    BuildContext context,
    int fieldIndex,
    dynamic file,
  ) {
    final localizations = AppLocalizations.of(context)!;
    String name = field.name ?? "";
    String validation = field.validation ?? "";
    String type = field.type ?? "";

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          width: 2,
          color: AppColors.lightTextPrimary.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: const BorderRadiusDirectional.only(
                topStart: Radius.circular(30),
                topEnd: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: AppColors.lightTextPrimary,
                    letterSpacing: 0,
                  ),
                ),
                Visibility(
                  visible: validation == "required",
                  child: const Text(
                    "*",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: AppColors.error,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    final decodedImage = Image.file(file);
                    decodedImage.image
                        .resolve(const ImageConfiguration())
                        .addListener(
                          ImageStreamListener((ImageInfo info, bool _) {
                            final imageHeight = info.image.height.toDouble();
                            final imageWidth = info.image.width.toDouble();

                            final screenWidth =
                                MediaQuery.of(context).size.width - 36;
                            final scaledHeight =
                                (imageHeight / imageWidth) * screenWidth;
                            final bottomExtraHeight = 50.0;

                            Get.bottomSheet(
                              DynamicAttachmentPreview(
                                file: file,
                                scaledHeight: scaledHeight,
                                bottomExtraHeight: bottomExtraHeight,
                              ),
                              isScrollControlled: true,
                              enableDrag: true,
                              backgroundColor: AppColors.transparent,
                            );
                          }),
                        );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.file(
                      file,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                CommonIconButton(
                  onPressed: () async {
                    if (type == "file") {
                      await controller.pickFile(field.name ?? "");
                    } else if (type == "camera") {
                      final result = await Get.to(
                        () => BackCameraCapture(fieldName: field.name ?? ""),
                      );
                      if (result != null) {
                        controller.fieldFiles[field.name ?? ""] = result;
                      }
                    } else if (type == "front_camera") {
                      final result = await Get.to(
                        () => FrontCameraCapture(fieldName: field.name ?? ""),
                      );
                      if (result != null) {
                        controller.fieldFiles[field.name ?? ""] = result;
                      }
                    }
                  },
                  backgroundColor: AppColors.transparent,
                  borderColor: AppColors.lightPrimary.withValues(alpha: 0.50),
                  borderWidth: 2,
                  textColor: AppColors.lightTextPrimary,
                  width: double.infinity,
                  height: 52,
                  text: type == "file"
                      ? localizations.kycSubmissionReUpload
                      : localizations.kycSubmissionRetake,
                  icon: type == "file"
                      ? PngAssets.commonReSubmitIcon
                      : PngAssets.commonRetackIcon,
                  iconWidth: 20,
                  iconHeight: 20,
                  iconAndTextSpace: 10,
                  iconColor: AppColors.lightPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
