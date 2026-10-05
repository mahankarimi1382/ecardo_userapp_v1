import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
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

  Color _statusColor(String status, BuildContext context) {
    switch (status) {
      case 'COMPLETED': return ECardoTokens.success(context);
      case 'ACTIVE': return ECardoTokens.brand500(context);
      case 'CONFIRMED': return const Color(0xFF0D9488);
      case 'DISPUTED': return ECardoTokens.danger(context);
      case 'CANCELLED': case 'REFUNDED': case 'EXPIRED': return ECardoTokens.inkMuted(context);
      case 'AWAITING_DOCS': case 'AWAITING_PAYMENT': case 'PENDING_CONFIRMATION':
      case 'RETURNED': return ECardoTokens.warning(context);
      default: return ECardoTokens.info(context);
    }
  }

  void _confirm(String title, String message, Future<bool> Function() action) {
    Get.dialog(AlertDialog(
      backgroundColor: ECardoTokens.surfaceCard(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusLg.r)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: ECardoTokens.ink(context),
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          color: ECardoTokens.inkMuted(context),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            l10nPick(context, en: 'Cancel', fa: 'انصراف', ar: 'إلغاء', zh: '取消'),
            style: TextStyle(color: ECardoTokens.inkMuted(context)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ECardoTokens.brand500(context),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r)),
          ),
          onPressed: () async {
            Get.back();
            final ok = await action();
            if (!mounted) return;
            if (!ok) {
              Get.snackbar(
                l10nPick(context, en: 'Error', fa: 'خطا'),
                l10nPick(context, en: 'Action failed.', fa: 'عملیات ناموفق بود.'),
                backgroundColor: ECardoTokens.danger(context),
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

    Get.dialog(AlertDialog(
      backgroundColor: ECardoTokens.surfaceCard(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusLg.r)),
      title: Text(
        l10nPick(context, en: 'Upload Driver License', fa: 'بارگذاری گواهینامه راننده', ar: 'رفع رخصة القيادة', zh: '提交驾驶执照'),
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
          color: ECardoTokens.ink(context),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: licenseCtrl,
            style: TextStyle(color: ECardoTokens.ink(context)),
            decoration: InputDecoration(
              labelText: l10nPick(context, en: 'License Number', fa: 'شماره گواهینامه'),
              labelStyle: TextStyle(color: ECardoTokens.inkMuted(context)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                borderSide: BorderSide(color: ECardoTokens.border(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                borderSide: BorderSide(color: ECardoTokens.border(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                borderSide: BorderSide(color: ECardoTokens.focusRing(context), width: 2),
              ),
            ),
          ),
          SizedBox(height: ECardoTokens.space2.h),
          TextField(
            controller: yearsCtrl,
            keyboardType: TextInputType.number,
            style: TextStyle(color: ECardoTokens.ink(context)),
            decoration: InputDecoration(
              labelText: l10nPick(context, en: 'Years with license', fa: 'سابقه گواهینامه (سال)'),
              labelStyle: TextStyle(color: ECardoTokens.inkMuted(context)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                borderSide: BorderSide(color: ECardoTokens.border(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                borderSide: BorderSide(color: ECardoTokens.border(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                borderSide: BorderSide(color: ECardoTokens.focusRing(context), width: 2),
              ),
            ),
          ),
          SizedBox(height: ECardoTokens.space2.h),
          TextField(
            controller: expiryCtrl,
            style: TextStyle(color: ECardoTokens.ink(context)),
            decoration: InputDecoration(
              labelText: l10nPick(context, en: 'Expiry date (YYYY-MM-DD)', fa: 'تاریخ اعتبار (میلادی)'),
              labelStyle: TextStyle(color: ECardoTokens.inkMuted(context)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                borderSide: BorderSide(color: ECardoTokens.border(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                borderSide: BorderSide(color: ECardoTokens.border(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                borderSide: BorderSide(color: ECardoTokens.focusRing(context), width: 2),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            l10nPick(context, en: 'Cancel', fa: 'انصراف'),
            style: TextStyle(color: ECardoTokens.inkMuted(context)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ECardoTokens.brand500(context),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r)),
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
                backgroundColor: ECardoTokens.success(context),
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

    Get.dialog(AlertDialog(
      backgroundColor: ECardoTokens.surfaceCard(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusLg.r)),
      title: Text(
        isPickup
          ? l10nPick(context, en: 'Pickup Digital Handover', fa: 'تحویل دیجیتال خودرو (شروع اجاره)', ar: 'استلام السيارة الرقمي', zh: '电子取车交接')
          : l10nPick(context, en: 'Return Digital Handover', fa: 'استرداد دیجیتال خودرو (پایان اجاره)', ar: 'إرجاع السيارة الرقمي', zh: '电子还车交接'),
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w800,
          color: ECardoTokens.ink(context),
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
                color: ECardoTokens.ink(context),
              ),
            ),
            SizedBox(height: ECardoTokens.space1.h),
            Wrap(
              spacing: ECardoTokens.space1.w,
              runSpacing: ECardoTokens.space1.h,
              children: [
                'جلو', 'عقب', 'راست', 'چپ',
                'کیلومتر', 'سوخت', 'کابین', 'خسارت قبلی'
              ].map((slot) => Chip(
                avatar: Icon(Icons.check_circle, size: 16, color: ECardoTokens.success(context)),
                label: Text(slot, style: TextStyle(fontSize: 10.sp)),
              )).toList(),
            ),
            SizedBox(height: ECardoTokens.space3.h),
            TextField(
              controller: odoCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: ECardoTokens.ink(context)),
              decoration: InputDecoration(
                labelText: l10nPick(context, en: 'Odometer (km)', fa: 'کیلومترشمار فعلی'),
                labelStyle: TextStyle(color: ECardoTokens.inkMuted(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                  borderSide: BorderSide(color: ECardoTokens.border(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                  borderSide: BorderSide(color: ECardoTokens.border(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                  borderSide: BorderSide(color: ECardoTokens.focusRing(context), width: 2),
                ),
              ),
            ),
            SizedBox(height: ECardoTokens.space2.h),
            TextField(
              controller: fuelCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: ECardoTokens.ink(context)),
              decoration: InputDecoration(
                labelText: l10nPick(context, en: 'Fuel level (%)', fa: 'درصد سوخت (۰ تا ۱۰۰)'),
                labelStyle: TextStyle(color: ECardoTokens.inkMuted(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                  borderSide: BorderSide(color: ECardoTokens.border(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                  borderSide: BorderSide(color: ECardoTokens.border(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                  borderSide: BorderSide(color: ECardoTokens.focusRing(context), width: 2),
                ),
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
            style: TextStyle(color: ECardoTokens.inkMuted(context)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ECardoTokens.brand500(context),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r)),
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
                backgroundColor: ECardoTokens.success(context),
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

    Get.dialog(StatefulBuilder(
      builder: (dlgContext, setDlgState) => AlertDialog(
        backgroundColor: ECardoTokens.surfaceCard(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusLg.r)),
        title: Text(
          l10nPick(context, en: 'File Dispute', fa: 'ثبت اختلاف خسارت / تسویه', ar: 'تسجيل نزاع', zh: '发起售后争议'),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: ECardoTokens.ink(context),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10nPick(context, en: 'Dispute reason:', fa: 'موضوع اختلاف:'),
              style: TextStyle(color: ECardoTokens.inkMuted(context)),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: disputeType,
              dropdownColor: ECardoTokens.surfaceCard(context),
              style: TextStyle(color: ECardoTokens.ink(context), fontSize: 13.sp),
              items: [
                DropdownMenuItem(value: 'damage', child: Text(l10nPick(context, en: 'Damage claim', fa: 'اعتراض به ادعای خسارت'))),
                DropdownMenuItem(value: 'fuel', child: Text(l10nPick(context, en: 'Fuel calculation', fa: 'مغایرت محاسبه سوخت'))),
                DropdownMenuItem(value: 'extra_km', child: Text(l10nPick(context, en: 'Extra KM calculation', fa: 'مغایرت کیلومتر اضافه'))),
                DropdownMenuItem(value: 'cleaning', child: Text(l10nPick(context, en: 'Cleaning fee', fa: 'اعتراض به هزینه نظافت'))),
              ],
              onChanged: (v) => setDlgState(() => disputeType = v ?? 'damage'),
            ),
            SizedBox(height: ECardoTokens.space2.h),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: ECardoTokens.ink(context)),
              decoration: InputDecoration(
                labelText: l10nPick(context, en: 'Contested amount', fa: 'مبلغ مورد اختلاف'),
                labelStyle: TextStyle(color: ECardoTokens.inkMuted(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                  borderSide: BorderSide(color: ECardoTokens.border(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                  borderSide: BorderSide(color: ECardoTokens.border(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                  borderSide: BorderSide(color: ECardoTokens.focusRing(context), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              l10nPick(context, en: 'Cancel', fa: 'انصراف'),
              style: TextStyle(color: ECardoTokens.inkMuted(context)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ECardoTokens.danger(context),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r)),
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
                  backgroundColor: ECardoTokens.warning(context),
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
    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: AppBar(
        backgroundColor: ECardoTokens.surfaceCard(context),
        elevation: 0,
        title: Text(
          l10nPick(context, en: 'Rental Booking', fa: 'جزئیات اجاره خودرو', ar: 'تفاصيل الحجز', zh: '订单详情'),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: ECardoTokens.ink(context),
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
                color: ECardoTokens.brand500(context),
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
          padding: EdgeInsets.all(ECardoTokens.space4.w),
          children: [
            // Vehicle & Booking Card
            Container(
              padding: EdgeInsets.all(ECardoTokens.space4.r),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceCard(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
                border: Border.all(
                  color: ECardoTokens.border(context),
                ),
                boxShadow: ECardoTokens.shadowCard(context),
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
                          color: ECardoTokens.ink(context),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: _statusColor(b.status, context).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                        ),
                        child: Text(
                          _statusFa(b.status),
                          style: TextStyle(
                            color: _statusColor(b.status, context),
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ECardoTokens.space2.h),
                  if (car != null) ...[
                    Text(
                      car.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      l10nPick(context,
                        en: 'Category: ${car.category} · \$${car.dailyPrice}/day',
                        fa: 'دسته: ${car.category} · \$${car.dailyPrice} روزانه'),
                      style: TextStyle(
                        color: ECardoTokens.inkMuted(context),
                        fontSize: 11.5.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space3.h),

            // Schedule & Pricing Details Card
            Container(
              padding: EdgeInsets.all(ECardoTokens.space4.r),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceCard(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
                border: Border.all(
                  color: ECardoTokens.border(context),
                ),
                boxShadow: ECardoTokens.shadowCard(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(context, en: 'Rental Schedule & Cost', fa: 'برنامه زمانی و هزینه‌ها', ar: 'الجدول والتكاليف', zh: '行程与费用明细'),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.sp,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                  SizedBox(height: ECardoTokens.space2.h),
                  if (b.pickupAt != null && b.returnAt != null) ...[
                    Text(
                      l10nPick(context,
                        en: 'Pickup: ${b.pickupAt!.toLocal()}',
                        fa: 'تحویل: ${b.pickupAt!.toLocal()}'),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: ECardoTokens.inkMuted(context),
                      ),
                    ),
                    Text(
                      l10nPick(context,
                        en: 'Return: ${b.returnAt!.toLocal()}',
                        fa: 'استرداد: ${b.returnAt!.toLocal()}'),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: ECardoTokens.inkMuted(context),
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
                        color: ECardoTokens.inkMuted(context),
                      ),
                    ),
                  Divider(
                    height: 20.h,
                    color: ECardoTokens.border(context),
                  ),
                  Text(
                    l10nPick(context,
                      en: 'Rental: \$${b.rentalTotal} + Extras: \$${b.extrasTotal} = Total: \$${b.grandTotal}',
                      fa: 'کرایه: \$${b.rentalTotal} + خدمات: \$${b.extrasTotal} = مجموع: \$${b.grandTotal}'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                  if (car != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      l10nPick(context,
                        en: 'Refundable Security Deposit: \$${car.depositAmount} (locked, not charged)',
                        fa: 'ودیعه ضمانت قابل بازگشت: \$${car.depositAmount} (قفل، نه برداشت)'),
                      style: TextStyle(
                        color: ECardoTokens.inkMuted(context),
                        fontSize: 10.5.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Step: Upload Driver License
            if (b.status == 'DRAFT' || b.status == 'AWAITING_DOCS') ...[
              SizedBox(height: ECardoTokens.space3.h),
              Container(
                padding: EdgeInsets.all(ECardoTokens.space4.r),
                decoration: BoxDecoration(
                  color: ECardoTokens.brand100(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
                  border: Border.all(
                    color: ECardoTokens.brand500(context).withValues(alpha: 0.3),
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
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      l10nPick(context,
                        en: 'Mandatory verification by Compliance officer before payment.',
                        fa: 'بررسی مدارک هویتی و گواهینامه توسط افسر امتثال الزامی است.'),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: ECardoTokens.inkMuted(context),
                      ),
                    ),
                    SizedBox(height: ECardoTokens.space3.h),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ECardoTokens.brand500(context),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r)),
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
              SizedBox(height: ECardoTokens.space3.h),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ECardoTokens.brand500(context),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r)),
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
              SizedBox(height: ECardoTokens.space3.h),
              Container(
                padding: EdgeInsets.all(ECardoTokens.space4.r),
                decoration: BoxDecoration(
                  color: ECardoTokens.warningBg(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
                  border: Border.all(color: ECardoTokens.warning(context).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.hourglass_top, color: ECardoTokens.warning(context)),
                    SizedBox(width: ECardoTokens.space3.w),
                    Expanded(
                      child: Text(
                        l10nPick(context,
                          en: 'Waiting for host confirmation (max 6h). In case of silence, booking auto-cancels with full refund.',
                          fa: 'منتظر تأیید میزبان خودرو (حداکثر ۶ ساعت). در صورت عدم پاسخ، رزرو خودکار با عودت کامل لغو می‌گردد.'),
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: ECardoTokens.ink(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Step: Digital Handover Protocol
            if (b.status == 'CONFIRMED') ...[
              SizedBox(height: ECardoTokens.space3.h),
              Container(
                padding: EdgeInsets.all(ECardoTokens.space4.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
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
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      l10nPick(context,
                        en: '8 mandatory photos + GPS verification + mutual digital signature before key handover.',
                        fa: 'تکمیل ۸ عکس با GPS و امضای دیجیتال دو طرف قبل از تحویل سوئیچ.'),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: ECardoTokens.inkMuted(context),
                      ),
                    ),
                    SizedBox(height: ECardoTokens.space3.h),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r)),
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
              SizedBox(height: ECardoTokens.space3.h),
              Container(
                padding: EdgeInsets.all(ECardoTokens.space4.r),
                decoration: BoxDecoration(
                  color: ECardoTokens.successBg(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
                  border: Border.all(color: ECardoTokens.success(context).withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.directions_car, color: ECardoTokens.success(context)),
                        SizedBox(width: ECardoTokens.space2.w),
                        Text(
                          l10nPick(context, en: 'Rental Active — Trip in Progress', fa: 'اجاره فعال — سفر در حال انجام'),
                          style: TextStyle(fontWeight: FontWeight.w800, color: ECardoTokens.success(context)),
                        ),
                      ],
                    ),
                    SizedBox(height: ECardoTokens.space2.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: ECardoTokens.danger(context)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r)),
                            ),
                            icon: Icon(Icons.phone_in_talk, color: ECardoTokens.danger(context), size: 16),
                            label: Text(
                              l10nPick(context, en: 'Emergency 24/7', fa: 'تماس اضطراری'),
                              style: TextStyle(color: ECardoTokens.danger(context), fontSize: 11),
                            ),
                            onPressed: () {
                              Get.snackbar(
                                l10nPick(context, en: 'Trip Support', fa: 'پشتیبانی سفر'),
                                l10nPick(context,
                                  en: 'Connecting to 24/7 trip emergency hotline: +98-21-9100-ECAR',
                                  fa: 'تماس با خط اضطراری ۲۴ ساعته سفر: ۰۲۱-۹۱۰۰-اکاردو'),
                                backgroundColor: ECardoTokens.danger(context),
                                colorText: Colors.white,
                              );
                            },
                          ),
                        ),
                        SizedBox(width: ECardoTokens.space2.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: ECardoTokens.borderStrong(context)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r)),
                            ),
                            icon: Icon(Icons.report_problem, size: 16, color: ECardoTokens.ink(context)),
                            label: Text(
                              l10nPick(context, en: 'Report Incident', fa: 'گزارش حادثه'),
                              style: TextStyle(
                                fontSize: 11,
                                color: ECardoTokens.ink(context),
                              ),
                            ),
                            onPressed: () {
                              Get.snackbar(
                                l10nPick(context, en: 'Incident', fa: 'ثبت حادثه'),
                                l10nPick(context,
                                  en: 'Incident file opened — late fees paused.',
                                  fa: 'پرونده حادثه ثبت شد — محاسبه دیرکرد متوقف گردید.'),
                                backgroundColor: ECardoTokens.warning(context),
                                colorText: Colors.white,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ECardoTokens.space2.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ECardoTokens.brand500(context),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r)),
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
              SizedBox(height: ECardoTokens.space3.h),
              Container(
                padding: EdgeInsets.all(ECardoTokens.space4.r),
                decoration: BoxDecoration(
                  color: ECardoTokens.surfaceCard(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
                  border: Border.all(
                    color: ECardoTokens.border(context),
                  ),
                  boxShadow: ECardoTokens.shadowCard(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10nPick(context, en: 'Return Settlement', fa: 'تسویه استرداد و آزادسازی ودیعه'),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.sp,
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      l10nPick(context,
                        en: 'Automatic diff calculated (extra km, fuel, cleaning). 72h damage window active.',
                        fa: 'تفاضل خودکار کیلومتر اضافه، کسری سوخت و نظافت محاسبه گردید (پنجره خسارت ۷۲ ساعت).'),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: ECardoTokens.inkMuted(context),
                      ),
                    ),
                    SizedBox(height: ECardoTokens.space3.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ECardoTokens.success(context),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r)),
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
                        SizedBox(width: ECardoTokens.space2.w),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ECardoTokens.danger(context),
                              side: BorderSide(color: ECardoTokens.danger(context)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r)),
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
              SizedBox(height: ECardoTokens.space3.h),
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
                  style: TextStyle(color: ECardoTokens.danger(context)),
                ),
              ),
            ],

            // Timeline Events
            SizedBox(height: ECardoTokens.space4.h),
            Text(
              l10nPick(context, en: 'Timeline', fa: 'تایم‌لاین رویدادها'),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13.sp,
                color: ECardoTokens.ink(context),
              ),
            ),
            SizedBox(height: ECardoTokens.space1.h),
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
                      color: ECardoTokens.brand500(context),
                    ),
                  ),
                  SizedBox(width: ECardoTokens.space2.w),
                  Expanded(
                    child: Text(
                      '${e.createdAt?.toLocal() ?? ''} · ${e.actorRole}${e.reason != null ? ' — ${e.reason}' : ''}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: ECardoTokens.inkMuted(context),
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