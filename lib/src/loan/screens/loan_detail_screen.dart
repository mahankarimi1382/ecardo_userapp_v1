import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/loan_controller.dart';
import '../models/loan_models.dart';

/// جزئیات پرونده وام — کارت وضعیت، پیشنهاد، وثایق، جدول اقساط، تایم‌لاین، دکمه‌های اقدام.
class LoanDetailScreen extends StatefulWidget {
  final int caseId;
  const LoanDetailScreen({super.key, required this.caseId});

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  final LoanController controller = Get.find<LoanController>();

  String _statusFa(String status) {
    switch (status) {
      case 'DRAFT': return 'پیش‌نویس';
      case 'UNDER_ASSESSMENT': return 'در حال سنجش اعتبار';
      case 'COMPLEMENT_REQUIRED': return 'نیاز به تکمیل مدارک';
      case 'OFFERED': return 'پیشنهاد صادر شد';
      case 'AWAITING_COLLATERAL': return 'در انتظار تودیع وثیقه';
      case 'AWAITING_SIGNING': return 'در انتظار امضا';
      case 'DISBURSED': return 'پرداخت شد';
      case 'ACTIVE': return 'در حال بازپرداخت';
      case 'OVERDUE': return 'معوق';
      case 'DEFAULTED': return 'نکول';
      case 'COMPLETED': return 'تسویه‌شده';
      case 'REJECTED': return 'رد شد';
      case 'CANCELLED': return 'لغو';
      default: return status;
    }
  }

  void _confirm(String title, String message, Future<bool> Function() action) {
    Get.dialog(AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text(l10nPick(context, en: 'Cancel', fa: 'انصراف'))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
          onPressed: () async {
            Get.back();
            final ok = await action();
            if (!ok) {
              Get.snackbar(l10nPick(context, en: 'Error', fa: 'خطا'),
                l10nPick(context, en: 'Action failed.', fa: 'عملیات ناموفق بود.'),
                backgroundColor: Colors.red, colorText: Colors.white);
            }
          },
          child: Text(l10nPick(context, en: 'Confirm', fa: 'تأیید'), style: const TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(l10nPick(context, en: 'Loan Case', fa: 'پرونده وام'))),
      body: Obx(() {
        final c = controller.selectedCase.value;
        if (controller.isLoadingDetail.value || c == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // کارت وضعیت
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(c.caseNo, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.sp)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.lightPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(_statusFa(c.status), style: TextStyle(fontSize: 10.sp, color: AppColors.lightPrimary)),
                    ),
                  ]),
                  SizedBox(height: 8.h),
                  Text(l10nPick(context,
                    en: 'Requested: ${c.requestedAmount} · ${c.tenureMonths} months',
                    fa: 'درخواست: ${c.requestedAmount} · ${c.tenureMonths} ماهه')),
                ]),
              ),
            ),

            // پیشنهاد
            if (c.offer != null && c.status == 'OFFERED') ...[
              SizedBox(height: 12.h),
              Card(color: Colors.orange.shade50, child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10nPick(context, en: 'Your Offer', fa: 'پیشنهاد وام'),
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp)),
                  SizedBox(height: 6.h),
                  Text(l10nPick(context,
                    en: 'Amount ${c.offer!.offeredAmount} · Rate ${c.offer!.ratePct}%',
                    fa: 'مبلغ ${c.offer!.offeredAmount} · نرخ ${c.offer!.ratePct}٪')),
                  if (c.offerExpiresAt != null)
                    Text(l10nPick(context,
                      en: 'Valid until ${c.offerExpiresAt!.toLocal()}',
                      fa: 'اعتبار تا ${c.offerExpiresAt!.toLocal()}')),
                  SizedBox(height: 10.h),
                  // جدول اقساط کامل قبل از پذیرش
                  Text(l10nPick(context, en: 'Installment Schedule (preview)', fa: 'جدول اقساط (قبل از پذیرش)'),
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.sp)),
                  ...c.offer!.schedulePreview.take(6).map((row) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Text('${row['seq']}: ${row['amount']} (اصل ${row['principal_part']} + سود ${row['interest_part']})',
                      style: TextStyle(fontSize: 10.sp)),
                  )),
                  SizedBox(height: 10.h),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                    onPressed: () => _confirm(
                      l10nPick(context, en: 'Accept Offer', fa: 'پذیرش پیشنهاد'),
                      l10nPick(context, en: 'Lock the offer terms and continue to collateral?', fa: 'شرایط پیشنهاد قفل و به تودیع وثیقه برویم؟'),
                      () => controller.acceptOffer(c.id),
                    ),
                    child: Text(l10nPick(context, en: 'Accept Offer', fa: 'پذیرش پیشنهاد'),
                      style: const TextStyle(color: Colors.white)),
                  ),
                ]),
              )),
            ],

            // تودیع وثیقه
            if (c.status == 'AWAITING_COLLATERAL') ...[
              SizedBox(height: 12.h),
              Row(children: [
                Expanded(child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                  icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
                  label: Text(l10nPick(context, en: 'Post Cash Collateral', fa: 'تودیع وثیقه نقدی'),
                    style: const TextStyle(color: Colors.white)),
                  onPressed: () => _confirm(
                    l10nPick(context, en: 'Post Cash Collateral', fa: 'تودیع وثیقه نقدی'),
                    l10nPick(context, en: 'Lock cash from your wallet as collateral?', fa: 'قفل وجه نقد از کیف پول به‌عنوان وثیقه؟'),
                    () => controller.postCashCollateral(c.id, c.requestedAmount, 'IRT'),
                  ),
                )),
                SizedBox(width: 8.w),
                Expanded(child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  icon: const Icon(Icons.currency_bitcoin, color: Colors.white),
                  label: Text(l10nPick(context, en: 'Post Crypto Collateral', fa: 'تودیع وثیقه رمزارزی'),
                    style: const TextStyle(color: Colors.white)),
                  onPressed: () => _confirm(
                    l10nPick(context, en: 'Post Crypto Collateral', fa: 'تودیع وثیقه رمزارزی'),
                    l10nPick(context, en: 'Lock crypto from your wallet (LTV monitored)?', fa: 'قفل رمزارز از کیف پول (با پایش LTV)؟'),
                    () => controller.postCryptoCollateral(c.id, c.requestedAmount, 'USDT'),
                  ),
                )),
              ]),
            ],

            // امضای قرارداد
            if (c.status == 'AWAITING_SIGNING') ...[
              SizedBox(height: 12.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                onPressed: () => _confirm(
                  l10nPick(context, en: 'Sign Contract', fa: 'امضای قرارداد'),
                  l10nPick(context, en: 'Sign the digital loan contract?', fa: 'قرارداد دیجیتال وام امضا شود؟'),
                  () => controller.signContract(c.id),
                ),
                child: Text(l10nPick(context, en: 'Sign Contract', fa: 'امضای قرارداد'),
                  style: const TextStyle(color: Colors.white)),
              ),
            ],

            // جدول اقساط (در ACTIVE/OVERDUE)
            if (c.installments.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Card(child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10nPick(context, en: 'Repayment Schedule', fa: 'جدول بازپرداخت'),
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp)),
                  SizedBox(height: 8.h),
                  ...c.installments.map((inst) => _installmentTile(context, c.id, inst)),
                  if (c.status == 'ACTIVE') ...[
                    SizedBox(height: 8.h),
                    TextButton(
                      onPressed: () => _confirm(
                        l10nPick(context, en: 'Early Repayment', fa: 'تسویه زودهنگام'),
                        l10nPick(context, en: 'Pay remaining principal (interest of future periods waived)?', fa: 'پرداخت اصل باقیمانده (معافیت سود دوره‌های آینده)؟'),
                        () => controller.earlyRepayment(c.id),
                      ),
                      child: Text(l10nPick(context, en: 'Early Repayment', fa: 'تسویه زودهنگام')),
                    ),
                  ],
                ]),
              )),
            ],

            // لغو درخواست
            if (['DRAFT', 'OFFERED', 'AWAITING_COLLATERAL', 'AWAITING_SIGNING'].contains(c.status)) ...[
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () => _confirm(
                  l10nPick(context, en: 'Cancel Application', fa: 'لغو درخواست'),
                  l10nPick(context, en: 'Cancel and release any locked collateral?', fa: 'لغو پرونده و آزادسازی وثایق قفل‌شده؟'),
                  () async {
                    final ok = await controller.cancelCase(c.id);
                    if (ok) Get.back();
                    return ok;
                  },
                ),
                child: Text(l10nPick(context, en: 'Cancel Application', fa: 'لغو درخواست'),
                  style: const TextStyle(color: Colors.red)),
              ),
            ],

            // تایم‌لاین
            SizedBox(height: 12.h),
            Text(l10nPick(context, en: 'Timeline', fa: 'تایم‌لاین'),
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp)),
            ...c.events.map((e) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.circle, size: 8),
                SizedBox(width: 8.w),
                Expanded(child: Text(
                  '${e.createdAt?.toLocal() ?? ''} · ${e.actorRole}${e.reason != null ? ' — ${e.reason}' : ''}',
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade700),
                )),
              ]),
            )),
          ],
        );
      }),
    );
  }

  Widget _installmentTile(BuildContext context, int caseId, LoanInstallmentModel inst) {
    final statusColor = inst.isPaid
        ? Colors.green
        : inst.isOverdue
            ? Colors.red
            : Colors.blueGrey;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Text('#${inst.seq}', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700)),
      title: Text(l10nPick(context,
        en: '${inst.amount} due ${inst.dueDate?.toLocal().toString().split(' ').first ?? ''}',
        fa: '${inst.amount} — سررسید ${inst.dueDate?.toLocal().toString().split(' ').first ?? ''}'),
        style: TextStyle(fontSize: 11.sp)),
      subtitle: inst.lateFeeAccrued > 0
          ? Text(l10nPick(context, en: 'Late fee: ${inst.lateFeeAccrued}', fa: 'جریمه: ${inst.lateFeeAccrued}'),
              style: const TextStyle(color: Colors.red, fontSize: 10))
          : null,
      trailing: inst.isPaid
          ? const Icon(Icons.check_circle, color: Colors.green)
          : ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
              onPressed: () => _confirm(
                l10nPick(context, en: 'Pay Installment', fa: 'پرداخت قسط'),
                l10nPick(context, en: 'Pay installment #${inst.seq} (${inst.totalDue})?', fa: 'پرداخت قسط #${inst.seq} (${inst.totalDue})؟'),
                () => controller.payInstallment(caseId, inst.id),
              ),
              child: Text(l10nPick(context, en: 'Pay', fa: 'پرداخت'), style: const TextStyle(color: Colors.white)),
            ),
      tileColor: statusColor.withValues(alpha: 0.04),
    );
  }
}
