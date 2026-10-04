import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/financial_service_unavailable_banner.dart';
import '../../helper/l10n_pick.dart';
import '../controllers/visa_controller.dart';
import '../models/visa_models.dart';
import '../widgets/visa_widgets.dart';
import 'visa_intro_screen.dart';
import 'visa_list_screen.dart';
import 'visa_requirements_screen.dart';

class VisaCatalogScreen extends StatefulWidget {
  const VisaCatalogScreen({super.key});

  @override
  State<VisaCatalogScreen> createState() => _VisaCatalogScreenState();
}

class _VisaCatalogScreenState extends State<VisaCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<VisaController>()
        ? Get.find<VisaController>()
        : Get.put(VisaController());

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'خدمات ویزا و کنسولی',
              en: 'Visa & Consular Desk',
              ar: 'خدمات التأشيرات والقنصلية',
              zh: '签证与领事服务',
            ),
            rightSideWidget: Padding(
              padding: EdgeInsetsDirectional.only(end: 16.w),
              child: IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Get.to(() => const VisaListScreen());
                },
                tooltip: l10nPick(context, en: 'My Visas', fa: 'درخواست‌های من', ar: 'تأشيراتي', zh: '我的申请'),
                icon: Icon(
                  Icons.history_rounded,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadCatalog,
        color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg.w,
            vertical: AppSpacing.md.h,
          ),
          children: [
            // Notice banner if backend error or catalog empty
            Obx(() {
              if (controller.hasBackendError.value || controller.catalogList.isEmpty) {
                return FinancialServiceUnavailableBanner(
                  serviceNameFa: 'ویزا و خدمات کنسولی',
                  serviceNameEn: 'Visa & Consular Service',
                  serviceNameAr: 'خدمات التأشيرات والقنصلية',
                  serviceNameZh: '签证及领事服务',
                  onRetry: controller.loadCatalog,
                );
              }
              return const SizedBox.shrink();
            }),

            SizedBox(height: AppSpacing.xs.h),

            // Quick action cards
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    context,
                    isDark: isDark,
                    icon: Icons.menu_book_rounded,
                    titleFa: 'راهنمای انواع ویزا',
                    titleEn: 'Visa Guide',
                    color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                    onTap: () => Get.to(() => const VisaIntroScreen()),
                  ),
                ),
                SizedBox(width: AppSpacing.cardGap.w),
                Expanded(
                  child: _buildActionTile(
                    context,
                    isDark: isDark,
                    icon: Icons.history_edu_rounded,
                    titleFa: 'پیگیری پرونده‌ها',
                    titleEn: 'My Applications',
                    color: AppColors.success,
                    onTap: () => Get.to(() => const VisaListScreen()),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.lg.h),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim().toLowerCase();
                  });
                },
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  fontSize: 13.sp,
                ),
                decoration: InputDecoration(
                  hintText: l10nPick(
                    context,
                    en: 'Search destination country or visa...',
                    fa: 'جستجوی کشور مقصد یا نوع ویزا...',
                    ar: 'البحث عن الدولة أو نوع التأشيرة...',
                    zh: '搜索目的地国家或签证类型...',
                  ),
                  hintStyle: TextStyle(
                    fontSize: 12.5.sp,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),

            SizedBox(height: AppSpacing.lg.h),

            // Hero Promotion Banner
            Container(
              padding: EdgeInsets.all(AppSpacing.lg.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                gradient: const LinearGradient(
                  colors: [AppColors.deepBlack, AppColors.darkGray],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10nPick(
                            context,
                            en: 'Fast & Reliable E-Visa',
                            fa: 'صدور سریع و مطمئن ویزای الکترونیک',
                            ar: 'إصدار سريع وموثوق للتأشيرات الإلكترونية',
                            zh: '快捷可信的电子签证申请通道',
                          ),
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs.h),
                        Text(
                          l10nPick(
                            context,
                            en: 'Apply online in minutes with 100% consultant review guarantee.',
                            fa: 'درخواست آنلاین در چند دقیقه با بررسی تخصصی کارشناسان رسمی سفر.',
                            ar: 'تقديم الطلب في دقائق مع تدقيق الخبراء المتخصصين.',
                            zh: '数分钟内完成线上申报，专属领事专家全程预审护航。',
                          ),
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.9),
                            fontSize: 11.sp,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Icon(
                    Icons.flight_takeoff_rounded,
                    color: AppColors.white.withValues(alpha: 0.8),
                    size: 40.r,
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.xl.h),

            // Catalog Header
            Text(
              l10nPick(
                context,
                en: 'Available Destinations',
                fa: 'مقاصد فعال ویزا',
                ar: 'الوجهات المتاحة',
                zh: '可办理的目的地国家',
              ),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),

            // Catalog List (4 States)
            Obx(() {
              // 1. Loading Shimmer
              if (controller.isLoadingCatalog.value && controller.catalogList.isEmpty) {
                return _buildCatalogSkeleton(isDark);
              }

              // 2. Service Unavailable Error
              if (controller.isServiceUnavailable.value) {
                return Container(
                  margin: EdgeInsetsDirectional.only(top: AppSpacing.sm.h),
                  padding: EdgeInsetsDirectional.all(AppSpacing.xl.r),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md.r),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_off_rounded,
                          color: AppColors.warning,
                          size: 40.r,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Visa Service Temporarily Unavailable',
                          fa: 'سرویس آنلاین ویزا موقتاً در دسترس نیست',
                          ar: 'خدمة التأشيرات غير متوفرة مؤقتاً',
                          zh: '在线签证申请服务暂不可用',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'The visa catalog is undergoing backend partner integration. Please retry shortly.',
                          fa: 'ارتباط با سامانه مرکزی صدور روادید بین‌المللی در دست اتصال است. لطفاً بعداً تلاش فرمایید.',
                          ar: 'خوادم التأشيرات الدولية قيد التحديث مع الجهات المعتمدة.',
                          zh: '全球签证服务接口正在与合作伙伴联调中，请稍后重试。',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                          fontSize: 11.5.sp,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                          foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                          ),
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: AppSpacing.xl.w,
                            vertical: AppSpacing.sm.h,
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          controller.loadCatalog();
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(
                          l10nPick(
                            context,
                            en: 'Retry Connection',
                            fa: 'تلاش مجدد',
                            ar: 'إعادة المحاولة',
                            zh: '重试连接',
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final items = controller.catalogList.where((it) {
                if (_searchQuery.isEmpty) return true;
                return it.countryName.toLowerCase().contains(_searchQuery) ||
                    it.title.toLowerCase().contains(_searchQuery) ||
                    it.countryCode.toLowerCase().contains(_searchQuery);
              }).toList();

              // 3. Empty Search State
              if (items.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(AppSpacing.xxl.r),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.travel_explore_rounded,
                        size: 48.r,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'No visa packages found',
                          fa: 'هیچ ویزایی با این مشخصات یافت نشد',
                          ar: 'لم يتم العثور على أي باقات تأشيرة',
                          zh: '未找到符合条件的签证项目',
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.sp,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'You can review requirements and the application guide in the meantime.',
                          fa: 'می‌توانید شرایط عمومی مدارک و مراحل درخواست را در بخش راهنما مشاهده فرمایید.',
                          ar: 'يمكنك الاطلاع على شروط الوثائق في قسم الدليل.',
                          zh: '您可以在等待期间查阅签证申请通用材料指南。',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                          fontSize: 11.5.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // 4. Content State
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
                itemBuilder: (context, idx) {
                  final item = items[idx];
                  return VisaCatalogCard(
                    item: item,
                    isDark: isDark,
                    onTap: () {
                      controller.selectCatalog(item);
                      Get.to(() => VisaRequirementsScreen(item: item));
                    },
                  );
                },
              );
            }),
            SizedBox(height: AppSpacing.xxxl.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogSkeleton(bool isDark) {
    final baseColor = isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade300;
    final highlightColor = isDark ? AppColors.darkSurface : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: List.generate(
          3,
          (_) => Container(
            margin: EdgeInsets.only(bottom: AppSpacing.cardGap.h),
            height: 100.h,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String titleFa,
    required String titleEn,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: AppSpacing.iconSm.r),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Text(
              l10nPick(context, fa: titleFa, en: titleEn),
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VisaCatalogCard extends StatelessWidget {
  final VisaCatalogItem item;
  final bool isDark;
  final VoidCallback onTap;

  const VisaCatalogCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return VisaCard(
      onTap: onTap,
      padding: EdgeInsets.all(AppSpacing.lg.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          VisaCountryFlag(flagUrl: item.countryFlag, size: 48),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.countryName,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm.w, vertical: AppSpacing.xs.h),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                      ),
                      child: Text(
                        '${item.processingDaysMin}-${item.processingDaysMax} ${l10nPick(context, en: 'days', fa: 'روز')}',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs.h),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10nPick(context, en: 'From', fa: 'شروع از')}: \$${item.totalFee.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          l10nPick(context, en: 'Details', fa: 'شرایط و مدارک'),
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16.r,
                          color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
