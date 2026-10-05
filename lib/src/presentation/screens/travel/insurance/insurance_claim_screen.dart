// DATA: MOCK (claim submission & review tracking) — real claims API in INS-BE-004.
// Fully theme-aware (Light + Dark), RTL + LTR compliant, WCAG 2.2 AA.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../services/mock_travel_data.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';
import 'insurance_models.dart';
import 'insurance_service.dart';

/// Screen to submit and track international travel insurance claims.
class InsuranceClaimScreen extends StatefulWidget {
  final String? initialPolicyNumber;

  const InsuranceClaimScreen({
    super.key,
    this.initialPolicyNumber,
  });

  @override
  State<InsuranceClaimScreen> createState() => _InsuranceClaimScreenState();
}

class _InsuranceClaimScreenState extends State<InsuranceClaimScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<InsuranceClaim> _claims = [];
  bool _loadingClaims = true;

  final _formKey = GlobalKey<FormState>();
  final _policyNumberController = TextEditingController();
  final _insuredNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  InsuranceClaimType _incidentType = InsuranceClaimType.medicalEmergency;
  DateTime _incidentDate = DateTime.now().subtract(const Duration(days: 1));
  String _currency = 'EUR';
  final List<String> _attachedDocuments = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.initialPolicyNumber != null) {
      _policyNumberController.text = widget.initialPolicyNumber!;
    }
    _loadClaims();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _policyNumberController.dispose();
    _insuredNameController.dispose();
    _locationController.dispose();
    _amountController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadClaims() async {
    final claims = await InsuranceLocalStore.loadClaims();
    if (!mounted) return;
    setState(() {
      _claims = claims.reversed.toList();
      _loadingClaims = false;
    });
  }

  Future<void> _pickIncidentDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _incidentDate,
      firstDate: now.subtract(const Duration(days: 90)),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _incidentDate = picked);
    }
  }

  void _addMockDocument(String name) {
    if (!_attachedDocuments.contains(name)) {
      setState(() {
        _attachedDocuments.add(name);
      });
    }
    _showAttachedMessage(
      title: l10nPickAuto(en: 'Document Attached', fa: 'مدرک ضمیمه شد', ar: 'تم إرفاق المستند'),
      message: name,
    );
  }

  void _showAttachedMessage({required String title, required String message}) {
    // Safe context-free showTravelMessage using GetX root
    try {
      final ctx = Get.context;
      if (ctx != null) {
        showTravelMessage(
          ctx,
          title: title,
          message: message,
        );
      }
    } catch (_) {
      // Silently fail if no context available
    }
  }

  Future<void> _submitClaim(BuildContext context) async {
    final localization = AppLocalizations.of(context)!;
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final ref = InsuranceService.buildClaimReference();
    final claim = InsuranceClaim(
      claimId: ref,
      policyNumber: _policyNumberController.text.trim().toUpperCase(),
      insuredName: _insuredNameController.text.trim(),
      incidentType: _incidentType,
      incidentDate: _incidentDate,
      incidentLocation: _locationController.text.trim(),
      description: _descriptionController.text.trim(),
      estimatedAmount: int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0,
      currency: _currency,
      contactPhone: _phoneController.text.trim(),
      submittedAt: DateTime.now(),
      status: InsuranceClaimStatus.submitted,
      documentNames: List.from(_attachedDocuments),
    );

    await InsuranceLocalStore.addClaim(claim);

    if (!mounted) return;
    _formKey.currentState?.reset();
    setState(() {
      _isSubmitting = false;
      _claims.insert(0, claim);
      _attachedDocuments.clear();
    });

    _tabController.animateTo(1);

    _showRegistrationSuccess(localization, ref);
  }

  void _showRegistrationSuccess(AppLocalizations localization, String ref) {
    // Call back into build context after async work completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Get.context != null) {
        showTravelMessage(
          Get.context!,
          title: l10nPickAuto(en: 'Claim Registered', fa: 'پرونده خسارت ثبت شد', ar: 'تم تسجيل المطالبة بنجاح'),
          message: '${localization.travelStatus}: $ref',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = TravelTheme.isDark(context);

    return TravelPage(
      title: l10nPick(
        context,
        en: 'Insurance Claims & SOS',
        fa: 'اعلام خسارت و امداد اضطراری',
        ar: 'المطالبات والمساعدة الطارئة',
        zh: '保险理赔与紧急求助',
      ),
      showTravelNavigation: false,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: TravelTheme.blue,
            labelColor: TravelTheme.blue,
            unselectedLabelColor: TravelTheme.textSecondaryFor(context),
            tabs: [
              Tab(
                text: l10nPick(
                  context,
                  en: 'File New Claim',
                  fa: 'ثبت خسارت جدید',
                  ar: 'تقديم مطالبة جديدة',
                ),
              ),
              Tab(
                text: l10nPick(
                  context,
                  en: 'Track Claims (${_claims.length})',
                  fa: 'پیگیری پرونده‌ها (${_claims.length})',
                  ar: 'متابعة المطالبات (${_claims.length})',
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFileClaimForm(context, localization, isDark),
                _buildClaimsList(context, localization, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileClaimForm(
    BuildContext context,
    AppLocalizations localization,
    bool isDark,
  ) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsetsDirectional.fromSTEB(20.w, 14.h, 20.w, 30.h),
        children: [
          // Emergency Helpline Banner
          Container(
            padding: EdgeInsetsDirectional.all(14.r),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E3A8A).withValues(alpha: 0.25)
                  : const Color(0xFFEFF6FF),
              borderRadius: TravelTheme.radiusSm,
              border: Border.all(
                color: isDark
                    ? const Color(0xFF3B82F6).withValues(alpha: 0.4)
                    : const Color(0xFFBFDBFE),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.phone_in_talk_rounded,
                  color: Color(0xFF2563EB),
                  size: 28,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: 'Hospitalized or Need Urgent Evacuation?',
                          fa: 'بستری در بیمارستان یا نیاز به اعزام فوری؟',
                          ar: 'في المستشفى أو تحتاج إخلاء عاجل؟',
                        ),
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w900,
                          color: TravelTheme.textPrimaryFor(context),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Call SOS helpline within 48h: +33 1 45 16 65 65 for direct insurer hospital billing.',
                          fa: 'ظرف ۴۸ ساعت با امداد تماس بگیرید: ۳۳۱۴۵۱۶۶۵۶۵+ تا معرفی‌نامه مستقیم صادر شود.',
                          ar: 'اتصل بمركز الطوارئ خلال 48 ساعة لتغطية الفواتير مباشرة.',
                        ),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: TravelTheme.textSecondaryFor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Incident Type
          Text(
            l10nPick(
              context,
              en: 'Incident Classification',
              fa: 'نوع حادثه یا خسارت',
              ar: 'نوع الحادث أو المطالبة',
            ),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              color: TravelTheme.textPrimaryFor(context),
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: InsuranceClaimType.values.map((type) {
              final isSelected = _incidentType == type;
              return InkWell(
                onTap: () => setState(() => _incidentType = type),
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 10.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? TravelTheme.blue
                        : (isDark
                            ? TravelTheme.cardSurfaceFor(context)
                            : Colors.white),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isSelected
                          ? TravelTheme.blue
                          : TravelTheme.borderFor(context),
                    ),
                  ),
                  child: Text(
                    l10nPick(context, en: type.labelEn, fa: type.labelFa),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : TravelTheme.textPrimaryFor(context),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),

          // Form Fields Card
          TravelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Policy Number
                TextFormField(
                  controller: _policyNumberController,
                  decoration: InputDecoration(
                    labelText: l10nPick(
                      context,
                      en: 'Policy / Certificate Number',
                      fa: 'شماره بیمه‌نامه یا گواهی (مثال: EC-SNG-...)',
                      ar: 'رقم وثيقة التأمين',
                    ),
                    prefixIcon: const Icon(Icons.verified_outlined),
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

                // Insured Name
                TextFormField(
                  controller: _insuredNameController,
                  decoration: InputDecoration(
                    labelText: l10nPick(
                      context,
                      en: 'Full Name of Insured Traveler',
                      fa: 'نام کامل مسافر آسیب‌دیده (مطابق پاسپورت)',
                      ar: 'اسم المؤمن عليه بالكامل',
                    ),
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

                // Incident Date & Location
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickIncidentDate(context),
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: 12.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: TravelTheme.borderFor(context),
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event_rounded, size: 20),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  DateFormat('yyyy-MM-dd').format(_incidentDate),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: TravelTheme.textPrimaryFor(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: l10nPick(
                            context,
                            en: 'City, Country',
                            fa: 'شهر و کشور محل حادثه',
                            ar: 'المدينة والدولة',
                          ),
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          border: const OutlineInputBorder(),
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
                SizedBox(height: 12.h),

                // Amount and Currency
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10nPick(
                            context,
                            en: 'Estimated Claim Expense',
                            fa: 'مبلغ تقریبی خسارت',
                            ar: 'المبلغ التقريبي للمطالبة',
                          ),
                          prefixIcon: const Icon(Icons.payments_outlined),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return localization.travelFormRequired;
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        initialValue: _currency,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: ['EUR', 'USD', 'IRR', 'TRY', 'AED']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _currency = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Contact Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10nPick(
                      context,
                      en: 'Direct Contact Phone Number',
                      fa: 'شماره تلفن مستقیم جهت تماس کارشناس',
                      ar: 'رقم الهاتف للتواصل',
                    ),
                    prefixIcon: const Icon(Icons.phone_rounded),
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

                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10nPick(
                      context,
                      en: 'Brief Description of the Incident',
                      fa: 'شرح مختصر واقعه و اقدامات درمانی / صورت گرفته',
                      ar: 'وصف موجز للحادث',
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return localization.travelFormRequired;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Document Attachments
          Text(
            l10nPick(
              context,
              en: 'Attach Invoices & Receipts',
              fa: 'ضمیمه صورت‌حساب‌ها و فاکتورها',
              ar: 'المستندات والفواتير المرفقة',
            ),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              color: TravelTheme.textPrimaryFor(context),
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _DocChip(
                label: l10nPick(
                  context,
                  en: '+ Hospital Invoice',
                  fa: '+ صورتحساب بیمارستان',
                  ar: '+ فاتورة المستشفى',
                ),
                onTap: () => _addMockDocument('Hospital_Invoice.pdf'),
              ),
              _DocChip(
                label: l10nPick(
                  context,
                  en: '+ Prescription / RX',
                  fa: '+ نسخه دارو و درمان',
                  ar: '+ الوصفة الطبية',
                ),
                onTap: () => _addMockDocument('Medical_Prescription.pdf'),
              ),
              _DocChip(
                label: l10nPick(
                  context,
                  en: '+ Police / PIR Report',
                  fa: '+ گزارش پلیس یا ایرلاین (PIR)',
                  ar: '+ تقرير الشرطة / تقرير الأمتعة',
                ),
                onTap: () => _addMockDocument('Airline_PIR_Report.pdf'),
              ),
              _DocChip(
                label: l10nPick(
                  context,
                  en: '+ Passport Stamp',
                  fa: '+ مهر ورود و خروج پاسپورت',
                  ar: '+ ختم الجوازات',
                ),
                onTap: () => _addMockDocument('Passport_Stamps.pdf'),
              ),
            ],
          ),
          if (_attachedDocuments.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Column(
              children: _attachedDocuments
                  .map(
                    (doc) => Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 6.h),
                      child: Container(
                        padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? TravelTheme.cardSurfaceFor(context)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.attach_file_rounded,
                              size: 16,
                              color: TravelTheme.blue,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                doc,
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: TravelTheme.textPrimaryFor(context),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () => setState(
                                () => _attachedDocuments.remove(doc),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          SizedBox(height: 20.h),

          // Submit Button
          CommonButton(
            width: double.infinity,
            text: _isSubmitting
                ? l10nPick(
                    context,
                    en: 'Registering Claim...',
                    fa: 'در حال ثبت پرونده خسارت...',
                    ar: 'جاري تسجيل المطالبة...',
                  )
                : l10nPick(
                    context,
                    en: 'Submit Claim to Adjuster',
                    fa: 'ارسال پرونده به کارشناس خسارت',
                    ar: 'إرسال المطالبة للتقييم',
                  ),
            backgroundColor: TravelTheme.blue,
            onPressed: _isSubmitting ? () {} : () => _submitClaim(context),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimsList(
    BuildContext context,
    AppLocalizations localization,
    bool isDark,
  ) {
    if (_loadingClaims) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_claims.isEmpty) {
      return TravelEmptyState(
        icon: Icons.assignment_turned_in_outlined,
        title: l10nPick(
          context,
          en: 'No Claims Filed Yet',
          fa: 'هنوز پرونده خسارتی ثبت نشده است',
          ar: 'لا توجد مطالبات مسجلة حتى الآن',
        ),
        message: l10nPick(
          context,
          en: 'If you experienced medical issues, flight delays or baggage damage during your trip, submit a claim anytime.',
          fa: 'در صورت بروز حوادث درمانی، تأخیر پرواز یا خسارت بار، می‌توانید در هر زمان پرونده خود را ثبت نمایید.',
          ar: 'يمكنك تقديم مطالبة في حال واجهت أي طارئ صحي أو تأخير في الرحلة.',
        ),
        actionText: l10nPick(
          context,
          en: 'File a Claim Now',
          fa: 'ثبت اولین پرونده خسارت',
          ar: 'تقديم مطالبة الآن',
        ),
        onAction: () => _tabController.animateTo(0),
      );
    }

    return ListView.builder(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 14.h, 20.w, 30.h),
      itemCount: _claims.length,
      itemBuilder: (context, index) {
        final claim = _claims[index];
        return Padding(
          padding: EdgeInsetsDirectional.only(bottom: 12.h),
          child: TravelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      claim.claimId,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        color: TravelTheme.blue,
                      ),
                    ),
                    Container(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: claim.status.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        l10nPick(
                          context,
                          en: claim.status.labelEn,
                          fa: claim.status.labelFa,
                        ),
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w900,
                          color: claim.status.color,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  l10nPick(
                    context,
                    en: claim.incidentType.labelEn,
                    fa: claim.incidentType.labelFa,
                  ),
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w900,
                    color: TravelTheme.textPrimaryFor(context),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${claim.policyNumber} · ${claim.incidentLocation} · ${DateFormat('yyyy-MM-dd').format(claim.incidentDate)}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: TravelTheme.textSecondaryFor(context),
                  ),
                ),
                if (claim.description.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    claim.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: TravelTheme.textPrimaryFor(context),
                    ),
                  ),
                ],
                const Divider(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10nPick(
                        context,
                        en: 'Claimed: ${formatMockAmount(claim.estimatedAmount)} ${claim.currency}',
                        fa: 'مبلغ مطالبه: ${formatMockAmount(claim.estimatedAmount)} ${claim.currency}',
                        ar: 'المبلغ: ${formatMockAmount(claim.estimatedAmount)} ${claim.currency}',
                      ),
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w800,
                        color: TravelTheme.textPrimaryFor(context),
                      ),
                    ),
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(claim.submittedAt),
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: TravelTheme.textSecondaryFor(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DocChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DocChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = TravelTheme.isDark(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isDark
              ? TravelTheme.cardSurfaceFor(context)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: TravelTheme.borderFor(context)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: TravelTheme.textPrimaryFor(context),
          ),
        ),
      ),
    );
  }
}
