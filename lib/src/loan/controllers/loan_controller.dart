import 'package:get/get.dart';

import '../models/loan_models.dart';
import '../services/loan_service.dart';

/// GetX controller for the Loan & Credit service (Loan-Service-Flow.md).
/// حالت‌ها از سمت سرور می‌آیند — کلاینت فقط نمایش می‌دهد (قاعده ۱ سند).
class LoanController extends GetxController {
  final LoanApiService _api = Get.find<LoanApiService>();

  final products = <LoanProductModel>[].obs;
  final myCases = <LoanCaseModel>[].obs;
  final selectedCase = Rxn<LoanCaseModel>();

  final isLoadingProducts = false.obs;
  final isLoadingCases = false.obs;
  final isLoadingDetail = false.obs;
  final isSubmitting = false.obs;

  // Form state
  final selectedProduct = Rxn<LoanProductModel>();
  final selectedTenure = 0.obs;
  final amountInput = ''.obs;

  /// Fetch product catalog
  Future<void> fetchProducts() async {
    try {
      isLoadingProducts.value = true;
      products.value = await _api.getProducts();
    } finally {
      isLoadingProducts.value = false;
    }
  }

  /// Fetch my cases
  Future<void> fetchMyCases() async {
    try {
      isLoadingCases.value = true;
      myCases.value = await _api.getMyCases();
    } finally {
      isLoadingCases.value = false;
    }
  }

  /// Fetch single case detail
  Future<void> fetchCase(int id) async {
    try {
      isLoadingDetail.value = true;
      selectedCase.value = await _api.getCase(id);
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Apply for loan — returns error code/message on failure (قانون توقف)
  Future<String?> applyForLoan() async {
    final product = selectedProduct.value;
    if (product == null) return 'ERR_PRECONDITION: محصولی انتخاب نشده است';
    final amount = double.tryParse(amountInput.value) ?? 0;
    if (amount < product.minAmount || amount > product.maxAmount) {
      return 'ERR_LIMIT_EXCEEDED: مبلغ خارج از بازه مجاز محصول است';
    }
    if (selectedTenure.value <= 0) {
      return 'ERR_PRECONDITION: مدت بازپرداخت انتخاب نشده است';
    }

    try {
      isSubmitting.value = true;
      final result = await _api.apply(
        productId: product.id,
        requestedAmount: amount,
        tenureMonths: selectedTenure.value,
      );
      if (result == null) {
        return 'ERR_NETWORK: خطا در ثبت درخواست';
      }
      await fetchMyCases();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Accept offer
  Future<bool> acceptOffer(int caseId) async {
    final ok = await _api.acceptOffer(caseId);
    if (ok) await fetchCase(caseId);
    return ok;
  }

  /// Post cash collateral
  Future<bool> postCashCollateral(int caseId, double amount, String asset) async {
    final ok = await _api.postCashCollateral(caseId, amount, asset);
    if (ok) await fetchCase(caseId);
    return ok;
  }

  /// Post crypto collateral
  Future<bool> postCryptoCollateral(int caseId, double amount, String asset) async {
    final ok = await _api.postCryptoCollateral(caseId, amount, asset);
    if (ok) await fetchCase(caseId);
    return ok;
  }

  /// Sign contract
  Future<bool> signContract(int caseId) async {
    final ok = await _api.signContract(caseId);
    if (ok) await fetchCase(caseId);
    return ok;
  }

  /// Pay installment
  Future<bool> payInstallment(int caseId, int installmentId) async {
    final ok = await _api.payInstallment(caseId, installmentId);
    if (ok) await fetchCase(caseId);
    return ok;
  }

  /// Early repayment
  Future<bool> earlyRepayment(int caseId) async {
    final ok = await _api.earlyRepayment(caseId);
    if (ok) await fetchCase(caseId);
    return ok;
  }

  /// Cancel application
  Future<bool> cancelCase(int caseId) async {
    final ok = await _api.cancel(caseId);
    if (ok) {
      selectedCase.value = null;
      await fetchMyCases();
    }
    return ok;
  }
}
