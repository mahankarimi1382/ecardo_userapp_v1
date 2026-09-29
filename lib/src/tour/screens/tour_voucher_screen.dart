
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_theme.dart';
import '../models/tour_model.dart';
import 'tour_list_screen.dart';

class TourVoucherScreen extends StatelessWidget {
  final TourBookingModel booking;

  const TourVoucherScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2761), // Midnight Executive Navy
      appBar: AppBar(
        title: Text(
          l10nPick(context, en: 'Official Tour Voucher', fa: 'واچر رسمی تور مسافرتی'),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            tooltip: l10nPick(context, en: 'All Tours', fa: 'کاتالوگ تورها'),
            icon: const Icon(Icons.explore_rounded, color: Colors.white),
            onPressed: () => Get.offAll(() => const TourListScreen()),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        children: [
          // Header Verified Badge
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: TravelTheme.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: TravelTheme.green),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_rounded, color: TravelTheme.green, size: 18),
                  SizedBox(width: 6.w),
                  Text(
                    l10nPick(context, en: 'Verified & Confirmed Travel Voucher', fa: 'واچر قطعی و تأییدشده سفر'),
                    style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Boarding Pass Ticket Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Brand Header
                Container(
                  padding: EdgeInsets.all(18.r),
                  color: const Color(0xFF141A45),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'eCardo Travel & Tours',
                            style: TextStyle(color: Colors.white70, fontSize: 10.sp, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            booking.bookingNo,
                            style: TextStyle(color: Colors.amber, fontSize: 16.sp, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          booking.statusLabel,
                          style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tour Title & Destination
                Padding(
                  padding: EdgeInsets.all(18.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.tourTitle,
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: TravelTheme.ink),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: TravelTheme.blue, size: 16),
                          SizedBox(width: 4.w),
                          Text(
                            booking.tourCity,
                            style: TextStyle(fontSize: 12.sp, color: TravelTheme.muted, fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          Text(
                            '${l10nPick(context, en: 'Tier:', fa: 'پکیج:')} ${booking.tier}',
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: TravelTheme.blue),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Dates & Meeting Point Grid
                      Container(
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: TravelTheme.background,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoItem(
                                    l10nPick(context, en: 'Departure Date', fa: 'تاریخ حرکت'),
                                    booking.departDate ?? 'نامشخص',
                                    Icons.flight_takeoff_rounded,
                                  ),
                                ),
                                Container(width: 1, height: 36.h, color: TravelTheme.border),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.only(start: 12.w),
                                    child: _buildInfoItem(
                                      l10nPick(context, en: 'Return Date', fa: 'تاریخ بازگشت'),
                                      booking.returnDate ?? 'نامشخص',
                                      Icons.flight_land_rounded,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            const Divider(height: 1),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoItem(
                                    l10nPick(context, en: 'Tour Guide', fa: 'راهنمای تور'),
                                    booking.guideName ?? 'تورلیدر مجرب eCardo',
                                    Icons.person_pin_rounded,
                                  ),
                                ),
                                Container(width: 1, height: 36.h, color: TravelTheme.border),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.only(start: 12.w),
                                    child: _buildInfoItem(
                                      l10nPick(context, en: 'Emergency Phone', fa: 'شماره اضطراری'),
                                      booking.guidePhone ?? '+98 21 8888 0000',
                                      Icons.phone_in_talk_rounded,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (booking.meetingPoint != null && booking.meetingPoint!.isNotEmpty) ...[
                              SizedBox(height: 12.h),
                              const Divider(height: 1),
                              SizedBox(height: 12.h),
                              _buildInfoItem(
                                l10nPick(context, en: 'Meeting Point', fa: 'محل و ساعت گردهمایی'),
                                booking.meetingPoint!,
                                Icons.meeting_room_rounded,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Perforated Line Decoration
                Row(
                  children: [
                    Container(
                      width: 16.r,
                      height: 32.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E2761),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: List.generate(
                              (constraints.constrainWidth() / 10).floor(),
                              (_) => SizedBox(
                                width: 5.w,
                                height: 1.5.h,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(color: Colors.grey.shade300),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      width: 16.r,
                      height: 32.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E2761),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom Ticket Section: QR & Voucher Code
                Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10nPick(context, en: 'Voucher Code:', fa: 'کد اختصاصی واچر:'),
                                style: TextStyle(fontSize: 10.sp, color: TravelTheme.muted),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                booking.voucherCode ?? 'VCH-${booking.id}98X',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w900,
                                  color: TravelTheme.blue,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: TravelTheme.background,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: TravelTheme.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.people_alt_rounded, size: 16, color: TravelTheme.blue),
                                SizedBox(width: 6.w),
                                Text(
                                  '${booking.travelersCount} ${l10nPick(context, en: 'Travelers', fa: 'مسافر')}',
                                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Barcode simulation box
                      Container(
                        height: 60.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Center(
                          child: Icon(Icons.qr_code_2_rounded, size: 52.r, color: Colors.black87),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Present this digital voucher at hotel check-in and airport meeting point',
                          fa: 'این واچر را در هنگام پذیرش هتل و حضور در فرودگاه به همراه داشته باشید',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10.sp, color: TravelTheme.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: Text(l10nPick(context, en: 'Share Voucher', fa: 'اشتراک‌گذاری واچر')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TravelTheme.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  onPressed: () {
                    Get.snackbar(
                      l10nPick(context, en: 'Voucher Link Copied', fa: 'لینک واچر کپی شد'),
                      l10nPick(context, en: 'You can now send this voucher to your companions.', fa: 'می‌توانید اطلاعات واچر را برای همسفران خود ارسال نمایید.'),
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.white,
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: Text(l10nPick(context, en: 'Download PDF', fa: 'دانلود نسخه PDF')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  onPressed: () {
                    Get.snackbar(
                      l10nPick(context, en: 'PDF Generated', fa: 'نسخه PDF آماده شد'),
                      l10nPick(context, en: 'Voucher saved to your device downloads folder.', fa: 'فایل واچر در پوشه دانلودهای شما ذخیره شد.'),
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.white,
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.r, color: TravelTheme.blue),
            SizedBox(width: 4.w),
            Text(label, style: TextStyle(fontSize: 10.sp, color: TravelTheme.muted)),
          ],
        ),
        SizedBox(height: 3.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: TravelTheme.ink),
        ),
      ],
    );
  }
}

