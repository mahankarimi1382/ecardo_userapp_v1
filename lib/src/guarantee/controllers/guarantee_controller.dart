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

  Future<void> fetchInstruments() async {
    try {
      isLoadingInstruments.value = true;
      hasBackendError.value = false;
      final result = await _api.listInstruments();
      instruments.value = result;

      if (result.isEmpty) {
        hasBackendError.value = true;
        isServiceAvailable.value = false;
      } else {
        isServiceAvailable.value = true;
        if (selectedInstrument.value == null) {
          selectedInstrument.value = result.first;
        }
      }
    } catch (_) {
      hasBackendError.value = true;
      isServiceAvailable.value = false;
      instruments.clear();
    } finally {
      isLoadingInstruments.value = false;
    }
  }

  Future<void> fetchMyCases() async {
    try {
      isLoadingCases.value = true;
      myCases.value = await _api.getMyCases();
    } catch (_) {
      myCases.clear();
    } finally {
      isLoadingCases.value = false;
    }
  }

  Future<void> fetchCase(int id) async {
    try {
      isLoadingDetail.value = true;
      selectedCase.value = await _api.getCase(id);
    } catch (_) {
      selectedCase.value = null;
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
