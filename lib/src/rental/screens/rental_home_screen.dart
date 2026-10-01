import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/rental_controller.dart';
import '../models/rental_models.dart';
import 'rental_voucher_screen.dart';

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

  static const CATEGORIES = ['all', 'ECONOMY', 'SUV', 'LUXURY', 'VAN'];

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
      case 'ECONOMY': return l10nPick(context, en: 'Economy', fa: 'اقتصادی');
      case 'SUV': return l10nPick(context, en: 'SUV', fa: 'شاسی');
      case 'LUXURY': return l10nPick(context, en: 'Luxury', fa: 'لاکچری');
      case 'VAN': return l10nPick(context, en: 'Van', fa: 'ون');
      default: return l10nPick(context, en: 'All', fa: 'همه');
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

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(car.title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800)),
              SizedBox(height: 6.h),
              Text(l10nPick(context,
                en: '${car.dailyPrice}/day · Deposit ${car.depositAmount}',
                fa: '${car.dailyPrice} روزانه · ودیعه ${car.depositAmount}')),
              SizedBox(height: 12.h),
              Text(l10nPick(context, en: 'Insurance tier (required)', fa: 'سطح بیمه (اجباری)'),
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.sp)),
              ...car.insuranceTiers.map((t) => RadioListTile<String>(
                dense: true,
                value: t['tier'].toString(),
                groupValue: insuranceTier,
                onChanged: (v) => setSheetState(() => insuranceTier = v!),
                title: Text('${t['tier']} (+${t['extra_cost']})', style: TextStyle(fontSize: 11.sp)),
              )),
              SizedBox(height: 12.h),
              Row(children: [
                Expanded(child: ElevatedButton(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (d != null) setSheetState(() => pickup = d);
                  },
                  child: Text(pickup == null
                    ? l10nPick(context, en: 'Pickup date', fa: 'تاریخ تحویل')
                    : pickup!.toLocal().toString().split(' ').first),
                )),
                SizedBox(width: 8.w),
                Expanded(child: ElevatedButton(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 3)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (d != null) setSheetState(() => returnAt = d);
                  },
                  child: Text(returnAt == null
                    ? l10nPick(context, en: 'Return date', fa: 'تاریخ استرداد')
                    : returnAt!.toLocal().toString().split(' ').first),
                )),
              ]),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
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
                    if (err != null) {
                      Get.snackbar(l10nPick(context, en: 'Error', fa: 'خطا'), err,
                        backgroundColor: Colors.red, colorText: Colors.white);
                    } else {
                      _tabController.animateTo(1);
                      Get.snackbar(l10nPick(context, en: 'Booked', fa: 'رزرو شد'),
                        l10nPick(context, en: 'Price locked for 1 hour — upload driver docs.',
                          fa: 'قیمت ۱ ساعت قفل شد؛ مدارک راننده را بارگذاری کنید.'),
                        backgroundColor: Colors.green, colorText: Colors.white);
                    }
                  },
                  child: Text(l10nPick(context, en: 'Book Car', fa: 'رزرو خودرو'),
                    style: const TextStyle(color: Colors.white)),
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
      appBar: AppBar(
        title: Text(l10nPick(context, en: 'Car Rental', fa: 'رنت ماشین در سفر')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10nPick(context, en: 'Cars', fa: 'خودروها')),
            Tab(text: l10nPick(context, en: 'My Bookings', fa: 'رزروهای من')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // تب ۱: فهرست و جست‌وجوی خودروها
          Column(children: [
            SizedBox(
              height: 40.h,
              child: Obx(() => ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                children: CATEGORIES.map((c) => Padding(
                  padding: EdgeInsetsDirectional.only(start: 8.w),
                  child: ChoiceChip(
                    label: Text(_categoryLabel(context, c)),
                    selected: controller.selectedCategory.value == c,
                    onSelected: (_) {
                      controller.selectedCategory.value = c;
                      controller.fetchCars();
                    },
                  ),
                )).toList(),
              )),
            ),
            Expanded(child: Obx(() {
              if (controller.isLoadingCars.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.isServiceUnavailable.value) {
                return Center(
                  child: Padding(
                    padding: EdgeInsetsDirectional.all(24.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cloud_off_rounded,
                            color: Colors.orange,
                            size: 40,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          l10nPick(
                            context,
                            en: 'Car Rental Service Temporarily Unavailable',
                            fa: 'سرویس رنت خودرو موقتاً در دسترس نیست',
                            ar: 'خدمة تأجير السيارات غير متوفرة مؤقتاً',
                            zh: '租车服务暂时不可用',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: TravelTheme.ink,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          l10nPick(
                            context,
                            en: 'Car rental fleet endpoints (/rental/cars) are undergoing backend integration. Please retry shortly.',
                            fa: 'ارتباط با سامانه مدیریت ناوگان خودرو (/rental/cars) در حال همگام‌سازی است. به زودی در دسترس خواهد بود.',
                            ar: 'خوادم أسطول السيارات قيد التحديث مع المزودين.',
                            zh: '租车车队接口正在与后台合作伙伴联调中，稍后恢复。',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TravelTheme.muted,
                            fontSize: 11.5.sp,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsetsDirectional.symmetric(
                              horizontal: 20.w,
                              vertical: 10.h,
                            ),
                          ),
                          onPressed: () => controller.fetchCars(),
                          icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                          label: Text(
                            l10nPick(
                              context,
                              en: 'Retry Connection',
                              fa: 'تلاش مجدد',
                              ar: 'إعادة المحاولة',
                              zh: '重试连接',
                            ),
                            style: const TextStyle(color: Colors.white, fontSize: 12.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (controller.cars.isEmpty) {
                return Center(
                  child: Text(
                    l10nPick(
                      context,
                      en: 'No cars found',
                      fa: 'خودرویی در این کلاس یافت نشد',
                      ar: 'لم يتم العثور على سيارات',
                      zh: '未找到符合条件的车辆',
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsetsDirectional.all(16.w),
                itemCount: controller.cars.length,
                itemBuilder: (context, i) {
                  final car = controller.cars[i];
                  return Card(
                    margin: EdgeInsetsDirectional.only(bottom: 8.h),
                    child: ListTile(
                      title: Text(car.title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp)),
                      subtitle: Text(l10nPick(context,
                        en: '${_categoryLabel(context, car.category)} · ${car.dailyPrice}/day · Deposit ${car.depositAmount}',
                        fa: '${_categoryLabel(context, car.category)} · ${car.dailyPrice} روزانه · ودیعه ${car.depositAmount}')),
                      trailing: Container(
                        padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: car.isFleet ? Colors.green.withValues(alpha: 0.12) : Colors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(car.isFleet
                          ? l10nPick(context, en: 'Instant', fa: 'تأیید آنی')
                          : l10nPick(context, en: 'Host', fa: 'میزبان'),
                          style: TextStyle(fontSize: 9.sp)),
                      ),
                      onTap: () => _showBookingSheet(context, car),
                    ),
                  );
                },
              );
            })),
          ]),

          // تب ۲: رزروهای من
          Obx(() {
            if (controller.isLoadingBookings.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.myBookings.isEmpty) {
              return Center(child: Text(l10nPick(context, en: 'No bookings yet', fa: 'هنوز رزروی ثبت نکرده‌اید')));
            }
            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: controller.myBookings.length,
              itemBuilder: (context, i) {
                final b = controller.myBookings[i];
                return Card(
                  margin: EdgeInsets.only(bottom: 8.h),
                  child: ListTile(
                    title: Text(b.bookingNo, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp)),
                    subtitle: Text(b.car?.title ?? l10nPick(context, en: 'Booking', fa: 'رزرو خودرو'),
                      style: TextStyle(fontSize: 11.sp)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: AppColors.lightPrimary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(_statusFa(b.status),
                            style: TextStyle(fontSize: 9.sp, color: AppColors.lightPrimary)),
                        ),
                        const Icon(Icons.chevron_right, size: 18),
                      ],
                    ),
                    onTap: () => Get.toNamed(BaseRoute.rentalDetail, arguments: b.id),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
