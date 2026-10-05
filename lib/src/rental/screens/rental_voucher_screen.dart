import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';

import '../models/rental_models.dart';

/// Digital Car Rental Voucher & Handover Pass
class RentalVoucherScreen extends StatelessWidget {
  final RentalBookingModel booking;

  const RentalVoucherScreen({super.key, required this.booking});

  String _generateQrSvg() {
    final barcode = Barcode.qrCode();
    return barcode.toSvg(
      'CAR-RENTAL-${booking.bookingNo}-${booking.car?.title ?? ''}-${booking.status}',
      width: 140,
      height: 140,
    );
  }

  @override
  Widget build(BuildContext context) {
    final car = booking.car;

    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: AppBar(
        title: Text(
          l10nPick(
            context,
            en: 'Car Rental Voucher',
            fa: 'رسید و ووچر اجاره خودرو',
            ar: 'قسيمة تأجير السيارة',
            zh: '租车电子凭证',
          ),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: ECardoTokens.ink(context),
          ),
        ),
        backgroundColor: ECardoTokens.surfaceCard(context),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: ECardoTokens.ink(context),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.all(ECardoTokens.space4.r),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsetsDirectional.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                    ),
                    side: BorderSide(
                      color: ECardoTokens.borderStrong(context),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(ClipboardData(text: booking.bookingNo));
                    ToastHelper().showSuccessToast(
                      l10nPick(
                        context,
                        en: 'Booking number copied: ${booking.bookingNo}',
                        fa: 'شماره رزرو کپی شد: ${booking.bookingNo}',
                        ar: 'تم نسخ رقم الحجز',
                        zh: '预订编号已复制',
                      ),
                    );
                  },
                  child: Text(
                    l10nPick(
                      context,
                      en: 'Copy Booking No',
                      fa: 'کپی شماره رزرو',
                      ar: 'نسخ رقم الحجز',
                      zh: '复制预订号',
                    ),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ECardoTokens.space3.w),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ECardoTokens.brand500(context),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                    ),
                    padding: EdgeInsetsDirectional.symmetric(vertical: 14.h),
                    elevation: 0,
                  ),
                  onPressed: () => Get.back(),
                  child: Text(
                    l10nPick(
                      context,
                      en: 'Done',
                      fa: 'تأیید و بازگشت',
                      ar: 'تم',
                      zh: '完成',
                    ),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsetsDirectional.fromSTEB(ECardoTokens.space4.w, ECardoTokens.space3.h, ECardoTokens.space4.w, ECardoTokens.space8.h),
        children: [
          // Status banner
          Container(
            padding: EdgeInsetsDirectional.all(ECardoTokens.space4.r),
            decoration: BoxDecoration(
              color: ECardoTokens.successBg(context),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusLg.r),
              border: Border.all(color: ECardoTokens.success(context).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(ECardoTokens.space2.r),
                  decoration: BoxDecoration(
                    color: ECardoTokens.success(context),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                ),
                SizedBox(width: ECardoTokens.space3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: 'Rental Voucher Confirmed',
                          fa: 'رزرو خودرو با موفقیت تأیید شد',
                          ar: 'تم تأكيد حجز السيارة',
                          zh: '租车凭证已确认',
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          color: ECardoTokens.success(context),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Present this voucher and your original driving license at vehicle handover.',
                          fa: 'این برگه را همراه با اصل گواهینامه معتبر هنگام تحویل خودرو ارائه فرمایید.',
                          ar: 'يرجى تقديم هذه القسيمة مع رخصة القيادة الأصلية عند الاستلام.',
                          zh: '请在取车时出示此凭证及有效驾照原件。',
                        ),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: ECardoTokens.inkMuted(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ECardoTokens.space4.h),

          // Voucher Card
          Container(
            padding: EdgeInsetsDirectional.all(ECardoTokens.space5.r),
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
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_car_rounded,
                            color: ECardoTokens.brand500(context),
                            size: 20.sp,
                          ),
                          SizedBox(width: ECardoTokens.space2.w),
                          Expanded(
                            child: Text(
                              car?.title ?? '—',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w900,
                                color: ECardoTokens.ink(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: ECardoTokens.space2.w),
                    Container(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: ECardoTokens.brand100(context),
                        borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                      ),
                      child: Text(
                        booking.bookingNo,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w900,
                          color: ECardoTokens.brand500(context),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 24.h,
                  color: ECardoTokens.border(context),
                ),

                // Vehicle Specs
                Row(
                  children: [
                    Expanded(
                      child: _RentalFact(
                        icon: Icons.category_rounded,
                        label: l10nPick(context, en: 'Category', fa: 'کلاس', ar: 'الفئة', zh: '类别'),
                        value: car?.category ?? '—',
                      ),
                    ),
                    Expanded(
                      child: _RentalFact(
                        icon: Icons.settings_rounded,
                        label: l10nPick(context, en: 'Transmission', fa: 'گیربکس', ar: 'ناقل الحركة', zh: '变速箱'),
                        value: car?.transmission ?? 'Auto',
                      ),
                    ),
                    Expanded(
                      child: _RentalFact(
                        icon: Icons.shield_rounded,
                        label: l10nPick(context, en: 'Insurance', fa: 'بیمه', ar: 'التأمين', zh: '保险'),
                        value: booking.insuranceTier,
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 24.h,
                  color: ECardoTokens.border(context),
                ),

                // Dates & Locations
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(context, en: 'Pickup', fa: 'تحویل گرفتن', ar: 'الاستلام', zh: '取车时间'),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: ECardoTokens.inkMuted(context),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            booking.pickupAt != null ? booking.pickupAt!.toIso8601String().split('T').first : '—',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: ECardoTokens.ink(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: ECardoTokens.inkMuted(context),
                      size: 20.r,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10nPick(context, en: 'Return', fa: 'استرداد خودرو', ar: 'الإرجاع', zh: '还车时间'),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: ECardoTokens.inkMuted(context),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            booking.returnAt != null ? booking.returnAt!.toIso8601String().split('T').first : '—',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: ECardoTokens.ink(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 24.h,
                  color: ECardoTokens.border(context),
                ),

                // Pricing Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l10nPick(context, en: 'Rental Total', fa: 'مجموع کرایه', ar: 'إجمالي الإيجار', zh: '租金合计'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: ECardoTokens.inkMuted(context),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '\$${booking.rentalTotal}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: ECardoTokens.brand500(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l10nPick(context, en: 'Security Deposit (Locked)', fa: 'ودیعه ضمانت (قفل موقت)', ar: 'مبلغ التأمين (محجوز)', zh: '押金（预授权冻结）'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: ECardoTokens.inkMuted(context),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      car != null ? '\$${car.depositAmount}' : '—',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: ECardoTokens.warning(context),
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 24.h,
                  color: ECardoTokens.border(context),
                ),

                // QR Code
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(ECardoTokens.space3.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                          border: Border.all(
                            color: ECardoTokens.border(context),
                          ),
                        ),
                        child: SvgPicture.string(_generateQrSvg(), width: 120.r, height: 120.r),
                      ),
                      SizedBox(height: ECardoTokens.space2.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Scan QR at pickup point for 8-angle condition check-in',
                          fa: 'اسکن بارکد در محل تحویل خودرو جهت ثبت تصاویر دیجیتال ۸ جهته',
                          ar: 'امسح الرمز لتسجيل فحص السيارة من ٨ زوايا',
                          zh: '取车时扫描二维码以完成八方位车况记录',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: ECardoTokens.inkMuted(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ECardoTokens.space4.h),

          // Roadside Assistance
          Container(
            padding: EdgeInsetsDirectional.all(ECardoTokens.space4.r),
            decoration: BoxDecoration(
              color: ECardoTokens.surfaceCard(context),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusLg.r),
              border: Border.all(
                color: ECardoTokens.border(context),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.support_agent_rounded,
                  color: ECardoTokens.brand500(context),
                  size: 24.sp,
                ),
                SizedBox(width: ECardoTokens.space3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(context, en: '24/7 Roadside Assistance', fa: 'امداد جاده‌ای و پشتیبانی ۲۴ ساعته', ar: 'المساعدة على الطريق ٢٤/٧', zh: '24/7 道路救援支持'),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.sp,
                          color: ECardoTokens.ink(context),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        l10nPick(context, en: 'Direct emergency line: +98 21 9100 ECAR', fa: 'تماس اضطراری ۲۴ ساعته: ۰۲۱-۹۱۰۰-اکاردو', ar: 'خط الدعم المباشر', zh: '紧急支持专线：+98 21 9100 ECAR'),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: ECardoTokens.inkMuted(context),
                        ),
                      ),
                    ],
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

class _RentalFact extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RentalFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14.r,
              color: ECardoTokens.inkMuted(context),
            ),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  color: ECardoTokens.inkMuted(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: ECardoTokens.ink(context),
          ),
        ),
      ],
    );
  }
}