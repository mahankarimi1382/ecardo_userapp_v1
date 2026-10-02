import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';

/// Pillar 1 of Block 4 (Cards & Security): Virtual Card Security Controls
///
/// Contains 3 advanced security controls for eCardo Virtual Cards:
/// 1. [DynamicCvv2Card] - Rotating real-time dynamic CVV2 with animated countdown.
/// 2. [CardFreezeOverlay] - Frosted glass frozen card overlay & quick toggle.
/// 3. [CardSpendingLimitsCard] - Sliders for daily/monthly limits & channel toggles.

// ============================================================================
// 1. DYNAMIC CVV2 CARD
// ============================================================================

/// Real-time rotating dynamic CVV2 for ultra-secure online checkout.
/// Displays a 3-digit CVV with countdown timer (e.g. 180s cycle) and circular
/// animated progress ring, tap-to-copy with haptics & toast, and a
/// "Regenerate Now" action button.
class DynamicCvv2Card extends StatefulWidget {
  final String? initialCvv;
  final int rotationCycleSeconds;
  final VoidCallback? onRegenerate;
  final ValueChanged<String>? onCvvChanged;

  const DynamicCvv2Card({
    super.key,
    this.initialCvv,
    this.rotationCycleSeconds = 180,
    this.onRegenerate,
    this.onCvvChanged,
  });

  @override
  State<DynamicCvv2Card> createState() => _DynamicCvv2CardState();
}

class _DynamicCvv2CardState extends State<DynamicCvv2Card>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  late String _currentCvv;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _currentCvv = _resolveInitialCvv();
    _remainingSeconds = widget.rotationCycleSeconds;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startCountdownTimer();
  }

  String _resolveInitialCvv() {
    final candidate = widget.initialCvv?.trim() ?? '';
    if (candidate.length == 3 && int.tryParse(candidate) != null) {
      return candidate;
    }
    return _generateRandomCvv();
  }

  String _generateRandomCvv() {
    final code = 100 + _random.nextInt(900);
    return code.toString();
  }

  void _startCountdownTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _regenerateCvv(isManual: false);
      }
    });
  }

  void _regenerateCvv({bool isManual = true}) {
    String newCode = _generateRandomCvv();
    // Ensure the new code rotates to a different value
    while (newCode == _currentCvv) {
      newCode = _generateRandomCvv();
    }

    setState(() {
      _currentCvv = newCode;
      _remainingSeconds = widget.rotationCycleSeconds;
    });

    widget.onCvvChanged?.call(_currentCvv);

    if (isManual) {
      HapticFeedback.mediumImpact();
      ToastHelper().showSuccessToast('Dynamic CVV2 regenerated');
      widget.onRegenerate?.call();
    }
  }

  void _copyCvv() {
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: _currentCvv));
    ToastHelper().showSuccessToast('Dynamic CVV2 copied: $_currentCvv');
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.rotationCycleSeconds > 0
        ? _remainingSeconds / widget.rotationCycleSeconds
        : 0.0;
    final isWarningTime = _remainingSeconds <= 30;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.mutedBlue.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.lightWarmGray.withValues(alpha: 0.45),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Security Icon, Title, and LIVE Badge
          Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: AppColors.mainSoftBlue.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: AppColors.deepBlack,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dynamic CVV2',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Rotating security code for secure checkout',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // LIVE Badge with pulsing indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.successContainer,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.35),
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 7.r,
                        height: 7.r,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                        letterSpacing: 0.6.w,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 18.h),

          // Core Interactive Area: Circular Timer + 3-Digit CVV Box
          Row(
            children: [
              // Circular Animated Progress Ring with Countdown
              SizedBox(
                width: 68.r,
                height: 68.r,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 68.r,
                      height: 68.r,
                      child: CircularProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        strokeWidth: 4.5.w,
                        backgroundColor:
                            AppColors.lightWarmGray.withValues(alpha: 0.35),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isWarningTime
                              ? AppColors.warning
                              : AppColors.deepBlack,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 13.sp,
                          color: isWarningTime
                              ? AppColors.warning
                              : AppColors.softGray,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _formatTime(_remainingSeconds),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: isWarningTime
                                ? AppColors.warning
                                : AppColors.deepBlack,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 16.w),

              // Interactive 3-Digit CVV2 Container with Tap-to-Copy
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _copyCvv,
                    borderRadius: BorderRadius.circular(16.r),
                    child: Ink(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8FC),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.mainSoftBlue.withValues(alpha: 0.5),
                          width: 1.2.w,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'CVV2 / CVC',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.lightTextSecondary,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Icon(
                                      Icons.copy_rounded,
                                      size: 12.sp,
                                      color: AppColors.mutedBlue,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  _currentCvv,
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 6.w,
                                    color: AppColors.deepBlack,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: AppColors.lightWarmGray
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.touch_app_outlined,
                                  size: 13.sp,
                                  color: AppColors.deepBlack,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'Copy',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.deepBlack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // "Regenerate Now" Action Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _regenerateCvv(isManual: true),
              borderRadius: BorderRadius.circular(12.r),
              child: Ink(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.lightWarmGray.withValues(alpha: 0.6),
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 16.sp,
                      color: AppColors.deepBlack,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Regenerate Now',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. CARD FREEZE OVERLAY & TOGGLE
// ============================================================================

/// Visual frozen card state widget / card freeze toggle.
/// When frozen: displays frosted glass blur effect, frosted blue border,
/// lock/snowflake badge, and "Card is currently frozen - all transactions blocked" banner.
/// Includes quick toggle switch to freeze / unfreeze card with haptic feedback.
class CardFreezeOverlay extends StatelessWidget {
  final Widget child;
  final bool isFrozen;
  final ValueChanged<bool>? onFreezeToggled;
  final ValueChanged<bool>? onToggleFreeze;
  final bool showToggle;
  final BorderRadius? borderRadius;

  const CardFreezeOverlay({
    super.key,
    required this.child,
    required this.isFrozen,
    this.onFreezeToggled,
    this.onToggleFreeze,
    this.showToggle = true,
    this.borderRadius,
  });

  void _handleToggle(bool value) {
    HapticFeedback.mediumImpact();
    onFreezeToggled?.call(value);
    onToggleFreeze?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(18.r);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Card Container with Frosted Glass Overlay when frozen
        Stack(
          children: [
            child,

            // Frosted Glass Blur Effect & Frozen Badge Overlay
            if (isFrozen)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: radius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        color: const Color(0x384A90E2),
                        border: Border.all(
                          color: AppColors.mainSoftBlue,
                          width: 2.2.w,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0x40ABC3EA),
                            const Color(0x28849ACD),
                            const Color(0x45ABC3EA),
                          ],
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Lock & Snowflake Frost Badge
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.deepBlack
                                    .withValues(alpha: 0.82),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: AppColors.mainSoftBlue
                                      .withValues(alpha: 0.8),
                                  width: 1.2.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.mainSoftBlue
                                        .withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.ac_unit_rounded,
                                    color: AppColors.mainSoftBlue,
                                    size: 15.sp,
                                  ),
                                  SizedBox(width: 6.w),
                                  Icon(
                                    Icons.lock_rounded,
                                    color: Colors.white,
                                    size: 13.sp,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Card is Frozen',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5.w,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Frozen Banner: "Card is currently frozen - all transactions blocked"
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 9.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.deepBlack
                                  .withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColors.mainSoftBlue
                                    .withValues(alpha: 0.65),
                                width: 1.w,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.shield_rounded,
                                  color: AppColors.mainSoftBlue,
                                  size: 18.sp,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'Card is currently frozen - all transactions blocked',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w700,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Quick Toggle Switch below card
        if (showToggle) ...[
          SizedBox(height: 14.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: isFrozen
                    ? AppColors.mainSoftBlue
                    : AppColors.lightWarmGray.withValues(alpha: 0.45),
                width: 1.2.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: isFrozen
                      ? AppColors.mainSoftBlue.withValues(alpha: 0.12)
                      : AppColors.mutedBlue.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: isFrozen
                        ? AppColors.mainSoftBlue.withValues(alpha: 0.25)
                        : AppColors.lightBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFrozen
                        ? Icons.ac_unit_rounded
                        : Icons.lock_open_rounded,
                    color: isFrozen
                        ? AppColors.deepBlack
                        : AppColors.softGray,
                    size: 19.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFrozen ? 'Card is Frozen' : 'Freeze Virtual Card',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: isFrozen
                              ? AppColors.deepBlack
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isFrozen
                            ? 'Toggle off to unfreeze and resume transactions'
                            : 'Temporarily lock your card against any charges',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                CupertinoSwitch(
                  value: isFrozen,
                  activeTrackColor: AppColors.mutedBlue,
                  onChanged: _handleToggle,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ============================================================================
// 3. CARD SPENDING LIMITS & TRANSACTION CHANNELS CARD
// ============================================================================

/// Spending and channel controls card for eCardo Virtual Cards.
/// Features sliders for Daily Spending Limit & Monthly Limit,
/// along with toggles for:
/// - E-Commerce / Online Transactions (خرید اینترنتی)
/// - International Transactions (تراکنش‌های بین‌المللی)
/// - Contactless / NFC Payments (پرداخت بدون تماس)
/// Plus a Save Limits button with instant feedback.
class CardSpendingLimitsCard extends StatefulWidget {
  final String? currency;
  final double? initialDailyLimit;
  final double? initialMonthlyLimit;
  final double? maxDailyLimit;
  final double? maxMonthlyLimit;
  final bool? initialEcommerceEnabled;
  final bool? initialInternationalEnabled;
  final bool? initialContactlessEnabled;
  final void Function({
    required double dailyLimit,
    required double monthlyLimit,
    required bool ecommerceEnabled,
    required bool internationalEnabled,
    required bool contactlessEnabled,
  })? onSaveLimits;

  const CardSpendingLimitsCard({
    super.key,
    this.currency,
    this.initialDailyLimit,
    this.initialMonthlyLimit,
    this.maxDailyLimit,
    this.maxMonthlyLimit,
    this.initialEcommerceEnabled,
    this.initialInternationalEnabled,
    this.initialContactlessEnabled,
    this.onSaveLimits,
  });

  @override
  State<CardSpendingLimitsCard> createState() => _CardSpendingLimitsCardState();
}

class _CardSpendingLimitsCardState extends State<CardSpendingLimitsCard> {
  late double _dailyLimit;
  late double _monthlyLimit;
  late bool _ecommerceEnabled;
  late bool _internationalEnabled;
  late bool _contactlessEnabled;
  bool _isSaving = false;

  late double _maxDaily;
  late double _maxMonthly;
  late String _currencyCode;

  @override
  void initState() {
    super.initState();
    _currencyCode = widget.currency?.toUpperCase() ?? 'USD';
    final isIrr = _currencyCode == 'IRR' || _currencyCode == 'TOMAN';

    _maxDaily = widget.maxDailyLimit ?? (isIrr ? 100000000.0 : 5000.0);
    _maxMonthly = widget.maxMonthlyLimit ?? (isIrr ? 500000000.0 : 25000.0);

    _dailyLimit = widget.initialDailyLimit ?? (isIrr ? 25000000.0 : 1200.0);
    _monthlyLimit = widget.initialMonthlyLimit ?? (isIrr ? 150000000.0 : 6500.0);

    _dailyLimit = _dailyLimit.clamp(0.0, _maxDaily);
    _monthlyLimit = _monthlyLimit.clamp(0.0, _maxMonthly);

    _ecommerceEnabled = widget.initialEcommerceEnabled ?? true;
    _internationalEnabled = widget.initialInternationalEnabled ?? true;
    _contactlessEnabled = widget.initialContactlessEnabled ?? false;
  }

  String _formatAmount(double value) {
    final isIrr = _currencyCode == 'IRR' || _currencyCode == 'TOMAN';
    final formatter = NumberFormat.currency(
      symbol: isIrr ? '' : '\$',
      decimalDigits: 0,
    );
    final formatted = formatter.format(value.round()).trim();
    if (isIrr) {
      return '$formatted $_currencyCode';
    }
    return formatted;
  }

  Future<void> _handleSave() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSaving = true;
    });

    widget.onSaveLimits?.call(
      dailyLimit: _dailyLimit,
      monthlyLimit: _monthlyLimit,
      ecommerceEnabled: _ecommerceEnabled,
      internationalEnabled: _internationalEnabled,
      contactlessEnabled: _contactlessEnabled,
    );

    // Provide immediate responsive UX
    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });

    ToastHelper().showSuccessToast(
      'Spending limits & security rules saved successfully',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.mutedBlue.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.lightWarmGray.withValues(alpha: 0.45),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: AppColors.mainSoftBlue.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: AppColors.deepBlack,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending Limits & Channel Controls',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Configure transaction amounts & channels',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // ------------------------------------------------------------------
          // Slider 1: Daily Spending Limit
          // ------------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Spending Limit',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Online Transactions · سقف خرید روزانه اینترنتی',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FC),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.mainSoftBlue.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  _formatAmount(_dailyLimit),
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deepBlack,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.deepBlack,
              inactiveTrackColor:
                  AppColors.lightWarmGray.withValues(alpha: 0.45),
              thumbColor: AppColors.deepBlack,
              overlayColor: AppColors.mainSoftBlue.withValues(alpha: 0.2),
              trackHeight: 4.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.r),
            ),
            child: Slider(
              value: _dailyLimit,
              min: 0.0,
              max: _maxDaily,
              divisions: 50,
              onChanged: (val) {
                setState(() {
                  _dailyLimit = val;
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatAmount(0),
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
                Text(
                  _formatAmount(_maxDaily),
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 18.h),

          // ------------------------------------------------------------------
          // Slider 2: Monthly Spending Limit
          // ------------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Spending Limit',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Monthly Limit · سقف خرید ماهانه',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FC),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.mainSoftBlue.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  _formatAmount(_monthlyLimit),
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deepBlack,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.deepBlack,
              inactiveTrackColor:
                  AppColors.lightWarmGray.withValues(alpha: 0.45),
              thumbColor: AppColors.deepBlack,
              overlayColor: AppColors.mainSoftBlue.withValues(alpha: 0.2),
              trackHeight: 4.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.r),
            ),
            child: Slider(
              value: _monthlyLimit,
              min: 0.0,
              max: _maxMonthly,
              divisions: 50,
              onChanged: (val) {
                setState(() {
                  _monthlyLimit = val;
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatAmount(0),
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
                Text(
                  _formatAmount(_maxMonthly),
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),
          Divider(
            color: AppColors.lightWarmGray.withValues(alpha: 0.5),
            height: 1.h,
          ),
          SizedBox(height: 16.h),

          // ------------------------------------------------------------------
          // Channel Controls: 3 Toggles
          // ------------------------------------------------------------------
          Text(
            'Allowed Transaction Channels',
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'کانال‌های مجاز تراکنش',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.lightTextSecondary,
            ),
          ),
          SizedBox(height: 14.h),

          // Toggle 1: Online Transactions / E-Commerce (خرید اینترنتی)
          _buildChannelToggleRow(
            icon: Icons.shopping_cart_outlined,
            title: 'Online Transactions',
            persianSubtitle: 'خرید اینترنتی',
            description: 'E-Commerce / Online Transactions & web checkouts',
            value: _ecommerceEnabled,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() {
                _ecommerceEnabled = val;
              });
            },
          ),

          SizedBox(height: 12.h),

          // Toggle 2: International Transactions (تراکنش‌های بین‌المللی)
          _buildChannelToggleRow(
            icon: Icons.public_rounded,
            title: 'International Transactions',
            persianSubtitle: 'تراکنش‌های بین‌المللی',
            description: 'Allow cross-border and foreign currency payments',
            value: _internationalEnabled,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() {
                _internationalEnabled = val;
              });
            },
          ),

          SizedBox(height: 12.h),

          // Toggle 3: Contactless / NFC Payments (پرداخت بدون تماس)
          _buildChannelToggleRow(
            icon: Icons.contactless_outlined,
            title: 'Contactless / NFC Payments',
            persianSubtitle: 'پرداخت بدون تماس',
            description: 'Enable tap & pay on supported terminals',
            value: _contactlessEnabled,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() {
                _contactlessEnabled = val;
              });
            },
          ),

          SizedBox(height: 20.h),

          // Save Limits Action Button
          CommonButton(
            text: 'Save Security Limits',
            height: 44,
            borderRadius: 14,
            fontSize: 14,
            backgroundColor: AppColors.deepBlack,
            isLoading: _isSaving,
            onPressed: _handleSave,
          ),
        ],
      ),
    );
  }

  Widget _buildChannelToggleRow({
    required IconData icon,
    required String title,
    required String persianSubtitle,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.lightWarmGray.withValues(alpha: 0.35),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.mainSoftBlue.withValues(alpha: 0.25)
                  : AppColors.lightWarmGray.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: value ? AppColors.deepBlack : AppColors.softGray,
              size: 17.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '($persianSubtitle)',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          CupertinoSwitch(
            value: value,
            activeTrackColor: AppColors.deepBlack,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
