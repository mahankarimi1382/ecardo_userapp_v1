// DATA: REAL | MOCK | PLACEHOLDER
// eCardo Travel Insurance & Emergency Assistance Module
// Compliant with EU Schengen Regulation (EC) No 810/2009, WCAG 2.2 AA.

import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:printing/printing.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_single_date_picker.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../services/mock_travel_data.dart';
import '../services/travel_service_request.dart';
import '../shared/travel_widgets.dart';
import 'insurance_claim_screen.dart';
import 'insurance_models.dart';
import 'insurance_service.dart';

// Backward compatibility aliases
typedef InsuranceZone = InsuranceDestinationZone;
const List<InsurancePlan> defaultInsurancePlans = standardInsurancePlans;

/// Main Travel Insurance quote and issuance screen.
class TravelInsuranceScreen extends StatefulWidget {
  final bool isOffline;

  const TravelInsuranceScreen({
    super.key,
    this.isOffline = false,
  });

  @override
  State<TravelInsuranceScreen> createState() => _TravelInsuranceScreenState();
}

class _TravelInsuranceScreenState extends State<TravelInsuranceScreen> {
  bool get _isOffline => widget.isOffline;
  InsuranceDestinationZone _zone = InsuranceDestinationZone.schengen;
  String _destinationCountry = 'France (Schengen)';
  int _durationDays = 15;
  TravelerAgeBand _ageBand = TravelerAgeBand.standard;
  InsurancePlan _selectedPlan = standardInsurancePlans[1]; // Schengen 30k
  DateTime _startDate = DateTime.now().add(const Duration(days: 3));
  DateTime _endDate = DateTime.now().add(const Duration(days: 17));
  final Set<InsuranceAddon> _selectedAddons = {};

  final _formKey = GlobalKey<FormState>();
  final _fullNameEnController = TextEditingController();
  final _passportController = TextEditingController();
  final _nationalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController(text: '1995-05-15');

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _recalculateDatesFromDuration();
  }

  @override
  void dispose() {
    _fullNameEnController.dispose();
    _passportController.dispose();
    _nationalCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _recalculateDatesFromDuration() {
    _endDate = _startDate.add(Duration(days: _durationDays - 1));
  }

  void _onDurationDaysSelected(int days) {
    setState(() {
      _durationDays = days;
      _recalculateDatesFromDuration();
    });
  }

  void _onStartDateSelected(DateTime date) {
    setState(() {
      _startDate = date;
      _recalculateDatesFromDuration();
    });
  }

  void _onBirthDateSelected(DateTime date) {
    _birthDateController.text = DateFormat('yyyy-MM-dd').format(date);
    final now = DateTime.now();
    int age = now.year - date.year;
    if (now.month < date.month || (now.month == date.month && now.day < date.day)) {
      age--;
    }
    setState(() {
      _ageBand = InsurancePricingCalculator.getAgeBand(age);
    });
  }

  InsurancePremiumBreakdown get _premiumBreakdown {
    return InsurancePricingCalculator.calculatePremium(
      durationDays: _durationDays,
      ageBand: _ageBand,
      zone: _zone,
      tier: _selectedPlan.tier,
      addons: _selectedAddons,
    );
  }

  int get _calculatedPrice => _premiumBreakdown.totalPremium;

  SchengenValidationResult get _schengenCheck {
    return InsurancePricingCalculator.validateSchengenEligibility(
      zone: _zone,
      tier: _selectedPlan.tier,
    );
  }

  Future<void> _submitOrder(BuildContext context) async {
    final localization = AppLocalizations.of(context)!;
    if (_formKey.currentState?.validate() != true) {
      showTravelMessage(
        context,
        title: l10nPick(context, en: 'Validation Error', fa: 'خطای اعتبارسنجی فرم', ar: 'خطأ في التحقق'),
        message: l10nPick(
          context,
          en: 'Please complete all required fields according to your passport.',
          fa: 'لطفاً تمامی فیلدهای الزامی را مطابق با گذرنامه تکمیل کنید.',
          ar: 'يرجى ملء جميع الحقول المطلوبة.',
        ),
      );
      return;
    }

    if (!_schengenCheck.isValid) {
      showTravelMessage(
        context,
        title: l10nPick(context, en: 'Schengen Non-Compliant', fa: 'عدم تطابق با ضوابط شنگن', ar: 'غير متوافق مع شنغن'),
        message: l10nPick(
          context,
          en: _schengenCheck.errorMessageEn ?? '',
          fa: _schengenCheck.errorMessageFa ?? '',
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final birthDateTime = DateTime.tryParse(_birthDateController.text) ?? DateTime(1995, 5, 15);
    final traveler = InsuredTraveler(
      fullNameEn: _fullNameEnController.text.trim().toUpperCase(),
      passportNumber: _passportController.text.trim().toUpperCase(),
      nationalId: _nationalCodeController.text.trim(),
      birthDate: birthDateTime,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
    );

    final service = InsuranceService();
    final result = service.issuePolicy(
      traveler: traveler,
      zone: _zone,
      destinationCountry: _destinationCountry,
      startDate: _startDate,
      endDate: _endDate,
      plan: _selectedPlan,
      addons: _selectedAddons,
    );

    if (!result.isSuccess || result.policy == null) {
      setState(() => _isProcessing = false);
      showTravelMessage(
        context,
        title: l10nPick(context, en: 'Issuance Failed', fa: 'خطا در صدور بیمه‌نامه', ar: 'فشل الإصدار'),
        message: l10nPick(
          context,
          en: result.errorEn ?? 'Policy could not be issued.',
          fa: result.errorFa ?? 'امکان صدور بیمه‌نامه وجود ندارد.',
        ),
      );
      return;
    }

    final policy = result.policy!;

    // Persist locally for offline certificate access
    await InsuranceLocalStore.addPolicy(policy);

    // Also register in shared local request book for admin tracking
    final request = TravelServiceRequest(
      id: policy.id,
      serviceKey: 'insurance',
      title: 'بیمه مسافرتی ${policy.plan.titleFa}',
      subtitle: '${policy.plan.coverageLimit} · ${policy.durationDays} روزه (${policy.destinationCountry})',
      amountLabel: '${formatMockAmount(policy.breakdown.totalPremium)} ${localization.travelMockCurrency}',
      reference: policy.certificateNumber,
      createdAt: policy.issuedAt,
      details: {
        'Zone': policy.destinationZone.displayNameEn,
        'Country': policy.destinationCountry,
        'Duration': '${policy.durationDays} Days',
        'Plan': policy.plan.titleEn,
        'Coverage': policy.plan.coverageLimit,
        'Insured': policy.traveler.fullNameEn,
        'Passport': policy.traveler.passportNumber,
        'National ID': policy.traveler.nationalId,
        'Start Date': DateFormat('yyyy-MM-dd').format(policy.startDate),
        'End Date': DateFormat('yyyy-MM-dd').format(policy.endDate),
        'Age Band': policy.traveler.ageBand.labelEn,
        'Addons': policy.addons.map((a) => a.titleEn).join(', '),
      },
    );
    await TravelServiceRequestStore.add(request);

    if (!mounted) return;
    setState(() => _isProcessing = false);

    Get.off(
      () => InsuranceCertificateScreen(
        policy: policy,
        policyNumber: policy.policyNumber,
        plan: policy.plan,
        insuredName: policy.traveler.fullNameEn,
        passportNumber: policy.traveler.passportNumber,
        durationDays: policy.durationDays,
        startDate: policy.startDate,
        totalPrice: policy.breakdown.totalPremium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = ECardoTokens.isDark(context);

    return TravelPage(
      title: l10nPick(
        context,
        en: 'Travel Insurance',
        fa: 'بیمه مسافرتی بین‌المللی',
        ar: 'التأمين الصحي للسفر',
        zh: '境外旅游意外保险',
      ),
      showTravelNavigation: false,
      trailing: IconButton(
        tooltip: l10nPick(context, en: 'Claims & Assistance', fa: 'اعلام خسارت و امداد', ar: 'المطالبات والمساعدة'),
        icon: Icon(Icons.support_agent_rounded, color: ECardoTokens.brand500(context)),
        onPressed: () => Get.to(() => const InsuranceClaimScreen()),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsetsDirectional.all(16.r),
          decoration: BoxDecoration(
            color: ECardoTokens.surfaceCard(context),
            border: Border(top: BorderSide(color: ECardoTokens.border(context))),
            boxShadow: ECardoTokens.shadowCard(context),
          ),
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
                        fontSize: 11.sp,
                        color: ECardoTokens.inkMuted(context),
                      ),
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
                width: 175.w,
                child: CommonButton(
                  text: _isProcessing
                      ? l10nPick(context, en: 'Issuing...', fa: 'در حال صدور...', ar: 'جاري الإصدار...')
                      : l10nPick(
                          context,
                          en: 'Issue Policy Online',
                          fa: 'صدور آنلاین بیمه‌نامه',
                          ar: 'إصدار الوثيقة فوراً',
                          zh: '即时在线出单',
                        ),
                  backgroundColor: ECardoTokens.brand700(context),
                  onPressed: _isProcessing ? () {} : () => _submitOrder(context),
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
            if (_isOffline) ...[
              _buildOfflineBanner(context),
              SizedBox(height: 12.h),
            ],

            // Hero Card
            _buildHeroCard(context),
            SizedBox(height: 16.h),

            // Destination Zone Selector
            _buildSectionHeader(
              title: l10nPick(
                context,
                en: 'Destination Zone',
                fa: 'منطقه جغرافیایی سفر و مقصد',
                ar: 'منطقة السفر الجغرافية',
                zh: '出行目的地分类',
              ),
            ),
            SizedBox(height: 8.h),
            _buildZoneSelector(context, isDark),
            SizedBox(height: 16.h),

            // Destination Country Input
            TextFormField(
              initialValue: _destinationCountry,
              style: TextStyle(color: ECardoTokens.ink(context), fontSize: 13.sp),
              decoration: InputDecoration(
                labelText: l10nPick(
                  context,
                  en: 'Primary Destination Country / City',
                  fa: 'کشور یا شهر مقصد اصلی سفر',
                  ar: 'الدولة أو المدينة الوجهة الرئيسية',
                ),
                labelStyle: TextStyle(color: ECardoTokens.inkMuted(context), fontSize: 12.sp),
                prefixIcon: Icon(Icons.flight_land_rounded, color: ECardoTokens.brand500(context)),
                filled: true,
                fillColor: ECardoTokens.surfaceSunken(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  borderSide: BorderSide(color: ECardoTokens.border(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  borderSide: BorderSide(color: ECardoTokens.border(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  borderSide: BorderSide(color: ECardoTokens.focusRing(context), width: 1.5),
                ),
              ),
              onChanged: (val) => _destinationCountry = val,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return localization.travelFormRequired;
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Trip Duration Chips & Custom Range
            _buildSectionHeader(
              title: l10nPick(
                context,
                en: 'Trip Duration',
                fa: 'مدت سفر (تعداد روزهای پوشش)',
                ar: 'مدة الإقامة والتغطية',
                zh: '保障天数',
              ),
            ),
            SizedBox(height: 8.h),
            _buildDurationChips(context, isDark),
            SizedBox(height: 16.h),

            // Traveler Age Band Selector
            _buildSectionHeader(
              title: l10nPick(
                context,
                en: 'Traveler Age Band',
                fa: 'رده سنی بیمه‌گذار (ضریب ریسک سنی)',
                ar: 'الفئة العمرية للمسافر',
              ),
            ),
            SizedBox(height: 8.h),
            _buildAgeBandChips(context, isDark),
            SizedBox(height: 16.h),

            // Plans Comparison Section
            _buildSectionHeader(
              title: l10nPick(
                context,
                en: 'Select Medical Coverage Plan',
                fa: 'انتخاب سطح پوشش درمانی بیمه',
                ar: 'اختر باقة التأمين الصحي',
                zh: '选择保障方案',
              ),
            ),
            SizedBox(height: 10.h),
            if (!_schengenCheck.isValid) ...[
              _buildSchengenAlertBanner(context),
              SizedBox(height: 10.h),
            ],
            ...standardInsurancePlans.map((plan) => _buildPlanCard(context, plan, isDark)),
            SizedBox(height: 16.h),

            // Optional Addon Riders
            _buildSectionHeader(
              title: l10nPick(
                context,
                en: 'Optional Protection Riders',
                fa: 'پوشش‌های تکمیلی و اختیاری',
                ar: 'التغطيات الإضافية الاختيارية',
              ),
            ),
            SizedBox(height: 8.h),
            ...InsuranceAddon.values.map((addon) => _buildAddonCard(context, addon, isDark)),
            SizedBox(height: 16.h),

            // Insured Person Form
            _buildTravelerFormCard(context, localization),
            SizedBox(height: 16.h),

            // Premium Breakdown Card
            _buildPriceBreakdownCard(context, localization),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13.5.sp,
        fontWeight: FontWeight.w900,
        color: ECardoTokens.ink(context),
      ),
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.all(12.r),
      decoration: BoxDecoration(
        color: ECardoTokens.warningBg(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
        border: Border.all(color: ECardoTokens.warning(context).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: ECardoTokens.warning(context), size: 20),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              l10nPick(
                context,
                en: 'Offline Mode: Draft saved locally. Certificate will sync once connected.',
                fa: 'حالت آفلاین: پیش‌نویس ذخیره شد. پس از اتصال، صدور نهایی می‌گردد.',
                ar: 'وضع غير متصل: سيتم مزامنة الوثيقة فور الاتصال.',
              ),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: ECardoTokens.ink(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.all(20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        gradient: LinearGradient(
          colors: [ECardoTokens.brand900(context), ECardoTokens.brand700(context)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        boxShadow: ECardoTokens.shadowCard(context),
        border: Border.all(
          color: ECardoTokens.sand400(context).withValues(alpha: 0.3),
        ),
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
                    color: ECardoTokens.inkOnBrand,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  l10nPick(
                    context,
                    en: 'Official PDF with QR code sent immediately. Valid for Schengen, UK, Canada, & worldwide visas.',
                    fa: 'نسخه رسمی همراه با بارکد اصالت‌سنجی و دانلود مستقیم PDF بلافاصله صادر می‌شود.',
                    ar: 'نسخة رقمية رسمية مع رمز QR صالحة لكافة أنواع التأشيرات.',
                    zh: '即时出具带二维码的官方电子保单，满足申根及全球签证要求。',
                  ),
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: ECardoTokens.inkOnBrandMuted(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.health_and_safety_rounded, size: 52, color: ECardoTokens.sand400(context)),
        ],
      ),
    );
  }

  Widget _buildZoneSelector(BuildContext context, bool isDark) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _ZoneChip(
          label: l10nPick(context, en: 'Schengen Area (EU)', fa: 'حوزه شنگن و اروپا', ar: 'منطقة شنغن', zh: '申根欧洲'),
          selected: _zone == InsuranceDestinationZone.schengen,
          onTap: () => setState(() => _zone = InsuranceDestinationZone.schengen),
        ),
        _ZoneChip(
          label: l10nPick(context, en: 'Worldwide (All Countries)', fa: 'سراسر جهان (کلیه کشورها)', ar: 'جميع أنحاء العالم', zh: '全球通用'),
          selected: _zone == InsuranceDestinationZone.worldwide,
          onTap: () => setState(() => _zone = InsuranceDestinationZone.worldwide),
        ),
        _ZoneChip(
          label: l10nPick(context, en: 'Worldwide (Excl. USA/CAN)', fa: 'سراسر جهان (به‌جز آمریکا/کانادا)', ar: 'العالم (باستثناء أمريكا)'),
          selected: _zone == InsuranceDestinationZone.worldwideExcludingUsa,
          onTap: () => setState(() => _zone = InsuranceDestinationZone.worldwideExcludingUsa),
        ),
        _ZoneChip(
          label: l10nPick(context, en: 'Turkey & Middle East', fa: 'ترکیه و خاورمیانه', ar: 'تركيا والشرق الأوسط', zh: '土耳其与中东'),
          selected: _zone == InsuranceDestinationZone.middleEast,
          onTap: () => setState(() => _zone = InsuranceDestinationZone.middleEast),
        ),
        _ZoneChip(
          label: l10nPick(context, en: 'Asia & Pacific', fa: 'آسیا و شرق دور', ar: 'آسيا والمحيط الهادئ'),
          selected: _zone == InsuranceDestinationZone.asia,
          onTap: () => setState(() => _zone = InsuranceDestinationZone.asia),
        ),
      ],
    );
  }

  Widget _buildDurationChips(BuildContext context, bool isDark) {
    return Row(
      children: [7, 15, 30, 60, 92].map((days) {
        final isSelected = _durationDays == days;
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: 6.w),
            child: InkWell(
              onTap: () => _onDurationDaysSelected(days),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
              child: Container(
                padding: EdgeInsetsDirectional.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ECardoTokens.brand700(context)
                      : ECardoTokens.surfaceCard(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  border: Border.all(
                    color: isSelected ? ECardoTokens.brand700(context) : ECardoTokens.border(context),
                  ),
                ),
                child: Center(
                  child: Text(
                    '$days ${l10nPick(context, en: 'd', fa: 'روز', ar: 'يوم', zh: '天')}',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: isSelected ? ECardoTokens.inkOnBrand : ECardoTokens.ink(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAgeBandChips(BuildContext context, bool isDark) {
    return Row(
      children: TravelerAgeBand.values.map((band) {
        final isSelected = _ageBand == band;
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: 6.w),
            child: InkWell(
              onTap: () => setState(() => _ageBand = band),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
              child: Container(
                padding: EdgeInsetsDirectional.symmetric(vertical: 8.h, horizontal: 4.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ECardoTokens.brand700(context)
                      : ECardoTokens.surfaceCard(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  border: Border.all(
                    color: isSelected ? ECardoTokens.brand700(context) : ECardoTokens.border(context),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      l10nPick(context, en: band.labelEn, fa: band.labelFa),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                        color: isSelected ? ECardoTokens.inkOnBrand : ECardoTokens.ink(context),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${band.multiplier}x',
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? ECardoTokens.inkOnBrandMuted(context) : ECardoTokens.inkMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSchengenAlertBanner(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.all(12.r),
      decoration: BoxDecoration(
        color: ECardoTokens.dangerBg(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
        border: Border.all(color: ECardoTokens.danger(context).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: ECardoTokens.danger(context), size: 22),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              l10nPick(
                context,
                en: 'Schengen Regulation Alert: European embassies reject policies under €30,000. Please select a Schengen-compliant plan.',
                fa: 'هشدار ویزای شنگن: سفارت‌های اروپایی سقف پوشش کمتر از ۳۰,۰۰۰ یورو را نمی‌پذیرند.',
                ar: 'تنبيه: تتطلب تأشيرات شنغن حداً أدنى قدره 30,000 يورو للتغطية الطبية.',
              ),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: ECardoTokens.danger(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, InsurancePlan plan, bool isDark) {
    final isSelected = _selectedPlan.id == plan.id;
    final surfaceColor = ECardoTokens.surfaceCard(context);

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 12.h),
      child: InkWell(
        onTap: () => setState(() => _selectedPlan = plan),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        child: Container(
          padding: EdgeInsetsDirectional.all(16.r),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
            border: Border.all(
              color: isSelected ? plan.color : ECardoTokens.border(context),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? ECardoTokens.shadowCard(context) : null,
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      plan.color.withValues(alpha: 0.06),
                      plan.color.withValues(alpha: 0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
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
                        backgroundColor: isSelected ? plan.color : ECardoTokens.borderStrong(context),
                        child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        l10nPick(context, en: plan.titleEn, fa: plan.titleFa),
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w900,
                          color: ECardoTokens.ink(context),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: plan.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 15, color: plan.color),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            b,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: ECardoTokens.inkMuted(context),
                            ),
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
  }

  Widget _buildAddonCard(BuildContext context, InsuranceAddon addon, bool isDark) {
    final isSelected = _selectedAddons.contains(addon);
    final cost = addon.calculateCost(_durationDays);
    final surfaceColor = ECardoTokens.surfaceCard(context);

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 8.h),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedAddons.remove(addon);
            } else {
              _selectedAddons.add(addon);
            }
          });
        },
        borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
        child: Container(
          padding: EdgeInsetsDirectional.all(12.r),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
            border: Border.all(
              color: isSelected ? ECardoTokens.brand700(context) : ECardoTokens.border(context),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected ? ECardoTokens.shadowCard(context) : null,
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                color: isSelected ? ECardoTokens.brand700(context) : ECardoTokens.inkMuted(context),
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10nPick(context, en: addon.titleEn, fa: addon.titleFa),
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w800,
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      l10nPick(context, en: addon.coverageLimitEn, fa: addon.coverageLimitFa),
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: ECardoTokens.inkMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '+${formatMockAmount(cost)}',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w800,
                  color: ECardoTokens.sand600(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTravelerFormCard(BuildContext context, AppLocalizations localization) {
    return Container(
      padding: EdgeInsetsDirectional.all(18.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        border: Border.all(color: ECardoTokens.border(context)),
        boxShadow: ECardoTokens.shadowCard(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10nPick(
              context,
              en: 'Insured Traveler Details',
              fa: 'مشخصات بیمه‌گذار (مطابق گذرنامه)',
              ar: 'بيانات المؤمن عليه',
              zh: '被保险人身份信息',
            ),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              color: ECardoTokens.ink(context),
            ),
          ),
          SizedBox(height: 12.h),

          // Full Name in English
          TextFormField(
            controller: _fullNameEnController,
            style: TextStyle(color: ECardoTokens.ink(context), fontSize: 13.sp),
            decoration: InputDecoration(
              labelText: l10nPick(
                context,
                en: 'Full Name in English (as in Passport)',
                fa: 'نام و نام خانوادگی به انگلیسی (مطابق پاسپورت)',
                ar: 'الاسم الكامل بالإنجليزية',
                zh: '护照英文姓名（大写）',
              ),
              labelStyle: TextStyle(color: ECardoTokens.inkMuted(context), fontSize: 12.sp),
              prefixIcon: Icon(Icons.person_outline_rounded, color: ECardoTokens.brand500(context)),
              filled: true,
              fillColor: ECardoTokens.surfaceSunken(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                borderSide: BorderSide(color: ECardoTokens.border(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                borderSide: BorderSide(color: ECardoTokens.border(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                borderSide: BorderSide(color: ECardoTokens.focusRing(context), width: 1.5),
              ),
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
            style: TextStyle(color: ECardoTokens.ink(context), fontSize: 13.sp),
            decoration: InputDecoration(
              labelText: l10nPick(
                context,
                en: 'Passport Number',
                fa: 'شماره گذرنامه',
                ar: 'رقم جواز السفر',
                zh: '护照号码',
              ),
              labelStyle: TextStyle(color: ECardoTokens.inkMuted(context), fontSize: 12.sp),
              prefixIcon: Icon(Icons.menu_book_rounded, color: ECardoTokens.brand500(context)),
              filled: true,
              fillColor: ECardoTokens.surfaceSunken(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                borderSide: BorderSide(color: ECardoTokens.border(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                borderSide: BorderSide(color: ECardoTokens.border(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                borderSide: BorderSide(color: ECardoTokens.focusRing(context), width: 1.5),
              ),
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
            style: TextStyle(color: ECardoTokens.ink(context), fontSize: 13.sp),
            decoration: InputDecoration(
              labelText: l10nPick(
                context,
                en: 'National ID Number',
                fa: 'کد ملی مسافر',
                ar: 'الرقم القومي',
                zh: '身份证号',
              ),
              labelStyle: TextStyle(color: ECardoTokens.inkMuted(context), fontSize: 12.sp),
              prefixIcon: Icon(Icons.badge_outlined, color: ECardoTokens.brand500(context)),
              filled: true,
              fillColor: ECardoTokens.surfaceSunken(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                borderSide: BorderSide(color: ECardoTokens.border(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                borderSide: BorderSide(color: ECardoTokens.border(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                borderSide: BorderSide(color: ECardoTokens.focusRing(context), width: 1.5),
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return localization.travelFormRequired;
              }
              return null;
            },
          ),
          SizedBox(height: 12.h),

          // Birth Date Picker
          CommonSingleDatePicker(
            initialDate: DateTime.tryParse(_birthDateController.text) ?? DateTime(1995, 5, 15),
            firstDate: DateTime(1930),
            lastDate: DateTime.now(),
            hintText: l10nPick(context, en: 'Date of Birth', fa: 'تاریخ تولد مسافر', ar: 'تاريخ الميلاد'),
            suffixIcon: Icon(Icons.cake_outlined, size: 18, color: ECardoTokens.brand500(context)),
            onDateSelected: _onBirthDateSelected,
          ),
          SizedBox(height: 12.h),

          // Phone Number
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(color: ECardoTokens.ink(context), fontSize: 13.sp),
            decoration: InputDecoration(
              labelText: l10nPick(
                context,
                en: 'Contact Mobile Phone',
                fa: 'شماره تلفن همراه جهت ارسال پیامک و پشتیبانی',
                ar: 'رقم الهاتف المحمول',
              ),
              labelStyle: TextStyle(color: ECardoTokens.inkMuted(context), fontSize: 12.sp),
              prefixIcon: Icon(Icons.phone_rounded, color: ECardoTokens.brand500(context)),
              filled: true,
              fillColor: ECardoTokens.surfaceSunken(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                borderSide: BorderSide(color: ECardoTokens.border(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                borderSide: BorderSide(color: ECardoTokens.border(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                borderSide: BorderSide(color: ECardoTokens.focusRing(context), width: 1.5),
              ),
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
            hintText: l10nPick(
              context,
              en: 'Insurance Start Date',
              fa: 'تاریخ شروع پوشش بیمه',
              ar: 'تاريخ بدء التأمين',
              zh: '起保日期',
            ),
            suffixIcon: Icon(Icons.calendar_month_rounded, size: 18, color: ECardoTokens.brand500(context)),
            onDateSelected: _onStartDateSelected,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdownCard(BuildContext context, AppLocalizations localization) {
    final breakdown = _premiumBreakdown;
    return Container(
      padding: EdgeInsetsDirectional.all(18.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        border: Border.all(color: ECardoTokens.border(context)),
        boxShadow: ECardoTokens.shadowCard(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10nPick(
              context,
              en: 'Premium Calculation Breakdown',
              fa: 'ریز محاسبات حق‌بیمه',
              ar: 'تفاصيل احتساب القسط',
            ),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              color: ECardoTokens.ink(context),
            ),
          ),
          SizedBox(height: 10.h),
          _breakdownRow(
            context,
            l10nPick(context, en: 'Base Medical Coverage', fa: 'حق‌بیمه پایه درمانی (${breakdown.durationDays} روز)'),
            '${formatMockAmount(breakdown.baseMedicalPremium)} ${localization.travelMockCurrency}',
          ),
          if (breakdown.ageSurcharge > 0) ...[
            SizedBox(height: 6.h),
            _breakdownRow(
              context,
              l10nPick(context, en: 'Age Risk Surcharge (${breakdown.ageBand.labelEn})', fa: 'اضافه نرخ ریسک سنی (${breakdown.ageBand.labelFa})'),
              '+${formatMockAmount(breakdown.ageSurcharge)} ${localization.travelMockCurrency}',
            ),
          ],
          if (breakdown.addonsTotal > 0) ...[
            SizedBox(height: 6.h),
            _breakdownRow(
              context,
              l10nPick(context, en: 'Selected Protection Riders', fa: 'پوشش‌های تکمیلی و الحاقیه'),
              '+${formatMockAmount(breakdown.addonsTotal)} ${localization.travelMockCurrency}',
            ),
          ],
          Divider(height: 18, color: ECardoTokens.border(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localization.travelTotal,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: ECardoTokens.ink(context),
                ),
              ),
              Text(
                '${formatMockAmount(breakdown.totalPremium)} ${localization.travelMockCurrency}',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: _selectedPlan.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _breakdownRow(BuildContext context, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11.5.sp,
              color: ECardoTokens.inkMuted(context),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w700,
            color: ECardoTokens.ink(context),
          ),
        ),
      ],
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
    final surfaceColor = ECardoTokens.surfaceCard(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? ECardoTokens.brand700(context) : surfaceColor,
          borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
          border: Border.all(
            color: selected ? ECardoTokens.brand700(context) : ECardoTokens.border(context),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? ECardoTokens.inkOnBrand : ECardoTokens.ink(context),
          ),
        ),
      ),
    );
  }
}

/// Digital Certificate of Insurance with PDF export, print, claims, and free-look cancellation.
class InsuranceCertificateScreen extends StatelessWidget {
  final String policyNumber;
  final InsurancePlan plan;
  final String insuredName;
  final String passportNumber;
  final int durationDays;
  final DateTime startDate;
  final int totalPrice;
  final InsurancePolicy? policy;

  const InsuranceCertificateScreen({
    super.key,
    required this.policyNumber,
    required this.plan,
    required this.insuredName,
    required this.passportNumber,
    required this.durationDays,
    required this.startDate,
    required this.totalPrice,
    this.policy,
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

  Future<void> _exportPdf(BuildContext context) async {
    final targetPolicy = policy ??
        InsurancePolicy(
          id: 'ins-$policyNumber',
          policyNumber: policyNumber,
          certificateNumber: policyNumber,
          qrVerificationPayload: 'https://verify.ecardo.io/insurance/policy/$policyNumber',
          traveler: InsuredTraveler(
            fullNameEn: insuredName,
            passportNumber: passportNumber,
            nationalId: '',
            birthDate: DateTime(1995),
            phone: '',
            email: '',
          ),
          destinationZone: InsuranceDestinationZone.schengen,
          destinationCountry: 'Europe / Worldwide',
          startDate: startDate,
          endDate: startDate.add(Duration(days: durationDays)),
          durationDays: durationDays,
          plan: plan,
          tier: plan.tier,
          addons: const {},
          breakdown: InsurancePremiumBreakdown(
            durationDays: durationDays,
            ageBand: TravelerAgeBand.standard,
            zone: InsuranceDestinationZone.schengen,
            tier: plan.tier,
            baseMedicalPremium: totalPrice,
            ageSurcharge: 0,
            zoneAdjustment: 0,
            addonCosts: const {},
            totalPremium: totalPrice,
          ),
          issuedAt: DateTime.now(),
        );

    final bytes = await InsuranceDocumentBuilder.buildCertificateBytes(targetPolicy);
    await Printing.sharePdf(bytes: bytes, filename: 'Insurance_Certificate_$policyNumber.pdf');
  }

  void _requestFreeLookCancellation(BuildContext context) {
    final now = DateTime.now();
    final isBeforeTrip = now.isBefore(startDate);
    final refund = policy != null
        ? InsurancePricingCalculator.calculateCancellationRefund(
            policy: policy!,
            requestDate: now,
          )
        : null;
    final isEligible = refund?.isEligible ?? isBeforeTrip;
    final refundAmt = refund?.refundAmount ?? totalPrice;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusXl)),
        title: Text(
          l10nPick(
            dialogCtx,
            en: 'Cancel Policy (Free-Look Guarantee)',
            fa: 'درخواست لغو بیمه‌نامه (ضمانت انصراف)',
            ar: 'إلغاء الوثيقة (فترة التراجع)',
          ),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15.sp,
            color: ECardoTokens.ink(context),
          ),
        ),
        content: Text(
          isEligible
              ? l10nPick(
                  dialogCtx,
                  en: 'Your policy is eligible for cancellation and refund (${formatMockAmount(refundAmt)} IRR) under the free-look guarantee. Would you like to proceed?',
                  fa: 'بیمه‌نامه شما در چارچوب ضمانت انصراف واجد شرایط لغو و استرداد وجه (${formatMockAmount(refundAmt)} ریال) است. آیا مایل به لغو می‌باشید؟',
                  ar: 'وثيقتك مؤهلة للإلغاء والاسترداد (${formatMockAmount(refundAmt)} ريال). هل ترغب في المتابعة؟',
                )
              : l10nPick(
                  dialogCtx,
                  en: 'Your coverage period has already commenced. According to insurance regulations, policies are non-refundable after the start date.',
                  fa: 'دوره پوشش بیمه‌نامه شما آغاز شده است. مطابق با مقررات بیمه مرکزی، پس از شروع پوشش امکان لغو وجود ندارد.',
                  ar: 'بدأت فترة التغطية بالفعل، ولا يمكن استرداد المبلغ بعد تاريخ البدء.',
                ),
          style: TextStyle(
            fontSize: 11.5.sp,
            color: ECardoTokens.inkMuted(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              l10nPick(dialogCtx, en: 'Close', fa: 'انصراف', ar: 'إغلاق'),
              style: TextStyle(color: ECardoTokens.inkMuted(context)),
            ),
          ),
          if (isEligible)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ECardoTokens.danger(context),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusMd)),
              ),
              onPressed: () async {
                Navigator.pop(dialogCtx);
                if (policy != null) {
                  await InsuranceLocalStore.updatePolicyStatus(
                    policyId: policy!.id,
                    status: 'cancelled',
                  );
                }
                if (context.mounted) {
                  showTravelMessage(
                    context,
                    title: l10nPick(context, en: 'Policy Cancelled', fa: 'بیمه‌نامه لغو شد', ar: 'تم إلغاء الوثيقة'),
                    message: l10nPick(
                      context,
                      en: 'Full refund will be credited to your eCardo wallet.',
                      fa: 'وجه کامل بیمه‌نامه به کیف پول eCardo شما مسترد شد.',
                      ar: 'تم إعادة المبلغ إلى محفظتك بنجاح.',
                    ),
                  );
                }
              },
              child: Text(
                l10nPick(context, en: 'Confirm Cancellation', fa: 'تأیید لغو و استرداد وجه', ar: 'تأكيد الإلغاء'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = ECardoTokens.isDark(context);
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
        child: Container(
          padding: EdgeInsetsDirectional.all(16.r),
          decoration: BoxDecoration(
            color: ECardoTokens.surfaceCard(context),
            border: Border(top: BorderSide(color: ECardoTokens.border(context))),
            boxShadow: ECardoTokens.shadowCard(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.picture_as_pdf_rounded, size: 18),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsetsDirectional.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ECardoTokens.radiusMd)),
                        side: BorderSide(color: ECardoTokens.border(context)),
                        backgroundColor: ECardoTokens.surfaceSunken(context),
                      ),
                      onPressed: () => _exportPdf(context),
                      label: Text(
                        l10nPick(context, en: 'Download PDF', fa: 'دانلود فایل PDF', ar: 'تحميل PDF'),
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: ECardoTokens.ink(context),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: CommonButton(
                      text: l10nPick(context, en: 'Submit Claim', fa: 'اعلام و ثبت خسارت', ar: 'تقديم مطالبة'),
                      textColor: Colors.white,
                      backgroundColor: ECardoTokens.brand700(context),
                      onPressed: () => Get.to(
                        () => InsuranceClaimScreen(initialPolicyNumber: policyNumber),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () => _requestFreeLookCancellation(context),
                child: Text(
                  l10nPick(context, en: 'Cancel Policy (Free-Look)', fa: 'لغو بیمه‌نامه و استرداد وجه', ar: 'إلغاء الوثيقة والاسترداد'),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: ECardoTokens.danger(context),
                    fontWeight: FontWeight.w700,
                  ),
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
              color: ECardoTokens.successBg(context),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
              border: Border.all(color: ECardoTokens.success(context).withValues(alpha: 0.4)),
              boxShadow: ECardoTokens.shadowCard(context),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_rounded, color: ECardoTokens.success(context), size: 28),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: 'Policy Issued & Embassy-Active',
                          fa: 'بیمه‌نامه با موفقیت صادر و فعال شد',
                          ar: 'تم إصدار الوثيقة وتفعيلها بنجاح',
                          zh: '保单已生效出单',
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          color: ECardoTokens.success(context),
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
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: ECardoTokens.inkMuted(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Certificate Body Card
          Container(
            padding: EdgeInsetsDirectional.all(20.r),
            decoration: BoxDecoration(
              color: ECardoTokens.surfaceCard(context),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
              border: Border.all(color: ECardoTokens.border(context)),
              boxShadow: ECardoTokens.shadowCard(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10nPick(context, en: 'Policy Number', fa: 'شماره بیمه‌نامه', ar: 'رقم الوثيقة', zh: '保单编号'),
                      style: TextStyle(fontSize: 11.5.sp, color: ECardoTokens.inkMuted(context)),
                    ),
                    Text(
                      policyNumber,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        color: plan.color,
                      ),
                    ),
                  ],
                ),
                Divider(height: 20, color: ECardoTokens.border(context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10nPick(context, en: 'Insured Person', fa: 'نام بیمه‌گذار', ar: 'المؤمن عليه', zh: '被保险人'),
                      style: TextStyle(fontSize: 11.5.sp, color: ECardoTokens.inkMuted(context)),
                    ),
                    Text(
                      insuredName,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10nPick(context, en: 'Passport Number', fa: 'شماره پاسپورت', ar: 'رقم جواز السفر', zh: '护照号码'),
                      style: TextStyle(fontSize: 11.5.sp, color: ECardoTokens.inkMuted(context)),
                    ),
                    Text(
                      passportNumber,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10nPick(context, en: 'Coverage Limit', fa: 'سقف تعهدات پوشش', ar: 'حد التغطية', zh: '最高保额'),
                      style: TextStyle(fontSize: 11.5.sp, color: ECardoTokens.inkMuted(context)),
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
                      style: TextStyle(fontSize: 11.5.sp, color: ECardoTokens.inkMuted(context)),
                    ),
                    Text(
                      '${DateFormat('yyyy-MM-dd').format(startDate)} ➔ ${DateFormat('yyyy-MM-dd').format(endDate)} ($durationDays days)',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                  ],
                ),
                Divider(height: 24, color: ECardoTokens.border(context)),

                // Barcode & QR Display
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsetsDirectional.all(8.r),
                        decoration: BoxDecoration(
                          color: ECardoTokens.surfaceSunken(context),
                          borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                        ),
                        child: SvgPicture.string(_generateBarcodeSvg(), height: 44.h),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: ECardoTokens.surfaceCard(context),
                          borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
                          border: Border.all(color: ECardoTokens.border(context)),
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
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: ECardoTokens.inkMuted(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 24, color: ECardoTokens.border(context)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localization.travelTotal,
                      style: TextStyle(fontSize: 12.sp, color: ECardoTokens.inkMuted(context)),
                    ),
                    Text(
                      '${formatMockAmount(totalPrice)} ${localization.travelMockCurrency}',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: plan.color),
                    ),
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
              color: isDark
                  ? ECardoTokens.brand900(context).withValues(alpha: 0.2)
                  : ECardoTokens.brand100(context),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
              border: Border.all(
                color: isDark
                    ? ECardoTokens.brand500(context).withValues(alpha: 0.4)
                    : ECardoTokens.brand500(context).withValues(alpha: 0.2),
              ),
              boxShadow: ECardoTokens.shadowCard(context),
            ),
            child: Row(
              children: [
                Icon(Icons.phone_in_talk_rounded, color: ECardoTokens.brand700(context)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: '24/7 International Emergency SOS Assistance',
                          fa: 'خط اضطراری SOS بین‌المللی ۲۴ ساعته',
                          ar: 'خدمة الطوارئ الدولية ٢٤/٧',
                          zh: '24/7 境外全球紧急救援热线',
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.sp,
                          color: ECardoTokens.ink(context),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Worldwide SOS helpline: +33 1 45 16 65 65 (Multi-lingual)',
                          fa: 'تماس رایگان پشتیبانی خارج از کشور: ۳۳۱۴۵۱۶۶۵۶۵+ (چند زبانه)',
                          ar: 'هاتف الطوارئ الدولي: 0033145166565',
                          zh: '多语种国际救援专线：+33 1 45 16 65 65',
                        ),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: ECardoTokens.inkMuted(context),
                        ),
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
