import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Interactive financial loan slider with amount slider, quick chips,
/// term duration selector, grace period toggle, and live computed metrics.
class LoanCalculatorSlider extends StatefulWidget {
  final double? initialAmount;
  final int? initialMonths;
  final int? initialGraceMonths;
  final double minAmount;
  final double maxAmount;
  final double stepAmount;
  final double annualInterestRate;
  final List<int> termOptions;
  final List<int> gracePeriodOptions;
  final List<double>? quickAmounts;
  final String currency;
  final void Function(double amount, int months, int graceMonths, double monthlyPayment)? onPlanChanged;

  const LoanCalculatorSlider({
    super.key,
    this.initialAmount,
    this.initialMonths,
    this.initialGraceMonths,
    this.minAmount = 5000000.0,
    this.maxAmount = 500000000.0,
    this.stepAmount = 1000000.0,
    this.annualInterestRate = 18.0,
    this.termOptions = const [3, 6, 12, 18, 24, 36],
    this.gracePeriodOptions = const [0, 1, 2, 3],
    this.quickAmounts,
    this.currency = 'IRR',
    this.onPlanChanged,
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
    _amount = (widget.initialAmount ?? 50000000.0).clamp(widget.minAmount, widget.maxAmount);
    _months = widget.initialMonths ?? 12;
    if (!widget.termOptions.contains(_months) && widget.termOptions.isNotEmpty) {
      _months = widget.termOptions.first;
    }
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
      _months = widget.initialMonths!;
      changed = true;
    }

    if (widget.annualInterestRate != oldWidget.annualInterestRate) {
      changed = true;
    }

    if (changed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _notifyChange());
    }
  }

  double get _monthlyRate => (widget.annualInterestRate / 100.0) / 12.0;

  /// Standard EMI during regular amortizing period
  double get _monthlyPayment {
    final p = _amount;
    final r = _monthlyRate;
    final m = math.max(1, _months - _graceMonths);
    if (p <= 0 || m <= 0) return 0.0;
    if (r <= 0) return p / m;

    final factor = math.pow(1.0 + r, m).toDouble();
    if (factor <= 1.0) return p / m;

    return (p * r * factor) / (factor - 1.0);
  }

  /// Interest-only installment during grace period
  double get _graceMonthlyPayment {
    if (_graceMonths <= 0) return 0.0;
    return _amount * _monthlyRate;
  }

  /// Total interest for entire loan duration
  double get _totalInterest {
    final graceInterest = _graceMonths * _graceMonthlyPayment;
    final amortizingMonths = math.max(1, _months - _graceMonths);
    final amortizingTotal = amortizingMonths * _monthlyPayment;
    return math.max(0.0, (graceInterest + amortizingTotal) - _amount);
  }

  /// Total repayment (principal + interest)
  double get _totalRepayment => _amount + _totalInterest;

  void _notifyChange() {
    widget.onPlanChanged?.call(_amount, _months, _graceMonths, _monthlyPayment);
  }

  String _formatAmount(double val) {
    final rounded = val.round();
    return rounded.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  String _currencyLabel(BuildContext context) {
    if (widget.currency == 'USD') return r'$';
    return l10nPick(context, fa: 'ریال', en: 'IRR', ar: 'ريال', zh: '里亚尔');
  }

  String _quickChipLabel(BuildContext context, double amount) {
    if (widget.currency == 'USD') {
      if (amount >= 1000) {
        return '\$${(amount / 1000).toInt()}k';
      }
      return '\$${amount.toInt()}';
    }
    // Persian IRR representation
    if (amount >= 1000000) {
      final millions = (amount / 1000000).toInt();
      return '$millions ' + l10nPick(context, fa: 'م', en: 'M', ar: 'م', zh: '百万');
    }
    return _formatAmount(amount);
  }

  List<double> get _effectiveQuickAmounts {
    if (widget.quickAmounts != null && widget.quickAmounts!.isNotEmpty) {
      return widget.quickAmounts!;
    }
    if (widget.currency == 'USD') {
      return [1000.0, 5000.0, 10000.0, 25000.0, 50000.0]
          .where((a) => a >= widget.minAmount && a <= widget.maxAmount)
          .toList();
    }
    return [10000000.0, 25000000.0, 50000000.0, 100000000.0, 200000000.0, 500000000.0]
        .where((a) => a >= widget.minAmount && a <= widget.maxAmount)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final divisions = ((widget.maxAmount - widget.minAmount) / widget.stepAmount).round();
    final effectiveDivisions = divisions > 0 && divisions <= 500 ? divisions : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Amount Header & Big Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                l10nPick(
                  context,
                  fa: 'مبلغ تسهیلات درخواستی',
                  en: 'Loan Amount',
                  ar: 'مبلغ التسهيل',
                  zh: '融资金额',
                ),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightTextSecondary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _currencyLabel(context),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatAmount(_amount),
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.lightTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                _currencyLabel(context),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.lightPrimary,
              inactiveTrackColor: AppColors.lightBorder,
              thumbColor: AppColors.lightPrimary,
              overlayColor: AppColors.lightPrimary.withValues(alpha: 0.12),
              trackHeight: 5.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.r, elevation: 3),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 18.r),
            ),
            child: Slider(
              value: _amount,
              min: widget.minAmount,
              max: widget.maxAmount,
              divisions: effectiveDivisions,
              onChanged: (val) {
                final stepped = (val / widget.stepAmount).round() * widget.stepAmount;
                setState(() {
                  _amount = stepped.clamp(widget.minAmount, widget.maxAmount);
                });
                _notifyChange();
              },
            ),
          ),

          // Min/Max bounds indicators
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10nPick(context, fa: 'حداقل', en: 'Min', ar: 'الحد الأدنى', zh: '最小')}: ${_formatAmount(widget.minAmount)}',
                  style: TextStyle(fontSize: 10.sp, color: AppColors.lightTextSecondary),
                ),
                Text(
                  '${l10nPick(context, fa: 'حداکثر', en: 'Max', ar: 'الحد الأقصى', zh: '最大')}: ${_formatAmount(widget.maxAmount)}',
                  style: TextStyle(fontSize: 10.sp, color: AppColors.lightTextSecondary),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Quick Amount Chips
          if (_effectiveQuickAmounts.isNotEmpty) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _effectiveQuickAmounts.map((q) {
                  final isSelected = (_amount - q).abs() < (widget.stepAmount / 2);
                  return Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10.r),
                      onTap: () {
                        setState(() {
                          _amount = q;
                        });
                        _notifyChange();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.lightPrimary
                              : AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isSelected ? AppColors.lightPrimary : AppColors.lightBorder,
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          _quickChipLabel(context, q),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16.h),
          ],

          const Divider(height: 1, color: AppColors.lightBorder),
          SizedBox(height: 14.h),

          // Section 2: Term / Duration Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10nPick(
                  context,
                  fa: 'مدت زمان بازپرداخت',
                  en: 'Repayment Term',
                  ar: 'مدة السداد',
                  zh: '还款期限',
                ),
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              Text(
                '$_months ' + l10nPick(context, fa: 'ماهه', en: 'months', ar: 'شهر', zh: '个月'),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: widget.termOptions.map((m) {
              final isSelected = _months == m;
              return InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () {
                  setState(() {
                    _months = m;
                    if (_graceMonths >= _months) {
                      _graceMonths = 0;
                    }
                  });
                  _notifyChange();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.lightPrimary : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected ? AppColors.lightPrimary : AppColors.lightBorder,
                      width: 1.3,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.lightPrimary.withValues(alpha: 0.18),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    '$m ' + l10nPick(context, fa: 'ماه', en: 'Mo', ar: 'شهر', zh: '月'),
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 16.h),
          const Divider(height: 1, color: AppColors.lightBorder),
          SizedBox(height: 14.h),

          // Section 3: Grace Period Toggle (دوره تنفس)
          Row(
            children: [
              Icon(Icons.hourglass_top_rounded, size: 16.sp, color: const Color(0xFFF59E0B)),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  l10nPick(
                    context,
                    fa: 'دوره تنفس (تعویق بازپرداخت اصل)',
                    en: 'Grace Period (Deferred Principal)',
                    ar: 'فترة السماح (تأجيل سداد الأصل)',
                    zh: '宽限期（延后本金偿还）',
                  ),
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ),
              if (_graceMonths > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '$_graceMonths ' + l10nPick(context, fa: 'ماه تنفس', en: 'mo grace', ar: 'سماح', zh: '宽限'),
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            l10nPick(
              context,
              fa: 'در ماه‌های تنفس فقط سود محاسبه شده پرداخت می‌شود و بازپرداخت اصل وام پس از آن آغاز می‌گردد.',
              en: 'During the grace period, only interest is serviced; principal amortization begins afterward.',
              ar: 'خلال فترة السماح يتم سداد الفائدة فقط، ويبدأ استهلاك أصل القرض لاحقاً.',
              zh: '在宽限期内仅支付利息，期满后开始正常本息摊还。',
            ),
            style: TextStyle(fontSize: 10.5.sp, color: AppColors.lightTextSecondary, height: 1.4),
          ),
          SizedBox(height: 8.h),
          Row(
            children: widget.gracePeriodOptions.map((g) {
              final isSelected = _graceMonths == g;
              final label = g == 0
                  ? l10nPick(context, fa: 'بدون تنفس', en: 'None', ar: 'بدون', zh: '无')
                  : '$g ' + l10nPick(context, fa: 'ماه', en: 'Mo', ar: 'شهر', zh: '月');

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: g == widget.gracePeriodOptions.first ? 0 : 3.w, right: g == widget.gracePeriodOptions.last ? 0 : 3.w),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.r),
                    onTap: () {
                      setState(() {
                        _graceMonths = g;
                      });
                      _notifyChange();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(vertical: 7.h),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (g > 0 ? const Color(0xFFD97706) : AppColors.lightPrimary)
                            : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isSelected
                              ? (g > 0 ? const Color(0xFFD97706) : AppColors.lightPrimary)
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 16.h),

          // Section 4: Live Computed Metrics Card
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.lightPrimary.withValues(alpha: 0.04),
                  AppColors.lightPrimary.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.lightPrimary.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                // Row 1: Monthly Installment & Effective Rate
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        title: l10nPick(
                          context,
                          fa: 'مبلغ قسط ماهانه',
                          en: 'Monthly Installment',
                          ar: 'القسط الشهري',
                          zh: '月供金额',
                        ),
                        value: '${_formatAmount(_monthlyPayment)} ${_currencyLabel(context)}',
                        caption: _graceMonths > 0
                            ? l10nPick(
                                context,
                                fa: 'پس از اتمام تنفس (${_months - _graceMonths} قسط)',
                                en: 'After grace period (${_months - _graceMonths} inst.)',
                                ar: 'بعد فترة السماح',
                                zh: '宽限期后（${_months - _graceMonths}期）',
                              )
                            : l10nPick(
                                context,
                                fa: 'طی $_months قسط مساوی',
                                en: 'Over $_months equal installments',
                                ar: 'على $_months قسط',
                                zh: '共 $_months 期等额本息',
                              ),
                        isEmphasized: true,
                      ),
                    ),
                    Container(width: 1, height: 45.h, color: AppColors.lightBorder),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: _buildMetricTile(
                          context,
                          title: l10nPick(
                            context,
                            fa: 'نرخ سود سالانه',
                            en: 'Annual Rate',
                            ar: 'الفائدة السنوية',
                            zh: '年化利率',
                          ),
                          value: '${widget.annualInterestRate.toStringAsFixed(1)}٪',
                          caption: l10nPick(
                            context,
                            fa: 'فرمول بانکی استاندارد',
                            en: 'Standard Banking Rate',
                            ar: 'المعدل البنكي',
                            zh: '标准银行综合利率',
                          ),
                          isEmphasized: false,
                        ),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 18, color: AppColors.lightBorder),

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
                          zh: '利息总计',
                        ),
                        value: '${_formatAmount(_totalInterest)} ${_currencyLabel(context)}',
                        caption: l10nPick(
                          context,
                          fa: 'هزینه مالی کل دوره',
                          en: 'Total borrowing cost',
                          ar: 'تكلفة التمويل الإجمالية',
                          zh: '全程利息成本',
                        ),
                        isEmphasized: false,
                      ),
                    ),
                    Container(width: 1, height: 45.h, color: AppColors.lightBorder),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: _buildMetricTile(
                          context,
                          title: l10nPick(
                            context,
                            fa: 'مجموع بازپرداخت',
                            en: 'Total Repayment',
                            ar: 'إجمالي السداد',
                            zh: '还款总计',
                          ),
                          value: '${_formatAmount(_totalRepayment)} ${_currencyLabel(context)}',
                          caption: l10nPick(
                            context,
                            fa: 'اصل + کل سود',
                            en: 'Principal + Interest',
                            ar: 'الأصل + الفائدة',
                            zh: '本金 + 总利息',
                          ),
                          isEmphasized: true,
                          accentColor: AppColors.lightPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                // Grace period callout note
                if (_graceMonths > 0) ...[
                  SizedBox(height: 10.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7).withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 14.sp, color: const Color(0xFFB45309)),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            '${l10nPick(context, fa: 'قسط ماهیانه در دوره تنفس (فقط سود)', en: 'Grace monthly payment (interest only)', ar: 'قسط فترة السماح', zh: '宽限期月付（仅付利息）')}: ${_formatAmount(_graceMonthlyPayment)} ${_currencyLabel(context)}',
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF92400E),
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

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required String caption,
    required bool isEmphasized,
    Color? accentColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextSecondary,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          value,
          style: TextStyle(
            fontSize: isEmphasized ? 14.sp : 13.sp,
            fontWeight: isEmphasized ? FontWeight.w900 : FontWeight.w700,
            color: accentColor ?? AppColors.lightTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          caption,
          style: TextStyle(
            fontSize: 9.5.sp,
            color: AppColors.lightTextSecondary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
