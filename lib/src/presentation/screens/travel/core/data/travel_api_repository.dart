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
  Future<List<TravelOffer>> searchHotels() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/hotel-offers',
      queryParameters: {
        'locale': Get.locale?.toLanguageTag() ?? 'en',
        'city': 'THR',
      },
    );
    return _dataList(response.data)
        .map(_mapHotelOffer)
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
    if (type != TravelProductType.hotel) {
      throw UnsupportedError(
        'The eCardo Travel gateway does not expose this product yet.',
      );
    }
    final checkInDate = bookingDetails.checkInDate;
    final checkOutDate = bookingDetails.checkOutDate;
    if (checkInDate == null || checkOutDate == null) {
      throw ArgumentError('Hotel booking dates are required.');
    }
    final token = await _ensureTravelAccessToken();
    final createResponse = await _client.post<Map<String, dynamic>>(
      '/offer-orders',
      data: {
        'offer_id': productId,
        'check_in_date': _date(checkInDate),
        'check_out_date': _date(checkOutDate),
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
          'Idempotency-Key': 'pay-$idempotencyKey',
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
      type: TravelProductType.hotel,
      titleKey: created['hotel_name']?.toString() ?? 'travelHotelBooking',
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
    return TravelOrder(
      id: (json['public_id'] ?? json['id'])?.toString() ?? '',
      type: TravelProductType.hotel,
      titleKey:
          hotel['name']?.toString() ??
          snapshotHotel['name']?.toString() ??
          productSnapshot['hotel_name']?.toString() ??
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
  Future<List<TravelOffer>> searchFlights() =>
      throw UnsupportedError('Flights are not exposed by the gateway yet.');

  @override
  Future<List<TravelEsimPackage>> getEsimPackages() =>
      throw UnsupportedError('eSIM is not exposed by the gateway yet.');

  @override
  Future<List<TravelTraveler>> getTravelers() =>
      throw UnsupportedError('Saved travelers are not exposed yet.');

  @override
  Future<TravelTraveler> saveTraveler(TravelTraveler traveler) =>
      throw UnsupportedError('Saved travelers are not exposed yet.');

  @override
  Future<List<TravelActivity>> getActivity() =>
      throw UnsupportedError('Combined activity is not exposed yet.');

  static List<Map<String, dynamic>> _dataList(Map<String, dynamic>? root) {
    final data = root?['data'];
    if (data is! List) return const [];
    return data.whereType<Map>().map(Map<String, dynamic>.from).toList();
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
