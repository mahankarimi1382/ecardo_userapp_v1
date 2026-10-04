import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          l10nPick(context, en: 'My Tour Bookings', fa: 'رزروهای تور من'),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            size: AppSpacing.iconSm.r,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Filter Horizontal Chips
          Container(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: SizedBox(
              height: 36.h,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, _) => SizedBox(width: AppSpacing.sm.w),
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
                        color: isSelected
                            ? AppColors.white
                            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      ),
                    ),
                    backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
                    selectedColor: isDark ? AppColors.darkPrimary : TravelTheme.blue,
                    checkmarkColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                      side: BorderSide(
                        color: isSelected
                            ? (isDark ? AppColors.darkPrimary : TravelTheme.blue)
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                    onSelected: (val) {
                      HapticFeedback.lightImpact();
                      setState(() => currentStatus = f['status']!);
                      controller.loadMyBookings(status: currentStatus.isEmpty ? null : currentStatus);
                    },
                  );
                },
              ),
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),

          // Bookings List (4 States)
          Expanded(
            child: Obx(() {
              // 1. Loading Shimmer
              if (controller.isLoadingBookings.value && controller.myBookings.isEmpty) {
                return _buildBookingsSkeleton(isDark);
              }

              // 2. Empty State
              if (controller.myBookings.isEmpty) {
                return Center(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(AppSpacing.xxxl.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppSpacing.xl.r),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.confirmation_number_outlined,
                            size: 48.r,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                          ),
                        ),
                        SizedBox(height: AppSpacing.md.h),
                        Text(
                          l10nPick(
                            context,
                            en: 'No bookings found',
                            fa: 'رزروی در این بخش یافت نشد',
                            ar: 'لم يتم العثور على أي حجوزات',
                            zh: '未找到预订记录',
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs.h),
                        Text(
                          l10nPick(
                            context,
                            en: 'Your booked tours will appear here after payment confirmation.',
                            fa: 'رزروهای قطعی شما پس از پرداخت در این بخش نمایش داده می‌شوند.',
                            ar: 'ستظهر حجوزاتك المؤكدة هنا بعد إتمام الدفع.',
                            zh: '支付确认后，您的旅游预订将显示在此处。',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg.h),
                        OutlinedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Get.back();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isDark ? AppColors.darkPrimary : TravelTheme.blue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
                          ),
                          child: Text(
                            l10nPick(context, en: 'Explore Tours', fa: 'مشاهده تورها'),
                            style: TextStyle(
                              color: isDark ? AppColors.darkPrimary : TravelTheme.blue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // 3. Content State
              return RefreshIndicator(
                color: isDark ? AppColors.darkPrimary : TravelTheme.blue,
                onRefresh: () => controller.loadMyBookings(
                  status: currentStatus.isEmpty ? null : currentStatus,
                ),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg.w,
                    vertical: AppSpacing.lg.h,
                  ),
                  itemCount: controller.myBookings.length,
                  separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
                  itemBuilder: (context, index) {
                    final booking = controller.myBookings[index];
                    return _BookingCard(
                      booking: booking,
                      isDark: isDark,
                      onViewVoucher: () {
                        HapticFeedback.lightImpact();
                        Get.to(() => TourVoucherScreen(booking: booking));
                      },
                      onPayRemainder: () {
                        HapticFeedback.lightImpact();
                        _showPayRemainderDialog(booking, isDark);
                      },
                      onCancel: () {
                        HapticFeedback.lightImpact();
                        _confirmCancelBooking(booking, isDark);
                      },
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

  Widget _buildBookingsSkeleton(bool isDark) {
    final baseColor = isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade300;
    final highlightColor = isDark ? AppColors.darkSurface : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.lg.r),
        itemCount: 3,
        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
        itemBuilder: (_, _) => Container(
          height: 160.h,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
          ),
        ),
      ),
    );
  }

  void _showPayRemainderDialog(TourBookingModel booking, bool isDark) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r)),
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
            SizedBox(height: AppSpacing.sm.h),
            Text(
              '${l10nPick(context, en: 'Remaining Balance:', fa: 'مانده قابل پرداخت:')} ${booking.remainingBalance.toInt()} ${booking.currency}',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: AppColors.success),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              l10nPick(
                context,
                en: 'Amount will be deducted from your eCardo main wallet.',
                fa: 'مبلغ باقیمانده از کیف پول اصلی eCardo شما کسر خواهد شد.',
              ),
              style: TextStyle(
                fontSize: 11.sp,
                color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
              ),
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
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
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

  void _confirmCancelBooking(TourBookingModel booking, bool isDark) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r)),
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
          style: TextStyle(
            fontSize: 12.sp,
            color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10nPick(context, en: 'Back', fa: 'بازگشت')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
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
  final bool isDark;
  final VoidCallback onViewVoucher;
  final VoidCallback onPayRemainder;
  final VoidCallback onCancel;

  const _BookingCard({
    required this.booking,
    required this.isDark,
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
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      padding: EdgeInsets.all(AppSpacing.lg.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.bookingNo,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkPrimary : TravelTheme.blue,
                ),
              ),
              _buildStatusBadge(context, booking.status, booking.statusLabel, isDark),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            booking.tourTitle,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${booking.tourCity} • حرکت: ${booking.departDate ?? 'نامشخص'} • ${booking.travelersCount} نفر',
            style: TextStyle(
              fontSize: 11.sp,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
          SizedBox(height: AppSpacing.sm.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(context, en: 'Total Amount:', fa: 'مبلغ کل:'),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${booking.totalPrice.toInt()} ${booking.currency}',
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              if (booking.remainingBalance > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10nPick(context, en: 'Remaining:', fa: 'مانده:'),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${booking.remainingBalance.toInt()} ${booking.currency}',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          Row(
            children: [
              if (canViewVoucher) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_rounded, size: 16),
                    label: Text(l10nPick(context, en: 'View Voucher', fa: 'مشاهده واچر')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.darkPrimary : TravelTheme.blue,
                      foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
                    ),
                    onPressed: onViewVoucher,
                  ),
                ),
                SizedBox(width: AppSpacing.sm.w),
              ],
              if (hasRemainder) ...[
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
                    ),
                    onPressed: onPayRemainder,
                    child: Text(l10nPick(context, en: 'Pay Remainder', fa: 'تسویه باقیمانده')),
                  ),
                ),
                SizedBox(width: AppSpacing.sm.w),
              ],
              if (canCancel)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
                  ),
                  onPressed: onCancel,
                  child: Text(l10nPick(context, en: 'Cancel', fa: 'لغو')),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status, String label, bool isDark) {
    Color bg;
    Color fg;

    switch (status.toUpperCase()) {
      case 'CONFIRMED':
      case 'VOUCHER_ISSUED':
      case 'COMPLETED':
        bg = isDark ? AppColors.success.withValues(alpha: 0.2) : AppColors.successContainer;
        fg = AppColors.success;
        break;
      case 'DEPOSIT_PAID':
        bg = isDark ? AppColors.mutedBlue.withValues(alpha: 0.2) : AppColors.infoContainer;
        fg = isDark ? AppColors.mainSoftBlue : TravelTheme.blue;
        break;
      case 'CANCELLED':
      case 'EXPIRED':
        bg = isDark ? AppColors.error.withValues(alpha: 0.2) : AppColors.errorContainer;
        fg = AppColors.error;
        break;
      default:
        bg = isDark ? AppColors.warning.withValues(alpha: 0.2) : AppColors.warningContainer;
        fg = AppColors.warning;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}
