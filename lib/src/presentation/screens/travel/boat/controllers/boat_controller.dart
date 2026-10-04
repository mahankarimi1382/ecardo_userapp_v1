import 'package:get/get.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import '../models/boat_models.dart';

class BoatController extends GetxController {
  final RxList<BoatExperienceModel> allBoats = <BoatExperienceModel>[].obs;
  final RxList<BoatExperienceModel> filteredBoats = <BoatExperienceModel>[].obs;
  final RxList<BoatBookingModel> myBookings = <BoatBookingModel>[].obs;

  final Rx<BoatCategory?> selectedCategory = Rx<BoatCategory?>(null);
  final RxString selectedCity = 'ALL'.obs;

  final RxBool isLoadingCatalog = false.obs;
  final RxBool isSubmittingBooking = false.obs;

  // Booking Builder State
  final RxInt selectedDurationHours = 2.obs;
  final RxString selectedTimeSlot = ''.obs;
  final RxInt passengerCount = 2.obs;
  final RxList<String> selectedAddons = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCatalog();
    loadSampleBookings();
  }

  void loadCatalog() {
    isLoadingCatalog.value = true;
    try {
      allBoats.assignAll([
        const BoatExperienceModel(
          id: 'boat-01',
          title: 'کشتی تفریحی و یات لوکس سان‌سیکر ۵۵ (Sunseeker 55ft Luxury Yacht)',
          marinaName: 'اسکله تفریحی میرمهنا، کیش',
          city: 'کیش (Kish Island)',
          category: BoatCategory.yacht,
          hourlyRate: 120.0,
          currency: 'USD',
          maxPassengers: 12,
          lengthMeters: 17.5,
          rating: 4.9,
          reviewsCount: 84,
          captainName: 'کاپیتان آرش علیزاده',
          images: [],
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
        ),
        const BoatExperienceModel(
          id: 'boat-02',
          title: 'قایق تندرو اسپرت اوشن مستر ۳۱ (Ocean Master Offshore Speedboat)',
          marinaName: 'دبی مارینا (Dubai Marina Pier 7)',
          city: 'دبی (Dubai)',
          category: BoatCategory.speedboat,
          hourlyRate: 85.0,
          currency: 'USD',
          maxPassengers: 6,
          lengthMeters: 9.8,
          rating: 4.8,
          reviewsCount: 112,
          captainName: 'کاپیتان طارق منصور',
          images: [],
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
        ),
        const BoatExperienceModel(
          id: 'boat-03',
          title: 'کاتاماران دوطبقه بادبانی بوسفوروس (Bosphorus Sailing Catamaran)',
          marinaName: 'مارینای ببک، استانبول',
          city: 'استانبول (Istanbul)',
          category: BoatCategory.catamaran,
          hourlyRate: 95.0,
          currency: 'USD',
          maxPassengers: 20,
          lengthMeters: 14.2,
          rating: 4.95,
          reviewsCount: 160,
          captainName: 'کاپیتان مراد ییلماز',
          images: [],
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
        ),
      ]);
      applyFilters();
    } finally {
      isLoadingCatalog.value = false;
    }
  }

  void applyFilters() {
    filteredBoats.assignAll(allBoats.where((boat) {
      final matchesCategory = selectedCategory.value == null || boat.category == selectedCategory.value;
      final matchesCity = selectedCity.value == 'ALL' || boat.city.contains(selectedCity.value);
      return matchesCategory && matchesCity;
    }));
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
    final basePrice = boat.hourlyRate * selectedDurationHours.value;
    double addonsTotal = 0.0;
    for (final addonId in selectedAddons) {
      final addon = boat.addons.firstWhereOrNull((a) => a.id == addonId);
      if (addon != null) {
        if (addon.unit.contains('نفر')) {
          addonsTotal += addon.price * passengerCount.value;
        } else {
          addonsTotal += addon.price;
        }
      }
    }
    return basePrice + addonsTotal;
  }

  Future<BoatBookingModel?> bookBoat({
    required BoatExperienceModel boat,
  }) async {
    isSubmittingBooking.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 1400)); // Network simulation

      final total = calculateTotalPrice(boat);
      final booking = BoatBookingModel(
        bookingId: 'SEA-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        boatId: boat.id,
        boatTitle: boat.title,
        marinaName: boat.marinaName,
        date: DateTime.now().add(const Duration(days: 2)),
        timeSlot: selectedTimeSlot.value.isNotEmpty ? selectedTimeSlot.value : boat.availableSlots.first,
        durationHours: selectedDurationHours.value,
        passengersCount: passengerCount.value,
        selectedAddonIds: List.from(selectedAddons),
        totalAmount: total,
        currency: boat.currency,
        captainPhone: '+98 912 884 9201',
        pierDockNumber: 'Dock C - Berthing #14',
        status: 'confirmed',
        bookedAt: DateTime.now(),
      );

      myBookings.insert(0, booking);
      ToastHelper().showSuccessToast('رزرو گشت دریایی با موفقیت تأیید و بلیت صادر شد');
      return booking;
    } catch (e) {
      ToastHelper().showErrorToast('خطا در ثبت رزرو: $e');
      return null;
    } finally {
      isSubmittingBooking.value = false;
    }
  }

  void loadSampleBookings() {
    myBookings.assignAll([
      BoatBookingModel(
        bookingId: 'SEA-88492',
        boatId: 'boat-01',
        boatTitle: 'کشتی تفریحی سان‌سیکر ۵۵ (Sunseeker 55ft Luxury Yacht)',
        marinaName: 'اسکله تفریحی میرمهنا، کیش',
        date: DateTime.now().add(const Duration(days: 1)),
        timeSlot: '17:00 - 19:00 (سانس طلایی غروب کیش 🌅)',
        durationHours: 2,
        passengersCount: 4,
        selectedAddonIds: ['snorkeling'],
        totalAmount: 300.0,
        currency: 'USD',
        captainPhone: '+98 912 884 9201',
        pierDockNumber: 'Dock B - Pier #8',
        status: 'confirmed',
        bookedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ]);
  }
}
