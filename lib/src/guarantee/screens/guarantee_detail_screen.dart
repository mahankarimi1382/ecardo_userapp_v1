import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';

import '../controllers/guarantee_controller.dart';
import '../models/guarantee_models.dart';
import '../widgets/guarantee_certificate_widget.dart';
import '../widgets/guarantee_status_stepper.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';

/// جزئیات پرونده ضمانت‌نامه و اعتبار اسنادی — Bank-Guarantee-Service-Flow.md
class GuaranteeDetailScreen extends StatefulWidget {
  final int caseId;
  const GuaranteeDetailScreen({super.key, required this.caseId});

  @override
  State<GuaranteeDetailScreen> createState() => _GuaranteeDetailScreenState();
}

class _GuaranteeDetailScreenState extends State<GuaranteeDetailScreen> {
  late final GuaranteeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<GuaranteeController>()
        ? Get.find<GuaranteeController>()
        : Get.put(GuaranteeController());
    final id = widget.caseId > 0 ? widget.caseId : (Get.arguments is int ? Get.arguments as int : 0);
    if (id > 0) {
      controller.fetchCase(id);
    }
  }

  String? _resolveApplicantName() {
    try {
      if (Get.isRegistered<HomeController>()) {
        final u = Get.find<HomeController>().userModel.value.data;
        final name = [u?.firstName, u?.lastName].where((s) => s != null && s.isNotEmpty).join(' ');
        if (name.isNotEmpty) return name;
      }
    } catch (_) {}
    return null;
  }

  String _statusFa(String status) {
    switch (status) {
      case 'DRAFT': return 'پیش‌نویس پرونده';
      case 'UNDER_REVIEW': return 'در حال بررسی';
      case 'COMPLEMENT_REQUIRED': return 'نیاز به تکمیل مدارک';
      case 'MARGIN_PENDING': return 'در انتظار تودیع وجه التزام';
      case 'IN_ISSUANCE': return 'در حال صدور بانک';
      case 'ISSUED': return 'صادر شد (فعال)';
      case 'CLAIMED': return 'مطالبه‌شده (فریز)';
      case 'EXPIRED': return 'منقضی (انتظار ۳۰ روزه)';
      case 'RELEASED': return 'تضامین آزاد شد';
      case 'REJECTED': return 'رد شد';
      case 'CANCELLED': return 'لغو';
      default: return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'RELEASED': return AppColors.success;
      case 'ISSUED': return const Color(0xFF0D9488);
      case 'CLAIMED': return AppColors.error;
      case 'REJECTED': case 'CANCELLED': return AppColors.grey;
      case 'MARGIN_PENDING': case 'IN_ISSUANCE': return AppColors.warning;
      case 'UNDER_REVIEW': case 'COMPLEMENT_REQUIRED': return AppColors.info;
      default: return Colors.blueGrey;
    }
  }

  void _confirm(String title, String message, Future<bool> Function() action) {
    final errTitle = l10nPick(context, en: 'Error', fa: 'خطا');
    final errBody = l10nPick(context, en: 'Action failed.', fa: 'عملیات ناموفق بود.');

    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r)),
      title: Text(title, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800)),
      content: Text(message, style: AppTextStyles.bodyMedium),
      actions: [
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.back();
          },
          child: Text(l10nPick(context, en: 'Cancel', fa: 'انصراف')),
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
            l10nPick(context, en: 'Confirm', fa: 'تأیید'),
            style: const TextStyle(color: AppColors.white),
          ),
        ),
      ],
    ));
  }

  void _showUploadDocDialog(GuaranteeCaseModel c) {
    String docType = 'base_contract';
    final fileRefCtrl = TextEditingController(text: '/docs/contract_scan.pdf');
    final successTitle = l10nPick(context, en: 'Uploaded', fa: 'بارگذاری شد');
    final successBody = l10nPick(context, en: 'Document attached to case.', fa: 'مدرک با موفقیت ضمیمه پرونده گردید.');

    Get.dialog(StatefulBuilder(
      builder: (ctx, setDlgState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r)),
        title: Text(
          l10nPick(ctx, en: 'Upload Document', fa: 'بارگذاری مدارک پرونده'),
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10nPick(ctx, en: 'Document Type:', fa: 'نوع مدرک الزامی:'), style: AppTextStyles.bodySmall),
            SizedBox(height: AppSpacing.xs.h),
            DropdownButton<String>(
              isExpanded: true,
              value: docType,
              items: [
                DropdownMenuItem(value: 'base_contract', child: Text(l10nPick(ctx, en: 'Base Contract / Tender Notice', fa: 'قرارداد پایه یا آگهی مناقصه'))),
                DropdownMenuItem(value: 'registration', child: Text(l10nPick(ctx, en: 'Company Registration / Articles', fa: 'مدارک ثبتی شرکت و اساسنامه'))),
                DropdownMenuItem(value: 'financials', child: Text(l10nPick(ctx, en: 'Financial Statements / Tax Balance', fa: 'صورت‌های مالی و تراز مالیاتی'))),
              ],
              onChanged: (v) => setDlgState(() => docType = v ?? 'base_contract'),
            ),
            SizedBox(height: AppSpacing.sm.h),
            TextField(
              controller: fileRefCtrl,
              decoration: InputDecoration(
                labelText: l10nPick(ctx, en: 'File name / reference', fa: 'نام یا شناسه فایل'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Get.back();
            },
            child: Text(l10nPick(ctx, en: 'Cancel', fa: 'انصراف')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
            ),
            onPressed: () async {
              HapticFeedback.lightImpact();
              Get.back();
              final ok = await controller.uploadDoc(c.id, docType, fileRefCtrl.text.trim());
              if (!mounted) return;
              if (ok) {
                Get.snackbar(
                  successTitle,
                  successBody,
                  backgroundColor: AppColors.success,
                  colorText: AppColors.white,
                );
              }
            },
            child: Text(l10nPick(ctx, en: 'Upload', fa: 'بارگذاری'), style: const TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    ));
  }

  void _showDepositDialog(GuaranteeCaseModel c) {
    String source = 'WALLET_FIAT';
    final marginPct = c.bankOffer?.marginPct ?? c.instrument?.marginPct ?? 10.0;
    final feePct = c.bankOffer?.feePct ?? c.instrument?.feePct ?? 1.0;
    final marginAmount = (c.amount * marginPct / 100.0).toStringAsFixed(2);
    final feeAmount = (c.amount * feePct / 100.0).toStringAsFixed(2);
    final depositSuccessTitle = l10nPick(context, en: 'Deposited', fa: 'تودیع شد');
    final depositSuccessBody = l10nPick(
      context,
      en: 'Margin locked in escrow — sent to bank for issuance.',
      fa: 'وجه التزام نزد پلتفرم حبس شد و پرونده به بانک صادرکننده ارسال گردید.',
    );

    Get.dialog(StatefulBuilder(
      builder: (ctx, setDlgState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r)),
        title: Text(
          l10nPick(ctx, en: 'Deposit Margin', fa: 'تودیع وجه التزام و کارمزد صدور'),
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10nPick(
                ctx,
                en: 'Margin ($marginPct%): $marginAmount ${c.currency}',
                fa: 'وجه التزام ($marginPct٪): $marginAmount ${c.currency}',
              ),
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              l10nPick(
                ctx,
                en: 'Issuance Fee ($feePct%): $feeAmount ${c.currency}',
                fa: 'کارمزد صدور ($feePct٪): $feeAmount ${c.currency}',
              ),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.softGray),
            ),
            Divider(height: 24, color: AppColors.lightDivider),
            Text(
              l10nPick(ctx, en: 'Funding Source (held in escrow):', fa: 'منشأ وجه (حبس نزد پلتفرم):'),
              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: AppSpacing.xs.h),
            RadioGroup<String>(
              groupValue: source,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setDlgState(() => source = v ?? 'WALLET_FIAT');
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    dense: true,
                    value: 'WALLET_FIAT',
                    activeColor: AppColors.lightPrimary,
                    title: Text(
                      l10nPick(ctx, en: 'Internal Fiat Wallet', fa: 'کیف پول فیات داخلی'),
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                  RadioListTile<String>(
                    dense: true,
                    value: 'WALLET_CRYPTO',
                    activeColor: AppColors.lightPrimary,
                    title: Text(
                      l10nPick(ctx, en: 'Crypto Wallet (Instant FX snapshot)', fa: 'کیف پول رمزارز (تبدیل لحظه‌ای)'),
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Get.back();
            },
            child: Text(l10nPick(ctx, en: 'Cancel', fa: 'انصراف')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
            ),
            onPressed: () async {
              HapticFeedback.lightImpact();
              Get.back();
              final ok = await controller.depositMargin(c.id, source);
              if (!mounted) return;
              if (ok) {
                Get.snackbar(
                  depositSuccessTitle,
                  depositSuccessBody,
                  backgroundColor: AppColors.success,
                  colorText: AppColors.white,
                );
              }
            },
            child: Text(
              l10nPick(ctx, en: 'Deposit Margin', fa: 'تودیع وجه التزام'),
              style: const TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    ));
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
              en: 'Guarantee Case',
              fa: 'پرونده ضمانت‌نامه',
              ar: 'ملف خطاب الضمان',
              zh: '保函案件详情',
            ),
          ),
        ),
      ),
      body: Obx(() {
        final c = controller.selectedCase.value;
        if (controller.isLoadingDetail.value || c == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final inst = c.instrument;

        return RefreshIndicator(
          onRefresh: () => controller.fetchCase(c.id),
          child: ListView(
            padding: EdgeInsetsDirectional.all(AppSpacing.page.w),
            children: [
              // 1. Status Stepper
              GuaranteeStatusStepper(currentStatus: c.status),
              SizedBox(height: AppSpacing.md.h),

              // 2. Case Header Card
              Container(
                padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          c.caseNo,
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            fontFamily: 'monospace',
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Container(
                          padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: _statusColor(c.status).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                          ),
                          child: Text(
                            _statusFa(c.status),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: _statusColor(c.status),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    Text(
                      inst?.name ?? c.beneficiaryName,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs.h),
                    Text(
                      l10nPick(
                        context,
                        en: 'Beneficiary: ${c.beneficiaryName} · Amount: ${c.amount} ${c.currency}',
                        fa: 'ذینفع: ${c.beneficiaryName} · مبلغ: ${c.amount} ${c.currency}',
                      ),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    Text(
                      l10nPick(
                        context,
                        en: 'Validity: ${c.validityMonths} months',
                        fa: 'مدت اعتبار: ${c.validityMonths} ماه',
                      ),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // G2: Required Case Documents & Final Submit
              if (c.status == 'DRAFT' || c.status == 'COMPLEMENT_REQUIRED') ...[
                SizedBox(height: AppSpacing.md.h),
                Container(
                  padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF132838) : const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                    border: Border.all(
                      color: isDark ? const Color(0xFF38BDF8).withValues(alpha: 0.25) : const Color(0xFFBAE6FD),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(context, en: 'Required Case Documents', fa: 'مدارک الزامی پرونده'),
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Upload base contract or tender notice, company registration, and financials.',
                          fa: 'قرارداد پایه یا آگهی مناقصه، مدارک ثبتی شرکت و صورت‌های مالی را بارگذاری کنید.',
                        ),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? const Color(0xFFBAE6FD) : const Color(0xFF075985),
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      ...c.documents.map((doc) => Padding(
                            padding: EdgeInsetsDirectional.symmetric(vertical: 2.h),
                            child: Row(
                              children: [
                                const Icon(Icons.description, size: 14, color: Colors.blueGrey),
                                SizedBox(width: AppSpacing.xs.w),
                                Expanded(
                                  child: Text(
                                    '${doc.docType}: ${doc.fileRef} (${doc.status})',
                                    style: AppTextStyles.labelSmall,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      SizedBox(height: AppSpacing.md.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.upload_file, size: 16),
                              label: Text(
                                l10nPick(context, en: 'Upload Doc', fa: 'بارگذاری مدرک'),
                                style: AppTextStyles.labelSmall,
                              ),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                _showUploadDocDialog(c);
                              },
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                              icon: const Icon(Icons.send, color: AppColors.white, size: 16),
                              label: Text(
                                l10nPick(context, en: 'Submit Case', fa: 'ثبت نهایی پرونده'),
                                style: const TextStyle(color: AppColors.white),
                              ),
                              onPressed: () => _confirm(
                                l10nPick(context, en: 'Submit Case', fa: 'ثبت نهایی پرونده'),
                                l10nPick(context, en: 'Submit case for analyst and bank review?', fa: 'پرونده جهت بررسی کارشناس و استعلام بانک ارسال شود؟'),
                                () => controller.submitCase(c.id),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // G3: Under Review
              if (c.status == 'UNDER_REVIEW') ...[
                SizedBox(height: AppSpacing.md.h),
                Container(
                  padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF132838) : const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                    border: Border.all(
                      color: isDark ? const Color(0xFF38BDF8).withValues(alpha: 0.25) : const Color(0xFFBAE6FD),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sync, color: Color(0xFF0284C7)),
                      SizedBox(width: AppSpacing.md.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            en: 'Under review by Credit Analyst & querying issuing bank (max 5 business days SLA).',
                            fa: 'پرونده در دست بررسی کارشناس اعتباری و استعلام بانک صادرکننده است (سقف ۵ روز کاری).',
                          ),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark ? const Color(0xFFBAE6FD) : const Color(0xFF0369A1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // G4: Margin Pending
              if (c.status == 'MARGIN_PENDING') ...[
                SizedBox(height: AppSpacing.md.h),
                Container(
                  padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2E2211) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                    border: Border.all(
                      color: isDark ? const Color(0xFFFBBF24).withValues(alpha: 0.3) : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(context, en: 'Bank Approved — Margin Required', fa: 'موافقت مشروط بانک — تودیع وجه التزام'),
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Deposit margin and issuance fee within 48h. Held in platform escrow (not with bank).',
                          fa: 'مهلت تودیع ۴۸ ساعت است. وجه التزام نزد پلتفرم حبس می‌شود (نه نزد بانک).',
                        ),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r)),
                          ),
                          icon: const Icon(Icons.account_balance_wallet, color: AppColors.white),
                          label: Text(
                            l10nPick(context, en: 'Deposit Margin', fa: 'تودیع وجه التزام'),
                            style: const TextStyle(color: AppColors.white),
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _showDepositDialog(c);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // G5: In Issuance
              if (c.status == 'IN_ISSUANCE') ...[
                SizedBox(height: AppSpacing.md.h),
                Container(
                  padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2E2211) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                    border: Border.all(
                      color: isDark ? const Color(0xFFFBBF24).withValues(alpha: 0.3) : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.hourglass_bottom, color: Color(0xFFD97706)),
                      SizedBox(width: AppSpacing.md.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            en: 'Issuing bank is processing official document (SLA: 3 business days).',
                            fa: 'بانک صادرکننده در حال صدور و مهر سند رسمی است (حداکثر ۳ روز کاری).',
                          ),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // G6: Certificate or Preview
              if (c.issued != null || {'ISSUED', 'CLAIMED', 'EXPIRED', 'RELEASED'}.contains(c.status)) ...[
                SizedBox(height: AppSpacing.md.h),
                GuaranteeCertificateWidget.fromCase(
                  c,
                  applicantName: _resolveApplicantName(),
                ),
              ] else ...[
                SizedBox(height: AppSpacing.md.h),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: const Icon(Icons.verified_outlined, color: Color(0xFF0D9488)),
                      title: Text(
                        l10nPick(
                          context,
                          fa: 'پیش‌نمایش گواهی دیجیتال ضمانت‌نامه (سپام)',
                          en: 'Digital Guarantee Certificate Preview',
                          ar: 'معاينة شهادة الضمان الرقمية',
                          zh: '数字保函电子凭单预审预览',
                        ),
                        style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.all(AppSpacing.md.w),
                          child: GuaranteeCertificateWidget.fromCase(
                            c,
                            applicantName: _resolveApplicantName(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // G7: Claimed
              if (c.status == 'CLAIMED') ...[
                SizedBox(height: AppSpacing.md.h),
                Container(
                  padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF36181B) : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                    border: Border.all(
                      color: isDark ? const Color(0xFFF87171).withValues(alpha: 0.3) : const Color(0xFFFECACA),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: AppColors.error),
                          SizedBox(width: AppSpacing.sm.w),
                          Text(
                            l10nPick(context, en: 'Beneficiary Claim Received', fa: 'مطالبه ذینفع از بانک دریافت شد'),
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Margin is fully frozen and expiration timer is paused per banking rules.',
                          fa: 'وجه التزام کاملاً فریز شده و طبق رویه بانکی تایمر انقضا متوقف است.',
                        ),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // G8: Expired
              if (c.status == 'EXPIRED') ...[
                SizedBox(height: AppSpacing.md.h),
                Container(
                  padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(context, en: 'Legal 30-Day Waiting Period', fa: 'مهلت انتظار قانونی ۳۰ روزه'),
                        style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'After expiry, a 30-day legal wait ensures no late claims before margin release.',
                          fa: 'جهت اطمینان از عدم مطالبه دیرهنگام، آزادسازی پس از مهلت انتظار ۳۰ روزه انجام می‌شود.',
                        ),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Cancel Case
              if (['DRAFT', 'UNDER_REVIEW', 'COMPLEMENT_REQUIRED', 'MARGIN_PENDING', 'IN_ISSUANCE'].contains(c.status)) ...[
                SizedBox(height: AppSpacing.md.h),
                TextButton(
                  onPressed: () => _confirm(
                    l10nPick(context, en: 'Cancel Case', fa: 'لغو پرونده'),
                    l10nPick(
                      context,
                      en: 'Cancel this case? If deposited, margin and fees will be fully refunded.',
                      fa: 'آیا از لغو پرونده اطمینان دارید؟ در صورت تودیع، وجه التزام کامل عودت می‌گردد.',
                    ),
                    () => controller.cancelCase(c.id),
                  ),
                  child: Text(
                    l10nPick(context, en: 'Cancel Case', fa: 'لغو پرونده'),
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ],

              // Timeline & Events
              SizedBox(height: AppSpacing.md.h),
              Text(
                l10nPick(context, en: 'Timeline & Bank Queries', fa: 'تایم‌لاین رویدادها و استعلام‌های بانک'),
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),
              ...c.events.map((e) => Padding(
                    padding: EdgeInsetsDirectional.symmetric(vertical: 4.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.circle, size: 8, color: Color(0xFF0D9488)),
                        SizedBox(width: AppSpacing.sm.w),
                        Expanded(
                          child: Text(
                            '${e.createdAt?.toLocal() ?? ''} · ${e.actorRole}${e.source != null ? ' [${e.source}]' : ''}${e.reason != null ? ' — ${e.reason}' : ''}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              SizedBox(height: AppSpacing.xxl.h),
            ],
          ),
        );
      }),
    );
  }
}
