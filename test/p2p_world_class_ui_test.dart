import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/controller/p2p_order_details_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/model/p2p_marketplace_response_model.dart' as p2p_m;
import 'package:ecardo_user/src/presentation/screens/p2p/model/order_details_response_model.dart' as order_details;
import 'package:ecardo_user/src/presentation/screens/p2p/widgets/p2p_ad_card.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/widgets/order_details_widgets/order_details_action_buttons_widget.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/widgets/order_details_widgets/order_details_timeline_section_widget.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/widgets/order_details_widgets/order_details_title_block_widget.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/widgets/order_details_widgets/order_details_trader_header_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestableWidget(Widget child, {bool isDark = false, Locale locale = const Locale('en')}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => GetMaterialApp(
        theme: ThemeData(brightness: isDark ? Brightness.dark : Brightness.light),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
  }

  group('P2P Ad Card UI/UX Excellence', () {
    testWidgets('renders Pro badge, completion rate %, and colorful payment badges', (tester) async {
      final ad = p2p_m.Ad(
        id: 77,
        adType: 'sell',
        price: '72,500 IRT',
        orderLimit: '1,000,000 - 50,000,000 IRT',
        totalAmount: '5,000 USDT',
        completionRate: 99.4,
        completedOrders: 320,
        responseTime: '15m',
        isOwnAd: false,
        assetCurrency: p2p_m.TCurrency(code: 'USDT'),
        advertiser: p2p_m.Advertiser(
          id: 10,
          username: 'VIP_Merchant',
          fullName: 'VIP Merchant Gold',
          avatarText: 'V',
          isVerifiedTrader: true,
        ),
        paymentMethods: [
          p2p_m.PaymentMethodElement(
            id: 1,
            paymentMethod: p2p_m.PaymentMethodPaymentMethod(id: 1, name: 'Bank Transfer'),
          ),
          p2p_m.PaymentMethodElement(
            id: 2,
            paymentMethod: p2p_m.PaymentMethodPaymentMethod(id: 2, name: 'Sheba'),
          ),
        ],
      );

      await tester.pumpWidget(buildTestableWidget(P2pAdCard(item: ad)));
      await tester.pumpAndSettle();

      // Trader header & Pro merchant badge
      expect(find.text('VIP_Merchant'), findsOneWidget);
      expect(find.text('PRO'), findsOneWidget);
      expect(find.text('99.4%'), findsOneWidget);
      expect(find.textContaining('320'), findsOneWidget);

      // Price & limit typography
      expect(find.text('72,500 IRT'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('5,000 USDT')),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('1,000,000 - 50,000,000 IRT')),
        findsOneWidget,
      );

      // Payment badges
      expect(find.text('Bank Transfer'), findsOneWidget);
      expect(find.text('Sheba'), findsOneWidget);

      // Buy CTA button
      expect(find.text('Buy USDT'), findsOneWidget);
    });

    testWidgets('renders Sell CTA when ad type is buy', (tester) async {
      final ad = p2p_m.Ad(
        id: 88,
        adType: 'buy',
        price: '72,400 IRT',
        orderLimit: '500,000 - 20,000,000 IRT',
        totalAmount: '2,500 USDT',
        completionRate: 97.5,
        completedOrders: 150,
        isOwnAd: false,
        assetCurrency: p2p_m.TCurrency(code: 'USDT'),
        advertiser: p2p_m.Advertiser(
          id: 11,
          username: 'FastBuyer',
          isVerifiedTrader: false,
        ),
      );

      await tester.pumpWidget(buildTestableWidget(P2pAdCard(item: ad)));
      await tester.pumpAndSettle();

      expect(find.text('Sell USDT'), findsOneWidget);
    });
  });

  group('Order Details & Escrow Stepper Excellence', () {
    testWidgets('renders Escrow Protected Banner & Real-time Countdown', (tester) async {
      final controller = P2pOrderDetailsController(orderId: 999);
      final deadline = DateTime.now().add(const Duration(minutes: 14, seconds: 45));

      final orderData = order_details.Data(
        id: 999,
        orderNumber: 'ORD-2026-X999',
        status: 'pending_payment',
        adType: 'sell',
        paymentDeadlineAt: deadline,
      );

      controller.orderData.value = orderData;

      await tester.pumpWidget(buildTestableWidget(
        OrderDetailsTitleBlockWidget(data: orderData, controller: controller),
      ));
      await tester.pumpAndSettle();

      // Escrow Protected Banner
      expect(find.text('Escrow Protected'), findsOneWidget);
      expect(find.text('100% SAFE'), findsOneWidget);

      // Order Number
      expect(find.text('ORD-2026-X999'), findsOneWidget);

      // Live Countdown timer
      expect(find.byIcon(Icons.timer_rounded), findsOneWidget);
    });

    testWidgets('renders 3-Step Escrow Stepper & Prominent Bank Account Details', (tester) async {
      final controller = P2pOrderDetailsController(orderId: 1001);

      final orderData = order_details.Data(
        id: 1001,
        status: 'pending_payment',
        adType: 'sell',
        fiatAmount: '50,000,000 IRT',
        totalFiatAmount: '50,000,000 IRT',
        price: '72,500 IRT',
        assetAmount: '689.65 USDT',
        paymentMethod: order_details.PaymentMethod(id: 1, name: 'Bank Transfer - Sheba'),
        recipientPaymentMethod: order_details.RecipientPaymentMethod(
          id: 1,
          name: 'Saman Bank - Sheba',
          fields: [
            order_details.Field(name: 'Account Holder', value: 'Ali Rezaei'),
            order_details.Field(name: 'Card Number', value: '6037-9918-1234-5678'),
            order_details.Field(name: 'IBAN (Sheba)', value: 'IR120560000000001234567890'),
          ],
        ),
      );

      controller.orderData.value = orderData;

      await tester.pumpWidget(buildTestableWidget(
        OrderDetailsTimelineSectionWidget(data: orderData, controller: controller),
      ));
      await tester.pumpAndSettle();

      // 3-step escrow stepper labels
      expect(find.text('Created'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('Released'), findsOneWidget);

      // Order summary
      expect(find.text('50,000,000 IRT'), findsNWidgets(2)); // summary + bank card total
      expect(find.text('689.65 USDT'), findsOneWidget);

      // Bank account details card
      expect(find.text('Saman Bank - Sheba'), findsOneWidget);
      expect(find.text('Ali Rezaei'), findsOneWidget);
      expect(find.text('6037-9918-1234-5678'), findsOneWidget);
      expect(find.text('IR120560000000001234567890'), findsOneWidget);

      // Security notice
      expect(find.textContaining('Do NOT include crypto terms'), findsOneWidget);
    });

    testWidgets('renders "I have paid" button and opens confirmation dialog', (tester) async {
      final controller = P2pOrderDetailsController(orderId: 1002);

      final orderData = order_details.Data(
        id: 1002,
        status: 'pending_payment',
        adType: 'sell',
        totalFiatAmount: '35,000,000 IRT',
      );

      controller.orderData.value = orderData;

      await tester.pumpWidget(buildTestableWidget(
        OrderDetailsActionButtonsWidget(data: orderData, controller: controller),
      ));
      await tester.pumpAndSettle();

      final paidButton = find.text('Transferred, Notify Seller');
      expect(paidButton, findsOneWidget);

      // Tap "I have paid" button
      await tester.tap(paidButton);
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.text('Confirm Payment Transfer'), findsOneWidget);
      expect(find.textContaining('Amount: 35,000,000 IRT'), findsOneWidget);
      expect(find.text('I Have Paid'), findsOneWidget);
    });

    testWidgets('renders Trader Header with Pro Gold Badge & Chat Action', (tester) async {
      bool chatTapped = false;

      await tester.pumpWidget(buildTestableWidget(
        OrderDetailsTraderHeaderWidget(
          avatarText: 'S',
          name: 'SuperTrader',
          isVerified: true,
          onTap: () => chatTapped = true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('SuperTrader'), findsOneWidget);
      expect(find.text('PRO'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);

      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();

      expect(chatTapped, isTrue);
    });
  });
}
