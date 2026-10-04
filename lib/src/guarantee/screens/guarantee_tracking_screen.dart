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

import '../controllers/guarantee_controller.dart';
import '../models/guarantee_models.dart';
import '../widgets/guarantee_status_stepper.dart';
import 'guarantee_application_screen.dart';
import 'guarantee_detail_screen.dart';

/// Screen for tracking active and historical bank guarantee applications.
class GuaranteeTrackingScreen extends StatefulWidget {
  const GuaranteeTrackingScreen({super.key});

  @override
  State<GuaranteeTrackingScreen> createState() => _GuaranteeTrackingScreenState();
}

class _GuaranteeTrackingScreenState extends State<GuaranteeTrackingScreen> {
  final GuaranteeController controller = Get.isRegistered<GuaranteeController>()
      ? Get.find<GuaranteeController>()
      : Get.put(GuaranteeController());

  @override
  void initState() {
    super.initState();
    controller.fetchMyCases();
  }

  String _statusLabel(BuildContext context, String status) {
    switch (status) {
      case 'DRAFT': return l10nPick(context, fa: 'پیش‌نویس پرونده', en: 'Draft', ar: 'مسودة', zh: '草稿');
      case 'UNDER_REVIEW': return l10nPick(context, fa: 'در حال بررسی بانک', en: 'Under Bank Review', ar: 'قيد المراجعة', zh: '银行审查中');
      case 'COMPLEMENT_REQUIRED': return l10nPick(context, fa: 'نیاز به تکمیل مدارک', en: 'Docs Required', ar: 'مطلوب مستندات', zh: '待补交资料');
      case 'MARGIN_PENDING': return l10nPick(context, fa: 'در انتظار واریز وجه التزام', en: 'Margin Deposit Pending', ar: 'بانتظار التأمين', zh: '待交保证金');
      case 'IN_ISSUANCE': return l10nPick(context, fa: 'در حال صدور سپام', en: 'Issuing in SEPAM', ar: 'قيد الإصدار', zh: '正在生成SEPAM保函');
      case 'ISSUED': return l10nPick(context, fa: 'صادر شد (فعال)', en: 'Issued (Active)', ar: 'تم الإصدار', zh: '已正式开立');
      case 'CLAIMED': return l10nPick(context, fa: 'مطالبه‌شده توسط ذینفع', en: 'Claimed by Beneficiary', ar: 'تمت المطالبة', zh: '受益人已索赔');
      case 'EXPIRED': return l10nPick(context, fa: 'منقضی‌شده', en: 'Expired', ar: 'منتهي الصلاحية', zh: '已到期');
      case 'RELEASED': return l10nPick(context, fa: 'تضامین آزاد شد (تسویه)', en: 'Margin Released', ar: 'تم تحرير الضمان', zh: '担保已解质');
      case 'REJECTED': return l10nPick(context, fa: 'رد شد', en: 'Rejected', ar: 'مرفوض', zh: '已拒绝');
      case 'CANCELLED': return l10nPick(context, fa: 'لغوشده', en: 'Cancelled', ar: 'ملغي', zh: '已取消');
      default: return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'RELEASED': return AppColors.success;
      case 'ISSUED': return const Color(0xFF0D9488);
      case 'CLAIMED': case 'REJECTED': return AppColors.error;
      case 'MARGIN_PENDING': case 'IN_ISSUANCE': return AppColors.warning;
      case 'UNDER_REVIEW': case 'COMPLEMENT_REQUIRED': return AppColors.info;
      default: return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'پیگیری پرونده‌های ضمانت‌نامه',
              en: 'Guarantee Case Tracking',
              ar: 'متابعة خطابات الضمان',
              zh: '保函开立进度追踪',
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
                serviceNameFa: 'ضمانت‌نامه و LC',
                serviceNameEn: 'Guarantee & LC',
                serviceNameAr: 'خطابات الضمان والاعتمادات',
                serviceNameZh: '保函与信用证',
                isCompact: true,
                onRetry: controller.fetchMyCases,
              ),

              SizedBox(height: AppSpacing.sm.h),

              if (isLoading && cases.isEmpty) ...[
                const GuaranteeSkeletonLoader(itemCount: 3),
              ] else if (cases.isEmpty) ...[
                Padding(
                  padding: EdgeInsetsDirectional.only(top: AppSpacing.xxl.h),
                  child: EcardoEmptyState(
                    iconData: Icons.shield_outlined,
                    title: l10nPick(
                      context,
                      fa: 'پرونده ضمانت‌نامه فعالی یافت نشد',
                      en: 'No active guarantee application found',
                      ar: 'لا توجد طلبات ضمان نشطة',
                      zh: '暂无进行中的保函申请',
                    ),
                    description: l10nPick(
                      context,
                      fa: 'پرونده‌های صدور، تودیع وجه التزام و استعلام سپام شما در این کارتابل نمایش داده می‌شوند.',
                      en: 'Your guarantee issuance, margin deposits, and SEPAM status will appear here.',
                      ar: 'تظهر هنا ملفات الضمان وتأميناتها وسجلات سبام الخاصة بك.',
                      zh: '您的保函申请、保证金质押及央行SEPAM状态将在此处集中展现。',
                    ),
                    primaryActionLabel: l10nPick(
                      context,
                      fa: 'ثبت درخواست ضمانت‌نامه جدید',
                      en: 'New Guarantee Request',
                      ar: 'تقديم طلب ضمان جديد',
                      zh: '提交新保函申请',
                    ),
                    onPrimaryAction: () {
                      HapticFeedback.lightImpact();
                      Get.to(() => const GuaranteeApplicationScreen());
                    },
                  ),
                ),
              ] else ...[
                ...cases.map((c) => _buildCaseCard(context, c, isDark)),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCaseCard(BuildContext context, GuaranteeCaseModel c, bool isDark) {
    final statusColor = _statusColor(c.status);
    final statusText = _statusLabel(context, c.status);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.to(() => GuaranteeDetailScreen(caseId: c.id));
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
                  c.instrument?.name ?? '',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w800,
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
            SizedBox(height: AppSpacing.xs.h),
            Text(
              '${l10nPick(context, fa: 'شماره پرونده', en: 'Case No.', ar: 'رقم الملف', zh: '案号')}: ${c.caseNo}',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            Divider(
              height: 18,
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10nPick(context, fa: 'ذینفع', en: 'Beneficiary', ar: 'المستفيد', zh: '受益人'),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      ),
                    ),
                    Text(
                      c.beneficiaryName,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10nPick(context, fa: 'مبلغ ضمانت', en: 'Amount', ar: 'المبلغ', zh: '金额'),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      ),
                    ),
                    Text(
                      '${c.amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ${c.currency}',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0D9488),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
