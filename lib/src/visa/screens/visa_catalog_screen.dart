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
              fa: 'ÃƒËœÃ‚Â®ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§ Ãƒâ„¢Ã‹â€  ÃƒÅ¡Ã‚Â©Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚Â³Ãƒâ„¢Ã‹â€ Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ€ºÃ…â€™',
              en: 'Visa & Consular Desk',
              ar: 'ÃƒËœÃ‚Â®ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚ÂªÃƒËœÃ‚Â£ÃƒËœÃ‚Â´Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã¢â‚¬Å¡Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚ÂµÃƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â©',
              zh: 'ÃƒÂ§Ã‚Â­Ã‚Â¾ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ¤Ã‚Â¸Ã…Â½ÃƒÂ©Ã‚Â¢Ã¢â‚¬Â ÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â¹ÃƒÂ¦Ã…â€œÃ‚ÂÃƒÂ¥Ã…Â Ã‚Â¡',
            ),
            rightSideWidget: Padding(
              padding: EdgeInsetsDirectional.only(end: 16.w),
              child: IconButton(
                onPressed: () => Get.to(() => const VisaListScreen()),
                tooltip: l10nPick(context, en: 'My Visas', fa: 'ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â±ÃƒËœÃ‚Â®Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â³ÃƒËœÃ‚ÂªÃƒÂ¢Ã¢â€šÂ¬Ã…â€™Ãƒâ„¢Ã¢â‚¬Â¡ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã¢â‚¬Â ', ar: 'ÃƒËœÃ‚ÂªÃƒËœÃ‚Â£ÃƒËœÃ‚Â´Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§ÃƒËœÃ‚ÂªÃƒâ„¢Ã…Â ', zh: 'ÃƒÂ¦Ã‹â€ Ã¢â‚¬ËœÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ§Ã¢â‚¬ÂÃ‚Â³ÃƒÂ¨Ã‚Â¯Ã‚Â·'),
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
                  serviceNameFa: 'Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§ Ãƒâ„¢Ã‹â€  ÃƒËœÃ‚Â®ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª ÃƒÅ¡Ã‚Â©Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚Â³Ãƒâ„¢Ã‹â€ Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ€ºÃ…â€™',
                  serviceNameEn: 'Visa & Consular Service',
                  serviceNameAr: 'ÃƒËœÃ‚Â®ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚ÂªÃƒËœÃ‚Â£ÃƒËœÃ‚Â´Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã¢â‚¬Å¡Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚ÂµÃƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â©',
                  serviceNameZh: 'ÃƒÂ§Ã‚Â­Ã‚Â¾ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ¥Ã‚ÂÃ…Â ÃƒÂ©Ã‚Â¢Ã¢â‚¬Â ÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â¹ÃƒÂ¦Ã…â€œÃ‚ÂÃƒÂ¥Ã…Â Ã‚Â¡',
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
                    titleFa: 'ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â¡Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¹ Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§',
                    titleEn: 'Visa Guide',
                    color: AppColors.lightSecondary,
                    onTap: () => Get.to(() => const VisaIntroScreen()),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildActionTile(
                    context,
                    icon: Icons.history_edu_rounded,
                    titleFa: 'Ãƒâ„¢Ã‚Â¾Ãƒâ€ºÃ…â€™ÃƒÅ¡Ã‚Â¯Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â±Ãƒâ€ºÃ…â€™ Ãƒâ„¢Ã‚Â¾ÃƒËœÃ‚Â±Ãƒâ„¢Ã‹â€ Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Â¡ÃƒÂ¢Ã¢â€šÂ¬Ã…â€™Ãƒâ„¢Ã¢â‚¬Â¡ÃƒËœÃ‚Â§',
                    titleEn: 'My Applications',
                    color: AppColors.success,
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
                    fa: 'ÃƒËœÃ‚Â¬ÃƒËœÃ‚Â³ÃƒËœÃ‚ÂªÃƒËœÃ‚Â¬Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ ÃƒÅ¡Ã‚Â©ÃƒËœÃ‚Â´Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â± Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã¢â‚¬Å¡ÃƒËœÃ‚ÂµÃƒËœÃ‚Â¯ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â§ Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â¹ Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§...',
                    ar: 'ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â¨ÃƒËœÃ‚Â­ÃƒËœÃ‚Â« ÃƒËœÃ‚Â¹Ãƒâ„¢Ã¢â‚¬Â  ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â¯Ãƒâ„¢Ã‹â€ Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â© ÃƒËœÃ‚Â£Ãƒâ„¢Ã‹â€  Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â¹ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚ÂªÃƒËœÃ‚Â£ÃƒËœÃ‚Â´Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â±ÃƒËœÃ‚Â©...',
                    zh: 'ÃƒÂ¦Ã‚ÂÃ…â€œÃƒÂ§Ã‚Â´Ã‚Â¢ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã…â€œÃ‚Â°ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â½ÃƒÂ¥Ã‚Â®Ã‚Â¶ÃƒÂ¦Ã‹â€ Ã¢â‚¬â€œÃƒÂ§Ã‚Â­Ã‚Â¾ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ§Ã‚Â±Ã‚Â»ÃƒÂ¥Ã…Â¾Ã¢â‚¬Â¹...',
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
                  colors: [AppColors.deepBlack, AppColors.darkGray],
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
                            fa: 'ÃƒËœÃ‚ÂµÃƒËœÃ‚Â¯Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â± ÃƒËœÃ‚Â³ÃƒËœÃ‚Â±Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â¹ Ãƒâ„¢Ã‹â€  Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â·Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â¦Ãƒâ„¢Ã¢â‚¬Â  Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒÅ¡Ã‚Â©ÃƒËœÃ‚ÂªÃƒËœÃ‚Â±Ãƒâ„¢Ã‹â€ Ãƒâ„¢Ã¢â‚¬Â Ãƒâ€ºÃ…â€™ÃƒÅ¡Ã‚Â©',
                            ar: 'ÃƒËœÃ‚Â¥ÃƒËœÃ‚ÂµÃƒËœÃ‚Â¯ÃƒËœÃ‚Â§ÃƒËœÃ‚Â± ÃƒËœÃ‚Â³ÃƒËœÃ‚Â±Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â¹ Ãƒâ„¢Ã‹â€ Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â«Ãƒâ„¢Ã‹â€ Ãƒâ„¢Ã¢â‚¬Å¡ Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚ÂªÃƒËœÃ‚Â£ÃƒËœÃ‚Â´Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â¥Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã†â€™ÃƒËœÃ‚ÂªÃƒËœÃ‚Â±Ãƒâ„¢Ã‹â€ Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â©',
                            zh: 'ÃƒÂ¥Ã‚Â¿Ã‚Â«ÃƒÂ¦Ã‚ÂÃ‚Â·ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¤Ã‚Â¿Ã‚Â¡ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ§Ã¢â‚¬ÂÃ‚ÂµÃƒÂ¥Ã‚Â­Ã‚ÂÃƒÂ§Ã‚Â­Ã‚Â¾ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â³ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ©Ã¢â€šÂ¬Ã…Â¡ÃƒÂ©Ã‚ÂÃ¢â‚¬Å“',
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
                            fa: 'ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â±ÃƒËœÃ‚Â®Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â³ÃƒËœÃ‚Âª ÃƒËœÃ‚Â¢Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™Ãƒâ„¢Ã¢â‚¬Â  ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â± ÃƒÅ¡Ã¢â‚¬Â Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚Â¯ ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Å¡Ãƒâ€ºÃ…â€™Ãƒâ„¢Ã¢â‚¬Å¡Ãƒâ„¢Ã¢â‚¬Â¡ ÃƒËœÃ‚Â¨ÃƒËœÃ‚Â§ ÃƒËœÃ‚Â¨ÃƒËœÃ‚Â±ÃƒËœÃ‚Â±ÃƒËœÃ‚Â³Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚ÂªÃƒËœÃ‚Â®ÃƒËœÃ‚ÂµÃƒËœÃ‚ÂµÃƒâ€ºÃ…â€™ ÃƒÅ¡Ã‚Â©ÃƒËœÃ‚Â§ÃƒËœÃ‚Â±ÃƒËœÃ‚Â´Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚Â§ÃƒËœÃ‚Â³ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â  ÃƒËœÃ‚Â±ÃƒËœÃ‚Â³Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚Â³Ãƒâ„¢Ã‚ÂÃƒËœÃ‚Â±.',
                            ar: 'ÃƒËœÃ‚ÂªÃƒâ„¢Ã¢â‚¬Å¡ÃƒËœÃ‚Â¯Ãƒâ„¢Ã…Â Ãƒâ„¢Ã¢â‚¬Â¦ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â·Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â¨ Ãƒâ„¢Ã‚ÂÃƒâ„¢Ã…Â  ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Å¡ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¦Ãƒâ„¢Ã¢â‚¬Å¡ Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â¹ ÃƒËœÃ‚ÂªÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Å¡Ãƒâ„¢Ã…Â Ãƒâ„¢Ã¢â‚¬Å¡ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â®ÃƒËœÃ‚Â¨ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¡ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚ÂªÃƒËœÃ‚Â®ÃƒËœÃ‚ÂµÃƒËœÃ‚ÂµÃƒâ„¢Ã…Â Ãƒâ„¢Ã¢â‚¬Â .',
                            zh: 'ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¥Ã‹â€ Ã¢â‚¬Â ÃƒÂ©Ã¢â‚¬â„¢Ã…Â¸ÃƒÂ¥Ã¢â‚¬Â Ã¢â‚¬Â¦ÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ§Ã‚ÂºÃ‚Â¿ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ§Ã¢â‚¬ÂÃ‚Â³ÃƒÂ¦Ã…Â Ã‚Â¥ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Å“ÃƒÂ¨Ã‚ÂÃ…â€™ÃƒÂ©Ã‚Â¢Ã¢â‚¬Â ÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â¹ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Å“ÃƒÂ¥Ã‚Â®Ã‚Â¶ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ§Ã‚Â¨Ã¢â‚¬Â¹ÃƒÂ©Ã‚Â¢Ã¢â‚¬Å¾ÃƒÂ¥Ã‚Â®Ã‚Â¡ÃƒÂ¦Ã…Â Ã‚Â¤ÃƒÂ¨Ã‹â€ Ã‚ÂªÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
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
                fa: 'Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã¢â‚¬Å¡ÃƒËœÃ‚Â§ÃƒËœÃ‚ÂµÃƒËœÃ‚Â¯ Ãƒâ„¢Ã‚ÂÃƒËœÃ‚Â¹ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§',
                ar: 'ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â¬Ãƒâ„¢Ã¢â‚¬Â¡ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚ÂªÃƒËœÃ‚Â§ÃƒËœÃ‚Â­ÃƒËœÃ‚Â©',
                zh: 'ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã…Â Ã…Â¾ÃƒÂ§Ã‚ÂÃ¢â‚¬Â ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã…â€œÃ‚Â°ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â½ÃƒÂ¥Ã‚Â®Ã‚Â¶',
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
                          fa: 'ÃƒËœÃ‚Â³ÃƒËœÃ‚Â±Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â³ ÃƒËœÃ‚Â¢Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™Ãƒâ„¢Ã¢â‚¬Â  Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§ Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã‹â€ Ãƒâ„¢Ã¢â‚¬Å¡ÃƒËœÃ‚ÂªÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â¹ ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â± ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â³ÃƒËœÃ‚ÂªÃƒËœÃ‚Â±ÃƒËœÃ‚Â³ Ãƒâ„¢Ã¢â‚¬Â Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â³ÃƒËœÃ‚Âª',
                          ar: 'ÃƒËœÃ‚Â®ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â© ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚ÂªÃƒËœÃ‚Â£ÃƒËœÃ‚Â´Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª ÃƒËœÃ‚ÂºÃƒâ„¢Ã…Â ÃƒËœÃ‚Â± Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚ÂªÃƒâ„¢Ã‹â€ Ãƒâ„¢Ã‚ÂÃƒËœÃ‚Â±ÃƒËœÃ‚Â© Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â¤Ãƒâ„¢Ã¢â‚¬Å¡ÃƒËœÃ‚ÂªÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â¹',
                          zh: 'ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ§Ã‚ÂºÃ‚Â¿ÃƒÂ§Ã‚Â­Ã‚Â¾ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â³ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ¦Ã…â€œÃ‚ÂÃƒÂ¥Ã…Â Ã‚Â¡ÃƒÂ¦Ã…Â¡Ã¢â‚¬Å¡ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'The visa catalog (/visa/catalog) is undergoing backend partner integration. Please retry shortly.',
                          fa: 'ÃƒËœÃ‚Â§ÃƒËœÃ‚Â±ÃƒËœÃ‚ÂªÃƒËœÃ‚Â¨ÃƒËœÃ‚Â§ÃƒËœÃ‚Â· ÃƒËœÃ‚Â¨ÃƒËœÃ‚Â§ ÃƒËœÃ‚Â³ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã¢â‚¬Â¡ Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â±ÃƒÅ¡Ã‚Â©ÃƒËœÃ‚Â²Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚ÂµÃƒËœÃ‚Â¯Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â± ÃƒËœÃ‚Â±Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¯Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â¯ ÃƒËœÃ‚Â¨Ãƒâ€ºÃ…â€™Ãƒâ„¢Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã…â€™ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â± ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â³ÃƒËœÃ‚Âª ÃƒËœÃ‚Â§ÃƒËœÃ‚ÂªÃƒËœÃ‚ÂµÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â³ÃƒËœÃ‚Âª. Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â·Ãƒâ„¢Ã‚ÂÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â¹ ÃƒËœÃ‚Â¨ÃƒËœÃ‚Â¹ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â¹ ÃƒËœÃ‚ÂªÃƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â§ÃƒËœÃ‚Â´ Ãƒâ„¢Ã‚ÂÃƒËœÃ‚Â±Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â¯.',
                          ar: 'ÃƒËœÃ‚Â®Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Â¦ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚ÂªÃƒËœÃ‚Â£ÃƒËœÃ‚Â´Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â¯Ãƒâ„¢Ã‹â€ Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â© Ãƒâ„¢Ã¢â‚¬Å¡Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â¯ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚ÂªÃƒËœÃ‚Â­ÃƒËœÃ‚Â¯Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â« Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â¹ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â¬Ãƒâ„¢Ã¢â‚¬Â¡ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â¹ÃƒËœÃ‚ÂªÃƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â©.',
                          zh: 'ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ§Ã‚ÂÃ†â€™ÃƒÂ§Ã‚Â­Ã‚Â¾ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ¦Ã…â€œÃ‚ÂÃƒÂ¥Ã…Â Ã‚Â¡ÃƒÂ¦Ã…Â½Ã‚Â¥ÃƒÂ¥Ã‚ÂÃ‚Â£ÃƒÂ¦Ã‚Â­Ã‚Â£ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ¤Ã‚Â¸Ã…Â½ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¤Ã‚Â½Ã…â€œÃƒÂ¤Ã‚Â¼Ã¢â€žÂ¢ÃƒÂ¤Ã‚Â¼Ã‚Â´ÃƒÂ¨Ã‚ÂÃ¢â‚¬ÂÃƒÂ¨Ã‚Â°Ã†â€™ÃƒÂ¤Ã‚Â¸Ã‚Â­ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ§Ã‚Â¨Ã‚ÂÃƒÂ¥Ã‚ÂÃ…Â½ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ¨Ã‚Â¯Ã¢â‚¬Â¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
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
                          backgroundColor: AppColors.lightSecondary,
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
                            fa: 'ÃƒËœÃ‚ÂªÃƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â§ÃƒËœÃ‚Â´ Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â¬ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â¯',
                            ar: 'ÃƒËœÃ‚Â¥ÃƒËœÃ‚Â¹ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â© ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â­ÃƒËœÃ‚Â§Ãƒâ„¢Ã‹â€ Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â©',
                            zh: 'ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ¨Ã‚Â¯Ã¢â‚¬Â¢ÃƒÂ¨Ã‚Â¿Ã…Â¾ÃƒÂ¦Ã…Â½Ã‚Â¥',
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
                          fa: 'Ãƒâ„¢Ã¢â‚¬Â¡Ãƒâ€ºÃ…â€™ÃƒÅ¡Ã¢â‚¬Â  Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚Â¨ÃƒËœÃ‚Â§ ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™Ãƒâ„¢Ã¢â‚¬Â  Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â´ÃƒËœÃ‚Â®ÃƒËœÃ‚ÂµÃƒËœÃ‚Â§ÃƒËœÃ‚Âª Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â§Ãƒâ„¢Ã‚ÂÃƒËœÃ‚Âª Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚Â´ÃƒËœÃ‚Â¯',
                          ar: 'Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã¢â‚¬Â¦ Ãƒâ„¢Ã…Â ÃƒËœÃ‚ÂªÃƒâ„¢Ã¢â‚¬Â¦ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â¹ÃƒËœÃ‚Â«Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â± ÃƒËœÃ‚Â¹Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã¢â‚¬Â° ÃƒËœÃ‚Â£Ãƒâ„¢Ã…Â  ÃƒËœÃ‚Â¨ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¡ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª ÃƒËœÃ‚ÂªÃƒËœÃ‚Â£ÃƒËœÃ‚Â´Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â±ÃƒËœÃ‚Â©',
                          zh: 'ÃƒÂ¦Ã…â€œÃ‚ÂªÃƒÂ¦Ã¢â‚¬Â°Ã‚Â¾ÃƒÂ¥Ã‹â€ Ã‚Â°ÃƒÂ§Ã‚Â¬Ã‚Â¦ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¦Ã‚ÂÃ‚Â¡ÃƒÂ¤Ã‚Â»Ã‚Â¶ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ§Ã‚Â­Ã‚Â¾ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ©Ã‚Â¡Ã‚Â¹ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®',
                        ),
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'You can review requirements and the application guide in the meantime.',
                          fa: 'Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ€ºÃ…â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…â€™ÃƒËœÃ‚ÂªÃƒâ„¢Ã‹â€ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â¯ ÃƒËœÃ‚Â´ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â· ÃƒËœÃ‚Â¹Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã‹â€ Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ€ºÃ…â€™ Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â§ÃƒËœÃ‚Â±ÃƒÅ¡Ã‚Â© Ãƒâ„¢Ã‹â€  Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§ÃƒËœÃ‚Â­Ãƒâ„¢Ã¢â‚¬Å¾ ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â±ÃƒËœÃ‚Â®Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â³ÃƒËœÃ‚Âª ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§ ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â± ÃƒËœÃ‚Â¨ÃƒËœÃ‚Â®ÃƒËœÃ‚Â´ ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â¡Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â§ Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â´ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â¡ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Â¡ Ãƒâ„¢Ã‚ÂÃƒËœÃ‚Â±Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â¯.',
                          ar: 'Ãƒâ„¢Ã…Â Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã†â€™Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã†â€™ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â§ÃƒËœÃ‚Â·Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¹ ÃƒËœÃ‚Â¹Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã¢â‚¬Â° ÃƒËœÃ‚Â´ÃƒËœÃ‚Â±Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â· ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â«ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¦Ãƒâ„¢Ã¢â‚¬Å¡ Ãƒâ„¢Ã‚ÂÃƒâ„¢Ã…Â  Ãƒâ„¢Ã¢â‚¬Å¡ÃƒËœÃ‚Â³Ãƒâ„¢Ã¢â‚¬Â¦ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã…Â Ãƒâ„¢Ã¢â‚¬Å¾.',
                          zh: 'ÃƒÂ¦Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¤Ã‚Â»Ã‚Â¥ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ§Ã‚Â­Ã¢â‚¬Â°ÃƒÂ¥Ã‚Â¾Ã¢â‚¬Â¦ÃƒÂ¦Ã…â€œÃ…Â¸ÃƒÂ©Ã¢â‚¬â€Ã‚Â´ÃƒÂ¦Ã…Â¸Ã‚Â¥ÃƒÂ©Ã‹Å“Ã¢â‚¬Â¦ÃƒÂ§Ã‚Â­Ã‚Â¾ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â³ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ©Ã¢â€šÂ¬Ã…Â¡ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¦Ã‚ÂÃ‚ÂÃƒÂ¦Ã¢â‚¬â€œÃ¢â€žÂ¢ÃƒÂ¦Ã…â€™Ã¢â‚¬Â¡ÃƒÂ¥Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
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
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${item.processingDaysMin}-${item.processingDaysMax} ${l10nPick(context, en: 'days', fa: 'ÃƒËœÃ‚Â±Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â²Ãƒâ„¢Ã¢â‚¬Â¡')}',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: AppColors.lightTextSecondary,
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
                    color: AppColors.lightTextSecondary,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10nPick(context, en: 'From', fa: 'ÃƒËœÃ‚Â´ÃƒËœÃ‚Â±Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â¹ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â²')}: \$${item.totalFee.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.lightSecondary,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          l10nPick(context, en: 'Details', fa: 'Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â´ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â¡ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Â¡ ÃƒËœÃ‚Â´ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â·'),
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.lightSecondary,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppColors.lightSecondary,
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
