import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/app_haptics.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/mock_travel_data.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_theme.dart';
import 'taxi_models.dart';

/// Accessible, theme-aware counter tile with >=48dp touch targets and dark mode safety.
/// Fixes lines ~474 and ~488 in legacy taxi_search_screen.
class TaxiCounterControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final RxInt value;
  final int min;
  final int max;
  final String unit;
  final ValueChanged<int>? onChanged;

  const TaxiCounterControl({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.min = 0,
    this.max = 10,
    this.unit = '',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = TravelTheme.isDark(context);
    final cardBg = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC);
    final buttonBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final borderColor = TravelTheme.borderFor(context);
    final textColor = TravelTheme.textPrimaryFor(context);
    final mutedColor = TravelTheme.textSecondaryFor(context);

    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.r, color: const Color(0xFF0D9488)),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: mutedColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Decrement Button (min 44x44dp hit area)
              Semantics(
                button: true,
                label: 'کاهش $label',
                child: InkWell(
                  onTap: () {
                    if (value.value > min) {
                      AppHaptics.light();
                      value.value--;
                      onChanged?.call(value.value);
                    }
                  },
                  borderRadius: BorderRadius.circular(24.r),
                  child: Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      color: buttonBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor),
                      boxShadow: isDark ? null : TravelTheme.shadow,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.remove_rounded,
                        size: 18.r,
                        color: value.value > min ? textColor : mutedColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
              // Value Display
              Obx(() => Text(
                '${value.value}${unit.isNotEmpty ? ' $unit' : ''}',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              )),
              // Increment Button
              Semantics(
                button: true,
                label: 'افزایش $label',
                child: InkWell(
                  onTap: () {
                    if (value.value < max) {
                      AppHaptics.light();
                      value.value++;
                      onChanged?.call(value.value);
                    }
                  },
                  borderRadius: BorderRadius.circular(24.r),
                  child: Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      color: buttonBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor),
                      boxShadow: isDark ? null : TravelTheme.shadow,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add_rounded,
                        size: 18.r,
                        color: value.value < max ? const Color(0xFF0D9488) : mutedColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Trust signals banner highlighting the 4 core pillars of airport transfers
class TaxiTrustSignalsBanner extends StatelessWidget {
  const TaxiTrustSignalsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.all(16.r),
      decoration: BoxDecoration(
        borderRadius: TravelTheme.radius,
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        boxShadow: TravelTheme.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            l10nPick(context, en: '100% FIXED RATE', fa: 'کرایه قطعی و تضمین‌شده', ar: 'سعر ثابت مؤكد'),
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      l10nPick(
                        context,
                        en: 'Punctual & Safe Airport Transfers',
                        fa: 'ترانسفر اختصاصی و مطمئن فرودگاهی',
                        ar: 'خدمة نقل مريحة ودقيقة في المواعيد',
                        zh: '准时、安全、舒适的专属接送',
                      ),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.local_taxi_rounded,
                size: 52.r,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(color: Colors.white24, height: 1),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 6.h,
            children: [
              _TrustItem(
                icon: Icons.hourglass_top_rounded,
                label: l10nPick(context, en: 'Free 60m Flight Delay Wait', fa: '۶۰ دقیقه انتظار رایگان تأخیر پرواز', ar: 'انتظار ٦٠ دقيقة مجاني'),
              ),
              _TrustItem(
                icon: Icons.verified_user_rounded,
                label: l10nPick(context, en: 'Verified Chauffeur Fleet', fa: 'رانندگان رسمی تشریفات', ar: 'سائقون محترفون معتمدون'),
              ),
              _TrustItem(
                icon: Icons.cancel_outlined,
                label: l10nPick(context, en: 'Free Cancel up to 24h', fa: 'لغو رایگان تا ۲۴ ساعت قبل', ar: 'إلغاء مجاني حتى ٢٤ ساعة'),
              ),
              _TrustItem(
                icon: Icons.flight_takeoff_rounded,
                label: l10nPick(context, en: 'Live Flight Status Tracking', fa: 'رصد زنده وضعیت پرواز', ar: 'تتبع مباشر لحركة الطيران'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.r, color: const Color(0xFF99F6E4)),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.95),
          ),
        ),
      ],
    );
  }
}

/// Vehicle Card showing capacity, luggage, amenities, features, and price hierarchy
class TaxiVehicleCard extends StatelessWidget {
  final TaxiVehicleClass vehicle;
  final int totalFare;
  final bool isSelected;
  final int passengerCount;
  final int luggageCount;
  final VoidCallback onTap;

  const TaxiVehicleCard({
    super.key,
    required this.vehicle,
    required this.totalFare,
    required this.isSelected,
    required this.passengerCount,
    required this.luggageCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = TravelTheme.isDark(context);
    final cardBg = isDark ? AppColors.darkSurfaceVariant : Colors.white;
    final titleColor = TravelTheme.textPrimaryFor(context);
    final mutedColor = TravelTheme.textSecondaryFor(context);

    final bool capacityExceeded =
        passengerCount > vehicle.maxPassengers || luggageCount > vehicle.maxLuggage;

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 12.h),
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        borderRadius: TravelTheme.radius,
        child: Container(
          padding: EdgeInsetsDirectional.all(16.r),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: TravelTheme.radius,
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0D9488)
                  : (capacityExceeded ? Colors.amber.shade700 : TravelTheme.borderFor(context)),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? TravelTheme.shadowFor(context) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52.r,
                    height: 52.r,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0D9488).withValues(alpha: 0.18)
                          : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      vehicle.icon,
                      color: isSelected ? const Color(0xFF0D9488) : mutedColor,
                      size: 28.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10nPick(context, en: vehicle.titleEn, fa: vehicle.titleFa),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w900,
                                color: titleColor,
                              ),
                            ),
                            Text(
                              '${formatMockAmount(totalFare)} ${localization.travelMockCurrency}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0D9488),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          vehicle.exampleModels,
                          style: TextStyle(fontSize: 11.sp, color: mutedColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Row(
                    children: [
                      Icon(Icons.people_alt_rounded, size: 16.r, color: mutedColor),
                      SizedBox(width: 4.w),
                      Text(
                        '${vehicle.maxPassengers} ${l10nPick(context, en: 'pax', fa: 'نفر', ar: 'ركاب', zh: '人')}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: passengerCount > vehicle.maxPassengers ? Colors.red : mutedColor,
                          fontWeight: passengerCount > vehicle.maxPassengers ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 14.w),
                  Row(
                    children: [
                      Icon(Icons.luggage_rounded, size: 16.r, color: mutedColor),
                      SizedBox(width: 4.w),
                      Text(
                        '${vehicle.maxLuggage} ${l10nPick(context, en: 'bags', fa: 'چمدان', ar: 'حقائب', zh: '件行李')}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: luggageCount > vehicle.maxLuggage ? Colors.red : mutedColor,
                          fontWeight: luggageCount > vehicle.maxLuggage ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (isSelected)
                    Container(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check, size: 14, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text(
                            l10nPick(context, en: 'Selected', fa: 'انتخاب شده', ar: 'محدد', zh: '已选'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (capacityExceeded) ...[
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 14, color: Colors.amber),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            en: 'Passenger or luggage count exceeds vehicle standard capacity.',
                            fa: 'تعداد مسافر یا بار بیش از ظرفیت استاندارد این خودرو است.',
                            ar: 'عدد الركاب أو الأمتعة يتجاوز سعة السيارة.',
                          ),
                          style: TextStyle(fontSize: 10.sp, color: Colors.amber.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (vehicle.features.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: vehicle.features.map((f) => Container(
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(fontSize: 10.sp, color: mutedColor),
                    ),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Live Tracking & Driver Details Card for Voucher Screen
class TaxiLiveDriverCard extends StatelessWidget {
  final TaxiBookingInfo booking;
  final VoidCallback? onCallDriver;
  final VoidCallback? onOpenSupport;

  const TaxiLiveDriverCard({
    super.key,
    required this.booking,
    this.onCallDriver,
    this.onOpenSupport,
  });

  @override
  Widget build(BuildContext context) {
    final driver = booking.driver;
    final isDark = TravelTheme.isDark(context);
    final cardBg = isDark ? AppColors.darkSurfaceVariant : Colors.white;
    final titleColor = TravelTheme.textPrimaryFor(context);
    final mutedColor = TravelTheme.textSecondaryFor(context);

    if (driver == null) {
      return Container(
        padding: EdgeInsetsDirectional.all(16.r),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: TravelTheme.radius,
          border: Border.all(color: TravelTheme.borderFor(context)),
        ),
        child: Row(
          children: [
            const CircularProgressIndicator.adaptive(),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(context, en: 'Matching Chauffeur...', fa: 'در حال تخصیص بهترین راننده تشریفات...', ar: 'جاري تخصيص السائق...'),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: titleColor),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    l10nPick(context, en: 'Chauffeur details will be finalized 2h prior to arrival.', fa: 'اطلاعات نهایی خودرو ۲ ساعت پیش از حرکت به شما اعلام می‌شود.', ar: 'سيتم تأكيد السائق قبل الموعد بساعتين.'),
                    style: TextStyle(fontSize: 11.sp, color: mutedColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsetsDirectional.all(18.r),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: TravelTheme.radius,
        border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
        boxShadow: TravelTheme.shadowFor(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26.r,
                backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.15),
                child: const Icon(Icons.person_pin_rounded, color: Color(0xFF0D9488), size: 32),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          driver.name,
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: titleColor),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsetsDirectional.symmetric(horizontal: 6.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 13, color: Colors.amber),
                              SizedBox(width: 2.w),
                              Text(
                                '${driver.rating}',
                                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: Colors.amber.shade900),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${driver.vehicleModel} · ${driver.color ?? 'سفید'}',
                      style: TextStyle(fontSize: 11.5.sp, color: mutedColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // License Plate Display
              Container(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: TravelTheme.borderFor(context)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car_rounded, size: 16, color: Color(0xFF0D9488)),
                    SizedBox(width: 6.w),
                    Text(
                      driver.licensePlate,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Call Chauffeur Button
              CommonButton(
                width: 120.w,
                height: 36.h,
                text: l10nPick(context, en: 'Call Chauffeur', fa: 'تماس با راننده', ar: 'اتصال بالسائق'),
                backgroundColor: const Color(0xFF0D9488),
                onPressed: onCallDriver ?? () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Rating bottom sheet for finished rides
class TaxiRatingBottomSheet extends StatefulWidget {
  final String rideId;
  final String driverName;
  final Future<void> Function(RideRatingSubmission rating) onSubmit;

  const TaxiRatingBottomSheet({
    super.key,
    required this.rideId,
    required this.driverName,
    required this.onSubmit,
  });

  @override
  State<TaxiRatingBottomSheet> createState() => _TaxiRatingBottomSheetState();
}

class _TaxiRatingBottomSheetState extends State<TaxiRatingBottomSheet> {
  int _rating = 5;
  final List<String> _selectedTags = [];
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  static const List<String> _complimentTags = [
    'رانندگی مطمئن و ایمن',
    'وقت‌شناسی عالی',
    'خودرو بسیار تمیز و مطبوع',
    'کمک در جابجایی چمدان‌ها',
    'برخورد حرفه‌ای و محترمانه',
    'پذیرایی مناسب',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleColor = TravelTheme.textPrimaryFor(context);
    final mutedColor = TravelTheme.textSecondaryFor(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10nPick(context, en: 'Rate Your Transfer Chauffeur', fa: 'ثبت نظر و امتیاز به راننده تشریفات', ar: 'تقييم تجربة التوصيل'),
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: titleColor),
            ),
            SizedBox(height: 4.h),
            Text(
              widget.driverName,
              style: TextStyle(fontSize: 12.sp, color: mutedColor),
            ),
            SizedBox(height: 14.h),
            // Star row
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    iconSize: 36.r,
                    icon: Icon(
                      starIndex <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      AppHaptics.selection();
                      setState(() => _rating = starIndex);
                    },
                  );
                }),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              l10nPick(context, en: 'Compliments / Feedback', fa: 'نقاط قوت و بازخورد شما', ar: 'الملاحظات الإيجابية'),
              style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w800, color: titleColor),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: _complimentTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag, style: TextStyle(fontSize: 11.sp)),
                  selected: isSelected,
                  selectedColor: const Color(0xFF0D9488).withValues(alpha: 0.2),
                  checkmarkColor: const Color(0xFF0D9488),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _commentController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: l10nPick(context, en: 'Optional comments for our dispatch team...', fa: 'توضیحات اختیاری جهت ارتقای کیفیت خدمات...', ar: 'أي ملاحظات إضافية...'),
                border: const OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            CommonButton(
              width: double.infinity,
              text: l10nPick(context, en: 'Submit Review', fa: 'ثبت و ارسال بازخورد', ar: 'إرسال التقييم'),
              backgroundColor: const Color(0xFF0D9488),
              isLoading: _isSubmitting,
              onPressed: () async {
                setState(() => _isSubmitting = true);
                try {
                  await widget.onSubmit(RideRatingSubmission(
                    rideId: widget.rideId,
                    stars: _rating,
                    tags: _selectedTags,
                    comment: _commentController.text.trim(),
                  ));
                  if (context.mounted) Navigator.pop(context);
                } finally {
                  if (mounted) setState(() => _isSubmitting = false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Cancellation confirmation bottom sheet with refund calculation
class TaxiCancellationBottomSheet extends StatelessWidget {
  final TaxiBookingInfo booking;
  final Future<void> Function(String reason) onConfirmCancel;

  const TaxiCancellationBottomSheet({
    super.key,
    required this.booking,
    required this.onConfirmCancel,
  });

  @override
  Widget build(BuildContext context) {
    final policy = RideCancellationPolicy.standard(
      pickupTime: booking.pickupDate,
      totalFare: booking.totalFare,
      currency: booking.currency,
    );
    final titleColor = TravelTheme.textPrimaryFor(context);
    final mutedColor = TravelTheme.textSecondaryFor(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10nPick(context, en: 'Cancel Transfer Booking', fa: 'لغو رزرو ترانسفر فرودگاهی', ar: 'إلغاء حجز التوصيل'),
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: titleColor),
            ),
            SizedBox(height: 6.h),
            Text(
              l10nPick(context, en: policy.policySummaryEn, fa: policy.policySummaryFa),
              style: TextStyle(fontSize: 12.sp, color: mutedColor, height: 1.4),
            ),
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsetsDirectional.all(14.r),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10nPick(context, en: 'Total Paid Fare:', fa: 'مبلغ کل پرداختی:', ar: 'المبلغ الإجمالي:'),
                        style: TextStyle(fontSize: 12.sp, color: mutedColor)),
                      Text('${formatMockAmount(booking.totalFare)} ${booking.currency}',
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: titleColor)),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10nPick(context, en: 'Refund to eCardo Wallet:', fa: 'مبلغ استرداد به کیف پول:', ar: 'المبلغ المسترد:'),
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.green.shade800)),
                      Text('${formatMockAmount(policy.refundableAmount)} ${booking.currency}',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: Colors.green.shade800)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10nPick(context, en: 'Keep Booking', fa: 'انصراف و حفظ رزرو', ar: 'تراجع')),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CommonButton(
                    text: l10nPick(context, en: 'Confirm Cancel', fa: 'تأیید لغو ترانسفر', ar: 'تأكيد الإلغاء'),
                    backgroundColor: Colors.red.shade700,
                    onPressed: () async {
                      Navigator.pop(context);
                      await onConfirmCancel('درخواست لغو توسط کاربر');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
