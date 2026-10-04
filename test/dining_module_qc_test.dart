import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/presentation/screens/travel/dining/controllers/dining_controller.dart';
import 'package:ecardo_user/src/presentation/screens/travel/dining/models/dining_models.dart';
import 'package:ecardo_user/src/presentation/screens/travel/dining/screens/dining_catalog_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/dining/screens/dining_order_pass_screen.dart';

Widget _host(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => GetMaterialApp(
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('PonnamKarthik/fluttertoast'),
      (MethodCall methodCall) async => true,
    );
  });

  void phoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(750, 1624);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  tearDown(() {
    Get.reset();
  });

  group('Dining Module Unit & Cart Tests', () {
    test('DiningController cart operations, totals and order submission work', () async {
      final controller = Get.put(DiningController());
      final rest = controller.allRestaurants.first;
      final item1 = rest.menu[0];
      final item2 = rest.menu[1];

      expect(controller.cartCount, equals(0));

      controller.addToCart(rest, item1);
      expect(controller.cartCount, equals(1));
      expect(controller.getItemQuantity(item1.id), equals(1));

      controller.addToCart(rest, item1);
      expect(controller.cartCount, equals(2));
      expect(controller.getItemQuantity(item1.id), equals(2));

      controller.addToCart(rest, item2);
      expect(controller.cartCount, equals(3));
      // item1: 18 * 2 = 36 + item2: 12 = 48
      expect(controller.cartSubtotal, equals(48.0));

      final order = await controller.submitOrder();
      expect(order, isNotNull);
      expect(order!.totalAmount, equals(48.0));
      expect(controller.cartCount, equals(0));
      expect(controller.myOrders.first.orderId, equals(order.orderId));
    });

    testWidgets('DiningCatalogScreen renders transit dining catalog with hubs', (tester) async {
      phoneSurface(tester);
      await tester.pumpWidget(_host(const DiningCatalogScreen()));
      await tester.pumpAndSettle();

      expect(find.text('In-Transit Dining'), findsOneWidget);
      expect(find.text('همه پایانه‌ها ✈️'), findsOneWidget);
      expect(find.text('فرودگاه امام (IKA) 🇮🇷'), findsOneWidget);
      expect(find.textContaining('پرشین لانژ'), findsOneWidget);
    });

    testWidgets('DiningOrderPassScreen renders barcode and pickup details', (tester) async {
      phoneSurface(tester);
      final sampleOrder = DiningOrderModel(
        orderId: 'MEAL-77123',
        restaurantId: 'rest-01',
        restaurantName: 'Persian Sky Lounge (IKA)',
        terminalLocation: 'Tehran Imam Khomeini Airport — Gate 18',
        mode: DiningServiceMode.airportGatePickup,
        gateOrTable: 'Gate 18',
        pickupTime: '15:30',
        items: [
          DiningOrderItem(
            item: const MenuItemModel(
              id: 'menu-01',
              title: 'Special Kabab with Saffron Rice',
              description: '',
              price: 18.0,
              currency: 'USD',
              calories: 720,
              prepMinutes: 15,
            ),
            quantity: 2,
          ),
        ],
        totalAmount: 36.0,
        currency: 'USD',
        status: 'ready_for_pickup',
        orderedAt: DateTime(2026, 10, 12, 15, 0),
      );

      await tester.pumpWidget(_host(DiningOrderPassScreen(order: sampleOrder)));
      await tester.pumpAndSettle();

      expect(find.text('Travel Dining Pass'), findsOneWidget);
      expect(find.text('eCardo In-Transit Dining'), findsOneWidget);
      expect(find.text('Persian Sky Lounge (IKA)'), findsOneWidget);
      expect(find.text('15:30'), findsOneWidget);
      expect(find.text('Gate 18'), findsOneWidget);
      expect(find.text('2× Special Kabab with Saffron Rice'), findsOneWidget);
      expect(find.textContaining('MEAL-77123'), findsOneWidget);
    });
  });
}
