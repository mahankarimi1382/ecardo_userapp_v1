import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/model/payment_account_response_model.dart';

class PaymentAccountDetailsBottomSheet extends StatelessWidget {
  final PaymentAccount account;

  const PaymentAccountDetailsBottomSheet({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final fields = account.fields ?? <Field>[];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(20.r),
          topEnd: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            spreadRadius: 0,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 45.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30.r),
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  account.paymentMethod?.name ?? 'Payment Account',
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w800,
                    fontSize: 16.sp,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: Get.back,
                  child: Image.asset(
                    PngAssets.closeCommonIcon,
                    width: 20.w,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 18.w),
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.white,
                  AppColors.lightTextPrimary.withValues(alpha: 0.10),
                  AppColors.white,
                ],
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsetsDirectional.fromSTEB(18.w, 16.h, 18.w, 28.h),
              child: Column(
                children: [
                  if (fields.isEmpty) _buildDetailRow('Details', '--'),
                  ...fields.map(
                    (field) => _buildDetailRow(
                      field.name ?? '--',
                      field.value ?? '--',
                      isImage: _isImageField(field),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isImage = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: AppColors.lightTextPrimary.withValues(alpha: 0.60),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: isImage
                ? GestureDetector(
                    onTap: () => _showImagePreviewDialog(value),
                    child: Text(
                      _extractFileName(value),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                        color: AppColors.lightPrimary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(
                    value,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  bool _isImageField(Field field) {
    final type = (field.type ?? '').trim().toLowerCase();
    final value = (field.value ?? '').trim().toLowerCase();

    if (value.isEmpty) return false;
    if (type.contains('image') || type.contains('file')) return true;
    return value.endsWith('.png') ||
        value.endsWith('.jpg') ||
        value.endsWith('.jpeg') ||
        value.endsWith('.webp') ||
        value.endsWith('.gif');
  }

  String _extractFileName(String value) {
    final safe = value.trim();
    if (safe.isEmpty) return 'View Image';
    final parts = safe.split('/');
    if (parts.isEmpty) return 'View Image';
    final fileName = parts.last.trim();
    return fileName.isEmpty ? 'View Image' : fileName;
  }

  void _showImagePreviewDialog(String imageUrl) {
    final safeUrl = imageUrl.trim();
    if (safeUrl.isEmpty) return;

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: GestureDetector(
                  onTap: Get.back,
                  child: Icon(
                    Icons.close_rounded,
                    size: 22.w,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.network(
                  safeUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120.h,
                      alignment: Alignment.center,
                      child: Text(
                        'Unable to load image',
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                          color: AppColors.lightTextPrimary.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
