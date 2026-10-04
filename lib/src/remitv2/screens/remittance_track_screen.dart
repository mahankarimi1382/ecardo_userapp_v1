import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../remit_v2_service.dart';

class RemittanceTrackScreen extends StatefulWidget {
  const RemittanceTrackScreen({super.key});

  @override
  State<RemittanceTrackScreen> createState() => _RemittanceTrackScreenState();
}

class _RemittanceTrackScreenState extends State<RemittanceTrackScreen>
    with SingleTickerProviderStateMixin {
  final RemittanceV2ApiService _api = RemittanceV2ApiService();
  late final TabController _tabController;

  final TextEditingController _trxController = TextEditingController();
  final TextEditingController _calcAmountController = TextEditingController(text: '1000');

  final RxBool _isTracking = false.obs;
  final Rx<Map<String, dynamic>?> _trackResult = Rx<Map<String, dynamic>?>(null);

  final RxBool _isLoadingCorridors = false.obs;
  final RxList<Map<String, dynamic>> _corridors = <Map<String, dynamic>>[].obs;

  // Live Calculator State
  final Rx<Map<String, dynamic>?> _selectedCorridor = Rx<Map<String, dynamic>?>(null);
  final RxDouble _sendAmount = 1000.0.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCorridors();

    _calcAmountController.addListener(() {
      final val = double.tryParse(_calcAmountController.text.replaceAll(',', '')) ?? 0.0;
      _sendAmount.value = val;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _trxController.dispose();
    _calcAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadCorridors() async {
    try {
      _isLoadingCorridors.value = true;
      final list = await _api.getCorridors();
      _corridors.value = list;
      if (list.isNotEmpty && _selectedCorridor.value == null) {
        _selectedCorridor.value = list.first;
      }
    } finally {
      _isLoadingCorridors.value = false;
    }
  }

  Future<void> _track() async {
    final trx = _trxController.text.trim();
    if (trx.isEmpty) return;

    HapticFeedback.lightImpact();
    try {
      _isTracking.value = true;
      final res = await _api.publicTrack(trx);
      if (!mounted) return;
      if (res != null) {
        _trackResult.value = res;
      } else {
        Get.snackbar(
          l10nPick(context, en: 'Not Found', fa: 'یافت نشد'),
          l10nPick(context, en: 'No remittance found with this tracking number.', fa: 'حواله‌ای با این شماره پیگیری یافت نشد.'),
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
        );
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
      builder: (dlgContext, setDlgState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r)),
        title: Text(
          l10nPick(dlgContext, en: 'File Dispute (30-day window)', fa: 'ثبت اختلاف حواله (مهلت ۳۰ روز)'),
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10nPick(dlgContext, en: 'Reason:', fa: 'دلیل اختلاف:'),
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: AppSpacing.xs.h),
            DropdownButton<String>(
              isExpanded: true,
              value: reason,
              items: [
                DropdownMenuItem(value: 'NOT_RECEIVED', child: Text(l10nPick(dlgContext, en: 'Funds not received', fa: 'وجه به ذینفع نرسید'))),
                DropdownMenuItem(value: 'PARTIAL', child: Text(l10nPick(dlgContext, en: 'Less amount received', fa: 'مبلغ کمتر از فاکتور واریز شد'))),
                DropdownMenuItem(value: 'WRONG_BENEFICIARY', child: Text(l10nPick(dlgContext, en: 'Wrong account credited', fa: 'حساب اشتباه واریز شد'))),
              ],
              onChanged: (v) => setDlgState(() => reason = v ?? 'NOT_RECEIVED'),
            ),
            SizedBox(height: AppSpacing.sm.h),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              style: TextStyle(fontSize: 12.sp),
              decoration: InputDecoration(
                labelText: l10nPick(dlgContext, en: 'Description / bank reference', fa: 'توضیحات و شماره پیگیری بانکی'),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10nPick(dlgContext, en: 'Cancel', fa: 'انصراف')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r)),
            ),
            onPressed: () async {
              HapticFeedback.lightImpact();
              Get.back();
              final ok = await _api.fileDispute(
                trx: trx,
                reasonType: reason,
                description: descCtrl.text.trim(),
              );
              if (!mounted) return;
              if (ok) {
                Get.snackbar(
                  l10nPick(context, en: 'Dispute Filed', fa: 'پرونده ثبت شد'),
                  l10nPick(context, en: 'Dispute opened with destination payout partner (SLA 5 business days).', fa: 'پرونده اختلاف با شریک پرداخت مقصد گشوده شد (مهلت بررسی ۵ روز کاری).'),
                  backgroundColor: AppColors.warning,
                  colorText: AppColors.deepBlack,
                );
              } else {
                Get.snackbar(
                  l10nPick(context, en: 'Error', fa: 'خطا'),
                  l10nPick(context, en: 'Failed to file dispute — ensure you are logged in.', fa: 'خطا در ثبت اختلاف — از اتصال به حساب کاربری مطمئن شوید.'),
                  backgroundColor: AppColors.error,
                  colorText: AppColors.white,
                );
              }
            },
            child: Text(
              l10nPick(dlgContext, en: 'Submit Dispute', fa: 'ثبت اختلاف'),
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
      appBar: AppBar(
        title: Text(
          l10nPick(context, en: 'Remittance & Corridors', fa: 'حواله ارزی و مسیرها'),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            size: AppSpacing.iconSm.r,
          ),
          onPressed: () => Get.back(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
          indicatorColor: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
          indicatorWeight: 3,
          labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
          tabs: [
            Tab(text: l10nPick(context, en: 'Calculator', fa: 'محاسبه کارمزد')),
            Tab(text: l10nPick(context, en: 'Track (TRX)', fa: 'رهگیری عمومی')),
            Tab(text: l10nPick(context, en: 'Corridors', fa: 'کاتالوگ مسیرها')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // تب ۱: انتخاب مسیر و ماشین‌حساب زنده کارمزد
          _buildCalculatorTab(isDark),

          // تب ۲: رهگیری عمومی
          _buildTrackingTab(isDark),

          // تب ۳: کاتالوگ مسیرها
          _buildCorridorsCatalogTab(isDark),
        ],
      ),
    );
  }

  /// تب ۱: ماشین‌حساب زنده و انتخابگر مسیر حواله
  Widget _buildCalculatorTab(bool isDark) {
    return Obx(() {
      if (_isLoadingCorridors.value && _corridors.isEmpty) {
        return _buildSkeleton(isDark);
      }

      final corridor = _selectedCorridor.value;

      return ListView(
        padding: EdgeInsets.all(AppSpacing.lg.r),
        children: [
          // Corridor Selector Card
          Container(
            padding: EdgeInsets.all(AppSpacing.md.r),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              boxShadow: [
                BoxShadow(
                  color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(context, en: 'Select Remittance Corridor:', fa: 'انتخاب کریدور و مسیر انتقال وجه:'),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                if (_corridors.isNotEmpty)
                  DropdownButtonFormField<Map<String, dynamic>>(
                    initialValue: corridor,
                    isExpanded: true,
                    dropdownColor: isDark ? AppColors.darkSurface : AppColors.white,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.sm.h),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
                    ),
                    items: _corridors.map((c) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: c,
                        child: Text(
                          '${c['source_country']} ➔ ${c['dest_country']} (${c['dest_currency']})',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      if (val != null) {
                        _selectedCorridor.value = val;
                      }
                    },
                  ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg.h),

          // Send Amount Input Card
          Container(
            padding: EdgeInsets.all(AppSpacing.lg.r),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              boxShadow: [
                BoxShadow(
                  color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                  blurRadius: 10,
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
                      l10nPick(context, en: 'You Send Amount:', fa: 'مبلغ ارسالی شما:'),
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    if (corridor != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.darkPrimary : AppColors.lightSecondary).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          ((corridor['source_currencies'] as List?)?.firstOrNull ?? 'USD').toString(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm.h),
                TextField(
                  controller: _calcAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.payments_rounded,
                      color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                    ),
                    hintText: '1000',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
                    contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.md.h),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg.h),

          // Live Fee & SLA Calculation Breakdown (Wise Pattern)
          if (corridor != null) ...[
            _buildCalculationBreakdown(corridor, isDark),
            SizedBox(height: AppSpacing.xl.h),

            // CTA Button to Start Remittance
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                ),
                elevation: 0,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                Get.toNamed(BaseRoute.remittance);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10nPick(context, en: 'Send Money Now', fa: 'شروع حواله ارزی'),
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildCalculationBreakdown(Map<String, dynamic> corridor, bool isDark) {
    final feePct = double.tryParse('${corridor['fee_pct']}') ?? 1.2;
    final feeAmount = (_sendAmount.value * feePct) / 100.0;
    final netSend = (_sendAmount.value - feeAmount) > 0 ? (_sendAmount.value - feeAmount) : 0.0;
    final destCurrency = corridor['dest_currency'] ?? 'EUR';
    final minKyc = corridor['min_kyc_level'] ?? 1;

    // Approximate conversion rate for live preview
    final rate = destCurrency == 'IRT' ? 95000.0 : (destCurrency == 'TRY' ? 36.5 : 0.92);
    final recipientGets = netSend * rate;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10nPick(context, en: 'Transparent Breakdown:', fa: 'ریز محاسبات شفاف و لحظه‌ای:'),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.md.h),

          // Fee line
          _calcRow(
            icon: Icons.remove_circle_outline_rounded,
            iconColor: AppColors.error,
            label: '${l10nPick(context, en: 'Our Fee', fa: 'کارمزد شفاف پلتفرم')} ($feePct%)',
            value: '-${feeAmount.toStringAsFixed(2)}',
            isDark: isDark,
          ),
          SizedBox(height: AppSpacing.sm.h),

          // Mid-market rate line
          _calcRow(
            icon: Icons.sync_alt_rounded,
            iconColor: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
            label: l10nPick(context, en: 'Real Exchange Rate', fa: 'نرخ لحظه‌ای مرجع'),
            value: '1 USD ≈ ${rate.toStringAsFixed(2)} $destCurrency',
            isDark: isDark,
          ),
          SizedBox(height: AppSpacing.sm.h),

          // Recipient receives line
          _calcRow(
            icon: Icons.arrow_downward_rounded,
            iconColor: AppColors.success,
            label: l10nPick(context, en: 'Recipient Receives', fa: 'مبلغ دریافتی ذینفع'),
            value: '${_formatNumber(recipientGets)} $destCurrency',
            isBold: true,
            isDark: isDark,
          ),

          Divider(
            height: AppSpacing.xxl,
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),

          // SLA and KYC Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.bolt_rounded, size: 16.r, color: Colors.amber),
                  SizedBox(width: 4.w),
                  Text(
                    l10nPick(context, en: 'Delivery: ≤ 2 Hours', fa: 'تحویل: کمتر از ۲ ساعت'),
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.amber.shade800),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '${l10nPick(context, en: 'Min KYC', fa: 'احراز هویت')}: Level $minKyc',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calcRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool isBold = false,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: iconColor),
        SizedBox(width: AppSpacing.sm.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14.sp : 12.5.sp,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: isBold ? AppColors.success : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
        ),
      ],
    );
  }

  /// تب ۲: رهگیری عمومی
  Widget _buildTrackingTab(bool isDark) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      children: [
        Text(
          l10nPick(context, en: 'Enter remittance tracking number (TRX):', fa: 'شماره پیگیری حواله (TRX) را وارد کنید:'),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13.5.sp,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.sm.h),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _trxController,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  fontSize: 13.sp,
                ),
                decoration: InputDecoration(
                  hintText: 'REM...',
                  hintStyle: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.softGray),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.md.h),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm.w),
            Obx(
              () => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w, vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
                ),
                onPressed: _isTracking.value ? null : _track,
                child: _isTracking.value
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                      )
                    : Text(
                        l10nPick(context, en: 'Track', fa: 'رهگیری'),
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp),
                      ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg.h),
        Obx(() {
          final r = _trackResult.value;
          if (r == null) {
            return Container(
              padding: EdgeInsets.all(AppSpacing.xxl.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.fingerprint_rounded,
                    size: 40.r,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  Text(
                    l10nPick(
                      context,
                      en: 'Track your money transfer in real-time. For security reasons, full names and amounts are hidden on public tracking.',
                      fa: 'وضعیت زنده حواله خود را پیگیری نمایید. به دلایل امنیتی، اطلاعات هویتی و مبالغ در صفحه رهگیری عمومی نمایش داده نمی‌شود.',
                    ),
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Container(
            padding: EdgeInsets.all(AppSpacing.lg.r),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              boxShadow: [
                BoxShadow(
                  color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                  blurRadius: 10,
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
                      r['trx']?.toString() ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5.sp,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.darkPrimary : AppColors.lightSecondary).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                      ),
                      child: Text(
                        r['status_label']?.toString() ?? '',
                        style: TextStyle(
                          color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm.h),
                if (r['created_at'] != null)
                  Text(
                    l10nPick(context, en: 'Created: ${r['created_at']}', fa: 'تاریخ ثبت: ${r['created_at']}'),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                    ),
                  ),
                Divider(
                  height: AppSpacing.xxl,
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.report_problem_rounded, color: AppColors.error, size: 16),
                      label: Text(
                        l10nPick(context, en: 'File Dispute', fa: 'ثبت اختلاف حواله'),
                        style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _showDisputeDialog,
                    ),
                    Text(
                      l10nPick(context, en: '30-day window', fa: 'مهلت ۳۰ روز'),
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: isDark ? AppColors.darkTextTertiary : AppColors.softGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// تب ۳: کاتالوگ مسیرها
  Widget _buildCorridorsCatalogTab(bool isDark) {
    return Obx(() {
      if (_isLoadingCorridors.value && _corridors.isEmpty) {
        return _buildSkeleton(isDark);
      }
      if (_corridors.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.route_rounded, size: 48.r, color: isDark ? AppColors.darkTextSecondary : AppColors.softGray),
              SizedBox(height: AppSpacing.sm.h),
              Text(
                l10nPick(context, en: 'No corridors available', fa: 'مسیری یافت نشد'),
                style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.softGray),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
        onRefresh: _loadCorridors,
        child: ListView.separated(
          padding: EdgeInsets.all(AppSpacing.lg.r),
          itemCount: _corridors.length,
          separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
          itemBuilder: (context, i) {
            final c = _corridors[i];
            final methods = (c['payout_methods'] as List?) ?? [];

            return Container(
              padding: EdgeInsets.all(AppSpacing.md.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                    blurRadius: 10,
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
                        '${c['source_country']} ➔ ${c['dest_country']} (${c['dest_currency']})',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5.sp,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.success.withValues(alpha: 0.18) : AppColors.successContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                        ),
                        child: Text(
                          l10nPick(context, en: 'Fee ${c['fee_pct']}%', fa: 'کارمزد ${c['fee_pct']}٪'),
                          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  Text(
                    l10nPick(
                      context,
                      en: 'Source: ${((c['source_currencies'] as List?) ?? []).join(', ')} · Min KYC: Level ${c['min_kyc_level']}',
                      fa: 'ارزهای مبدأ: ${((c['source_currencies'] as List?) ?? []).join('، ')} · حداقل احراز: سطح ${c['min_kyc_level']}',
                    ),
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  Text(
                    l10nPick(context, en: 'Payout Methods & Delivery SLA:', fa: 'روش‌های تحویل در مقصد و زمان تحویل:'),
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    children: methods.map((m) {
                      final method = m['method']?.toString() ?? '';
                      final sla = m['sla_hours'];
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXs.r),
                        ),
                        child: Text(
                          '$method (≤${sla}h)',
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildSkeleton(bool isDark) {
    final baseColor = isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade300;
    final highlightColor = isDark ? AppColors.darkSurface : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.lg.r),
        itemCount: 4,
        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
        itemBuilder: (_, _) => Container(
          height: 120.h,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
          ),
        ),
      ),
    );
  }

  String _formatNumber(double number) {
    return number.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
