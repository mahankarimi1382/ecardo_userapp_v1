import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/travel_service_request.dart';

import 'taxi_models.dart';

/// Where the returned payload came from. `fallback` means the live
/// `api/ride/*` call did not succeed (offline, unauthorized, or the route is
/// not reachable from this build) and a safe deterministic local value was
/// produced instead. Screens MUST surface this as `Partial`/`Offline`, never
/// as a confirmed backend booking.
enum RideDataSource { network, fallback }

/// Transport boundary for the `api/ride/*` subsystem. Injected so the unit
/// tests can replay realistic Laravel envelopes without a live backend.
abstract class RideTransport {
  Future<RideTransportResponse> get(String endpoint, {Map<String, dynamic>? query});
  Future<RideTransportResponse> post(String endpoint, Map<String, dynamic> data);
}

/// Normalized transport outcome — never throws to the caller.
class RideTransportResponse {
  final bool ok;
  final bool unauthorized;
  final String? message;

  /// Decoded JSON envelope, e.g. `{"status":"success","data":{...}}`.
  final Map<String, dynamic>? body;

  const RideTransportResponse({
    required this.ok,
    this.unauthorized = false,
    this.message,
    this.body,
  });

  const RideTransportResponse.networkFailed([String? reason])
      : ok = false,
        unauthorized = false,
        message = reason ?? 'network_unreachable',
        body = null;

  const RideTransportResponse.success(Map<String, dynamic> this.body)
      : ok = true,
        unauthorized = false,
        message = null;

  const RideTransportResponse.rejected({this.unauthorized = false, this.message})
      : ok = false,
        body = null;
}

/// NetworkService-backed transport against `https://ecardo.ir/api/ride/*`.
class NetworkRideTransport implements RideTransport {
  NetworkService? get _network =>
      Get.isRegistered<NetworkService>() ? Get.find<NetworkService>() : null;

  @override
  Future<RideTransportResponse> get(String endpoint, {Map<String, dynamic>? query}) async {
    final net = _network;
    if (net == null) return const RideTransportResponse.networkFailed();
    final full = _withQuery(endpoint, query);
    try {
      final response = await net.get(endpoint: full);
      return _map(response.data, response.status);
    } catch (e) {
      if (kDebugMode) debugPrint('NetworkRideTransport GET $full failed: $e');
      return RideTransportResponse.networkFailed(e.toString());
    }
  }

  @override
  Future<RideTransportResponse> post(String endpoint, Map<String, dynamic> data) async {
    final net = _network;
    if (net == null) return const RideTransportResponse.networkFailed();
    try {
      final response = await net.post(endpoint: endpoint, data: data);
      return _map(response.data, response.status);
    } catch (e) {
      if (kDebugMode) debugPrint('NetworkRideTransport POST $endpoint failed: $e');
      return RideTransportResponse.networkFailed(e.toString());
    }
  }

  static String _withQuery(String endpoint, Map<String, dynamic>? query) {
    if (query == null || query.isEmpty) return endpoint;
    final uri = Uri(
      path: endpoint,
      queryParameters: query.map((key, value) => MapEntry(key, value?.toString() ?? '')),
    );
    return uri.toString();
  }

  static RideTransportResponse _map(
    Map<String, dynamic>? body,
    dynamic status,
  ) {
    final envelope = body ?? const <String, dynamic>{};
    final errors = envelope['errors'];
    final errorText = errors is List && errors.isNotEmpty ? errors.first.toString() : null;
    final unauthorized =
        errorText?.contains('Unauthenticated') == true || errorText?.contains('auth') == true;
    if (status == Status.completed && errorText == null) {
      return RideTransportResponse.success(envelope);
    }
    return RideTransportResponse.rejected(
      unauthorized: unauthorized,
      message: errorText ?? 'request_failed',
    );
  }
}

/// Typed result wrapper: payload + provenance + auth signal.
class RideServiceResult<T> {
  final T data;
  final RideDataSource source;
  final bool unauthorized;
  final String? message;

  const RideServiceResult({
    required this.data,
    required this.source,
    this.unauthorized = false,
    this.message,
  });

  bool get isFallback => source == RideDataSource.fallback;
}

/// Airport Transfer & Taxi API client over the deployed `api/ride/*` routes:
/// geo, history, places, quote, requests, support, vehicle-types.
///
/// Every method degrades gracefully: a network miss yields a deterministic
/// local value flagged as [RideDataSource.fallback], so the UI can render the
/// Offline/Partial states instead of a fake "success".
class TaxiApiService extends GetxService {
  final RideTransport transport;

  TaxiApiService({RideTransport? transport})
      : transport = transport ?? NetworkRideTransport();

  static const Color brandTeal = Color(0xFF0D9488);

  /// Local vehicle catalog — used when `GET /ride/vehicle-types` is
  /// unreachable. Kept identical in shape to what `TaxiVehicleClass.fromJson`
  /// expects from the backend so cards render the same either way.
  static const List<TaxiVehicleClass> fallbackVehicles = [
    TaxiVehicleClass(
      id: 'economy',
      title: 'Economy Sedan',
      titleFa: 'سواری اقتصادی',
      titleEn: 'Economy Sedan',
      exampleModels: 'پژو پارس / سمند سورن / رنو تندر',
      maxPassengers: 3,
      maxLuggage: 2,
      basePrice: 650000,
      icon: Icons.directions_car_rounded,
      features: ['کولر و تهویه فعال', 'امکان پیگیری آنلاین', 'بیمه سرنشین'],
    ),
    TaxiVehicleClass(
      id: 'comfort',
      title: 'Comfort Sedan',
      titleFa: 'سواری کامفورت',
      titleEn: 'Comfort Sedan',
      exampleModels: 'تویوتا کرولا / کمری / هیوندای النترا',
      maxPassengers: 4,
      maxLuggage: 3,
      basePrice: 1100000,
      icon: Icons.airport_shuttle_rounded,
      features: ['صندلی راحت', 'آب معدنی رایگان', 'وای‌فای'],
    ),
    TaxiVehicleClass(
      id: 'vip',
      title: 'VIP Executive',
      titleFa: 'تشریفات VIP',
      titleEn: 'VIP Executive',
      exampleModels: 'مرسدس بنز E-Class / ب‌ام‌و سری ۵',
      maxPassengers: 3,
      maxLuggage: 3,
      basePrice: 2400000,
      icon: Icons.stars_rounded,
      features: ['ناوگان تشریفاتی لوکس', 'تابلو استقبال اختصاصی', 'راننده مسلط به زبان'],
      isVip: true,
    ),
    TaxiVehicleClass(
      id: 'van',
      title: 'Family Minivan',
      titleFa: 'ون خانوادگی (۷ نفره)',
      titleEn: 'Family Minivan',
      exampleModels: 'تویوتا هایس / هیوندای H1',
      maxPassengers: 7,
      maxLuggage: 6,
      basePrice: 1850000,
      icon: Icons.directions_bus_rounded,
      features: ['فضای جادار چمدان‌ها', 'مناسب سفرهای گروهی', 'صندلی کودک در صورت درخواست'],
    ),
  ];

  static const int meetAndGreetFeeIrr = 150000;
  static const int childSeatFeeIrr = 75000;

  // ---------------------------------------------------------------- catalog

  /// `GET /ride/vehicle-types?city={code}` — fixed-price fleet for a city.
  Future<RideServiceResult<List<TaxiVehicleClass>>> getVehicleTypes({
    String? cityCode,
  }) async {
    final endpoint = cityCode == null
        ? '/ride/vehicle-types'
        : '/ride/vehicle-types?city=$cityCode';
    final response = await transport.get(endpoint);
    final list = _extractList(response.body, const ['vehicle_types', 'types', 'items', 'data']);
    if (response.ok && list != null && list.isNotEmpty) {
      return RideServiceResult(
        data: list.map((e) => TaxiVehicleClass.fromJson(e)).toList(),
        source: RideDataSource.network,
      );
    }
    return RideServiceResult(
      data: fallbackVehicles,
      source: RideDataSource.fallback,
      unauthorized: response.unauthorized,
      message: response.message,
    );
  }

  /// `GET /ride/places` — the rider's saved addresses.
  Future<RideServiceResult<List<RidePlace>>> getSavedPlaces() async {
    final response = await transport.get('/ride/places');
    final list = _extractList(response.body, const ['places', 'saved_places', 'items', 'data']);
    if (response.ok && list != null) {
      return RideServiceResult(
        data: list.map((e) => RidePlace.fromJson(e)).toList(),
        source: RideDataSource.network,
      );
    }
    return RideServiceResult(
      data: RidePlace.popularAirportPlaces,
      source: RideDataSource.fallback,
      unauthorized: response.unauthorized,
      message: response.message,
    );
  }

  /// `GET /ride/geo?q=` — forward-geocode pickup / dropoff candidates.
  Future<RideServiceResult<List<RidePlace>>> searchPlaces(String query) async {
    final clean = query.trim();
    if (clean.length < 2) {
      return RideServiceResult(
        data: RidePlace.popularAirportPlaces,
        source: RideDataSource.fallback,
        message: 'query_too_short',
      );
    }
    final response = await transport.get(
      '/ride/geo',
      query: {'q': clean},
    );
    final list = _extractList(response.body, const ['results', 'places', 'predictions', 'items']);
    if (response.ok && list != null) {
      return RideServiceResult(
        data: list.map((e) => RidePlace.fromJson(e)).toList(),
        source: RideDataSource.network,
      );
    }
    final lower = clean.toLowerCase();
    final local = RidePlace.popularAirportPlaces.where((p) {
      return p.title.toLowerCase().contains(lower) ||
          p.titleFa.contains(clean) ||
          p.subtitle.toLowerCase().contains(lower) ||
          p.subtitleFa.contains(clean) ||
          p.address.toLowerCase().contains(lower) ||
          (p.iataCode?.toLowerCase().contains(lower) ?? false);
    }).toList();
    return RideServiceResult(
      data: local,
      source: RideDataSource.fallback,
      unauthorized: response.unauthorized,
      message: response.message,
    );
  }

  // ------------------------------------------------------------------ quote

  /// `POST /ride/quote` — authoritative fixed price per vehicle class.
  Future<RideServiceResult<RideQuote>> requestQuote({
    required TaxiRideType rideType,
    required String origin,
    required String destination,
    required DateTime pickupDate,
    required String pickupTime,
    required int passengerCount,
    required int luggageCount,
    required bool meetAndGreet,
    int childSeatCount = 0,
    List<TaxiVehicleClass>? vehicles,
  }) async {
    final activeVehicles =
        (vehicles == null || vehicles.isEmpty) ? fallbackVehicles : vehicles;
    final payload = <String, dynamic>{
      'ride_type': _rideTypeWire(rideType),
      'origin': origin,
      'destination': destination,
      'pickup_date': pickupDate.toIso8601String().split('T').first,
      'pickup_time': pickupTime,
      'passenger_count': passengerCount,
      'luggage_count': luggageCount,
      'meet_and_greet': meetAndGreet,
      'child_seat_count': childSeatCount,
    };

    final response = await transport.post('/ride/quote', payload);
    final data = _extractMap(response.body, const ['data', 'quote']);
    if (response.ok && data != null) {
      final quote = RideQuote.fromJson(data, activeVehicles);
      if (quote.vehicleQuotes.isNotEmpty) {
        return RideServiceResult(data: quote, source: RideDataSource.network);
      }
    }

    // Deterministic fallback quote so the flow never dead-ends; marked
    // `fallback` so the UI shows the partial/notice treatment.
    final meetFee = meetAndGreet ? meetAndGreetFeeIrr : 0;
    final childFee = childSeatCount * childSeatFeeIrr;
    final multiplier = rideType == TaxiRideType.intercity ? 1.6 : 1.0;

    final quotes = activeVehicles.map((v) {
      final adjustedBase = (v.basePrice * multiplier).round();
      return RideVehicleQuote(
        vehicleClass: v,
        baseFare: adjustedBase,
        meetAndGreetFee: meetFee,
        childSeatFee: childFee,
        totalFare: adjustedBase + meetFee + childFee,
        currency: 'IRR',
        estimatedArrivalMins: v.isVip ? 20 : 12,
        isGuaranteedFixedRate: true,
      );
    }).toList();

    return RideServiceResult(
      data: RideQuote(
        quoteId: 'quote-${DateTime.now().millisecondsSinceEpoch}',
        distanceKm: rideType == TaxiRideType.intercity ? 145.0 : 48.0,
        durationMinutes: rideType == TaxiRideType.intercity ? 110 : 45,
        vehicleQuotes: quotes,
        expiresAt: DateTime.now().add(const Duration(minutes: 15)),
        currency: 'IRR',
        isFixedPrice: true,
      ),
      source: RideDataSource.fallback,
      unauthorized: response.unauthorized,
      message: response.message,
    );
  }

  // ---------------------------------------------------------------- request

  /// `POST /ride/requests` — confirm the selected quote and book.
  Future<RideServiceResult<TaxiBookingInfo>> createRideRequest({
    required String quoteId,
    required TaxiVehicleClass vehicle,
    required TaxiRideType rideType,
    required AirportTransferDirection direction,
    required String origin,
    required String destination,
    required DateTime pickupDate,
    required String pickupTime,
    required String flightNumber,
    required String passengerName,
    required String passengerPhone,
    required int passengerCount,
    required int luggageCount,
    required bool meetAndGreet,
    int childSeatCount = 0,
    String terminal = '',
    String notes = '',
    required int totalFare,
    String currency = 'IRR',
  }) async {
    final bookingId = 'taxi-${DateTime.now().microsecondsSinceEpoch}';
    final reference = TravelServiceRequest.generateReference();

    final payload = <String, dynamic>{
      'quote_id': quoteId,
      'client_booking_id': bookingId,
      'vehicle_type_id': vehicle.id,
      'ride_type': _rideTypeWire(rideType),
      'direction': direction == AirportTransferDirection.toAirport ? 'to_airport' : 'from_airport',
      'origin': origin,
      'destination': destination,
      'pickup_date': pickupDate.toIso8601String(),
      'pickup_time': pickupTime,
      'flight_number': flightNumber,
      'terminal': terminal,
      'passenger_name': passengerName,
      'passenger_phone': passengerPhone,
      'passenger_count': passengerCount,
      'luggage_count': luggageCount,
      'child_seat_count': childSeatCount,
      'meet_and_greet': meetAndGreet,
      'notes': notes,
      'expected_total': totalFare,
      'expected_currency': currency,
    };

    final response = await transport.post('/ride/requests', payload);
    final data = _extractMap(response.body, const ['data', 'ride', 'request']);

    TaxiBookingInfo booking;
    if (response.ok && data != null) {
      booking = TaxiBookingInfo.fromJson(data, vehicle);
      if (booking.reference.isEmpty) {
        booking = booking.copyWith(reference: reference);
      }
      await _persistAudit(booking);
      return RideServiceResult(data: booking, source: RideDataSource.network);
    }

    booking = TaxiBookingInfo(
      id: bookingId,
      reference: reference,
      rideType: rideType,
      transferDirection: direction,
      origin: origin,
      destination: destination,
      pickupDate: pickupDate,
      pickupTime: pickupTime,
      flightNumber: flightNumber,
      terminal: terminal,
      passengerName: passengerName,
      passengerPhone: passengerPhone,
      passengerCount: passengerCount,
      luggageCount: luggageCount,
      childSeatCount: childSeatCount,
      vehicle: vehicle,
      totalFare: totalFare,
      currency: currency,
      meetAndGreet: meetAndGreet,
      notes: notes,
      createdAt: DateTime.now(),
      status: 'AWAITING_CONFIRMATION',
      operationalStatus: RideBookingStatus.findingDriver,
      isFixedPrice: true,
    );
    await _persistAudit(booking);
    return RideServiceResult(
      data: booking,
      source: RideDataSource.fallback,
      unauthorized: response.unauthorized,
      message: response.message,
    );
  }

  /// `GET /ride/requests/{id}` — live status; used for driver matching,
  /// assignment and live-tracking polls (2s active, 15s idle).
  Future<RideServiceResult<TaxiBookingInfo?>> getRideStatus(
    String rideId, {
    required TaxiVehicleClass vehicleFallback,
  }) async {
    final response = await transport.get('/ride/requests/$rideId');
    final data = _extractMap(response.body, const ['data', 'ride', 'request']);
    if (response.ok && data != null) {
      return RideServiceResult(
        data: TaxiBookingInfo.fromJson(data, vehicleFallback),
        source: RideDataSource.network,
      );
    }
    return RideServiceResult(
      data: null,
      source: RideDataSource.fallback,
      unauthorized: response.unauthorized,
      message: response.message,
    );
  }

  /// `GET /ride/history` — the rider's past transfers.
  Future<RideServiceResult<List<TaxiBookingInfo>>> getRideHistory({
    List<TaxiVehicleClass>? vehicles,
  }) async {
    final response = await transport.get('/ride/history');
    final list = _extractList(response.body, const ['rides', 'items', 'data', 'requests']);
    final catalog = (vehicles == null || vehicles.isEmpty) ? fallbackVehicles : vehicles;
    final byId = {for (final v in catalog) v.id: v};
    if (response.ok && list != null) {
      return RideServiceResult(
        data: list.map((e) {
          final vehicleId = e['vehicle_type_id']?.toString() ?? e['vehicle']?['id']?.toString() ?? '';
          return TaxiBookingInfo.fromJson(e, byId[vehicleId] ?? catalog.first);
        }).toList(),
        source: RideDataSource.network,
      );
    }
    return RideServiceResult(
      data: const [],
      source: RideDataSource.fallback,
      unauthorized: response.unauthorized,
      message: response.message,
    );
  }

  /// `POST /ride/requests/{id}/cancel` — cancel with policy-aware refund.
  Future<RideServiceResult<bool>> cancelRide({
    required String rideId,
    required String reason,
  }) async {
    final response = await transport.post(
      '/ride/requests/$rideId/cancel',
      {'reason': reason},
    );
    return RideServiceResult(
      data: response.ok,
      source: response.ok ? RideDataSource.network : RideDataSource.fallback,
      unauthorized: response.unauthorized,
      message: response.message,
    );
  }

  /// `POST /ride/requests/{id}/rate` — 1..5 stars + tags + comment.
  Future<RideServiceResult<bool>> submitRating(RideRatingSubmission rating) async {
    final response = await transport.post(
      '/ride/requests/${rating.rideId}/rate',
      rating.toJson(),
    );
    return RideServiceResult(
      data: response.ok,
      source: response.ok ? RideDataSource.network : RideDataSource.fallback,
      unauthorized: response.unauthorized,
      message: response.message,
    );
  }

  /// `POST /ride/support` — open a support case tied to a ride.
  Future<RideServiceResult<bool>> createSupportTicket(RideSupportTicket ticket) async {
    final response = await transport.post('/ride/support', ticket.toJson());
    return RideServiceResult(
      data: response.ok,
      source: response.ok ? RideDataSource.network : RideDataSource.fallback,
      unauthorized: response.unauthorized,
      message: response.message,
    );
  }

  // ------------------------------------------------------------- validation

  /// Server-side rule mirrored locally so the rider sees the Validation Error
  /// state before spending a request: vehicle must fit pax + luggage.
  static String? capacityViolationFor({
    required TaxiVehicleClass vehicle,
    required int passengerCount,
    required int luggageCount,
  }) {
    if (passengerCount > vehicle.maxPassengers) {
      return 'passengers_exceed_${vehicle.maxPassengers}';
    }
    if (luggageCount > vehicle.maxLuggage) {
      return 'luggage_exceed_${vehicle.maxLuggage}';
    }
    return null;
  }

  /// Iranian mobile validation used both by the detail form and controller.
  static bool isValidIranianMobile(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    final candidate = digits.replaceAll(RegExp(r'[^0-9]'), '');
    if (candidate.endsWith('0') && candidate.length == 11 && candidate.startsWith('09')) {
      return true; // 09xxxxxxxxx
    }
    if (candidate.length == 12 && candidate.startsWith('989')) {
      return true; // 989xxxxxxxxx
    }
    if (candidate.length == 13 && candidate.startsWith('989')) {
      return true; // 00989xxxxxxxxx shortened variants
    }
    return false;
  }

  // ----------------------------------------------------------------- helpers

  static String _rideTypeWire(TaxiRideType type) => switch (type) {
        TaxiRideType.airportTransfer => 'airport_transfer',
        TaxiRideType.cityRide => 'city_ride',
        TaxiRideType.intercity => 'intercity',
      };

  /// Unwrap `{"data": {...}}` or `{"data": {"ride": {...}}}` defensively.
  Map<String, dynamic>? _extractMap(
    Map<String, dynamic>? body,
    List<String> innerKeys,
  ) {
    if (body == null) return null;
    final data = body['data'];
    if (data is Map) {
      for (final key in innerKeys) {
        final inner = data[key];
        if (inner is Map) return Map<String, dynamic>.from(inner);
      }
      return Map<String, dynamic>.from(data);
    }
    // Some routes return the object at the top level.
    return body;
  }

  /// Unwrap `{"data": [...]}` or `{"data": {"rides": [...]}}` defensively.
  List<Map<String, dynamic>>? _extractList(
    Map<String, dynamic>? body,
    List<String> innerKeys,
  ) {
    if (body == null) return null;
    final data = body['data'];
    List? raw;
    if (data is List) {
      raw = data;
    } else if (data is Map) {
      for (final key in innerKeys) {
        final inner = data[key];
        if (inner is List) {
          raw = inner;
          break;
        }
      }
    } else {
      for (final key in innerKeys) {
        final inner = body[key];
        if (inner is List) {
          raw = inner;
          break;
        }
      }
    }
    if (raw == null) return null;
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> _persistAudit(TaxiBookingInfo booking) async {
    try {
      await TravelServiceRequestStore.add(TravelServiceRequest(
        id: booking.id,
        serviceKey: 'taxi',
        title: '${booking.origin} ← ${booking.destination}',
        subtitle: '${booking.vehicle.titleFa} · ${booking.pickupTime}',
        amountLabel: '${booking.totalFare} ${booking.currency}',
        reference: booking.reference,
        createdAt: booking.createdAt,
        status: TravelServiceRequestStatus.approved,
        details: {
          'Origin': booking.origin,
          'Destination': booking.destination,
          'Pickup Date': booking.pickupDate.toIso8601String().split('T').first,
          'Pickup Time': booking.pickupTime,
          'Vehicle Class': booking.vehicle.titleFa,
          'Passenger': booking.passengerName,
          'Phone': booking.passengerPhone,
          'Flight Number': booking.flightNumber,
          'Terminal': booking.terminal,
          'Meet & Greet': booking.meetAndGreet ? 'بله' : 'خیر',
          'Child Seats': '${booking.childSeatCount}',
        },
      ));
    } catch (e) {
      if (kDebugMode) debugPrint('TaxiApiService audit persist skipped: $e');
    }
  }
}
