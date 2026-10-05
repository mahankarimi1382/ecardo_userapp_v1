import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_single_date_picker.dart';
import 'package:ecardo_user/src/helper/app_haptics.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../services/travel_service_requests_screen.dart';
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
    final textPrimary = ECardoTokens.ink(context);
    final textSecondary = ECardoTokens.inkMuted(context);
    final border = ECardoTokens.border(context);

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
          padding: EdgeInsetsDirectional.all(ECardoTokens.space4.r),
          child: Obx(() => CommonButton(
            width: double.infinity,
            text: l10nPick(
              context,
              en: 'View Available Vehicles & Rates',
              fa: 'مشاهده خودروها و استعلام نرخ قطعی',
              ar: 'عرض السيارات والأسعار المتاحة',
              zh: '查看可选车型及固定报价',
            ),
            backgroundColor: ECardoTokens.brand500(context),
            textColor: ECardoTokens.inkOnBrand,
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
        padding: EdgeInsetsDirectional.fromSTEB(
          ECardoTokens.space5.w,
          ECardoTokens.space3.h,
          ECardoTokens.space5.w,
          ECardoTokens.space6.h,
        ),
        children: [
          // Hero Trust Signals Banner (Fixed Rates, 60m free wait, flight tracking)
          const TaxiTrustSignalsBanner(),
          SizedBox(height: ECardoTokens.space4.h),

          // Offline Notice if applicable
          Obx(() {
            if (controller.uiState.value == TaxiUiState.offline) {
              return Container(
                margin: EdgeInsetsDirectional.only(bottom: ECardoTokens.space3.h),
                padding: EdgeInsetsDirectional.all(ECardoTokens.space3.r),
                decoration: BoxDecoration(
                  color: ECardoTokens.warningBg(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  border: Border.all(color: ECardoTokens.warning(context).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off_rounded, color: ECardoTokens.warning(context), size: 20.r),
                    SizedBox(width: ECardoTokens.space2.w),
                    Expanded(
                      child: Text(
                        l10nPick(
                          context,
                          en: 'Offline mode active. Guaranteed regional rates shown.',
                          fa: 'حالت بدون اینترنت فعال است. نرخ‌های استاندارد و تضمین‌شده نمایش داده می‌شوند.',
                          ar: 'وضع عدم الاتصال مفعل. الأسعار القياسية المعروضة.',
                        ),
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: ECardoTokens.warning(context),
                        ),
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
                SizedBox(width: ECardoTokens.space2.w),
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
                SizedBox(width: ECardoTokens.space2.w),
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
          SizedBox(height: ECardoTokens.space4.h),

          // Airport Transfer Direction Selector (Arrival Pickup vs Departure Dropoff)
          Obx(() {
            if (controller.selectedRideType.value == TaxiRideType.airportTransfer) {
              final isArrival = controller.transferDirection.value == AirportTransferDirection.fromAirport;
              return Container(
                margin: EdgeInsetsDirectional.only(bottom: ECardoTokens.space4.h),
                padding: EdgeInsetsDirectional.all(ECardoTokens.space1.r),
                decoration: BoxDecoration(
                  color: ECardoTokens.surfaceSunken(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
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
                        borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                        child: Container(
                          padding: EdgeInsetsDirectional.symmetric(horizontal: 6.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: isArrival ? ECardoTokens.brand500(context) : Colors.transparent,
                            borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.flight_land_rounded,
                                size: 16.r,
                                color: isArrival ? ECardoTokens.inkOnBrand : textSecondary,
                              ),
                              SizedBox(width: 6.w),
                              Flexible(
                                child: Text(
                                  l10nPick(context, en: 'Pickup from Airport', fa: 'استقبال در فرودگاه (ورودی)', ar: 'استقبال من المطار', zh: '接机'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: isArrival ? FontWeight.w900 : FontWeight.w600,
                                    color: isArrival ? ECardoTokens.inkOnBrand : textSecondary,
                                  ),
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
                        borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                        child: Container(
                          padding: EdgeInsetsDirectional.symmetric(horizontal: 6.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: !isArrival ? ECardoTokens.brand500(context) : Colors.transparent,
                            borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.flight_takeoff_rounded,
                                size: 16.r,
                                color: !isArrival ? ECardoTokens.inkOnBrand : textSecondary,
                              ),
                              SizedBox(width: 6.w),
                              Flexible(
                                child: Text(
                                  l10nPick(context, en: 'Drop-off at Airport', fa: 'بدرقه به فرودگاه (خروجی)', ar: 'توصيل إلى المطار', zh: '送机'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: !isArrival ? FontWeight.w900 : FontWeight.w600,
                                    color: !isArrival ? ECardoTokens.inkOnBrand : textSecondary,
                                  ),
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
            color: ECardoTokens.surfaceCard(context),
            borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
            padding: EdgeInsetsDirectional.all(ECardoTokens.space4.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l10nPick(context, en: 'Route & Schedule', fa: 'مسیر و زمان‌بندی ترانسفر', ar: 'المسار والجدول الزمني', zh: '行程与时间'),
                        style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w900, color: textPrimary),
                      ),
                    ),
                    IconButton(
                      tooltip: l10nPick(context, en: 'Swap Route', fa: 'جابجایی مبدأ و مقصد', ar: 'تبديل المسار'),
                      icon: Icon(Icons.swap_vert_rounded, color: ECardoTokens.brand500(context)),
                      onPressed: () {
                        AppHaptics.light();
                        controller.swapRoute();
                      },
                    ),
                  ],
                ),
                SizedBox(height: ECardoTokens.space2.h),

                // Pickup Location Input
                TextFormField(
                  controller: controller.originController,
                  decoration: InputDecoration(
                    labelText: l10nPick(context, en: 'Pickup Location', fa: 'مبدأ (محل سوار شدن)', ar: 'نقطة الانطلاق', zh: '出发地上车点'),
                    prefixIcon: Icon(Icons.trip_origin_rounded, color: ECardoTokens.brand500(context)),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: ECardoTokens.space2.h),

                // Quick Regional Airport & Terminal Shortcuts
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: [
                    ActionChip(
                      backgroundColor: ECardoTokens.surfaceSunken(context),
                      side: BorderSide(color: border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusSm)),
                      avatar: const Icon(Icons.flight_rounded, size: 14),
                      label: Text('IKA ترمینال ۱ امام', style: TextStyle(fontSize: 10.5.sp, color: textPrimary)),
                      onPressed: () {
                        AppHaptics.light();
                        controller.originController.text = 'فرودگاه بین‌المللی امام خمینی (IKA) - ترمینال ۱';
                      },
                    ),
                    ActionChip(
                      backgroundColor: ECardoTokens.surfaceSunken(context),
                      side: BorderSide(color: border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusSm)),
                      avatar: Icon(Icons.stars_rounded, size: 14, color: ECardoTokens.sand600(context)),
                      label: Text('IKA سالن تشریفات CIP', style: TextStyle(fontSize: 10.5.sp, color: textPrimary)),
                      onPressed: () {
                        AppHaptics.light();
                        controller.originController.text = 'فرودگاه امام خمینی - جایگاه اختصاصی تشریفات CIP';
                      },
                    ),
                    ActionChip(
                      backgroundColor: ECardoTokens.surfaceSunken(context),
                      side: BorderSide(color: border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusSm)),
                      avatar: const Icon(Icons.local_airport_rounded, size: 14),
                      label: Text('THR مهرآباد ترمینال ۴ و ۶', style: TextStyle(fontSize: 10.5.sp, color: textPrimary)),
                      onPressed: () {
                        AppHaptics.light();
                        controller.originController.text = 'فرودگاه مهرآباد، ترمینال ۴ و ۶ (ایران‌ایر و ماهان)';
                      },
                    ),
                    ActionChip(
                      backgroundColor: ECardoTokens.surfaceSunken(context),
                      side: BorderSide(color: border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusSm)),
                      avatar: const Icon(Icons.flight_takeoff_rounded, size: 14),
                      label: Text('DXB دبی ترمینال ۱-۳', style: TextStyle(fontSize: 10.5.sp, color: textPrimary)),
                      onPressed: () {
                        AppHaptics.light();
                        controller.originController.text = 'Dubai International Airport (DXB) - Terminal 3';
                      },
                    ),
                  ],
                ),
                SizedBox(height: ECardoTokens.space3.h),

                // Destination Location Input
                TextFormField(
                  controller: controller.destinationController,
                  decoration: InputDecoration(
                    labelText: l10nPick(context, en: 'Destination / Drop-off', fa: 'مقصد (محل پیاده شدن)', ar: 'الوجهة / نقطة النزول', zh: '目的地'),
                    prefixIcon: Icon(Icons.location_on_rounded, color: ECardoTokens.danger(context)),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: ECardoTokens.space3.h + 2.h),

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
                    SizedBox(width: ECardoTokens.space2.w),
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
                        borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                        child: Container(
                          padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: ECardoTokens.surfaceSunken(context),
                            borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 18.r, color: ECardoTokens.brand500(context)),
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
          SizedBox(height: ECardoTokens.space4.h),

          // Flight Details & Passengers Card
          TravelCard(
            color: ECardoTokens.surfaceCard(context),
            borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
            padding: EdgeInsetsDirectional.all(ECardoTokens.space4.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(context, en: 'Flight & Travelers Setup', fa: 'اطلاعات پرواز و مسافران', ar: 'تفاصيل الرحلة والركاب', zh: '航班与乘车人'),
                  style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w900, color: textPrimary),
                ),
                SizedBox(height: ECardoTokens.space3.h),

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
                    prefixIcon: Icon(Icons.flight_rounded, color: ECardoTokens.brand500(context)),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: ECardoTokens.space3.h + 2.h),

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
                SizedBox(height: ECardoTokens.space3.h),

                // Meet & Greet Switch
                Obx(() => SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  activeTrackColor: ECardoTokens.brand500(context),
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
          SizedBox(height: ECardoTokens.space4.h),

          // Quality & Safety Standards Notice
          Container(
            padding: EdgeInsetsDirectional.all(ECardoTokens.space4.r),
            decoration: BoxDecoration(
              color: ECardoTokens.brand100(context),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
              border: Border.all(
                color: ECardoTokens.brand500(context).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_user_rounded, color: ECardoTokens.brand500(context)),
                SizedBox(width: ECardoTokens.space3.w),
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
                      color: ECardoTokens.isDark(context)
                          ? ECardoTokens.brand500(context)
                          : ECardoTokens.brand700(context),
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
    final selectedBg = ECardoTokens.brand500(context);
    final unselectedBg = ECardoTokens.surfaceCard(context);
    final unselectedText = ECardoTokens.ink(context);
    final border = ECardoTokens.border(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? selectedBg : unselectedBg,
          borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
          border: Border.all(
            color: selected ? selectedBg : border,
          ),
          boxShadow: selected ? ECardoTokens.shadowCard(context) : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? ECardoTokens.inkOnBrand : unselectedText, size: 20),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                color: selected ? ECardoTokens.inkOnBrand : unselectedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
