import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/drop_down/recent_transaction_details.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/recent_transactions_section.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/model/transactions_model.dart';

Widget _hostWidget(
  Widget child, {
  Locale locale = const Locale('en'),
  TextDirection direction = TextDirection.ltr,
  ThemeMode themeMode = ThemeMode.light,
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      locale: locale,
      themeMode: themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      supportedLocales: const [
        Locale('en'),
        Locale('fa'),
        Locale('ar'),
        Locale('tr'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 375,
              height: 812,
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    Get.reset();
  });

  group('RecentTransactionsSection Elevation & Smart Clustering', () {
    testWidgets('renders empty state when transaction list is empty', (tester) async {
      await tester.pumpWidget(
        _hostWidget(const RecentTransactionsSection(transactions: [])),
      );
      await tester.pumpAndSettle();

      expect(find.text('No transactions yet'), findsOneWidget);
    });

    testWidgets('clusters transactions into human-friendly groups (Today, Yesterday, Past)', (tester) async {
      final now = DateTime.now().toUtc();
      final nowIso = now.toIso8601String();
      final yesterdayIso = now.subtract(const Duration(days: 1)).toIso8601String();
      final pastIso = now.subtract(const Duration(days: 14)).toIso8601String();

      final transactions = [
        Transactions(
          tnx: 'TX-TODAY-01',
          type: 'Deposit',
          amount: '100.00',
          trxCurrencySymbol: r'$',
          isPlus: true,
          status: 'success',
          createdAt: nowIso,
        ),
        Transactions(
          tnx: 'TX-YEST-01',
          type: 'Transfer',
          amount: '50.00',
          trxCurrencySymbol: r'$',
          isPlus: false,
          status: 'pending',
          createdAt: yesterdayIso,
        ),
        Transactions(
          tnx: 'TX-PAST-01',
          type: 'Exchange',
          amount: '200.00',
          trxCurrencySymbol: r'$',
          isPlus: false,
          status: 'failed',
          createdAt: pastIso,
        ),
      ];

      await tester.pumpWidget(
        _hostWidget(RecentTransactionsSection(transactions: transactions)),
      );
      await tester.pumpAndSettle();

      // Verify cluster headers
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('Past'), findsOneWidget);

      // Verify transaction amounts & signs
      expect(find.text(r'+$ 100.00'), findsOneWidget);
      expect(find.text(r'-$ 50.00'), findsOneWidget);
      expect(find.text(r'-$ 200.00'), findsOneWidget);

      // Verify status badges
      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Failed'), findsOneWidget);
    });

    testWidgets('clusters properly in Persian RTL locale (امروز, دیروز)', (tester) async {
      final now = DateTime.now().toUtc();
      final nowIso = now.toIso8601String();
      final yesterdayIso = now.subtract(const Duration(days: 1)).toIso8601String();

      final transactions = [
        Transactions(
          tnx: 'TX-FA-01',
          type: 'Deposit',
          amount: '150.00',
          trxCurrencySymbol: r'$',
          isPlus: true,
          status: 'success',
          createdAt: nowIso,
        ),
        Transactions(
          tnx: 'TX-FA-02',
          type: 'Transfer',
          amount: '30.00',
          trxCurrencySymbol: r'$',
          isPlus: false,
          status: 'pending',
          createdAt: yesterdayIso,
        ),
      ];

      await tester.pumpWidget(
        _hostWidget(
          RecentTransactionsSection(transactions: transactions),
          locale: const Locale('fa'),
          direction: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('امروز'), findsOneWidget);
      expect(find.text('دیروز'), findsOneWidget);
      expect(find.text('موفق'), findsOneWidget);
      expect(find.text('در انتظار'), findsOneWidget);
    });

    testWidgets('renders category icon containers with rounded 14r and distinctive styling', (tester) async {
      final transactions = [
        Transactions(
          tnx: 'TX-CAT-01',
          type: 'Deposit',
          amount: '80.00',
          trxCurrencySymbol: r'$',
          isPlus: true,
          status: 'success',
          createdAt: DateTime.now().toUtc().toIso8601String(),
        ),
      ];

      await tester.pumpWidget(
        _hostWidget(RecentTransactionsSection(transactions: transactions)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.south_west_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
    });
  });

  group('RecentTransactionDetails Digital Receipt Excellence', () {
    final luxuryTx = Transactions(
      tnx: 'TX-RECEIPT-999',
      type: 'Exchange',
      amount: '500.00',
      charge: '2.50',
      finalAmount: '502.50',
      payAmount: '450.00',
      payCurrency: 'EUR',
      status: 'success',
      method: 'Bank Wire',
      walletType: 'Primary USD',
      trxCurrencyCode: 'USD',
      trxCurrencySymbol: r'$',
      isPlus: false,
      isCrypto: false,
      createdAt: '2026-03-20T10:00:00.000000Z',
      description: 'Euro to Dollar Swap',
    );

    testWidgets('renders 3 action buttons (Repeat, Share, Support)', (tester) async {
      await tester.pumpWidget(
        _hostWidget(RecentTransactionDetails(transaction: luxuryTx)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Repeat'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.byIcon(Icons.replay_rounded), findsOneWidget);
      expect(find.byIcon(Icons.ios_share_rounded), findsOneWidget);
      expect(find.byIcon(Icons.headset_mic_rounded), findsOneWidget);
    });

    testWidgets('renders breakdown rows including wallet, method, fee, and exchange rate', (tester) async {
      await tester.pumpWidget(
        _hostWidget(RecentTransactionDetails(transaction: luxuryTx)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Primary USD (USD)'), findsOneWidget);
      expect(find.text('Bank Wire'), findsOneWidget);
      expect(find.text(r'-$2.50'), findsOneWidget);
      expect(find.text('450.00 EUR'), findsOneWidget);
      expect(find.text(r'-$502.50'), findsOneWidget);
      expect(find.text('TX-RECEIPT-999'), findsOneWidget);
    });

    testWidgets('renders Persian localized action buttons in RTL', (tester) async {
      await tester.pumpWidget(
        _hostWidget(
          RecentTransactionDetails(transaction: luxuryTx),
          locale: const Locale('fa'),
          direction: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تکرار'), findsOneWidget);
      expect(find.text('اشتراک'), findsOneWidget);
      expect(find.text('پشتیبانی'), findsOneWidget);
      expect(find.text('موفق'), findsOneWidget);
    });

    testWidgets('renders dark mode theme without contrast clipping or overflow', (tester) async {
      await tester.pumpWidget(
        _hostWidget(
          RecentTransactionDetails(transaction: luxuryTx),
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(RecentTransactionDetails), findsOneWidget);
    });
  });
}
