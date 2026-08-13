import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';

/// Step 3: Receiver information form.
class RemittanceReceiverSection extends StatelessWidget {
  const RemittanceReceiverSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RemittanceController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Receiver Information', style: _title()),
        SizedBox(height: 16.h),
        _Label('Full Name'),
        _Field(c.receiverNameController, 'Enter receiver full name'),
        SizedBox(height: 16.h),
        _Label('Country'),
        _CountryDropdown(value: c.selectedReceiverCountry.value, onChanged: (v) => c.selectedReceiverCountry.value = v ?? ''),
        SizedBox(height: 16.h),
        _Label('Phone Number'),
        _Field(c.receiverPhoneController, '+86 138 0000 0000', keyboardType: TextInputType.phone),
        SizedBox(height: 24.h),
        Divider(color: AppColors.lightBorder),
        SizedBox(height: 16.h),
        Text('Payout Details', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
        SizedBox(height: 4.h),
        Text('Fill in the fields relevant to the selected payout method.', style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary)),
        SizedBox(height: 16.h),
        _Label('Bank Name (optional)'),
        _Field(c.receiverBankNameController, 'Bank of China'),
        SizedBox(height: 16.h),
        _Label('Account Number (optional)'),
        _Field(c.receiverAccountNumberController, '6225 0000 0000 0000', keyboardType: TextInputType.number),
        SizedBox(height: 16.h),
        _Label('IBAN (optional)'),
        _Field(c.receiverIbanController, 'GB29 NWBK 6016 1331 9268 19'),
        SizedBox(height: 16.h),
        _Label('Alipay Account (optional)'),
        _Field(c.receiverAlipayController, 'alipay@example.com or phone'),
        SizedBox(height: 16.h),
        _Label('WeChat Account (optional)'),
        _Field(c.receiverWechatController, 'WeChat ID'),
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
  const _CountryDropdown({required this.value, required this.onChanged});

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
            hint: Text('Select country', style: TextStyle(fontSize: 14.sp, color: AppColors.lightTextHint)),
            isExpanded: true,
            items: countries.map((c) => DropdownMenuItem(value: c.$1, child: Text('${c.$1} — ${c.$2}', style: TextStyle(fontSize: 14.sp)))).toList(),
            onChanged: onChanged,
          ),
        ),
      );
}
