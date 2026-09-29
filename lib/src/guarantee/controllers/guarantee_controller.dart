import 'package:get/get.dart';

import '../models/guarantee_models.dart';
import '../services/guarantee_service.dart';

/// GetX controller for Bank Guarantee & LC service.
class GuaranteeController extends GetxController {
  final GuaranteeApiService _api = Get.find<GuaranteeApiService>();

  final instruments = <GuaranteeInstrumentModel>[].obs;
  final myCases = <GuaranteeCaseModel>[].obs;
  final selectedCase = Rxn<GuaranteeCaseModel>();

  final isLoadingInstruments = false.obs;
  final isLoadingCases = false.obs;
  final isSubmitting = false.obs;

  Future<void> fetchInstruments() async {
    try {
      isLoadingInstruments.value = true;
      instruments.value = await _api.listInstruments();
    } finally {
      isLoadingInstruments.value = false;
    }
  }

  Future<void> fetchMyCases() async {
    try {
      isLoadingCases.value = true;
      myCases.value = await _api.getMyCases();
    } finally {
      isLoadingCases.value = false;
    }
  }

  Future<void> fetchCase(int id) async {
    selectedCase.value = await _api.getCase(id);
  }

  /// Create case — returns error string or null
  Future<String?> createCase({
    required int instrumentId,
    required String beneficiaryName,
    required double amount,
    required int validityMonths,
  }) async {
    try {
      isSubmitting.value = true;
      final result = await _api.createCase(
        instrumentId: instrumentId,
        beneficiaryName: beneficiaryName,
        amount: amount,
        validityMonths: validityMonths,
      );
      if (result == null) return 'ERR_NETWORK: خطا در ایجاد پرونده';
      await fetchMyCases();
      return null;
    } catch (e) {
      return e.toString();
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
    if (ok) await fetchCase(caseId);
    return ok;
  }
}
