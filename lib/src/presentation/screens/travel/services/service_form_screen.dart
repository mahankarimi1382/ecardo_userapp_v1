import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/service_form_spec.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/travel_service_request.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/travel_service_requests_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_theme.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_widgets.dart';

/// Generic request form for the extra travel services. Fields are declared
/// with [TravelFormFieldSpec]; the submission is stored locally with the
/// `underReview` status (no backend contract for these demo services yet).
class TravelServiceFormScreen extends StatefulWidget {
  final String serviceKey;
  final String title;
  final String itemTitle;
  final String itemSubtitle;
  final String amountLabel;
  final List<TravelFormFieldSpec> fields;

  const TravelServiceFormScreen({
    super.key,
    required this.serviceKey,
    required this.title,
    required this.itemTitle,
    required this.itemSubtitle,
    required this.amountLabel,
    required this.fields,
  });

  @override
  State<TravelServiceFormScreen> createState() =>
      _TravelServiceFormScreenState();
}

class _TravelServiceFormScreenState extends State<TravelServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _values = <String, String>{};
  final _controllers = <String, TextEditingController>{};

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(TravelFormFieldSpec spec) {
    return _controllers.putIfAbsent(
      spec.key,
      () => TextEditingController(),
    );
  }

  Future<void> _pickDateTime(TravelFormFieldSpec spec) async {
    if (spec.type == TravelFormFieldType.date) {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: now.add(const Duration(days: 1)),
        firstDate: now,
        lastDate: now.add(const Duration(days: 400)),
      );
      if (picked != null) {
        setState(() {
          _values[spec.key] = DateFormat('yyyy-MM-dd').format(picked);
        });
      }
      return;
    }
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _values[spec.key] = picked.format(context);
      });
    }
  }

  Future<void> _submit(AppLocalizations localization) async {
    final valid = _formKey.currentState?.validate() == true;
    if (!valid) return;
    final details = <String, String>{
      for (final spec in widget.fields)
        if (_values[spec.key]?.trim().isNotEmpty == true)
          spec.label(): _values[spec.key]!.trim(),
    };
    final request = TravelServiceRequest(
      id: 'req-${DateTime.now().microsecondsSinceEpoch}',
      serviceKey: widget.serviceKey,
      title: widget.itemTitle,
      subtitle: widget.itemSubtitle,
      amountLabel: widget.amountLabel,
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
      title: widget.title,
      showTravelNavigation: false,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20.r),
          children: [
            TravelCard(
              color: const Color(0xFFEAF3FF),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.itemTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.sp,
                    ),
                  ),
                  if (widget.itemSubtitle.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    TravelBidiText(
                      widget.itemSubtitle,
                      style: TextStyle(
                        color: TravelTheme.muted,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                  if (widget.amountLabel.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      '${localization.travelTotal}: ${widget.amountLabel}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.sp,
                        color: TravelTheme.blue,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 18.h),
            ...widget.fields.map(
              (spec) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildField(spec, localization),
              ),
            ),
            SizedBox(height: 6.h),
            CommonButton(
              width: double.infinity,
              text: localization.travelFormSubmit,
              backgroundColor: TravelTheme.blue,
              onPressed: () => _submit(localization),
            ),
            SizedBox(height: 10.h),
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

  Widget _buildField(TravelFormFieldSpec spec, AppLocalizations localization) {
    final label = spec.label();
    if (spec.type == TravelFormFieldType.dropdown) {
      return DropdownButtonFormField<String>(
        initialValue: _values[spec.key],
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(spec.icon),
          border: const OutlineInputBorder(),
        ),
        items: spec.options
            .map(
              (option) => DropdownMenuItem(value: option, child: Text(option)),
            )
            .toList(),
        validator: (value) =>
            spec.required && (value == null || value.isEmpty)
            ? localization.travelFormRequired
            : null,
        onChanged: (value) => _values[spec.key] = value ?? '',
      );
    }
    if (spec.type == TravelFormFieldType.date ||
        spec.type == TravelFormFieldType.time) {
      return TravelFieldTile(
        label: label,
        value: _values[spec.key] ?? localization.travelFormPickHint,
        icon: spec.icon,
        onTap: () => _pickDateTime(spec),
      );
    }
    final controller = _controllerFor(spec);
    return TextFormField(
      controller: controller,
      keyboardType: spec.type == TravelFormFieldType.phone
          ? TextInputType.phone
          : spec.type == TravelFormFieldType.number
          ? TextInputType.number
          : TextInputType.text,
      maxLines: spec.type == TravelFormFieldType.textarea ? spec.maxLines ?? 3 : 1,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: spec.type == TravelFormFieldType.textarea
            ? null
            : Icon(spec.icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          spec.required && (value == null || value.trim().isEmpty)
          ? localization.travelFormRequired
          : null,
      onChanged: (value) => _values[spec.key] = value,
    );
  }
}

/// Confirmation shown right after a request is submitted — the request is
/// tracked under "My requests" with the under-review status.
class TravelServiceRequestSuccessScreen extends StatelessWidget {
  final TravelServiceRequest request;

  const TravelServiceRequestSuccessScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return TravelPage(
      title: localization.travelRequestSubmittedTitle,
      showTravelNavigation: false,
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          SizedBox(height: 26.h),
          CircleAvatar(
            radius: 42.r,
            backgroundColor: TravelTheme.green.withValues(alpha: .12),
            child: Icon(
              Icons.check_circle_rounded,
              color: TravelTheme.green,
              size: 52.r,
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            localization.travelRequestSubmittedTitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8.h),
          Text(
            localization.travelRequestSubmittedDescription,
            textAlign: TextAlign.center,
            style: TextStyle(color: TravelTheme.muted, fontSize: 11.5.sp),
          ),
          SizedBox(height: 22.h),
          TravelCard(
            child: Column(
              children: [
                _requestRow(
                  localization.travelRequestReference,
                  request.reference,
                ),
                Divider(color: TravelTheme.border),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localization.travelStatus,
                        style: TextStyle(
                          color: TravelTheme.muted,
                          fontSize: 12.sp,
                        ),
                      ),
                      TravelRequestStatusChip(status: request.status),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 22.h),
          CommonButton(
            width: double.infinity,
            text: localization.travelMyRequests,
            backgroundColor: TravelTheme.blue,
            onPressed: () => Get.off(
              () => const TravelServiceRequestsScreen(),
            ),
          ),
          SizedBox(height: 10.h),
          CommonButton(
            width: double.infinity,
            text: localization.travelRequestBackHome,
            backgroundColor: TravelTheme.muted,
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _requestRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: TravelTheme.muted, fontSize: 12.sp)),
          TravelBidiText(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

/// Colored status chip — under review / approved / rejected.
class TravelRequestStatusChip extends StatelessWidget {
  final TravelServiceRequestStatus status;

  const TravelRequestStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final label = switch (status) {
      TravelServiceRequestStatus.approved => localization.travelRequestApproved,
      TravelServiceRequestStatus.rejected => localization.travelRequestRejected,
      TravelServiceRequestStatus.underReview =>
        localization.travelRequestUnderReview,
    };
    final color = switch (status) {
      TravelServiceRequestStatus.approved => TravelTheme.green,
      TravelServiceRequestStatus.rejected => TravelTheme.red,
      TravelServiceRequestStatus.underReview => TravelTheme.warning,
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 11.sp,
        ),
      ),
    );
  }
}
