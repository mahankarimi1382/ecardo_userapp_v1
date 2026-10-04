import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_theme.dart';
import '../controllers/tour_controller.dart';
import '../models/tour_model.dart';
import 'tour_my_bookings_screen.dart';
import 'tour_voucher_screen.dart';

class TourPaymentScreen extends StatefulWidget {
  final int bookingId;

  const TourPaymentScreen({super.key, required this.bookingId});

  @override
  State<TourPaymentScreen> createState() => _TourPaymentScreenState();
}

class _TourPaymentScreenState extends State<TourPaymentScreen> {
  final TourController controller = Get.find<TourController>();

  String paymentMode = 'FULL'; // 'FULL' or 'DEPOSIT'

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          l10nPick(context, en: 'Confirm & Pay Tour', fa: 'تأیید و پرداخت نهایی تور'),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textPrimary, size: AppSpacing.iconSm.r),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingDetail.value && controller.activeBooking.value == null) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? AppColors.darkPrimary : TravelTheme.blue,
            ),
          );
        }

        final booking = controller.activeBooking.value;
        if (booking == null) {
          return Center(
            child: Text(
              l10nPick(context, en: 'Booking not found', fa: 'رزرو یافت نشد'),
              style: TextStyle(color: textSecondary),
            ),
          );
        }

        final depositAmount = (booking.totalPrice * 0.30);

        return ListView(
          padding: EdgeInsets.all(AppSpacing.lg.r),
          children: [
            // Order Summary Card
            Container(
              padding: EdgeInsets.all(AppSpacing.lg.r),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                    blurRadius: 12,
                    offset: const Offset(0, 3),
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
                        booking.bookingNo,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkPrimary : TravelTheme.blue,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.warning.withValues(alpha: 0.2) : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          booking.statusLabel,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.warning : Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  Text(
                    booking.tourTitle,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${booking.tourCity} • ${booking.departDate ?? ''} تا ${booking.returnDate ?? ''}',
                    style: TextStyle(fontSize: 11.sp, color: textSecondary),
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  Divider(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                  SizedBox(height: AppSpacing.xs.h),
                  _buildSummaryRow(
                    l10nPick(context, en: 'Travelers:', fa: 'مسافران:'),
                    '${booking.travelersCount} ${l10nPick(context, en: 'Persons', fa: 'نفر')} (${booking.adultsCount} بزرگسال${booking.childrenCount > 0 ? ' + ${booking.childrenCount} کودک' : ''})',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  _buildSummaryRow(
                    l10nPick(context, en: 'Accommodation Tier:', fa: 'درجه اقامت:'),
                    booking.tier,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  _buildSummaryRow(
                    l10nPick(context, en: 'Total Tour Price:', fa: 'مجموع بهای کل تور:'),
                    '${_formatPrice(booking.totalPrice)} ${booking.currency}',
                    isBold: true,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),

            // Payment Mode Selector
            Text(
              l10nPick(context, en: 'Choose Payment Option:', fa: 'نحوه پرداخت را انتخاب کنید:'),
              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w900, color: textPrimary),
            ),
            SizedBox(height: AppSpacing.sm.h),
            _buildPaymentModeTile(
              mode: 'FULL',
              title: l10nPick(context, en: 'Full Payment (100%)', fa: 'تسویه کامل (۱۰۰٪)'),
              subtitle: l10nPick(
                context,
                en: 'Pay full amount now and immediately receive your finalized tour voucher',
                fa: 'پرداخت کل مبلغ و دریافت فوری واچر قطعی تور',
              ),
              amount: booking.totalPrice,
              currency: booking.currency,
              isDark: isDark,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            SizedBox(height: AppSpacing.sm.h),
            _buildPaymentModeTile(
              mode: 'DEPOSIT',
              title: l10nPick(context, en: 'Deposit (30% Upfront)', fa: 'پرداخت بیعانه (۳۰٪ پیش‌پرداخت)'),
              subtitle: l10nPick(
                context,
                en: 'Pay 30% to guarantee your seat lock; settle remainder up to 7 days before departure',
                fa: 'پرداخت ۳۰٪ جهت قطعی‌سازی سهمیه صندلی؛ تسویه باقیمانده تا ۷ روز قبل از پرواز',
              ),
              amount: depositAmount,
              currency: booking.currency,
              badgeText: l10nPick(context, en: 'Popular', fa: 'محبوب‌ترین'),
              isDark: isDark,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            SizedBox(height: AppSpacing.lg.h),

            // Wallet Payment Card
            Container(
              padding: EdgeInsets.all(AppSpacing.lg.r),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                border: Border.all(
                  color: (isDark ? AppColors.darkPrimary : TravelTheme.blue).withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md.r),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.darkPrimary : TravelTheme.blue).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: isDark ? AppColors.darkPrimary : TravelTheme.blue,
                      size: AppSpacing.iconSm.r,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10nPick(context, en: 'Pay from eCardo Wallet', fa: 'پرداخت از کیف پول اصلی eCardo'),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          l10nPick(context, en: 'Instant deduction with double-entry security', fa: 'کسر آنی و مطمئن با پشتیبانی دفترکل مالی'),
                          style: TextStyle(fontSize: 10.5.sp, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20.r),
                ],
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final booking = controller.activeBooking.value;
        if (booking == null) return const SizedBox.shrink();

        final depositAmount = (booking.totalPrice * 0.30);
        final payableAmount = paymentMode == 'FULL' ? booking.totalPrice : depositAmount;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl.w,
            vertical: AppSpacing.md.h,
          ),
          decoration: BoxDecoration(
            color: surfaceColor,
            boxShadow: [
              BoxShadow(
                color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paymentMode == 'FULL'
                            ? l10nPick(context, en: 'Full Payment:', fa: 'پرداخت کل مبلغ:')
                            : l10nPick(context, en: 'Deposit (30%):', fa: 'پیش‌پرداخت بیعانه:'),
                        style: TextStyle(fontSize: 11.sp, color: textSecondary),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${_formatPrice(payableAmount)} ${booking.currency}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl.w, vertical: 14.h),
                  ),
                  onPressed: controller.isBookingAction.value
                      ? null
                      : () => _executePayment(booking),
                  child: controller.isBookingAction.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                        )
                      : Text(
                          l10nPick(context, en: 'Confirm & Pay', fa: 'تأیید و پرداخت نهایی'),
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                        ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 11.sp, color: textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: isBold ? AppColors.success : textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentModeTile({
    required String mode,
    required String title,
    required String subtitle,
    required double amount,
    required String currency,
    String? badgeText,
    required bool isDark,
    required Color surfaceColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final isSelected = paymentMode == mode;
    final primaryColor = isDark ? AppColors.darkPrimary : TravelTheme.blue;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => paymentMode = mode);
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md.r),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkPrimaryContainer : TravelTheme.blue.withValues(alpha: 0.08))
              : surfaceColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
          border: Border.all(
            color: isSelected ? primaryColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: isSelected ? primaryColor : textSecondary,
                  size: 20.r,
                ),
                SizedBox(width: AppSpacing.sm.w),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                          color: isSelected ? primaryColor : textPrimary,
                        ),
                      ),
                      if (badgeText != null) ...[
                        SizedBox(width: AppSpacing.sm.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusXs.r),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w900, color: AppColors.deepBlack),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  '${_formatPrice(amount)} $currency',
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Padding(
              padding: EdgeInsetsDirectional.only(start: 30.w),
              child: Text(
                subtitle,
                style: TextStyle(fontSize: 10.5.sp, color: textSecondary, height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _executePayment(TourBookingModel booking) async {
    HapticFeedback.lightImpact();
    final updated = await controller.payBooking(
      bookingId: booking.id,
      paymentMode: paymentMode,
    );

    if (!mounted) return;

    if (updated != null) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success),
              SizedBox(width: AppSpacing.sm.w),
              Text(
                l10nPick(context, en: 'Payment Successful!', fa: 'پرداخت با موفقیت انجام شد!'),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Text(
            l10nPick(
              context,
              en: 'Your tour booking has been confirmed. You can now access and share your digital voucher.',
              fa: 'رزرو تور شما با موفقیت ثبت و تأیید شد. اکنون می‌توانید واچر دیجیتال سفر خود را مشاهده یا دانلود کنید.',
            ),
            style: TextStyle(fontSize: 12.sp, color: TravelTheme.muted, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.off(() => const TourMyBookingsScreen());
              },
              child: Text(l10nPick(context, en: 'My Bookings', fa: 'رزروهای من')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: TravelTheme.blue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
              ),
              onPressed: () {
                Get.back();
                Get.off(() => TourVoucherScreen(booking: updated));
              },
              child: Text(l10nPick(context, en: 'View Voucher', fa: 'مشاهده واچر تور')),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } else {
      Get.snackbar(
        l10nPick(context, en: 'Payment Failed', fa: 'خطا در پرداخت'),
        l10nPick(context, en: 'Insufficient balance or payment processing error.', fa: 'موجودی کیف پول کافی نیست یا در فرآیند پرداخت خطایی رخ داد.'),
      );
    }
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
