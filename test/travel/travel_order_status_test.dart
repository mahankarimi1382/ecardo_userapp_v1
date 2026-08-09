import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/models/travel_models.dart';

void main() {
  group('travelOrderStatusFromRaw', () {
    test('keeps supported lifecycle distinctions', () {
      expect(
        travelOrderStatusFromRaw('pending_payment'),
        TravelOrderStatus.paymentPending,
      );
      expect(
        travelOrderStatusFromRaw('wallet_processing'),
        TravelOrderStatus.paymentProcessing,
      );
      expect(
        travelOrderStatusFromRaw('paid_pending_admin_approval'),
        TravelOrderStatus.paymentReceived,
      );
      expect(
        travelOrderStatusFromRaw('pending_purchase'),
        TravelOrderStatus.supplierPending,
      );
      expect(travelOrderStatusFromRaw('booked'), TravelOrderStatus.confirmed);
      expect(
        travelOrderStatusFromRaw('voucher_generated'),
        TravelOrderStatus.issued,
      );
      expect(
        travelOrderStatusFromRaw('cancel_requested'),
        TravelOrderStatus.cancellationPending,
      );
      expect(
        travelOrderStatusFromRaw('refund_requested'),
        TravelOrderStatus.refundPending,
      );
      expect(
        travelOrderStatusFromRaw('cancelled'),
        TravelOrderStatus.cancelled,
      );
      expect(travelOrderStatusFromRaw('refunded'), TravelOrderStatus.refunded);
    });

    test('unknown and blank values stay unknown', () {
      expect(
        travelOrderStatusFromRaw('new_provider_state'),
        TravelOrderStatus.unknown,
      );
      expect(travelOrderStatusFromRaw(''), TravelOrderStatus.unknown);
    });
  });

  group('TravelOrder lifecycle capabilities', () {
    test('unknown status never exposes voucher or cancellation actions', () {
      final order = _order(
        rawStatus: 'new_provider_state',
        status: TravelOrderStatus.unknown,
        details: const {'voucher_number': 'VCH-unsafe'},
      );

      expect(order.hasIssuedVoucher, isFalse);
      expect(order.canRequestCancellation, isFalse);
      expect(order.group, TravelOrderGroup.attention);
    });

    test('issued voucher and cancellable backend states are explicit', () {
      final order = _order(
        rawStatus: 'voucher_generated',
        status: TravelOrderStatus.issued,
      );

      expect(order.hasIssuedVoucher, isTrue);
      expect(order.canRequestCancellation, isTrue);
      expect(order.group, TravelOrderGroup.upcoming);
    });

    test('refund review removes issued and duplicate request actions', () {
      final order = _order(
        rawStatus: 'refund_requested',
        status: TravelOrderStatus.refundPending,
        details: const {'voucher_number': 'VCH-123'},
      );

      expect(order.hasIssuedVoucher, isFalse);
      expect(order.canRequestCancellation, isFalse);
      expect(order.group, TravelOrderGroup.cancellation);
    });
  });
}

TravelOrder _order({
  required String rawStatus,
  required TravelOrderStatus status,
  Map<String, String> details = const {},
}) {
  return TravelOrder(
    id: 'order-1',
    type: TravelProductType.hotel,
    titleKey: 'Hotel',
    reference: 'TRV-1',
    total: const TravelMoney(amount: 10, currency: 'USD'),
    status: status,
    rawStatus: rawStatus,
    createdAt: DateTime(2026, 7, 28),
    details: details,
  );
}
