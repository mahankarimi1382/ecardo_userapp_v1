import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../services/mock_travel_data.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';
import 'taxi_controller.dart';
import 'taxi_voucher_screen.dart';

class TaxiDetailScreen extends StatefulWidget {
  const TaxiDetailScreen({super.key});

  @override
  State<TaxiDetailScreen> createState() => _TaxiDetailScreenState();
}

class _TaxiDetailScreenState extends State<TaxiDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TaxiController>();
    final localization = AppLocalizations.of(context)!;
    final vehicle = controller.selectedVehicle.value ?? TaxiController.defaultVehicles.first;
    final totalFare = controller.calculateTotalFare(vehicle);

    return TravelPage(
      title: l10nPick(
        context,
        en: 'Passenger & Confirmation',
        fa: 'اطلاعات مسافر و تأیید نهایی',
        ar: 'بيانات الراكب والتأكيد',
        zh: '乘车人信息与确认',
      ),
      showTravelNavigation: false,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.all(16.r),
          child: Obx(() => CommonButton(
            width: double.infinity,
            text: l10nPick(
              context,
              en: 'Confirm & Book Transfer',
              fa: 'تأیید نهایی و رزرو ترانسفر',
              ar: 'تأكيد وحجز التوصيل',
              zh: '确认并预订接送服务',
            ),
            backgroundColor: const Color(0xFF0D9488),
            isLoading: controller.isSubmitting.value,
            onPressed: () async {
              if (_formKey.currentState?.validate() != true) return;
              final booking = await controller.createBooking();
              if (booking != null) {
                Get.off(() => TaxiVoucherScreen(booking: booking));
              }
            },
          )),
        ),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 30.h),
          children: [
            // Selected Vehicle Banner
            TravelCard(
              color: const Color(0xFFF0FDFA),
              child: Row(
                children: [
                  Container(
                    width: 52.r,
                    height: 52.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(vehicle.icon, color: const Color(0xFF0D9488), size: 28),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10nPick(context, en: vehicle.titleEn, fa: vehicle.titleFa),
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: TravelTheme.ink),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          vehicle.exampleModels,
                          style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
                        ),
                      ],
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
            ),
            SizedBox(height: 16.h),

            // Passenger Contact Details Card
            TravelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(context, en: 'Passenger Information', fa: 'مشخصات سرپرست و مسافر', ar: 'معلومات الراكب', zh: '乘车人联系信息'),
                    style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w900, color: TravelTheme.ink),
                  ),
                  SizedBox(height: 12.h),

                  // Passenger Name
                  TextFormField(
                    controller: controller.passengerNameController,
                    decoration: InputDecoration(
                      labelText: l10nPick(context, en: 'Full Name', fa: 'نام و نام خانوادگی', ar: 'الاسم الكامل', zh: '姓名'),
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return localization.travelFormRequired;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),

                  // Passenger Phone
                  TextFormField(
                    controller: controller.passengerPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: l10nPick(context, en: 'Mobile Phone (for driver WhatsApp/call)', fa: 'شماره تماس مسافر (جهت هماهنگی راننده)', ar: 'رقم الهاتف للتواصل', zh: '联系电话'),
                      prefixIcon: const Icon(Icons.phone_rounded),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return localization.travelFormRequired;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),

                  // Flight Number
                  TextFormField(
                    controller: controller.flightNumberController,
                    decoration: InputDecoration(
                      labelText: l10nPick(context, en: 'Flight Number', fa: 'شماره پرواز (اختیاری)', ar: 'رقم الرحلة الجوية', zh: '航班号（选填）'),
                      prefixIcon: const Icon(Icons.flight_rounded),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Notes for driver
                  TextFormField(
                    controller: controller.notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: l10nPick(context, en: 'Special Requests / Notes for Driver', fa: 'توضیحات و نیازمندی‌های خاص برای راننده', ar: 'ملاحظات خاصة للسائق', zh: '给司机的留言或特殊要求'),
                      prefixIcon: const Icon(Icons.note_alt_outlined),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Free Waiting Time Guarantee Card
            Container(
              padding: EdgeInsetsDirectional.all(14.r),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: TravelTheme.radius,
                border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_bottom_rounded, color: Colors.green),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10nPick(
                            context,
                            en: 'Free 60-Minute Flight Delay Waiting',
                            fa: '۶۰ دقیقه انتظار رایگان در صورت تأخیر پرواز',
                            ar: 'انتظار مجاني ٦٠ دقيقة في حال تأخر الطائرة',
                            zh: '航班延误享60分钟免费等待保障',
                          ),
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.sp, color: Colors.green.shade900),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          l10nPick(
                            context,
                            en: 'Our operations team tracks your flight in real time.',
                            fa: 'تیم پشتیبانی ترانسفر پرواز شما را به صورت زنده رصد می‌کند.',
                            ar: 'فريق العمليات يتابع حركة طائرتك مباشرة.',
                            zh: '运营调度团队实时跟踪航班动态，无需担心延误。',
                          ),
                          style: TextStyle(fontSize: 11.sp, color: Colors.green.shade800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Fare Breakdown
            TravelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(context, en: 'Fare Breakdown', fa: 'ریز محاسبات کرایه', ar: 'تفاصيل الأجرة', zh: '费用明细'),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: TravelTheme.ink),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10nPick(context, en: 'Base Vehicle Fare', fa: 'کرایه پایه خودرو', ar: 'الأجرة الأساسية', zh: '车辆基础费'),
                        style: TextStyle(fontSize: 11.5.sp, color: TravelTheme.muted)),
                      Text('${formatMockAmount(vehicle.basePrice)} ${localization.travelMockCurrency}',
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  if (controller.meetAndGreet.value) ...[
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10nPick(context, en: 'Meet & Greet Service', fa: 'خدمات استقبال با تابلو', ar: 'خدمة الاستقبال باللوحة', zh: '举牌接机服务费'),
                          style: TextStyle(fontSize: 11.5.sp, color: TravelTheme.muted)),
                        Text('150,000 ${localization.travelMockCurrency}',
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(localization.travelTotal,
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: TravelTheme.ink)),
                      Text('${formatMockAmount(totalFare)} ${localization.travelMockCurrency}',
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0D9488))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
