import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/constants/assets_path/svg/svg_assets.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/controller/epay_card_controller.dart';

/// WAVE-REVIEW: سکشن PayCardo در My Cards — کارت‌های دلاری که با تتر
/// شارژ می‌شوند. سبک رندر هم‌ترازِ بقیه صفحه (site-tiles + l10nPick).
class EpayCardsSection extends StatelessWidget {
  const EpayCardsSection({super.key});

  String _pick(
    BuildContext context, {
    required String en,
    required String fa,
    String? ar,
    String? zh,
  }) =>
      l10nPick(context, en: en, fa: fa, ar: ar, zh: zh);

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<EpayCardController>()
        ? Get.find<EpayCardController>()
        : Get.put(EpayCardController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
          child: Row(
            children: [
              Text(
                _pick(
                  context,
                  en: 'PayCardo (USD)',
                  fa: 'پی‌کاردو (دلاری)',
                  ar: 'PayCardo (دولار)',
                  zh: 'PayCardo（美元）',
                ),
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w900,
                  fontSize: 16.sp,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => controller.fetchEpayCards(),
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 22.sp,
                  color: AppColors.lightPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (controller.epayCards.isEmpty) {
            return Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
              child: CommonButton(
                isLoading: controller.isActionLoading.value,
                onPressed: controller.isActionLoading.value
                    ? null
                    : () => controller.issueCard(),
                width: double.infinity,
                text: _pick(
                  context,
                  en: 'Issue a PayCardo card',
                  fa: 'صدور کارت پی‌کاردو',
                  ar: 'إصدار بطاقة PayCardo',
                  zh: '发行 PayCardo 卡',
                ),
              ),
            );
          }
          return Column(
            children: [
              for (final card in controller.epayCards)
                Container(
                  margin: EdgeInsetsDirectional.only(start: 18.w, end: 18.w, bottom: 16.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.r),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFBEA8FD), Color(0xFF9876F5)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9E7EF8).withValues(alpha: 0.30),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // World map watermark
                      Positioned.fill(
                        child: Center(
                          child: Opacity(
                            opacity: 0.18,
                            child: Image.asset(
                              PngAssets.cardMap,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      // Translucent angled shield
                      PositionedDirectional(
                        top: 0,
                        start: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: 0.14,
                            child: SvgPicture.asset(
                              SvgAssets.cardShape,
                              fit: BoxFit.fill,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  PngAssets.cardVisa,
                                  width: 48.w,
                                  height: 16.h,
                                  fit: BoxFit.contain,
                                ),
                                const Spacer(),
                                Image.asset(
                                  PngAssets.cardChip,
                                  width: 36.w,
                                  height: 26.h,
                                ),
                              ],
                            ),
                            SizedBox(height: 14.h),
                            Text(
                              'PayCardo (USD)',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              (card['card_number_masked'] ?? '•••• •••• •••• ••••').toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 17.sp,
                                letterSpacing: 2.0,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _pick(
                                        context,
                                        en: 'Balance',
                                        fa: 'موجودی',
                                        ar: 'الرصيد',
                                        zh: '余额',
                                      ),
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.75),
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      '${((card['balance'] ?? 0) as num).toStringAsFixed(2)} '
                                      '${(card['currency_code'] ?? 'USD')}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 14.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (card['status'] == 'active')
                                        ? const Color(0xFFD4F4D2)
                                        : const Color(0xFFFDE8E8),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    (card['status'] ?? '').toString().toUpperCase(),
                                    style: TextStyle(
                                      color: (card['status'] == 'active')
                                          ? const Color(0xFF2E7238)
                                          : const Color(0xFFC53030),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (card['status'] == 'active')
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.r),
                                        side: BorderSide(
                                          color: Colors.white.withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ),
                                    onPressed: controller.isActionLoading.value
                                        ? null
                                        : () => _showTopupSheet(
                                              context,
                                              controller,
                                            ),
                                    child: Text(
                                      _pick(
                                        context,
                                        en: 'Top up',
                                        fa: 'شارژ',
                                        ar: 'شحن',
                                        zh: '充值',
                                      ),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
                child: CommonButton(
                  isLoading: controller.isActionLoading.value,
                  onPressed: controller.isActionLoading.value
                      ? null
                      : () => controller.issueCard(),
                  width: double.infinity,
                  text: _pick(
                    context,
                    en: 'Issue another card',
                    fa: 'صدور کارت دیگر',
                    ar: 'إصدار بطاقة أخرى',
                    zh: '发行新卡',
                  ),
                ),
              ),
              SizedBox(height: 12.h),
            ],
          );
        }),
      ],
    );
  }

  void _showTopupSheet(
    BuildContext context,
    EpayCardController controller,
  ) {
    final amountController = TextEditingController();
    final pick = ({
      required String en,
      required String fa,
      String? ar,
      String? zh,
    }) =>
        l10nPick(context, en: en, fa: fa, ar: ar, zh: zh);

    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pick(en: 'Top up PayCardo card', fa: 'شارژ کارت پی‌کاردو',
                    ar: 'شحن بطاقة PayCardo', zh: '充值 PayCardo 卡'),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16.sp,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                pick(
                  en: 'Funded from your USDT/USD wallet — 2% fee applies.',
                  fa: 'از کیف تتر/دلار شما شارژ می‌شود — کارمزد ۲٪ دارد.',
                  ar: 'يُشحن من محفظة USDT/USD — رسوم ٢٪.',
                  zh: '从 USDT/USD 钱包扣款 — 收取 2% 手续费。',
                ),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.lightTextTertiary,
                ),
              ),
              SizedBox(height: 14.h),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'USD',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Obx(
                () => CommonButton(
                  isLoading: controller.isActionLoading.value,
                  onPressed: controller.isActionLoading.value
                      ? null
                      : () {
                          final amount =
                              double.tryParse(amountController.text.trim());
                          if (amount == null) {
                            Navigator.of(context).pop();
                            return;
                          }
                          Navigator.of(context).pop();
                          controller.topUpCard(amount);
                        },
                  width: double.infinity,
                  text: pick(en: 'Top up', fa: 'شارژ', ar: 'شحن', zh: '充值'),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
    );
  }
}
