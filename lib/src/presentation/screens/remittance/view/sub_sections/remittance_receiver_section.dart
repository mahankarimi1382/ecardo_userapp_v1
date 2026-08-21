import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';

/// Step 3: Receiver information form.
class RemittanceReceiverSection extends StatelessWidget {
  const RemittanceReceiverSection({super.key});

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
        _CountryDropdown(value: c.selectedReceiverCountry.value, onChanged: (v) => c.selectedReceiverCountry.value = v ?? '', hint: l.remittanceSelectCountry),
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
        // Dynamic fields based on the selected method's `fields`.
        if (c.shouldShowReceiverField('bank_name')) ...[
          _Label(l.remittanceBankName),
          _Field(c.receiverBankNameController, 'Bank of China'),
          SizedBox(height: 16.h),
        ],
        if (c.shouldShowReceiverField('account_number')) ...[
          _Label(l.remittanceAccountNumber),
          _Field(c.receiverAccountNumberController, '6225 0000 0000 0000', keyboardType: TextInputType.number),
          SizedBox(height: 16.h),
        ],
        if (c.shouldShowReceiverField('iban')) ...[
          _Label(l.remittanceIban),
          _Field(c.receiverIbanController, 'GB29 NWBK 6016 1331 9268 19'),
          SizedBox(height: 16.h),
        ],
        if (c.shouldShowReceiverField('swift')) ...[
          _Label(l.remittanceSwift),
          _Field(c.receiverSwiftController, 'SWIFT Code'),
          SizedBox(height: 16.h),
        ],
        if (c.shouldShowReceiverField('shaba_number')) ...[
          _Label(l.remittanceShabaNumber),
          _Field(c.receiverShabaNumberController, 'IR 12 3456 7890 ...'),
          SizedBox(height: 16.h),
        ],
        if (c.shouldShowReceiverField('usdt_address')) ...[
          _Label(l.remittanceUsdtAddress),
          _Field(c.receiverUsdtAddressController, '0x... or Tron address'),
          SizedBox(height: 16.h),
        ],
        if (c.shouldShowReceiverField('alipay_account')) ...[
          _Label(l.remittanceAlipayAccount),
          _Field(c.receiverAlipayController, 'alipay@example.com or phone'),
          SizedBox(height: 16.h),
        ],
        if (c.shouldShowReceiverField('wechat_account')) ...[
          _Label(l.remittanceWechatAccount),
          _Field(c.receiverWechatController, 'WeChat ID'),
          SizedBox(height: 16.h),
        ],
      ],
    );
  }

  TextStyle _title() => TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary);
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
  final ValueChanged<String?> onChanged;
  final String hint;
  const _CountryDropdown({required this.value, required this.onChanged, required this.hint});

  static const countries = [
    ('IR', 'Iran'), ('CN', 'China'), ('TR', 'Turkey'), ('AE', 'UAE'),
    ('RU', 'Russia'), ('PK', 'Pakistan'), ('AF', 'Afghanistan'), ('IQ', 'Iraq'),
  ];

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value.isEmpty ? null : value,
            hint: Text(hint, style: TextStyle(fontSize: 14.sp, color: AppColors.lightTextHint)),
            isExpanded: true,
            items: countries.map((c) => DropdownMenuItem(value: c.$1, child: Text('${c.$1} — ${c.$2}', style: TextStyle(fontSize: 14.sp)))).toList(),
            onChanged: onChanged,
          ),
        ),
      );
}
