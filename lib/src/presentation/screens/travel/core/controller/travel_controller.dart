import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/travel_repository.dart';
import '../data/travel_api_repository.dart';
import '../models/travel_models.dart';

class TravelController extends GetxController {
  final TravelRepository repository;

  TravelController({TravelRepository? repository})
    : repository = repository ?? TravelApiRepository();

  final RxBool isLoading = false.obs;
  final RxBool isBootstrapLoading = false.obs;
  final RxBool isActivityLoading = false.obs;
  final RxBool isCheckoutLoading = false.obs;
  final RxBool isOfferLoading = false.obs;
  final RxBool isUpcomingFlightsLoading = false.obs;
  final RxBool isTravelerProfileLoading = false.obs;
  final RxBool checkoutFailed = false.obs;
  final RxnString bootstrapError = RxnString();
  final RxnString searchError = RxnString();
  final RxnString ordersError = RxnString();
  final RxnString checkoutError = RxnString();
  final RxnString loadingOfferId = RxnString();
  final Rxn<TravelBootstrap> bootstrap = Rxn<TravelBootstrap>();
  final Rxn<TravelHotelSearch> lastHotelSearch = Rxn<TravelHotelSearch>();
  final Rxn<TravelFlightSearch> lastFlightSearch = Rxn<TravelFlightSearch>();
  final RxList<TravelOffer> hotelOffers = <TravelOffer>[].obs;
  final RxList<TravelOffer> flightOffers = <TravelOffer>[].obs;
  final RxList<TravelOffer> upcomingFlightOffers = <TravelOffer>[].obs;
  final RxList<TravelHotelSearch> recentHotelSearches =
      <TravelHotelSearch>[].obs;
  final RxList<TravelFlightSearch> recentFlightSearches =
      <TravelFlightSearch>[].obs;
  final RxList<TravelEsimPackage> esimPackages = <TravelEsimPackage>[].obs;
  final RxList<TravelTraveler> travelers = <TravelTraveler>[].obs;
  final RxList<TravelOrder> orders = <TravelOrder>[].obs;
  final RxList<TravelActivity> activity = <TravelActivity>[].obs;
  final Rxn<TravelOffer> selectedOffer = Rxn<TravelOffer>();
  final Rxn<TravelOffer> selectedOutboundOffer = Rxn<TravelOffer>();
  final RxBool isSelectingReturnFlight = false.obs;
  final Rxn<TravelEsimPackage> selectedEsim = Rxn<TravelEsimPackage>();
  final Rxn<TravelOrder> latestOrder = Rxn<TravelOrder>();
  final Rxn<TravelReservation> activeReservation = Rxn<TravelReservation>();
  final Rxn<TravelTravelerProfile> travelerProfile =
      Rxn<TravelTravelerProfile>();
  final Rxn<DateTime> ordersLastUpdatedAt = Rxn<DateTime>();
  final Rx<TravelBookingDetails> hotelBookingDetails = TravelBookingDetails(
    checkInDate: DateTime.now().add(const Duration(days: 30)),
    checkOutDate: DateTime.now().add(const Duration(days: 32)),
    roomCount: 1,
    adultCount: 2,
  ).obs;
  final Rx<TravelBookingDetails> flightBookingDetails =
      const TravelBookingDetails().obs;
  String? _activeIdempotencyKey;
  final Map<String, String> _paymentIdempotencyKeys = {};
  final Map<String, String> _refundIdempotencyKeys = {};
  int _idempotencySequence = 0;

  @override
  void onInit() {
    super.onInit();
    unawaited(_loadRecentSearches());
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      await Future.wait<void>([_loadBootstrap(), _loadOrders()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadBootstrap() async {
    isBootstrapLoading.value = true;
    bootstrapError.value = null;
    try {
      bootstrap.value = await repository.getBootstrap();
    } catch (error) {
      bootstrap.value = null;
      bootstrapError.value = travelSafeErrorMessage(error);
    } finally {
      isBootstrapLoading.value = false;
    }
  }

  Future<void> reloadBootstrap() async {
    isLoading.value = true;
    try {
      await _loadBootstrap();
    } finally {
      isLoading.value = false;
    }
  }

  bool isServiceEnabled(TravelProductType type) =>
      bootstrap.value?.serviceFor(type) != null;

  TravelServiceConfig? serviceFor(TravelProductType type) =>
      bootstrap.value?.serviceFor(type);

  bool canPurchase(TravelProductType type) {
    final service = serviceFor(type);
    final purchaseEnabled = service?.capabilities.any(
      (capability) => {
        'catalog_checkout',
        'sandbox_purchase',
        'purchase',
        'book',
        'booking',
        'checkout',
      }.contains(capability.toLowerCase()),
    );
    if (service == null || purchaseEnabled != true) return false;
    if (service.dataMode.toLowerCase() == 'catalog') {
      return service.capabilities.any(
        (capability) => {
          'catalog_checkout',
          'sandbox_purchase',
        }.contains(capability.toLowerCase()),
      );
    }
    return service.dataMode.toLowerCase() == 'live';
  }

  Future<void> _loadOrders() async {
    isActivityLoading.value = true;
    ordersError.value = null;
    try {
      final loadedOrders = await repository.getOrders();
      orders.assignAll(loadedOrders);
      activity.assignAll(
        loadedOrders.map(
          (order) => TravelActivity(
            id: 'order-${order.id}',
            titleKey: order.titleKey,
            subtitleKey: order.reference,
            amount: order.total,
            isCredit: false,
            createdAt: order.createdAt,
            type: order.type,
          ),
        ),
      );
      ordersLastUpdatedAt.value = DateTime.now();
    } catch (error) {
      ordersError.value = travelSafeErrorMessage(error);
    } finally {
      isActivityLoading.value = false;
    }
  }

  Future<void> refreshOrders() => _loadOrders();

  Future<List<TravelSuggestion>> getSuggestions(
    TravelProductType type, {
    String query = '',
    int limit = 20,
  }) async {
    try {
      return await repository.getSuggestions(type, query: query, limit: limit);
    } catch (_) {
      return const [];
    }
  }

  Future<bool> searchHotels(TravelHotelSearch search) async {
    isLoading.value = true;
    searchError.value = null;
    try {
      final offers = await repository.searchHotels(search);
      hotelOffers.assignAll(offers);
      lastHotelSearch.value = search;
      await _rememberHotelSearch(search);
      return true;
    } catch (error) {
      searchError.value = travelSafeErrorMessage(error);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> searchFlights(TravelFlightSearch search) async {
    isLoading.value = true;
    searchError.value = null;
    try {
      final offers = await repository.searchFlights(search);
      flightOffers.assignAll(offers);
      lastFlightSearch.value = search;
      selectedOutboundOffer.value = null;
      isSelectingReturnFlight.value = false;
      await _rememberFlightSearch(search);
      return true;
    } catch (error) {
      searchError.value = travelSafeErrorMessage(error);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> beginReturnFlightSelection(TravelOffer outbound) async {
    final search = lastFlightSearch.value;
    final returnDate = search?.returnDate;
    if (search == null || returnDate == null) return false;
    isLoading.value = true;
    searchError.value = null;
    try {
      final offers = await repository.searchFlights(
        TravelFlightSearch(
          origin: search.destination,
          destination: search.origin,
          departureDate: returnDate,
          adultCount: search.adultCount,
          childCount: search.childCount,
          infantCount: search.infantCount,
          cabinClass: search.cabinClass,
        ),
      );
      selectedOutboundOffer.value = outbound;
      isSelectingReturnFlight.value = true;
      flightOffers.assignAll(offers);
      return true;
    } catch (error) {
      searchError.value = travelSafeErrorMessage(error);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUpcomingFlights() async {
    if (isUpcomingFlightsLoading.value) return;
    isUpcomingFlightsLoading.value = true;
    try {
      upcomingFlightOffers.assignAll(await repository.getUpcomingFlights());
    } catch (_) {
      upcomingFlightOffers.clear();
    } finally {
      isUpcomingFlightsLoading.value = false;
    }
  }

  Future<bool> loadOfferDetails(TravelOffer offer) async {
    if (isOfferLoading.value) return false;
    selectedOffer.value = offer;
    isOfferLoading.value = true;
    loadingOfferId.value = offer.id;
    try {
      selectedOffer.value = await repository.getOfferDetails(
        offer.type,
        offer.id,
      );
    } catch (_) {
      selectedOffer.value = offer;
    } finally {
      isOfferLoading.value = false;
      loadingOfferId.value = null;
    }
    return true;
  }

  bool isOfferLoadingFor(TravelOffer offer) => loadingOfferId.value == offer.id;

  Future<bool> loadEsimPackages(String destinationCode) async {
    isLoading.value = true;
    searchError.value = null;
    try {
      esimPackages.assignAll(await repository.getEsimPackages(destinationCode));
      return true;
    } catch (error) {
      esimPackages.clear();
      searchError.value = travelSafeErrorMessage(error);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveTraveler(TravelTraveler traveler) async {
    isLoading.value = true;
    try {
      final savedTraveler = await repository.saveTraveler(traveler);
      final index = travelers.indexWhere((item) => item.id == savedTraveler.id);
      if (index == -1) {
        travelers.add(savedTraveler);
      } else {
        travelers[index] = savedTraveler;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<TravelTravelerProfile?> loadTravelerProfile() async {
    if (isTravelerProfileLoading.value) return travelerProfile.value;
    isTravelerProfileLoading.value = true;
    try {
      travelerProfile.value = await repository.getTravelerProfile();
      return travelerProfile.value;
    } catch (_) {
      return travelerProfile.value;
    } finally {
      isTravelerProfileLoading.value = false;
    }
  }

  Future<bool> updateTravelerProfile(
    TravelPassenger passenger, {
    String phone = '',
  }) async {
    if (isTravelerProfileLoading.value) return false;
    isTravelerProfileLoading.value = true;
    try {
      travelerProfile.value = await repository.updateTravelerProfile(
        passenger,
        phone: phone,
      );
      return travelerProfile.value?.complete == true;
    } catch (_) {
      return false;
    } finally {
      isTravelerProfileLoading.value = false;
    }
  }

  Future<void> _loadRecentSearches() async {
    final preferences = await SharedPreferences.getInstance();
    recentHotelSearches.assignAll(
      _decodeSearches(
        preferences.getStringList('travel_recent_hotels') ?? const [],
        TravelHotelSearch.fromJson,
      ),
    );
    recentFlightSearches.assignAll(
      _decodeSearches(
        preferences.getStringList('travel_recent_flights') ?? const [],
        TravelFlightSearch.fromJson,
      ),
    );
  }

  Future<void> _rememberHotelSearch(TravelHotelSearch search) async {
    recentHotelSearches
      ..removeWhere(
        (item) =>
            item.city.toLowerCase() == search.city.toLowerCase() &&
            item.checkInDate == search.checkInDate &&
            item.checkOutDate == search.checkOutDate,
      )
      ..insert(0, search);
    if (recentHotelSearches.length > 5) {
      recentHotelSearches.removeRange(5, recentHotelSearches.length);
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      'travel_recent_hotels',
      recentHotelSearches.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Future<void> _rememberFlightSearch(TravelFlightSearch search) async {
    recentFlightSearches
      ..removeWhere(
        (item) =>
            item.origin?.toLowerCase() == search.origin?.toLowerCase() &&
            item.destination?.toLowerCase() ==
                search.destination?.toLowerCase() &&
            item.departureDate == search.departureDate,
      )
      ..insert(0, search);
    if (recentFlightSearches.length > 5) {
      recentFlightSearches.removeRange(5, recentFlightSearches.length);
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      'travel_recent_flights',
      recentFlightSearches.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Wallets? walletForCurrency(String currency) {
    if (!Get.isRegistered<HomeController>()) return null;
    final wallets = Get.find<HomeController>().walletsList;
    return wallets.firstWhereOrNull(
      (item) => item.code?.toUpperCase() == currency.toUpperCase(),
    );
  }

  List<Wallets> walletsForCurrency(String currency) {
    if (!Get.isRegistered<HomeController>()) return const [];
    return Get.find<HomeController>().walletsList
        .where((item) => item.code?.toUpperCase() == currency.toUpperCase())
        .toList();
  }

  List<Wallets> fundedExchangeWallets(String targetCurrency) {
    if (!Get.isRegistered<HomeController>()) return const [];
    return Get.find<HomeController>().walletsList
        .where(
          (item) =>
              item.code?.toUpperCase() != targetCurrency.toUpperCase() &&
              (double.tryParse(
                        (item.balance ?? '0')
                            .replaceAll(',', '')
                            .replaceAll(RegExp(r'[^0-9.-]'), ''),
                      ) ??
                      0) >
                  0,
        )
        .toList()
      ..sort((left, right) {
        double balance(Wallets wallet) =>
            double.tryParse(
              (wallet.balance ?? '0')
                  .replaceAll(',', '')
                  .replaceAll(RegExp(r'[^0-9.-]'), ''),
            ) ??
            0;
        return balance(right).compareTo(balance(left));
      });
  }

  double walletBalanceFor(String currency) {
    final wallet = walletForCurrency(currency);
    if (wallet == null) return 0;
    final raw = wallet.balance ?? '0';
    return double.tryParse(
          raw.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.-]'), ''),
        ) ??
        0;
  }

  Future<void> refreshMainWallet() async {
    if (!Get.isRegistered<HomeController>()) return;
    final homeController = Get.find<HomeController>();
    await Future.wait<void>([
      homeController.fetchWallets(),
      homeController.fetchUser(),
    ]);
  }

  Future<TravelReservation?> reserve({
    required TravelProductType type,
    required String productId,
    required TravelMoney total,
    required TravelBookingDetails bookingDetails,
  }) async {
    if (isCheckoutLoading.value) return null;
    if (!canPurchase(type)) {
      checkoutFailed.value = true;
      checkoutError.value = travelSafeErrorMessage();
      return null;
    }
    isCheckoutLoading.value = true;
    checkoutFailed.value = false;
    checkoutError.value = null;
    _activeIdempotencyKey ??=
        '${type.name}-$productId-${_nextIdempotencyNonce()}';
    try {
      final reservation = await repository.createReservation(
        type: type,
        productId: productId,
        expectedTotal: total,
        idempotencyKey: _activeIdempotencyKey!,
        bookingDetails: bookingDetails,
      );
      activeReservation.value = reservation;
      return reservation;
    } catch (error) {
      checkoutFailed.value = true;
      checkoutError.value = travelSafeErrorMessage(error);
      return null;
    } finally {
      isCheckoutLoading.value = false;
    }
  }

  Future<TravelOrder?> payReservation(TravelReservation reservation) async {
    if (isCheckoutLoading.value) return null;
    if (DateTime.now().isAfter(reservation.expiresAt)) {
      checkoutFailed.value = true;
      checkoutError.value = travelSafeErrorMessage();
      clearExpiredReservationForRetry(reservation);
      return null;
    }
    isCheckoutLoading.value = true;
    checkoutFailed.value = false;
    checkoutError.value = null;
    final idempotencyKey = _paymentIdempotencyKeys.putIfAbsent(
      reservation.id,
      () => 'pay-${reservation.id}-${_nextIdempotencyNonce()}',
    );
    try {
      final order = await repository.payReservation(
        reservation: reservation,
        idempotencyKey: idempotencyKey,
      );
      latestOrder.value = order;
      orders.insert(0, order);
      activeReservation.value = null;
      _activeIdempotencyKey = null;
      _paymentIdempotencyKeys.remove(reservation.id);
      await refreshMainWallet();
      return order;
    } catch (error) {
      checkoutFailed.value = true;
      checkoutError.value = travelSafeErrorMessage(error);
      return null;
    } finally {
      isCheckoutLoading.value = false;
    }
  }

  void clearExpiredReservationForRetry(TravelReservation reservation) {
    if (activeReservation.value == null ||
        activeReservation.value?.id == reservation.id) {
      activeReservation.value = null;
      _activeIdempotencyKey = null;
    }
    _paymentIdempotencyKeys.remove(reservation.id);
  }

  Future<TravelOrder?> requestRefund({
    required TravelOrder order,
    required String reasonCode,
    String? customerNote,
  }) async {
    if (isCheckoutLoading.value) return null;
    isCheckoutLoading.value = true;
    checkoutFailed.value = false;
    checkoutError.value = null;
    final idempotencyKey = _refundIdempotencyKeys.putIfAbsent(
      order.id,
      () => 'refund-${order.id}-${_nextIdempotencyNonce()}',
    );
    try {
      final updatedOrder = await repository.requestRefund(
        order: order,
        reasonCode: reasonCode,
        customerNote: customerNote,
        idempotencyKey: idempotencyKey,
      );
      final index = orders.indexWhere((item) => item.id == order.id);
      if (index >= 0) {
        orders[index] = updatedOrder;
      }
      latestOrder.value = updatedOrder;
      _refundIdempotencyKeys.remove(order.id);
      return updatedOrder;
    } catch (error) {
      checkoutFailed.value = true;
      checkoutError.value = travelSafeErrorMessage(error);
      return null;
    } finally {
      isCheckoutLoading.value = false;
    }
  }

  String _nextIdempotencyNonce() {
    _idempotencySequence++;
    return '${DateTime.now().microsecondsSinceEpoch}-$_idempotencySequence';
  }
}

List<T> _decodeSearches<T>(
  List<String> encoded,
  T Function(Map<String, dynamic>) decode,
) {
  final result = <T>[];
  for (final item in encoded) {
    try {
      final value = jsonDecode(item);
      if (value is Map) result.add(decode(Map<String, dynamic>.from(value)));
    } catch (_) {
      continue;
    }
  }
  return result;
}

const String travelGenericErrorMessage =
    'We could not complete this request. Please try again.';

String travelSafeErrorMessage([Object? error]) {
  final reference = _travelErrorReference(error);
  if (reference == null) return travelGenericErrorMessage;
  return '$travelGenericErrorMessage Reference: $reference';
}

String? _travelErrorReference(Object? error) {
  if (error is DioException) {
    return _travelReferenceFromMap(_travelMap(error.response?.data)) ??
        _firstSafeReference(error.response?.headers.value('x-request-id')) ??
        _firstSafeReference(error.response?.headers.value('x-correlation-id'));
  }
  return null;
}

String? _travelReferenceFromMap(Map<String, dynamic> map, [int depth = 0]) {
  if (map.isEmpty || depth >= 4) return null;
  const keys = [
    'support_reference',
    'supportReference',
    'request_reference',
    'requestReference',
    'request_id',
    'requestId',
    'correlation_id',
    'correlationId',
    'trace_id',
    'traceId',
    'reference',
  ];
  for (final key in keys) {
    final reference = _firstSafeReference(map[key]);
    if (reference != null) return reference;
  }
  for (final key in const ['error', 'meta', 'data']) {
    final nested = _travelMap(map[key]);
    if (nested.isEmpty) continue;
    final reference = _travelReferenceFromMap(nested, depth + 1);
    if (reference != null) return reference;
  }
  return null;
}

Map<String, dynamic> _travelMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

String? _firstSafeReference(dynamic value) {
  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty || raw.length > 80) return null;
  return RegExp(r'^[A-Za-z0-9][A-Za-z0-9._:-]*$').hasMatch(raw) ? raw : null;
}
