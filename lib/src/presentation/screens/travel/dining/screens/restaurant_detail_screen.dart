// DATA: MOCK (Ready for REAL backend domain registration under schema_version: 1.0)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/dining_controller.dart';
import '../models/dining_models.dart';
import '../../local/models/experience_contracts.dart';
import '../../local/widgets/experience_ui_components.dart';
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

    if (!controller.cartItems.any((i) => i.item.id == 'temp-init')) {
      // Reset cart when navigating to a new restaurant
      controller.clearCart();
    }
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

                // Service Mode Selector
                _buildModeSelector(context, isDark, amberColor),
                SizedBox(height: AppSpacing.lg.h),

                // Validation Error Banner
                Obx(() {
                  if (controller.validationError.value.isNotEmpty) {
                    return ExperienceErrorView(
                      errorMessage: controller.validationError.value,
                      onRetry: () => controller.clearCart(),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Menu items section
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10nPick(
                          context,
                          fa: 'منوی غذای فرودگاهی',
                          en: 'In-Transit Dining Menu',
                          ar: 'قائمة وجبات السفر',
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    if (widget.restaurant.dietaryOptions.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          widget.restaurant.dietaryOptions.first,
                          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppColors.success),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10.h),
                ...widget.restaurant.menu.map((item) {
                  return _buildMenuItemTile(context, item, isDark, amberColor);
                }),
                SizedBox(height: AppSpacing.xxl.h),
              ],
            ),
          ),

          // Bottom Cart Sheet with 12-state UI states
          Obx(() {
            final list = controller.filteredRestaurants.where((r) => r.id == widget.restaurant.id).toList();
            final rest = list.isEmpty ? null : list.first;

            if (rest == null) {
              return const SizedBox.shrink();
            }

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Order summary
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            controller.cartCount > 0 ? '${controller.cartCount} آیتم' : 'سبد سفارش خالی است',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                        Text(
                          controller.cartCount > 0 ? '${controller.cartSubtotal.toStringAsFixed(0)} ${rest.currency}' : '',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 12.h * 0.5),
                  // Checkout button
                  controller.cartCount > 0 && !isDark && controller.uiState.value != ExperienceServiceState.processing
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 44.h),
                            backgroundColor: amberColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            elevation: 0,
                          ),
                          child: Text(l10nPick(context, fa: 'تکمیل و پرداخت', en: 'Complete & Pay'),
                              style: const TextStyle(fontWeight: FontWeight.w800)),
                          onPressed: () async {
                            HapticFeedback.heavyImpact();
                            final order = await controller.submitOrder();
                            if (order != null && mounted) {
                              Get.off(() => DiningOrderPassScreen(order: order));
                            }
                          },
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, bool isDark, Color amberColor) {
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: amberColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.restaurant_rounded, color: amberColor, size: 24),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.restaurant.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.flight_takeoff_rounded, size: 12.sp, color: AppColors.success),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            widget.restaurant.city,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
              SizedBox(width: 4.w),
              Text(
                '${widget.restaurant.rating}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              Text(' (${widget.restaurant.reviewsCount} نظرات)',
                  style: TextStyle(
                      fontSize: 10.sp,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary)),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            widget.restaurant.terminalLocation,
            style: TextStyle(
              fontSize: 11.sp,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          SizedBox(height: 4.h),
          Wrap(
            spacing: 6.w,
            children: widget.restaurant.availableModes.take(3).map((m) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: amberColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  m.labelFa,
                  style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w700, color: amberColor),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(BuildContext context, bool isDark, Color amberColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10nPick(context, fa: 'روش سرو سفارش را انتخاب کنید', en: 'Select Ordering Method'),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() {
          final active = controller.orderMode.value;
          final modes = widget.restaurant.availableModes;
          return Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: modes.map((mode) {
              final isSelected = active == mode;
              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.orderMode.value = mode;
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
                  decoration: BoxDecoration(
                    color: isSelected ? amberColor : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isSelected
                          ? amberColor
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      mode.labelFa,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildMenuItemTile(
    BuildContext context,
    MenuItemModel item,
    bool isDark,
    Color amberColor,
  ) {
    final qty = controller.getItemQuantity(item.id);
    final inCart = qty > 0;

    return Semantics(
      label: '${item.title} - ${item.price.toStringAsFixed(0)} ${item.currency}',
      button: inCart,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.md.h),
        padding: EdgeInsets.all(AppSpacing.md.r),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          boxShadow: inCart
              ? [
                  BoxShadow(
                    color: amberColor.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (item.isHalal)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          margin: EdgeInsetsDirectional.only(start: 6.w),
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
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 12.sp,
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                      SizedBox(width: 4.w),
                      Text(
                        'آماده‌سازی: ~${item.prepMinutes} دقیقه',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            if (inCart)
              Container(
                width: 56.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: amberColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded, size: 16),
                      color: Colors.white,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        controller.removeFromCart(item);
                      },
                    ),
                    Text(
                      '$qty',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                      color: Colors.white,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        controller.addToCart(widget.restaurant, item);
                      },
                    ),
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(96.w, 40.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  side: BorderSide(color: amberColor),
                ),
                icon: Icon(Icons.add_shopping_cart_rounded, size: 16, color: amberColor),
                label: Text(
                  l10nPick(context, fa: 'افزودن', en: 'Add'),
                  style: TextStyle(fontSize: 11.sp, color: amberColor),
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  controller.addToCart(widget.restaurant, item);
                },
              ),
          ],
        ),
      ),
    );
  }
}
