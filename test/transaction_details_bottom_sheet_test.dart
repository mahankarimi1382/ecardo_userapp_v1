import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/drop_down/recent_transaction_details.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/model/transactions_model.dart';

Widget _host(
  Widget child, {
  Locale locale = const Locale('en'),
  TextDirection direction = TextDirection.ltr,
}) {
  return MaterialApp(
    locale: locale,
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
            width: 420,
            height: 750,
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  final testTx = Transactions(
    tnx: 'TXN-98421048',
    type: 'Deposit',
    amount: '250.00',
    charge: '0.00',
    finalAmount: '250.00',
    status: 'success',
    method: 'MasterCard',
    walletType: 'Main Wallet',
    trxCurrencyCode: 'USD',
    trxCurrencySymbol: r'$',
    isPlus: true,
    isCrypto: false,
    createdAt: '2026-03-15T14:30:00.000000Z',
    description: 'Online Top-up Deposit via Card',
  );

  group('RecentTransactionDetails Polish', () {
    testWidgets('renders category badge with icon and label', (tester) async {
      await tester.pumpWidget(_host(RecentTransactionDetails(transaction: testTx)));
      await tester.pumpAndSettle();

      expect(find.text('Deposit'), findsWidgets);
      expect(find.byType(RecentTransactionDetails), findsOneWidget);
    });

    testWidgets('renders localized status Success for en locale', (tester) async {
      await tester.pumpWidget(_host(
        RecentTransactionDetails(transaction: testTx),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Success'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('renders localized status موفق for fa locale', (tester) async {
      await tester.pumpWidget(_host(
        RecentTransactionDetails(transaction: testTx),
        locale: const Locale('fa'),
        direction: TextDirection.rtl,
      ));
      await tester.pumpAndSettle();

      expect(find.text('موفق'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('renders transaction ID with quick copy button', (tester) async {
      await tester.pumpWidget(_host(RecentTransactionDetails(transaction: testTx)));
      await tester.pumpAndSettle();

      expect(find.text('TXN-98421048'), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);

      // Ensure button is scrolled into visible view before tapping
      await tester.ensureVisible(find.byIcon(Icons.copy_rounded));
      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pump();

      // Checkmark icon appears on successful copy
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Advance past the 2-second reset timer so no pending timers leak
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('formats timestamp properly without dangling dots', (tester) async {
      await tester.pumpWidget(_host(RecentTransactionDetails(transaction: testTx)));
      await tester.pumpAndSettle();

      // Timestamp renders with clock icon
      expect(find.byIcon(Icons.access_time_rounded), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is Text && (w.data?.endsWith(' ·') ?? false)),
        findsNothing,
      );
    });

    testWidgets('renders seamlessly in RTL without overflow', (tester) async {
      await tester.pumpWidget(_host(
        RecentTransactionDetails(transaction: testTx),
        locale: const Locale('fa'),
        direction: TextDirection.rtl,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
