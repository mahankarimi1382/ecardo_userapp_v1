import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/loan_controller.dart';
import '../widgets/loan_amortization_schedule.dart';
import '../widgets/loan_status_stepper.dart';

/// Screen displaying complete details for a single loan application,
/// including timeline, collateral status, repayment schedule, and action buttons.
class LoanDetailScreen extends StatefulWidget {
  final int caseId;
  const LoanDetailScreen({super.key, required this.caseId});

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  late final LoanController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LoanController>()
        ? Get.find<LoanController>()
        : Get.put(LoanController());
    if (widget.caseId > 0) {
      controller.fetchCase(widget.caseId);
    }
  }

  String _statusLabel(BuildContext context, String status) {
    switch (status) {
      case 'DRAFT': return l10nPick(context, fa: 'پیش‌نویس', en: 'Draft', ar: 'مسودة', zh: '草稿');
      case 'UNDER_ASSESSMENT': return l10nPick(context, fa: 'در حال سنجش اعتبار', en: 'Under Scoring', ar: 'قيد التقييم', zh: '审核中');
      case 'COMPLEMENT_REQUIRED': return l10nPick(context, fa: 'نیاز به تکمیل مدارک', en: 'Docs Required', ar: 'مطلوب مستندات', zh: '待补充资料');
      case 'OFFERED': return l10nPick(context, fa: 'پیشنهاد صادر شد', en: 'Offered', ar: 'تم إصدار العرض', zh: '已出方案');
      case 'AWAITING_COLLATERAL': return l10nPick(context, fa: 'در انتظار تودیع وثیقه', en: 'Awaiting Collateral', ar: 'بانتظار الضمان', zh: '待交抵押');
      case 'AWAITING_SIGNING': return l10nPick(context, fa: 'در انتظار امضا', en: 'Awaiting Signature', ar: 'بانتظار التوقيع', zh: '待签署');
      case 'DISBURSED': return l10nPick(context, fa: 'پرداخت شد', en: 'Disbursed', ar: 'تم الصرف', zh: '已放款');
      case 'ACTIVE': return l10nPick(context, fa: 'در حال بازپرداخت', en: 'Active Repayment', ar: 'سداد جاري', zh: '还款中');
      case 'OVERDUE': return l10nPick(context, fa: 'معوق', en: 'Overdue', ar: 'متأخر', zh: '已逾期');
      case 'DEFAULTED': return l10nPick(context, fa: 'نکول', en: 'Defaulted', ar: 'تعثر', zh: '违约');
      case 'COMPLETED': return l10nPick(context, fa: 'تسویه‌شده', en: 'Completed', ar: 'تمت التسوية', zh: '已结清');
      case 'REJECTED': return l10nPick(context, fa: 'رد شد', en: 'Rejected', ar: 'مرفوض', zh: '已拒绝');
      case 'CANCELLED': return l10nPick(context, fa: 'لغوشده', en: 'Cancelled', ar: 'ملغي', zh: '已取消');
      default: return status;
    }
  }

  void _confirm(String title, String message, Future<bool> Function() action) {
    final errTitle = l10nPick(context, fa: 'خطا', en: 'Error', ar: 'خطأ', zh: '错误');
    final errBody = l10nPick(
      context,
      fa: 'عملیات با خطا مواجه شد. ارتباط با سرور را بررسی کنید.',
      en: 'Operation failed. Please verify server connection.',
      ar: 'فشلت العملية. يرجى التحقق من الاتصال.',
      zh: '操作失败，请检查服务器连接。',
    );

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r)),
        title: Text(title, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800)),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Get.back();
            },
            child: Text(l10nPick(context, fa: 'انصراف', en: 'Cancel', ar: 'إلغاء', zh: '取消')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
            ),
            onPressed: () async {
              HapticFeedback.lightImpact();
              Get.back();
              final ok = await action();
              if (!mounted) return;
              if (!ok) {
                Get.snackbar(
                  errTitle,
                  errBody,
                  backgroundColor: AppColors.error,
                  colorText: AppColors.white,
                );
              }
            },
            child: Text(
              l10nPick(context, fa: 'تأیید', en: 'Confirm', ar: 'تأكيد', zh: '确认'),
              style: const TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'جزئیات پرونده تسهیلات',
              en: 'Loan Case Details',
              ar: 'تفاصيل ملف التسهيل',
              zh: '贷款案件详情',
            ),
          ),
        ),
      ),
      body: Obx(() {
        final c = controller.selectedCase.value;
        if (controller.isLoadingDetail.value || c == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchCase(c.id),
          child: ListView(
            padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.page.w, vertical: AppSpacing.md.h),
            children: [
              // 1. Loan Status Stepper
              LoanStatusStepper(currentStatus: c.status),
              SizedBox(height: AppSpacing.md.h),

              // 2. Status & Header Card
              Container(
                padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
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
                          '${l10nPick(context, fa: 'پرونده شماره', en: 'Case No.', ar: 'رقم الملف', zh: '案号')}: ${c.caseNo}',
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            fontFamily: 'monospace',
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Container(
                          padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: primaryAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                          ),
                          child: Text(
                            _statusLabel(context, c.status),
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: primaryAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    Text(
                      l10nPick(
                        context,
                        fa: 'مبلغ درخواستی: ${c.requestedAmount.toInt()} ریال · بازپرداخت: ${c.tenureMonths} ماهه',
                        en: 'Requested: ${c.requestedAmount.toInt()} IRR · Tenure: ${c.tenureMonths} months',
                        ar: 'المبلغ: ${c.requestedAmount.toInt()} ريال · المدة: ${c.tenureMonths} شهر',
                        zh: '申请金额：${c.requestedAmount.toInt()} 里亚尔 · 期限：${c.tenureMonths} 个月',
                      ),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Offer section
              if (c.offer != null && c.status == 'OFFERED') ...[
                SizedBox(height: AppSpacing.md.h),
                Container(
                  padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2E2211) : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(context, fa: 'پیشنهاد تسهیلاتی صادرشده', en: 'Approved Loan Offer', ar: 'العرض الصادر', zh: '已出具授信方案'),
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF92400E),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Text(
                        l10nPick(
                          context,
                          fa: 'مبلغ مصوب: ${c.offer!.offeredAmount.toInt()} ریال · سود: ${c.offer!.ratePct}٪ سالانه',
                          en: 'Approved Amount: ${c.offer!.offeredAmount.toInt()} IRR · Rate: ${c.offer!.ratePct}%',
                          ar: 'المبلغ المعتمد: ${c.offer!.offeredAmount.toInt()} ريال · الفائدة: ${c.offer!.ratePct}٪',
                          zh: '获批金额：${c.offer!.offeredAmount.toInt()} · 利率：${c.offer!.ratePct}%',
                        ),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF78350F),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r)),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _confirm(
                            l10nPick(context, fa: 'پذیرش پیشنهاد', en: 'Accept Offer', ar: 'قبول العرض', zh: '接受方案'),
                            l10nPick(
                              context,
                              fa: 'آیا شرایط پیشنهاد مصوب را تأیید کرده و به مرحله تودیع وثیقه می‌روید؟',
                              en: 'Do you confirm and proceed to collateral deposit?',
                              ar: 'هل توافق على الشروط والانتقال إلى توديع الضمان؟',
                              zh: '确认接受并进入担保质押环节？',
                            ),
                            () => controller.acceptOffer(c.id),
                          );
                        },
                        child: Text(
                          l10nPick(context, fa: 'پذیرش پیشنهاد و ادامه', en: 'Accept Offer & Continue', ar: 'قبول ومتابعة', zh: '接受方案并继续'),
                          style: TextStyle(color: isDark ? AppColors.deepBlack : AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Collateral Actions
              if (c.status == 'AWAITING_COLLATERAL') ...[
                SizedBox(height: AppSpacing.md.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r)),
                          padding: EdgeInsetsDirectional.symmetric(vertical: 12.h),
                        ),
                        icon: Icon(Icons.account_balance_wallet, color: isDark ? AppColors.deepBlack : AppColors.white, size: 18.sp),
                        label: Text(
                          l10nPick(context, fa: 'تودیع وثیقه نقدی', en: 'Post Cash Collateral', ar: 'توديع نقدي', zh: '质押现金'),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark ? AppColors.deepBlack : AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _confirm(
                            l10nPick(context, fa: 'تودیع وثیقه نقدی', en: 'Post Cash Collateral', ar: 'توديع نقدي', zh: '质押现金'),
                            l10nPick(context, fa: 'قفل وجه نقد از کیف پول به‌عنوان وثیقه تضمین بازپرداخت؟', en: 'Lock cash from your wallet as collateral?', ar: 'تجميد الرصيد كضمان؟', zh: '从钱包中锁定资金作为还款担保？'),
                            () => controller.postCashCollateral(c.id, c.requestedAmount, 'IRR'),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4338CA),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r)),
                          padding: EdgeInsetsDirectional.symmetric(vertical: 12.h),
                        ),
                        icon: Icon(Icons.currency_bitcoin, color: AppColors.white, size: 18.sp),
                        label: Text(
                          l10nPick(context, fa: 'توثیق رمزارز', en: 'Post Crypto', ar: 'توديع كريبتو', zh: '质押加密币'),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _confirm(
                            l10nPick(context, fa: 'توثیق رمزارز', en: 'Post Crypto', ar: 'توديع كريبتو', zh: '质押加密币'),
                            l10nPick(context, fa: 'قفل معادل ارزی USDT از والت برای پوشش وثیقه با پایش LTV؟', en: 'Lock USDT equivalent as monitored LTV collateral?', ar: 'قفل عملات رقمية كضمان؟', zh: '锁定等额USDT作为LTV监测抵押？'),
                            () => controller.postCryptoCollateral(c.id, c.requestedAmount, 'USDT'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],

              // Signing Action
              if (c.status == 'AWAITING_SIGNING') ...[
                SizedBox(height: AppSpacing.md.h),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryAccent,
                    padding: EdgeInsetsDirectional.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r)),
                  ),
                  icon: Icon(Icons.draw_rounded, color: isDark ? AppColors.deepBlack : AppColors.white),
                  label: Text(
                    l10nPick(context, fa: 'امضای الکترونیک قرارداد', en: 'Sign Digital Contract', ar: 'توقيع العقد إلكترونياً', zh: '电子签署合同'),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isDark ? AppColors.deepBlack : AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _confirm(
                      l10nPick(context, fa: 'امضای قرارداد', en: 'Sign Contract', ar: 'توقيع العقد', zh: '签署合同'),
                      l10nPick(context, fa: 'قرارداد دیجیتال وام با گواهی الکترونیک امضا شود؟', en: 'Sign digital loan contract with digital certificate?', ar: 'توقيع العقد الرقمي الآن؟', zh: '使用数字证书签署贷款电子合同？'),
                      () => controller.signContract(c.id),
                    );
                  },
                ),
              ],

              // Repayment Tracker & Amortization Schedule
              SizedBox(height: AppSpacing.lg.h),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                padding: EdgeInsetsDirectional.all(AppSpacing.md.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.timeline_rounded, color: primaryAccent, size: 20.sp),
                            SizedBox(width: AppSpacing.sm.w),
                            Text(
                              l10nPick(
                                context,
                                fa: 'ردیاب بازپرداخت و جدول استهلاک',
                                en: 'Repayment Tracker & Schedule',
                                ar: 'متابعة السداد وجدول الاستهلاك',
                                zh: '还款进度跟踪与分摊明细',
                              ),
                              style: AppTextStyles.titleSmall.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (c.status == 'ACTIVE')
                          TextButton.icon(
                            icon: Icon(Icons.bolt_rounded, size: 16.sp, color: AppColors.success),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _confirm(
                                l10nPick(context, fa: 'تسویه زودهنگام', en: 'Early Repayment', ar: 'السداد المبكر', zh: '提前结清'),
                                l10nPick(context, fa: 'آیا مایل به پرداخت یکجای اصل باقیمانده با معافیت از سود آینده هستید؟', en: 'Pay remaining principal with future interest waived?', ar: 'سداد كامل المبلغ المتبقي مع الإعفاء من الفوائد؟', zh: '一次性结清剩余本金并减免后续利息？'),
                                () => controller.earlyRepayment(c.id),
                              );
                            },
                            label: Text(
                              l10nPick(context, fa: 'تسویه پیش از موعد', en: 'Early Payoff', ar: 'تسوية مبكرة', zh: '提前结清'),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md.h),
                    LoanAmortizationSchedule(
                      installments: c.installments.isNotEmpty
                          ? InstallmentItem.fromLoanInstallments(c.installments, totalLoanPrincipal: c.requestedAmount)
                          : InstallmentItem.generateSchedule(
                              principal: c.requestedAmount > 0 ? c.requestedAmount : (c.offer?.offeredAmount ?? 50000000),
                              annualInterestRatePct: c.offer?.ratePct ?? c.product?.interestRatePct ?? 18.0,
                              tenureMonths: c.tenureMonths > 0 ? c.tenureMonths : 12,
                            ),
                      totalPrincipal: c.requestedAmount > 0 ? c.requestedAmount : c.offer?.offeredAmount,
                      currency: 'IRR',
                      showHeader: true,
                      isCompactInitially: true,
                      onPayInstallment: (item) {
                        if (item.id != null) {
                          HapticFeedback.lightImpact();
                          _confirm(
                            l10nPick(context, fa: 'پرداخت قسط', en: 'Pay Installment', ar: 'سداد القسط', zh: '支付分期'),
                            l10nPick(context, fa: 'مبلغ قسط از موجودی کیف پول شما کسر شود؟', en: 'Deduct installment from wallet balance?', ar: 'خصم القسط من المحفظة؟', zh: '从钱包余额中扣缴此期还款？'),
                            () => controller.payInstallment(c.id, item.id!),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Cancel application option
              if (['DRAFT', 'OFFERED', 'AWAITING_COLLATERAL', 'AWAITING_SIGNING'].contains(c.status)) ...[
                SizedBox(height: AppSpacing.md.h),
                Center(
                  child: TextButton.icon(
                    icon: Icon(Icons.cancel_outlined, size: 16.sp, color: AppColors.softGray),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _confirm(
                        l10nPick(context, fa: 'لغو پرونده وام', en: 'Cancel Application', ar: 'إلغاء الطلب', zh: '取消申请'),
                        l10nPick(context, fa: 'آیا از لغو این پرونده و آزادسازی هرگونه وثیقه اطمینان دارید؟', en: 'Cancel this application and release collateral?', ar: 'هل أنت متأكد من إلغاء الملف؟', zh: '确定取消此申请并释放抵押？'),
                        () => controller.cancelCase(c.id),
                      );
                    },
                    label: Text(
                      l10nPick(context, fa: 'انصراف و لغو این درخواست', en: 'Cancel Application', ar: 'إلغاء هذا الطلب', zh: '放弃并取消此申请'),
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.softGray),
                    ),
                  ),
                ),
              ],
              SizedBox(height: AppSpacing.xxl.h),
            ],
          ),
        );
      }),
    );
  }
}
