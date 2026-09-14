// remittance_receiver_section.dart — Step 3: Receiver information form.
//
// Task-12 — TWO structural fixes:
//
// 1) DYNAMIC PAYOUT FIELDS: the form previously hard-coded ALL payout
//    fields (bank / account / IBAN / Alipay / WeChat) regardless of the
//    selected method, and NEVER collected swift / shaba_number /
//    usdt_address / card_number — although the backend storeFlat()
//    validation accepts them and the admin-configured method `fields`
//    mark them REQUIRED (CN-BANK → swift, SHABA → shaba_number,
//    USDT-WALLET → usdt_address). The form now renders EXACTLY the fields
//    the selected method defines (from the methods endpoint) and marks the
//    required ones. If the method defines no fields, the legacy generic
//    bank set is shown (same behavior as before).
//
// 2) COUNTRY LIST FROM API: the hard-coded 8-country dropdown (IR, CN, TR,
//    AE, RU, PK, AF, IQ) is replaced by the global /get-countries payload
//    loaded by the controller. A compact offline fallback keeps the flow
//    usable if the API call failed.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/model/remittance_model.dart';

/// Step 3: Receiver information form.
class RemittanceReceiverSection extends StatelessWidget {
  const RemittanceReceiverSection({super.key});

  /// Offline fallback — only used when /get-countries returned nothing
  /// (e.g. transient network failure). Keep in sync with the payout
  /// methods' country coverage (CN / IR today).
  static const _fallbackCountries = [
    ('IR', 'Iran'), ('CN', 'China'), ('TR', 'Turkey'), ('AE', 'UAE'),
    ('RU', 'Russia'), ('PK', 'Pakistan'), ('AF', 'Afghanistan'), ('IQ', 'Iraq'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RemittanceController>();
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.remittanceReceiverInfo, style: _title()),
        SizedBox(height: 16.h),
        _Label(l.remittanceReceiverName),
        _Field(c.receiverNameController, l.remittanceReceiverName),
        SizedBox(height: 16.h),
        _Label(l.remittanceSelectCountry),
        Obx(() => _CountryDropdown(
              value: c.selectedReceiverCountry.value,
              countries: c.countries.isNotEmpty
                  ? c.countries.map((x) => (x.code ?? '', x.name ?? '')).toList()
                  : _fallbackCountries,
              onChanged: (v) => c.selectedReceiverCountry.value = v ?? '',
              hint: l.remittanceSelectCountry,
            )),
        SizedBox(height: 16.h),
        _Label(l.remittanceReceiverPhone),
        _Field(c.receiverPhoneController, '+86 138 0000 0000', keyboardType: TextInputType.phone),
        SizedBox(height: 24.h),
        Divider(color: AppColors.lightBorder),
        SizedBox(height: 16.h),
        Text(l.remittancePayoutDetails, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
        SizedBox(height: 4.h),
        Text(l.remittancePayoutDetailsHint, style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary)),
        SizedBox(height: 16.h),
        // Task-12 — dynamic fields driven by the selected method. Wrapped
        // in Obx so switching the payout method re-renders the form.
        Obx(() {
          final fields = c.selectedMethodFields;
          if (fields.isEmpty) {
            // Legacy generic set — method defines no custom fields.
            return Column(children: [
              _LabeledField(controller: c, name: 'bank_name', label: c.localizedFieldLabel(_generic('bank_name')), required: false),
              SizedBox(height: 16.h),
              _LabeledField(controller: c, name: 'account_number', label: c.localizedFieldLabel(_generic('account_number')), required: false),
              SizedBox(height: 16.h),
              _LabeledField(controller: c, name: 'iban', label: c.localizedFieldLabel(_generic('iban')), required: false),
              SizedBox(height: 16.h),
              _LabeledField(controller: c, name: 'alipay_account', label: c.localizedFieldLabel(_generic('alipay_account')), required: false),
              SizedBox(height: 16.h),
              _LabeledField(controller: c, name: 'wechat_account', label: c.localizedFieldLabel(_generic('wechat_account')), required: false),
            ]);
          }
          return Column(
            children: [
              for (var i = 0; i < fields.length; i++) ...[
                _LabeledField(
                  controller: c,
                  name: fields[i].name,
                  label: c.localizedFieldLabel(fields[i]),
                  required: fields[i].required,
                ),
                if (i < fields.length - 1) SizedBox(height: 16.h),
              ],
            ],
          );
        }),
      ],
    );
  }

  /// Synthetic descriptor for the legacy generic set (method.fields empty).
  static RemittanceMethodField _generic(String name) {
    const labels = {
      'bank_name': 'Bank Name',
      'account_number': 'Account Number',
      'iban': 'IBAN',
      'alipay_account': 'Alipay Account',
      'wechat_account': 'WeChat Account',
    };
    return RemittanceMethodField(name: name, label: labels[name] ?? name);
  }

  TextStyle _title() => TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary);
}

class _LabeledField extends StatelessWidget {
  final RemittanceController controller;
  final String name;
  final String label;
  final bool required;
  const _LabeledField({
    required this.controller,
    required this.name,
    required this.label,
    required this.required,
  });

  @override
  Widget build(BuildContext context) {
    final fieldController = controller.methodFieldController(name);
    if (fieldController == null) {
      // Unknown backend field name — skip silently (never crash).
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(required ? '$label *' : label),
        _Field(fieldController, label,
            keyboardType: name == 'card_number' || name == 'account_number'
                ? TextInputType.number
                : TextInputType.text),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: Text(text, style: TextStyle(fontSize: 13.sp, color: AppColors.lightTextSecondary)),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  const _Field(this.controller, this.hint, {this.keyboardType});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.lightTextHint),
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.lightBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.lightBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.lightPrimary, width: 1.5)),
        ),
      );
}

class _CountryDropdown extends StatelessWidget {
  final String value;
  final List<(String, String)> countries;
  final ValueChanged<String?> onChanged;
  final String hint;
  const _CountryDropdown({
    required this.value,
    required this.countries,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: countries.any((c) => c.$1 == value) && value.isNotEmpty
                ? value
                : null,
            hint: Text(hint, style: TextStyle(fontSize: 14.sp, color: AppColors.lightTextHint)),
            isExpanded: true,
            items: countries
                .map((c) => DropdownMenuItem(value: c.$1, child: Text('${c.$1} — ${c.$2}', style: TextStyle(fontSize: 14.sp))))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );
}
