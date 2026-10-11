import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/constants/assets_path/svg/svg_assets.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';

/// Ultra-premium interactive 3D virtual card visualization for eCardo.
///
/// Follows modern fintech standards (Apple Card, Revolut, Monzo):
/// - Interactive 3D Perspective Flip Animation (`setEntry(3, 2, 0.0015)`).
/// - Realistic Front: Brand, EMV Chip, Contactless NFC, Monospace PAN,
///   Expiry, Cardholder Name, Status Badge, 1-tap Copy with haptic feedback
///   and temporary checkmark indicator.
/// - Realistic Back: Deep magnetic strip, textured signature panel with
///   authorized signature, CVV2 panel with reveal/hide toggle and tap-to-copy,
///   iridescent holographic security badge, and issuer bank regulatory text.
/// - Frosted-glass freeze overlay with snowflake when card is frozen.
class CommonVirtualCardView extends StatefulWidget {
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

  // Modern fintech additions (with graceful backward compatibility)
  final String? rawCardNumber;
  final String? cvv;
  final String? cardHolderName;
  final bool enableFlip;
  final bool showFlipIndicator;
  final VoidCallback? onCopyCardNumber;
  final ValueChanged<bool>? onFlip;

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
    this.rawCardNumber,
    this.cvv,
    this.cardHolderName,
    this.enableFlip = true,
    this.showFlipIndicator = true,
    this.onCopyCardNumber,
    this.onFlip,
  });

  @override
  State<CommonVirtualCardView> createState() => _CommonVirtualCardViewState();
}

class _CommonVirtualCardViewState extends State<CommonVirtualCardView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  bool _isCopiedRecently = false;
  bool _isCvvRevealed = false;
  bool _isCvvCopiedRecently = false;

  bool get _isCardFrozen {
    if (widget.isFrozen == true) return true;
    final normalized = widget.status.toLowerCase();
    return normalized == 'frozen' ||
        normalized == 'freeze' ||
        normalized == 'blocked';
  }

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (!widget.enableFlip) return;
    HapticFeedback.lightImpact();
    if (_flipController.isCompleted) {
      _flipController.reverse();
      widget.onFlip?.call(false);
    } else {
      _flipController.forward();
      widget.onFlip?.call(true);
    }
  }

  void _handleCopyCardNumber(String numberToCopy) {
    if (numberToCopy.isEmpty) return;
    HapticFeedback.mediumImpact();
    final cleanDigits = numberToCopy.replaceAll(RegExp(r'\s+'), '');
    Clipboard.setData(ClipboardData(text: cleanDigits));
    widget.onCopyCardNumber?.call();

    if (mounted) {
      setState(() => _isCopiedRecently = true);
    }

    ToastHelper().showSuccessToast(
      l10nPick(
        context,
        en: 'Card number copied to clipboard',
        fa: 'شماره کارت در کلیپ‌بورد کپی شد',
        ar: 'تم نسخ رقم البطاقة إلى الحافظة',
        tr: 'Kart numarası panoya kopyalandı',
        ru: 'Номер карты скопирован в буфер',
        zh: '卡号已复制到剪贴板',
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isCopiedRecently = false);
      }
    });
  }

  void _handleCopyCvv(String cvvToCopy) {
    if (cvvToCopy.isEmpty) return;
    HapticFeedback.mediumImpact();
    Clipboard.setData(ClipboardData(text: cvvToCopy));

    if (mounted) {
      setState(() => _isCvvCopiedRecently = true);
    }

    ToastHelper().showSuccessToast(
      l10nPick(
        context,
        en: 'Security code (CVV) copied',
        fa: 'کد امنیتی (CVV) کپی شد',
        ar: 'تم نسخ رمز الأمان (CVV)',
        tr: 'Güvenlik kodu (CVV) kopyalandı',
        ru: 'Код безопасности (CVV) скопирован',
        zh: '安全码 (CVV) 已复制',
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isCvvCopiedRecently = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppSpacing.radiusXl);

    final cardWidget = Container(
      width: double.infinity,
      height: 215.h,
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
          // 1. Mesh Gradient Background / Remote Image
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

          // 5. Interactive 3D Perspective Flip Animation Content
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, _) {
                final angle = _flipAnimation.value * pi;
                final shineOpacity =
                    (sin(_flipAnimation.value * pi) * 0.24).clamp(0.0, 0.24);

                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0015)
                    ..rotateY(angle),
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      angle >= (pi / 2)
                          ? Transform(
                              transform: Matrix4.identity()..rotateY(pi),
                              alignment: Alignment.center,
                              child: _buildCardBack(borderRadius),
                            )
                          : _buildCardFront(borderRadius),

                      // Dynamic Specular Sweep highlight during flip
                      if (shineOpacity > 0.01)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: borderRadius,
                                gradient: LinearGradient(
                                  begin: Alignment(
                                    -1.2 + (_flipAnimation.value * 2.4),
                                    -1.0,
                                  ),
                                  end: Alignment(
                                    1.2 + (_flipAnimation.value * 2.4),
                                    1.0,
                                  ),
                                  colors: [
                                    Colors.white.withValues(alpha: 0.0),
                                    Colors.white.withValues(alpha: shineOpacity),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
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

    if (widget.enableFlip) {
      return GestureDetector(
        onTap: _toggleFlip,
        behavior: HitTestBehavior.translucent,
        child: cardWidget,
      );
    }

    return cardWidget;
  }

  // ===========================================================================
  // FRONT FACE
  // ===========================================================================
  Widget _buildCardFront(BorderRadius borderRadius) {
    final effectiveNumber = widget.value;
    final copyTarget = (widget.rawCardNumber != null &&
            widget.rawCardNumber!.isNotEmpty)
        ? widget.rawCardNumber!
        : (widget.value.replaceAll(RegExp(r'\s+'), ''));

    final holderText = widget.cardHolderName?.isNotEmpty == true
        ? widget.cardHolderName!
        : (widget.title.isNotEmpty ? widget.title : 'Virtual Card');

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 20.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
            // Row 1: Brand + Contactless NFC + EMV Chip
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildBrand(),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.contactless_rounded,
                  size: 20.sp,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
                const Spacer(),
                _buildEmvChip(),
              ],
            ),

            SizedBox(height: 12.h),

          // Row 2: Card Title & Masked PAN with Tap-To-Copy & Reveal Toggle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                holderText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5.sp,
                  color: Colors.white.withValues(alpha: 0.88),
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 6.h),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _handleCopyCardNumber(copyTarget),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                effectiveNumber,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18.5.sp,
                                  letterSpacing: 2.0,
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
                            SizedBox(width: 8.w),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: _isCopiedRecently
                                  ? Container(
                                      key: const ValueKey('copied_check'),
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: AppColors.success,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        size: 13.sp,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      Icons.copy_rounded,
                                      key: const ValueKey('copy_icon'),
                                      size: 14.sp,
                                      color: Colors.white.withValues(alpha: 0.70),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.canReveal)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onReveal?.call();
                          },
                          child: Container(
                            width: 44.w,
                            height: 44.h,
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              widget.isRevealed
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
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Row 3: First Value (Expiry/Balance), Second Value (CVC/Currency), Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: _ValueBlock(
                  label: widget.firstLabel,
                  value: widget.firstValue,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                flex: 2,
                child: _ValueBlock(
                  label: widget.secondLabel,
                  value: widget.secondValue,
                ),
              ),
              SizedBox(width: 8.w),
              _StatusBadge(status: widget.status, isFrozen: _isCardFrozen),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BACK FACE
  // ===========================================================================
  Widget _buildCardBack(BorderRadius borderRadius) {
    final effectiveCvv = widget.cvv?.isNotEmpty == true
        ? widget.cvv!
        : (widget.secondLabel.toUpperCase() == 'CVC' ? widget.secondValue : '888');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 14.h),

        // 1. Deep Metallic Magnetic Strip
        Container(
          height: 38.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0F0F12),
                Color(0xFF26262B),
                Color(0xFF141416),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _MagneticStripLusterPainter(),
          ),
        ),

        SizedBox(height: 12.h),

        // 2. Signature Panel & CVV2 Box Row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Row(
            children: [
              // Signature Panel
              Expanded(
                flex: 5,
                child: Container(
                  height: 38.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F2EE),
                    borderRadius: BorderRadius.circular(4.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'AUTHORIZED SIGNATURE',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 7.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: const Color(0xFF7A7875),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'eCardo',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontStyle: FontStyle.italic,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // CVV2 Panel with reveal toggle and tap-to-copy
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () => _handleCopyCvv(effectiveCvv),
                  child: Container(
                    height: 38.h,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(
                        color: const Color(0xFFDCD6D0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CVV2',
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: const Color(0xFF6A6864),
                          ),
                        ),
                        Text(
                          _isCvvRevealed ? effectiveCvv : '•••',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontStyle: FontStyle.italic,
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: const Color(0xFF161614),
                          ),
                        ),
                        _isCvvCopiedRecently
                            ? Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 10.sp,
                                  color: Colors.white,
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    _isCvvRevealed = !_isCvvRevealed;
                                  });
                                },
                                child: Icon(
                                  _isCvvRevealed
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  size: 14.sp,
                                  color: const Color(0xFF4A4A48),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // 3. Security Hologram + Issuer Bank Notice + Brand
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Security Holographic Foil Badge
              _buildHologramBadge(),
              SizedBox(width: 10.w),

              // Regulatory & Issuer Bank Text
              Expanded(
                child: Text(
                  'Issued by eCardo Financial Services. For customer support visit ecardo.com. '
                  'Do not share CVV credentials with unauthorized parties.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 7.5.sp,
                    height: 1.25,
                    color: Colors.white.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // Flip back affordance
              GestureDetector(
                onTap: _toggleFlip,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.rotate_left_rounded,
                        size: 11.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        l10nPick(
                          context,
                          en: 'Front',
                          fa: 'روی کارت',
                          ar: 'الوجه',
                          tr: 'Ön yüz',
                          ru: 'Лицо',
                          zh: '正面',
                        ),
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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
    );
  }

  // ===========================================================================
  // SUB-COMPONENTS
  // ===========================================================================

  Widget _buildEmvChip() {
    return Container(
      width: 36.w,
      height: 26.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFDF7D),
            Color(0xFFC79E3B),
            Color(0xFFECCB68),
            Color(0xFF9E7720),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 3,
            offset: const Offset(0, 1.5),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFFF2AC),
          width: 0.6,
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2.5),
        child: CustomPaint(
          painter: _EmvMicrochipTracePainter(),
        ),
      ),
    );
  }

  Widget _buildHologramBadge() {
    return Container(
      width: 34.w,
      height: 24.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE2E8F0),
            Color(0xFFA5B4FC),
            Color(0xFFFBCFE8),
            Color(0xFF6EE7B7),
            Color(0xFFFDE68A),
            Color(0xFFE2E8F0),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 0.6,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.shield_rounded,
          size: 13.sp,
          color: const Color(0xCC1E293B),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    final image = widget.backgroundImage?.trim() ?? '';
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
    final primary = _color(widget.primaryColor, null);
    final secondary = _color(widget.secondaryColor, null);

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
    final image = widget.brandImage?.trim() ?? '';
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
    final net = widget.network?.trim().toLowerCase() ?? '';
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
        widget.network!.trim(),
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

// =============================================================================
// PAINTERS & WIDGET HELPERS
// =============================================================================

/// Custom painter for physical EMV microchip contact pads
class _EmvMicrochipTracePainter extends CustomPainter {
  const _EmvMicrochipTracePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = const Color(0x4D000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final outerRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(3),
    );
    canvas.drawRRect(outerRRect, stroke);

    final midX = size.width * 0.44;
    canvas.drawLine(Offset(midX, 0), Offset(midX, size.height), stroke);

    canvas.drawLine(
      Offset(0, size.height * 0.36),
      Offset(midX, size.height * 0.36),
      stroke,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.68),
      Offset(midX, size.height * 0.68),
      stroke,
    );
    canvas.drawLine(
      Offset(midX, size.height * 0.50),
      Offset(size.width, size.height * 0.50),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Subtle horizontal luster stripes across magnetic stripe
class _MagneticStripLusterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double y = 4; y < size.height; y += 6) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
