import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../bookings/travel_checkout_screen.dart';
import '../core/controller/travel_controller.dart';
import '../core/models/travel_models.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';

/// Full-flow eSIM detail screen — bridges packages list and checkout.
/// Includes package specifications, APN setup, carrier networks,
/// interactive device compatibility checker, and activation instructions.
class EsimDetailScreen extends StatefulWidget {
  final TravelEsimPackage package;

  const EsimDetailScreen({super.key, required this.package});

  @override
  State<EsimDetailScreen> createState() => _EsimDetailScreenState();
}

class _EsimDetailScreenState extends State<EsimDetailScreen> {
  bool _compatibilityExpanded = false;

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
          child: Row(
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
                          const Icon(Icons.public_rounded, size: 16, color: TravelTheme.ink),
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

          // Activation Steps
          TravelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(
                    context,
                    en: 'How to Install & Activate',
                    fa: 'مراحل نصب و فعال‌سازی',
                    ar: 'طريقة التثبيت والتفعيل',
                    zh: '安装与激活步骤',
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: TravelTheme.ink,
                  ),
                ),
                SizedBox(height: 14.h),
                _StepTile(
                  number: '۱',
                  title: l10nPick(
                    context,
                    en: '1. Receive QR Code in receipt',
                    fa: '۱. دریافت بارکد QR بلافاصله پس از پرداخت',
                    ar: '١. استلام رمز QR في الإيصال فوراً',
                    zh: '1. 支付后在收据中获取专属二维码',
                  ),
                  subtitle: l10nPick(
                    context,
                    en: 'QR code and SM-DP+ manual code are generated instantly in your order voucher.',
                    fa: 'کد QR و اطلاعات دستی فعال‌سازی در رسید شما ثبت و ایمیل می‌شود.',
                    ar: 'يتم إنشاء رمز QR ومعلومات التفعيل فوراً في إيصال طلبك.',
                    zh: '收据和订单中会即时生成二维码与手动配置代码。',
                  ),
                ),
                SizedBox(height: 12.h),
                _StepTile(
                  number: '۲',
                  title: l10nPick(
                    context,
                    en: '2. Scan with camera or phone settings',
                    fa: '۲. اسکن با دوربین یا تنظیمات Cellular',
                    ar: '٢. المسح عبر الكاميرا أو إعدادات الشبكة',
                    zh: '2. 通过相机或蜂窝网络设置扫码',
                  ),
                  subtitle: l10nPick(
                    context,
                    en: 'Settings > Cellular > Add eSIM. Follow the on-screen steps while on Wi-Fi.',
                    fa: 'در تنظیمات گوشی به بخش Cellular/SIM رفته و گزینه Add eSIM را بزنید.',
                    ar: 'انتقل إلى الإعدادات > الخلوي > إضافة eSIM عبر اتصال الواي فاي.',
                    zh: '在Wi-Fi环境下前往 设置 > 蜂窝网络 > 添加 eSIM。',
                  ),
                ),
                SizedBox(height: 12.h),
                _StepTile(
                  number: '۳',
                  title: l10nPick(
                    context,
                    en: '3. Turn on Data Roaming upon arrival',
                    fa: '۳. روشن کردن رومینگ دیتا در کشور مقصد',
                    ar: '٣. تشغيل تجوال البيانات عند الوصول',
                    zh: '3. 抵达目的地后开启数据漫游',
                  ),
                  subtitle: l10nPick(
                    context,
                    en: 'When you arrive, set this eSIM as the cellular data line and enable Data Roaming.',
                    fa: 'پس از فرود در مقصد، رومینگ خط eSIM را فعال کنید تا اینترنت وصل شود.',
                    ar: 'عند الوصول، فعّل تجوال البيانات لهذا الخط ليعمل الإنترنت فوراً.',
                    zh: '抵达目的地后，将此 eSIM 设为移动数据线路并开启数据漫游。',
                  ),
                ),
              ],
            ),
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

class _StepTile extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;

  const _StepTile({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12.r,
          backgroundColor: TravelTheme.yellow,
          child: Text(
            number,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              color: TravelTheme.ink,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w800,
                  color: TravelTheme.ink,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: TravelTheme.muted,
                  height: 1.4,
                ),
              ),
            ],
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
