import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/financial_service_unavailable_banner.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/loan_controller.dart';
import '../models/loan_models.dart';
import 'loan_application_screen.dart';
import 'loan_detail_screen.dart';

/// Screen for tracking active and historical loan cases, with status timelines
/// and installment repayment controls.
class LoanTrackingScreen extends StatefulWidget {
  const LoanTrackingScreen({super.key});

  @override
  State<LoanTrackingScreen> createState() => _LoanTrackingScreenState();
}

class _LoanTrackingScreenState extends State<LoanTrackingScreen> {
  final LoanController controller = Get.isRegistered<LoanController>()
      ? Get.find<LoanController>()
      : Get.put(LoanController());

  @override
  void initState() {
    super.initState();
    controller.fetchMyCases();
  }

  String _statusLabel(BuildContext context, String status) {
    switch (status) {
      case 'DRAFT':
        return l10nPick(context, fa: 'پیش‌نویس اولیه', en: 'Draft', ar: 'مسودة', zh: '草稿');
      case 'UNDER_ASSESSMENT':
        return l10nPick(context, fa: 'در حال سنجش اعتبار', en: 'Under Scoring', ar: 'قيد التقييم', zh: '审核评分中');
      case 'COMPLEMENT_REQUIRED':
        return l10nPick(context, fa: 'نیاز به تکمیل مدارک', en: 'Docs Required', ar: 'مطلوب مستندات', zh: '待补充资料');
      case 'OFFERED':
        return l10nPick(context, fa: 'پیشنهاد صادر شد', en: 'Offered', ar: 'تم إصدار العرض', zh: '已出方案');
      case 'AWAITING_COLLATERAL':
        return l10nPick(context, fa: 'در انتظار وثیقه', en: 'Awaiting Collateral', ar: 'بانتظار الضمان', zh: '待交抵押');
      case 'AWAITING_SIGNING':
        return l10nPick(context, fa: 'در انتظار امضا', en: 'Awaiting Signature', ar: 'بانتظار التوقيع', zh: '待电子签署');
      case 'DISBURSED':
        return l10nPick(context, fa: 'پرداخت به والت', en: 'Disbursed', ar: 'تم الصرف', zh: '已放款');
      case 'ACTIVE':
        return l10nPick(context, fa: 'در حال بازپرداخت', en: 'Active Repayment', ar: 'سداد جاري', zh: '还款中');
      case 'OVERDUE':
        return l10nPick(context, fa: 'قسط معوق', en: 'Overdue', ar: 'متأخر', zh: '已逾期');
      case 'COMPLETED':
        return l10nPick(context, fa: 'تسویه کامل', en: 'Completed', ar: 'تمت التسوية', zh: '已结清');
      case 'REJECTED':
        return l10nPick(context, fa: 'رد شد', en: 'Rejected', ar: 'مرفوض', zh: '已拒绝');
      case 'CANCELLED':
        return l10nPick(context, fa: 'لغوشده', en: 'Cancelled', ar: 'ملغي', zh: '已取消');
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return const Color(0xFF059669);
      case 'ACTIVE':
      case 'DISBURSED':
        return const Color(0xFF2563EB);
      case 'OFFERED':
      case 'AWAITING_COLLATERAL':
      case 'AWAITING_SIGNING':
        return const Color(0xFFD97706);
      case 'OVERDUE':
      case 'REJECTED':
        return const Color(0xFFDC2626);
      default:
        return Colors.blueGrey;
    }
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
              fa: 'پیگیری پرونده‌های تسهیلات',
              en: 'Loan Application Tracking',
              ar: 'متابعة ملفات التسهيلات',
              zh: '贷款审批与还款追踪',
            ),
          ),
        ),
      ),
      body: Obx(() {
        final cases = controller.myCases;
        final isLoading = controller.isLoadingCases.value;

        return RefreshIndicator(
          onRefresh: controller.fetchMyCases,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            children: [
              // Notice banner if backend has no active cases or endpoint pending
              FinancialServiceUnavailableBanner(
                serviceNameFa: 'تسهیلات و اعتبارات',
                serviceNameEn: 'Loan & Credit',
                serviceNameAr: 'التسهيلات والقروض',
                serviceNameZh: '信贷融通',
                isCompact: true,
                onRetry: controller.fetchMyCases,
              ),

              SizedBox(height: 10.h),

              if (isLoading && cases.isEmpty) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ] else if (cases.isEmpty) ...[
                Container(
                  margin: EdgeInsets.only(top: 20.h),
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        size: 54.sp,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        l10nPick(
                          context,
                          fa: 'پرونده تسهیلاتی فعالی یافت نشد',
                          en: 'No active loan application found',
                          ar: 'لا توجد طلبات قروض نشطة',
                          zh: '暂无进行中的贷款申请',
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        l10nPick(
                          context,
                          fa: 'شما در حال حاضر هیچ درخواست باز یا اقساط در حال پرداختی در سامانه ندارید.',
                          en: 'You currently have no open requests or pending installments in the system.',
                          ar: 'ليس لديك أي طلبات نشطة أو أقساط معلقة حالياً.',
                          zh: '您当前在系统中没有待处理的申请或分期账单。',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                      SizedBox(height: 18.h),
                      CommonButton(
                        height: 42,
                        text: l10nPick(
                          context,
                          fa: 'ثبت اولین درخواست وام',
                          en: 'Submit First Application',
                          ar: 'تقديم طلب جديد',
                          zh: '立即申请贷款',
                        ),
                        backgroundColor: AppColors.lightPrimary,
                        onPressed: () => Get.to(() => const LoanApplicationScreen()),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ...cases.map((loanCase) => _buildCaseCard(context, loanCase)),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCaseCard(BuildContext context, LoanCaseModel c) {
    final statusColor = _statusColor(c.status);
    final statusText = _statusLabel(context, c.status);

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
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
                '${l10nPick(context, fa: 'پرونده', en: 'Case', ar: 'ملف', zh: '案号')}: ${c.caseNo}',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10nPick(context, fa: 'مبلغ مصوب / درخواستی:', en: 'Amount:', ar: 'المبلغ:', zh: '金额：'),
                style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary),
              ),
              Text(
                '${c.requestedAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ' +
                    l10nPick(context, fa: 'ریال', en: 'IRR', ar: 'ريال', zh: '里亚尔'),
                style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10nPick(context, fa: 'مدت بازپرداخت:', en: 'Tenure:', ar: 'المدة:', zh: '期数：'),
                style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary),
              ),
              Text(
                '${c.tenureMonths} ' + l10nPick(context, fa: 'ماه', en: 'Months', ar: 'شهر', zh: '个月'),
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.lightPrimary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: () => Get.to(() => LoanDetailScreen(caseId: c.id)),
              icon: Icon(Icons.arrow_forward_rounded, size: 16.sp, color: AppColors.lightPrimary),
              label: Text(
                l10nPick(
                  context,
                  fa: 'مشاهده جزئیات و پرداخت اقساط',
                  en: 'View Details & Repay',
                  ar: 'عرض التفاصيل والسداد',
                  zh: '查看详情与还款',
                ),
                style: const TextStyle(color: AppColors.lightPrimary, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
