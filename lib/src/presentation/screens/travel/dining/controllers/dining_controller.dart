import 'package:get/get.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import '../models/dining_models.dart';

class DiningController extends GetxController {
  final RxList<RestaurantModel> allRestaurants = <RestaurantModel>[].obs;
  final RxList<RestaurantModel> filteredRestaurants = <RestaurantModel>[].obs;
  final RxList<DiningOrderModel> myOrders = <DiningOrderModel>[].obs;

  final RxString selectedHub = 'ALL'.obs;
  final Rx<DiningServiceMode?> selectedMode = Rx<DiningServiceMode?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isSubmittingOrder = false.obs;

  // Active Cart State
  final RxList<DiningOrderItem> cartItems = <DiningOrderItem>[].obs;
  final Rx<RestaurantModel?> cartRestaurant = Rx<RestaurantModel?>(null);
  final Rx<DiningServiceMode> orderMode = DiningServiceMode.airportGatePickup.obs;
  final RxString gateOrFlightNumber = 'Gate 14 / Flight EK972'.obs;
  final RxString targetPickupTime = '12:45'.obs;

  @override
  void onInit() {
    super.onInit();
    loadCatalog();
    loadSampleOrders();
  }

  void loadCatalog() {
    isLoading.value = true;
    try {
      allRestaurants.assignAll([
        const RestaurantModel(
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
          ],
          menu: [
            MenuItemModel(
              id: 'menu-01',
              title: 'چلوکباب کوبیده مخصوص با برنج ایرانی و سماق',
              description: 'دو سیخ کباب گوشت گوسفندی تازه، برنج طارم زعفرانی، گوجه کبابی و کره محلی',
              price: 18.0,
              currency: 'USD',
              isHalal: true,
              calories: 720,
              prepMinutes: 15,
            ),
            MenuItemModel(
              id: 'menu-02',
              title: 'باکس صبحانه گرم تشریفاتی (Executive Warm Breakfast)',
              description: 'املت قارچ و پنیر، بیکن بوقلمون، سوسیس، آب‌پرتقال طبیعی و کروسان تازه',
              price: 12.0,
              currency: 'USD',
              isHalal: true,
              calories: 540,
              prepMinutes: 10,
            ),
            MenuItemModel(
              id: 'menu-03',
              title: 'اسموتی انرژی‌زای سفر و قهوه اسپرسو دوبل',
              description: 'ترکیب طبیعی بری، موز، دانه چیا + یک شات قهوه تخصصی ۱۰۰٪ عربیکا',
              price: 7.0,
              currency: 'USD',
              isHalal: true,
              isVegan: true,
              calories: 210,
              prepMinutes: 5,
            ),
          ],
        ),
        const RestaurantModel(
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
          menu: [
            MenuItemModel(
              id: 'menu-04',
              title: 'پیتزا ناپولیتن مارگریتا تنوری (Neapolitan Pizza)',
              description: 'پنیر موزارلا تازه دی بوفالا، سس گوجه سن مارزانو و ریحان ارگانیک',
              price: 16.0,
              currency: 'USD',
              isHalal: true,
              isVegan: false,
              calories: 680,
              prepMinutes: 12,
            ),
            MenuItemModel(
              id: 'menu-05',
              title: 'پاستا پنه آلفردو با سینه مرغ گریل‌شده',
              description: 'پنه ریگاته با خامه ترافل، پنیر پارمزان ۲۴ ماهه و قارچ تازه',
              price: 15.0,
              currency: 'USD',
              isHalal: true,
              calories: 620,
              prepMinutes: 14,
            ),
            MenuItemModel(
              id: 'menu-06',
              title: 'سالاد سزار مدیترانه‌ای کینوا (Quinoa Caesar Salad)',
              description: 'کاهو پیچ تازه، کینوا، نان تست سیردار و سس مخصوص سزار بدون تخم‌مرغ خام',
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
          ],
          menu: [
            MenuItemModel(
              id: 'menu-07',
              title: 'اسکندر کباب اصیل بورسا (Authentic Iskender Kebab)',
              description: 'برش‌های دونر گوشت بره، نان پیده برشته، کره داغ گوسفندی و ماست محلی',
              price: 17.0,
              currency: 'USD',
              isHalal: true,
              calories: 790,
              prepMinutes: 15,
            ),
            MenuItemModel(
              id: 'menu-08',
              title: 'باقلوای پسته آنتپ همراه با چای دمی ترکی',
              description: '۴ تکه باقلوای ترد استانبولی با مغز پسته تازه و یک استکان چای درجه‌یک',
              price: 8.0,
              currency: 'USD',
              isHalal: true,
              calories: 420,
              prepMinutes: 5,
            ),
          ],
        ),
      ]);
      applyFilters();
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    filteredRestaurants.assignAll(allRestaurants.where((rest) {
      final matchesHub = selectedHub.value == 'ALL' || rest.city.contains(selectedHub.value);
      final matchesMode = selectedMode.value == null || rest.availableModes.contains(selectedMode.value);
      return matchesHub && matchesMode;
    }));
  }

  void setHub(String hub) {
    selectedHub.value = hub;
    applyFilters();
  }

  void setMode(DiningServiceMode? mode) {
    selectedMode.value = mode;
    applyFilters();
  }

  // Cart operations
  void addToCart(RestaurantModel restaurant, MenuItemModel item) {
    if (cartRestaurant.value != null && cartRestaurant.value!.id != restaurant.id) {
      // Clear cart if switching restaurant
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

  int getItemQuantity(String itemId) {
    final existing = cartItems.firstWhereOrNull((i) => i.item.id == itemId);
    return existing?.quantity ?? 0;
  }

  double get cartSubtotal {
    return cartItems.fold(0.0, (sum, i) => sum + i.subtotal);
  }

  int get cartCount {
    return cartItems.fold(0, (sum, i) => sum + i.quantity);
  }

  Future<DiningOrderModel?> submitOrder() async {
    if (cartItems.isEmpty || cartRestaurant.value == null) return null;

    isSubmittingOrder.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 1400)); // Checkout simulation

      final rest = cartRestaurant.value!;
      final order = DiningOrderModel(
        orderId: 'MEAL-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        restaurantId: rest.id,
        restaurantName: rest.name,
        terminalLocation: rest.terminalLocation,
        mode: orderMode.value,
        gateOrTable: gateOrFlightNumber.value,
        pickupTime: targetPickupTime.value,
        items: List.from(cartItems),
        totalAmount: cartSubtotal,
        currency: cartItems.first.item.currency,
        status: 'preparing',
        orderedAt: DateTime.now(),
      );

      myOrders.insert(0, order);
      cartItems.clear();
      cartRestaurant.value = null;

      ToastHelper().showSuccessToast('سفارش غذا با موفقیت ثبت شد و در حال آماده‌سازی است');
      return order;
    } catch (e) {
      ToastHelper().showErrorToast('خطا در ثبت سفارش: $e');
      return null;
    } finally {
      isSubmittingOrder.value = false;
    }
  }

  void loadSampleOrders() {
    myOrders.assignAll([
      DiningOrderModel(
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
            quantity: 1,
          ),
        ],
        totalAmount: 18.0,
        currency: 'USD',
        status: 'ready_for_pickup',
        orderedAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
    ]);
  }
}
