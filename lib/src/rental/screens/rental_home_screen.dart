import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/rental_controller.dart';
import '../models/rental_models.dart';

export 'rental_voucher_screen.dart';

/// جست‌وجو و کاتالوگ خودرو + رزروهای من — Car-Rental-Service-Flow.md
class RentalHomeScreen extends StatefulWidget {
  const RentalHomeScreen({super.key});

  @override
  State<RentalHomeScreen> createState() => _RentalHomeScreenState();
}

class _RentalHomeScreenState extends State<RentalHomeScreen> with SingleTickerProviderStateMixin {
  final RentalController controller = Get.put(RentalController());
  late TabController _tabController;

  static const categories = ['all', 'ECONOMY', 'SUV', 'LUXURY', 'VAN'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    controller.fetchCars();
    controller.fetchMyBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _categoryLabel(BuildContext context, String c) {
    switch (c) {
      case 'ECONOMY': return l10nPick(context, en: 'Economy', fa: 'اقتصادی', ar: 'اقتصادي', zh: '经济型');
      case 'SUV': return l10nPick(context, en: 'SUV', fa: 'شاسی‌بلند', ar: 'دفع رباعي', zh: 'SUV越野');
      case 'LUXURY': return l10nPick(context, en: 'Luxury', fa: 'لاکچری', ar: 'فاخر', zh: '豪华商务');
      case 'VAN': return l10nPick(context, en: 'Van', fa: 'ون خانوادگی', ar: 'فان', zh: '客运商务');
      default: return l10nPick(context, en: 'All', fa: 'همه', ar: 'الكل', zh: '全部');
    }
  }

  String _statusFa(String status) {
    switch (status) {
      case 'DRAFT': return 'پیش‌نویس';
      case 'AWAITING_DOCS': return 'در انتظار مدارک';
      case 'AWAITING_PAYMENT': return 'در انتظار پرداخت';
      case 'PENDING_CONFIRMATION': return 'منتظر تأیید میزبان';
      case 'CONFIRMED': return 'رزرو قطعی';
      case 'ACTIVE': return 'در حال اجاره';
      case 'RETURNED': return 'مسترد شده';
      case 'COMPLETED': return 'تکمیل‌شده';
      case 'DISPUTED': return 'در اختلاف';
      case 'CANCELLED': return 'لغو';
      case 'REFUNDED': return 'برگشت وجه';
      case 'EXPIRED': return 'منقضی';
      default: return status;
    }
  }

  void _showBookingSheet(BuildContext context, CarModel car) {
    DateTime? pickup;
    DateTime? returnAt;
    String insuranceTier = 'BASIC';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (sheetContext, setSheetState) => Container(
          padding: EdgeInsets.all(AppSpacing.xxl.r),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      car.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                    ),
                    child: Text(
                      '\$${car.dailyPrice}/day',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm.h),
              Text(
                l10nPick(context,
                  en: 'Security Deposit: \$${car.depositAmount} (Refundable)',
                  fa: 'ودیعه ضمانت نقدی: \$${car.depositAmount} (قابل استرداد)',
                  ar: 'مبلغ التأمين: \$${car.depositAmount}',
                  zh: '押金：\$${car.depositAmount}（行程结束无损返还）'),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.md.h),
              Text(
                l10nPick(context, en: 'Insurance tier (required)', fa: 'سطح پوشش بیمه (اجباری)', ar: 'مستوى التأمين', zh: '保险保障级别'),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              RadioGroup<String>(
                groupValue: insuranceTier,
                onChanged: (v) => setSheetState(() => insuranceTier = v ?? insuranceTier),
                child: Column(
                  children: [
                    for (final t in car.insuranceTiers)
                      RadioListTile<String>(
                        dense: true,
                        activeColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        value: t['tier'].toString(),
                        title: Text(
                          '${t['tier']} (+${t['extra_cost']})',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.md.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: sheetContext,
                          initialDate: DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (d != null) setSheetState(() => pickup = d);
                      },
                      child: Text(
                        pickup == null
                            ? l10nPick(context, en: 'Pickup date', fa: 'تاریخ تحویل')
                            : pickup!.toIso8601String().substring(0, 10),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md.w),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: sheetContext,
                          initialDate: (pickup ?? DateTime.now()).add(const Duration(days: 3)),
                          firstDate: pickup ?? DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 120)),
                        );
                        if (d != null) setSheetState(() => returnAt = d);
                      },
                      child: Text(
                        returnAt == null
                            ? l10nPick(context, en: 'Return date', fa: 'تاریخ عودت')
                            : returnAt!.toIso8601String().substring(0, 10),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  onPressed: (pickup == null || returnAt == null) ? null : () async {
                    controller.selectedBooking.value = RentalBookingModel(
                      id: 0, bookingNo: '', car: car, insuranceTier: insuranceTier,
                      rentalTotal: 0, extrasTotal: 0, status: '', events: [],
                    );
                    Get.back();
                    final err = await controller.createBooking(
                      pickup!.toIso8601String(),
                      returnAt!.toIso8601String(),
                      insuranceTier,
                    );
                    if (!context.mounted) return;
                    if (err != null) {
                      Get.snackbar(
                        l10nPick(context, en: 'Error', fa: 'خطا'),
                        err,
                        backgroundColor: AppColors.error,
                        colorText: Colors.white,
                      );
                    } else {
                      _tabController.animateTo(1);
                      Get.snackbar(
                        l10nPick(context, en: 'Booked', fa: 'رزرو شد'),
                        l10nPick(context,
                          en: 'Price locked for 1 hour — upload driver docs.',
                          fa: 'قیمت ۱ ساعت قفل شد؛ مدارک راننده را بارگذاری کنید.'),
                        backgroundColor: AppColors.success,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: Text(
                    l10nPick(context, en: 'Confirm Reservation', fa: 'تأیید و ثبت پیش‌رزرو', ar: 'تأكيد الحجز', zh: '确认锁定预订'),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        title: Text(
          l10nPick(context, en: 'Car Rental', fa: 'رنت خودرو در سفر', ar: 'تأجير السيارات', zh: '境外车辆租赁'),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          indicatorColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          indicatorWeight: 3.h,
          tabs: [
            Tab(text: l10nPick(context, en: 'Vehicle Fleet', fa: 'ناوگان خودروها', ar: 'الأسطول', zh: '精选车队')),
            Tab(text: l10nPick(context, en: 'My Bookings', fa: 'رزروهای من', ar: 'حجوزاتي', zh: '我的订单')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Cars Catalog
          Column(
            children: [
              SizedBox(
                height: 48.h,
                child: Obx(() => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.lg.w, vertical: AppSpacing.xs.h),
                  children: categories.map((c) => Padding(
                    padding: EdgeInsetsDirectional.only(end: AppSpacing.sm.w),
                    child: ChoiceChip(
                      label: Text(_categoryLabel(context, c)),
                      selected: controller.selectedCategory.value == c,
                      selectedColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                      labelStyle: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: controller.selectedCategory.value == c ? FontWeight.bold : FontWeight.normal,
                        color: controller.selectedCategory.value == c
                            ? (isDark ? AppColors.deepBlack : AppColors.white)
                            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      ),
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        controller.selectedCategory.value = c;
                        controller.fetchCars();
                      },
                    ),
                  )).toList(),
                )),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingCars.value) {
                    return _buildCarsSkeleton(isDark);
                  }

                  if (controller.isServiceUnavailable.value) {
                    return Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsetsDirectional.all(AppSpacing.xxl.r),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppSpacing.lg.r),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.cloud_off_rounded,
                                color: AppColors.warning,
                                size: AppSpacing.iconXl.sp,
                              ),
                            ),
                            SizedBox(height: AppSpacing.md.h),
                            Text(
                              l10nPick(
                                context,
                                en: 'Car Rental Service Unavailable',
                                fa: 'سرویس رنت خودرو موقتاً در دسترس نیست',
                                ar: 'خدمة تأجير السيارات غير متوفرة',
                                zh: '租车服务暂时不可用',
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            SizedBox(height: AppSpacing.sm.h),
                            Text(
                              l10nPick(
                                context,
                                en: 'Car rental fleet endpoints are undergoing backend integration. Please retry shortly.',
                                fa: 'سامانه اتصال به تأمین‌کنندگان خودرو در حال همگام‌سازی است. به زودی در دسترس خواهد بود.',
                                ar: 'خوادم أسطول السيارات قيد التحديث.',
                                zh: '租车车队接口正在与后台合作伙伴联调中，稍后恢复。',
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                fontSize: 12.sp,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: AppSpacing.lg.h),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                                foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                                ),
                                padding: EdgeInsetsDirectional.symmetric(
                                  horizontal: AppSpacing.xl.w,
                                  vertical: AppSpacing.md.h,
                                ),
                              ),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                controller.fetchCars();
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: Text(
                                l10nPick(
                                  context,
                                  en: 'Retry Connection',
                                  fa: 'تلاش مجدد',
                                  ar: 'إعادة المحاولة',
                                  zh: '重试连接',
                                ),
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (controller.cars.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(AppSpacing.xxl.r),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_car_outlined,
                              size: 56.sp,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                            SizedBox(height: AppSpacing.md.h),
                            Text(
                              l10nPick(
                                context,
                                en: 'No vehicles found in this category',
                                fa: 'خودرویی در این دسته‌بندی یافت نشد',
                                ar: 'لم يتم العثور على سيارات',
                                zh: '未找到符合条件的车辆',
                              ),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => controller.fetchCars(),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
                      itemCount: controller.cars.length,
                      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
                      itemBuilder: (context, i) {
                        final car = controller.cars[i];
                        return _buildVehicleCard(context, car, isDark);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),

          // Tab 2: My Bookings
          Obx(() {
            if (controller.isLoadingBookings.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.myBookings.isEmpty) {
              return Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(AppSpacing.xxl.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          size: 40.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      Text(
                        l10nPick(context, en: 'No Active Bookings', fa: 'هنوز رزروی ثبت نکرده‌اید', ar: 'لا توجد حجوزات', zh: '暂无预订订单'),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      Text(
                        l10nPick(context,
                          en: 'Select a premium car from our catalog to book with guaranteed pricing.',
                          fa: 'خودروی مورد نظرتان را برای رزرو انتخاب کنید.'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => controller.fetchMyBookings(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(AppSpacing.lg.w),
                itemCount: controller.myBookings.length,
                separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
                itemBuilder: (context, i) {
                  final b = controller.myBookings[i];
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(AppSpacing.radius.r),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w, vertical: AppSpacing.xs.h),
                      leading: Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                        ),
                        child: Icon(
                          Icons.directions_car_rounded,
                          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        ),
                      ),
                      title: Text(
                        b.bookingNo,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.sp,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      subtitle: Text(
                        b.car?.title ?? l10nPick(context, en: 'Vehicle Rental', fa: 'رزرو خودرو'),
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                            ),
                            child: Text(
                              _statusFa(b.status),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.chevron_right,
                            size: 18.sp,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ],
                      ),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Get.toNamed(BaseRoute.rentalDetail, arguments: b.id);
                      },
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCarsSkeleton(bool isDark) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      itemCount: 4,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
      itemBuilder: (_, _) => Container(
        height: 140.h,
        padding: EdgeInsets.all(AppSpacing.lg.r),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppSpacing.radius.r),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                  ),
                ),
                SizedBox(width: AppSpacing.md.w),
                Expanded(
                  child: Container(
                    height: 18.h,
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, CarModel car, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSpacing.radius.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title & Fleet status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                ),
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  size: AppSpacing.iconMd.sp,
                ),
              ),
              SizedBox(width: AppSpacing.md.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5.sp,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _categoryLabel(context, car.category),
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: car.isFleet
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      car.isFleet ? Icons.bolt_rounded : Icons.person_outline_rounded,
                      size: 12.sp,
                      color: car.isFleet ? AppColors.success : AppColors.warning,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      car.isFleet
                          ? l10nPick(context, en: 'Instant Fleet', fa: 'تأیید آنی', ar: 'تأكيد فوري', zh: '极速出车')
                          : l10nPick(context, en: 'Host', fa: 'میزبان تأییدشده', ar: 'مضيف', zh: '认证车主'),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: car.isFleet ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md.h),

          // Spec Badges Row
          Wrap(
            spacing: AppSpacing.xs.w,
            runSpacing: AppSpacing.xs.h,
            children: [
              _buildSpecBadge(
                icon: Icons.speed_rounded,
                label: '${car.dailyKmLimit} km/day',
                isDark: isDark,
              ),
              if (car.transmission != null)
                _buildSpecBadge(
                  icon: Icons.tune_rounded,
                  label: car.transmission!,
                  isDark: isDark,
                ),
              _buildSpecBadge(
                icon: Icons.shield_outlined,
                label: l10nPick(context, en: 'Deposit: \$${car.depositAmount.toInt()}', fa: 'ودیعه: \$${car.depositAmount.toInt()}'),
                isDark: isDark,
              ),
              _buildSpecBadge(
                icon: Icons.person_outline_rounded,
                label: 'Age ${car.minAge}+',
                isDark: isDark,
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md.h),

          // Bottom Bar: Price & Book Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(context, en: 'Daily rate', fa: 'نرخ روزانه', ar: 'السعر اليومي', zh: '日租金'),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                  Text(
                    '\$${car.dailyPrice.toStringAsFixed(0)} / day',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  elevation: 0,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showBookingSheet(context, car);
                },
                child: Text(
                  l10nPick(context, en: 'Book Vehicle', fa: 'رزرو خودرو', ar: 'حجز الآن', zh: '立即预订'),
                  style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecBadge({required IconData icon, required String label, required bool isDark}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}