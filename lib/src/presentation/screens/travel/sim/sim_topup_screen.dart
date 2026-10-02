import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../services/mock_travel_data.dart';
import '../services/travel_service_request.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';

class SimOperatorItem {
  final String id;
  final String name;
  final String country;
  final String flag;
  final String dialCode;
  final Color brandColor;

  const SimOperatorItem({
    required this.id,
    required this.name,
    required this.country,
    required this.flag,
    required this.dialCode,
    required this.brandColor,
  });
}

const List<SimOperatorItem> popularOperators = [
  SimOperatorItem(
    id: 'turkcell',
    name: 'Turkcell',
    country: 'Turkey',
    flag: '🇹🇷',
    dialCode: '+90',
    brandColor: Color(0xFF0038A8),
  ),
  SimOperatorItem(
    id: 'vodafone',
    name: 'Vodafone',
    country: 'International',
    flag: '🌐',
    dialCode: '+90',
    brandColor: Color(0xFFE60000),
  ),
  SimOperatorItem(
    id: 'etisalat',
    name: 'e& (Etisalat)',
    country: 'UAE',
    flag: '🇦🇪',
    dialCode: '+971',
    brandColor: Color(0xFF719E19),
  ),
  SimOperatorItem(
    id: 'zain',
    name: 'Zain',
    country: 'Saudi / Regional',
    flag: '🇸🇦',
    dialCode: '+966',
    brandColor: Color(0xFF231F20),
  ),
  SimOperatorItem(
    id: 'du',
    name: 'du Telecom',
    country: 'UAE',
    flag: '🇦🇪',
    dialCode: '+971',
    brandColor: Color(0xFF00A9E0),
  ),
];

class SimPackageOption {
  final String id;
  final String title;
  final String quota;
  final String validity;
  final int price;

  const SimPackageOption({
    required this.id,
    required this.title,
    required this.quota,
    required this.validity,
    required this.price,
  });
}

const List<SimPackageOption> defaultSimPackages = [
  SimPackageOption(
    id: 'credit_100',
    title: '100 TRY Airtime Credit',
    quota: '100 TRY',
    validity: '90 Days',
    price: 350000,
  ),
  SimPackageOption(
    id: 'data_10gb',
    title: '10 GB High-Speed Data',
    quota: '10 GB LTE',
    validity: '30 Days',
    price: 580000,
  ),
  SimPackageOption(
    id: 'data_25gb',
    title: '25 GB Data + 500 Min Call',
    quota: '25 GB + 500 Min',
    validity: '30 Days',
    price: 950000,
  ),
  SimPackageOption(
    id: 'data_unlimited',
    title: 'Tourist Unlimited Data',
    quota: 'Unlimited GB',
    validity: '15 Days',
    price: 1450000,
  ),
];

class SimTopUpScreen extends StatefulWidget {
  const SimTopUpScreen({super.key});

  @override
  State<SimTopUpScreen> createState() => _SimTopUpScreenState();
}

class _SimTopUpScreenState extends State<SimTopUpScreen> {
  SimOperatorItem _selectedOperator = popularOperators.first;
  SimPackageOption _selectedPackage = defaultSimPackages[1];
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitRecharge(BuildContext context) async {
    final localization = AppLocalizations.of(context)!;
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isSubmitting = true);
    final ref = TravelServiceRequest.generateReference();
    final fullNumber = '${_selectedOperator.dialCode} ${_phoneController.text.trim()}';

    final request = TravelServiceRequest(
      id: 'sim-${DateTime.now().microsecondsSinceEpoch}',
      serviceKey: 'simTopUp',
      title: '${_selectedOperator.name} $fullNumber',
      subtitle: '${_selectedPackage.title} · ${_selectedPackage.validity}',
      amountLabel: '${formatMockAmount(_selectedPackage.price)} ${localization.travelMockCurrency}',
      reference: ref,
      createdAt: DateTime.now(),
      details: {
        'Operator': _selectedOperator.name,
        'Number': fullNumber,
        'Package': _selectedPackage.title,
        'Quota': _selectedPackage.quota,
        'Validity': _selectedPackage.validity,
      },
    );
    await TravelServiceRequestStore.add(request);
    setState(() => _isSubmitting = false);

    Get.off(
      () => SimTopUpVoucherScreen(
        reference: ref,
        operator: _selectedOperator,
        package: _selectedPackage,
        mobileNumber: fullNumber,
        totalPrice: _selectedPackage.price,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return TravelPage(
      title: l10nPick(
        context,
        en: 'Tourist SIM Recharge',
        fa: 'شارژ و بسته سیم‌کارت مسافرتی',
        ar: 'شحن رصيد وباقات الشريحة',
        zh: '境外手机话费与流量充值',
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
                      '${formatMockAmount(_selectedPackage.price)} ${localization.travelMockCurrency}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: _selectedOperator.brandColor,
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
                    en: 'Instant Recharge',
                    fa: 'شارژ فوری مستقیم',
                    ar: 'شحن فوري مباشر',
                    zh: '即时在线充值',
                  ),
                  backgroundColor: _selectedOperator.brandColor,
                  isLoading: _isSubmitting,
                  onPressed: () => _submitRecharge(context),
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
            // Operator Selector Section
            Text(
              l10nPick(context, en: 'Select Mobile Operator', fa: 'انتخاب اپراتور تلفن همراه', ar: 'اختر مزود الخدمة', zh: '选择电信运营商'),
              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w900, color: TravelTheme.ink),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 48.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: popularOperators.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final op = popularOperators[index];
                  final isSelected = _selectedOperator.id == op.id;
                  return InkWell(
                    onTap: () => setState(() => _selectedOperator = op),
                    borderRadius: BorderRadius.circular(14.r),
                    child: Container(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected ? op.brandColor : Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: isSelected ? op.brandColor : TravelTheme.border),
                      ),
                      child: Row(
                        children: [
                          Text(op.flag, style: TextStyle(fontSize: 16.sp)),
                          SizedBox(width: 8.w),
                          Text(
                            op.name,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                              color: isSelected ? Colors.white : TravelTheme.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 18.h),

            // Mobile Number Input Card
            TravelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(context, en: 'Mobile Number', fa: 'شماره تلفن سیم‌کارت مقصد', ar: 'رقم الهاتف المحمول', zh: '充值手机号码'),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: TravelTheme.ink),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: TravelTheme.border),
                        ),
                        child: Text(
                          _selectedOperator.dialCode,
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: '5XX XXX XXXX',
                            border: const OutlineInputBorder(),
                            contentPadding: EdgeInsetsDirectional.symmetric(horizontal: 14.w, vertical: 14.h),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return localization.travelFormRequired;
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),

            // Packages List
            Text(
              l10nPick(context, en: 'Available Top-Up Packages', fa: 'بسته‌های اینترنت و شارژ اعتباری', ar: 'الباقات المتاحة', zh: '可选充值套餐'),
              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w900, color: TravelTheme.ink),
            ),
            SizedBox(height: 10.h),
            ...defaultSimPackages.map((pkg) {
              final isSelected = _selectedPackage.id == pkg.id;
              return Padding(
                padding: EdgeInsetsDirectional.only(bottom: 10.h),
                child: InkWell(
                  onTap: () => setState(() => _selectedPackage = pkg),
                  borderRadius: TravelTheme.radius,
                  child: Container(
                    padding: EdgeInsetsDirectional.all(14.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: TravelTheme.radius,
                      border: Border.all(
                        color: isSelected ? _selectedOperator.brandColor : TravelTheme.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12.r,
                              backgroundColor: isSelected ? _selectedOperator.brandColor : TravelTheme.border,
                              child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                            ),
                            SizedBox(width: 10.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pkg.title,
                                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: TravelTheme.ink),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  '${pkg.quota} · ${pkg.validity}',
                                  style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          '${formatMockAmount(pkg.price)} ${localization.travelMockCurrency}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w900,
                            color: _selectedOperator.brandColor,
                          ),
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
  }
}

/// Digital SIM Top-Up Voucher & Receipt
class SimTopUpVoucherScreen extends StatelessWidget {
  final String reference;
  final SimOperatorItem operator;
  final SimPackageOption package;
  final String mobileNumber;
  final int totalPrice;

  const SimTopUpVoucherScreen({
    super.key,
    required this.reference,
    required this.operator,
    required this.package,
    required this.mobileNumber,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return TravelPage(
      title: l10nPick(
        context,
        en: 'Recharge Receipt',
        fa: 'رسید شارژ سیم‌کارت',
        ar: 'إيصال الشحن',
        zh: '充值成功凭证',
      ),
      showTravelNavigation: false,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.all(16.r),
          child: CommonButton(
            width: double.infinity,
            text: l10nPick(context, en: 'Done & Return', fa: 'تأیید و بازگشت', ar: 'تم والعودة', zh: '完成并返回'),
            textColor: Colors.white,
            backgroundColor: operator.brandColor,
            onPressed: () => Get.offAllNamed(BaseRoute.travel),
          ),
        ),
      ),
      child: ListView(
        padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 30.h),
        children: [
          // Success Card
          Container(
            padding: EdgeInsetsDirectional.all(18.r),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: TravelTheme.radius,
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: 'Recharge Submitted Successfully',
                          fa: 'شارژ با موفقیت اعمال گردید',
                          ar: 'تم إرسال الشحن بنجاح',
                          zh: '话费充值已提交成功',
                        ),
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: Colors.green.shade900),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'The operator confirmation SMS will arrive within 2 minutes.',
                          fa: 'پیامک تأیید اپراتور تا ۲ دقیقه دیگر به خط مسافر ارسال خواهد شد.',
                          ar: 'ستصل رسالة التأكيد خلال دقيقتين.',
                          zh: '运营商确认短信将在2分钟内发送至充值号码。',
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

          // Details Card
          TravelCard(
            padding: EdgeInsetsDirectional.all(20.r),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10nPick(context, en: 'Reference Code', fa: 'کد پیگیری', ar: 'الرقم المرجعي', zh: '交易流水号'),
                      style: TextStyle(fontSize: 11.5.sp, color: TravelTheme.muted)),
                    Text(reference, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10nPick(context, en: 'Operator', fa: 'اپراتور', ar: 'المشغل', zh: '运营商'),
                      style: TextStyle(fontSize: 11.5.sp, color: TravelTheme.muted)),
                    Text('${operator.flag} ${operator.name}', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800)),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10nPick(context, en: 'Mobile Number', fa: 'شماره تلفن', ar: 'رقم الهاتف', zh: '充值号码'),
                      style: TextStyle(fontSize: 11.5.sp, color: TravelTheme.muted)),
                    Text(mobileNumber, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, fontFamily: 'monospace')),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10nPick(context, en: 'Package / Quota', fa: 'بسته خریداری شده', ar: 'الباقة', zh: '充值项目'),
                      style: TextStyle(fontSize: 11.5.sp, color: TravelTheme.muted)),
                    Text(package.title, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(localization.travelTotal, style: TextStyle(fontSize: 12.sp, color: TravelTheme.muted)),
                    Text('${formatMockAmount(totalPrice)} ${localization.travelMockCurrency}',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: operator.brandColor)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // USSD Balance check info
          Container(
            padding: EdgeInsetsDirectional.all(14.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: TravelTheme.radius,
              border: Border.all(color: TravelTheme.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.dialpad_rounded, color: TravelTheme.blue, size: 22),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    l10nPick(
                      context,
                      en: 'To check remaining quota: Turkcell dial *123#, Vodafone dial *7000#, Etisalat dial *170#.',
                      fa: 'استعلام باقیمانده بسته: ترکسل *123# ، وودافون *7000# ، اتصالات *170#',
                      ar: 'للاستعلام عن الرصيد: تركسل *123# ، فودافون *7000# ، اتصالات *170#',
                      zh: '查询剩余流量与余额：Turkcell 拨打 *123#，Vodafone 拨打 *7000#。',
                    ),
                    style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted, height: 1.4),
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
