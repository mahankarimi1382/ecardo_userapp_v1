
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_theme.dart';
import '../controllers/tour_controller.dart';
import '../models/tour_model.dart';
import 'tour_voucher_screen.dart';

class TourMyBookingsScreen extends StatefulWidget {
  const TourMyBookingsScreen({super.key});

  @override
  State<TourMyBookingsScreen> createState() => _TourMyBookingsScreenState();
}

class _TourMyBookingsScreenState extends State<TourMyBookingsScreen> {
  final TourController controller = Get.find<TourController>();
  String currentStatus = '';

  final filters = [
    {'status': '', 'label_fa': 'همه رزروها', 'label_en': 'All'},
    {'status': 'CONFIRMED', 'label_fa': 'تأییدشده', 'label_en': 'Confirmed'},
    {'status': 'DEPOSIT_PAID', 'label_fa': 'بیعانه پرداخت‌شده', 'label_en': 'Deposit Paid'},
    {'status': 'DRAFT', 'label_fa': 'در انتظار پرداخت', 'label_en': 'Pending Payment'},
    {'status': 'CANCELLED', 'label_fa': 'لغوشده', 'label_en': 'Cancelled'},
  ];

  @override
  void initState() {
    super.initState();
    controller.loadMyBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TravelTheme.background,
      appBar: AppBar(
        title: Text(
          l10nPick(context, en: 'My Tour Bookings', fa: 'رزروهای تور من'),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: TravelTheme.ink),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: TravelTheme.ink),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Filter Horizontal Chips
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: SizedBox(
              height: 36.h,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final f = filters[index];
                  final isSelected = currentStatus == f['status'];
                  return FilterChip(
                    selected: isSelected,
                    label: Text(
                      l10nPick(context, en: f['label_en']!, fa: f['label_fa']!),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : TravelTheme.ink,
                      ),
                    ),
                    backgroundColor: TravelTheme.background,
                    selectedColor: TravelTheme.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      side: BorderSide(color: isSelected ? TravelTheme.blue : TravelTheme.border),
                    ),
                    onSelected: (val) {
                      setState(() => currentStatus = f['status']!);
                      controller.loadMyBookings(status: currentStatus.isEmpty ? null : currentStatus);
                    },
                  );
                },
              ),
            ),
          ),

          // Bookings List
          Expanded(
            child: Obx(() {
              if (controller.isLoadingBookings.value && controller.myBookings.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.myBookings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.confirmation_number_outlined, size: 64.r, color: TravelTheme.muted),
                      SizedBox(height: 12.h),
                      Text(
                        l10nPick(context, en: 'No bookings found', fa: 'رزروی در این بخش یافت نشد'),
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: TravelTheme.blue,
                onRefresh: () => controller.loadMyBookings(
                  status: currentStatus.isEmpty ? null : currentStatus,
                ),
                child: ListView.separated(
                  padding: EdgeInsets.all(16.r),
                  itemCount: controller.myBookings.length,
                  separatorBuilder: (_, __) => SizedBox(height: 14.h),
                  itemBuilder: (context, index) {
                    final booking = controller.myBookings[index];
                    return _BookingCard(
                      booking: booking,
                      onViewVoucher: () {
                        Get.to(() => TourVoucherScreen(booking: booking));
                      },
                      onPayRemainder: () => _showPayRemainderDialog(booking),
                      onCancel: () => _confirmCancelBooking(booking),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showPayRemainderDialog(TourBookingModel booking) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          l10nPick(context, en: 'Settle Remaining Balance', fa: 'تسویه باقیمانده مبلغ تور'),
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${booking.tourTitle} (${booking.bookingNo})',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10.h),
            Text(
              '${l10nPick(context, en: 'Remaining Balance:', fa: 'مانده قابل پرداخت:')} ${booking.remainingBalance.toInt()} ${booking.currency}',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: TravelTheme.green),
            ),
            SizedBox(height: 6.h),
            Text(
              l10nPick(
                context,
                en: 'Amount will be deducted from your eCardo main wallet.',
                fa: 'مبلغ باقیمانده از کیف پول اصلی eCardo شما کسر خواهد شد.',
              ),
              style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10nPick(context, en: 'Cancel', fa: 'انصراف')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: TravelTheme.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            onPressed: () async {
              Get.back();
              await controller.payRemainder(booking.id);
            },
            child: Text(l10nPick(context, en: 'Pay Now', fa: 'پرداخت و تسویه')),
          ),
        ],
      ),
    );
  }

  void _confirmCancelBooking(TourBookingModel booking) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          l10nPick(context, en: 'Cancel Booking?', fa: 'آیا از لغو رزرو اطمینان دارید؟'),
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
        ),
        content: Text(
          l10nPick(
            context,
            en: 'Your seat reservation will be released.',
            fa: 'صندلی‌های قفل‌شده برای این تور آزاد خواهد شد.',
          ),
          style: TextStyle(fontSize: 12.sp, color: TravelTheme.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10nPick(context, en: 'Back', fa: 'بازگشت')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: TravelTheme.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            onPressed: () async {
              Get.back();
              await controller.cancelBooking(booking.id);
            },
            child: Text(l10nPick(context, en: 'Confirm Cancel', fa: 'تأیید لغو')),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final TourBookingModel booking;
  final VoidCallback onViewVoucher;
  final VoidCallback onPayRemainder;
  final VoidCallback onCancel;

  const _BookingCard({
    required this.booking,
    required this.onViewVoucher,
    required this.onPayRemainder,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final canViewVoucher = booking.status == 'CONFIRMED' ||
        booking.status == 'VOUCHER_ISSUED' ||
        booking.status == 'COMPLETED' ||
        booking.status == 'DEPOSIT_PAID';

    final hasRemainder = booking.remainingBalance > 0 &&
        (booking.status == 'DEPOSIT_PAID' || booking.status == 'CONFIRMED');

    final canCancel = booking.status == 'DRAFT' || booking.status == 'PENDING_PAYMENT';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: TravelTheme.shadow,
        border: Border.all(color: TravelTheme.border.withValues(alpha: 0.6)),
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.bookingNo,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: TravelTheme.blue),
              ),
              _buildStatusBadge(booking.status, booking.statusLabel),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            booking.tourTitle,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: TravelTheme.ink),
          ),
          SizedBox(height: 4.h),
          Text(
            '${booking.tourCity} • حرکت: ${booking.departDate ?? 'نامشخص'} • ${booking.travelersCount} نفر',
            style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(context, en: 'Total Amount:', fa: 'مبلغ کل:'),
                    style: TextStyle(fontSize: 10.sp, color: TravelTheme.muted),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${booking.totalPrice.toInt()} ${booking.currency}',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              if (booking.remainingBalance > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10nPick(context, en: 'Remaining:', fa: 'مانده:'),
                      style: TextStyle(fontSize: 10.sp, color: TravelTheme.muted),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${booking.remainingBalance.toInt()} ${booking.currency}',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: TravelTheme.red),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              if (canViewVoucher) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_rounded, size: 16),
                    label: Text(l10nPick(context, en: 'View Voucher', fa: 'مشاهده واچر')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TravelTheme.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    onPressed: onViewVoucher,
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              if (hasRemainder) ...[
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TravelTheme.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    onPressed: onPayRemainder,
                    child: Text(l10nPick(context, en: 'Pay Remainder', fa: 'تسویه باقیمانده')),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              if (canCancel)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TravelTheme.red,
                    side: const BorderSide(color: TravelTheme.red),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  onPressed: onCancel,
                  child: Text(l10nPick(context, en: 'Cancel', fa: 'لغو رزرو')),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, String label) {
    Color bg = Colors.grey.shade100;
    Color fg = Colors.grey.shade800;

    switch (status) {
      case 'CONFIRMED':
      case 'VOUCHER_ISSUED':
      case 'COMPLETED':
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        break;
      case 'DEPOSIT_PAID':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade800;
        break;
      case 'DRAFT':
      case 'PENDING_PAYMENT':
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade900;
        break;
      case 'CANCELLED':
        bg = Colors.red.shade50;
        fg = Colors.red.shade800;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}

