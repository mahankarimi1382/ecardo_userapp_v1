import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/constants/app_colors.dart';
import '../../helper/l10n_pick.dart';
import '../controllers/visa_controller.dart';
import '../models/visa_models.dart';
import '../widgets/visa_widgets.dart';
import 'visa_detail_screen.dart';

class VisaListScreen extends StatefulWidget {
  const VisaListScreen({super.key});

  @override
  State<VisaListScreen> createState() => _VisaListScreenState();
}

class _VisaListScreenState extends State<VisaListScreen> {
  late final VisaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<VisaController>()
        ? Get.find<VisaController>()
        : Get.put(VisaController());
    _controller.loadUserRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          l10nPick(context, en: 'My Visa Applications', fa: 'ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â±ÃƒËœÃ‚Â®Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â³ÃƒËœÃ‚ÂªÃƒÂ¢Ã¢â€šÂ¬Ã…â€™Ãƒâ„¢Ã¢â‚¬Â¡ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã¢â‚¬Â '),
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
      body: RefreshIndicator(
        onRefresh: _controller.loadUserRequests,
        color: AppColors.lightSecondary,
        child: Column(
          children: [
            // Status Filter Tabs
            Container(
              height: 48.h,
              color: Colors.white,
              child: Obx(() {
                final current = _controller.selectedFilterStatus.value;
                final filters = [
                  {'id': 'ALL', 'label': l10nPick(context, en: 'All', fa: 'Ãƒâ„¢Ã¢â‚¬Â¡Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã¢â‚¬Â¡')},
                  {'id': 'UNDER_REVIEW', 'label': l10nPick(context, en: 'Reviewing', fa: 'ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â± ÃƒËœÃ‚Â­ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Å¾ ÃƒËœÃ‚Â¨ÃƒËœÃ‚Â±ÃƒËœÃ‚Â±ÃƒËœÃ‚Â³Ãƒâ€ºÃ…â€™')},
                  {'id': 'AWAITING_PAYMENT', 'label': l10nPick(context, en: 'Payment', fa: 'Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚ÂªÃƒËœÃ‚Â¸ÃƒËœÃ‚Â± Ãƒâ„¢Ã‚Â¾ÃƒËœÃ‚Â±ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â§ÃƒËœÃ‚Â®ÃƒËœÃ‚Âª')},
                  {'id': 'APPROVED', 'label': l10nPick(context, en: 'Approved', fa: 'ÃƒËœÃ‚ÂµÃƒËœÃ‚Â§ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â±ÃƒËœÃ‚Â´ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Â¡')},
                  {'id': 'REJECTED', 'label': l10nPick(context, en: 'Rejected', fa: 'ÃƒËœÃ‚Â±ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â´ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Â¡')},
                ];

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: filters.length,
                  separatorBuilder: (_, _) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final f = filters[index];
                    final isSelected = current == f['id'];

                    return InkWell(
                      onTap: () {
                        _controller.selectedFilterStatus.value = f['id'] as String;
                      },
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.lightSecondary : AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Center(
                          child: Text(
                            f['label'] as String,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            const Divider(height: 1),

            // List of Requests
            Expanded(
              child: Obx(() {
                if (_controller.isLoadingRequests.value && _controller.myRequests.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = _controller.filteredRequests;

                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.r),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_outlined, size: 64.r, color: Colors.grey[400]),
                          SizedBox(height: 12.h),
                          Text(
                            l10nPick(context, en: 'No visa applications found', fa: 'Ãƒâ„¢Ã¢â‚¬Â¡Ãƒâ€ºÃ…â€™ÃƒÅ¡Ã¢â‚¬Â  ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â±ÃƒËœÃ‚Â®Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â³ÃƒËœÃ‚Âª Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™Ãƒâ€ºÃ…â€™ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â§Ãƒâ„¢Ã‚ÂÃƒËœÃ‚Âª Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚Â´ÃƒËœÃ‚Â¯'),
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.lightTextSecondary),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            l10nPick(
                              context,
                              en: 'Apply for your destination visa and track the status in real time.',
                              fa: 'ÃƒÅ¡Ã‚Â©ÃƒËœÃ‚Â´Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â± Ãƒâ„¢Ã¢â‚¬Â¦Ãƒâ„¢Ã¢â‚¬Å¡ÃƒËœÃ‚ÂµÃƒËœÃ‚Â¯ ÃƒËœÃ‚Â®Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â¯ ÃƒËœÃ‚Â±ÃƒËœÃ‚Â§ ÃƒËœÃ‚Â§Ãƒâ„¢Ã¢â‚¬Â ÃƒËœÃ‚ÂªÃƒËœÃ‚Â®ÃƒËœÃ‚Â§ÃƒËœÃ‚Â¨ ÃƒÅ¡Ã‚Â©ÃƒËœÃ‚Â±ÃƒËœÃ‚Â¯Ãƒâ„¢Ã¢â‚¬Â¡ Ãƒâ„¢Ã‹â€  ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â±ÃƒËœÃ‚Â®Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â³ÃƒËœÃ‚Âª Ãƒâ„¢Ã‹â€ Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â²ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™ ÃƒËœÃ‚Â¢Ãƒâ„¢Ã¢â‚¬Â Ãƒâ„¢Ã¢â‚¬Å¾ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™Ãƒâ„¢Ã¢â‚¬Â  ÃƒËœÃ‚Â«ÃƒËœÃ‚Â¨ÃƒËœÃ‚Âª Ãƒâ„¢Ã‚ÂÃƒËœÃ‚Â±Ãƒâ„¢Ã¢â‚¬Â¦ÃƒËœÃ‚Â§Ãƒâ€ºÃ…â€™Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â¯.',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11.5.sp, color: AppColors.lightTextSecondary),
                          ),
                          SizedBox(height: 20.h),
                          ElevatedButton.icon(
                            onPressed: () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightSecondary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                            ),
                            icon: const Icon(Icons.add, color: Colors.white, size: 18),
                            label: Text(
                              l10nPick(context, en: 'New Application', fa: 'ÃƒËœÃ‚Â«ÃƒËœÃ‚Â¨ÃƒËœÃ‚Âª ÃƒËœÃ‚Â¯ÃƒËœÃ‚Â±ÃƒËœÃ‚Â®Ãƒâ„¢Ã‹â€ ÃƒËœÃ‚Â§ÃƒËœÃ‚Â³ÃƒËœÃ‚Âª ÃƒËœÃ‚Â¬ÃƒËœÃ‚Â¯Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â¯'),
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final req = list[index];
                    return _VisaRequestCard(
                      request: req,
                      onTap: () {
                        Get.to(() => VisaDetailScreen(caseNo: req.caseNo));
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisaRequestCard extends StatelessWidget {
  final VisaRequestModel request;
  final VoidCallback onTap;

  const _VisaRequestCard({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return VisaCard(
      onTap: onTap,
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
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.applicantName,
                    style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 2.h),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      request.caseNo,
                      style: TextStyle(fontSize: 11.sp, color: AppColors.lightTextSecondary),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${request.totalFee.toStringAsFixed(0)} ${request.currency}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.lightSecondary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Text(
                        l10nPick(context, en: 'Track', fa: 'Ãƒâ„¢Ã‚Â¾Ãƒâ€ºÃ…â€™ÃƒÅ¡Ã‚Â¯Ãƒâ€ºÃ…â€™ÃƒËœÃ‚Â±Ãƒâ€ºÃ…â€™'),
                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.lightSecondary),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.lightSecondary),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
