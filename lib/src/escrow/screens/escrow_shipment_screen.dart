import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../controllers/escrow_controller.dart';

class EscrowShipmentScreen extends StatefulWidget {
  final int orderId;

  const EscrowShipmentScreen({super.key, required this.orderId});

  @override
  State<EscrowShipmentScreen> createState() => _EscrowShipmentScreenState();
}

class _EscrowShipmentScreenState extends State<EscrowShipmentScreen> {
  late final EscrowController controller;

  final TextEditingController _carrierController = TextEditingController();
  final TextEditingController _trackingController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<String> _suggestedCarriers = ['تیپاکس (Tipax)', 'پست پیشتاز', 'چاپار (Chapar)', 'باربری اختصاصی'];

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<EscrowController>()
        ? Get.find<EscrowController>()
        : Get.put(EscrowController());
  }

  @override
  void dispose() {
    _carrierController.dispose();
    _trackingController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final carrier = _carrierController.text.trim();
    final tracking = _trackingController.text.trim();

    if (carrier.isEmpty || tracking.isEmpty) {
      Get.snackbar(
        l10nPick(context, fa: 'خطا', en: 'Error'),
        l10nPick(context, fa: 'نام شرکت حمل‌ونقل و شماره بارنامه الزامی است.', en: 'Carrier and tracking number are required.'),
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
      return;
    }

    HapticFeedback.lightImpact();
    final ok = await controller.submitShipment(
      widget.orderId,
      carrier: carrier,
      trackingNumber: tracking,
      trackingUrl: _urlController.text.trim().isNotEmpty ? _urlController.text.trim() : null,
      shippingNotes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    if (!mounted) return;
    if (ok) {
      Get.back();
      Get.snackbar(
        l10nPick(context, fa: 'ثبت شد', en: 'Submitted'),
        l10nPick(context, fa: 'اطلاعات ارسال کالا با موفقیت ثبت شد.', en: 'Shipment details submitted successfully.'),
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

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
          l10nPick(context, fa: 'ثبت اطلاعات ارسال (Step 4)', en: 'Submit Shipment'),
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
            // Notice
            Container(
              padding: EdgeInsetsDirectional.all(AppSpacing.md.w),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2E2211) : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                border: Border.all(
                  color: isDark ? const Color(0xFFFBBF24).withValues(alpha: 0.3) : const Color(0xFFFDE68A),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                    size: AppSpacing.iconMd.sp,
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: Text(
                      l10nPick(
                        context,
                        fa: 'فروشنده گرامی، لطفاً اطلاعات دقیق بارنامه را ثبت نمایید تا وضعیت معامله به «در حال ارسال» تغییر کند.',
                        en: 'Please provide shipping carrier and tracking number to update deal status to In Delivery.',
                      ),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),

            // Carrier input & chips
            Text(
              l10nPick(context, fa: 'شرکت حمل‌ونقل یا شرکت باربری *', en: 'Shipping Carrier *'),
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Wrap(
              spacing: AppSpacing.sm.w,
              children: _suggestedCarriers.map((c) {
                return ActionChip(
                  label: Text(c, style: AppTextStyles.labelSmall),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() => _carrierController.text = c);
                  },
                );
              }).toList(),
            ),
            SizedBox(height: AppSpacing.sm.h),
            _buildTextField(
              isDark: isDark,
              controller: _carrierController,
              hint: l10nPick(context, fa: 'نام شرکت حمل (مثلا تیپاکس)', en: 'e.g. Tipax, Iran Post'),
            ),
            SizedBox(height: AppSpacing.md.h),

            // Tracking number
            Text(
              l10nPick(context, fa: 'شماره پیگیری / شماره بارنامه *', en: 'Tracking / Consignment Number *'),
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            _buildTextField(
              isDark: isDark,
              controller: _trackingController,
              hint: 'مثلا: 9812400015',
            ),
            SizedBox(height: AppSpacing.md.h),

            // Tracking URL
            Text(
              l10nPick(context, fa: 'لینک پیگیری آنلاین (اختیاری)', en: 'Tracking URL (Optional)'),
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            _buildTextField(
              isDark: isDark,
              controller: _urlController,
              hint: 'https://tipaxco.com/tracking/...',
            ),
            SizedBox(height: AppSpacing.md.h),

            // Notes
            Text(
              l10nPick(context, fa: 'توضیحات و نکات تحویل', en: 'Shipping Notes'),
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            _buildTextField(
              isDark: isDark,
              controller: _notesController,
              maxLines: 3,
              hint: l10nPick(context, fa: 'نکاتی مانند لزوم تحویل با ارائه کارت ملی...', en: 'Special delivery instructions...'),
            ),
            SizedBox(height: AppSpacing.xxl.h),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r)),
                ),
                onPressed: _handleSubmit,
                child: Text(
                  l10nPick(context, fa: 'ثبت و اعلام ارسال به خریدار', en: 'Submit & Notify Buyer'),
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.deepBlack : AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required bool isDark,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC),
      ),
    );
  }
}
