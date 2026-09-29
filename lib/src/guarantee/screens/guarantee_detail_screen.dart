import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/guarantee_controller.dart';
import '../models/guarantee_models.dart';

/// جزئیات پرونده ضمانت‌نامه و اعتبار اسنادی — Bank-Guarantee-Service-Flow.md
/// مدیریت چرخه: تکمیل پرونده و مدارک → بررسی کارشناس/بانک → تودیع وجه التزام (اسکرو پلتفرم) →
/// صدور سند رسمی بانک با bank_ref → دوره اعتبار → مهلت انتظار ۳۰ روزه قانونی و آزادسازی تضامین.
class GuaranteeDetailScreen extends StatefulWidget {
  final int caseId;
  const GuaranteeDetailScreen({super.key, required this.caseId});

  @override
  State<GuaranteeDetailScreen> createState() => _GuaranteeDetailScreenState();
}

class _GuaranteeDetailScreenState extends State<GuaranteeDetailScreen> {
  final GuaranteeController controller = Get.find<GuaranteeController>();

  @override
  void initState() {
    super.initState();
    final id = widget.caseId > 0 ? widget.caseId : (Get.arguments is int ? Get.arguments as int : 0);
    if (id > 0) {
      controller.fetchCase(id);
    }
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
      case 'RELEASED': return Colors.green;
      case 'ISSUED': return Colors.teal;
      case 'CLAIMED': return Colors.red;
      case 'REJECTED': case 'CANCELLED': return Colors.grey;
      case 'MARGIN_PENDING': case 'IN_ISSUANCE': return Colors.orange;
      case 'UNDER_REVIEW': case 'COMPLEMENT_REQUIRED': return Colors.blue;
      default: return Colors.blueGrey;
    }
  }

  void _confirm(String title, String message, Future<bool> Function() action) {
    Get.dialog(AlertDialog(
      title: Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
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

  void _showUploadDocDialog(GuaranteeCaseModel c) {
    String docType = 'base_contract';
    final fileRefCtrl = TextEditingController(text: '/docs/contract_scan.pdf');

    Get.dialog(StatefulBuilder(
      builder: (context, setDlgState) => AlertDialog(
        title: Text(l10nPick(context, en: 'Upload Document', fa: 'بارگذاری مدارک پرونده'),
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10nPick(context, en: 'Document Type:', fa: 'نوع مدرک الزامی:')),
            DropdownButton<String>(
              isExpanded: true,
              value: docType,
              items: [
                DropdownMenuItem(value: 'base_contract', child: Text(l10nPick(context, en: 'Base Contract / Tender Notice', fa: 'قرارداد پایه یا آگهی مناقصه'))),
                DropdownMenuItem(value: 'registration', child: Text(l10nPick(context, en: 'Company Registration / Articles', fa: 'مدارک ثبتی شرکت و اساسنامه'))),
                DropdownMenuItem(value: 'financials', child: Text(l10nPick(context, en: 'Financial Statements / Tax Balance', fa: 'صورت‌های مالی و تراز مالیاتی'))),
              ],
              onChanged: (v) => setDlgState(() => docType = v ?? 'base_contract'),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: fileRefCtrl,
              decoration: InputDecoration(
                labelText: l10nPick(context, en: 'File name / reference', fa: 'نام یا شناسه فایل'),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(l10nPick(context, en: 'Cancel', fa: 'انصراف'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
            onPressed: () async {
              Get.back();
              final ok = await controller.uploadDoc(c.id, docType, fileRefCtrl.text.trim());
              if (ok) {
                Get.snackbar(l10nPick(context, en: 'Uploaded', fa: 'بارگذاری شد'),
                  l10nPick(context, en: 'Document attached to case.', fa: 'مدرک با موفقیت ضمیمه پرونده گردید.'),
                  backgroundColor: Colors.green, colorText: Colors.white);
              }
            },
            child: Text(l10nPick(context, en: 'Upload', fa: 'بارگذاری'), style: const TextStyle(color: Colors.white)),
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

    Get.dialog(StatefulBuilder(
      builder: (context, setDlgState) => AlertDialog(
        title: Text(l10nPick(context, en: 'Deposit Margin', fa: 'تودیع وجه التزام و کارمزد صدور'),
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10nPick(context,
              en: 'Margin (${marginPct}%): $marginAmount ${c.currency}',
              fa: 'وجه التزام (${marginPct}٪): $marginAmount ${c.currency}'),
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.sp)),
            Text(l10nPick(context,
              en: 'Issuance Fee (${feePct}%): $feeAmount ${c.currency}',
              fa: 'کارمزد صدور (${feePct}٪): $feeAmount ${c.currency}'),
              style: TextStyle(fontSize: 11.sp, color: Colors.blueGrey)),
            const Divider(),
            Text(l10nPick(context, en: 'Funding Source (held in escrow):', fa: 'منشأ وجه (حبس نزد پلتفرم):'),
              style: TextStyle(fontSize: 11.sp)),
            RadioListTile<String>(
              dense: true,
              value: 'WALLET_FIAT',
              groupValue: source,
              onChanged: (v) => setDlgState(() => source = v!),
              title: Text(l10nPick(context, en: 'Internal Fiat Wallet', fa: 'کیف پول فیات داخلی'), style: TextStyle(fontSize: 11.sp)),
            ),
            RadioListTile<String>(
              dense: true,
              value: 'WALLET_CRYPTO',
              groupValue: source,
              onChanged: (v) => setDlgState(() => source = v!),
              title: Text(l10nPick(context, en: 'Crypto Wallet (Instant FX snapshot)', fa: 'کیف پول رمزارز (تبدیل لحظه‌ای)'), style: TextStyle(fontSize: 11.sp)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(l10nPick(context, en: 'Cancel', fa: 'انصراف'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
            onPressed: () async {
              Get.back();
              final ok = await controller.depositMargin(c.id, source);
              if (ok) {
                Get.snackbar(l10nPick(context, en: 'Deposited', fa: 'تودیع شد'),
                  l10nPick(context, en: 'Margin locked in escrow — sent to bank for issuance.',
                    fa: 'وجه التزام نزد پلتفرم حبس شد و پرونده به بانک صادرکننده ارسال گردید.'),
                  backgroundColor: Colors.green, colorText: Colors.white);
              }
            },
            child: Text(l10nPick(context, en: 'Deposit Margin', fa: 'تودیع وجه التزام'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10nPick(context, en: 'Guarantee Case', fa: 'پرونده ضمانت‌نامه')),
      ),
      body: Obx(() {
        final c = controller.selectedCase.value;
        if (controller.isLoadingDetail.value || c == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final inst = c.instrument;

        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // هدر: شماره پرونده و وضعیت
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(c.caseNo, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.sp)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _statusColor(c.status).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(_statusFa(c.status),
                        style: TextStyle(color: _statusColor(c.status), fontSize: 10.sp, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                  SizedBox(height: 6.h),
                  Text(inst?.name ?? c.beneficiaryName, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
                  Text(l10nPick(context,
                    en: 'Beneficiary: ${c.beneficiaryName} · Amount: ${c.amount} ${c.currency}',
                    fa: 'ذینفع: ${c.beneficiaryName} · مبلغ: ${c.amount} ${c.currency}'),
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 11.sp)),
                  Text(l10nPick(context,
                    en: 'Validity: ${c.validityMonths} months',
                    fa: 'مدت اعتبار: ${c.validityMonths} ماه'),
                    style: TextStyle(color: Colors.blueGrey, fontSize: 10.sp)),
                ]),
              ),
            ),

            // گام ۲: مدارک پرونده و ارسال نهایی
            if (c.status == 'DRAFT' || c.status == 'COMPLEMENT_REQUIRED') ...[
              SizedBox(height: 12.h),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l10nPick(context, en: 'Required Case Documents', fa: 'مدارک الزامی پرونده'),
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp)),
                    SizedBox(height: 4.h),
                    Text(l10nPick(context,
                      en: 'Upload base contract or tender notice, company registration, and financials.',
                      fa: 'قرارداد پایه یا آگهی مناقصه، مدارک ثبتی شرکت و صورت‌های مالی را بارگذاری کنید.'),
                      style: TextStyle(fontSize: 11.sp)),
                    SizedBox(height: 8.h),
                    ...c.documents.map((doc) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Row(children: [
                        const Icon(Icons.description, size: 14, color: Colors.blueGrey),
                        SizedBox(width: 6.w),
                        Expanded(child: Text('${doc.docType}: ${doc.fileRef} (${doc.status})', style: TextStyle(fontSize: 10.sp))),
                      ]),
                    )),
                    SizedBox(height: 10.h),
                    Row(children: [
                      Expanded(child: OutlinedButton.icon(
                        icon: const Icon(Icons.upload_file, size: 16),
                        label: Text(l10nPick(context, en: 'Upload Doc', fa: 'بارگذاری مدرک'),
                          style: TextStyle(fontSize: 11.sp)),
                        onPressed: () => _showUploadDocDialog(c),
                      )),
                      SizedBox(width: 8.w),
                      Expanded(child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                        icon: const Icon(Icons.send, color: Colors.white, size: 16),
                        label: Text(l10nPick(context, en: 'Submit Case', fa: 'ثبت نهایی پرونده'),
                          style: const TextStyle(color: Colors.white)),
                        onPressed: () => _confirm(
                          l10nPick(context, en: 'Submit Case', fa: 'ثبت نهایی پرونده'),
                          l10nPick(context, en: 'Submit case for analyst and bank review?', fa: 'پرونده جهت بررسی کارشناس و استعلام بانک ارسال شود؟'),
                          () => controller.submitCase(c.id),
                        ),
                      )),
                    ]),
                  ]),
                ),
              ),
            ],

            // گام ۳: در حال بررسی
            if (c.status == 'UNDER_REVIEW') ...[
              SizedBox(height: 12.h),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(children: [
                    const Icon(Icons.sync, color: Colors.blue),
                    SizedBox(width: 12.w),
                    Expanded(child: Text(l10nPick(context,
                      en: 'Under review by Credit Analyst & querying issuing bank (max 5 business days SLA).',
                      fa: 'در حال بررسی توسط کارشناس اعتباری و استعلام از بانک صادرکننده (حداکثر ۵ روز کاری).'),
                      style: TextStyle(fontSize: 11.sp))),
                  ]),
                ),
              ),
            ],

            // گام ۴: تودیع وجه التزام
            if (c.status == 'MARGIN_PENDING') ...[
              SizedBox(height: 12.h),
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l10nPick(context, en: 'Bank Approved — Margin Required', fa: 'موافقت مشروط بانک — تودیع وجه التزام'),
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp)),
                    SizedBox(height: 4.h),
                    Text(l10nPick(context,
                      en: 'Deposit margin and issuance fee within 48h. Held in platform escrow (not with bank).',
                      fa: 'مهلت تودیع ۴۸ ساعت است. وجه التزام نزد پلتفرم حبس می‌شود (نه نزد بانک).'),
                      style: TextStyle(fontSize: 11.sp)),
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                        icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
                        label: Text(l10nPick(context, en: 'Deposit Margin', fa: 'تودیع وجه التزام'),
                          style: const TextStyle(color: Colors.white)),
                        onPressed: () => _showDepositDialog(c),
                      ),
                    ),
                  ]),
                ),
              ),
            ],

            // گام ۵: در حال صدور
            if (c.status == 'IN_ISSUANCE') ...[
              SizedBox(height: 12.h),
              Card(
                color: Colors.amber.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(children: [
                    const Icon(Icons.hourglass_bottom, color: Colors.amber),
                    SizedBox(width: 12.w),
                    Expanded(child: Text(l10nPick(context,
                      en: 'Issuing bank is processing official document (SLA: 3 business days).',
                      fa: 'بانک صادرکننده در حال صدور و مهر سند رسمی است (حداکثر ۳ روز کاری).'),
                      style: TextStyle(fontSize: 11.sp))),
                  ]),
                ),
              ),
            ],

            // گام ۶: سند صادر شد (فعال)
            if (c.status == 'ISSUED' && c.issued != null) ...[
              SizedBox(height: 12.h),
              Card(
                color: Colors.teal.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l10nPick(context, en: 'Official Bank Instrument Issued', fa: 'سند رسمی بانک صادر شد (فعال)'),
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp, color: Colors.teal.shade900)),
                    SizedBox(height: 6.h),
                    Text(l10nPick(context,
                      en: 'Bank Ref: ${c.issued!.bankRef}',
                      fa: 'شناسه مرجع بانک: ${c.issued!.bankRef}'),
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.sp)),
                    if (c.issued!.expiryDate != null)
                      Text(l10nPick(context,
                        en: 'Valid until: ${c.issued!.expiryDate!.toLocal().toString().split(' ').first}',
                        fa: 'تاریخ سررسید اعتبار: ${c.issued!.expiryDate!.toLocal().toString().split(' ').first}'),
                        style: TextStyle(fontSize: 11.sp)),
                    SizedBox(height: 10.h),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: Text(l10nPick(context, en: 'Download Official PDF', fa: 'دریافت سند رسمی ضمانت‌نامه (PDF)'),
                        style: const TextStyle(color: Colors.white)),
                      onPressed: () {
                        Get.snackbar(l10nPick(context, en: 'Download', fa: 'دانلود سند'),
                          l10nPick(context, en: 'Downloading official bank document...', fa: 'در حال دریافت نسخه الکترونیکی سند رسمی بانک...'),
                          backgroundColor: Colors.teal, colorText: Colors.white);
                      },
                    ),
                  ]),
                ),
              ),
            ],

            // گام ۷: مطالبه (فریز)
            if (c.status == 'CLAIMED') ...[
              SizedBox(height: 12.h),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 8.w),
                      Text(l10nPick(context, en: 'Beneficiary Claim Received', fa: 'مطالبه ذینفع از بانک دریافت شد'),
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp, color: Colors.red.shade900)),
                    ]),
                    SizedBox(height: 6.h),
                    Text(l10nPick(context,
                      en: 'Margin is fully frozen and expiration timer is paused per URDG 758 / UCP 600 rules.',
                      fa: 'وجه التزام کاملاً فریز شده و طبق رویه بین‌المللی تایمر انقضا متوقف است.'),
                      style: TextStyle(fontSize: 11.sp)),
                  ]),
                ),
              ),
            ],

            // گام ۸: انقضا و مهلت انتظار ۳۰ روزه
            if (c.status == 'EXPIRED') ...[
              SizedBox(height: 12.h),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l10nPick(context, en: 'Legal 30-Day Waiting Period', fa: 'مهلت انتظار قانونی ۳۰ روزه'),
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp)),
                    SizedBox(height: 6.h),
                    Text(l10nPick(context,
                      en: 'After expiry, a 30-day legal wait ensures no late claims before margin release.',
                      fa: 'جهت اطمینان از عدم مطالبه دیرهنگام، آزادسازی پس از مهلت انتظار ۳۰ روزه انجام می‌شود.'),
                      style: TextStyle(fontSize: 11.sp)),
                  ]),
                ),
              ),
            ],

            // لغو پرونده
            if (['DRAFT', 'UNDER_REVIEW', 'COMPLEMENT_REQUIRED', 'MARGIN_PENDING', 'IN_ISSUANCE'].contains(c.status)) ...[
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () => _confirm(
                  l10nPick(context, en: 'Cancel Case', fa: 'لغو پرونده'),
                  l10nPick(context,
                    en: 'Cancel this case? If deposited, margin and fees will be fully refunded.',
                    fa: 'آیا از لغو پرونده اطمینان دارید؟ در صورت تودیع، وجه التزام کامل عودت می‌گردد.'),
                  () => controller.cancelCase(c.id),
                ),
                child: Text(l10nPick(context, en: 'Cancel Case', fa: 'لغو پرونده'),
                  style: const TextStyle(color: Colors.red)),
              ),
            ],

            // تایم‌لاین رویدادها
            SizedBox(height: 12.h),
            Text(l10nPick(context, en: 'Timeline & Bank Queries', fa: 'تایم‌لاین رویدادها و استعلام‌های بانک'),
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp)),
            ...c.events.map((e) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.circle, size: 8),
                SizedBox(width: 8.w),
                Expanded(child: Text(
                  '${e.createdAt?.toLocal() ?? ''} · ${e.actorRole}${e.source != null ? ' [${e.source}]' : ''}${e.reason != null ? ' — ${e.reason}' : ''}',
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade700),
                )),
              ]),
            )),
          ],
        );
      }),
    );
  }
}
