import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/constants/assets_path/svg/svg_assets.dart';

/// Ultra-premium realistic virtual card visualization for eCardo.
///
/// Features:
/// - Realistic multi-stop NUVO mesh gradient (deepBlack / mainSoftBlue / mutedBlue).
/// - Gloss highlights and metallic sheen line.
/// - Contactless wave / NFC payment insignia.
/// - Golden micro-circuit EMV chip.
/// - World map watermark & subtle security shield.
/// - Masked PAN with accessible 44x44 eye toggle and haptic feedback.
/// - Dynamic status badge (Active, Frozen, Inactive).
/// - Integrated frosted-glass freeze overlay when frozen.
class CommonVirtualCardView extends StatelessWidget {
  final String title;
  final String value;
  final String firstLabel;
  final String firstValue;
  final String secondLabel;
  final String secondValue;
  final String status;
  final bool canReveal;
  final bool isRevealed;
  final VoidCallback? onReveal;
  final String? backgroundImage;
  final String? brandImage;
  final String? network;
  final String? primaryColor;
  final String? secondaryColor;
  final bool? isFrozen;

  const CommonVirtualCardView({
    super.key,
    required this.title,
    required this.value,
    required this.firstLabel,
    required this.firstValue,
    required this.secondLabel,
    required this.secondValue,
    required this.status,
    this.canReveal = false,
    this.isRevealed = false,
    this.onReveal,
    this.backgroundImage,
    this.brandImage,
    this.network,
    this.primaryColor,
    this.secondaryColor,
    this.isFrozen,
  });

  bool get _isCardFrozen {
    if (isFrozen == true) return true;
    final normalized = status.toLowerCase();
    return normalized == 'frozen' || normalized == 'freeze' || normalized == 'blocked';
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppSpacing.radiusXl);

    return Container(
      width: double.infinity,
      height: 210.h,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: _isCardFrozen
                ? AppColors.mainSoftBlue.withValues(alpha: 0.35)
                : AppColors.deepBlack.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.mutedBlue.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. Realistic Mesh Gradient / Custom Background
          Positioned.fill(child: _buildBackground()),

          // 2. Gloss / Sheen Highlight diagonal overlay
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 0.35, 0.65, 1.0],
                    colors: [
                      Colors.white.withValues(alpha: 0.16),
                      Colors.white.withValues(alpha: 0.04),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.22),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. World map watermark
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.16,
                child: Image.asset(
                  PngAssets.cardMap,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // 4. Translucent shield outline overlay
          PositionedDirectional(
            top: 0,
            start: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.12,
                child: SvgPicture.asset(
                  SvgAssets.cardShape,
                  fit: BoxFit.fill,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),

          // 5. Main Card Content (Title, PAN, Expiry/CVC, Status)
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.w, 18.h, 20.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Brand Logo + Contactless NFC + EMV Chip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildBrand(),
                    const SizedBox(width: AppSpacing.sm),
                    // Contactless wave indicator
                    Icon(
                      Icons.contactless_rounded,
                      size: 20.sp,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                    const Spacer(),
                    // Gold EMV Chip
                    Image.asset(
                      PngAssets.cardChip,
                      width: 36.w,
                      height: 26.h,
                      errorBuilder: (_, _, _) => Container(
                        width: 34.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5B94E),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  ],
                ),

                // Middle: Card Title & Masked PAN with Reveal Toggle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isNotEmpty ? title : 'Virtual Card',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: Colors.white.withValues(alpha: 0.88),
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w700,
                              fontSize: 19.sp,
                              letterSpacing: 2.2,
                              color: AppColors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  offset: const Offset(0, 1.5),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (canReveal)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                onReveal?.call();
                              },
                              child: Container(
                                width: 44.w,
                                height: 44.h,
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  isRevealed
                                      ? SvgAssets.hideEyeIcon
                                      : SvgAssets.showEyeIcon,
                                  width: 20.w,
                                  height: 20.h,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // Bottom Row: First Value (Expiry/Balance), Second Value (CVC/Currency), Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _ValueBlock(
                        label: firstLabel,
                        value: firstValue,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      flex: 2,
                      child: _ValueBlock(
                        label: secondLabel,
                        value: secondValue,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _StatusBadge(status: status, isFrozen: _isCardFrozen),
                  ],
                ),
              ],
            ),
          ),

          // 6. Frosted Glass Freeze Overlay when card is frozen
          if (_isCardFrozen)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: borderRadius,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0x381E2E42),
                      border: Border.all(
                        color: AppColors.mainSoftBlue.withValues(alpha: 0.8),
                        width: 1.8,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.deepBlack.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: AppColors.mainSoftBlue,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.ac_unit_rounded,
                              size: 15,
                              color: AppColors.mainSoftBlue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'CARD FROZEN',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    final image = backgroundImage?.trim() ?? '';
    if (image.isNotEmpty) {
      if (image.toLowerCase().endsWith('.svg')) {
        return SvgPicture.network(
          image,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => _buildMeshGradient(),
        );
      }
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildMeshGradient(),
      );
    }
    return _buildMeshGradient();
  }

  Widget _buildMeshGradient() {
    final primary = _color(primaryColor, null);
    final secondary = _color(secondaryColor, null);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary ?? AppColors.deepBlack,
            secondary ?? const Color(0xFF1E2738),
            AppColors.darkGray,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }

  Widget _buildBrand() {
    final image = brandImage?.trim() ?? '';
    if (image.isNotEmpty) {
      return Image.network(
        image,
        width: 48.w,
        height: 22.h,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _visaOrNetwork(),
      );
    }
    return _visaOrNetwork();
  }

  Widget _visaOrNetwork() {
    final net = network?.trim().toLowerCase() ?? '';
    if (net.contains('visa') || net.isEmpty) {
      return Image.asset(
        PngAssets.cardVisa,
        width: 48.w,
        height: 18.h,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Text(
          'VISA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 100.w),
      child: Text(
        network!.trim(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static Color? _color(String? value, Color? fallback) {
    final normalized = value?.trim().replaceFirst('#', '');
    if (normalized == null || (normalized.length != 6 && normalized.length != 8)) {
      return fallback;
    }
    final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
    final parsed = int.tryParse(hex, radix: 16);
    return parsed == null ? fallback : Color(parsed);
  }
}

class _ValueBlock extends StatelessWidget {
  final String label;
  final String value;

  const _ValueBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.white.withValues(alpha: 0.72),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 13.5.sp,
            color: AppColors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isFrozen;

  const _StatusBadge({required this.status, required this.isFrozen});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final active = normalized == 'active' || normalized == 'completed';

    Color bg;
    Color fg;
    String displayStatus;
    IconData icon;

    if (isFrozen) {
      bg = AppColors.mainSoftBlue.withValues(alpha: 0.25);
      fg = AppColors.mainSoftBlue;
      displayStatus = 'Frozen';
      icon = Icons.ac_unit_rounded;
    } else if (active) {
      bg = AppColors.success.withValues(alpha: 0.25);
      fg = const Color(0xFF69F0AE);
      displayStatus = 'Active';
      icon = Icons.check_circle_rounded;
    } else {
      bg = AppColors.error.withValues(alpha: 0.25);
      fg = const Color(0xFFFF8A80);
      displayStatus = _humanize(status);
      icon = Icons.lock_outline_rounded;
    }

    return Container(
      constraints: BoxConstraints(minWidth: 64.w, maxWidth: 96.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: fg.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 10.sp, color: fg),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              displayStatus,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 10.5.sp,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _humanize(String value) {
    if (value.isEmpty) return 'Active';
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
