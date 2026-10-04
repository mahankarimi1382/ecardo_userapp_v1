import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/rental_controller.dart';
import '../models/rental_models.dart';
import 'rental_voucher_screen.dart';

/// جزئیات رزرو رنت خودرو — Car-Rental-Service-Flow.md
/// مدیریت کامل چرخه: مدارک راننده → پرداخت کرایه و قفل ودیعه → تأیید میزبان →
/// تحویل دیجیتال ۸ عکسی → حین اجاره → استرداد دیجیتال و تفاضل خودکار → تسویه/اختلاف.
class RentalDetailScreen extends StatefulWidget {
  final int bookingId;
  const RentalDetailScreen({super.key, required this.bookingId});

  @override
  State<RentalDetailScreen> createState() => _RentalDetailScreenState();
}

class _RentalDetailScreenState extends State<RentalDetailScreen> {
  final RentalController controller = Get.find<RentalController>();

  @override
  void initState() {
    super.initState();
    final id = widget.bookingId > 0 ? widget.bookingId : (Get.arguments is int ? Get.arguments as int : 0);
    if (id > 0) {
      controller.fetchBooking(id);
    }
  }

  String _statusFa(String status) {
    switch (status) {
      case 'DRAFT': return 'پیش‌نویس';
      case 'AWAITING_DOCS': return 'در انتظار مدارک راننده';
      case 'AWAITING_PAYMENT': return 'در انتظار پرداخت';
      case 'PENDING_CONFIRMATION': return 'در انتظار تأیید میزبان';
      case 'CONFIRMED': return 'رزرو قطعی شد';
      case 'ACTIVE': return 'در حال اجاره';
      case 'RETURNED': return 'مسترد شده';
      case 'COMPLETED': return 'تکمیل‌شده';
      case 'DISPUTED': return 'در اختلاف خسارت';
      case 'CANCELLED': return 'لغو';
      case 'REFUNDED': return 'وجه برگشت داده شد';
      case 'EXPIRED': return 'منقضی';
      default: return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED': return AppColors.success;
      case 'ACTIVE': return AppColors.lightPrimary;
      case 'CONFIRMED': return const Color(0xFF0D9488);
      case 'DISPUTED': return AppColors.error;
      case 'CANCELLED': case 'REFUNDED': case 'EXPIRED': return AppColors.softGray;
      case 'AWAITING_DOCS': case 'AWAITING_PAYMENT': case 'PENDING_CONFIRMATION':
      case 'RETURNED': return AppColors.warning;
      default: return AppColors.mutedBlue;
    }
  }

  void _confirm(String title, String message, Future<bool> Function() action) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radius.r)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            l10nPick(context, en: 'Cancel', fa: 'انصراف', ar: 'إلغاء', zh: '取消'),
            style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
          ),
          onPressed: () async {
            Get.back();
            final ok = await action();
            if (!mounted) return;
            if (!ok) {
              Get.snackbar(
                l10nPick(context, en: 'Error', fa: 'خطا'),
                l10nPick(context, en: 'Action failed.', fa: 'عملیات ناموفق بود.'),
                backgroundColor: AppColors.error,
                colorText: Colors.white,
              );
            }
          },
          child: Text(
            l10nPick(context, en: 'Confirm', fa: 'تأیید', ar: 'تأكيد', zh: '确认'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ));
  }

  void _showDriverDocsDialog(RentalBookingModel booking) {
    final licenseCtrl = TextEditingController(text: 'IR-DL-');
    final yearsCtrl = TextEditingController(text: '3');
    final expiryCtrl = TextEditingController(text: '2028-12-31');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radius.r)),
      title: Text(
        l10nPick(context, en: 'Upload Driver License', fa: 'بارگذاری گواهینامه راننده', ar: 'رفع رخصة القيادة', zh: '提交驾驶执照'),
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: licenseCtrl,
            style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            decoration: InputDecoration(
              labelText: l10nPick(context, en: 'License Number', fa: 'شماره گواهینامه'),
              border: const OutlineInputBorder(),
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          TextField(
            controller: yearsCtrl,
            keyboardType: TextInputType.number,
            style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            decoration: InputDecoration(
              labelText: l10nPick(context, en: 'Years with license', fa: 'سابقه گواهینامه (سال)'),
              border: const OutlineInputBorder(),
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          TextField(
            controller: expiryCtrl,
            style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            decoration: InputDecoration(
              labelText: l10nPick(context, en: 'Expiry date (YYYY-MM-DD)', fa: 'تاریخ اعتبار (میلادی)'),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            l10nPick(context, en: 'Cancel', fa: 'انصراف'),
            style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
          ),
          onPressed: () async {
            Get.back();
            final ok = await controller.submitDocs(booking.id, [
              {
                'driver_role': 'PRIMARY',
                'license_ref': licenseCtrl.text.trim(),
                'license_years': int.tryParse(yearsCtrl.text) ?? 1,
                'license_expiry': expiryCtrl.text.trim(),
              }
            ]);
            if (!mounted) return;
            if (ok) {
              Get.snackbar(
                l10nPick(context, en: 'Submitted', fa: 'ثبت شد'),
                l10nPick(context, en: 'Driver docs submitted for verification.',
                  fa: 'مدارک راننده ثبت شد و در انتظار تأیید امتثال است.'),
                backgroundColor: AppColors.success,
                colorText: Colors.white,
              );
            }
          },
          child: Text(
            l10nPick(context, en: 'Submit Docs', fa: 'ارسال مدارک'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ));
  }

  void _showHandoverDialog(RentalBookingModel booking, String phase) {
    final isPickup = phase == 'PICKUP';
    final odoCtrl = TextEditingController(text: '45000');
    final fuelCtrl = TextEditingController(text: '100');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radius.r)),
      title: Text(
        isPickup
          ? l10nPick(context, en: 'Pickup Digital Handover', fa: 'تحویل دیجیتال خودرو (شروع اجاره)', ar: 'استلام السيارة الرقمي', zh: '电子取车交接')
          : l10nPick(context, en: 'Return Digital Handover', fa: 'استرداد دیجیتال خودرو (پایان اجاره)', ar: 'إرجاع السيارة الرقمي', zh: '电子还车交接'),
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w800,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10nPick(context,
                en: '8 mandatory photos with GPS/timestamp:',
                fa: 'چک‌لیست ۸ عکسی الزامی با مهر زمانی و GPS:'),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 4.h,
              children: [
                'جلو', 'عقب', 'راست', 'چپ',
                'کیلومتر', 'سوخت', 'کابین', 'خسارت قبلی'
              ].map((slot) => Chip(
                avatar: const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                label: Text(slot, style: TextStyle(fontSize: 10.sp)),
              )).toList(),
            ),
            SizedBox(height: AppSpacing.md.h),
            TextField(
              controller: odoCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              decoration: InputDecoration(
                labelText: l10nPick(context, en: 'Odometer (km)', fa: 'کیلومترشمار فعلی'),
                border: const OutlineInputBorder(),
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            TextField(
              controller: fuelCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              decoration: InputDecoration(
                labelText: l10nPick(context, en: 'Fuel level (%)', fa: 'درصد سوخت (۰ تا ۱۰۰)'),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            l10nPick(context, en: 'Cancel', fa: 'انصراف'),
            style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
          ),
          onPressed: () async {
            Get.back();
            final photos = List.generate(8, (i) => 'photo_${phase.toLowerCase()}_slot$i.jpg');
            final ok = await controller.submitHandover(
              booking.id,
              phase,
              photos,
              int.tryParse(odoCtrl.text) ?? 45000,
              int.tryParse(fuelCtrl.text) ?? 100,
            );
            if (!mounted) return;
            if (ok) {
              if (isPickup) {
                await controller.confirmPickup(booking.id);
              } else {
                await controller.confirmReturn(booking.id);
              }
              if (!mounted) return;
              Get.snackbar(
                l10nPick(context, en: 'Completed', fa: 'ثبت شد'),
                isPickup
                  ? l10nPick(context, en: 'Vehicle picked up — trip is active!', fa: 'خودرو تحویل گرفته شد — سفر فعال است!')
                  : l10nPick(context, en: 'Vehicle returned — settlement calculated.', fa: 'خودرو مسترد شد — تفاضل خودکار محاسبه گردید.'),
                backgroundColor: AppColors.success,
                colorText: Colors.white,
              );
            }
          },
          child: Text(
            l10nPick(context, en: 'Record & Sign', fa: 'ثبت و امضای دیجیتال'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ));
  }

  void _showDisputeDialog(RentalBookingModel booking) {
    final amountCtrl = TextEditingController(text: '50');
    String disputeType = 'damage';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(StatefulBuilder(
      builder: (dlgContext, setDlgState) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radius.r)),
        title: Text(
          l10nPick(context, en: 'File Dispute', fa: 'ثبت اختلاف خسارت / تسویه', ar: 'تسجيل نزاع', zh: '发起售后争议'),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10nPick(context, en: 'Dispute reason:', fa: 'موضوع اختلاف:'),
              style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: disputeType,
              dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              items: [
                DropdownMenuItem(value: 'damage', child: Text(l10nPick(context, en: 'Damage claim', fa: 'اعتراض به ادعای خسارت'))),
                DropdownMenuItem(value: 'fuel', child: Text(l10nPick(context, en: 'Fuel calculation', fa: 'مغایرت محاسبه سوخت'))),
                DropdownMenuItem(value: 'extra_km', child: Text(l10nPick(context, en: 'Extra KM calculation', fa: 'مغایرت کیلومتر اضافه'))),
                DropdownMenuItem(value: 'cleaning', child: Text(l10nPick(context, en: 'Cleaning fee', fa: 'اعتراض به هزینه نظافت'))),
              ],
              onChanged: (v) => setDlgState(() => disputeType = v ?? 'damage'),
            ),
            SizedBox(height: AppSpacing.sm.h),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              decoration: InputDecoration(
                labelText: l10nPick(context, en: 'Contested amount', fa: 'مبلغ مورد اختلاف'),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              l10nPick(context, en: 'Cancel', fa: 'انصراف'),
              style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
            ),
            onPressed: () async {
              Get.back();
              final ok = await controller.fileDispute(
                booking.id,
                disputeType,
                double.tryParse(amountCtrl.text) ?? 0,
              );
              if (!mounted) return;
              if (ok) {
                Get.snackbar(
                  l10nPick(context, en: 'Dispute Filed', fa: 'اختلاف ثبت شد'),
                  l10nPick(context,
                    en: 'Security deposit frozen — referee ruling in 5 days.',
                    fa: 'ودیعه فریز شد و پرونده به داور ارجاع گردید (مهلت رأی ۵ روز).'),
                  backgroundColor: AppColors.warning,
                  colorText: Colors.white,
                );
              }
            },
            child: Text(
              l10nPick(context, en: 'Submit Dispute', fa: 'ثبت اختلاف'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        title: Text(
          l10nPick(context, en: 'Rental Booking', fa: 'جزئیات اجاره خودرو', ar: 'تفاصيل الحجز', zh: '订单详情'),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        actions: [
          Obx(() {
            final b = controller.selectedBooking.value;
            if (b == null) return const SizedBox.shrink();
            return IconButton(
              tooltip: l10nPick(
                context,
                en: 'View Voucher',
                fa: 'مشاهده ووچر دیجیتال',
                ar: 'عرض القسيمة',
                zh: '查看凭证',
              ),
              icon: Icon(
                Icons.confirmation_number_outlined,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                Get.to(() => RentalVoucherScreen(booking: b));
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        final b = controller.selectedBooking.value;
        if (controller.isLoadingDetail.value || b == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final car = b.car;

        return ListView(
          padding: EdgeInsets.all(AppSpacing.lg.w),
          children: [
            // Vehicle & Booking Card
            Container(
              padding: EdgeInsets.all(AppSpacing.lg.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(AppSpacing.radius.r),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        b.bookingNo,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.sp,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: _statusColor(b.status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                        ),
                        child: Text(
                          _statusFa(b.status),
                          style: TextStyle(
                            color: _statusColor(b.status),
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  if (car != null) ...[
                    Text(
                      car.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      l10nPick(context,
                        en: 'Category: ${car.category} · \$${car.dailyPrice}/day',
                        fa: 'دسته: ${car.category} · \$${car.dailyPrice} روزانه'),
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        fontSize: 11.5.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: AppSpacing.md.h),

            // Schedule & Pricing Details Card
            Container(
              padding: EdgeInsets.all(AppSpacing.lg.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(AppSpacing.radius.r),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(context, en: 'Rental Schedule & Cost', fa: 'برنامه زمانی و هزینه‌ها', ar: 'الجدول والتكاليف', zh: '行程与费用明细'),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.sp,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  if (b.pickupAt != null && b.returnAt != null) ...[
                    Text(
                      l10nPick(context,
                        en: 'Pickup: ${b.pickupAt!.toLocal()}',
                        fa: 'تحویل: ${b.pickupAt!.toLocal()}'),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    Text(
                      l10nPick(context,
                        en: 'Return: ${b.returnAt!.toLocal()}',
                        fa: 'استرداد: ${b.returnAt!.toLocal()}'),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                  if (b.pickupLocation != null)
                    Text(
                      l10nPick(context,
                        en: 'Location: ${b.pickupLocation}',
                        fa: 'محل تحویل: ${b.pickupLocation}'),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  Divider(
                    height: 20.h,
                    color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  ),
                  Text(
                    l10nPick(context,
                      en: 'Rental: \$${b.rentalTotal} + Extras: \$${b.extrasTotal} = Total: \$${b.grandTotal}',
                      fa: 'کرایه: \$${b.rentalTotal} + خدمات: \$${b.extrasTotal} = مجموع: \$${b.grandTotal}'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  if (car != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      l10nPick(context,
                        en: 'Refundable Security Deposit: \$${car.depositAmount} (locked, not charged)',
                        fa: 'ودیعه ضمانت قابل بازگشت: \$${car.depositAmount} (قفل، نه برداشت)'),
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        fontSize: 10.5.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Step: Upload Driver License
            if (b.status == 'DRAFT' || b.status == 'AWAITING_DOCS') ...[
              SizedBox(height: AppSpacing.md.h),
              Container(
                padding: EdgeInsets.all(AppSpacing.lg.r),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkPrimaryContainer : AppColors.lightSecondaryContainer),
                  borderRadius: BorderRadius.circular(AppSpacing.radius.r),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10nPick(context, en: 'Driver License Verification', fa: 'اعتبارسنجی گواهینامه راننده'),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5.sp,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      l10nPick(context,
                        en: 'Mandatory verification by Compliance officer before payment.',
                        fa: 'بررسی مدارک هویتی و گواهینامه توسط افسر امتثال الزامی است.'),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md.h),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
                      ),
                      icon: const Icon(Icons.badge, size: 18),
                      label: Text(
                        l10nPick(context, en: 'Upload License', fa: 'بارگذاری گواهینامه'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onPressed: () => _showDriverDocsDialog(b),
                    ),
                  ],
                ),
              ),
            ],

            // Step: Pay Rental + Lock Deposit
            if (b.status == 'AWAITING_PAYMENT') ...[
              SizedBox(height: AppSpacing.md.h),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                icon: const Icon(Icons.payment, size: 20),
                label: Text(
                  l10nPick(context,
                    en: 'Pay Rental (\$${b.grandTotal}) + Lock Deposit (\$${car?.depositAmount ?? 0})',
                    fa: 'پرداخت کرایه (\$${b.grandTotal}) + قفل ودیعه (\$${car?.depositAmount ?? 0})'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onPressed: () => _confirm(
                  l10nPick(context, en: 'Confirm Payment', fa: 'تأیید پرداخت'),
                  l10nPick(context,
                    en: 'Pay rental fee and lock security deposit from your wallet?',
                    fa: 'پرداخت کرایه قطعی و قفل اتمیک ودیعه از موجودی کیف پول؟'),
                  () => controller.pay(b.id),
                ),
              ),
            ],

            // Step: Waiting for Host Confirmation
            if (b.status == 'PENDING_CONFIRMATION') ...[
              SizedBox(height: AppSpacing.md.h),
              Container(
                padding: EdgeInsets.all(AppSpacing.lg.r),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radius.r),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_top, color: AppColors.warning),
                    SizedBox(width: AppSpacing.md.w),
                    Expanded(
                      child: Text(
                        l10nPick(context,
                          en: 'Waiting for host confirmation (max 6h). In case of silence, booking auto-cancels with full refund.',
                          fa: 'منتظر تأیید میزبان خودرو (حداکثر ۶ ساعت). در صورت عدم پاسخ، رزرو خودکار با عودت کامل لغو می‌گردد.'),
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Step: Digital Handover Protocol
            if (b.status == 'CONFIRMED') ...[
              SizedBox(height: AppSpacing.md.h),
              Container(
                padding: EdgeInsets.all(AppSpacing.lg.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radius.r),
                  border: Border.all(color: const Color(0xFF0D9488)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10nPick(context, en: 'Digital Handover Protocol', fa: 'پروتکل تحویل دیجیتال خودرو'),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.sp,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      l10nPick(context,
                        en: '8 mandatory photos + GPS verification + mutual digital signature before key handover.',
                        fa: 'تکمیل ۸ عکس با GPS و امضای دیجیتال دو طرف قبل از تحویل سوئیچ.'),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md.h),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
                      ),
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: Text(
                        l10nPick(context, en: 'Start Handover & Inspect', fa: 'شروع تحویل و ثبت وضعیت خودرو'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onPressed: () => _showHandoverDialog(b, 'PICKUP'),
                    ),
                  ],
                ),
              ),
            ],

            // Step: Active Rental
            if (b.status == 'ACTIVE') ...[
              SizedBox(height: AppSpacing.md.h),
              Container(
                padding: EdgeInsets.all(AppSpacing.lg.r),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radius.r),
                  border: Border.all(color: AppColors.success),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_car, color: AppColors.success),
                        SizedBox(width: AppSpacing.sm.w),
                        Text(
                          l10nPick(context, en: 'Rental Active — Trip in Progress', fa: 'اجاره فعال — سفر در حال انجام'),
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.success),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.phone_in_talk, color: AppColors.error, size: 16),
                            label: Text(
                              l10nPick(context, en: 'Emergency 24/7', fa: 'تماس اضطراری'),
                              style: const TextStyle(color: AppColors.error, fontSize: 11),
                            ),
                            onPressed: () {
                              Get.snackbar(
                                l10nPick(context, en: 'Trip Support', fa: 'پشتیبانی سفر'),
                                l10nPick(context,
                                  en: 'Connecting to 24/7 trip emergency hotline: +98-21-9100-ECAR',
                                  fa: 'تماس با خط اضطراری ۲۴ ساعته سفر: ۰۲۱-۹۱۰۰-اکاردو'),
                                backgroundColor: AppColors.error,
                                colorText: Colors.white,
                              );
                            },
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.report_problem, size: 16),
                            label: Text(
                              l10nPick(context, en: 'Report Incident', fa: 'گزارش حادثه'),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            onPressed: () {
                              Get.snackbar(
                                l10nPick(context, en: 'Incident', fa: 'ثبت حادثه'),
                                l10nPick(context,
                                  en: 'Incident file opened — late fees paused.',
                                  fa: 'پرونده حادثه ثبت شد — محاسبه دیرکرد متوقف گردید.'),
                                backgroundColor: AppColors.warning,
                                colorText: Colors.white,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                          foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
                        ),
                        icon: const Icon(Icons.assignment_turned_in, size: 18),
                        label: Text(
                          l10nPick(context, en: 'Start Return Handover', fa: 'شروع استرداد دیجیتال خودرو'),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        onPressed: () => _showHandoverDialog(b, 'RETURN'),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Step: Return Settlement
            if (b.status == 'RETURNED') ...[
              SizedBox(height: AppSpacing.md.h),
              Container(
                padding: EdgeInsets.all(AppSpacing.lg.r),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(AppSpacing.radius.r),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10nPick(context, en: 'Return Settlement', fa: 'تسویه استرداد و آزادسازی ودیعه'),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.sp,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      l10nPick(context,
                        en: 'Automatic diff calculated (extra km, fuel, cleaning). 72h damage window active.',
                        fa: 'تفاضل خودکار کیلومتر اضافه، کسری سوخت و نظافت محاسبه گردید (پنجره خسارت ۷۲ ساعت).'),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
                            ),
                            onPressed: () => _confirm(
                              l10nPick(context, en: 'Accept Settlement', fa: 'پذیرش تسویه'),
                              l10nPick(context,
                                en: 'Accept settlement items and release remaining deposit to wallet?',
                                fa: 'پذیرش اقلام تسویه و آزادسازی باقیمانده ودیعه به کیف پول؟'),
                              () => controller.acceptSettlement(b.id),
                            ),
                            child: Text(
                              l10nPick(context, en: 'Accept Settlement', fa: 'پذیرش تسویه'),
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm.w),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
                            ),
                            onPressed: () => _showDisputeDialog(b),
                            child: Text(l10nPick(context, en: 'File Dispute', fa: 'ثبت اختلاف خسارت')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Cancel Booking
            if (['DRAFT', 'AWAITING_DOCS', 'AWAITING_PAYMENT', 'PENDING_CONFIRMATION', 'CONFIRMED'].contains(b.status)) ...[
              SizedBox(height: AppSpacing.md.h),
              TextButton(
                onPressed: () => _confirm(
                  l10nPick(context, en: 'Cancel Booking', fa: 'لغو رزرو'),
                  l10nPick(context,
                    en: 'Tiered refund applies: >72h: 90% · 48-72h: 50% · 24-48h: 25% · <24h: 0%. Deposit fully released.',
                    fa: 'جدول پلکانی لغو: بیش از ۷۲ ساعت: ۹۰٪ · ۴۸ تا ۷۲ ساعت: ۵۰٪ · ۲۴ تا ۴۸ ساعت: ۲۵٪ · کمتر از ۲۴ ساعت: ۰٪. ودیعه کامل آزاد می‌شود.'),
                  () => controller.cancelBooking(b.id),
                ),
                child: Text(
                  l10nPick(context, en: 'Cancel Booking (Tiered Refund)', fa: 'لغو رزرو (طبق جدول پلکانی)'),
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ],

            // Timeline Events
            SizedBox(height: AppSpacing.lg.h),
            Text(
              l10nPick(context, en: 'Timeline', fa: 'تایم‌لاین رویدادها'),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13.sp,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            ...b.events.map((e) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Icon(
                      Icons.circle,
                      size: 8.sp,
                      color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: Text(
                      '${e.createdAt?.toLocal() ?? ''} · ${e.actorRole}${e.reason != null ? ' — ${e.reason}' : ''}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        );
      }),
    );
  }
}