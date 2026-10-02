import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

/// StepProgressIndicator — Clean, accessible step progress funnel for multi-step flows.
class StepProgressIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep; // 0-based
  final List<String>? stepTitles;

  const StepProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(totalSteps * 2 - 1, (index) {
              if (index.isOdd) {
                final completedBefore = (index ~/ 2) < currentStep;
                return Expanded(
                  child: Container(
                    height: 2.5.h,
                    color: completedBefore
                        ? AppColors.lightPrimary
                        : AppColors.lightBorder,
                  ),
                );
              }
              final stepIndex = index ~/ 2;
              final isCompleted = stepIndex < currentStep;
              final isCurrent = stepIndex == currentStep;

              return Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.lightPrimary
                      : (isCurrent ? AppColors.white : AppColors.lightBackground),
                  border: Border.all(
                    color: (isCompleted || isCurrent)
                        ? AppColors.lightPrimary
                        : AppColors.lightBorder,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(Icons.check, size: 16.sp, color: AppColors.white)
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: isCurrent
                                ? AppColors.lightPrimary
                                : AppColors.lightTextHint,
                          ),
                        ),
                ),
              );
            }),
          ),
          if (stepTitles != null && stepTitles!.length == totalSteps) ...[
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(totalSteps, (idx) {
                final isCurrent = idx == currentStep;
                return Expanded(
                  child: Text(
                    stepTitles![idx],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isCurrent
                          ? AppColors.lightPrimary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}
