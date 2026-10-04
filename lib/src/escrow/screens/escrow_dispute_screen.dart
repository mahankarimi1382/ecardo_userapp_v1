import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../controllers/escrow_controller.dart';

class EscrowDisputeScreen extends StatefulWidget {
  final int orderId;

  const EscrowDisputeScreen({super.key, required this.orderId});

  @override
  State<EscrowDisputeScreen> createState() => _EscrowDisputeScreenState();
}

class _EscrowDisputeScreenState extends State<EscrowDisputeScreen> {
  late final EscrowController controller;

  String _disputeType = 'QUALITY_ISSUE';
  final TextEditingController _descController = TextEditingController();

  final List<Map<String, String>> _types = [
    {'key': 'QUALITY_ISSUE', 'label': 'کیفیت نامطلوب / معیوب بودن کالا'},
    {'key': 'ITEM_NOT_AS_DESCRIBED', 'label': 'مغایرت کالا با توضیحات و قرارداد'},
    {'key': 'QUANTITY_SHORTAGE', 'label': 'کسری در تعداد یا مقدار ارسالی'},
    {'key': 'SHIPPING_DELAY', 'label': 'تأخیر غیرمجاز در ارسال کالا'},
    {'key': 'NON_DELIVERY', 'label': 'عدم تحویل کالا توسط فروشنده'},
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<EscrowController>()
        ? Get.find<EscrowController>()
        : Get.put(EscrowController());
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final desc = _descController.text.trim();
    if (desc.length < 50) {
      Get.snackbar(
        l10nPick(context, fa: 'خطا', en: 'Error'),
        l10nPick(context, fa: 'شرح اختلاف باید حداقل ۵۰ کاراکتر باشد.', en: 'Description must be at least 50 characters.'),
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
      return;
    }

    HapticFeedback.lightImpact();
    final ok = await controller.openDispute(
      widget.orderId,
      type: _disputeType,
      description: desc,
      evidenceFiles: ['evidence_sample_photo1.jpg', 'evidence_sample_photo2.jpg'],
    );

    if (!mounted) return;
    if (ok) {
      Get.back();
      Get.snackbar(
        l10nPick(context, fa: 'پرونده ثبت شد', en: 'Dispute Opened'),
        l10nPick(context, fa: 'پرونده اختلاف با موفقیت ثبت شد و وجه معامله فریز گردید.', en: 'Dispute opened and funds frozen.'),
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: AppSpacing.iconSm.sp,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.back();
          },
        ),
        title: Text(
          l10nPick(context, fa: 'ثبت اختلاف و داوری (Open Dispute)', en: 'Open Dispute'),
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsetsDirectional.all(AppSpacing.page.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Box
            Container(
              padding: EdgeInsetsDirectional.all(AppSpacing.md.w),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF36181B) : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                border: Border.all(
                  color: isDark ? const Color(0xFFF87171).withValues(alpha: 0.3) : const Color(0xFFFECACA),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
                    size: AppSpacing.iconMd.sp,
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: Text(
                      l10nPick(
                        context,
                        fa: 'توجه: پس از ثبت اختلاف، وجه معامله فریز شده و فروشنده ۴۸ ساعت فرصت دارد پاسخ دهد. در صورت عدم توافق، داور رسمی پلتفرم رأی قطعی را صادر خواهد کرد.',
                        en: 'Notice: Dispute freezes funds. Seller has 48h to respond before platform arbitration begins.',
                      ),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),

            // Type selector
            Text(
              l10nPick(context, fa: 'موضوع اصلی اختلاف *', en: 'Dispute Reason *'),
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: RadioGroup<String>(
                groupValue: _disputeType,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  setState(() => _disputeType = v ?? 'QUALITY_ISSUE');
                },
                child: Column(
                  children: _types.map((t) {
                    return RadioListTile<String>(
                      value: t['key']!,
                      activeColor: AppColors.error,
                      title: Text(
                        t['label']!,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),

            // Description
            Text(
              l10nPick(context, fa: 'شرح کامل اختلاف و مغایرت * (حداقل ۵۰ کاراکتر)', en: 'Detailed Description * (min 50 chars)'),
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            TextField(
              controller: _descController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: l10nPick(
                  context,
                  fa: 'شرح دقیق علت عدم رضایت، مغایرت کالا با قرارداد، خسارات احتمالی و ادعای شما...',
                  en: 'Describe defect, contract deviation, damage...',
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
                filled: true,
                fillColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC),
              ),
            ),
            SizedBox(height: AppSpacing.xxl.h),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r)),
                ),
                onPressed: _handleSubmit,
                child: Text(
                  l10nPick(context, fa: 'ثبت نهایی اختلاف و فریز وجه', en: 'Submit Dispute & Freeze Funds'),
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
