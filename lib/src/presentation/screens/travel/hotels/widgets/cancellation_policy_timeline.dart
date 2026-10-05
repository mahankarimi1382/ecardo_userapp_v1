import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// intl exports its own TextDirection (RTL/LTR constants) which shadows
// dart:ui's — hide it so `TextDirection.rtl` resolves to the engine type.
import 'package:intl/intl.dart' hide TextDirection;

import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';

/// Represents a single stage in the cancellation policy timeline.
class CancellationPolicyStage {
  final int stageNumber;
  final String titleEn;
  final String titleFa;
  final String refundRateEn;
  final String refundRateFa;
  final String deadlineDescriptionEn;
  final String deadlineDescriptionFa;
  final String detailsEn;
  final String detailsFa;
  final Color primaryColor;
  final Color containerColor;
  final IconData icon;

  const CancellationPolicyStage({
    required this.stageNumber,
    required this.titleEn,
    required this.titleFa,
    required this.refundRateEn,
    required this.refundRateFa,
    required this.deadlineDescriptionEn,
    required this.deadlineDescriptionFa,
    required this.detailsEn,
    required this.detailsFa,
    required this.primaryColor,
    required this.containerColor,
    required this.icon,
  });

  String localizedTitle(bool isRtl) => isRtl ? titleFa : titleEn;
  String localizedRefundRate(bool isRtl) => isRtl ? refundRateFa : refundRateEn;
  String localizedDeadline(bool isRtl) =>
      isRtl ? deadlineDescriptionFa : deadlineDescriptionEn;
  String localizedDetails(bool isRtl) => isRtl ? detailsFa : detailsEn;
}

/// Helper function to display the cancellation policy timeline modal bottom sheet.
Future<void> showCancellationPolicyTimelineModal(
  BuildContext context, {
  DateTime? checkInDate,
  String? customPolicySummary,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) => CancellationPolicyTimelineModal(
      checkInDate: checkInDate,
      customPolicySummary: customPolicySummary,
    ),
  );
}

/// Standalone visual card showing the cancellation policy timeline summary
/// with an action to expand into the full modal breakdown.
class CancellationPolicyTimelineCard extends StatelessWidget {
  final DateTime? checkInDate;
  final String? customPolicySummary;
  final bool showViewDetailsButton;
  final VoidCallback? onTap;

  const CancellationPolicyTimelineCard({
    super.key,
    this.checkInDate,
    this.customPolicySummary,
    this.showViewDetailsButton = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final stages = _generateStages(context, checkInDate, isRtl);
    final cardBg = ECardoTokens.surfaceCard(context);
    final borderColor = ECardoTokens.border(context);
    final textPrimary = ECardoTokens.ink(context);
    final textSecondary = ECardoTokens.inkMuted(context);
    final brandColor = ECardoTokens.brand700(context);

    return Semantics(
      label:
          'Cancellation & Refund Timeline - $brandColor',
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
          border: Border.all(
            color: borderColor.withValues(alpha: 0.8),
            width: 1.w,
          ),
          boxShadow: ECardoTokens.shadowCard(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: ECardoTokens.successBg(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.security_rounded,
                      color: ECardoTokens.success(context),
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRtl
                              ? 'قوانین و جدول زمانی استرداد وجه'
                              : 'Cancellation & Refund Timeline',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          isRtl
                              ? 'استرداد فوری به کیف پول eCardo بدون کارمزد'
                              : 'Instant eCardo Wallet deposit with zero fees',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showViewDetailsButton)
                    ConstrainedBox(
                      constraints: BoxConstraints(minWidth: 44.w, minHeight: 44.h),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 14.sp,
                        color: brandColor,
                        onPressed: onTap ??
                            () => showCancellationPolicyTimelineModal(
                                  context,
                                  checkInDate: checkInDate,
                                  customPolicySummary: customPolicySummary,
                                ),
                        icon: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Horizontal Stages Tracker
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  for (var i = 0; i < stages.length; i++) ...[
                    Expanded(
                      child: _buildStagePreviewPill(context, stages[i], isRtl),
                    ),
                    if (i < stages.length - 1)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Icon(
                          isRtl
                              ? Icons.chevron_left_rounded
                              : Icons.chevron_right_rounded,
                          size: 16.sp,
                          color: textSecondary.withValues(alpha: 0.5),
                        ),
                      ),
                  ],
                ],
              ),
            ),

            // Wallet Deposit Rules Banner
            Container(
              margin: EdgeInsets.all(16.r),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: ECardoTokens.brand100(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                border: Border.all(
                  color: brandColor.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 18.sp,
                    color: brandColor,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      isRtl
                          ? 'مبالغ استردادی بین ۱ تا ۲۴ ساعت کاری مستقیماً به کیف پول eCardo شما واریز می‌شود.'
                          : 'Refunds deposit directly to your eCardo Wallet within 1-24 hours.',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: textPrimary,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onTap ??
                        () => showCancellationPolicyTimelineModal(
                              context,
                              checkInDate: checkInDate,
                              customPolicySummary: customPolicySummary,
                            ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      isRtl ? 'جزئیات' : 'Details',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: brandColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStagePreviewPill(
    BuildContext context,
    CancellationPolicyStage stage,
    bool isRtl,
  ) {
    final isDark = ECardoTokens.isDark(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark
            ? stage.primaryColor.withValues(alpha: 0.18)
            : stage.containerColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: stage.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                stage.icon,
                size: 13.sp,
                color: stage.primaryColor,
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  stage.localizedRefundRate(isRtl),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: stage.primaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            stage.localizedTitle(isRtl),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: ECardoTokens.ink(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Detailed Modal Bottom Sheet showing the comprehensive 3-stage cancellation timeline,
/// date thresholds, and wallet deposit rules.
class CancellationPolicyTimelineModal extends StatelessWidget {
  final DateTime? checkInDate;
  final String? customPolicySummary;

  const CancellationPolicyTimelineModal({
    super.key,
    this.checkInDate,
    this.customPolicySummary,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final stages = _generateStages(context, checkInDate, isRtl);
    final cardBg = ECardoTokens.surfaceCard(context);
    final borderColor = ECardoTokens.border(context);
    final brandColor = ECardoTokens.brand700(context);
    final textPrimary = ECardoTokens.ink(context);
    final textSecondary = ECardoTokens.inkMuted(context);

    return Semantics(
      label: 'Cancellation Policy & Refund Timeline',
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ECardoTokens.radius2xl),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            SizedBox(height: 10.h),
            Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 14.h),

            // Modal Title & Close
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: ECardoTokens.brand100(context),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                    ),
                    child: Icon(
                      Icons.timeline_rounded,
                      size: 20.sp,
                      color: brandColor,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      isRtl
                          ? 'مراحل و قوانین استرداد هزینه'
                          : 'Cancellation Policy & Refund Timeline',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Divider(color: borderColor, height: 16.h),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                children: [
                  // Info banner
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: ECardoTokens.isDark(context)
                          ? ECardoTokens.surfaceSunken(context)
                          : ECardoTokens.surfaceCanvas(context),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      border: Border.all(
                        color: borderColor.withValues(alpha: 0.7),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 20.sp,
                          color: brandColor,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            isRtl
                                ? 'سیاست لغو هتل بر اساس زمان ورود رسمی محاسبه می‌شود. تمام زمان‌ها به وقت محلی هتل مقصد است.'
                                : 'Cancellation policy is calculated relative to official hotel check-in time. All times in destination local time.',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: textSecondary,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h),

                  // Vertical Timeline of 3 Stages
                  Text(
                    isRtl ? 'مراحل استرداد وجه' : 'Refund Schedule Stages',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  for (var index = 0; index < stages.length; index++) ...[
                    _buildTimelineStageNode(
                      context: context,
                      stage: stages[index],
                      isLast: index == stages.length - 1,
                      isRtl: isRtl,
                    ),
                  ],

                  SizedBox(height: 20.h),

                  // Plain-Language Wallet Deposit Rules Section
                  _buildWalletRulesSection(context, isRtl),

                  SizedBox(height: 16.h),

                  // Custom provider policy note if available
                  if (customPolicySummary != null &&
                      customPolicySummary!.trim().isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: ECardoTokens.brand100(context),
                        borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                        border: Border.all(
                          color: brandColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRtl ? 'یادداشت هتل' : 'Hotel Specific Policy Note',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: brandColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            customPolicySummary!,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ],
              ),
            ),

            // Bottom Action Button
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 14.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 44.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandColor,
                        foregroundColor: ECardoTokens.inkOnBrand,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ECardoTokens.radiusLg,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                      ),
                      child: Text(
                        isRtl ? 'متوجه شدم' : 'Understood',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStageNode({
    required BuildContext context,
    required CancellationPolicyStage stage,
    required bool isLast,
    required bool isRtl,
  }) {
    final isDark = ECardoTokens.isDark(context);
    final cardBg = ECardoTokens.surfaceCard(context);
    final borderColor = ECardoTokens.border(context);
    final textPrimary = ECardoTokens.ink(context);
    final textSecondary = ECardoTokens.inkMuted(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Node & Track Column
          Column(
            children: [
              // Circular Indicator
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: isDark
                      ? stage.primaryColor.withValues(alpha: 0.18)
                      : stage.containerColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: stage.primaryColor,
                    width: 2.w,
                  ),
                ),
                child: Center(
                  child: Icon(
                    stage.icon,
                    size: 16.sp,
                    color: stage.primaryColor,
                  ),
                ),
              ),
              // Connecting Line to next node
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(1.r),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(width: 14.w),

          // Stage Details Card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: isDark
                    ? ECardoTokens.surfaceSunken(context)
                    : cardBg,
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                border: Border.all(
                  color: stage.primaryColor.withValues(alpha: 0.25),
                  width: 1.w,
                ),
                boxShadow: ECardoTokens.shadowCard(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Badge Row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          stage.localizedTitle(isRtl),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? stage.primaryColor.withValues(alpha: 0.18)
                              : stage.containerColor,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          stage.localizedRefundRate(isRtl),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            color: stage.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6.h),

                  // Deadline Window Text
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 13.sp,
                        color: textSecondary,
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Text(
                          stage.localizedDeadline(isRtl),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: stage.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6.h),

                  // Plain Explanation Text
                  Text(
                    stage.localizedDetails(isRtl),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: textSecondary,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
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

  Widget _buildWalletRulesSection(BuildContext context, bool isRtl) {
    final isDark = ECardoTokens.isDark(context);
    final textPrimary = ECardoTokens.ink(context);
    final borderColor = ECardoTokens.border(context);
    final brandColor = ECardoTokens.brand700(context);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark
            ? ECardoTokens.surfaceSunken(context)
            : ECardoTokens.infoBg(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        border: Border.all(
          color: isDark
              ? borderColor
              : brandColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: ECardoTokens.brand100(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 18.sp,
                  color: brandColor,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                isRtl
                    ? 'قوانین واریز به کیف پول eCardo'
                    : 'eCardo Wallet Deposit & Settlement Rules',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          _buildRuleItem(
            context: context,
            icon: Icons.flash_on_rounded,
            title: isRtl ? 'واریز مستقیم و آنی' : 'Fast Direct Credit',
            description: isRtl
                ? 'مبلغ استرداد شده بلافاصله پس از تأیید لغو (معمولاً بین ۱ تا ۲۴ ساعت) به کیف پول کاربر واریز می‌شود.'
                : 'Approved refunds are credited directly to your eCardo Wallet within 1 to 24 hours.',
            isRtl: isRtl,
          ),
          SizedBox(height: 10.h),

          _buildRuleItem(
            context: context,
            icon: Icons.money_off_rounded,
            title: isRtl ? 'بدون کارمزد اضافه' : 'Zero Processing Fees',
            description: isRtl
                ? 'در بازه لغو رایگان، ۱۰۰٪ مبلغ پرداختی بدون کسر هیچ‌گونه کارمزد اداری بازگردانده می‌شود.'
                : '100% of eligible refund amount is returned with zero platform cancellation or handling charges.',
            isRtl: isRtl,
          ),
          SizedBox(height: 10.h),

          _buildRuleItem(
            context: context,
            icon: Icons.sync_alt_rounded,
            title: isRtl ? 'قابلیت استفاده مجدد یا برداشت' : 'Reusable or Withdrawable',
            description: isRtl
                ? 'موجودی کیف پول بلافاصله برای رزرو پرواز، هتل یا بسته eSIM دیگر در دسترس است و امکان تسویه بانکی نیز وجود دارد.'
                : 'Wallet balance can immediately book replacement flights, hotels, eSIM or be cashed out.',
            isRtl: isRtl,
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required bool isRtl,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: ECardoTokens.brand700(context),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: ECardoTokens.ink(context),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: ECardoTokens.inkMuted(context),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Helper function to construct the three standard stages dynamically.
List<CancellationPolicyStage> _generateStages(
  BuildContext context,
  DateTime? checkInDate,
  bool isRtl,
) {
  String stage1Deadline;
  String stage2Deadline;
  String stage3Deadline;

  if (checkInDate != null) {
    final format = DateFormat('yyyy/MM/dd HH:mm');
    final stage1Date = checkInDate.subtract(const Duration(hours: 48));
    final stage2Date = checkInDate.subtract(const Duration(hours: 24));

    stage1Deadline = isRtl
        ? 'تا قبل از ${format.format(stage1Date)}'
        : 'Before ${format.format(stage1Date)}';
    stage2Deadline = isRtl
        ? 'از ${format.format(stage1Date)} تا ${format.format(stage2Date)}'
        : 'From ${format.format(stage1Date)} to ${format.format(stage2Date)}';
    stage3Deadline = isRtl
        ? 'بعد از ${format.format(stage2Date)} یا عدم مراجعه'
        : 'After ${format.format(stage2Date)} or No-Show';
  } else {
    stage1Deadline = isRtl
        ? 'تا ۴۸ ساعت قبل از زمان ورود'
        : 'Up to 48 hours before check-in';
    stage2Deadline = isRtl
        ? 'بین ۴۸ تا ۲۴ ساعت قبل از زمان ورود'
        : 'Between 48h and 24h before check-in';
    stage3Deadline = isRtl
        ? 'کمتر از ۲۴ ساعت تا زمان ورود یا عدم حضور'
        : 'Within 24 hours of check-in or No-Show';
  }

  final successColor = ECardoTokens.success(context);
  final warningColor = ECardoTokens.warning(context);
  final dangerColor = ECardoTokens.danger(context);
  final successBgColor = ECardoTokens.successBg(context);
  final warningBgColor = ECardoTokens.warningBg(context);
  final dangerBgColor = ECardoTokens.dangerBg(context);

  return [
    // Stage 1: 100% Free Cancellation
    CancellationPolicyStage(
      stageNumber: 1,
      titleEn: '100% Free Cancellation',
      titleFa: 'کنسلی ۱۰۰٪ رایگان',
      refundRateEn: '100% Refund',
      refundRateFa: 'استرداد ۱۰۰٪',
      deadlineDescriptionEn: stage1Deadline,
      deadlineDescriptionFa: stage1Deadline,
      detailsEn:
          'Cancel your booking before this deadline to receive a full 100% refund deposited directly to your eCardo Wallet with zero deduction.',
      detailsFa:
          'لغو رزرو تا قبل از این تاریخ بدون هیچ‌گونه جریمه انجام می‌شود و ۱۰۰٪ وجه مستقیماً به کیف پول eCardo شما برگشت داده می‌شود.',
      primaryColor: successColor,
      containerColor: successBgColor,
      icon: Icons.check_circle_rounded,
    ),

    // Stage 2: Partial Refund / 1 Night Fee
    CancellationPolicyStage(
      stageNumber: 2,
      titleEn: 'Partial Refund / 1 Night Fee',
      titleFa: 'استرداد با کسر هزینه ۱ شب',
      refundRateEn: 'Partial Refund',
      refundRateFa: 'استرداد با جریمه',
      deadlineDescriptionEn: stage2Deadline,
      deadlineDescriptionFa: stage2Deadline,
      detailsEn:
          'Cancellations within this period incur a penalty equal to the first night of the booking. The remainder is automatically refunded.',
      detailsFa:
          'در صورت لغو در این بازه زمانی، جریمه معادل هزینه اقامت شب اول کسر شده و مابقی مبلغ به کیف پول کاربر بازگردانده می‌شود.',
      primaryColor: warningColor,
      containerColor: warningBgColor,
      icon: Icons.warning_amber_rounded,
    ),

    // Stage 3: Non-refundable
    CancellationPolicyStage(
      stageNumber: 3,
      titleEn: 'Non-refundable / No-Show',
      titleFa: 'غیرقابل استرداد / غیبت',
      refundRateEn: '0% Refund',
      refundRateFa: 'عدم استرداد',
      deadlineDescriptionEn: stage3Deadline,
      deadlineDescriptionFa: stage3Deadline,
      detailsEn:
          'Cancellations requested within 24 hours of scheduled check-in or failure to arrive (no-show) are strictly non-refundable.',
      detailsFa:
          'درخواست‌های لغو در کمتر از ۲۴ ساعت مانده به ساعت تحویل اتاق یا عدم حضور مهمان مشمول جریمه ۱۰۰٪ بوده و غیرقابل استرداد است.',
      primaryColor: dangerColor,
      containerColor: dangerBgColor,
      icon: Icons.cancel_rounded,
    ),
  ];
}
