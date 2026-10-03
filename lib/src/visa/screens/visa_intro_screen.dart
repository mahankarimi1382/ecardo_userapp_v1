import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import 'visa_catalog_screen.dart';
import 'visa_list_screen.dart';

/// Screen introducing specialized visa and consular services.
class VisaIntroScreen extends StatelessWidget {
  const VisaIntroScreen({super.key});

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
              fa: 'ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â¡Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚Â®ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª ÃƒËœÃ‚Â§ÃƒËœÃ‚Â®ÃƒËœÃ‚Â° Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§',
              en: 'Visa & Consular Services',
              ar: 'ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã…Â Ãƒâ„¢Ã¢â‚¬Å¾ ÃƒËœÃ‚Â®ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚ÂªÃƒËœÃ‚Â£ÃƒËœÃ‚Â´Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã¢â‚¬Å¡Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚ÂµÃƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â©',
              zh: 'ÃƒÂ§Ã‚Â­Ã‚Â¾ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ¤Ã‚Â¸Ã…Â½ÃƒÂ©Ã‚Â¢Ã¢â‚¬Â ÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â¹ÃƒÂ¦Ã…â€œÃ‚ÂÃƒÂ¥Ã…Â Ã‚Â¡ÃƒÂ¦Ã…â€™Ã¢â‚¬Â¡ÃƒÂ¥Ã‚ÂÃ¢â‚¬â€',
            ),
            rightSideWidget: Padding(
              padding: EdgeInsetsDirectional.only(end: 16.w),
              child: IconButton(
                icon: const Icon(Icons.history_rounded),
                tooltip: l10nPick(context, fa: 'ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â±ÃƒËœÃ‚Â®Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â³ÃƒËœÃ‚ÂªÃƒÂ¢Ã¢â€šÂ¬Ã…â€™Ãƒâ„¢Ã¢â‚¬Â¡ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã¢â‚¬Â ', en: 'My Visas', ar: 'ÃƒËœÃ‚ÂªÃƒËœÃ‚Â£ÃƒËœÃ‚Â´Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§ÃƒËœÃ‚ÂªÃƒâ„¢Ã…Â ', zh: 'ÃƒÂ¦Ã‹â€ Ã¢â‚¬ËœÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ§Ã‚Â­Ã‚Â¾ÃƒÂ¨Ã‚Â¯Ã‚Â'),
                onPressed: () => Get.to(() => const VisaListScreen()),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CommonButton(
            width: double.infinity,
            text: l10nPick(
              context,
              fa: 'Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â´ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â¡ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Â¡ ÃƒÅ¡Ã‚Â©ÃƒËœÃ‚Â§ÃƒËœÃ‚ÂªÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã‹â€ ÃƒÅ¡Ã‚Â¯ ÃƒÅ¡Ã‚Â©ÃƒËœÃ‚Â´Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â±Ãƒâ„¢Ã¢â‚¬Â¡ÃƒËœÃ‚Â§ Ãƒâ„¢Ã‹â€  ÃƒËœÃ‚Â«ÃƒËœÃ‚Â¨ÃƒËœÃ‚Âª ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â±ÃƒËœÃ‚Â®Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â³ÃƒËœÃ‚Âª',
              en: 'Explore Countries & Apply',
              ar: 'ÃƒËœÃ‚Â§ÃƒËœÃ‚Â³ÃƒËœÃ‚ÂªÃƒËœÃ‚Â¹ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¶ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â¯Ãƒâ„¢Ã‹â€ Ãƒâ„¢Ã¢â‚¬Å¾ Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚ÂªÃƒâ„¢Ã¢â‚¬Å¡ÃƒËœÃ‚Â¯Ãƒâ„¢Ã…Â Ãƒâ„¢Ã¢â‚¬Â¦ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â·Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â¨',
              zh: 'ÃƒÂ¦Ã‚ÂµÃ‚ÂÃƒÂ¨Ã‚Â§Ã‹â€ ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã…â€œÃ‚Â°ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â½ÃƒÂ¥Ã‚Â®Ã‚Â¶ÃƒÂ¥Ã‚Â¹Ã‚Â¶ÃƒÂ§Ã¢â‚¬ÂÃ‚Â³ÃƒÂ¨Ã‚Â¯Ã‚Â·',
            ),
            backgroundColor: AppColors.lightPrimary,
            onPressed: () => Get.to(() => const VisaCatalogScreen()),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.deepBlack, AppColors.darkGray],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: AppColors.mainSoftBlue.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.flight_takeoff_rounded, color: AppColors.mainSoftBlue, size: 26.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            fa: 'ÃƒËœÃ‚ÂµÃƒËœÃ‚Â¯Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â± Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒÅ¡Ã‚Â©ÃƒËœÃ‚ÂªÃƒËœÃ‚Â±Ãƒâ„¢Ã‹â€ Ãƒâ„¢Ã¢â‚¬Â Ãƒâ€ºÃ…â€™ÃƒÅ¡Ã‚Â© (e-Visa) Ãƒâ„¢Ã‹â€  ÃƒËœÃ‚Â®ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª ÃƒÅ¡Ã‚Â©Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚Â³Ãƒâ„¢Ã‹â€ Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ€ºÃ…â€™',
                            en: 'Electronic Visa & Consular Desk',
                            ar: 'ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚ÂªÃƒËœÃ‚Â£ÃƒËœÃ‚Â´Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â¥Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã†â€™ÃƒËœÃ‚ÂªÃƒËœÃ‚Â±Ãƒâ„¢Ã‹â€ Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â© Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â®ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã¢â‚¬Å¡Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚ÂµÃƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â©',
                            zh: 'ÃƒÂ§Ã¢â‚¬ÂÃ‚ÂµÃƒÂ¥Ã‚Â­Ã‚ÂÃƒÂ§Ã‚Â­Ã‚Â¾ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ¯Ã‚Â¼Ã‹â€ e-VisaÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ¤Ã‚Â¸Ã…Â½ÃƒÂ©Ã‚Â¢Ã¢â‚¬Â ÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â¹ÃƒÂ¥Ã‚Â®Ã…Â¾ÃƒÂ¥Ã…Â Ã‚Â¡',
                          ),
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'Ãƒâ„¢Ã‚Â¾ÃƒËœÃ‚Â´ÃƒËœÃ‚ÂªÃƒâ€ºÃ…â€™ÃƒËœÃ‚Â¨ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚ÂªÃƒËœÃ‚Â®ÃƒËœÃ‚ÂµÃƒËœÃ‚ÂµÃƒâ€ºÃ…â€™ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â² ÃƒËœÃ‚Â§ÃƒËœÃ‚Â®ÃƒËœÃ‚Â° Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚Â¨Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â´ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â² Ãƒâ€ºÃ‚Â±Ãƒâ€ºÃ‚Â²Ãƒâ€ºÃ‚Â° ÃƒÅ¡Ã‚Â©ÃƒËœÃ‚Â´Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â± ÃƒËœÃ‚Â¬Ãƒâ„¢Ã¢â‚¬Â¡ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â . ÃƒËœÃ‚Â¨ÃƒËœÃ‚Â±ÃƒËœÃ‚Â±ÃƒËœÃ‚Â³Ãƒâ€ºÃ…â€™ Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â§ÃƒËœÃ‚Â±ÃƒÅ¡Ã‚Â© ÃƒËœÃ‚ÂªÃƒâ„¢Ã‹â€ ÃƒËœÃ‚Â³ÃƒËœÃ‚Â· ÃƒÅ¡Ã‚Â©ÃƒËœÃ‚Â§ÃƒËœÃ‚Â±ÃƒËœÃ‚Â´Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚Â§ÃƒËœÃ‚Â³ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â  ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â± ÃƒËœÃ‚Â¨Ãƒâ€ºÃ…â€™Ãƒâ„¢Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã…â€™ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ…â€™ Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â¨ÃƒËœÃ‚ÂªÃƒÂ¢Ã¢â€šÂ¬Ã…â€™ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Â¡Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚Â³Ãƒâ„¢Ã‚ÂÃƒËœÃ‚Â§ÃƒËœÃ‚Â±ÃƒËœÃ‚Âª Ãƒâ„¢Ã‹â€  ÃƒËœÃ‚ÂªÃƒËœÃ‚Â­Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™Ãƒâ„¢Ã¢â‚¬Å¾ ÃƒËœÃ‚Â¯Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â¬Ãƒâ€ºÃ…â€™ÃƒËœÃ‚ÂªÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§.',
                      en: 'Specialized visa processing for 120+ destinations. Expert document pre-check, embassy scheduling, and digital e-visa issuance.',
                      ar: 'Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â¹ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â¬ÃƒËœÃ‚Â© ÃƒËœÃ‚ÂªÃƒËœÃ‚Â£ÃƒËœÃ‚Â´Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â£Ãƒâ„¢Ã†â€™ÃƒËœÃ‚Â«ÃƒËœÃ‚Â± Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã¢â‚¬Â  Ãƒâ„¢Ã‚Â¡Ãƒâ„¢Ã‚Â¢Ãƒâ„¢Ã‚Â  Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â¬Ãƒâ„¢Ã¢â‚¬Â¡ÃƒËœÃ‚Â© ÃƒËœÃ‚Â¹ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â© Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â¹ ÃƒËœÃ‚ÂªÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Å¡Ãƒâ„¢Ã…Â Ãƒâ„¢Ã¢â‚¬Å¡ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â«ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¦Ãƒâ„¢Ã¢â‚¬Å¡ Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â­ÃƒËœÃ‚Â¬ÃƒËœÃ‚Â² Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¹Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â¯ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â³Ãƒâ„¢Ã‚ÂÃƒËœÃ‚Â§ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª.',
                      zh: 'ÃƒÂ¨Ã‚Â¦Ã¢â‚¬Â ÃƒÂ§Ã¢â‚¬ÂºÃ¢â‚¬â€œÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ§Ã‚ÂÃ†â€™120ÃƒÂ¥Ã‚Â¤Ã…Â¡ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã…â€œÃ‚Â°ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Å“ÃƒÂ¤Ã‚Â¸Ã…Â¡ÃƒÂ§Ã‚Â­Ã‚Â¾ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ¤Ã‚Â»Ã‚Â£ÃƒÂ¥Ã…Â Ã…Â¾ÃƒÂ¦Ã…â€œÃ‚ÂÃƒÂ¥Ã…Â Ã‚Â¡ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¦Ã‚ÂÃ‚ÂÃƒÂ¤Ã‚Â¾Ã¢â‚¬ÂºÃƒÂ¦Ã‚ÂÃ†â€™ÃƒÂ¥Ã‚Â¨Ã‚ÂÃƒÂ¦Ã¢â‚¬â€œÃ¢â‚¬Â¡ÃƒÂ¤Ã‚Â»Ã‚Â¶ÃƒÂ©Ã‚Â¢Ã¢â‚¬Å¾ÃƒÂ¥Ã‚Â®Ã‚Â¡ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ©Ã‚Â¦Ã¢â‚¬Â ÃƒÂ©Ã‚Â¢Ã¢â‚¬Å¾ÃƒÂ§Ã‚ÂºÃ‚Â¦ÃƒÂ¥Ã‚ÂÃ…Â ÃƒÂ§Ã¢â‚¬ÂÃ‚ÂµÃƒÂ¥Ã‚Â­Ã‚ÂÃƒÂ§Ã‚Â­Ã‚Â¾ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ¥Ã‚Â¿Ã‚Â«ÃƒÂ©Ã¢â€šÂ¬Ã…Â¸ÃƒÂ§Ã‚Â­Ã‚Â¾ÃƒÂ¥Ã‚ÂÃ¢â‚¬ËœÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
                    ),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.warmWhite.withValues(alpha: 0.85),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Visa Types
            Text(
              l10nPick(
                context,
                fa: 'ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¹ Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â¡ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ Ãƒâ„¢Ã¢â‚¬Å¡ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¨Ãƒâ„¢Ã¢â‚¬Å¾ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â®ÃƒËœÃ‚Â°',
                en: 'Available Visa Categories',
                ar: 'ÃƒËœÃ‚Â£Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¹ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚ÂªÃƒËœÃ‚Â£ÃƒËœÃ‚Â´Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚ÂªÃƒËœÃ‚Â§ÃƒËœÃ‚Â­ÃƒËœÃ‚Â©',
                zh: 'ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ§Ã¢â‚¬ÂÃ‚Â³ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ§Ã‚Â­Ã‚Â¾ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ§Ã‚Â±Ã‚Â»ÃƒÂ¥Ã‹â€ Ã‚Â«',
              ),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 10.h),
            _buildTypeCard(
              context,
              icon: Icons.beach_access_rounded,
              titleFa: 'Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚ÂªÃƒâ„¢Ã‹â€ ÃƒËœÃ‚Â±Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â³ÃƒËœÃ‚ÂªÃƒâ€ºÃ…â€™ Ãƒâ„¢Ã‹â€  ÃƒÅ¡Ã‚Â¯ÃƒËœÃ‚Â±ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â´ÃƒÅ¡Ã‚Â¯ÃƒËœÃ‚Â±Ãƒâ€ºÃ…â€™ (Tourist eVisa)',
              titleEn: 'Tourist eVisa',
              descFa: 'ÃƒËœÃ‚ÂµÃƒËœÃ‚Â¯Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â± ÃƒËœÃ‚Â³ÃƒËœÃ‚Â±Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â¹ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒÅ¡Ã‚Â©ÃƒËœÃ‚ÂªÃƒËœÃ‚Â±Ãƒâ„¢Ã‹â€ Ãƒâ„¢Ã¢â‚¬Â Ãƒâ€ºÃ…â€™ÃƒÅ¡Ã‚Â©Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚Â¨ÃƒËœÃ‚Â¯Ãƒâ„¢Ã‹â€ Ãƒâ„¢Ã¢â‚¬Â  Ãƒâ„¢Ã¢â‚¬Â Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â§ÃƒËœÃ‚Â² ÃƒËœÃ‚Â¨Ãƒâ„¢Ã¢â‚¬Â¡ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â±ÃƒËœÃ‚Â³ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ Ãƒâ„¢Ã‚ÂÃƒâ€ºÃ…â€™ÃƒËœÃ‚Â²Ãƒâ€ºÃ…â€™ÃƒÅ¡Ã‚Â©Ãƒâ€ºÃ…â€™ ÃƒÅ¡Ã‚Â¯ÃƒËœÃ‚Â°ÃƒËœÃ‚Â±Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã¢â‚¬Â¡ ÃƒËœÃ‚Â¨ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã¢â‚¬Å¡ÃƒËœÃ‚Â§ÃƒËœÃ‚ÂµÃƒËœÃ‚Â¯ Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚ÂªÃƒËœÃ‚Â®ÃƒËœÃ‚Â¨.',
              descEn: 'Instant electronic issuance with zero passport mailing for qualifying countries.',
            ),
            _buildTypeCard(
              context,
              icon: Icons.business_center_rounded,
              titleFa: 'Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚ÂªÃƒËœÃ‚Â¬ÃƒËœÃ‚Â§ÃƒËœÃ‚Â±Ãƒâ€ºÃ…â€™ Ãƒâ„¢Ã‹â€  ÃƒËœÃ‚Â¨ÃƒËœÃ‚Â§ÃƒËœÃ‚Â²ÃƒËœÃ‚Â±ÃƒÅ¡Ã‚Â¯ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â Ãƒâ€ºÃ…â€™ (Business Visa)',
              titleEn: 'Business & Commercial Visa',
              descFa: 'ÃƒËœÃ‚Â§ÃƒËœÃ‚Â®ÃƒËœÃ‚Â° ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â¹Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚ÂªÃƒÂ¢Ã¢â€šÂ¬Ã…â€™Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã¢â‚¬Â¡ ÃƒËœÃ‚Â±ÃƒËœÃ‚Â³Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ€ºÃ…â€™ÃƒËœÃ…â€™ Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â´ÃƒÅ¡Ã‚Â¯ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â¡Ãƒâ€ºÃ…â€™ Ãƒâ„¢Ã‹â€  ÃƒËœÃ‚Â¬Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â³ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª ÃƒËœÃ‚Â¨ÃƒËœÃ‚Â§ÃƒËœÃ‚Â²ÃƒËœÃ‚Â±ÃƒÅ¡Ã‚Â¯ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚Â¨Ãƒâ€ºÃ…â€™Ãƒâ„¢Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã…â€™ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ€ºÃ…â€™.',
              descEn: 'Official business invitation letters, trade expo entry, and corporate meetings.',
            ),
            _buildTypeCard(
              context,
              icon: Icons.school_rounded,
              titleFa: 'Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚ÂªÃƒËœÃ‚Â­ÃƒËœÃ‚ÂµÃƒâ€ºÃ…â€™Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ€ºÃ…â€™ Ãƒâ„¢Ã‹â€  ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚Â´ÃƒËœÃ‚Â¬Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™Ãƒâ€ºÃ…â€™ (Student Visa)',
              titleEn: 'Study & Student Visa',
              descFa: 'Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â´ÃƒËœÃ‚Â§Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â±Ãƒâ„¢Ã¢â‚¬Â¡ Ãƒâ„¢Ã‚Â¾ÃƒËœÃ‚Â°Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â±ÃƒËœÃ‚Â´ ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚Â´ÃƒÅ¡Ã‚Â¯ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â¡Ãƒâ€ºÃ…â€™ÃƒËœÃ…â€™ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â³ÃƒËœÃ‚ÂªÃƒËœÃ‚Â¹Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â¦ ÃƒËœÃ‚Â³Ãƒâ„¢Ã‚ÂÃƒËœÃ‚Â§ÃƒËœÃ‚Â±ÃƒËœÃ‚Âª Ãƒâ„¢Ã‹â€  ÃƒËœÃ‚Â¨ÃƒËœÃ‚Â±ÃƒËœÃ‚Â±ÃƒËœÃ‚Â³Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚ÂªÃƒâ„¢Ã¢â‚¬Â¦ÃƒÅ¡Ã‚Â©Ãƒâ„¢Ã¢â‚¬Â  Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ€ºÃ…â€™ Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚ÂªÃƒâ„¢Ã¢â‚¬Å¡ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¶Ãƒâ€ºÃ…â€™.',
              descEn: 'University admission advisory, embassy interview prep, and financial proofing.',
            ),
            _buildTypeCard(
              context,
              icon: Icons.work_outline_rounded,
              titleFa: 'Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ ÃƒÅ¡Ã‚Â©ÃƒËœÃ‚Â§ÃƒËœÃ‚Â±Ãƒâ€ºÃ…â€™ Ãƒâ„¢Ã‹â€  ÃƒËœÃ‚Â¬ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¨ÃƒÂ¢Ã¢â€šÂ¬Ã…â€™ÃƒËœÃ‚Â¢Ãƒâ„¢Ã‚ÂÃƒËœÃ‚Â± (Work Permit)',
              titleEn: 'Work & Employment Permit',
              descFa: 'ÃƒËœÃ‚Â§ÃƒËœÃ‚Â±ÃƒËœÃ‚Â²Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¨Ãƒâ€ºÃ…â€™ Ãƒâ„¢Ã¢â‚¬Å¡ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§ÃƒËœÃ‚Â±ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Â¡ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â³ÃƒËœÃ‚ÂªÃƒËœÃ‚Â®ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚Â®ÃƒËœÃ‚Â§ÃƒËœÃ‚Â±ÃƒËœÃ‚Â¬Ãƒâ€ºÃ…â€™ Ãƒâ„¢Ã‹â€  Ãƒâ„¢Ã‚Â¾Ãƒâ€ºÃ…â€™ÃƒÅ¡Ã‚Â¯Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â±Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚ÂªÃƒËœÃ‚Â£Ãƒâ€ºÃ…â€™Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â¯Ãƒâ€ºÃ…â€™Ãƒâ„¢Ã¢â‚¬Â¡ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â§ÃƒËœÃ‚Â±Ãƒâ„¢Ã¢â‚¬Â¡ Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã¢â‚¬Â¡ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¬ÃƒËœÃ‚Â±ÃƒËœÃ‚Âª ÃƒÅ¡Ã‚Â©ÃƒËœÃ‚Â´Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â± Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã¢â‚¬Å¡ÃƒËœÃ‚ÂµÃƒËœÃ‚Â¯.',
              descEn: 'Overseas employment contract evaluation and destination immigration approval.',
            ),

            SizedBox(height: 20.h),

            // Steps
            Text(
              l10nPick(
                context,
                fa: 'Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§ÃƒËœÃ‚Â­Ãƒâ„¢Ã¢â‚¬Å¾ ÃƒËœÃ‚Â«ÃƒËœÃ‚Â¨ÃƒËœÃ‚Âª Ãƒâ„¢Ã‹â€  ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â±Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â§Ãƒâ„¢Ã‚ÂÃƒËœÃ‚Âª Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§',
                en: 'Application Workflow',
                ar: 'ÃƒËœÃ‚Â®ÃƒËœÃ‚Â·Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â§ÃƒËœÃ‚Âª ÃƒËœÃ‚Â§ÃƒËœÃ‚Â³ÃƒËœÃ‚ÂªÃƒËœÃ‚Â®ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¬ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚ÂªÃƒËœÃ‚Â£ÃƒËœÃ‚Â´Ãƒâ„¢Ã…Â ÃƒËœÃ‚Â±ÃƒËœÃ‚Â©',
                zh: 'ÃƒÂ§Ã‚Â­Ã‚Â¾ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ¥Ã…Â Ã…Â¾ÃƒÂ§Ã‚ÂÃ¢â‚¬Â ÃƒÂ¦Ã‚ÂµÃ‚ÂÃƒÂ§Ã‚Â¨Ã¢â‚¬Â¹',
              ),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 10.h),
            _buildStepRow(context, step: 'Ãƒâ€ºÃ‚Â±', titleFa: 'ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚ÂªÃƒËœÃ‚Â®ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¨ ÃƒÅ¡Ã‚Â©ÃƒËœÃ‚Â´Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â± Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã¢â‚¬Å¡ÃƒËœÃ‚ÂµÃƒËœÃ‚Â¯ Ãƒâ„¢Ã‹â€  Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â¹ Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§', titleEn: 'Select Destination & Type'),
            _buildStepRow(context, step: 'Ãƒâ€ºÃ‚Â²', titleFa: 'ÃƒËœÃ‚ÂªÃƒÅ¡Ã‚Â©Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ€ºÃ…â€™Ãƒâ„¢Ã¢â‚¬Å¾ Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â´ÃƒËœÃ‚Â®ÃƒËœÃ‚ÂµÃƒËœÃ‚Â§ÃƒËœÃ‚Âª Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â³ÃƒËœÃ‚Â§Ãƒâ„¢Ã‚ÂÃƒËœÃ‚Â± Ãƒâ„¢Ã‹â€  Ãƒâ„¢Ã‚Â¾ÃƒËœÃ‚Â§ÃƒËœÃ‚Â³Ãƒâ„¢Ã‚Â¾Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â±ÃƒËœÃ‚Âª', titleEn: 'Enter Passenger Details'),
            _buildStepRow(context, step: 'Ãƒâ€ºÃ‚Â³', titleFa: 'ÃƒËœÃ‚Â¢Ãƒâ„¢Ã‚Â¾Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â¯ Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â§ÃƒËœÃ‚Â±ÃƒÅ¡Ã‚Â© Ãƒâ„¢Ã¢â‚¬Â¡Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚ÂªÃƒâ€ºÃ…â€™ Ãƒâ„¢Ã‹â€  ÃƒËœÃ‚Â¹ÃƒÅ¡Ã‚Â©ÃƒËœÃ‚Â³ Ãƒâ„¢Ã‚Â¾ÃƒËœÃ‚Â±ÃƒËœÃ‚Â³Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ€ºÃ…â€™', titleEn: 'Upload Passport & Documents'),
            _buildStepRow(context, step: 'Ãƒâ€ºÃ‚Â´', titleFa: 'Ãƒâ„¢Ã‚Â¾ÃƒËœÃ‚Â±ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â§ÃƒËœÃ‚Â®ÃƒËœÃ‚Âª ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã¢â‚¬Â  Ãƒâ„¢Ã¢â‚¬Â¡ÃƒËœÃ‚Â²Ãƒâ€ºÃ…â€™Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã¢â‚¬Â¡ ÃƒÅ¡Ã‚Â©Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚Â³Ãƒâ„¢Ã‹â€ Ãƒâ„¢Ã¢â‚¬Å¾Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â² Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Âª', titleEn: 'Secure Wallet Payment'),
            _buildStepRow(context, step: 'Ãƒâ€ºÃ‚Âµ', titleFa: 'ÃƒËœÃ‚Â¨ÃƒËœÃ‚Â±ÃƒËœÃ‚Â±ÃƒËœÃ‚Â³Ãƒâ€ºÃ…â€™ ÃƒÅ¡Ã‚Â©ÃƒËœÃ‚Â§ÃƒËœÃ‚Â±ÃƒËœÃ‚Â´Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚Â§ÃƒËœÃ‚Â³ Ãƒâ„¢Ã‹â€  ÃƒËœÃ‚ÂµÃƒËœÃ‚Â¯Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â± Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã¢â‚¬Â¡ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™Ãƒâ€ºÃ…â€™ e-Visa', titleEn: 'Consultant Audit & e-Visa Issue'),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(
    BuildContext context, {
    required IconData icon,
    required String titleFa,
    required String titleEn,
    required String descFa,
    required String descEn,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.lightSecondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.lightSecondary, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(context, fa: titleFa, en: titleEn),
                  style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 3.h),
                Text(
                  l10nPick(context, fa: descFa, en: descEn),
                  style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(BuildContext context, {required String step, required String titleFa, required String titleEn}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.lightSecondary,
              shape: BoxShape.circle,
            ),
            child: Text(step, style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 10.w),
          Text(
            l10nPick(context, fa: titleFa, en: titleEn),
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
