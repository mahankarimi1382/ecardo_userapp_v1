import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';

import '../bookings/travel_checkout_screen.dart';
import '../core/models/travel_models.dart';
import '../shared/travel_theme.dart';

class CipLoungeReservationScreen extends StatefulWidget {
  const CipLoungeReservationScreen({super.key});

  @override
  State<CipLoungeReservationScreen> createState() =>
      _CipLoungeReservationScreenState();
}

class _CipLoungeReservationScreenState
    extends State<CipLoungeReservationScreen> {
  String _selectedAirport = 'IKA';
  String _flightType = 'departure'; // 'departure' or 'arrival'
  final _flightNumberController = TextEditingController(text: 'EK972');
  DateTime _flightDate = DateTime.now().add(const Duration(days: 3));
  TimeOfDay _flightTime = const TimeOfDay(hour: 14, minute: 30);
  int _adultsCount = 1;
  int _childrenCount = 0;
  bool _needPetCare = false;
  bool _needWheelchair = false;
  final _notesController = TextEditingController();

  final Map<String, Map<String, dynamic>> _airportData = {
    'IKA': {
      'name': 'Tehran Imam Khomeini (IKA)',
      'country': 'Iran 🇮🇷',
      'basePriceUsd': 45.0,
      'childPriceUsd': 25.0,
    },
    'DXB': {
      'name': 'Dubai International (DXB)',
      'country': 'UAE 🇦🇪',
      'basePriceUsd': 85.0,
      'childPriceUsd': 45.0,
    },
    'IST': {
      'name': 'Istanbul Airport (IST)',
      'country': 'Turkey 🇹🇷',
      'basePriceUsd': 70.0,
      'childPriceUsd': 40.0,
    },
    'DOH': {
      'name': 'Hamad International Doha (DOH)',
      'country': 'Qatar 🇶🇦',
      'basePriceUsd': 80.0,
      'childPriceUsd': 45.0,
    },
  };

  @override
  void dispose() {
    _flightNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    final airport = _airportData[_selectedAirport]!;
    final basePrice = airport['basePriceUsd'] as double;
    final childPrice = airport['childPriceUsd'] as double;
    return (_adultsCount * basePrice) + (_childrenCount * childPrice);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final airportInfo = _airportData[_selectedAirport]!;

    return Scaffold(
      backgroundColor: TravelTheme.background,
      appBar: AppBar(
        title: Text(
          loc?.travelQuickCipTitle ?? 'Airport CIP & VIP Lounge',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: TravelTheme.textPrimary,
          ),
        ),
        backgroundColor: TravelTheme.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero VIP Banner
            _buildHeroBanner(),
            SizedBox(height: 18.h),

            // Airport Selector
            _buildSectionTitle('Select Airport'),
            SizedBox(height: 8.h),
            _buildAirportSelector(),
            SizedBox(height: 16.h),

            // Flight Type (Departure / Arrival)
            _buildSectionTitle('Flight Type'),
            SizedBox(height: 8.h),
            _buildFlightTypeSelector(),
            SizedBox(height: 16.h),

            // Flight Details Card
            _buildSectionTitle('Flight Information'),
            SizedBox(height: 8.h),
            _buildFlightDetailsCard(),
            SizedBox(height: 16.h),

            // Guest Count Card
            _buildSectionTitle('Guests'),
            SizedBox(height: 8.h),
            _buildGuestsCard(),
            SizedBox(height: 16.h),

            // Included VIP Amenities
            _buildSectionTitle('Included CIP & Lounge Amenities'),
            SizedBox(height: 8.h),
            _buildAmenitiesCard(),
            SizedBox(height: 16.h),

            // Special Assistance Checkboxes
            _buildSectionTitle('Special Assistance'),
            SizedBox(height: 8.h),
            _buildSpecialAssistanceCard(),
            SizedBox(height: 24.h),

            // Price Summary & Reservation CTA
            _buildPriceSummaryCard(airportInfo),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.airline_seat_recline_extra_rounded,
              color: Color(0xFFD4AF37),
              size: 28,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'PREMIUM VIP CIP',
                      style: TextStyle(
                        color: const Color(0xFFD4AF37),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(Icons.star_rounded, color: const Color(0xFFD4AF37), size: 14.sp),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  'Skip queues with dedicated fast-track, private luxury transport & executive lounge dining.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w800,
        color: TravelTheme.textPrimary,
      ),
    );
  }

  Widget _buildAirportSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: TravelTheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: TravelTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAirport,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: TravelTheme.textSecondary),
          items: _airportData.entries.map((e) {
            return DropdownMenuItem<String>(
              value: e.key,
              child: Row(
                children: [
                  Text(e.value['country'].toString(), style: TextStyle(fontSize: 13.sp)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      e.value['name'].toString(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: TravelTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedAirport = val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildFlightTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildTypeOption(
            title: 'Departure (خروجی)',
            icon: Icons.flight_takeoff_rounded,
            isSelected: _flightType == 'departure',
            onTap: () => setState(() => _flightType = 'departure'),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildTypeOption(
            title: 'Arrival (ورودی)',
            icon: Icons.flight_land_rounded,
            isSelected: _flightType == 'arrival',
            onTap: () => setState(() => _flightType = 'arrival'),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOption({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected
              ? TravelTheme.primary.withValues(alpha: 0.08)
              : TravelTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? TravelTheme.primary : TravelTheme.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: isSelected ? TravelTheme.primary : TravelTheme.textSecondary,
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? TravelTheme.primary : TravelTheme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightDetailsCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: TravelTheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: TravelTheme.border),
      ),
      child: Column(
        children: [
          TextField(
            controller: _flightNumberController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Flight Number',
              hintText: 'e.g. EK972, TK875, IR452',
              prefixIcon: const Icon(Icons.flight_rounded, color: TravelTheme.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _flightDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _flightDate = picked);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: TravelTheme.border),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 16, color: TravelTheme.primary),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            DateFormat('yyyy-MM-dd').format(_flightDate),
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _flightTime,
                    );
                    if (picked != null) {
                      setState(() => _flightTime = picked);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: TravelTheme.border),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 16, color: TravelTheme.primary),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            _flightTime.format(context),
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuestsCard() {
    final airport = _airportData[_selectedAirport]!;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: TravelTheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: TravelTheme.border),
      ),
      child: Column(
        children: [
          _buildCounterRow(
            label: 'Adult Guests (12+ yrs)',
            subtitle: '\$${airport['basePriceUsd']} per person',
            value: _adultsCount,
            minValue: 1,
            onChanged: (val) => setState(() => _adultsCount = val),
          ),
          Divider(height: 24.h, color: TravelTheme.border),
          _buildCounterRow(
            label: 'Child Guests (2-12 yrs)',
            subtitle: '\$${airport['childPriceUsd']} per person',
            value: _childrenCount,
            minValue: 0,
            onChanged: (val) => setState(() => _childrenCount = val),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterRow({
    required String label,
    required String subtitle,
    required int value,
    required int minValue,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: TravelTheme.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: TravelTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded),
              color: value > minValue ? TravelTheme.primary : Colors.grey,
              onPressed: value > minValue ? () => onChanged(value - 1) : null,
            ),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: TravelTheme.textPrimary,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              color: TravelTheme.primary,
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenitiesCard() {
    final amenities = [
      {'icon': Icons.security_rounded, 'title': 'Dedicated Passport & Customs'},
      {'icon': Icons.directions_car_rounded, 'title': 'Private Ramp Transfer to Aircraft'},
      {'icon': Icons.restaurant_rounded, 'title': 'Chef Buffet & Beverage Service'},
      {'icon': Icons.wifi_rounded, 'title': 'High-Speed Wi-Fi & Workstation'},
      {'icon': Icons.luggage_rounded, 'title': 'Luggage Check-In & Bag Delivery'},
      {'icon': Icons.child_care_rounded, 'title': 'Kids Play Area & Quiet Suites'},
    ];

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: TravelTheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: TravelTheme.border),
      ),
      child: Column(
        children: amenities.map((item) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Row(
              children: [
                Icon(
                  item['icon'] as IconData,
                  size: 16.sp,
                  color: AppColors.success,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    item['title'] as String,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: TravelTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSpecialAssistanceCard() {
    return Material(
      color: TravelTheme.surface,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: TravelTheme.border),
        ),
        child: Column(
          children: [
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Wheelchair / Mobility Assistance', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
              value: _needWheelchair,
              activeColor: TravelTheme.primary,
              onChanged: (val) => setState(() => _needWheelchair = val ?? false),
            ),
            Divider(height: 1, color: TravelTheme.border),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Pet Travel Reception Assistance', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
              value: _needPetCare,
              activeColor: TravelTheme.primary,
              onChanged: (val) => setState(() => _needPetCare = val ?? false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummaryCard(Map<String, dynamic> airportInfo) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: TravelTheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: TravelTheme.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: TravelTheme.primary.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Guests: ${_adultsCount + _childrenCount}',
                style: TextStyle(fontSize: 12.sp, color: TravelTheme.textSecondary, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Text(
                    '\$${_totalPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: TravelTheme.primary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'USD',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: TravelTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          CommonButton(
            width: double.infinity,
            text: 'Reserve CIP Lounge Service',
            onPressed: () {
              HapticFeedback.selectionClick();
              _onReserveTap();
            },
          ),
        ],
      ),
    );
  }

  void _onReserveTap() {
    final flightNumber = _flightNumberController.text.trim();
    if (flightNumber.isEmpty) {
      ToastHelper().showErrorToast('Please enter your flight number');
      return;
    }

    final airport = _airportData[_selectedAirport]!;
    final bookingDetails = TravelBookingDetails(
      adultCount: _adultsCount,
      childCount: _childrenCount,
      cabinClass: 'VIP CIP Lounge',
      specialRequests: 'Airport: ${airport['name']} ($_flightType), Flight: $flightNumber, Date: ${DateFormat('yyyy-MM-dd').format(_flightDate)} ${_flightTime.format(context)}, Wheelchair: $_needWheelchair, Pet: $_needPetCare',
    );

    Get.to(
      () => TravelCheckoutScreen(
        type: TravelProductType.flight,
        productId: 'cip_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Airport CIP Lounge (${airport['name']})',
        total: TravelMoney(amount: _totalPrice, currency: 'USD'),
        bookingDetails: bookingDetails,
      ),
    );
  }
}
