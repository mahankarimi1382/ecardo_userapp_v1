import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/mock_travel_data.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/service_form_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/travel_service_request.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/travel_service_requests_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_theme.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_widgets.dart';

/// Visa module — country catalog + application form. The application is an
/// internal request (stored locally with the under-review status the admin
/// flow will pick up later); no external provider is involved.
class VisaIntroScreen extends StatelessWidget {
  const VisaIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return TravelPage(
      title: localization.travelServiceVisa,
      showTravelNavigation: false,
      trailing: IconButton(
        tooltip: localization.travelMyRequests,
        onPressed: () => Get.to(() => const TravelServiceRequestsScreen()),
        icon: const Icon(Icons.receipt_long_rounded),
      ),
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          Container(
            height: 170.h,
            padding: EdgeInsets.all(22.r),
            decoration: BoxDecoration(
              borderRadius: TravelTheme.radius,
              gradient: const LinearGradient(
                colors: [Color(0xFF283593), TravelTheme.purple],
              ),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Icon(
                    Icons.approval_rounded,
                    size: 110.r,
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Text(
                    localization.travelVisaHero,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          TravelJourneyGuide(
            currentStep: 1,
            steps: [
              localization.travelVisaStepDocuments,
              localization.travelVisaStepReview,
              localization.travelVisaStepIssue,
            ],
            message: localization.travelVisaIntroDescription,
          ),
          SizedBox(height: 20.h),
          TravelSectionHeader(title: localization.travelVisaCountries),
          SizedBox(height: 10.h),
          ...mockVisaCountries.map(
            (country) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: TravelCard(
                onTap: () => Get.to(
                  () => VisaRequestFormScreen(country: country),
                ),
                child: Row(
                  children: [
                    Text(country.flagEmoji, style: TextStyle(fontSize: 34.sp)),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TravelBidiText(
                            country.name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            travelVisaProcessingLabel(
                              localization,
                              country.processingDays,
                            ),
                            style: TextStyle(
                              color: TravelTheme.muted,
                              fontSize: 10.5.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${formatMockAmount(country.touristPrice)} ${localization.travelMockCurrency}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: TravelTheme.purple,
                            fontSize: 12.5.sp,
                          ),
                        ),
                        Text(
                          localization.travelStartingPrice,
                          style: TextStyle(
                            color: TravelTheme.muted,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String travelVisaProcessingLabel(
  AppLocalizations localization,
  int days,
) => localization.travelVisaProcessingDays(days);

class VisaRequestFormScreen extends StatefulWidget {
  final VisaCountry country;

  const VisaRequestFormScreen({super.key, required this.country});

  @override
  State<VisaRequestFormScreen> createState() => _VisaRequestFormScreenState();
}

class _VisaRequestFormScreenState extends State<VisaRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _passportController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  String _visaType = 'tourist';
  String _entries = 'single';
  int _applicants = 1;
  DateTime? _travelDate;
  DateTime? _passportExpiry;

  @override
  void dispose() {
    _fullNameController.dispose();
    _passportController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get _basePrice => _visaType == 'business'
      ? widget.country.businessPrice
      : widget.country.touristPrice;
  int get _totalPrice =>
      _basePrice * _applicants * (_entries == 'multiple' ? 2 : 1);

  Future<void> _pickDate({
    required bool isTravelDate,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: isTravelDate ? now : now,
      lastDate: now.add(const Duration(days: 1200)),
    );
    if (picked == null) return;
    setState(() {
      if (isTravelDate) {
        _travelDate = picked;
      } else {
        _passportExpiry = picked;
      }
    });
  }

  Future<void> _submit() async {
    final localization = AppLocalizations.of(context)!;
    if (_formKey.currentState?.validate() != true) return;
    final visaTypeLabel = _visaType == 'business'
        ? localization.travelVisaBusiness
        : localization.travelVisaTourist;
    final entriesLabel = _entries == 'multiple'
        ? localization.travelVisaMultipleEntry
        : localization.travelVisaSingleEntry;
    final details = <String, String>{
      localization.travelVisaCountry: widget.country.name,
      localization.travelVisaType: visaTypeLabel,
      localization.travelVisaEntries: entriesLabel,
      localization.travelVisaApplicants: '$_applicants',
      if (_travelDate != null)
        localization.travelVisaTravelDate: DateFormat(
          'yyyy-MM-dd',
        ).format(_travelDate!),
      localization.travelVisaFullName: _fullNameController.text.trim(),
      localization.travelVisaPassportNumber: _passportController.text.trim(),
      if (_passportExpiry != null)
        localization.travelVisaPassportExpiry: DateFormat(
          'yyyy-MM-dd',
        ).format(_passportExpiry!),
      localization.travelContactPhone: _phoneController.text.trim(),
      if (_notesController.text.trim().isNotEmpty)
        localization.travelFieldNote: _notesController.text.trim(),
    };
    final request = TravelServiceRequest(
      id: 'req-${DateTime.now().microsecondsSinceEpoch}',
      serviceKey: 'visa',
      title: '${widget.country.flagEmoji} ${widget.country.name}',
      subtitle: '$visaTypeLabel · $entriesLabel',
      amountLabel:
          '${formatMockAmount(_totalPrice)} ${localization.travelMockCurrency}',
      reference: TravelServiceRequest.generateReference(),
      createdAt: DateTime.now(),
      details: details,
    );
    await TravelServiceRequestStore.add(request);
    if (!mounted) return;
    Get.off(() => TravelServiceRequestSuccessScreen(request: request));
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return TravelPage(
      title: localization.travelVisaFormTitle,
      showTravelNavigation: false,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CommonButton(
            width: double.infinity,
            text: localization.travelVisaSubmit,
            backgroundColor: TravelTheme.purple,
            onPressed: _submit,
          ),
        ),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20.r),
          children: [
            TravelCard(
              color: const Color(0xFFEDE7F6),
              child: Row(
                children: [
                  Text(
                    widget.country.flagEmoji,
                    style: TextStyle(fontSize: 38.sp),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TravelBidiText(
                          widget.country.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          travelVisaProcessingLabel(
                            localization,
                            widget.country.processingDays,
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
            ),
            SizedBox(height: 18.h),
            TravelSectionHeader(title: localization.travelVisaDocuments),
            SizedBox(height: 10.h),
            TravelCard(
              child: Column(
                children: mockVisaDocuments
                    .map(
                      (document) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.h),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 16.r,
                              color: TravelTheme.green,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: TravelBidiText(
                                document,
                                style: TextStyle(fontSize: 11.5.sp),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            SizedBox(height: 18.h),
            TravelSectionHeader(title: localization.travelServiceVisa),
            SizedBox(height: 10.h),
            TravelCard(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _visaType,
                    decoration: InputDecoration(
                      labelText: localization.travelVisaType,
                      prefixIcon: const Icon(Icons.approval_rounded),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'tourist',
                        child: Text(localization.travelVisaTourist),
                      ),
                      DropdownMenuItem(
                        value: 'business',
                        child: Text(localization.travelVisaBusiness),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _visaType = value ?? 'tourist'),
                  ),
                  SizedBox(height: 12.h),
                  DropdownButtonFormField<String>(
                    initialValue: _entries,
                    decoration: InputDecoration(
                      labelText: localization.travelVisaEntries,
                      prefixIcon: const Icon(Icons.repeat_rounded),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'single',
                        child: Text(localization.travelVisaSingleEntry),
                      ),
                      DropdownMenuItem(
                        value: 'multiple',
                        child: Text(localization.travelVisaMultipleEntry),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _entries = value ?? 'single'),
                  ),
                  SizedBox(height: 12.h),
                  DropdownButtonFormField<int>(
                    initialValue: _applicants,
                    decoration: InputDecoration(
                      labelText: localization.travelVisaApplicants,
                      prefixIcon: const Icon(Icons.people_outline_rounded),
                    ),
                    items: [for (var i = 1; i <= 6; i++) i]
                        .map(
                          (count) => DropdownMenuItem(
                            value: count,
                            child: Text('$count'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _applicants = value ?? 1),
                  ),
                  SizedBox(height: 12.h),
                  TravelFieldTile(
                    label: localization.travelVisaTravelDate,
                    value: _travelDate == null
                        ? localization.travelFormPickHint
                        : DateFormat('yyyy-MM-dd').format(_travelDate!),
                    icon: Icons.flight_takeoff_rounded,
                    onTap: () => _pickDate(isTravelDate: true),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            TravelSectionHeader(title: localization.travelPrimaryPassenger),
            SizedBox(height: 10.h),
            TravelCard(
              child: Column(
                children: [
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: localization.travelVisaFullName,
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                        ? localization.travelFormRequired
                        : null,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _passportController,
                    decoration: InputDecoration(
                      labelText: localization.travelVisaPassportNumber,
                      prefixIcon: const Icon(Icons.badge_rounded),
                    ),
                    validator: (value) =>
                        value == null || value.trim().length < 6
                        ? localization.travelFormRequired
                        : null,
                  ),
                  SizedBox(height: 12.h),
                  TravelFieldTile(
                    label: localization.travelVisaPassportExpiry,
                    value: _passportExpiry == null
                        ? localization.travelFormPickHint
                        : DateFormat('yyyy-MM-dd').format(_passportExpiry!),
                    icon: Icons.event_busy_rounded,
                    onTap: () => _pickDate(isTravelDate: false),
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: localization.travelContactPhone,
                      prefixIcon: const Icon(Icons.phone_rounded),
                    ),
                    validator: (value) =>
                        value == null || value.trim().length < 10
                        ? localization.travelFormRequired
                        : null,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: localization.travelFieldNote,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            TravelCard(
              color: const Color(0xFFEDE7F6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localization.travelTotal,
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    '${formatMockAmount(_totalPrice)} ${localization.travelMockCurrency}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: TravelTheme.purple,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              localization.travelExtraUnderReviewNote,
              textAlign: TextAlign.center,
              style: TextStyle(color: TravelTheme.muted, fontSize: 10.5.sp),
            ),
          ],
        ),
      ),
    );
  }
}
