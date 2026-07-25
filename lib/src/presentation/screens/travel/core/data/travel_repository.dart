import '../models/travel_models.dart';

abstract interface class TravelRepository {
  Future<List<TravelOffer>> searchHotels();

  Future<List<TravelOffer>> searchFlights();

  Future<List<TravelEsimPackage>> getEsimPackages();

  Future<List<TravelTraveler>> getTravelers();

  Future<TravelTraveler> saveTraveler(TravelTraveler traveler);

  Future<List<TravelOrder>> getOrders();

  Future<List<TravelActivity>> getActivity();

  Future<TravelOrder> createOrder({
    required TravelProductType type,
    required String productId,
    required TravelMoney expectedTotal,
    required String idempotencyKey,
    required TravelBookingDetails bookingDetails,
  });
}

class HybridTravelRepository implements TravelRepository {
  final TravelRepository gateway;
  final TravelRepository fallback;

  const HybridTravelRepository({
    required this.gateway,
    required this.fallback,
  });

  @override
  Future<List<TravelOffer>> searchHotels() => gateway.searchHotels();

  @override
  Future<List<TravelOffer>> searchFlights() => fallback.searchFlights();

  @override
  Future<List<TravelEsimPackage>> getEsimPackages() =>
      fallback.getEsimPackages();

  @override
  Future<List<TravelTraveler>> getTravelers() => fallback.getTravelers();

  @override
  Future<TravelTraveler> saveTraveler(TravelTraveler traveler) =>
      fallback.saveTraveler(traveler);

  @override
  Future<List<TravelOrder>> getOrders() => gateway.getOrders();

  @override
  Future<List<TravelActivity>> getActivity() => fallback.getActivity();

  @override
  Future<TravelOrder> createOrder({
    required TravelProductType type,
    required String productId,
    required TravelMoney expectedTotal,
    required String idempotencyKey,
    required TravelBookingDetails bookingDetails,
  }) {
    if (type != TravelProductType.hotel) {
      return fallback.createOrder(
        type: type,
        productId: productId,
        expectedTotal: expectedTotal,
        idempotencyKey: idempotencyKey,
        bookingDetails: bookingDetails,
      );
    }
    return gateway.createOrder(
      type: type,
      productId: productId,
      expectedTotal: expectedTotal,
      idempotencyKey: idempotencyKey,
      bookingDetails: bookingDetails,
    );
  }
}

class MockTravelRepository implements TravelRepository {
  static const _delay = Duration(milliseconds: 350);
  final List<TravelTraveler> _travelers = [
    const TravelTraveler(
      id: 'traveler-1',
      fullName: 'Sara Ahmadi',
      passportNumber: 'P4829137',
      nationalityCode: 'IR',
    ),
    const TravelTraveler(
      id: 'traveler-2',
      fullName: 'Arman Ahmadi',
      passportNumber: 'P7312048',
      nationalityCode: 'IR',
    ),
  ];

  @override
  Future<List<TravelOffer>> searchHotels() async {
    await Future<void>.delayed(_delay);
    return const [
      TravelOffer(
        id: 'hotel-espinas',
        type: TravelProductType.hotel,
        titleKey: 'travelMockHotelEspinas',
        subtitleKey: 'travelMockHotelEspinasLocation',
        badgeKey: 'travelRecommended',
        total: TravelMoney(amount: 4800000, currency: 'IRR'),
        rating: 4.9,
        featureKeys: [
          'travelFeatureBreakfast',
          'travelFeaturePool',
          'travelFeatureWifi',
        ],
        metadata: {'rooms': '1', 'nights': '2'},
      ),
      TravelOffer(
        id: 'hotel-parsian',
        type: TravelProductType.hotel,
        titleKey: 'travelMockHotelParsian',
        subtitleKey: 'travelMockHotelParsianLocation',
        badgeKey: 'travelBestValue',
        total: TravelMoney(amount: 3150000, currency: 'IRR'),
        rating: 4.7,
        featureKeys: ['travelFeatureParking', 'travelFeatureWifi'],
        metadata: {'rooms': '1', 'nights': '2'},
      ),
      TravelOffer(
        id: 'hotel-visteria',
        type: TravelProductType.hotel,
        titleKey: 'travelMockHotelVisteria',
        subtitleKey: 'travelMockHotelVisteriaLocation',
        badgeKey: 'travelLuxury',
        total: TravelMoney(amount: 3900000, currency: 'IRR'),
        rating: 4.5,
        featureKeys: ['travelFeaturePool', 'travelFeatureAirportTransfer'],
        metadata: {'rooms': '1', 'nights': '2'},
      ),
    ];
  }

  @override
  Future<List<TravelOffer>> searchFlights() async {
    await Future<void>.delayed(_delay);
    return const [
      TravelOffer(
        id: 'flight-ec-218',
        type: TravelProductType.flight,
        titleKey: 'travelMockFlightTehranIstanbul',
        subtitleKey: 'travelMockAirlineOne',
        badgeKey: 'travelDirect',
        total: TravelMoney(amount: 6200000, currency: 'IRR'),
        rating: 4.8,
        featureKeys: ['travelFeatureCabinBag', 'travelFeatureRefundable'],
        metadata: {
          'origin': 'THR',
          'destination': 'IST',
          'departure': '08:30',
          'arrival': '11:20',
          'duration': '03:20',
        },
      ),
      TravelOffer(
        id: 'flight-ec-402',
        type: TravelProductType.flight,
        titleKey: 'travelMockFlightTehranIstanbul',
        subtitleKey: 'travelMockAirlineTwo',
        badgeKey: 'travelLowestPrice',
        total: TravelMoney(amount: 5750000, currency: 'IRR'),
        rating: 4.5,
        featureKeys: ['travelFeatureCabinBag'],
        metadata: {
          'origin': 'THR',
          'destination': 'IST',
          'departure': '14:10',
          'arrival': '17:25',
          'duration': '03:45',
        },
      ),
    ];
  }

  @override
  Future<List<TravelEsimPackage>> getEsimPackages() async {
    await Future<void>.delayed(_delay);
    return const [
      TravelEsimPackage(
        id: 'esim-tr-3',
        destinationCode: 'TR',
        dataLabel: '3 GB',
        validityDays: 15,
        total: TravelMoney(amount: 850000, currency: 'IRR'),
      ),
      TravelEsimPackage(
        id: 'esim-tr-10',
        destinationCode: 'TR',
        dataLabel: '10 GB',
        validityDays: 30,
        total: TravelMoney(amount: 1900000, currency: 'IRR'),
        isPopular: true,
      ),
      TravelEsimPackage(
        id: 'esim-global-20',
        destinationCode: 'GLOBAL',
        dataLabel: '20 GB',
        validityDays: 30,
        total: TravelMoney(amount: 3250000, currency: 'IRR'),
      ),
    ];
  }

  @override
  Future<List<TravelTraveler>> getTravelers() async {
    await Future<void>.delayed(_delay);
    return List.unmodifiable(_travelers);
  }

  @override
  Future<TravelTraveler> saveTraveler(TravelTraveler traveler) async {
    await Future<void>.delayed(_delay);
    final savedTraveler = traveler.id.isEmpty
        ? TravelTraveler(
            id: 'traveler-${DateTime.now().millisecondsSinceEpoch}',
            fullName: traveler.fullName,
            passportNumber: traveler.passportNumber,
            nationalityCode: traveler.nationalityCode,
          )
        : traveler;
    final index = _travelers.indexWhere(
      (item) => item.id == savedTraveler.id,
    );
    if (index == -1) {
      _travelers.add(savedTraveler);
    } else {
      _travelers[index] = savedTraveler;
    }
    return savedTraveler;
  }

  @override
  Future<List<TravelOrder>> getOrders() async {
    await Future<void>.delayed(_delay);
    return [
      TravelOrder(
        id: 'order-hotel-1',
        type: TravelProductType.hotel,
        titleKey: 'travelMockHotelEspinas',
        reference: 'ECH-784251',
        total: const TravelMoney(amount: 4800000, currency: 'IRR'),
        status: TravelOrderStatus.confirmed,
        createdAt: DateTime(2026, 7, 18, 14, 30),
        details: const {'checkIn': '2026-08-12', 'checkOut': '2026-08-14'},
      ),
      TravelOrder(
        id: 'order-flight-1',
        type: TravelProductType.flight,
        titleKey: 'travelMockFlightTehranIstanbul',
        reference: 'ECF-193820',
        total: const TravelMoney(amount: 6200000, currency: 'IRR'),
        status: TravelOrderStatus.confirmed,
        createdAt: DateTime(2026, 7, 15, 9, 10),
        details: const {'route': 'THR → IST', 'departure': '2026-08-20'},
      ),
      TravelOrder(
        id: 'order-esim-1',
        type: TravelProductType.esim,
        titleKey: 'travelEsimTurkey',
        reference: 'ECE-642190',
        total: const TravelMoney(amount: 850000, currency: 'IRR'),
        status: TravelOrderStatus.active,
        createdAt: DateTime(2026, 7, 12, 10, 15),
        details: const {'data': '3 GB', 'validity': '15'},
      ),
    ];
  }

  @override
  Future<List<TravelActivity>> getActivity() async {
    await Future<void>.delayed(_delay);
    return [
      TravelActivity(
        id: 'activity-1',
        titleKey: 'travelActivityFlightPurchase',
        subtitleKey: 'travelMockFlightTehranIstanbul',
        amount: const TravelMoney(amount: 6200000, currency: 'IRR'),
        isCredit: false,
        createdAt: DateTime(2026, 7, 15, 9, 10),
        type: TravelProductType.flight,
      ),
      TravelActivity(
        id: 'activity-2',
        titleKey: 'travelActivityEsimPurchase',
        subtitleKey: 'travelEsimTurkey',
        amount: const TravelMoney(amount: 850000, currency: 'IRR'),
        isCredit: false,
        createdAt: DateTime(2026, 7, 12, 10, 15),
        type: TravelProductType.esim,
      ),
      TravelActivity(
        id: 'activity-3',
        titleKey: 'travelActivityWalletTopUp',
        subtitleKey: 'travelMainWallet',
        amount: const TravelMoney(amount: 10000000, currency: 'IRR'),
        isCredit: true,
        createdAt: DateTime(2026, 7, 10, 9),
      ),
    ];
  }

  @override
  Future<TravelOrder> createOrder({
    required TravelProductType type,
    required String productId,
    required TravelMoney expectedTotal,
    required String idempotencyKey,
    required TravelBookingDetails bookingDetails,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final titleKey = switch (productId) {
      'hotel-parsian' => 'travelMockHotelParsian',
      'hotel-visteria' => 'travelMockHotelVisteria',
      _ => switch (type) {
        TravelProductType.hotel => 'travelMockHotelEspinas',
        TravelProductType.flight => 'travelMockFlightTehranIstanbul',
        TravelProductType.esim => 'travelEsimTurkey',
      },
    };
    return TravelOrder(
      id: 'order-$idempotencyKey',
      type: type,
      titleKey: titleKey,
      reference: switch (type) {
        TravelProductType.hotel => 'ECH-NEW-251',
        TravelProductType.flight => 'ECF-NEW-251',
        TravelProductType.esim => 'ECE-NEW-251',
      },
      total: expectedTotal,
      status: type == TravelProductType.esim
          ? TravelOrderStatus.active
          : TravelOrderStatus.confirmed,
      createdAt: DateTime.now(),
      details: const {},
    );
  }
}
