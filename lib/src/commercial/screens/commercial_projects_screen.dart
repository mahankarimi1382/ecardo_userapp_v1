import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/commercial_controller.dart';
import '../widgets/commercial_document_checklist.dart';
import '../widgets/equity_project_card.dart';
import '../widgets/investment_calculator_sheet.dart';
import 'equity_project_detail_screen.dart';
import 'my_investments_screen.dart';

class CommercialProjectsScreen extends StatefulWidget {
  const CommercialProjectsScreen({super.key});

  @override
  State<CommercialProjectsScreen> createState() =>
      _CommercialProjectsScreenState();
}

class _CommercialProjectsScreenState extends State<CommercialProjectsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final CommercialController controller;
  late final List<CommercialDocumentItem> _documents;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<CommercialController>()
        ? Get.find<CommercialController>()
        : Get.put(CommercialController());

    _tabController = TabController(length: 3, vsync: this);
    _documents = [
      CommercialDocumentItem(
        id: 'doc-1',
        title: 'Official Commercial Gazette / Registration Certificate',
        description: 'Latest official company registration publication',
        isMandatory: true,
        status: DocumentVerificationStatus.required,
        fileName: 'Gazette_Publication_2026.pdf',
      ),
      CommercialDocumentItem(
        id: 'doc-2',
        title: 'Board of Directors Resolution & Signing Authority',
        description: 'Authorized signatory resolution signed by board',
        isMandatory: true,
        status: DocumentVerificationStatus.required,
        fileName: 'Board_Resolution_Signatures.pdf',
      ),
      CommercialDocumentItem(
        id: 'doc-3',
        title: 'Passport / National ID of Key Shareholders (>25%)',
        description: 'Color copy of valid international passports',
        isMandatory: true,
        status: DocumentVerificationStatus.required,
      ),
      CommercialDocumentItem(
        id: 'doc-4',
        title: 'Corporate Tax Clearance / VAT Compliance Certificate',
        description: 'Official tax authority certificate of good standing',
        isMandatory: false,
        status: DocumentVerificationStatus.required,
      ),
    ];
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
        title: Text(
          l10nPick(
            context,
            en: 'Commercial & Equity Projects',
            fa: 'پروژه‌های بازرگانی و سرمایه‌گذاری',
            ar: 'المشاريع التجارية والاستثمارية',
            zh: '商业与股权投资项目',
          ),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        actions: [
          IconButton(
            icon: Icon(
              Icons.pie_chart_outline_rounded,
              color: primaryAccent,
              size: 22.sp,
            ),
            tooltip: 'پورتفوی من',
            onPressed: () {
              HapticFeedback.lightImpact();
              Get.to(() => const MyInvestmentsScreen());
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryAccent,
          unselectedLabelColor: isDark
              ? AppColors.darkTextTertiary
              : AppColors.lightTextTertiary,
          indicatorColor: primaryAccent,
          indicatorWeight: 3.h,
          isScrollable: false,
          tabs: [
            Tab(
              text: l10nPick(
                context,
                en: 'Equity Projects',
                fa: 'طرح‌های سرمایه‌گذاری',
                ar: 'مشاريع الاستثمار',
                zh: '股权项目',
              ),
            ),
            Tab(
              text: l10nPick(
                context,
                en: 'My Portfolio',
                fa: 'پورتفوی من',
                ar: 'محفظتي',
                zh: '我的持仓',
              ),
            ),
            Tab(
              text: l10nPick(
                context,
                en: 'Corporate KYC',
                fa: 'مدارک و احراز',
                ar: 'التوثيق',
                zh: '企业资质',
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Equity & Crowdfunding Projects
            _buildProjectsTab(context, isDark, primaryAccent),

            // Tab 2: My Portfolio
            _buildPortfolioTab(context, isDark, primaryAccent),

            // Tab 3: Commercial Document Checklist
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg.w,
                AppSpacing.lg.h,
                AppSpacing.lg.w,
                AppSpacing.xxl.h,
              ),
              child: CommercialDocumentChecklist(
                documents: _documents,
                onUploadTap: (doc) {
                  setState(() {
                    doc.status = DocumentVerificationStatus.underReview;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsTab(
    BuildContext context,
    bool isDark,
    Color primaryAccent,
  ) {
    final sectors = [
      {'key': 'ALL', 'label': 'همه صنایع'},
      {'key': 'Fintech', 'label': 'فین‌تک و پرداخت'},
      {'key': 'Clean Energy', 'label': 'انرژی پاک'},
      {'key': 'Agriculture', 'label': 'کشاورزی مدرن'},
    ];

    return Obx(() {
      final projects = controller.filteredProjects;
      final selectedSector = controller.selectedSector.value;

      return Column(
        children: [
          // Filter Chips
          Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
              itemCount: sectors.length,
              separatorBuilder: (_, _) => SizedBox(width: 8.w),
              itemBuilder: (context, idx) {
                final s = sectors[idx];
                final isSelected = selectedSector == s['key'];

                return ChoiceChip(
                  label: Text(
                    s['label']!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? AppColors.white
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: primaryAccent,
                  backgroundColor:
                      isDark ? AppColors.darkCard : AppColors.lightSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                    side: BorderSide(
                      color: isSelected
                          ? primaryAccent
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                    ),
                  ),
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    controller.applyFilter(s['key']!);
                  },
                );
              },
            ),
          ),
          Expanded(
            child: projects.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(AppSpacing.xxl.r),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.business_center_outlined,
                            size: 56.sp,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          SizedBox(height: AppSpacing.md.h),
                          Text(
                            l10nPick(
                              context,
                              en: 'No Projects Available in this sector',
                              fa: 'طرحی در این صنعت یافت نشد',
                            ),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg.w,
                      AppSpacing.sm.h,
                      AppSpacing.lg.w,
                      AppSpacing.xxl.h,
                    ),
                    itemCount: projects.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const _EquityNotAvailableNotice();
                      }
                      final project = projects[index - 1];
                      return InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Get.to(() => EquityProjectDetailScreen(
                                projectId: project.id,
                              ));
                        },
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radius.r),
                        child: EquityProjectCard(
                          project: project,
                          onInvestTap: () {
                            InvestmentCalculatorSheet.show(
                              context,
                              project: project,
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildPortfolioTab(
    BuildContext context,
    bool isDark,
    Color primaryAccent,
  ) {
    return Obx(() {
      final holdings = controller.myInvestments;

      if (holdings.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 56.sp,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              SizedBox(height: AppSpacing.md.h),
              Text(
                'هنوز سرمایه‌گذاری فعالی ثبت نشده است',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),
              Text(
                'طرح‌های تجاری مورد نظر خود را بررسی و سرمایه‌گذاری کنید',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return ListView(
        padding: EdgeInsets.all(AppSpacing.lg.r),
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.lg.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.darkCard, AppColors.darkSurface]
                    : [AppColors.white, const Color(0xFFF0FDF4)],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radius.r),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مجموع ارزش سهام من',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '\$${controller.totalInvestedUSD.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'سود واریزی',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '\$${controller.totalDividendsUSD.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg.h),
          ...holdings.map((h) => Container(
                margin: EdgeInsets.only(bottom: AppSpacing.md.h),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          h.projectTitle,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'فعال',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'سرمایه: ${h.amountInvested.toStringAsFixed(0)} ${h.currency} • سود سالانه: ${h.expectedYieldPercent}%',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      );
    });
  }
}

/// Prominent notice that equity crowdfunding has not launched yet.
class _EquityNotAvailableNotice extends StatelessWidget {
  const _EquityNotAvailableNotice();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.lg.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radius.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.6), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  l10nPick(
                    context,
                    en: 'Coming Soon',
                    fa: 'به‌زودی',
                    ar: 'قريباً',
                    zh: '即将上线',
                  ),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  l10nPick(
                    context,
                    en: 'Equity crowdfunding is not available yet',
                    fa: 'سرمایه‌گذاری جمعی (crowdfunding) هنوز فعال نیست',
                    ar: 'التمويل الجماعي غير متاح بعد',
                    zh: '股权众筹尚未开放',
                  ),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            l10nPick(
              context,
              en: 'The projects below are an illustrative example, not a live offering. The yields, amounts and progress shown are sample data and are not a promise of return. You can register your interest to be notified when investment opens.',
              fa: 'پروژه‌های زیر صرفاً یک نمونهٔ نمایشی است، نه یک فرصت سرمایه‌گذاری فعال. سودها، مبالغ و درصد پیشرفت نمایش‌داده‌شده داده‌های نمونه هستند و تعهدی برای بازدهی وجود ندارد. می‌توانید تمایل خود را ثبت کنید تا پس از آغاز سرمایه‌گذاری به شما اطلاع داده شود.',
              ar: 'المشاريع أدناه نموذج توضيحي وليست عرضاً حياً. العوائد والمبالغ والنسب المعروضة بيانات نموذجية وليست وعداً بعائد. يمكنك تسجيل اهتمامك ليتم إشعارك عند فتح الاستثمار.',
              zh: '以下项目仅为示例，并非真实募集。所有收益率、金额和进度均为示例数据，不构成收益承诺。您可以登记意向，待投资开放后我们将通知您。',
            ),
            style: TextStyle(
              fontSize: 11.sp,
              height: 1.6,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
