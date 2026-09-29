import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../controller/license_controller.dart';
import '../model/license_models.dart';
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
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
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
              padding: EdgeInsetsDirectional.only(end: 16.w),
              child: InkWell(
                onTap: () => Get.to(() => const LicenseMyLicensesScreen()),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.lightPrimary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.vpn_key_rounded, size: 16.sp, color: AppColors.lightPrimary),
                      SizedBox(width: 4.w),
                      Text(
                        l10nPick(
                          context,
                          en: 'My Licenses',
                          fa: 'لایسنس‌های من',
                          ar: 'تراخيصي',
                          zh: '我的许可证',
                        ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.lightPrimary,
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
          _buildCategoryChips(),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingCatalog.value && controller.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64.sp, color: Colors.grey.shade400),
                      SizedBox(height: 12.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'No licenses available in this category.',
                          fa: 'لایسنسی در این دسته‌بندی یافت نشد.',
                          ar: 'لا توجد تراخيص متاحة.',
                          zh: '没有可用的许可证。',
                        ),
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchCatalog(category: controller.selectedCategory.value),
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: controller.products.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return _buildProductCard(context, product);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = [
      {'key': 'all', 'en': 'All', 'fa': 'همه', 'ar': 'الكل', 'zh': '全部'},
      {'key': 'software', 'en': 'Software', 'fa': 'نرم‌افزار', 'ar': 'البرمجيات', 'zh': '软件'},
      {'key': 'developer', 'en': 'Developer', 'fa': 'توسعه‌دهندگان', 'ar': 'المطورين', 'zh': '开发者'},
      {'key': 'ai', 'en': 'AI Services', 'fa': 'هوش مصنوعی', 'ar': 'الذكاء الاصطناعي', 'zh': '人工智能'},
      {'key': 'security', 'en': 'Security', 'fa': 'امنیت و آنتی‌ویروس', 'ar': 'الأمان', 'zh': '安全'},
    ];

    return Container(
      height: 48.h,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final isSelected = controller.selectedCategory.value == cat['key'];
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
                  color: active ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              selected: active,
              selectedColor: AppColors.lightPrimary,
              backgroundColor: Colors.white,
              onSelected: (val) {
                if (val) {
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

  Widget _buildProductCard(BuildContext context, LicenseProductItem product) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                  color: AppColors.lightPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.apps_rounded, color: AppColors.lightPrimary, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    if (product.vendor != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        product.vendor!,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: product.isInStock ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  product.isInStock
                      ? l10nPick(context, en: 'In Stock (${product.stockCount})', fa: 'موجود در انبار (${product.stockCount})')
                      : l10nPick(context, en: 'Out of Stock', fa: 'ناموجود'),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: product.isInStock ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          if (product.description != null) ...[
            SizedBox(height: 10.h),
            Text(
              product.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600, height: 1.3),
            ),
          ],
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(context, en: 'Starting from', fa: 'شروع قیمت از'),
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                  ),
                  Text(
                    '\$${product.priceUsd.toStringAsFixed(2)} USD',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.lightPrimary,
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
                      onPressed: () => Get.to(() => LicenseDetailScreen(product: product)),
                    )
                  : CommonButton(
                      width: 120,
                      height: 40,
                      backgroundColor: Colors.grey.shade200,
                      textColor: Colors.grey.shade600,
                      text: l10nPick(
                        context,
                        en: 'Notify Me',
                        fa: 'خبرم کن',
                        ar: 'أعلمني',
                        zh: '通知我',
                      ),
                      fontSize: 13,
                      onPressed: () {},
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
