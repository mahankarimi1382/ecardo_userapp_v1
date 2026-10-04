import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_spacing.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          l10nPick(context, en: 'My Visa Applications', fa: 'درخواست‌های ویزای من'),
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            size: AppSpacing.iconSm.r,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _controller.loadUserRequests,
        color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
        child: Column(
          children: [
            // Status Filter Tabs
            Container(
              height: 48.h,
              color: isDark ? AppColors.darkSurface : AppColors.white,
              child: Obx(() {
                final current = _controller.selectedFilterStatus.value;
                final filters = [
                  {'id': 'ALL', 'label': l10nPick(context, en: 'All', fa: 'همه')},
                  {'id': 'UNDER_REVIEW', 'label': l10nPick(context, en: 'Reviewing', fa: 'در حال بررسی')},
                  {'id': 'AWAITING_PAYMENT', 'label': l10nPick(context, en: 'Payment', fa: 'منتظر پرداخت')},
                  {'id': 'APPROVED', 'label': l10nPick(context, en: 'Approved', fa: 'صادرشده')},
                  {'id': 'REJECTED', 'label': l10nPick(context, en: 'Rejected', fa: 'ردشده')},
                ];

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg.w,
                    vertical: AppSpacing.sm.h,
                  ),
                  itemCount: filters.length,
                  separatorBuilder: (_, _) => SizedBox(width: AppSpacing.sm.w),
                  itemBuilder: (context, index) {
                    final f = filters[index];
                    final isSelected = current == f['id'];

                    return InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _controller.selectedFilterStatus.value = f['id'] as String;
                      },
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md.w,
                          vertical: AppSpacing.xs.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? AppColors.darkPrimary : AppColors.lightSecondary)
                              : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                        ),
                        child: Center(
                          child: Text(
                            f['label'] as String,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected
                                  ? (isDark ? AppColors.deepBlack : AppColors.white)
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            Divider(
              height: 1,
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),

            // List of Requests (4 States)
            Expanded(
              child: Obx(() {
                // 1. Loading State (Shimmer skeleton)
                if (_controller.isLoadingRequests.value && _controller.myRequests.isEmpty) {
                  return _buildLoadingSkeleton(isDark);
                }

                final list = _controller.filteredRequests;

                // 2. Empty State
                if (list.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(AppSpacing.xxxl.r),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppSpacing.xl.r),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.assignment_outlined,
                              size: 48.r,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                            ),
                          ),
                          SizedBox(height: AppSpacing.md.h),
                          Text(
                            l10nPick(context, en: 'No visa applications found', fa: 'هیچ پرونده ویزایی یافت نشد'),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs.h),
                          Text(
                            l10nPick(
                              context,
                              en: 'Apply for your destination visa and track the status in real time.',
                              fa: 'کشور مقصد خود را انتخاب کرده و درخواست ویزا را به صورت آنلاین ثبت نمایید.',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xl.h),
                          ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                              foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
                              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w, vertical: AppSpacing.md.h),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(
                              l10nPick(context, en: 'New Application', fa: 'ثبت درخواست جدید'),
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // 3. Content State
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg.w,
                    vertical: AppSpacing.lg.h,
                  ),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
                  itemBuilder: (context, index) {
                    final req = list[index];
                    return _VisaRequestCard(
                      request: req,
                      isDark: isDark,
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

  Widget _buildLoadingSkeleton(bool isDark) {
    final baseColor = isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade300;
    final highlightColor = isDark ? AppColors.darkSurface : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.lg.r),
        itemCount: 4,
        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
        itemBuilder: (_, _) => Container(
          height: 120.h,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
          ),
        ),
      ),
    );
  }
}

class _VisaRequestCard extends StatelessWidget {
  final VisaRequestModel request;
  final bool isDark;
  final VoidCallback onTap;

  const _VisaRequestCard({
    required this.request,
    required this.isDark,
    required this.onTap,
  });

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
                  SizedBox(width: AppSpacing.sm.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.countryName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        request.visaTitle,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              VisaStatusBadge(status: request.status),
            ],
          ),
          Divider(
            height: AppSpacing.xl,
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.applicantName,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      request.caseNo,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
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
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Text(
                        l10nPick(context, en: 'Track', fa: 'رهگیری'),
                        style: TextStyle(
                          fontSize: 11.sp,
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
        ],
      ),
    );
  }
}
