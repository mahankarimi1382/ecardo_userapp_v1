import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/boat_controller.dart';
import '../models/boat_models.dart';
import 'boat_voucher_screen.dart';

class BoatDetailScreen extends StatefulWidget {
  final BoatExperienceModel boat;

  const BoatDetailScreen({
    super.key,
    required this.boat,
  });

  @override
  State<BoatDetailScreen> createState() => _BoatDetailScreenState();
}

class _BoatDetailScreenState extends State<BoatDetailScreen> {
  late final BoatController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<BoatController>()
        ? Get.find<BoatController>()
        : Get.put(BoatController());

    if (widget.boat.availableSlots.isNotEmpty) {
      controller.selectedTimeSlot.value = widget.boat.availableSlots.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const oceanColor = Color(0xFF0077B6);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: AppSpacing.iconSm.sp,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.back();
          },
        ),
        title: Text(
          l10nPick(context, fa: 'جزئیات شناور و گشت دریایی', en: 'Boat Experience Details'),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.lg.r),
              children: [
                // Hero Header Card
                _buildHeroCard(context, isDark, oceanColor),
                SizedBox(height: AppSpacing.lg.h),

                // Technical Specs Grid
                _buildSpecGrid(context, isDark, oceanColor),
                SizedBox(height: AppSpacing.lg.h),

                // Time Slot Selector
                _buildTimeSlotSelector(context, isDark, oceanColor),
                SizedBox(height: AppSpacing.lg.h),

                // Duration Selector
                _buildDurationSelector(context, isDark, oceanColor),
                SizedBox(height: AppSpacing.lg.h),

                // Passenger Count Selector
                _buildPassengerSelector(context, isDark, oceanColor),
                SizedBox(height: AppSpacing.lg.h),

                // Add-on Services Checklist
                if (widget.boat.addons.isNotEmpty) ...[
                  _buildAddonsSection(context, isDark, oceanColor),
                  SizedBox(height: AppSpacing.lg.h),
                ],

                // Amenities & Included Features
                _buildFeaturesCard(context, isDark, oceanColor),
                SizedBox(height: AppSpacing.lg.h),

                // Description
                _buildDescriptionCard(context, isDark),
                SizedBox(height: AppSpacing.xxl.h),
              ],
            ),
          ),

          // Bottom Checkout Bar
          _buildBottomCheckoutBar(context, isDark, oceanColor),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, bool isDark, Color oceanColor) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: oceanColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  widget.boat.categoryLabel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: oceanColor,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                  SizedBox(width: 4.w),
                  Text(
                    '${widget.boat.rating} (${widget.boat.reviewsCount} نظر)',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            widget.boat.title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              height: 1.3,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.place_rounded, size: 15.sp, color: oceanColor),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  widget.boat.marinaName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.person_pin_rounded, size: 15.sp, color: AppColors.success),
              SizedBox(width: 4.w),
              Text(
                widget.boat.captainName,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecGrid(BuildContext context, bool isDark, Color oceanColor) {
    return Row(
      children: [
        Expanded(
          child: _buildSpecTile(
            'ظرفیت مجاز',
            '${widget.boat.maxPassengers} نفر',
            Icons.people_alt_outlined,
            isDark,
            oceanColor,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildSpecTile(
            'طول شناور',
            '${widget.boat.lengthMeters} متر',
            Icons.straighten_rounded,
            isDark,
            oceanColor,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildSpecTile(
            'کرایه هر ساعت',
            '${widget.boat.hourlyRate.toStringAsFixed(0)} ${widget.boat.currency}',
            Icons.schedule_rounded,
            isDark,
            oceanColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecTile(
    String label,
    String value,
    IconData icon,
    bool isDark,
    Color oceanColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20.sp, color: oceanColor),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotSelector(BuildContext context, bool isDark, Color oceanColor) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10nPick(context, fa: 'انتخاب سانس حرکت شناور', en: 'Departure Slot'),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          Obx(() {
            final activeSlot = controller.selectedTimeSlot.value;
            return Column(
              children: widget.boat.availableSlots.map((slot) {
                final isSelected = activeSlot == slot;
                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      controller.selectedTimeSlot.value = slot;
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? oceanColor.withValues(alpha: 0.12)
                            : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isSelected ? oceanColor : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            size: 18.sp,
                            color: isSelected ? oceanColor : AppColors.greyLight,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              slot,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
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

  Widget _buildDurationSelector(BuildContext context, bool isDark, Color oceanColor) {
    final durations = [1, 2, 3, 4];

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10nPick(context, fa: 'مدت زمان گشت دریایی', en: 'Trip Duration'),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          Obx(() {
            final activeHours = controller.selectedDurationHours.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: durations.map((h) {
                final isSelected = activeHours == h;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        controller.selectedDurationHours.value = h;
                      },
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected ? oceanColor : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isSelected ? oceanColor : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$h ساعت',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected
                                  ? AppColors.white
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ),
                        ),
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

  Widget _buildPassengerSelector(BuildContext context, bool isDark, Color oceanColor) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10nPick(context, fa: 'تعداد مسافران همراه', en: 'Passengers Count'),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'حداکثر ظرفیت این شناور: ${widget.boat.maxPassengers} نفر',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
              ),
            ],
          ),
          Obx(() {
            final count = controller.passengerCount.value;
            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  color: oceanColor,
                  onPressed: count > 1
                      ? () {
                          HapticFeedback.selectionClick();
                          controller.passengerCount.value--;
                        }
                      : null,
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  color: oceanColor,
                  onPressed: count < widget.boat.maxPassengers
                      ? () {
                          HapticFeedback.selectionClick();
                          controller.passengerCount.value++;
                        }
                      : null,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAddonsSection(BuildContext context, bool isDark, Color oceanColor) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10nPick(context, fa: 'خدمات جانبی و تفریحات انتخابی', en: 'Optional Add-ons'),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          Obx(() {
            final selected = controller.selectedAddons;
            return Column(
              children: widget.boat.addons.map((addon) {
                final isChecked = selected.contains(addon.id);
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  activeColor: oceanColor,
                  title: Text(
                    addon.title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '+${addon.price.toStringAsFixed(0)} ${widget.boat.currency} (${addon.unit})',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                  value: isChecked,
                  onChanged: (_) => controller.toggleAddon(addon.id),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard(BuildContext context, bool isDark, Color oceanColor) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10nPick(context, fa: 'امکانات و تجهیزات موجود روی شناور', en: 'Included Amenities'),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          ...widget.boat.features.map(
            (feat) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      feat,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10nPick(context, fa: 'توضیحات و شرایط گشت', en: 'Overview'),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            widget.boat.description,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.6,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckoutBar(BuildContext context, bool isDark, Color oceanColor) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Obx(() {
        final total = controller.calculateTotalPrice(widget.boat);
        final isSubmitting = controller.isSubmittingBooking.value;

        return Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'مبلغ نهایی رزرو',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${total.toStringAsFixed(0)} ${widget.boat.currency}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: oceanColor,
                  ),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: oceanColor,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                  ),
                  elevation: 0,
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        HapticFeedback.heavyImpact();
                        final booking = await controller.bookBoat(boat: widget.boat);
                        if (booking != null) {
                          Get.off(() => BoatVoucherScreen(booking: booking));
                        }
                      },
                child: isSubmitting
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'پرداخت و صدور بلیت دریایی',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
