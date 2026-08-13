import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

/// RemittanceStepper — visual progress indicator for the 5-step remittance flow.
class RemittanceStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const RemittanceStepper({
    super.key,
    required this.currentStep,
    this.totalSteps = 5,
  });

  @override
  Widget build(BuildContext context) {
    final stepLabels = ['Amount', 'Sender', 'Receiver', 'Review', 'Done'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.lightBackground,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (index) {
          if (index.isOdd) {
            // Connector line
            final stepIndex = index ~/ 2;
            final isCompleted = stepIndex < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                color: isCompleted
                    ? AppColors.lightPrimary
                    : AppColors.lightBackground,
              ),
            );
          }

          // Step circle
          final stepIndex = index ~/ 2;
          final isCurrent = stepIndex == currentStep;
          final isCompleted = stepIndex < currentStep;

          return _StepIndicator(
            stepNumber: stepIndex + 1,
            label: stepLabels[stepIndex],
            isCurrent: isCurrent,
            isCompleted: isCompleted,
          );
        }),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int stepNumber;
  final String label;
  final bool isCurrent;
  final bool isCompleted;

  const _StepIndicator({
    required this.stepNumber,
    required this.label,
    required this.isCurrent,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color iconColor;
    Color textColor;

    if (isCompleted) {
      bgColor = AppColors.lightPrimary;
      iconColor = AppColors.white;
      textColor = AppColors.lightPrimary;
    } else if (isCurrent) {
      bgColor = AppColors.lightPrimary;
      iconColor = AppColors.white;
      textColor = AppColors.lightPrimary;
    } else {
      bgColor = AppColors.lightBackground;
      iconColor = AppColors.lightTextPrimary;
      textColor = AppColors.lightTextPrimary;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, color: iconColor, size: 16.sp)
                : Text(
                    '$stepNumber',
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 10.sp,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
