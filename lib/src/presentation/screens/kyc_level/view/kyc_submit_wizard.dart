import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/helper/upload_helper.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/model/kyc_level_model.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/view/kyc_labels.dart';

/// KycSubmitWizard — جادوگر مرحله‌به‌مرحله ارسال مدارک KYC
///
/// مراحل:
///   ۱. نمایش مدارک لازم برای سطح هدف
///   ۲. آپلود هر مدرک (image picker)
///   ۳. بررسی و تأیید
///   ۴. ارسال
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

  void _handleBack() {
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
    return PopScope(
      canPop: _currentStep == 0 && Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.lightSurface,
        appBar: AppBar(
          backgroundColor: AppColors.lightSurface,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.lightTextPrimary),
            onPressed: _handleBack,
          ),
          title: Text(
          localization?.kycSubmitWizardTitleForLevel(widget.targetLevel) ??
              'Verification — level ${widget.targetLevel}',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.levels.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // پیدا کردن سطح هدف
        final targetLevel = controller.levels
            .where((l) => l.level == widget.targetLevel)
            .firstOrNull;

        if (targetLevel == null) {
          return Center(child: Text(
            localization?.kycSubmitWizardInvalidLevel ?? 'Invalid level',
            style: TextStyle(color: AppColors.lightTextSecondary),
          ));
        }

        final docs = targetLevel.requiredDocs;
        // QC-M4: a level with zero docs must not produce a negative
        // List.generate range — render the review step directly instead.
        final hasDocs = docs.isNotEmpty;

        return Column(
          children: [
            // Progress indicator
            if (hasDocs)
              Container(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: List.generate(docs.length * 2 - 1, (index) {
                    if (index.isOdd) {
                      return Expanded(child: Container(height: 2, margin: EdgeInsets.symmetric(horizontal: 4), color: _currentStep > index ~/ 2 ? AppColors.lightPrimary : AppColors.lightBorder));
                    }
                    final stepIdx = index ~/ 2;
                    return _StepCircle(step: stepIdx + 1, isActive: _currentStep >= stepIdx, isCurrent: _currentStep == stepIdx);
                  }),
                ),
              ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: hasDocs && _currentStep < docs.length
                    ? _buildDocUploadStep(localization, docs[_currentStep])
                    : _buildReviewStep(localization, targetLevel, docs),
              ),
            ),

            // Bottom button
            _buildBottomButton(localization, docs),
          ],
        );
      }),
    ),
    );
  }

  Widget _buildDocUploadStep(AppLocalizations? localization, String docKey) {
    // v1.1 (KYC-DOC): shared localized labels — unknown per-country keys
    // (e.g. national_card for IR users) render with a readable generic
    // label and never crash.
    final docLabel = KycDocLabels.label(localization, docKey);
    final isUploaded = _documents.containsKey(docKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization?.kycSubmitWizardRequiredDoc ?? 'Required document',
          style: TextStyle(fontSize: 14.sp, color: AppColors.lightTextSecondary),
        ),
        SizedBox(height: 8.h),
        Text(docLabel, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary)),
        SizedBox(height: 24.h),
        GestureDetector(
          onTap: () => _pickDocument(docKey),
          child: Container(
            width: double.infinity,
            height: 200.h,
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isUploaded ? AppColors.success : AppColors.lightBorder, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isUploaded ? Icons.check_circle : Icons.upload_file, size: 48.sp, color: isUploaded ? AppColors.success : AppColors.lightPrimary),
                SizedBox(height: 8.h),
                Text(
                  isUploaded
                      ? (localization?.kycSubmitWizardUploaded(
                            _documents[docKey]!.split('/').last,
                          ) ??
                          'Uploaded: ${_documents[docKey]!.split('/').last}')
                      : (localization?.kycSubmitWizardTapToUpload ??
                          'Tap to upload'),
                  style: TextStyle(fontSize: 14.sp, color: isUploaded ? AppColors.success : AppColors.lightTextSecondary),
                ),
                if (!isUploaded) ...[
                  SizedBox(height: 4.h),
                  Text(
                    localization?.kycSubmitWizardFileFormat ??
                        'Format: JPG, PNG, PDF — max 20MB',
                    style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextHint),
                  ),
                ],
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
        // Document requirements
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(color: AppColors.infoContainer, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 18.sp),
              SizedBox(width: 8.w),
              Expanded(child: Text(
                KycDocLabels.instruction(localization, docKey),
                style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextPrimary),
              )),
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
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization?.kycSubmitWizardReviewTitle ?? 'Review & submit',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary),
        ),
        SizedBox(height: 16.h),
        ...docs.map((doc) => _ReviewItem(label: KycDocLabels.label(localization, doc), fileName: _documents[doc]?.split('/').last ?? localization?.kycSubmitWizardNotUploaded ?? 'Not uploaded', isUploaded: _documents.containsKey(doc))),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(color: AppColors.warningContainer, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Icon(Icons.warning_amber, color: AppColors.warning, size: 18.sp),
              SizedBox(width: 8.w),
              Expanded(child: Text(
                localization?.kycSubmitWizardReviewNote ??
                    'After submission your documents are reviewed by an admin. This usually takes 1–2 business days.',
                style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextPrimary),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(
    AppLocalizations? localization,
    List<String> docs,
  ) {
    final isLastStep = _currentStep >= docs.length;
    final currentDoc =
        (!isLastStep && _currentStep < docs.length) ? docs[_currentStep] : null;
    final canProceed = isLastStep || (currentDoc != null && _documents.containsKey(currentDoc));

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: AppColors.lightSurface, boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))]),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: canProceed ? (isLastStep ? _submit : () => setState(() => _currentStep++)) : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: Obx(() => controller.isSubmitting.value
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    isLastStep
                        ? (localization?.kycSubmitWizardSubmit ?? 'Submit documents')
                        : (localization?.kycSubmitWizardContinue ?? 'Continue'),
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                  )),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDocument(String docKey) async {
    final localization = AppLocalizations.of(context);
    final String? source = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                l10nPickAuto(
                  en: 'Select Upload Source',
                  fa: 'انتخاب نحوه بارگذاری مدرک',
                ),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.lightPrimary),
                title: Text(
                  l10nPickAuto(en: 'Take a Photo (Camera)', fa: 'عکس‌برداری با دوربین'),
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                onTap: () => Navigator.pop(ctx, 'camera'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.lightPrimary),
                title: Text(
                  l10nPickAuto(en: 'Choose from Gallery', fa: 'انتخاب تصویر از گالری'),
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.lightPrimary),
                title: Text(
                  l10nPickAuto(en: 'Choose PDF Document', fa: 'انتخاب سند با فرمت PDF'),
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
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
            l10nPickAuto(en: 'Failed to pick document. Please try again.', fa: 'انتخاب مدرک ناموفق بود. لطفاً دوباره تلاش کنید.'),
      );
    }
  }

  Future<void> _submit() async {
    // BUG-04: تبدیل File به multipart upload
    final success = await controller.submitDocuments(documents: _documents, targetLevel: widget.targetLevel);
    if (success) {
      Get.offAllNamed(BaseRoute.navigation);
    }
  }
}

class _StepCircle extends StatelessWidget {
  final int step;
  final bool isActive;
  final bool isCurrent;
  const _StepCircle({required this.step, required this.isActive, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.w, height: 32.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.lightPrimary : AppColors.lightBorder,
        border: isCurrent && !isActive ? Border.all(color: AppColors.lightPrimary, width: 2) : null,
      ),
      child: Center(child: Icon(isActive ? Icons.check : Icons.circle, color: isActive ? AppColors.white : AppColors.lightTextHint, size: 16.sp)),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String label;
  final String fileName;
  final bool isUploaded;
  const _ReviewItem({required this.label, required this.fileName, required this.isUploaded});

  @override
  Widget build(BuildContext context) {
    final isPdf = fileName.toLowerCase().endsWith('.pdf');
    final icon = !isUploaded
        ? Icons.error
        : (isPdf ? Icons.picture_as_pdf_rounded : Icons.check_circle);
    final iconColor = isUploaded
        ? (isPdf ? AppColors.lightPrimary : AppColors.success)
        : AppColors.error;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isUploaded ? AppColors.success : AppColors.error),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  fileName,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.lightTextSecondary,
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
