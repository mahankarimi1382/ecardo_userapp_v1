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
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/helper/upload_helper.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/controller/auth_id_verification_controller.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/model/user_kyc_model.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/camera_type_section.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/document_alignment_guide.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/front_camera_type_section.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/view/auth_id_verification/sub_sections/kyc_submission_section.dart';
import 'package:ecardo_user/src/presentation/widgets/dynamic_attachment_preview.dart';

class FileTypeSection extends StatelessWidget {
  final Fields field;

  const FileTypeSection({super.key, required this.field});

  void _proceedToNext(BuildContext context, AuthIdVerificationController controller) {
    final currentFieldIndex = controller.fields.indexWhere((f) => f.name == field.name);
    if (currentFieldIndex != -1 && currentFieldIndex + 1 < controller.fields.length) {
      final nextField = controller.fields[currentFieldIndex + 1];
      controller.currentFieldIndex.value = currentFieldIndex + 1;
      final type = nextField.type?.toLowerCase();
      if (type == 'camera') {
        Get.to(() => CameraTypeSection(field: nextField));
      } else if (type == 'file') {
        Get.to(() => FileTypeSection(field: nextField));
      } else if (type == 'front_camera') {
        Get.to(() => FrontCameraTypeSection(field: nextField));
      } else {
        Get.to(() => const KycSubmissionSection());
      }
    } else {
      Get.to(() => const KycSubmissionSection());
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final AuthIdVerificationController controller = Get.find();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor =
        isDark ? AppColors.softGray : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final borderCol = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: const CommonDefaultAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    CommonAppBar(
                      title: localizations.fileTypeBack,
                      isBackLogicApply: true,
                      backLogicFunction: () {
                        if (controller.currentFieldIndex.value > 0) {
                          controller.currentFieldIndex.value--;
                        } else {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else if (Get.key.currentState?.canPop() ?? false) {
                            Get.back();
                          } else {
                            Get.offAllNamed(BaseRoute.navigation);
                          }
                        }
                      },
                    ),
                    SizedBox(height: 12.h),

                    // Header: Document Title & Instructions
                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          Text(
                            field.name ?? localizations.fileTypeNotAvailable,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 22.sp,
                              color: primaryTextColor,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            field.instructions ?? localizations.fileTypeNotAvailable,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                              color: secondaryTextColor,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Real-time tips banner
                    RealtimeTipsBanner(
                      isDark: isDark,
                      autoCycle: true,
                      backgroundColor: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurfaceVariant,
                    ),
                    SizedBox(height: 16.h),

                    // Upload Container & Document Alignment Frame
                    Expanded(
                      child: Container(
                        margin: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
                        padding: EdgeInsetsDirectional.all(18.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadiusDirectional.only(
                            topStart: Radius.circular(28.r),
                            topEnd: Radius.circular(28.r),
                          ),
                          color: cardBg,
                          border: Border.all(color: borderCol, width: 1),
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, -2),
                              blurRadius: 20.r,
                              color: AppColors.black.withValues(
                                alpha: isDark ? 0.25 : 0.04,
                              ),
                            ),
                          ],
                        ),
                        child: Obx(() {
                          final file = controller.fieldFiles[field.name ?? ""];
                          final hasFile = file != null && file.existsSync();

                          return Column(
                            children: [
                              SizedBox(height: 10.h),

                              if (!hasFile)
                                _buildUploadDropzone(
                                  context: context,
                                  isDark: isDark,
                                  controller: controller,
                                  primaryText: primaryTextColor,
                                  secondaryText: secondaryTextColor,
                                )
                              else
                                _buildThumbnailPreview(
                                  context: context,
                                  file: file,
                                  isDark: isDark,
                                  controller: controller,
                                  primaryText: primaryTextColor,
                                  secondaryText: secondaryTextColor,
                                ),

                              const Spacer(),
                              SizedBox(height: 20.h),

                              // Primary Action Button
                              if (!hasFile)
                                Semantics(
                                  button: true,
                                  label: localizations.fileTypeChooseFile,
                                  child: CommonButton(
                                    text: localizations.fileTypeChooseFile,
                                    width: double.infinity,
                                    onPressed: () async {
                                      final picked = await controller.pickFile(field.name ?? "");
                                      if (picked != null) {
                                        if (UploadHelper.exceedsSize(
                                          picked,
                                          UploadHelper.maxKycDocBytes,
                                        )) {
                                          controller.fieldFiles.remove(field.name ?? "");
                                          ToastHelper().showErrorToast(
                                            l10nPickAuto(
                                              en: 'File size must not exceed 20MB',
                                              fa: 'حجم فایل نباید بیشتر از ۲۰ مگابایت باشد',
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                )
                              else
                                Semantics(
                                  button: true,
                                  label: l10nPick(
                                    context,
                                    en: 'Confirm & Continue',
                                    fa: 'تأیید مدرک و ادامه',
                                    ar: 'تأكيد ومتابعة',
                                    zh: '确认并继续',
                                  ),
                                  child: CommonButton(
                                    text: l10nPick(
                                      context,
                                      en: 'Confirm & Continue',
                                      fa: 'تأیید مدرک و ادامه',
                                      ar: 'تأكيد ومتابعة',
                                      zh: '确认并继续',
                                    ),
                                    width: double.infinity,
                                    onPressed: () {
                                      if (Navigator.canPop(context)) {
                                        Navigator.pop(context, file);
                                      } else {
                                        _proceedToNext(context, controller);
                                      }
                                    },
                                  ),
                                ),

                              // Skip option if nullable
                              if (field.validation == "nullable") ...[
                                SizedBox(height: 12.h),
                                Semantics(
                                  button: true,
                                  label: localizations.fileTypeSkip,
                                  child: CommonButton(
                                    backgroundColor: AppColors.transparent,
                                    text: localizations.fileTypeSkip,
                                    width: 120.w,
                                    height: 44.h,
                                    textColor: secondaryTextColor,
                                    onPressed: () {
                                      controller.skipField(field.name ?? "");
                                      _proceedToNext(context, controller);
                                    },
                                  ),
                                ),
                              ],
                              SizedBox(height: 16.h),
                            ],
                          );
                        }),
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

  /// Modern dropzone with corner markers and guidelines
  Widget _buildUploadDropzone({
    required BuildContext context,
    required bool isDark,
    required AuthIdVerificationController controller,
    required Color primaryText,
    required Color secondaryText,
  }) {
    final guideColor = isDark ? AppColors.mainSoftBlue : AppColors.brandViolet;

    return Semantics(
      button: true,
      label: l10nPick(
        context,
        en: 'Tap to upload document file',
        fa: 'برای بارگذاری فایل مدرک لمس کنید',
        ar: 'اضغط لتحميل مستند الهوية',
        zh: '点击上传证件文件',
      ),
      child: GestureDetector(
        onTap: () async {
          final picked = await controller.pickFile(field.name ?? "");
          if (picked != null) {
            if (UploadHelper.exceedsSize(picked, UploadHelper.maxKycDocBytes)) {
              controller.fieldFiles.remove(field.name ?? "");
              ToastHelper().showErrorToast(
                l10nPickAuto(
                  en: 'File size must not exceed 20MB',
                  fa: 'حجم فایل نباید بیشتر از ۲۰ مگابایت باشد',
                ),
              );
            }
          }
        },
        child: Container(
          width: double.infinity,
          height: 220.h,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              // Corner alignment markers
              _buildCornerBracket(top: 12.h, left: 12.w, isTop: true, isLeft: true, color: guideColor),
              _buildCornerBracket(top: 12.h, right: 12.w, isTop: true, isLeft: false, color: guideColor),
              _buildCornerBracket(bottom: 12.h, left: 12.w, isTop: false, isLeft: true, color: guideColor),
              _buildCornerBracket(bottom: 12.h, right: 12.w, isTop: false, isLeft: false, color: guideColor),

              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: guideColor.withValues(alpha: isDark ? 0.16 : 0.10),
                      ),
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        size: 32.sp,
                        color: guideColor,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      l10nPick(
                        context,
                        en: 'Tap to upload document file',
                        fa: 'برای بارگذاری فایل مدرک لمس کنید',
                        ar: 'اضغط لتحميل مستند الهوية',
                        zh: '点击上传证件文件',
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: primaryText,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'JPG, PNG, PDF, DOC — Max 20MB',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCornerBracket({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isTop,
    required bool isLeft,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 18.w,
        height: 18.w,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? BorderSide(color: color, width: 3)
                : BorderSide.none,
            bottom: !isTop
                ? BorderSide(color: color, width: 3)
                : BorderSide.none,
            left: isLeft
                ? BorderSide(color: color, width: 3)
                : BorderSide.none,
            right: !isLeft
                ? BorderSide(color: color, width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// Thumbnail preview with file size check badge and replace/retake button
  Widget _buildThumbnailPreview({
    required BuildContext context,
    required File file,
    required bool isDark,
    required AuthIdVerificationController controller,
    required Color primaryText,
    required Color secondaryText,
  }) {
    final guideColor = isDark ? AppColors.mainSoftBlue : AppColors.brandViolet;
    final fileLength = file.lengthSync();
    final sizeInMB = fileLength / (1024 * 1024);
    final sizeString = '${sizeInMB.toStringAsFixed(2)} MB';
    final isValidSize = !UploadHelper.exceedsSize(file, UploadHelper.maxKycDocBytes);
    final nameLower = file.path.toLowerCase();
    final isImage = nameLower.endsWith('.jpg') ||
        nameLower.endsWith('.jpeg') ||
        nameLower.endsWith('.png') ||
        nameLower.endsWith('.webp');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: guideColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Thumbnail or Document icon
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: isImage
                ? Semantics(
                    button: true,
                    label: l10nPick(
                      context,
                      en: 'Preview document image full screen',
                      fa: 'پیش‌نمایش تصویر مدرک در نمای تمام‌صفحه',
                      ar: 'معاينة صورة المستند بملء الشاشة',
                      zh: '全屏预览证件图片',
                    ),
                    child: GestureDetector(
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
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 180.h,
                            width: double.infinity,
                            child: Image.file(
                              file,
                              fit: BoxFit.cover,
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
                                color: AppColors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.zoom_in_rounded,
                                    size: 13,
                                    color: AppColors.white,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    l10nPick(context, en: 'Preview', fa: 'پیش‌نمایش'),
                                    style: const TextStyle(
                                      color: AppColors.white,
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
                  )
                : Container(
                    height: 140.h,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_rounded,
                          size: 40.sp,
                          color: guideColor,
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.path.split(RegExp(r'[/\\]')).last,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: primaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              sizeString,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),

          // File status & replace toolbar
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // File Size Status Pill
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: (isValidSize
                            ? AppColors.success
                            : AppColors.error)
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
                        size: 13.sp,
                        color: isValidSize
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '$sizeString / 20MB',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                          color: isValidSize
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),

                // Replace / Retake Button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      button: true,
                      label: l10nPick(
                        context,
                        en: 'Replace file',
                        fa: 'تغییر فایل',
                        ar: 'استبدال',
                        zh: '更换',
                      ),
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await controller.pickFile(field.name ?? "");
                          if (picked != null) {
                            if (UploadHelper.exceedsSize(
                              picked,
                              UploadHelper.maxKycDocBytes,
                            )) {
                              controller.fieldFiles.remove(field.name ?? "");
                              ToastHelper().showErrorToast(
                                l10nPickAuto(
                                  en: 'File size must not exceed 20MB',
                                  fa: 'حجم فایل نباید بیشتر از ۲۰ مگابایت باشد',
                                ),
                              );
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(88.w, 44.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 15),
                        label: Text(
                          l10nPick(
                            context,
                            en: 'Replace',
                            fa: 'تغییر فایل',
                            ar: 'استبدال',
                            zh: '更换',
                          ),
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            color: primaryText,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Semantics(
                      button: true,
                      label: l10nPick(
                        context,
                        en: 'Delete file',
                        fa: 'حذف فایل',
                        ar: 'حذف',
                        zh: '删除',
                      ),
                      child: IconButton(
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                        tooltip: l10nPick(
                          context,
                          en: 'Delete file',
                          fa: 'حذف فایل',
                          ar: 'حذف',
                          zh: '删除',
                        ),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                        onPressed: () {
                          controller.fieldFiles.remove(field.name ?? "");
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
