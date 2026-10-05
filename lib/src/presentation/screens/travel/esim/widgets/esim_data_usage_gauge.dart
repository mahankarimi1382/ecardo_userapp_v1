import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/app_haptics.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../../shared/travel_theme.dart';

/// Interactive data consumption gauge and visual meter for active eSIM packages.
/// Displays radial and layered linear progress meters, dynamic color transitions,
/// low data alert pill (<15%), and fast top-up action button.
class EsimDataUsageGauge extends StatelessWidget {
  /// Total allocated data volume in Gigabytes (e.g. 10.0 GB).
  final double totalDataGb;

  /// Consumed data volume in Gigabytes (e.g. 6.4 GB).
  final double usedDataGb;

  /// Remaining validity period in days (e.g. 14 days).
  final int daysRemaining;

  /// Country or region name (e.g. "Turkey & Europe", "Global").
  final String countryOrRegion;

  /// Callback when user taps "+ Top-Up Data".
  final VoidCallback? onTopUpTap;

  /// Optional ICCID or line identifier.
  final String? iccid;

  /// Optional plan name (e.g. "Explorer 10GB 30Days").
  final String? planName;

  /// Whether to show the "+ Top-Up Data" button inside the gauge card.
  final bool showTopUpButton;

  const EsimDataUsageGauge({
    super.key,
    required this.totalDataGb,
    required this.usedDataGb,
    required this.daysRemaining,
    required this.countryOrRegion,
    this.onTopUpTap,
    this.iccid,
    this.planName,
    this.showTopUpButton = true,
  });

  /// Remaining data in GB, clamped between 0 and totalDataGb.
  double get remainingDataGb =>
      (totalDataGb - usedDataGb).clamp(0.0, totalDataGb > 0 ? totalDataGb : 0.0);

  /// Remaining ratio from 0.0 to 1.0.
  double get remainingRatio =>
      totalDataGb > 0 ? (remainingDataGb / totalDataGb).clamp(0.0, 1.0) : 0.0;

  /// Used ratio from 0.0 to 1.0.
  double get usedRatio =>
      totalDataGb > 0 ? (usedDataGb / totalDataGb).clamp(0.0, 1.0) : 0.0;

  /// Remaining percentage integer (0 to 100).
  int get remainingPercent => (remainingRatio * 100).round();

  /// Color transitions based on remaining percentage:
  /// - Green/Primary when >35% remaining.
  /// - Warning amber when 15%-35% remaining.
  /// - Danger red when <15% remaining.
  Color get statusColor {
    if (remainingRatio > 0.35) {
      return TravelTheme.green;
    } else if (remainingRatio >= 0.15) {
      return TravelTheme.warning;
    } else {
      return TravelTheme.red;
    }
  }

  /// Gradient colors for radial and linear meters.
  List<Color> get statusGradient {
    if (remainingRatio > 0.35) {
      return [const Color(0xFF27AE60), const Color(0xFF2ECC71)];
    } else if (remainingRatio >= 0.15) {
      return [const Color(0xFFF2994A), const Color(0xFFF2C94C)];
    } else {
      return [const Color(0xFFD32F2F), const Color(0xFFE57373)];
    }
  }

  /// Whether the plan is in low data state (<15% remaining).
  bool get isLowData => remainingRatio < 0.15;

  String _formatGb(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toInt()}.0 GB';
    }
    return '${value.toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = TravelTheme.isDark(context);
    final cardBg = TravelTheme.cardSurfaceFor(context);
    final statBg = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8F9FA);
    final linearTrackBg = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFECEFF1);
    final arcTrackBg = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF0F2F5);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: TravelTheme.radius,
        border: Border.all(
          color: isLowData
              ? TravelTheme.red.withValues(alpha: 0.3)
              : TravelTheme.borderFor(context),
          width: isLowData ? 1.5 : 1.0,
        ),
        boxShadow: TravelTheme.shadowFor(context),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.all(18.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header: Country/Region + Active Status Pill
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: TravelTheme.yellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Icon(
                    Icons.public_rounded,
                    color: TravelTheme.ink,
                    size: 20,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        countryOrRegion,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          color: TravelTheme.textPrimaryFor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (planName != null && planName!.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          planName!,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: TravelTheme.textSecondaryFor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Active eSIM Badge with animated green indicator
                Container(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: TravelTheme.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: TravelTheme.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7.r,
                        height: 7.r,
                        decoration: const BoxDecoration(
                          color: TravelTheme.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        l10nPick(
                          context,
                          en: 'Active eSIM',
                          fa: 'سیم‌کارت فعال',
                          ar: 'شريحة نشطة',
                          zh: '已激活 eSIM',
                        ),
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w800,
                          color: TravelTheme.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Low Data Alert Banner (When < 15% remaining)
            if (isLowData) ...[
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: TravelTheme.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: TravelTheme.red.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: TravelTheme.red,
                      size: 18,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        l10nPick(
                          context,
                          en: 'Low Data Alert: Under 15% remaining. Top-up recommended.',
                          fa: 'هشدار مصرف: کمتر از ۱۵٪ از حجم دیتا باقی مانده است.',
                          ar: 'تنبيه: متبقي أقل من ١٥٪ من البيانات. يُنصح بإعادة الشحن.',
                          zh: '低流量警报：剩余流量不足15%，建议及时充值。',
                        ),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: TravelTheme.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 18.h),

            // Radial Usage Meter Centerpiece
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: remainingRatio),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, animatedRatio, child) {
                  return SizedBox(
                    width: 210.r,
                    height: 200.r,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: Size(210.r, 200.r),
                          painter: _RadialArcGaugePainter(
                            ratio: animatedRatio,
                            primaryColor: statusColor,
                            gradientColors: statusGradient,
                            trackColor: arcTrackBg,
                            strokeWidth: 15.r,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.only(bottom: 10.h),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Cellular signal icon with dynamic color
                                Icon(
                                  Icons.signal_cellular_alt_rounded,
                                  size: 22.r,
                                  color: statusColor,
                                ),
                                SizedBox(height: 4.h),
                                // Large legible remaining data
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    _formatGb(remainingDataGb),
                                    style: TextStyle(
                                      fontSize: 27.sp,
                                      fontWeight: FontWeight.w900,
                                      color: TravelTheme.textPrimaryFor(context),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                // "Remaining of 10.0 GB"
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    'Remaining of ${_formatGb(totalDataGb)}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: TravelTheme.textSecondaryFor(context),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                // Remaining percent pill
                                Container(
                                  padding: EdgeInsetsDirectional.symmetric(
                                    horizontal: 10.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Text(
                                      '$remainingPercent% Available',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w800,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 14.h),

            // Sleek Layered Linear Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l10nPick(
                          context,
                          en: 'Data Consumption',
                          fa: 'میزان مصرف حجم',
                          ar: 'استهلاك البيانات',
                          zh: '流量消耗',
                        ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: TravelTheme.textPrimaryFor(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        '${_formatGb(usedDataGb)} / ${_formatGb(totalDataGb)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: TravelTheme.textSecondaryFor(context),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 10.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: linearTrackBg,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: usedRatio,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor.withValues(alpha: 0.7),
                            statusColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Stat Cards Row: [Used Data] [Remaining Days]
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsetsDirectional.all(12.r),
                    decoration: BoxDecoration(
                      color: statBg,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: TravelTheme.borderFor(context)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.data_usage_rounded,
                              size: 16,
                              color: TravelTheme.muted,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                l10nPick(
                                  context,
                                  en: 'Used Data',
                                  fa: 'مصرف شده',
                                  ar: 'المستهلك',
                                  zh: '已用数据',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: TravelTheme.textSecondaryFor(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            _formatGb(usedDataGb),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: TravelTheme.textPrimaryFor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsetsDirectional.all(12.r),
                    decoration: BoxDecoration(
                      color: statBg,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: TravelTheme.borderFor(context)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.timelapse_rounded,
                              size: 16,
                              color: TravelTheme.blue,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                l10nPick(
                                  context,
                                  en: 'Validity Left',
                                  fa: 'اعتبار زمانی',
                                  ar: 'المدة المتبقية',
                                  zh: '剩余有效期',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: TravelTheme.textSecondaryFor(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            '$daysRemaining Days left',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: TravelTheme.textPrimaryFor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Fast Top-Up Button: "+ Top-Up Data"
            if (showTopUpButton) ...[
              SizedBox(height: 16.h),
              Material(
                color: TravelTheme.yellow,
                borderRadius: BorderRadius.circular(16.r),
                child: InkWell(
                  onTap: () {
                    AppHaptics.light();
                    onTopUpTap?.call();
                  },
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsetsDirectional.symmetric(vertical: 12.h),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_circle_outline_rounded,
                          color: TravelTheme.ink,
                          size: 20,
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            l10nPick(
                              context,
                              en: '+ Top-Up Data',
                              fa: '+ شارژ و افزایش حجم دیتا',
                              ar: '+ إعادة شحن البيانات',
                              zh: '+ 充值流量',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              color: TravelTheme.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Custom radial gauge painter rendering background track and sweep arc.
/// Arc spans 260 degrees from bottom-left to bottom-right.
class _RadialArcGaugePainter extends CustomPainter {
  final double ratio;
  final Color primaryColor;
  final List<Color> gradientColors;
  final Color trackColor;
  final double strokeWidth;

  _RadialArcGaugePainter({
    required this.ratio,
    required this.primaryColor,
    required this.gradientColors,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10);
    final radius = (size.width - strokeWidth) / 2;

    // Arc starts at 140 degrees (in radians) and sweeps 260 degrees
    const startAngle = 140 * (math.pi / 180);
    const totalSweepAngle = 260 * (math.pi / 180);
    final activeSweepAngle = totalSweepAngle * ratio.clamp(0.0, 1.0);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweepAngle,
      false,
      trackPaint,
    );

    if (ratio > 0.005) {
      final activePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + totalSweepAngle,
          colors: gradientColors,
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      // Draw active progress arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        activeSweepAngle,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadialArcGaugePainter oldDelegate) {
    return oldDelegate.ratio != ratio ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
