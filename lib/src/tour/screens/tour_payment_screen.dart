
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_theme.dart';
import '../controllers/tour_controller.dart';
import '../models/tour_model.dart';
import 'tour_voucher_screen.dart';
import 'tour_my_bookings_screen.dart';

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
    controller.loadBookingDetails(widget.bookingId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TravelTheme.background,
      appBar: AppBar(
        title: Text(
          l10nPick(context, en: 'Confirm & Pay Tour', fa: 'تأیید و پرداخت رزرو تور'),
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
      body: Obx(() {
        if (controller.isBookingAction.value && controller.activeBooking.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final booking = controller.activeBooking.value;
        if (booking == null) {
          return Center(
            child: Text(l10nPick(context, en: 'Booking not found', fa: 'رزرو یافت نشد')),
          );
        }

        final depositAmount = (booking.totalPrice * 0.30);
        final payableAmount = paymentMode == 'FULL' ? booking.totalPrice : depositAmount;

        return ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            // Order Summary Card
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: TravelTheme.shadow,
              ),
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          booking.statusLabel,
                          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.amber.shade900),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    booking.tourTitle,
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: TravelTheme.ink),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '${booking.tourCity} • ${booking.departDate ?? ''} تا ${booking.returnDate ?? ''}',
                    style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
                  ),
                  SizedBox(height: 12.h),
                  const Divider(),
                  SizedBox(height: 8.h),
                  _buildSummaryRow(
                    l10nPick(context, en: 'Travelers:', fa: 'مسافران:'),
                    '${booking.travelersCount} ${l10nPick(context, en: 'Persons', fa: 'نفر')} (${booking.adultsCount} بزرگسال${booking.childrenCount > 0 ? ' + ${booking.childrenCount} کودک' : ''})',
                  ),
                  SizedBox(height: 6.h),
                  _buildSummaryRow(
                    l10nPick(context, en: 'Accommodation Tier:', fa: 'درجه اقامت:'),
                    booking.tier,
                  ),
                  SizedBox(height: 6.h),
                  _buildSummaryRow(
                    l10nPick(context, en: 'Total Tour Price:', fa: 'مجموع بهای کل تور:'),
                    '${_formatPrice(booking.totalPrice)} ${booking.currency}',
                    isBold: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Payment Mode Selector
            Text(
              l10nPick(context, en: 'Choose Payment Option:', fa: 'نحوه پرداخت را انتخاب کنید:'),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: TravelTheme.ink),
            ),
            SizedBox(height: 10.h),
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
            ),
            SizedBox(height: 10.h),
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
            ),
            SizedBox(height: 16.h),

            // Wallet Payment Card
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: TravelTheme.shadow,
                border: Border.all(color: TravelTheme.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: TravelTheme.blue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: TravelTheme.blue),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10nPick(context, en: 'Pay from eCardo Wallet', fa: 'پرداخت از کیف پول اصلی eCardo'),
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          l10nPick(context, en: 'Instant deduction with double-entry security', fa: 'کسر آنی و مطمئن با پشتیبانی دفترکل مالی'),
                          style: TextStyle(fontSize: 10.sp, color: TravelTheme.muted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded, color: TravelTheme.green),
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
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
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
                        l10nPick(context, en: 'Payable Amount:', fa: 'مبلغ قابل پرداخت:'),
                        style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${_formatPrice(payableAmount)} ${booking.currency}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: TravelTheme.green,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TravelTheme.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 14.h),
                  ),
                  onPressed: controller.isBookingAction.value
                      ? null
                      : () => _executePayment(booking),
                  child: controller.isBookingAction.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted)),
        Text(
          value,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: isBold ? TravelTheme.green : TravelTheme.ink,
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
  }) {
    final isSelected = paymentMode == mode;

    return InkWell(
      onTap: () => setState(() => paymentMode = mode),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isSelected ? TravelTheme.blue.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? TravelTheme.blue : TravelTheme.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: TravelTheme.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: isSelected ? TravelTheme.blue : TravelTheme.muted,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                          color: isSelected ? TravelTheme.blue : TravelTheme.ink,
                        ),
                      ),
                      if (badgeText != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w900, color: Colors.black87),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  '${_formatPrice(amount)} $currency',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    color: TravelTheme.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Padding(
              padding: EdgeInsetsDirectional.only(start: 34.w),
              child: Text(
                subtitle,
                style: TextStyle(fontSize: 10.sp, color: TravelTheme.muted, height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _executePayment(TourBookingModel booking) async {
    final updated = await controller.payBooking(
      bookingId: booking.id,
      paymentMode: paymentMode,
    );

    if (updated != null) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: TravelTheme.green),
              SizedBox(width: 8.w),
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
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
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

