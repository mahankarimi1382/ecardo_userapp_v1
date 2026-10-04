import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';

class QuickAmountPackage {
  final int amountToman;
  final int amountRials;
  final String labelFa;
  final String? badgeText;
  final Color? badgeColor;

  const QuickAmountPackage({
    required this.amountToman,
    required this.amountRials,
    required this.labelFa,
    this.badgeText,
    this.badgeColor,
  });
}

class QuickAmountSelectorWidget extends StatelessWidget {
  final String? selectedAmount;
  final Function(int amountToman, int amountRials) onAmountSelected;
  final String currency;
  final bool showTitle;

  static const List<QuickAmountPackage> standardPackages = [
    QuickAmountPackage(
      amountToman: 50000,
      amountRials: 500000,
      labelFa: '۵۰,۰۰۰',
      badgeText: null,
      badgeColor: null,
    ),
    QuickAmountPackage(
      amountToman: 100000,
      amountRials: 1000000,
      labelFa: '۱۰۰,۰۰۰',
      badgeText: 'محبوب',
      badgeColor: Color(0xFFF59E0B),
    ),
    QuickAmountPackage(
      amountToman: 200000,
      amountRials: 2000000,
      labelFa: '۲۰۰,۰۰۰',
      badgeText: 'ویژه',
      badgeColor: Color(0xFFEF4444),
    ),
    QuickAmountPackage(
      amountToman: 500000,
      amountRials: 5000000,
      labelFa: '۵۰۰,۰۰۰',
      badgeText: 'به‌صرفه',
      badgeColor: Color(0xFF10B981),
    ),
  ];

  const QuickAmountSelectorWidget({
    super.key,
    required this.selectedAmount,
    required this.onAmountSelected,
    this.currency = 'تومان',
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'بسته‌های شارژ سریع / Quick Packages',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.warmWhite : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  'انتخاب با ۱ لمس',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: standardPackages.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
            childAspectRatio: 2.5,
          ),
          itemBuilder: (context, index) {
            final package = standardPackages[index];
            final isSelected = selectedAmount == package.amountToman.toString() ||
                selectedAmount == package.amountRials.toString();

            return _QuickAmountChip(
              package: package,
              currency: currency,
              isSelected: isSelected,
              isDark: isDark,
              onTap: () => onAmountSelected(package.amountToman, package.amountRials),
            );
          },
        ),
      ],
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  final QuickAmountPackage package;
  final String currency;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickAmountChip({
    required this.package,
    required this.currency,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryBrand = isDark ? AppColors.mainSoftBlue : AppColors.deepBlack;

    final activeBg = isDark
        ? AppColors.mainSoftBlue.withValues(alpha: 0.16)
        : AppColors.mainSoftBlue.withValues(alpha: 0.12);

    final inactiveBg = isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground;

    return AnimatedContainer(
      duration: AppDurations.fast,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected ? activeBg : inactiveBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isSelected
              ? primaryBrand
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: (isDark ? AppColors.mainSoftBlue : Colors.black).withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            package.labelFa,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                              color: isSelected
                                  ? (isDark ? Colors.white : AppColors.deepBlack)
                                  : (isDark ? AppColors.warmWhite : AppColors.lightTextPrimary),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            currency,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${_formatNumber(package.amountRials)} ریال',
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (package.badgeText != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: (package.badgeColor ?? AppColors.warning).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      border: Border.all(
                        color: package.badgeColor ?? AppColors.warning,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      package.badgeText!,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: package.badgeColor ?? AppColors.warning,
                      ),
                    ),
                  )
                else if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16.w,
                    color: primaryBrand,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
