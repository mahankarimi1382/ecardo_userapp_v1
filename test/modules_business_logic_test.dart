import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/loan/controllers/loan_controller.dart';
import 'package:ecardo_user/src/guarantee/controllers/guarantee_controller.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';
import 'package:ecardo_user/src/escrow/controllers/escrow_controller.dart';

void main() {
  group('1. Loans & Credit — Business Logic & Rules Invariants', () {
    test('Standard products define correct risk profiles and terms', () {
      final products = LoanController.defaultProducts;
      expect(products.length, 3);

      final crypto = products[0];
      expect(crypto.name, 'Crypto-backed loan');
      expect(crypto.interestRatePct, 14.0);
      expect(crypto.collateralRatioPct, 150.0);
      expect(crypto.requiredCollateralType, 'USDT');
      expect(crypto.maxAmount, 100000.0);
      expect(crypto.slaTag, 'Fastest');

      final business = products[1];
      expect(business.name, 'Business loan');
      expect(business.interestRatePct, 20.0);
      expect(business.requiredKycTier, 3);
      expect(business.maxAmount, 50000.0);
      expect(business.slaTag, '5 working days');

      final micro = products[2];
      expect(micro.name, 'Personal micro-loan');
      expect(micro.interestRatePct, 24.0);
      expect(micro.requiredKycTier, 2);
      expect(micro.maxAmount, 5000.0);
      expect(micro.slaTag, '2 working days');
    });

    test('Active Loan LN-2208 calculations and health metrics', () {
      final loan = LoanController.sampleActiveLoan;
      expect(loan.caseNo, 'LN-2208');
      expect(loan.requestedAmount, 10000.0);
      expect(loan.installments.length, 6);
      expect(loan.paidInstallmentsCount, 2);
      expect(loan.totalInstallmentsCount, 6);
      expect(loan.outstandingAmount, 4560.0);
      expect(loan.lockedCollateralUsdt, 15000.0);
      expect(loan.coverageNowPct, 219.0);
      expect(loan.isCollateralWarning, isFalse);
    });

    test('Collateral Warning LN-2209 margin call logic and resolution paths', () {
      final loan = LoanController.sampleWarningLoan;
      expect(loan.coverageNowPct, 118.0);
      expect(loan.isCollateralWarning, isTrue);
      expect(loan.isCollateralDanger, isTrue);

      // Shortfall to reach 150% coverage:
      // Outstanding = 6840. Target = 6840 * 1.5 = 10260. Locked = 8071. Diff = 2189
      expect(loan.collateralShortfallUsdt, 2189.0);

      // Debt reduction required to reach 150% with current 8071 USDT:
      // Max debt = 8071 / 1.5 = 5380.67. Debt reduction = 6840 - 5380.67 = 1459.33
      expect(loan.debtReductionRequiredUsd, closeTo(1459.33, 0.5));
    });
  });

  group('2. Guarantee & LC — Margin & Liability Rules', () {
    test('Standard guarantee instruments reflect official margins and fees', () {
      final instruments = GuaranteeController.defaultInstruments;
      expect(instruments.length, 6);

      final bid = instruments[0];
      expect(bid.code, 'BID_BOND');
      expect(bid.marginPct, 10.0);
      expect(bid.feePct, 1.0);

      final performance = instruments[1];
      expect(performance.code, 'PERFORMANCE_BOND');
      expect(performance.marginPct, 10.0);
      expect(performance.feePct, 1.0);

      final advance = instruments[2];
      expect(advance.code, 'ADVANCE_PAYMENT');
      expect(advance.marginPct, 20.0);
      expect(advance.feePct, 1.0);
    });

    test('Guarantee Called claim liability net calculation', () {
      final cases = GuaranteeController.sampleCases;
      final calledCase = cases.firstWhere((c) => c.isClaimed);

      expect(calledCase.caseNo, 'GTE-0389');
      expect(calledCase.beneficiaryName, 'Pars Polymer Co.');
      expect(calledCase.amount, 10000.0);
      expect(calledCase.marginAmount, 2000.0); // 20% margin
      expect(calledCase.claimReason, 'Goods not delivered');

      // Net liability owed: Claim ($10,000) - Margin covered ($2,000) = $8,000
      final netPayable = (calledCase.claimAmount ?? calledCase.amount) - calledCase.marginAmount;
      expect(netPayable, 8000.0);
    });
  });

  group('3. Remittance — Rate Lock & Multi-Method Delivery', () {
    test('Standard payout methods have correct status and currencies', () {
      final methods = RemittanceController.defaultMethods;
      expect(methods.length, 4);

      final chinaBank = methods[0];
      expect(chinaBank.name, 'Bank transfer · China');
      expect(chinaBank.receiveCurrencyCode, 'CNY');
      expect(chinaBank.isActive, isTrue);

      final alipay = methods[1];
      expect(alipay.name, 'Alipay');
      expect(alipay.receiveCurrencyCode, 'CNY');
      expect(alipay.isActive, isTrue);

      final shaba = methods[2];
      expect(shaba.name, 'Iranian bank · SHABA');
      expect(shaba.isActive, isFalse);

      final usdt = methods[3];
      expect(usdt.name, 'USDT wallet');
      expect(usdt.isActive, isFalse);
    });
  });

  group('4. Escrow — Inspection, Dispute & Settlement Logic', () {
    test('Escrow sample orders cover all lifecycle states', () {
      final orders = EscrowController.defaultOrders;
      expect(orders.length, 4);

      final held = orders[0];
      expect(held.contractNo, 'ESC-2041');
      expect(held.isFundsHeld, isTrue);
      expect(held.amount, 2400.0);
      expect(held.totalEscrowAmount, 2424.0); // includes 1% fee

      final inspection = orders[1];
      expect(inspection.contractNo, 'ESC-2042');
      expect(inspection.isInspection, isTrue);
      expect(inspection.sellerDeliveryWaybill, 'Waybill-4471.pdf');

      final pending = orders[2];
      expect(pending.contractNo, 'ESC-2043');
      expect(pending.isPendingAgreement, isTrue);

      final dispute = orders[3];
      expect(dispute.contractNo, 'ESC-2044');
      expect(dispute.isDisputed, isTrue);
      expect(dispute.dispute?.caseNumber, 'DSP-118');
    });

    test('Dispute decision resolution financial split 60/40 is accurate', () {
      final disputeOrder = EscrowController.defaultOrders.firstWhere((o) => o.isDisputed);
      final decision = disputeOrder.dispute?.decision;
      expect(decision, isNotNull);

      expect(decision!.splitPercentBuyer, 60.0);
      expect(decision.splitPercentSeller, 40.0);
      expect(decision.buyerRefundAmount, 516.0);
      expect(decision.sellerPayoutAmount, 344.0);
      expect(decision.feeAmount, 8.60);

      // Verify mathematical balance: $516 + $344 + $8.60 = $868.60
      final total = decision.buyerRefundAmount + decision.sellerPayoutAmount + decision.feeAmount;
      expect(total, 868.60);
    });
  });
}
