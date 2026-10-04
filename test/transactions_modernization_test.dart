import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/controller/transactions_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/model/transactions_model.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/view/sub_sections/bottom_sheet/transaction_filter_bottom_sheet.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/view/sub_sections/transaction_type_list.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/widgets/transaction_card.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/widgets/transaction_date_group_header.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/widgets/transaction_shimmer_skeleton.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/widgets/transaction_summary_card.dart';

class _TestTransactionsController extends TransactionsController {
  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> fetchDynamicTransactions() async {}

  @override
  Future<void> fetchTransactions() async {}
}

Widget _host(
  Widget child, {
  Locale locale = const Locale('en'),
  TextDirection direction = TextDirection.ltr,
  ThemeMode themeMode = ThemeMode.light,
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => GetMaterialApp(
      locale: locale,
      themeMode: themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      supportedLocales: const [
        Locale('en'),
        Locale('fa'),
        Locale('ar'),
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
          body: child,
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.put<TransactionsController>(_TestTransactionsController());
  });

  tearDown(() {
    Get.reset();
  });

  group('TransactionsModel helper invariants', () {
    test('verifies normalized status and state flags', () {
      final successTx = Transactions(status: 'Success');
      expect(successTx.isSuccess, isTrue);
      expect(successTx.isPending, isFalse);
      expect(successTx.isFailed, isFalse);

      final pendingTx = Transactions(status: 'processing');
      expect(pendingTx.isSuccess, isFalse);
      expect(pendingTx.isPending, isTrue);
      expect(pendingTx.isFailed, isFalse);

      final failedTx = Transactions(status: 'failed');
      expect(failedTx.isSuccess, isFalse);
      expect(failedTx.isPending, isFalse);
      expect(failedTx.isFailed, isTrue);
    });

    test('verifies initials extraction from counterparty and type', () {
      final txNamed = Transactions(description: 'John Doe', type: 'Send Money');
      expect(txNamed.initials, 'JD');

      final txSingle = Transactions(description: 'Alice', type: 'Send Money');
      expect(txSingle.initials, 'A');

      final txFallback = Transactions(type: 'Deposit');
      expect(txFallback.initials, 'D');
    });

    test('verifies numerical amount parser', () {
      final tx = Transactions(amount: '1,250.75');
      expect(tx.numericAmount, 1250.75);

      final txEmpty = Transactions(amount: null);
      expect(txEmpty.numericAmount, 0.0);
    });
  });

  group('TransactionCard widget tests', () {
    testWidgets('renders credit transaction with + amount and success pill', (tester) async {
      final tx = Transactions(
        tnx: 'TXN1001',
        type: 'Deposit',
        description: 'Bank Transfer Deposit',
        amount: '150.00',
        isPlus: true,
        status: 'success',
        method: 'Card',
        trxCurrencySymbol: r'$',
        createdAt: '2026-03-15 10:30:00',
      );

      await tester.pumpWidget(_host(
        TransactionCard(transaction: tx),
      ));
      await tester.pumpAndSettle();

      expect(find.text(r'+$150.00'), findsOneWidget);
      expect(find.text('Bank Transfer Deposit'), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
    });

    testWidgets('renders debit transaction with - amount in Persian RTL', (tester) async {
      final tx = Transactions(
        tnx: 'TXN1002',
        type: 'Withdraw',
        description: 'برداشت به حساب بانکی',
        amount: '80.00',
        isPlus: false,
        status: 'pending',
        method: 'پایا',
        trxCurrencySymbol: r'$',
        createdAt: '2026-03-15 11:00:00',
      );

      await tester.pumpWidget(_host(
        TransactionCard(transaction: tx),
        locale: const Locale('fa'),
        direction: TextDirection.rtl,
      ));
      await tester.pumpAndSettle();

      expect(find.text(r'-$80.00'), findsOneWidget);
      expect(find.text('برداشت به حساب بانکی'), findsOneWidget);
      expect(find.text('در انتظار'), findsOneWidget);
    });
  });

  group('TransactionSummaryCard widget tests', () {
    testWidgets('computes total inflow and outflow correctly', (tester) async {
      final txList = [
        Transactions(amount: '200.00', isPlus: true, trxCurrencySymbol: r'$'),
        Transactions(amount: '50.00', isPlus: false, trxCurrencySymbol: r'$'),
        Transactions(amount: '150.00', isPlus: true, trxCurrencySymbol: r'$'),
      ];

      await tester.pumpWidget(_host(
        TransactionSummaryCard(transactions: txList),
      ));
      await tester.pumpAndSettle();

      expect(find.text(r'+$350.00'), findsOneWidget);
      expect(find.text(r'-$50.00'), findsOneWidget);
      expect(find.text('3 items'), findsOneWidget);
    });
  });

  group('TransactionDateGroupHeader widget tests', () {
    testWidgets('renders title and item count pill', (tester) async {
      await tester.pumpWidget(_host(
        const TransactionDateGroupHeader(title: 'Today', count: 4),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });
  });

  group('TransactionShimmerSkeleton widget tests', () {
    testWidgets('renders shimmer skeleton in Dark Mode without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_host(
        const TransactionShimmerSkeleton(),
        themeMode: ThemeMode.dark,
      ));
      await tester.pump();

      expect(find.byType(TransactionShimmerSkeleton), findsOneWidget);
    });
  });

  group('TransactionTypeList widget tests', () {
    testWidgets('renders localized types and updates controller on tap', (tester) async {
      final controller = Get.find<TransactionsController>();

      await tester.pumpWidget(_host(
        const SizedBox(
          height: 40,
          child: TransactionTypeList(),
        ),
        locale: const Locale('fa'),
        direction: TextDirection.rtl,
      ));
      await tester.pumpAndSettle();

      expect(find.text('همه'), findsOneWidget);
      expect(find.text('واریز'), findsOneWidget);

      await tester.tap(find.text('واریز'));
      await tester.pumpAndSettle();

      expect(controller.selectedType.value, 'Deposit');
    });
  });

  group('TransactionFilterBottomSheet widget tests', () {
    testWidgets('renders direction chips and status pills', (tester) async {
      int? updatedDir;

      await tester.pumpWidget(_host(
        TransactionFilterBottomSheet(
          initialDirFilter: 0,
          onDirectionChanged: (val) => updatedDir = val,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Filter Transactions'), findsOneWidget);
      expect(find.text('Income (+)'), findsOneWidget);
      expect(find.text('Expense (-)'), findsOneWidget);

      await tester.tap(find.text('Income (+)'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CommonButton));
      await tester.pumpAndSettle();

      expect(updatedDir, 1);
    });
  });
}
