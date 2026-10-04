import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/view/widgets/operator_selector_widget.dart';

class BillReviewReceiptCard extends StatelessWidget {
  final String serviceTitle;
  final String? operatorId;
  final String? operatorName;
  final String recipientValue; // Phone number or Bill ID
  final String recipientLabel; // "شماره تلفن" or "شناسه قبض"
  final String baseAmount;
  final String chargeAmount;
  final String? conversionRate;
  final String payableAmount;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onConfirm;
  final String confirmButtonText;
  final String backButtonText;

  const BillReviewReceiptCard({
    super.key,
    required this.serviceTitle,
    this.operatorId,
    this.operatorName,
    required this.recipientValue,
    this.recipientLabel = 'شماره تلفن همراه / Mobile',
    required this.baseAmount,
    required this.chargeAmount,
    this.conversionRate,
    required this.payableAmount,
    required this.isLoading,
    required this.onBack,
    required this.onConfirm,
    this.confirmButtonText = 'تأیید و پرداخت نهایی',
    this.backButtonText = 'بازگشت و ویرایش',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;

    OperatorInfo? opInfo;
    if (operatorId != null) {
      for (final op in OperatorSelectorWidget.operators) {
        if (op.id == operatorId) {
          opInfo = op;
          break;
        }
      }
    }

    final accentColor = opInfo?.primaryColor ?? (isDark ? AppColors.mainSoftBlue : AppColors.deepBlack);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          // Ticket / Receipt Card
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Column(
                children: [
                  // Top Accent Brand Bar
                  Container(
                    height: 5.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor,
                          opInfo?.accentColor ?? accentColor.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 14.h),
                    child: Column(
                      children: [
                        // Operator / Service Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                if (opInfo != null)
                                  Container(
                                    width: 38.w,
                                    height: 38.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [opInfo.primaryColor, opInfo.accentColor],
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        opInfo.nameEn.substring(0, 1),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: 38.w,
                                    height: 38.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: accentColor.withValues(alpha: 0.15),
                                    ),
                                    child: Icon(
                                      Icons.receipt_long_rounded,
                                      color: accentColor,
                                      size: 20.w,
                                    ),
                                  ),
                                SizedBox(width: 12.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      serviceTitle,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? AppColors.warmWhite : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    Text(
                                      operatorName ?? opInfo?.nameFa ?? 'eCardo Verified Hub',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: accentColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                border: Border.all(
                                  color: AppColors.success.withValues(alpha: 0.35),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded, size: 12.w, color: AppColors.success),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'پیش‌فاکتور رسمی',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        // Prominent Amount
                        Text(
                          'مبلغ کل پرداختی / Total Payable',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          payableAmount,
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : AppColors.deepBlack,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Perforated Notches & Dashed Line
                  _PerforatedDivider(isDark: isDark),

                  // Breakdown Table
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                    child: Column(
                      children: [
                        _buildRow(
                          isDark: isDark,
                          title: recipientLabel,
                          value: recipientValue,
                          isMonospace: true,
                          highlight: true,
                        ),
                        _buildDivider(isDark),
                        _buildRow(
                          isDark: isDark,
                          title: 'مبلغ پایه بسته / شارژ',
                          value: baseAmount,
                        ),
                        _buildDivider(isDark),
                        _buildRow(
                          isDark: isDark,
                          title: 'کارمزد و مالیات (VAT)',
                          value: chargeAmount,
                          valueColor: AppColors.error,
                        ),
                        if (conversionRate != null && conversionRate!.isNotEmpty) ...[
                          _buildDivider(isDark),
                          _buildRow(
                            isDark: isDark,
                            title: 'نرخ تبدیل ارز',
                            value: conversionRate!,
                          ),
                        ],
                        _buildDivider(isDark),
                        _buildRow(
                          isDark: isDark,
                          title: 'سرعت تسویه',
                          value: 'آنی و مستقیم (Instant)',
                          valueColor: AppColors.success,
                          icon: Icons.bolt_rounded,
                        ),
                      ],
                    ),
                  ),

                  // Security Guarantee Strip
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                    color: isDark
                        ? AppColors.darkSurfaceVariant.withValues(alpha: 0.6)
                        : AppColors.lightBackground,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.security_rounded,
                          size: 14.w,
                          color: isDark ? AppColors.mainSoftBlue : AppColors.mutedBlue,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'تضمین بازگشت وجه و تراکنش امن شبکه شتاب و شاپرک',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                flex: 1,
                child: CommonButton(
                  onPressed: onBack,
                  text: backButtonText,
                  backgroundColor: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightPrimary.withValues(alpha: 0.05),
                  borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderWidth: 1.2,
                  textColor: isDark ? AppColors.warmWhite : AppColors.lightTextPrimary,
                  height: 52.h,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: CommonButton(
                  isLoading: isLoading,
                  onPressed: onConfirm,
                  text: confirmButtonText,
                  height: 52.h,
                ),
              ),
            ],
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildRow({
    required bool isDark,
    required String title,
    required String value,
    Color? valueColor,
    bool isMonospace = false,
    bool highlight = false,
    IconData? icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14.w, color: valueColor ?? AppColors.success),
                SizedBox(width: 4.w),
              ],
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: highlight ? FontWeight.w800 : FontWeight.w700,
                  letterSpacing: isMonospace ? 0.5 : 0,
                  color: valueColor ?? (isDark ? AppColors.warmWhite : AppColors.lightTextPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 12.h,
      thickness: 0.8,
      color: isDark ? AppColors.darkBorder : AppColors.lightDivider.withValues(alpha: 0.4),
    );
  }
}

class _PerforatedDivider extends StatelessWidget {
  final bool isDark;

  const _PerforatedDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final parentBg = isDark ? AppColors.deepBlack : AppColors.lightBackground;
    final dividerColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Dashed horizontal line
        CustomPaint(
          size: const Size(double.infinity, 1),
          painter: _DashedLinePainter(color: dividerColor),
        ),
        // Left notch cutout
        Positioned(
          left: -12.w,
          child: Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: parentBg,
              shape: BoxShape.circle,
              border: Border.all(color: dividerColor, width: 1.0),
            ),
          ),
        ),
        // Right notch cutout
        Positioned(
          right: -12.w,
          child: Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: parentBg,
              shape: BoxShape.circle,
              border: Border.all(color: dividerColor, width: 1.0),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 18.0;
    final endX = size.width - 18.0;

    while (startX < endX) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
