import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/common/services/app_event_bus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Zapier-style AppEventBus integration tests', () {
    test('emits and receives BalanceChangedEvent', () async {
      BalanceChangedEvent? receivedEvent;

      final sub = AppEventBus.on<BalanceChangedEvent>().listen((event) {
        receivedEvent = event;
      });

      AppEventBus.emit(BalanceChangedEvent(
        sourceModule: 'airtime',
        currencyCode: 'USD',
        amount: 25.0,
      ));

      // Allow event stream tick
      await Future.delayed(const Duration(milliseconds: 50));

      expect(receivedEvent, isNotNull);
      expect(receivedEvent!.sourceModule, 'airtime');
      expect(receivedEvent!.currencyCode, 'USD');
      expect(receivedEvent!.amount, 25.0);

      await sub.cancel();
    });

    test('filters events by type accurately without crosstalk', () async {
      int balanceEventCount = 0;
      int kycEventCount = 0;

      final sub1 = AppEventBus.on<BalanceChangedEvent>().listen((_) {
        balanceEventCount++;
      });
      final sub2 = AppEventBus.on<KycStatusChangedEvent>().listen((_) {
        kycEventCount++;
      });

      AppEventBus.emit(KycStatusChangedEvent(newLevel: 2, status: 'approved'));
      AppEventBus.emit(BalanceChangedEvent(sourceModule: 'transfer'));

      await Future.delayed(const Duration(milliseconds: 50));

      expect(balanceEventCount, 1);
      expect(kycEventCount, 1);

      await sub1.cancel();
      await sub2.cancel();
    });

    test('emits and receives WalletListChangedEvent', () async {
      WalletListChangedEvent? received;
      final sub = AppEventBus.on<WalletListChangedEvent>().listen((e) => received = e);

      AppEventBus.emit(WalletListChangedEvent(action: 'create', currencyCode: 'EUR'));

      await Future.delayed(const Duration(milliseconds: 50));

      expect(received, isNotNull);
      expect(received!.action, 'create');
      expect(received!.currencyCode, 'EUR');

      await sub.cancel();
    });
  });
}
