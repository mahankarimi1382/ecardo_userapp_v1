import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'taxi_api_service.dart';
import 'taxi_models.dart';

/// Airport Transfer & Taxi controller — wired to the deployed `api/ride/*`
/// subsystem with an explicit 14-state machine. No method here fakes a
/// confirmed booking: when the backend is unreachable the resulting booking is
/// flagged [RideDataSource.fallback] and the UI must surface Partial/Offline.
class TaxiController extends GetxController {
  TaxiController({TaxiApiService? api}) : _api = api ?? TaxiApiService();

  final TaxiApiService _api;

  // ------------------------------------------------------------ search form
  final Rx<TaxiRideType> selectedRideType = TaxiRideType.airportTransfer.obs;
  final Rx<AirportTransferDirection> transferDirection =
      AirportTransferDirection.fromAirport.obs;
  final Rx<DateTime> pickupDate =
      DateTime.now().add(const Duration(days: 1)).obs;
  final RxString pickupTime = '10:00'.obs;
  final RxInt passengerCount = 1.obs;
  final RxInt luggageCount = 1.obs;
  final RxInt childSeatCount = 0.obs;
  final RxBool meetAndGreet = true.obs;

  final originController =
      TextEditingController(text: 'فرودگاه بین‌المللی امام خمینی (IKA) - ترمینال ۱');
  final destinationController = TextEditingController(text: 'تهران، میدان ونک');
  final terminalController = TextEditingController();
  final flightNumberController = TextEditingController();
  final passengerNameController = TextEditingController();
  final passengerPhoneController = TextEditingController();
  final notesController = TextEditingController();

  // -------------------------------------------------------------- geo search
  final RxList<RidePlace> savedPlaces = <RidePlace>[].obs;
  final RxList<RidePlace> placeSuggestions = <RidePlace>[].obs;
  final RxBool isSearchingPlaces = false.obs;
  final RxString activePlaceField = ''.obs; // 'origin' | 'destination' | ''
  Timer? _geoDebounce;
  int _geoGeneration = 0;
  static const Duration geoDebounceDuration = Duration(milliseconds: 350);

  // ---------------------------------------------------------------- catalog
  final RxList<TaxiVehicleClass> availableVehicles = <TaxiVehicleClass>[].obs;
  final Rxn<TaxiVehicleClass> selectedVehicle = Rxn<TaxiVehicleClass>();
  final Rxn<TaxiBookingInfo> activeBooking = Rxn<TaxiBookingInfo>();

  // ------------------------------------------------------------------ quote
  final Rxn<RideQuote> quote = Rxn<RideQuote>();
  final Rx<RideDataSource> quoteSource = RideDataSource.fallback.obs;
  final RxBool isQuoteExpired = false.obs;
  Timer? _quoteExpiryTimer;

  // ------------------------------------------------------------------- state
  final Rx<TaxiUiState> uiState = TaxiUiState.defaultState.obs;
  final RxBool isLoadingVehicles = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isCancelling = false.obs;
  final RxBool isServiceUnavailable = false.obs;

  /// True when the last ride call reached the backend. False ⇒ Partial/Offline.
  final RxBool isLiveBackendData = false.obs;
  final RxBool isOffline = false.obs;
  final RxBool isUnauthorized = false.obs;
  final RxnString errorMessage = RxnString();

  /// Validation error keys (resolved to localized copy by the screens).
  final RxSet<String> validationErrors = <String>{}.obs;

  Timer? _statusPoller;

  /// Static catalog kept for backward compatibility with existing screens and
  /// tests; delegates to the service's fallback fleet.
  static List<TaxiVehicleClass> get defaultVehicles =>
      TaxiApiService.fallbackVehicles;

  bool get hasQuote => quote.value != null && quote.value!.vehicleQuotes.isNotEmpty;

  bool get isAirportRide => selectedRideType.value == TaxiRideType.airportTransfer;

  int get totalFare {
    final vehicle = selectedVehicle.value;
    if (vehicle == null) return 0;
    return calculateTotalFare(vehicle);
  }

  RideCancellationPolicy? get cancellationPolicy {
    final vehicle = selectedVehicle.value;
    if (vehicle == null) return null;
    return RideCancellationPolicy.standard(
      pickupTime: DateTime(
        pickupDate.value.year,
        pickupDate.value.month,
        pickupDate.value.day,
        int.tryParse(pickupTime.value.split(':').first) ?? 10,
        int.tryParse(pickupTime.value.split(':').elementAtOrNull(1) ?? '') ?? 0,
      ),
      totalFare: totalFare,
      currency: quote.value?.currency ?? 'IRR',
    );
  }

  @override
  void onInit() {
    super.onInit();
    availableVehicles.assignAll(defaultVehicles);
    selectedVehicle.value = defaultVehicles.length > 1
        ? defaultVehicles[1]
        : defaultVehicles.first;
    WidgetsBinding.instance.addPostFrameCallback((_) => loadCatalog());
  }

  @override
  void onClose() {
    _geoDebounce?.cancel();
    _quoteExpiryTimer?.cancel();
    stopStatusPolling();
    originController.dispose();
    destinationController.dispose();
    terminalController.dispose();
    flightNumberController.dispose();
    passengerNameController.dispose();
    passengerPhoneController.dispose();
    notesController.dispose();
    _api.onClose();
    super.onClose();
  }

  // ----------------------------------------------------------------- catalog

  /// Bootstrap: `GET /ride/vehicle-types` + `GET /ride/places`.
  Future<void> loadCatalog() async {
    uiState.value = TaxiUiState.loading;
    errorMessage.value = null;
    final vehiclesResult = await _api.getVehicleTypes();
    final placesResult = await _api.getSavedPlaces();

    availableVehicles.assignAll(vehiclesResult.data);
    savedPlaces.assignAll(placesResult.data);

    final stillSelected = selectedVehicle.value == null ||
        !availableVehicles.any((v) => v.id == selectedVehicle.value!.id);
    if (stillSelected) {
      selectedVehicle.value = availableVehicles.isNotEmpty
          ? availableVehicles.first
          : null;
    }

    isLiveBackendData.value =
        !vehiclesResult.isFallback || !placesResult.isFallback;
    isUnauthorized.value =
        vehiclesResult.unauthorized || placesResult.unauthorized;
    isOffline.value = vehiclesResult.isFallback && placesResult.isFallback;
    isServiceUnavailable.value = availableVehicles.isEmpty;

    if (vehiclesResult.unauthorized || placesResult.unauthorized) {
      uiState.value = TaxiUiState.unauthorized;
    } else if (availableVehicles.isEmpty) {
      uiState.value = TaxiUiState.empty;
    } else if (isOffline.value) {
      uiState.value = TaxiUiState.offline;
    } else if (vehiclesResult.isFallback || placesResult.isFallback) {
      uiState.value = TaxiUiState.partial;
    } else {
      uiState.value = TaxiUiState.success;
    }
  }

  // -------------------------------------------------------------- geo search

  /// Debounced, race-safe geo lookup for the pickup / dropoff field.
  void searchPlaces(String query, {required String field}) {
    activePlaceField.value = field;
    _geoDebounce?.cancel();
    if (query.trim().length < 2) {
      placeSuggestions.assignAll(RidePlace.popularAirportPlaces);
      isSearchingPlaces.value = false;
      return;
    }
    isSearchingPlaces.value = true;
    _geoDebounce = Timer(geoDebounceDuration, () => _runGeoSearch(query, field));
  }

  Future<void> _runGeoSearch(String query, String field) async {
    final generation = ++_geoGeneration;
    final result = await _api.searchPlaces(query);
    // A newer keystroke superseded this response — drop it.
    if (generation != _geoGeneration) return;
    placeSuggestions.assignAll(result.data);
    isSearchingPlaces.value = false;
    if (result.data.isEmpty) {
      uiState.value = TaxiUiState.empty;
    }
  }

  void applyPlace(RidePlace place, {required String field}) {
    final label = place.localizedTitle;
    if (field == 'destination') {
      destinationController.text = label;
    } else {
      originController.text = label;
    }
    activePlaceField.value = '';
    placeSuggestions.clear();
  }

  void swapRoute() {
    final origin = originController.text;
    originController.text = destinationController.text;
    destinationController.text = origin;
  }

  // ------------------------------------------------------------------- quote

  /// `POST /ride/quote` — fixed price per vehicle class for this route/time.
  Future<RideQuote?> fetchVehicleEstimates() async {
    if (originController.text.trim().isEmpty ||
        destinationController.text.trim().isEmpty) {
      uiState.value = TaxiUiState.validationError;
      validationErrors.addAll({'origin_required', 'destination_required'});
      return null;
    }

    isLoadingVehicles.value = true;
    isServiceUnavailable.value = false;
    errorMessage.value = null;
    uiState.value = TaxiUiState.skeleton;
    try {
      final result = await _api.requestQuote(
        rideType: selectedRideType.value,
        origin: originController.text.trim(),
        destination: destinationController.text.trim(),
        pickupDate: pickupDate.value,
        pickupTime: pickupTime.value,
        passengerCount: passengerCount.value,
        luggageCount: luggageCount.value,
        meetAndGreet: meetAndGreet.value,
        childSeatCount: childSeatCount.value,
        vehicles: availableVehicles.isNotEmpty
            ? availableVehicles.toList()
            : TaxiApiService.fallbackVehicles,
      );

      quote.value = result.data;
      quoteSource.value = result.source;
      isLiveBackendData.value = !result.isFallback;
      isUnauthorized.value = result.unauthorized;
      isOffline.value = result.isFallback && result.unauthorized == false;

      if (result.unauthorized) {
        uiState.value = TaxiUiState.unauthorized;
      } else if (result.data.vehicleQuotes.isEmpty) {
        uiState.value = TaxiUiState.empty;
      } else if (result.isFallback) {
        uiState.value = TaxiUiState.partial;
      } else {
        uiState.value = TaxiUiState.success;
      }

      _armQuoteExpiry(result.data);
      return result.data;
    } catch (e) {
      isServiceUnavailable.value = true;
      uiState.value = TaxiUiState.error;
      errorMessage.value = e.toString();
      return null;
    } finally {
      isLoadingVehicles.value = false;
    }
  }

  void _armQuoteExpiry(RideQuote value) {
    _quoteExpiryTimer?.cancel();
    final until = value.expiresAt.difference(DateTime.now());
    if (until.isNegative || until == Duration.zero) {
      isQuoteExpired.value = true;
      uiState.value = TaxiUiState.expired;
      return;
    }
    isQuoteExpired.value = false;
    _quoteExpiryTimer = Timer(until, () {
      isQuoteExpired.value = true;
      uiState.value = TaxiUiState.expired;
    });
  }

  RideVehicleQuote? quoteFor(TaxiVehicleClass vehicle) {
    final current = quote.value;
    if (current == null) return null;
    for (final entry in current.vehicleQuotes) {
      if (entry.vehicleClass.id == vehicle.id) return entry;
    }
    return null;
  }

  /// Fare for a class. Prefers the backend quote; falls back to the local
  /// fixed-price rule (base + meet & greet + child seats ± intercity factor).
  int calculateTotalFare(TaxiVehicleClass vehicle) {
    final backendQuote = quoteFor(vehicle);
    if (backendQuote != null && !isQuoteExpired.value) {
      return backendQuote.totalFare;
    }
    var fare = (vehicle.basePrice *
            (selectedRideType.value == TaxiRideType.intercity ? 1.6 : 1.0))
        .round();
    if (meetAndGreet.value) fare += TaxiApiService.meetAndGreetFeeIrr;
    fare += childSeatCount.value * TaxiApiService.childSeatFeeIrr;
    return fare;
  }

  /// Which classes cannot carry the requested pax / luggage.
  bool isVehicleUnavailable(TaxiVehicleClass vehicle) {
    return TaxiApiService.capacityViolationFor(
          vehicle: vehicle,
          passengerCount: passengerCount.value,
          luggageCount: luggageCount.value,
        ) !=
        null;
  }

  // ---------------------------------------------------------------- request

  /// Validates the rider + flight inputs. Returns the failing keys.
  List<String> validateBookingForm() {
    final errors = <String>[];
    if (passengerNameController.text.trim().length < 3) {
      errors.add('passenger_name_invalid');
    }
    if (!_api.isUsableForTest) {
      // guard never taken in production; keeps the branch explicit
    }
    if (!TaxiApiService.isValidIranianMobile(passengerPhoneController.text)) {
      errors.add('passenger_phone_invalid');
    }
    if (isAirportRide &&
        transferDirection.value == AirportTransferDirection.fromAirport &&
        flightNumberController.text.trim().isEmpty) {
      errors.add('flight_number_required');
    }
    if (selectedVehicle.value != null &&
        TaxiApiService.capacityViolationFor(
          vehicle: selectedVehicle.value!,
          passengerCount: passengerCount.value,
          luggageCount: luggageCount.value,
        ) !=
            null) {
      errors.add('vehicle_capacity_exceeded');
    }
    if (pickupDate.value.isBefore(DateTime.now().subtract(const Duration(hours: 2)))) {
      errors.add('pickup_in_past');
    }

    validationErrors.assignAll(errors);
    if (errors.isNotEmpty) {
      uiState.value = TaxiUiState.validationError;
    }
    return errors;
  }

  /// `POST /ride/requests` — book the selected quote.
  Future<TaxiBookingInfo?> createBooking() async {
    final errors = validateBookingForm();
    if (errors.isNotEmpty) return null;
    if (isQuoteExpired.value) {
      uiState.value = TaxiUiState.expired;
      return null;
    }

    final vehicle = selectedVehicle.value ??
        (availableVehicles.isNotEmpty ? availableVehicles.first : null);
    if (vehicle == null) {
      uiState.value = TaxiUiState.empty;
      return null;
    }

    isSubmitting.value = true;
    uiState.value = TaxiUiState.processing;
    errorMessage.value = null;
    try {
      final result = await _api.createRideRequest(
        quoteId: quote.value?.quoteId ?? 'quote-local',
        vehicle: vehicle,
        rideType: selectedRideType.value,
        direction: transferDirection.value,
        origin: originController.text.trim(),
        destination: destinationController.text.trim(),
        pickupDate: pickupDate.value,
        pickupTime: pickupTime.value,
        flightNumber: flightNumberController.text.trim(),
        terminal: terminalController.text.trim(),
        passengerName: passengerNameController.text.trim(),
        passengerPhone: passengerPhoneController.text.trim(),
        passengerCount: passengerCount.value,
        luggageCount: luggageCount.value,
        childSeatCount: childSeatCount.value,
        meetAndGreet: meetAndGreet.value,
        notes: notesController.text.trim(),
        totalFare: calculateTotalFare(vehicle),
        currency: quote.value?.currency ?? 'IRR',
      );

      activeBooking.value = result.data;
      isLiveBackendData.value = !result.isFallback;
      isUnauthorized.value = result.unauthorized;

      if (result.unauthorized) {
        uiState.value = TaxiUiState.unauthorized;
      } else if (result.isFallback) {
        // Booking is queued locally but NOT backend-confirmed.
        uiState.value = TaxiUiState.partial;
      } else {
        uiState.value = TaxiUiState.success;
      }
      return result.data;
    } catch (e) {
      uiState.value = TaxiUiState.error;
      errorMessage.value = e.toString();
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Backward-compatible alias used by the existing search screen.
  Future<void> refreshQuote() => fetchVehicleEstimates().then((_) {});

  // ------------------------------------------------------------- status/ops

  /// Poll `GET /ride/requests/{id}` — 2s while a driver is being matched,
  /// 15s once assigned or in transit.
  void startStatusPolling() {
    stopStatusPolling();
    final booking = activeBooking.value;
    if (booking == null) return;
    final interval = booking.driver == null
        ? const Duration(seconds: 2)
        : const Duration(seconds: 15);
    _statusPoller = Timer.periodic(interval, (_) => refreshStatus());
  }

  void stopStatusPolling() {
    _statusPoller?.cancel();
    _statusPoller = null;
  }

  Future<void> refreshStatus() async {
    final booking = activeBooking.value;
    if (booking == null) return;
    final result = await _api.getRideStatus(
      booking.id,
      vehicleFallback: booking.vehicle,
    );
    final updated = result.data;
    if (updated == null) return;
    activeBooking.value = updated;
    isLiveBackendData.value = !result.isFallback;
    switch (updated.operationalStatus) {
      case RideBookingStatus.completed:
        uiState.value = TaxiUiState.completed;
        stopStatusPolling();
      case RideBookingStatus.cancelled:
        uiState.value = TaxiUiState.cancelled;
        stopStatusPolling();
      case RideBookingStatus.expired:
        uiState.value = TaxiUiState.expired;
        stopStatusPolling();
      default:
        break;
    }
  }

  /// `POST /ride/requests/{id}/cancel` — policy-aware, wallet refund.
  Future<bool> cancelBooking(String reason) async {
    final booking = activeBooking.value;
    if (booking == null) return false;
    isCancelling.value = true;
    try {
      final result = await _api.cancelRide(rideId: booking.id, reason: reason);
      if (result.data) {
        activeBooking.value = booking.copyWith(
          status: 'CANCELLED',
          operationalStatus: RideBookingStatus.cancelled,
        );
        uiState.value = TaxiUiState.cancelled;
      } else {
        uiState.value = TaxiUiState.error;
        errorMessage.value = result.message ?? 'cancel_failed';
      }
      stopStatusPolling();
      return result.data;
    } finally {
      isCancelling.value = false;
    }
  }

  /// `POST /ride/requests/{id}/rate`
  Future<bool> submitRating(RideRatingSubmission rating) async {
    final result = await _api.submitRating(rating);
    if (!result.data) {
      errorMessage.value = result.message ?? 'rating_failed';
    }
    return result.data;
  }

  /// `POST /ride/support`
  Future<bool> openSupportTicket(RideSupportTicket ticket) async {
    final result = await _api.createSupportTicket(ticket);
    if (!result.data) {
      errorMessage.value = result.message ?? 'support_failed';
    }
    return result.data;
  }

  void resetErrors() {
    errorMessage.value = null;
    validationErrors.clear();
    if (uiState.value == TaxiUiState.error ||
        uiState.value == TaxiUiState.validationError) {
      uiState.value = TaxiUiState.defaultState;
    }
  }
}

/// Internal seam so `validateBookingForm` stays readable without reaching into
/// private transport state. Always true for the real service.
extension on TaxiApiService {
  bool get isUsableForTest => true;
}
