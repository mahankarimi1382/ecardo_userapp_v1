import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_spacing.dart';
import '../../helper/l10n_pick.dart';
import '../controllers/visa_controller.dart';
import '../models/visa_models.dart';
import '../widgets/visa_widgets.dart';
import 'visa_payment_screen.dart';

class VisaApplicationScreen extends StatelessWidget {
  final VisaCatalogItem catalog;

  const VisaApplicationScreen({super.key, required this.catalog});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<VisaController>()
        ? Get.find<VisaController>()
        : Get.put(VisaController());

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          l10nPick(context, en: 'Visa Application', fa: 'فرم درخواست ویزا'),
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            size: AppSpacing.iconSm.r,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final isBusy = controller.isSubmitting.value;

        return Stack(
          children: [
            ListView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg.w,
                vertical: AppSpacing.lg.h,
              ),
              children: [
                // Top Destination Info Bar
                VisaCard(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md.w,
                    vertical: AppSpacing.md.h,
                  ),
                  child: Row(
                    children: [
                      VisaCountryFlag(flagUrl: catalog.countryFlag, size: 36),
                      SizedBox(width: AppSpacing.md.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              catalog.countryName,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              catalog.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${catalog.totalFee.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg.h),

                // Section 1: Passenger / Applicant Info
                VisaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                            size: AppSpacing.iconSm.r,
                          ),
                          SizedBox(width: AppSpacing.sm.w),
                          Text(
                            l10nPick(context, en: 'Applicant Information', fa: 'مشخصات متقاضی (مطابق گذرنامه)'),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md.h),

                      // Full Name (Latin)
                      _textField(
                        context: context,
                        isDark: isDark,
                        controller: controller.fullNameController,
                        label: l10nPick(context, en: 'Full Name (Latin as in passport)', fa: 'نام و نام خانوادگی به انگلیسی'),
                        hint: 'e.g. ALI REZAEI',
                        keyboardType: TextInputType.name,
                      ),
                      SizedBox(height: AppSpacing.md.h),

                      // Passport Number
                      _textField(
                        context: context,
                        isDark: isDark,
                        controller: controller.passportNumberController,
                        label: l10nPick(context, en: 'Passport Number', fa: 'شماره گذرنامه'),
                        hint: 'e.g. A12345678',
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: AppSpacing.md.h),

                      // Phone Number
                      _textField(
                        context: context,
                        isDark: isDark,
                        controller: controller.phoneController,
                        label: l10nPick(context, en: 'Contact Phone Number', fa: 'شماره تماس'),
                        hint: 'e.g. +989123456789',
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: AppSpacing.md.h),

                      // Email
                      _textField(
                        context: context,
                        isDark: isDark,
                        controller: controller.emailController,
                        label: l10nPick(context, en: 'Email Address (for e-visa delivery)', fa: 'ایمیل دریافت ویزا الکترونیک'),
                        hint: 'e.g. yourname@example.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: AppSpacing.md.h),

                      // Travel Date Picker
                      Text(
                        l10nPick(context, en: 'Intended Travel Date', fa: 'تاریخ تقریبی سفر'),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      InkWell(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: controller.travelDate.value ?? now.add(const Duration(days: 7)),
                            firstDate: now,
                            lastDate: now.add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            controller.travelDate.value = picked;
                          }
                        },
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md.w,
                            vertical: AppSpacing.md.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            color: isDark ? AppColors.darkSurfaceVariant : AppColors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.travelDate.value != null
                                    ? "${controller.travelDate.value!.year}-${controller.travelDate.value!.month.toString().padLeft(2, '0')}-${controller.travelDate.value!.day.toString().padLeft(2, '0')}"
                                    : l10nPick(context, en: 'Select date', fa: 'انتخاب تاریخ'),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: controller.travelDate.value != null
                                      ? (isDark ? AppColors.darkTextPrimary : AppColors.deepBlack)
                                      : (isDark ? AppColors.darkTextSecondary : AppColors.softGray),
                                ),
                              ),
                              Icon(
                                Icons.calendar_today_outlined,
                                size: AppSpacing.iconSm.r,
                                color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg.h),

                // Section 2: Documents Checklist
                VisaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.upload_file_rounded,
                            color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                            size: AppSpacing.iconSm.r,
                          ),
                          SizedBox(width: AppSpacing.sm.w),
                          Text(
                            l10nPick(context, en: 'Document Checklist', fa: 'چک‌لیست مدارک موردنیاز'),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Upload clear scans or photos (JPG, PNG, or PDF up to 5MB).',
                          fa: 'تصاویر واضح یا اسکن با فرمت‌های مجاز JPG، PNG یا PDF تا حداکثر ۵ مگابایت بارگذاری نمایید.',
                        ),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md.h),

                      // Document upload items
                      if (catalog.requiredDocs.isEmpty)
                        _buildUploadItem(
                          controller: controller,
                          docKey: 'passport_scan',
                          title: l10nPick(context, en: 'Passport Scan', fa: 'اسکن صفحه اول گذرنامه'),
                          instructions: l10nPick(context, en: 'Must be valid for at least 6 months.', fa: 'حداقل ۶ ماه اعتبار قانونی داشته باشد.'),
                          isRequired: true,
                        )
                      else
                        ...catalog.requiredDocs.map(
                          (doc) => _buildUploadItem(
                            controller: controller,
                            docKey: doc.key,
                            title: doc.title,
                            instructions: doc.instructions,
                            isRequired: doc.required,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 100.h),
              ],
            ),

            if (isBusy)
              Container(
                color: AppColors.black.withValues(alpha: 0.35),
                child: Center(
                  child: CircularProgressIndicator(
                    color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                  ),
                ),
              ),
          ],
        );
      }),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg.w,
          vertical: AppSpacing.md.h,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () async {
              HapticFeedback.lightImpact();
              final req = await controller.submitApplication();
              if (req != null) {
                Get.to(() => VisaPaymentScreen(request: req));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
              foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10nPick(context, en: 'Proceed to Payment', fa: 'تأیید و رفتن به پرداخت'),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: AppSpacing.sm.w),
                const Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadItem({
    required VisaController controller,
    required String docKey,
    required String title,
    required String instructions,
    required bool isRequired,
  }) {
    return Obx(() {
      final pickedFile = controller.pickedFiles[docKey];
      final isUploading = controller.uploadProgress[docKey] == true;

      return VisaDocUploadCard(
        title: title,
        instructions: instructions,
        isRequired: isRequired,
        pickedFile: pickedFile,
        isUploading: isUploading,
        onPickFile: () async {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'webp'],
          );
          if (result != null && result.files.single.path != null) {
            controller.pickDocumentFile(
              docKey,
              File(result.files.single.path!),
            );
          }
        },
      );
    });
  }

  Widget _textField({
    required BuildContext context,
    required bool isDark,
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.xs.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.white,
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 13.5.sp,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 12.5.sp,
                color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md.w,
                vertical: AppSpacing.md.h,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
