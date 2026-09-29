
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_theme.dart';
import '../controllers/tour_controller.dart';
import '../models/tour_model.dart';
import 'tour_detail_screen.dart';

class TourMatchScreen extends StatefulWidget {
  const TourMatchScreen({super.key});

  @override
  State<TourMatchScreen> createState() => _TourMatchScreenState();
}

class _TourMatchScreenState extends State<TourMatchScreen> {
  final TourController controller = Get.find<TourController>();
  bool showResults = false;

  final List<Map<String, dynamic>> questions = [
    {
      'key': 'q1',
      'title_fa': 'وضعیت تأهل شما چگونه است؟',
      'title_en': 'What is your marital status?',
      'subtitle_fa': 'برای تنظیم سبک اقامت و هتل‌های متناسب',
      'subtitle_en': 'To tailor accommodation and hotel style',
      'options': [
        {'id': 'single', 'label_fa': 'مجرد / انفرادی', 'label_en': 'Single', 'icon': Icons.person_rounded},
        {'id': 'married', 'label_fa': 'متأهل / زوج', 'label_en': 'Married / Couple', 'icon': Icons.favorite_rounded},
      ],
      'multi': false,
    },
    {
      'key': 'q2',
      'title_fa': 'آیا در این سفر کودک زیر ۱۲ سال همراه دارید؟',
      'title_en': 'Are you traveling with children under 12?',
      'subtitle_fa': 'جهت پیشنهاد هتل‌های با کلاب کودک و برنامه‌های متناسب',
      'subtitle_en': 'For kid-friendly hotels and pacing',
      'options': [
        {'id': 'no_kids', 'label_fa': 'خیر، همگی بزرگسال هستیم', 'label_en': 'No, adults only', 'icon': Icons.groups_rounded},
        {'id': 'kids', 'label_fa': 'بله، کودک همراه داریم', 'label_en': 'Yes, with children', 'icon': Icons.child_care_rounded},
      ],
      'multi': false,
    },
    {
      'key': 'q3',
      'title_fa': 'ترکیب همسفران شما در این سفر چیست؟',
      'title_en': 'Who are you traveling with?',
      'subtitle_fa': 'انتخاب برنامه گروهی یا خصوصی',
      'subtitle_en': 'Select group vs private model',
      'options': [
        {'id': 'solo', 'label_fa': 'تک‌نفره (سلو)', 'label_en': 'Solo Traveler', 'icon': Icons.person_pin_circle_rounded},
        {'id': 'friends', 'label_fa': 'با اکیپ دوستان', 'label_en': 'With Friends', 'icon': Icons.celebration_rounded},
        {'id': 'family', 'label_fa': 'خانوادگی', 'label_en': 'Family', 'icon': Icons.family_restroom_rounded},
        {'id': 'business', 'label_fa': 'همکاران / کاری', 'label_en': 'Business', 'icon': Icons.business_center_rounded},
      ],
      'multi': false,
    },
    {
      'key': 'q4',
      'title_fa': 'بازه بودجه تقریبی برای هر نفر چقدر است؟',
      'title_en': 'Approximate budget per traveler?',
      'subtitle_fa': 'پکیج‌های هم‌تراز با قدرت خرید شما',
      'subtitle_en': 'Packages matching your purchasing power',
      'options': [
        {'id': 'budget_eco', 'label_fa': 'اقتصادی و بهینه', 'label_en': 'Economy & Value', 'icon': Icons.savings_rounded},
        {'id': 'budget_std', 'label_fa': 'متوسط و استاندارد', 'label_en': 'Standard Comfort', 'icon': Icons.account_balance_wallet_rounded},
        {'id': 'budget_lux', 'label_fa': 'لوکس و VIP', 'label_en': 'Luxury & VIP', 'icon': Icons.diamond_rounded},
      ],
      'multi': false,
    },
    {
      'key': 'q5',
      'title_fa': 'چه سبک تفریحاتی بیشتر شما را به وجد می‌آورد؟',
      'title_en': 'Which travel experiences excite you most?',
      'subtitle_fa': 'می‌توانید تا ۳ مورد را انتخاب کنید',
      'subtitle_en': 'Select up to 3 options',
      'options': [
        {'id': 'nature', 'label_fa': 'طبیعت‌گردی و کوهستان', 'label_en': 'Nature & Mountains', 'icon': Icons.terrain_rounded},
        {'id': 'cultural', 'label_fa': 'تاریخ، هنر و موزه', 'label_en': 'History & Culture', 'icon': Icons.museum_rounded},
        {'id': 'beach', 'label_fa': 'ساحل، آفتاب و ورزش آبی', 'label_en': 'Beach & Water Sports', 'icon': Icons.beach_access_rounded},
        {'id': 'shopping', 'label_fa': 'خرید و مراکز مدرن', 'label_en': 'Shopping & Malls', 'icon': Icons.shopping_bag_rounded},
        {'id': 'adventure', 'label_fa': 'ماجراجویی و آدرنالین', 'label_en': 'Adventure & Safari', 'icon': Icons.kayaking_rounded},
        {'id': 'wellness', 'label_fa': 'آرامش، اسپا و ریلکس', 'label_en': 'Wellness & Spa', 'icon': Icons.spa_rounded},
      ],
      'multi': true,
    },
    {
      'key': 'q6',
      'title_fa': 'ریتم دلخواه شما در سفر چگونه است؟',
      'title_en': 'What is your preferred travel rhythm?',
      'subtitle_fa': 'تراکم برنامه‌های روزانه گشت شهری',
      'subtitle_en': 'Daily itinerary density',
      'options': [
        {'id': 'fast_pace', 'label_fa': 'پرانرژی؛ هر روز کلی جا ببینیم', 'label_en': 'High Energy & Packed', 'icon': Icons.bolt_rounded},
        {'id': 'relaxed', 'label_fa': 'آرام؛ با خواب کافی و زمان آزاد', 'label_en': 'Relaxed & Flexible', 'icon': Icons.nightlife_rounded},
      ],
      'multi': false,
    },
    {
      'key': 'q7',
      'title_fa': 'مدت زمان مطلوب شما برای این سفر چقدر است؟',
      'title_en': 'Ideal duration for this tour?',
      'subtitle_fa': 'تعداد روزهای اقامت در مقصد',
      'subtitle_en': 'Length of stay',
      'options': [
        {'id': 'short_trip', 'label_fa': 'کوتاه (۳ تا ۵ روز)', 'label_en': 'Short (3-5 days)', 'icon': Icons.timer_3_rounded},
        {'id': 'medium_trip', 'label_fa': 'متوسط (۶ تا ۸ روز)', 'label_en': 'Medium (6-8 days)', 'icon': Icons.date_range_rounded},
        {'id': 'long_trip', 'label_fa': 'طولانی (۹ روز به بالا)', 'label_en': 'Long (9+ days)', 'icon': Icons.calendar_month_rounded},
      ],
      'multi': false,
    },
    {
      'key': 'q8',
      'title_fa': 'ترجیح اصلی شما در محل اقامت چیست؟',
      'title_en': 'Main accommodation preference?',
      'subtitle_fa': 'نوع و درجه هتل پکیج',
      'subtitle_en': 'Hotel tier & atmosphere',
      'options': [
        {'id': 'hostel', 'label_fa': 'بوم‌گردی و هاستل‌های سنتی', 'label_en': 'Eco-lodge / Hostel', 'icon': Icons.cabin_rounded},
        {'id': 'std_hotel', 'label_fa': 'هتل استاندارد ۳ یا ۴ ستاره', 'label_en': 'Standard 3-4 Star Hotel', 'icon': Icons.hotel_rounded},
        {'id': 'resort', 'label_fa': 'هتل ۵ ستاره و ریزورت لوکس', 'label_en': '5-Star Resort & Spa', 'icon': Icons.star_rate_rounded},
      ],
      'multi': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (showResults) {
      return _buildResultsView();
    }

    return Obx(() {
      final step = controller.quizStep.value;
      final q = questions[step];
      final isLastStep = step == questions.length - 1;

      return Scaffold(
        backgroundColor: TravelTheme.background,
        appBar: AppBar(
          title: Text(
            l10nPick(context, en: 'Tour-Yar Smart Match', fa: 'تور-یار هوشمند eCardo'),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: TravelTheme.ink),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: TravelTheme.ink),
            onPressed: () {
              if (step > 0) {
                controller.previousQuizStep();
              } else {
                Get.back();
              }
            },
          ),
        ),
        body: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (step + 1) / questions.length,
              backgroundColor: TravelTheme.border,
              valueColor: const AlwaysStoppedAnimation<Color>(TravelTheme.blue),
              minHeight: 4.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10nPick(context, en: 'Question', fa: 'پرسش')} ${step + 1} ${l10nPick(context, en: 'of', fa: 'از')} ${questions.length}',
                    style: TextStyle(fontSize: 12.sp, color: TravelTheme.blue, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${(((step + 1) / questions.length) * 100).toInt()}%',
                    style: TextStyle(fontSize: 12.sp, color: TravelTheme.muted, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                children: [
                  SizedBox(height: 8.h),
                  Text(
                    l10nPick(context, en: q['title_en'], fa: q['title_fa']),
                    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w900, color: TravelTheme.ink, height: 1.3),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    l10nPick(context, en: q['subtitle_en'], fa: q['subtitle_fa']),
                    style: TextStyle(fontSize: 12.sp, color: TravelTheme.muted),
                  ),
                  SizedBox(height: 20.h),
                  ...((q['options'] as List).map((opt) {
                    final isMulti = q['multi'] == true;
                    final currentVal = controller.quizAnswers[q['key']];
                    final isSelected = isMulti
                        ? (currentVal is List && currentVal.contains(opt['id']))
                        : (currentVal == opt['id']);

                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: InkWell(
                        onTap: () {
                          if (isMulti) {
                            final list = List<String>.from(currentVal is List ? currentVal : []);
                            if (list.contains(opt['id'])) {
                              list.remove(opt['id']);
                            } else {
                              if (list.length < 3) list.add(opt['id']);
                            }
                            controller.answerQuiz(q['key'], list);
                          } else {
                            controller.answerQuiz(q['key'], opt['id']);
                            if (!isLastStep) {
                              controller.nextQuizStep();
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(16.r),
                        child: Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: isSelected ? TravelTheme.blue.withValues(alpha: 0.08) : Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isSelected ? TravelTheme.blue : TravelTheme.border,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: TravelTheme.shadow,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44.r,
                                height: 44.r,
                                decoration: BoxDecoration(
                                  color: isSelected ? TravelTheme.blue : TravelTheme.background,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  opt['icon'] as IconData,
                                  color: isSelected ? Colors.white : TravelTheme.ink,
                                  size: 22.r,
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Text(
                                  l10nPick(context, en: opt['label_en'], fa: opt['label_fa']),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? TravelTheme.blue : TravelTheme.ink,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, color: TravelTheme.blue),
                            ],
                          ),
                        ),
                      ),
                    );
                  })),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    if (step > 0)
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          ),
                          onPressed: () => controller.previousQuizStep(),
                          child: Text(l10nPick(context, en: 'Previous', fa: 'مرحله قبل')),
                        ),
                      ),
                    if (step > 0) SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TravelTheme.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        onPressed: () async {
                          if (isLastStep) {
                            await controller.submitQuiz();
                            setState(() {
                              showResults = true;
                            });
                          } else {
                            controller.nextQuizStep();
                          }
                        },
                        child: Obx(() => controller.isMatching.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                isLastStep
                                    ? l10nPick(context, en: 'Find My Matching Tours', fa: 'مشاهده تورهای پیشنهادی من')
                                    : l10nPick(context, en: 'Next Question', fa: 'سوال بعدی'),
                                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                              )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildResultsView() {
    return Scaffold(
      backgroundColor: TravelTheme.background,
      appBar: AppBar(
        title: Text(
          l10nPick(context, en: 'Your Matched Tours', fa: 'تورهای پیشنهادی تور-یار'),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: TravelTheme.ink),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: TravelTheme.ink),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isMatching.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final tours = controller.matchedTours;
        if (tours.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sentiment_dissatisfied_rounded, size: 64.r, color: TravelTheme.muted),
                SizedBox(height: 12.h),
                Text(
                  l10nPick(context, en: 'No exact matches found', fa: 'توری با تطابق ۱۰۰٪ یافت نشد'),
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showResults = false;
                      controller.resetQuiz();
                    });
                  },
                  child: Text(l10nPick(context, en: 'Retake Quiz', fa: 'تکرار کوییز')),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: TravelTheme.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: TravelTheme.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, color: TravelTheme.green, size: 28),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      l10nPick(
                        context,
                        en: 'Based on your answers, these packages best match your taste and budget!',
                        fa: 'بر اساس پاسخ‌های شما، این پکیج‌ها بیشترین تطابق را با روحیه، سبک و بودجه شما دارند!',
                      ),
                      style: TextStyle(fontSize: 12.sp, color: TravelTheme.ink, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            ...tours.map((tour) {
              return Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: TravelTheme.shadow,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      controller.loadTourDetail(tour.id);
                      Get.to(() => TourDetailScreen(tourId: tour.id));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (tour.featuredImage != null && tour.featuredImage!.startsWith('http'))
                          SizedBox(
                            height: 130.h,
                            width: double.infinity,
                            child: Image.network(tour.featuredImage!, fit: BoxFit.cover),
                          ),
                        Padding(
                          padding: EdgeInsets.all(14.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    tour.title,
                                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                                  ),
                                  if (tour.matchPercentage != null)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                      decoration: BoxDecoration(
                                        color: TravelTheme.green,
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Text(
                                        '${tour.matchPercentage}% تطابق',
                                        style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                '${tour.city} • ${tour.durationDays} روز • قیمت از: ${tour.basePrice.toInt()} ${tour.currency}',
                                style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}

