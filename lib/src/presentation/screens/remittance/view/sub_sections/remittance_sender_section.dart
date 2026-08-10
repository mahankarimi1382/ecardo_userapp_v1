import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';

/// Step 2: Sender information form.
class RemittanceSenderSection extends StatelessWidget {
  const RemittanceSenderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RemittanceController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sender Information', style: _title()),
        SizedBox(height: 16.h),
        _Label('Full Name'),
        _Field(c.senderNameController, 'Enter full name'),
        SizedBox(height: 16.h),
        _Label('Country'),
        _CountryDropdown(value: c.selectedSenderCountry.value, onChanged: (v) => c.selectedSenderCountry.value = v ?? ''),
        SizedBox(height: 16.h),
        _Label('Phone Number'),
        _Field(c.senderPhoneController, '+98 912 345 6789', keyboardType: TextInputType.phone),
        SizedBox(height: 16.h),
        _Label('ID Number / National ID'),
        _Field(c.senderIdNumberController, 'Enter ID number'),
        SizedBox(height: 16.h),
        _Label('Sender Type'),
        Obx(() => Row(children: [
              Expanded(child: _TypeChip('Individual', 'individual', c.selectedSenderType.value, (v) => c.selectedSenderType.value = v)),
              SizedBox(width: 8.w),
              Expanded(child: _TypeChip('Business', 'business', c.selectedSenderType.value, (v) => c.selectedSenderType.value = v)),
            ])),
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

class _TypeChip extends StatelessWidget {
  final String label, value, groupValue;
  final ValueChanged<String> onSelected;
  const _TypeChip(this.label, this.value, this.groupValue, this.onSelected);

  @override
  Widget build(BuildContext context) {
    final sel = value == groupValue;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: sel ? AppColors.lightPrimaryContainer : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: sel ? AppColors.lightPrimary : AppColors.lightBorder),
        ),
        child: Center(child: Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: sel ? AppColors.lightPrimary : AppColors.lightTextPrimary))),
      ),
    );
  }
}
