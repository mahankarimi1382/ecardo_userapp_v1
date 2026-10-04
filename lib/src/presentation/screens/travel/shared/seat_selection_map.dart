import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import 'travel_theme.dart';

// ---------------------------------------------------------------------------
// Enums & Models
// ---------------------------------------------------------------------------

enum SeatType {
  window,
  aisle,
  middle;

  String localizedLabel(bool isRtl) {
    switch (this) {
      case SeatType.window:
        return isRtl ? 'پنجره' : 'Window';
      case SeatType.aisle:
        return isRtl ? 'راهرو' : 'Aisle';
      case SeatType.middle:
        return isRtl ? 'وسط' : 'Middle';
    }
  }
}

enum SeatCabinClass {
  economy,
  business;

  String localizedLabel(bool isRtl) {
    switch (this) {
      case SeatCabinClass.business:
        return isRtl ? 'کلاس بیزینس' : 'Business Class';
      case SeatCabinClass.economy:
        return isRtl ? 'کلاس اقتصادی' : 'Economy Class';
    }
  }
}

enum SeatStatus {
  available,
  reserved,
  selected,
  premium;

  String localizedLabel(bool isRtl) {
    switch (this) {
      case SeatStatus.available:
        return isRtl ? 'در دسترس' : 'Available';
      case SeatStatus.reserved:
        return isRtl ? 'رزرو شده' : 'Reserved';
      case SeatStatus.selected:
        return isRtl ? 'انتخاب شده' : 'Selected';
      case SeatStatus.premium:
        return isRtl ? 'فضای پای بیشتر' : 'Extra Legroom';
    }
  }
}

enum SeatVehicleType {
  aircraft,
  train;

  String localizedLabel(bool isRtl) {
    switch (this) {
      case SeatVehicleType.aircraft:
        return isRtl ? 'هواپیما' : 'Aircraft';
      case SeatVehicleType.train:
        return isRtl ? 'قطار' : 'Train';
    }
  }
}

class SeatItem {
  final String id;
  final int row;
  final String column;
  final SeatType type;
  final SeatCabinClass cabinClass;
  final SeatStatus status;
  final double extraPrice;

  const SeatItem({
    required this.id,
    required this.row,
    required this.column,
    required this.type,
    required this.cabinClass,
    required this.status,
    this.extraPrice = 0.0,
  });

  String get code => '$row$column';
  bool get isAvailable => status == SeatStatus.available;
  bool get isReserved => status == SeatStatus.reserved;
  bool get isSelected => status == SeatStatus.selected;
  bool get isPremium => status == SeatStatus.premium;
  bool get isSelectable => status != SeatStatus.reserved;

  SeatItem copyWith({
    String? id,
    int? row,
    String? column,
    SeatType? type,
    SeatCabinClass? cabinClass,
    SeatStatus? status,
    double? extraPrice,
  }) {
    return SeatItem(
      id: id ?? this.id,
      row: row ?? this.row,
      column: column ?? this.column,
      type: type ?? this.type,
      cabinClass: cabinClass ?? this.cabinClass,
      status: status ?? this.status,
      extraPrice: extraPrice ?? this.extraPrice,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'row': row,
    'column': column,
    'type': type.name,
    'cabinClass': cabinClass.name,
    'status': status.name,
    'extraPrice': extraPrice,
  };

  factory SeatItem.fromJson(Map<String, dynamic> json) {
    return SeatItem(
      id: json['id']?.toString() ?? '',
      row: (json['row'] as num?)?.toInt() ?? 1,
      column: json['column']?.toString() ?? 'A',
      type: SeatType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SeatType.middle,
      ),
      cabinClass: SeatCabinClass.values.firstWhere(
        (e) => e.name == json['cabinClass'],
        orElse: () => SeatCabinClass.economy,
      ),
      status: SeatStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SeatStatus.available,
      ),
      extraPrice: (json['extraPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() => 'SeatItem($code, ${cabinClass.name}, ${status.name}, extraPrice: $extraPrice)';
}

// ---------------------------------------------------------------------------
// Default Mock Seat Layout Generator
// ---------------------------------------------------------------------------

class SeatMapDefaults {
  static List<SeatItem> generateSeats({
    SeatVehicleType vehicleType = SeatVehicleType.aircraft,
  }) {
    final seats = <SeatItem>[];

    if (vehicleType == SeatVehicleType.aircraft) {
      // ----------------- Aircraft Layout -----------------
      // Business Class: Rows 1 to 4 (2-2 Layout: A, C [Aisle] D, F)
      const businessCols = ['A', 'C', 'D', 'F'];
      const reservedBusiness = {'1C', '2A', '3D', '4F'};

      for (var row = 1; row <= 4; row++) {
        for (final col in businessCols) {
          final id = '$row$col';
          final isReserved = reservedBusiness.contains(id);
          final isPremium = row == 1; // Row 1 Bulkhead
          final type = (col == 'A' || col == 'F')
              ? SeatType.window
              : SeatType.aisle;

          seats.add(
            SeatItem(
              id: id,
              row: row,
              column: col,
              type: type,
              cabinClass: SeatCabinClass.business,
              status: isReserved
                  ? SeatStatus.reserved
                  : isPremium
                      ? SeatStatus.premium
                      : SeatStatus.available,
              extraPrice: isPremium ? 45.0 : 30.0,
            ),
          );
        }
      }

      // Economy Class: Rows 5 to 22 (3-3 Layout: A, B, C [Aisle] D, E, F)
      const economyCols = ['A', 'B', 'C', 'D', 'E', 'F'];
      const reservedEconomy = {
        '6B', '6C', '7A', '8D', '8E', '9F', '10B', '11C',
        '12A', '14D', '15B', '16E', '17F', '18A', '19C', '20D', '21B', '22E',
      };

      for (var row = 5; row <= 22; row++) {
        for (final col in economyCols) {
          final id = '$row$col';
          final isReserved = reservedEconomy.contains(id);
          // Row 5 (Bulkhead) and Row 12 (Exit Row) are Premium with extra legroom
          final isPremium = (row == 5 || row == 12);
          final type = (col == 'A' || col == 'F')
              ? SeatType.window
              : (col == 'C' || col == 'D')
                  ? SeatType.aisle
                  : SeatType.middle;

          seats.add(
            SeatItem(
              id: id,
              row: row,
              column: col,
              type: type,
              cabinClass: SeatCabinClass.economy,
              status: isReserved
                  ? SeatStatus.reserved
                  : isPremium
                      ? SeatStatus.premium
                      : SeatStatus.available,
              extraPrice: isPremium
                  ? (row == 5 ? 25.0 : 20.0)
                  : (type == SeatType.window ? 5.0 : 0.0),
            ),
          );
        }
      }
    } else {
      // ----------------- Train Layout -----------------
      // VIP / First Class: Rows 1 to 4 (2-2 Layout: A, B [Aisle] C, D)
      const trainVipCols = ['A', 'B', 'C', 'D'];
      const reservedTrainVip = {'1B', '2C', '3A'};

      for (var row = 1; row <= 4; row++) {
        for (final col in trainVipCols) {
          final id = '$row$col';
          final isReserved = reservedTrainVip.contains(id);
          final isPremium = row == 1;
          final type = (col == 'A' || col == 'D')
              ? SeatType.window
              : SeatType.aisle;

          seats.add(
            SeatItem(
              id: id,
              row: row,
              column: col,
              type: type,
              cabinClass: SeatCabinClass.business,
              status: isReserved
                  ? SeatStatus.reserved
                  : isPremium
                      ? SeatStatus.premium
                      : SeatStatus.available,
              extraPrice: isPremium ? 25.0 : 15.0,
            ),
          );
        }
      }

      // Coupe / Economy: Rows 5 to 16 (3-3 Layout: A, B, C [Aisle] D, E, F)
      const trainEcoCols = ['A', 'B', 'C', 'D', 'E', 'F'];
      const reservedTrainEco = {
        '5B', '6D', '7A', '8E', '9F', '10C', '11B', '12E', '14A', '15D', '16B',
      };

      for (var row = 5; row <= 16; row++) {
        for (final col in trainEcoCols) {
          final id = '$row$col';
          final isReserved = reservedTrainEco.contains(id);
          final isPremium = (row == 5 || row == 10);
          final type = (col == 'A' || col == 'F')
              ? SeatType.window
              : (col == 'C' || col == 'D')
                  ? SeatType.aisle
                  : SeatType.middle;

          seats.add(
            SeatItem(
              id: id,
              row: row,
              column: col,
              type: type,
              cabinClass: SeatCabinClass.economy,
              status: isReserved
                  ? SeatStatus.reserved
                  : isPremium
                      ? SeatStatus.premium
                      : SeatStatus.available,
              extraPrice: isPremium ? 12.0 : 0.0,
            ),
          );
        }
      }
    }

    return seats;
  }
}

// ---------------------------------------------------------------------------
// SeatSelectionMap Widget
// ---------------------------------------------------------------------------

class SeatSelectionMap extends StatefulWidget {
  final SeatVehicleType vehicleType;
  final SeatCabinClass initialCabinClass;
  final int maxSelectedSeats;
  final List<SeatItem>? initialSeats;
  final List<String> initiallySelectedSeatIds;
  final String currency;
  final ValueChanged<List<SeatItem>>? onSelectionChanged;
  final ValueChanged<List<SeatItem>>? onConfirmed;

  const SeatSelectionMap({
    super.key,
    this.vehicleType = SeatVehicleType.aircraft,
    this.initialCabinClass = SeatCabinClass.economy,
    this.maxSelectedSeats = 1,
    this.initialSeats,
    this.initiallySelectedSeatIds = const [],
    this.currency = 'USD',
    this.onSelectionChanged,
    this.onConfirmed,
  });

  @override
  State<SeatSelectionMap> createState() => _SeatSelectionMapState();
}

class _SeatSelectionMapState extends State<SeatSelectionMap> {
  late SeatCabinClass _activeCabin;
  late List<SeatItem> _allSeats;
  final Set<String> _selectedSeatIds = {};

  @override
  void initState() {
    super.initState();
    _activeCabin = widget.initialCabinClass;
    _allSeats = widget.initialSeats ??
        SeatMapDefaults.generateSeats(vehicleType: widget.vehicleType);
    _selectedSeatIds.addAll(widget.initiallySelectedSeatIds);
  }

  List<SeatItem> get _selectedSeats =>
      _allSeats.where((s) => _selectedSeatIds.contains(s.id)).toList();

  double get _totalExtraFees => _selectedSeats.fold(
        0.0,
        (sum, item) => sum + item.extraPrice,
      );

  void _handleSeatTap(SeatItem seat) {
    if (seat.isReserved) {
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.selectionClick();

    setState(() {
      if (_selectedSeatIds.contains(seat.id)) {
        _selectedSeatIds.remove(seat.id);
      } else {
        if (widget.maxSelectedSeats == 1) {
          _selectedSeatIds.clear();
          _selectedSeatIds.add(seat.id);
        } else if (_selectedSeatIds.length < widget.maxSelectedSeats) {
          _selectedSeatIds.add(seat.id);
        } else {
          // Reached limit
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10nPick(
                  context,
                  en: 'You can only select up to ${widget.maxSelectedSeats} seats.',
                  fa: 'حداکثر می‌توانید ${widget.maxSelectedSeats} صندلی انتخاب کنید.',
                  ar: 'يمكنك اختيار ما يصل إلى ${widget.maxSelectedSeats} مقاعد فقط.',
                ),
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }
    });

    widget.onSelectionChanged?.call(_selectedSeats);
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final cabinSeats =
        _allSeats.where((s) => s.cabinClass == _activeCabin).toList();

    // Group seats by row
    final Map<int, List<SeatItem>> seatsByRow = {};
    for (final seat in cabinSeats) {
      seatsByRow.putIfAbsent(seat.row, () => []).add(seat);
    }
    final sortedRows = seatsByRow.keys.toList()..sort();

    return Column(
      children: [
        // 1. Cabin Class Selector Tabs
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: _CabinClassTabs(
            activeCabin: _activeCabin,
            isRtl: isRtl,
            onChanged: (cabin) => setState(() => _activeCabin = cabin),
          ),
        ),

        // 2. Legend Row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: _SeatLegendRow(isRtl: isRtl),
        ),

        // 3. Scrollable Cabin Fuselage & Seats
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 20.h),
            children: [
              // Vehicle Nose Indicator
              _VehicleNoseHeader(
                vehicleType: widget.vehicleType,
                isRtl: isRtl,
              ),

              SizedBox(height: 14.h),

              // Fuselage Body with Cabin Walls & Seats
              Container(
                decoration: BoxDecoration(
                  color: TravelTheme.cardSurfaceFor(context),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: TravelTheme.borderFor(context), width: 1.5.w),
                  boxShadow: TravelTheme.shadowFor(context),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                child: Column(
                  children: [
                    // Column Headers (A, B, C [Aisle] D, E, F)
                    _ColumnHeaders(
                      cabinClass: _activeCabin,
                      isRtl: isRtl,
                    ),

                    SizedBox(height: 10.h),
                    Divider(height: 1, color: TravelTheme.borderFor(context)),
                    SizedBox(height: 10.h),

                    // Rows
                    ...sortedRows.map((rowNum) {
                      final rowSeats = seatsByRow[rowNum] ?? [];
                      final isExitRow = (rowNum == 12);

                      return _SeatRowWidget(
                        rowNum: rowNum,
                        seats: rowSeats,
                        cabinClass: _activeCabin,
                        selectedSeatIds: _selectedSeatIds,
                        isExitRow: isExitRow,
                        isRtl: isRtl,
                        onSeatTap: _handleSeatTap,
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 4. Floating / Bottom Summary Bar
        _SeatSummaryBar(
          selectedSeats: _selectedSeats,
          maxSeats: widget.maxSelectedSeats,
          totalExtraFees: _totalExtraFees,
          currency: widget.currency,
          isRtl: isRtl,
          onConfirm: () => widget.onConfirmed?.call(_selectedSeats),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Cabin Class Selector Tabs
// ---------------------------------------------------------------------------

class _CabinClassTabs extends StatelessWidget {
  final SeatCabinClass activeCabin;
  final bool isRtl;
  final ValueChanged<SeatCabinClass> onChanged;

  const _CabinClassTabs({
    required this.activeCabin,
    required this.isRtl,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = TravelTheme.isDark(context);
    final tabsBg = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F3F5);

    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: tabsBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabButton(
              context: context,
              title: isRtl ? 'کلاس بیزینس (۲-۲)' : 'Business (2-2)',
              subtitle: isRtl ? 'صندلی‌های عریض‌تر' : 'Wide Recliner',
              icon: Icons.airline_seat_flat_rounded,
              isActive: activeCabin == SeatCabinClass.business,
              onTap: () => onChanged(SeatCabinClass.business),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: _tabButton(
              context: context,
              title: isRtl ? 'کلاس اقتصادی (۳-۳)' : 'Economy (3-3)',
              subtitle: isRtl ? 'کابین اصلی' : 'Main Cabin',
              icon: Icons.airline_seat_recline_normal_rounded,
              isActive: activeCabin == SeatCabinClass.economy,
              onTap: () => onChanged(SeatCabinClass.economy),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final activeBg = TravelTheme.cardSurfaceFor(context);
    final textPrimary = TravelTheme.textPrimaryFor(context);
    final textSecondary = TravelTheme.textSecondaryFor(context);
    final brandColor = TravelTheme.primaryFor(context);

    return Material(
      color: isActive ? activeBg : Colors.transparent,
      borderRadius: BorderRadius.circular(12.r),
      elevation: isActive ? 2 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 16.r,
                    color: isActive ? textPrimary : textSecondary,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                      color: isActive ? textPrimary : textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isActive
                      ? brandColor
                      : textSecondary.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seat Legend Row
// ---------------------------------------------------------------------------

class _SeatLegendRow extends StatelessWidget {
  final bool isRtl;

  const _SeatLegendRow({required this.isRtl});

  @override
  Widget build(BuildContext context) {
    final isDark = TravelTheme.isDark(context);
    final borderColor = TravelTheme.borderFor(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: TravelTheme.backgroundFor(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem(
            context: context,
            label: isRtl ? 'در دسترس' : 'Available',
            child: Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: TravelTheme.cardSurfaceFor(context),
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: borderColor, width: 1.2.w),
              ),
            ),
          ),
          _legendItem(
            context: context,
            label: isRtl ? 'انتخاب شده' : 'Selected',
            child: Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: TravelTheme.primaryFor(context),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: const Icon(Icons.check_rounded, size: 12, color: AppColors.white),
            ),
          ),
          _legendItem(
            context: context,
            label: isRtl ? 'رزرو شده' : 'Reserved',
            child: Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFE4E7EB),
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: isDark ? borderColor : const Color(0xFFD0D5DD)),
              ),
              child: Icon(Icons.close_rounded, size: 12, color: TravelTheme.textSecondaryFor(context)),
            ),
          ),
          _legendItem(
            context: context,
            label: isRtl ? 'فضای پا' : 'Legroom',
            child: Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF332A00) : const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: const Color(0xFFF2C94C), width: 1.3.w),
              ),
              child: const Icon(Icons.star_rounded, size: 12, color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem({
    required BuildContext context,
    required String label,
    required Widget child,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        SizedBox(width: 5.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w600,
            color: TravelTheme.textPrimaryFor(context),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Vehicle Nose Header (Airplane Nose / Train Engine)
// ---------------------------------------------------------------------------

class _VehicleNoseHeader extends StatelessWidget {
  final SeatVehicleType vehicleType;
  final bool isRtl;

  const _VehicleNoseHeader({
    required this.vehicleType,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = TravelTheme.isDark(context);
    final airGradient = isDark
        ? [const Color(0xFF1E2E42), AppColors.darkSurface]
        : const [Color(0xFFE2EDFC), Color(0xFFF4F7FB)];
    final trainGradient = isDark
        ? [const Color(0xFF1A3828), AppColors.darkSurface]
        : const [Color(0xFFE0F2E9), Color(0xFFF2F9F5)];
    final frontIndicatorColor = isDark
        ? AppColors.darkSurfaceVariant
        : const Color(0xFFF4F7FB);
    final trainIndicatorColor = isDark
        ? AppColors.darkSurfaceVariant
        : const Color(0xFFF2F9F5);

    if (vehicleType == SeatVehicleType.aircraft) {
      return Center(
        child: SizedBox(
          width: 240.w,
          child: Column(
            children: [
              // Curved Airplane Nose Cone
              Container(
                height: 48.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: airGradient,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(50.r),
                  ),
                  border: Border.all(color: TravelTheme.blue.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Cockpit Windows
                      _cockpitWindow(isDark),
                      SizedBox(width: 8.w),
                      _cockpitWindow(isDark),
                    ],
                  ),
                ),
              ),
              // Front indicator & Emergency Exits
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                color: frontIndicatorColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _exitBadge(left: true, isDark: isDark),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          size: 14.r,
                          color: TravelTheme.primaryFor(context),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          isRtl ? 'جلوی هواپیما' : 'Front of Aircraft',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: TravelTheme.primaryFor(context),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    _exitBadge(left: false, isDark: isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Train Locomotive Engine
      return Center(
        child: SizedBox(
          width: 240.w,
          child: Column(
            children: [
              Container(
                height: 46.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: trainGradient,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30.r),
                  ),
                  border: Border.all(color: TravelTheme.green.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lightbulb_outline_rounded,
                          size: 16.r, color: TravelTheme.green),
                      SizedBox(width: 10.w),
                      Icon(Icons.train_rounded,
                          size: 20.r, color: TravelTheme.green),
                      SizedBox(width: 10.w),
                      Icon(Icons.lightbulb_outline_rounded,
                          size: 16.r, color: TravelTheme.green),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                color: trainIndicatorColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 14.r,
                      color: TravelTheme.green,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isRtl ? 'جهت حرکت قطار' : 'Direction of Travel',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: TravelTheme.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _cockpitWindow(bool isDark) {
    return Container(
      width: 26.w,
      height: 14.h,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFF263238),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }

  Widget _exitBadge({required bool left, required bool isDark}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A24) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: isDark ? const Color(0xFF2E7D32) : const Color(0xFF81C784)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (left)
            Icon(Icons.chevron_left_rounded, size: 10.r, color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32)),
          Text(
            isRtl ? 'خروج' : 'EXIT',
            style: TextStyle(
              fontSize: 8.5.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
            ),
          ),
          if (!left)
            Icon(Icons.chevron_right_rounded, size: 10.r, color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Column Headers (A, B, C  [Aisle]  D, E, F)
// ---------------------------------------------------------------------------

class _ColumnHeaders extends StatelessWidget {
  final SeatCabinClass cabinClass;
  final bool isRtl;

  const _ColumnHeaders({
    required this.cabinClass,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = TravelTheme.textPrimaryFor(context);
    final textSecondary = TravelTheme.textSecondaryFor(context);
    final isBusiness = cabinClass == SeatCabinClass.business;
    final leftCols = isBusiness ? ['A', 'C'] : ['A', 'B', 'C'];
    final rightCols = isBusiness ? ['D', 'F'] : ['D', 'E', 'F'];
    final seatWidth = isBusiness ? 46.w : 38.w;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left Seats Headers
          Row(
            children: leftCols
                .map((col) => SizedBox(
                      width: seatWidth,
                      child: Center(
                        child: Text(
                          col,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),

          // Center Aisle Gap & Header
          SizedBox(
            width: 38.w,
            child: Center(
              child: Text(
                isRtl ? 'راهرو' : 'AISLE',
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w800,
                  color: textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // Right Seats Headers
          Row(
            children: rightCols
                .map((col) => SizedBox(
                      width: seatWidth,
                      child: Center(
                        child: Text(
                          col,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single Seat Row Widget
// ---------------------------------------------------------------------------

class _SeatRowWidget extends StatelessWidget {
  final int rowNum;
  final List<SeatItem> seats;
  final SeatCabinClass cabinClass;
  final Set<String> selectedSeatIds;
  final bool isExitRow;
  final bool isRtl;
  final ValueChanged<SeatItem> onSeatTap;

  const _SeatRowWidget({
    required this.rowNum,
    required this.seats,
    required this.cabinClass,
    required this.selectedSeatIds,
    required this.isExitRow,
    required this.isRtl,
    required this.onSeatTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = TravelTheme.isDark(context);
    final isBusiness = cabinClass == SeatCabinClass.business;
    final leftCols = isBusiness ? ['A', 'C'] : ['A', 'B', 'C'];
    final rightCols = isBusiness ? ['D', 'F'] : ['D', 'E', 'F'];
    final seatWidth = isBusiness ? 46.w : 38.w;
    final seatHeight = isBusiness ? 48.h : 44.h;

    SeatItem? findSeat(String col) {
      return seats.cast<SeatItem?>().firstWhere(
            (s) => s?.column == col,
            orElse: () => null,
          );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        children: [
          // Exit row banner
          if (isExitRow)
            Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF332A00) : const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: const Color(0xFFF2C94C), width: 1.w),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 11.r, color: isDark ? const Color(0xFFFFD54F) : const Color(0xFF8A6D00)),
                    SizedBox(width: 4.w),
                    Text(
                      isRtl ? 'ردیف خروج اضطراری · فضای پای بیشتر' : 'Emergency Exit Row · Extra Legroom',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFFFD54F) : const Color(0xFF8A6D00),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left Seats
                Row(
                  children: leftCols.map((col) {
                    final seat = findSeat(col);
                    if (seat == null) return SizedBox(width: seatWidth);
                    final isSelected = selectedSeatIds.contains(seat.id);

                    return _SeatItemCard(
                      seat: isSelected
                          ? seat.copyWith(status: SeatStatus.selected)
                          : seat,
                      width: seatWidth,
                      height: seatHeight,
                      onTap: () => onSeatTap(seat),
                    );
                  }).toList(),
                ),

                // Center Aisle: Row Number
                SizedBox(
                  width: 38.w,
                  child: Center(
                    child: Container(
                      width: 24.w,
                      height: 24.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isExitRow
                            ? (isDark ? const Color(0xFF332A00) : const Color(0xFFFFF3CD))
                            : TravelTheme.backgroundFor(context),
                        shape: BoxShape.circle,
                        border: isExitRow
                            ? Border.all(color: const Color(0xFFF2C94C), width: 1.w)
                            : Border.all(color: TravelTheme.borderFor(context)),
                      ),
                      child: Text(
                        '$rowNum',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w800,
                          color: isExitRow
                              ? (isDark ? const Color(0xFFFFD54F) : const Color(0xFF856404))
                              : TravelTheme.textSecondaryFor(context),
                        ),
                      ),
                    ),
                  ),
                ),

                // Right Seats
                Row(
                  children: rightCols.map((col) {
                    final seat = findSeat(col);
                    if (seat == null) return SizedBox(width: seatWidth);
                    final isSelected = selectedSeatIds.contains(seat.id);

                    return _SeatItemCard(
                      seat: isSelected
                          ? seat.copyWith(status: SeatStatus.selected)
                          : seat,
                      width: seatWidth,
                      height: seatHeight,
                      onTap: () => onSeatTap(seat),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual Seat Card
// ---------------------------------------------------------------------------

class _SeatItemCard extends StatelessWidget {
  final SeatItem seat;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _SeatItemCard({
    required this.seat,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = TravelTheme.isDark(context);
    final status = seat.status;
    final primaryColor = TravelTheme.primaryFor(context);
    final borderColor = TravelTheme.borderFor(context);
    final textPrimary = TravelTheme.textPrimaryFor(context);
    final textSecondary = TravelTheme.textSecondaryFor(context);

    // Styling based on seat status
    final Color bgColor;
    final Border border;
    final List<BoxShadow>? shadows;

    switch (status) {
      case SeatStatus.selected:
        bgColor = primaryColor;
        border = Border.all(color: primaryColor, width: 1.5.w);
        shadows = [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];
        break;
      case SeatStatus.reserved:
        bgColor = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFECEFF1);
        border = Border.all(color: isDark ? borderColor : const Color(0xFFD3D8DC), width: 1.w);
        shadows = null;
        break;
      case SeatStatus.premium:
        bgColor = isDark ? const Color(0xFF332A00) : const Color(0xFFFFFBEB);
        border = Border.all(color: const Color(0xFFD4AF37), width: 1.4.w);
        shadows = [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
        break;
      case SeatStatus.available:
        bgColor = TravelTheme.cardSurfaceFor(context);
        border = Border.all(color: borderColor, width: 1.2.w);
        shadows = [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ];
        break;
    }

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(2.r),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: status == SeatStatus.reserved ? null : onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: border,
              boxShadow: shadows,
            ),
            child: Stack(
              children: [
                // Top headrest contour
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 4.h,
                    width: width * 0.5,
                    decoration: BoxDecoration(
                      color: status == SeatStatus.selected
                          ? AppColors.white.withValues(alpha: 0.3)
                          : status == SeatStatus.reserved
                              ? (isDark ? AppColors.darkCard : const Color(0xFFCFD8DC))
                              : status == SeatStatus.premium
                                  ? const Color(0xFFD4AF37).withValues(alpha: 0.4)
                                  : borderColor,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(3.r),
                      ),
                    ),
                  ),
                ),

                // Center Seat Icon / Letter / Status
                Center(
                  child: _buildSeatContent(status, textPrimary, textSecondary, isDark),
                ),

                // Premium Star Badge
                if (status == SeatStatus.premium)
                  Positioned(
                    top: 2.h,
                    right: 2.w,
                    child: Icon(
                      Icons.star_rounded,
                      size: 10.r,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeatContent(
    SeatStatus status,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    switch (status) {
      case SeatStatus.selected:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_rounded, size: 14, color: AppColors.white),
            Text(
              seat.code,
              style: TextStyle(
                fontSize: 8.5.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
          ],
        );
      case SeatStatus.reserved:
        return Icon(
          Icons.close_rounded,
          size: 14,
          color: isDark ? AppColors.softGray : const Color(0xFF90A4AE),
        );
      case SeatStatus.premium:
        return Text(
          seat.column,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? const Color(0xFFFFD54F) : const Color(0xFF8A6D00),
          ),
        );
      case SeatStatus.available:
        return Text(
          seat.column,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Bottom / Floating Summary Bar
// ---------------------------------------------------------------------------

class _SeatSummaryBar extends StatelessWidget {
  final List<SeatItem> selectedSeats;
  final int maxSeats;
  final double totalExtraFees;
  final String currency;
  final bool isRtl;
  final VoidCallback onConfirm;

  const _SeatSummaryBar({
    required this.selectedSeats,
    required this.maxSeats,
    required this.totalExtraFees,
    required this.currency,
    required this.isRtl,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final count = selectedSeats.length;
    final isSelectionReady = count > 0;
    final isDark = TravelTheme.isDark(context);
    final cardBg = TravelTheme.cardSurfaceFor(context);
    final borderColor = TravelTheme.borderFor(context);
    final textPrimary = TravelTheme.textPrimaryFor(context);
    final textSecondary = TravelTheme.textSecondaryFor(context);
    final brandColor = TravelTheme.primaryFor(context);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(top: BorderSide(color: borderColor)),
        boxShadow: TravelTheme.shadowFor(context),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 14.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Seats overview & pricing
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.airline_seat_recline_extra_rounded,
                            size: 16.r,
                            color: brandColor,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            isRtl ? 'صندلی‌های انتخابی:' : 'Selected Seats:',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: textSecondary,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: TravelTheme.backgroundFor(context),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              '$count / $maxSeats',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      if (selectedSeats.isEmpty)
                        Text(
                          isRtl
                              ? 'لطفاً صندلی‌های خود را روی نقشه انتخاب کنید'
                              : 'Select your seat(s) on the cabin map',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: textSecondary,
                          ),
                        )
                      else
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: selectedSeats.map((seat) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkPrimaryContainer
                                    : AppColors.lightPrimaryContainer
                                        .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkPrimary.withValues(alpha: 0.4)
                                      : AppColors.mutedBlue.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                '${seat.code} (${seat.type.localizedLabel(isRtl)})',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.lightPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                // Total extra price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isRtl ? 'هزینه اضافی' : 'Seat Fee',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      totalExtraFees > 0
                          ? '+$currency ${totalExtraFees.toStringAsFixed(1)}'
                          : (isRtl ? 'رایگان' : 'Included'),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: totalExtraFees > 0
                            ? TravelTheme.green
                            : textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Confirm Selection Button
            CommonButton(
              width: double.infinity,
              text: isSelectionReady
                  ? (isRtl
                      ? 'تأیید انتخاب ($count صندلی)'
                      : 'Confirm Selection ($count Seat${count > 1 ? 's' : ''})')
                  : (isRtl ? 'انتخاب صندلی' : 'Select Seats'),
              backgroundColor: isSelectionReady
                  ? TravelTheme.blue
                  : TravelTheme.muted,
              onPressed: isSelectionReady ? onConfirm : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Modal Bottom Sheet Widget & Helper Function
// ---------------------------------------------------------------------------

class SeatMapBottomSheet extends StatelessWidget {
  final SeatVehicleType vehicleType;
  final SeatCabinClass initialCabinClass;
  final int maxSelectedSeats;
  final List<SeatItem>? initialSeats;
  final List<String> initiallySelectedSeatIds;
  final String? title;
  final String? subtitle;
  final String currency;
  final ValueChanged<List<SeatItem>>? onConfirmed;

  const SeatMapBottomSheet({
    super.key,
    this.vehicleType = SeatVehicleType.aircraft,
    this.initialCabinClass = SeatCabinClass.economy,
    this.maxSelectedSeats = 1,
    this.initialSeats,
    this.initiallySelectedSeatIds = const [],
    this.title,
    this.subtitle,
    this.currency = 'USD',
    this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final defaultTitle = vehicleType == SeatVehicleType.aircraft
        ? (isRtl ? 'انتخاب صندلی پرواز' : 'Select Aircraft Seat')
        : (isRtl ? 'انتخاب صندلی قطار' : 'Select Train Seat');

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.90,
      decoration: const BoxDecoration(
        color: TravelTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          SizedBox(height: 10.h),
          Center(
            child: Container(
              width: 38.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: TravelTheme.muted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // Header: Title & Close Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title ?? defaultTitle,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: TravelTheme.ink,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: TravelTheme.muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: isRtl ? 'بستن' : 'Close',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: TravelTheme.border),

          // Interactive Map Widget
          Expanded(
            child: SeatSelectionMap(
              vehicleType: vehicleType,
              initialCabinClass: initialCabinClass,
              maxSelectedSeats: maxSelectedSeats,
              initialSeats: initialSeats,
              initiallySelectedSeatIds: initiallySelectedSeatIds,
              currency: currency,
              onConfirmed: (selected) {
                onConfirmed?.call(selected);
                Navigator.of(context).pop(selected);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to display the seat selection bottom sheet
Future<List<SeatItem>?> showSeatSelectionBottomSheet(
  BuildContext context, {
  SeatVehicleType vehicleType = SeatVehicleType.aircraft,
  SeatCabinClass initialCabinClass = SeatCabinClass.economy,
  int maxSelectedSeats = 1,
  List<SeatItem>? initialSeats,
  List<String> initiallySelectedSeatIds = const [],
  String? title,
  String? subtitle,
  String currency = 'USD',
  ValueChanged<List<SeatItem>>? onConfirmed,
}) async {
  return showModalBottomSheet<List<SeatItem>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (modalContext) => SeatMapBottomSheet(
      vehicleType: vehicleType,
      initialCabinClass: initialCabinClass,
      maxSelectedSeats: maxSelectedSeats,
      initialSeats: initialSeats,
      initiallySelectedSeatIds: initiallySelectedSeatIds,
      title: title,
      subtitle: subtitle,
      currency: currency,
      onConfirmed: onConfirmed,
    ),
  );
}
