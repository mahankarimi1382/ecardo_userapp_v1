import '../models/travel_models.dart';

abstract interface class TravelRepository {
  Future<TravelBootstrap> getBootstrap();

  Future<List<TravelOffer>> searchHotels(TravelHotelSearch search);

  Future<List<TravelOffer>> searchFlights(TravelFlightSearch search);

  Future<List<TravelOffer>> getUpcomingFlights();

  Future<TravelOffer> getOfferDetails(
    TravelProductType type,
    String offerId,
  );

  Future<List<TravelEsimPackage>> getEsimPackages(String destinationCode);

  Future<List<TravelTraveler>> getTravelers();

  Future<TravelTraveler> saveTraveler(TravelTraveler traveler);

  Future<List<TravelOrder>> getOrders();

  Future<List<TravelActivity>> getActivity();

  Future<TravelReservation> createReservation({
    required TravelProductType type,
    required String productId,
    required TravelMoney expectedTotal,
    required String idempotencyKey,
    required TravelBookingDetails bookingDetails,
  });

  Future<TravelOrder> payReservation({
    required TravelReservation reservation,
    required String idempotencyKey,
  });
}
