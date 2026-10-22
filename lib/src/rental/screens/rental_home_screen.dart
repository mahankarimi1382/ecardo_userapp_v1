import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
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

class _RentalHomeScreenState extends State<RentalHomeScreen>
    with SingleTickerProviderStateMixin {
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
      case 'ECONOMY':
        return l10nPick(
          context,
          en: 'Economy',
          fa: 'اقتصادی',
          ar: 'اقتصادي',
          zh: '经济型',
        );
      case 'SUV':
        return l10nPick(
          context,
          en: 'SUV',
          fa: 'شاسی‌بلند',
          ar: 'دفع رباعي',
          zh: 'SUV越野',
        );
      case 'LUXURY':
        return l10nPick(
          context,
          en: 'Luxury',
          fa: 'لاکچری',
          ar: 'فاخر',
          zh: '豪华商务',
        );
      case 'VAN':
        return l10nPick(
          context,
          en: 'Van',
          fa: 'ون خانوادگی',
          ar: 'فان',
          zh: '客运商务',
        );
      default:
        return l10nPick(context, en: 'All', fa: 'همه', ar: 'الكل', zh: '全部');
    }
  }

  String _statusFa(String status) {
    switch (status) {
      case 'DRAFT':
        return 'پیش‌نویس';
      case 'AWAITING_DOCS':
        return 'در انتظار مدارک';
      case 'AWAITING_PAYMENT':
        return 'در انتظار پرداخت';
      case 'PENDING_CONFIRMATION':
        return 'منتظر تأیید میزبان';
      case 'CONFIRMED':
        return 'رزرو قطعی';
      case 'ACTIVE':
        return 'در حال اجاره';
      case 'RETURNED':
        return 'مسترد شده';
      case 'COMPLETED':
        return 'تکمیل‌شده';
      case 'DISPUTED':
        return 'در اختلاف';
      case 'CANCELLED':
        return 'لغو';
      case 'REFUNDED':
        return 'برگشت وجه';
      case 'EXPIRED':
        return 'منقضی';
      default:
        return status;
    }
  }

  void _showBookingSheet(BuildContext context, CarModel car) {
    DateTime? pickup;
    DateTime? returnAt;
    String insuranceTier = 'BASIC';

    Get.bottomSheet(
      StatefulBuilder(
        builder: (sheetContext, setSheetState) => Container(
          padding: EdgeInsets.all(ECardoTokens.space5.r),
          decoration: BoxDecoration(
            color: ECardoTokens.surfaceCard(context),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ECardoTokens.radius2xl.r),
            ),
            boxShadow: ECardoTokens.shadowSheet(context),
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
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: ECardoTokens.brand100(context),
                      borderRadius: BorderRadius.circular(
                        ECardoTokens.radiusSm.r,
                      ),
                    ),
                    child: Text(
                      '\$${car.dailyPrice}/day',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: ECardoTokens.brand500(context),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ECardoTokens.space2.h),
              Text(
                l10nPick(
                  context,
                  en: 'Security Deposit: \$${car.depositAmount} (Refundable)',
                  fa: 'ودیعه ضمانت نقدی: \$${car.depositAmount} (قابل استرداد)',
                  ar: 'مبلغ التأمين: \$${car.depositAmount}',
                  zh: '押金：\$${car.depositAmount}（行程结束无损返还）',
                ),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: ECardoTokens.inkMuted(context),
                ),
              ),
              SizedBox(height: ECardoTokens.space3.h),
              Text(
                l10nPick(
                  context,
                  en: 'Insurance tier (required)',
                  fa: 'سطح پوشش بیمه (اجباری)',
                  ar: 'مستوى التأمين',
                  zh: '保险保障级别',
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                  color: ECardoTokens.ink(context),
                ),
              ),
              RadioGroup<String>(
                groupValue: insuranceTier,
                onChanged: (v) =>
                    setSheetState(() => insuranceTier = v ?? insuranceTier),
                child: Column(
                  children: [
                    for (final t in car.insuranceTiers)
                      RadioListTile<String>(
                        dense: true,
                        activeColor: ECardoTokens.brand500(context),
                        value: t['tier'].toString(),
                        title: Text(
                          '${t['tier']} (+${t['extra_cost']})',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: ECardoTokens.ink(context),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: ECardoTokens.space3.h),
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: l10nPick(
                        context,
                        en: 'Select pickup date',
                        fa: 'انتخاب تاریخ تحویل',
                        ar: 'تحديد تاريخ الاستلام',
                        zh: '选择取车日期',
                      ),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: ECardoTokens.borderStrong(context),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ECardoTokens.radiusMd.r,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          minimumSize: Size(0, 44.h),
                        ),
                        onPressed: () async {
                          HapticFeedback.selectionClick();
                          final d = await showDatePicker(
                            context: sheetContext,
                            initialDate: DateTime.now().add(
                              const Duration(days: 1),
                            ),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 90),
                            ),
                          );
                          if (d != null) setSheetState(() => pickup = d);
                        },
                        child: Text(
                          pickup == null
                              ? l10nPick(
                                  context,
                                  en: 'Pickup date',
                                  fa: 'تاریخ تحویل',
                                )
                              : pickup!.toIso8601String().substring(0, 10),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: ECardoTokens.ink(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ECardoTokens.space3.w),
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: l10nPick(
                        context,
                        en: 'Select return date',
                        fa: 'انتخاب تاریخ عودت',
                        ar: 'تحديد تاريخ الإرجاع',
                        zh: '选择还车日期',
                      ),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: ECardoTokens.borderStrong(context),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ECardoTokens.radiusMd.r,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          minimumSize: Size(0, 44.h),
                        ),
                        onPressed: () async {
                          HapticFeedback.selectionClick();
                          final d = await showDatePicker(
                            context: sheetContext,
                            initialDate: (pickup ?? DateTime.now()).add(
                              const Duration(days: 3),
                            ),
                            firstDate: pickup ?? DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 120),
                            ),
                          );
                          if (d != null) setSheetState(() => returnAt = d);
                        },
                        child: Text(
                          returnAt == null
                              ? l10nPick(
                                  context,
                                  en: 'Return date',
                                  fa: 'تاریخ عودت',
                                )
                              : returnAt!.toIso8601String().substring(0, 10),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: ECardoTokens.ink(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ECardoTokens.space4.h),
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  button: true,
                  label: l10nPick(
                    context,
                    en: 'Confirm Reservation',
                    fa: 'تأیید و ثبت پیش‌رزرو',
                    ar: 'تأكيد الحجز',
                    zh: '确认锁定预订',
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ECardoTokens.brand500(context),
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ECardoTokens.radiusMd.r,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      minimumSize: Size(double.infinity, 48.h),
                    ),
                    onPressed: (pickup == null || returnAt == null)
                        ? null
                        : () async {
                            HapticFeedback.lightImpact();
                            controller.selectedBooking.value =
                                RentalBookingModel(
                                  id: 0,
                                  bookingNo: '',
                                  car: car,
                                  insuranceTier: insuranceTier,
                                  rentalTotal: 0,
                                  extrasTotal: 0,
                                  status: '',
                                  events: [],
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
                                backgroundColor: ECardoTokens.danger(context),
                                colorText: AppColors.white,
                              );
                            } else {
                              _tabController.animateTo(1);
                              Get.snackbar(
                                l10nPick(context, en: 'Booked', fa: 'رزرو شد'),
                                l10nPick(
                                  context,
                                  en: 'Price locked for 1 hour — upload driver docs.',
                                  fa: 'قیمت ۱ ساعت قفل شد؛ مدارک راننده را بارگذاری کنید.',
                                ),
                                backgroundColor: ECardoTokens.success(context),
                                colorText: AppColors.white,
                              );
                            }
                          },
                    child: Text(
                      l10nPick(
                        context,
                        en: 'Confirm Reservation',
                        fa: 'تأیید و ثبت پیش‌رزرو',
                        ar: 'تأكيد الحجز',
                        zh: '确认锁定预订',
                      ),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: AppBar(
        backgroundColor: ECardoTokens.surfaceCard(context),
        elevation: 0,
        title: Text(
          l10nPick(
            context,
            en: 'Car Rental',
            fa: 'رنت خودرو در سفر',
            ar: 'تأجير السيارات',
            zh: '境外车辆租赁',
          ),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: ECardoTokens.ink(context),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ECardoTokens.brand500(context),
          unselectedLabelColor: ECardoTokens.inkMuted(context),
          indicatorColor: ECardoTokens.brand500(context),
          indicatorWeight: 3.h,
          tabs: [
            Tab(
              text: l10nPick(
                context,
                en: 'Vehicle Fleet',
                fa: 'ناوگان خودروها',
                ar: 'الأسطول',
                zh: '精选车队',
              ),
            ),
            Tab(
              text: l10nPick(
                context,
                en: 'My Bookings',
                fa: 'رزروهای من',
                ar: 'حجوزاتي',
                zh: '我的订单',
              ),
            ),
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
                child: Obx(
                  () => ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: ECardoTokens.space4.w,
                      vertical: ECardoTokens.space2.h,
                    ),
                    children: categories
                        .map(
                          (c) => Padding(
                            padding: EdgeInsetsDirectional.only(
                              end: ECardoTokens.space2.w,
                            ),
                            child: Semantics(
                              button: true,
                              selected: controller.selectedCategory.value == c,
                              label: _categoryLabel(context, c),
                              child: ChoiceChip(
                                label: Text(_categoryLabel(context, c)),
                                selected:
                                    controller.selectedCategory.value == c,
                                selectedColor: ECardoTokens.brand500(context),
                                backgroundColor: ECardoTokens.surfaceCard(
                                  context,
                                ),
                                labelStyle: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight:
                                      controller.selectedCategory.value == c
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: controller.selectedCategory.value == c
                                      ? AppColors.white
                                      : ECardoTokens.ink(context),
                                ),
                                onSelected: (_) {
                                  HapticFeedback.selectionClick();
                                  controller.selectedCategory.value = c;
                                  controller.fetchCars();
                                },
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingCars.value) {
                    return _buildCarsSkeleton();
                  }

                  if (controller.isServiceUnavailable.value) {
                    return Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsetsDirectional.all(
                          ECardoTokens.space6.r,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(ECardoTokens.space4.r),
                              decoration: BoxDecoration(
                                color: ECardoTokens.warningBg(context),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.cloud_off_rounded,
                                color: ECardoTokens.warning(context),
                                size: ECardoTokens.space8.sp,
                              ),
                            ),
                            SizedBox(height: ECardoTokens.space3.h),
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
                                color: ECardoTokens.ink(context),
                              ),
                            ),
                            SizedBox(height: ECardoTokens.space2.h),
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
                                color: ECardoTokens.inkMuted(context),
                                fontSize: 12.sp,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: ECardoTokens.space4.h),
                            Semantics(
                              button: true,
                              label: l10nPick(
                                context,
                                en: 'Retry Connection',
                                fa: 'تلاش مجدد',
                                ar: 'إعادة المحاولة',
                                zh: '重试连接',
                              ),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ECardoTokens.brand500(
                                    context,
                                  ),
                                  foregroundColor: AppColors.white,
                                  minimumSize: Size(160.w, 44.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      ECardoTokens.radiusMd.r,
                                    ),
                                  ),
                                  padding: EdgeInsetsDirectional.symmetric(
                                    horizontal: ECardoTokens.space4.w,
                                    vertical: ECardoTokens.space3.h,
                                  ),
                                ),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  controller.fetchCars();
                                },
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  l10nPick(
                                    context,
                                    en: 'Retry Connection',
                                    fa: 'تلاش مجدد',
                                    ar: 'إعادة المحاولة',
                                    zh: '重试连接',
                                  ),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (controller.cars.isEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: EcardoEmptyState(
                        iconData: Icons.directions_car_outlined,
                        glowColor: ECardoTokens.brand500(context),
                        title: l10nPick(
                          context,
                          en: 'No Vehicles Found',
                          fa: 'خودرویی در این دسته‌بندی یافت نشد',
                          ar: 'لم يتم العثور على سيارات',
                          zh: '未找到符合条件的车辆',
                        ),
                        description: l10nPick(
                          context,
                          en: 'Try selecting a different vehicle category or refresh the fleet catalog.',
                          fa: 'دسته‌بندی دیگری را انتخاب کنید یا کاتالوگ خودروها را بازخوانی نمایید.',
                          ar: 'حاول اختيار فئة أخرى أو تحديث قائمة المركبات.',
                          zh: '请尝试选择其他车辆分类或刷新车队列表。',
                        ),
                        primaryActionLabel: l10nPick(
                          context,
                          en: 'Show All Vehicles',
                          fa: 'مشاهده همه خودروها',
                          ar: 'عرض جميع السيارات',
                          zh: '查看全部车辆',
                        ),
                        onPrimaryAction: () {
                          HapticFeedback.selectionClick();
                          controller.selectedCategory.value = 'all';
                          controller.fetchCars();
                        },
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => controller.fetchCars(),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsetsDirectional.all(ECardoTokens.space4.w),
                      itemCount: controller.cars.length,
                      separatorBuilder: (_, _) =>
                          SizedBox(height: ECardoTokens.space6.h),
                      itemBuilder: (context, i) {
                        final car = controller.cars[i];
                        return _buildVehicleCard(context, car);
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
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: EcardoEmptyState(
                  iconData: Icons.receipt_long_outlined,
                  glowColor: ECardoTokens.brand500(context),
                  title: l10nPick(
                    context,
                    en: 'No Active Bookings',
                    fa: 'هنوز رزروی ثبت نکرده‌اید',
                    ar: 'لا توجد حجوزات',
                    zh: '暂无预订订单',
                  ),
                  description: l10nPick(
                    context,
                    en: 'Select a premium car from our catalog to book with guaranteed pricing.',
                    fa: 'خودروی مورد نظرتان را برای رزرو با قیمت تضمین‌شده انتخاب کنید.',
                    ar: 'اختر سيارة مميزة من أسطولنا لحجزها بأسعار مضمونة.',
                    zh: '从我们的车队精选心仪车辆，享受价格锁定保障。',
                  ),
                  primaryActionLabel: l10nPick(
                    context,
                    en: 'Browse Vehicle Fleet',
                    fa: 'مشاهده ناوگان خودروها',
                    ar: 'تصفح أسطول السيارات',
                    zh: '浏览精选车队',
                  ),
                  onPrimaryAction: () {
                    HapticFeedback.lightImpact();
                    _tabController.animateTo(0);
                  },
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => controller.fetchMyBookings(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(ECardoTokens.space4.w),
                itemCount: controller.myBookings.length,
                separatorBuilder: (_, _) =>
                    SizedBox(height: ECardoTokens.space6.h),
                itemBuilder: (context, i) {
                  final b = controller.myBookings[i];
                  return Container(
                    decoration: BoxDecoration(
                      color: ECardoTokens.surfaceCard(context),
                      borderRadius: BorderRadius.circular(
                        ECardoTokens.radiusLg.r,
                      ),
                      border: Border.all(color: ECardoTokens.border(context)),
                    ),
                    child: Semantics(
                      button: true,
                      label:
                          '${b.bookingNo}, ${b.car?.title ?? l10nPick(context, en: "Vehicle Rental", fa: "رزرو خودرو")}, ${_statusFa(b.status)}',
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: ECardoTokens.space4.w,
                          vertical: ECardoTokens.space2.h,
                        ),
                        minVerticalPadding: 12.h,
                        leading: Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: ECardoTokens.brand100(context),
                            borderRadius: BorderRadius.circular(
                              ECardoTokens.radiusSm.r,
                            ),
                          ),
                          child: Icon(
                            Icons.directions_car_rounded,
                            color: ECardoTokens.brand500(context),
                          ),
                        ),
                        title: Text(
                          b.bookingNo,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.sp,
                            color: ECardoTokens.ink(context),
                          ),
                        ),
                        subtitle: Text(
                          b.car?.title ??
                              l10nPick(
                                context,
                                en: 'Vehicle Rental',
                                fa: 'رزرو خودرو',
                              ),
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: ECardoTokens.inkMuted(context),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: ECardoTokens.brand100(context),
                                borderRadius: BorderRadius.circular(
                                  ECardoTokens.radiusSm.r,
                                ),
                              ),
                              child: Text(
                                _statusFa(b.status),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: ECardoTokens.brand500(context),
                                ),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.chevron_right,
                              size: 18.sp,
                              color: ECardoTokens.inkMuted(context),
                            ),
                          ],
                        ),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Get.toNamed(BaseRoute.rentalDetail, arguments: b.id);
                        },
                      ),
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

  Widget _buildCarsSkeleton() {
    return Builder(
      builder: (context) {
        final placeholder = ECardoTokens.surfaceSunken(context);
        return ListView.separated(
          padding: EdgeInsets.all(ECardoTokens.space4.r),
          itemCount: 4,
          separatorBuilder: (_, _) => SizedBox(height: ECardoTokens.space3.h),
          itemBuilder: (_, _) => Container(
            padding: EdgeInsets.all(ECardoTokens.space4.r),
            decoration: BoxDecoration(
              color: ECardoTokens.surfaceCard(context),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
              border: Border.all(color: ECardoTokens.border(context)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: placeholder,
                        borderRadius: BorderRadius.circular(
                          ECardoTokens.radiusMd.r,
                        ),
                      ),
                    ),
                    SizedBox(width: ECardoTokens.space3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 14.h, color: placeholder),
                          SizedBox(height: 6.h),
                          Container(
                            height: 12.h,
                            width: 120.w,
                            color: placeholder,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ECardoTokens.space3.h),
                Container(height: 12.h, color: placeholder),
                SizedBox(height: ECardoTokens.space2.h),
                Row(
                  children: [
                    Container(width: 90.w, height: 12.h, color: placeholder),
                    SizedBox(width: ECardoTokens.space2.w),
                    Container(width: 60.w, height: 12.h, color: placeholder),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVehicleCard(BuildContext context, CarModel car) {
    return Container(
      padding: EdgeInsets.all(ECardoTokens.space4.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
        border: Border.all(color: ECardoTokens.border(context)),
        boxShadow: ECardoTokens.shadowCard(context),
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
                  color: ECardoTokens.brand100(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                ),
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  color: ECardoTokens.brand500(context),
                  size: 22.sp,
                ),
              ),
              SizedBox(width: ECardoTokens.space3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5.sp,
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _categoryLabel(context, car.category),
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: ECardoTokens.inkMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                label: car.isFleet
                    ? l10nPick(
                        context,
                        en: 'Instant Fleet Confirmation',
                        fa: 'تأیید آنی ناوگان',
                      )
                    : l10nPick(
                        context,
                        en: 'Verified Host',
                        fa: 'میزبان تأییدشده',
                      ),
                child: Container(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: car.isFleet
                        ? ECardoTokens.successBg(context)
                        : ECardoTokens.warningBg(context),
                    borderRadius: BorderRadius.circular(
                      ECardoTokens.radiusSm.r,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        car.isFleet
                            ? Icons.bolt_rounded
                            : Icons.person_outline_rounded,
                        size: 12.sp,
                        color: car.isFleet
                            ? ECardoTokens.success(context)
                            : ECardoTokens.warning(context),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        car.isFleet
                            ? l10nPick(
                                context,
                                en: 'Instant Fleet',
                                fa: 'تأیید آنی',
                                ar: 'تأكيد فوري',
                                zh: '极速出车',
                              )
                            : l10nPick(
                                context,
                                en: 'Host',
                                fa: 'میزبان تأییدشده',
                                ar: 'مضيف',
                                zh: '认证车主',
                              ),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: car.isFleet
                              ? ECardoTokens.success(context)
                              : ECardoTokens.warning(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ECardoTokens.space3.h),

          // Spec Badges Row
          Wrap(
            spacing: ECardoTokens.space1.w,
            runSpacing: ECardoTokens.space1.h,
            children: [
              _buildSpecBadge(
                context: context,
                icon: Icons.speed_rounded,
                label: '${car.dailyKmLimit} km/day',
                semanticsLabel: l10nPick(
                  context,
                  en: 'Daily distance limit: ${car.dailyKmLimit} km per day',
                  fa: 'محدودیت تردد روزانه: ${car.dailyKmLimit} کیلومتر در روز',
                ),
              ),
              if (car.transmission != null)
                _buildSpecBadge(
                  context: context,
                  icon: Icons.tune_rounded,
                  label: car.transmission!,
                  semanticsLabel: l10nPick(
                    context,
                    en: 'Transmission: ${car.transmission}',
                    fa: 'گیربکس: ${car.transmission}',
                  ),
                ),
              _buildSpecBadge(
                context: context,
                icon: Icons.shield_outlined,
                label: l10nPick(
                  context,
                  en: 'Deposit: \$${car.depositAmount.toInt()}',
                  fa: 'ودیعه: \$${car.depositAmount.toInt()}',
                ),
                semanticsLabel: l10nPick(
                  context,
                  en: 'Security deposit: \$${car.depositAmount.toInt()}',
                  fa: 'ودیعه ضمانت نقدی: \$${car.depositAmount.toInt()}',
                ),
              ),
              _buildSpecBadge(
                context: context,
                icon: Icons.person_outline_rounded,
                label: 'Age ${car.minAge}+',
                semanticsLabel: l10nPick(
                  context,
                  en: 'Minimum driver age: ${car.minAge} years',
                  fa: 'حداقل سن مجاز راننده: ${car.minAge} سال',
                ),
              ),
            ],
          ),

          SizedBox(height: ECardoTokens.space3.h),

          // Bottom Bar: Price & Book Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(
                      context,
                      en: 'Daily rate',
                      fa: 'نرخ روزانه',
                      ar: 'السعر اليومي',
                      zh: '日租金',
                    ),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: ECardoTokens.inkMuted(context),
                    ),
                  ),
                  Text(
                    '\$${car.dailyPrice.toStringAsFixed(0)} / day',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: ECardoTokens.brand500(context),
                    ),
                  ),
                ],
              ),
              Semantics(
                button: true,
                label: l10nPick(
                  context,
                  en: 'Book ${car.title} for \$${car.dailyPrice.toStringAsFixed(0)} per day',
                  fa: 'رزرو ${car.title} با \$${car.dailyPrice.toStringAsFixed(0)} روزانه',
                  ar: 'حجز ${car.title} بسعر \$${car.dailyPrice.toStringAsFixed(0)} يومياً',
                  zh: '以每日 \$${car.dailyPrice.toStringAsFixed(0)} 预订 ${car.title}',
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ECardoTokens.brand500(context),
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ECardoTokens.radiusMd.r,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    minimumSize: Size(120.w, 44.h),
                    elevation: 0,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showBookingSheet(context, car);
                  },
                  child: Text(
                    l10nPick(
                      context,
                      en: 'Book Vehicle',
                      fa: 'رزرو خودرو',
                      ar: 'حجز الآن',
                      zh: '立即预订',
                    ),
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecBadge({
    required BuildContext context,
    required IconData icon,
    required String label,
    String? semanticsLabel,
  }) {
    final sLabel = semanticsLabel ?? label;
    return Semantics(
      button: true,
      label: sLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            Clipboard.setData(ClipboardData(text: label));
            ToastHelper().showSuccessToast(
              l10nPick(
                context,
                en: '$label copied to clipboard',
                fa: '$label در حافظه کپی شد',
                ar: 'تم نسخ $label إلى الحافظة',
                zh: '已复制 $label 到剪贴板',
              ),
            );
          },
          borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
          child: Container(
            constraints: BoxConstraints(minHeight: 44.h, minWidth: 44.w),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: ECardoTokens.surfaceSunken(context),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14.sp, color: ECardoTokens.inkMuted(context)),
                SizedBox(width: 4.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: ECardoTokens.inkMuted(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
