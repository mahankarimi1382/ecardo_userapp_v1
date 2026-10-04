import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'exchange_design_tokens.dart';

/// A lightweight custom-painted sparkline chart visualizing a 24-hour currency
/// rate trend.
///
/// Complies with dataviz guidelines:
/// - 2px stroke thickness ([strokeWidth])
/// - Positive trend: [AppColors.success] (green)
/// - Negative trend: [AppColors.error] (red)
/// - Recessive baseline indicating starting reference rate
/// - Smooth cubic bezier spline with subtle vertical gradient area fill
/// - Theme-adaptive marker ring and baseline
class CurrencySparklineChart extends StatelessWidget {
  const CurrencySparklineChart({
    super.key,
    this.rates,
    this.changePercent,
    this.baseRate,
    this.width,
    this.height = 40.0,
    this.showBaseline = true,
    this.showGradientFill = true,
    this.showLatestPointDot = true,
    this.customLineColor,
    this.surfaceColor,
    this.strokeWidth = 2.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
  });

  /// Explicit list of historical rates. When provided with >= 2 points,
  /// this is used directly.
  final List<double>? rates;

  /// 24h percentage change (e.g. +0.45, -1.20).
  final double? changePercent;

  /// Current base rate (e.g. 1.085, 62000).
  final double? baseRate;

  /// Optional chart width. If null, expands to parent constraints.
  final double? width;

  /// Chart height. Defaults to 40.0.
  final double height;

  /// Whether to render a subtle dashed baseline representing the starting rate.
  final bool showBaseline;

  /// Whether to render a gradient area fill below the curve.
  final bool showGradientFill;

  /// Whether to draw an accent marker dot at the latest (rightmost) point.
  final bool showLatestPointDot;

  /// Optional color override. Defaults to [AppColors.success] for positive
  /// trends and [AppColors.error] for negative trends.
  final Color? customLineColor;

  /// Optional surface background color used to separate the marker dot from the line.
  final Color? surfaceColor;

  /// Line thickness. Defaults to 2.0 per dataviz specs.
  final double strokeWidth;

  /// Inner padding around the chart.
  final EdgeInsets padding;

  /// Resolves the data points to be rendered.
  List<double> _resolvePoints() {
    if (rates != null && rates!.length >= 2) {
      return rates!;
    }

    final double effectiveBase = (baseRate != null && baseRate! > 0)
        ? baseRate!
        : 1.0;
    final double effectivePct = changePercent ?? 0.0;

    return _generateRealisticTrend(
      baseRate: effectiveBase,
      changePercent: effectivePct,
    );
  }

  /// Synthesizes 24 realistic hourly points using a deterministic Brownian
  /// bridge between startRate and baseRate.
  static List<double> _generateRealisticTrend({
    required double baseRate,
    required double changePercent,
  }) {
    const int stepCount = 24;
    final double startRate = changePercent.abs() > 0.0001
        ? baseRate / (1.0 + (changePercent / 100.0))
        : baseRate;
    final double diff = baseRate - startRate;

    // Deterministic seed ensures zero visual jitter on rebuilds
    final int seed = ((baseRate.abs() * 1000).toInt() ^
        (changePercent.abs() * 100).toInt() ^
        0x5F3759DF);
    final math.Random rng = math.Random(seed);

    final double volatility = diff.abs() > 1e-6
        ? diff.abs() * 0.40
        : (baseRate.abs() * 0.002).clamp(0.0001, 50.0);

    final List<double> rawWalk = List<double>.filled(stepCount, 0.0);
    for (int i = 1; i < stepCount; i++) {
      rawWalk[i] = rawWalk[i - 1] + (rng.nextDouble() - 0.49) * volatility;
    }

    final double endDeviation = rawWalk[stepCount - 1];
    final List<double> points = <double>[];

    for (int i = 0; i < stepCount; i++) {
      final double progress = i / (stepCount - 1).toDouble();
      final double bridge = rawWalk[i] - progress * endDeviation;
      final double value = startRate + progress * diff + bridge;
      points.add(value);
    }

    points[0] = startRate;
    points[stepCount - 1] = baseRate;
    return points;
  }

  bool _isPositiveTrend(List<double> points) {
    if (changePercent != null) {
      return changePercent! >= 0;
    }
    if (points.length >= 2) {
      return points.last >= points.first;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final List<double> points = _resolvePoints();
    final bool isPositive = _isPositiveTrend(points);
    final Color trendColor = customLineColor ??
        (isPositive ? AppColors.success : AppColors.error);

    final effectiveSurfaceColor = surfaceColor ??
        ExchangeDesignTokens.cardSurface(context);

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        size: Size(width ?? double.infinity, height),
        painter: _SparklinePainter(
          points: points,
          trendColor: trendColor,
          surfaceColor: effectiveSurfaceColor,
          showBaseline: showBaseline,
          showGradientFill: showGradientFill,
          showLatestPointDot: showLatestPointDot,
          strokeWidth: strokeWidth,
          padding: padding,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.points,
    required this.trendColor,
    required this.surfaceColor,
    required this.showBaseline,
    required this.showGradientFill,
    required this.showLatestPointDot,
    required this.strokeWidth,
    required this.padding,
  });

  final List<double> points;
  final Color trendColor;
  final Color surfaceColor;
  final bool showBaseline;
  final bool showGradientFill;
  final bool showLatestPointDot;
  final double strokeWidth;
  final EdgeInsets padding;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final double availableWidth = size.width - padding.horizontal;
    final double availableHeight = size.height - padding.vertical;

    if (availableWidth <= 0 || availableHeight <= 0) return;

    double minVal = points.first;
    double maxVal = points.first;
    for (final val in points) {
      if (val < minVal) minVal = val;
      if (val > maxVal) maxVal = val;
    }

    final double range = maxVal - minVal;
    final double stepX = availableWidth / (points.length - 1);

    final List<Offset> offsets = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final double x = padding.left + i * stepX;
      final double normalized = range > 1e-12
          ? (points[i] - minVal) / range
          : 0.5;
      final double y = padding.top + (1.0 - normalized) * availableHeight;
      offsets.add(Offset(x, y));
    }

    // 1. Recessive baseline indicating initial rate
    if (showBaseline) {
      final double baselineY = offsets.first.dy;
      final Paint baselinePaint = Paint()
        ..color = AppColors.softGray.withValues(alpha: 0.22)
        ..strokeWidth = 1.0;

      const double dashWidth = 3.0;
      const double dashSpace = 3.0;
      double startX = padding.left;
      final double endX = size.width - padding.right;

      while (startX < endX) {
        final double nextX = math.min(startX + dashWidth, endX);
        canvas.drawLine(
          Offset(startX, baselineY),
          Offset(nextX, baselineY),
          baselinePaint,
        );
        startX += dashWidth + dashSpace;
      }
    }

    // 2. Build smooth cubic bezier spline path
    final Path linePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      final Offset p0 = i > 0 ? offsets[i - 1] : offsets[i];
      final Offset p1 = offsets[i];
      final Offset p2 = offsets[i + 1];
      final Offset p3 = (i + 2 < offsets.length) ? offsets[i + 2] : p2;

      final double cp1x = p1.dx + (p2.dx - p0.dx) / 5.5;
      final double cp1y = (p1.dy + (p2.dy - p0.dy) / 5.5).clamp(
        padding.top,
        size.height - padding.bottom,
      );

      final double cp2x = p2.dx - (p3.dx - p1.dx) / 5.5;
      final double cp2y = (p2.dy - (p3.dy - p1.dy) / 5.5).clamp(
        padding.top,
        size.height - padding.bottom,
      );

      linePath.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    // 3. Gradient area fill underneath spline
    if (showGradientFill) {
      final Path fillPath = Path.from(linePath)
        ..lineTo(offsets.last.dx, size.height)
        ..lineTo(offsets.first.dx, size.height)
        ..close();

      final Paint fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            trendColor.withValues(alpha: 0.16),
            trendColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(fillPath, fillPaint);
    }

    // 4. Spline line stroke (2px per dataviz specs)
    final Paint linePaint = Paint()
      ..color = trendColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // 5. Latest point dot with surface ring
    if (showLatestPointDot) {
      final Offset latest = offsets.last;

      // Glow halo
      final Paint haloPaint = Paint()
        ..color = trendColor.withValues(alpha: 0.25);
      canvas.drawCircle(latest, 4.5, haloPaint);

      // Surface ring (separates line from dot)
      final Paint ringPaint = Paint()
        ..color = surfaceColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(latest, 3.2, ringPaint);

      // Core point
      final Paint dotPaint = Paint()
        ..color = trendColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(latest, 2.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.trendColor != trendColor ||
        oldDelegate.surfaceColor != surfaceColor ||
        oldDelegate.showBaseline != showBaseline ||
        oldDelegate.showGradientFill != showGradientFill ||
        oldDelegate.showLatestPointDot != showLatestPointDot ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
