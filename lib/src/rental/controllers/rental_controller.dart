import 'package:get/get.dart';

import '../models/rental_models.dart';
import '../services/rental_service.dart';

/// GetX controller for Car Rental service (Car-Rental-Service-Flow.md).
class RentalController extends GetxController {
  final RentalApiService _api = Get.find<RentalApiService>();

  final cars = <CarModel>[].obs;
  final myBookings = <RentalBookingModel>[].obs;
  final selectedBooking = Rxn<RentalBookingModel>();

  final isLoadingCars = false.obs;
  final isLoadingBookings = false.obs;
  final isLoadingDetail = false.obs;
  final isSubmitting = false.obs;

  // Search state
  final selectedCategory = 'all'.obs;
  final searchQuery = ''.obs;

  Future<void> fetchCars() async {
    try {
      isLoadingCars.value = true;
      cars.value = await _api.getCars(
        category: selectedCategory.value == 'all' ? null : selectedCategory.value,
        q: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
    } finally {
      isLoadingCars.value = false;
    }
  }

  Future<void> fetchMyBookings() async {
    try {
      isLoadingBookings.value = true;
      myBookings.value = await _api.getMyBookings();
    } finally {
      isLoadingBookings.value = false;
    }
  }

  Future<void> fetchBooking(int id) async {
    try {
      isLoadingDetail.value = true;
      selectedBooking.value = await _api.getBooking(id);
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Create booking — returns error string or null on success
  Future<String?> createBooking(String pickupAt, String returnAt, String insuranceTier) async {
    final car = selectedBooking.value?.car;
    if (car == null) return 'ERR_PRECONDITION: خودرو انتخاب نشده';
    try {
      isSubmitting.value = true;
      final result = await _api.createBooking(
        carId: car.id,
        pickupAt: pickupAt,
        returnAt: returnAt,
        insuranceTier: insuranceTier,
      );
      if (result == null) return 'ERR_NETWORK: خطا در ثبت رزرو';
      await fetchMyBookings();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> pay(int bookingId) async {
    final ok = await _api.pay(bookingId);
    if (ok) await fetchBooking(bookingId);
    return ok;
  }

  Future<bool> submitDocs(int bookingId, List<Map<String, dynamic>> docs) async {
    final ok = await _api.submitDocs(bookingId, docs);
    if (ok) await fetchBooking(bookingId);
    return ok;
  }

  Future<bool> confirmPickup(int bookingId) async {
    final ok = await _api.confirmPickup(bookingId);
    if (ok) await fetchBooking(bookingId);
    return ok;
  }

  Future<bool> confirmReturn(int bookingId) async {
    final ok = await _api.confirmReturn(bookingId);
    if (ok) await fetchBooking(bookingId);
    return ok;
  }

  Future<bool> acceptSettlement(int bookingId) async {
    final ok = await _api.acceptSettlement(bookingId);
    if (ok) await fetchBooking(bookingId);
    return ok;
  }

  Future<bool> cancelBooking(int bookingId) async {
    final ok = await _api.cancel(bookingId);
    if (ok) await fetchBooking(bookingId);
    return ok;
  }
}
