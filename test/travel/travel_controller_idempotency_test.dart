import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/controller/travel_controller.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/data/travel_repository.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/models/travel_models.dart';

void main() {
  group('TravelController idempotency', () {
    test('reservation retries reuse the same key until success', () async {
      final repository = _FakeTravelRepository()..reservationFailures = 1;
      final controller = TravelController(repository: repository);
      controller.bootstrap.value = _bootstrap();

      expect(
        await controller.reserve(
          type: TravelProductType.hotel,
          productId: 'hotel-1',
          total: _money,
          bookingDetails: const TravelBookingDetails(),
        ),
        isNull,
      );
      expect(
        await controller.reserve(
          type: TravelProductType.hotel,
          productId: 'hotel-1',
          total: _money,
          bookingDetails: const TravelBookingDetails(),
        ),
        isNotNull,
      );

      expect(repository.reservationKeys, hasLength(2));
      expect(repository.reservationKeys.toSet(), hasLength(1));
    });

    test('payment retries reuse the same key until success', () async {
      final repository = _FakeTravelRepository()..paymentFailures = 1;
      final controller = TravelController(repository: repository);
      final reservation = _reservation();

      expect(await controller.payReservation(reservation), isNull);
      expect(await controller.payReservation(reservation), isNotNull);

      expect(repository.paymentKeys, hasLength(2));
      expect(repository.paymentKeys.toSet(), hasLength(1));
    });

    test('refund retries reuse the same key until success', () async {
      final repository = _FakeTravelRepository()..refundFailures = 1;
      final controller = TravelController(repository: repository);
      final order = _order();

      expect(
        await controller.requestRefund(
          order: order,
          reasonCode: 'customer_request',
        ),
        isNull,
      );
      expect(
        await controller.requestRefund(
          order: order,
          reasonCode: 'customer_request',
        ),
        isNotNull,
      );

      expect(repository.refundKeys, hasLength(2));
      expect(repository.refundKeys.toSet(), hasLength(1));
    });

    test('expired reservation clears its payment retry key', () async {
      final repository = _FakeTravelRepository()..paymentFailures = 1;
      final controller = TravelController(repository: repository);
      final activeReservation = _reservation();

      expect(await controller.payReservation(activeReservation), isNull);
      controller.clearExpiredReservationForRetry(activeReservation);
      expect(await controller.payReservation(activeReservation), isNotNull);

      expect(repository.paymentKeys, hasLength(2));
      expect(repository.paymentKeys.toSet(), hasLength(2));
    });
  });
}

const _money = TravelMoney(amount: 100, currency: 'USD');

TravelBootstrap _bootstrap() {
  return const TravelBootstrap(
    currency: 'USD',
    locale: 'en',
    services: [
      TravelServiceConfig(
        type: TravelProductType.hotel,
        displayName: 'Hotels',
        description: '',
        iconKey: 'hotel',
        accentColor: '#000000',
        capabilities: ['catalog_checkout'],
        searchFields: [],
        presentation: {},
        dataMode: 'catalog',
      ),
    ],
  );
}

TravelReservation _reservation() {
  return TravelReservation(
    id: 'reservation-1',
    orderNumber: 'TRV-1',
    title: 'Hotel',
    type: TravelProductType.hotel,
    total: _money,
    expiresAt: DateTime.now().add(const Duration(minutes: 10)),
  );
}

TravelOrder _order({
  TravelOrderStatus status = TravelOrderStatus.confirmed,
  String rawStatus = 'booked',
}) {
  return TravelOrder(
    id: 'order-1',
    type: TravelProductType.hotel,
    titleKey: 'Hotel',
    reference: 'TRV-1',
    total: _money,
    status: status,
    rawStatus: rawStatus,
    createdAt: DateTime(2026, 8, 3),
    details: const {},
  );
}

class _FakeTravelRepository implements TravelRepository {
  @override
  Future<List<TravelSuggestion>> getSuggestions(
    TravelProductType type, {
    String query = '',
    int limit = 20,
  }) async => const [];

  int reservationFailures = 0;
  int paymentFailures = 0;
  int refundFailures = 0;
  final List<String> reservationKeys = [];
  final List<String> paymentKeys = [];
  final List<String> refundKeys = [];

  @override
  Future<TravelReservation> createReservation({
    required TravelProductType type,
    required String productId,
    required TravelMoney expectedTotal,
    required String idempotencyKey,
    required TravelBookingDetails bookingDetails,
  }) async {
    reservationKeys.add(idempotencyKey);
    if (reservationFailures-- > 0) throw StateError('reservation failed');
    return _reservation();
  }

  @override
  Future<TravelOrder> payReservation({
    required TravelReservation reservation,
    required String idempotencyKey,
  }) async {
    paymentKeys.add(idempotencyKey);
    if (paymentFailures-- > 0) throw StateError('payment failed');
    return _order(status: TravelOrderStatus.paymentReceived);
  }

  @override
  Future<TravelOrder> requestRefund({
    required TravelOrder order,
    required String reasonCode,
    String? customerNote,
    required String idempotencyKey,
  }) async {
    refundKeys.add(idempotencyKey);
    if (refundFailures-- > 0) throw StateError('refund failed');
    return _order(
      status: TravelOrderStatus.refundPending,
      rawStatus: 'refund_requested',
    );
  }

  @override
  Future<TravelBootstrap> getBootstrap() async => _bootstrap();

  @override
  Future<List<TravelActivity>> getActivity() async => const [];

  @override
  Future<List<TravelEsimPackage>> getEsimPackages(
    String destinationCode,
  ) async => const [];

  @override
  Future<TravelOffer> getOfferDetails(TravelProductType type, String offerId) {
    throw UnimplementedError();
  }

  @override
  Future<List<TravelOrder>> getOrders() async => const [];

  @override
  Future<List<TravelTraveler>> getTravelers() async => const [];

  @override
  Future<TravelTravelerProfile> getTravelerProfile() async =>
      const TravelTravelerProfile(complete: false);

  @override
  Future<List<TravelOffer>> getUpcomingFlights() async => const [];

  @override
  Future<TravelTraveler> saveTraveler(TravelTraveler traveler) async =>
      traveler;

  @override
  Future<TravelTravelerProfile> updateTravelerProfile(
    TravelPassenger passenger, {
    String phone = '',
  }) async => TravelTravelerProfile(
    complete: passenger.isComplete,
    passenger: passenger,
    phone: phone,
  );

  @override
  Future<List<TravelOffer>> searchFlights(TravelFlightSearch search) async =>
      const [];

  @override
  Future<List<TravelOffer>> searchHotels(TravelHotelSearch search) async =>
      const [];
}
