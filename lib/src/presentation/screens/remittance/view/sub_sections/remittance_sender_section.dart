import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/text_field/common_text_field.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';

/// Step 2: Sender information (name, country, phone, ID, type).
class RemittanceSenderSection extends StatelessWidget {
  const RemittanceSenderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RemittanceController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sender Information',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: 16.h),

        // Full name
        Text(
          'Full Name',
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.lightTextSecondary,
          ),
        ),
        SizedBox(height: 6.h),
        CommonTextField(
          controller: controller.senderNameController,
          hintText: 'Enter full name',
        ),
        SizedBox(height: 16.h),

        // Country
        Text(
          'Country',
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.lightTextSecondary,
          ),
        ),
        SizedBox(height: 6.h),
        _CountryDropdown(
          value: controller.selectedSenderCountry.value,
          onChanged: (v) => controller.selectedSenderCountry.value = v ?? '',
        ),
        SizedBox(height: 16.h),

        // Phone
        Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.lightTextSecondary,
          ),
        ),
        SizedBox(height: 6.h),
        CommonTextField(
          controller: controller.senderPhoneController,
          hintText: '+98 912 345 6789',
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 16.h),

        // ID Number
        Text(
          'ID Number / National ID',
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.lightTextSecondary,
          ),
        ),
        SizedBox(height: 6.h),
        CommonTextField(
          controller: controller.senderIdNumberController,
          hintText: 'Enter ID number',
        ),
        SizedBox(height: 16.h),

        // Type (individual/business)
        Text(
          'Sender Type',
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.lightTextSecondary,
          ),
        ),
        SizedBox(height: 6.h),
        Obx(() => Row(
              children: [
                Expanded(
                  child: _TypeChip(
                    label: 'Individual',
                    value: 'individual',
                    groupValue: controller.selectedSenderType.value,
                    onSelected: (v) =>
                        controller.selectedSenderType.value = v,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _TypeChip(
                    label: 'Business',
                    value: 'business',
                    groupValue: controller.selectedSenderType.value,
                    onSelected: (v) =>
                        controller.selectedSenderType.value = v,
                  ),
                ),
              ],
            )),
      ],
    );
  }
}

class _CountryDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _CountryDropdown({required this.value, required this.onChanged});

  static const countries = [
    ('IR', 'Iran'),
    ('CN', 'China'),
    ('TR', 'Turkey'),
    ('AE', 'United Arab Emirates'),
    ('RU', 'Russia'),
    ('PK', 'Pakistan'),
    ('AF', 'Afghanistan'),
    ('IQ', 'Iraq'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.isEmpty ? null : value,
          hint: Text('Select country',
              style: TextStyle(fontSize: 14.sp, color: AppColors.lightTextSecondary)),
          isExpanded: true,
          items: countries
              .map((c) => DropdownMenuItem(
                    value: c.$1,
                    child: Text('${c.$1} — ${c.$2}',
                        style: TextStyle(fontSize: 14.sp)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onSelected;

  const _TypeChip({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.lightBorder,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? AppColors.primaryColor
                  : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
