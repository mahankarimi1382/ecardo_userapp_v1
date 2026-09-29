import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/guarantee_controller.dart';
import '../models/guarantee_models.dart';

/// خانه ضمانت‌نامه‌ها — ابزارها + راهنمای انتخاب + پرونده‌های من.
class GuaranteeHomeScreen extends StatefulWidget {
  const GuaranteeHomeScreen({super.key});

  @override
  State<GuaranteeHomeScreen> createState() => _GuaranteeHomeScreenState();
}

class _GuaranteeHomeScreenState extends State<GuaranteeHomeScreen> {
  final GuaranteeController controller = Get.put(GuaranteeController());

  String _statusFa(String status) {
    switch (status) {
      case 'DRAFT': return 'پیش‌نویس';
      case 'UNDER_REVIEW': return 'در حال بررسی';
      case 'COMPLEMENT_REQUIRED': return 'نیاز به تکمیل مدارک';
      case 'MARGIN_PENDING': return 'در انتظار تودیع';
      case 'IN_ISSUANCE': return 'در حال صدور';
      case 'ISSUED': return 'صادر شد';
      case 'CLAIMED': return 'مطالبه‌شده';
      case 'EXPIRED': return 'منقضی';
      case 'RELEASED': return 'تضامین آزاد شد';
      case 'REJECTED': return 'رد شد';
      case 'CANCELLED': return 'لغو';
      default: return status;
    }
  }

  void _showCreateSheet(BuildContext context, GuaranteeInstrumentModel inst) {
    final beneficiaryCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    int validityMonths = 12;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(inst.name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800)),
              SizedBox(height: 6.h),
              Text(l10nPick(context,
                en: 'Margin ${inst.marginPct}% · Fee ${inst.feePct}%',
                fa: 'وجه التزام ${inst.marginPct}٪ · کارمزد ${inst.feePct}٪')),
              SizedBox(height: 12.h),
              TextField(
                controller: beneficiaryCtrl,
                decoration: InputDecoration(
                  labelText: l10nPick(context, en: 'Beneficiary name', fa: 'نام ذینفع'),
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10nPick(context, en: 'Amount', fa: 'مبلغ سند'),
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.h),
              Text(l10nPick(context, en: 'Validity (months)', fa: 'مدت اعتبار (ماه)')),
              Wrap(
                spacing: 8.w,
                children: [6, 12, 24].map((m) => ChoiceChip(
                  label: Text('$m'),
                  selected: validityMonths == m,
                  onSelected: (_) => setSheetState(() => validityMonths = m),
                )).toList(),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                  onPressed: () async {
                    final controller = Get.find<GuaranteeController>();
                    final err = await controller.createCase(
                      instrumentId: inst.id,
                      beneficiaryName: beneficiaryCtrl.text.trim(),
                      amount: double.tryParse(amountCtrl.text) ?? 0,
                      validityMonths: validityMonths,
                    );
                    if (err != null) {
                      Get.snackbar(l10nPick(context, en: 'Error', fa: 'خطا'), err,
                        backgroundColor: Colors.red, colorText: Colors.white);
                    } else {
                      Get.back();
                      Get.snackbar(l10nPick(context, en: 'Created', fa: 'ایجاد شد'),
                        l10nPick(context, en: 'Case created — upload base contract document.',
                          fa: 'پرونده ساخته شد؛ قرارداد پایه را بارگذاری کنید.'),
                        backgroundColor: Colors.green, colorText: Colors.white);
                    }
                  },
                  child: Text(l10nPick(context, en: 'Apply for Guarantee', fa: 'ثبت درخواست ضمانت‌نامه'),
                    style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(l10nPick(context, en: 'Bank Guarantees & LC', fa: 'ضمانت‌نامه بانکی'))),
      body: Obx(() {
        if (controller.isLoadingInstruments.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            Text(l10nPick(context, en: 'Instruments', fa: 'ابزارها'),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),
            ...controller.instruments.map((inst) => Card(
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListTile(
                title: Text(inst.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.sp)),
                subtitle: Text('${inst.code} · ${inst.marginPct}%'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showCreateSheet(context, inst),
              ),
            )),
            SizedBox(height: 16.h),
            Text(l10nPick(context, en: 'My Cases', fa: 'پرونده‌های من'),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),
            if (controller.myCases.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(child: Text(l10nPick(context, en: 'No cases yet', fa: 'پرونده‌ای ندارید'))),
              ),
            ...controller.myCases.map((c) => Card(
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListTile(
                title: Text(c.caseNo, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp)),
                subtitle: Text(c.instrument?.name ?? c.beneficiaryName, style: TextStyle(fontSize: 11.sp)),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(_statusFa(c.status), style: TextStyle(fontSize: 9.sp, color: AppColors.lightPrimary)),
                ),
              ),
            )),
          ],
        );
      }),
    );
  }
}
