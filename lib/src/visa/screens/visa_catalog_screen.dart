import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
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

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
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
                onPressed: () => Get.to(() => const VisaListScreen()),
                tooltip: l10nPick(context, en: 'My Visas', fa: 'درخواست‌های من', ar: 'تأشيراتي', zh: '我的申请'),
                icon: const Icon(Icons.history_rounded, color: AppColors.lightPrimary),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadCatalog,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          children: [
            // Notice banner if backend is unavailable / catalog empty
            Obx(() {
              if (controller.hasBackendError.value || controller.catalogList.isEmpty) {
                return FinancialServiceUnavailableBanner(
                  serviceNameFa: 'ویزا و خدمات کنسولی',
                  serviceNameEn: 'Visa & Consular Service',
                  serviceNameAr: 'خدمات التأشيرات القنصلية',
                  serviceNameZh: '签证及领事服务',
                  onRetry: controller.loadCatalog,
                );
              }
              return const SizedBox.shrink();
            }),

            SizedBox(height: 6.h),

            // Quick action cards
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    context,
                    icon: Icons.menu_book_rounded,
                    titleFa: 'راهنمای انواع ویزا',
                    titleEn: 'Visa Guide',
                    color: const Color(0xFF4338CA),
                    onTap: () => Get.to(() => const VisaIntroScreen()),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildActionTile(
                    context,
                    icon: Icons.history_edu_rounded,
                    titleFa: 'پیگیری پرونده‌ها',
                    titleEn: 'My Applications',
                    color: const Color(0xFF059669),
                    onTap: () => Get.to(() => const VisaListScreen()),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: l10nPick(
                    context,
                    en: 'Search destination country or visa...',
                    fa: 'جستجوی کشور مقصد یا نوع ویزا...',
                    ar: 'البحث عن الدولة أو نوع التأشيرة...',
                    zh: '搜索目的地国家或签证类型...',
                  ),
                  hintStyle: TextStyle(fontSize: 12.5.sp, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: AppColors.lightPrimary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Banner
            Container(
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF3730A3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          l10nPick(
                            context,
                            en: 'Apply online in minutes with 100% consultant review guarantee.',
                            fa: 'درخواست آنلاین در چند دقیقه با بررسی تخصصی کارشناسان رسمی سفر.',
                            ar: 'تقديم الطلب في دقائق مع تدقيق الخبراء المتخصصين.',
                            zh: '数分钟内完成线上申报，专职领事专家全程预审护航。',
                          ),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11.sp,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.flight_takeoff_rounded,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 44.r,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

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
                color: AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 10.h),

            // Catalog List
            Obx(() {
              if (controller.isLoadingCatalog.value &&
                  controller.catalogList.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.isServiceUnavailable.value) {
                return Container(
                  margin: EdgeInsetsDirectional.only(top: 8.h),
                  padding: EdgeInsetsDirectional.all(20.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_off_rounded,
                          color: Colors.orange,
                          size: 40,
                        ),
                      ),
                      SizedBox(height: 12.h),
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
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'The visa catalog (/visa/catalog) is undergoing backend partner integration. Please retry shortly.',
                          fa: 'ارتباط با سامانه مرکزی صدور روادید بین‌المللی در دست اتصال است. لطفاً بعداً تلاش فرمایید.',
                          ar: 'خوادم التأشيرات الدولية قيد التحديث مع الجهات المعتمدة.',
                          zh: '全球签证服务接口正在与合作伙伴联调中，请稍后重试。',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11.5.sp,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7445FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                        ),
                        onPressed: controller.loadCatalog,
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                        label: Text(
                          l10nPick(
                            context,
                            en: 'Retry Connection',
                            fa: 'تلاش مجدد',
                            ar: 'إعادة المحاولة',
                            zh: '重试连接',
                          ),
                          style: const TextStyle(color: Colors.white),
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

              if (items.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.travel_explore_rounded, size: 48.r, color: Colors.grey.shade400),
                      SizedBox(height: 10.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'No visa packages found',
                          fa: 'هیچ ویزایی با این مشخصات یافت نشد',
                          ar: 'لم يتم العثور على أي باقات تأشيرة',
                          zh: '未找到符合条件的签证项目',
                        ),
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'You can review requirements and the application guide in the meantime.',
                          fa: 'می‌توانید شرایط عمومی مدارک و مراحل درخواست را در بخش راهنما مشاهده فرمایید.',
                          ar: 'يمكنك الاطلاع على شروط الوثائق في قسم الدليل.',
                          zh: '您可以在等待期间查阅签证申请通用材料指南。',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5.sp),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, idx) {
                  final item = items[idx];
                  return VisaCatalogCard(
                    item: item,
                    onTap: () {
                      controller.selectCatalog(item);
                      Get.to(() => VisaRequirementsScreen(item: item));
                    },
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String titleFa,
    required String titleEn,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              l10nPick(context, fa: titleFa, en: titleEn),
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.lightTextPrimary,
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
  final VoidCallback onTap;

  const VisaCatalogCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return VisaCard(
      onTap: onTap,
      padding: EdgeInsets.all(16.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          VisaCountryFlag(flagUrl: item.countryFlag, size: 48),
          SizedBox(width: 14.w),
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
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${item.processingDaysMin}-${item.processingDaysMax} ${l10nPick(context, en: 'days', fa: 'روزه')}',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10nPick(context, en: 'From', fa: 'شروع از')}: \$${item.totalFee.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF7445FF),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          l10nPick(context, en: 'Details', fa: 'مشاهده شرایط'),
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF7445FF),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: Color(0xFF7445FF),
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
