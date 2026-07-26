import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:qunzo_user/src/network/service/token_service.dart';

import '../models/travel_models.dart';
import 'travel_repository.dart';

class TravelApiRepository implements TravelRepository {
  static const String baseUrl = 'https://trip.ecardo.ir/api/v1';

  final Dio _client;
  String? _travelAccessToken;
  DateTime? _travelAccessTokenExpiresAt;

  TravelApiRepository({Dio? client})
    : _client =
          client ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 30),
              contentType: Headers.jsonContentType,
              headers: const {'Accept': 'application/json'},
            ),
          );

  @override
  Future<TravelBootstrap> getBootstrap() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/travel/bootstrap',
      queryParameters: {'locale': _locale},
      options: _localeOptions(),
    );
    final data = _map(response.data?['data']);
    final services = _listOfMaps(data['services'])
        .map(_mapService)
        .whereType<TravelServiceConfig>()
        .toList();
    return TravelBootstrap(
      currency: data['currency']?.toString() ?? 'IRR',
      locale: data['locale']?.toString() ?? 'en',
      services: services,
    );
  }

  @override
  Future<List<TravelOffer>> searchHotels(TravelHotelSearch search) async {
    final offers = await _searchService('hotel', {
        'city': search.city,
        'check_in': _date(search.checkInDate),
        'check_out': _date(search.checkOutDate),
        'rooms': search.roomCount,
        'adults': search.adultCount,
        'children': search.childCount,
      });
    return offers
        .map((offer) => _mapNormalizedOffer(offer, TravelProductType.hotel))
        .where((offer) => offer.id.isNotEmpty)
        .toList();
  }

  @override
  Future<List<TravelOrder>> getOrders() async {
    final response = await _authorizedGet('/orders');
    return _dataList(response.data)
        .map(_mapOrder)
        .where((order) => order.id.isNotEmpty)
        .toList();
  }

  @override
  Future<TravelOrder> createOrder({
    required TravelProductType type,
    required String productId,
    required TravelMoney expectedTotal,
    required String idempotencyKey,
    required TravelBookingDetails bookingDetails,
  }) async {
    final checkInDate = bookingDetails.checkInDate;
    final checkOutDate = bookingDetails.checkOutDate;
    if (type == TravelProductType.hotel &&
        (checkInDate == null || checkOutDate == null)) {
      throw ArgumentError('Hotel booking dates are required.');
    }
    final token = await _ensureTravelAccessToken();
    final isCatalogOffer = productId.startsWith('master_json:');
    final createResponse = await _client.post<Map<String, dynamic>>(
      isCatalogOffer ? '/catalog-orders' : '/offer-orders',
      data: isCatalogOffer
          ? {
              'service': type.name,
              'offer_id': productId,
              if (checkInDate != null) 'check_in_date': _date(checkInDate),
              if (checkOutDate != null) 'check_out_date': _date(checkOutDate),
              'room_count': bookingDetails.roomCount,
              'adult_count': bookingDetails.adultCount,
              'child_count': bookingDetails.childCount,
            }
          : {
              'offer_id': productId,
              'check_in_date': _date(checkInDate!),
              'check_out_date': _date(checkOutDate!),
              'room_count': bookingDetails.roomCount,
              'adult_count': bookingDetails.adultCount,
              'child_count': bookingDetails.childCount,
            },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Idempotency-Key': idempotencyKey,
        },
      ),
    );
    final created = _map(createResponse.data?['data']);
    final orderId = created['id']?.toString() ?? '';
    if (orderId.isEmpty) {
      throw StateError('Travel order response did not include an order id.');
    }
    final payableAmount = _amount(created['payable_amount']);
    final payableCurrency =
        created['currency']?.toString() ?? expectedTotal.currency;
    if ((payableAmount - expectedTotal.amount).abs() > 0.000001 ||
        payableCurrency != expectedTotal.currency) {
      throw StateError(
        'The authoritative Travel total changed before wallet payment.',
      );
    }
    final payResponse = await _client.post<Map<String, dynamic>>(
      '/orders/${Uri.encodeComponent(orderId)}/pay',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Idempotency-Key':
              'pay-$idempotencyKey-${DateTime.now().millisecondsSinceEpoch}',
        },
      ),
    );
    final paid = _map(payResponse.data?['data']);
    final paidStatus = paid['status']?.toString() ?? '';
    if (!{
      'paid_pending_admin_approval',
      'booked',
      'voucher_generated',
      'completed',
    }.contains(paidStatus)) {
      throw StateError(
        'Travel wallet payment did not reach a successful state.',
      );
    }
    return TravelOrder(
      id: orderId,
      type: type,
      titleKey:
          created['title']?.toString() ??
          created['hotel_name']?.toString() ??
          'travelHotelBooking',
      reference:
          created['order_number']?.toString() ??
          paid['order_number']?.toString() ??
          orderId,
      total: TravelMoney(
        amount: _amount(
          paid['paid_amount'] ??
              created['payable_amount'] ??
              expectedTotal.amount,
        ),
        currency:
            paid['currency']?.toString() ??
            created['currency']?.toString() ??
            expectedTotal.currency,
      ),
      status: _orderStatus(paid['status'] ?? created['status']),
      createdAt: DateTime.now(),
      details: {
        'gateway_status':
            paid['status']?.toString() ?? created['status']?.toString() ?? '',
      },
    );
  }

  Future<Response<Map<String, dynamic>>> _authorizedGet(String path) async {
    final token = await _ensureTravelAccessToken();
    return _client.get<Map<String, dynamic>>(
      path,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<String> _ensureTravelAccessToken() async {
    if (_travelAccessToken?.isNotEmpty == true &&
        _travelAccessTokenExpiresAt?.isAfter(
              DateTime.now().add(const Duration(seconds: 30)),
            ) ==
            true) {
      return _travelAccessToken!;
    }
    if (!Get.isRegistered<TokenService>()) {
      throw StateError('The eCardo authentication token is unavailable.');
    }
    final sourceToken = Get.find<TokenService>().accessToken.value;
    if (sourceToken?.isNotEmpty != true) {
      throw StateError('The user must sign in before using Travel.');
    }
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/exchange',
      data: {'source_token': sourceToken},
    );
    final data = _map(response.data?['data']);
    final token = data['token']?.toString();
    if (token?.isNotEmpty != true) {
      throw StateError('Travel token exchange did not return a token.');
    }
    _travelAccessToken = token;
    _travelAccessTokenExpiresAt = DateTime.tryParse(
      data['expires_at']?.toString() ?? '',
    );
    return token!;
  }

  TravelOffer _mapHotelOffer(Map<String, dynamic> json) {
    final hotel = _map(json['hotel']);
    final price = _map(json['price']);
    final inclusions = _strings(json['inclusions']);
    final amenities = _strings(hotel['amenities']);
    return TravelOffer(
      id: json['id']?.toString() ?? '',
      type: TravelProductType.hotel,
      titleKey: hotel['name']?.toString() ?? '',
      subtitleKey: hotel['city']?.toString() ?? '',
      badgeKey: json['is_demo'] == true
          ? 'travelDemoOffer'
          : 'travelRequiresConfirmation',
      total: TravelMoney(
        amount: _amount(price['amount']),
        currency: price['currency']?.toString() ?? 'IRR',
      ),
      rating: _amount(hotel['star_rating']),
      featureKeys: [...inclusions, ...amenities].take(4).toList(),
      metadata: {
        'room_name': json['room_name']?.toString() ?? '',
        'board_type': json['board_type']?.toString() ?? '',
        'valid_until': json['valid_until']?.toString() ?? '',
        'catalog_revision': json['catalog_revision']?.toString() ?? '',
      },
    );
  }

  TravelOrder _mapOrder(Map<String, dynamic> json) {
    final quote = _map(json['quote']);
    final request = _map(quote['request']);
    final hotel = _map(request['hotel']);
    final booking = _map(json['booking']);
    final productSnapshot = _map(json['product_snapshot']);
    final snapshotHotel = _map(productSnapshot['hotel']);
    final type = switch (productSnapshot['service']?.toString()) {
      'flight' => TravelProductType.flight,
      'esim' => TravelProductType.esim,
      _ => TravelProductType.hotel,
    };
    final snapshotOffer = _map(productSnapshot['offer']);
    return TravelOrder(
      id: (json['public_id'] ?? json['id'])?.toString() ?? '',
      type: type,
      titleKey:
          hotel['name']?.toString() ??
          snapshotHotel['name']?.toString() ??
          productSnapshot['hotel_name']?.toString() ??
          snapshotOffer['title']?.toString() ??
          json['hotel_name']?.toString() ??
          'travelHotelBooking',
      reference:
          json['order_number']?.toString() ??
          booking['supplier_reference']?.toString() ??
          json['public_id']?.toString() ??
          '',
      total: TravelMoney(
        amount: _amount(
          json['paid_amount'] ??
              json['payable_amount'] ??
              json['total_amount'],
        ),
        currency: json['currency']?.toString() ?? 'IRR',
      ),
      status: _orderStatus(json['status']),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      details: {
        'approval_status': json['approval_status']?.toString() ?? '',
        'check_in':
            (json['check_in_date'] ?? request['check_in_date'])?.toString() ??
            '',
        'check_out':
            (json['check_out_date'] ?? request['check_out_date'])?.toString() ??
            '',
      },
    );
  }

  @override
  Future<List<TravelOffer>> searchFlights(TravelFlightSearch search) async {
    final offers = await _searchService('flight', {
      if (search.origin?.isNotEmpty == true) 'origin': search.origin,
      if (search.destination?.isNotEmpty == true)
        'destination': search.destination,
      if (search.departureDate != null)
        'departure_date': _date(search.departureDate!),
      'adults': search.adultCount,
      'children': search.childCount,
    });
    return offers
        .map((offer) => _mapNormalizedOffer(offer, TravelProductType.flight))
        .where((offer) => offer.id.isNotEmpty)
        .toList();
  }

  @override
  Future<List<TravelOffer>> getUpcomingFlights() =>
      searchFlights(const TravelFlightSearch());

  @override
  Future<TravelOffer> getOfferDetails(
    TravelProductType type,
    String offerId,
  ) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/travel/services/${type.name}/offers/${Uri.encodeComponent(offerId)}',
      queryParameters: {'locale': _locale},
      options: _localeOptions(),
    );
    final data = _map(response.data?['data']);
    return _mapNormalizedOffer(_map(data['offer']), type);
  }

  @override
  Future<List<TravelEsimPackage>> getEsimPackages(
    String destinationCode,
  ) async {
    final offers = await _searchService('esim', {
      'country_code': destinationCode,
    });
    return offers.map(_mapEsimPackage).where((item) => item.id.isNotEmpty).toList();
  }

  @override
  Future<List<TravelTraveler>> getTravelers() =>
      throw UnsupportedError('Saved travelers are not exposed yet.');

  @override
  Future<TravelTraveler> saveTraveler(TravelTraveler traveler) =>
      throw UnsupportedError('Saved travelers are not exposed yet.');

  @override
  Future<List<TravelActivity>> getActivity() =>
      throw UnsupportedError('Combined activity is not exposed yet.');

  Future<List<Map<String, dynamic>>> _searchService(
    String service,
    Map<String, dynamic> criteria,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/travel/services/$service/search',
      queryParameters: {'locale': _locale},
      data: {'criteria': criteria},
      options: _localeOptions(),
    );
    final data = _map(response.data?['data']);
    return _listOfMaps(data['offers']);
  }

  static List<Map<String, dynamic>> _dataList(Map<String, dynamic>? root) {
    final data = root?['data'];
    if (data is! List) return const [];
    return data.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  static List<Map<String, dynamic>> _listOfMaps(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  TravelServiceConfig? _mapService(Map<String, dynamic> json) {
    final type = switch (json['key']?.toString()) {
      'hotel' => TravelProductType.hotel,
      'flight' => TravelProductType.flight,
      'esim' => TravelProductType.esim,
      _ => null,
    };
    if (type == null) return null;
    final resultSchema = _map(json['result_schema']);
    return TravelServiceConfig(
      type: type,
      displayName: json['display_name']?.toString() ?? type.name,
      description: json['description']?.toString() ?? '',
      iconKey: json['icon_key']?.toString() ?? type.name,
      accentColor: json['accent_color']?.toString() ?? '',
      capabilities: _strings(json['capabilities']),
      searchFields: _listOfMaps(json['search_schema'])
          .map(
            (field) => TravelSearchField(
              key: field['key']?.toString() ?? '',
              type: field['type']?.toString() ?? 'text',
              label: field['label']?.toString() ?? '',
              hint: field['hint']?.toString(),
              required: field['required'] == true,
              defaultValue: field['default'] is num
                  ? field['default'] as num
                  : num.tryParse(field['default']?.toString() ?? ''),
              minimum: field['min'] is num
                  ? field['min'] as num
                  : num.tryParse(field['min']?.toString() ?? ''),
              maximum: field['max'] is num
                  ? field['max'] as num
                  : num.tryParse(field['max']?.toString() ?? ''),
            ),
          )
          .where((field) => field.key.isNotEmpty)
          .toList(),
      presentation: _map(resultSchema['presentation']),
      dataMode: json['data_mode']?.toString() ?? 'live',
    );
  }

  TravelOffer _mapNormalizedOffer(
    Map<String, dynamic> json,
    TravelProductType type,
  ) {
    final pricing = _map(json['pricing']);
    final attributes = _map(json['attributes']);
    final product = _map(json['product']);
    final policies = _map(json['policies']);
    return TravelOffer(
      id: json['id']?.toString() ?? '',
      type: type,
      titleKey: json['title']?.toString() ?? '',
      subtitleKey: json['subtitle']?.toString() ?? '',
      badgeKey: json['badge']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      total: TravelMoney(
        amount: _amount(pricing['total_amount']),
        currency: pricing['currency']?.toString() ?? 'IRR',
      ),
      rating: _amount(attributes['stars']),
      featureKeys: _strings(json['highlights']).take(4).toList(),
      product: product,
      attributes: attributes,
      policies: policies,
      actions: _listOfMaps(json['actions']),
      pricingComponents: _listOfMaps(pricing['components']),
      metadata: {
        ...attributes.map(
          (key, value) => MapEntry(key, value?.toString() ?? ''),
        ),
        'provider_key': json['provider_key']?.toString() ?? '',
        'booking_mode': json['booking_mode']?.toString() ?? '',
        'departure':
            attributes['departure_time']?.toString() ??
            attributes['departure']?.toString() ??
            '',
        'arrival':
            attributes['arrival_time']?.toString() ??
            attributes['arrival']?.toString() ??
            '',
        'duration': attributes['duration']?.toString() ?? '',
      },
    );
  }

  TravelEsimPackage _mapEsimPackage(Map<String, dynamic> json) {
    final pricing = _map(json['pricing']);
    final attributes = _map(json['attributes']);
    final dataGb = attributes['data_gb'];
    return TravelEsimPackage(
      id: json['id']?.toString() ?? '',
      destinationCode: attributes['country_code']?.toString() ?? '',
      dataLabel: dataGb == null ? '∞' : '${_amount(dataGb).toStringAsFixed(0)} GB',
      validityDays: _amount(attributes['validity_days']).round(),
      total: TravelMoney(
        amount: _amount(pricing['total_amount']),
        currency: pricing['currency']?.toString() ?? 'IRR',
      ),
      isPopular: _strings(json['highlights']).any(
        (item) => item.toLowerCase().contains('best'),
      ),
    );
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  static List<String> _strings(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((item) {
          if (item is Map) {
            return (item['label'] ?? item['name'] ?? item['key'])?.toString();
          }
          return item?.toString();
        })
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static double _amount(dynamic value) {
    return double.tryParse(
          value?.toString().replaceAll(',', '') ?? '0',
        ) ??
        0;
  }

  String get _locale => Get.locale?.languageCode.toLowerCase() ?? 'en';

  Options _localeOptions({Map<String, dynamic>? headers}) {
    return Options(headers: {'X-Locale': _locale, ...?headers});
  }

  static TravelOrderStatus _orderStatus(dynamic value) {
    return switch (value?.toString()) {
      'booked' ||
      'voucher_generated' ||
      'confirmed' => TravelOrderStatus.confirmed,
      'active' => TravelOrderStatus.active,
      'completed' => TravelOrderStatus.completed,
      'refunded' => TravelOrderStatus.refunded,
      'failed' => TravelOrderStatus.failed,
      'quoted' ||
      'pending_payment' ||
      'wallet_processing' ||
      'wallet_locked' ||
      'pending_purchase' ||
      'paid_pending_admin_approval' ||
      'pending_operator' ||
      'cancel_requested' ||
      'refund_requested' ||
      'manual_review' => TravelOrderStatus.pending,
      _ => TravelOrderStatus.completed,
    };
  }

  static String _date(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
