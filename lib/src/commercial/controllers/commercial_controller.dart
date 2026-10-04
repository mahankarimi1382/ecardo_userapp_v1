import 'package:get/get.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import '../models/commercial_models.dart';
import '../widgets/equity_project_card.dart';

class CommercialController extends GetxController {
  final RxList<EquityProjectItem> allProjects = <EquityProjectItem>[].obs;
  final RxList<EquityProjectItem> filteredProjects = <EquityProjectItem>[].obs;
  final RxList<UserInvestmentModel> myInvestments = <UserInvestmentModel>[].obs;

  final Rx<EquityProjectDetailModel?> selectedDetail = Rx<EquityProjectDetailModel?>(null);

  final RxString selectedSector = 'ALL'.obs;
  final RxBool isLoadingProjects = false.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxBool isSubmittingInvestment = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProjects();
    loadMyInvestments();
  }

  void loadProjects() {
    isLoadingProjects.value = true;
    try {
      // Seed illustrative baseline projects
      final initial = [
        const EquityProjectItem(
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
        const EquityProjectItem(
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
        const EquityProjectItem(
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

      allProjects.assignAll(initial);
      applyFilter(selectedSector.value);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingProjects.value = false;
    }
  }

  void applyFilter(String sector) {
    selectedSector.value = sector;
    if (sector == 'ALL') {
      filteredProjects.assignAll(allProjects);
    } else {
      filteredProjects.assignAll(
        allProjects.where((p) => p.sector.toLowerCase().contains(sector.toLowerCase())),
      );
    }
  }

  Future<void> fetchProjectDetail(String id) async {
    isLoadingDetail.value = true;
    try {
      final base = allProjects.firstWhere(
        (p) => p.id == id,
        orElse: () => allProjects.first,
      );

      selectedDetail.value = EquityProjectDetailModel(
        base: base,
        fullDescription:
            'This project expands regional merchant acquisition, borderless multi-currency settlement rails, and automated POS terminals for enterprise clients. Backed by corporate guarantees and audited smart contracts.',
        founderName: 'Dr. Arash Rahimi & Partners',
        companyRegistrationNo: 'CR-884920-UAE',
        valuationAmount: base.targetAmount * 4.0,
        equityOfferedPercent: 25.0,
        sharePrice: 50.0,
        totalInvestors: 142,
        galleryImages: const [],
        milestones: const [
          ProjectMilestone(
            title: 'Regulatory & Central Bank SandBox Approval',
            description: 'Approved compliance framework and capital custody license.',
            targetDate: 'Q1 2026',
            isCompleted: true,
          ),
          ProjectMilestone(
            title: 'Hardware POS Rollout (Phase 1)',
            description: 'Deploy 500 smart terminal nodes in tier-1 logistics hubs.',
            targetDate: 'Q2 2026',
            isCompleted: true,
          ),
          ProjectMilestone(
            title: 'Cross-Border Instant Settlement Rail',
            description: 'Integration with GCC & Eurasian banking payment switches.',
            targetDate: 'Q3 2026',
            isCompleted: false,
          ),
          ProjectMilestone(
            title: 'Series A Secondary Liquidity Window',
            description: 'Option for early equity participants to exit with premium.',
            targetDate: 'Q4 2026',
            isCompleted: false,
          ),
        ],
        legalDocuments: const [
          ProjectLegalDocument(
            id: 'leg-1',
            title: 'Commercial Gazette & Certificate of Incorporation',
            fileSize: '2.4 MB',
            fileType: 'PDF',
            url: '',
          ),
          ProjectLegalDocument(
            id: 'leg-2',
            title: 'Executive Financial Model & 3-Year Audited Projections',
            fileSize: '4.8 MB',
            fileType: 'PDF',
            url: '',
          ),
          ProjectLegalDocument(
            id: 'leg-3',
            title: 'Independent Legal Counsel Opinion & Custody Terms',
            fileSize: '1.9 MB',
            fileType: 'PDF',
            url: '',
          ),
        ],
        financialHighlights: {
          'grossMargin': '42.8%',
          'ebitdaForecast': '+34% YoY',
          'burnRate': 'Controlled',
          'dividendCycle': 'Quarterly',
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingDetail.value = false;
    }
  }

  void loadMyInvestments() {
    // Seed initial mock investment portfolio for active visualization
    myInvestments.assignAll([
      UserInvestmentModel(
        investmentId: 'INV-2026-8891',
        projectId: 'eq-001',
        projectTitle: 'eCardo Regional Remittance Node & Hub',
        sector: 'Fintech & Payments',
        amountInvested: 2500.0,
        currency: 'USD',
        shareCount: 50,
        expectedYieldPercent: 26.5,
        accumulatedDividends: 331.25,
        investedAt: DateTime.now().subtract(const Duration(days: 45)),
        status: 'active',
      ),
    ]);
  }

  Future<bool> executeInvestment({
    required String projectId,
    required double amount,
    required String currency,
  }) async {
    isSubmittingInvestment.value = true;
    try {
      // Simulate network / blockchain escrow settlement
      await Future.delayed(const Duration(milliseconds: 1200));

      final project = allProjects.firstWhereOrNull((p) => p.id == projectId);
      final title = project?.title ?? 'Commercial Project';
      final sector = project?.sector ?? 'General';
      final yieldPct = project?.annualYieldPercent ?? 20.0;

      final newInvestment = UserInvestmentModel(
        investmentId: 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
        projectId: projectId,
        projectTitle: title,
        sector: sector,
        amountInvested: amount,
        currency: currency,
        shareCount: (amount / 50.0).clamp(1.0, 10000.0),
        expectedYieldPercent: yieldPct,
        accumulatedDividends: 0.0,
        investedAt: DateTime.now(),
        status: 'active',
      );

      myInvestments.insert(0, newInvestment);

      // Increment raised amount locally
      final idx = allProjects.indexWhere((p) => p.id == projectId);
      if (idx != -1) {
        final current = allProjects[idx];
        allProjects[idx] = EquityProjectItem(
          id: current.id,
          title: current.title,
          sector: current.sector,
          currency: current.currency,
          targetAmount: current.targetAmount,
          raisedAmount: current.raisedAmount + amount,
          annualYieldPercent: current.annualYieldPercent,
          minInvestment: current.minInvestment,
          daysLeft: current.daysLeft,
          location: current.location,
          imageUrl: current.imageUrl,
        );
        applyFilter(selectedSector.value);
      }

      ToastHelper().showSuccessToast('سرمایه‌گذاری شما با موفقیت ثبت و تأیید شد');
      return true;
    } catch (e) {
      ToastHelper().showErrorToast('خطا در ثبت سرمایه‌گذاری: ${e.toString()}');
      return false;
    } finally {
      isSubmittingInvestment.value = false;
    }
  }

  double get totalInvestedUSD {
    return myInvestments.fold(0.0, (acc, item) {
      if (item.currency == 'USD') return acc + item.amountInvested;
      return acc + (item.amountInvested / 650000.0); // Approx conversion for IRR
    });
  }

  double get totalDividendsUSD {
    return myInvestments.fold(0.0, (acc, item) => acc + item.accumulatedDividends);
  }
}
