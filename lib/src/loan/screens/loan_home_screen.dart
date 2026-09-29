import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/loan_controller.dart';
import '../models/loan_models.dart';

/// خانه وام — محصولات + پیشنهاد شخصی‌شده (بدون رقم‌سازی: نمایش فقط با سنجش واقعی).
class LoanHomeScreen extends StatefulWidget {
  const LoanHomeScreen({super.key});

  @override
  State<LoanHomeScreen> createState() => _LoanHomeScreenState();
}

class _LoanHomeScreenState extends State<LoanHomeScreen> {
  final LoanController controller = Get.put(LoanController());

  @override
  void initState() {
    super.initState();
    controller.fetchProducts();
    controller.fetchMyCases();
  }

  String _statusLabel(BuildContext context, String status) {
    return l10nPick(context,
      en: status, fa: _statusFa(status), ar: _statusFa(status));
  }

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

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED': return Colors.green;
      case 'ACTIVE': return AppColors.lightPrimary;
      case 'OVERDUE': case 'DEFAULTED': return Colors.red;
      case 'REJECTED': case 'CANCELLED': return Colors.grey;
      case 'OFFERED': case 'AWAITING_COLLATERAL': case 'AWAITING_SIGNING':
        return Colors.orange;
      default: return Colors.blueGrey;
    }
  }

  void _showApplySheet(BuildContext context, LoanProductModel product) {
    controller.selectedProduct.value = product;
    controller.amountInput.value = '';
    controller.selectedTenure.value = product.tenureOptions.first;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800)),
            SizedBox(height: 8.h),
            Text(l10nPick(context,
              en: 'Amount range: ${product.minAmount} - ${product.maxAmount}',
              fa: 'بازه مبلغ: ${product.minAmount} تا ${product.maxAmount}')),
            SizedBox(height: 12.h),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10nPick(context, en: 'Requested amount', fa: 'مبلغ درخواستی'),
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => controller.amountInput.value = v,
            ),
            SizedBox(height: 12.h),
            Text(l10nPick(context, en: 'Tenure (months)', fa: 'مدت بازپرداخت (ماه)')),
            Wrap(
              spacing: 8.w,
              children: product.tenureOptions.map((m) => ChoiceChip(
                label: Text('$m'),
                selected: controller.selectedTenure.value == m,
                onSelected: (_) => controller.selectedTenure.value = m,
              )).toList(),
            ),
            SizedBox(height: 16.h),
            // جدول اقساط نمونه — فقط با سنجش واقعی بعد از ثبت نمایش داده می‌شود
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                onPressed: controller.isSubmitting.value ? null : () async {
                  final error = await controller.applyForLoan();
                  if (error != null) {
                    Get.snackbar(l10nPick(context, en: 'Error', fa: 'خطا'), error,
                      backgroundColor: Colors.red, colorText: Colors.white);
                  } else {
                    Get.back();
                    Get.snackbar(
                      l10nPick(context, en: 'Submitted', fa: 'ثبت شد'),
                      l10nPick(context,
                        en: 'Credit assessment completed — check the offer.',
                        fa: 'سنجش اعتبار انجام شد؛ پیشنهاد را ببینید.'),
                      backgroundColor: Colors.green, colorText: Colors.white);
                  }
                },
                child: Text(l10nPick(context, en: 'Apply for Loan', fa: 'ثبت درخواست وام'),
                  style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10nPick(context, en: 'Loans', fa: 'وام و اعتبار')),
      ),
      body: Obx(() {
        if (controller.isLoadingProducts.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            Text(l10nPick(context, en: 'Loan Products', fa: 'محصولات وام'),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),
            ...controller.products.map((p) => Card(
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListTile(
                title: Text(p.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp)),
                subtitle: Text(l10nPick(context,
                  en: 'Rate ${p.interestRatePct}% · ${p.minAmount}–${p.maxAmount}',
                  fa: 'نرخ ${p.interestRatePct}٪ · ${p.minAmount} تا ${p.maxAmount}')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showApplySheet(context, p),
              ),
            )),
            SizedBox(height: 16.h),
            Text(l10nPick(context, en: 'My Applications', fa: 'درخواست‌های من'),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),
            if (controller.myCases.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(child: Text(l10nPick(context,
                  en: 'No loan applications yet', fa: 'هنوز درخواست وامی ندارید'))),
              ),
            ...controller.myCases.map((c) => Card(
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListTile(
                title: Text(c.caseNo, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp)),
                subtitle: Text(l10nPick(context,
                  en: '${c.requestedAmount} · ${c.tenureMonths}m',
                  fa: '${c.requestedAmount} · ${c.tenureMonths} ماهه')),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _statusColor(c.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(_statusLabel(context, c.status),
                    style: TextStyle(color: _statusColor(c.status), fontSize: 10.sp)),
                ),
                onTap: () => Get.toNamed('/loan_detail_route', arguments: c.id),
              ),
            )),
          ],
        );
      }),
    );
  }
}
