import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

/// Card freeze control (Block 4).
///
/// [CardFreezeOverlay] is retained because freezing actually calls the card
/// status endpoint — the toggle is backed by a real request.
///
/// `DynamicCvv2Card` and `CardSpendingLimitsCard` were removed in v1.0.133.
/// Both presented client-side state as an authoritative control: the CVV was
/// generated with `Random().nextInt(900)` and never sent anywhere, and the
/// limit sliders were never persisted — the save handler showed
/// "saved successfully" with no `onSaveLimits` wired at the call site. On a
/// card holding real funds, a control that looks enforced but is not is worse
/// than no control. Reintroduce them only once a backend endpoint exists.

// ============================================================================
// 2. CARD FREEZE OVERLAY & TOGGLE
// ============================================================================

/// Visual frozen card state widget / card freeze toggle.
/// When frozen: displays frosted glass blur effect, frosted blue border,
/// lock/snowflake badge, and "Card is currently frozen - all transactions blocked" banner.
/// Includes quick toggle switch to freeze / unfreeze card with haptic feedback.
class CardFreezeOverlay extends StatelessWidget {
  final Widget child;
  final bool isFrozen;
  final ValueChanged<bool>? onFreezeToggled;
  final ValueChanged<bool>? onToggleFreeze;
  final bool showToggle;
  final BorderRadius? borderRadius;

  const CardFreezeOverlay({
    super.key,
    required this.child,
    required this.isFrozen,
    this.onFreezeToggled,
    this.onToggleFreeze,
    this.showToggle = true,
    this.borderRadius,
  });

  void _handleToggle(bool value) {
    HapticFeedback.mediumImpact();
    onFreezeToggled?.call(value);
    onToggleFreeze?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(18.r);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Card Container with Frosted Glass Overlay when frozen
        Stack(
          children: [
            child,

            // Frosted Glass Blur Effect & Frozen Badge Overlay
            if (isFrozen)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: radius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        color: const Color(0x384A90E2),
                        border: Border.all(
                          color: AppColors.mainSoftBlue,
                          width: 2.2.w,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0x40ABC3EA),
                            const Color(0x28849ACD),
                            const Color(0x45ABC3EA),
                          ],
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      // The card underneath sets the size of this surface, and
                      // it is usually shorter than badge + banner plus the
                      // overlay padding. Laying the content out at its natural
                      // height keeps the badge at the top and the banner at the
                      // bottom on a normal card; the scroll view keeps both
                      // reachable on a short one, where a rigid Column would
                      // either overflow or clip the banner.
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Lock & Snowflake Frost Badge
                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.deepBlack.withValues(
                                    alpha: 0.82,
                                  ),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: AppColors.mainSoftBlue.withValues(
                                      alpha: 0.8,
                                    ),
                                    width: 1.2.w,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.mainSoftBlue.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.ac_unit_rounded,
                                      color: AppColors.mainSoftBlue,
                                      size: 15.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    Icon(
                                      Icons.lock_rounded,
                                      color: Colors.white,
                                      size: 13.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    // The glyphs keep their size and only the
                                    // words flex, so the badge can never be
                                    // wider than the card it is stamped on.
                                    Flexible(
                                      child: Text(
                                        'Card is Frozen',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 11.5.sp,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5.w,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Frozen Banner: "Card is currently frozen - all transactions blocked"
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 9.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.deepBlack.withValues(
                                  alpha: 0.88,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.mainSoftBlue.withValues(
                                    alpha: 0.65,
                                  ),
                                  width: 1.w,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.shield_rounded,
                                    color: AppColors.mainSoftBlue,
                                    size: 18.sp,
                                  ),
<<<<<<< HEAD
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'Card is currently frozen - all transactions blocked',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
=======
                                  SizedBox(width: 6.w),
                                  Icon(
                                    Icons.lock_rounded,
                                    color: Colors.white,
                                    size: 13.sp,
                                  ),
                                  SizedBox(width: 6.w),
                                  Flexible(
                                    child: Text(
                                      'Card is Frozen',
                                      maxLines: 1,
>>>>>>> origin/main
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.5.sp,
<<<<<<< HEAD
                                        fontWeight: FontWeight.w700,
                                        height: 1.25,
=======
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5.w,
>>>>>>> origin/main
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Quick Toggle Switch below card
        if (showToggle) ...[
          SizedBox(height: 14.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: isFrozen
                    ? AppColors.mainSoftBlue
                    : AppColors.lightWarmGray.withValues(alpha: 0.45),
                width: 1.2.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: isFrozen
                      ? AppColors.mainSoftBlue.withValues(alpha: 0.12)
                      : AppColors.mutedBlue.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: isFrozen
                        ? AppColors.mainSoftBlue.withValues(alpha: 0.25)
                        : AppColors.lightBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFrozen ? Icons.ac_unit_rounded : Icons.lock_open_rounded,
                    color: isFrozen ? AppColors.deepBlack : AppColors.softGray,
                    size: 19.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // This row is the action control, so it names what the
                      // tap will do. Repeating the banner's status
                      // ("Card is Frozen") here showed the same sentence twice
                      // on one card and left the user with no idea whether the
                      // switch freezes or unfreezes.
                      Text(
<<<<<<< HEAD
                        isFrozen ? 'Unfreeze Card' : 'Freeze Virtual Card',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
=======
                        // Distinct action-style toggle title: the frost
                        // badge on the card visual is THE single
                        // "Card is Frozen" banner (QC expects one match).
                        isFrozen
                            ? 'Unfreeze Virtual Card'
                            : 'Freeze Virtual Card',
>>>>>>> origin/main
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: isFrozen
                              ? AppColors.deepBlack
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isFrozen
                            ? 'Toggle off to unfreeze and resume transactions'
                            : 'Temporarily lock your card against any charges',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Switch.adaptive(
                  value: isFrozen,
                  activeTrackColor: AppColors.mutedBlue,
                  onChanged: _handleToggle,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
