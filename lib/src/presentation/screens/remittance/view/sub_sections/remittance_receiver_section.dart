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
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/model/remittance_model.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';

/// Step 3: Receiver information form.
class RemittanceReceiverSection extends StatelessWidget {
  const RemittanceReceiverSection({super.key});

  /// Offline fallback — only used when /get-countries returned nothing
  /// (e.g. transient network failure). Keep in sync with the payout
  /// methods' country coverage (CN / IR today).
  static const _fallbackCountries = [
    ('IR', 'Iran'),
    ('CN', 'China'),
    ('TR', 'Turkey'),
    ('AE', 'UAE'),
    ('RU', 'Russia'),
    ('PK', 'Pakistan'),
    ('AF', 'Afghanistan'),
    ('IQ', 'Iraq'),
  ];

  /// Validates Iranian Sheba format:
  /// Must begin with 'IR' (case-insensitive) followed by exactly 24 digits (total 26 characters).
  static String? validateSheba(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      if (required) return 'Sheba number is required';
      return null;
    }
    final clean = value.replaceAll(' ', '').toUpperCase();
    if (!clean.startsWith('IR')) {
      return 'Sheba must start with IR';
    }
    if (clean.length != 26) {
      return 'Sheba must be exactly 26 characters (IR + 24 digits)';
    }
    final digitsPart = clean.substring(2);
    if (!RegExp(r'^\d{24}$').hasMatch(digitsPart)) {
      return 'Sheba must contain only 24 digits after IR';
    }
    return null;
  }

  /// Luhn checksum calculation for 16-digit debit/credit card numbers.
  static bool isValidLuhn(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 16) return false;
    int sum = 0;
    bool alternate = false;
    for (int i = digits.length - 1; i >= 0; i--) {
      int n = int.parse(digits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n -= 9;
        }
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  /// Validates 16-digit debit card numbers:
  /// Must be exactly 16 digits, with optional Luhn checksum check.
  static String? validateCardNumber(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      if (required) return 'Card number is required';
      return null;
    }
    final clean = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (!RegExp(r'^\d+$').hasMatch(clean)) {
      return 'Card number must contain digits only';
    }
    if (clean.length != 16) {
      return 'Card number must be exactly 16 digits';
    }
    if (!isValidLuhn(clean)) {
      return 'Invalid card number checksum';
    }
    return null;
  }

  /// Validates all receiver fields before calling [RemittanceController.nextStep].
  static bool validate(BuildContext context, RemittanceController controller) {
    final l = AppLocalizations.of(context);

    // 1. Core receiver fields
    if (controller.receiverNameController.text.trim().isEmpty ||
        controller.receiverPhoneController.text.trim().isEmpty ||
        controller.selectedReceiverCountry.value.isEmpty) {
      ToastHelper().showErrorToast(
        l?.remittanceErrCompleteReceiver ??
            'Please complete receiver information',
      );
      return false;
    }

    // 2. Sheba validation for shaba_number field
    final isShebaRequired = controller.selectedMethodFields.any(
      (f) => (f.name == 'shaba_number' || f.name == 'iban') && f.required,
    );
    final shabaVal = controller.receiverShabaController.text.trim();
    if (shabaVal.isNotEmpty || isShebaRequired) {
      final err = validateSheba(shabaVal, required: isShebaRequired);
      if (err != null) {
        ToastHelper().showErrorToast(err);
        return false;
      }
    }

    // 3. IBAN field when country is IR or value starts with IR
    final ibanVal = controller.receiverIbanController.text.trim();
    if (ibanVal.isNotEmpty &&
        (controller.selectedReceiverCountry.value == 'IR' ||
            ibanVal.toUpperCase().startsWith('IR'))) {
      final err = validateSheba(ibanVal, required: false);
      if (err != null) {
        ToastHelper().showErrorToast(err);
        return false;
      }
    }

    // 4. 16-digit debit card validation
    final isCardRequired = controller.selectedMethodFields.any(
      (f) => f.name == 'card_number' && f.required,
    );
    final cardVal = controller.receiverCardNumberController.text.trim();
    if (cardVal.isNotEmpty || isCardRequired) {
      final err = validateCardNumber(cardVal, required: isCardRequired);
      if (err != null) {
        ToastHelper().showErrorToast(err);
        return false;
      }
    }

    // 5. Enforce required dynamic payout fields
    for (final field in controller.selectedMethodFields) {
      if (!field.required) continue;
      final fc = controller.methodFieldController(field.name);
      if (fc == null || fc.text.trim().isEmpty) {
        ToastHelper().showErrorToast(
          l?.remittanceErrRequiredField(
                controller.localizedFieldLabel(field),
              ) ??
              'Please enter ${field.label}',
        );
        return false;
      }
    }

    return true;
  }

  /// Convenience method that validates the receiver form and triggers [RemittanceController.nextStep].
  static void proceedToNextStep(
    BuildContext context,
    RemittanceController controller,
  ) {
    if (validate(context, controller)) {
      controller.nextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RemittanceController>();
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.remittanceReceiverInfo, style: _title(context)),
        SizedBox(height: 16.h),
        _Label(l.remittanceReceiverName),
        _Field(c.receiverNameController, l.remittanceReceiverName),
        SizedBox(height: 16.h),
        _Label(l.remittanceSelectCountry),
        Obx(
          () => _CountryDropdown(
            value: c.selectedReceiverCountry.value,
            countries: c.countries.isNotEmpty
                ? c.countries.map((x) => (x.code ?? '', x.name ?? '')).toList()
                : _fallbackCountries,
            onChanged: (v) => c.selectedReceiverCountry.value = v ?? '',
            hint: l.remittanceSelectCountry,
          ),
        ),
        SizedBox(height: 16.h),
        _Label(l.remittanceReceiverPhone),
        _Field(
          c.receiverPhoneController,
          '+86 138 0000 0000',
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 24.h),
        Divider(color: isDark ? AppColors.darkDivider : AppColors.lightBorder),
        SizedBox(height: 16.h),
        Text(
          l.remittancePayoutDetails,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          l.remittancePayoutDetailsHint,
          style: TextStyle(
            fontSize: 11.sp,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        // Task-12 — dynamic fields driven by the selected method. Wrapped
        // in Obx so switching the payout method re-renders the form.
        Obx(() {
          final fields = c.selectedMethodFields;
          if (fields.isEmpty) {
            // Legacy generic set — method defines no custom fields.
            return Column(
              children: [
                _LabeledField(
                  controller: c,
                  name: 'bank_name',
                  label: c.localizedFieldLabel(_generic('bank_name')),
                  required: false,
                ),
                SizedBox(height: 16.h),
                _LabeledField(
                  controller: c,
                  name: 'account_number',
                  label: c.localizedFieldLabel(_generic('account_number')),
                  required: false,
                ),
                SizedBox(height: 16.h),
                _LabeledField(
                  controller: c,
                  name: 'iban',
                  label: c.localizedFieldLabel(_generic('iban')),
                  required: false,
                ),
                SizedBox(height: 16.h),
                _LabeledField(
                  controller: c,
                  name: 'alipay_account',
                  label: c.localizedFieldLabel(_generic('alipay_account')),
                  required: false,
                ),
                SizedBox(height: 16.h),
                _LabeledField(
                  controller: c,
                  name: 'wechat_account',
                  label: c.localizedFieldLabel(_generic('wechat_account')),
                  required: false,
                ),
              ],
            );
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

  TextStyle _title(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }
}

class _LabeledField extends StatefulWidget {
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
  State<_LabeledField> createState() => _LabeledFieldState();
}

class _LabeledFieldState extends State<_LabeledField> {
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final c = widget.controller.methodFieldController(widget.name);
    if (c != null && c.text.isNotEmpty) {
      _validate(c.text);
    }
  }

  void _validate(String value) {
    String? err;
    final trimmed = value.trim();
    final isSheba =
        widget.name == 'shaba_number' ||
        (widget.name == 'iban' &&
            (widget.controller.selectedReceiverCountry.value == 'IR' ||
                trimmed.toUpperCase().startsWith('IR')));
    final isCard = widget.name == 'card_number';

    if (isSheba) {
      if (trimmed.isNotEmpty || widget.required) {
        err = RemittanceReceiverSection.validateSheba(
          trimmed,
          required: widget.required,
        );
      }
    } else if (isCard) {
      if (trimmed.isNotEmpty || widget.required) {
        err = RemittanceReceiverSection.validateCardNumber(
          trimmed,
          required: widget.required,
        );
      }
    }

    if (_errorText != err) {
      setState(() {
        _errorText = err;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fieldController = widget.controller.methodFieldController(
      widget.name,
    );
    if (fieldController == null) {
      // Unknown backend field name — skip silently (never crash).
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(widget.required ? '${widget.label} *' : widget.label),
        _Field(
          fieldController,
          widget.label,
          errorText: _errorText,
          onChanged: _validate,
          keyboardType:
              widget.name == 'card_number' || widget.name == 'account_number'
              ? TextInputType.number
              : TextInputType.text,
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _Field(
    this.controller,
    this.hint, {
    this.keyboardType,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.brandViolet : AppColors.brandViolet;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Semantics(
      textField: true,
      label: hint,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 48.h),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.white,
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
            ),
            errorText: errorText,
            errorMaxLines: 2,
            errorStyle: TextStyle(
              fontSize: 11.sp,
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorText != null ? AppColors.error : borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorText != null ? AppColors.error : primaryColor,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Semantics(
      button: true,
      label: hint,
      child: Container(
        constraints: BoxConstraints(minHeight: 48.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.white,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: countries.any((c) => c.$1 == value) && value.isNotEmpty
                ? value
                : null,
            dropdownColor: isDark ? AppColors.darkSurface : AppColors.white,
            hint: Text(
              hint,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.darkTextHint
                    : AppColors.lightTextHint,
              ),
            ),
            isExpanded: true,
            items: countries
                .map(
                  (c) => DropdownMenuItem(
                    value: c.$1,
                    child: Text(
                      '${c.$1} — ${c.$2}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              HapticFeedback.lightImpact();
              onChanged(val);
            },
          ),
        ),
      ),
    );
  }
}
