import 'package:get/get.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';

import '../data/travel_repository.dart';
import '../data/travel_api_repository.dart';
import '../models/travel_models.dart';

class TravelController extends GetxController {
  final TravelRepository repository;

  TravelController({TravelRepository? repository})
    : repository =
          repository ??
          HybridTravelRepository(
            gateway: TravelApiRepository(),
            fallback: MockTravelRepository(),
          );

  final RxBool isLoading = false.obs;
  final RxBool isCheckoutLoading = false.obs;
  final RxBool checkoutFailed = false.obs;
  final RxList<TravelOffer> hotelOffers = <TravelOffer>[].obs;
  final RxList<TravelOffer> flightOffers = <TravelOffer>[].obs;
  final RxList<TravelEsimPackage> esimPackages = <TravelEsimPackage>[].obs;
  final RxList<TravelTraveler> travelers = <TravelTraveler>[].obs;
  final RxList<TravelOrder> orders = <TravelOrder>[].obs;
  final RxList<TravelActivity> activity = <TravelActivity>[].obs;
  final Rxn<TravelOffer> selectedOffer = Rxn<TravelOffer>();
  final Rxn<TravelEsimPackage> selectedEsim = Rxn<TravelEsimPackage>();
  final Rxn<TravelOrder> latestOrder = Rxn<TravelOrder>();
  final Rx<TravelBookingDetails> hotelBookingDetails = TravelBookingDetails(
    checkInDate: DateTime.now().add(const Duration(days: 30)),
    checkOutDate: DateTime.now().add(const Duration(days: 32)),
    roomCount: 1,
    adultCount: 2,
  ).obs;
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
        _loadOrders(),
        _loadActivity(),
        _loadTravelers(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadOrders() async {
    try {
      orders.assignAll(await repository.getOrders());
    } catch (_) {
      orders.clear();
    }
  }

  Future<void> _loadActivity() async {
    try {
      activity.assignAll(await repository.getActivity());
    } catch (_) {
      activity.clear();
    }
  }

  Future<void> _loadTravelers() async {
    try {
      travelers.assignAll(await repository.getTravelers());
    } catch (_) {
      travelers.clear();
    }
  }

  Future<void> searchHotels() async {
    isLoading.value = true;
    try {
      hotelOffers.assignAll(await repository.searchHotels());
    } catch (_) {
      hotelOffers.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchFlights() async {
    isLoading.value = true;
    try {
      flightOffers.assignAll(await repository.searchFlights());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadEsimPackages() async {
    isLoading.value = true;
    try {
      esimPackages.assignAll(await repository.getEsimPackages());
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

  double get mainWalletBalance {
    if (!Get.isRegistered<HomeController>()) return 0;
    final raw = Get.find<HomeController>().userModel.value.data?.balance ?? '0';
    return double.tryParse(
          raw.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.-]'), ''),
        ) ??
        0;
  }

  Future<TravelOrder?> checkout({
    required TravelProductType type,
    required String productId,
    required TravelMoney total,
    required TravelBookingDetails bookingDetails,
  }) async {
    if (isCheckoutLoading.value) return null;
    isCheckoutLoading.value = true;
    checkoutFailed.value = false;
    _activeIdempotencyKey ??=
        '${type.name}-$productId-${DateTime.now().millisecondsSinceEpoch}';
    try {
      final order = await repository.createOrder(
        type: type,
        productId: productId,
        expectedTotal: total,
        idempotencyKey: _activeIdempotencyKey!,
        bookingDetails: bookingDetails,
      );
      latestOrder.value = order;
      orders.insert(0, order);
      _activeIdempotencyKey = null;
      return order;
    } catch (_) {
      checkoutFailed.value = true;
      return null;
    } finally {
      isCheckoutLoading.value = false;
    }
  }
}
