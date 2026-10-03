import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../services/mock_travel_data.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';
import 'taxi_controller.dart';
import 'taxi_detail_screen.dart';

class TaxiVehiclesScreen extends StatelessWidget {
  const TaxiVehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TaxiController>();
    final localization = AppLocalizations.of(context)!;

    return TravelPage(
      title: l10nPick(
        context,
        en: 'Choose Vehicle Class',
        fa: 'انتخاب کلاس خودرو',
        ar: 'اختر فئة السيارة',
        zh: '选择车辆等级',
      ),
      showTravelNavigation: false,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.all(16.r),
          child: Obx(() {
            final vehicle = controller.selectedVehicle.value;
            final fare = vehicle != null ? controller.calculateTotalFare(vehicle) : 0;
            return Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.travelTotal,
                        style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${formatMockAmount(fare)} ${localization.travelMockCurrency}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0D9488),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 14.w),
                SizedBox(
                  width: 160.w,
                  child: CommonButton(
                    text: l10nPick(
                      context,
                      en: 'Confirm Vehicle',
                      fa: 'تأیید خودرو و ادامه',
                      ar: 'تأكيد ومتابعة',
                      zh: '确认车型并继续',
                    ),
                    textColor: Colors.white,
                    backgroundColor: const Color(0xFF0D9488),
                    onPressed: () => Get.to(() => const TaxiDetailScreen()),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
      child: ListView(
        padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 30.h),
        children: [
          // Route Summary Card
          TravelCard(
            color: const Color(0xFFF0FDFA),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10nPick(context, en: 'Trip Summary', fa: 'خلاصه مسیر ترانسفر', ar: 'ملخص الرحلة', zh: '行程摘要'),
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F766E)),
                    ),
                    Text(
                      '${DateFormat('yyyy-MM-dd').format(controller.pickupDate.value)} · ${controller.pickupTime.value}',
                      style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    const Icon(Icons.trip_origin_rounded, size: 16, color: Color(0xFF0D9488)),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        controller.originController.text,
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 16, color: Colors.red),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        controller.destinationController.text,
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Section Title
          Text(
            l10nPick(context, en: 'Available Vehicle Options', fa: 'ناوگان در دسترس', ar: 'الخيارات المتاحة', zh: '可选车型列表'),
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: TravelTheme.ink),
          ),
          SizedBox(height: 12.h),

          // Vehicle List
          Obx(() {
            return Column(
              children: controller.availableVehicles.map((vehicle) {
                final isSelected = controller.selectedVehicle.value?.id == vehicle.id;
                final fare = controller.calculateTotalFare(vehicle);

                return Padding(
                  padding: EdgeInsetsDirectional.only(bottom: 12.h),
                  child: InkWell(
                    onTap: () => controller.selectedVehicle.value = vehicle,
                    borderRadius: TravelTheme.radius,
                    child: Container(
                      padding: EdgeInsetsDirectional.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: TravelTheme.radius,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0D9488) : TravelTheme.border,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected ? TravelTheme.shadow : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48.r,
                                height: 48.r,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF0D9488).withValues(alpha: 0.15)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                child: Icon(
                                  vehicle.icon,
                                  color: isSelected ? const Color(0xFF0D9488) : TravelTheme.muted,
                                  size: 26,
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
                                            color: TravelTheme.ink,
                                          ),
                                        ),
                                        Text(
                                          '${formatMockAmount(fare)} ${localization.travelMockCurrency}',
                                          style: TextStyle(
                                            fontSize: 13.5.sp,
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFF0D9488),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      vehicle.exampleModels,
                                      style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
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
                                  const Icon(Icons.people_alt_rounded, size: 16, color: TravelTheme.muted),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${vehicle.maxPassengers} ${l10nPick(context, en: 'pax', fa: 'نفر', ar: 'ركاب', zh: '人')}',
                                    style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
                                  ),
                                ],
                              ),
                              SizedBox(width: 14.w),
                              Row(
                                children: [
                                  const Icon(Icons.luggage_rounded, size: 16, color: TravelTheme.muted),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${vehicle.maxLuggage} ${l10nPick(context, en: 'bags', fa: 'چمدان', ar: 'حقائب', zh: '件行李')}',
                                    style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              if (isSelected)
                                Container(
                                  padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 3.h),
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
                                        style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          if (vehicle.features.isNotEmpty) ...[
                            SizedBox(height: 10.h),
                            Wrap(
                              spacing: 6.w,
                              children: vehicle.features.map((f) => Chip(
                                label: Text(f, style: TextStyle(fontSize: 9.5.sp)),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              )).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
