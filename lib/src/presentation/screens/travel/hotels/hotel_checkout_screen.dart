import 'package:flutter/material.dart';

import '../bookings/travel_checkout_screen.dart';
import '../core/models/travel_models.dart';

/// International-Grade Hotel Checkout Screen (Service T-01)
/// Seamlessly forwards to the unified production [TravelCheckoutScreen]
/// handling guest profiles, special requests, room occupancy, and escrow payment.
class HotelCheckoutScreen extends StatelessWidget {
  final String productId;
  final String hotelTitle;
  final String hotelAddress;
  final TravelMoney total;
  final TravelBookingDetails bookingDetails;
  final int nights;

  const HotelCheckoutScreen({
    super.key,
    required this.productId,
    required this.hotelTitle,
    required this.hotelAddress,
    required this.total,
    required this.bookingDetails,
    required this.nights,
  });

  @override
  Widget build(BuildContext context) {
    return TravelCheckoutScreen(
      type: TravelProductType.hotel,
      productId: productId,
      title: hotelTitle,
      total: total,
      bookingDetails: bookingDetails,
    );
  }
}
