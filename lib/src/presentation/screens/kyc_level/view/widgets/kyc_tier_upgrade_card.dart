import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';

/// Explicit status of a KYC tier verification.
enum KycTierStatus {
  verified,
  pending,
  rejected,
  actionRequired,
  unverified,
}

/// KycTierUpgradeCard — Pillar 2 of Block 4 (Cards & Security)
///
/// Visual tier comparison and upgrade roadmap card supporting:
///   - Tier 1 (Basic / برنزی): Email & Phone verified, $1,000/day limit, 1 Virtual Card.
///   - Tier 2 (Standard / نقره‌ای): National ID / Passport verified, $10,000/day limit,
///     3 Virtual Cards, Travel & Exchange allowed.
///   - Tier 3 (VIP / طلایی): Proof of Address & Video Liveness verified,
///     Unlimited / $100,000/day limit, Unlimited Cards, Loan & Guarantee access,
///     Dedicated VIP Concierge.
///
/// Modernized Features:
///   - Status Badges: Verified (emerald green), Pending (amber hourglass),
///     Rejected (crimson error), Action Required (deep orange warning).
///   - Required Documents List for each tier with structured indicators.
///   - Upload Progress Indicator: visual bar with percentage & filename when uploading.
///   - Comprehensive Dark / Light mode adaptation with M3 tokens.
///   - Accessible touch targets (min 48x48dp) and RTL layout support.
class KycTierUpgradeCard extends StatefulWidget {
  /// Override user's current tier (1, 2, or 3; 0 for unverified).
  /// If null, reads dynamically from [KycLevelController].
  final int? currentTier;

  /// Initially selected tier in the comparison carousel (1, 2, or 3).
  /// If null, defaults to next tier (or current tier if at max).
  final int? initialSelectedTier;

  /// Consumed daily limit in USD. If null, a realistic sample usage is calculated
  /// relative to the current tier's cap.
  final double? consumedDailyLimit;

  /// Total daily limit override in USD. If null, derived from current tier cap.
  final double? totalDailyLimit;

  /// Custom callback on upgrade button tap. If null, navigates to
  /// [BaseRoute.kycSubmitWizard] with `arguments: {'target_level': targetTier}`.
  final void Function(int targetTier)? onUpgradeTap;

  /// Explicit status badge override (e.g. [KycTierStatus.verified], [KycTierStatus.pending],
  /// [KycTierStatus.rejected], [KycTierStatus.actionRequired]).
  final KycTierStatus? statusOverride;

  /// Optional text label override for status badge (e.g. 'Pending', 'Verified', 'Rejected', 'Action Required').
  final String? statusBadgeOverride;

  /// In-progress upload progress fraction (0.0 to 1.0). When non-null,
  /// renders the active upload progress indicator.
  final double? uploadProgress;

  /// Descriptive label for upload progress (e.g., "Uploading National ID Front...").
  final String? uploadProgressLabel;

  /// Optional cancel callback for in-progress uploads.
  final VoidCallback? onCancelUpload;

  /// Whether to show the outer card border and shadow. Default is true.
  final bool showElevation;

  const KycTierUpgradeCard({
    super.key,
    this.currentTier,
    this.initialSelectedTier,
    this.consumedDailyLimit,
    this.totalDailyLimit,
    this.onUpgradeTap,
    this.statusOverride,
    this.statusBadgeOverride,
    this.uploadProgress,
    this.uploadProgressLabel,
    this.onCancelUpload,
    this.showElevation = true,
  });

  @override
  State<KycTierUpgradeCard> createState() => _KycTierUpgradeCardState();
}

class _KycTierUpgradeCardState extends State<KycTierUpgradeCard>
    with SingleTickerProviderStateMixin {
  late int _selectedTier;
  late AnimationController _animController;
  late Animation<double> _glowAnimation;

  bool _shouldReduceMotion(BuildContext context) {
    return (MediaQuery.maybeDisableAnimationsOf(context) ?? false) ||
        (WidgetsBinding.instance is! WidgetsFlutterBinding) ||
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
  }

  @override
  void initState() {
    super.initState();
    final effectiveCurrent = _resolveCurrentTier();
    final defaultTarget = (effectiveCurrent >= 3)
        ? 3
        : (effectiveCurrent <= 0 ? 1 : effectiveCurrent + 1);
    _selectedTier = widget.initialSelectedTier ?? defaultTarget;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _glowAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shouldReduceMotion(context)) {
      if (_animController.isAnimating) {
        _animController.stop();
      }
      _animController.value = 1.0;
    } else if (!_animController.isAnimating) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  KycLevelController? _findController() {
    if (Get.isRegistered<KycLevelController>()) {
      return Get.find<KycLevelController>();
    }
    return null;
  }

  int _resolveCurrentTier() {
    if (widget.currentTier != null) return widget.currentTier!;
    final controller = _findController();
    if (controller != null) {
      final status = controller.status.value;
      if (status != null) return status.currentLevel;
      final badge = controller.badge.value;
      if (badge != null) return badge.level;
      return controller.currentLevel;
    }
    return 1; // Default basic tier
  }

  KycTierStatus _resolveStatus(int currentTier) {
    if (widget.statusOverride != null) {
      return widget.statusOverride!;
    }
    if (widget.statusBadgeOverride != null) {
      final s = widget.statusBadgeOverride!.trim().toLowerCase();
      if (s.contains('action') || s.contains('اقدام')) {
        return KycTierStatus.actionRequired;
      }
      if (s.contains('reject') || s.contains('رد')) {
        return KycTierStatus.rejected;
      }
      if (s.contains('pend') || s.contains('review') || s.contains('بررسی')) {
        return KycTierStatus.pending;
      }
      if (s.contains('verif') || s.contains('active') || s.contains('تأیید')) {
        return KycTierStatus.verified;
      }
    }

    final controller = _findController();
    if (controller != null) {
      if (controller.isPending) return KycTierStatus.pending;
      if (controller.isRejected) return KycTierStatus.rejected;
    }

    if (currentTier <= 0) return KycTierStatus.unverified;
    return KycTierStatus.verified;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _findController();

    if (controller != null && widget.currentTier == null) {
      return Obx(() => _buildContent(context, _resolveCurrentTier()));
    }

    return _buildContent(context, _resolveCurrentTier());
  }

  Widget _buildContent(BuildContext context, int currentTier) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTierDef = _TierDefinition.get(currentTier);
    final selectedTierDef = _TierDefinition.get(_selectedTier);
    final status = _resolveStatus(currentTier);

    final cardBg = isDark ? AppColors.darkCard : AppColors.lightSurface;
    final primaryTextColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    // Daily limit calculations
    final maxLimit = widget.totalDailyLimit ?? currentTierDef.dailyLimit;
    final consumed =
        widget.consumedDailyLimit ??
        (currentTier <= 0
            ? 0.0
            : (currentTier == 1
                  ? 250.0
                  : (currentTier == 2 ? 1850.0 : 8200.0)));
    final remaining = (maxLimit - consumed).clamp(0.0, maxLimit);
    final progressFraction = maxLimit > 0
        ? (consumed / maxLimit).clamp(0.0, 1.0)
        : 0.0;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowFactor = _glowAnimation.value;
        final themeGlowColor = currentTierDef.glowColor.withValues(
          alpha: (isDark ? 0.38 : 0.28) * glowFactor,
        );

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: currentTierDef.primaryColor.withValues(
                alpha: 0.45 * glowFactor,
              ),
              width: 1.6.w,
            ),
            boxShadow: widget.showElevation
                ? [
                    BoxShadow(
                      color: themeGlowColor,
                      blurRadius: 18.r * glowFactor,
                      spreadRadius: 1.5.r,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: isDark
                          ? AppColors.black.withValues(alpha: 0.4)
                          : AppColors.lightShadow,
                      blurRadius: 12.r,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Current Tier Badge with prominent status badge
            _buildCurrentTierHeader(
              context,
              currentTier,
              currentTierDef,
              status,
              isDark,
              primaryTextColor,
            ),

            // In-Progress Upload Progress Indicator (when active)
            if (widget.uploadProgress != null) ...[
              SizedBox(height: 14.h),
              _buildUploadProgressIndicator(
                context,
                widget.uploadProgress!,
                widget.uploadProgressLabel,
                widget.onCancelUpload,
                isDark,
                currentTierDef.primaryColor,
              ),
            ],

            SizedBox(height: 16.h),

            // Daily Transaction Limit Indicator with animated progress
            _buildDailyLimitIndicator(
              context,
              currentTier,
              currentTierDef,
              consumed,
              maxLimit,
              remaining,
              progressFraction,
              isDark,
            ),

            SizedBox(height: 20.h),

            // Comparison Tabs Header
            _buildComparisonTabs(context, currentTier, isDark),

            SizedBox(height: 14.h),

            // Tier Details & Comparison Card with Required Documents List
            _buildTierDetailCard(
              context,
              currentTier,
              selectedTierDef,
              isDark,
            ),

            SizedBox(height: 16.h),

            // CTA Action Button
            _buildActionButton(
              context,
              currentTier,
              selectedTierDef,
              status,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  /// Top Section: User Current Tier Badge & Status (Verified, Pending, Rejected, Action Required)
  Widget _buildCurrentTierHeader(
    BuildContext context,
    int currentTier,
    _TierDefinition currentTierDef,
    KycTierStatus status,
    bool isDark,
    Color primaryTextColor,
  ) {
    late final String statusLabel;
    late final Color statusColor;
    late final IconData statusIcon;

    switch (status) {
      case KycTierStatus.pending:
        statusLabel = widget.statusBadgeOverride ??
            l10nPick(
              context,
              en: 'Pending Review',
              fa: 'در حال بررسی',
              ar: 'قيد المراجعة',
              zh: '审核中',
            );
        statusColor = AppColors.warning;
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case KycTierStatus.rejected:
        statusLabel = widget.statusBadgeOverride ??
            l10nPick(
              context,
              en: 'Rejected',
              fa: 'رد شده',
              ar: 'مرفوض',
              zh: '已拒绝',
            );
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_rounded;
        break;
      case KycTierStatus.actionRequired:
        statusLabel = widget.statusBadgeOverride ??
            l10nPick(
              context,
              en: 'Action Required',
              fa: 'اقدام لازم است',
              ar: 'إجراء مطلوب',
              zh: '需要操作',
            );
        statusColor = const Color(0xFFFF9800);
        statusIcon = Icons.warning_amber_rounded;
        break;
      case KycTierStatus.verified:
        statusLabel = widget.statusBadgeOverride ??
            l10nPick(
              context,
              en: 'Verified',
              fa: 'احراز شده',
              ar: 'موثق',
              zh: '已验证',
            );
        statusColor = AppColors.success;
        statusIcon = Icons.verified_rounded;
        break;
      case KycTierStatus.unverified:
        statusLabel = widget.statusBadgeOverride ??
            l10nPick(
              context,
              en: 'Unverified',
              fa: 'احراز نشده',
              ar: 'غير موثق',
              zh: '未验证',
            );
        statusColor = isDark
            ? AppColors.darkTextTertiary
            : AppColors.lightTextSecondary;
        statusIcon = Icons.lock_outline_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            currentTierDef.primaryColor.withValues(alpha: isDark ? 0.20 : 0.12),
            currentTierDef.accentColor.withValues(alpha: isDark ? 0.10 : 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: currentTierDef.primaryColor.withValues(alpha: isDark ? 0.40 : 0.28),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          // Glowing Tier Icon Badge
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: currentTierDef.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: currentTierDef.glowColor.withValues(alpha: 0.45),
                  blurRadius: 10.r,
                  spreadRadius: 1.r,
                ),
              ],
            ),
            child: Icon(
              currentTierDef.icon,
              color: AppColors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),

          // Tier Name and Verification Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        currentTierDef.title(context),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: primaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Status Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.45),
                          width: 1.w,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            color: statusColor,
                            size: 11.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  currentTierDef.requirement(context),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Upload Progress Indicator Widget (Shown during document uploads)
  Widget _buildUploadProgressIndicator(
    BuildContext context,
    double progress,
    String? label,
    VoidCallback? onCancel,
    bool isDark,
    Color primaryColor,
  ) {
    final percent = (progress.clamp(0.0, 1.0) * 100).toInt();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.35),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.08),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_upload_rounded,
                      size: 16.sp,
                      color: primaryColor,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        label ??
                            l10nPick(
                              context,
                              en: 'Uploading Documents...',
                              fa: 'در حال بارگذاری مدارک...',
                              ar: 'جارٍ رفع المستندات...',
                              zh: '正在上传文件...',
                            ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                  if (onCancel != null) ...[
                    SizedBox(width: 8.w),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onCancel,
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: 32.w,
                          minHeight: 32.h,
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 14.sp,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6.h,
              backgroundColor: isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  /// Daily Transaction Limit Indicator with Progress Bar
  Widget _buildDailyLimitIndicator(
    BuildContext context,
    int currentTier,
    _TierDefinition currentTierDef,
    double consumed,
    double maxLimit,
    double remaining,
    double progressFraction,
    bool isDark,
  ) {
    final percentInt = (progressFraction * 100).toInt();

    final barColor = progressFraction > 0.90
        ? AppColors.error
        : (progressFraction > 0.75
              ? AppColors.warning
              : currentTierDef.primaryColor);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.speed_rounded,
                      size: 16.sp,
                      color: currentTierDef.primaryColor,
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        l10nPick(
                          context,
                          en: 'Daily Transaction Limit',
                          fa: 'سقف تراکنش روزانه',
                          ar: 'الحد اليومي للمعاملات',
                          zh: '每日交易限额',
                        ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  currentTierDef.isUnlimited
                      ? l10nPick(
                          context,
                          en: 'Unlimited',
                          fa: 'نامحدود',
                          ar: 'غير محدود',
                          zh: '无限制',
                        )
                      : '\$${_formatNumber(consumed)} / \$${_formatNumber(maxLimit)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: currentTierDef.primaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 9.h,
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.lightWarmGray.withValues(alpha: 0.35),
                ),
                FractionallySizedBox(
                  widthFactor: currentTierDef.isUnlimited
                      ? 0.08
                      : progressFraction,
                  child: Container(
                    height: 9.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [barColor.withValues(alpha: 0.8), barColor],
                      ),
                      borderRadius: BorderRadius.circular(6.r),
                      boxShadow: [
                        BoxShadow(
                          color: barColor.withValues(alpha: 0.4),
                          blurRadius: 4.r,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // Footnote Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  currentTierDef.isUnlimited
                      ? l10nPick(
                          context,
                          en: 'No daily volume limit applies',
                          fa: 'بدون محدودیت سقف تراکنش روزانه',
                          ar: 'لا ينطبق حد أقصى للمعاملات اليومية',
                          zh: '无每日交易额度限制',
                        )
                      : l10nPick(
                          context,
                          en: '\$${_formatNumber(remaining)} remaining today ($percentInt% used)',
                          fa: '\$${_formatNumber(remaining)} باقی‌مانده امروز ($percentInt٪ مصرف شده)',
                          ar: '\$${_formatNumber(remaining)} المتبقي اليوم ($percentInt% مستخدم)',
                          zh: '今日剩余 \$${_formatNumber(remaining)} (已用 $percentInt%)',
                        ),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.update_rounded,
                    size: 11.sp,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextHint,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    '00:00 UTC',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Comparison Tabs Header
  Widget _buildComparisonTabs(
    BuildContext context,
    int currentTier,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                l10nPick(
                  context,
                  en: 'Tier Comparison & Roadmap',
                  fa: 'مقایسه سطوح و مسیر ارتقا',
                  ar: 'مقارنة المستويات وخريطة الترقية',
                  zh: '等级对比与升级路线',
                ),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              l10nPick(
                context,
                en: '3 Levels',
                fa: '۳ سطح',
                ar: '3 مستويات',
                zh: '3 个等级',
              ),
              style: TextStyle(
                fontSize: 11.sp,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            for (int t = 1; t <= 3; t++) ...[
              Expanded(
                child: _buildTierTabItem(
                  context: context,
                  tierLevel: t,
                  currentTier: currentTier,
                  isSelected: _selectedTier == t,
                  isDark: isDark,
                ),
              ),
              if (t < 3) SizedBox(width: 8.w),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTierTabItem({
    required BuildContext context,
    required int tierLevel,
    required int currentTier,
    required bool isSelected,
    required bool isDark,
  }) {
    final def = _TierDefinition.get(tierLevel);
    final isCurrent = tierLevel == currentTier;
    final isNext = tierLevel == currentTier + 1;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _selectedTier = tierLevel);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        constraints: const BoxConstraints(minHeight: 48.0),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: isSelected
              ? def.primaryColor.withValues(alpha: isDark ? 0.24 : 0.16)
              : (isDark ? AppColors.darkSurface : AppColors.lightBackground),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? def.primaryColor
                : (isCurrent
                      ? AppColors.success.withValues(alpha: 0.5)
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
            width: isSelected ? 1.8.w : 1.w,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: def.glowColor.withValues(alpha: 0.28),
                    blurRadius: 8.r,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  def.icon,
                  size: 14.sp,
                  color: isSelected
                      ? def.primaryColor
                      : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                ),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    def.tabLabel(context),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isSelected
                          ? (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary)
                          : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            if (isCurrent)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  l10nPick(
                    context,
                    en: 'Current',
                    fa: 'فعلی',
                    ar: 'الحالي',
                    zh: '当前',
                  ),
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              )
            else if (isNext)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  l10nPick(
                    context,
                    en: 'Next',
                    fa: 'بعدی',
                    ar: 'التالي',
                    zh: '下阶段',
                  ),
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.info,
                  ),
                ),
              )
            else
              Text(
                def.limitSummary,
                style: TextStyle(
                  fontSize: 8.5.sp,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextHint,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Tier Detail & Comparison Card with Required Documents List & Specs
  Widget _buildTierDetailCard(
    BuildContext context,
    int currentTier,
    _TierDefinition def,
    bool isDark,
  ) {
    final isCurrent = def.level == currentTier;
    final isCompleted = def.level < currentTier;
    final isNext = def.level == currentTier + 1;

    final statusText = isCurrent
        ? l10nPick(
            context,
            en: 'Your Current Active Tier',
            fa: 'سطح فعال کنونی شما',
            ar: 'مستواك النشط حالياً',
            zh: '您当前生效的等级',
          )
        : isCompleted
        ? l10nPick(
            context,
            en: 'Unlocked & Verified',
            fa: 'تکمیل و احراز شده',
            ar: 'تم الفتح والتوثيق',
            zh: '已解锁并验证',
          )
        : isNext
        ? l10nPick(
            context,
            en: 'Recommended Next Upgrade',
            fa: 'پیشنهاد ارتقای بعدی شما',
            ar: 'الترقية التالية الموصى بها',
            zh: '推荐的下一升级阶段',
          )
        : l10nPick(
            context,
            en: 'Locked — Complete Tier ${def.level - 1} First',
            fa: 'قفل شده — ابتدا سطح ${def.level - 1} را تکمیل کنید',
            ar: 'مقفل — أكمل المستوى ${def.level - 1} أولاً',
            zh: '锁定 — 请先完成第 ${def.level - 1} 级',
          );

    final statusBgColor = isCurrent
        ? AppColors.success.withValues(alpha: 0.12)
        : isCompleted
        ? AppColors.info.withValues(alpha: 0.12)
        : isNext
        ? def.primaryColor.withValues(alpha: isDark ? 0.20 : 0.14)
        : (isDark
              ? AppColors.darkBorder.withValues(alpha: 0.5)
              : AppColors.lightWarmGray.withValues(alpha: 0.35));

    final statusTextColor = isCurrent
        ? AppColors.success
        : isCompleted
        ? AppColors.info
        : isNext
        ? def.primaryColor
        : (isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: def.primaryColor.withValues(alpha: 0.35),
          width: 1.2.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner strip
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
            ),
            child: Row(
              children: [
                Icon(
                  isCurrent
                      ? Icons.check_circle_rounded
                      : isCompleted
                      ? Icons.done_all_rounded
                      : isNext
                      ? Icons.star_rounded
                      : Icons.lock_outline_rounded,
                  size: 15.sp,
                  color: statusTextColor,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: statusTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2 Micro-metric specs: Daily Limit & Virtual Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSpecCard(
                        context,
                        title: l10nPick(
                          context,
                          en: 'Daily Limit',
                          fa: 'سقف روزانه',
                          ar: 'الحد اليومي',
                          zh: '每日限额',
                        ),
                        value: def.dailyLimitLabel,
                        icon: Icons.payments_outlined,
                        color: def.primaryColor,
                        isDark: isDark,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildSpecCard(
                        context,
                        title: l10nPick(
                          context,
                          en: 'Virtual Cards',
                          fa: 'کارت‌های مجازی',
                          ar: 'البطاقات الافتراضية',
                          zh: '虚拟卡数量',
                        ),
                        value: def.virtualCardsLabel(context),
                        icon: Icons.credit_card_outlined,
                        color: def.primaryColor,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Verification requirements card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        size: 16.sp,
                        color: def.primaryColor,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10nPick(
                                context,
                                en: 'Verification Required',
                                fa: 'مدارک و شرایط احراز',
                                ar: 'التوثيق المطلوب',
                                zh: '所需认证条件',
                              ),
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              def.requirement(context),
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10.h),

                // Required Documents List Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkCard
                        : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 16.sp,
                            color: def.primaryColor,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            l10nPick(
                              context,
                              en: 'Required Documents',
                              fa: 'مدارک و شرایط موردنیاز',
                              ar: 'المستندات المطلوبة',
                              zh: '所需资料清单',
                            ),
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      // Bullet document list
                      ...def.requiredDocuments(context).map(
                        (doc) => Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 2.h),
                                width: 14.w,
                                height: 14.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: def.primaryColor.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                                child: Icon(
                                  Icons.description_outlined,
                                  size: 9.sp,
                                  color: def.primaryColor,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  doc,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // Unlocked Benefits header
                Text(
                  l10nPick(
                    context,
                    en: 'Unlocked Benefits',
                    fa: 'مزایای اختصاصی این سطح',
                    ar: 'المزايا المتاحة في هذا المستوى',
                    zh: '本等级解锁权益',
                  ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 8.h),

                // Benefits checklist
                ...def.benefits(context).map(
                  (benefit) => Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 2.h),
                          width: 16.w,
                          height: 16.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: def.primaryColor.withValues(alpha: 0.15),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 11.sp,
                            color: def.primaryColor,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            benefit,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// CTA Action Button opening submission wizard
  Widget _buildActionButton(
    BuildContext context,
    int currentTier,
    _TierDefinition def,
    KycTierStatus status,
    bool isDark,
  ) {
    final isAlreadyOwned = def.level <= currentTier;

    if (isAlreadyOwned) {
      return Container(
        width: double.infinity,
        height: 48.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.success.withValues(alpha: 0.16)
              : AppColors.successContainer,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.35),
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_rounded, color: AppColors.success, size: 18.sp),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                l10nPick(
                  context,
                  en: 'Tier ${def.level} Active',
                  fa: 'سطح ${def.level} فعال است',
                  ar: 'المستوى ${def.level} نشط',
                  zh: '第 ${def.level} 级已激活',
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    if (status == KycTierStatus.pending) {
      return Container(
        width: double.infinity,
        height: 48.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.warning.withValues(alpha: 0.16)
              : AppColors.warningContainer,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.4),
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_top_rounded,
              color: AppColors.warning,
              size: 18.sp,
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                l10nPick(
                  context,
                  en: 'Submission Under Review',
                  fa: 'درخواست در حال بررسی است',
                  ar: 'الطلب قيد المراجعة',
                  zh: '申请审核中',
                ),
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warning,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    final buttonLabel = l10nPick(
      context,
      en: 'Upgrade to Tier ${def.level} (${def.shortName(context)})',
      fa: 'ارتقا به سطح ${def.level} (${def.shortName(context)})',
      ar: 'الترقية إلى المستوى ${def.level} (${def.shortName(context)})',
      zh: '升级至第 ${def.level} 级 (${def.shortName(context)})',
    );

    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: () => _handleUpgradeTap(def.level),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark
              ? AppColors.mainSoftBlue
              : AppColors.lightPrimary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
          shadowColor: def.primaryColor.withValues(alpha: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_upward_rounded,
              size: 18.sp,
              color: AppColors.white,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                buttonLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              Icons.arrow_forward_rounded,
              size: 16.sp,
              color: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }

  void _handleUpgradeTap(int targetTier) {
    if (widget.onUpgradeTap != null) {
      widget.onUpgradeTap!(targetTier);
      return;
    }

    Get.toNamed(
      BaseRoute.kycSubmitWizard,
      arguments: {'target_level': targetTier},
    );
  }

  static String _formatNumber(double amount) {
    if (amount >= 1000) {
      final formatted = amount.toInt().toString();
      final buffer = StringBuffer();
      int count = 0;
      for (int i = formatted.length - 1; i >= 0; i--) {
        buffer.write(formatted[i]);
        count++;
        if (count % 3 == 0 && i > 0) {
          buffer.write(',');
        }
      }
      return buffer.toString().split('').reversed.join();
    }
    return amount.toInt().toString();
  }
}

/// Internal configuration for KYC Tiers (Bronze, Silver, Gold)
class _TierDefinition {
  final int level;
  final String limitSummary;
  final double dailyLimit;
  final String dailyLimitLabel;
  final int virtualCards;
  final bool isUnlimited;
  final Color primaryColor;
  final Color accentColor;
  final Color glowColor;
  final List<Color> gradientColors;
  final IconData icon;

  final String Function(BuildContext) title;
  final String Function(BuildContext) shortName;
  final String Function(BuildContext) tabLabel;
  final String Function(BuildContext) requirement;
  final String Function(BuildContext) virtualCardsLabel;
  final List<String> Function(BuildContext) requiredDocuments;
  final List<String> Function(BuildContext) benefits;

  const _TierDefinition({
    required this.level,
    required this.limitSummary,
    required this.dailyLimit,
    required this.dailyLimitLabel,
    required this.virtualCards,
    required this.isUnlimited,
    required this.primaryColor,
    required this.accentColor,
    required this.glowColor,
    required this.gradientColors,
    required this.icon,
    required this.title,
    required this.shortName,
    required this.tabLabel,
    required this.requirement,
    required this.virtualCardsLabel,
    required this.requiredDocuments,
    required this.benefits,
  });

  static _TierDefinition get(int level) {
    switch (level) {
      case 2:
        return _tier2;
      case 3:
        return _tier3;
      case 1:
      default:
        return _tier1;
    }
  }

  // Tier 1 (Basic / برنزی)
  static final _tier1 = _TierDefinition(
    level: 1,
    limitSummary: '\$1,000/day',
    dailyLimit: 1000.0,
    dailyLimitLabel: '\$1,000 / day',
    virtualCards: 1,
    isUnlimited: false,
    primaryColor: const Color(0xFFCD7F32), // Bronze
    accentColor: const Color(0xFFD99B66),
    glowColor: const Color(0xFFCD7F32),
    gradientColors: const [Color(0xFF8C532B), Color(0xFFD99B66)],
    icon: Icons.shield_outlined,
    title: (context) => l10nPick(
      context,
      en: 'Tier 1 — Basic',
      fa: 'سطح ۱ — برنزی',
      ar: 'المستوى 1 — البرونزي',
      tr: 'Seviye 1 — Temel (Bronz)',
      ru: 'Уровень 1 — Базовый (Бронзовый)',
      zh: '第 1 级 — 青铜级',
    ),
    shortName: (context) => l10nPick(
      context,
      en: 'Basic',
      fa: 'برنزی',
      ar: 'برونزي',
      tr: 'Bronz',
      ru: 'Бронзовый',
      zh: '青铜',
    ),
    tabLabel: (context) => l10nPick(
      context,
      en: 'Tier 1 (Basic)',
      fa: 'سطح ۱ (برنزی)',
      ar: 'مستوى 1 (برونزي)',
      tr: 'Seviye 1 (Bronz)',
      ru: 'Уровень 1 (Бронзовый)',
      zh: '第1级 (青铜)',
    ),
    requirement: (context) => l10nPick(
      context,
      en: 'Email & Phone verified',
      fa: 'تأیید ایمیل و شماره همراه',
      ar: 'البريد الإلكتروني ورقم الهاتف موثقان',
      tr: 'E-posta ve Telefon doğrulandı',
      ru: 'Эл. почта и телефон подтверждены',
      zh: '邮箱和手机号已验证',
    ),
    virtualCardsLabel: (context) => l10nPick(
      context,
      en: '1 Virtual Card',
      fa: '۱ کارت مجازی',
      ar: 'بطاقة افتراضية واحدة',
      tr: '1 Sanal Kart',
      ru: '1 виртуальная карта',
      zh: '1 张虚拟卡',
    ),
    requiredDocuments: (context) => [
      l10nPick(
        context,
        en: 'Email verification code',
        fa: 'کد تأیید ایمیل کاربری',
        ar: 'رمز التحقق من البريد الإلكتروني',
        zh: '邮箱验证码',
      ),
      l10nPick(
        context,
        en: 'Mobile phone number & SMS OTP',
        fa: 'شماره تلفن همراه و کد پیامکی',
        ar: 'رقم الهاتف المحمول ورمز الرسالة',
        zh: '手机号码及短信验证码',
      ),
      l10nPick(
        context,
        en: 'Basic personal details (Full name, Date of birth)',
        fa: 'مشخصات هویتی اولیه (نام و نام‌خانوادگی، تاریخ تولد)',
        ar: 'البيانات الشخصية الأساسية (الاسم الكامل، تاريخ الميلاد)',
        zh: '基础身份信息 (姓名、出生日期)',
      ),
    ],
    benefits: (context) => [
      l10nPick(
        context,
        en: '\$1,000 daily transaction limit',
        fa: 'سقف تراکنش ۱,۰۰۰ دلار در روز',
        ar: 'حد معاملات 1,000 دولار يومياً',
        zh: '每日交易限额 \$1,000',
      ),
      l10nPick(
        context,
        en: '1 Active Virtual Card for online payments',
        fa: '۱ کارت مجازی فعال برای خریدهای آنلاین',
        ar: 'بطاقة افتراضية نشطة واحدة للمدفوعات عبر الإنترنت',
        zh: '1 张用于在线支付的活跃虚拟卡',
      ),
      l10nPick(
        context,
        en: 'Basic wallet transfers and payment requests',
        fa: 'انتقال و درخواست وجه در کیف‌پول پایه',
        ar: 'تحويلات المحفظة الأساسية وطلبات الدفع',
        zh: '基础钱包转账与收款请求',
      ),
      l10nPick(
        context,
        en: 'Standard SMS and email security alerts',
        fa: 'هشدارهای امنیتی استاندارد پیامکی و ایمیل',
        ar: 'تنبيهات أمان قياسية عبر الرسائل والبريد',
        zh: '标准短信与邮件安全通知',
      ),
    ],
  );

  // Tier 2 (Standard / نقره‌ای)
  static final _tier2 = _TierDefinition(
    level: 2,
    limitSummary: '\$10,000/day',
    dailyLimit: 10000.0,
    dailyLimitLabel: '\$10,000 / day',
    virtualCards: 3,
    isUnlimited: false,
    primaryColor: const Color(0xFF9EABB8), // Silver
    accentColor: const Color(0xFFCFD8DC),
    glowColor: const Color(0xFFB0BEC5),
    gradientColors: const [Color(0xFF607D8B), Color(0xFFB0BEC5)],
    icon: Icons.military_tech_rounded,
    title: (context) => l10nPick(
      context,
      en: 'Tier 2 — Standard',
      fa: 'سطح ۲ — نقره‌ای',
      ar: 'المستوى 2 — الفضي',
      tr: 'Seviye 2 — Standart (Gümüş)',
      ru: 'Уровень 2 — Стандартный (Серебряный)',
      zh: '第 2 级 — 白银级',
    ),
    shortName: (context) => l10nPick(
      context,
      en: 'Standard',
      fa: 'نقره‌ای',
      ar: 'فضي',
      tr: 'Gümüş',
      ru: 'Серебряный',
      zh: '白银',
    ),
    tabLabel: (context) => l10nPick(
      context,
      en: 'Tier 2 (Standard)',
      fa: 'سطح ۲ (نقره‌ای)',
      ar: 'مستوى 2 (فضي)',
      tr: 'Seviye 2 (Gümüş)',
      ru: 'Уровень 2 (Серебряный)',
      zh: '第2级 (白银)',
    ),
    requirement: (context) => l10nPick(
      context,
      en: 'National ID / Passport verified',
      fa: 'تأیید کارت ملی یا پاسپورت',
      ar: 'الهوية الوطنية أو جواز السفر موثق',
      tr: 'Kimlik Kartı veya Pasaport doğrulandı',
      ru: 'Удостоверение личности или паспорт подтверждены',
      zh: '身份证或护照已验证',
    ),
    virtualCardsLabel: (context) => l10nPick(
      context,
      en: '3 Virtual Cards',
      fa: '۳ کارت مجازی',
      ar: '3 بطاقات افتراضية',
      tr: '3 Sanal Kart',
      ru: '3 виртуальные карты',
      zh: '3 张虚拟卡',
    ),
    requiredDocuments: (context) => [
      l10nPick(
        context,
        en: 'Government National ID or Passport (Front & Back)',
        fa: 'کارت ملی هوشمند یا گذرنامه معتبر (رو و پشت)',
        ar: 'الهوية الوطنية أو جواز السفر الصادر عن الحكومة (الوجهان)',
        zh: '政府颁发的身份证或护照 (正反面)',
      ),
      l10nPick(
        context,
        en: 'Live Liveness Selfie Capture',
        fa: 'تصویر سلفی احراز هویت زنده با دوربین',
        ar: 'التقاط صورة سيلفي حية للتحقق من الهوية',
        zh: '活体自拍动态捕获',
      ),
      l10nPick(
        context,
        en: 'National Registration / Tax Identification Number',
        fa: 'کد ملی ده‌رقمی و اطلاعات ثبت احوال',
        ar: 'الرقم القومي / الرقم الضريبي المعتمد',
        zh: '国家税务识别号或公民身份编号',
      ),
    ],
    benefits: (context) => [
      l10nPick(
        context,
        en: '\$10,000 daily transaction limit',
        fa: 'سقف تراکنش ۱۰,۰۰۰ دلار در روز',
        ar: 'حد معاملات 10,000 دولار يومياً',
        zh: '每日交易限额 \$10,000',
      ),
      l10nPick(
        context,
        en: '3 Virtual Cards with custom spending limits',
        fa: '۳ کارت مجازی هم‌زمان با سقف هزینه جداگانه',
        ar: '3 بطاقات افتراضية مع حدود إنفاق مخصصة',
        zh: '3 张支持独立消费限额的虚拟卡',
      ),
      l10nPick(
        context,
        en: 'Travel booking & hotel reservations unlocked',
        fa: 'دسترسی مجاز به رزرو خدمات سفر، پرواز و هتل',
        ar: 'حجز السفر والفنادق متاح',
        zh: '解锁旅游与酒店预订特权',
      ),
      l10nPick(
        context,
        en: 'Multi-currency exchange & asset conversions',
        fa: 'دسترسی به صرافی و تبدیل چندارزی',
        ar: 'تبادل العملات المتعددة وتحويل الأصول',
        zh: '多币种兑换与资产转换',
      ),
      l10nPick(
        context,
        en: 'Priority automated verification queue',
        fa: 'صف پردازش اولویت‌دار احراز هویت',
        ar: 'أولوية في معالجة التوثيق الآلي',
        zh: '优先自动化审核通道',
      ),
    ],
  );

  // Tier 3 (VIP / طلایی)
  static final _tier3 = _TierDefinition(
    level: 3,
    limitSummary: '\$100,000/day',
    dailyLimit: 100000.0,
    dailyLimitLabel: '\$100,000 / Unlimited',
    virtualCards: -1,
    isUnlimited: true,
    primaryColor: const Color(0xFFD4AF37), // Gold
    accentColor: const Color(0xFFFFE082),
    glowColor: const Color(0xFFFFD700),
    gradientColors: const [Color(0xFFB8860B), Color(0xFFFFD700)],
    icon: Icons.workspace_premium_rounded,
    title: (context) => l10nPick(
      context,
      en: 'Tier 3 — VIP',
      fa: 'سطح ۳ — طلایی (VIP)',
      ar: 'المستوى 3 — الذهبي (VIP)',
      tr: 'Seviye 3 — Altın (VIP)',
      ru: 'Уровень 3 — Золотой (VIP)',
      zh: '第 3 级 — 黄金级 (VIP)',
    ),
    shortName: (context) => l10nPick(
      context,
      en: 'VIP',
      fa: 'طلایی',
      ar: 'VIP ذهبي',
      tr: 'Altın VIP',
      ru: 'Золотой VIP',
      zh: 'VIP 黄金',
    ),
    tabLabel: (context) => l10nPick(
      context,
      en: 'Tier 3 (VIP)',
      fa: 'سطح ۳ (طلایی)',
      ar: 'مستوى 3 (ذهبي)',
      tr: 'Seviye 3 (VIP)',
      ru: 'Уровень 3 (VIP)',
      zh: '第3级 (VIP)',
    ),
    requirement: (context) => l10nPick(
      context,
      en: 'Proof of Address & Video Liveness verified',
      fa: 'تأیید نشانی سکونت و احراز هویت ویدیویی زنده',
      ar: 'إثبات العنوان والتحقق المرئي المباشر',
      tr: 'İkamet Adresi ve Canlı Video Doğrulaması',
      ru: 'Подтверждение адреса и видеоверификация',
      zh: '地址证明与动态活体视频验证',
    ),
    virtualCardsLabel: (context) => l10nPick(
      context,
      en: 'Unlimited Cards',
      fa: 'کارت‌های نامحدود',
      ar: 'بطاقات غير محدودة',
      tr: 'Sınırsız Sanal Kart',
      ru: 'Неограниченное количество виртуальных карт',
      zh: '无限量虚拟卡',
    ),
    requiredDocuments: (context) => [
      l10nPick(
        context,
        en: 'Proof of Residential Address (Utility Bill / Lease < 3 months)',
        fa: 'تأییدیه نشانی سکونت (قبض خدماتی یا سند/اجاره‌نامه زیر ۳ ماه)',
        ar: 'إثبات محل الإقامة (فاتورة خدمات أو عقد إيجار أقل من 3 أشهر)',
        zh: '居住地址证明 (3个月内水电账单或租约)',
      ),
      l10nPick(
        context,
        en: 'Video Liveness & Voice Speech Verification Prompt',
        fa: 'احراز هویت ویدیویی زنده با قرائت متن تأیید هوشمند',
        ar: 'فيديو مباشر للتحقق من الهوية مع مطابقة الصوت الذكية',
        zh: '动态视频活体与语音阅读核验',
      ),
      l10nPick(
        context,
        en: 'Bank Statement / Official Proof of Source of Funds',
        fa: 'پرینت حساب بانکی رسمی یا گواهی تمکن مالی',
        ar: 'كشف حساب بنكي رسمي أو إثبات مصدر الأموال',
        zh: '官方银行流水或资金来源合法证明',
      ),
    ],
    benefits: (context) => [
      l10nPick(
        context,
        en: 'Unlimited / \$100,000 daily transaction limit',
        fa: 'سقف تراکنش نامحدود / ۱۰۰,۰۰۰ دلار در روز',
        ar: 'حد يومي غير محدود / 100,000 دولار',
        zh: '无限制 / 每日 \$100,000 限额',
      ),
      l10nPick(
        context,
        en: 'Unlimited Virtual Cards with custom BIN options',
        fa: 'کارت‌های مجازی نامحدود با شماره‌های اختصاصی',
        ar: 'بطاقات افتراضية غير محدودة مع خيارات مخصصة',
        zh: '无限量虚拟卡及专属 BIN 号段支持',
      ),
      l10nPick(
        context,
        en: 'Full access to Loan & Commercial Guarantee facilities',
        fa: 'دسترسی کامل به تسهیلات وام و ضمانت‌نامه تجاری',
        ar: 'وصول كامل لخدمات القروض والضمانات التجارية',
        zh: '尊享贷款与商业担保完整服务',
      ),
      l10nPick(
        context,
        en: 'Dedicated 24/7 VIP Concierge & Account Manager',
        fa: 'مدیر اختصاصی پشتیبانی و خدمات ۲۴/۷ مشتریان VIP',
        ar: 'مدير حساب وكونسيرج VIP مخصص على مدار الساعة',
        zh: '24/7 专属 VIP 私人客户经理',
      ),
      l10nPick(
        context,
        en: 'Zero exchange markups and expedited settlements',
        fa: 'کارمزد صفر تبدیل ارز و تسویه فوری بین‌المللی',
        ar: 'بدون هوامش تحويل وتسويات دولية فورية',
        zh: '零外汇点差及极速跨国结算',
      ),
    ],
  );
}
