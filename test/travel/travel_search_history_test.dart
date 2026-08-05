import 'package:flutter_test/flutter_test.dart';
import 'package:qunzo_user/src/presentation/screens/travel/core/models/travel_models.dart';

void main() {
  test('hotel search history preserves backend request criteria', () {
    final search = TravelHotelSearch(
      city: 'THR',
      checkInDate: DateTime(2026, 8, 10),
      checkOutDate: DateTime(2026, 8, 13),
      roomCount: 2,
      adultCount: 3,
      childCount: 1,
    );

    final restored = TravelHotelSearch.fromJson(search.toJson());

    expect(restored.city, 'THR');
    expect(restored.checkInDate, DateTime(2026, 8, 10));
    expect(restored.checkOutDate, DateTime(2026, 8, 13));
    expect(restored.roomCount, 2);
    expect(restored.adultCount, 3);
    expect(restored.childCount, 1);
  });

  test('flight search history preserves route and passenger criteria', () {
    final search = TravelFlightSearch(
      origin: 'THR',
      destination: 'MHD',
      departureDate: DateTime(2026, 8, 12),
      returnDate: DateTime(2026, 8, 19),
      adultCount: 2,
      childCount: 1,
      infantCount: 1,
      cabinClass: 'economy',
    );

    final restored = TravelFlightSearch.fromJson(search.toJson());

    expect(restored.origin, 'THR');
    expect(restored.destination, 'MHD');
    expect(restored.departureDate, DateTime(2026, 8, 12));
    expect(restored.returnDate, DateTime(2026, 8, 19));
    expect(restored.adultCount, 2);
    expect(restored.childCount, 1);
    expect(restored.infantCount, 1);
    expect(restored.cabinClass, 'economy');
  });
}
