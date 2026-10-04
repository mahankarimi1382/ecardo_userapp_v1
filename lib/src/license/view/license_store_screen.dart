import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/financial_service_unavailable_banner.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../controller/license_controller.dart';
import '../model/license_models.dart';
import 'license_intro_screen.dart';
import 'license_detail_screen.dart';
import 'license_my_licenses_screen.dart';

class LicenseStoreScreen extends StatefulWidget {
  const LicenseStoreScreen({super.key});

  @override
  State<LicenseStoreScreen> createState() => _LicenseStoreScreenState();
}

class _LicenseStoreScreenState extends State<LicenseStoreScreen> {
  late final LicenseController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LicenseController>()
        ? Get.find<LicenseController>()
        : Get.put(LicenseController());
    controller.fetchCatalog();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              en: 'License Store',
              fa: 'فروشگاه لایسنس',
              ar: 'متجر التراخيص',
              zh: '许可证商店',
            ),
            rightSideWidget: Padding(
              padding: EdgeInsetsDirectional.only(end: AppSpacing.lg.w),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Get.to(() => const LicenseMyLicensesScreen());
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                    border: Border.all(
                      color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.vpn_key_rounded,
                        size: AppSpacing.iconXs.sp,
                        color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        l10nPick(
                          context,
                          en: 'My Vault',
                          fa: 'صندوق من',
                          ar: 'خزينتي',
                          zh: '我的保险库',
                        ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Obx(() {
            if (controller.hasBackendError.value || controller.products.isEmpty) {
              return FinancialServiceUnavailableBanner(
                serviceNameFa: 'فروشگاه لایسنس‌های نرم‌افزار',
                serviceNameEn: 'Software License Store',
                serviceNameAr: 'متجر التراخيص الرقمية',
                serviceNameZh: '数字软件授权商城',
                isCompact: true,
                onRetry: () => controller.fetchCatalog(category: controller.selectedCategory.value),
              );
            }
            return const SizedBox.shrink();
          }),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w, vertical: AppSpacing.xs.h),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Get.to(() => const LicenseIntroScreen()),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: AppSpacing.iconXs.sp,
                            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            l10nPick(context, fa: 'راهنمای لایسنس‌ها', en: 'Licenses Guide', ar: 'دليل التراخيص', zh: '授权指南'),
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm.w),
                Expanded(
                  child: InkWell(
                    onTap: () => Get.to(() => const LicenseMyLicensesScreen()),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield_outlined, size: AppSpacing.iconXs.sp, color: AppColors.success),
                          SizedBox(width: 6.w),
                          Text(
                            l10nPick(context, fa: 'صندوق لایسنس‌های من', en: 'Key Vault', ar: 'خزينة تراخيصي', zh: '我的授权库'),
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildCategoryChips(isDark),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingCatalog.value && controller.products.isEmpty) {
                return _buildCatalogSkeleton(isDark);
              }

              if (controller.products.isEmpty) {
                return Center(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(AppSpacing.xxl.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 40.sp,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.md.h),
                        Text(
                          l10nPick(
                            context,
                            en: 'No licenses available in this category.',
                            fa: 'لایسنسی در این دسته‌بندی یافت نشد.',
                            ar: 'لا توجد تراخيص متاحة في هذا التصنيف.',
                            zh: '该分类下暂无可用许可证。',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.md.h),
                        CommonButton(
                          width: 140,
                          height: 38,
                          text: l10nPick(context, en: 'View All', fa: 'مشاهده همه', ar: 'عرض الكل', zh: '查看全部'),
                          onPressed: () {
                            controller.selectedCategory.value = 'all';
                            controller.fetchCatalog(category: 'all');
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchCatalog(category: controller.selectedCategory.value),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w, vertical: AppSpacing.md.h),
                  itemCount: controller.products.length,
                  separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return _buildProductCard(context, product, isDark: isDark);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogSkeleton(bool isDark) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      itemCount: 4,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
      itemBuilder: (_, _) => Container(
        height: 150.h,
        padding: EdgeInsets.all(AppSpacing.lg.r),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppSpacing.radius.r),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                  ),
                ),
                SizedBox(width: AppSpacing.md.w),
                Expanded(
                  child: Container(
                    height: 18.h,
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md.h),
            Container(
              height: 14.h,
              width: 180.w,
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(bool isDark) {
    final categories = [
      {'key': 'all', 'en': 'All', 'fa': 'همه', 'ar': 'الكل', 'zh': '全部'},
      {'key': 'software', 'en': 'Software', 'fa': 'نرم‌افزار', 'ar': 'البرمجيات', 'zh': '软件'},
      {'key': 'developer', 'en': 'Developer', 'fa': 'توسعه‌دهندگان', 'ar': 'المطورين', 'zh': '开发者'},
      {'key': 'ai', 'en': 'AI Services', 'fa': 'هوش مصنوعی', 'ar': 'الذكاء الاصطناعي', 'zh': '人工智能'},
      {'key': 'security', 'en': 'Security', 'fa': 'امنیت و آنتی‌ویروس', 'ar': 'الأمان', 'zh': '安全'},
    ];

    return Container(
      height: 48.h,
      margin: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => SizedBox(width: AppSpacing.sm.w),
        itemBuilder: (context, i) {
          final cat = categories[i];
          return Obx(() {
            final active = controller.selectedCategory.value == cat['key'];
            return ChoiceChip(
              label: Text(
                l10nPick(
                  context,
                  en: cat['en']!,
                  fa: cat['fa']!,
                  ar: cat['ar'],
                  zh: cat['zh'],
                ),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  color: active
                      ? (isDark ? AppColors.deepBlack : AppColors.white)
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                ),
              ),
              selected: active,
              selectedColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
              onSelected: (val) {
                if (val) {
                  HapticFeedback.selectionClick();
                  controller.selectedCategory.value = cat['key']!;
                  controller.fetchCatalog(category: cat['key']);
                }
              },
            );
          });
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, LicenseProductItem product, {required bool isDark}) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSpacing.radius.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                ),
                child: Icon(
                  Icons.apps_rounded,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  size: AppSpacing.iconMd.sp,
                ),
              ),
              SizedBox(width: AppSpacing.md.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    if (product.vendor != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        product.vendor!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: product.isInStock
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                ),
                child: Text(
                  product.isInStock
                      ? l10nPick(context, en: 'In Stock (${product.stockCount})', fa: 'موجود (${product.stockCount})', ar: 'متوفر', zh: '现货')
                      : l10nPick(context, en: 'Out of Stock', fa: 'ناموجود', ar: 'نفد', zh: '缺货'),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: product.isInStock ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          if (product.description != null) ...[
            SizedBox(height: AppSpacing.sm.h),
            Text(
              product.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                height: 1.3,
              ),
            ),
          ],
          SizedBox(height: AppSpacing.md.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(context, en: 'Starting from', fa: 'شروع قیمت از', ar: 'يبدأ من', zh: '起售价'),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                  Text(
                    '\$${product.priceUsd.toStringAsFixed(2)} USD',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    ),
                  ),
                ],
              ),
              product.isInStock
                  ? CommonButton(
                      width: 120,
                      height: 40,
                      text: l10nPick(
                        context,
                        en: 'Buy License',
                        fa: 'خرید لایسنس',
                        ar: 'شراء الترخيص',
                        zh: '购买许可证',
                      ),
                      fontSize: 13,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Get.to(() => LicenseDetailScreen(product: product));
                      },
                    )
                  : CommonButton(
                      width: 120,
                      height: 40,
                      backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                      textColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      text: l10nPick(
                        context,
                        en: 'Notify Me',
                        fa: 'خبرم کن',
                        ar: 'أعلمني',
                        zh: '通知我',
                      ),
                      fontSize: 13,
                      onPressed: () {
                        HapticFeedback.selectionClick();
                      },
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
