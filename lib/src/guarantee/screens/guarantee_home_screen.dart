import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/financial_service_unavailable_banner.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/guarantee_controller.dart';
import '../models/guarantee_models.dart';
import 'guarantee_intro_screen.dart';
import 'guarantee_application_screen.dart';
import 'guarantee_tracking_screen.dart';
import 'guarantee_detail_screen.dart';

/// Main hub for the Bank Guarantee & LC service.
class GuaranteeHomeScreen extends StatefulWidget {
  const GuaranteeHomeScreen({super.key});

  @override
  State<GuaranteeHomeScreen> createState() => _GuaranteeHomeScreenState();
}

class _GuaranteeHomeScreenState extends State<GuaranteeHomeScreen> {
  late final GuaranteeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<GuaranteeController>()
        ? Get.find<GuaranteeController>()
        : Get.put(GuaranteeController());
    controller.fetchInstruments();
    controller.fetchMyCases();
  }

  String _statusFa(String status) {
    switch (status) {
      case 'DRAFT': return 'پیش‌نویس';
      case 'UNDER_REVIEW': return 'در حال بررسی';
      case 'COMPLEMENT_REQUIRED': return 'نقص مدارک';
      case 'MARGIN_PENDING': return 'در انتظار تودیع';
      case 'IN_ISSUANCE': return 'در حال صدور';
      case 'ISSUED': return 'صادر شد (فعال)';
      case 'CLAIMED': return 'مطالبه‌شده';
      case 'EXPIRED': return 'منقضی';
      case 'RELEASED': return 'تضامین آزاد شد';
      case 'REJECTED': return 'رد شد';
      case 'CANCELLED': return 'لغو';
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
              fa: 'ضمانت‌نامه و اعتبارات اسنادی',
              en: 'Guarantee & LC',
              ar: 'خطابات الضمان والاعتمادات',
              zh: '保函与信用证',
            ),
            rightSideWidget: Padding(
              padding: EdgeInsetsDirectional.only(end: 16.w),
              child: IconButton(
                icon: const Icon(Icons.history_rounded),
                tooltip: l10nPick(context, fa: 'پیگیری پرونده‌ها', en: 'Tracking', ar: 'المتابعة', zh: '追踪'),
                onPressed: () => Get.to(() => const GuaranteeTrackingScreen()),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingInstruments.value && controller.instruments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchInstruments();
            await controller.fetchMyCases();
          },
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            children: [
              // Notice banner if backend is pending / returning empty
              if (controller.hasBackendError.value || controller.instruments.isEmpty)
                FinancialServiceUnavailableBanner(
                  serviceNameFa: 'ضمانت‌نامه و سامانه سپام',
                  serviceNameEn: 'Bank Guarantee & SEPAM',
                  serviceNameAr: 'خطابات الضمان ونظام سبام',
                  serviceNameZh: '央行SEPAM保函系统',
                  onRetry: () {
                    controller.fetchInstruments();
                    controller.fetchMyCases();
                  },
                ),

              SizedBox(height: 6.h),

              // Action tiles
              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      context,
                      icon: Icons.shield_outlined,
                      titleFa: 'راهنما و انواع ابزار',
                      titleEn: 'Guide & Tools',
                      color: const Color(0xFF0D9488),
                      onTap: () => Get.to(() => const GuaranteeIntroScreen()),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildActionTile(
                      context,
                      icon: Icons.add_moderator_rounded,
                      titleFa: 'صدور ضمانت‌نامه',
                      titleEn: 'Issue Guarantee',
                      color: AppColors.lightPrimary,
                      onTap: () => Get.to(() => const GuaranteeApplicationScreen()),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildActionTile(
                      context,
                      icon: Icons.assignment_outlined,
                      titleFa: 'پیگیری و کارتابل',
                      titleEn: 'Track Cases',
                      color: const Color(0xFF2563EB),
                      onTap: () => Get.to(() => const GuaranteeTrackingScreen()),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Instruments Catalog
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10nPick(
                      context,
                      fa: 'ابزارهای ضمانتی مورد تأیید بانک',
                      en: 'Approved Guarantee Instruments',
                      ar: 'أدوات الضمان المعتمدة',
                      zh: '银行批准的保函种类',
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => const GuaranteeIntroScreen()),
                    child: Text(
                      l10nPick(context, fa: 'مشاهده نرخ‌ها', en: 'Rates', ar: 'الأسعار', zh: '费率'),
                      style: TextStyle(fontSize: 11.5.sp, color: AppColors.lightPrimary),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),

              if (controller.instruments.isEmpty)
                Container(
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.security_update_warning_rounded, size: 40.sp, color: Colors.grey.shade400),
                      SizedBox(height: 8.h),
                      Text(
                        l10nPick(
                          context,
                          fa: 'کاتالوگ ابزارها در حال اتصال به وب‌سرویس بانکی است',
                          en: 'Instrument catalog awaiting banking web-service',
                          ar: 'بانتظار مزامنة أدوات الضمان المصرفية',
                          zh: '正在等待银行Web服务同步保函目录',
                        ),
                        style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10nPick(
                          context,
                          fa: 'می‌توانید پیش‌نویس درخواست انواع ضمانت‌نامه را به صورت محلی ثبت فرمایید.',
                          en: 'You can draft guarantee applications via the online form.',
                          ar: 'يمكنك تقديم مسودة الضمان عبر النموذج الإلكتروني.',
                          zh: '您可以通过在线表单直接起草各类型保函申请。',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary),
                      ),
                    ],
                  ),
                )
              else
                ...controller.instruments.map((inst) => _buildInstrumentItem(context, inst)),

              SizedBox(height: 20.h),

              // Recent Cases
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10nPick(
                      context,
                      fa: 'پرونده‌های فعال من',
                      en: 'My Active Cases',
                      ar: 'ملفاتي النشطة',
                      zh: '我的保函记录',
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  if (controller.myCases.isNotEmpty)
                    TextButton(
                      onPressed: () => Get.to(() => const GuaranteeTrackingScreen()),
                      child: Text(
                        l10nPick(context, fa: 'مشاهده همه', en: 'View All', ar: 'الكل', zh: '全部'),
                        style: TextStyle(fontSize: 11.5.sp, color: AppColors.lightPrimary),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 6.h),

              if (controller.myCases.isEmpty)
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.folder_shared_outlined, size: 28.sp, color: Colors.grey.shade400),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            fa: 'پرونده ضمانت‌نامه یا اعتبار اسنادی بازی ثبت نشده است.',
                            en: 'No open guarantee or LC recorded for your account.',
                            ar: 'لا توجد خطابات ضمان أو اعتمادات مسجلة لحسابك.',
                            zh: '您当前没有任何未结清的保函或信用证申请。',
                          ),
                          style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...controller.myCases.take(3).map((c) => _buildCaseItem(context, c)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String titleFa,
    required String titleEn,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              l10nPick(context, fa: titleFa, en: titleEn),
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstrumentItem(BuildContext context, GuaranteeInstrumentModel inst) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.shield_rounded, color: const Color(0xFF0D9488), size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(inst.name, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800)),
                SizedBox(height: 3.h),
                Text(
                  l10nPick(
                    context,
                    fa: 'وجه التزام: ${inst.marginPct}٪ · کارمزد: ${inst.feePct}٪',
                    en: 'Margin: ${inst.marginPct}% · Fee: ${inst.feePct}%',
                    ar: 'التأمين: ${inst.marginPct}٪ · الرسوم: ${inst.feePct}٪',
                    zh: '保证金：${inst.marginPct}% · 开立费：${inst.feePct}%',
                  ),
                  style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            ),
            onPressed: () {
              controller.selectedInstrument.value = inst;
              Get.to(() => const GuaranteeApplicationScreen());
            },
            child: Text(
              l10nPick(context, fa: 'صدور', en: 'Apply', ar: 'طلب', zh: '申请'),
              style: TextStyle(fontSize: 11.5.sp, color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseItem(BuildContext context, GuaranteeCaseModel c) {
    final statusColor = _statusColor(c.status);

    return InkWell(
      onTap: () => Get.to(() => GuaranteeDetailScreen(caseId: c.id)),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${c.instrument.name} (${c.beneficiaryName})',
                    style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${c.amount.toInt()} ${c.currency}',
                    style: TextStyle(fontSize: 11.5.sp, color: AppColors.lightTextSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                _statusFa(c.status),
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: statusColor),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right, size: 20.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
