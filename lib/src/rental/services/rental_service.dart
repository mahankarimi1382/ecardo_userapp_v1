import 'package:ecardo_user/src/network/response/status.dart';
import 'package:get/get.dart' as getx;

import 'package:ecardo_user/src/network/service/network_service.dart';
import '../models/rental_models.dart';

/// Car Rental API client — endpoints: /rental/*
class RentalApiService extends getx.GetxService {
  final NetworkService _network = getx.Get.find<NetworkService>();

  /// Search/filter cars (کاتالوگ = داده)
  Future<List<CarModel>> getCars({String? category, String? q, String? transmission}) async {
    final qp = <String>[];
    if (category != null && category != 'all') qp.add('category=$category');
    if (transmission != null && transmission != 'all') qp.add('transmission=$transmission');
    if (q != null && q.isNotEmpty) qp.add('q=${Uri.encodeComponent(q)}');
    final ep = qp.isEmpty ? '/rental/cars' : '/rental/cars?${qp.join('&')}';

    final response = await _network.get(endpoint: ep);
    if (response.status == Status.completed && response.data != null) {
      final list = response.data!['data']?['data'] as List?;
      if (list != null) {
        return list.map((e) => CarModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
    }
    return [];
  }

  /// Car detail
  Future<CarModel?> getCar(int id) async {
    final response = await _network.get(endpoint: '/rental/cars/$id');
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data']?['car'];
      if (data is Map<String, dynamic>) return CarModel.fromJson(data);
    }
    return null;
  }

  /// My bookings
  Future<List<RentalBookingModel>> getMyBookings() async {
    final response = await _network.get(endpoint: '/rental/my');
    if (response.status == Status.completed && response.data != null) {
      final list = response.data!['data']?['bookings'] as List?;
      if (list != null) {
        return list.map((e) => RentalBookingModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
    }
    return [];
  }

  /// Booking detail
  Future<RentalBookingModel?> getBooking(int id) async {
    final response = await _network.get(endpoint: '/rental/bookings/$id');
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data']?['booking'];
      if (data is Map<String, dynamic>) return RentalBookingModel.fromJson(data);
    }
    return null;
  }

  /// Create booking (DRAFT + 1h price lock + atomic calendar) — BTN_BOOK_CAR
  Future<Map<String, dynamic>?> createBooking({
    required int carId,
    required String pickupAt,
    required String returnAt,
    required String insuranceTier,
    Map<String, dynamic>? extras,
  }) async {
    final response = await _network.post(endpoint: '/rental/bookings', data: {
      'car_id': carId,
      'pickup_at': pickupAt,
      'return_at': returnAt,
      'insurance_tier': insuranceTier,
      'extras': extras ?? {},
    });
    if (response.status == Status.completed && response.data != null) {
      return response.data!['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// Submit driver docs — BTN_UPLOAD_LICENSE
  Future<bool> submitDocs(int bookingId, List<Map<String, dynamic>> docs) async {
    final response = await _network.post(endpoint: '/rental/bookings/$bookingId/driver-docs', data: {'docs': docs});
    return response.status == Status.completed;
  }

  /// Pay rental + lock deposit — BTN_PAY_RENTAL
  Future<bool> pay(int bookingId) async {
    final response = await _network.post(endpoint: '/rental/bookings/$bookingId/pay', data: {});
    return response.status == Status.completed;
  }

  /// Handover photos+condition — BTN_RECORD_CONDITION
  Future<bool> submitHandover(int bookingId, String phase, List<String> photos, int odometer, int fuelPct) async {
    final response = await _network.post(endpoint: '/rental/bookings/$bookingId/handover', data: {
      'phase': phase,
      'photos': {
        'front': photos.isNotEmpty ? photos[0] : '',
        'rear': photos.length > 1 ? photos[1] : '',
        'right': photos.length > 2 ? photos[2] : '',
        'left': photos.length > 3 ? photos[3] : '',
        'odometer': photos.length > 4 ? photos[4] : '',
        'fuel': photos.length > 5 ? photos[5] : '',
        'cabin': photos.length > 6 ? photos[6] : '',
        'existing_damage': photos.length > 7 ? photos[7] : '',
      },
      'odometer': odometer,
      'fuel_pct': fuelPct,
    });
    return response.status == Status.completed;
  }

  /// Confirm pickup (both sides signed) — BTN_CONFIRM_PICKUP
  Future<bool> confirmPickup(int bookingId) async {
    final response = await _network.post(endpoint: '/rental/bookings/$bookingId/confirm-pickup', data: {});
    return response.status == Status.completed;
  }

  /// Confirm return (auto diff) — BTN_CONFIRM_RETURN
  Future<bool> confirmReturn(int bookingId) async {
    final response = await _network.post(endpoint: '/rental/bookings/$bookingId/confirm-return', data: {});
    return response.status == Status.completed;
  }

  /// Accept settlement — BTN_ACCEPT_SETTLEMENT
  Future<bool> acceptSettlement(int bookingId) async {
    final response = await _network.post(endpoint: '/rental/bookings/$bookingId/accept-settlement', data: {});
    return response.status == Status.completed;
  }

  /// File dispute — BTN_FILE_DISPUTE
  Future<bool> fileDispute(int bookingId, String type, double amount) async {
    final response = await _network.post(endpoint: '/rental/bookings/$bookingId/dispute', data: {
      'type': type,
      'amount': amount,
    });
    return response.status == Status.completed;
  }

  /// Cancel booking (tiered 90/50/25/0) — BTN_CANCEL_BOOKING
  Future<bool> cancel(int bookingId) async {
    final response = await _network.post(endpoint: '/rental/bookings/$bookingId/cancel', data: {});
    return response.status == Status.completed;
  }
}
