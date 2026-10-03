import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../core/models/travel_models.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';
import 'esim_detail_screen.dart';
import 'widgets/esim_data_usage_gauge.dart';

export 'esim_detail_screen.dart';
export 'widgets/esim_activation_card.dart';
export 'widgets/esim_data_usage_gauge.dart';

class EsimIntroScreen extends StatelessWidget {
  const EsimIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = ensureTravelController();
    final service = controller.serviceFor(TravelProductType.esim);
    final heroTitle =
        service?.presentation['hero_title']?.toString() ??
        localization.travelEsimIntroTitle;
    final heroSubtitle =
        service?.presentation['hero_subtitle']?.toString() ??
        localization.travelEsimIntroDescription;
    return TravelPage(
      title: localization.travelEsim,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CommonButton(
            width: double.infinity,
            text: localization.travelBrowseEsimPackages,
            textColor: TravelTheme.ink,
            backgroundColor: TravelTheme.yellow,
            onPressed: () => Get.to(() => const EsimPackagesScreen()),
          ),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          Container(
            height: 260.h,
            decoration: BoxDecoration(
              borderRadius: TravelTheme.radius,
              gradient: const LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [Color(0xFFFFE082), TravelTheme.yellow],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.sim_card_download_rounded,
                color: TravelTheme.ink,
                size: 120.r,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            heroTitle,
            style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 10.h),
          Text(
            heroSubtitle,
            style: TextStyle(
              color: TravelTheme.muted,
              fontSize: 13.sp,
              height: 1.7,
            ),
          ),
          SizedBox(height: 24.h),
          _Benefit(
            icon: Icons.phonelink_setup_rounded,
            title: localization.travelEsimDeviceReadinessTitle,
            subtitle: localization.travelEsimDeviceReadinessDescription,
          ),
          _Benefit(
            icon: Icons.public_rounded,
            title: localization.travelEsimCoverageTitle,
            subtitle: localization.travelEsimCoverageDescription,
          ),
          _Benefit(
            icon: Icons.payments_outlined,
            title: localization.travelEsimTransparentTitle,
            subtitle: localization.travelEsimTransparentDescription,
          ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Benefit({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TravelCard(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: TravelTheme.yellow.withValues(alpha: .25),
              child: Icon(icon, color: TravelTheme.ink),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(color: TravelTheme.muted, fontSize: 10.sp),
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

class EsimPackagesScreen extends StatefulWidget {
  const EsimPackagesScreen({super.key});

  @override
  State<EsimPackagesScreen> createState() => _EsimPackagesScreenState();
}

class _EsimPackagesScreenState extends State<EsimPackagesScreen> {
  final destinationController = TextEditingController();
  String searchedDestination = '';

  static const List<Map<String, String>> _popularDestinations = [
    {'code': 'TR', 'flag': '🇹🇷', 'name_fa': 'ترکیه', 'name_en': 'Turkey'},
    {'code': 'AE', 'flag': '🇦🇪', 'name_fa': 'امارات', 'name_en': 'UAE'},
    {'code': 'GE', 'flag': '🇬🇪', 'name_fa': 'گرجستان', 'name_en': 'Georgia'},
    {'code': 'TH', 'flag': '🇹🇭', 'name_fa': 'تایلند', 'name_en': 'Thailand'},
    {'code': 'DE', 'flag': '🇩🇪', 'name_fa': 'آلمان', 'name_en': 'Germany'},
    {'code': 'FR', 'flag': '🇫🇷', 'name_fa': 'فرانسه', 'name_en': 'France'},
    {'code': 'CN', 'flag': '🇨🇳', 'name_fa': 'چین', 'name_en': 'China'},
  ];

  @override
  void dispose() {
    destinationController.dispose();
    super.dispose();
  }

  Future<void> _searchPackages(String code) async {
    final controller = ensureTravelController();
    destinationController.text = code;
    final succeeded = await controller.loadEsimPackages(code);
    if (!mounted) return;
    if (succeeded) {
      setState(() => searchedDestination = code);
    } else {
      showTravelMessage(
        context,
        title: l10nPick(
          context,
          en: 'eSIM Packages',
          fa: 'بسته‌های سیم‌کارت',
          ar: 'باقات eSIM',
          zh: 'eSIM 套餐',
        ),
        message: l10nPick(
          context,
          en: 'Service temporarily unavailable. Please retry shortly.',
          fa: 'سرویس استعلام سیم‌کارت موقتاً در دسترس نیست. لطفاً مجدداً تلاش کنید.',
          ar: 'الخدمة غير متوفرة مؤقتاً. يرجى إعادة المحاولة لاحقاً.',
          zh: 'eSIM 服务暂时不可用，请稍后重试。',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = ensureTravelController();
    final service = controller.serviceFor(TravelProductType.esim);
    final destinationField = service?.searchFields.firstWhereOrNull(
      (field) => field.key == 'country_code',
    );
    return TravelPage(
      title: localization.travelEsimPackages,
      child: Obx(
        () => controller.isLoading.value && controller.esimPackages.isEmpty
            ? const CommonLoading()
            : ListView(
                padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 24.h),
                children: [
                  // Active eSIM Data Consumption Gauge
                  Padding(
                    padding: EdgeInsetsDirectional.only(bottom: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8.r,
                                  height: 8.r,
                                  decoration: const BoxDecoration(
                                    color: TravelTheme.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  l10nPick(
                                    context,
                                    en: 'My Active eSIM',
                                    fa: 'سیم‌کارت فعال من',
                                    ar: 'شريحتي النشطة',
                                    zh: '我的活跃 eSIM',
                                  ),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w900,
                                    color: TravelTheme.ink,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                final activePkg = controller.esimPackages.isNotEmpty
                                    ? controller.esimPackages.first
                                    : const TravelEsimPackage(
                                        id: 'active-esim-1',
                                        destinationCode: 'Turkey & Europe',
                                        dataLabel: '10.0 GB',
                                        validityDays: 14,
                                        total: TravelMoney(
                                          amount: 1900,
                                          currency: 'USD',
                                        ),
                                      );
                                Get.to(
                                  () => EsimDetailScreen(
                                    package: activePkg,
                                    isActive: true,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(8.r),
                              child: Padding(
                                padding: EdgeInsetsDirectional.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      l10nPick(
                                        context,
                                        en: 'View QR & Setup',
                                        fa: 'مشاهده بارکد و فعال‌سازی',
                                        ar: 'عرض الرمز والإعدادات',
                                        zh: '查看二维码与设置',
                                      ),
                                      style: TextStyle(
                                        fontSize: 11.5.sp,
                                        fontWeight: FontWeight.w800,
                                        color: TravelTheme.blue,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 11,
                                      color: TravelTheme.blue,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        EsimDataUsageGauge(
                          totalDataGb: 10.0,
                          usedDataGb: 6.4,
                          daysRemaining: 14,
                          countryOrRegion: 'Turkey & Europe',
                          planName:
                              'Active eSIM · 10.0 GB High-Speed Roaming',
                          onTopUpTap: () {
                            if (controller.esimPackages.isNotEmpty) {
                              Get.to(
                                () => EsimDetailScreen(
                                  package: controller.esimPackages.first,
                                  isActive: true,
                                ),
                              );
                            } else {
                              _searchPackages('TR');
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  CommonTextInputField(
                    controller: destinationController,
                    hintText:
                        destinationField?.hint ??
                        destinationField?.label ??
                        localization.travelDestination,
                    prefixIcon: const Icon(
                      Icons.public_rounded,
                      color: TravelTheme.yellow,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Quick Popular Destination Chips
                  SizedBox(
                    height: 36.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _popularDestinations.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final item = _popularDestinations[index];
                        final code = item['code']!;
                        final isSelected = searchedDestination == code;
                        return InkWell(
                          onTap: () => _searchPackages(code),
                          borderRadius: BorderRadius.circular(18.r),
                          child: Container(
                            padding: EdgeInsetsDirectional.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? TravelTheme.yellow
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18.r),
                              border: Border.all(
                                color: isSelected
                                    ? TravelTheme.ink
                                    : TravelTheme.border,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(item['flag'] ?? '', style: TextStyle(fontSize: 14.sp)),
                                SizedBox(width: 6.w),
                                Text(
                                  l10nPick(
                                    context,
                                    en: item['name_en']!,
                                    fa: item['name_fa']!,
                                  ),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w900
                                        : FontWeight.w600,
                                    color: TravelTheme.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 12.h),

                  TravelCard(
                    color: TravelTheme.yellow.withValues(alpha: .1),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: TravelTheme.ink,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            localization.travelEsimCompatibilityNotice,
                            style: TextStyle(
                              color: TravelTheme.muted,
                              fontSize: 11.sp,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  CommonButton(
                    width: double.infinity,
                    text: localization.travelBrowseEsimPackages,
                    textColor: TravelTheme.ink,
                    backgroundColor: TravelTheme.yellow,
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      final destination = destinationController.text
                          .trim()
                          .toUpperCase();
                      if (destination.isEmpty) {
                        showTravelMessage(
                          context,
                          title: localization.travelEsimPackages,
                          message: localization.travelDestination,
                        );
                        return;
                      }
                      _searchPackages(destination);
                    },
                  ),
                  SizedBox(height: 20.h),
                  TravelSectionHeader(
                    title: localization.travelChoosePackage,
                    action: searchedDestination.isEmpty
                        ? null
                        : '$searchedDestination · '
                              '${controller.esimPackages.length}',
                  ),
                  SizedBox(height: 10.h),
                  if (controller.searchError.value != null) ...[
                    Container(
                      padding: EdgeInsetsDirectional.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.08),
                        borderRadius: TravelTheme.radius,
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.cloud_off_rounded, color: Colors.orange, size: 36),
                          SizedBox(height: 8.h),
                          Text(
                            l10nPick(
                              context,
                              en: 'eSIM Service Temporarily Unavailable',
                              fa: 'سرویس خرید آنلاین سیم‌کارت موقتاً در دسترس نیست',
                              ar: 'خدمة باقات eSIM غير متوفرة مؤقتاً',
                              zh: 'eSIM 服务暂时不可用',
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            l10nPick(
                              context,
                              en: 'Backend travel partner API is undergoing scheduled maintenance.',
                              fa: 'ارتباط با ارائه‌دهنده بین‌المللی سیم‌کارت در حال به‌روزرسانی است.',
                              ar: 'يجري تحديث خوادم باقات eSIM مع مزود الخدمة.',
                              zh: '国际 eSIM 供应商正在进行系统维护。',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: TravelTheme.muted,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          TextButton.icon(
                            onPressed: () {
                              if (searchedDestination.isNotEmpty) {
                                _searchPackages(searchedDestination);
                              }
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: Text(
                              l10nPick(
                                context,
                                en: 'Retry Connection',
                                fa: 'تلاش مجدد',
                                ar: 'إعادة المحاولة',
                                zh: '重试连接',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ] else if (searchedDestination.isNotEmpty &&
                      controller.esimPackages.isEmpty)
                    TravelEmptyState(
                      message: localization.travelNoEsimPackages,
                    ),
                  ...controller.esimPackages.map(
                    (package) => Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 14.h),
                      child: _PackageCard(package: package),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final TravelEsimPackage package;

  const _PackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = ensureTravelController();
    final canPurchase = controller.canPurchase(TravelProductType.esim);
    return TravelCard(
      onTap: () {
        controller.selectedEsim.value = package;
        Get.to(() => EsimDetailScreen(package: package));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54.r,
                height: 54.r,
                decoration: BoxDecoration(
                  color: TravelTheme.yellow.withValues(alpha: .25),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: const Icon(
                  Icons.sim_card_rounded,
                  color: TravelTheme.ink,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        package.dataLabel,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        package.destinationCode,
                        style: TextStyle(
                          color: TravelTheme.muted,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (package.isPopular)
                Chip(
                  backgroundColor: TravelTheme.yellow,
                  label: Text(localization.travelMostPopular),
                ),
            ],
          ),
          const Divider(height: 28),
          Row(
            children: [
              Expanded(
                child: _PackageFact(
                  icon: Icons.public_rounded,
                  label: localization.travelDestinationCountry,
                  value: package.destinationCode,
                  forceLtr: true,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _PackageFact(
                  icon: Icons.calendar_today_rounded,
                  label: localization.travelEsimValidity,
                  value: localization.travelValidityDays(package.validityDays),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localization.travelTotal,
                      style: TextStyle(
                        color: TravelTheme.muted,
                        fontSize: 10.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        travelMoney(context, package.total),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 120.w,
                child: CommonButton(
                  height: 42,
                  text: canPurchase
                      ? localization.travelSelect
                      : localization.travelOfferUnavailable,
                  fontSize: 10,
                  textColor: canPurchase ? TravelTheme.ink : Colors.white,
                  backgroundColor: canPurchase
                      ? TravelTheme.yellow
                      : TravelTheme.muted,
                  onPressed: () {
                    controller.selectedEsim.value = package;
                    Get.to(() => EsimDetailScreen(package: package));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PackageFact extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool forceLtr;

  const _PackageFact({
    required this.icon,
    required this.label,
    required this.value,
    this.forceLtr = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: TravelTheme.background,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.r, color: TravelTheme.muted),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: TravelTheme.muted, fontSize: 9.sp),
                ),
                SizedBox(height: 2.h),
                Directionality(
                  textDirection: forceLtr
                      ? TextDirection.ltr
                      : Directionality.of(context),
                  child: Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
