import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_single_date_picker.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../services/mock_travel_data.dart';
import '../services/travel_service_request.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';

enum InsuranceZone {
  schengen,
  worldwide,
  middleEast,
  asia,
}

class InsurancePlan {
  final String id;
  final String titleEn;
  final String titleFa;
  final String coverageLimit;
  final int basePrice;
  final List<String> benefits;
  final Color color;

  const InsurancePlan({
    required this.id,
    required this.titleEn,
    required this.titleFa,
    required this.coverageLimit,
    required this.basePrice,
    required this.benefits,
    required this.color,
  });
}

const List<InsurancePlan> defaultInsurancePlans = [
  InsurancePlan(
    id: 'basic',
    titleEn: 'Basic Schengen Plan',
    titleFa: 'پلن پایه (استاندارد شنگن)',
    coverageLimit: '€30,000',
    basePrice: 420000,
    benefits: [
      'پوشش هزینه‌های فوریت‌های پزشکی تا ۳۰,۰۰۰ یورو',
      'بازگرداندن بیمار یا متوفی به کشور',
      'پوشش فوریت‌های دندانپزشکی تا ۲۰۰ یورو',
    ],
    color: Color(0xFF2563EB),
  ),
  InsurancePlan(
    id: 'standard',
    titleEn: 'Standard Comprehensive',
    titleFa: 'پلن جامع پلاس (شنگن + کرونا)',
    coverageLimit: '€50,000',
    basePrice: 780000,
    benefits: [
      'پوشش هزینه‌های پزشکی و بیمارستانی تا ۵۰,۰۰۰ یورو',
      'پوشش کامل بیماری کرونا (COVID-19)',
      'جبران خسارت گم شدن یا تأخیر چمدان تا ۱,۰۰۰ یورو',
      'پوشش کنسلی یا تأخیر پرواز بیش از ۶ ساعت',
    ],
    color: Color(0xFF0D9488),
  ),
  InsurancePlan(
    id: 'vip',
    titleEn: 'Worldwide Gold VIP',
    titleFa: 'پلن طلایی VIP جهانی',
    coverageLimit: '€100,000',
    basePrice: 1450000,
    benefits: [
      'سقف پوشش تا ۱۰۰,۰۰۰ یورو در سراسر جهان (شامل آمریکا و کانادا)',
      'پوشش بازگشت همراه بیمار و سرپرستی کودک',
      'کمک‌رسانی حقوقی و انتقال وجه اضطراری',
      'پشتیبانی مستقیم SOS ۲۴ ساعته بین‌المللی',
    ],
    color: Color(0xFFD97706),
  ),
];

class TravelInsuranceScreen extends StatefulWidget {
  const TravelInsuranceScreen({super.key});

  @override
  State<TravelInsuranceScreen> createState() => _TravelInsuranceScreenState();
}

class _TravelInsuranceScreenState extends State<TravelInsuranceScreen> {
  InsuranceZone _zone = InsuranceZone.schengen;
  int _durationDays = 15;
  InsurancePlan _selectedPlan = defaultInsurancePlans[1];
  DateTime _startDate = DateTime.now().add(const Duration(days: 3));

  final _formKey = GlobalKey<FormState>();
  final _fullNameEnController = TextEditingController();
  final _passportController = TextEditingController();
  final _nationalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController(text: '1995-05-15');

  @override
  void dispose() {
    _fullNameEnController.dispose();
    _passportController.dispose();
    _nationalCodeController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  int get _calculatedPrice {
    final ratio = switch (_durationDays) {
      7 => 0.8,
      15 => 1.0,
      30 => 1.5,
      60 => 2.2,
      92 => 2.8,
      _ => 4.0,
    };
    return (_selectedPlan.basePrice * ratio).toInt();
  }

  Future<void> _submitOrder(BuildContext context) async {
    final localization = AppLocalizations.of(context)!;
    if (_formKey.currentState?.validate() != true) return;

    final ref = TravelServiceRequest.generateReference();
    final request = TravelServiceRequest(
      id: 'ins-${DateTime.now().microsecondsSinceEpoch}',
      serviceKey: 'insurance',
      title: 'بیمه مسافرتی ${_selectedPlan.titleFa}',
      subtitle: '${_selectedPlan.coverageLimit} · $_durationDays روزه',
      amountLabel: '${formatMockAmount(_calculatedPrice)} ${localization.travelMockCurrency}',
      reference: ref,
      createdAt: DateTime.now(),
      details: {
        'Zone': _zone.name,
        'Duration': '$_durationDays Days',
        'Plan': _selectedPlan.titleEn,
        'Coverage': _selectedPlan.coverageLimit,
        'Insured': _fullNameEnController.text.trim(),
        'Passport': _passportController.text.trim().toUpperCase(),
        'National ID': _nationalCodeController.text.trim(),
        'Start Date': DateFormat('yyyy-MM-dd').format(_startDate),
      },
    );
    await TravelServiceRequestStore.add(request);

    Get.off(
      () => InsuranceCertificateScreen(
        policyNumber: 'INS-$ref',
        plan: _selectedPlan,
        insuredName: _fullNameEnController.text.trim(),
        passportNumber: _passportController.text.trim().toUpperCase(),
        durationDays: _durationDays,
        startDate: _startDate,
        totalPrice: _calculatedPrice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return TravelPage(
      title: l10nPick(
        context,
        en: 'Travel Insurance',
        fa: 'بیمه مسافرتی بین‌المللی',
        ar: 'التأمين الصحي للسفر',
        zh: '境外旅游意外保险',
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
                      style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${formatMockAmount(_calculatedPrice)} ${localization.travelMockCurrency}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: _selectedPlan.color,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 14.w),
              SizedBox(
                width: 170.w,
                child: CommonButton(
                  text: l10nPick(
                    context,
                    en: 'Issue Policy Online',
                    fa: 'صدور آنلاین بیمه‌نامه',
                    ar: 'إصدار الوثيقة فوراً',
                    zh: '即时在线出单',
                  ),
                  backgroundColor: _selectedPlan.color,
                  onPressed: () => _submitOrder(context),
                ),
              ),
            ],
          ),
        ),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 30.h),
          children: [
            // Hero Card
            Container(
              padding: EdgeInsetsDirectional.all(20.r),
              decoration: BoxDecoration(
                borderRadius: TravelTheme.radius,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
                boxShadow: TravelTheme.shadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10nPick(
                            context,
                            en: 'Instant Embassy-Approved Coverage',
                            fa: 'صدور فوری بیمه‌نامه مورد تأیید سفارت‌ها',
                            ar: 'تأمين فوري معتمد لدى جميع السفارات',
                            zh: '使领馆认可的合规出境保单',
                          ),
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          l10nPick(
                            context,
                            en: 'Official PDF with QR code sent immediately. Valid for Schengen, UK, Canada, & worldwide visas.',
                            fa: 'نسخه رسمی با کد QR اختصاصی، بلافاصله پس از پرداخت صادر و ایمیل می‌شود.',
                            ar: 'نسخة رقمية رسمية مع رمز QR صالحة لكافة أنواع التأشيرات.',
                            zh: '即时出具带二维码的官方电子保单，满足申根及全球签证要求。',
                          ),
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  const Icon(Icons.health_and_safety_rounded, size: 54, color: Colors.white),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Destination Zone Selector
            Text(
              l10nPick(context, en: 'Destination Zone', fa: 'منطقه سفر و مقصد', ar: 'منطقة السفر', zh: '出行目的地分类'),
              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w900, color: TravelTheme.ink),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _ZoneChip(
                  label: l10nPick(context, en: 'Schengen Area (EU)', fa: 'حوزه شنگن و اروپا', ar: 'منطقة شنغن', zh: '申根欧洲'),
                  selected: _zone == InsuranceZone.schengen,
                  onTap: () => setState(() => _zone = InsuranceZone.schengen),
                ),
                _ZoneChip(
                  label: l10nPick(context, en: 'Worldwide (All Countries)', fa: 'سراسر جهان (کلیه کشورها)', ar: 'جميع أنحاء العالم', zh: '全球通用'),
                  selected: _zone == InsuranceZone.worldwide,
                  onTap: () => setState(() => _zone = InsuranceZone.worldwide),
                ),
                _ZoneChip(
                  label: l10nPick(context, en: 'Turkey & Middle East', fa: 'ترکیه و خاورمیانه', ar: 'تركيا والشرق الأوسط', zh: '土耳其与中东'),
                  selected: _zone == InsuranceZone.middleEast,
                  onTap: () => setState(() => _zone = InsuranceZone.middleEast),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Trip Duration Chips
            Text(
              l10nPick(context, en: 'Trip Duration (Days)', fa: 'مدت سفر (تعداد روز)', ar: 'مدة الإقامة (بالأيام)', zh: '保障天数'),
              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w900, color: TravelTheme.ink),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [7, 15, 30, 60, 92].map((days) {
                final isSelected = _durationDays == days;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(end: 6.w),
                    child: InkWell(
                      onTap: () => setState(() => _durationDays = days),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        padding: EdgeInsetsDirectional.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected ? TravelTheme.blue : Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: isSelected ? TravelTheme.blue : TravelTheme.border),
                        ),
                        child: Center(
                          child: Text(
                            '$days ${l10nPick(context, en: 'd', fa: 'روز', ar: 'يوم', zh: '天')}',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                              color: isSelected ? Colors.white : TravelTheme.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),

            // Plans Comparison Section
            Text(
              l10nPick(context, en: 'Select Coverage Plan', fa: 'انتخاب سطح پوشش بیمه', ar: 'اختر باقة التأمين', zh: '选择保障方案'),
              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w900, color: TravelTheme.ink),
            ),
            SizedBox(height: 10.h),
            ...defaultInsurancePlans.map((plan) {
              final isSelected = _selectedPlan.id == plan.id;
              return Padding(
                padding: EdgeInsetsDirectional.only(bottom: 12.h),
                child: InkWell(
                  onTap: () => setState(() => _selectedPlan = plan),
                  borderRadius: TravelTheme.radius,
                  child: Container(
                    padding: EdgeInsetsDirectional.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: TravelTheme.radius,
                      border: Border.all(
                        color: isSelected ? plan.color : TravelTheme.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected ? TravelTheme.shadow : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 12.r,
                                  backgroundColor: isSelected ? plan.color : TravelTheme.border,
                                  child: isSelected
                                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                                      : null,
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  l10nPick(context, en: plan.titleEn, fa: plan.titleFa),
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w900,
                                    color: TravelTheme.ink,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: plan.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                plan.coverageLimit,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w900,
                                  color: plan.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        ...plan.benefits.map((b) => Padding(
                          padding: EdgeInsetsDirectional.only(bottom: 4.h),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline_rounded, size: 15, color: plan.color),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  b,
                                  style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              );
            }),
            SizedBox(height: 16.h),

            // Insured Person Form
            TravelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(context, en: 'Insured Traveler Details', fa: 'مشخصات بیمه‌گذار (مطابق گذرنامه)', ar: 'بيانات المؤمن عليه', zh: '被保险人身份信息'),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: TravelTheme.ink),
                  ),
                  SizedBox(height: 12.h),

                  // Full Name in English
                  TextFormField(
                    controller: _fullNameEnController,
                    decoration: InputDecoration(
                      labelText: l10nPick(context, en: 'Full Name in English (as in Passport)', fa: 'نام و نام خانوادگی به انگلیسی (مطابق پاسپورت)', ar: 'الاسم الكامل بالإنجليزية', zh: '护照英文姓名（大写）'),
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return localization.travelFormRequired;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),

                  // Passport Number
                  TextFormField(
                    controller: _passportController,
                    decoration: InputDecoration(
                      labelText: l10nPick(context, en: 'Passport Number', fa: 'شماره گذرنامه', ar: 'رقم جواز السفر', zh: '护照号码'),
                      prefixIcon: const Icon(Icons.menu_book_rounded),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return localization.travelFormRequired;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),

                  // National Code
                  TextFormField(
                    controller: _nationalCodeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10nPick(context, en: 'National ID Number', fa: 'کد ملی مسافر', ar: 'الرقم القومي', zh: '身份证号'),
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return localization.travelFormRequired;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),

                  // Start Date Picker
                  CommonSingleDatePicker(
                    initialDate: _startDate,
                    firstDate: DateTime.now(),
                    hintText: l10nPick(context, en: 'Insurance Start Date', fa: 'تاریخ شروع پوشش بیمه', ar: 'تاريخ بدء التأمين', zh: '起保日期'),
                    suffixIcon: const Icon(Icons.calendar_month_rounded, size: 18),
                    onDateSelected: (d) => setState(() => _startDate = d),
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

class _ZoneChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ZoneChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? TravelTheme.blue : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: selected ? TravelTheme.blue : TravelTheme.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? Colors.white : TravelTheme.ink,
          ),
        ),
      ),
    );
  }
}

/// Digital Certificate of Insurance
class InsuranceCertificateScreen extends StatelessWidget {
  final String policyNumber;
  final InsurancePlan plan;
  final String insuredName;
  final String passportNumber;
  final int durationDays;
  final DateTime startDate;
  final int totalPrice;

  const InsuranceCertificateScreen({
    super.key,
    required this.policyNumber,
    required this.plan,
    required this.insuredName,
    required this.passportNumber,
    required this.durationDays,
    required this.startDate,
    required this.totalPrice,
  });

  String _generateBarcodeSvg() {
    final barcode = Barcode.code128();
    return barcode.toSvg(
      policyNumber,
      width: 260,
      height: 60,
      drawText: false,
    );
  }

  String _generateQrSvg() {
    final barcode = Barcode.qrCode();
    return barcode.toSvg(
      'INSURANCE-POLICY-$policyNumber-$insuredName-${plan.coverageLimit}',
      width: 140,
      height: 140,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final endDate = startDate.add(Duration(days: durationDays));

    return TravelPage(
      title: l10nPick(
        context,
        en: 'Insurance Certificate',
        fa: 'بیمه‌نامه رسمی مسافرتی',
        ar: 'وثيقة التأمين الرسمية',
        zh: '电子保单凭证',
      ),
      showTravelNavigation: false,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.all(16.r),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsetsDirectional.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    side: const BorderSide(color: TravelTheme.border),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: policyNumber));
                    showTravelMessage(
                      context,
                      title: l10nPick(context, en: 'Policy Copied', fa: 'شماره بیمه‌نامه کپی شد', ar: 'تم نسخ رقم الوثيقة', zh: '保单号已复制'),
                      message: policyNumber,
                    );
                  },
                  child: Text(
                    l10nPick(context, en: 'Copy Policy No', fa: 'کپی شماره بیمه‌نامه', ar: 'نسخ رقم الوثيقة', zh: '复制保单号'),
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: TravelTheme.ink),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CommonButton(
                  text: l10nPick(context, en: 'Back to Travel', fa: 'بازگشت به خدمات سفر', ar: 'العودة لخدمات السفر', zh: '返回旅游服务'),
                  textColor: Colors.white,
                  backgroundColor: plan.color,
                  onPressed: () => Get.offAllNamed(BaseRoute.travel),
                ),
              ),
            ],
          ),
        ),
      ),
      child: ListView(
        padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 30.h),
        children: [
          // Success Certificate Banner
          Container(
            padding: EdgeInsetsDirectional.all(18.r),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: TravelTheme.radius,
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: Colors.green, size: 28),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: 'Policy Issued & Active',
                          fa: 'بیمه‌نامه با موفقیت صادر و فعال شد',
                          ar: 'تم إصدار الوثيقة وتفعيلها بنجاح',
                          zh: '保单已生效出单',
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.green.shade900,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Embassy-compliant digital certificate with verification QR.',
                          fa: 'مورد تأیید سفارت‌ها همراه با بارکد اصالت‌سنجی آنلاین.',
                          ar: 'وثيقة رسمية معتمدة مع رمز التحقق الإلكتروني.',
                          zh: '符合签证要求的官方保单，支持在线扫码查验。',
                        ),
                        style: TextStyle(fontSize: 11.sp, color: Colors.green.shade800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Certificate Body
          TravelCard(
            padding: EdgeInsetsDirectional.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10nPick(context, en: 'Policy Number', fa: 'شماره بیمه‌نامه', ar: 'رقم الوثيقة', zh: '保单编号'),
                      style: TextStyle(fontSize: 11.5.sp, color: TravelTheme.muted),
                    ),
                    Text(
                      policyNumber,
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, fontFamily: 'monospace', color: plan.color),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10nPick(context, en: 'Insured Person', fa: 'نام بیمه‌گذار', ar: 'المؤمن عليه', zh: '被保险人'),
                      style: TextStyle(fontSize: 11.5.sp, color: TravelTheme.muted),
                    ),
                    Text(
                      insuredName,
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10nPick(context, en: 'Passport Number', fa: 'شماره پاسپورت', ar: 'رقم جواز السفر', zh: '护照号码'),
                      style: TextStyle(fontSize: 11.5.sp, color: TravelTheme.muted),
                    ),
                    Text(
                      passportNumber,
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, fontFamily: 'monospace'),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10nPick(context, en: 'Coverage Limit', fa: 'سقف تعهدات پوشش', ar: 'حد التغطية', zh: '最高保额'),
                      style: TextStyle(fontSize: 11.5.sp, color: TravelTheme.muted),
                    ),
                    Text(
                      plan.coverageLimit,
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: plan.color),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10nPick(context, en: 'Validity Period', fa: 'مدت اعتبار', ar: 'فترة الصلاحية', zh: '保险期间'),
                      style: TextStyle(fontSize: 11.5.sp, color: TravelTheme.muted),
                    ),
                    Text(
                      '${DateFormat('yyyy-MM-dd').format(startDate)} ➔ ${DateFormat('yyyy-MM-dd').format(endDate)} ($durationDays days)',
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Barcode & QR
                Center(
                  child: Column(
                    children: [
                      SvgPicture.string(_generateBarcodeSvg(), height: 48.h),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: TravelTheme.border),
                        ),
                        child: SvgPicture.string(_generateQrSvg(), width: 110.r, height: 110.r),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Scan to verify certificate authenticity on international portal',
                          fa: 'اسکن بارکد جهت استعلام اصالت بیمه‌نامه در سامانه بین‌المللی',
                          ar: 'امسح الرمز للتحقق من صحة الوثيقة دولياً',
                          zh: '扫描二维码可在国际查验平台核对保单真伪',
                        ),
                        style: TextStyle(fontSize: 10.sp, color: TravelTheme.muted),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(localization.travelTotal, style: TextStyle(fontSize: 12.sp, color: TravelTheme.muted)),
                    Text('${formatMockAmount(totalPrice)} ${localization.travelMockCurrency}',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: plan.color)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // 24/7 Assistance Hotline
          Container(
            padding: EdgeInsetsDirectional.all(14.r),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: TravelTheme.radius,
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF2563EB)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(context, en: '24/7 International Emergency SOS Assistance', fa: 'خط اضطراری SOS بین‌المللی ۲۴ ساعته', ar: 'خدمة الطوارئ الدولية ٢٤/٧', zh: '24/7 境外全球紧急救援热线'),
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.sp),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        l10nPick(context, en: 'Worldwide SOS helpline: +33 1 45 16 65 65 (Multi-lingual)', fa: 'تماس رایگان پشتیبانی خارج از کشور: ۳۳۱۴۵۱۶۶۵۶۵+ (چند زبانه)', ar: 'هاتف الطوارئ الدولي: 0033145166565', zh: '多语种国际救援专线：+33 1 45 16 65 65'),
                        style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
                      ),
                    ],
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
