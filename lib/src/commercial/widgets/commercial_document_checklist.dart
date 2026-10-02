import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';

enum DocumentVerificationStatus {
  verified,
  underReview,
  required,
  rejected;

  Color get color {
    switch (this) {
      case DocumentVerificationStatus.verified:
        return AppColors.success;
      case DocumentVerificationStatus.underReview:
        return AppColors.warning;
      case DocumentVerificationStatus.required:
        return AppColors.lightPrimary;
      case DocumentVerificationStatus.rejected:
        return AppColors.error;
    }
  }

  String label(BuildContext context) {
    switch (this) {
      case DocumentVerificationStatus.verified:
        return l10nPick(context, en: 'Verified', fa: 'تاییدشده', ar: 'تم التحقق', zh: '已验证');
      case DocumentVerificationStatus.underReview:
        return l10nPick(context, en: 'Under Review', fa: 'در حال بررسی', ar: 'قيد المراجعة', zh: '审核中');
      case DocumentVerificationStatus.required:
        return l10nPick(context, en: 'Required', fa: 'الزامی', ar: 'مطلوب', zh: '必需');
      case DocumentVerificationStatus.rejected:
        return l10nPick(context, en: 'Rejected', fa: 'رد شده', ar: 'مرفوض', zh: '已拒绝');
    }
  }

  IconData get icon {
    switch (this) {
      case DocumentVerificationStatus.verified:
        return Icons.check_circle_rounded;
      case DocumentVerificationStatus.underReview:
        return Icons.access_time_rounded;
      case DocumentVerificationStatus.required:
        return Icons.upload_file_rounded;
      case DocumentVerificationStatus.rejected:
        return Icons.error_outline_rounded;
    }
  }
}

class CommercialDocumentItem {
  final String id;
  final String title;
  final String description;
  final bool isMandatory;
  DocumentVerificationStatus status;
  final String? rejectionReason;
  final String? fileName;

  CommercialDocumentItem({
    required this.id,
    required this.title,
    required this.description,
    this.isMandatory = true,
    this.status = DocumentVerificationStatus.required,
    this.rejectionReason,
    this.fileName,
  });
}

class CommercialDocumentChecklist extends StatelessWidget {
  final List<CommercialDocumentItem> documents;
  final Function(CommercialDocumentItem doc)? onUploadTap;

  const CommercialDocumentChecklist({
    super.key,
    required this.documents,
    this.onUploadTap,
  });

  @override
  Widget build(BuildContext context) {
    final verifiedCount =
        documents.where((d) => d.status == DocumentVerificationStatus.verified).length;
    final progress = documents.isNotEmpty ? verifiedCount / documents.length : 0.0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.lightTextPrimary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10nPick(
                  context,
                  en: 'Corporate KYC & Licensing Documents',
                  fa: 'مدارک هویتی و ثبت شرکتی',
                  ar: 'وثائق التراخيص والشركات',
                  zh: '企业资质与认证文件',
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              Text(
                '$verifiedCount/${documents.length}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5.h,
              backgroundColor: AppColors.lightBorder.withValues(alpha: 0.5),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ),
          SizedBox(height: 16.h),

          // Items list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: documents.length,
            separatorBuilder: (_, __) => Divider(
              height: 16.h,
              color: AppColors.lightBorder.withValues(alpha: 0.5),
            ),
            itemBuilder: (context, index) {
              final doc = documents[index];
              return _buildDocTile(context, doc);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDocTile(BuildContext context, CommercialDocumentItem doc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: doc.status.color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(doc.status.icon, color: doc.status.color, size: 18.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      doc.title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  if (doc.isMandatory)
                    Container(
                      margin: EdgeInsets.only(left: 4.w),
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.lightPrimary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        l10nPick(context, en: 'Mandatory', fa: 'الزامی', ar: 'إلزامي', zh: '必填'),
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lightPrimary,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 3.h),
              Text(
                doc.description,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.lightTextTertiary,
                ),
              ),
              if (doc.rejectionReason != null) ...[
                SizedBox(height: 4.h),
                Text(
                  'Reason: ${doc.rejectionReason}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (doc.fileName != null) ...[
                SizedBox(height: 4.h),
                Text(
                  'Uploaded: ${doc.fileName}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 8.w),
        ElevatedButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            if (doc.status == DocumentVerificationStatus.verified) {
              ToastHelper().showSuccessToast(
                l10nPick(context, en: 'Document already verified', fa: 'مدرک تایید شده است', ar: 'تم التحقق من الوثيقة', zh: '文件已验证'),
              );
              return;
            }
            onUploadTap?.call(doc);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: doc.status == DocumentVerificationStatus.verified
                ? AppColors.success.withValues(alpha: 0.12)
                : AppColors.lightPrimary.withValues(alpha: 0.10),
            foregroundColor: doc.status == DocumentVerificationStatus.verified
                ? AppColors.success
                : AppColors.lightPrimary,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            doc.status.label(context),
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
