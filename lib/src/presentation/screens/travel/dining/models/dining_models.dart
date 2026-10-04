enum DiningServiceMode {
  airportGatePickup,
  loungeDelivery,
  tableReservation,
}

class MenuItemModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final String? imageUrl;
  final bool isHalal;
  final bool isVegan;
  final int calories;
  final int prepMinutes;

  const MenuItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    this.imageUrl,
    this.isHalal = true,
    this.isVegan = false,
    required this.calories,
    required this.prepMinutes,
  });
}

class RestaurantModel {
  final String id;
  final String name;
  final String terminalLocation;
  final String city;
  final String cuisineType;
  final double rating;
  final int reviewsCount;
  final String openingHours;
  final List<DiningServiceMode> availableModes;
  final List<MenuItemModel> menu;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.terminalLocation,
    required this.city,
    required this.cuisineType,
    required this.rating,
    required this.reviewsCount,
    required this.openingHours,
    required this.availableModes,
    required this.menu,
  });
}

class DiningOrderItem {
  final MenuItemModel item;
  int quantity;

  DiningOrderItem({
    required this.item,
    this.quantity = 1,
  });

  double get subtotal => item.price * quantity;
}

class DiningOrderModel {
  final String orderId;
  final String restaurantId;
  final String restaurantName;
  final String terminalLocation;
  final DiningServiceMode mode;
  final String? flightNumber;
  final String? gateOrTable;
  final String pickupTime;
  final List<DiningOrderItem> items;
  final double totalAmount;
  final String currency;
  final String status; // preparing, ready_for_pickup, completed, cancelled
  final DateTime orderedAt;

  const DiningOrderModel({
    required this.orderId,
    required this.restaurantId,
    required this.restaurantName,
    required this.terminalLocation,
    required this.mode,
    this.flightNumber,
    this.gateOrTable,
    required this.pickupTime,
    required this.items,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.orderedAt,
  });
}
