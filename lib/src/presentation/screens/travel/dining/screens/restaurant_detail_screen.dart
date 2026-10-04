import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/dining_controller.dart';
import '../models/dining_models.dart';
import 'dining_order_pass_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late final DiningController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<DiningController>()
        ? Get.find<DiningController>()
        : Get.put(DiningController());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const amberColor = Color(0xFFD97706);

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
          widget.restaurant.name,
          style: TextStyle(
            fontSize: 15.sp,
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
                // Restaurant info header card
                _buildHeaderCard(context, isDark, amberColor),
                SizedBox(height: AppSpacing.lg.h),

                // Delivery / Service Mode Selector
                _buildModeSelector(context, isDark, amberColor),
                SizedBox(height: AppSpacing.lg.h),

                // Menu items section
                Text(
                  l10nPick(context, fa: 'منوی غذا و نوشیدنی‌های سفر', en: 'Travel Dining Menu'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 10.h),
                ...widget.restaurant.menu.map((item) {
                  return _buildMenuItemTile(context, item, isDark, amberColor);
                }),
                SizedBox(height: AppSpacing.xxl.h),
              ],
            ),
          ),

          // Bottom Cart Sheet
          Obx(() {
            if (controller.cartCount == 0) return const SizedBox.shrink();
            return _buildBottomCartBar(context, isDark, amberColor);
          }),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, bool isDark, Color amberColor) {
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
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: amberColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  widget.restaurant.cuisineType,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: amberColor,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                  SizedBox(width: 4.w),
                  Text(
                    '${widget.restaurant.rating} (${widget.restaurant.reviewsCount} نظر)',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            widget.restaurant.name,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.place_rounded, size: 14.sp, color: amberColor),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  widget.restaurant.terminalLocation,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(BuildContext context, bool isDark, Color amberColor) {
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
            l10nPick(context, fa: 'نحوه دریافت سفارش:', en: 'Delivery / Pickup Option:'),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() {
            final activeMode = controller.orderMode.value;
            return Row(
              children: [
                Expanded(
                  child: _buildModeChip(
                    'تحویل در گیت پرواز',
                    DiningServiceMode.airportGatePickup,
                    activeMode,
                    amberColor,
                    isDark,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildModeChip(
                    'رزرو میز در سالن',
                    DiningServiceMode.tableReservation,
                    activeMode,
                    amberColor,
                    isDark,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildModeChip(
    String label,
    DiningServiceMode mode,
    DiningServiceMode active,
    Color amberColor,
    bool isDark,
  ) {
    final isSelected = mode == active;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        controller.orderMode.value = mode;
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: isSelected ? amberColor : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: isSelected ? amberColor : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemTile(
    BuildContext context,
    MenuItemModel item,
    bool isDark,
    Color amberColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md.h),
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (item.isHalal)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        margin: EdgeInsets.only(left: 6.w),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'حلال 🥩',
                          style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w700, color: AppColors.success),
                        ),
                      ),
                    if (item.isVegan)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'گیاهی 🥗',
                          style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w700, color: AppColors.success),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                if (item.description.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Text(
                      '${item.price.toStringAsFixed(0)} ${item.currency}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: amberColor,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      '${item.prepMinutes} دقیقه آماده‌سازی',
                      style: TextStyle(fontSize: 10.5.sp, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Obx(() {
            final qty = controller.getItemQuantity(item.id);
            if (qty == 0) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: amberColor,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  elevation: 0,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  controller.addToCart(widget.restaurant, item);
                },
                child: const Text('افزودن +', style: TextStyle(color: Colors.white)),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: amberColor),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    color: amberColor,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      controller.removeFromCart(item);
                    },
                  ),
                  Text(
                    '$qty',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    color: amberColor,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      controller.addToCart(widget.restaurant, item);
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomCartBar(BuildContext context, bool isDark, Color amberColor) {
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
        final total = controller.cartSubtotal;
        final count = controller.cartCount;
        final isSubmitting = controller.isSubmittingOrder.value;

        return Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'سبد خرید ($count قلم)',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${total.toStringAsFixed(0)} USD',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: amberColor,
                  ),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: amberColor,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
                  elevation: 0,
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        HapticFeedback.heavyImpact();
                        final order = await controller.submitOrder();
                        if (order != null) {
                          Get.off(() => DiningOrderPassScreen(order: order));
                        }
                      },
                child: isSubmitting
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'ثبت و پرداخت با کیف پول',
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
