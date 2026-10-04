import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:get/get.dart' as getx;

import '../models/loan_models.dart';

/// Loan & Credit Service API client — endpoints: /loan/*
class LoanApiService extends getx.GetxService {
  final NetworkService _network = getx.Get.find<NetworkService>();

  /// Catalog of active loan products (کاتالوگ = داده، نه کد)
  Future<List<LoanProductModel>> getProducts() async {
    final response = await _network.get(endpoint: '/loan/products');
    if (response.status == Status.completed && response.data != null) {
      final list = response.data!['data']?['products'] as List?;
      if (list != null) {
        return list
            .map((e) => LoanProductModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    }
    return [];
  }

  /// My loan cases
  Future<List<LoanCaseModel>> getMyCases() async {
    final response = await _network.get(endpoint: '/loan/my');
    if (response.status == Status.completed && response.data != null) {
      final list = response.data!['data']?['cases'] as List?;
      if (list != null) {
        return list
            .map((e) => LoanCaseModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    }
    return [];
  }

  /// Case detail with timeline
  Future<LoanCaseModel?> getCase(int id) async {
    final response = await _network.get(endpoint: '/loan/cases/$id');
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data']?['case'];
      if (data is Map<String, dynamic>) {
        return LoanCaseModel.fromJson(data);
      }
    }
    return null;
  }

  /// Apply for a loan (گام ۱ + سنجش فوری) — BTN_APPLY_LOAN
  Future<Map<String, dynamic>?> apply({
    required int productId,
    required double requestedAmount,
    required int tenureMonths,
    String? purpose,
    double? documentedIncome,
  }) async {
    final response = await _network.post(endpoint: '/loan/apply', data: {
      'product_id': productId,
      'requested_amount': requestedAmount,
      'tenure_months': tenureMonths,
      'purpose': purpose,
      'documented_income': documentedIncome,
    });
    if (response.status == Status.completed && response.data != null) {
      return response.data!['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// Accept offer (گام ۳) — BTN_ACCEPT_OFFER
  Future<bool> acceptOffer(int caseId) async {
    final response = await _network.post(endpoint: '/loan/cases/$caseId/accept-offer', data: {});
    return response.status == Status.completed;
  }

  /// Post cash collateral — BTN_POST_CASH
  Future<bool> postCashCollateral(int caseId, double amount, String asset) async {
    final response = await _network.post(endpoint: '/loan/cases/$caseId/collateral/cash', data: {
      'amount': amount,
      'asset': asset,
    });
    return response.status == Status.completed;
  }

  /// Post crypto collateral — BTN_POST_CRYPTO
  Future<bool> postCryptoCollateral(int caseId, double amount, String asset) async {
    final response = await _network.post(endpoint: '/loan/cases/$caseId/collateral/crypto', data: {
      'amount': amount,
      'asset': asset,
    });
    return response.status == Status.completed;
  }

  /// Sign guarantee (ضامن) — BTN_SIGN_GUARANTEE
  Future<bool> signGuarantee(int caseId) async {
    final response = await _network.post(endpoint: '/loan/cases/$caseId/guarantor', data: {});
    return response.status == Status.completed;
  }

  /// Sign contract — BTN_SIGN_CONTRACT
  Future<bool> signContract(int caseId, {String role = 'BORROWER'}) async {
    final response = await _network.post(endpoint: '/loan/cases/$caseId/sign', data: {'role': role});
    return response.status == Status.completed;
  }

  /// Pay installment — BTN_PAY_INSTALLMENT
  Future<bool> payInstallment(int caseId, int installmentId) async {
    final response = await _network.post(
      endpoint: '/loan/cases/$caseId/installments/$installmentId/pay',
      data: {},
    );
    return response.status == Status.completed;
  }

  /// Early repayment — BTN_EARLY_REPAY
  Future<bool> earlyRepayment(int caseId) async {
    final response = await _network.post(endpoint: '/loan/cases/$caseId/early-repayment', data: {});
    return response.status == Status.completed;
  }

  /// Cancel application (C1) — BTN_CANCEL_APPLICATION
  Future<bool> cancel(int caseId) async {
    final response = await _network.post(endpoint: '/loan/cases/$caseId/cancel', data: {});
    return response.status == Status.completed;
  }
}
