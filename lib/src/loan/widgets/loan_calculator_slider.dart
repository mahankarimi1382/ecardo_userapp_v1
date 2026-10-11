import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Modern interactive fintech loan calculator with dual sliders
/// (Amount slider and Duration slider), tactile haptic feedback on notch changes,
/// quick preset duration chips (3, 6, 12, 24 months), and live repayment metrics:
/// Monthly Installment (قسط ماهانه), Total Interest (کل سود), Total Repayment (کل بازپرداخت), APR percentage.
class LoanCalculatorSlider extends StatefulWidget {
  final double? initialAmount;
  final int? initialMonths;
  final int? initialGraceMonths;
  final double minAmount;
  final double maxAmount;
  final double stepAmount;
  final double annualInterestRate; // APR percentage
  final int minMonths;
  final int maxMonths;
  final List<int> presetDurations; // Default: [3, 6, 12, 24]
  final List<int> gracePeriodOptions;
  final List<double>? quickAmounts;
  final String currency; // 'USD' or 'IRR'
  final bool showGracePeriod;
  final void Function(double amount, int months, int graceMonths, double monthlyPayment)? onPlanChanged;
  final void Function({
    required double amount,
    required int months,
    required double monthlyPayment,
    required double totalInterest,
    required double totalRepayment,
    required double aprRate,
  })? onCalculationChanged;

  const LoanCalculatorSlider({
    super.key,
    this.initialAmount,
    this.initialMonths,
    this.initialGraceMonths,
    this.minAmount = 500.0,
    this.maxAmount = 100000.0,
    this.stepAmount = 500.0,
    this.annualInterestRate = 14.0,
    this.minMonths = 3,
    this.maxMonths = 24,
    this.presetDurations = const [3, 6, 12, 24],
    this.gracePeriodOptions = const [0, 1, 2, 3],
    this.quickAmounts,
    this.currency = 'USD',
    this.showGracePeriod = false,
    this.onPlanChanged,
    this.onCalculationChanged,
  });

  @override
  State<LoanCalculatorSlider> createState() => _LoanCalculatorSliderState();
}

class _LoanCalculatorSliderState extends State<LoanCalculatorSlider> {
  late double _amount;
  late int _months;
  late int _graceMonths;

  @override
  void initState() {
    super.initState();
    _amount = (widget.initialAmount ?? (widget.currency == 'USD' ? 10000.0 : 50000000.0))
        .clamp(widget.minAmount, widget.maxAmount);
    _months = (widget.initialMonths ?? 12).clamp(widget.minMonths, widget.maxMonths);
    _graceMonths = widget.initialGraceMonths ?? 0;
    if (!widget.gracePeriodOptions.contains(_graceMonths)) {
      _graceMonths = 0;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyChange();
    });
  }

  @override
  void didUpdateWidget(covariant LoanCalculatorSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool changed = false;

    if (widget.initialAmount != null && widget.initialAmount != oldWidget.initialAmount) {
      _amount = widget.initialAmount!.clamp(widget.minAmount, widget.maxAmount);
      changed = true;
    } else {
      final clamped = _amount.clamp(widget.minAmount, widget.maxAmount);
      if (clamped != _amount) {
        _amount = clamped;
        changed = true;
      }
    }

    if (widget.initialMonths != null && widget.initialMonths != oldWidget.initialMonths) {
      _months = widget.initialMonths!.clamp(widget.minMonths, widget.maxMonths);
      changed = true;
    } else {
      final clampedM = _months.clamp(widget.minMonths, widget.maxMonths);
      if (clampedM != _months) {
        _months = clampedM;
        changed = true;
      }
    }

    if (widget.annualInterestRate != oldWidget.annualInterestRate) {
      changed = true;
    }

    if (changed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _notifyChange());
    }
  }

  double get _monthlyRate => (widget.annualInterestRate / 100.0) / 12.0;

  int get _effectiveGraceMonths =>
      widget.showGracePeriod ? _graceMonths.clamp(0, math.max(0, _months - 1)).toInt() : 0;

  /// Standard EMI calculation using French amortization
  double get _monthlyPayment {
    final p = _amount;
    final r = _monthlyRate;
    final m = math.max(1, _months - _effectiveGraceMonths);
    if (p <= 0 || m <= 0) return 0.0;
    if (r <= 0) return p / m;

    final factor = math.pow(1.0 + r, m).toDouble();
    if (factor <= 1.0) return p / m;

    return (p * r * factor) / (factor - 1.0);
  }

  /// Interest-only installment during grace period
  double get _graceMonthlyPayment {
    if (_effectiveGraceMonths <= 0) return 0.0;
    return _amount * _monthlyRate;
  }

  /// Total interest for entire loan duration
  double get _totalInterest {
    final graceInterest = _effectiveGraceMonths * _graceMonthlyPayment;
    final amortizingMonths = math.max(1, _months - _effectiveGraceMonths);
    final amortizingTotal = amortizingMonths * _monthlyPayment;
    return math.max(0.0, (graceInterest + amortizingTotal) - _amount);
  }

  /// Total repayment (principal + total interest)
  double get _totalRepayment => _amount + _totalInterest;

  void _notifyChange() {
    widget.onPlanChanged?.call(_amount, _months, _graceMonths, _monthlyPayment);
    widget.onCalculationChanged?.call(
      amount: _amount,
      months: _months,
      monthlyPayment: _monthlyPayment,
      totalInterest: _totalInterest,
      totalRepayment: _totalRepayment,
      aprRate: widget.annualInterestRate,
    );
  }

  String _formatAmount(double val) {
    if (widget.currency.toUpperCase() == 'USD') {
      final isWhole = (val - val.truncateToDouble()).abs() < 0.001;
      final fixedStr = isWhole ? val.toStringAsFixed(0) : val.toStringAsFixed(2);
      final parts = fixedStr.split('.');
      final intPart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
      return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
    }
    final rounded = val.round();
    return rounded.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  String _currencyLabel(BuildContext context) {
    if (widget.currency.toUpperCase() == 'USD') return 'USD';
    return l10nPick(context, fa: 'ریال', en: 'IRR', ar: 'ريال', zh: '里亚尔');
  }

  List<double> get _effectiveQuickAmounts {
    if (widget.quickAmounts != null && widget.quickAmounts!.isNotEmpty) {
      return widget.quickAmounts!;
    }
    if (widget.currency.toUpperCase() == 'USD') {
      return [1000.0, 5000.0, 10000.0, 25000.0, 50000.0, 100000.0]
          .where((a) => a >= widget.minAmount && a <= widget.maxAmount)
          .toList();
    }
    return [10000000.0, 25000000.0, 50000000.0, 100000000.0, 200000000.0, 500000000.0]
        .where((a) => a >= widget.minAmount && a <= widget.maxAmount)
        .toList();
  }

  String _quickChipLabel(BuildContext context, double amount) {
    if (widget.currency.toUpperCase() == 'USD') {
      if (amount >= 1000) {
        return '\$${(amount / 1000).toInt()}k';
      }
      return '\$${amount.toInt()}';
    }
    if (amount >= 1000000) {
      final millions = (amount / 1000000).toInt();
      return '$millions ${l10nPick(context, fa: 'م', en: 'M', ar: 'م', zh: '百万')}';
    }
    return _formatAmount(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final primaryAccent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final sunkenColor = isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground;

    final amountDivisions = ((widget.maxAmount - widget.minAmount) / widget.stepAmount).round();
    final effectiveAmountDivisions = amountDivisions > 0 && amountDivisions <= 500 ? amountDivisions : null;

    final durationRange = widget.maxMonths - widget.minMonths;
    final durationDivisions = durationRange > 0 ? durationRange : null;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsetsDirectional.all(AppSpacing.lg.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------ SECTION 1: AMOUNT SLIDER ------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: primaryAccent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.payments_outlined,
                          size: 17.sp,
                          color: primaryAccent,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    Expanded(
                      child: Text(
                        l10nPick(
                          context,
                          fa: 'مبلغ تسهیلات درخواستی',
                          en: 'Loan Amount',
                          ar: 'مبلغ القرض',
                          zh: '融资金额',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              _buildCurrencyPill(context, isDark, primaryAccent),
            ],
          ),

          SizedBox(height: AppSpacing.sm.h),

          // Big Displayed Amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    _formatAmount(_amount),
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                      letterSpacing: -0.5,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.xs.w),
              Text(
                _currencyLabel(context),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: primaryAccent,
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.xs.h),

          // Amount Slider with Tactile Haptic Feedback
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: primaryAccent,
              inactiveTrackColor: isDark ? AppColors.darkOutlineVariant : AppColors.lightOutlineVariant,
              thumbColor: primaryAccent,
              overlayColor: primaryAccent.withValues(alpha: 0.15),
              trackHeight: 5.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.r, elevation: 3),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 18.r),
            ),
            child: Slider(
              value: _amount,
              min: widget.minAmount,
              max: widget.maxAmount,
              divisions: effectiveAmountDivisions,
              onChanged: (val) {
                final stepped = (val / widget.stepAmount).round() * widget.stepAmount;
                final clamped = stepped.clamp(widget.minAmount, widget.maxAmount);
                if (clamped != _amount) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _amount = clamped;
                  });
                  _notifyChange();
                }
              },
            ),
          ),

          // Amount Bounds (Min / Max)
          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.xs.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${l10nPick(context, fa: 'حداقل', en: 'Min', ar: 'الأدنى', zh: '最小')}: ${_formatAmount(widget.minAmount)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10.5.sp, color: textSecondary),
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    '${l10nPick(context, fa: 'حداکثر', en: 'Max', ar: 'الأقصى', zh: '最大')}: ${_formatAmount(widget.maxAmount)}',
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10.5.sp, color: textSecondary),
                  ),
                ),
              ],
            ),
          ),

          // Quick Amount Chips
          if (_effectiveQuickAmounts.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _effectiveQuickAmounts.map((q) {
                  final isSelected = (_amount - q).abs() < (widget.stepAmount / 2);
                  return Padding(
                    padding: EdgeInsetsDirectional.only(end: AppSpacing.xs.w),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _amount = q;
                        });
                        _notifyChange();
                      },
                      child: AnimatedContainer(
                        duration: AppSpacing.fast,
                        padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryAccent : sunkenColor,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                          border: Border.all(
                            color: isSelected ? primaryAccent : borderColor,
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          _quickChipLabel(context, q),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? (isDark ? AppColors.deepBlack : Colors.white)
                                : textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          SizedBox(height: AppSpacing.md.h),
          Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
          SizedBox(height: AppSpacing.md.h),

          // ------------------ SECTION 2: DURATION SLIDER & PRESETS ------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: primaryAccent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.calendar_month_outlined,
                          size: 17.sp,
                          color: primaryAccent,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    Expanded(
                      child: Text(
                        l10nPick(
                          context,
                          fa: 'مدت زمان بازپرداخت',
                          en: 'Repayment Duration',
                          ar: 'مدة السداد',
                          zh: '还款期限',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: primaryAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '$_months ${l10nPick(context, fa: 'ماهه', en: 'Months', ar: 'شهراً', zh: '个月')}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    color: primaryAccent,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.xs.h),

          // Duration Slider with Tactile Haptic Feedback
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: primaryAccent,
              inactiveTrackColor: isDark ? AppColors.darkOutlineVariant : AppColors.lightOutlineVariant,
              thumbColor: primaryAccent,
              overlayColor: primaryAccent.withValues(alpha: 0.15),
              trackHeight: 5.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.r, elevation: 3),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 18.r),
            ),
            child: Slider(
              value: _months.toDouble(),
              min: widget.minMonths.toDouble(),
              max: widget.maxMonths.toDouble(),
              divisions: durationDivisions,
              onChanged: (val) {
                final stepped = val.round().clamp(widget.minMonths, widget.maxMonths);
                if (stepped != _months) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _months = stepped;
                    if (_graceMonths >= _months) {
                      _graceMonths = 0;
                    }
                  });
                  _notifyChange();
                }
              },
            ),
          ),

          // Duration Bounds
          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.xs.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${widget.minMonths} ${l10nPick(context, fa: 'ماه', en: 'mo', ar: 'شهر', zh: '月')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10.5.sp, color: textSecondary),
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    '${widget.maxMonths} ${l10nPick(context, fa: 'ماه', en: 'mo', ar: 'شهر', zh: '月')}',
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10.5.sp, color: textSecondary),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.sm.h),

          // Quick Preset Duration Chips (3, 6, 12, 24 months)
          Row(
            children: widget.presetDurations.map((m) {
              final isSelected = _months == m;
              return Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 3.w),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _months = m.clamp(widget.minMonths, widget.maxMonths);
                        if (_graceMonths >= _months) {
                          _graceMonths = 0;
                        }
                      });
                      _notifyChange();
                    },
                    child: AnimatedContainer(
                      duration: AppSpacing.fast,
                      padding: EdgeInsetsDirectional.symmetric(vertical: 8.h),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? primaryAccent : sunkenColor,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                        border: Border.all(
                          color: isSelected ? primaryAccent : borderColor,
                          width: isSelected ? 1.4 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: primaryAccent.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        '$m ${l10nPick(context, fa: 'ماهه', en: 'Mo', ar: 'شهر', zh: '月')}',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          color: isSelected
                              ? (isDark ? AppColors.deepBlack : Colors.white)
                              : textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Optional Grace Period Toggle
          if (widget.showGracePeriod) ...[
            SizedBox(height: AppSpacing.md.h),
            Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
            SizedBox(height: AppSpacing.md.h),
            _buildGracePeriodSelector(context, isDark, primaryAccent, borderColor, sunkenColor, textPrimary, textSecondary),
          ],

          SizedBox(height: AppSpacing.lg.h),

          // ------------------ SECTION 3: LIVE REPAYMENT DISPLAY ------------------
          // 4-tile grid: Monthly Installment, Total Interest, Total Repayment, APR percentage
          Container(
            padding: EdgeInsetsDirectional.all(AppSpacing.md.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        AppColors.darkSurfaceVariant,
                        AppColors.darkSurfaceVariant.withValues(alpha: 0.7),
                      ]
                    : [
                        primaryAccent.withValues(alpha: 0.05),
                        primaryAccent.withValues(alpha: 0.09),
                      ],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : primaryAccent.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              children: [
                // Row 1: Monthly Installment & APR percentage
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        title: l10nPick(
                          context,
                          fa: 'قسط ماهانه',
                          en: 'Monthly Installment',
                          ar: 'القسط الشهري',
                          zh: '每月供款',
                        ),
                        value: '${_formatAmount(_monthlyPayment)} ${_currencyLabel(context)}',
                        caption: _effectiveGraceMonths > 0
                            ? l10nPick(
                                context,
                                fa: 'پس از تنفس (${_months - _effectiveGraceMonths} قسط)',
                                en: 'Post grace (${_months - _effectiveGraceMonths} inst.)',
                                ar: 'بعد فترة السماح',
                                zh: '宽限期后',
                              )
                            : l10nPick(
                                context,
                                fa: 'طی $_months قسط مساوی',
                                en: 'Over $_months installments',
                                ar: 'على $_months قسط',
                                zh: '共 $_months 期',
                              ),
                        isEmphasized: true,
                        accentColor: primaryAccent,
                        isDark: isDark,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 48.h,
                      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(start: AppSpacing.sm.w),
                        child: _buildMetricTile(
                          context,
                          title: l10nPick(
                            context,
                            fa: 'نرخ سود سالانه (APR)',
                            en: 'APR Percentage',
                            ar: 'الفائدة السنوية APR',
                            zh: '年化利率 (APR)',
                          ),
                          value: '${widget.annualInterestRate.toStringAsFixed(1)}٪',
                          caption: l10nPick(
                            context,
                            fa: 'فرمول بانکی استاندارد',
                            en: 'Annualized fixed rate',
                            ar: 'المعدل السنوي',
                            zh: '综合年化率',
                          ),
                          isEmphasized: false,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ],
                ),

                Divider(
                  height: AppSpacing.lg.h,
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),

                // Row 2: Total Interest & Total Repayment
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        title: l10nPick(
                          context,
                          fa: 'کل سود تسهیلات',
                          en: 'Total Interest',
                          ar: 'إجمالي الفائدة',
                          zh: '总利息',
                        ),
                        value: '${_formatAmount(_totalInterest)} ${_currencyLabel(context)}',
                        caption: l10nPick(
                          context,
                          fa: 'هزینه کل دریافت وام',
                          en: 'Total borrowing cost',
                          ar: 'تكلفة الاقتراض',
                          zh: '融资总成本',
                        ),
                        isEmphasized: false,
                        accentColor: const Color(0xFFF59E0B),
                        isDark: isDark,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 48.h,
                      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(start: AppSpacing.sm.w),
                        child: _buildMetricTile(
                          context,
                          title: l10nPick(
                            context,
                            fa: 'کل بازپرداخت',
                            en: 'Total Repayment',
                            ar: 'إجمالي السداد',
                            zh: '还款总计',
                          ),
                          value: '${_formatAmount(_totalRepayment)} ${_currencyLabel(context)}',
                          caption: l10nPick(
                            context,
                            fa: 'اصل وام + سود کل',
                            en: 'Principal + Interest',
                            ar: 'الأصل + الفائدة',
                            zh: '本金 + 总利息',
                          ),
                          isEmphasized: true,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ],
                ),

                // Grace period callout banner if active
                if (_effectiveGraceMonths > 0) ...[
                  SizedBox(height: AppSpacing.sm.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                      border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 14.sp, color: const Color(0xFFB45309)),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            '${l10nPick(context, fa: 'قسط ماهانه دوره تنفس (فقط سود)', en: 'Grace monthly installment (interest only)', ar: 'قسط فترة السماح', zh: '宽限期月供')}: ${_formatAmount(_graceMonthlyPayment)} ${_currencyLabel(context)}',
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF92400E),
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyPill(BuildContext context, bool isDark, Color primaryAccent) {
    final isUsd = widget.currency.toUpperCase() == 'USD';
    const greenAccent = Color(0xFF10B981);

    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isUsd
            ? greenAccent.withValues(alpha: 0.12)
            : primaryAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(
          color: isUsd
              ? greenAccent.withValues(alpha: 0.3)
              : primaryAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUsd ? Icons.attach_money_rounded : Icons.account_balance_wallet_outlined,
            size: 13.sp,
            color: isUsd ? greenAccent : primaryAccent,
          ),
          SizedBox(width: 4.w),
          Text(
            isUsd ? r'USD ($)' : 'IRR (${_currencyLabel(context)})',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: isUsd ? greenAccent : primaryAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGracePeriodSelector(
    BuildContext context,
    bool isDark,
    Color primaryAccent,
    Color borderColor,
    Color sunkenColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.hourglass_top_rounded, size: 16.sp, color: const Color(0xFFF59E0B)),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                l10nPick(
                  context,
                  fa: 'دوره تنفس (تعویق بازپرداخت اصل وام)',
                  en: 'Grace Period (Deferred Principal)',
                  ar: 'فترة السماح',
                  zh: '宽限期',
                ),
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs.h),
        Row(
          children: widget.gracePeriodOptions.map((g) {
            final isSelected = _graceMonths == g;
            final label = g == 0
                ? l10nPick(context, fa: 'بدون تنفس', en: 'None', ar: 'بدون', zh: '无')
                : '$g ${l10nPick(context, fa: 'ماه', en: 'Mo', ar: 'شهر', zh: '月')}';

            return Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 2.w),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _graceMonths = g;
                    });
                    _notifyChange();
                  },
                  child: AnimatedContainer(
                    duration: AppSpacing.fast,
                    padding: EdgeInsetsDirectional.symmetric(vertical: 6.h),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFD97706) : sunkenColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFD97706) : borderColor,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required String caption,
    required bool isEmphasized,
    required bool isDark,
    Color? accentColor,
  }) {
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        SizedBox(height: 3.h),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(
              fontSize: isEmphasized ? 15.sp : 13.5.sp,
              fontWeight: isEmphasized ? FontWeight.w900 : FontWeight.w700,
              color: accentColor ?? textPrimary,
              letterSpacing: -0.3,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9.5.sp,
            color: textSecondary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
