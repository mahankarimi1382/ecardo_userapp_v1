import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/dining_controller.dart';
import '../models/dining_models.dart';
import 'restaurant_detail_screen.dart';
import 'dining_order_pass_screen.dart';

class DiningCatalogScreen extends StatefulWidget {
  const DiningCatalogScreen({super.key});

  @override
  State<DiningCatalogScreen> createState() => _DiningCatalogScreenState();
}

class _DiningCatalogScreenState extends State<DiningCatalogScreen> {
  late final DiningController controller;

  final List<Map<String, dynamic>> _hubs = const [
    {'key': 'ALL', 'label': 'همه پایانه‌ها ✈️'},
    {'key': 'IKA', 'label': 'فرودگاه امام (IKA) 🇮🇷'},
    {'key': 'DXB', 'label': 'دبی (DXB) 🇦🇪'},
    {'key': 'IST', 'label': 'استانبول (IST) 🇹🇷'},
  ];

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
          l10nPick(
            context,
            fa: 'رستوران و غذای طول سفر',
            en: 'In-Transit Dining',
            ar: 'مطاعم ووجبات السفر',
          ),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.receipt_long_outlined,
              color: amberColor,
              size: 22.sp,
            ),
            tooltip: 'سفارش‌های من',
            onPressed: () => _showMyOrdersSheet(context, isDark),
          ),
        ],
      ),
      body: Column(
        children: [
          // Transit Hub Selector Row
          Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Obx(() {
              final activeHub = controller.selectedHub.value;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                itemCount: _hubs.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.w),
                itemBuilder: (context, idx) {
                  final h = _hubs[idx];
                  final isSelected = activeHub == h['key'];

                  return ChoiceChip(
                    label: Text(
                      h['label']!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: amberColor,
                    backgroundColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      side: BorderSide(
                        color: isSelected ? amberColor : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      controller.setHub(h['key']!);
                    },
                  );
                },
              );
            }),
          ),

          SizedBox(height: 6.h),

          // Restaurant Cards List
          Expanded(
            child: Obx(() {
              final list = controller.filteredRestaurants;

              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_outlined, size: 54.sp, color: AppColors.greyLight),
                      SizedBox(height: 12.h),
                      Text(
                        'رستورانی در این پایانه یافت نشد.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.fromLTRB(AppSpacing.lg.w, 4.h, AppSpacing.lg.w, AppSpacing.xl.h),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final rest = list[index];
                  return _buildRestaurantCard(context, rest, isDark, amberColor);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(
    BuildContext context,
    RestaurantModel rest,
    bool isDark,
    Color amberColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.lg.h),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Get.to(() => RestaurantDetailScreen(restaurant: rest));
          },
          borderRadius: BorderRadius.circular(AppSpacing.radius.r),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: amberColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          rest.cuisineType,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w700,
                            color: amberColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.warning, size: 15),
                        SizedBox(width: 4.w),
                        Text(
                          '${rest.rating}',
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
                  rest.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.place_rounded, size: 14.sp, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        rest.terminalLocation,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 6.w,
                  children: [
                    _buildPill(Icons.access_time_rounded, rest.openingHours, isDark),
                    _buildPill(Icons.delivery_dining_rounded, 'تحویل گیت', isDark),
                  ],
                ),
                SizedBox(height: 12.h),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${rest.menu.length} نوع غذا و نوشیدنی آماده',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: amberColor,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Get.to(() => RestaurantDetailScreen(restaurant: rest));
                      },
                      child: const Text('مشاهده منو و سفارش', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPill(IconData icon, String label, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5.sp,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showMyOrdersSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl.r)),
      ),
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.all(AppSpacing.lg.r),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'رسید و سفارش‌های غذای من',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: Obx(() {
                  final orders = controller.myOrders;
                  if (orders.isEmpty) {
                    return Center(
                      child: Text(
                        'شما سفارش غذای فعالی ندارید.',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, idx) {
                      final o = orders[idx];
                      return Card(
                        margin: EdgeInsets.only(bottom: 10.h),
                        color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                        child: ListTile(
                          title: Text(
                            o.restaurantName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text('${o.pickupTime} • ${o.totalAmount.toStringAsFixed(0)} ${o.currency}'),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          onTap: () {
                            Navigator.pop(ctx);
                            Get.to(() => DiningOrderPassScreen(order: o));
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
