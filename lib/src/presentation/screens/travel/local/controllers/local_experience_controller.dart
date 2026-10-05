// DATA: MOCK (Ready for REAL backend domain registration under schema_version: 1.0)
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import '../../local/models/experience_contracts.dart';
import '../models/local_experience_models.dart';

class LocalExperienceController extends GetxController {
  // UI State Machine (mandatory 12 states)
  final Rx<ExperienceServiceState> uiState = ExperienceServiceState.defaultState.obs;
  final RxString errorMessage = ''.obs;
  final RxString validationError = ''.obs;
  final RxBool isOffline = false.obs;
  final RxString searchQuery = ''.obs;

  // Catalog & Bookings
  final RxList<LocalExperienceItemModel> allExperiences = <LocalExperienceItemModel>[].obs;
  final RxList<LocalExperienceItemModel> filteredExperiences = <LocalExperienceItemModel>[].obs;
  final RxList<LocalBookingModel> myBookings = <LocalBookingModel>[].obs;

  // Filters
  final Rx<LocalServiceType?> selectedType = Rx<LocalServiceType?>(null);
  final RxString selectedCity = 'ALL'.obs;

  // Booking Form State
  final Rx<DateTime> selectedDate = DateTime.now().add(const Duration(days: 2)).obs;
  final RxString selectedTime = '09:00'.obs;
  final RxInt guestsCount = 2.obs;
  final RxInt childrenCount = 0.obs;
  final RxString customerNote = ''.obs;

  Timer? _debounceTimer;
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
    // DATA: REAL connectivity check
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

  /// Local experience catalog (attractions, tours, activities). Tagged MOCK until backend `tour_activities` wired.
  Future<void> loadCatalog() async {
    uiState.value = ExperienceServiceState.skeleton;
    errorMessage.value = '';

    try {
      await Future.delayed(const Duration(milliseconds: 580));

      // DATA: MOCK data from Viator/GetYourGuide spec simulation
      final mockData = [
        const LocalExperienceItemModel(
          schemaVersion: '1.0',
          id: 'local-01',
          title: 'راهنمای تور محلی و گشت تاریخی استانبول با لیدر مجرب',
          subtitle: 'فارسی‌زبان · گشت نیم‌روز سلطان‌احمد و بسفر',
          providerName: 'استاد امین خلیلی (راهنمای رسمی وزارت گردشگری ترکیه)',
          city: 'استانبول',
          type: LocalServiceType.tourGuide,
          price: 45.0,
          childPrice: 20.0,
          currency: 'USD',
          pricingType: ExperiencePricingType.perPerson,
          durationLabel: '۴ ساعت',
          durationMinutes: 240,
          languages: ['فارسی', 'ترکی استانبولی', 'انگلیسی'],
          rating: 4.95,
          reviewsCount: 142,
          highlights: [
            'بازدید بدون صف از مسجد ایاصوفیه و کاخ توپکاپی',
            'پیاده‌روی در بافت محلی و معرفی بهترین کافه‌ها',
            'پاسخگویی به تمام سوالات تاریخی و شهری',
          ],
          meetingPoint: 'میدان سلطان‌احمد، مقابل درب اصلی ایاصوفیه',
          description:
              'با همراهی راهنمای مجرب و مسلط به زبان فارسی و تاریخ ترکیه، سفری به عمق تاریخ کهن قسطنطنیه و استانبول داشته باشید. بدون سردرگمی و اتلاف وقت، از مهم‌ترین آثار تاریخی، بازارهای سنتی و نماهای مخفی شهر دیدن فرمایید.',
          images: [
            'https://images.unsplash.com/photo-1565639127188-d213d1c6e2b3?w=800&auto=format&fit=crop',
          ],
          minGuests: 1,
          maxGuests: 8,
          remainingCapacity: 6,
          availableTimeSlots: ['09:00', '11:00', '14:00', '16:30'],
          skipTheLine: true,
          freeCancellation: true,
          cancellationPolicy: ExperienceCancellationPolicy(
            freeCancellationHours: 24,
            lateCancelPenaltyPercent: 0.0,
          ),
        ),
        const LocalExperienceItemModel(
          schemaVersion: '1.0',
          id: 'local-02',
          title: 'عکاس حرفه‌ای سفر در دبی (Dubai Professional Travel Photographer)',
          subtitle: 'دو ساعت عکاسی لوکس + ۳۵ شات ادیت‌شده',
          providerName: 'سارا پرتو (عکاس و ادیتور فشن و توریسم دبی)',
          city: 'دبی',
          type: LocalServiceType.photographer,
          price: 90.0,
          childPrice: 30.0,
          currency: 'USD',
          pricingType: ExperiencePricingType.perGroup,
          durationLabel: '۲ ساعت',
          durationMinutes: 120,
          languages: ['فارسی', 'انگلیسی', 'عربی'],
          rating: 4.9,
          reviewsCount: 98,
          highlights: [
            'عکاسی در زیباترین نماهای برج خلیفه و دبی مال',
            'تحویل فایل‌های ادیت‌شده با کیفیت چاپی ظرف ۴۸ ساعت',
            'همراهی دستیار نورپردازی و هدایت ژست‌ها',
          ],
          meetingPoint: 'پل سوق‌البحار (Souk Al Bahar Bridge)، روبروی برج خلیفه',
          description:
              'ثبت به یادماندنی‌ترین خاطرات شما از سفر به دبی با دوربین‌های حرفه‌ای سونی Alpha و لنزهای پرایم. ایده‌آل برای زوج‌ها، خانواده‌ها و تولید محتوای شبکه‌های اجتماعی.',
          minGuests: 1,
          maxGuests: 4,
          remainingCapacity: 2,
          availableTimeSlots: ['08:30', '10:30', '16:00', '17:30'],
          freeCancellation: false,
          cancellationPolicy: ExperienceCancellationPolicy(
            freeCancellationHours: 48,
            lateCancelPenaltyPercent: 100.0,
            policyNotes: 'لغو کمتر از ۴۸ ساعت منجر به جریمه کامل می‌شود.',
          ),
        ),
        const LocalExperienceItemModel(
          schemaVersion: '1.0',
          id: 'local-03',
          title: 'راننده منتسب روزانه با خودروی لوکس اختصاصی در کیش',
          subtitle: '۸ ساعت در اختیار کامل با بنز کلاس E',
          providerName: 'تشریفات خودرویی رنت‌کیش (کاپیتان بهرام)',
          city: 'کیش',
          type: LocalServiceType.chauffeur,
          price: 65.0,
          childPrice: 0.0,
          currency: 'USD',
          pricingType: ExperiencePricingType.perHour,
          durationLabel: '۸ ساعت',
          durationMinutes: 480,
          languages: ['فارسی', 'عربی'],
          rating: 4.85,
          reviewsCount: 76,
          highlights: [
            'خودروی تمیز و ضدعفونی‌شده با کولر پرقدرت',
            'پذیرایی نوشیدنی سرد و اینترنت وای‌فای همراه',
            'آشنایی کامل با تمام مراکز خرید، تفریحات و رستوران‌ها',
          ],
          meetingPoint: 'لابی هتل محل اقامت شما در جزیره کیش',
          description:
              'آسودگی خاطر کامل در طول سفر به جزیره کیش با راننده تشریفاتی اختصاصی. بدون دغدغه گرفتن تاکسی در گرمای هوا، کل جزیره را با آرامش و با بهترین برنامه بگردید.',
          minGuests: 1,
          maxGuests: 6,
          remainingCapacity: 1,
          availableTimeSlots: ['07:00', '08:30', '10:00', '11:00', '14:00'],
          freeCancellation: true,
          cancellationPolicy: ExperienceCancellationPolicy(
            freeCancellationHours: 12,
            lateCancelPenaltyPercent: 20.0,
          ),
        ),
        const LocalExperienceItemModel(
          schemaVersion: '1.0',
          id: 'local-04',
          title: 'همراه فرودگاهی و مترجم همزمان تجاری در دبی (Airport VIP Assistant)',
          subtitle: 'پذیرش و همراهی از پای پرواز تا ترانسفر هتل',
          providerName: 'تیم خدمات فرودگاهی اکسلنت دبی',
          city: 'دبی',
          type: LocalServiceType.meetAndGreet,
          price: 55.0,
          childPrice: 0.0,
          currency: 'USD',
          pricingType: ExperiencePricingType.perGroup,
          durationLabel: 'تا خروج از پایانه',
          durationMinutes: 90,
          languages: ['فارسی', 'انگلیسی', 'عربی', 'روسی'],
          rating: 4.8,
          reviewsCount: 54,
          highlights: [
            'استقبال در سالن ورودی پروازهای بین‌المللی با تابلوی اختصاصی نام مسافر',
            'کمک در دریافت بار و هدایت از گیت‌های کنترل پاسپورت',
            'کمک در تبدیل ارز، تهیه سیم‌کارت و سوار شدن به خودرو',
          ],
          meetingPoint: 'سالن خروجی پروازهای بین‌المللی فرودگاه دبی (DXB Terminal 1/3)',
          description:
              'خدمت اختصاصی برای مسافرانی که برای اولین بار به دبی سفر می‌کنند یا به زبان‌های خارجی مسلط نیستند. میزبان حرفه‌ای ما تمام مراحل فرودگاهی را با احترام و سرعت برای شما تسهیل خواهد کرد.',
          minGuests: 1,
          maxGuests: 10,
          remainingCapacity: 3,
          availableTimeSlots: ['24/7 پشتیبانی'],
          freeCancellation: true,
          cancellationPolicy: ExperienceCancellationPolicy(
            freeCancellationHours: 6,
            lateCancelPenaltyPercent: 0.0,
          ),
        ),
      ];

      allExperiences.assignAll(mockData);
      applyFilters();
      uiState.value =
          filteredExperiences.isEmpty ? ExperienceServiceState.empty : ExperienceServiceState.success;
    } catch (e) {
      errorMessage.value = 'خطا در بارگذاری تجربه‌های محلی: $e';
      uiState.value = ExperienceServiceState.error;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () => applyFilters());
  }

  void applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();
    final results = allExperiences.where((exp) {
      final matchesType = selectedType.value == null || exp.type == selectedType.value;
      final matchesCity = selectedCity.value == 'ALL' || exp.city.contains(selectedCity.value);
      final matchesQuery = query.isEmpty ||
          exp.title.toLowerCase().contains(query) ||
          exp.description.toLowerCase().contains(query) ||
          exp.providerName.toLowerCase().contains(query);
      return matchesType && matchesCity && matchesQuery;
    }).toList();

    filteredExperiences.assignAll(results);
    uiState.value = results.isEmpty ? ExperienceServiceState.empty : ExperienceServiceState.success;
  }

  void resetFilters() {
    selectedType.value = null;
    selectedCity.value = 'ALL';
    searchQuery.value = '';
    applyFilters();
  }

  void setType(LocalServiceType? type) {
    selectedType.value = type;
    applyFilters();
  }

  void setCity(String city) {
    selectedCity.value = city;
    applyFilters();
  }

  String? validateBooking(LocalExperienceItemModel item) {
    if (!item.hasCapacityFor(guestsCount.value, childrenCount.value)) {
      return 'ظرفیت این خدمت برای $guestsCount همراه و $childrenCount کودک کافی نیست. حداکثر ${item.maxGuests} نفر.';
    }
    if (guestsCount.value + childrenCount.value < item.minGuests) {
      return 'حداقل تعداد نفرات لازم: ${item.minGuests}.';
    }
    if (selectedDate.value.isBefore(DateTime.now()) || selectedDate.value.isAtSameMomentAs(DateTime.now())) {
      final now = DateTime.now();
      if (selectedDate.value.year == now.year &&
          selectedDate.value.month == now.month &&
          selectedDate.value.day == now.day) {
        // Same day allowed only if time slot exists
        final validTimes = int.tryParse(selectedTime.value.split(':')[0]) ?? 0;
        if (validTimes >= 23) {
          return 'زمان سرو باید قبل از ۲۳:۰۰ باشد.';
        }
      }
    }
    return null;
  }

  double calculateTotal(LocalExperienceItemModel item) {
    return item.calculateTotal(adults: guestsCount.value, children: childrenCount.value);
  }

  /// Submits local service booking. Tagged MOCK — no `local` travel_service_domain registered at trip.ecardo.ir.
  Future<LocalBookingModel?> bookExperience({required LocalExperienceItemModel item}) async {
    validationError.value = '';
    final vErr = validateBooking(item);
    if (vErr != null) {
      validationError.value = vErr;
      uiState.value = ExperienceServiceState.validationError;
      ToastHelper().showErrorToast(vErr);
      return null;
    }

    uiState.value = ExperienceServiceState.processing;
    try {
      // Network simulation
      await Future.delayed(const Duration(milliseconds: 1100));

      final total = item.calculateTotal(adults: guestsCount.value, children: childrenCount.value);
      final bookingId = 'EXP-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final booking = LocalBookingModel(
        schemaVersion: '1.0',
        bookingId: bookingId,
        serviceId: item.id,
        serviceTitle: item.title,
        providerName: item.providerName,
        city: item.city,
        serviceDate: selectedDate.value,
        serviceTime: selectedTime.value,
        guestsCount: guestsCount.value,
        childrenCount: childrenCount.value,
        totalAmount: total,
        currency: item.currency,
        refundDestinationWalletCurrency: item.currency,
        meetingPoint: item.meetingPoint,
        providerPhone: '+971 50 123 4567',
        status: 'confirmed',
        bookedAt: DateTime.now(),
        cancellationPolicy: item.cancellationPolicy,
      );

      myBookings.insert(0, booking);
      uiState.value = ExperienceServiceState.completed;
      ToastHelper().showSuccessToast('رزرو خدمت محلی با موفقیت ثبت و واچر صادر گردید');
      return booking;
    } catch (e) {
      errorMessage.value = 'خطا در رزرو خدمت: $e';
      uiState.value = ExperienceServiceState.error;
      ToastHelper().showErrorToast('خطا در رزرو خدمت: $e');
      return null;
    }
  }

  Future<bool> cancelBooking(String bookingId, {String? reason}) async {
    final idx = myBookings.indexWhere((b) => b.bookingId == bookingId);
    if (idx < 0) return false;

    final booking = myBookings[idx];
    if (!booking.canCancel) {
      ToastHelper().showErrorToast('این خدمت قابل لغو نیست.');
      return false;
    }

    uiState.value = ExperienceServiceState.processing;
    try {
      await Future.delayed(const Duration(milliseconds: 750));

      final refundCalc = booking.calculateCancellationRefund();
      final updated = booking.copyWithCancelled(
        penalty: refundCalc.penaltyAmount,
        refund: refundCalc.refundableAmount,
        reason: reason ?? refundCalc.policySummary,
      );

      myBookings[idx] = updated;
      uiState.value = ExperienceServiceState.cancelled;

      final msg = refundCalc.isFreeCancellation
          ? 'خدمات با استرداد کامل (${refundCalc.refundableAmount} ${refundCalc.currency}) لغو شد.'
          : 'خدمات لغو شد. مبلغ ${refundCalc.refundableAmount} ${refundCalc.currency} پس از کسر جریمه به کیف پول مسترد شد.';
      ToastHelper().showSuccessToast(msg);
      return true;
    } catch (e) {
      ToastHelper().showErrorToast('خطا در لغو رزرو: $e');
      uiState.value = ExperienceServiceState.error;
      return false;
    }
  }

  void loadSampleBookings() {
    // DATA: MOCK sample bookings demonstrating partial success and various statuses
    myBookings.assignAll([
      LocalBookingModel(
        schemaVersion: '1.0',
        bookingId: 'EXP-48201',
        serviceId: 'local-01',
        serviceTitle: 'راهنمای تور محلی و گشت تاریخی استانبول',
        providerName: 'استاد امین خلیلی',
        city: 'استانبول',
        serviceDate: DateTime.now().add(const Duration(days: 3)),
        serviceTime: '09:30',
        guestsCount: 2,
        childrenCount: 1,
        totalAmount: 135.0, // 45*2 + 20*1
        currency: 'USD',
        refundDestinationWalletCurrency: 'USD',
        meetingPoint: 'میدان سلطان‌احمد، درب اصلی ایاصوفیه',
        providerPhone: '+90 532 111 2233',
        status: 'confirmed',
        bookedAt: DateTime.now().subtract(const Duration(days: 1)),
        cancellationPolicy: const ExperienceCancellationPolicy(
          freeCancellationHours: 24,
          lateCancelPenaltyPercent: 0.0,
        ),
      ),
      LocalBookingModel(
        schemaVersion: '1.0',
        bookingId: 'EXP-42108',
        serviceId: 'local-03',
        serviceTitle: 'راننده منتسب روزانه با خودروی لوکس',
        providerName: 'کاپیتان بهرام',
        city: 'کیش',
        serviceDate: DateTime.now().subtract(const Duration(days: 4)),
        serviceTime: '08:00',
        guestsCount: 3,
        childrenCount: 0,
        totalAmount: 520.0, // 65*8 hours flat-rate
        currency: 'USD',
        refundDestinationWalletCurrency: 'USD',
        meetingPoint: 'لابی هتل هتلوکلا کیش',
        providerPhone: '+98 912 999 8877',
        status: 'completed',
        bookedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      LocalBookingModel(
        schemaVersion: '1.0',
        bookingId: 'EXP-40997',
        serviceId: 'local-02',
        serviceTitle: 'عکاس حرفه‌ای سفر در دبی',
        providerName: 'سارا پرتو',
        city: 'دبی',
        serviceDate: DateTime.now().subtract(const Duration(days: 12)),
        serviceTime: '16:00',
        guestsCount: 2,
        childrenCount: 0,
        totalAmount: 90.0,
        currency: 'USD',
        refundDestinationWalletCurrency: 'USD',
        meetingPoint: 'پل سوق‌البحار',
        providerPhone: '+971 50 777 6655',
        status: 'cancelled',
        bookedAt: DateTime.now().subtract(const Duration(days: 12)),
        cancellationReason:
            'برنامه سفر تغییر کرد — طبق قرارداد ۴۸ ساعتی قبلاً پرداخت شده (بدون جریمه)',
        cancelledAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ]);
  }

  // Utility helpers
  String formattedDate(DateTime date) => DateFormat('yyyy/MM/dd').format(date);
  String formattedTime(String time) => '$time:00';
}
