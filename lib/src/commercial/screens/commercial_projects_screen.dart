import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
        status: DocumentVerificationStatus.verified,
        fileName: 'Gazette_Publication_2026.pdf',
      ),
      CommercialDocumentItem(
        id: 'doc-2',
        title: 'Board of Directors Resolution & Signing Authority',
        description: 'Authorized signatory resolution signed by board',
        isMandatory: true,
        status: DocumentVerificationStatus.underReview,
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
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Equity & Crowdfunding Projects
          ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: _projects.length,
            itemBuilder: (context, index) {
              final project = _projects[index];
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
            padding: EdgeInsets.all(16.w),
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
    );
  }
}
