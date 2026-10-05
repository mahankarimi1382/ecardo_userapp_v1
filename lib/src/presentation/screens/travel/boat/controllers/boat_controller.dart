// DATA: MOCK (Ready for REAL backend domain registration under schema_version: 1.0)
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import '../../local/models/experience_contracts.dart';
import '../models/boat_models.dart';

class BoatController extends GetxController {
  // UI State Machine (Mandatory 12 states)
  final Rx<ExperienceServiceState> uiState = ExperienceServiceState.defaultState.obs;
  final RxString errorMessage = ''.obs;
  final RxString validationError = ''.obs;
  final RxBool isOffline = false.obs;
  final RxBool isPartial = false.obs;

  // Catalog State
  final RxList<BoatExperienceModel> allBoats = <BoatExperienceModel>[].obs;
  final RxList<BoatExperienceModel> filteredBoats = <BoatExperienceModel>[].obs;
  final RxList<BoatBookingModel> myBookings = <BoatBookingModel>[].obs;

  // Filters
  final Rx<BoatCategory?> selectedCategory = Rx<BoatCategory?>(null);
  final RxString selectedCity = 'ALL'.obs;
  final RxString searchQuery = ''.obs;
  Timer? _debounceTimer;

  // Booking Builder State
  final RxInt selectedDurationHours = 2.obs;
  final RxString selectedTimeSlot = ''.obs;
  final RxInt passengerCount = 2.obs;
  final RxInt childrenCount = 0.obs;
  final RxList<String> selectedAddons = <String>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().add(const Duration(days: 2)).obs;
  final RxString customerNote = ''.obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    loadCatalog();
    loadSampleBookings();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  void _initConnectivity() {
    // DATA: REAL connectivity check with fallback
    Connectivity().checkConnectivity().then((result) {
      final offline = result.contains(ConnectivityResult.none);
      isOffline.value = offline;
      if (offline && uiState.value == ExperienceServiceState.defaultState) {
        uiState.value = ExperienceServiceState.offline;
      }
    }).catchError((_) {});

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final offline = results.contains(ConnectivityResult.none);
      isOffline.value = offline;
      if (offline) {
        uiState.value = ExperienceServiceState.offline;
      } else if (uiState.value == ExperienceServiceState.offline) {
        uiState.value = ExperienceServiceState.success;
      }
    });
  }

  /// Loads boat catalog items. Tagged as MOCK until backend endpoint is available.
  Future<void> loadCatalog({bool forceRefresh = false}) async {
    uiState.value = ExperienceServiceState.skeleton;
    errorMessage.value = '';

    try {
      // Simulate network request
      await Future.delayed(const Duration(milliseconds: 600));

      // DATA: MOCK catalog dataset mirroring trip.ecardo.ir specification
      final mockData = [
        const BoatExperienceModel(
          schemaVersion: '1.0',
          id: 'boat-01',
          title: 'کشتی تفریحی و یات لوکس سان‌سیکر ۵۵ (Sunseeker 55ft Luxury Yacht)',
          marinaName: 'اسکله تفریحی میرمهنا، کیش',
          city: 'کیش (Kish Island)',
          category: BoatCategory.yacht,
          hourlyRate: 120.0,
          childRate: 40.0,
          currency: 'USD',
          minPassengers: 1,
          maxPassengers: 12,
          lengthMeters: 17.5,
          rating: 4.9,
          reviewsCount: 84,
          captainName: 'کاپیتان آرش علیزاده',
          images: [
            'https://images.unsplash.com/photo-1569263979104-865ab7cd8d13?w=800&auto=format&fit=crop',
          ],
          features: [
            'سیستم صوتی استریو بلوتوث',
            'سالن پذیرایی مجهز با تهویه مطبوع',
            'دک آفتاب‌گیری و تشک‌های VIP',
            'پذیرایی رایگان نوشیدنی و میوه',
            'جلیقه نجات و نجات‌غریق حرفه‌ای',
          ],
          availableSlots: [
            '10:00 - 12:00 (گشت صبحگاهی)',
            '14:00 - 16:00 (بعدازظهر)',
            '17:00 - 19:00 (سانس طلایی غروب کیش 🌅)',
            '20:00 - 22:00 (گشت شبانه مهتابی)',
          ],
          addons: [
            BoatAddon(
              id: 'snorkeling',
              title: 'تجهیزات غواصی سطحی و اسنورکلینگ',
              price: 15.0,
              unit: 'هر نفر',
              icon: 'scuba',
            ),
            BoatAddon(
              id: 'chef',
              title: 'پک شام دریایی باربیکیو اختصاصی روی عرشه',
              price: 45.0,
              unit: 'هر نفر',
              icon: 'restaurant',
            ),
            BoatAddon(
              id: 'jetski',
              title: 'همراهی یک دستگاه جت‌اسکی یاماها ۱۸۰ اسب بخار',
              price: 60.0,
              unit: '۱ ساعت',
              icon: 'speed',
            ),
          ],
          description:
              'تجربه لوکس‌ترین گشت دریایی در آب‌های فیروزه‌ای خلیج فارس. یات مجلل ۵۵ فوتی سان‌سیکر با دو موتور قدرتمند، عرشه وسیع و کادر مجرب، آماده میزبانی از دورهمی‌ها، جلسات تجاری و خاطره‌انگیزترین لحظات غروب آفتاب شماست.',
          pricingType: ExperiencePricingType.perHour,
          cancellationPolicy: ExperienceCancellationPolicy(
            freeCancellationHours: 24,
            lateCancelPenaltyPercent: 30.0,
            policyNotes: 'لغو رایگان تا ۲۴ ساعت قبل از حرکت با استرداد ۱۰۰٪ به کیف پول دلاری.',
          ),
          pierDockNumber: 'Dock B - Pier #8',
          seaConditionsAdvisory: 'آب‌های آرام خلیج فارس، بدون ریسک دریازدگی',
          fuelPolicy: 'سوخت مصرفی استاندارد تا ۱۰ مایل دریایی شامل رزرو است',
        ),
        const BoatExperienceModel(
          schemaVersion: '1.0',
          id: 'boat-02',
          title: 'قایق تندرو اسپرت اوشن مستر ۳۱ (Ocean Master Offshore Speedboat)',
          marinaName: 'دبی مارینا (Dubai Marina Pier 7)',
          city: 'دبی (Dubai)',
          category: BoatCategory.speedboat,
          hourlyRate: 85.0,
          childRate: 35.0,
          currency: 'USD',
          minPassengers: 1,
          maxPassengers: 6,
          lengthMeters: 9.8,
          rating: 4.8,
          reviewsCount: 112,
          captainName: 'کاپیتان طارق منصور',
          images: [
            'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&auto=format&fit=crop',
          ],
          features: [
            'سرعت هیجان‌انگیز تا ۴۵ نات دریایی',
            'سیستم صوتی ضدآب Fusion',
            'دید پانوراما از برج‌العرب و پالم جمیرا',
            'امکان توقف جهت شنا در آب‌های آزاد',
          ],
          availableSlots: [
            '09:00 - 11:00',
            '11:30 - 13:30',
            '15:00 - 17:00',
            '17:30 - 19:30 (غروب دبی مارینا)',
          ],
          addons: [
            BoatAddon(
              id: 'gopro',
              title: 'فیلمبرداری و عکاسی حرفه‌ای با هلی‌شات و GoPro',
              price: 30.0,
              unit: 'پکیج',
              icon: 'camera',
            ),
          ],
          description:
              'هیجان بی‌پایان در آب‌های دبی با قایق تندرو اسپرت. مشاهده چشم‌اندازهای بی‌نظیر مارینا، برج العرب، چرخ‌وفلک عین دبی و هتل آتلانتیس با بالاترین استانداردهای ایمنی گارد ساحلی امارات.',
          pricingType: ExperiencePricingType.perHour,
          cancellationPolicy: ExperienceCancellationPolicy(
            freeCancellationHours: 24,
            lateCancelPenaltyPercent: 25.0,
          ),
          pierDockNumber: 'Marina Gate 3 - Slip 12',
          seaConditionsAdvisory: 'آب‌های آرام ساحلی دبی، مناسب کودکان و خانواده‌ها',
        ),
        const BoatExperienceModel(
          schemaVersion: '1.0',
          id: 'boat-03',
          title: 'کاتاماران دوطبقه بادبانی بوسفوروس (Bosphorus Sailing Catamaran)',
          marinaName: 'مارینای ببک، استانبول',
          city: 'استانبول (Istanbul)',
          category: BoatCategory.catamaran,
          hourlyRate: 95.0,
          childRate: 30.0,
          currency: 'USD',
          minPassengers: 2,
          maxPassengers: 20,
          lengthMeters: 14.2,
          rating: 4.95,
          reviewsCount: 160,
          captainName: 'کاپیتان مراد ییلماز',
          images: [
            'https://images.unsplash.com/photo-1506929562872-bb421503ef21?w=800&auto=format&fit=crop',
          ],
          features: [
            'تور کروز در تنگه بسفر میان آسیا و اروپا',
            'عرشه فوقانی با دید ۳۶۰ درجه',
            'سرو چای و شیرینی سنتی ترکی',
            'محیط آرام، باثبات و بدون تکان دریایی',
          ],
          availableSlots: [
            '10:00 - 13:00 (گشت تاریخی قلعه روملی)',
            '16:00 - 19:00 (غروب پل بسفر)',
            '19:30 - 22:30 (دید در شب استانبول)',
          ],
          addons: [
            BoatAddon(
              id: 'turkish_music',
              title: 'اجرای زنده موسیقی سنتی ترکی روی آب',
              price: 50.0,
              unit: 'پکیج',
              icon: 'music',
            ),
          ],
          description:
              'آرامش و شکوه در تنگه جادویی بسفر. عبور از زیر پل‌های معروف استانبول و تماشای کاخ‌های تاریخی عثمانی از روی آب، روی عرشه لوکس کاتاماران بادبانی.',
          pricingType: ExperiencePricingType.perHour,
          cancellationPolicy: ExperienceCancellationPolicy(
            freeCancellationHours: 48,
            lateCancelPenaltyPercent: 40.0,
          ),
          pierDockNumber: 'Bebek Pier - Mooring #4',
        ),
        const BoatExperienceModel(
          schemaVersion: '1.0',
          id: 'boat-04',
          title: 'کروز غواصی و کاوش صخره‌های مرجانی خلیج فارس',
          marinaName: 'مرکز غواصی پارک مارین، کیش',
          city: 'کیش (Kish Island)',
          category: BoatCategory.diving,
          hourlyRate: 75.0,
          childRate: 0.0, // Children under 10 not permitted
          currency: 'USD',
          minPassengers: 1,
          maxPassengers: 8,
          lengthMeters: 11.0,
          rating: 4.88,
          reviewsCount: 65,
          captainName: 'مربی حمید رضایی (PADI Master)',
          images: [],
          features: [
            'همراهی مربی رسمی PADI دو ستاره',
            'تجهیزات کامل غواصی ScubaPro و کپسول اکسیژن',
            'عکاسی زیر آب با کیس ضدآب حرفه‌ای',
            'گواهینامه تجربه غواصی دیسکاوری',
          ],
          availableSlots: [
            '08:30 - 11:30 (سانس صبح با وضوح بالا)',
            '13:00 - 16:00 (سانس ظهر)',
          ],
          addons: [
            BoatAddon(
              id: 'deep_dive',
              title: 'غواصی در عمق بالای ۱۲ متر (ویژه دارندگان مدرک)',
              price: 25.0,
              unit: 'هر نفر',
              icon: 'scuba',
            ),
          ],
          description:
              'کاوش اعماق زلال خلیج فارس و تماشای مرجان‌های زنده، لاک‌پشت‌های پوزه‌عقابی و ماهی‌های رنگارنگ با رعایت بالاترین استانداردهای ایمنی فدراسیون جهانی غواصی.',
          pierDockNumber: 'Kish Marine Diving Dock - Berth D',
        ),
      ];

      allBoats.assignAll(mockData);
      applyFilters();

      if (filteredBoats.isEmpty) {
        uiState.value = ExperienceServiceState.empty;
      } else {
        uiState.value = ExperienceServiceState.success;
      }
    } catch (e) {
      errorMessage.value = 'خطا در بارگذاری فهرست شناورها: $e';
      uiState.value = ExperienceServiceState.error;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      applyFilters();
    });
  }

  void applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();
    final results = allBoats.where((boat) {
      final matchesCategory =
          selectedCategory.value == null || boat.category == selectedCategory.value;
      final matchesCity =
          selectedCity.value == 'ALL' || boat.city.contains(selectedCity.value);
      final matchesQuery = query.isEmpty ||
          boat.title.toLowerCase().contains(query) ||
          boat.marinaName.toLowerCase().contains(query) ||
          boat.captainName.toLowerCase().contains(query);
      return matchesCategory && matchesCity && matchesQuery;
    }).toList();

    filteredBoats.assignAll(results);

    if (results.isEmpty) {
      uiState.value = ExperienceServiceState.empty;
    } else {
      uiState.value = ExperienceServiceState.success;
    }
  }

  void resetFilters() {
    selectedCategory.value = null;
    selectedCity.value = 'ALL';
    searchQuery.value = '';
    applyFilters();
  }

  void setCategory(BoatCategory? cat) {
    selectedCategory.value = cat;
    applyFilters();
  }

  void setCity(String city) {
    selectedCity.value = city;
    applyFilters();
  }

  void toggleAddon(String addonId) {
    if (selectedAddons.contains(addonId)) {
      selectedAddons.remove(addonId);
    } else {
      selectedAddons.add(addonId);
    }
  }

  double calculateTotalPrice(BoatExperienceModel boat) {
    return boat.calculateTotal(
      hours: selectedDurationHours.value,
      adults: passengerCount.value,
      children: childrenCount.value,
      selectedAddonIds: selectedAddons,
    );
  }

  String? validateBooking(BoatExperienceModel boat) {
    final totalGuests = passengerCount.value + childrenCount.value;
    if (totalGuests < boat.minPassengers) {
      return 'حداقل تعداد مسافران برای این شناور ${boat.minPassengers} نفر است.';
    }
    if (totalGuests > boat.maxPassengers) {
      return 'تعداد مسافران ($totalGuests نفر) بیش از حداکثر ظرفیت شناور (${boat.maxPassengers} نفر) است.';
    }
    if (selectedDurationHours.value < 1) {
      return 'مدت رزرو باید حداقل ۱ ساعت باشد.';
    }
    return null;
  }

  /// Submits boat booking. Tagged as MOCK simulation until backend travel domain is wired.
  Future<BoatBookingModel?> bookBoat({
    required BoatExperienceModel boat,
  }) async {
    validationError.value = '';
    final valErr = validateBooking(boat);
    if (valErr != null) {
      validationError.value = valErr;
      uiState.value = ExperienceServiceState.validationError;
      ToastHelper().showErrorToast(valErr);
      return null;
    }

    uiState.value = ExperienceServiceState.processing;
    try {
      // Network simulation
      await Future.delayed(const Duration(milliseconds: 1200));

      final total = calculateTotalPrice(boat);
      final bookingId = 'SEA-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final booking = BoatBookingModel(
        schemaVersion: '1.0',
        bookingId: bookingId,
        boatId: boat.id,
        boatTitle: boat.title,
        marinaName: boat.marinaName,
        date: selectedDate.value,
        timeSlot: selectedTimeSlot.value.isNotEmpty
            ? selectedTimeSlot.value
            : (boat.availableSlots.isNotEmpty ? boat.availableSlots.first : '10:00 - 12:00'),
        durationHours: selectedDurationHours.value,
        passengersCount: passengerCount.value,
        childrenCount: childrenCount.value,
        selectedAddonIds: List.from(selectedAddons),
        totalAmount: total,
        currency: boat.currency,
        refundDestinationWalletCurrency: boat.currency,
        captainPhone: '+98 912 884 9201',
        pierDockNumber: boat.pierDockNumber,
        status: 'confirmed',
        bookedAt: DateTime.now(),
        cancellationPolicy: boat.cancellationPolicy,
      );

      myBookings.insert(0, booking);
      uiState.value = ExperienceServiceState.completed;
      ToastHelper().showSuccessToast('رزرو گشت دریایی با موفقیت تأیید و بلیت صادر شد');
      return booking;
    } catch (e) {
      errorMessage.value = 'خطا در ثبت رزرو: $e';
      uiState.value = ExperienceServiceState.error;
      ToastHelper().showErrorToast('خطا در ثبت رزرو: $e');
      return null;
    }
  }

  /// Cancels booking with refund calculation deposited to user's matching-currency wallet.
  Future<bool> cancelBooking(String bookingId, {String? reason}) async {
    final idx = myBookings.indexWhere((b) => b.bookingId == bookingId);
    if (idx < 0) return false;

    final booking = myBookings[idx];
    if (!booking.canCancel) {
      ToastHelper().showErrorToast('این بلیت در وضعیت غیرقابل استرداد است.');
      return false;
    }

    uiState.value = ExperienceServiceState.processing;
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final refundCalc = booking.calculateCancellationRefund();
      final updated = booking.copyWithCancelled(
        penalty: refundCalc.penaltyAmount,
        refund: refundCalc.refundableAmount,
        reason: reason ?? refundCalc.policySummary,
      );

      myBookings[idx] = updated;
      uiState.value = ExperienceServiceState.cancelled;

      final msg = refundCalc.isFreeCancellation
          ? 'بلیت با استرداد کامل ۱۰۰٪ (${refundCalc.refundableAmount} ${refundCalc.currency}) به کیف پول لغو شد.'
          : 'بلیت لغو شد. مبلغ ${refundCalc.refundableAmount} ${refundCalc.currency} پس از کسر جریمه به کیف پول مسترد شد.';
      ToastHelper().showSuccessToast(msg);
      return true;
    } catch (e) {
      ToastHelper().showErrorToast('خطا در لغو رزرو: $e');
      uiState.value = ExperienceServiceState.error;
      return false;
    }
  }

  /// Sample bookings demonstrating realistic booking lifecycle states.
  void loadSampleBookings() {
    // DATA: MOCK sample bookings
    myBookings.assignAll([
      BoatBookingModel(
        schemaVersion: '1.0',
        bookingId: 'SEA-88492',
        boatId: 'boat-01',
        boatTitle: 'کشتی تفریحی سان‌سیکر ۵۵ (Sunseeker 55ft Luxury Yacht)',
        marinaName: 'اسکله تفریحی میرمهنا، کیش',
        date: DateTime.now().add(const Duration(days: 1)),
        timeSlot: '17:00 - 19:00 (سانس طلایی غروب کیش 🌅)',
        durationHours: 2,
        passengersCount: 4,
        childrenCount: 1,
        selectedAddonIds: const ['snorkeling'],
        totalAmount: 315.0,
        currency: 'USD',
        refundDestinationWalletCurrency: 'USD',
        captainPhone: '+98 912 884 9201',
        pierDockNumber: 'Dock B - Pier #8',
        status: 'confirmed',
        bookedAt: DateTime.now().subtract(const Duration(hours: 3)),
        cancellationPolicy: const ExperienceCancellationPolicy(
          freeCancellationHours: 24,
          lateCancelPenaltyPercent: 30.0,
        ),
      ),
      BoatBookingModel(
        schemaVersion: '1.0',
        bookingId: 'SEA-72109',
        boatId: 'boat-03',
        boatTitle: 'کاتاماران دوطبقه بادبانی بوسفوروس',
        marinaName: 'مارینای ببک، استانبول',
        date: DateTime.now().subtract(const Duration(days: 5)),
        timeSlot: '16:00 - 19:00',
        durationHours: 3,
        passengersCount: 2,
        childrenCount: 0,
        selectedAddonIds: const ['turkish_music'],
        totalAmount: 335.0,
        currency: 'USD',
        refundDestinationWalletCurrency: 'USD',
        captainPhone: '+90 532 999 1122',
        pierDockNumber: 'Bebek Pier - Mooring #4',
        status: 'completed',
        bookedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
    ]);
  }
}
