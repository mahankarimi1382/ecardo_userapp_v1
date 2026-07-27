import 'package:get/get.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/model/wallets_model.dart';

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
  final RxBool checkoutFailed = false.obs;
  final RxnString bootstrapError = RxnString();
  final RxnString searchError = RxnString();
  final Rxn<TravelBootstrap> bootstrap = Rxn<TravelBootstrap>();
  final RxList<TravelOffer> hotelOffers = <TravelOffer>[].obs;
  final RxList<TravelOffer> flightOffers = <TravelOffer>[].obs;
  final RxList<TravelOffer> upcomingFlightOffers = <TravelOffer>[].obs;
  final RxList<TravelEsimPackage> esimPackages = <TravelEsimPackage>[].obs;
  final RxList<TravelTraveler> travelers = <TravelTraveler>[].obs;
  final RxList<TravelOrder> orders = <TravelOrder>[].obs;
  final RxList<TravelActivity> activity = <TravelActivity>[].obs;
  final Rxn<TravelOffer> selectedOffer = Rxn<TravelOffer>();
  final Rxn<TravelEsimPackage> selectedEsim = Rxn<TravelEsimPackage>();
  final Rxn<TravelOrder> latestOrder = Rxn<TravelOrder>();
  final Rxn<TravelReservation> activeReservation = Rxn<TravelReservation>();
  final Rx<TravelBookingDetails> hotelBookingDetails = TravelBookingDetails(
    checkInDate: DateTime.now().add(const Duration(days: 30)),
    checkOutDate: DateTime.now().add(const Duration(days: 32)),
    roomCount: 1,
    adultCount: 2,
  ).obs;
  final Rx<TravelBookingDetails> flightBookingDetails =
      const TravelBookingDetails().obs;
  String? _activeIdempotencyKey;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      await Future.wait<void>([
        _loadBootstrap(),
        _loadOrders(),
      ]);
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
      bootstrapError.value = error.toString();
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
    } catch (_) {
      orders.clear();
      activity.clear();
    } finally {
      isActivityLoading.value = false;
    }
  }

  Future<bool> searchHotels(TravelHotelSearch search) async {
    isLoading.value = true;
    searchError.value = null;
    try {
      hotelOffers.assignAll(await repository.searchHotels(search));
      return true;
    } catch (error) {
      hotelOffers.clear();
      searchError.value = error.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> searchFlights(TravelFlightSearch search) async {
    isLoading.value = true;
    searchError.value = null;
    try {
      flightOffers.assignAll(await repository.searchFlights(search));
      return true;
    } catch (error) {
      flightOffers.clear();
      searchError.value = error.toString();
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

  Future<void> loadOfferDetails(TravelOffer offer) async {
    selectedOffer.value = offer;
    if (isOfferLoading.value) return;
    isOfferLoading.value = true;
    try {
      selectedOffer.value = await repository.getOfferDetails(
        offer.type,
        offer.id,
      );
    } catch (_) {
      selectedOffer.value = offer;
    } finally {
      isOfferLoading.value = false;
    }
  }

  Future<bool> loadEsimPackages(String destinationCode) async {
    isLoading.value = true;
    searchError.value = null;
    try {
      esimPackages.assignAll(
        await repository.getEsimPackages(destinationCode),
      );
      return true;
    } catch (error) {
      esimPackages.clear();
      searchError.value = error.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveTraveler(TravelTraveler traveler) async {
    isLoading.value = true;
    try {
      final savedTraveler = await repository.saveTraveler(traveler);
      final index = travelers.indexWhere(
        (item) => item.id == savedTraveler.id,
      );
      if (index == -1) {
        travelers.add(savedTraveler);
      } else {
        travelers[index] = savedTraveler;
      }
    } finally {
      isLoading.value = false;
    }
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
        .where(
          (item) => item.code?.toUpperCase() == currency.toUpperCase(),
        )
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
      return null;
    }
    isCheckoutLoading.value = true;
    checkoutFailed.value = false;
    _activeIdempotencyKey ??=
        '${type.name}-$productId-${DateTime.now().millisecondsSinceEpoch}';
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
    } catch (_) {
      checkoutFailed.value = true;
      return null;
    } finally {
      isCheckoutLoading.value = false;
    }
  }

  Future<TravelOrder?> payReservation(TravelReservation reservation) async {
    if (isCheckoutLoading.value) return null;
    if (DateTime.now().isAfter(reservation.expiresAt)) {
      checkoutFailed.value = true;
      activeReservation.value = null;
      return null;
    }
    isCheckoutLoading.value = true;
    checkoutFailed.value = false;
    try {
      final order = await repository.payReservation(
        reservation: reservation,
        idempotencyKey:
            'pay-${reservation.id}-${DateTime.now().millisecondsSinceEpoch}',
      );
      latestOrder.value = order;
      orders.insert(0, order);
      activeReservation.value = null;
      _activeIdempotencyKey = null;
      await refreshMainWallet();
      return order;
    } catch (_) {
      checkoutFailed.value = true;
      return null;
    } finally {
      isCheckoutLoading.value = false;
    }
  }
}
