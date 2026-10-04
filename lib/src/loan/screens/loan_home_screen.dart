import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/loan_controller.dart';
import '../models/loan_models.dart';
import 'loan_application_screen.dart';
import 'loan_detail_screen.dart';
import 'loan_collateral_warning_screen.dart';
import 'loan_tracking_screen.dart';

/// Main hub for the Loans & Credit service — directly implements `loans_and_credit.html`
/// Features:
/// 1. Header: Loans
/// 2. Active loan card (Repaying, Outstanding balance, Next payment, Collateral status)
/// 3. Available loan products list (Crypto-backed, Business, Personal micro)
/// 4. Sticky Bottom CTA: "Apply for a loan"
class LoanHomeScreen extends StatefulWidget {
  const LoanHomeScreen({super.key});

  @override
  State<LoanHomeScreen> createState() => _LoanHomeScreenState();
}

class _LoanHomeScreenState extends State<LoanHomeScreen> {
  late final LoanController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LoanController>()
        ? Get.find<LoanController>()
        : Get.put(LoanController());
    controller.fetchProducts();
    controller.fetchMyCases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'تسهیلات و وام‌ها',
              en: 'Loans',
              ar: 'القروض والتسهيلات',
              zh: '贷款',
            ),
            rightSideWidget: Padding(
              padding: EdgeInsetsDirectional.only(end: ECardoTokens.space4.w),
              child: IconButton(
                icon: Icon(
                  Icons.history_rounded,
                  color: ECardoTokens.ink(context),
                  size: 22.sp,
                ),
                tooltip: l10nPick(context, fa: 'پیگیری پرونده‌ها', en: 'Tracking', ar: 'المتابعة', zh: '追踪'),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Get.to(() => const LoanTrackingScreen());
                },
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingProducts.value && controller.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeCase = controller.myCases.isNotEmpty
            ? controller.myCases.first
            : LoanController.sampleActiveLoan;

        final availableProducts = controller.products.isNotEmpty
            ? controller.products
            : LoanController.defaultProducts;

        return RefreshIndicator(
          color: ECardoTokens.brand900(context),
          onRefresh: () async {
            await controller.fetchProducts();
            await controller.fetchMyCases();
          },
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: ECardoTokens.space4.w,
              vertical: ECardoTokens.space3.h,
            ),
            children: [
              // ------------------ Active Loan Card ------------------
              _buildActiveLoanCard(context, activeCase),
              SizedBox(height: ECardoTokens.space5.h),

              // ------------------ Available Loans Header ------------------
              Text(
                l10nPick(
                  context,
                  fa: 'طرح‌های تسهیلاتی دردسترس',
                  en: 'Available loans',
                  ar: 'القروض المتاحة',
                  zh: '可用贷款方案',
                ),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: ECardoTokens.ink(context),
                ),
              ),
              SizedBox(height: ECardoTokens.space3.h),

              // ------------------ Product List Cards ------------------
              ...availableProducts.map((product) => Padding(
                    padding: EdgeInsets.only(bottom: ECardoTokens.space3.h),
                    child: _buildProductCard(context, product),
                  )),

              SizedBox(height: ECardoTokens.space8.h),
            ],
          ),
        );
      }),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(ECardoTokens.space4.r),
        decoration: BoxDecoration(
          color: ECardoTokens.surfaceCard(context),
          border: Border(top: BorderSide(color: ECardoTokens.border(context))),
          boxShadow: ECardoTokens.shadowSheet(context),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 48.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ECardoTokens.brand900(context),
                foregroundColor: ECardoTokens.inkOnBrand,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusLg.r),
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                Get.to(() => const LoanApplicationScreen());
              },
              child: Text(
                l10nPick(
                  context,
                  fa: 'درخواست تسهیلات جدید',
                  en: 'Apply for a loan',
                  ar: 'طلب قرض جديد',
                  zh: '申请贷款',
                ),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the top card for currently active / repaying loan (LN-2208)
  Widget _buildActiveLoanCard(BuildContext context, LoanCaseModel c) {
    final nextInst = c.nextInstallment;
    final nextAmount = nextInst?.amount ?? 1140.0;
    final isWarning = c.isCollateralWarning;

    return InkWell(
      borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
      onTap: () {
        HapticFeedback.lightImpact();
        Get.to(() => LoanDetailScreen(caseId: c.id));
      },
      child: Container(
        padding: EdgeInsets.all(ECardoTokens.space4.r),
        decoration: BoxDecoration(
          color: ECardoTokens.surfaceCard(context),
          borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
          border: Border.all(
            color: isWarning
                ? ECardoTokens.danger(context).withValues(alpha: 0.5)
                : ECardoTokens.border(context),
            width: isWarning ? 1.5 : 1.0,
          ),
          boxShadow: ECardoTokens.shadowCard(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top tag row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: ECardoTokens.successBg(context),
                        borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                      ),
                      child: Text(
                        l10nPick(context, fa: 'در حال بازپرداخت', en: 'Repaying'),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: ECardoTokens.success(context),
                        ),
                      ),
                    ),
                    SizedBox(width: ECardoTokens.space2.w),
                    Text(
                      c.product?.name ?? 'Crypto-backed loan',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: ECardoTokens.inkMuted(context),
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.sp,
                  color: ECardoTokens.inkMuted(context),
                ),
              ],
            ),
            SizedBox(height: ECardoTokens.space4.h),

            // Outstanding balance
            Text(
              l10nPick(context, fa: 'مانده بدهی اصل وام', en: 'Outstanding'),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: ECardoTokens.inkMuted(context),
              ),
            ),
            SizedBox(height: ECardoTokens.space1.h),
            Text(
              '${c.outstandingAmount.toStringAsFixed(2)} USD',
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w900,
                color: ECardoTokens.ink(context),
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: ECardoTokens.space3.h),

            // Next payment banner
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceSunken(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10nPick(context, fa: 'قسط بعدی (۱۲ اکتبر)', en: 'Next payment 12 Oct'),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                  Text(
                    '${nextAmount.toStringAsFixed(2)} USD',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                ],
              ),
            ),

            // Warning Banner if collateral is low
            if (isWarning) ...[
              SizedBox(height: ECardoTokens.space3.h),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Get.to(() => LoanCollateralWarningScreen(loanCase: c));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: ECardoTokens.dangerBg(context),
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: ECardoTokens.danger(context),
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            fa: 'هشدار وثیقه: پوشش ${c.coverageNowPct.toStringAsFixed(0)}٪ است · لمس برای شارژ',
                            en: 'Collateral warning: Coverage is ${c.coverageNowPct.toStringAsFixed(0)}% · Tap to top up',
                          ),
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            color: ECardoTokens.danger(context),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: ECardoTokens.danger(context),
                        size: 16.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds individual available product card
  Widget _buildProductCard(BuildContext context, LoanProductModel p) {
    return InkWell(
      borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
      onTap: () {
        HapticFeedback.lightImpact();
        controller.selectProduct(p);
        Get.to(() => const LoanApplicationScreen());
      },
      child: Container(
        padding: EdgeInsets.all(ECardoTokens.space4.r),
        decoration: BoxDecoration(
          color: ECardoTokens.surfaceCard(context),
          borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
          border: Border.all(color: ECardoTokens.border(context)),
          boxShadow: ECardoTokens.shadowCard(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & SLA Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    p.name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: ECardoTokens.brand100(context),
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                  ),
                  child: Text(
                    p.slaTag,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: ECardoTokens.brand700(context),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ECardoTokens.space1.h),

            // Tagline
            Text(
              p.tagline,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w500,
                color: ECardoTokens.inkMuted(context),
              ),
            ),
            SizedBox(height: ECardoTokens.space3.h),

            // Rate and Limit
            Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  size: 16.sp,
                  color: ECardoTokens.brand500(context),
                ),
                SizedBox(width: 6.w),
                Text(
                  '${p.interestRatePct.toStringAsFixed(1)}% a year · up to ${p.maxAmount.toInt()} USD',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: ECardoTokens.ink(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
