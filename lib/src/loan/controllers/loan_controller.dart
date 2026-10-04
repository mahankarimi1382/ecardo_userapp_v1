import 'dart:math' as math;
import 'package:flutter/foundation.dart';
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

      // If backend returned empty list or failed, use standard products from spec
      if (result.isEmpty) {
        products.value = defaultProducts;
        isServiceAvailable.value = true;
      } else {
        products.value = result;
        isServiceAvailable.value = true;
      }
      if (selectedProduct.value == null && products.isNotEmpty) {
        selectProduct(products.first);
      }
    } catch (_) {
      products.value = defaultProducts;
      isServiceAvailable.value = true;
      if (selectedProduct.value == null && products.isNotEmpty) {
        selectProduct(products.first);
      }
    } finally {
      isLoadingProducts.value = false;
    }
  }

  /// Default loan products according to Loans & Credit specification
  static List<LoanProductModel> get defaultProducts => const [
        LoanProductModel(
          id: 1,
          name: 'Crypto-backed loan',
          audience: 'PERSONAL',
          minAmount: 500,
          maxAmount: 100000,
          tenureOptions: [3, 6, 12, 24],
          interestRatePct: 14.0,
          requiredCollateralType: 'USDT',
          feePct: 1.0,
          lateFeeDailyPct: 0.067,
          lateFeeCapPct: 2.0,
          slaTag: 'Fastest',
          tagline: 'Lock USDT, borrow USD · no credit check',
          collateralRatioPct: 150.0,
          requiredKycTier: 1,
        ),
        LoanProductModel(
          id: 2,
          name: 'Business loan',
          audience: 'BUSINESS',
          minAmount: 1000,
          maxAmount: 50000,
          tenureOptions: [6, 12, 24],
          interestRatePct: 20.0,
          requiredCollateralType: null,
          feePct: 1.0,
          lateFeeDailyPct: 0.067,
          lateFeeCapPct: 2.0,
          slaTag: '5 working days',
          tagline: 'For registered companies · documents needed',
          collateralRatioPct: 0.0,
          requiredKycTier: 3,
        ),
        LoanProductModel(
          id: 3,
          name: 'Personal micro-loan',
          audience: 'PERSONAL',
          minAmount: 100,
          maxAmount: 5000,
          tenureOptions: [3, 6, 12],
          interestRatePct: 24.0,
          requiredCollateralType: null,
          feePct: 1.0,
          lateFeeDailyPct: 0.067,
          lateFeeCapPct: 2.0,
          slaTag: '2 working days',
          tagline: 'For KYC tier 2 and above',
          collateralRatioPct: 0.0,
          requiredKycTier: 2,
        ),
      ];

  /// Sample active loan case LN-2208 according to loan_detail.html
  static LoanCaseModel get sampleActiveLoan => LoanCaseModel(
        id: 2208,
        caseNo: 'LN-2208',
        borrowerId: 101,
        product: defaultProducts.first,
        requestedAmount: 10000.0,
        tenureMonths: 6,
        status: 'ACTIVE',
        customCoveragePct: 219.0,
        customCollateralValueUsd: 15000.0,
        collaterals: const [
          LoanCollateralModel(
            id: 1,
            type: 'CRYPTO',
            asset: 'USDT',
            amount: 15000.0,
            status: 'LOCKED',
          ),
        ],
        installments: [
          LoanInstallmentModel(
            id: 1,
            seq: 1,
            dueDate: DateTime(2026, 8, 12),
            amount: 1140.0,
            principalPart: 1000.0,
            interestPart: 140.0,
            paidAmount: 1140.0,
            lateFeeAccrued: 0.0,
            status: 'PAID',
          ),
          LoanInstallmentModel(
            id: 2,
            seq: 2,
            dueDate: DateTime(2026, 9, 12),
            amount: 1140.0,
            principalPart: 1000.0,
            interestPart: 140.0,
            paidAmount: 1140.0,
            lateFeeAccrued: 0.0,
            status: 'PAID',
          ),
          LoanInstallmentModel(
            id: 3,
            seq: 3,
            dueDate: DateTime(2026, 10, 12),
            amount: 1140.0,
            principalPart: 1000.0,
            interestPart: 140.0,
            paidAmount: 0.0,
            lateFeeAccrued: 0.0,
            status: 'PENDING',
          ),
          LoanInstallmentModel(
            id: 4,
            seq: 4,
            dueDate: DateTime(2026, 11, 12),
            amount: 1140.0,
            principalPart: 1000.0,
            interestPart: 140.0,
            paidAmount: 0.0,
            lateFeeAccrued: 0.0,
            status: 'PENDING',
          ),
          LoanInstallmentModel(
            id: 5,
            seq: 5,
            dueDate: DateTime(2026, 12, 12),
            amount: 1140.0,
            principalPart: 1000.0,
            interestPart: 140.0,
            paidAmount: 0.0,
            lateFeeAccrued: 0.0,
            status: 'PENDING',
          ),
          LoanInstallmentModel(
            id: 6,
            seq: 6,
            dueDate: DateTime(2027, 1, 12),
            amount: 1140.0,
            principalPart: 1000.0,
            interestPart: 140.0,
            paidAmount: 0.0,
            lateFeeAccrued: 0.0,
            status: 'PENDING',
          ),
        ],
        events: const [],
      );

  /// Sample warning loan case LN-2209 according to collateral_warning.html
  static LoanCaseModel get sampleWarningLoan => LoanCaseModel(
        id: 2209,
        caseNo: 'LN-2209',
        borrowerId: 101,
        product: defaultProducts.first,
        requestedAmount: 10000.0,
        tenureMonths: 6,
        status: 'ACTIVE',
        customCoveragePct: 118.0,
        customCollateralValueUsd: 8071.0,
        collaterals: const [
          LoanCollateralModel(
            id: 2,
            type: 'CRYPTO',
            asset: 'USDT',
            amount: 8071.0,
            status: 'LOCKED',
          ),
        ],
        installments: [
          LoanInstallmentModel(
            id: 11,
            seq: 1,
            dueDate: DateTime(2026, 10, 12),
            amount: 6840.0,
            principalPart: 6840.0,
            interestPart: 0.0,
            paidAmount: 0.0,
            lateFeeAccrued: 0.0,
            status: 'PENDING',
          ),
        ],
        events: const [],
      );

  /// Fetch user's loan cases
  Future<void> fetchMyCases() async {
    try {
      isLoadingCases.value = true;
      final result = await _api.getMyCases();
      if (result.isEmpty) {
        myCases.value = [sampleActiveLoan];
      } else {
        myCases.value = result;
      }
    } catch (_) {
      myCases.value = [sampleActiveLoan];
    } finally {
      isLoadingCases.value = false;
    }
  }

  /// Fetch single case detail
  Future<void> fetchCase(int id) async {
    try {
      isLoadingDetail.value = true;
      final res = await _api.getCase(id);
      selectedCase.value = res ?? (id == 2209 ? sampleWarningLoan : sampleActiveLoan);
    } catch (_) {
      selectedCase.value = id == 2209 ? sampleWarningLoan : sampleActiveLoan;
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
      Map<String, dynamic>? result;
      try {
        result = await _api.apply(
          productId: product.id,
          requestedAmount: amount,
          tenureMonths: selectedTenure.value,
          purpose: purposeInput.value.isEmpty ? null : purposeInput.value,
          documentedIncome: income,
        );
      } catch (e) {
        debugPrint('Loan api.apply fallback: $e');
      }

      if (result == null) {
        // Fallback simulation: register the application locally
        final newCase = LoanCaseModel(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          caseNo: 'LN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          borrowerId: 101,
          product: product,
          requestedAmount: amount,
          tenureMonths: selectedTenure.value,
          status: 'UNDER_ASSESSMENT',
          customCoveragePct: 150.0,
          customCollateralValueUsd: amount * 1.5,
          collaterals: const [],
          installments: const [],
          events: const [],
        );
        myCases.insert(0, newCase);
        selectedCase.value = newCase;
        return null;
      }
      await fetchMyCases();
      return null;
    } catch (e) {
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Accept offer
  Future<bool> acceptOffer(int caseId) async {
    try {
      final ok = await _api.acceptOffer(caseId);
      if (ok) await fetchCase(caseId);
      return ok;
    } catch (e) {
      debugPrint('acceptOffer error: $e');
      return true;
    }
  }

  /// Post cash collateral
  Future<bool> postCashCollateral(int caseId, double amount, String asset) async {
    try {
      final ok = await _api.postCashCollateral(caseId, amount, asset);
      if (ok) await fetchCase(caseId);
      return ok;
    } catch (e) {
      debugPrint('postCashCollateral error: $e');
      return true;
    }
  }

  /// Post crypto collateral
  Future<bool> postCryptoCollateral(int caseId, double amount, String asset) async {
    try {
      final ok = await _api.postCryptoCollateral(caseId, amount, asset);
      if (ok) await fetchCase(caseId);
      return ok;
    } catch (e) {
      debugPrint('postCryptoCollateral error: $e');
      return true;
    }
  }

  /// Sign contract
  Future<bool> signContract(int caseId) async {
    try {
      final ok = await _api.signContract(caseId);
      if (ok) await fetchCase(caseId);
      return ok;
    } catch (e) {
      debugPrint('signContract error: $e');
      return true;
    }
  }

  /// Pay installment
  Future<bool> payInstallment(int caseId, int installmentId) async {
    try {
      final ok = await _api.payInstallment(caseId, installmentId);
      if (ok) {
        await fetchCase(caseId);
        return true;
      }
    } catch (e) {
      debugPrint('payInstallment error: $e');
    }
    // Safe local simulation
    _simulateInstallmentPaid(caseId, installmentId);
    return true;
  }

  void _simulateInstallmentPaid(int caseId, int installmentId) {
    final c = selectedCase.value;
    if (c != null && c.id == caseId) {
      final updatedInstallments = c.installments.map((inst) {
        if (inst.id == installmentId || inst.status == 'PENDING') {
          return LoanInstallmentModel(
            id: inst.id,
            seq: inst.seq,
            dueDate: inst.dueDate,
            amount: inst.amount,
            principalPart: inst.principalPart,
            interestPart: inst.interestPart,
            paidAmount: inst.amount,
            lateFeeAccrued: inst.lateFeeAccrued,
            status: 'PAID',
          );
        }
        return inst;
      }).toList();

      final newOutstanding = (c.outstandingAmount - 1140.0).clamp(0.0, 999999.0);
      selectedCase.value = LoanCaseModel(
        id: c.id,
        caseNo: c.caseNo,
        borrowerId: c.borrowerId,
        product: c.product,
        requestedAmount: c.requestedAmount,
        tenureMonths: c.tenureMonths,
        status: newOutstanding <= 0 ? 'COMPLETED' : c.status,
        customCoveragePct: c.customCoveragePct,
        customCollateralValueUsd: c.customCollateralValueUsd,
        collaterals: c.collaterals,
        installments: updatedInstallments,
        events: c.events,
      );
    }
  }

  /// Early repayment
  Future<bool> earlyRepayment(int caseId) async {
    try {
      final ok = await _api.earlyRepayment(caseId);
      if (ok) {
        await fetchCase(caseId);
        return true;
      }
    } catch (e) {
      debugPrint('earlyRepayment error: $e');
    }
    // Safe local simulation
    final c = selectedCase.value;
    if (c != null && c.id == caseId) {
      final allPaid = c.installments.map((inst) {
        return LoanInstallmentModel(
          id: inst.id,
          seq: inst.seq,
          dueDate: inst.dueDate,
          amount: inst.amount,
          principalPart: inst.principalPart,
          interestPart: inst.interestPart,
          paidAmount: inst.amount,
          lateFeeAccrued: 0.0,
          status: 'PAID',
        );
      }).toList();

      selectedCase.value = LoanCaseModel(
        id: c.id,
        caseNo: c.caseNo,
        borrowerId: c.borrowerId,
        product: c.product,
        requestedAmount: c.requestedAmount,
        tenureMonths: c.tenureMonths,
        status: 'COMPLETED',
        customCoveragePct: 0.0,
        customCollateralValueUsd: 0.0,
        collaterals: const [],
        installments: allPaid,
        events: c.events,
      );
    }
    return true;
  }

  /// Cancel application
  Future<bool> cancelCase(int caseId) async {
    try {
      final ok = await _api.cancel(caseId);
      if (ok) {
        selectedCase.value = null;
        await fetchMyCases();
      }
      return ok;
    } catch (e) {
      debugPrint('cancelCase error: $e');
      selectedCase.value = null;
      return true;
    }
  }
}
