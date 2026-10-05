import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/app_haptics.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../services/mock_travel_data.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';
import 'taxi_api_service.dart';
import 'taxi_controller.dart';
import 'taxi_detail_screen.dart';
import 'taxi_models.dart';
import 'taxi_widgets.dart';

/// Vehicle class selection with fixed-price quotes from `POST /ride/quote`.
/// Renders Loading/Skeleton, Empty, Error, Expired, Partial and Offline states.
class TaxiVehiclesScreen extends StatefulWidget {
  const TaxiVehiclesScreen({super.key});

  @override
  State<TaxiVehiclesScreen> createState() => _TaxiVehiclesScreenState();
}

class _TaxiVehiclesScreenState extends State<TaxiVehiclesScreen> {
  late final TaxiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<TaxiController>()
        ? Get.find<TaxiController>()
        : Get.put(TaxiController());
    // Guarantee a quote exists even when this screen is opened directly.
    if (!_controller.hasQuote && !_controller.isLoadingVehicles.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.fetchVehicleEstimates();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = TravelTheme.isDark(context);
    final textPrimary = TravelTheme.textPrimaryFor(context);
    final textSecondary = TravelTheme.textSecondaryFor(context);

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
            final vehicle = _controller.selectedVehicle.value;
            final fare = vehicle != null ? _controller.calculateTotalFare(vehicle) : 0;
            final expired = _controller.isQuoteExpired.value;
            return Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.travelTotal,
                        style: TextStyle(fontSize: 11.sp, color: textSecondary),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${formatMockAmount(fare)} ${localization.travelMockCurrency}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                color: expired ? Colors.red : const Color(0xFF0D9488),
                              ),
                            ),
                          ),
                          if (vehicle != null && !expired) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsetsDirectional.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                l10nPick(context, en: 'FIXED', fa: 'قطعی', ar: 'ثابت'),
                                style: TextStyle(
                                  fontSize: 8.5.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0D9488),
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 14.w),
                SizedBox(
                  width: 160.w,
                  child: CommonButton(
                    text: expired
                        ? l10nPick(context, en: 'Refresh Price', fa: 'استعلام مجدد', ar: 'تحديث السعر')
                        : l10nPick(context, en: 'Confirm Vehicle', fa: 'تأیید خودرو و ادامه', ar: 'تأكيد ومتابعة', zh: '确认车型并继续'),
                    textColor: Colors.white,
                    backgroundColor: expired ? Colors.orange.shade700 : const Color(0xFF0D9488),
                    onPressed: () {
                      AppHaptics.selection();
                      if (expired) {
                        _controller.fetchVehicleEstimates();
                        return;
                      }
                      Get.to(() => const TaxiDetailScreen());
                    },
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
          // Route Summary Card (theme-aware)
          TravelCard(
            color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF0FDFA),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l10nPick(context, en: 'Trip Summary', fa: 'خلاصه مسیر ترانسفر', ar: 'ملخص الرحلة', zh: '行程摘要'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w900,
                          color: isDark ? const Color(0xFF5EEAD4) : const Color(0xFF0F766E),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${DateFormat('yyyy-MM-dd').format(_controller.pickupDate.value)} · ${_controller.pickupTime.value}',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    const Icon(Icons.trip_origin_rounded, size: 16, color: Color(0xFF0D9488)),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TravelBidiText(
                        _controller.originController.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: textPrimary),
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
                      child: TravelBidiText(
                        _controller.destinationController.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: textPrimary),
                      ),
                    ),
                  ],
                ),
                Obx(() {
                  final q = _controller.quote.value;
                  if (q == null) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsetsDirectional.only(top: 8.h),
                    child: Wrap(
                      spacing: 10.w,
                      runSpacing: 4.h,
                      children: [
                        _SummaryPill(
                          icon: Icons.route_rounded,
                          text: '${q.distanceKm.toStringAsFixed(1)} km',
                        ),
                        _SummaryPill(
                          icon: Icons.timelapse_rounded,
                          text: '~${q.durationMinutes} min',
                        ),
                        _SummaryPill(
                          icon: Icons.groups_rounded,
                          text: '${_controller.passengerCount.value} ${l10nPick(context, en: 'pax', fa: 'نفر')}'
                              ' · ${_controller.luggageCount.value} ${l10nPick(context, en: 'bags', fa: 'چمدان')}',
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // Data-source notice: Partial (fallback quote) vs Expired vs Unauthorized
          Obx(() => _SourceNotice(state: _controller.uiState.value)),

          // Section title
          Text(
            l10nPick(context, en: 'Available Vehicle Options', fa: 'ناوگان در دسترس', ar: 'الخيارات المتاحة', zh: '可选车型列表'),
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: textPrimary),
          ),
          SizedBox(height: 12.h),

          // Vehicle list with full state coverage
          Obx(() {
            final state = _controller.uiState.value;

            if (state == TaxiUiState.loading || state == TaxiUiState.skeleton) {
              return const TravelShimmerLoading(type: TravelShimmerType.list, count: 3);
            }

            if (state == TaxiUiState.unauthorized) {
              return TravelEmptyState(
                icon: Icons.lock_outline_rounded,
                title: l10nPick(context, en: 'Sign-in required', fa: 'نیاز به ورود کاربر'),
                message: l10nPick(
                  context,
                  en: 'Please log in to fetch live fixed rates for your route.',
                  fa: 'برای استعلام نرخ زوایر و قطعی فرودگاهی لطفاً وارد حساب خود شوید.',
                ),
                actionText: l10nPick(context, en: 'Retry', fa: 'تلاش مجدد'),
                onAction: _controller.loadCatalog,
              );
            }

            if (state == TaxiUiState.error) {
              return TravelErrorState(
                title: l10nPick(context, en: 'Rate enquiry failed', fa: 'خطا در استعلام کرایه'),
                message: _controller.errorMessage.value ?? 'unavailable',
                onRetry: _controller.fetchVehicleEstimates,
                retryText: l10nPick(context, en: 'Try Again', fa: 'تلاش دوباره'),
              );
            }

            if (state == TaxiUiState.empty || _controller.availableVehicles.isEmpty) {
              return TravelEmptyState(
                icon: Icons.directions_car_filled_rounded,
                title: l10nPick(context, en: 'No vehicles available', fa: 'هیچ خودروای موجود نیست'),
                message: l10nPick(
                  context,
                  en: 'Our fleet is fully booked for this time window. Try a different pickup hour.',
                  fa: 'ناوگان تشریفات در این بازه زمانی تکمیل ظرفیت است. ساعت دیگری را امتحان فرمایید.',
                ),
                actionText: l10nPick(context, en: 'Change Time', fa: 'تغییر زمان'),
                onAction: () => Get.back(),
              );
            }

            final quotesByVehicle = <String, RideVehicleQuote>{};
            for (final entry in _controller.quote.value?.vehicleQuotes ?? const <RideVehicleQuote>[]) {
              quotesByVehicle[entry.vehicleClass.id] = entry;
            }

            return Column(
              children: _controller.availableVehicles.map((vehicle) {
                final entry = quotesByVehicle[vehicle.id];
                final unavailable = _controller.isVehicleUnavailable(vehicle);
                return Opacity(
                  opacity: unavailable ? 0.55 : 1,
                  child: TaxiVehicleCard(
                    vehicle: vehicle,
                    totalFare: entry?.totalFare ?? _controller.calculateTotalFare(vehicle),
                    isSelected: _controller.selectedVehicle.value?.id == vehicle.id,
                    passengerCount: _controller.passengerCount.value,
                    luggageCount: _controller.luggageCount.value,
                    onTap: () {
                      if (unavailable) {
                        showTravelMessage(
                          context,
                          title: l10nPick(context, en: 'Capacity exceeded', fa: 'ظرفت غیرکافی'),
                          message: l10nPick(
                            context,
                            en: '${vehicle.titleEn} seats ${vehicle.maxPassengers} pax and ${vehicle.maxLuggage} bags.',
                            fa: 'ظرفیت این خودرو ${vehicle.maxPassengers} مسافر و ${vehicle.maxLuggage} چمدان است.',
                          ),
                        );
                        return;
                      }
                      _controller.selectedVehicle.value = vehicle;
                    },
                  ),
                );
              }).toList(),
            );
          }),

          // Fare rules explainer (builds trust in the fixed price)
          SizedBox(height: 8.h),
          Obx(() {
            final source = _controller.quoteSource.value;
            if (source != RideDataSource.network) return const SizedBox.shrink();
            return Container(
              padding: EdgeInsetsDirectional.all(12.r),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: isDark ? 0.12 : 0.08),
                borderRadius: TravelTheme.radius,
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: Colors.green, size: 20),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      l10nPick(
                        context,
                        en: 'Prices confirmed by eCardo ride engine. Tolls, parking and waiting beyond 60 min are settled by the chauffeur on arrival.',
                        fa: 'مبلغ نهایی توسط موتور قیمت‌گذاری ترانسفر تأیید شده است. عوارض و پارکینگ و انتظار مازاد بر ۶۰ دقیقه در محل تسویه می‌شود.',
                      ),
                      style: TextStyle(fontSize: 10.5.sp, color: isDark ? Colors.green.shade200 : Colors.green.shade900, height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SummaryPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.r, color: const Color(0xFF0D9488)),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w700,
            color: TravelTheme.textSecondaryFor(context),
          ),
        ),
      ],
    );
  }
}

/// Explains degraded states honestly instead of pretending success.
class _SourceNotice extends StatelessWidget {
  final TaxiUiState state;

  const _SourceNotice({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = TravelTheme.isDark(context);
    if (state == TaxiUiState.partial) {
      return _NoticeTile(
        icon: Icons.cloud_off_rounded,
        color: Colors.orange,
        message: l10nPick(
          context,
          en: 'Live rate engine unreachable — indicative fixed prices shown. Final price is confirmed at booking.',
          fa: 'استعلام برخط در دسترس نیست — نرخ‌های تقریبی نمایش داده می‌شود. مبلغ نهایی هنگام ثبت رزرو قطعی می‌گردد.',
        ),
      );
    }
    if (state == TaxiUiState.offline) {
      return _NoticeTile(
        icon: Icons.wifi_off_rounded,
        color: Colors.amber,
        message: l10nPick(
          context,
          en: 'You are offline. Cached regional fixed rates are displayed.',
          fa: 'اتصال اینترنت قطع است. نرخ‌های ذخیره‌شده منطقه‌ای نمایش داده می‌شود.',
        ),
      );
    }
    if (state == TaxiUiState.expired) {
      return _NoticeTile(
        icon: Icons.timer_off_rounded,
        color: Colors.red,
        message: l10nPick(
          context,
          en: 'This quote expired (15 min validity). Refresh to lock a new fixed price.',
          fa: 'اعتبار این استعلام ۱۵ دقیقه‌ای به پایان رسید. برای نرخ قطعی جدید استعلام را تازه کنید.',
        ),
        isDark: isDark,
      );
    }
    if (state == TaxiUiState.validationError) {
      return _NoticeTile(
        icon: Icons.error_outline_rounded,
        color: Colors.red,
        message: l10nPick(
          context,
          en: 'Origin and destination are both required to price a transfer.',
          fa: 'برای محاسبه کرایه، وارد کردن مبدأ و مقصد الزامی است.',
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _NoticeTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;
  final bool isDark;

  const _NoticeTile({
    required this.icon,
    required this.color,
    required this.message,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 12.h),
      child: Container(
        padding: EdgeInsetsDirectional.all(12.r),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 11.sp,
                  height: 1.4,
                  color: isDark ? Colors.white70 : TravelTheme.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
