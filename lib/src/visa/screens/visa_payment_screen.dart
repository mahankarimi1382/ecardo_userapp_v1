import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/constants/app_colors.dart';
import '../../helper/l10n_pick.dart';
import '../controllers/visa_controller.dart';
import '../models/visa_models.dart';
import '../widgets/visa_widgets.dart';
import 'visa_detail_screen.dart';

class VisaPaymentScreen extends StatelessWidget {
  final VisaRequestModel request;

  const VisaPaymentScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<VisaController>()
        ? Get.find<VisaController>()
        : Get.put(VisaController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          l10nPick(context, en: 'Visa Payment', fa: 'ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€šÃ‚Â¾ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â®ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Âª ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â²ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€¹Ã¢â‚¬Â ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â²ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§'),
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.lightTextPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final isPaying = controller.isPaying.value;

        return Stack(
          children: [
            ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              children: [
                // Case & Destination Summary
                VisaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              VisaCountryFlag(flagUrl: request.countryFlag, size: 36),
                              SizedBox(width: 10.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request.countryName,
                                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    request.visaTitle,
                                    style: TextStyle(fontSize: 11.5.sp, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          VisaStatusBadge(status: request.status),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10nPick(context, en: 'Case Tracking No.', fa: 'ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â´ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€šÃ‚Â¾ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ÃƒÆ’Ã…Â¡Ãƒâ€šÃ‚Â¯ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€šÃ‚Â¾ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€¹Ã¢â‚¬Â ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡:'),
                            style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary),
                          ),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              request.caseNo,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.lightSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10nPick(context, en: 'Applicant Name:', fa: 'ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚ÂªÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¶ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢:'),
                            style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary),
                          ),
                          Text(
                            request.applicantName,
                            style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Payment Breakdown Card (Two clear rows)
                VisaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(context, en: 'Fee Breakdown', fa: 'ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â² ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â²ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã¢â‚¬â„¢ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¨ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾ ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€šÃ‚Â¾ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â®ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Âª'),
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 14.h),

                      // Row 1: Service Fee
                      _costItem(
                        context,
                        title: l10nPick(context, en: '1. Platform Service Fee', fa: 'ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€šÃ‚Â±. ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â²ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â®ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Âª ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€¹Ã¢â‚¬Â  ÃƒÆ’Ã…Â¡Ãƒâ€šÃ‚Â©ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â´ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â³ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€šÃ‚Â¾ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚ÂªÃƒÆ’Ã¢â€žÂ¢Ãƒâ€šÃ‚ÂÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦'),
                        subtitle: l10nPick(context, en: 'Application audit, translation check, and tracking', fa: 'ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¨ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â³ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã…Â¡Ãƒâ€šÃ‚Â©ÃƒÆ’Ã‹Å“Ãƒâ€¦Ã¢â‚¬â„¢ ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€šÃ‚ÂÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã¢â‚¬â„¢ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¨ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€¹Ã¢â‚¬Â  ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€šÃ‚Â¾ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ÃƒÆ’Ã…Â¡Ãƒâ€šÃ‚Â¯ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â®ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚ÂªÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚ÂµÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚ÂµÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢'),
                        amount: '\$${request.serviceFee.toStringAsFixed(2)}',
                      ),
                      const Divider(height: 24),

                      // Row 2: Gov Fee
                      _costItem(
                        context,
                        title: l10nPick(context, en: '2. Embassy & Government Fee', fa: 'ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€šÃ‚Â². ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â²ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â³ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€¹Ã¢â‚¬Â ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚ÂªÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€¹Ã¢â‚¬Â  ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â³ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€šÃ‚ÂÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Âª'),
                        subtitle: l10nPick(context, en: 'Official immigration authority fee for issuance', fa: 'ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚ÂªÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¹ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€šÃ‚ÂÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â³ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚ÂªÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¹ ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚ÂªÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ ÃƒÆ’Ã…Â¡Ãƒâ€šÃ‚Â©ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â´ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€¹Ã¢â‚¬Â ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â± ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚ÂµÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯'),
                        amount: '\$${request.govFee.toStringAsFixed(2)}',
                      ),
                      const Divider(height: 24),

                      // Total Row
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors.infoContainer,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10nPick(context, en: 'Total Amount to Pay:', fa: 'ÃƒÆ’Ã…Â¡Ãƒâ€šÃ‚Â©ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾ ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¨ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Âº ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¨ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾ ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€šÃ‚Â¾ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â®ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Âª:'),
                              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              '\$${request.totalFee.toStringAsFixed(2)} ${request.currency}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                color: AppColors.lightSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Payment Method Card
                VisaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(context, en: 'Payment Method', fa: 'ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€¹Ã¢â‚¬Â ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â´ ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€šÃ‚Â¾ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â®ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Âª'),
                        style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.lightSecondary, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: const BoxDecoration(
                                color: AppColors.infoContainer,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.lightSecondary),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10nPick(context, en: 'eCardo Multi-Currency Wallet', fa: 'ÃƒÆ’Ã…Â¡Ãƒâ€šÃ‚Â©ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€šÃ‚Â ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€šÃ‚Â¾ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€¹Ã¢â‚¬Â ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾ ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â²ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ eCardo'),
                                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    l10nPick(context, en: 'Instant debit with double-entry ledger lock', fa: 'ÃƒÆ’Ã…Â¡Ãƒâ€šÃ‚Â©ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â³ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â± ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€¹Ã¢â‚¬Â  ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â·ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¦ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â  ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¨ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¶ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Âª ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â³ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚ÂªÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯'),
                                    style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.check_circle_rounded, color: AppColors.lightSecondary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Security & Refund Policy Note
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: AppColors.successContainer,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.security_rounded, color: AppColors.success, size: 20),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            en: 'Protection Guarantee: If documents are rejected during our consultant pre-review, your payment will be refunded 100% to your wallet.',
                            fa: 'ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¶ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Âª ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¨ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â²ÃƒÆ’Ã…Â¡Ãƒâ€šÃ‚Â¯ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â´ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Âª ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€¹Ã¢â‚¬Â ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡: ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â± ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚ÂµÃƒÆ’Ã¢â€žÂ¢Ãƒâ€¹Ã¢â‚¬Â ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Âª ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¹ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚ÂªÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â£ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯ ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã…Â¡Ãƒâ€šÃ‚Â© ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â± ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â­ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€šÃ‚Â¾ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â´ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã¢â‚¬â„¢ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¨ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â³ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ ÃƒÆ’Ã…Â¡Ãƒâ€šÃ‚Â©ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â´ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â³ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‹Å“Ãƒâ€¦Ã¢â‚¬â„¢ ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€¹Ã¢â‚¬Â ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€šÃ‚Â¾ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â®ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚ÂªÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¨ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â·ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€¹Ã¢â‚¬Â ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â± ÃƒÆ’Ã…Â¡Ãƒâ€šÃ‚Â©ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾ ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¨ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ ÃƒÆ’Ã…Â¡Ãƒâ€šÃ‚Â©ÃƒÆ’Ã¢â‚¬ÂºÃƒâ€¦Ã¢â‚¬â„¢ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€šÃ‚Â ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€šÃ‚Â¾ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€¹Ã¢â‚¬Â ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾ ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â´ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â³ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚ÂªÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯ ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â®ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€¹Ã¢â‚¬Â ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã¢â€žÂ¢ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯ ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â´ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯.',
                          ),
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: AppColors.success,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),

            if (isPaying)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      }),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () async {
              final ok = await controller.payForRequest(request.caseNo);
              if (ok) {
                Get.off(() => VisaDetailScreen(caseNo: request.caseNo));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightSecondary,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8.w),
                Text(
                  '${l10nPick(context, en: 'Pay', fa: 'ÃƒÆ’Ã¢â€žÂ¢Ãƒâ€šÃ‚Â¾ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â±ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â¯ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â§ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Â®ÃƒÆ’Ã‹Å“Ãƒâ€šÃ‚Âª')} \$${request.totalFee.toStringAsFixed(2)} ${request.currency}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _costItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String amount,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppColors.lightTextPrimary),
        ),
      ],
    );
  }
}
