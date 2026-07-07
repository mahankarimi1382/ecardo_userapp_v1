import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qunzo_user/src/common/widgets/common_label_text.dart';

class CommonRequiredLabelAndDynamicField extends StatelessWidget {
  final String labelText;
  final bool isLabelRequired;
  final Widget dynamicField;
  final double? labelHeight;

  const CommonRequiredLabelAndDynamicField({
    super.key,
    required this.labelText,
    this.isLabelRequired = false,
    required this.dynamicField,
    this.labelHeight = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonLabelText(text: labelText, isRequired: isLabelRequired),
        SizedBox(height: labelHeight!.h),
        dynamicField,
      ],
    );
  }
}
