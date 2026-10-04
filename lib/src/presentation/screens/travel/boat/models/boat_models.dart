enum BoatCategory {
  yacht,
  catamaran,
  speedboat,
  diving,
  jetski,
}

class BoatAddon {
  final String id;
  final String title;
  final double price;
  final String unit;
  final String icon;

  const BoatAddon({
    required this.id,
    required this.title,
    required this.price,
    required this.unit,
    required this.icon,
  });
}

class BoatExperienceModel {
  final String id;
  final String title;
  final String marinaName;
  final String city;
  final BoatCategory category;
  final double hourlyRate;
  final String currency;
  final int maxPassengers;
  final double lengthMeters;
  final double rating;
  final int reviewsCount;
  final String captainName;
  final List<String> images;
  final List<String> features; // sound system, air conditioning, sun deck, etc.
  final List<String> availableSlots; // e.g., '10:00 - 12:00', '16:00 - 18:00 (Sunset)'
  final List<BoatAddon> addons;
  final String description;

  const BoatExperienceModel({
    required this.id,
    required this.title,
    required this.marinaName,
    required this.city,
    required this.category,
    required this.hourlyRate,
    required this.currency,
    required this.maxPassengers,
    required this.lengthMeters,
    required this.rating,
    required this.reviewsCount,
    required this.captainName,
    required this.images,
    required this.features,
    required this.availableSlots,
    required this.addons,
    required this.description,
  });

  String get categoryLabel {
    switch (category) {
      case BoatCategory.yacht:
        return 'یویات لوکس (Luxury Yacht)';
      case BoatCategory.catamaran:
        return 'کاتاماران (Catamaran)';
      case BoatCategory.speedboat:
        return 'قایق تندرو (Speedboat)';
      case BoatCategory.diving:
        return 'غواصی و ماهیگیری (Diving)';
      case BoatCategory.jetski:
        return 'جت‌اسکی (Jet Ski)';
    }
  }
}

class BoatBookingModel {
  final String bookingId;
  final String boatId;
  final String boatTitle;
  final String marinaName;
  final DateTime date;
  final String timeSlot;
  final int durationHours;
  final int passengersCount;
  final List<String> selectedAddonIds;
  final double totalAmount;
  final String currency;
  final String captainPhone;
  final String pierDockNumber;
  final String status; // confirmed, active, completed, cancelled
  final DateTime bookedAt;

  const BoatBookingModel({
    required this.bookingId,
    required this.boatId,
    required this.boatTitle,
    required this.marinaName,
    required this.date,
    required this.timeSlot,
    required this.durationHours,
    required this.passengersCount,
    required this.selectedAddonIds,
    required this.totalAmount,
    required this.currency,
    required this.captainPhone,
    required this.pierDockNumber,
    required this.status,
    required this.bookedAt,
  });
}
