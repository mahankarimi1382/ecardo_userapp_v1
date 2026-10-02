import 'dart:math' as math;
import 'package:get/get.dart';

import '../models/loan_models.dart';
import '../services/loan_service.dart';

/// GetX controller for the Loan & Credit service.
/// Provides reactive state for products, user applications, calculations,
/// and backend availability detection.
class LoanController extends GetxController {
  late final LoanApiService _api;

  final products = <LoanProductModel>[].obs;
  final myCases = <LoanCaseModel>[].obs;
  final selectedCase = Rxn<LoanCaseModel>();

  final isLoadingProducts = false.obs;
  final isLoadingCases = false.obs;
  final isLoadingDetail = false.obs;
  final isSubmitting = false.obs;

  // Backend connection status
  final hasBackendError = false.obs;
  final isServiceAvailable = true.obs;

  // Form state for new loan application
  final selectedProduct = Rxn<LoanProductModel>();
  final selectedTenure = 0.obs;
  final graceMonthsInput = 0.obs;
  final amountInput = ''.obs;
  final purposeInput = ''.obs;
  final documentedIncomeInput = ''.obs;
  final collateralTypeInput = 'CASH'.obs;
  final guarantorNationalIdInput = ''.obs;
  final termsAccepted = false.obs;

  @override
  void onInit() {
    super.onInit();
    _api = Get.isRegistered<LoanApiService>()
        ? Get.find<LoanApiService>()
        : Get.put(LoanApiService());
  }

  /// Reset application form fields
  void resetForm() {
    amountInput.value = '';
    purposeInput.value = '';
    documentedIncomeInput.value = '';
    collateralTypeInput.value = 'CASH';
    guarantorNationalIdInput.value = '';
    graceMonthsInput.value = 0;
    termsAccepted.value = false;
    if (products.isNotEmpty && selectedProduct.value == null) {
      selectProduct(products.first);
    }
  }

  /// Select a loan product
  void selectProduct(LoanProductModel product) {
    selectedProduct.value = product;
    if (product.tenureOptions.isNotEmpty) {
      selectedTenure.value = product.tenureOptions.first;
    }
  }

  /// Calculate estimated monthly installment using standard amortization formula:
  /// EMI = [P x R x (1+R)^N] / [(1+R)^N - 1]
  /// Grace period interest-only months are accounted for by amortizing principal over
  /// the remaining amortizing months (tenure - grace).
  double calculateMonthlyInstallment({
    required double principal,
    required double annualInterestRatePct,
    required int tenureMonths,
    int gracePeriodMonths = 0,
  }) {
    if (principal <= 0 || tenureMonths <= 0) return 0.0;
    final graceMonths =
        gracePeriodMonths.clamp(0, math.max(0, tenureMonths - 1)).toInt();
    final amortizingMonths = math.max(1, tenureMonths - graceMonths);

    if (annualInterestRatePct <= 0) return principal / amortizingMonths;

    final monthlyRate = (annualInterestRatePct / 100.0) / 12.0;
    final factor = math.pow(1.0 + monthlyRate, amortizingMonths).toDouble();
    if (factor <= 1.0) return principal / amortizingMonths;

    return (principal * monthlyRate * factor) / (factor - 1.0);
  }

  /// Total repayment amount including grace period interest payments and principal amortization
  double calculateTotalRepayment({
    required double principal,
    required double annualInterestRatePct,
    required int tenureMonths,
    int gracePeriodMonths = 0,
  }) {
    if (principal <= 0 || tenureMonths <= 0) return 0.0;
    // `int.clamp` is declared on `num`, so it returns `num`, not `int`.
    // Without this the value fails to satisfy the `int` parameter below.
    final graceMonths =
        gracePeriodMonths.clamp(0, math.max(0, tenureMonths - 1)).toInt();
    final monthlyRate = (annualInterestRatePct / 100.0) / 12.0;
    final graceInterest = graceMonths * (principal * monthlyRate);

    final emi = calculateMonthlyInstallment(
      principal: principal,
      annualInterestRatePct: annualInterestRatePct,
      tenureMonths: tenureMonths,
      gracePeriodMonths: graceMonths,
    );
    final amortizingMonths = math.max(1, tenureMonths - graceMonths);
    return principal + graceInterest + math.max(0.0, (emi * amortizingMonths) - principal);
  }

  /// Fetch product catalog
  Future<void> fetchProducts() async {
    try {
      isLoadingProducts.value = true;
      hasBackendError.value = false;
      final result = await _api.getProducts();
      products.value = result;

      // If backend returned empty list or failed, mark status
      if (result.isEmpty) {
        hasBackendError.value = true;
        isServiceAvailable.value = false;
      } else {
        isServiceAvailable.value = true;
        if (selectedProduct.value == null) {
          selectProduct(result.first);
        }
      }
    } catch (_) {
      hasBackendError.value = true;
      isServiceAvailable.value = false;
      products.clear();
    } finally {
      isLoadingProducts.value = false;
    }
  }

  /// Fetch user's loan cases
  Future<void> fetchMyCases() async {
    try {
      isLoadingCases.value = true;
      final result = await _api.getMyCases();
      myCases.value = result;
    } catch (_) {
      myCases.clear();
    } finally {
      isLoadingCases.value = false;
    }
  }

  /// Fetch single case detail
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

  /// Apply for loan — returns error message on failure or null on success
  Future<String?> applyForLoan() async {
    final product = selectedProduct.value;
    if (product == null) {
      return 'ERR_PRECONDITION: لطفاً یک محصول تسهیلاتی انتخاب کنید.';
    }

    final amount = double.tryParse(amountInput.value) ?? 0;
    if (amount <= 0) {
      return 'ERR_VALIDATION: مبلغ درخواستی نامعتبر است.';
    }
    if (amount < product.minAmount || amount > product.maxAmount) {
      return 'ERR_LIMIT_EXCEEDED: مبلغ خارج از سقف مجاز این طرح است (${product.minAmount.toInt()} تا ${product.maxAmount.toInt()}).';
    }
    if (selectedTenure.value <= 0) {
      return 'ERR_PRECONDITION: مدت بازپرداخت را مشخص کنید.';
    }
    if (!termsAccepted.value) {
      return 'ERR_CONSENT: تأیید شرایط و قوانین دریافت تسهیلات الزامی است.';
    }

    try {
      isSubmitting.value = true;
      final income = double.tryParse(documentedIncomeInput.value);
      final result = await _api.apply(
        productId: product.id,
        requestedAmount: amount,
        tenureMonths: selectedTenure.value,
        purpose: purposeInput.value.isEmpty ? null : purposeInput.value,
        documentedIncome: income,
      );

      if (result == null) {
        // If backend returned null/404, notify gracefully
        return 'ERR_BACKEND_UNAVAILABLE: درگاه ثبت تسهیلات بانکی در حال حاضر در دسترس نیست. لطفاً بعداً تلاش فرمایید.';
      }
      await fetchMyCases();
      return null;
    } catch (e) {
      return 'ERR_EXCEPTION: ${e.toString()}';
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
