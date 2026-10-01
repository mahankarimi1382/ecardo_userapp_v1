import 'dart:math';

/// MoneyMathHelper — Safe financial math without IEEE-754 binary floating point drift.
///
/// In binary double math, operations like 0.1 + 0.2 yield 0.30000000000000004.
/// MoneyMathHelper performs fee percentages, additions, and fixed-decimal
/// roundings using scaled integer (minor unit) arithmetic.
class MoneyMathHelper {
  /// Scaling factor: 10^8 (handles up to 8 decimal places for crypto and fiat).
  static const int defaultScale = 100000000;

  /// Calculates percentage charge safely: (amount * percent) / 100.
  /// Returns exact rounded double to [decimals] places.
  static double calculatePercentCharge(double amount, double percent, {int decimals = 4}) {
    if (amount <= 0 || percent <= 0) return 0.0;
    final int scaledAmount = (amount * defaultScale).round();
    final int scaledPercent = (percent * 10000).round();
    final BigInt numerator = BigInt.from(scaledAmount) * BigInt.from(scaledPercent);
    final BigInt denominator = BigInt.from(1000000) * BigInt.from(defaultScale);

    final double result = numerator.toDouble() / denominator.toDouble();
    return roundToDecimals(result, decimals);
  }

  /// Adds two monetary amounts safely without floating point drift.
  static double add(double a, double b, {int decimals = 4}) {
    final int scaledA = (a * defaultScale).round();
    final int scaledB = (b * defaultScale).round();
    final int scaledSum = scaledA + scaledB;
    return roundToDecimals(scaledSum / defaultScale, decimals);
  }

  /// Subtracts b from a safely: a - b.
  static double subtract(double a, double b, {int decimals = 4}) {
    final int scaledA = (a * defaultScale).round();
    final int scaledB = (b * defaultScale).round();
    final int scaledDiff = scaledA - scaledB;
    return roundToDecimals(scaledDiff / defaultScale, decimals);
  }

  /// Rounds double [val] to exactly [decimals] decimal places.
  static double roundToDecimals(double val, int decimals) {
    if (val.isNaN || val.isInfinite) return 0.0;
    final factor = pow(10, decimals).toDouble();
    return (val * factor).roundToDouble() / factor;
  }
}
