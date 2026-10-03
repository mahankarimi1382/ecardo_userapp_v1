// Real regression tests for the loan amortization math.
//
// Every existing loan test is a smoke test: it asserts that the code *runs*,
// not that the numbers are right. A real money bug shipped through this gap —
// `calculateMonthlyInstallment` ignored the grace period on the confirmation
// screen, understating the loan cost by ~1,066,425 IRR. Nothing caught it.
//
// The tests below are therefore written as INVARIANTS — properties that must
// hold for ANY correct amortization — evaluated over a table of realistic loan
// cases. If an assertion fails, do not weaken it: the math is wrong.
//
// The load-bearing one is group 3 ("total repayment agrees with the schedule").
// `calculateTotalRepayment` (controller) and `generateSchedule` (widget layer)
// are two independent implementations of the same amortization. If they
// disagree about the grace period — exactly the historical bug — the two
// totals diverge and the borrower is quoted a wrong cost on one screen and a
// different wrong cost on another.

import 'package:ecardo_user/src/loan/controllers/loan_controller.dart';
import 'package:ecardo_user/src/loan/services/loan_service.dart';
import 'package:ecardo_user/src/loan/widgets/loan_amortization_schedule.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// One loan to run every invariant against.
class _LoanCase {
  const _LoanCase(
    this.name,
    this.principal,
    this.annualRatePct,
    this.tenureMonths,
    this.graceMonths,
  );

  final String name;
  final double principal;
  final double annualRatePct;
  final int tenureMonths;
  final int graceMonths;

  /// Grace is clamped to [0, tenureMonths - 1] by the production code; mirror
  /// that here so the test can talk about "effective" grace months.
  int get effectiveGraceMonths =>
      graceMonths.clamp(0, tenureMonths - 1 < 0 ? 0 : tenureMonths - 1);

  int get amortizingMonths => tenureMonths - effectiveGraceMonths;

  double get monthlyRate => (annualRatePct / 100.0) / 12.0;

  /// Name shown in `test(...)` and in every `reason:`, so a failure always
  /// identifies the exact loan that broke.
  String get label =>
      '$name (P=${principal.toStringAsFixed(0)}, rate=$annualRatePct%, '
      'tenure=$tenureMonths mo, grace=$graceMonths mo)';

  List<InstallmentItem> schedule() => InstallmentItem.generateSchedule(
        principal: principal,
        annualInterestRatePct: annualRatePct,
        tenureMonths: tenureMonths,
        gracePeriodMonths: graceMonths,
      );

  double sumPrincipal(List<InstallmentItem> s) =>
      s.fold<double>(0.0, (a, i) => a + i.principalAmount);

  double sumInterest(List<InstallmentItem> s) =>
      s.fold<double>(0.0, (a, i) => a + i.interestAmount);
}

final List<_LoanCase> _cases = const [
  _LoanCase('IRR 50M, no grace', 50000000, 18, 12, 0),
  _LoanCase('IRR 50M, 3mo grace', 50000000, 18, 12, 3),
  _LoanCase('IRR 100M, 3mo grace', 100000000, 24, 36, 3),
  _LoanCase('USD 1000, no grace', 1000, 6, 6, 0),
  _LoanCase('single-month term', 50000000, 18, 1, 0),
  _LoanCase('zero-rate', 50000000, 0, 12, 0),
  _LoanCase('zero-rate with grace', 50000000, 0, 12, 3),
  _LoanCase('grace == tenure', 50000000, 18, 12, 12),
  _LoanCase('grace > tenure', 50000000, 18, 12, 99),
];

/// Cases that actually have effective grace AND a positive rate — the
/// interest-only property is only meaningful when interest is non-zero.
final List<_LoanCase> _graceCases =
    _cases.where((c) => c.effectiveGraceMonths > 0 && c.annualRatePct > 0).toList();

final List<_LoanCase> _zeroRateCases =
    _cases.where((c) => c.annualRatePct == 0).toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LoanController controller;

  setUp(() {
    Get.put<TokenService>(TokenService());
    Get.put<NetworkService>(NetworkService());
    Get.put<LoanApiService>(LoanApiService());
    controller = Get.put<LoanController>(LoanController());
  });

  tearDown(Get.reset);

  // ---------------------------------------------------------------------
  group('1. Balance closes (principal fully repaid, ending at zero)', () {
    for (final c in _cases) {
      test(c.label, () {
        final s = c.schedule();

        expect(
          s.length,
          c.tenureMonths,
          reason: 'Schedule must contain exactly one installment per month '
              'of tenure. Got ${s.length} for tenure ${c.tenureMonths}.',
        );

        final principalSum = c.sumPrincipal(s);
        expect(
          (principalSum - c.principal).abs(),
          lessThanOrEqualTo(0.01),
          reason: 'Sum of all principal portions ($principalSum) must equal the '
              'loan principal (${c.principal}). A shortfall means the borrower '
              'ends the term still owing money; an excess means the schedule '
              'over-amortizes and inflates the quoted total.',
        );

        expect(
          s.last.remainingBalance,
          closeTo(0.0, 0.01),
          reason: 'The LAST installment must retire the debt: remaining '
              'balance is ${s.last.remainingBalance}, expected 0.',
        );
      });
    }
  });

  // ---------------------------------------------------------------------
  group('2. Grace period is interest-only (principal untouched)', () {
    for (final c in _graceCases) {
      test(c.label, () {
        final s = c.schedule();
        final g = c.effectiveGraceMonths;

        final graceItems = s.take(g).toList();
        expect(
          graceItems.length,
          g,
          reason: 'Expected $g interest-only installments before amortization '
              'begins, got ${graceItems.length}.',
        );

        for (final item in graceItems) {
          expect(
            item.principalAmount,
            closeTo(0.0, 0.0),
            reason: 'Grace installment #${item.installmentNumber} must defer '
                'ALL principal (principal part was ${item.principalAmount}).',
          );
          expect(
            item.interestAmount,
            greaterThan(0),
            reason: 'Grace installment #${item.installmentNumber} must still '
                'charge interest (interest was ${item.interestAmount}); a zero '
                'means the grace period is silently free.',
          );
          expect(
            item.remainingBalance,
            closeTo(c.principal, 0.01),
            reason: 'Balance must be unchanged during grace. Installment '
                '#${item.installmentNumber} showed balance '
                '${item.remainingBalance}, expected the untouched '
                '${c.principal}.',
          );
          expect(
            item.isGracePeriod,
            isTrue,
            reason: 'Installment #${item.installmentNumber} is inside the grace '
                'window but is not flagged as such — the UI would not badge it.',
          );
        }

        // Balance roll-forward: each row's balance must be exactly the
        // previous row's balance minus that row's principal portion. The row
        // before the first one starts from the loan principal. This is the
        // stronger form of "grace does not touch the balance" — it also pins
        // every subsequent amortizing row to the one before it, so a drifting
        // or truncated amortization cannot hide behind the closing balance.
        var runningBalance = c.principal;
        for (final item in s) {
          expect(
            item.remainingBalance,
            closeTo(runningBalance - item.principalAmount, 0.01),
            reason: 'Balance roll-forward broken at installment '
                '#${item.installmentNumber}: previous balance $runningBalance '
                'minus principal ${item.principalAmount} should be '
                '${runningBalance - item.principalAmount}, but the schedule '
                'reports ${item.remainingBalance}.',
          );
          runningBalance = item.remainingBalance;
        }
      });
    }
  });

  // ---------------------------------------------------------------------
  group('3. Total repayment agrees with the amortization schedule', () {
    for (final c in _cases) {
      test(c.label, () {
        final s = c.schedule();
        final scheduleTotal = c.principal + c.sumInterest(s);

        final controllerTotal = controller.calculateTotalRepayment(
          principal: c.principal,
          annualInterestRatePct: c.annualRatePct,
          tenureMonths: c.tenureMonths,
          gracePeriodMonths: c.graceMonths,
        );

        expect(
          (controllerTotal - scheduleTotal).abs(),
          lessThanOrEqualTo(1.0),
          reason: 'calculateTotalRepayment() returned $controllerTotal but the '
              'generated schedule implies $scheduleTotal '
              '(principal ${c.principal} + interest ${c.sumInterest(s)}). The '
              'two implementations of the amortization disagree, so the borrower '
              'is quoted two different loan costs on two different screens. '
              'Difference: ${controllerTotal - scheduleTotal}.',
        );
      });
    }
  });

  // ---------------------------------------------------------------------
  group('4. No negative amounts anywhere in the schedule', () {
    for (final c in _cases) {
      test(c.label, () {
        final s = c.schedule();
        for (final item in s) {
          expect(
            item.principalAmount,
            greaterThanOrEqualTo(0),
            reason: 'Negative principal (${item.principalAmount}) on installment '
                '#${item.installmentNumber} — the loan would grow instead of '
                'shrinking.',
          );
          expect(
            item.interestAmount,
            greaterThanOrEqualTo(0),
            reason: 'Negative interest (${item.interestAmount}) on installment '
                '#${item.installmentNumber}.',
          );
          expect(
            item.remainingBalance,
            greaterThanOrEqualTo(0),
            reason: 'Negative remaining balance (${item.remainingBalance}) on '
                'installment #${item.installmentNumber}.',
          );
        }
      });
    }
  });

  // ---------------------------------------------------------------------
  group('5. Zero-rate sanity', () {
    for (final c in _zeroRateCases) {
      test(c.label, () {
        final s = c.schedule();

        final emi = controller.calculateMonthlyInstallment(
          principal: c.principal,
          annualInterestRatePct: c.annualRatePct,
          tenureMonths: c.tenureMonths,
          gracePeriodMonths: c.graceMonths,
        );

        expect(
          emi,
          closeTo(c.principal / c.amortizingMonths, 0.01),
          reason: 'At 0% the installment must be principal spread evenly over '
              'the ${c.amortizingMonths} amortizing months '
              '(= ${c.principal / c.amortizingMonths}), got $emi.',
        );

        expect(
          c.sumInterest(s),
          closeTo(0.0, 0.0),
          reason: 'At 0% annual rate the total interest must be exactly 0, got '
              '${c.sumInterest(s)}.',
        );

        final total = controller.calculateTotalRepayment(
          principal: c.principal,
          annualInterestRatePct: c.annualRatePct,
          tenureMonths: c.tenureMonths,
          gracePeriodMonths: c.graceMonths,
        );
        expect(
          total,
          closeTo(c.principal, 0.01),
          reason: 'At 0% the borrower repays exactly the principal '
              '(${c.principal}), got $total.',
        );
      });
    }
  });

  // ---------------------------------------------------------------------
  group('6. Edge cases', () {
    test('grace >= tenure clamps to tenure-1 and stays finite', () {
      for (final c in _cases.where((c) => c.graceMonths >= c.tenureMonths)) {
        final emi = controller.calculateMonthlyInstallment(
          principal: c.principal,
          annualInterestRatePct: c.annualRatePct,
          tenureMonths: c.tenureMonths,
          gracePeriodMonths: c.graceMonths,
        );
        final total = controller.calculateTotalRepayment(
          principal: c.principal,
          annualInterestRatePct: c.annualRatePct,
          tenureMonths: c.tenureMonths,
          gracePeriodMonths: c.graceMonths,
        );
        final s = c.schedule();

        expect(
          c.effectiveGraceMonths,
          c.tenureMonths - 1,
          reason: 'Grace must clamp to tenure-1 for ${c.label}.',
        );
        expect(
          c.amortizingMonths,
          1,
          reason: 'The amortizing window must never collapse to zero or go '
              'negative for ${c.label} (got ${c.amortizingMonths}).',
        );
        expect(
          emi.isFinite,
          isTrue,
          reason: 'EMI must be a finite number for ${c.label}, got $emi.',
        );
        expect(
          emi,
          greaterThan(0),
          reason: 'EMI must be positive for ${c.label}, got $emi.',
        );
        expect(
          total.isFinite,
          isTrue,
          reason: 'Total repayment must be a finite number for ${c.label}, '
              'got $total.',
        );
        expect(
          s.where((i) => i.isGracePeriod).length,
          c.tenureMonths - 1,
          reason: 'Exactly tenure-1 grace installments expected for ${c.label}.',
        );
        expect(
          s.last.remainingBalance,
          closeTo(0.0, 0.01),
          reason: 'The single amortizing installment must retire the debt for '
              '${c.label}.',
        );
      }
    });

    test('principal == 0 returns 0 and generates no schedule', () {
      expect(
        controller.calculateMonthlyInstallment(
          principal: 0,
          annualInterestRatePct: 18,
          tenureMonths: 12,
        ),
        0.0,
        reason: 'A zero loan must quote a zero installment, not NaN or '
            'Infinity.',
      );
      expect(
        controller.calculateTotalRepayment(
          principal: 0,
          annualInterestRatePct: 18,
          tenureMonths: 12,
          gracePeriodMonths: 3,
        ),
        0.0,
        reason: 'A zero loan must quote a zero total repayment.',
      );
      expect(
        InstallmentItem.generateSchedule(
          principal: 0,
          annualInterestRatePct: 18,
          tenureMonths: 12,
        ),
        isEmpty,
        reason: 'A zero loan must generate an empty schedule, not installments '
            'of NaN.',
      );
    });

    test('tenure == 1 works', () {
      const p = 50000000.0;
      const rate = 18.0;
      final s = InstallmentItem.generateSchedule(
        principal: p,
        annualInterestRatePct: rate,
        tenureMonths: 1,
      );

      expect(s.length, 1, reason: 'A 1-month term must yield exactly 1 row.');
      expect(
        s.single.remainingBalance,
        closeTo(0.0, 0.01),
        reason: 'The only installment must retire the debt.',
      );
      expect(
        s.single.principalAmount,
        closeTo(p, 0.01),
        reason: 'The only installment must repay the full principal.',
      );
      expect(
        s.single.interestAmount,
        closeTo(p * (rate / 100.0 / 12.0), 0.01),
        reason: 'One month of interest on the full principal.',
      );
      expect(
        controller.calculateMonthlyInstallment(
          principal: p,
          annualInterestRatePct: rate,
          tenureMonths: 1,
        ),
        closeTo(p * (1 + rate / 100.0 / 12.0), 0.01),
        reason: 'A 1-month term is principal plus one month of interest.',
      );
      expect(
        controller.calculateTotalRepayment(
          principal: p,
          annualInterestRatePct: rate,
          tenureMonths: 1,
        ),
        closeTo(p * (1 + rate / 100.0 / 12.0), 0.01),
        reason: 'A 1-month term must be quoted consistently by both functions.',
      );
    });

    test('tenure <= 0 and negative principal return 0 instead of NaN', () {
      expect(
        controller.calculateMonthlyInstallment(
          principal: 50000000,
          annualInterestRatePct: 18,
          tenureMonths: 0,
        ),
        0.0,
        reason: 'A zero-month term must not divide by zero or return NaN.',
      );
      expect(
        controller.calculateTotalRepayment(
          principal: -100,
          annualInterestRatePct: 18,
          tenureMonths: 12,
        ),
        0.0,
        reason: 'A negative principal must return 0, not a negative quote.',
      );
      expect(
        InstallmentItem.generateSchedule(
          principal: 50000000,
          annualInterestRatePct: 18,
          tenureMonths: 0,
        ),
        isEmpty,
        reason: 'A zero-month term must generate no installments.',
      );
    });
  });
}