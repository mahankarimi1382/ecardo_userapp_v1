import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/app_haptics.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../services/mock_travel_data.dart';
import '../shared/travel_widgets.dart';
import 'taxi_api_service.dart';
import 'taxi_controller.dart';
import 'taxi_models.dart';
import 'taxi_voucher_screen.dart';
import 'taxi_widgets.dart';

/// Passenger & Confirmation Screen for Airport Transfer
/// Collects contact info, validates form, displays fare breakdown, and confirms
/// fixed-rate transfers. Shows live driver assignment tracking.
class TaxiDetailScreen extends StatefulWidget {
  const TaxiDetailScreen({super.key});

  @override
  State<TaxiDetailScreen> createState() => _TaxiDetailScreenState();
}

class _TaxiDetailScreenState extends State<TaxiDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TaxiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<TaxiController>()
        ? Get.find<TaxiController>()
        : Get.put(TaxiController());
  }

  int get totalFare => _controller.calculateTotalFare(_selectedVehicle!);

  TaxiVehicleClass? get _selectedVehicle {
    final v = _controller.selectedVehicle.value ??
        (availableVehicles.isNotEmpty ? availableVehicles.first : null);
    if (v != null) return v;
    return null;
  }

  List<TaxiVehicleClass> get availableVehicles => _controller.availableVehicles;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final textPrimary = ECardoTokens.ink(context);
    final textSecondary = ECardoTokens.inkMuted(context);

    final vehicle = _selectedVehicle;
    if (vehicle == null) {
      return TravelErrorState(
        title: l10nPick(context, en: 'No vehicle selected', fa: 'خودرو انتخاب نشده'),
        message: l10nPick(
          context,
          en: 'Please select a vehicle class from the previous step.',
          fa: 'لطفاً کلاس خودرو را از مرحله قبلی انتخاب کنید.',
        ),
        onRetry: () => Get.back(),
        retryText: l10nPick(context, en: 'Back to Vehicles', fa: 'بازگشت به انتخاب خودرو'),
      );
    }

    final capacityViolation = TaxiApiService.capacityViolationFor(
      vehicle: vehicle,
      passengerCount: _controller.passengerCount.value,
      luggageCount: _controller.luggageCount.value,
    );

    return TravelPage(
      title: l10nPick(
        context,
        en: 'Passenger & Confirmation',
        fa: 'مشخصات مسافر و تأیید نهایی',
        ar: 'بيانات الراكب والتأكيد',
        zh: '乘车人信息与确认',
      ),
      showTravelNavigation: false,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.all(ECardoTokens.space4.r),
          child: Obx(() {
            final isInvalidPhone = !TaxiApiService.isValidIranianMobile(_controller.passengerPhoneController.text.trim());
            final isBlocked = capacityViolation != null || _controller.isQuoteExpired.value;
            final isInactive = isBlocked || isInvalidPhone;

            return CommonButton(
              width: double.infinity,
              text: _controller.isSubmitting.value
                  ? l10nPick(context, en: 'Booking...', fa: 'در حال ثبت...', ar: 'جاري الحجز')
                  : _controller.quoteSource.value == RideDataSource.fallback
                      ? l10nPick(context, en: 'Confirm & Book Transfer', fa: 'تأیید و رزرو قطعی', ar: 'تأكيد وحجز التوصيل')
                      : l10nPick(context, en: 'Pay & Confirm Transfer', fa: 'پرداخت و اتمام رزرو', ar: 'الدفع وتأكيد الحجز'),
              backgroundColor: isInactive
                  ? ECardoTokens.borderStrong(context)
                  : ECardoTokens.brand500(context),
              textColor: ECardoTokens.inkOnBrand,
              isLoading: _controller.isSubmitting.value,
              onPressed: isBlocked
                  ? null
                  : () async {
                      AppHaptics.selection();
                      if (_formKey.currentState?.validate() != true) return;
                      if (capacityViolation != null) {
                        showTravelMessage(
                          context,
                          title: l10nPick(context, en: 'Capacity exceeded', fa: 'ظرفیت غیرکافی'),
                          message: l10nPick(
                            context,
                            en: 'This vehicle cannot fit all passengers and bags.',
                            fa: 'این خودرو نمی‌تواند تمام مسافران و چمدان‌ها را جای دهد.',
                          ),
                        );
                        return;
                      }
                      final booking = await _controller.createBooking();
                      if (booking != null && mounted) {
                        // Start polling for live driver status once booked
                        _controller.startStatusPolling();
                        Get.off(() => TaxiVoucherScreen(booking: booking));
                      }
                    },
            );
          }),
        ),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(
            ECardoTokens.space5.w,
            ECardoTokens.space3.h,
            ECardoTokens.space5.w,
            ECardoTokens.space8.h,
          ),
          children: [
            // Selected Vehicle Banner
            TravelCard(
              color: ECardoTokens.surfaceCard(context),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
              padding: EdgeInsetsDirectional.all(ECardoTokens.space4.r),
              child: Row(
                children: [
                  Container(
                    width: 52.r,
                    height: 52.r,
                    decoration: BoxDecoration(
                      color: ECardoTokens.brand100(context),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
                    ),
                    child: Icon(vehicle.icon, color: ECardoTokens.brand500(context), size: 28.r),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10nPick(context, en: vehicle.titleEn, fa: vehicle.titleFa),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          vehicle.exampleModels,
                          style: TextStyle(fontSize: 11.sp, color: textSecondary),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${formatMockAmount(totalFare)} ${localization.travelMockCurrency}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                            color: ECardoTokens.brand500(context),
                          ),
                        ),
                        if (capacityViolation != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsetsDirectional.only(top: 6.h),
                              child: Container(
                                padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: ECardoTokens.warningBg(context),
                                  borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded, size: 13, color: ECardoTokens.warning(context)),
                                    SizedBox(width: 4.w),
                                    Expanded(
                                      child: Text(
                                        l10nPick(
                                          context,
                                          en: 'Passenger or luggage count exceeds standard capacity.',
                                          fa: 'تعداد مسافر یا بار این خودرو با ظرفیت استاندارد همخوانی ندارد.',
                                        ),
                                        style: TextStyle(fontSize: 10.sp, color: ECardoTokens.warning(context)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ECardoTokens.space4.h),

            // Passenger Contact Details Card
            TravelCard(
              color: ECardoTokens.surfaceCard(context),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
              padding: EdgeInsetsDirectional.all(ECardoTokens.space4.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                        Text(
                          l10nPick(context, en: 'Passenger Information', fa: 'مشخصات سرپرست و مسافر', ar: 'معلومات الراكب', zh: '乘车联系信息'),
                          style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w900, color: textPrimary),
                        ),
                        SizedBox(height: ECardoTokens.space3.h),

                        // Passenger Name
                        TextFormField(
                          controller: _controller.passengerNameController,
                          decoration: InputDecoration(
                            labelText: l10nPick(context, en: 'Full Name', fa: 'نام و نام خانوادگی', ar: 'الاسم الكامل', zh: '姓名'),
                            prefixIcon: Icon(Icons.person_outline_rounded, color: ECardoTokens.brand500(context)),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().length < 3) {
                              return localization.travelFormRequired;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: ECardoTokens.space3.h),

                        // Passenger Phone
                        TextFormField(
                          controller: _controller.passengerPhoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                          ],
                          decoration: InputDecoration(
                            labelText: l10nPick(
                              context,
                              en: 'Mobile Phone (for driver WhatsApp/call)',
                              fa: 'شماره تماس مسافر (جهت هماهنگی راننده)',
                              ar: 'رقم الهاتف للتواصل',
                              zh: '联系电话（用于WhatsApp或电话）',
                            ),
                            prefixIcon: Icon(Icons.phone_rounded, color: ECardoTokens.brand500(context)),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (val) {
                            if (!TaxiApiService.isValidIranianMobile(val ?? '')) {
                              return l10nPick(context, en: 'Invalid mobile format', fa: 'فرمت شماره اشتباه است', ar: 'تنسيق رقم الهاتف غير صحيح');
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: ECardoTokens.space3.h),

                        // Flight Number (optional but encouraged for airport pickups)
                        TextFormField(
                          controller: _controller.flightNumberController,
                          decoration: InputDecoration(
                            labelText: l10nPick(
                              context,
                              en: 'Flight Number (Optional — helps track delays)',
                              fa: 'شماره پرواز (اختیاری — برای رصد تأخیرها مفید است)',
                              ar: 'رقم الرحلة الجوية (اختياري - للمتابعة)',
                              zh: '航班号（选填，有助于跟踪延误）',
                            ),
                            prefixIcon: Icon(Icons.flight_rounded, color: ECardoTokens.brand500(context)),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: ECardoTokens.space3.h),

                        // Notes for driver / special requests
                        TextFormField(
                          controller: _controller.notesController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: l10nPick(
                              context,
                              en: 'Special Requests / Notes for Driver',
                              fa: 'درخواست‌های ویژه / توضیحات برای راننده',
                              ar: 'طلبات خاصة للسائق',
                              zh: '给司机的特殊要求',
                            ),
                            prefixIcon: Icon(Icons.note_alt_outlined, color: ECardoTokens.brand500(context)),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
            SizedBox(height: ECardoTokens.space4.h),

            // Live Tracking Status Bar for Completed/Confirmed rides
            Obx(() {
              final b = _controller.activeBooking.value;
              final operational = b?.operationalStatus;
              if (b == null || operational == null) return const SizedBox.shrink();
              return TaxiLiveDriverCard(
                booking: b,
                onCallDriver: () {
                  AppHaptics.light();
                  // In real app: launch dialer with driver.phone
                },
                onOpenSupport: () {
                  AppHaptics.light();
                  // In real app: open support sheet/ticket flow
                },
              );
            }),

            SizedBox(height: ECardoTokens.space4.h),

            // Fare Breakdown with trust signals about fixed-price guarantee
            TravelCard(
              color: ECardoTokens.surfaceCard(context),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
              padding: EdgeInsetsDirectional.all(ECardoTokens.space4.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(context, en: 'Fare Breakdown', fa: 'ریز محاسبات کرایه', ar: 'تفاصيل الأجرة', zh: '费用明细'),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: textPrimary),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10nPick(context, en: 'Base Vehicle Fare', fa: 'کرایه پایه خودرو', ar: 'الأجرة الأساسية', zh: '车辆基础费'),
                          style: TextStyle(fontSize: 11.5.sp, color: textSecondary),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${formatMockAmount(vehicle.basePrice)} ${localization.travelMockCurrency}',
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: textPrimary),
                      ),
                    ],
                  ),
                  if (_controller.meetAndGreet.value) ...[
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10nPick(context, en: 'Meet & Greet Service', fa: 'خدمات استقبال با تابلو', ar: 'خدمة الاستقبال باللوحة'),
                            style: TextStyle(fontSize: 11.5.sp, color: textSecondary),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '150,000 ${localization.travelMockCurrency}',
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: textPrimary),
                        ),
                      ],
                    ),
                  ],
                  if (_controller.childSeatCount.value > 0) ...[
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10nPick(
                              context,
                              en: 'Child Safety Seats (${_controller.childSeatCount.value} × 75,000 IRR)',
                              fa: 'صندلی ایمنی کودک (${_controller.childSeatCount.value} × ۷۵,۰۰۰ تومان)',
                            ),
                            style: TextStyle(fontSize: 11.5.sp, color: textSecondary),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${formatMockAmount(_controller.childSeatCount.value * TaxiApiService.childSeatFeeIrr)} ${localization.travelMockCurrency}',
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: textPrimary),
                        ),
                      ],
                    ),
                  ],
                  if (_controller.selectedRideType.value == TaxiRideType.intercity) ...[
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: ECardoTokens.sand100(context),
                        borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                      ),
                      child: Text(
                        l10nPick(context, en: '+ Intercity factor applied (60% increase)', fa: '+ عامل بین شهری (افزایش ۶۰٪)', ar: '+ تطبيق عامل بین شهری'),
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: ECardoTokens.sand600(context)),
                      ),
                    ),
                  ],
                  Divider(height: 20, color: ECardoTokens.border(context)),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          localization.travelTotal,
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: textPrimary),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${formatMockAmount(totalFare)} ${localization.travelMockCurrency}',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: ECardoTokens.brand500(context)),
                      ),
                    ],
                  ),
                  Obx(() {
                    if (_controller.quoteSource.value == RideDataSource.network) {
                      return Padding(
                        padding: EdgeInsetsDirectional.only(top: 6.h),
                        child: Row(
                          children: [
                            Icon(Icons.receipt_long_rounded, size: 13, color: ECardoTokens.brand500(context)),
                            SizedBox(width: 4.w),
                            Text(
                              l10nPick(
                                context,
                                en: 'Fixed price confirmed by eCardo engine. No surge pricing.',
                                fa: 'نرخ قطعی توسط موتور قیمت‌گذاری تأیید شده است.',
                                ar: 'سعر مؤكد بدون زيادة.',
                                zh: '固定价格已确认。无动态加价。',
                              ),
                              style: TextStyle(fontSize: 9.5.sp, color: textSecondary),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
