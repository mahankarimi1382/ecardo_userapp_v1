import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/upload_helper.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/controller/auth_id_verification_controller.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/model/user_kyc_model.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/back_camera_capture.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/camera_type_section.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/document_alignment_guide.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/file_type_section.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/front_camera_capture.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/front_camera_type_section.dart';
import 'package:ecardo_user/src/presentation/widgets/dynamic_attachment_preview.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;

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
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: const CommonDefaultAppBar(),
        body: Stack(
          children: [
            Obx(() {
              return Column(
                children: [
                  SizedBox(height: 16.h),
                  CommonAppBar(
                    title: localizations.kycSubmissionIdVerification,
                    isBackLogicApply: true,
                    backLogicFunction: () {
                      controller.currentFieldIndex.value = 0;
                      controller.fields.clear();
                      controller.fieldFiles.clear();
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else if (Get.key.currentState?.canPop() ?? false) {
                        Get.back();
                      } else {
                        Get.offAllNamed(
                          BaseRoute.signUpStatus,
                          arguments: {"is_login_state": true},
                        );
                      }
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Real-time tips banner before final submission
                  RealtimeTipsBanner(
                    isDark: isDark,
                    autoCycle: true,
                    backgroundColor: isDark
                        ? AppColors.darkSurface
                        : const Color(0xFFF8FAFC),
                  ),
                  SizedBox(height: 14.h),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10nPick(
                                context,
                                en: 'Review Documents Before Submission',
                                fa: 'بررسی نهایی مدارک قبل از ارسال',
                                ar: 'مراجعة المستندات قبل الإرسال',
                                zh: '提交前核对证件信息',
                              ),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: primaryTextColor,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              l10nPick(
                                context,
                                en: 'Ensure details are sharp and 4 corners are visible.',
                                fa: 'اطمینان حاصل کنید متن مدارک واضح بوده و هر ۴ گوشه در تصویر مشخص است.',
                                ar: 'تأكد من وضوح البيانات وظهور جميع الزوايا الأربع.',
                                zh: '请确保细节清晰且四个角完整可见。',
                              ),
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                color: isDark
                                    ? AppColors.softGray
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: controller.fields.length,
                              itemBuilder: (context, index) {
                                final field = controller.fields[index];
                                final file = controller.fieldFiles[field.name ?? ""];

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
                                      isDark,
                                    ),
                                    SizedBox(height: 18.h),
                                  ],
                                );
                              },
                            ),

                            SizedBox(height: 10.h),
                            _buildActionButton(),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),

            // Loading overlay with upload progress
            Obx(() {
              if (!controller.isLoading.value) return const SizedBox.shrink();
              final progress = controller.uploadProgress.value;
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: AppColors.black.withValues(alpha: 0.45),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 22.h),
                    margin: EdgeInsets.symmetric(horizontal: 36.w),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.20),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CommonLoading(size: 40),
                        SizedBox(height: 16.h),
                        Text(
                          progress > 0
                              ? '${(progress * 100).toInt()}% ${l10nPickAuto(en: 'Uploaded', fa: 'بارگذاری شد')}'
                              : l10nPickAuto(
                                  en: 'Optimizing & uploading documents...',
                                  fa: 'در حال فشرده‌سازی و بارگذاری مدارک...',
                                ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            color: primaryTextColor,
                          ),
                        ),
                        if (progress > 0) ...[
                          SizedBox(height: 12.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6.h,
                              backgroundColor: isDark
                                  ? AppColors.darkDivider
                                  : AppColors.lightBorder,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
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

        final Fields? fieldToProcess = nextUnprocessedField;
        if (fieldToProcess != null) {
          final result = await _navigateToFieldScreen(fieldToProcess);

          if (result != null) {
            controller.fieldFiles[fieldToProcess.name ?? ""] = result;
            controller.currentFieldIndex.value = controller.fields.indexOf(
              fieldToProcess,
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
    File file,
    bool isDark,
  ) {
    final localizations = AppLocalizations.of(context)!;
    final name = field.name ?? "";
    final validation = field.validation ?? "";
    final type = field.type ?? "";
    final primaryText = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryText = isDark ? AppColors.softGray : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final borderCol = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final fileLength = file.existsSync() ? file.lengthSync() : 0;
    final sizeInMB = fileLength / (1024 * 1024);
    final sizeString = '${sizeInMB.toStringAsFixed(2)} MB';
    final isValidSize = !UploadHelper.exceedsSize(file, UploadHelper.maxKycDocBytes);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          width: 1.5,
          color: const Color(0xFF10B981).withValues(alpha: 0.45),
        ),
        boxShadow: !isDark
            ? [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadiusDirectional.only(
                topStart: Radius.circular(18.r),
                topEnd: Radius.circular(18.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,
                        color: primaryText,
                      ),
                    ),
                    if (validation == "required")
                      const Text(
                        " *",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: AppColors.error,
                        ),
                      ),
                  ],
                ),

                // Size Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: (isValidSize
                            ? const Color(0xFF10B981)
                            : const Color(0xFFDC2626))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isValidSize
                            ? Icons.check_circle_rounded
                            : Icons.error_outline_rounded,
                        size: 12.sp,
                        color: isValidSize
                            ? const Color(0xFF10B981)
                            : const Color(0xFFDC2626),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '$sizeString / 20MB',
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w700,
                          color: isValidSize
                              ? const Color(0xFF10B981)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              children: [
                // Clear Thumbnail Preview with Zoom tap
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
                            Get.bottomSheet(
                              DynamicAttachmentPreview(
                                file: file,
                                scaledHeight: scaledHeight,
                                bottomExtraHeight: 50.0,
                              ),
                              isScrollControlled: true,
                              enableDrag: true,
                              backgroundColor: AppColors.transparent,
                            );
                          }),
                        );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 180.h,
                          width: double.infinity,
                          child: Image.file(
                            file,
                            fit: BoxFit.cover,
                            cacheWidth: 800,
                          ),
                        ),
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.zoom_in_rounded,
                                  size: 13,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  l10nPick(context, en: 'Preview', fa: 'پیش‌نمایش'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Quality Checks Status row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQualityCheck(
                      Icons.crop_free_rounded,
                      l10nPick(context, en: '4 Corners Visible', fa: '۴ گوشه مشخص'),
                      const Color(0xFF10B981),
                      secondaryText,
                    ),
                    _buildQualityCheck(
                      Icons.wb_sunny_outlined,
                      l10nPick(context, en: 'No Glare', fa: 'بدون بازتاب'),
                      const Color(0xFF10B981),
                      secondaryText,
                    ),
                    _buildQualityCheck(
                      Icons.text_fields_rounded,
                      l10nPick(context, en: 'Text Legible', fa: 'متن خوانا'),
                      const Color(0xFF10B981),
                      secondaryText,
                    ),
                  ],
                ),
                SizedBox(height: 14.h),

                // Retake / Re-upload Button
                SizedBox(
                  width: double.infinity,
                  height: 44.h,
                  child: OutlinedButton.icon(
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
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark ? borderCol : AppColors.lightPrimary.withValues(alpha: 0.6),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: 18.sp,
                      color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                    ),
                    label: Text(
                      type == "file"
                          ? localizations.kycSubmissionReUpload
                          : localizations.kycSubmissionRetake,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityCheck(
    IconData icon,
    String label,
    Color color,
    Color textColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.sp, color: color),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
