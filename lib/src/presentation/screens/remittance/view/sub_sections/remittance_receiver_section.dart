import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/text_field/common_text_field.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';

/// Step 3: Receiver information (name, country, phone, bank/alipay/wechat).
class RemittanceReceiverSection extends StatelessWidget {
  const RemittanceReceiverSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RemittanceController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Receiver Information',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: 16.h),

        // Full name
        Text('Full Name', style: _labelStyle()),
        SizedBox(height: 6.h),
        CommonTextField(
          controller: controller.receiverNameController,
          hintText: 'Enter receiver full name',
        ),
        SizedBox(height: 16.h),

        // Country
        Text('Country', style: _labelStyle()),
        SizedBox(height: 6.h),
        _CountryDropdown(
          value: controller.selectedReceiverCountry.value,
          onChanged: (v) => controller.selectedReceiverCountry.value = v ?? '',
        ),
        SizedBox(height: 16.h),

        // Phone
        Text('Phone Number', style: _labelStyle()),
        SizedBox(height: 6.h),
        CommonTextField(
          controller: controller.receiverPhoneController,
          hintText: '+86 138 0000 0000',
          keyboardType: TextInputType.phone,
        ),

        SizedBox(height: 24.h),
        Divider(color: AppColors.lightBorder),
        SizedBox(height: 16.h),

        // Optional fields based on method
        Text(
          'Payout Details',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Fill in the fields relevant to the selected payout method.',
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.lightTextSecondary,
          ),
        ),
        SizedBox(height: 16.h),

        // Bank Name
        Text('Bank Name (optional)', style: _labelStyle()),
        SizedBox(height: 6.h),
        CommonTextField(
          controller: controller.receiverBankNameController,
          hintText: 'Bank of China',
        ),
        SizedBox(height: 16.h),

        // Account Number
        Text('Account Number (optional)', style: _labelStyle()),
        SizedBox(height: 6.h),
        CommonTextField(
          controller: controller.receiverAccountNumberController,
          hintText: '6225 0000 0000 0000',
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16.h),

        // IBAN
        Text('IBAN (optional)', style: _labelStyle()),
        SizedBox(height: 6.h),
        CommonTextField(
          controller: controller.receiverIbanController,
          hintText: 'GB29 NWBK 6016 1331 9268 19',
        ),
        SizedBox(height: 16.h),

        // Alipay (for Chinese methods)
        Text('Alipay Account (optional)', style: _labelStyle()),
        SizedBox(height: 6.h),
        CommonTextField(
          controller: controller.receiverAlipayController,
          hintText: 'alipay@example.com or phone',
        ),
        SizedBox(height: 16.h),

        // WeChat
        Text('WeChat Account (optional)', style: _labelStyle()),
        SizedBox(height: 6.h),
        CommonTextField(
          controller: controller.receiverWechatController,
          hintText: 'WeChat ID',
        ),
      ],
    );
  }

  TextStyle _labelStyle() => TextStyle(
        fontSize: 13.sp,
        color: AppColors.lightTextSecondary,
      );
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
