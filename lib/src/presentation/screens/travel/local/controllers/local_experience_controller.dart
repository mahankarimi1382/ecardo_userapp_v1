import 'package:get/get.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import '../models/local_experience_models.dart';

class LocalExperienceController extends GetxController {
  final RxList<LocalExperienceItemModel> allExperiences = <LocalExperienceItemModel>[].obs;
  final RxList<LocalExperienceItemModel> filteredExperiences = <LocalExperienceItemModel>[].obs;
  final RxList<LocalBookingModel> myBookings = <LocalBookingModel>[].obs;

  final Rx<LocalServiceType?> selectedType = Rx<LocalServiceType?>(null);
  final RxString selectedCity = 'ALL'.obs;

  final RxBool isLoading = false.obs;
  final RxBool isSubmittingBooking = false.obs;

  // Booking Form State
  final Rx<DateTime> selectedDate = DateTime.now().add(const Duration(days: 2)).obs;
  final RxString selectedTime = '09:00'.obs;
  final RxInt guestsCount = 2.obs;

  @override
  void onInit() {
    super.onInit();
    loadCatalog();
    loadSampleBookings();
  }

  void loadCatalog() {
    isLoading.value = true;
    try {
      allExperiences.assignAll([
        const LocalExperienceItemModel(
          id: 'local-01',
          title: 'راهنمای تور محلی و گشت تاریخی استانبول با لیدر مجرب',
          subtitle: 'فارسی‌زبان · گشت نیم‌روز سلطان‌احمد و بسفر',
          providerName: 'استاد امین خلیلی (راهنمای رسمی وزارت گردشگری ترکیه)',
          city: 'استانبول',
          type: LocalServiceType.tourGuide,
          price: 45.0,
          currency: 'USD',
          durationLabel: '۴ ساعت',
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
        ),
        const LocalExperienceItemModel(
          id: 'local-02',
          title: 'عکاس حرفه‌ای سفر در دبی (Dubai Professional Travel Photographer)',
          subtitle: 'دو ساعت عکاسی لوکس + ۳۵ شات ادیت‌شده',
          providerName: 'سارا پرتو (عکاس و ادیتور فشن و توریسم دبی)',
          city: 'دبی',
          type: LocalServiceType.photographer,
          price: 90.0,
          currency: 'USD',
          durationLabel: '۲ ساعت',
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
        ),
        const LocalExperienceItemModel(
          id: 'local-03',
          title: 'راننده منتسب روزانه با خودروی لوکس اختصاصی در کیش',
          subtitle: '۸ ساعت در اختیار کامل با بنز کلاس E',
          providerName: 'تشریفات خودرویی رنت‌کیش (کاپیتان بهرام)',
          city: 'کیش',
          type: LocalServiceType.chauffeur,
          price: 65.0,
          currency: 'USD',
          durationLabel: '۸ ساعت',
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
        ),
        const LocalExperienceItemModel(
          id: 'local-04',
          title: 'همراه فرودگاهی و مترجم همزمان تجاری در دبی (Airport VIP Assistant)',
          subtitle: 'پذیرش و همراهی از پای پرواز تا ترانسفر هتل',
          providerName: 'تیم خدمات فرودگاهی اِکسلنت دبی',
          city: 'دبی',
          type: LocalServiceType.meetAndGreet,
          price: 55.0,
          currency: 'USD',
          durationLabel: 'تا خروج از پایانه',
          languages: ['فارسی', 'انگلیسی', 'عربی', 'روسی'],
          rating: 4.8,
          reviewsCount: 54,
          highlights: [
            'استقبال در سالن ورودی با تابلوی اختصاصی نام مسافر',
            'کمک در دریافت بار و هدایت از گیت‌های کنترل پاسپورت',
            'کمک در تبدیل ارز، تهیه سیم‌کارت و سوار شدن به خودرو',
          ],
          meetingPoint: 'سالن خروجی پروازهای بین‌المللی فرودگاه دبی (DXB Terminal 1/3)',
          description:
              'خدمت اختصاصی برای مسافرانی که برای اولین بار به دبی سفر می‌کنند یا به زبان‌های خارجی مسلط نیستند. میزبان حرفه‌ای ما تمام مراحل فرودگاهی را با احترام و سرعت برای شما تسهیل خواهد کرد.',
        ),
      ]);
      applyFilters();
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    filteredExperiences.assignAll(allExperiences.where((exp) {
      final matchesType = selectedType.value == null || exp.type == selectedType.value;
      final matchesCity = selectedCity.value == 'ALL' || exp.city.contains(selectedCity.value);
      return matchesType && matchesCity;
    }));
  }

  void setType(LocalServiceType? type) {
    selectedType.value = type;
    applyFilters();
  }

  void setCity(String city) {
    selectedCity.value = city;
    applyFilters();
  }

  Future<LocalBookingModel?> bookExperience({
    required LocalExperienceItemModel item,
  }) async {
    isSubmittingBooking.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 1300)); // Simulate checkout

      final booking = LocalBookingModel(
        bookingId: 'EXP-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        serviceId: item.id,
        serviceTitle: item.title,
        providerName: item.providerName,
        city: item.city,
        serviceDate: selectedDate.value,
        serviceTime: selectedTime.value,
        guestsCount: guestsCount.value,
        totalAmount: item.price,
        currency: item.currency,
        meetingPoint: item.meetingPoint,
        providerPhone: '+971 50 123 4567',
        status: 'confirmed',
        bookedAt: DateTime.now(),
      );

      myBookings.insert(0, booking);
      ToastHelper().showSuccessToast('رزرو خدمت محلی با موفقیت ثبت و واچر صادر گردید');
      return booking;
    } catch (e) {
      ToastHelper().showErrorToast('خطا در رزرو خدمت: $e');
      return null;
    } finally {
      isSubmittingBooking.value = false;
    }
  }

  void loadSampleBookings() {
    myBookings.assignAll([
      LocalBookingModel(
        bookingId: 'EXP-48201',
        serviceId: 'local-01',
        serviceTitle: 'راهنمای تور محلی و گشت تاریخی استانبول',
        providerName: 'استاد امین خلیلی',
        city: 'استانبول',
        serviceDate: DateTime.now().add(const Duration(days: 3)),
        serviceTime: '09:30',
        guestsCount: 2,
        totalAmount: 45.0,
        currency: 'USD',
        meetingPoint: 'میدان سلطان‌احمد، درب اصلی ایاصوفیه',
        providerPhone: '+90 532 111 2233',
        status: 'confirmed',
        bookedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }
}
