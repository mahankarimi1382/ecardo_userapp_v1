// DATA: MOCK (Ready for REAL backend domain registration under schema_version: 1.0)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/local_experience_controller.dart';
import '../models/local_experience_models.dart';
import '../../local/models/experience_contracts.dart';
import '../../local/widgets/experience_ui_components.dart';
import 'local_voucher_screen.dart';

class LocalDetailScreen extends StatefulWidget {
  final LocalExperienceItemModel experience;

  const LocalDetailScreen({
    super.key,
    required this.experience,
  });

  @override
  State<LocalDetailScreen> createState() => _LocalDetailScreenState();
}

class _LocalDetailScreenState extends State<LocalDetailScreen> {
  late final LocalExperienceController controller;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) {
      HapticFeedback.selectionClick();
      controller.selectedDate.value = picked;
    }
  }

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LocalExperienceController>()
        ? Get.find<LocalExperienceController>()
        : Get.put(LocalExperienceController());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const tealColor = Color(0xFF0F766E);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: AppSpacing.iconSm.sp,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.back();
          },
        ),
        title: Text(
          l10nPick(context, fa: 'مشخصات خدمت و رزرو', en: 'Experience Details'),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.lg.r),
              children: [
                // Hero Info Card
                _buildHeroCard(context, isDark, tealColor),
                SizedBox(height: AppSpacing.lg.h),

                // Date & Time Config Card
                _buildDateAndTimeCard(context, isDark, tealColor),
                SizedBox(height: AppSpacing.lg.h),

                // Highlights Card
                _buildHighlightsCard(context, isDark, tealColor),
                SizedBox(height: AppSpacing.lg.h),

                // Meeting Point & Map Advisory
                _buildMeetingPointCard(context, isDark, tealColor),
                SizedBox(height: AppSpacing.lg.h),

                // Cancellation Policy Card
                _buildCancellationPolicyCard(context, isDark, tealColor),
                SizedBox(height: AppSpacing.lg.h),

                // Description
                _buildDescriptionCard(context, isDark),
                SizedBox(height: AppSpacing.xxl.h),
              ],
            ),
          ),

          // Bottom Bar
          Obx(() {
            final total = controller.calculateTotal(widget.experience);
            final vErr = controller.validationError.value.isNotEmpty;
            final isSubmitting = controller.uiState.value == ExperienceServiceState.processing;

            return Container(
              padding: EdgeInsets.all(AppSpacing.lg.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Validation Error Banner
                  if (vErr)
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          controller.validationError.value,
                          style: TextStyle(fontSize: 11.5.sp, color: AppColors.error, height: 1.4),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'مبلغ نهایی (${widget.experience.durationLabel})',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${total.toStringAsFixed(0)} ${widget.experience.currency}',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                              color: tealColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tealColor,
                            minimumSize: Size(double.infinity, 44.h),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                            ),
                            elevation: 0,
                          ),
                          onPressed: isSubmitting || vErr
                              ? null
                              : () async {
                                  HapticFeedback.heavyImpact();
                                  final booking = await controller.bookExperience(item: widget.experience);
                                  if (booking != null) {
                                    Get.off(() => LocalVoucherScreen(booking: booking));
                                  }
                                },
                          child: isSubmitting
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'پرداخت و صدور واچر',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, bool isDark, Color tealColor) {
    final hasImage = widget.experience.images.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            ExperienceNetworkImage(
              imageUrl: widget.experience.images.first,
              width: double.infinity,
              height: 180.h,
              borderRadius: AppSpacing.radius,
              fallbackIcon: Icons.place_rounded,
              semanticLabel: widget.experience.title,
            ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: tealColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          widget.experience.typeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: tealColor,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                        SizedBox(width: 4.w),
                        Text(
                          '${widget.experience.rating} (${widget.experience.reviewsCount} نظر)',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  widget.experience.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  widget.experience.subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Icon(Icons.person_pin_rounded, size: 16.sp, color: tealColor),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        widget.experience.providerName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 6.w,
                  children: widget.experience.languages.map((l) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        l,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateAndTimeCard(BuildContext context, bool isDark, Color tealColor) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10nPick(context, fa: 'زمان‌بندی و تعداد نفرات', en: 'Date & Guests'),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          // Adults selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('بزرگسالان',
                        style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                    Text('${widget.experience.price.toStringAsFixed(0)} ${widget.experience.currency} / نفر',
                        style: TextStyle(
                            fontSize: 10.5.sp,
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary)),
                  ],
                ),
              ),
              Obx(() {
                final gCount = controller.guestsCount.value;
                final cCount = controller.childrenCount.value;
                final totalGuests = gCount + cCount;
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                      color: tealColor,
                      onPressed: gCount > 1
                          ? () {
                              HapticFeedback.selectionClick();
                              controller.guestsCount.value--;
                            }
                          : null,
                    ),
                    Text(
                      '$gCount',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      color: tealColor,
                      onPressed: totalGuests < widget.experience.maxGuests
                          ? () {
                              HapticFeedback.selectionClick();
                              controller.guestsCount.value++;
                            }
                          : null,
                    ),
                  ],
                );
              }),
            ],
          ),
          const Divider(),
          // Children selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('کودکان (۲ تا ۱۲ سال)',
                        style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                    Text(
                        widget.experience.childPrice > 0
                            ? '${widget.experience.childPrice.toStringAsFixed(0)} ${widget.experience.currency} / نفر'
                            : 'تعرفه نیم‌بها',
                        style: TextStyle(
                            fontSize: 10.5.sp,
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary)),
                  ],
                ),
              ),
              Obx(() {
                final cCount = controller.childrenCount.value;
                final totalGuests = controller.guestsCount.value + cCount;
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                      color: tealColor,
                      onPressed: cCount > 0
                          ? () {
                              HapticFeedback.selectionClick();
                              controller.childrenCount.value--;
                            }
                          : null,
                    ),
                    Text(
                      '$cCount',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      color: tealColor,
                      onPressed: totalGuests < widget.experience.maxGuests
                          ? () {
                              HapticFeedback.selectionClick();
                              controller.childrenCount.value++;
                            }
                          : null,
                    ),
                  ],
                );
              }),
            ],
          ),
          SizedBox(height: 10.h),
          // Date picker
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 16.sp, color: tealColor),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Obx(() => Text(
                                DateFormat('yyyy/MM/dd').format(controller.selectedDate.value),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'همراهان:',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Obx(() => Text(
                              '${controller.guestsCount.value}ب + ${controller.childrenCount.value}ک',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsCard(BuildContext context, bool isDark, Color tealColor) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10nPick(context, fa: 'مزایا و ویژگی‌های این خدمت', en: 'Service Highlights'),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          ...widget.experience.highlights.map(
            (h) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      h,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingPointCard(BuildContext context, bool isDark, Color tealColor) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on_outlined, color: tealColor, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'محل گردهمایی و آغاز خدمت:',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.experience.meetingPoint,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationPolicyCard(BuildContext context, bool isDark, Color tealColor) {
    final policy = widget.experience.cancellationPolicy;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: AppColors.success, size: 18.sp),
              SizedBox(width: 6.w),
              Text(
                'شرایط لغو و استرداد وجه',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '• لغو رایگان تا ${policy.freeCancellationHours} ساعت قبل از سرویس با استرداد ۱۰۰٪ به کیف پول',
            style: TextStyle(
              fontSize: 11.5.sp,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '• لغو کمتر از ${policy.freeCancellationHours} ساعت: ${policy.lateCancelPenaltyPercent.toStringAsFixed(0)}٪ جریمه کنسلی',
            style: TextStyle(
              fontSize: 11.5.sp,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10nPick(context, fa: 'درباره این تجربه', en: 'Overview'),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            widget.experience.description,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.6,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
