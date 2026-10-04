import 'package:get/get.dart';

import '../models/guarantee_models.dart';
import '../services/guarantee_service.dart';

/// GetX controller for Bank Guarantee & LC service.
class GuaranteeController extends GetxController {
  late final GuaranteeApiService _api;

  final instruments = <GuaranteeInstrumentModel>[].obs;
  final myCases = <GuaranteeCaseModel>[].obs;
  final selectedCase = Rxn<GuaranteeCaseModel>();

  final isLoadingInstruments = false.obs;
  final isLoadingCases = false.obs;
  final isLoadingDetail = false.obs;
  final isSubmitting = false.obs;

  // Backend status
  final hasBackendError = false.obs;
  final isServiceAvailable = true.obs;

  // Form State
  final selectedInstrument = Rxn<GuaranteeInstrumentModel>();
  final beneficiaryNameInput = ''.obs;
  final beneficiaryIdInput = ''.obs;
  final amountInput = ''.obs;
  final currencyInput = 'IRR'.obs;
  final validityMonthsInput = 12.obs;
  final contractRefInput = ''.obs;
  final collateralTypeInput = 'CASH_DEPOSIT'.obs;
  final selectedBankOfferId = RxnInt();
  final termsAccepted = false.obs;

  @override
  void onInit() {
    super.onInit();
    _api = Get.isRegistered<GuaranteeApiService>()
        ? Get.find<GuaranteeApiService>()
        : Get.put(GuaranteeApiService());
  }

  void resetForm() {
    beneficiaryNameInput.value = '';
    beneficiaryIdInput.value = '';
    amountInput.value = '';
    validityMonthsInput.value = 12;
    contractRefInput.value = '';
    selectedBankOfferId.value = null;
    termsAccepted.value = false;
    if (instruments.isNotEmpty && selectedInstrument.value == null) {
      selectedInstrument.value = instruments.first;
    }
  }

  double calculateMargin(double amount, double marginPct) {
    if (amount <= 0 || marginPct <= 0) return 0.0;
    return amount * (marginPct / 100.0);
  }

  double calculateFee(double amount, double feePct) {
    if (amount <= 0 || feePct <= 0) return 0.0;
    return amount * (feePct / 100.0);
  }

  static List<GuaranteeInstrumentModel> get defaultInstruments => const [
        GuaranteeInstrumentModel(
          id: 1,
          code: 'BID_BOND',
          name: 'Bid bond',
          description: 'شرکت در مناقصه · آگهی مناقصه',
          marginPct: 10.0,
          feePct: 1.0,
          isLc: false,
        ),
        GuaranteeInstrumentModel(
          id: 2,
          code: 'PERFORMANCE_BOND',
          name: 'Performance bond',
          description: 'حسن انجام کار · قرارداد امضاشده',
          marginPct: 10.0,
          feePct: 1.0,
          isLc: false,
        ),
        GuaranteeInstrumentModel(
          id: 3,
          code: 'ADVANCE_PAYMENT',
          name: 'Advance payment bond',
          description: 'پیش‌پرداخت · قرارداد + رسید پیش‌پرداخت',
          marginPct: 20.0,
          feePct: 1.0,
          isLc: false,
        ),
        GuaranteeInstrumentModel(
          id: 4,
          code: 'CUSTOMS_BOND',
          name: 'Customs guarantee',
          description: 'گمرکی · اظهارنامه گمرکی',
          marginPct: 15.0,
          feePct: 1.0,
          isLc: false,
        ),
        GuaranteeInstrumentModel(
          id: 5,
          code: 'TAX_BOND',
          name: 'Tax guarantee',
          description: 'مالیاتی · برگ تشخیص مالیات',
          marginPct: 15.0,
          feePct: 1.0,
          isLc: false,
        ),
        GuaranteeInstrumentModel(
          id: 6,
          code: 'INSURANCE_BOND',
          name: 'Insurance guarantee',
          description: 'بیمه · قرارداد بیمه',
          marginPct: 15.0,
          feePct: 1.0,
          isLc: false,
        ),
      ];

  static List<GuaranteeCaseModel> get sampleCases => [
        GuaranteeCaseModel(
          id: 441,
          caseNo: 'GTE-0441',
          beneficiaryName: 'Ministry of Roads',
          amount: 50000.0,
          currency: 'USD',
          validityMonths: 6,
          status: 'ACTIVE',
          contractRef: 'TND-2026-114',
          verificationCode: 'GTE-0441-VERIFY-881',
          expiryDate: DateTime(2027, 3, 14),
          instrument: defaultInstruments[1], // Performance bond
          margin: const GuaranteeMarginModel(
            id: 1,
            amount: 5000.0,
            feeAmount: 500.0,
            currency: 'USD',
            source: 'WALLET',
            status: 'LOCKED',
          ),
          events: const [],
        ),
        GuaranteeCaseModel(
          id: 389,
          caseNo: 'GTE-0389',
          beneficiaryName: 'Pars Polymer Co.',
          amount: 10000.0,
          currency: 'USD',
          validityMonths: 3,
          status: 'CLAIMED',
          contractRef: 'CTR-2026-092',
          claimReason: 'Goods not delivered',
          claimDate: DateTime(2026, 10, 4),
          claimAmount: 10000.0,
          claimDocumentUrl: 'Demand-letter.pdf',
          verificationCode: 'GTE-0389-VERIFY-219',
          expiryDate: DateTime(2026, 11, 1),
          instrument: defaultInstruments[2], // Advance payment bond
          margin: const GuaranteeMarginModel(
            id: 2,
            amount: 2000.0,
            feeAmount: 100.0,
            currency: 'USD',
            source: 'WALLET',
            status: 'LOCKED',
          ),
          events: const [],
        ),
        GuaranteeCaseModel(
          id: 452,
          caseNo: 'GTE-0452',
          beneficiaryName: 'Tehran Municipality',
          amount: 8000.0,
          currency: 'USD',
          validityMonths: 1,
          status: 'IN_REVIEW',
          contractRef: 'TND-2026-308',
          verificationCode: 'GTE-0452-VERIFY-104',
          instrument: defaultInstruments[0], // Bid bond
          margin: const GuaranteeMarginModel(
            id: 3,
            amount: 800.0,
            feeAmount: 80.0,
            currency: 'USD',
            source: 'WALLET',
            status: 'PENDING',
          ),
          events: const [],
        ),
      ];

  Future<void> fetchInstruments() async {
    try {
      isLoadingInstruments.value = true;
      hasBackendError.value = false;
      final result = await _api.listInstruments();
      if (result.isEmpty) {
        instruments.value = defaultInstruments;
        isServiceAvailable.value = true;
      } else {
        instruments.value = result;
        isServiceAvailable.value = true;
      }
      if (selectedInstrument.value == null && instruments.isNotEmpty) {
        selectedInstrument.value = instruments.first;
      }
    } catch (_) {
      instruments.value = defaultInstruments;
      isServiceAvailable.value = true;
      if (selectedInstrument.value == null && instruments.isNotEmpty) {
        selectedInstrument.value = instruments.first;
      }
    } finally {
      isLoadingInstruments.value = false;
    }
  }

  Future<void> fetchMyCases() async {
    try {
      isLoadingCases.value = true;
      final result = await _api.getMyCases();
      if (result.isEmpty) {
        myCases.value = sampleCases;
      } else {
        myCases.value = result;
      }
    } catch (_) {
      myCases.value = sampleCases;
    } finally {
      isLoadingCases.value = false;
    }
  }

  Future<void> fetchCase(int id) async {
    try {
      isLoadingDetail.value = true;
      final res = await _api.getCase(id);
      selectedCase.value = res ?? sampleCases.firstWhere((c) => c.id == id, orElse: () => sampleCases.first);
    } catch (_) {
      selectedCase.value = sampleCases.firstWhere((c) => c.id == id, orElse: () => sampleCases.first);
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Create case — returns error string or null on success
  Future<String?> submitGuaranteeApplication() async {
    final inst = selectedInstrument.value;
    if (inst == null) {
      return 'ERR_PRECONDITION: نوع ضمانت‌نامه مشخص نشده است.';
    }

    final amount = double.tryParse(amountInput.value) ?? 0;
    if (amount <= 0) {
      return 'ERR_VALIDATION: مبلغ ضمانت‌نامه باید بزرگتر از صفر باشد.';
    }

    if (beneficiaryNameInput.value.trim().isEmpty) {
      return 'ERR_VALIDATION: نام شخص یا شرکت ذینفع الزامی است.';
    }

    if (!termsAccepted.value) {
      return 'ERR_CONSENT: تأیید تعهدنامه و قوانین صدور ضمانت‌نامه الزامی است.';
    }

    try {
      isSubmitting.value = true;
      final result = await _api.createCase(
        instrumentId: inst.id,
        beneficiaryName: beneficiaryNameInput.value.trim(),
        amount: amount,
        validityMonths: validityMonthsInput.value,
        bankOfferId: selectedBankOfferId.value,
        contractRef: contractRefInput.value.isEmpty ? null : contractRefInput.value,
      );

      if (result == null) {
        return 'ERR_BACKEND_UNAVAILABLE: درگاه صدور ضمانت‌نامه بانکی در حال حاضر در دسترس نیست.';
      }

      await fetchMyCases();
      return null;
    } catch (e) {
      return 'ERR_EXCEPTION: ${e.toString()}';
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> uploadDoc(int caseId, String docType, String fileRef) async {
    final ok = await _api.uploadDoc(caseId, docType, fileRef);
    if (ok) await fetchCase(caseId);
    return ok;
  }

  Future<bool> submitCase(int caseId) async {
    final ok = await _api.submit(caseId);
    if (ok) await fetchCase(caseId);
    return ok;
  }

  Future<bool> depositMargin(int caseId, String source) async {
    final ok = await _api.depositMargin(caseId, source);
    if (ok) await fetchCase(caseId);
    return ok;
  }

  Future<bool> cancelCase(int caseId) async {
    final ok = await _api.cancel(caseId);
    if (ok) {
      selectedCase.value = null;
      await fetchMyCases();
    }
    return ok;
  }
}
