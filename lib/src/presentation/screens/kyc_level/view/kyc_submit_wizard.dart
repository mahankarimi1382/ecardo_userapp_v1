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
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;

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
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryTextColor),
            onPressed: _handleBack,
          ),
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
                color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
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
                style: AppTextStyles.bodyMedium.copyWith(color: secondaryTextColor),
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
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: AppSpacing.sm),
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF450A0A).withValues(alpha: 0.35)
                        : AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
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
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: AppSpacing.md),
                  child: Row(
                    children: List.generate(docs.length * 2 - 1, (index) {
                      if (index.isOdd) {
                        return Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            color: _currentStep > index ~/ 2
                                ? (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                                : (isDark ? AppColors.darkDivider : AppColors.lightBorder),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization?.kycSubmitWizardRequiredDoc ?? 'Required document',
          style: AppTextStyles.bodySmall.copyWith(color: secondaryTextColor),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          docLabel,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: primaryTextColor,
          ),
        ),
        SizedBox(height: AppSpacing.xl),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _pickDocument(docKey, isDark, primaryTextColor);
          },
          child: Container(
            width: double.infinity,
            height: 190.h,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: isUploaded
                    ? AppColors.success
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                width: isUploaded ? 2 : 1.2,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isUploaded ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                  size: 46.sp,
                  color: isUploaded
                      ? AppColors.success
                      : (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  isUploaded
                      ? (localization?.kycSubmitWizardUploaded(
                            _documents[docKey]!.split('/').last,
                          ) ??
                          'Uploaded: ${_documents[docKey]!.split('/').last}')
                      : (localization?.kycSubmitWizardTapToUpload ??
                          'Tap to upload'),
                  style: AppTextStyles.titleSmall.copyWith(
                    color: isUploaded ? AppColors.success : primaryTextColor,
                    fontWeight: isUploaded ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                if (!isUploaded) ...[
                  SizedBox(height: 4.h),
                  Text(
                    localization?.kycSubmitWizardFileFormat ??
                        'Format: JPG, PNG, PDF — max 20MB',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark ? AppColors.softGray : AppColors.lightTextHint,
                    ),
                  ),
                ],
              ],
            ),
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
        ...docs.map((doc) => _ReviewItem(
              label: KycDocLabels.label(localization, doc),
              fileName: _documents[doc]?.split('/').last ??
                  localization?.kycSubmitWizardNotUploaded ??
                  'Not uploaded',
              isUploaded: _documents.containsKey(doc),
              isDark: isDark,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
            )),
        SizedBox(height: AppSpacing.xl),
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF78350F).withValues(alpha: 0.25)
                : AppColors.warningContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20.sp),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  localization?.kycSubmitWizardReviewNote ??
                      'After submission your documents are reviewed by an admin. This usually takes 1–2 business days.',
                  style: AppTextStyles.bodySmall.copyWith(color: primaryTextColor),
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
    final currentDoc =
        (!isLastStep && _currentStep < docs.length) ? docs[_currentStep] : null;
    final canProceed =
        isLastStep || (currentDoc != null && _documents.containsKey(currentDoc));

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
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
              backgroundColor: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
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
                            color: isDark ? AppColors.deepBlack : AppColors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        if (controller.uploadProgress.value > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${(controller.uploadProgress.value * 100).toInt()}%',
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.deepBlack : AppColors.white,
                            ),
                          ),
                        ],
                      ],
                    )
                  : Text(
                      isLastStep
                          ? (localization?.kycSubmitWizardSubmit ?? 'Submit documents')
                          : (localization?.kycSubmitWizardContinue ?? 'Continue'),
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.deepBlack : AppColors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDocument(String docKey, bool isDark, Color primaryTextColor) async {
    final localization = AppLocalizations.of(context);
    final String? source = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: AppSpacing.md),
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
              ListTile(
                leading: Icon(
                  Icons.camera_alt_outlined,
                  color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                ),
                title: Text(
                  l10nPickAuto(en: 'Take a Photo (Camera)', fa: 'عکس‌برداری با دوربین'),
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                onTap: () => Navigator.pop(ctx, 'camera'),
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library_outlined,
                  color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                ),
                title: Text(
                  l10nPickAuto(en: 'Choose from Gallery', fa: 'انتخاب تصویر از گالری'),
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
              ListTile(
                leading: Icon(
                  Icons.picture_as_pdf_outlined,
                  color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                ),
                title: Text(
                  l10nPickAuto(en: 'Choose PDF Document', fa: 'انتخاب سند با فرمت PDF'),
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                onTap: () => Navigator.pop(ctx, 'pdf'),
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
    final activeColor = isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary;
    final inactiveColor = isDark ? AppColors.darkCard : AppColors.lightBorder;

    return Container(
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
        ? (isPdf ? (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary) : AppColors.success)
        : AppColors.error;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isUploaded ? AppColors.success.withValues(alpha: 0.4) : AppColors.error,
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
    );
  }
}
