import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_single_date_picker.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../services/travel_service_requests_screen.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';
import 'taxi_controller.dart';
import 'taxi_models.dart';
import 'taxi_vehicles_screen.dart';

class TaxiSearchScreen extends StatelessWidget {
  const TaxiSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TaxiController());
    final localization = AppLocalizations.of(context)!;

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
          child: CommonButton(
            width: double.infinity,
            text: l10nPick(
              context,
              en: 'View Available Vehicles',
              fa: 'مشاهده خودروها و استعلام کرایه',
              ar: 'عرض السيارات والأسعار المتاحة',
              zh: '查看可选车型及报价',
            ),
            backgroundColor: const Color(0xFF0D9488),
            onPressed: () {
              if (controller.originController.text.trim().isEmpty ||
                  controller.destinationController.text.trim().isEmpty) {
                showTravelMessage(
                  context,
                  title: l10nPick(context, en: 'Required Fields', fa: 'فیلدهای الزامی', ar: 'حقول مطلوبة', zh: '必填字段'),
                  message: l10nPick(context, en: 'Please enter origin and destination.', fa: 'لطفاً مبدأ و مقصد را وارد فرمایید.', ar: 'يرجى إدخال نقطة الانطلاق والوجهة.', zh: '请输入出发地和目的地。'),
                );
                return;
              }
              Get.to(() => const TaxiVehiclesScreen());
            },
          ),
        ),
      ),
      child: ListView(
        padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 24.h),
        children: [
          // Hero Banner
          Container(
            padding: EdgeInsetsDirectional.all(20.r),
            decoration: BoxDecoration(
              borderRadius: TravelTheme.radius,
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
              boxShadow: TravelTheme.shadow,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: 'Comfortable & Punctual Transfers',
                          fa: 'ترانسفر امن و به موقع فرودگاهی',
                          ar: 'خدمة نقل مريحة ودقيقة في المواعيد',
                          zh: '准时、安全、舒适的专属接送',
                        ),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Fixed rates, verified chauffeurs, and free 60-minute flight delay waiting.',
                          fa: 'کرایه ثابت بدون نوسان، رانندگان مجرب تشریفات و ۶۰ دقیقه انتظار رایگان تأخیر پرواز.',
                          ar: 'أسعار ثابتة وسائقون محترفون وانتظار مجاني لمدة ٦٠ دقيقة عند تأخر الرحلة.',
                          zh: '全天一口价，无隐形费用，航班延误享60分钟免费等待。',
                        ),
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.local_taxi_rounded,
                  size: 56.r,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Ride Type Selector
          Obx(() {
            return Row(
              children: [
                Expanded(
                  child: _RideTypeChip(
                    icon: Icons.flight_land_rounded,
                    label: l10nPick(context, en: 'Airport', fa: 'فرودگاهی', ar: 'مطار', zh: '机场接送'),
                    selected: controller.selectedRideType.value == TaxiRideType.airportTransfer,
                    onTap: () => controller.selectedRideType.value = TaxiRideType.airportTransfer,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _RideTypeChip(
                    icon: Icons.location_city_rounded,
                    label: l10nPick(context, en: 'City Ride', fa: 'شهری', ar: 'داخل المدينة', zh: '市内出行'),
                    selected: controller.selectedRideType.value == TaxiRideType.cityRide,
                    onTap: () => controller.selectedRideType.value = TaxiRideType.cityRide,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _RideTypeChip(
                    icon: Icons.alt_route_rounded,
                    label: l10nPick(context, en: 'Intercity', fa: 'بین شهری', ar: 'بين المدن', zh: '城际专车'),
                    selected: controller.selectedRideType.value == TaxiRideType.intercity,
                    onTap: () => controller.selectedRideType.value = TaxiRideType.intercity,
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 16.h),

          // Route Card
          TravelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(context, en: 'Route & Schedule', fa: 'مسیر و زمان‌بندی', ar: 'المسار والجدول الزمني', zh: '行程与时间'),
                  style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w900, color: TravelTheme.ink),
                ),
                SizedBox(height: 12.h),

                // Origin
                TextFormField(
                  controller: controller.originController,
                  decoration: InputDecoration(
                    labelText: l10nPick(context, en: 'Pickup Location', fa: 'مبدأ (محل سوار شدن)', ar: 'نقطة الانطلاق', zh: '出发地上车点'),
                    prefixIcon: const Icon(Icons.trip_origin_rounded, color: Color(0xFF0D9488)),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 6.h),

                // Quick Airport Shortcuts
                Wrap(
                  spacing: 6.w,
                  children: [
                    ActionChip(
                      label: const Text('IKA فرودگاه امام'),
                      onPressed: () => controller.originController.text = 'فرودگاه بین‌المللی امام خمینی (IKA)',
                    ),
                    ActionChip(
                      label: const Text('THR فرودگاه مهرآباد'),
                      onPressed: () => controller.originController.text = 'فرودگاه مهرآباد، ترمینال ۴ و ۶',
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Destination
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
                            border: Border.all(color: TravelTheme.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF0D9488)),
                              SizedBox(width: 6.w),
                              Obx(() => Text(
                                controller.pickupTime.value,
                                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
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

          // Flight Details & Travelers Card
          TravelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(context, en: 'Flight & Passengers', fa: 'اطلاعات پرواز و مسافران', ar: 'تفاصيل الرحلة والركاب', zh: '航班与乘车人'),
                  style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w900, color: TravelTheme.ink),
                ),
                SizedBox(height: 12.h),

                // Flight Number
                TextFormField(
                  controller: controller.flightNumberController,
                  decoration: InputDecoration(
                    labelText: l10nPick(context, en: 'Flight Number (Optional for airport arrival)', fa: 'شماره پرواز (اختیاری جهت رصد تأخیر)', ar: 'رقم الرحلة الجوية', zh: '航班号（可选，用于跟踪延误）'),
                    prefixIcon: const Icon(Icons.flight_rounded, color: TravelTheme.blue),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 14.h),

                // Passenger & Luggage Counters
                Row(
                  children: [
                    Expanded(
                      child: _CounterTile(
                        icon: Icons.person_rounded,
                        label: l10nPick(context, en: 'Passengers', fa: 'تعداد مسافران', ar: 'الركاب', zh: '乘客人数'),
                        value: controller.passengerCount,
                        min: 1,
                        max: 8,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _CounterTile(
                        icon: Icons.luggage_rounded,
                        label: l10nPick(context, en: 'Luggage / Bags', fa: 'تعداد چمدان‌ها', ar: 'الحقائب', zh: '行李数量'),
                        value: controller.luggageCount,
                        min: 0,
                        max: 10,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),

                // Meet & Greet Switch
                Obx(() => SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  activeColor: const Color(0xFF0D9488),
                  title: Text(
                    l10nPick(
                      context,
                      en: 'Meet & Greet (Driver with Name Board)',
                      fa: 'استقبال فرودگاهی (راننده با تابلوی نام شما)',
                      ar: 'خدمة الاستقبال في المطار (لوحة الاسم)',
                      zh: '机场举牌接机服务',
                    ),
                    style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    l10nPick(
                      context,
                      en: 'The chauffeur meets you at the arrival hall gate.',
                      fa: 'راننده در سالن خروجی با تابلو منتظر شما خواهد بود (+۱۵۰,۰۰۰ تومان).',
                      ar: 'ينتظرك السائق عند بوابة القاعة حاملاً لافتة باسمك.',
                      zh: '专属司机会在出站口手举姓名牌等候您。',
                    ),
                    style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
                  ),
                  value: controller.meetAndGreet.value,
                  onChanged: (v) => controller.meetAndGreet.value = v,
                )),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Quality Standards Notice
          Container(
            padding: EdgeInsetsDirectional.all(14.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: TravelTheme.radius,
              border: Border.all(color: const Color(0xFFCCFBF1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: Color(0xFF0D9488)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    l10nPick(
                      context,
                      en: 'All vehicles undergo daily hygiene inspection. Sanitized water and air conditioning provided.',
                      fa: 'تمامی خودروهای ناوگان پیش از اعزام نظافت و ضدعفونی شده و مجهز به سیستم تهویه مطبوع هستند.',
                      ar: 'تخضع جميع السيارات لفحص النظافة اليومي مع توفير مياه معقمة وتكييف.',
                      zh: '所有车辆均经过严格消杀清洁，配备空调及免费瓶装水。',
                    ),
                    style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF115E59), height: 1.4),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0D9488) : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? const Color(0xFF0D9488) : TravelTheme.border,
          ),
          boxShadow: selected ? TravelTheme.shadow : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.white : TravelTheme.ink, size: 20),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                color: selected ? Colors.white : TravelTheme.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final RxInt value;
  final int min;
  final int max;

  const _CounterTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: TravelTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: TravelTheme.muted),
              SizedBox(width: 4.w),
              Text(label, style: TextStyle(fontSize: 10.5.sp, color: TravelTheme.muted)),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  if (value.value > min) value.value--;
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.remove, size: 16),
                ),
              ),
              Obx(() => Text(
                '${value.value}',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900),
              )),
              InkWell(
                onTap: () {
                  if (value.value < max) value.value++;
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.add, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
