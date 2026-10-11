import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../models/loan_models.dart';

/// Single item in the loan amortization schedule.
class InstallmentItem {
  final int installmentNumber;
  final DateTime dueDate;
  final double principalAmount;
  final double interestAmount;
  final double totalPayment;
  final double remainingBalance;
  final bool isGracePeriod;
  final String status; // 'paid', 'pending', 'overdue'
  final int? id;

  const InstallmentItem({
    required this.installmentNumber,
    required this.dueDate,
    required this.principalAmount,
    required this.interestAmount,
    required this.totalPayment,
    required this.remainingBalance,
    required this.isGracePeriod,
    required this.status,
    this.id,
  });

  bool get isPaid => status.toLowerCase() == 'paid' || status.toUpperCase() == 'WAIVED';
  bool get isOverdue => status.toLowerCase() == 'overdue';
  bool get isPending => !isPaid && !isOverdue;

  /// Map an existing backend [LoanInstallmentModel] list into amortization schedule items.
  static List<InstallmentItem> fromLoanInstallments(
    List<LoanInstallmentModel> list, {
    double? totalLoanPrincipal,
  }) {
    double currentBalance = totalLoanPrincipal ??
        list.fold<double>(0.0, (sum, item) => sum + item.principalPart);

    final result = <InstallmentItem>[];
    for (final inst in list) {
      currentBalance = math.max(0.0, currentBalance - inst.principalPart);
      result.add(
        InstallmentItem(
          installmentNumber: inst.seq,
          dueDate: inst.dueDate ?? DateTime.now(),
          principalAmount: inst.principalPart,
          interestAmount: inst.interestPart,
          totalPayment: inst.amount,
          remainingBalance: currentBalance,
          isGracePeriod: inst.principalPart == 0 && inst.interestPart > 0,
          status: inst.isPaid ? 'paid' : (inst.isOverdue ? 'overdue' : 'pending'),
          id: inst.id,
        ),
      );
    }
    return result;
  }

  static DateTime _addMonthsClamped(DateTime base, int monthsToAdd) {
    final targetYear = base.year + (base.month + monthsToAdd - 1) ~/ 12;
    final targetMonth = (base.month + monthsToAdd - 1) % 12 + 1;
    final daysInMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    final targetDay = base.day > daysInMonth ? daysInMonth : base.day;
    return DateTime(targetYear, targetMonth, targetDay);
  }

  /// Generate a mathematically projected amortization schedule from loan terms.
  static List<InstallmentItem> generateSchedule({
    required double principal,
    required double annualInterestRatePct,
    required int tenureMonths,
    int gracePeriodMonths = 0,
    DateTime? startDate,
  }) {
    if (principal <= 0 || tenureMonths <= 0) return [];

    final baseDate = startDate ?? DateTime.now().add(const Duration(days: 30));
    final monthlyRate = (annualInterestRatePct / 100.0) / 12.0;
    final graceMonths = gracePeriodMonths.clamp(0, math.max(0, tenureMonths - 1)).toInt();
    final amortizingMonths = math.max(1, tenureMonths - graceMonths);

    // Standard EMI for amortizing period
    double emi = 0.0;
    if (monthlyRate <= 0) {
      emi = principal / amortizingMonths;
    } else {
      final factor = math.pow(1.0 + monthlyRate, amortizingMonths).toDouble();
      emi = factor <= 1.0 ? principal / amortizingMonths : (principal * monthlyRate * factor) / (factor - 1.0);
    }

    final schedule = <InstallmentItem>[];
    double balance = principal;

    for (int i = 0; i < tenureMonths; i++) {
      final itemDate = _addMonthsClamped(baseDate, i);
      final isGrace = i < graceMonths;

      if (isGrace) {
        final interest = balance * monthlyRate;
        schedule.add(
          InstallmentItem(
            installmentNumber: i + 1,
            dueDate: itemDate,
            principalAmount: 0.0,
            interestAmount: interest,
            totalPayment: interest,
            remainingBalance: balance,
            isGracePeriod: true,
            status: 'pending',
          ),
        );
      } else {
        final isLast = i == tenureMonths - 1;
        final interest = balance * monthlyRate;
        double principalPart = emi - interest;

        if (isLast || principalPart > balance) {
          principalPart = balance;
        }

        final payment = principalPart + interest;
        balance = math.max(0.0, balance - principalPart);

        schedule.add(
          InstallmentItem(
            installmentNumber: i + 1,
            dueDate: itemDate,
            principalAmount: principalPart,
            interestAmount: interest,
            totalPayment: payment,
            remainingBalance: balance,
            isGracePeriod: false,
            status: 'pending',
          ),
        );
      }
    }

    return schedule;
  }
}

/// Clean Amortization Schedule Preview Table matching modern fintech standards.
/// Shows Month #, Principal, Interest, Total Payment, and Remaining Balance.
class LoanAmortizationSchedule extends StatefulWidget {
  final List<InstallmentItem>? installments;
  final double? principal;
  final double? annualInterestRatePct;
  final int? tenureMonths;
  final int gracePeriodMonths;
  final double? totalPrincipal;
  final double? totalInterest;
  final String currency;
  final void Function(InstallmentItem item)? onPayInstallment;
  final bool showHeader;
  final bool isCompactInitially;
  final bool initiallyExpanded;

  const LoanAmortizationSchedule({
    super.key,
    this.installments,
    this.principal,
    this.annualInterestRatePct,
    this.tenureMonths,
    this.gracePeriodMonths = 0,
    this.totalPrincipal,
    this.totalInterest,
    this.currency = 'USD',
    this.onPayInstallment,
    this.showHeader = true,
    this.isCompactInitially = false,
    this.initiallyExpanded = true,
  });

  /// Factory constructor for live interactive loan preview during application
  factory LoanAmortizationSchedule.preview({
    Key? key,
    required double principal,
    required double annualInterestRatePct,
    required int tenureMonths,
    int gracePeriodMonths = 0,
    String currency = 'USD',
    bool showHeader = true,
  }) {
    return LoanAmortizationSchedule(
      key: key,
      principal: principal,
      annualInterestRatePct: annualInterestRatePct,
      tenureMonths: tenureMonths,
      gracePeriodMonths: gracePeriodMonths,
      currency: currency,
      showHeader: showHeader,
      isCompactInitially: false,
    );
  }

  @override
  State<LoanAmortizationSchedule> createState() => _LoanAmortizationScheduleState();
}

class _LoanAmortizationScheduleState extends State<LoanAmortizationSchedule> {
  late bool _isCompactView;
  bool _showAllItems = false;
  static const int _previewLimit = 6;

  @override
  void initState() {
    super.initState();
    _isCompactView = widget.isCompactInitially;
  }

  List<InstallmentItem> get _resolvedInstallments {
    if (widget.installments != null && widget.installments!.isNotEmpty) {
      return widget.installments!;
    }
    if (widget.principal != null && widget.principal! > 0 && widget.tenureMonths != null && widget.tenureMonths! > 0) {
      return InstallmentItem.generateSchedule(
        principal: widget.principal!,
        annualInterestRatePct: widget.annualInterestRatePct ?? 14.0,
        tenureMonths: widget.tenureMonths!,
        gracePeriodMonths: widget.gracePeriodMonths,
      );
    }
    return const [];
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

  String _formatDate(DateTime dt, BuildContext context) {
    final isFa = Localizations.localeOf(context).languageCode == 'fa';
    if (isFa) {
      final j = Jalali.fromDateTime(dt);
      final y = j.year.toString().padLeft(4, '0');
      final m = j.month.toString().padLeft(2, '0');
      final d = j.day.toString().padLeft(2, '0');
      return '$y/$m/$d';
    }
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _currencyLabel(BuildContext context) {
    if (widget.currency.toUpperCase() == 'USD') return 'USD';
    return l10nPick(context, fa: 'ریال', en: 'IRR', ar: 'ريال', zh: '里亚尔');
  }

  double get _computedTotalPrincipal {
    if (widget.totalPrincipal != null && widget.totalPrincipal! > 0) {
      return widget.totalPrincipal!;
    }
    final items = _resolvedInstallments;
    if (items.isEmpty) return widget.principal ?? 0.0;
    return items.fold<double>(0.0, (sum, i) => sum + i.principalAmount);
  }

  double get _computedTotalInterest {
    if (widget.totalInterest != null && widget.totalInterest! > 0) {
      return widget.totalInterest!;
    }
    final items = _resolvedInstallments;
    return items.fold<double>(0.0, (sum, i) => sum + i.interestAmount);
  }

  double get _computedTotalRepayment => _computedTotalPrincipal + _computedTotalInterest;

  int get _paidCount => _resolvedInstallments.where((i) => i.isPaid).length;
  int get _overdueCount => _resolvedInstallments.where((i) => i.isOverdue).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _resolvedInstallments;

    if (items.isEmpty) {
      return Container(
        padding: EdgeInsetsDirectional.all(AppSpacing.lg.r),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Center(
          child: Text(
            l10nPick(
              context,
              fa: 'برنامه استهلاک اقساط یافت نشد',
              en: 'No amortization schedule available',
              ar: 'لا يوجد جدول استهلاك',
              zh: '暂无还款计划表',
            ),
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ),
      );
    }

    final displayedItems = _showAllItems || items.length <= _previewLimit
        ? items
        : items.take(_previewLimit).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Header Card
        if (widget.showHeader) ...[
          _buildSummaryHeader(context, isDark, items.length),
          SizedBox(height: AppSpacing.md.h),
        ],

        // Toggle Bar: Cards vs Clean Table
        _buildViewToggleBar(context, isDark, items.length),
        SizedBox(height: AppSpacing.sm.h),

        // Content
        if (_isCompactView)
          _buildCompactCardsList(context, displayedItems, isDark)
        else
          _buildFullAmortizationTable(context, displayedItems, isDark),

        // Show More / Show Less Button for long schedules
        if (items.length > _previewLimit) ...[
          SizedBox(height: AppSpacing.xs.h),
          Center(
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
              icon: Icon(
                _showAllItems ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                size: 20.sp,
              ),
              label: Text(
                _showAllItems
                    ? l10nPick(
                        context,
                        fa: 'بستن جدول و نمایش کمتر',
                        en: 'Show Less',
                        ar: 'عرض أقل',
                        zh: '收起',
                      )
                    : '${l10nPick(context, fa: 'مشاهده تمام', en: 'View All', ar: 'عرض جميع', zh: '查看全部')} ${items.length} ${l10nPick(context, fa: 'قسط', en: 'Installments', ar: 'أقساط', zh: '期')}',
                style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                setState(() {
                  _showAllItems = !_showAllItems;
                });
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryHeader(BuildContext context, bool isDark, int totalCount) {
    final principal = _computedTotalPrincipal;
    final interest = _computedTotalInterest;
    final total = _computedTotalRepayment;

    final principalPct = total > 0 ? (principal / total * 100).round() : 100;
    final interestPct = total > 0 ? (100 - principalPct) : 0;

    final primaryAccent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      padding: EdgeInsetsDirectional.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.pie_chart_outline_rounded, size: 16.sp, color: primaryAccent),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        l10nPick(
                          context,
                          fa: 'خلاصه تسهیلات و سهم اصل و سود',
                          en: 'Repayment & Amortization Summary',
                          ar: 'ملخص السداد والاستهلاك',
                          zh: '还款与利息分布',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_paidCount > 0) ...[
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.successContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                  ),
                  child: Text(
                    '$_paidCount / $totalCount ${l10nPick(context, fa: 'تسویه شده', en: 'paid', ar: 'مسدد', zh: '已付')}',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: AppSpacing.sm.h),

          // 3 Metric columns: Principal, Interest, Total Due
          Row(
            children: [
              Expanded(
                child: _buildHeaderMetric(
                  context,
                  label: l10nPick(context, fa: 'اصل وام', en: 'Principal', ar: 'الأصل', zh: '本金'),
                  value: _formatAmount(principal),
                  color: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              Container(width: 1, height: 35.h, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 6.w),
                  child: _buildHeaderMetric(
                    context,
                    label: l10nPick(context, fa: 'کل سود', en: 'Total Interest', ar: 'إجمالي الفائدة', zh: '总利息'),
                    value: _formatAmount(interest),
                    color: const Color(0xFFD97706),
                    textSecondary: textSecondary,
                  ),
                ),
              ),
              Container(width: 1, height: 35.h, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
              Expanded(
                child: _buildHeaderMetric(
                  context,
                  label: l10nPick(context, fa: 'مجموع بازپرداخت', en: 'Total Due', ar: 'الإجمالي', zh: '总还款'),
                  value: _formatAmount(total),
                  color: primaryAccent,
                  textSecondary: textSecondary,
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.sm.h),

          // Principal vs Interest Stacked Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXs.r),
            child: SizedBox(
              height: 6.h,
              child: Row(
                children: [
                  Expanded(
                    flex: principalPct.clamp(1, 99),
                    child: Container(color: primaryAccent),
                  ),
                  Expanded(
                    flex: interestPct.clamp(1, 99),
                    child: Container(color: const Color(0xFFF59E0B)),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 5.h),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7.r,
                      height: 7.r,
                      decoration: BoxDecoration(
                        color: primaryAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        '${l10nPick(context, fa: 'اصل وام', en: 'Principal', ar: 'الأصل', zh: '本金')}: $principalPct٪',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10.sp, color: textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7.r,
                      height: 7.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        '${l10nPick(context, fa: 'سود تسهیلات', en: 'Interest', ar: 'الفائدة', zh: '利息')}: $interestPct٪',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10.sp, color: textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_overdueCount > 0) ...[
            SizedBox(height: AppSpacing.sm.h),
            Container(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16.sp, color: AppColors.error),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      '$_overdueCount ${l10nPick(
                            context,
                            fa: 'قسط معوق سررسید گذشته دارید. لطفاً تسویه فرمایید.',
                            en: 'overdue installment(s). Please settle to prevent late fees.',
                            ar: 'قسط متأخر. يرجى السداد لتجنب الغرامات.',
                            zh: '笔分期已逾期。请及时还款。',
                          )}',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderMetric(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required Color textSecondary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: textSecondary),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w800,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          _currencyLabel(context),
          style: TextStyle(
            fontSize: 8.5.sp,
            color: textSecondary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildViewToggleBar(BuildContext context, bool isDark, int count) {
    final primaryAccent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            '${l10nPick(context, fa: 'جدول استهلاک اقساط', en: 'Amortization Table', ar: 'جدول الاستهلاك', zh: '还款计划表')} ($count)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: textPrimary),
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsetsDirectional.all(2.r),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              _buildViewToggleButton(
                context,
                icon: Icons.table_chart_outlined,
                label: l10nPick(context, fa: 'جدول', en: 'Table', ar: 'جدول', zh: '表格'),
                isSelected: !_isCompactView,
                primaryAccent: primaryAccent,
                isDark: isDark,
                onTap: () => setState(() => _isCompactView = false),
              ),
              SizedBox(width: 2.w),
              _buildViewToggleButton(
                context,
                icon: Icons.view_agenda_outlined,
                label: l10nPick(context, fa: 'کارت‌ها', en: 'Cards', ar: 'بطاقات', zh: '卡片'),
                isSelected: _isCompactView,
                primaryAccent: primaryAccent,
                isDark: isDark,
                onTap: () => setState(() => _isCompactView = true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewToggleButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color primaryAccent,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(6.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppSpacing.fast,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 7.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected ? primaryAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 13.sp,
              color: isSelected
                  ? (isDark ? AppColors.deepBlack : Colors.white)
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            SizedBox(width: 3.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? AppColors.deepBlack : Colors.white)
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Clean Amortization Schedule Table showing:
  /// Month #, Principal, Interest, and Remaining Balance
  Widget _buildFullAmortizationTable(BuildContext context, List<InstallmentItem> items, bool isDark) {
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final headerBg = isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground;
    final zebraColor = isDark
        ? AppColors.darkSurfaceVariant.withValues(alpha: 0.4)
        : AppColors.lightBackground.withValues(alpha: 0.6);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(headerBg),
            headingTextStyle: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
            dataTextStyle: TextStyle(
              fontSize: 10.5.sp,
              color: textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            horizontalMargin: 12.w,
            columnSpacing: 14.w,
            columns: [
              DataColumn(
                label: Text(l10nPick(context, fa: 'ماه #', en: 'Month #', ar: 'الشهر', zh: '期数')),
              ),
              DataColumn(
                label: Text(l10nPick(context, fa: 'اصل وام', en: 'Principal', ar: 'الأصل', zh: '本金')),
              ),
              DataColumn(
                label: Text(l10nPick(context, fa: 'سود', en: 'Interest', ar: 'الفائدة', zh: '利息')),
              ),
              DataColumn(
                label: Text(l10nPick(context, fa: 'مبلغ قسط', en: 'Payment', ar: 'القسط', zh: '总额')),
              ),
              DataColumn(
                label: Text(l10nPick(context, fa: 'مانده اصل', en: 'Remaining Balance', ar: 'المتبقي', zh: '剩余本金')),
              ),
              DataColumn(
                label: Text(l10nPick(context, fa: 'سررسید', en: 'Due Date', ar: 'الاستحقاق', zh: '到期日')),
              ),
              DataColumn(
                label: Text(l10nPick(context, fa: 'وضعیت', en: 'Status', ar: 'الحالة', zh: '状态')),
              ),
              if (widget.onPayInstallment != null)
                DataColumn(
                  label: Text(l10nPick(context, fa: 'عملیات', en: 'Action', ar: 'إجراء', zh: '操作')),
                ),
            ],
            rows: items.map((item) {
              final isEven = item.installmentNumber % 2 == 0;
              Color rowColor;
              if (item.isOverdue) {
                rowColor = AppColors.errorContainer.withValues(alpha: isDark ? 0.2 : 0.4);
              } else if (item.isGracePeriod) {
                rowColor = const Color(0xFFFEF3C7).withValues(alpha: isDark ? 0.15 : 0.35);
              } else if (isEven) {
                rowColor = zebraColor;
              } else {
                rowColor = surfaceColor;
              }

              return DataRow(
                color: WidgetStateProperty.all(rowColor),
                cells: [
                  // Month #
                  DataCell(
                    Text(
                      '${item.installmentNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  // Principal
                  DataCell(
                    Text(
                      _formatAmount(item.principalAmount),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: item.principalAmount > 0 ? textPrimary : AppColors.softGray,
                      ),
                    ),
                  ),
                  // Interest
                  DataCell(
                    Text(
                      _formatAmount(item.interestAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ),
                  // Payment
                  DataCell(
                    Text(
                      _formatAmount(item.totalPayment),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      ),
                    ),
                  ),
                  // Remaining Balance
                  DataCell(
                    Text(
                      _formatAmount(item.remainingBalance),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  // Due Date
                  DataCell(Text(_formatDate(item.dueDate, context))),
                  // Status
                  DataCell(_buildStatusBadge(context, item, isDark)),
                  // Action if needed
                  if (widget.onPayInstallment != null)
                    DataCell(
                      !item.isPaid
                          ? TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: item.isOverdue ? AppColors.error : AppColors.lightPrimary,
                                padding: EdgeInsetsDirectional.symmetric(horizontal: 6.w, vertical: 2.h),
                              ),
                              onPressed: () => widget.onPayInstallment!(item),
                              child: Text(
                                l10nPick(context, fa: 'پرداخت', en: 'Pay', ar: 'سداد', zh: '支付'),
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCardsList(BuildContext context, List<InstallmentItem> items, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.sm.h),
      itemBuilder: (ctx, index) {
        final item = items[index];
        return _buildInstallmentCard(context, item, isDark);
      },
    );
  }

  Widget _buildInstallmentCard(BuildContext context, InstallmentItem item, bool isDark) {
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final primaryAccent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final principalRatio = item.totalPayment > 0 ? (item.principalAmount / item.totalPayment).clamp(0.0, 1.0) : 0.0;
    final interestRatio = item.totalPayment > 0 ? (item.interestAmount / item.totalPayment).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: EdgeInsetsDirectional.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
        border: Border.all(
          color: item.isOverdue ? AppColors.error.withValues(alpha: 0.6) : borderColor,
          width: item.isOverdue ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Seq #, Grace Pill, Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      '${l10nPick(context, fa: 'قسط', en: 'Month', ar: 'قسط', zh: '期')} ${item.installmentNumber}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  if (item.isGracePeriod) ...[
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                      ),
                      child: Text(
                        l10nPick(context, fa: 'تنفس (فقط سود)', en: 'Grace', ar: 'سماح', zh: '宽限'),
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              _buildStatusBadge(context, item, isDark),
            ],
          ),

          SizedBox(height: AppSpacing.sm.h),

          // Row 2: Payment Amount & Due Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${_formatAmount(item.totalPayment)} ${_currencyLabel(context)}',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                '${l10nPick(context, fa: 'سررسید', en: 'Due', ar: 'الاستحقاق', zh: '到期')}: ${_formatDate(item.dueDate, context)}',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.sm.h),

          // Row 3: Principal vs Interest Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: SizedBox(
              height: 4.5.h,
              child: Row(
                children: [
                  if (principalRatio > 0)
                    Expanded(
                      flex: (principalRatio * 100).round().clamp(1, 100),
                      child: Container(color: primaryAccent),
                    ),
                  if (interestRatio > 0)
                    Expanded(
                      flex: (interestRatio * 100).round().clamp(1, 100),
                      child: Container(color: const Color(0xFFF59E0B)),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 5.h),

          // Details: Principal vs Interest
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10nPick(context, fa: 'سهم اصل', en: 'Principal', ar: 'الأصل', zh: '本金')}: ${_formatAmount(item.principalAmount)}',
                style: TextStyle(
                  fontSize: 10.5.sp,
                  color: textSecondary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                '${l10nPick(context, fa: 'سهم سود', en: 'Interest', ar: 'الفائدة', zh: '利息')}: ${_formatAmount(item.interestAmount)}',
                style: TextStyle(
                  fontSize: 10.5.sp,
                  color: const Color(0xFFD97706),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          // Footer: Remaining Balance & Pay Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10nPick(context, fa: 'مانده اصل', en: 'Remaining Balance', ar: 'المتبقي', zh: '本金余额')}: ${_formatAmount(item.remainingBalance)} ${_currencyLabel(context)}',
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w700,
                  color: textSecondary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (!item.isPaid && widget.onPayInstallment != null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.isOverdue ? AppColors.error : primaryAccent,
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 4.h),
                    minimumSize: Size(0, 28.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
                  ),
                  icon: Icon(
                    item.isOverdue ? Icons.priority_high_rounded : Icons.payment_rounded,
                    size: 13.sp,
                    color: Colors.white,
                  ),
                  label: Text(
                    l10nPick(context, fa: 'پرداخت قسط', en: 'Pay', ar: 'سداد', zh: '支付'),
                    style: TextStyle(fontSize: 10.5.sp, color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () => widget.onPayInstallment!(item),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, InstallmentItem item, bool isDark) {
    if (item.isPaid) {
      return Container(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 7.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: AppColors.successContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 12.sp, color: AppColors.success),
            SizedBox(width: 4.w),
            Text(
              l10nPick(context, fa: 'پرداخت‌شده', en: 'Paid', ar: 'مسدد', zh: '已支付'),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }

    if (item.isOverdue) {
      return Container(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 7.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 12.sp, color: AppColors.error),
            SizedBox(width: 4.w),
            Text(
              l10nPick(context, fa: 'معوق', en: 'Overdue', ar: 'متأخر', zh: '已逾期'),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      );
    }

    // Pending
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 12.sp,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          SizedBox(width: 4.w),
          Text(
            l10nPick(context, fa: 'در انتظار', en: 'Pending', ar: 'معلق', zh: '待付'),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
