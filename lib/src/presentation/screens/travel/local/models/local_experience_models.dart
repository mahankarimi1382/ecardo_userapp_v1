enum LocalServiceType {
  tourGuide,
  photographer,
  chauffeur,
  meetAndGreet,
  translator,
}

class LocalExperienceItemModel {
  final String id;
  final String title;
  final String subtitle;
  final String providerName;
  final String city;
  final LocalServiceType type;
  final double price;
  final String currency;
  final String durationLabel;
  final List<String> languages;
  final double rating;
  final int reviewsCount;
  final List<String> highlights;
  final String meetingPoint;
  final String description;

  const LocalExperienceItemModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.providerName,
    required this.city,
    required this.type,
    required this.price,
    required this.currency,
    required this.durationLabel,
    required this.languages,
    required this.rating,
    required this.reviewsCount,
    required this.highlights,
    required this.meetingPoint,
    required this.description,
  });

  String get typeLabel {
    switch (type) {
      case LocalServiceType.tourGuide:
        return 'راهنمای تور محلی (Tour Guide)';
      case LocalServiceType.photographer:
        return 'عکاس حرفه‌ای سفر (Photographer)';
      case LocalServiceType.chauffeur:
        return 'راننده منتسب اختصاصی (Chauffeur)';
      case LocalServiceType.meetAndGreet:
        return 'همراهی فرودگاه (Meet & Greet)';
      case LocalServiceType.translator:
        return 'مترجم همزمان تجاری (Interpreter)';
    }
  }
}

class LocalBookingModel {
  final String bookingId;
  final String serviceId;
  final String serviceTitle;
  final String providerName;
  final String city;
  final DateTime serviceDate;
  final String serviceTime;
  final int guestsCount;
  final double totalAmount;
  final String currency;
  final String meetingPoint;
  final String providerPhone;
  final String status; // confirmed, active, completed, cancelled
  final DateTime bookedAt;

  const LocalBookingModel({
    required this.bookingId,
    required this.serviceId,
    required this.serviceTitle,
    required this.providerName,
    required this.city,
    required this.serviceDate,
    required this.serviceTime,
    required this.guestsCount,
    required this.totalAmount,
    required this.currency,
    required this.meetingPoint,
    required this.providerPhone,
    required this.status,
    required this.bookedAt,
  });
}
