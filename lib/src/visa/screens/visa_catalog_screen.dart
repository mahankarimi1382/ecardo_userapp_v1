import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../helper/l10n_pick.dart';
import '../controllers/visa_controller.dart';
import '../models/visa_models.dart';
import '../widgets/visa_widgets.dart';
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          l10nPick(context, en: 'Visa Services', fa: 'خدمات ویزا'),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const VisaListScreen()),
            tooltip: l10nPick(context, en: 'My Visas', fa: 'درخواست‌های من'),
            icon: const Icon(Icons.history_rounded, color: Color(0xFF7445FF)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadCatalog,
        color: const Color(0xFF7445FF),
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  ),
                  hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF7445FF)),
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
                  colors: [Color(0xFF7445FF), Color(0xFF9B51E0)],
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
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          l10nPick(
                            context,
                            en: 'Apply online in minutes with 100% money-back guarantee on consultant review.',
                            fa: 'درخواست آنلاین در چند دقیقه با بررسی تخصصی کارشناسان رسمی سفر.',
                          ),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.flight_takeoff_rounded,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 48.r,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Catalog Header
            Text(
              l10nPick(context, en: 'Available Destinations', fa: 'مقاصد فعال ویزا'),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 12.h),

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

              final items = controller.catalogList.where((it) {
                if (_searchQuery.isEmpty) return true;
                return it.countryName.toLowerCase().contains(_searchQuery) ||
                    it.title.toLowerCase().contains(_searchQuery) ||
                    it.countryCode.toLowerCase().contains(_searchQuery);
              }).toList();

              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.r),
                    child: Column(
                      children: [
                        Icon(Icons.travel_explore_rounded,
                            size: 56.r, color: Colors.grey),
                        SizedBox(height: 10.h),
                        Text(
                          l10nPick(
                            context,
                            en: 'No visa packages found',
                            fa: 'هیچ ویزایی با این مشخصات یافت نشد',
                          ),
                          style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _VisaCatalogCard(
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
}

class _VisaCatalogCard extends StatelessWidget {
  final VisaCatalogItem item;
  final VoidCallback onTap;

  const _VisaCatalogCard({required this.item, required this.onTap});

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
