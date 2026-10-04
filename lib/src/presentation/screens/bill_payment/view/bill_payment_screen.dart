import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/view/widgets/recent_favorite_bills_strip.dart';

class BillCategoryItem {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String navigate;
  final Color tintColor;
  final String? badge;
  final String keywords;
  final VoidCallback? onCustomTap;

  const BillCategoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.navigate,
    required this.tintColor,
    this.badge,
    required this.keywords,
    this.onCustomTap,
  });
}

class BillPaymentScreen extends StatefulWidget {
  const BillPaymentScreen({super.key});

  @override
  State<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BillCategoryItem> _buildCategories(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return [
      BillCategoryItem(
        id: 'airtime',
        title: localization?.billPaymentAirtime ?? 'شارژ سیم‌کارت',
        subtitle: 'همراه اول، ایرانسل، رایتل',
        icon: PngAssets.commonAirtimeIcon,
        navigate: BaseRoute.airtime,
        tintColor: const Color(0xFF2563EB),
        badge: 'محبوب',
        keywords: 'airtime mci irancell rightel شارژ سیم کارت همراه اول ایرانسل رایتل شاتل اعتباری',
      ),
      BillCategoryItem(
        id: 'data_bundle',
        title: localization?.billPaymentDataBundle ?? 'بسته اینترنت',
        subtitle: 'بسته‌های 4G / 5G و TD-LTE',
        icon: PngAssets.commonDataBundleIcon,
        navigate: BaseRoute.dataBundle,
        tintColor: const Color(0xFF6366F1),
        badge: 'تخفیف',
        keywords: 'data bundle internet بسته اینترنت همراه دیتا گیگابایت مودم بسته',
      ),
      BillCategoryItem(
        id: 'internet',
        title: localization?.billPaymentInternet ?? 'اینترنت ثابت',
        subtitle: 'مخابرات، شاتل، آسیاتک',
        icon: PngAssets.commonInternetIcon,
        navigate: BaseRoute.internet,
        tintColor: const Color(0xFF8B5CF6),
        keywords: 'internet adsl vdsl ftth شاتل مخابرات آسیاتک اینترنت ثابت پارس آنلاین',
      ),
      BillCategoryItem(
        id: 'electricity',
        title: localization?.billPaymentElectricity ?? 'قبض برق',
        subtitle: 'سامانه سراسری توانیر',
        icon: PngAssets.commonElectricityIcon,
        navigate: BaseRoute.electricity,
        tintColor: const Color(0xFFF59E0B),
        badge: 'فوری',
        keywords: 'electricity power توانیر برق قبض شناسه پرداخت برق سراسری کنتور',
      ),
      BillCategoryItem(
        id: 'water',
        title: 'قبض آب',
        subtitle: 'آب و فاضلاب استانی',
        icon: PngAssets.commonWaterBillIcon,
        navigate: BaseRoute.electricity,
        tintColor: const Color(0xFF06B6D4),
        keywords: 'water bill آب و فاضلاب آبفا قبض آب کنتور آب مصرفی',
        onCustomTap: () {
          Get.toNamed(BaseRoute.electricity, arguments: {
            'service_type': 'water',
            'title': 'قبض آب و فاضلاب',
          });
        },
      ),
      BillCategoryItem(
        id: 'toll',
        title: localization?.billPaymentToll ?? 'عوارض آزادراه',
        subtitle: 'آزادراه‌ها و طرح ترافیک',
        icon: PngAssets.commonTollIcon,
        navigate: BaseRoute.toll,
        tintColor: const Color(0xFF10B981),
        badge: 'تسویه آنی',
        keywords: 'toll road freeway آزادراه عوارض طرح ترافیک پلاک خلافی عوارض خودرویی',
      ),
      BillCategoryItem(
        id: 'cable',
        title: localization?.billPaymentCables ?? 'تلویزیون کابلی',
        subtitle: 'تلویزیون و رسانه تعاملی',
        icon: PngAssets.commonCablesIcon,
        navigate: BaseRoute.cable,
        tintColor: const Color(0xFFF43F5E),
        keywords: 'cable tv iptv فیلمیو نماوا تلویزیون کابلی اشتراک استریم رسانه',
      ),
      BillCategoryItem(
        id: 'government',
        title: 'خدمات دولتی',
        subtitle: 'پلیس راهور، مالیات، شهرداری',
        icon: PngAssets.commonEducationFeeIcon,
        navigate: BaseRoute.toll,
        tintColor: const Color(0xFF64748B),
        badge: 'ملی',
        keywords: 'government tax police خلافی پلیس راهور راهنمایی رانندگی مالیات شهرداری خدمات دولتی',
        onCustomTap: () {
          _showGovernmentServicesSheet(context);
        },
      ),
    ];
  }

  void _showGovernmentServicesSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(
                  Icons.account_balance_rounded,
                  color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                  size: 22.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  'خدمات دولتی و عمومی / Government Services',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.warmWhite : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildGovTile(
              context,
              title: 'استعلام و پرداخت خلافی خودرو و موتور',
              subtitle: 'اتصال به سامانه پلیس راهور ناجا',
              icon: Icons.directions_car_rounded,
              color: const Color(0xFFE11D48),
              onTap: () {
                Get.back();
                Get.toNamed(BaseRoute.toll);
              },
            ),
            _buildGovTile(
              context,
              title: 'عوارض سالیانه شهرداری و نوسازی',
              subtitle: 'سامانه یکپارچه عوارض شهری',
              icon: Icons.location_city_rounded,
              color: const Color(0xFF0D9488),
              onTap: () {
                Get.back();
                Get.toNamed(BaseRoute.electricity);
              },
            ),
            _buildGovTile(
              context,
              title: 'مالیات نقل و انتقال و مالیات خودرو',
              subtitle: 'سازمان امور مالیاتی کشور',
              icon: Icons.receipt_long_rounded,
              color: const Color(0xFF4F46E5),
              onTap: () {
                Get.back();
                ToastHelper().showSuccessToast('اتصال به درگاه سازمان امور مالیاتی کشور');
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildGovTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(vertical: 4.h),
      leading: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.25 : 0.12),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: color, size: 20.w),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.warmWhite : AppColors.lightTextPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 10.sp,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14.w,
        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allCategories = _buildCategories(context);

    final filteredCategories = _searchQuery.isEmpty
        ? allCategories
        : allCategories.where((item) {
            final titleMatch = item.title.toLowerCase().contains(_searchQuery);
            final subtitleMatch = item.subtitle.toLowerCase().contains(_searchQuery);
            final keywordMatch = item.keywords.toLowerCase().contains(_searchQuery);
            return titleMatch || subtitleMatch || keywordMatch;
          }).toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          Get.offNamed(BaseRoute.navigation);
        }
      },
      child: Scaffold(
        appBar: const CommonDefaultAppBar(),
        backgroundColor: isDark ? AppColors.deepBlack : AppColors.lightBackground,
        body: Column(
          children: [
            SizedBox(height: 16.h),
            // Screen Header with History shortcut
            CommonAppBar(
              title: localization?.billPaymentScreenTitle ?? 'پرداخت قبوض و خدمات',
              isBackLogicApply: true,
              backLogicFunction: () async {
                Get.offNamed(BaseRoute.navigation);
              },
              rightSideWidget: GestureDetector(
                onTap: () => Get.toNamed(BaseRoute.billPaymentHistory),
                child: Container(
                  padding: EdgeInsets.all(7.w),
                  margin: EdgeInsetsDirectional.only(end: 18.w),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.mainSoftBlue : AppColors.deepBlack)
                        .withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    PngAssets.commonHistoryIcon,
                    width: 22.w,
                    color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                  ),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            // Search Bar with instant live filtering
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? AppColors.warmWhite : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'جستجوی خدمات، اپراتور یا قبض (همراه اول، برق، آب...)',
                    hintStyle: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 20.w,
                      color: isDark ? AppColors.mainSoftBlue : AppColors.softGray,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              size: 18.w,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // Main Content ScrollView
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recent & Favorite Bills Strip (when not searching)
                    if (_searchQuery.isEmpty) ...[
                      const RecentFavoriteBillsStrip(),
                      SizedBox(height: 20.h),
                    ],
                    // Section Title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _searchQuery.isEmpty
                                ? 'خدمات و قبوض / Hub Services'
                                : 'نتایج جستجو (${filteredCategories.length} مورد)',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.warmWhite : AppColors.lightTextPrimary,
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () => _searchController.clear(),
                              child: Text(
                                'پاک کردن فیلتر',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.mainSoftBlue : AppColors.mutedBlue,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Grid of Service Categories
                    if (filteredCategories.isEmpty)
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(18.w),
                        padding: EdgeInsets.all(28.w),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 44.w,
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'خدماتی متناسب با جستجوی شما یافت نشد',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.warmWhite : AppColors.lightTextPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'کلمات کلیدی دیگری مانند شارژ، برق، عوارض یا آب را امتحان کنید.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredCategories.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 1.35,
                          ),
                          itemBuilder: (context, index) {
                            final category = filteredCategories[index];
                            return _ServiceGridCard(
                              category: category,
                              isDark: isDark,
                              onTap: () {
                                if (category.onCustomTap != null) {
                                  category.onCustomTap!();
                                } else {
                                  Get.toNamed(category.navigate);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    SizedBox(height: 24.h),
                    // Promotional & Cashback Banner
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [
                                    const Color(0xFF1E2E42),
                                    const Color(0xFF161614),
                                  ]
                                : [
                                    AppColors.mainSoftBlue.withValues(alpha: 0.18),
                                    const Color(0xFFF0EDEC),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: (isDark ? AppColors.mainSoftBlue : AppColors.deepBlack)
                                    .withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.card_giftcard_rounded,
                                size: 22.w,
                                color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '۲٪ پاداش نقدی در کیف پول eCardo',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.warmWhite : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'با پرداخت هر قبض یا خرید بسته، کش‌بک آنی دریافت کنید.',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
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

class _ServiceGridCard extends StatelessWidget {
  final BillCategoryItem category;
  final bool isDark;
  final VoidCallback onTap;

  const _ServiceGridCard({
    required this.category,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42.w,
                      height: 42.w,
                      decoration: BoxDecoration(
                        color: category.tintColor.withValues(alpha: isDark ? 0.22 : 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Image.asset(
                          category.icon,
                          width: 24.w,
                          height: 24.w,
                          color: category.tintColor,
                        ),
                      ),
                    ),
                    if (category.badge != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: category.tintColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          category.badge!,
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: category.tintColor,
                          ),
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.warmWhite : AppColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      category.subtitle,
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
