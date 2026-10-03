import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../widgets/commercial_document_checklist.dart';
import '../widgets/equity_project_card.dart';
import '../widgets/investment_calculator_sheet.dart';

class CommercialProjectsScreen extends StatefulWidget {
  const CommercialProjectsScreen({super.key});

  @override
  State<CommercialProjectsScreen> createState() =>
      _CommercialProjectsScreenState();
}

class _CommercialProjectsScreenState extends State<CommercialProjectsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<EquityProjectItem> _projects = const [
    // SAMPLE DATA ONLY. Equity crowdfunding is not live and no API supplies
    // these projects; every figure below is illustrative and must stay labelled
    // as such in the UI.
    EquityProjectItem(
      id: 'eq-001',
      title: 'eCardo Regional Remittance Node & Payment Terminal Hub',
      sector: 'Fintech & Payments',
      currency: 'USD',
      targetAmount: 500000.0,
      raisedAmount: 385000.0,
      annualYieldPercent: 26.5,
      minInvestment: 500.0,
      daysLeft: 18,
      location: 'Dubai Internet City, UAE 🇦🇪',
    ),
    EquityProjectItem(
      id: 'eq-002',
      title: 'Solar Clean Energy Micro-Grid Phase 2',
      sector: 'Clean Energy & Infrastructure',
      currency: 'USD',
      targetAmount: 1200000.0,
      raisedAmount: 840000.0,
      annualYieldPercent: 21.0,
      minInvestment: 1000.0,
      daysLeft: 34,
      location: 'Antalya Solar Park, Turkey 🇹🇷',
    ),
    EquityProjectItem(
      id: 'eq-003',
      title: 'Smart Agri-Tech Cold Chain Logistics Network',
      sector: 'Agriculture & Supply Chain',
      currency: 'IRR',
      targetAmount: 50000000000.0,
      raisedAmount: 42000000000.0,
      annualYieldPercent: 32.0,
      minInvestment: 50000000.0,
      daysLeft: 12,
      location: 'Shiraz Agro-Industrial Zone, Iran 🇮🇷',
    ),
  ];

  late final List<CommercialDocumentItem> _documents;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _documents = [
      CommercialDocumentItem(
        id: 'doc-1',
        title: 'Official Commercial Gazette / Registration Certificate',
        description: 'Latest official company registration publication',
        isMandatory: true,
        // No verification API backs this list, so nothing here may be shown
        // as verified or under review.
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
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
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
            color: AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.lightPrimary,
          unselectedLabelColor: AppColors.lightTextTertiary,
          indicatorColor: AppColors.lightPrimary,
          indicatorWeight: 3.h,
          isScrollable: false,
          tabs: [
            Tab(
              text: l10nPick(
                context,
                en: 'Equity Projects',
                fa: 'پروژه‌های سهام و سرمایه‌گذاری',
                ar: 'مشاريع الاستثمار',
                zh: '股权项目',
              ),
            ),
            Tab(
              text: l10nPick(
                context,
                en: 'Corporate KYC',
                fa: 'مدارک و احراز شرکتی',
                ar: 'التوثيق التجاري',
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
            ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              itemCount: _projects.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return const _EquityNotAvailableNotice();
                final project = _projects[index - 1];
                return EquityProjectCard(
                  project: project,
                  onInvestTap: () {
                    InvestmentCalculatorSheet.show(
                      context,
                      project: project,
                    );
                  },
                );
              },
            ),

            // Tab 2: Commercial Document Checklist
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
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
}

/// Prominent notice that equity crowdfunding has not launched yet.
///
/// Without it the sample projects below read as live offerings with real
/// yields and funding progress, which is not true — no API supplies them.
class _EquityNotAvailableNotice extends StatelessWidget {
  const _EquityNotAvailableNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16.r),
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
                  style: TextStyle(
                    fontSize: 10.sp,
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
                    color: AppColors.lightTextPrimary,
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
              color: AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
