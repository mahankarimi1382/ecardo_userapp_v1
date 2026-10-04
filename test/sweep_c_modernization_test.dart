import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/escrow/models/escrow_models.dart';
import 'package:ecardo_user/src/escrow/widgets/escrow_widgets.dart';
import 'package:ecardo_user/src/guarantee/widgets/guarantee_status_stepper.dart';
import 'package:ecardo_user/src/loan/widgets/loan_status_stepper.dart';
import 'package:ecardo_user/src/loan/widgets/loan_calculator_slider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void phoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(750, 1624);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  Widget wrapWithTheme(Widget child, {bool isDark = false, Locale locale = const Locale('fa')}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(
        locale: locale,
        supportedLocales: const [Locale('fa'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: isDark ? ThemeData.dark() : ThemeData.light(),
        home: Scaffold(body: child),
      ),
    );
  }

  group('Escrow Module Modernization Tests', () {
    testWidgets('EscrowStatusBadge renders badges in light and dark mode', (tester) async {
      phoneSurface(tester);

      await tester.pumpWidget(
        wrapWithTheme(
          const Column(
            children: [
              EscrowStatusBadge(status: 'DRAFT'),
              EscrowStatusBadge(status: 'AWAITING_PAYMENT'),
              EscrowStatusBadge(status: 'FUNDS_HELD'),
              EscrowStatusBadge(status: 'COMPLETED'),
              EscrowStatusBadge(status: 'DISPUTED'),
            ],
          ),
          isDark: false,
          locale: const Locale('fa'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('پیش‌نویس'), findsOneWidget);
      expect(find.text('در انتظار پرداخت'), findsOneWidget);
      expect(find.text('امان نزد پلتفرم'), findsOneWidget);
      expect(find.text('تکمیل و تسویه'), findsOneWidget);
      expect(find.text('پرونده اختلاف'), findsOneWidget);

      // Dark mode test
      await tester.pumpWidget(
        wrapWithTheme(
          const Column(
            children: [
              EscrowStatusBadge(status: 'DRAFT'),
              EscrowStatusBadge(status: 'COMPLETED'),
            ],
          ),
          isDark: true,
          locale: const Locale('fa'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('پیش‌نویس'), findsOneWidget);
      expect(find.text('تکمیل و تسویه'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('EscrowMilestoneStepper displays 6 steps and calculates progress correctly', (tester) async {
      phoneSurface(tester);

      await tester.pumpWidget(
        wrapWithTheme(
          const SingleChildScrollView(
            child: Column(
              children: [
                EscrowMilestoneStepper(currentStatus: 'DRAFT'),
                SizedBox(height: 20),
                EscrowMilestoneStepper(currentStatus: 'FUNDS_HELD'),
                SizedBox(height: 20),
                EscrowMilestoneStepper(currentStatus: 'COMPLETED'),
              ],
            ),
          ),
          locale: const Locale('fa'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('مراحل انجام معامله امانی'), findsNWidgets(3));
      expect(find.text('1 / 6'), findsOneWidget);
      expect(find.text('3 / 6'), findsOneWidget);
      expect(find.text('6 / 6'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('EscrowCounterpartyAvatar renders monogram and role', (tester) async {
      phoneSurface(tester);

      await tester.pumpWidget(
        wrapWithTheme(
          const Row(
            children: [
              Expanded(
                child: EscrowCounterpartyAvatar(
                  name: 'علی رضایی',
                  role: 'خریدار',
                  isBuyer: true,
                ),
              ),
              Expanded(
                child: EscrowCounterpartyAvatar(
                  name: 'شرکت تجارت نوین',
                  role: 'فروشنده',
                  isBuyer: false,
                ),
              ),
            ],
          ),
          locale: const Locale('fa'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('علی رضایی'), findsOneWidget);
      expect(find.text('شرکت تجارت نوین'), findsOneWidget);
      expect(find.text('خریدار'), findsOneWidget);
      expect(find.text('فروشنده'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('EscrowSkeletonLoader renders without layout overflow', (tester) async {
      phoneSurface(tester);

      await tester.pumpWidget(
        wrapWithTheme(
          const EscrowSkeletonLoader(itemCount: 2),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('EscrowTimelineWidget renders chronological events', (tester) async {
      phoneSurface(tester);

      final events = [
        EscrowEventModel(
          id: 1,
          actorRole: 'BUYER',
          toStatus: 'AWAITING_AGREEMENT',
          action: 'ایجاد معامله',
          createdAt: DateTime(2026, 10, 4, 14, 30),
        ),
        EscrowEventModel(
          id: 2,
          actorRole: 'SELLER',
          toStatus: 'FUNDS_HELD',
          action: 'تأیید شرایط',
          reason: 'موافقت با تمام مفاد قرارداد',
          createdAt: DateTime(2026, 10, 4, 15, 0),
        ),
      ];

      await tester.pumpWidget(
        wrapWithTheme(
          EscrowTimelineWidget(events: events),
          locale: const Locale('fa'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ایجاد معامله'), findsOneWidget);
      expect(find.text('تأیید شرایط'), findsOneWidget);
      expect(find.text('موافقت با تمام مفاد قرارداد'), findsOneWidget);
      expect(find.text('14:30'), findsOneWidget);
      expect(find.text('15:00'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Guarantee Module Modernization Tests', () {
    testWidgets('GuaranteeStatusStepper displays progress through 5 steps', (tester) async {
      phoneSurface(tester);

      await tester.pumpWidget(
        wrapWithTheme(
          const SingleChildScrollView(
            child: Column(
              children: [
                GuaranteeStatusStepper(currentStatus: 'DRAFT'),
                SizedBox(height: 20),
                GuaranteeStatusStepper(currentStatus: 'MARGIN_PENDING'),
                SizedBox(height: 20),
                GuaranteeStatusStepper(currentStatus: 'ISSUED'),
              ],
            ),
          ),
          locale: const Locale('fa'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('مراحل صدور ضمانت‌نامه بانکی'), findsNWidgets(3));
      expect(find.text('1 / 5'), findsOneWidget);
      expect(find.text('3 / 5'), findsOneWidget);
      expect(find.text('5 / 5'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('GuaranteeSkeletonLoader renders cleanly without overflow', (tester) async {
      phoneSurface(tester);

      await tester.pumpWidget(
        wrapWithTheme(
          const GuaranteeSkeletonLoader(itemCount: 3),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('Loan Module Modernization Tests', () {
    testWidgets('LoanStatusStepper renders 5 milestones and active steps', (tester) async {
      phoneSurface(tester);

      await tester.pumpWidget(
        wrapWithTheme(
          const SingleChildScrollView(
            child: Column(
              children: [
                LoanStatusStepper(currentStatus: 'DRAFT'),
                SizedBox(height: 20),
                LoanStatusStepper(currentStatus: 'OFFERED'),
                SizedBox(height: 20),
                LoanStatusStepper(currentStatus: 'ACTIVE'),
              ],
            ),
          ),
          locale: const Locale('fa'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('مراحل دریافت تسهیلات'), findsNWidgets(3));
      expect(find.text('1 / 5'), findsOneWidget);
      expect(find.text('3 / 5'), findsOneWidget);
      expect(find.text('5 / 5'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('LoanSkeletonLoader renders cleanly without overflow', (tester) async {
      phoneSurface(tester);

      await tester.pumpWidget(
        wrapWithTheme(
          const LoanSkeletonLoader(itemCount: 2),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('LoanCalculatorSlider calculates live metrics on interaction', (tester) async {
      phoneSurface(tester);

      double? currentMonthly;
      int? currentTenure;

      await tester.pumpWidget(
        wrapWithTheme(
          SingleChildScrollView(
            child: LoanCalculatorSlider(
              initialAmount: 60000000.0,
              initialMonths: 12,
              minAmount: 10000000.0,
              maxAmount: 200000000.0,
              annualInterestRate: 18.0,
              currency: 'IRR',
              onPlanChanged: (amt, m, grace, pmt) {
                currentTenure = m;
                currentMonthly = pmt;
              },
            ),
          ),
          locale: const Locale('fa'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('60,000,000'), findsOneWidget);
      expect(currentTenure, 12);
      expect(currentMonthly, greaterThan(0));
      expect(tester.takeException(), isNull);
    });
  });
}
