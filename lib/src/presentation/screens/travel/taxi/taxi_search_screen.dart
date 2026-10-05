import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_single_date_picker.dart';
import 'package:ecardo_user/src/helper/app_haptics.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../services/travel_service_requests_screen.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';
import 'taxi_controller.dart';
import 'taxi_models.dart';
import 'taxi_vehicles_screen.dart';
import 'taxi_widgets.dart';

/// Airport Transfer & Taxi Search Screen
/// Provides flight-aware route entry, terminal selection, date/time pickers,
/// passenger/luggage counters, and trust signals.
class TaxiSearchScreen extends StatelessWidget {
  const TaxiSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<TaxiController>()
        ? Get.find<TaxiController>()
        : Get.put(TaxiController());
    final localization = AppLocalizations.of(context)!;
    final isDark = TravelTheme.isDark(context);
    final textPrimary = TravelTheme.textPrimaryFor(context);
    final textSecondary = TravelTheme.textSecondaryFor(context);
    final border = TravelTheme.borderFor(context);

    return TravelPage(
      title: l10nPick(
        context,
        en: 'Airport Transfer & Taxi',
        fa: 'ترانسفر فرودگاهی و تاکسی سفر',
        ar: 'التوصيل من وإلى المطار والتاكسي',
        zh: '机场接送与出行专车',
      ),
      showTravelNavigation: false,
      trailing: IconButton(
        tooltip: localization.travelMyRequests,
        onPressed: () => Get.to(() => const TravelServiceRequestsScreen()),
        icon: const Icon(Icons.receipt_long_rounded),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.all(16.r),
          child: Obx(() => CommonButton(
            width: double.infinity,
            text: l10nPick(
              context,
              en: 'View Available Vehicles & Rates',
              fa: 'مشاهده خودروها و استعلام نرخ قطعی',
              ar: 'عرض السيارات والأسعار المتاحة',
              zh: '查看可选车型及固定报价',
            ),
            backgroundColor: const Color(0xFF0D9488),
            isLoading: controller.isLoadingVehicles.value,
            onPressed: () async {
              AppHaptics.selection();
              if (controller.originController.text.trim().isEmpty ||
                  controller.destinationController.text.trim().isEmpty) {
                showTravelMessage(
                  context,
                  title: l10nPick(context, en: 'Required Fields', fa: 'فیلدهای الزامی', ar: 'حقول مطلوبة', zh: '必填字段'),
                  message: l10nPick(context, en: 'Please enter origin and destination.', fa: 'لطفاً مبدأ و مقصد را وارد فرمایید.', ar: 'يرجى إدخال نقطة الانطلاق والوجهة.', zh: '请输入出发地和目的地。'),
                );
                return;
              }
              await controller.fetchVehicleEstimates();
              Get.to(() => const TaxiVehiclesScreen());
            },
          )),
        ),
      ),
      child: ListView(
        padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 24.h),
        children: [
          // Hero Trust Signals Banner (Fixed Rates, 60m free wait, flight tracking)
          const TaxiTrustSignalsBanner(),
          SizedBox(height: 16.h),

          // Offline Notice if applicable
          Obx(() {
            if (controller.uiState.value == TaxiUiState.offline) {
              return Container(
                margin: EdgeInsetsDirectional.only(bottom: 12.h),
                padding: EdgeInsetsDirectional.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: Colors.amber, size: 20),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        l10nPick(
                          context,
                          en: 'Offline mode active. Guaranteed regional rates shown.',
                          fa: 'حالت بدون اینترنت فعال است. نرخ‌های استاندارد و تضمین‌شده نمایش داده می‌شوند.',
                          ar: 'وضع عدم الاتصال مفعل. الأسعار القياسية المعروضة.',
                        ),
                        style: TextStyle(fontSize: 11.5.sp, color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Ride Type Selector: Airport vs City vs Intercity
          Obx(() {
            return Row(
              children: [
                Expanded(
                  child: _RideTypeChip(
                    icon: Icons.flight_land_rounded,
                    label: l10nPick(context, en: 'Airport Transfer', fa: 'ترانسفر فرودگاه', ar: 'توصيل المطار', zh: '机场接送'),
                    selected: controller.selectedRideType.value == TaxiRideType.airportTransfer,
                    onTap: () {
                      AppHaptics.selection();
                      controller.selectedRideType.value = TaxiRideType.airportTransfer;
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _RideTypeChip(
                    icon: Icons.location_city_rounded,
                    label: l10nPick(context, en: 'City Chauffeur', fa: 'تاکسی شهری', ar: 'داخل المدينة', zh: '市内出行'),
                    selected: controller.selectedRideType.value == TaxiRideType.cityRide,
                    onTap: () {
                      AppHaptics.selection();
                      controller.selectedRideType.value = TaxiRideType.cityRide;
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _RideTypeChip(
                    icon: Icons.alt_route_rounded,
                    label: l10nPick(context, en: 'Intercity Trip', fa: 'بین شهری', ar: 'بين المدن', zh: '城际专车'),
                    selected: controller.selectedRideType.value == TaxiRideType.intercity,
                    onTap: () {
                      AppHaptics.selection();
                      controller.selectedRideType.value = TaxiRideType.intercity;
                    },
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 16.h),

          // Airport Transfer Direction Selector (Arrival Pickup vs Departure Dropoff)
          Obx(() {
            if (controller.selectedRideType.value == TaxiRideType.airportTransfer) {
              final isArrival = controller.transferDirection.value == AirportTransferDirection.fromAirport;
              return Container(
                margin: EdgeInsetsDirectional.only(bottom: 16.h),
                padding: EdgeInsetsDirectional.all(4.r),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          AppHaptics.selection();
                          controller.transferDirection.value = AirportTransferDirection.fromAirport;
                          controller.originController.text = 'فرودگاه بین‌المللی امام خمینی (IKA) - ترمینال ۱';
                        },
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsetsDirectional.symmetric(vertical: 8.h),
                          decoration: BoxDecoration(
                            color: isArrival ? const Color(0xFF0D9488) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.flight_land_rounded,
                                size: 16.r,
                                color: isArrival ? Colors.white : textSecondary,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                l10nPick(context, en: 'Pickup from Airport', fa: 'استقبال در فرودگاه (ورودی)', ar: 'استقبال من المطار'),
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  fontWeight: isArrival ? FontWeight.w900 : FontWeight.w600,
                                  color: isArrival ? Colors.white : textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          AppHaptics.selection();
                          controller.transferDirection.value = AirportTransferDirection.toAirport;
                          controller.destinationController.text = 'فرودگاه بین‌المللی امام خمینی (IKA) - ترمینال ۱';
                        },
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsetsDirectional.symmetric(vertical: 8.h),
                          decoration: BoxDecoration(
                            color: !isArrival ? const Color(0xFF0D9488) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.flight_takeoff_rounded,
                                size: 16.r,
                                color: !isArrival ? Colors.white : textSecondary,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                l10nPick(context, en: 'Drop-off at Airport', fa: 'بدرقه به فرودگاه (خروجی)', ar: 'توصيل إلى المطار'),
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  fontWeight: !isArrival ? FontWeight.w900 : FontWeight.w600,
                                  color: !isArrival ? Colors.white : textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Route & Schedule Card
          TravelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10nPick(context, en: 'Route & Schedule', fa: 'مسیر و زمان‌بندی ترانسفر', ar: 'المسار والجدول الزمني', zh: '行程与时间'),
                      style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w900, color: textPrimary),
                    ),
                    IconButton(
                      tooltip: l10nPick(context, en: 'Swap Route', fa: 'جابجایی مبدأ و مقصد', ar: 'تبديل المسار'),
                      icon: const Icon(Icons.swap_vert_rounded, color: Color(0xFF0D9488)),
                      onPressed: () {
                        AppHaptics.light();
                        controller.swapRoute();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Pickup Location Input
                TextFormField(
                  controller: controller.originController,
                  decoration: InputDecoration(
                    labelText: l10nPick(context, en: 'Pickup Location', fa: 'مبدأ (محل سوار شدن)', ar: 'نقطة الانطلاق', zh: '出发地上车点'),
                    prefixIcon: const Icon(Icons.trip_origin_rounded, color: Color(0xFF0D9488)),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8.h),

                // Quick Regional Airport & Terminal Shortcuts
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.flight_rounded, size: 14),
                      label: const Text('IKA ترمینال ۱ امام'),
                      onPressed: () {
                        AppHaptics.light();
                        controller.originController.text = 'فرودگاه بین‌المللی امام خمینی (IKA) - ترمینال ۱';
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.stars_rounded, size: 14, color: Colors.amber),
                      label: const Text('IKA سالن تشریفات CIP'),
                      onPressed: () {
                        AppHaptics.light();
                        controller.originController.text = 'فرودگاه امام خمینی - جایگاه اختصاصی تشریفات CIP';
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.local_airport_rounded, size: 14),
                      label: const Text('THR مهرآباد ترمینال ۴ و ۶'),
                      onPressed: () {
                        AppHaptics.light();
                        controller.originController.text = 'فرودگاه مهرآباد، ترمینال ۴ و ۶ (ایران‌ایر و ماهان)';
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.flight_takeoff_rounded, size: 14),
                      label: const Text('DXB دبی ترمینال ۱-۳'),
                      onPressed: () {
                        AppHaptics.light();
                        controller.originController.text = 'Dubai International Airport (DXB) - Terminal 3';
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Destination Location Input
                TextFormField(
                  controller: controller.destinationController,
                  decoration: InputDecoration(
                    labelText: l10nPick(context, en: 'Destination / Drop-off', fa: 'مقصد (محل پیاده شدن)', ar: 'الوجهة / نقطة النزول', zh: '目的地'),
                    prefixIcon: const Icon(Icons.location_on_rounded, color: Colors.red),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 14.h),

                // Date & Time Picker
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Obx(() => CommonSingleDatePicker(
                        initialDate: controller.pickupDate.value,
                        firstDate: DateTime.now(),
                        hintText: l10nPick(context, en: 'Pickup Date', fa: 'تاریخ ترانسفر', ar: 'تاريخ التوصيل', zh: '接送日期'),
                        suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
                        onDateSelected: (d) => controller.pickupDate.value = d,
                      )),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: () async {
                          AppHaptics.selection();
                          final time = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 10, minute: 0),
                          );
                          if (time != null) {
                            controller.pickupTime.value =
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                          }
                        },
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF0D9488)),
                              SizedBox(width: 6.w),
                              Obx(() => Text(
                                controller.pickupTime.value,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Flight Details & Passengers Card
          TravelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(context, en: 'Flight & Travelers Setup', fa: 'اطلاعات پرواز و مسافران', ar: 'تفاصيل الرحلة والركاب', zh: '航班与乘车人'),
                  style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w900, color: textPrimary),
                ),
                SizedBox(height: 12.h),

                // Flight Number input (essential for automatic flight delay monitoring)
                TextFormField(
                  controller: controller.flightNumberController,
                  decoration: InputDecoration(
                    labelText: l10nPick(
                      context,
                      en: 'Flight Number (e.g. W5-115, EK-971)',
                      fa: 'شماره پرواز (جهت رصد خودکار تأخیر، مانند W5-115)',
                      ar: 'رقم الرحلة الجوية (لتتبع التأخير)',
                      zh: '航班号（用于实时跟踪延误，如 EK-971）',
                    ),
                    prefixIcon: const Icon(Icons.flight_rounded, color: Color(0xFF0D9488)),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 14.h),

                // Passenger & Luggage Counters (Fix dark mode bug by using TaxiCounterControl)
                Row(
                  children: [
                    Expanded(
                      child: TaxiCounterControl(
                        icon: Icons.person_rounded,
                        label: l10nPick(context, en: 'Passengers', fa: 'تعداد مسافران', ar: 'الركاب', zh: '乘客人数'),
                        value: controller.passengerCount,
                        min: 1,
                        max: 8,
                        unit: l10nPick(context, en: 'pax', fa: 'نفر', ar: 'ركاب'),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TaxiCounterControl(
                        icon: Icons.luggage_rounded,
                        label: l10nPick(context, en: 'Luggage / Bags', fa: 'تعداد چمدان‌ها', ar: 'الحقائب', zh: '行李数量'),
                        value: controller.luggageCount,
                        min: 0,
                        max: 10,
                        unit: l10nPick(context, en: 'bags', fa: 'چمدان', ar: 'حقائب'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Child Safety Seat Counter
                TaxiCounterControl(
                  icon: Icons.child_friendly_rounded,
                  label: l10nPick(context, en: 'Child Safety Seats (+75,000 IRR each)', fa: 'صندلی ایمنی کودک (+۷۵,۰۰۰ تومان)', ar: 'مقاعد أمان للأطفال'),
                  value: controller.childSeatCount,
                  min: 0,
                  max: 3,
                  unit: l10nPick(context, en: 'seats', fa: 'عدد', ar: 'مقعد'),
                ),
                SizedBox(height: 12.h),

                // Meet & Greet Switch
                Obx(() => SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  activeTrackColor: const Color(0xFF0D9488),
                  title: Text(
                    l10nPick(
                      context,
                      en: 'Meet & Greet (Chauffeur with Name Board)',
                      fa: 'استقبال فرودگاهی (راننده با تابلوی نام شما در گیت خروجی)',
                      ar: 'خدمة الاستقبال في المطار (لوحة الاسم)',
                      zh: '机场举牌接机服务',
                    ),
                    style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700, color: textPrimary),
                  ),
                  subtitle: Text(
                    l10nPick(
                      context,
                      en: 'Chauffeur waits inside the arrival hall with your name board (+150,000 IRR).',
                      fa: 'راننده تشریفات در سالن تحویل بار با تابلوی اختصاصی منتظر شما خواهد بود (+۱۵۰,۰۰۰ تومان).',
                      ar: 'ينتظرك السائق عند بوابة القاعة حاملاً لافتة باسمك.',
                      zh: '专属司机会在出站口手举姓名牌等候您。',
                    ),
                    style: TextStyle(fontSize: 11.sp, color: textSecondary),
                  ),
                  value: controller.meetAndGreet.value,
                  onChanged: (v) {
                    AppHaptics.selection();
                    controller.meetAndGreet.value = v;
                  },
                )),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Quality & Safety Standards Notice
          Container(
            padding: EdgeInsetsDirectional.all(14.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D9488).withValues(alpha: 0.12) : const Color(0xFFF0FDFA),
              borderRadius: TravelTheme.radius,
              border: Border.all(
                color: isDark ? const Color(0xFF0D9488).withValues(alpha: 0.3) : const Color(0xFFCCFBF1),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: Color(0xFF0D9488)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    l10nPick(
                      context,
                      en: 'All vehicles undergo daily hygiene inspection. Sanitized water and air conditioning provided. Fixed rates without surge pricing.',
                      fa: 'تمامی خودروهای ناوگان پیش از اعزام نظافت و ضدعفونی شده و مجهز به سیستم تهویه مطبوع هستند. کرایه قطعی بدون افزایش نرخ بارندگی یا ترافیک.',
                      ar: 'تخضع جميع السيارات لفحص النظافة اليومي مع توفير مياه معقمة وتكييف وأسعار ثابتة بدون زيادة في ساعات الذروة.',
                      zh: '所有车辆均经过严格消杀清洁，配备空调及免费瓶装水，一口价无动态加价。',
                    ),
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: isDark ? const Color(0xFF5EEAD4) : const Color(0xFF115E59),
                      height: 1.4,
                    ),
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

class _RideTypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RideTypeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = TravelTheme.isDark(context);
    final selectedBg = const Color(0xFF0D9488);
    final unselectedBg = isDark ? AppColors.darkSurfaceVariant : Colors.white;
    final unselectedText = TravelTheme.textPrimaryFor(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? selectedBg : unselectedBg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? selectedBg : TravelTheme.borderFor(context),
          ),
          boxShadow: selected ? TravelTheme.shadowFor(context) : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.white : unselectedText, size: 20),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                color: selected ? Colors.white : unselectedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
