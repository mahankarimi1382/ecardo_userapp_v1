import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/common/widgets/financial_service_unavailable_banner.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/loan_controller.dart';
import '../models/loan_models.dart';
import '../widgets/loan_status_stepper.dart';
import 'loan_application_screen.dart';
import 'loan_detail_screen.dart';

/// Screen for tracking active and historical loan applications.
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
      case 'DRAFT': return l10nPick(context, fa: 'پیش‌نویس پرونده', en: 'Draft', ar: 'مسودة', zh: '草稿');
      case 'UNDER_ASSESSMENT': return l10nPick(context, fa: 'در حال ارزیابی اعتباری', en: 'Under Assessment', ar: 'قيد التقييم', zh: '信用评估中');
      case 'COMPLEMENT_REQUIRED': return l10nPick(context, fa: 'نیاز به تکمیل مدارک', en: 'Docs Required', ar: 'مطلوب مستندات', zh: '待补充资料');
      case 'OFFERED': return l10nPick(context, fa: 'پیشنهاد صادر شد', en: 'Offer Issued', ar: 'تم إصدار العرض', zh: '已出具方案');
      case 'AWAITING_COLLATERAL': return l10nPick(context, fa: 'در انتظار تودیع وثیقه', en: 'Awaiting Collateral', ar: 'بانتظار الضمان', zh: '待交抵押');
      case 'AWAITING_SIGNING': return l10nPick(context, fa: 'در انتظار امضای دیجیتال', en: 'Awaiting Signing', ar: 'بانتظار التوقيع', zh: '待电子签署');
      case 'DISBURSED': return l10nPick(context, fa: 'تسهیلات واریز شد', en: 'Disbursed', ar: 'تم الصرف', zh: '已发放贷款');
      case 'ACTIVE': return l10nPick(context, fa: 'در حال بازپرداخت اقساط', en: 'Active Repayment', ar: 'سداد جاري', zh: '还款中');
      case 'OVERDUE': return l10nPick(context, fa: 'دارای قسط معوق', en: 'Overdue', ar: 'متأخر', zh: '已逾期');
      case 'DEFAULTED': return l10nPick(context, fa: 'نکول تسهیلات', en: 'Defaulted', ar: 'تعثر', zh: '贷款违约');
      case 'COMPLETED': return l10nPick(context, fa: 'تسویه کامل', en: 'Completed', ar: 'تمت التسوية', zh: '已结清');
      case 'REJECTED': return l10nPick(context, fa: 'رد شد', en: 'Rejected', ar: 'مرفوض', zh: '已拒绝');
      case 'CANCELLED': return l10nPick(context, fa: 'لغوشده', en: 'Cancelled', ar: 'ملغي', zh: '已取消');
      default: return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED': return AppColors.success;
      case 'ACTIVE':
      case 'DISBURSED': return AppColors.lightPrimary;
      case 'OFFERED':
      case 'AWAITING_COLLATERAL':
      case 'AWAITING_SIGNING': return AppColors.warning;
      case 'OVERDUE':
      case 'REJECTED': return AppColors.error;
      default: return Colors.blueGrey;
    }
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
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.page.w, vertical: AppSpacing.md.h),
            children: [
              FinancialServiceUnavailableBanner(
                serviceNameFa: 'تسهیلات و اعتبارات',
                serviceNameEn: 'Loan & Credit',
                serviceNameAr: 'التسهيلات والقروض',
                serviceNameZh: '信贷融通',
                isCompact: true,
                onRetry: controller.fetchMyCases,
              ),

              SizedBox(height: AppSpacing.sm.h),

              if (isLoading && cases.isEmpty) ...[
                const LoanSkeletonLoader(itemCount: 3),
              ] else if (cases.isEmpty) ...[
                Padding(
                  padding: EdgeInsetsDirectional.only(top: AppSpacing.xxl.h),
                  child: EcardoEmptyState(
                    iconData: Icons.folder_open_rounded,
                    title: l10nPick(
                      context,
                      fa: 'پرونده تسهیلاتی فعالی یافت نشد',
                      en: 'No active loan application found',
                      ar: 'لا توجد طلبات قروض نشطة',
                      zh: '暂无进行中的贷款申请',
                    ),
                    description: l10nPick(
                      context,
                      fa: 'شما در حال حاضر هیچ درخواست باز یا اقساط در حال پرداختی در سامانه ندارید.',
                      en: 'You currently have no open requests or pending installments in the system.',
                      ar: 'ليس لديك أي طلبات نشطة أو أقساط معلقة حالياً.',
                      zh: '您当前在系统中没有待处理的申请或分期账单。',
                    ),
                    primaryActionLabel: l10nPick(
                      context,
                      fa: 'ثبت اولین درخواست وام',
                      en: 'Submit First Application',
                      ar: 'تقديم طلب جديد',
                      zh: '立即申请贷款',
                    ),
                    onPrimaryAction: () {
                      HapticFeedback.lightImpact();
                      Get.to(() => const LoanApplicationScreen());
                    },
                  ),
                ),
              ] else ...[
                ...cases.map((loanCase) => _buildCaseCard(context, loanCase, isDark, primaryAccent)),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCaseCard(
    BuildContext context,
    LoanCaseModel c,
    bool isDark,
    Color primaryAccent,
  ) {
    final statusColor = _statusColor(c.status);
    final statusText = _statusLabel(context, c.status);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.to(() => LoanDetailScreen(caseId: c.id));
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
      child: Container(
        margin: EdgeInsetsDirectional.only(bottom: AppSpacing.md.h),
        padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
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
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Container(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    statusText,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              height: 18,
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10nPick(context, fa: 'مبلغ مصوب / درخواستی:', en: 'Amount:', ar: 'المبلغ:', zh: '金额：'),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                Text(
                  '${c.requestedAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ${l10nPick(context, fa: 'ریال', en: 'IRR', ar: 'ريال', zh: '里亚尔')}',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w900,
                    color: primaryAccent,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10nPick(context, fa: 'مدت بازپرداخت:', en: 'Tenure:', ar: 'المدة:', zh: '期数：'),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                Text(
                  '${c.tenureMonths} ${l10nPick(context, fa: 'ماه', en: 'Months', ar: 'شهر', zh: '个月')}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md.h),
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Get.to(() => LoanDetailScreen(caseId: c.id));
                },
                icon: Icon(Icons.arrow_forward_rounded, size: 16.sp, color: primaryAccent),
                label: Text(
                  l10nPick(
                    context,
                    fa: 'مشاهده جزئیات و پرداخت اقساط',
                    en: 'View Details & Repay',
                    ar: 'عرض التفاصيل والسداد',
                    zh: '查看详情与还款',
                  ),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: primaryAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
