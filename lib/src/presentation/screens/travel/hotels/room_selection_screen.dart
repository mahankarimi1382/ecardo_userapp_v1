import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../core/models/travel_models.dart';
import '../shared/travel_widgets.dart';
import 'hotel_checkout_screen.dart';
import 'hotel_search_components.dart';
import 'widgets/hotel_room_selection_card.dart';
import 'widgets/cancellation_policy_timeline.dart';

/// Comprehensive Room Selection Screen showing detailed grid of rooms with bed types,
/// occupancy limits, breakfast inclusion, price per night × nights breakdown.
class RoomSelectionScreen extends StatefulWidget {
  final TravelOffer hotelOffer;
  final String? initialSelectedRoomId;

  const RoomSelectionScreen({
    super.key,
    required this.hotelOffer,
    this.initialSelectedRoomId,
  });

  @override
  State<RoomSelectionScreen> createState() => _RoomSelectionScreenState();
}

class _RoomSelectionScreenState extends State<RoomSelectionScreen> {
  final Map<String, int> _selectedRoomQuantities = {};
  final bool _isLoading = false;

  List<Map<String, dynamic>> get _rooms => _providerMaps(widget.hotelOffer.product['rooms']);
  double get _nights => _calculateNights();

  double _calculateNights() {
    final controller = ensureTravelController();
    final bookingDetails = controller.hotelBookingDetails.value;
    if (bookingDetails.checkInDate == null || bookingDetails.checkOutDate == null) {
      return 1;
    }
    return bookingDetails.checkOutDate!
        .difference(bookingDetails.checkInDate!)
        .inDays
        .clamp(1, 365)
        .toDouble();
  }

  List<TravelSelectedRoom> _getSelectedRooms() {
    return _rooms
        .map((room) {
          final id = room['room_id']?.toString() ?? '';
          final quantity = _selectedRoomQuantities[id] ?? 0;
          if (id.isEmpty || quantity <= 0) return null;
          return TravelSelectedRoom(
            id: id,
            name: travelBackendText(context, room['room_name'] ?? room['name']),
            quantity: quantity,
            unitPrice: double.tryParse(room['price']?.toString() ?? '') ?? 0,
            currency: room['currency']?.toString() ?? widget.hotelOffer.total.currency,
          );
        })
        .whereType<TravelSelectedRoom>()
        .toList();
  }

  double _calculateTotalPrice() {
    var total = 0.0;
    for (final room in _rooms) {
      final id = room['room_id']?.toString() ?? '';
      final quantity = _selectedRoomQuantities[id] ?? 0;
      final price = double.tryParse(room['price']?.toString() ?? '') ?? 0;
      if (quantity > 0 && price > 0) {
        total += price * quantity * _nights.toInt();
      }
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set initial selection if provided
      final controller = ensureTravelController();
      final details = controller.hotelBookingDetails.value;
      if (widget.initialSelectedRoomId != null && details.roomId != widget.initialSelectedRoomId) {
        setState(() {
          _selectedRoomQuantities[details.roomId.isNotEmpty ? details.roomId : widget.initialSelectedRoomId!] = details.roomCount > 0 ? details.roomCount : 1;
        });
      } else if (widget.initialSelectedRoomId != null) {
        setState(() {
          _selectedRoomQuantities[widget.initialSelectedRoomId!] = 1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return TravelPage(
      title: l10nPick(context, en: 'Select Rooms', fa: 'انتخاب اتاق‌ها', ar: 'اختيار الغرف', zh: '选择房间'),
      child: Container(
        color: ECardoTokens.surfaceCanvas(context),
        child: CustomScrollView(
          slivers: [
            // Sticky Header with Hotel Info & Night Count
            SliverAppBar(
              expandedHeight: 140.h,
              pinned: true,
              backgroundColor: ECardoTokens.brand900(context),
              flexibleSpace: FlexibleSpaceBar(
                title: TravelBidiText(
                  travelLocalizedKey(AppLocalizations.of(context)!, widget.hotelOffer.titleKey),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: ECardoTokens.inkOnBrand,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Fallback gradient if no image
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ECardoTokens.brand900(context),
                            ECardoTokens.brand700(context),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20.h,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.date_range_rounded,
                                size: 18.sp,
                                color: ECardoTokens.inkOnBrand.withValues(alpha: 0.8),
                              ),
                              SizedBox(width: 8.w),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  '$_nights ${AppLocalizations.of(context)!.hotel_nights}',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: ECardoTokens.inkOnBrand,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  iconSize: 24.sp,
                  onPressed: () async {
                    await showHotelDateRangePicker(
                      context,
                      initialStart: DateTime.now().add(const Duration(days: 30)),
                      initialEnd: DateTime.now().add(const Duration(days: 32)),
                    );
                    setState(() {});
                  },
                  icon: Icon(Icons.edit_calendar_outlined, color: ECardoTokens.inkOnBrand),
                ),
              ],
            ),

            // Content Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cancellation Policy Summary
                    Semantics(
                      label: 'Cancellation policy summary',
                      child: CancellationPolicyTimelineCard(
                        checkInDate: ensureTravelController().hotelBookingDetails.value.checkInDate,
                        customPolicySummary: _providerCancellationSummary(
                          context,
                          widget.hotelOffer.product,
                        ),
                        onTap: null,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Room Options Grid
                    Text(
                      isRtl ? 'انتخاب اتاق‌های مناسب' : 'Select Your Rooms',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_rooms.isEmpty)
                      TravelEmptyState(
                        icon: Icons.bed_rounded,
                        title: l10nPick(context, en: 'No Rooms Available', fa: 'اتاقی موجود نیست', ar: 'لا توجد غرف متاحة', zh: '无可用房间'),
                        message: l10nPick(context, en: 'Try different dates', fa: 'تاریخ‌های متفاوت را امتحان کنید', ar: 'جرب تواريخ مختلفة', zh: '尝试不同日期'),
                      )
                    else
                      ..._rooms.map((room) {
                        final roomId = room['room_id']?.toString() ?? '';
                        final qty = _selectedRoomQuantities[roomId] ?? 0;

                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            child: HotelRoomSelectionCard(
                              room: room,
                              enabled: true,
                              nights: _nights.toInt(),
                              quantity: qty,
                              onQuantityChanged: (quantity) => setState(() {
                                _selectedRoomQuantities[roomId] = quantity;
                              }),
                            ),
                          ),
                        );
                      }),

                    // Price Summary Card
                    if (_getSelectedRooms().isNotEmpty) ...[
                      SizedBox(height: 20.h),
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: ECardoTokens.surfaceCard(context),
                          borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
                          border: Border.all(color: ECardoTokens.border(context)),
                          boxShadow: ECardoTokens.shadowCard(context),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isRtl ? 'خلاصه قیمت' : 'Price Summary',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w900,
                                color: ECardoTokens.ink(context),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            ..._getSelectedRooms().map((room) {
                              final roomQtyStr = '${room.quantity} x ${l10nPick(context, en: 'night', fa: 'شب', ar: 'ليلة', zh: '晚')}';
                              final totalPriceStr = travelMoney(context, TravelMoney(amount: room.unitPrice * room.quantity * _nights.toInt(), currency: room.currency));

                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 6.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '$roomQtyStr - ${travelBackendText(context, room.name)}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: ECardoTokens.inkMuted(context),
                                        ),
                                      ),
                                    ),
                                    Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Text(
                                        totalPriceStr,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w800,
                                          color: ECardoTokens.brand700(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            Divider(color: ECardoTokens.border(context), height: 20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isRtl ? 'مجموع کل برای $_nights شب:' : 'Total for $_nights nights:',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w900,
                                    color: ECardoTokens.ink(context),
                                  ),
                                ),
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    travelMoney(context, TravelMoney(amount: _calculateTotalPrice(), currency: _getSelectedRooms().firstOrNull?.currency ?? widget.hotelOffer.total.currency)),
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w900,
                                      color: ECardoTokens.brand700(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              isRtl ? 'شامل مالیات و عوارض' : 'Includes taxes & fees',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: ECardoTokens.inkMuted(context),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Continue Button
                      CommonButton(
                        width: double.infinity,
                        height: 52,
                        text: l10nPick(context, en: 'Continue Booking', fa: 'ادامه رزرو', ar: 'متابعة الحجز', zh: '继续预订'),
                        backgroundColor: ECardoTokens.brand900(context),
                        isLoading: _isLoading,
                        onPressed: () {
                          final selectedRooms = _getSelectedRooms();
                          if (selectedRooms.isEmpty) {
                            showTravelMessage(
                              context,
                              title: l10nPick(context, en: 'Select Rooms', fa: 'انتخاب اتاق‌ها', ar: 'اختيار الغرف', zh: '选择房间'),
                              message: l10nPick(context, en: 'Please select at least one room', fa: 'لطفاً حداقل یک اتاق را انتخاب کنید', ar: 'يرجى اختيار غرفة واحدة على الأقل', zh: '请至少选择一间房间'),
                            );
                            return;
                          }

                          final bookingDetails = ensureTravelController().hotelBookingDetails.value;

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => HotelCheckoutScreen(
                                productId: widget.hotelOffer.id,
                                hotelTitle: travelLocalizedKey(AppLocalizations.of(context)!, widget.hotelOffer.titleKey),
                                hotelAddress: widget.hotelOffer.attributes['address']?.toString() ?? '',
                                total: TravelMoney(
                                  amount: _calculateTotalPrice(),
                                  currency: selectedRooms.first.currency,
                                ),
                                bookingDetails: bookingDetails.copyWith(
                                  roomId: selectedRooms.first.id,
                                  roomName: selectedRooms.first.name,
                                  roomCount: selectedRooms.fold<int>(0, (sum, r) => sum + r.quantity),
                                  selectedRooms: selectedRooms,
                                ),
                                nights: _nights.toInt(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Map<String, dynamic>> _providerMaps(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
}

String _providerCancellationSummary(BuildContext context, Map<String, dynamic> source) {
  const keys = ['cancellation_policy', 'cancellation', 'refund_policy'];
  for (final key in keys) {
    final value = travelBackendValue(context, source[key]).trim();
    if (value.isNotEmpty) return value;
  }
  return '';
}
