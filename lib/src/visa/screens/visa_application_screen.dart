import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          l10nPick(context, en: 'Visa Application', fa: 'فرم درخواست ویزا'),
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final isBusy = controller.isSubmitting.value;

        return Stack(
          children: [
            ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              children: [
                // Top Destination Info Bar
                VisaCard(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  child: Row(
                    children: [
                      VisaCountryFlag(flagUrl: catalog.countryFlag, size: 36),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              catalog.countryName,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              catalog.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11.5.sp, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${catalog.totalFee.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF7445FF),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Section 1: Passenger / Applicant Info
                VisaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, color: Color(0xFF7445FF), size: 20),
                          SizedBox(width: 8.w),
                          Text(
                            l10nPick(context, en: 'Applicant Information', fa: 'مشخصات متقاضی (مطابق گذرنامه)'),
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),

                      // Full Name (English)
                      _textField(
                        controller: controller.fullNameController,
                        label: l10nPick(context, en: 'Full Name (Latin as in passport)', fa: 'نام و نام خانوادگی (انگلیسی مطابق گذرنامه)'),
                        hint: 'e.g. ALI REZAEI',
                        keyboardType: TextInputType.name,
                      ),
                      SizedBox(height: 12.h),

                      // Passport Number
                      _textField(
                        controller: controller.passportNumberController,
                        label: l10nPick(context, en: 'Passport Number', fa: 'شماره گذرنامه'),
                        hint: 'e.g. A12345678',
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: 12.h),

                      // Phone Number
                      _textField(
                        controller: controller.phoneController,
                        label: l10nPick(context, en: 'Contact Phone Number', fa: 'شماره تماس در دسترس'),
                        hint: 'e.g. +989123456789',
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 12.h),

                      // Email
                      _textField(
                        controller: controller.emailController,
                        label: l10nPick(context, en: 'Email Address (for e-visa delivery)', fa: 'ایمیل دریافت‌کننده ویزای الکترونیک'),
                        hint: 'e.g. yourname@example.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 12.h),

                      // Travel Date Picker
                      Text(
                        l10nPick(context, en: 'Intended Travel Date', fa: 'تاریخ تقریبی سفر'),
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF334155)),
                      ),
                      SizedBox(height: 6.h),
                      InkWell(
                        onTap: () async {
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
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.travelDate.value != null
                                    ? "${controller.travelDate.value!.year}-${controller.travelDate.value!.month.toString().padLeft(2, '0')}-${controller.travelDate.value!.day.toString().padLeft(2, '0')}"
                                    : l10nPick(context, en: 'Select date', fa: 'انتخاب تاریخ سفر'),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: controller.travelDate.value != null ? Colors.black87 : Colors.grey,
                                ),
                              ),
                              const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF7445FF)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Section 2: Documents Checklist
                VisaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.upload_file_rounded, color: Color(0xFF7445FF), size: 20),
                          SizedBox(width: 8.w),
                          Text(
                            l10nPick(context, en: 'Document Checklist', fa: 'چک‌لیست مدارک موردنیاز'),
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Upload clear scans or photos (JPG, PNG, or PDF up to 5MB).',
                          fa: 'تصاویر واضح یا اسکن با فرمت‌های مجاز JPG، PNG یا PDF تا سقف ۵ مگابایت بارگذاری فرمایید.',
                        ),
                        style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
                      ),
                      SizedBox(height: 14.h),

                      // Document upload items
                      if (catalog.requiredDocs.isEmpty)
                        _UploadItemTile(
                          docKey: 'passport_scan',
                          title: l10nPick(context, en: 'Passport Scan', fa: 'اسکن صفحه اول گذرنامه'),
                          instructions: l10nPick(context, en: 'Must be valid for at least 6 months.', fa: 'دارای حداقل ۶ ماه اعتبار.'),
                          isRequired: true,
                        )
                      else
                        ...catalog.requiredDocs.map(
                          (doc) => _UploadItemTile(
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
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      }),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () async {
              final req = await controller.submitApplication();
              if (req != null) {
                Get.to(() => VisaPaymentScreen(request: req));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7445FF),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
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
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8.w),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField({
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
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF334155)),
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFCBD5E1)),
            color: Colors.white,
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 13.5.sp),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 12.5.sp, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            ),
          ),
        ),
      ],
    );
  }
}

class _UploadItemTile extends StatelessWidget {
  final String docKey;
  final String title;
  final String instructions;
  final bool isRequired;

  const _UploadItemTile({
    required this.docKey,
    required this.title,
    required this.instructions,
    required this.isRequired,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VisaController>();

    return Obx(() {
      final pickedFile = controller.pickedFiles[docKey];
      final isUploading = controller.uploadProgress[docKey] == true;

      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: pickedFile != null ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: pickedFile != null ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor: pickedFile != null ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
              child: Icon(
                pickedFile != null ? Icons.check_circle_rounded : Icons.file_upload_outlined,
                color: pickedFile != null ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                size: 20.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      if (isRequired) ...[
                        SizedBox(width: 4.w),
                        Text('*', style: TextStyle(color: Colors.red, fontSize: 13.sp)),
                      ],
                    ],
                  ),
                  if (pickedFile != null)
                    Text(
                      pickedFile.path.split('/').last.split('\\').last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10.5.sp, color: const Color(0xFF16A34A), fontWeight: FontWeight.w600),
                    )
                  else if (instructions.isNotEmpty)
                    Text(
                      instructions,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10.5.sp, color: const Color(0xFF64748B)),
                    ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            if (isUploading)
              const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
            else
              TextButton(
                onPressed: () async {
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
                style: TextButton.styleFrom(
                  backgroundColor: pickedFile != null ? const Color(0xFFE2E8F0) : const Color(0xFF7445FF),
                  foregroundColor: pickedFile != null ? const Color(0xFF334155) : Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text(
                  pickedFile != null
                      ? l10nPick(context, en: 'Change', fa: 'تغییر')
                      : l10nPick(context, en: 'Upload', fa: 'انتخاب فایل'),
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
      );
    });
  }
}
