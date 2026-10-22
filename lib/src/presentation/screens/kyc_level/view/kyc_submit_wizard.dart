import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/helper/upload_helper.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/model/kyc_level_model.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/view/kyc_labels.dart';

/// KycSubmitWizard — Step-by-step document submission wizard
/// Complete tokenization, dark mode support, RTL correctness, and 4 states.
class KycSubmitWizard extends StatefulWidget {
  final int targetLevel;

  const KycSubmitWizard({super.key, this.targetLevel = 2});

  @override
  State<KycSubmitWizard> createState() => _KycSubmitWizardState();
}

class _KycSubmitWizardState extends State<KycSubmitWizard> {
  final KycLevelController controller = Get.find<KycLevelController>();
  final Map<String, String> _documents = {};
  final ImagePicker _picker = ImagePicker();
  int _currentStep = 0;

  int get _targetLevel {
    final args = Get.arguments;
    if (args is Map && args['target_level'] != null) {
      final raw = args['target_level'];
      if (raw is int) return raw;
      if (raw is num) return raw.toInt();
      if (raw is String) {
        final parsed = int.tryParse(raw);
        if (parsed != null) return parsed;
      }
    }
    return widget.targetLevel;
  }

  void _handleBack() {
    HapticFeedback.lightImpact();
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else if (Get.key.currentState?.canPop() ?? false) {
        Get.back();
      } else {
        Get.offAllNamed(BaseRoute.navigation);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark
        ? AppColors.softGray
        : AppColors.lightTextSecondary;

    return PopScope(
      canPop: _currentStep == 0 && Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          centerTitle: true,
          leading: BackButton(color: primaryTextColor, onPressed: _handleBack),
          title: Text(
            localization?.kycSubmitWizardTitleForLevel(_targetLevel) ??
                'Verification — level $_targetLevel',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: primaryTextColor,
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value && controller.levels.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
              ),
            );
          }

          final targetLevel = controller.levels
              .where((l) => l.level == _targetLevel)
              .firstOrNull;

          if (targetLevel == null) {
            return Center(
              child: Text(
                localization?.kycSubmitWizardInvalidLevel ?? 'Invalid level',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: secondaryTextColor,
                ),
              ),
            );
          }

          final docs = targetLevel.requiredDocs;
          final hasDocs = docs.isNotEmpty;

          return Column(
            children: [
              // Rejection alert banner if previous submission was rejected
              if (controller.rejectionData.value?.message != null &&
                  controller.rejectionData.value!.message!.trim().isNotEmpty)
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: AppSpacing.sm,
                  ),
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.error.withValues(alpha: 0.15)
                        : AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10nPickAuto(
                                en: 'Previous Submission Rejected',
                                fa: 'ارسال قبلی رد شده است',
                              ),
                              style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              controller.rejectionData.value!.message!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: primaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Stepper Progress indicator
              if (hasDocs)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: List.generate(docs.length * 2 - 1, (index) {
                      if (index.isOdd) {
                        return Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            color: _currentStep > index ~/ 2
                                ? (isDark
                                      ? AppColors.mainSoftBlue
                                      : AppColors.brandViolet)
                                : (isDark
                                      ? AppColors.darkDivider
                                      : AppColors.lightBorder),
                          ),
                        );
                      }
                      final stepIdx = index ~/ 2;
                      return _StepCircle(
                        step: stepIdx + 1,
                        isActive: _currentStep >= stepIdx,
                        isCurrent: _currentStep == stepIdx,
                        isDark: isDark,
                      );
                    }),
                  ),
                ),

              // Content step
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(18.w),
                  child: hasDocs && _currentStep < docs.length
                      ? _buildDocUploadStep(
                          localization,
                          docs[_currentStep],
                          isDark,
                          primaryTextColor,
                          secondaryTextColor,
                        )
                      : _buildReviewStep(
                          localization,
                          targetLevel,
                          docs,
                          isDark,
                          primaryTextColor,
                          secondaryTextColor,
                        ),
                ),
              ),

              // Bottom proceed button
              _buildBottomButton(localization, docs, isDark),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDocUploadStep(
    AppLocalizations? localization,
    String docKey,
    bool isDark,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final docLabel = KycDocLabels.label(localization, docKey);
    final isUploaded = _documents.containsKey(docKey);
    final filePath = _documents[docKey];
    File? uploadedFile;
    int fileSize = 0;
    bool isImage = false;
    if (isUploaded && filePath != null) {
      uploadedFile = File(filePath);
      if (uploadedFile.existsSync()) {
        fileSize = uploadedFile.lengthSync();
        final lower = filePath.toLowerCase();
        isImage =
            lower.endsWith('.jpg') ||
            lower.endsWith('.jpeg') ||
            lower.endsWith('.png') ||
            lower.endsWith('.webp');
      }
    }

    final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization?.kycSubmitWizardRequiredDoc ?? 'Required document',
          style: AppTextStyles.bodySmall.copyWith(color: secondaryTextColor),
        ),
        SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                docLabel,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: primaryTextColor,
                ),
              ),
            ),
            if (isUploaded)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 13,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '$fileSizeMB MB / 20 MB',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.md),

        // Real-time tips banner
        _buildTipsBanner(context, isDark),
        SizedBox(height: AppSpacing.md),

        // Upload Area / Thumbnail Preview
        if (!isUploaded)
          Semantics(
            button: true,
            label:
                localization?.kycSubmitWizardTapToUpload ??
                l10nPick(
                  context,
                  en: 'Tap to capture or upload $docLabel',
                  fa: 'برای تصویربرداری یا بارگذاری $docLabel لمس کنید',
                ),
            hint:
                localization?.kycSubmitWizardFileFormat ??
                'JPG, PNG, PDF — Max 20MB',
            child: Material(
              color: AppColors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                onTap: () {
                  HapticFeedback.lightImpact();
                  _pickDocument(docKey, isDark, primaryTextColor);
                },
                child: Container(
                  width: double.infinity,
                  height: 200.h,
                  constraints: BoxConstraints(minWidth: 44.w, minHeight: 44.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                      width: 1.5,
                    ),
                    boxShadow: !isDark
                        ? [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    children: [
                      // Corner alignment guides
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: isDark
                                    ? AppColors.mainSoftBlue
                                    : AppColors.brandViolet,
                                width: 3,
                              ),
                              left: BorderSide(
                                color: isDark
                                    ? AppColors.mainSoftBlue
                                    : AppColors.brandViolet,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: isDark
                                    ? AppColors.mainSoftBlue
                                    : AppColors.brandViolet,
                                width: 3,
                              ),
                              right: BorderSide(
                                color: isDark
                                    ? AppColors.mainSoftBlue
                                    : AppColors.brandViolet,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isDark
                                    ? AppColors.mainSoftBlue
                                    : AppColors.brandViolet,
                                width: 3,
                              ),
                              left: BorderSide(
                                color: isDark
                                    ? AppColors.mainSoftBlue
                                    : AppColors.brandViolet,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isDark
                                    ? AppColors.mainSoftBlue
                                    : AppColors.brandViolet,
                                width: 3,
                              ),
                              right: BorderSide(
                                color: isDark
                                    ? AppColors.mainSoftBlue
                                    : AppColors.brandViolet,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56.w,
                              height: 56.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    (isDark
                                            ? AppColors.mainSoftBlue
                                            : AppColors.brandViolet)
                                        .withValues(alpha: 0.12),
                              ),
                              child: Icon(
                                Icons.cloud_upload_outlined,
                                size: 28.sp,
                                color: isDark
                                    ? AppColors.mainSoftBlue
                                    : AppColors.brandViolet,
                              ),
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              localization?.kycSubmitWizardTapToUpload ??
                                  l10nPick(
                                    context,
                                    en: 'Tap to capture or upload',
                                    fa: 'برای تصویربرداری یا بارگذاری لمس کنید',
                                  ),
                              style: AppTextStyles.titleSmall.copyWith(
                                color: primaryTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              localization?.kycSubmitWizardFileFormat ??
                                  'JPG, PNG, PDF — Max 20MB',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isDark
                                    ? AppColors.softGray
                                    : AppColors.lightTextHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        else
          // Clear Thumbnail Preview Card with File Size Check & Retake Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusLg - 1),
                  ),
                  child: isImage && uploadedFile != null
                      ? SizedBox(
                          height: 180.h,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(uploadedFile, fit: BoxFit.cover),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.black.withValues(
                                      alpha: 0.7,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusSm,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 12,
                                        color: AppColors.success,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '$fileSizeMB MB',
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
                        )
                      : Container(
                          height: 120.h,
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.description_rounded,
                                size: 36.sp,
                                color: AppColors.success,
                              ),
                              SizedBox(width: 10.w),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    filePath?.split('/').last ?? 'Document',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: primaryTextColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '$fileSizeMB MB',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
                Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          button: true,
                          label: l10nPick(
                            context,
                            en: 'Retake or replace $docLabel',
                            fa: 'تغییر یا عکس مجدد مدرک $docLabel',
                            ar: 'إعادة التقاط أو استبدال $docLabel',
                            zh: '重新拍摄或更换 $docLabel',
                          ),
                          child: OutlinedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _pickDocument(docKey, isDark, primaryTextColor);
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(double.infinity, 44.h),
                              side: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: Text(
                              l10nPick(
                                context,
                                en: 'Retake / Replace',
                                fa: 'تغییر یا عکس مجدد',
                                ar: 'إعادة الالتقاط / استبدال',
                                zh: '重新拍摄/更换',
                              ),
                              style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: primaryTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Semantics(
                        button: true,
                        label: l10nPick(
                          context,
                          en: 'Remove $docLabel',
                          fa: 'حذف مدرک $docLabel',
                          ar: 'حذف $docLabel',
                          zh: '删除 $docLabel',
                        ),
                        child: IconButton(
                          constraints: BoxConstraints(
                            minWidth: 44.w,
                            minHeight: 44.h,
                          ),
                          tooltip: l10nPick(context, en: 'Remove', fa: 'حذف'),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.error,
                            size: 20,
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _documents.remove(docKey);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: AppSpacing.lg),

        // Document requirements instruction
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkPrimaryContainer.withValues(alpha: 0.3)
                : AppColors.infoContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: isDark ? AppColors.mainSoftBlue : AppColors.info,
                size: 18.sp,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  KycDocLabels.instruction(localization, docKey),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsBanner(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightOutlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                size: 16,
                color: AppColors.warning,
              ),
              SizedBox(width: 6.w),
              Text(
                l10nPick(
                  context,
                  en: 'Important Photo Guidelines',
                  fa: 'نکات مهم تصویربرداری',
                  ar: 'إرشادات مهمة للتصوير',
                  zh: '拍摄注意事项',
                ),
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.warmWhite : AppColors.deepBlack,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          _buildTipRow(
            Icons.wb_sunny_outlined,
            l10nPick(
              context,
              en: 'Avoid glare and shadows',
              fa: 'از بازتاب مستقیم نور و سایه خودداری کنید',
              ar: 'تجنب الوهج والظلال',
              zh: '避免反光和阴影',
            ),
            isDark,
          ),
          SizedBox(height: 4.h),
          _buildTipRow(
            Icons.crop_free_rounded,
            l10nPick(
              context,
              en: 'Ensure all 4 corners are visible',
              fa: 'مطمئن شوید هر ۴ گوشه مدرک داخل کادر قرار دارد',
              ar: 'تأكد من ظهور الزوايا الأربع',
              zh: '确保四个边角完整可见',
            ),
            isDark,
          ),
          SizedBox(height: 4.h),
          _buildTipRow(
            Icons.text_fields_rounded,
            l10nPick(
              context,
              en: 'Text and photo must be completely legible',
              fa: 'متن و تصویر مدرک باید کاملاً شفاف و خوانا باشد',
              ar: 'يجب أن تكون النصوص واضحة ومقروءة',
              zh: '文字与图像清晰可读',
            ),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 13.sp, color: AppColors.success),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10.5.sp,
              color: isDark ? AppColors.softGray : AppColors.lightTextSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep(
    AppLocalizations? localization,
    KycLevel level,
    List<String> docs,
    bool isDark,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization?.kycSubmitWizardReviewTitle ?? 'Review & submit',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: primaryTextColor,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        ...docs.map(
          (doc) => _ReviewItem(
            label: KycDocLabels.label(localization, doc),
            fileName:
                _documents[doc]?.split('/').last ??
                localization?.kycSubmitWizardNotUploaded ??
                'Not uploaded',
            isUploaded: _documents.containsKey(doc),
            isDark: isDark,
            primaryTextColor: primaryTextColor,
            secondaryTextColor: secondaryTextColor,
          ),
        ),
        SizedBox(height: AppSpacing.xl),
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.warning.withValues(alpha: 0.15)
                : AppColors.warningContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 20.sp,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  localization?.kycSubmitWizardReviewNote ??
                      'After submission your documents are reviewed by an admin. This usually takes 1–2 business days.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(
    AppLocalizations? localization,
    List<String> docs,
    bool isDark,
  ) {
    final isLastStep = _currentStep >= docs.length;
    final currentDoc = (!isLastStep && _currentStep < docs.length)
        ? docs[_currentStep]
        : null;
    final canProceed =
        isLastStep ||
        (currentDoc != null && _documents.containsKey(currentDoc));

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48.h,
          child: Semantics(
            button: true,
            label: isLastStep
                ? (localization?.kycSubmitWizardSubmit ?? 'Submit documents')
                : (localization?.kycSubmitWizardContinue ?? 'Continue'),
            child: ElevatedButton(
              onPressed: canProceed
                  ? (isLastStep
                        ? _submit
                        : () {
                            HapticFeedback.lightImpact();
                            setState(() => _currentStep++);
                          })
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.mainSoftBlue
                    : AppColors.brandViolet,
                foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                elevation: 0,
              ),
              child: Obx(
                () => controller.isSubmitting.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: isDark
                                  ? AppColors.deepBlack
                                  : AppColors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          if (controller.uploadProgress.value > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${(controller.uploadProgress.value * 100).toInt()}%',
                              style: AppTextStyles.labelMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.deepBlack
                                    : AppColors.white,
                              ),
                            ),
                          ],
                        ],
                      )
                    : Text(
                        isLastStep
                            ? (localization?.kycSubmitWizardSubmit ??
                                  'Submit documents')
                            : (localization?.kycSubmitWizardContinue ??
                                  'Continue'),
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.deepBlack : AppColors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDocument(
    String docKey,
    bool isDark,
    Color primaryTextColor,
  ) async {
    final localization = AppLocalizations.of(context);
    final String? source = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkDivider : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                l10nPickAuto(
                  en: 'Select Upload Source',
                  fa: 'انتخاب نحوه بارگذاری مدرک',
                ),
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: primaryTextColor,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Semantics(
                button: true,
                label: l10nPickAuto(
                  en: 'Take a Photo with Camera',
                  fa: 'عکس‌برداری با دوربین',
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 48.h),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    leading: Container(
                      width: 44.w,
                      height: 44.h,
                      decoration: BoxDecoration(
                        color:
                            (isDark
                                    ? AppColors.mainSoftBlue
                                    : AppColors.brandViolet)
                                .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: isDark
                            ? AppColors.mainSoftBlue
                            : AppColors.brandViolet,
                        size: 22.sp,
                      ),
                    ),
                    title: Text(
                      l10nPickAuto(
                        en: 'Take a Photo (Camera)',
                        fa: 'عکس‌برداری با دوربین',
                      ),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
                    ),
                    onTap: () => Navigator.pop(ctx, 'camera'),
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Semantics(
                button: true,
                label: l10nPickAuto(
                  en: 'Choose from Gallery',
                  fa: 'انتخاب تصویر از گالری',
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 48.h),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    leading: Container(
                      width: 44.w,
                      height: 44.h,
                      decoration: BoxDecoration(
                        color:
                            (isDark
                                    ? AppColors.mainSoftBlue
                                    : AppColors.brandViolet)
                                .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      child: Icon(
                        Icons.photo_library_outlined,
                        color: isDark
                            ? AppColors.mainSoftBlue
                            : AppColors.brandViolet,
                        size: 22.sp,
                      ),
                    ),
                    title: Text(
                      l10nPickAuto(
                        en: 'Choose from Gallery',
                        fa: 'انتخاب تصویر از گالری',
                      ),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
                    ),
                    onTap: () => Navigator.pop(ctx, 'gallery'),
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Semantics(
                button: true,
                label: l10nPickAuto(
                  en: 'Choose PDF Document',
                  fa: 'انتخاب سند با فرمت PDF',
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 48.h),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    leading: Container(
                      width: 44.w,
                      height: 44.h,
                      decoration: BoxDecoration(
                        color:
                            (isDark
                                    ? AppColors.mainSoftBlue
                                    : AppColors.brandViolet)
                                .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      child: Icon(
                        Icons.picture_as_pdf_outlined,
                        color: isDark
                            ? AppColors.mainSoftBlue
                            : AppColors.brandViolet,
                        size: 22.sp,
                      ),
                    ),
                    title: Text(
                      l10nPickAuto(
                        en: 'Choose PDF Document',
                        fa: 'انتخاب سند با فرمت PDF',
                      ),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
                    ),
                    onTap: () => Navigator.pop(ctx, 'pdf'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      String? filePath;
      if (source == 'camera') {
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          maxWidth: 1920,
          maxHeight: 1080,
        );
        filePath = photo?.path;
      } else if (source == 'gallery') {
        final XFile? picked = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1920,
          maxHeight: 1080,
        );
        filePath = picked?.path;
      } else if (source == 'pdf') {
        final FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        if (result != null && result.files.single.path != null) {
          filePath = result.files.single.path;
        }
      }

      if (filePath != null && filePath.isNotEmpty) {
        final file = File(filePath);
        if (UploadHelper.exceedsSize(file, UploadHelper.maxKycDocBytes)) {
          ToastHelper().showErrorToast(
            l10nPickAuto(
              en: 'File size must not exceed 20MB',
              fa: 'حجم فایل نباید بیشتر از ۲۰ مگابایت باشد',
            ),
          );
          return;
        }
        setState(() {
          _documents[docKey] = filePath!;
        });
      }
    } catch (e) {
      debugPrint('pickDocument error: $e');
      ToastHelper().showErrorToast(
        localization?.pickDocumentFailed ??
            l10nPickAuto(
              en: 'Failed to pick document. Please try again.',
              fa: 'انتخاب مدرک ناموفق بود. لطفاً دوباره تلاش کنید.',
            ),
      );
    }
  }

  Future<void> _submit() async {
    HapticFeedback.mediumImpact();
    final success = await controller.submitDocuments(
      documents: _documents,
      targetLevel: _targetLevel,
    );
    if (success) {
      Get.offAllNamed(BaseRoute.navigation);
    }
  }
}

class _StepCircle extends StatelessWidget {
  final int step;
  final bool isActive;
  final bool isCurrent;
  final bool isDark;

  const _StepCircle({
    required this.step,
    required this.isActive,
    required this.isCurrent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.mainSoftBlue : AppColors.brandViolet;
    final inactiveColor = isDark ? AppColors.darkCard : AppColors.lightBorder;

    return Semantics(
      label:
          'Step $step: ${isActive ? "completed" : (isCurrent ? "current" : "pending")}',
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? activeColor : inactiveColor,
          border: isCurrent && !isActive
              ? Border.all(color: activeColor, width: 2)
              : null,
        ),
        child: Center(
          child: Icon(
            isActive ? Icons.check : Icons.circle,
            color: isActive
                ? (isDark ? AppColors.deepBlack : AppColors.white)
                : (isDark ? AppColors.softGray : AppColors.lightTextHint),
            size: 15.sp,
          ),
        ),
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String label;
  final String fileName;
  final bool isUploaded;
  final bool isDark;
  final Color primaryTextColor;
  final Color secondaryTextColor;

  const _ReviewItem({
    required this.label,
    required this.fileName,
    required this.isUploaded,
    required this.isDark,
    required this.primaryTextColor,
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final isPdf = fileName.toLowerCase().endsWith('.pdf');
    final icon = !isUploaded
        ? Icons.error_outline_rounded
        : (isPdf ? Icons.picture_as_pdf_rounded : Icons.check_circle_rounded);
    final iconColor = isUploaded
        ? (isPdf
              ? (isDark ? AppColors.mainSoftBlue : AppColors.brandViolet)
              : AppColors.success)
        : AppColors.error;

    return Semantics(
      label: '$label: ${isUploaded ? fileName : "Not uploaded"}',
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isUploaded
                ? AppColors.success.withValues(alpha: 0.4)
                : AppColors.error,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20.sp),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: primaryTextColor,
                    ),
                  ),
                  Text(
                    fileName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
