import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/app_haptics.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../bookings/travel_checkout_screen.dart';
import '../core/models/travel_models.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';
import 'widgets/esim_activation_card.dart';
import 'widgets/esim_data_usage_gauge.dart';

/// Full-flow eSIM detail screen — bridges packages list, checkout,
/// active package data usage gauge, and QR code activation guide.
class EsimDetailScreen extends StatefulWidget {
  final TravelEsimPackage package;
  final bool isActive;
  final double? usedDataGb;
  final int? daysRemaining;
  final String? smdpAddress;
  final String? activationCode;
  final String? confirmationCode;
  final TravelOrder? order;

  const EsimDetailScreen({
    super.key,
    required this.package,
    this.isActive = false,
    this.usedDataGb,
    this.daysRemaining,
    this.smdpAddress,
    this.activationCode,
    this.confirmationCode,
    this.order,
  });

  @override
  State<EsimDetailScreen> createState() => _EsimDetailScreenState();
}

class _EsimDetailScreenState extends State<EsimDetailScreen> {
  late bool _showActiveMode;

  @override
  void initState() {
    super.initState();
    _showActiveMode = widget.isActive;
  }

  double _parseTotalDataGb(String dataLabel) {
    final match = RegExp(r'(\d+(?:\.\d+)?)\s*GB', caseSensitive: false)
        .firstMatch(dataLabel);
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 10.0;
    }
    return 10.0;
  }

  void _showTopUpBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: TravelTheme.border,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: TravelTheme.yellow.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: TravelTheme.ink,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(
                              context,
                              en: 'Top-Up eSIM Data',
                              fa: 'افزایش حجم بسته سیم‌کارت',
                              ar: 'إعادة شحن رصيد eSIM',
                              zh: '充值 eSIM 流量',
                            ),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: TravelTheme.ink,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${widget.package.destinationCode} · ${widget.package.dataLabel}',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: TravelTheme.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                // Top-Up Add-on Choices
                ...[
                  {'data': '1.0 GB', 'days': '7 Days', 'price': '\$3.50'},
                  {'data': '3.0 GB', 'days': '15 Days', 'price': '\$7.90'},
                  {'data': '5.0 GB', 'days': '30 Days', 'price': '\$11.50'},
                  {'data': '10.0 GB', 'days': '30 Days', 'price': '\$18.90'},
                ].map((addon) {
                  return Padding(
                    padding: EdgeInsetsDirectional.only(bottom: 10.h),
                    child: InkWell(
                      onTap: () {
                        AppHaptics.light();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10nPick(
                                context,
                                en: 'Selected ${addon['data']} top-up package',
                                fa: 'بسته افزایش حجم ${addon['data']} انتخاب شد',
                                ar: 'تم اختيار باقة ${addon['data']}',
                                zh: '已选择 ${addon['data']} 流量加油包',
                              ),
                            ),
                            backgroundColor: TravelTheme.ink,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: TravelTheme.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: TravelTheme.yellow.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: const Icon(
                                Icons.bolt_rounded,
                                color: TravelTheme.ink,
                                size: 18,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Text(
                                      addon['data']!,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w900,
                                        color: TravelTheme.ink,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    addon['days']!,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: TravelTheme.muted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              addon['price']!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w900,
                                color: TravelTheme.ink,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: TravelTheme.muted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCompatibilityDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 20.w, 24.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: TravelTheme.border,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: TravelTheme.yellow.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.phonelink_setup_rounded,
                          color: TravelTheme.ink,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            en: 'Device Compatibility Guide',
                            fa: 'راهنمای سازگاری گوشی با eSIM',
                            ar: 'دليل توافق الجهاز مع eSIM',
                            zh: '设备兼容性指南',
                          ),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            color: TravelTheme.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsetsDirectional.all(12.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: TravelTheme.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.dialpad_rounded, color: TravelTheme.blue),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            l10nPick(
                              context,
                              en: 'Dial *#06# on your device. If an "EID" number appears, your phone supports eSIM.',
                              fa: 'کد *#06# را در شماره‌گیر وارد کنید. اگر کد EID نمایش داده شد، گوشی شما از eSIM پشتیبانی می‌کند.',
                              ar: 'اطلب *#06# على جهازك. إذا ظهر رقم "EID"، فإن هاتفك يدعم eSIM.',
                              zh: '在拨号盘输入 *#06#。若出现 "EID" 码，说明您的设备支持 eSIM。',
                            ),
                            style: TextStyle(fontSize: 12.sp, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _BrandSection(
                    brand: 'Apple iPhone',
                    models: l10nPick(
                      context,
                      en: 'iPhone XR, XS, 11, 12, 13, 14, 15, 16 series & SE (2nd/3rd Gen).',
                      fa: 'سری‌های آیفون XR، XS، ۱۱، ۱۲، ۱۳، ۱۴، ۱۵، ۱۶ و SE (نسل ۲ و ۳).',
                      ar: 'سلسلة iPhone XR و XS و 11 و 12 و 13 و 14 و 15 و 16 و SE.',
                      zh: 'iPhone XR、XS、11、12、13、14、15、16 系列及 SE (第2/3代)。',
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _BrandSection(
                    brand: 'Samsung Galaxy',
                    models: l10nPick(
                      context,
                      en: 'Galaxy S20, S21, S22, S23, S24 series, Z Flip, Z Fold, Note 20.',
                      fa: 'سری‌های گلکسی S20، S21، S22، S23، S24، زد فلیپ، زد فولد و نوت ۲۰.',
                      ar: 'سلسلة Galaxy S20 و S21 و S22 و S23 و S24 و Z Flip و Z Fold.',
                      zh: 'Galaxy S20、S21、S22、S23、S24 系列、Z Flip、Z Fold。',
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _BrandSection(
                    brand: 'Google Pixel & Others',
                    models: l10nPick(
                      context,
                      en: 'Google Pixel 3 to 9 series, Xiaomi 12T Pro, 13/14 series, Huawei P40/Mate 40.',
                      fa: 'گوگل پیکسل ۳ تا ۹، شیائومی 12T Pro، سری‌های ۱۳ و ۱۴، هواوی P40.',
                      ar: 'سلسلة Google Pixel من 3 إلى 9، وشاومي 12T Pro و 13/14.',
                      zh: 'Google Pixel 3 至 9 系列、小米 12T Pro、13/14 系列。',
                    ),
                  ),
                  SizedBox(height: 20.h),
                  CommonButton(
                    width: double.infinity,
                    text: l10nPick(
                      context,
                      en: 'I Understand',
                      fa: 'متوجه شدم',
                      ar: 'فهمت ذلك',
                      zh: '我知道了',
                    ),
                    textColor: TravelTheme.ink,
                    backgroundColor: TravelTheme.yellow,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = ensureTravelController();
    final canPurchase = controller.canPurchase(TravelProductType.esim);
    final package = widget.package;

    return TravelPage(
      title: l10nPick(
        context,
        en: 'eSIM Package Details',
        fa: 'جزئیات بسته سیم‌کارت',
        ar: 'تفاصيل باقة eSIM',
        zh: 'eSIM 套餐详情',
      ),
      showTravelNavigation: false,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.all(16.r),
          child: _showActiveMode
              ? Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                  en: 'Active Line',
                                  fa: 'خط فعال',
                                  ar: 'الخط نشط',
                                  zh: '已激活线路',
                                ),
                                style: TextStyle(
                                  color: TravelTheme.green,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            l10nPick(
                              context,
                              en: 'Roaming Ready',
                              fa: 'آماده اتصال در مقصد',
                              ar: 'جاهز للتجوال',
                              zh: '随时漫游',
                            ),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w900,
                              color: TravelTheme.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 14.w),
                    SizedBox(
                      width: 160.w,
                      child: CommonButton(
                        text: l10nPick(
                          context,
                          en: '+ Top-Up Data',
                          fa: '+ افزایش حجم',
                          ar: '+ شحن البيانات',
                          zh: '+ 充值流量',
                        ),
                        textColor: TravelTheme.ink,
                        backgroundColor: TravelTheme.yellow,
                        onPressed: () {
                          AppHaptics.light();
                          _showTopUpBottomSheet(context);
                        },
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localization.travelTotal,
                            style: TextStyle(
                              color: TravelTheme.muted,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              travelMoney(context, package.total),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                color: TravelTheme.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 14.w),
                    SizedBox(
                      width: 170.w,
                      child: CommonButton(
                        text: canPurchase
                            ? l10nPick(
                                context,
                                en: 'Continue to Checkout',
                                fa: 'ادامه و پرداخت',
                                ar: 'المتابعة للدفع',
                                zh: '继续结账',
                              )
                            : localization.travelOfferUnavailable,
                        textColor: canPurchase ? TravelTheme.ink : Colors.white,
                        backgroundColor: canPurchase
                            ? TravelTheme.yellow
                            : TravelTheme.muted,
                        onPressed: canPurchase
                            ? () {
                                controller.selectedEsim.value = package;
                                Get.to(
                                  () => TravelCheckoutScreen(
                                    type: TravelProductType.esim,
                                    productId: package.id,
                                    title: package.destinationCode,
                                    total: package.total,
                                  ),
                                );
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
        ),
      ),
      child: ListView(
        padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 30.h),
        children: [
          // View Switcher Tab (Plan Specs vs Active Usage Meter & QR)
          Container(
            margin: EdgeInsetsDirectional.only(bottom: 16.h),
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF2F5),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      AppHaptics.light();
                      setState(() => _showActiveMode = false);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsetsDirectional.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: !_showActiveMode
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: !_showActiveMode
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 15.sp,
                            color: !_showActiveMode
                                ? TravelTheme.ink
                                : TravelTheme.muted,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            l10nPick(
                              context,
                              en: 'Plan Details',
                              fa: 'مشخصات بسته',
                              ar: 'تفاصيل الباقة',
                              zh: '套餐详情',
                            ),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: !_showActiveMode
                                  ? FontWeight.w900
                                  : FontWeight.w600,
                              color: !_showActiveMode
                                  ? TravelTheme.ink
                                  : TravelTheme.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      AppHaptics.light();
                      setState(() => _showActiveMode = true);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsetsDirectional.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color:
                            _showActiveMode ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: _showActiveMode
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.speed_rounded,
                            size: 15.sp,
                            color: _showActiveMode
                                ? TravelTheme.ink
                                : TravelTheme.muted,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            l10nPick(
                              context,
                              en: 'Usage Meter & QR',
                              fa: 'حجم مصرفی و بارکد',
                              ar: 'استهلاك البيانات و QR',
                              zh: '流量计量与二维码',
                            ),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: _showActiveMode
                                  ? FontWeight.w900
                                  : FontWeight.w600,
                              color: _showActiveMode
                                  ? TravelTheme.ink
                                  : TravelTheme.muted,
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

          if (_showActiveMode) ...[
            // Active eSIM Data Usage Gauge
            EsimDataUsageGauge(
              totalDataGb: _parseTotalDataGb(package.dataLabel),
              usedDataGb: widget.usedDataGb ?? 6.4,
              daysRemaining: widget.daysRemaining ??
                  (package.validityDays > 0 ? package.validityDays : 14),
              countryOrRegion: package.destinationCode,
              planName: '${package.destinationCode} · ${package.dataLabel}',
              onTopUpTap: () => _showTopUpBottomSheet(context),
            ),
            SizedBox(height: 18.h),

            // eSIM Activation Card with QR code & SM-DP+ manual code
            EsimActivationCard(
              smdpAddress: widget.smdpAddress ??
                  widget.order?.details['esim_smdp_address'] ??
                  'rsp.truphone.com',
              activationCode: widget.activationCode ??
                  widget.order?.details['esim_activation_code'] ??
                  'LPA:1\$rsp.truphone.com\$EC-TR-98421-B884',
              confirmationCode: widget.confirmationCode ??
                  widget.order?.details['esim_confirmation_code'] ??
                  'None',
              countryOrRegion: package.destinationCode,
              iccid: widget.order?.details['esim_iccid'] ??
                  '89014103211118510720',
            ),
            SizedBox(height: 18.h),
          ] else ...[
            // Hero Package Banner
            Container(
              padding: EdgeInsetsDirectional.all(20.r),
              decoration: BoxDecoration(
                borderRadius: TravelTheme.radius,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF3B0), Color(0xFFFFD54F)],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
                boxShadow: TravelTheme.shadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.public_rounded,
                                size: 16, color: TravelTheme.ink),
                            SizedBox(width: 6.w),
                            Text(
                              package.destinationCode,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w900,
                                color: TravelTheme.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (package.isPopular)
                        Container(
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: TravelTheme.ink,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            localization.travelMostPopular,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    package.dataLabel,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w900,
                      color: TravelTheme.ink,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    l10nPick(
                      context,
                      en: 'High-speed 4G / 5G Roaming Data',
                      fa: 'اینترنت پرسرعت 4G / 5G بدون نیاز به سیم‌کارت فیزیکی',
                      ar: 'بيانات تجوال 4G / 5G عالية السرعة',
                      zh: '高速 4G / 5G 漫游数据',
                    ),
                    style: TextStyle(
                      color: TravelTheme.ink.withValues(alpha: 0.8),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
          ],

          // Specifications Card
          TravelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(
                    context,
                    en: 'Plan Specifications',
                    fa: 'مشخصات بسته',
                    ar: 'مواصفات الباقة',
                    zh: '套餐规格',
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: TravelTheme.ink,
                  ),
                ),
                SizedBox(height: 12.h),
                _SpecRow(
                  icon: Icons.timelapse_rounded,
                  label: localization.travelEsimValidity,
                  value: localization.travelValidityDays(package.validityDays),
                ),
                const Divider(height: 20),
                _SpecRow(
                  icon: Icons.network_check_rounded,
                  label: l10nPick(
                    context,
                    en: 'Network Speed',
                    fa: 'سرعت و نسل شبکه',
                    ar: 'سرعة الشبكة',
                    zh: '网络速度',
                  ),
                  value: '4G LTE / 5G',
                ),
                const Divider(height: 20),
                _SpecRow(
                  icon: Icons.wifi_tethering_rounded,
                  label: l10nPick(
                    context,
                    en: 'Personal Hotspot / Tethering',
                    fa: 'اشتراک‌گذاری اینترنت (هات‌اسپات)',
                    ar: 'نقطة اتصال شخصية / بث',
                    zh: '个人热点分享',
                  ),
                  value: l10nPick(
                    context,
                    en: 'Supported',
                    fa: 'پشتیبانی می‌شود',
                    ar: 'مدعوم',
                    zh: '支持',
                  ),
                ),
                const Divider(height: 20),
                _SpecRow(
                  icon: Icons.sim_card_outlined,
                  label: l10nPick(
                    context,
                    en: 'Plan Type',
                    fa: 'نوع سرویس',
                    ar: 'نوع الخدمة',
                    zh: '服务类型',
                  ),
                  value: l10nPick(
                    context,
                    en: 'Data-only (VoIP apps active)',
                    fa: 'دیتا (واتساپ و پیام‌رسان‌ها فعال)',
                    ar: 'بيانات فقط (تطبيقات الاتصال تعمل)',
                    zh: '仅数据流量（支持VoIP通话）',
                  ),
                ),
                const Divider(height: 20),
                _SpecRow(
                  icon: Icons.settings_input_antenna_rounded,
                  label: l10nPick(
                    context,
                    en: 'APN Configuration',
                    fa: 'تنظیمات APN',
                    ar: 'إعدادات APN',
                    zh: 'APN 设置',
                  ),
                  value: l10nPick(
                    context,
                    en: 'Automatic / GlobalData',
                    fa: 'خودکار (Automatic)',
                    ar: 'تلقائي',
                    zh: '自动配置',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Device Compatibility Checker Card
          TravelCard(
            color: const Color(0xFFF5F9FF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: const BoxDecoration(
                        color: TravelTheme.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.phonelink_setup_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(
                              context,
                              en: 'Is your phone compatible?',
                              fa: 'آیا گوشی شما از eSIM پشتیبانی می‌کند؟',
                              ar: 'هل هاتفك متوافق مع eSIM؟',
                              zh: '您的手机是否支持 eSIM？',
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.sp,
                              color: TravelTheme.ink,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            l10nPick(
                              context,
                              en: 'Check before purchasing to ensure support.',
                              fa: 'پیش از خرید سازگاری دستگاه خود را بررسی کنید.',
                              ar: 'تحقق قبل الشراء للتأكد من التوافق.',
                              zh: '购买前请确认您的设备支持 eSIM。',
                            ),
                            style: TextStyle(
                              color: TravelTheme.muted,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                InkWell(
                  onTap: () => _showCompatibilityDialog(context),
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: TravelTheme.blue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: TravelTheme.blue,
                          size: 18,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          l10nPick(
                            context,
                            en: 'Open Device Compatibility Checker',
                            fa: 'بررسی لیست کامل مدل‌های سازگار',
                            ar: 'عرض الأجهزة المتوافقة',
                            zh: '查看兼容机型列表',
                          ),
                          style: TextStyle(
                            color: TravelTheme.blue,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Activation Guide & QR Code Card
          EsimActivationCard(
            smdpAddress: widget.smdpAddress ??
                widget.order?.details['esim_smdp_address'] ??
                'rsp.truphone.com',
            activationCode: widget.activationCode ??
                widget.order?.details['esim_activation_code'] ??
                'LPA:1\$rsp.truphone.com\$EC-TR-98421-B884',
            confirmationCode: widget.confirmationCode ??
                widget.order?.details['esim_confirmation_code'] ??
                'None',
            countryOrRegion: package.destinationCode,
            iccid: widget.order?.details['esim_iccid'] ??
                '89014103211118510720',
          ),
          SizedBox(height: 16.h),

          // Refund Policy Guarantee
          Container(
            padding: EdgeInsetsDirectional.all(14.r),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: TravelTheme.radius,
              border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.security_rounded, color: Colors.green),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    l10nPick(
                      context,
                      en: '100% Refund Guarantee if package is uninstalled & unactivated within 30 days.',
                      fa: 'ضمانت بازگشت ۱۰۰٪ وجه در صورت عدم نصب و فعال‌سازی تا ۳۰ روز.',
                      ar: 'ضمان استرداد ١٠٠٪ في حال عدم التثبيت أو التفعيل خلال ٣٠ يوماً.',
                      zh: '若30天内未安装或激活，享100%全额退款保障。',
                    ),
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w700,
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

class _SpecRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SpecRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: TravelTheme.blue),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: TravelTheme.muted,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: TravelTheme.ink,
          ),
        ),
      ],
    );
  }
}

class _BrandSection extends StatelessWidget {
  final String brand;
  final String models;

  const _BrandSection({required this.brand, required this.models});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          brand,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w900,
            color: TravelTheme.ink,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          models,
          style: TextStyle(
            fontSize: 11.5.sp,
            color: TravelTheme.muted,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
