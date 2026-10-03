import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
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
      final itemDate = DateTime(baseDate.year, baseDate.month + i, baseDate.day);
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

/// Detailed amortization schedule component supporting compact card view
/// and full horizontal data table view, with summary metrics and pay actions.
class LoanAmortizationSchedule extends StatefulWidget {
  final List<InstallmentItem> installments;
  final double? totalPrincipal;
  final double? totalInterest;
  final String currency;
  final void Function(InstallmentItem item)? onPayInstallment;
  final bool showHeader;
  final bool isCompactInitially;

  const LoanAmortizationSchedule({
    super.key,
    required this.installments,
    this.totalPrincipal,
    this.totalInterest,
    this.currency = 'IRR',
    this.onPayInstallment,
    this.showHeader = true,
    this.isCompactInitially = true,
  });

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

  String _formatAmount(double val) {
    if (widget.currency == 'USD') {
      return val.toStringAsFixed(2);
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
    if (widget.currency == 'USD') return r'$';
    return l10nPick(context, fa: 'ریال', en: 'IRR', ar: 'ريال', zh: '里亚尔');
  }

  double get _computedTotalPrincipal {
    if (widget.totalPrincipal != null && widget.totalPrincipal! > 0) {
      return widget.totalPrincipal!;
    }
    return widget.installments.fold<double>(0.0, (sum, i) => sum + i.principalAmount);
  }

  double get _computedTotalInterest {
    if (widget.totalInterest != null && widget.totalInterest! > 0) {
      return widget.totalInterest!;
    }
    return widget.installments.fold<double>(0.0, (sum, i) => sum + i.interestAmount);
  }

  double get _computedTotalRepayment => _computedTotalPrincipal + _computedTotalInterest;

  int get _paidCount => widget.installments.where((i) => i.isPaid).length;
  int get _overdueCount => widget.installments.where((i) => i.isOverdue).length;

  @override
  Widget build(BuildContext context) {
    if (widget.installments.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Center(
          child: Text(
            l10nPick(
              context,
              fa: 'برنامه اقساط ثبت نشده است',
              en: 'No amortization schedule recorded',
              ar: 'لا يوجد جدول أقساط',
              zh: '暂无还款计划表',
            ),
            style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary),
          ),
        ),
      );
    }

    final displayedItems = _showAllItems || widget.installments.length <= _previewLimit
        ? widget.installments
        : widget.installments.take(_previewLimit).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Header Card
        if (widget.showHeader) ...[
          _buildSummaryHeader(context),
          SizedBox(height: 12.h),
        ],

        // View Mode Toggle (Compact Cards vs Amortization Table)
        _buildViewToggleBar(context),
        SizedBox(height: 12.h),

        // Content
        if (_isCompactView)
          _buildCompactCardsList(context, displayedItems)
        else
          _buildFullAmortizationTable(context, displayedItems),

        // Show More / Show Less Button if long list
        if (widget.installments.length > _previewLimit) ...[
          SizedBox(height: 8.h),
          Center(
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.lightPrimary,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
              icon: Icon(
                _showAllItems ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                size: 20.sp,
              ),
              label: Text(
                _showAllItems
                    ? l10nPick(
                        context,
                        fa: 'بستن و نمایش کمتر',
                        en: 'Show Less',
                        ar: 'عرض أقل',
                        zh: '收起',
                      )
                    : '${l10nPick(context, fa: 'مشاهده تمام', en: 'View All', ar: 'عرض جميع', zh: '查看全部')} ${widget.installments.length} ${l10nPick(context, fa: 'قسط', en: 'Installments', ar: 'أقساط', zh: '期')}',
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

  Widget _buildSummaryHeader(BuildContext context) {
    final principal = _computedTotalPrincipal;
    final interest = _computedTotalInterest;
    final total = _computedTotalRepayment;

    final principalPct = total > 0 ? (principal / total * 100).round() : 100;
    final interestPct = total > 0 ? (100 - principalPct) : 0;
    final totalItems = widget.installments.length;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              Text(
                l10nPick(
                  context,
                  fa: 'خلاصه تسهیلات و بازپرداخت',
                  en: 'Loan & Repayment Summary',
                  ar: 'ملخص التسهيل والسداد',
                  zh: '贷款与还款汇总',
                ),
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
              ),
              if (_paidCount > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.successContainer,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '$_paidCount / $totalItems ${l10nPick(context, fa: 'تسویه شده', en: 'paid', ar: 'مسدد', zh: '已付')}',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 12.h),

          // 3 Metric columns: Principal, Interest, Total
          Row(
            children: [
              Expanded(
                child: _buildHeaderMetric(
                  context,
                  label: l10nPick(context, fa: 'اصل وام', en: 'Principal', ar: 'أصل التسهيل', zh: '本金'),
                  value: _formatAmount(principal),
                  color: AppColors.lightTextPrimary,
                ),
              ),
              Container(width: 1, height: 35.h, color: AppColors.lightBorder),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: _buildHeaderMetric(
                    context,
                    label: l10nPick(context, fa: 'کل سود', en: 'Total Interest', ar: 'إجمالي الفائدة', zh: '总利息'),
                    value: _formatAmount(interest),
                    color: const Color(0xFFD97706),
                  ),
                ),
              ),
              Container(width: 1, height: 35.h, color: AppColors.lightBorder),
              Expanded(
                child: _buildHeaderMetric(
                  context,
                  label: l10nPick(context, fa: 'مجموع بازپرداخت', en: 'Total Due', ar: 'الإجمالي', zh: '总还款'),
                  value: _formatAmount(total),
                  color: AppColors.lightPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Principal vs Interest Stacked Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: SizedBox(
              height: 7.h,
              child: Row(
                children: [
                  Expanded(
                    flex: principalPct.clamp(1, 99),
                    child: Container(color: AppColors.lightPrimary),
                  ),
                  Expanded(
                    flex: interestPct.clamp(1, 99),
                    child: Container(color: const Color(0xFFF59E0B)),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 6.h),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: const BoxDecoration(
                      color: AppColors.lightPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${l10nPick(context, fa: 'اصل وام', en: 'Principal', ar: 'الأصل', zh: '本金')}: $principalPct٪',
                    style: TextStyle(fontSize: 10.sp, color: AppColors.lightTextSecondary),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${l10nPick(context, fa: 'سود تسهیلات', en: 'Interest', ar: 'الفائدة', zh: '利息')}: $interestPct٪',
                    style: TextStyle(fontSize: 10.sp, color: AppColors.lightTextSecondary),
                  ),
                ],
              ),
            ],
          ),

          if (_overdueCount > 0) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(8.r),
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
                            fa: 'قسط معوق سررسید گذشته دارید. لطفاً جهت جلوگیری از جریمه تأخیر تسویه فرمایید.',
                            en: 'overdue installment(s). Please settle to prevent late fees.',
                            ar: 'قسط متأخر. يرجى السداد لتجنب الغرامات.',
                            zh: '笔分期已逾期。请及时还款以避免产生滞纳金。',
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10.5.sp, color: AppColors.lightTextSecondary),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          _currencyLabel(context),
          style: TextStyle(
            fontSize: 9.sp,
            color: AppColors.lightTextSecondary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildViewToggleBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${l10nPick(context, fa: 'جدول اقساط', en: 'Installments', ar: 'الأقساط', zh: '还款明细')} (${widget.installments.length})',
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
        ),
        Container(
          padding: EdgeInsets.all(3.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Row(
            children: [
              _buildViewToggleButton(
                context,
                icon: Icons.view_agenda_outlined,
                label: l10nPick(context, fa: 'کارت‌ها', en: 'Cards', ar: 'بطاقات', zh: '卡片'),
                isSelected: _isCompactView,
                onTap: () => setState(() => _isCompactView = true),
              ),
              SizedBox(width: 4.w),
              _buildViewToggleButton(
                context,
                icon: Icons.table_chart_outlined,
                label: l10nPick(context, fa: 'جدول استهلاک', en: 'Table', ar: 'جدول', zh: '表格'),
                isSelected: !_isCompactView,
                onTap: () => setState(() => _isCompactView = false),
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 13.sp,
              color: isSelected ? Colors.white : AppColors.lightTextSecondary,
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCardsList(BuildContext context, List<InstallmentItem> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(height: 8.h),
      itemBuilder: (ctx, index) {
        final item = items[index];
        return _buildInstallmentCard(context, item);
      },
    );
  }

  Widget _buildInstallmentCard(BuildContext context, InstallmentItem item) {
    final principalRatio = item.totalPayment > 0 ? (item.principalAmount / item.totalPayment).clamp(0.0, 1.0) : 0.0;
    final interestRatio = item.totalPayment > 0 ? (item.interestAmount / item.totalPayment).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: item.isOverdue
              ? AppColors.error.withValues(alpha: 0.5)
              : AppColors.lightBorder,
          width: item.isOverdue ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Seq #, Grace Pill, Due Date, Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: AppColors.lightBorder),
                    ),
                    child: Text(
                      '${l10nPick(context, fa: 'قسط', en: 'Inst.', ar: 'قسط', zh: '期')} ${item.installmentNumber}',
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (item.isGracePeriod) ...[
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6.r),
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
              _buildStatusBadge(context, item),
            ],
          ),

          SizedBox(height: 8.h),

          // Row 2: Amount & Due Date
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
                  color: AppColors.lightTextPrimary,
                ),
              ),
              Text(
                '${l10nPick(context, fa: 'سررسید', en: 'Due', ar: 'الاستحقاق', zh: '到期')}: ${_formatDate(item.dueDate, context)}',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Row 3: Principal vs Interest Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: SizedBox(
              height: 5.h,
              child: Row(
                children: [
                  if (principalRatio > 0)
                    Expanded(
                      flex: (principalRatio * 100).round().clamp(1, 100),
                      child: Container(color: AppColors.lightPrimary),
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

          SizedBox(height: 4.h),

          // Details: Principal vs Interest parts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10nPick(context, fa: 'سهم اصل', en: 'Principal', ar: 'الأصل', zh: '本金')}: ${_formatAmount(item.principalAmount)}',
                style: TextStyle(fontSize: 10.sp, color: AppColors.lightTextSecondary),
              ),
              Text(
                '${l10nPick(context, fa: 'سهم سود', en: 'Interest', ar: 'الفائدة', zh: '利息')}: ${_formatAmount(item.interestAmount)}',
                style: TextStyle(fontSize: 10.sp, color: const Color(0xFFD97706)),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          // Footer: Remaining Balance & Pay Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10nPick(context, fa: 'مانده اصل', en: 'Balance', ar: 'المتبقي', zh: '本金余额')}: ${_formatAmount(item.remainingBalance)} ${_currencyLabel(context)}',
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextSecondary,
                ),
              ),
              if (!item.isPaid && widget.onPayInstallment != null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.isOverdue ? AppColors.error : AppColors.lightPrimary,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    minimumSize: Size(0, 28.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
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

  Widget _buildStatusBadge(BuildContext context, InstallmentItem item) {
    if (item.isPaid) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: AppColors.successContainer,
          borderRadius: BorderRadius.circular(6.r),
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
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(6.r),
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
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 12.sp, color: AppColors.lightTextSecondary),
          SizedBox(width: 4.w),
          Text(
            l10nPick(context, fa: 'در انتظار', en: 'Pending', ar: 'قيد الانتظار', zh: '待付'),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullAmortizationTable(BuildContext context, List<InstallmentItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.lightBackground),
            headingTextStyle: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.lightTextPrimary,
            ),
            dataTextStyle: TextStyle(
              fontSize: 10.5.sp,
              color: AppColors.lightTextPrimary,
            ),
            horizontalMargin: 12.w,
            columnSpacing: 16.w,
            columns: [
              DataColumn(label: Text(l10nPick(context, fa: '#', en: '#', ar: '#', zh: '#'))),
              DataColumn(label: Text(l10nPick(context, fa: 'سررسید', en: 'Due Date', ar: 'الاستحقاق', zh: '到期日'))),
              DataColumn(label: Text(l10nPick(context, fa: 'مبلغ قسط', en: 'Payment', ar: 'القسط', zh: '应付金额'))),
              DataColumn(label: Text(l10nPick(context, fa: 'سهم اصل', en: 'Principal', ar: 'الأصل', zh: '本金'))),
              DataColumn(label: Text(l10nPick(context, fa: 'سهم سود', en: 'Interest', ar: 'الفائدة', zh: '利息'))),
              DataColumn(label: Text(l10nPick(context, fa: 'مانده اصل', en: 'Balance', ar: 'المتبقي', zh: '本金余额'))),
              DataColumn(label: Text(l10nPick(context, fa: 'وضعیت', en: 'Status', ar: 'الحالة', zh: '状态'))),
              if (widget.onPayInstallment != null)
                DataColumn(label: Text(l10nPick(context, fa: 'عملیات', en: 'Action', ar: 'الإجراء', zh: '操作'))),
            ],
            rows: items.map((item) {
              final isEven = item.installmentNumber % 2 == 0;
              final rowColor = item.isOverdue
                  ? AppColors.errorContainer.withValues(alpha: 0.3)
                  : (item.isGracePeriod
                      ? const Color(0xFFFEF3C7).withValues(alpha: 0.3)
                      : (isEven ? AppColors.lightBackground.withValues(alpha: 0.5) : Colors.white));

              return DataRow(
                color: WidgetStateProperty.all(rowColor),
                cells: [
                  DataCell(
                    Text(
                      '${item.installmentNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  DataCell(Text(_formatDate(item.dueDate, context))),
                  DataCell(
                    Text(
                      _formatAmount(item.totalPayment),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  DataCell(Text(_formatAmount(item.principalAmount))),
                  DataCell(
                    Text(
                      _formatAmount(item.interestAmount),
                      style: const TextStyle(color: Color(0xFFD97706)),
                    ),
                  ),
                  DataCell(Text(_formatAmount(item.remainingBalance))),
                  DataCell(_buildStatusBadge(context, item)),
                  if (widget.onPayInstallment != null)
                    DataCell(
                      !item.isPaid
                          ? TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: item.isOverdue ? AppColors.error : AppColors.lightPrimary,
                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
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
}
