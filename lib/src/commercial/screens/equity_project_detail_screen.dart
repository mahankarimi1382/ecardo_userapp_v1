import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/commercial_controller.dart';
import '../models/commercial_models.dart';
import '../widgets/investment_calculator_sheet.dart';
import 'equity_invest_checkout_screen.dart';

class EquityProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const EquityProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<EquityProjectDetailScreen> createState() =>
      _EquityProjectDetailScreenState();
}

class _EquityProjectDetailScreenState extends State<EquityProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late final CommercialController controller;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<CommercialController>()
        ? Get.find<CommercialController>()
        : Get.put(CommercialController());

    _tabController = TabController(length: 3, vsync: this);
    controller.fetchProjectDetail(widget.projectId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: AppSpacing.iconSm.sp,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.back();
          },
        ),
        title: Text(
          l10nPick(
            context,
            fa: 'جزئیات طرح سرمایه‌گذاری',
            en: 'Investment Opportunity',
            ar: 'تفاصيل الفرصة الاستثمارية',
          ),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoadingDetail.value) {
          return Center(
            child: CircularProgressIndicator(color: primaryAccent),
          );
        }

        final detail = controller.selectedDetail.value;
        if (detail == null) {
          return Center(
            child: Text(
              l10nPick(
                context,
                fa: 'اطلاعات پروژه یافت نشد',
                en: 'Project details not found',
              ),
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg.r),
                      child: _buildHeaderCard(context, detail, isDark),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: primaryAccent,
                        unselectedLabelColor: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                        indicatorColor: primaryAccent,
                        indicatorWeight: 3.h,
                        tabs: [
                          Tab(
                            text: l10nPick(
                              context,
                              fa: 'طرح و مدل مالی',
                              en: 'Pitch & Model',
                            ),
                          ),
                          Tab(
                            text: l10nPick(
                              context,
                              fa: 'مراحل اجرایی',
                              en: 'Milestones',
                            ),
                          ),
                          Tab(
                            text: l10nPick(
                              context,
                              fa: 'اسناد و مجوزها',
                              en: 'Documents',
                            ),
                          ),
                        ],
                      ),
                      isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                    ),
                  ),
                ],
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(context, detail, isDark),
                    _buildMilestonesTab(context, detail, isDark),
                    _buildDocumentsTab(context, detail, isDark),
                  ],
                ),
              ),
            ),
            _buildStickyActionBar(context, detail, isDark),
          ],
        );
      }),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    EquityProjectDetailModel detail,
    bool isDark,
  ) {
    final project = detail.base;
    final primaryAccent =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: primaryAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                ),
                child: Text(
                  project.sector,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: primaryAccent,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      size: 14.sp,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${project.annualYieldPercent}% بازده سالانه',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          Text(
            project.title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              height: 1.3,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14.sp,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
              SizedBox(width: 4.w),
              Text(
                project.location,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg.h),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: project.progressRatio,
              minHeight: 8.h,
              backgroundColor: isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
              valueColor: AlwaysStoppedAnimation<Color>(primaryAccent),
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تأمین‌شده: ${project.raisedAmount.toStringAsFixed(0)} ${project.currency}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: primaryAccent,
                ),
              ),
              Text(
                'هدف: ${project.targetAmount.toStringAsFixed(0)} ${project.currency} (${project.progressPercent}%)',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    EquityProjectDetailModel detail,
    bool isDark,
  ) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      children: [
        Text(
          l10nPick(context, fa: 'درباره طرح و شرکت مجری', en: 'Executive Summary'),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.sm.h),
        Text(
          detail.fullDescription,
          style: TextStyle(
            fontSize: 13.sp,
            height: 1.6,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.xl.h),
        // Key Metrics Grid
        Text(
          l10nPick(context, fa: 'شاخص‌های کلیدی مالی', en: 'Financial Highlights'),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.md.h),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'ارزش‌گذاری فعلی',
                value: '${detail.valuationAmount.toStringAsFixed(0)} ${detail.base.currency}',
                icon: Icons.assessment_outlined,
                isDark: isDark,
              ),
            ),
            SizedBox(width: AppSpacing.md.w),
            Expanded(
              child: _buildMetricTile(
                title: 'سهم واگذارشده',
                value: '${detail.equityOfferedPercent}%',
                icon: Icons.pie_chart_outline,
                isDark: isDark,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md.h),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'حداقل ورود',
                value: '${detail.base.minInvestment.toStringAsFixed(0)} ${detail.base.currency}',
                icon: Icons.payments_outlined,
                isDark: isDark,
              ),
            ),
            SizedBox(width: AppSpacing.md.w),
            Expanded(
              child: _buildMetricTile(
                title: 'سرمایه‌گذاران',
                value: '${detail.totalInvestors} نفر',
                icon: Icons.people_outline,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesTab(
    BuildContext context,
    EquityProjectDetailModel detail,
    bool isDark,
  ) {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      itemCount: detail.milestones.length,
      itemBuilder: (context, index) {
        final milestone = detail.milestones[index];
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.lg.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: milestone.isCompleted
                          ? AppColors.success
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      milestone.isCompleted
                          ? Icons.check
                          : Icons.access_time_rounded,
                      size: 16.sp,
                      color: AppColors.white,
                    ),
                  ),
                  if (index != detail.milestones.length - 1)
                    Container(
                      width: 2.w,
                      height: 50.h,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                ],
              ),
              SizedBox(width: AppSpacing.md.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md.r),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              milestone.title,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              milestone.targetDate,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.lightPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        milestone.description,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocumentsTab(
    BuildContext context,
    EquityProjectDetailModel detail,
    bool isDark,
  ) {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      itemCount: detail.legalDocuments.length,
      itemBuilder: (context, index) {
        final doc = detail.legalDocuments[index];
        return Container(
          margin: EdgeInsets.only(bottom: AppSpacing.md.h),
          padding: EdgeInsets.all(AppSpacing.md.r),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                ),
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  color: AppColors.error,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: AppSpacing.md.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${doc.fileType} • ${doc.fileSize}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.download_rounded,
                  size: 20.sp,
                  color: isDark
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Get.snackbar(
                    'دریافت سند',
                    'سند ${doc.title} در حال دریافت است',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStickyActionBar(
    BuildContext context,
    EquityProjectDetailModel detail,
    bool isDark,
  ) {
    final primaryAccent =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Calculate Sheet Action Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              side: BorderSide(color: primaryAccent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
              ),
            ),
            icon: Icon(Icons.calculate_outlined, size: 18.sp, color: primaryAccent),
            label: Text(
              'محاسبه سود',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: primaryAccent,
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              InvestmentCalculatorSheet.show(
                context,
                project: detail.base,
              );
            },
          ),
          SizedBox(width: AppSpacing.md.w),
          // Invest Now CTA
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryAccent,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                ),
                elevation: 0,
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                Get.to(
                  () => EquityInvestCheckoutScreen(project: detail.base),
                );
              },
              child: Text(
                'سرمایه‌گذاری در طرح',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color _bgColor;

  _SliverAppBarDelegate(this._tabBar, this._bgColor);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _bgColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
