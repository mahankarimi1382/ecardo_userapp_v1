import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/financial_service_unavailable_banner.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/guarantee_controller.dart';
import '../models/guarantee_models.dart';
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
      case 'RELEASED': return const Color(0xFF059669);
      case 'ISSUED': return const Color(0xFF0D9488);
      case 'CLAIMED': case 'REJECTED': return const Color(0xFFDC2626);
      case 'MARGIN_PENDING': case 'IN_ISSUANCE': return const Color(0xFFD97706);
      case 'UNDER_REVIEW': case 'COMPLEMENT_REQUIRED': return const Color(0xFF2563EB);
      default: return Colors.blueGrey;
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            children: [
              FinancialServiceUnavailableBanner(
                serviceNameFa: 'ضمانت‌نامه و LC',
                serviceNameEn: 'Guarantee & LC',
                serviceNameAr: 'خطابات الضمان والاعتمادات',
                serviceNameZh: '保函与信用证',
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
                      Icon(Icons.shield_outlined, size: 54.sp, color: Colors.grey.shade400),
                      SizedBox(height: 12.h),
                      Text(
                        l10nPick(
                          context,
                          fa: 'پرونده ضمانت‌نامه فعالی یافت نشد',
                          en: 'No active guarantee application found',
                          ar: 'لا توجد طلبات ضمان نشطة',
                          zh: '暂无进行中的保函申请',
                        ),
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        l10nPick(
                          context,
                          fa: 'پرونده‌های صدور، تودیع وجه التزام و استعلام سپام شما در این کارتابل نمایش داده می‌شوند.',
                          en: 'Your guarantee issuance, margin deposits, and SEPAM status will appear here.',
                          ar: 'تظهر هنا ملفات الضمان وتأميناتها وسجلات سبام الخاصة بك.',
                          zh: '您的保函申请、保证金质押及央行SEPAM状态将在此处集中展现。',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.5.sp, color: AppColors.lightTextSecondary),
                      ),
                      SizedBox(height: 18.h),
                      CommonButton(
                        height: 42,
                        text: l10nPick(
                          context,
                          fa: 'ثبت درخواست ضمانت‌نامه جدید',
                          en: 'New Guarantee Request',
                          ar: 'تقديم طلب ضمان جديد',
                          zh: '提交新保函申请',
                        ),
                        backgroundColor: const Color(0xFF0D9488),
                        onPressed: () => Get.to(() => const GuaranteeApplicationScreen()),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ...cases.map((c) => _buildCaseCard(context, c)),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCaseCard(BuildContext context, GuaranteeCaseModel c) {
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
                '${c.instrument.name}',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
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
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: statusColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            '${l10nPick(context, fa: 'شماره پرونده', en: 'Case No.', ar: 'رقم الملف', zh: '案号')}: ${c.caseNo}',
            style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary),
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10nPick(context, fa: 'ذینفع / کارفرما:', en: 'Beneficiary:', ar: 'المستفيد:', zh: '受益人：'),
                style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary),
              ),
              Text(
                c.beneficiaryName,
                style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10nPick(context, fa: 'مبلغ اسمی:', en: 'Face Amount:', ar: 'المبلغ:', zh: '保函面额：'),
                style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary),
              ),
              Text(
                '${c.amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ${c.currency}',
                style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0D9488)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: () => Get.to(() => GuaranteeDetailScreen(caseId: c.id)),
              icon: Icon(Icons.arrow_forward_rounded, size: 16.sp, color: const Color(0xFF0D9488)),
              label: Text(
                l10nPick(
                  context,
                  fa: 'جزئیات، واریز وجه التزام و اسناد',
                  en: 'Details, Margin & Documents',
                  ar: 'التفاصيل وتوديع التأمين والوثائق',
                  zh: '查看详情、补交质押与电子凭证',
                ),
                style: const TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
