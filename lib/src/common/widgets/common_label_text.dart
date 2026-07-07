import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';

class CommonLabelText extends StatelessWidget {
  final String text;
  final bool isRequired;

  const CommonLabelText({
    super.key,
    required this.text,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
        style: TextStyle(
          letterSpacing: 0,
          fontSize: 14.sp,
          fontWeight: FontWeight.w900,
          color: AppColors.lightTextPrimary,
        ),
        children: isRequired
            ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    letterSpacing: 0,
                    color: AppColors.error,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ]
            : [],
      ),
    );
  }
}
