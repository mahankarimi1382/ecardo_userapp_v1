
import 'package:get/get.dart' as getx;
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import '../models/tour_model.dart';

class TourService extends getx.GetxService {
  final NetworkService _network = getx.Get.find<NetworkService>();

  /// List/search tours
  Future<List<TourModel>> getTours({
    String? query,
    String? country,
    String? category,
    int page = 1,
  }) async {
    final params = <String, dynamic>{'page': page};
    if (query != null && query.isNotEmpty) params['q'] = query;
    if (country != null && country.isNotEmpty) params['country'] = country;
    if (category != null && category.isNotEmpty) params['category'] = category;

    final queryStr = Uri(queryParameters: params.map((k, v) => MapEntry(k, v.toString()))).query;
    final path = '/user/tours${queryStr.isNotEmpty ? '?$queryStr' : ''}';

    final response = await _network.get(endpoint: path);
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      final toursRaw = data is Map ? data['tours'] : null;
      if (toursRaw is List) {
        return toursRaw.map((e) => TourModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    return [];
  }

  /// Get tour details
  Future<TourModel?> getTourDetail(int id) async {
    final response = await _network.get(endpoint: '/user/tours/$id');
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return TourModel.fromJson(data);
      }
    }
    return null;
  }

  /// Quiz matching engine (Tour-Yar)
  Future<List<TourModel>> matchTours(Map<String, dynamic> answers) async {
    final response = await _network.post(
      endpoint: '/user/tours/match',
      data: {'answers': answers},
    );
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      final toursRaw = data is Map ? data['tours'] : (data is List ? data : null);
      if (toursRaw is List) {
        return toursRaw.map((e) => TourModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    return [];
  }

  /// Step 2: Create initial booking (Draft)
  Future<TourBookingModel?> bookTour(Map<String, dynamic> payload) async {
    final response = await _network.post(
      endpoint: '/user/tours/book',
      data: payload,
    );
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return TourBookingModel.fromJson(data);
      }
    }
    return null;
  }

  /// Step 3: Customize booking (hotel & activities)
  Future<TourBookingModel?> customizeBooking(int bookingId, Map<String, dynamic> payload) async {
    final response = await _network.post(
      endpoint: '/user/tours/bookings/$bookingId/customize',
      data: payload,
    );
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return TourBookingModel.fromJson(data);
      }
    }
    return null;
  }

  /// Step 4: Submit traveler details
  Future<TourBookingModel?> submitTravelers(
    int bookingId,
    List<Map<String, dynamic>> travelers,
  ) async {
    final response = await _network.post(
      endpoint: '/user/tours/bookings/$bookingId/travelers',
      data: {'travelers': travelers},
    );
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return TourBookingModel.fromJson(data);
      }
    }
    return null;
  }

  /// Step 5: Pay booking (FULL or DEPOSIT)
  Future<TourBookingModel?> payBooking(
    int bookingId, {
    String paymentMode = 'FULL',
    int? walletId,
  }) async {
    final payload = <String, dynamic>{
      'payment_mode': paymentMode,
      'wallet_id': ?walletId,
    };
    final response = await _network.post(
      endpoint: '/user/tours/bookings/$bookingId/pay',
      data: payload,
    );
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return TourBookingModel.fromJson(data);
      }
    }
    return null;
  }

  /// Step 5-B: Pay remaining balance
  Future<TourBookingModel?> payRemainder(int bookingId, {int? walletId}) async {
    final payload = <String, dynamic>{
      'wallet_id': ?walletId,
    };
    final response = await _network.post(
      endpoint: '/user/tours/bookings/$bookingId/pay-remainder',
      data: payload,
    );
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return TourBookingModel.fromJson(data);
      }
    }
    return null;
  }

  /// Get my tour bookings list
  Future<List<TourBookingModel>> getMyBookings({String? status, int page = 1}) async {
    final params = <String, dynamic>{'page': page};
    if (status != null && status.isNotEmpty) params['status'] = status;
    final queryStr = Uri(queryParameters: params.map((k, v) => MapEntry(k, v.toString()))).query;
    final path = '/user/tours/my-bookings${queryStr.isNotEmpty ? '?$queryStr' : ''}';

    final response = await _network.get(endpoint: path);
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      final rawList = data is Map ? data['bookings'] : (data is List ? data : null);
      if (rawList is List) {
        return rawList.map((e) => TourBookingModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    return [];
  }

  /// Get single booking details (including voucher details)
  Future<TourBookingModel?> getBookingDetails(int id) async {
    final response = await _network.get(endpoint: '/user/tours/bookings/$id');
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return TourBookingModel.fromJson(data);
      }
    }
    return null;
  }

  /// Cancel booking
  Future<bool> cancelBooking(int id) async {
    final response = await _network.post(
      endpoint: '/user/tours/bookings/$id/cancel',
      data: {},
    );
    return response.status == Status.completed;
  }
}

