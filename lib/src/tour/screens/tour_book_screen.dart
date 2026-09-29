
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_theme.dart';
import '../controllers/tour_controller.dart';
import '../models/tour_model.dart';
import 'tour_payment_screen.dart';

class TourBookScreen extends StatefulWidget {
  final TourModel tour;

  const TourBookScreen({super.key, required this.tour});

  @override
  State<TourBookScreen> createState() => _TourBookScreenState();
}

class _TourBookScreenState extends State<TourBookScreen> {
  final TourController controller = Get.find<TourController>();

  TourDeparture? selectedDeparture;
  String selectedModel = 'group';
  String selectedTier = 'STD';
  int adultsCount = 1;
  int childrenCount = 0;

  // Passenger form controllers
  final List<Map<String, TextEditingController>> travelerControllers = [];

  @override
  void initState() {
    super.initState();
    if (widget.tour.departures.isNotEmpty) {
      selectedDeparture = widget.tour.departures.first;
    }
    _syncTravelerForms();
  }

  void _syncTravelerForms() {
    final total = adultsCount + childrenCount;
    while (travelerControllers.length < total) {
      travelerControllers.add({
        'first_name': TextEditingController(),
        'last_name': TextEditingController(),
        'passport': TextEditingController(),
        'passport_expiry': TextEditingController(text: '2028-10-20'),
        'birth_date': TextEditingController(text: '1995-05-15'),
      });
    }
    while (travelerControllers.length > total) {
      final removed = travelerControllers.removeLast();
      for (final c in removed.values) {
        c.dispose();
      }
    }
  }

  @override
  void dispose() {
    for (final map in travelerControllers) {
      for (final c in map.values) {
        c.dispose();
      }
    }
    super.dispose();
  }

  double get totalPrice {
    final depMult = selectedDeparture?.priceMultiplier ?? 1.0;
    double hotelDelta = 0.0;
    final hotel = widget.tour.hotels.firstWhereOrNull((h) => h.tier == selectedTier);
    if (hotel != null) hotelDelta = hotel.priceDelta;

    final perPerson = (widget.tour.basePrice * depMult) + hotelDelta;
    final total = (perPerson * adultsCount) + (perPerson * 0.75 * childrenCount);
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TravelTheme.background,
      appBar: AppBar(
        title: Text(
          l10nPick(context, en: 'Book Tour', fa: 'رزرو تور مسافرتی'),
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
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          // Tour Header Info
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: TravelTheme.shadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: TravelTheme.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Icon(Icons.travel_explore_rounded, color: TravelTheme.blue),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tour.title,
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${widget.tour.city}, ${widget.tour.countryCode} • ${widget.tour.durationDays} ${l10nPick(context, en: 'Days', fa: 'روز')}',
                        style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // 1. Departure Date Selection
          _SectionTitle(title: l10nPick(context, en: '1. Select Departure Date', fa: '۱. انتخاب تاریخ حرکت')),
          SizedBox(height: 8.h),
          if (widget.tour.departures.isEmpty)
            Text(l10nPick(context, en: 'No departures available', fa: 'تاریخ حرکتی موجود نیست'))
          else
            Column(
              children: widget.tour.departures.map((dep) {
                final isSelected = selectedDeparture?.id == dep.id;
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: InkWell(
                    onTap: () => setState(() => selectedDeparture = dep),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: isSelected ? TravelTheme.blue.withValues(alpha: 0.08) : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected ? TravelTheme.blue : TravelTheme.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                color: isSelected ? TravelTheme.blue : TravelTheme.muted,
                                size: 20.r,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                '${dep.departDate} تا ${dep.returnDate}',
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: dep.availableSeats > 3 ? Colors.green.shade50 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              '${dep.availableSeats} ${l10nPick(context, en: 'seats left', fa: 'صندلی خالی')}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: dep.availableSeats > 3 ? Colors.green.shade700 : Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          SizedBox(height: 16.h),

          // 2. Hotel Tier Selection
          _SectionTitle(title: l10nPick(context, en: '2. Hotel Accommodation Tier', fa: '۲. درجه هتل و اقامت')),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildTierOption('ECO', 'اکونومی', Icons.eco_rounded),
              SizedBox(width: 8.w),
              _buildTierOption('STD', 'استاندارد', Icons.hotel_rounded),
              SizedBox(width: 8.w),
              _buildTierOption('LUX', 'لوکس VIP', Icons.diamond_rounded),
            ],
          ),
          SizedBox(height: 16.h),

          // 3. Travelers Count
          _SectionTitle(title: l10nPick(context, en: '3. Number of Travelers', fa: '۳. تعداد مسافران')),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: TravelTheme.shadow,
            ),
            child: Column(
              children: [
                _buildCounterRow(
                  title: l10nPick(context, en: 'Adults (12+ years)', fa: 'بزرگسال (۱۲ سال به بالا)'),
                  count: adultsCount,
                  onMinus: adultsCount > 1
                      ? () {
                          setState(() {
                            adultsCount--;
                            _syncTravelerForms();
                          });
                        }
                      : null,
                  onPlus: adultsCount < 10
                      ? () {
                          setState(() {
                            adultsCount++;
                            _syncTravelerForms();
                          });
                        }
                      : null,
                ),
                const Divider(),
                _buildCounterRow(
                  title: l10nPick(context, en: 'Children (2-12 years)', fa: 'کودک (۲ تا ۱۲ سال)'),
                  count: childrenCount,
                  onMinus: childrenCount > 0
                      ? () {
                          setState(() {
                            childrenCount--;
                            _syncTravelerForms();
                          });
                        }
                      : null,
                  onPlus: childrenCount < 6
                      ? () {
                          setState(() {
                            childrenCount++;
                            _syncTravelerForms();
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // 4. Passenger Information
          _SectionTitle(title: l10nPick(context, en: '4. Travelers Passport Information', fa: '۴. مشخصات گذرنامه مسافران')),
          SizedBox(height: 8.h),
          ...List.generate(travelerControllers.length, (index) {
            final isAdult = index < adultsCount;
            final map = travelerControllers[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: TravelTheme.shadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12.r,
                        backgroundColor: TravelTheme.blue,
                        child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${l10nPick(context, en: 'Passenger', fa: 'مسافر')} ${index + 1} (${isAdult ? l10nPick(context, en: 'Adult', fa: 'بزرگسال') : l10nPick(context, en: 'Child', fa: 'کودک')})',
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: map['first_name'],
                          decoration: InputDecoration(
                            labelText: l10nPick(context, en: 'First Name (Latin)', fa: 'نام لاتین (مطابق پاسپورت)'),
                            labelStyle: TextStyle(fontSize: 11.sp),
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextField(
                          controller: map['last_name'],
                          decoration: InputDecoration(
                            labelText: l10nPick(context, en: 'Last Name (Latin)', fa: 'نام خانوادگی لاتین'),
                            labelStyle: TextStyle(fontSize: 11.sp),
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: map['passport'],
                    decoration: InputDecoration(
                      labelText: l10nPick(context, en: 'Passport Number', fa: 'شماره گذرنامه (مثلاً A12345678)'),
                      labelStyle: TextStyle(fontSize: 11.sp),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: Container(
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
                      l10nPick(context, en: 'Total payable:', fa: 'مجموع کل رزرو:'),
                      style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${totalPrice.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")} ${widget.tour.currency}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                        color: TravelTheme.green,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TravelTheme.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                ),
                onPressed: _onProceedToPayment,
                child: Obx(() => controller.isBookingAction.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        l10nPick(context, en: 'Continue to Payment', fa: 'مرحله بعد: پرداخت'),
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                      )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierOption(String tier, String label, IconData icon) {
    final isSelected = selectedTier == tier;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedTier = tier),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: isSelected ? TravelTheme.blue.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? TravelTheme.blue : TravelTheme.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? TravelTheme.blue : TravelTheme.muted, size: 22.r),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? TravelTheme.blue : TravelTheme.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterRow({
    required String title,
    required int count,
    required VoidCallback? onMinus,
    required VoidCallback? onPlus,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded),
              onPressed: onMinus,
              color: onMinus != null ? TravelTheme.blue : Colors.grey.shade300,
            ),
            Text(
              '$count',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: onPlus,
              color: onPlus != null ? TravelTheme.blue : Colors.grey.shade300,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _onProceedToPayment() async {
    if (selectedDeparture == null) {
      Get.snackbar(
        l10nPick(context, en: 'Error', fa: 'خطا'),
        l10nPick(context, en: 'Please select a departure date', fa: 'لطفاً تاریخ حرکت را انتخاب کنید'),
      );
      return;
    }

    // Prepare travelers
    final travelers = <TourTravelerModel>[];
    for (int i = 0; i < travelerControllers.length; i++) {
      final map = travelerControllers[i];
      final fn = map['first_name']!.text.trim();
      final ln = map['last_name']!.text.trim();
      final pass = map['passport']!.text.trim();
      final expiry = map['passport_expiry']!.text.trim();

      travelers.add(TourTravelerModel(
        firstNameLatin: fn.isNotEmpty ? fn : 'Traveler${i + 1}',
        lastNameLatin: ln.isNotEmpty ? ln : 'TourGuest',
        passportNumber: pass.isNotEmpty ? pass : 'P${10000000 + i}',
        passportExpiry: expiry.isNotEmpty ? expiry : '2028-10-20',
        type: i < adultsCount ? 'ADULT' : 'CHILD',
      ));
    }

    final booking = await controller.createBooking(
      tourId: widget.tour.id,
      departureId: selectedDeparture!.id,
      travelersCount: adultsCount + childrenCount,
      adultsCount: adultsCount,
      childrenCount: childrenCount,
      model: selectedModel,
      tier: selectedTier,
    );

    if (booking != null) {
      await controller.submitTravelers(booking.id, travelers);
      Get.to(() => TourPaymentScreen(bookingId: booking.id));
    } else {
      Get.snackbar(
        l10nPick(context, en: 'Booking failed', fa: 'خطا در ثبت رزرو'),
        l10nPick(context, en: 'Unable to reserve seats. Please try again.', fa: 'امکان قفل صندلی وجود نداشت، مجدداً تلاش نمایید.'),
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w900,
        color: TravelTheme.ink,
      ),
    );
  }
}

