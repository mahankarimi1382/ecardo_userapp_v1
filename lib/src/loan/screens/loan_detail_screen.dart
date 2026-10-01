import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/loan_controller.dart';
import '../models/loan_models.dart';

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
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800)),
        content: Text(message, style: TextStyle(fontSize: 12.sp, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10nPick(context, fa: 'انصراف', en: 'Cancel', ar: 'إلغاء', zh: '取消')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
            onPressed: () async {
              Get.back();
              final ok = await action();
              if (!ok) {
                Get.snackbar(
                  l10nPick(context, fa: 'خطا', en: 'Error', ar: 'خطأ', zh: '错误'),
                  l10nPick(
                    context,
                    fa: 'عملیات با خطا مواجه شد. ارتباط با سرور را بررسی کنید.',
                    en: 'Operation failed. Please verify server connection.',
                    ar: 'فشلت العملية. يرجى التحقق من الاتصال.',
                    zh: '操作失败，请检查服务器连接。',
                  ),
                  backgroundColor: AppColors.error,
                  colorText: Colors.white,
                );
              }
            },
            child: Text(
              l10nPick(context, fa: 'تأیید', en: 'Confirm', ar: 'تأكيد', zh: '确认'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
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

        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          children: [
            // Status Card
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l10nPick(context, fa: 'پرونده شماره', en: 'Case No.', ar: 'رقم الملف', zh: '案号')}: ${c.caseNo}',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5.sp),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.lightPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          _statusLabel(context, c.status),
                          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: AppColors.lightPrimary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'مبلغ درخواستی: ${c.requestedAmount.toInt()} ریال · بازپرداخت: ${c.tenureMonths} ماهه',
                      en: 'Requested: ${c.requestedAmount.toInt()} IRR · Tenure: ${c.tenureMonths} months',
                      ar: 'المبلغ: ${c.requestedAmount.toInt()} ريال · المدة: ${c.tenureMonths} شهر',
                      zh: '申请金额：${c.requestedAmount.toInt()} 里亚尔 · 期限：${c.tenureMonths} 个月',
                    ),
                    style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary),
                  ),
                ],
              ),
            ),

            // Offer section
            if (c.offer != null && c.status == 'OFFERED') ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10nPick(context, fa: 'پیشنهاد تسهیلاتی صادرشده', en: 'Approved Loan Offer', ar: 'العرض الصادر', zh: '已出具授信方案'),
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp, color: const Color(0xFF92400E)),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      l10nPick(
                        context,
                        fa: 'مبلغ مصوب: ${c.offer!.offeredAmount.toInt()} ریال · سود: ${c.offer!.ratePct}٪ سالانه',
                        en: 'Approved Amount: ${c.offer!.offeredAmount.toInt()} IRR · Rate: ${c.offer!.ratePct}%',
                        ar: 'المبلغ المعتمد: ${c.offer!.offeredAmount.toInt()} ريال · الفائدة: ${c.offer!.ratePct}٪',
                        zh: '获批金额：${c.offer!.offeredAmount.toInt()} · 利率：${c.offer!.ratePct}%',
                      ),
                      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF78350F)),
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                      onPressed: () => _confirm(
                        l10nPick(context, fa: 'پذیرش پیشنهاد', en: 'Accept Offer', ar: 'قبول العرض', zh: '接受方案'),
                        l10nPick(
                          context,
                          fa: 'آیا شرایط پیشنهاد مصوب را تأیید کرده و به مرحله تودیع وثیقه می‌روید؟',
                          en: 'Do you confirm and proceed to collateral deposit?',
                          ar: 'هل توافق على الشروط والانتقال إلى توديع الضمان؟',
                          zh: '确认接受并进入担保质押环节？',
                        ),
                        () => controller.acceptOffer(c.id),
                      ),
                      child: Text(
                        l10nPick(context, fa: 'پذیرش پیشنهاد و ادامه', en: 'Accept Offer & Continue', ar: 'قبول ومتابعة', zh: '接受方案并继续'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Collateral Actions
            if (c.status == 'AWAITING_COLLATERAL') ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightPrimary,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                      icon: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
                      label: Text(
                        l10nPick(context, fa: 'تودیع وثیقه نقدی', en: 'Post Cash Collateral', ar: 'توديع نقدي', zh: '质押现金'),
                        style: TextStyle(fontSize: 11.sp, color: Colors.white),
                      ),
                      onPressed: () => _confirm(
                        l10nPick(context, fa: 'تودیع وثیقه نقدی', en: 'Post Cash Collateral', ar: 'توديع نقدي', zh: '质押现金'),
                        l10nPick(context, fa: 'قفل وجه نقد از کیف پول به‌عنوان وثیقه تضمین بازپرداخت؟', en: 'Lock cash from your wallet as collateral?', ar: 'تجميد الرصيد كضمان؟', zh: '从钱包中锁定资金作为还款担保？'),
                        () => controller.postCashCollateral(c.id, c.requestedAmount, 'IRR'),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4338CA),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                      icon: const Icon(Icons.currency_bitcoin, color: Colors.white, size: 18),
                      label: Text(
                        l10nPick(context, fa: 'توثیق رمزارز', en: 'Post Crypto', ar: 'توديع كريبتو', zh: '质押加密币'),
                        style: TextStyle(fontSize: 11.sp, color: Colors.white),
                      ),
                      onPressed: () => _confirm(
                        l10nPick(context, fa: 'توثیق رمزارز', en: 'Post Crypto', ar: 'توديع كريبتو', zh: '质押加密币'),
                        l10nPick(context, fa: 'قفل معادل ارزی USDT از والت برای پوشش وثیقه با پایش LTV؟', en: 'Lock USDT equivalent as monitored LTV collateral?', ar: 'قفل عملات رقمية كضمان؟', zh: '锁定等额USDT作为LTV监测抵押？'),
                        () => controller.postCryptoCollateral(c.id, c.requestedAmount, 'USDT'),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Signing Action
            if (c.status == 'AWAITING_SIGNING') ...[
              SizedBox(height: 12.h),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                icon: const Icon(Icons.draw_rounded, color: Colors.white),
                label: Text(
                  l10nPick(context, fa: 'امضای الکترونیک قرارداد', en: 'Sign Digital Contract', ar: 'توقيع العقد إلكترونياً', zh: '电子签署合同'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                onPressed: () => _confirm(
                  l10nPick(context, fa: 'امضای قرارداد', en: 'Sign Contract', ar: 'توقيع العقد', zh: '签署合同'),
                  l10nPick(context, fa: 'قرارداد دیجیتال وام با گواهی الکترونیک امضا شود؟', en: 'Sign digital loan contract with digital certificate?', ar: 'توقيع العقد الرقمي الآن؟', zh: '使用数字证书签署贷款电子合同？'),
                  () => controller.signContract(c.id),
                ),
              ),
            ],

            // Installment Schedule
            if (c.installments.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10nPick(context, fa: 'جدول اقساط و بازپرداخت', en: 'Repayment Schedule', ar: 'جدول الأقساط', zh: '还款计划表'),
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp),
                        ),
                        if (c.status == 'ACTIVE')
                          TextButton(
                            onPressed: () => _confirm(
                              l10nPick(context, fa: 'تسویه زودهنگام', en: 'Early Repayment', ar: 'السداد المبكر', zh: '提前结清'),
                              l10nPick(context, fa: 'آیا مایل به پرداخت یکجای اصل باقیمانده با معافیت از سود آینده هستید؟', en: 'Pay remaining principal with future interest waived?', ar: 'سداد كامل المبلغ المتبقي مع الإعفاء من الفوائد؟', zh: '一次性结清剩余本金并减免后续利息？'),
                              () => controller.earlyRepayment(c.id),
                            ),
                            child: Text(
                              l10nPick(context, fa: 'تسویه پیش از موعد', en: 'Early Payoff', ar: 'تسوية مبكرة', zh: '提前结清'),
                              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF059669), fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                    const Divider(height: 16),
                    ...c.installments.map((inst) => _installmentRow(context, c.id, inst)),
                  ],
                ),
              ),
            ],

            // Cancel application option
            if (['DRAFT', 'OFFERED', 'AWAITING_COLLATERAL', 'AWAITING_SIGNING'].contains(c.status)) ...[
              SizedBox(height: 14.h),
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.grey),
                  onPressed: () => _confirm(
                    l10nPick(context, fa: 'لغو پرونده وام', en: 'Cancel Application', ar: 'إلغاء الطلب', zh: '取消申请'),
                    l10nPick(context, fa: 'آیا از لغو این پرونده و آزادسازی هرگونه وثیقه اطمینان دارید؟', en: 'Cancel this application and release collateral?', ar: 'هل أنت متأكد من إلغاء الملف؟', zh: '确定取消此申请并释放抵押？'),
                    () => controller.cancelCase(c.id),
                  ),
                  label: Text(
                    l10nPick(context, fa: 'انصراف و لغو این درخواست', en: 'Cancel Application', ar: 'إلغاء هذا الطلب', zh: '放弃并取消此申请'),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _installmentRow(BuildContext context, int caseId, LoanInstallmentModel inst) {
    final isPaid = inst.isPaid;
    final isOverdue = inst.isOverdue;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isPaid
                    ? Icons.check_circle_rounded
                    : (isOverdue ? Icons.error_rounded : Icons.pending_rounded),
                size: 18.sp,
                color: isPaid
                    ? const Color(0xFF059669)
                    : (isOverdue ? const Color(0xFFDC2626) : Colors.grey),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10nPick(context, fa: 'قسط', en: 'Inst.', ar: 'قسط', zh: '期')} ${inst.installmentNo}',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${inst.amount.toInt()} ریال',
                    style: TextStyle(fontSize: 10.5.sp, color: AppColors.lightTextSecondary),
                  ),
                ],
              ),
            ],
          ),
          if (!isPaid)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isOverdue ? const Color(0xFFDC2626) : AppColors.lightPrimary,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              ),
              onPressed: () => _confirm(
                l10nPick(context, fa: 'پرداخت قسط', en: 'Pay Installment', ar: 'سداد القسط', zh: '支付分期'),
                l10nPick(context, fa: 'مبلغ قسط از موجودی کیف پول شما کسر شود؟', en: 'Deduct installment from wallet balance?', ar: 'خصم القسط من المحفظة؟', zh: '从钱包余额中扣缴此期还款？'),
                () => controller.payInstallment(caseId, inst.id),
              ),
              child: Text(
                l10nPick(context, fa: 'پرداخت قسط', en: 'Pay', ar: 'سداد', zh: '支付'),
                style: TextStyle(fontSize: 11.sp, color: Colors.white),
              ),
            )
          else
            Text(
              l10nPick(context, fa: 'پرداخت‌شده', en: 'Paid', ar: 'مسدد', zh: '已支付'),
              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF059669), fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }
}
