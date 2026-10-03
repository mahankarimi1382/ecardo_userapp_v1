
import 'package:get/get.dart';
import '../models/tour_model.dart';
import '../services/tour_service.dart';

class TourController extends GetxController {
  final TourService _service = Get.put(TourService());

  // Catalog State
  final RxList<TourModel> tours = <TourModel>[].obs;
  final RxBool isLoadingTours = false.obs;
  final RxString selectedCategory = ''.obs;
  final RxString searchQuery = ''.obs;

  // Detail State
  final Rx<TourModel?> selectedTour = Rx<TourModel?>(null);
  final RxBool isLoadingDetail = false.obs;

  // Tour-Yar Quiz State
  final RxInt quizStep = 0.obs;
  final RxMap<String, dynamic> quizAnswers = <String, dynamic>{}.obs;
  final RxList<TourModel> matchedTours = <TourModel>[].obs;
  final RxBool isMatching = false.obs;

  // Booking Flow State
  final Rx<TourBookingModel?> activeBooking = Rx<TourBookingModel?>(null);
  final RxBool isBookingAction = false.obs;

  // My Bookings State
  final RxList<TourBookingModel> myBookings = <TourBookingModel>[].obs;
  final RxBool isLoadingBookings = false.obs;
  final RxString selectedBookingFilter = ''.obs;

  // Service health / API availability state
  final RxBool isServiceUnavailable = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadTours();
  }

  /// Load tours catalog with optional filter
  Future<void> loadTours({bool refresh = false}) async {
    if (isLoadingTours.value && !refresh) return;
    isLoadingTours.value = true;
    isServiceUnavailable.value = false;
    errorMessage.value = null;
    try {
      final list = await _service.getTours(
        query: searchQuery.value.isEmpty ? null : searchQuery.value,
        category: selectedCategory.value.isEmpty ? null : selectedCategory.value,
      );
      tours.assignAll(list);
      // If list is empty and user wasn't filtering by query/category,
      // it indicates backend /user/tours endpoint is not responding.
      if (list.isEmpty && searchQuery.value.isEmpty && selectedCategory.value.isEmpty) {
        isServiceUnavailable.value = true;
      }
    } catch (e) {
      isServiceUnavailable.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoadingTours.value = false;
    }
  }

  /// Load single tour details
  Future<void> loadTourDetail(int id) async {
    isLoadingDetail.value = true;
    isServiceUnavailable.value = false;
    errorMessage.value = null;
    try {
      final detail = await _service.getTourDetail(id);
      selectedTour.value = detail;
      if (detail == null) {
        isServiceUnavailable.value = true;
      }
    } catch (e) {
      isServiceUnavailable.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Quiz question answering
  void answerQuiz(String key, dynamic value) {
    quizAnswers[key] = value;
  }

  void nextQuizStep() {
    if (quizStep.value < 7) {
      quizStep.value++;
    }
  }

  void previousQuizStep() {
    if (quizStep.value > 0) {
      quizStep.value--;
    }
  }

  void resetQuiz() {
    quizStep.value = 0;
    quizAnswers.clear();
    matchedTours.clear();
  }

  /// Submit Quiz and get matched tours
  Future<List<TourModel>> submitQuiz() async {
    isMatching.value = true;
    try {
      final matches = await _service.matchTours(Map<String, dynamic>.from(quizAnswers));
      matchedTours.assignAll(matches);
      return matches;
    } catch (_) {
      return [];
    } finally {
      isMatching.value = false;
    }
  }

  /// Create booking draft
  Future<TourBookingModel?> createBooking({
    required int tourId,
    required int departureId,
    required int travelersCount,
    int adultsCount = 1,
    int childrenCount = 0,
    String model = 'group',
    String tier = 'STD',
    String? roomType,
  }) async {
    isBookingAction.value = true;
    try {
      final booking = await _service.bookTour({
        'tour_id': tourId,
        'departure_id': departureId,
        'travelers_count': travelersCount,
        'adults_count': adultsCount,
        'children_count': childrenCount,
        'model': model,
        'tier': tier,
        'room_type': ?roomType,
      });
      activeBooking.value = booking;
      return booking;
    } catch (_) {
      return null;
    } finally {
      isBookingAction.value = false;
    }
  }

  /// Submit passenger information
  Future<TourBookingModel?> submitTravelers(
    int bookingId,
    List<TourTravelerModel> travelers,
  ) async {
    isBookingAction.value = true;
    try {
      final payload = travelers.map((t) => t.toJson()).toList();
      final updated = await _service.submitTravelers(bookingId, payload);
      if (updated != null) {
        activeBooking.value = updated;
      }
      return updated;
    } catch (_) {
      return null;
    } finally {
      isBookingAction.value = false;
    }
  }

  /// Pay booking
  Future<TourBookingModel?> payBooking({
    required int bookingId,
    String paymentMode = 'FULL',
    int? walletId,
  }) async {
    isBookingAction.value = true;
    try {
      final paid = await _service.payBooking(
        bookingId,
        paymentMode: paymentMode,
        walletId: walletId,
      );
      if (paid != null) {
        activeBooking.value = paid;
        loadMyBookings();
      }
      return paid;
    } catch (_) {
      return null;
    } finally {
      isBookingAction.value = false;
    }
  }

  /// Pay remaining balance
  Future<TourBookingModel?> payRemainder(int bookingId, {int? walletId}) async {
    isBookingAction.value = true;
    try {
      final paid = await _service.payRemainder(bookingId, walletId: walletId);
      if (paid != null) {
        activeBooking.value = paid;
        loadMyBookings();
      }
      return paid;
    } catch (_) {
      return null;
    } finally {
      isBookingAction.value = false;
    }
  }

  /// Load user's bookings
  Future<void> loadMyBookings({String? status}) async {
    isLoadingBookings.value = true;
    try {
      final list = await _service.getMyBookings(status: status);
      myBookings.assignAll(list);
    } catch (_) {
    } finally {
      isLoadingBookings.value = false;
    }
  }

  /// Load single booking details
  Future<TourBookingModel?> loadBookingDetails(int id) async {
    isBookingAction.value = true;
    try {
      final b = await _service.getBookingDetails(id);
      activeBooking.value = b;
      return b;
    } catch (_) {
      return null;
    } finally {
      isBookingAction.value = false;
    }
  }

  /// Cancel booking
  Future<bool> cancelBooking(int id) async {
    isBookingAction.value = true;
    try {
      final ok = await _service.cancelBooking(id);
      if (ok) {
        loadMyBookings();
      }
      return ok;
    } catch (_) {
      return false;
    } finally {
      isBookingAction.value = false;
    }
  }
}

