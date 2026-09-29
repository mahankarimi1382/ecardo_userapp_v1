import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../remit_v2_service.dart';

/// صفحه رهگیری عمومی حواله و کاتالوگ مسیرها — Remittance-Service-Flow.md
/// ماژول‌های MOD_TRACKING و MOD_CORRIDOR_CATALOG و MOD_DISPUTE
class RemittanceTrackScreen extends StatefulWidget {
  const RemittanceTrackScreen({super.key});

  @override
  State<RemittanceTrackScreen> createState() => _RemittanceTrackScreenState();
}

class _RemittanceTrackScreenState extends State<RemittanceTrackScreen> with SingleTickerProviderStateMixin {
  final RemittanceV2ApiService _api = RemittanceV2ApiService();
  late TabController _tabController;

  final TextEditingController _trxController = TextEditingController();
  final RxBool _isTracking = false.obs;
  final Rxn<Map<String, dynamic>> _trackResult = Rxn<Map<String, dynamic>>();

  final RxBool _isLoadingCorridors = false.obs;
  final RxList<Map<String, dynamic>> _corridors = <Map<String, dynamic>>[].obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCorridors();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _trxController.dispose();
    super.dispose();
  }

  Future<void> _loadCorridors() async {
    try {
      _isLoadingCorridors.value = true;
      _corridors.value = await _api.getCorridors();
    } finally {
      _isLoadingCorridors.value = false;
    }
  }

  Future<void> _track() async {
    final trx = _trxController.text.trim();
    if (trx.isEmpty) return;

    try {
      _isTracking.value = true;
      final res = await _api.publicTrack(trx);
      if (res != null) {
        _trackResult.value = res;
      } else {
        Get.snackbar(l10nPick(context, en: 'Not Found', fa: 'یافت نشد'),
          l10nPick(context, en: 'No remittance found with this tracking number.', fa: 'حواله‌ای با این شماره پیگیری یافت نشد.'),
          backgroundColor: Colors.red, colorText: Colors.white);
      }
    } finally {
      _isTracking.value = false;
    }
  }

  void _showDisputeDialog() {
    final trx = _trackResult.value?['trx'] ?? _trxController.text.trim();
    String reason = 'NOT_RECEIVED';
    final descCtrl = TextEditingController();

    Get.dialog(StatefulBuilder(
      builder: (context, setDlgState) => AlertDialog(
        title: Text(l10nPick(context, en: 'File Dispute (30-day window)', fa: 'ثبت اختلاف حواله (مهلت ۳۰ روز)'),
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10nPick(context, en: 'Reason:', fa: 'دلیل اختلاف:')),
            DropdownButton<String>(
              isExpanded: true,
              value: reason,
              items: [
                DropdownMenuItem(value: 'NOT_RECEIVED', child: Text(l10nPick(context, en: 'Funds not received', fa: 'وجه به ذینفع نرسید'))),
                DropdownMenuItem(value: 'PARTIAL', child: Text(l10nPick(context, en: 'Less amount received', fa: 'مبلغ کمتر از فاکتور واریز شد'))),
                DropdownMenuItem(value: 'WRONG_BENEFICIARY', child: Text(l10nPick(context, en: 'Wrong account credited', fa: 'حساب اشتباه واریز شد'))),
              ],
              onChanged: (v) => setDlgState(() => reason = v ?? 'NOT_RECEIVED'),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10nPick(context, en: 'Description / bank reference', fa: 'توضیحات و شماره پیگیری بانکی'),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(l10nPick(context, en: 'Cancel', fa: 'انصراف'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Get.back();
              final ok = await _api.fileDispute(
                trx: trx,
                reasonType: reason,
                description: descCtrl.text.trim(),
              );
              if (ok) {
                Get.snackbar(l10nPick(context, en: 'Dispute Filed', fa: 'ثبت شد'),
                  l10nPick(context, en: 'Dispute opened with destination payout partner (SLA 5 business days).',
                    fa: 'پرونده اختلاف با شریک پرداخت مقصد گشوده شد (مهلت بررسی ۵ روز کاری).'),
                  backgroundColor: Colors.orange, colorText: Colors.white);
              } else {
                Get.snackbar(l10nPick(context, en: 'Error', fa: 'خطا'),
                  l10nPick(context, en: 'Failed to file dispute — ensure you are logged in.', fa: 'خطا در ثبت اختلاف — وارد حساب کاربری شوید.'),
                  backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            child: Text(l10nPick(context, en: 'Submit Dispute', fa: 'ثبت اختلاف'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10nPick(context, en: 'Track & Corridors', fa: 'رهگیری حواله و مسیرها')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10nPick(context, en: 'Public Track', fa: 'رهگیری عمومی')),
            Tab(text: l10nPick(context, en: 'Corridors', fa: 'کاتالوگ مسیرها')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // تب ۱: رهگیری عمومی
          ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              Text(l10nPick(context,
                en: 'Enter your remittance tracking number (TRX):',
                fa: 'شماره پیگیری حواله (TRX) را وارد کنید:'),
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp)),
              SizedBox(height: 8.h),
              Row(children: [
                Expanded(child: TextField(
                  controller: _trxController,
                  decoration: InputDecoration(
                    hintText: 'REM...',
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  ),
                )),
                SizedBox(width: 8.w),
                Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPrimary,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  ),
                  onPressed: _isTracking.value ? null : _track,
                  child: _isTracking.value
                    ? SizedBox(width: 16.w, height: 16.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(l10nPick(context, en: 'Track', fa: 'رهگیری'), style: const TextStyle(color: Colors.white)),
                )),
              ]),
              SizedBox(height: 16.h),
              Obx(() {
                final r = _trackResult.value;
                if (r == null) {
                  return Card(
                    color: Colors.grey.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Text(
                        l10nPick(context,
                          en: 'Track your money transfer in real-time. For security reasons, full names and amounts are hidden on public tracking.',
                          fa: 'وضعیت زنده حواله خود را پیگیری نمایید. به دلایل امنیتی، اطلاعات هویتی و مبالغ در صفحه رهگیری عمومی نمایش داده نمی‌شود.'),
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(r['trx']?.toString() ?? '', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.sp)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.lightPrimary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(r['status_label']?.toString() ?? '',
                            style: TextStyle(color: AppColors.lightPrimary, fontSize: 10.sp, fontWeight: FontWeight.w700)),
                        ),
                      ]),
                      SizedBox(height: 8.h),
                      if (r['created_at'] != null)
                        Text(l10nPick(context, en: 'Created: ${r['created_at']}', fa: 'تاریخ ثبت: ${r['created_at']}'),
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700)),
                      const Divider(),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        TextButton.icon(
                          icon: const Icon(Icons.report_problem, color: Colors.red, size: 16),
                          label: Text(l10nPick(context, en: 'File Dispute', fa: 'ثبت اختلاف حواله'),
                            style: const TextStyle(color: Colors.red)),
                          onPressed: _showDisputeDialog,
                        ),
                        Text(l10nPick(context, en: '30-day window', fa: 'مهلت ۳۰ روز'),
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                      ]),
                    ]),
                  ),
                );
              }),
            ],
          ),

          // تب ۲: کاتالوگ مسیرها
          Obx(() {
            if (_isLoadingCorridors.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_corridors.isEmpty) {
              return Center(child: Text(l10nPick(context, en: 'No corridors available', fa: 'مسیری یافت نشد')));
            }
            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: _corridors.length,
              itemBuilder: (context, i) {
                final c = _corridors[i];
                final methods = (c['payout_methods'] as List?) ?? [];

                return Card(
                  margin: EdgeInsets.only(bottom: 12.h),
                  child: Padding(
                    padding: EdgeInsets.all(14.w),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('${c['source_country']} ➔ ${c['dest_country']} (${c['dest_currency']})',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(l10nPick(context,
                            en: 'Fee ${c['fee_pct']}%',
                            fa: 'کارمزد ${c['fee_pct']}٪'),
                            style: TextStyle(fontSize: 9.sp, color: Colors.green.shade800)),
                        ),
                      ]),
                      SizedBox(height: 6.h),
                      Text(l10nPick(context,
                        en: 'Source: ${((c['source_currencies'] as List?) ?? []).join(', ')} · Min KYC: Level ${c['min_kyc_level']}',
                        fa: 'ارزهای مبدأ: ${((c['source_currencies'] as List?) ?? []).join('، ')} · حداقل احراز: سطح ${c['min_kyc_level']}'),
                        style: TextStyle(fontSize: 10.sp, color: Colors.blueGrey)),
                      SizedBox(height: 8.h),
                      Text(l10nPick(context, en: 'Payout Methods & Delivery SLA:', fa: 'روش‌های تحویل در مقصد و زمان تحویل:'),
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700)),
                      SizedBox(height: 4.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 4.h,
                        children: methods.map((m) {
                          final method = m['method']?.toString() ?? '';
                          final sla = m['sla_hours'];
                          return Chip(
                            label: Text('$method (≤${sla}h)', style: TextStyle(fontSize: 9.sp)),
                          );
                        }).toList(),
                      ),
                    ]),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
