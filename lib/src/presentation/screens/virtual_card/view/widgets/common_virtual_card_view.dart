import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/constants/assets_path/svg/svg_assets.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            // مورد ۴ (v1.0.118): سایه NUVO Muted Blue جایگزین بنفش
            color: AppColors.mutedBlue.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: _background()),
          // World map watermark
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.18,
                child: Image.asset(
                  PngAssets.cardMap,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // Translucent angled shield overlay on the left
          PositionedDirectional(
            top: 0,
            start: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.14,
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
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(18.w, 54.h, 18.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                    color: AppColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                          letterSpacing: 2.0,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    if (canReveal)
                      GestureDetector(
                        onTap: onReveal,
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
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _ValueBlock(
                        label: firstLabel,
                        value: firstValue,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Flexible(
                      child: _ValueBlock(
                        label: secondLabel,
                        value: secondValue,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    _StatusBadge(status: status),
                  ],
                ),
              ],
            ),
          ),
          // Top-start: Brand / VISA logo
          PositionedDirectional(
            top: 18.h,
            start: 18.w,
            child: _brand(),
          ),
          // Top-end: Gold EMV Chip
          PositionedDirectional(
            top: 18.h,
            end: 18.w,
            child: Image.asset(PngAssets.cardChip, width: 38.w, height: 28.h),
          ),
        ],
      ),
    );
  }

  Widget _background() {
    final image = backgroundImage?.trim() ?? '';
    if (image.isNotEmpty) {
      if (image.toLowerCase().endsWith('.svg')) {
        return SvgPicture.network(
          image,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => _gradient(),
        );
      }
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _gradient(),
      );
    }
    return _gradient();
  }

  Widget _gradient() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _color(primaryColor, const Color(0xFFBEA8FD)),
            _color(secondaryColor, const Color(0xFF9876F5)),
          ],
        ),
      ),
    );
  }

  Widget _brand() {
    final image = brandImage?.trim() ?? '';
    if (image.isNotEmpty) {
      return Image.network(
        image,
        width: 52.w,
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
        width: 52.w,
        height: 18.h,
        fit: BoxFit.contain,
      );
    }
    return _networkText();
  }

  Widget _networkText() {
    final value = network?.trim() ?? '';
    if (value.isEmpty) return const SizedBox.shrink();
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 100.w),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.start,
        style: TextStyle(
          color: AppColors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  static Color _color(String? value, Color fallback) {
    final normalized = value?.trim().replaceFirst('#', '');
    if (normalized == null || normalized.length != 6) return fallback;
    final parsed = int.tryParse('FF$normalized', radix: 16);
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
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final active = normalized == 'active' || normalized == 'completed';
    return Container(
      constraints: BoxConstraints(minWidth: 64.w, maxWidth: 88.w),
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFD4F4D2) : const Color(0xFFFDE8E8),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        _humanize(status),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12.sp,
          color: active ? const Color(0xFF2E7238) : const Color(0xFFC53030),
        ),
      ),
    );
  }

  static String _humanize(String value) {
    if (value.isEmpty) return '';
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
