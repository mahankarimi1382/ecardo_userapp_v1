import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/guarantee_controller.dart';
import '../models/guarantee_models.dart';
import 'guarantee_application_screen.dart';
import 'guarantee_called_screen.dart';
import 'guarantee_detail_screen.dart';
import 'guarantee_tracking_screen.dart';

/// Main hub for the Bank Guarantee & LC service — matches `guarantees.html`
/// Features:
/// 1. Header: Guarantees
/// 2. Filter tabs: All | Active | In review | Closed
/// 3. Hero summary: Blocked as margin $7,500 | Across 2 active guarantees | $60,000 covered
/// 4. Guarantee items cards (Performance bond, Advance payment bond with claim notice, Bid bond)
/// 5. Sticky Bottom CTA: "Request a guarantee"
class GuaranteeHomeScreen extends StatefulWidget {
  const GuaranteeHomeScreen({super.key});

  @override
  State<GuaranteeHomeScreen> createState() => _GuaranteeHomeScreenState();
}

class _GuaranteeHomeScreenState extends State<GuaranteeHomeScreen> {
  late final GuaranteeController controller;
  int _selectedFilterIndex = 0;

  final List<String> _filters = ['All', 'Active', 'In review', 'Closed'];

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<GuaranteeController>()
        ? Get.find<GuaranteeController>()
        : Get.put(GuaranteeController());
    controller.fetchInstruments();
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
              fa: 'ضمانت‌نامه‌ها',
              en: 'Guarantees',
              ar: 'خطابات الضمان',
              zh: '银行保函',
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
                  Get.to(() => const GuaranteeTrackingScreen());
                },
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingCases.value && controller.myCases.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final allCases = controller.myCases.isNotEmpty
            ? controller.myCases
            : GuaranteeController.sampleCases;

        // Calculate summary metrics
        final activeAndClaimed = allCases.where((c) => c.isActive || c.isClaimed);
        final totalMarginBlocked = activeAndClaimed.fold(0.0, (sum, c) => sum + c.marginAmount);
        final totalCovered = activeAndClaimed.fold(0.0, (sum, c) => sum + c.amount);

        // Filter list by selected tab
        List<GuaranteeCaseModel> filteredCases;
        switch (_selectedFilterIndex) {
          case 1: // Active
            filteredCases = allCases.where((c) => c.isActive || c.isClaimed).toList();
            break;
          case 2: // In review
            filteredCases = allCases.where((c) => c.isInReview).toList();
            break;
          case 3: // Closed
            filteredCases = allCases.where((c) => c.isClosed).toList();
            break;
          default:
            filteredCases = allCases.toList();
        }

        return RefreshIndicator(
          color: ECardoTokens.brand900(context),
          onRefresh: () async {
            await controller.fetchInstruments();
            await controller.fetchMyCases();
          },
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: ECardoTokens.space4.w,
              vertical: ECardoTokens.space3.h,
            ),
            children: [
              // ------------------ Filter Chips ------------------
              SizedBox(
                height: 36.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, _) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedFilterIndex == index;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedFilterIndex = index);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ECardoTokens.brand900(context)
                              : ECardoTokens.surfaceCard(context),
                          borderRadius: BorderRadius.circular(ECardoTokens.radiusFull.r),
                          border: Border.all(
                            color: isSelected
                                ? ECardoTokens.brand900(context)
                                : ECardoTokens.border(context),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _filterLabel(context, _filters[index]),
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : ECardoTokens.ink(context),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: ECardoTokens.space4.h),

              // ------------------ Hero Summary Card ------------------
              Container(
                width: double.infinity,
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
                    Text(
                      l10nPick(context, fa: 'مارجین بلوکه‌شده در کیف پول', en: 'Blocked as margin'),
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: ECardoTokens.inkMuted(context),
                      ),
                    ),
                    SizedBox(height: ECardoTokens.space1.h),
                    Text(
                      '${totalMarginBlocked.toStringAsFixed(2)} USD',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w900,
                        color: ECardoTokens.ink(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: ECardoTokens.space2.h),
                    Row(
                      children: [
                        Text(
                          l10nPick(
                            context,
                            fa: 'در ۲ ضمانت‌نامه فعال · ',
                            en: 'Across ${activeAndClaimed.length} active guarantees · ',
                          ),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: ECardoTokens.inkMuted(context),
                          ),
                        ),
                        Text(
                          '${totalCovered.toStringAsFixed(2)} USD covered',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: ECardoTokens.brand500(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: ECardoTokens.space5.h),

              // ------------------ Guarantees List ------------------
              ...filteredCases.map((c) => Padding(
                    padding: EdgeInsets.only(bottom: ECardoTokens.space3.h),
                    child: _buildGuaranteeCard(context, c),
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
                Get.to(() => const GuaranteeApplicationScreen());
              },
              child: Text(
                l10nPick(
                  context,
                  fa: 'درخواست صدور ضمانت‌نامه',
                  en: 'Request a guarantee',
                  ar: 'طلب خطاب ضمان',
                  zh: '申请开立保函',
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

  Widget _buildGuaranteeCard(BuildContext context, GuaranteeCaseModel c) {
    final isClaimed = c.isClaimed;
    final isActive = c.isActive;

    return InkWell(
      borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
      onTap: () {
        HapticFeedback.lightImpact();
        if (isClaimed) {
          Get.to(() => GuaranteeCalledScreen(guaranteeCase: c));
        } else {
          Get.to(() => GuaranteeDetailScreen(caseId: c.id, initialCase: c));
        }
      },
      child: Container(
        padding: EdgeInsets.all(ECardoTokens.space4.r),
        decoration: BoxDecoration(
          color: ECardoTokens.surfaceCard(context),
          borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
          border: Border.all(
            color: isClaimed
                ? ECardoTokens.danger(context).withValues(alpha: 0.5)
                : ECardoTokens.border(context),
            width: isClaimed ? 1.5 : 1.0,
          ),
          boxShadow: ECardoTokens.shadowCard(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Type and Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    c.instrument?.name ?? 'Guarantee',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: isClaimed
                        ? ECardoTokens.dangerBg(context)
                        : isActive
                            ? ECardoTokens.successBg(context)
                            : ECardoTokens.brand100(context),
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                  ),
                  child: Text(
                    isClaimed
                        ? l10nPick(context, fa: 'مطالبه‌شده', en: 'Claimed')
                        : isActive
                            ? l10nPick(context, fa: 'فعال', en: 'Active')
                            : l10nPick(context, fa: 'در بررسی', en: 'In review'),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: isClaimed
                          ? ECardoTokens.danger(context)
                          : isActive
                              ? ECardoTokens.success(context)
                              : ECardoTokens.brand700(context),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),

            // Beneficiary
            Text(
              'For · ${c.beneficiaryName}',
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: ECardoTokens.inkMuted(context),
              ),
            ),
            SizedBox(height: ECardoTokens.space2.h),

            // Amount
            Text(
              '${c.amount.toStringAsFixed(2)} USD',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: ECardoTokens.ink(context),
              ),
            ),
            SizedBox(height: 4.h),

            // Subtext: Expiry & margin or claim urgency
            if (isClaimed) ...[
              Container(
                margin: EdgeInsets.only(top: 4.h),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: ECardoTokens.dangerBg(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: ECardoTokens.danger(context),
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      l10nPick(
                        context,
                        fa: 'ذینفع ضمانت‌نامه را مطالبه کرده · ۵ روز مهلت دارید',
                        en: 'Beneficiary called it · you have 5 days',
                      ),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: ECardoTokens.danger(context),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (isActive) ...[
              Text(
                'Expires 14 Mar 2027 · margin ${c.marginAmount.toStringAsFixed(2)} USD',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: ECardoTokens.inkMuted(context),
                ),
              ),
            ] else ...[
              Text(
                'Submitted 2 Oct · decision within 2 days',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: ECardoTokens.inkMuted(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _filterLabel(BuildContext context, String filter) {
    switch (filter) {
      case 'Active':
        return l10nPick(context, fa: 'فعال', en: 'Active');
      case 'In review':
        return l10nPick(context, fa: 'در بررسی', en: 'In review');
      case 'Closed':
        return l10nPick(context, fa: 'مختومه', en: 'Closed');
      default:
        return l10nPick(context, fa: 'همه', en: 'All');
    }
  }
}
