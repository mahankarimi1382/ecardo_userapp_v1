// DATA: MOCK (Ready for REAL backend domain registration under schema_version: 1.0)
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import '../../local/models/experience_contracts.dart';
import '../models/dining_models.dart';

class DiningController extends GetxController {
  // UI State Machine
  final Rx<ExperienceServiceState> uiState = ExperienceServiceState.defaultState.obs;
  final RxString errorMessage = ''.obs;
  final RxString validationError = ''.obs;
  final RxBool isOffline = false.obs;

  // Catalog
  final RxList<RestaurantModel> allRestaurants = <RestaurantModel>[].obs;
  final RxList<RestaurantModel> filteredRestaurants = <RestaurantModel>[].obs;
  final RxList<DiningOrderModel> myOrders = <DiningOrderModel>[].obs;

  // Filters
  final RxString selectedHub = 'ALL'.obs;
  final Rx<DiningServiceMode?> selectedMode = Rx<DiningServiceMode?>(null);
  final RxString searchQuery = ''.obs;
  final RxBool onlyHalal = false.obs;
  final RxBool onlyVegan = false.obs;
  Timer? _debounceTimer;

  // Active Cart State
  final RxList<DiningOrderItem> cartItems = <DiningOrderItem>[].obs;
  final Rx<RestaurantModel?> cartRestaurant = Rx<RestaurantModel?>(null);
  final Rx<DiningServiceMode> orderMode = DiningServiceMode.airportGatePickup.obs;
  final RxString gateOrFlightNumber = ''.obs;
  final RxString targetPickupTime = ''.obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    loadCatalog();
    loadSampleOrders();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  void _initConnectivity() {
    // DATA: REAL connectivity check
    Connectivity().checkConnectivity().then((result) {
      final offline = result.contains(ConnectivityResult.none);
      isOffline.value = offline;
      if (offline && uiState.value == ExperienceServiceState.defaultState) {
        uiState.value = ExperienceServiceState.offline;
      }
    }).catchError((_) {});

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final offline = results.contains(ConnectivityResult.none);
      isOffline.value = offline;
      if (offline) {
        uiState.value = ExperienceServiceState.offline;
      } else if (uiState.value == ExperienceServiceState.offline) {
        uiState.value = ExperienceServiceState.success;
      }
    });
  }

  /// In-transit dining catalog. Tagged MOCK — no `dining` travel_service_domain registered.
  Future<void> loadCatalog() async {
    uiState.value = ExperienceServiceState.skeleton;
    errorMessage.value = '';

    try {
      await Future.delayed(const Duration(milliseconds: 550));

      // DATA: MOCK dataset
      final mockData = [
        const RestaurantModel(
          schemaVersion: '1.0',
          id: 'rest-01',
          name: 'کافه رستوران پرشین لانژ (Persian Sky Lounge & Dining)',
          terminalLocation: 'فرودگاه امام خمینی (IKA) — سالن ترانزیت، مجاور گیت ۱۸',
          city: 'تهران (IKA)',
          cuisineType: 'ایرانی و بین‌المللی',
          rating: 4.8,
          reviewsCount: 184,
          openingHours: '۲۴ ساعته (شبانه روزی)',
          availableModes: [
            DiningServiceMode.airportGatePickup,
            DiningServiceMode.loungeDelivery,
            DiningServiceMode.tableReservation,
            DiningServiceMode.chefTastingExperience,
          ],
          currency: 'USD',
          minOrderAmount: 7.0,
          tableReservationDeposit: 5.0,
          avgPrepMinutes: 15,
          menu: [
            MenuItemModel(
              id: 'menu-01',
              title: 'چلوکباب کوبیده مخصوص با برنج ایرانی و سماق',
              description:
                  'دو سیخ کباب گوشت گوسفندی تازه، برنج طارم زعفرانی، گوجه کبابی و کره محلی',
              price: 18.0,
              currency: 'USD',
              isHalal: true,
              calories: 720,
              prepMinutes: 15,
            ),
            MenuItemModel(
              id: 'menu-02',
              title: 'باکس صبحانه گرم تشریفاتی (Executive Warm Breakfast)',
              description:
                  'املت قارچ و پنیر، بیکن بوقلمون، سوسیس، آب‌پرتقال طبیعی و کروسان تازه',
              price: 12.0,
              currency: 'USD',
              isHalal: true,
              calories: 540,
              prepMinutes: 10,
            ),
            MenuItemModel(
              id: 'menu-03',
              title: 'اسموتی انرژی‌زای سفر و قهوه اسپرسو دوبل',
              description:
                  'ترکیب طبیعی بری، موز، دانه چیا + یک شات قهوه تخصصی ۱۰۰٪ عربیکا',
              price: 7.0,
              currency: 'USD',
              isHalal: true,
              isVegan: true,
              isGlutenFree: true,
              calories: 210,
              prepMinutes: 5,
            ),
          ],
        ),
        const RestaurantModel(
          schemaVersion: '1.0',
          id: 'rest-02',
          name: 'رستوران ایتالیایی کاپری اکسپرس (Capri Airport Trattoria)',
          terminalLocation: 'فرودگاه بین‌المللی دبی (DXB) — پایانه ۳، کانسپت B',
          city: 'دبی (DXB)',
          cuisineType: 'ایتالیایی و مدیترانه‌ای',
          rating: 4.75,
          reviewsCount: 220,
          openingHours: '۲۴ ساعته',
          availableModes: [
            DiningServiceMode.airportGatePickup,
            DiningServiceMode.tableReservation,
          ],
          currency: 'USD',
          minOrderAmount: 11.0,
          avgPrepMinutes: 12,
          menu: [
            MenuItemModel(
              id: 'menu-04',
              title: 'پیتزا ناپولیتن مارگریتا تنوری (Neapolitan Pizza)',
              description:
                  'پنیر موزارلا تازه دی بوفالا، سس گوجه سن مارزانو و ریحان ارگانیک',
              price: 16.0,
              currency: 'USD',
              isHalal: true,
              calories: 680,
              prepMinutes: 12,
            ),
            MenuItemModel(
              id: 'menu-05',
              title: 'پاستا پنه آلفردو با سینه مرغ گریل‌شده',
              description:
                  'پنه ریگاته با خامه ترافل، پنیر پارمزان ۲۴ ماهه و قارچ تازه',
              price: 15.0,
              currency: 'USD',
              isHalal: true,
              calories: 620,
              prepMinutes: 14,
            ),
            MenuItemModel(
              id: 'menu-06',
              title: 'سالاد سزار مدیترانه‌ای کینوا (Quinoa Caesar Salad)',
              description:
                  'کاهو پیچ تازه، کینوا، نان تست سیردار و سس مخصوص سزار بدون تخم‌مرغ خام',
              price: 11.0,
              currency: 'USD',
              isHalal: true,
              isVegan: true,
              calories: 340,
              prepMinutes: 8,
            ),
          ],
        ),
        const RestaurantModel(
          schemaVersion: '1.0',
          id: 'rest-03',
          name: 'کافه کباب استانبول (Bosphorus Gourmet Grill)',
          terminalLocation: 'فرودگاه جدید استانبول (IST) — گیت‌های پرواز بین‌المللی F',
          city: 'استانبول (IST)',
          cuisineType: 'ترکی و عثمانی',
          rating: 4.9,
          reviewsCount: 310,
          openingHours: '۰۶:۰۰ تا ۲۴:۰۰',
          availableModes: [
            DiningServiceMode.airportGatePickup,
            DiningServiceMode.tableReservation,
            DiningServiceMode.chefTastingExperience,
          ],
          currency: 'USD',
          minOrderAmount: 8.0,
          avgPrepMinutes: 14,
          menu: [
            MenuItemModel(
              id: 'menu-07',
              title: 'اسکندر کباب اصیل بورسا (Authentic Iskender Kebab)',
              description:
                  'برش‌های دونر گوشت بره، نان پیده برشته، کره داغ گوسفندی و ماست محلی',
              price: 17.0,
              currency: 'USD',
              isHalal: true,
              spicyLevel: 2,
              calories: 790,
              prepMinutes: 15,
            ),
            MenuItemModel(
              id: 'menu-08',
              title: 'باقلوای پسته آنتپ همراه با چای دمی ترکی',
              description:
                  '۴ تکه باقلوای ترد استانبولی با مغز پسته تازه و یک استکان چای درجه‌یک',
              price: 8.0,
              currency: 'USD',
              isHalal: true,
              calories: 420,
              prepMinutes: 5,
            ),
          ],
        ),
      ];

      allRestaurants.assignAll(mockData);
      applyFilters();
      uiState.value =
          filteredRestaurants.isEmpty ? ExperienceServiceState.empty : ExperienceServiceState.success;
    } catch (e) {
      errorMessage.value = 'خطا در بارگذاری رستوران‌ها: $e';
      uiState.value = ExperienceServiceState.error;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), applyFilters);
  }

  void applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();
    final results = allRestaurants.where((rest) {
      final matchesHub = selectedHub.value == 'ALL' || rest.city.contains(selectedHub.value);
      final matchesMode =
          selectedMode.value == null || rest.availableModes.contains(selectedMode.value);
      final matchesQuery = query.isEmpty ||
          rest.name.toLowerCase().contains(query) ||
          rest.cuisineType.toLowerCase().contains(query) ||
          rest.menu.any((m) => m.title.toLowerCase().contains(query));
      return matchesHub && matchesMode && matchesQuery;
    }).toList();

    filteredRestaurants.assignAll(results);
    if (results.isEmpty) {
      uiState.value = ExperienceServiceState.empty;
    } else {
      uiState.value = ExperienceServiceState.success;
    }
  }

  void resetFilters() {
    selectedHub.value = 'ALL';
    selectedMode.value = null;
    searchQuery.value = '';
    onlyHalal.value = false;
    onlyVegan.value = false;
    applyFilters();
  }

  void setHub(String hub) {
    selectedHub.value = hub;
    applyFilters();
  }

  void setMode(DiningServiceMode? mode) {
    selectedMode.value = mode;
    applyFilters();
  }

  // ---- Cart operations ----
  void addToCart(RestaurantModel restaurant, MenuItemModel item) {
    if (cartRestaurant.value != null && cartRestaurant.value!.id != restaurant.id) {
      cartItems.clear();
    }
    cartRestaurant.value = restaurant;

    final existing = cartItems.firstWhereOrNull((i) => i.item.id == item.id);
    if (existing != null) {
      existing.quantity++;
      cartItems.refresh();
    } else {
      cartItems.add(DiningOrderItem(item: item, quantity: 1));
    }
    validationError.value = '';
    ToastHelper().showSuccessToast('${item.title} به سفارش شما اضافه شد');
  }

  void removeFromCart(MenuItemModel item) {
    final existing = cartItems.firstWhereOrNull((i) => i.item.id == item.id);
    if (existing != null) {
      if (existing.quantity > 1) {
        existing.quantity--;
        cartItems.refresh();
      } else {
        cartItems.remove(existing);
        if (cartItems.isEmpty) {
          cartRestaurant.value = null;
        }
      }
    }
  }

  void clearCart() {
    cartItems.clear();
    cartRestaurant.value = null;
    validationError.value = '';
  }

  int getItemQuantity(String itemId) {
    final existing = cartItems.firstWhereOrNull((i) => i.item.id == itemId);
    return existing?.quantity ?? 0;
  }

  double get cartSubtotal => cartItems.fold(0.0, (sum, i) => sum + i.subtotal);
  int get cartCount => cartItems.fold(0, (sum, i) => sum + i.quantity);
  int get cartPrepMinutes =>
      cartItems.isEmpty ? 0 : cartItems.map((i) => i.item.prepMinutes).reduce((a, b) => a > b ? a : b);

  String? validateOrder() {
    final rest = cartRestaurant.value;
    if (cartItems.isEmpty || rest == null) {
      return 'سبد سفارش شما خالی است. حداقل یک آیتم از منو انتخاب کنید.';
    }
    if (cartSubtotal < rest.minOrderAmount) {
      return 'حداقل مبلغ سفارش در این رستوران ${rest.minOrderAmount.toStringAsFixed(0)} ${rest.currency} است.';
    }
    if (orderMode.value == DiningServiceMode.airportGatePickup &&
        gateOrFlightNumber.value.trim().isEmpty) {
      return 'شماره گیت یا کد پرواز خود را برای تحویل وارد کنید.';
    }
    if (targetPickupTime.value.trim().isEmpty) {
      return 'زمان تحویل یا سرو را انتخاب کنید.';
    }
    return null;
  }

  /// Submits dining order. Tagged MOCK — no `dining` travel domain registered at trip.ecardo.ir.
  Future<DiningOrderModel?> submitOrder() async {
    validationError.value = '';
    final vErr = validateOrder();
    if (vErr != null) {
      validationError.value = vErr;
      uiState.value = ExperienceServiceState.validationError;
      ToastHelper().showErrorToast(vErr);
      return null;
    }

    uiState.value = ExperienceServiceState.processing;
    try {
      await Future.delayed(const Duration(milliseconds: 1300));

      final rest = cartRestaurant.value!;
      final orderId = 'MEAL-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final order = DiningOrderModel(
        schemaVersion: '1.0',
        orderId: orderId,
        restaurantId: rest.id,
        restaurantName: rest.name,
        terminalLocation: rest.terminalLocation,
        mode: orderMode.value,
        gateOrTable: gateOrFlightNumber.value.trim().isEmpty ? null : gateOrFlightNumber.value,
        pickupTime: targetPickupTime.value,
        items: List.from(cartItems),
        totalAmount: cartSubtotal,
        currency: rest.currency,
        refundDestinationWalletCurrency: rest.currency,
        status: 'preparing',
        orderedAt: DateTime.now(),
        cancellationPolicy: rest.cancellationPolicy,
      );

      myOrders.insert(0, order);
      cartItems.clear();
      cartRestaurant.value = null;

      uiState.value = ExperienceServiceState.completed;
      ToastHelper().showSuccessToast('سفارش غذا با موفقیت ثبت شد و در حال آماده‌سازی است');
      return order;
    } catch (e) {
      errorMessage.value = 'خطا در ثبت سفارش: $e';
      uiState.value = ExperienceServiceState.error;
      ToastHelper().showErrorToast('خطا در ثبت سفارش: $e');
      return null;
    }
  }

  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    final idx = myOrders.indexWhere((o) => o.orderId == orderId);
    if (idx < 0) return false;

    final order = myOrders[idx];
    if (!order.canCancel) {
      ToastHelper().showErrorToast('این سفارش قابل لغو نیست (آماده‌سازی تکمیل شده است).');
      return false;
    }

    uiState.value = ExperienceServiceState.processing;
    try {
      await Future.delayed(const Duration(milliseconds: 700));

      final refund = order.calculateCancellationRefund();
      myOrders[idx] = order.copyWithCancelled(
        penalty: refund.penaltyAmount,
        refund: refund.refundableAmount,
        reason: reason ?? refund.policySummary,
      );

      uiState.value = ExperienceServiceState.cancelled;
      ToastHelper().showSuccessToast(
        'سفارش لغو شد. ${refund.refundableAmount} ${refund.currency} به کیف پول مسترد گردید.',
      );
      return true;
    } catch (e) {
      ToastHelper().showErrorToast('خطا در لغو سفارش: $e');
      uiState.value = ExperienceServiceState.error;
      return false;
    }
  }

  /// Sample orders covering multiple lifecycle states (Partial success scenario).
  void loadSampleOrders() {
    // DATA: MOCK
    myOrders.assignAll([
      DiningOrderModel(
        schemaVersion: '1.0',
        orderId: 'MEAL-94210',
        restaurantId: 'rest-01',
        restaurantName: 'کافه رستوران پرشین لانژ (IKA)',
        terminalLocation: 'فرودگاه امام خمینی — سالن ترانزیت، گیت ۱۸',
        mode: DiningServiceMode.airportGatePickup,
        gateOrTable: 'Gate 18 • Flight W5-115',
        pickupTime: '14:15',
        items: [
          DiningOrderItem(
            item: const MenuItemModel(
              id: 'menu-01',
              title: 'چلوکباب کوبیده مخصوص با برنج زعفرانی',
              description: '',
              price: 18.0,
              currency: 'USD',
              calories: 720,
              prepMinutes: 15,
            ),
          ),
        ],
        totalAmount: 18.0,
        currency: 'USD',
        status: 'ready_for_pickup',
        orderedAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
      DiningOrderModel(
        schemaVersion: '1.0',
        orderId: 'MEAL-93188',
        restaurantId: 'rest-02',
        restaurantName: 'رستوران ایتالیایی کاپری اکسپرس (DXB)',
        terminalLocation: 'فرودگاه دبی — پایانه ۳',
        mode: DiningServiceMode.tableReservation,
        gateOrTable: 'Table 24, Concourse B',
        pickupTime: '11:00',
        items: [
          DiningOrderItem(
            item: const MenuItemModel(
              id: 'menu-04',
              title: 'پیتزا ناپولیتن مارگریتا تنوری',
              description: '',
              price: 16.0,
              currency: 'USD',
              calories: 680,
              prepMinutes: 12,
            ),
            quantity: 2,
          ),
        ],
        totalAmount: 32.0,
        currency: 'USD',
        status: 'cancelled',
        cancellationReason: 'پرواز زودتر کنسل شد — جریمه ۵۰٪ آماده‌سازی آشپزخانه',
        penaltyAmount: 16.0,
        refundedAmount: 16.0,
        orderedAt: DateTime.now().subtract(const Duration(hours: 6)),
        cancelledAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ]);
  }
}
