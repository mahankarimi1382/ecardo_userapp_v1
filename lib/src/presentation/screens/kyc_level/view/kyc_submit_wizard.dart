import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/model/kyc_level_model.dart';

/// KycSubmitWizard — جادوگر مرحله‌به‌مرحله ارسال مدارک KYC
///
/// مراحل:
///   ۱. نمایش مدارک لازم برای سطح هدف
///   ۲. آپلود هر مدرک (image picker)
///   ۳. بررسی و تأیید
///   ۴. ارسال
class KycSubmitWizard extends StatefulWidget {
  final int targetLevel;

  const KycSubmitWizard({super.key, required this.targetLevel});

  @override
  State<KycSubmitWizard> createState() => _KycSubmitWizardState();
}

class _KycSubmitWizardState extends State<KycSubmitWizard> {
  final KycLevelController controller = Get.find<KycLevelController>();
  final Map<String, String> _documents = {};
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.lightTextPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'احراز هویت — سطح ${widget.targetLevel}',
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
          return Center(child: Text('سطح نامعتبر', style: TextStyle(color: AppColors.lightTextSecondary)));
        }

        final docs = targetLevel.requiredDocs;

        return Column(
          children: [
            // Progress indicator
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
                child: _currentStep < docs.length
                    ? _buildDocUploadStep(docs[_currentStep])
                    : _buildReviewStep(targetLevel, docs),
              ),
            ),

            // Bottom button
            _buildBottomButton(docs.length),
          ],
        );
      }),
    );
  }

  Widget _buildDocUploadStep(String docKey) {
    final docLabel = _docLabel(docKey);
    final isUploaded = _documents.containsKey(docKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('مدرک مورد نیاز', style: TextStyle(fontSize: 14.sp, color: AppColors.lightTextSecondary)),
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
                Text(isUploaded ? 'آپلود شد: ${_documents[docKey]!.split('/').last}' : 'برای آپلود لمس کنید', style: TextStyle(fontSize: 14.sp, color: isUploaded ? AppColors.success : AppColors.lightTextSecondary)),
                if (!isUploaded) ...[
                  SizedBox(height: 4.h),
                  Text('فرمت: JPG, PNG, PDF — حداکثر ۵MB', style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextHint)),
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
              Expanded(child: Text(_docInstructions(docKey), style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextPrimary))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep(KycLevel level, List<String> docs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('بررسی و ارسال', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary)),
        SizedBox(height: 16.h),
        ...docs.map((doc) => _ReviewItem(label: _docLabel(doc), fileName: _documents[doc]?.split('/').last ?? 'آپلود نشده', isUploaded: _documents.containsKey(doc))),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(color: AppColors.warningContainer, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Icon(Icons.warning_amber, color: AppColors.warning, size: 18.sp),
              SizedBox(width: 8.w),
              Expanded(child: Text('پس از ارسال، مدارک توسط ادمین بررسی می‌شود. این فرآیند معمولاً ۱-۲ روز کاری طول می‌کشد.', style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextPrimary))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(int totalSteps) {
    final isLastStep = _currentStep >= totalSteps;
    final currentDoc = isLastStep ? null : controller.levels.where((l) => l.level == widget.targetLevel).first.requiredDocs[_currentStep];
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
                : Text(isLastStep ? 'ارسال مدارک' : 'ادامه', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700))),
          ),
        ),
      ),
    );
  }

  void _pickDocument(String docKey) {
    // شبیه‌سازی آپلود — در نسخه واقعی از image_picker استفاده می‌شود
    setState(() {
      _documents[docKey] = 'uploads/kyc/${docKey}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    });
  }

  Future<void> _submit() async {
    final success = await controller.submitDocuments(documents: _documents, targetLevel: widget.targetLevel);
    if (success) {
      Get.offAllNamed(BaseRoute.navigation);
    }
  }

  String _docLabel(String doc) => switch (doc) {
    'selfie' => 'سلفی چهره',
    'govt_id' => 'مدرک شناسایی (کارت ملی/شناسنامه/پاسپورت)',
    'personal_info' => 'اطلاعات شخصی',
    'trade_license' => 'جواز تجارت',
    'business_info' => 'اطلاعات کسب‌وکار',
    'company_docs' => 'مدارک شرکت',
    _ => doc,
  };

  String _docInstructions(String doc) => switch (doc) {
    'selfie' => 'یک سلفی واضح از چهره خود بگیرید. نور کافی و صورت کاملاً مشخص باشد.',
    'govt_id' => 'عکس واضح از روی و پشت مدرک شناسایی. تمام اطلاعات خوانا باشد.',
    'personal_info' => 'اطلاعات شخصی شامل آدرس، کد پستی و شماره تماس.',
    'trade_license' => 'نسخه اسکن شده جواز تجارت معتبر.',
    'business_info' => 'اطلاعات کامل کسب‌وکار شامل نام، نوع فعالیت و آدرس.',
    'company_docs' => 'مدارک ثبت شرکت، اساسنامه و آگهی تأسیس.',
    _ => 'مدرک مورد نیاز را آپلود کنید.',
  };
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
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 8.h),
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(color: AppColors.lightSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: isUploaded ? AppColors.success : AppColors.error)),
    child: Row(children: [
      Icon(isUploaded ? Icons.check_circle : Icons.error, color: isUploaded ? AppColors.success : AppColors.error, size: 20.sp),
      SizedBox(width: 10.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
        Text(fileName, style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary)),
      ])),
    ]),
  );
}
