import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/upload_helper.dart';

/// Document type aspect ratios and guidelines
enum KycDocumentType {
  /// Standard ID-1 card (National ID, Driver's License, Residence Card): 85.6mm x 53.98mm = ~1.586
  nationalCard,

  /// Passport ID page (ISO/IEC 7810 ID-3): ~1.42
  passport,

  /// Front camera selfie / biometric face frame
  selfie,
}

/// Professional Document Alignment Guide Box with rounded corners and corner markers.
/// Modern fintech standard (Sumsub, Onfido, Stripe Identity).
class DocumentAlignmentGuideBox extends StatefulWidget {
  final KycDocumentType documentType;
  final bool showScannerLine;
  final bool isDark;
  final Color frameColor;
  final Color overlayColor;
  final String? hintText;
  final Widget? child;

  const DocumentAlignmentGuideBox({
    super.key,
    this.documentType = KycDocumentType.nationalCard,
    this.showScannerLine = true,
    this.isDark = true,
    this.frameColor = const Color(0xFF10B981), // Emerald green
    this.overlayColor = const Color(0x99000000),
    this.hintText,
    this.child,
  });

  @override
  State<DocumentAlignmentGuideBox> createState() =>
      _DocumentAlignmentGuideBoxState();
}

class _DocumentAlignmentGuideBoxState extends State<DocumentAlignmentGuideBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, _) {
        return CustomPaint(
          painter: _DocumentGuidePainter(
            documentType: widget.documentType,
            frameColor: widget.frameColor,
            overlayColor: widget.overlayColor,
            scanProgress: widget.showScannerLine ? _scanAnimation.value : null,
          ),
          child: widget.child ?? const SizedBox.expand(),
        );
      },
    );
  }
}

class _DocumentGuidePainter extends CustomPainter {
  final KycDocumentType documentType;
  final Color frameColor;
  final Color overlayColor;
  final double? scanProgress;

  _DocumentGuidePainter({
    required this.documentType,
    required this.frameColor,
    required this.overlayColor,
    this.scanProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    if (documentType == KycDocumentType.selfie) {
      _paintSelfieOval(canvas, size);
      return;
    }

    // Card frame aspect ratio
    final aspectRatio = documentType == KycDocumentType.passport ? 1.42 : 1.586;
    final cardWidth = (size.width - 48.w).clamp(240.0, 480.0);
    final cardHeight = cardWidth / aspectRatio;

    final left = (size.width - cardWidth) / 2;
    final top = (size.height - cardHeight) / 2 - 20.h;
    final cardRect = Rect.fromLTWH(left, top, cardWidth, cardHeight);
    final cardRRect = RRect.fromRectAndRadius(cardRect, Radius.circular(16.r));

    // 1. Dark semi-transparent scrim with transparent card cutout
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRRect(cardRRect);
    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final overlayPaint = Paint()..color = overlayColor;
    canvas.drawPath(overlayPath, overlayPaint);

    // 2. Subtle bounding box border
    final borderPaint = Paint()
      ..color = frameColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(cardRRect, borderPaint);

    // 3. Four L-shaped Corner Markers
    _paintCornerMarkers(canvas, cardRect);

    // 4. Subtle watermark / ID card silhouette
    _paintCardWatermark(canvas, cardRect);

    // 5. Animated laser scanning line
    if (scanProgress != null) {
      final lineY = cardRect.top + cardRect.height * scanProgress!;
      final scanPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            frameColor.withValues(alpha: 0.0),
            frameColor.withValues(alpha: 0.85),
            frameColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(cardRect.left, lineY, cardRect.width, 2.5))
        ..strokeWidth = 2.5;

      canvas.drawLine(
        Offset(cardRect.left + 8.w, lineY),
        Offset(cardRect.right - 8.w, lineY),
        scanPaint,
      );
    }
  }

  void _paintCornerMarkers(Canvas canvas, Rect rect) {
    final cornerLength = 26.w;
    final cornerPaint = Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5.w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final r = 16.r;

    // Top-Left corner
    final tlPath = Path()
      ..moveTo(rect.left, rect.top + cornerLength)
      ..lineTo(rect.left, rect.top + r)
      ..quadraticBezierTo(rect.left, rect.top, rect.left + r, rect.top)
      ..lineTo(rect.left + cornerLength, rect.top);
    canvas.drawPath(tlPath, cornerPaint);

    // Top-Right corner
    final trPath = Path()
      ..moveTo(rect.right - cornerLength, rect.top)
      ..lineTo(rect.right - r, rect.top)
      ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + r)
      ..lineTo(rect.right, rect.top + cornerLength);
    canvas.drawPath(trPath, cornerPaint);

    // Bottom-Left corner
    final blPath = Path()
      ..moveTo(rect.left, rect.bottom - cornerLength)
      ..lineTo(rect.left, rect.bottom - r)
      ..quadraticBezierTo(rect.left, rect.bottom, rect.left + r, rect.bottom)
      ..lineTo(rect.left + cornerLength, rect.bottom);
    canvas.drawPath(blPath, cornerPaint);

    // Bottom-Right corner
    final brPath = Path()
      ..moveTo(rect.right - cornerLength, rect.bottom)
      ..lineTo(rect.right - r, rect.bottom)
      ..quadraticBezierTo(rect.right, rect.bottom, rect.right, rect.bottom - r)
      ..lineTo(rect.right, rect.bottom - cornerLength);
    canvas.drawPath(brPath, cornerPaint);
  }

  void _paintCardWatermark(Canvas canvas, Rect rect) {
    // Subtle ghost watermark indicating document orientation
    final watermarkPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Photo placeholder silhouette on the right (or left for LTR)
    final photoWidth = rect.width * 0.22;
    final photoHeight = photoWidth * 1.25;
    final photoRect = Rect.fromLTWH(
      rect.right - photoWidth - 18.w,
      rect.top + (rect.height - photoHeight) / 2,
      photoWidth,
      photoHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(photoRect, Radius.circular(6.r)),
      watermarkPaint,
    );

    // 3 subtle text placeholder lines
    final lineStartX = rect.left + 20.w;
    final lineEndX = rect.right - photoWidth - 32.w;
    final startY = rect.top + rect.height * 0.35;

    for (int i = 0; i < 3; i++) {
      final y = startY + (i * 14.h);
      final currentEnd = (i == 2) ? lineStartX + (lineEndX - lineStartX) * 0.6 : lineEndX;
      canvas.drawLine(
        Offset(lineStartX, y),
        Offset(currentEnd, y),
        watermarkPaint,
      );
    }
  }

  void _paintSelfieOval(Canvas canvas, Size size) {
    final ovalWidth = (size.width * 0.65).clamp(200.0, 320.0);
    final ovalHeight = ovalWidth * 1.35;
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 20.h),
      width: ovalWidth,
      height: ovalHeight,
    );

    final bgPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final ovalPath = Path()..addOval(ovalRect);
    final diff = Path.combine(PathOperation.difference, bgPath, ovalPath);

    canvas.drawPath(diff, Paint()..color = overlayColor);

    final borderPaint = Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.w;
    canvas.drawOval(ovalRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _DocumentGuidePainter oldDelegate) {
    return oldDelegate.documentType != documentType ||
        oldDelegate.frameColor != frameColor ||
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.scanProgress != scanProgress;
  }
}

/// Real-time tips banner: "Avoid glare and shadows", "Ensure all 4 corners are visible", "Text must be legible"
class RealtimeTipsBanner extends StatefulWidget {
  final bool isDark;
  final bool autoCycle;
  final Color? backgroundColor;

  const RealtimeTipsBanner({
    super.key,
    this.isDark = true,
    this.autoCycle = true,
    this.backgroundColor,
  });

  @override
  State<RealtimeTipsBanner> createState() => _RealtimeTipsBannerState();
}

class _RealtimeTipsBannerState extends State<RealtimeTipsBanner> {
  int _currentTipIndex = 0;

  final List<_TipItem> _tips = [
    _TipItem(
      icon: Icons.wb_sunny_outlined,
      iconColor: const Color(0xFFF59E0B),
      enText: 'Avoid glare, reflections, and heavy shadows',
      faText: 'از بازتاب مستقیم نور و ایجاد سایه خودداری کنید',
      arText: 'تجنب الوهج والانعكاسات والظلال',
      zhText: '避免强光反光和浓重阴影',
    ),
    _TipItem(
      icon: Icons.crop_free_rounded,
      iconColor: const Color(0xFF10B981),
      enText: 'Ensure all 4 corners are clearly visible',
      faText: 'مطمئن شوید هر ۴ گوشه مدرک داخل کادر باشد',
      arText: 'تأكد من وضوح وظهور جميع الزوايا الأربع',
      zhText: '确保文件的四个边角完整可见',
    ),
    _TipItem(
      icon: Icons.text_fields_rounded,
      iconColor: const Color(0xFF2196F3),
      enText: 'All text and details must be crisp & legible',
      faText: 'متن و مندرجات مدرک باید کاملاً شفاف و خوانا باشد',
      arText: 'يجب أن تكون النصوص والبيانات مقروءة وواضحة',
      zhText: '文字与证件信息必须清晰可读',
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.autoCycle) {
      _startTipTimer();
    }
  }

  void _startTipTimer() {
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _tips.length;
        });
        _startTipTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tip = _tips[_currentTipIndex];
    final defaultBg = widget.isDark
        ? Colors.black.withValues(alpha: 0.65)
        : Colors.white.withValues(alpha: 0.95);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? defaultBg,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.18)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: Row(
          key: ValueKey<int>(_currentTipIndex),
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: tip.iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                tip.icon,
                size: 15.sp,
                color: tip.iconColor,
              ),
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                l10nPick(
                  context,
                  en: tip.enText,
                  fa: tip.faText,
                  ar: tip.arText,
                  zh: tip.zhText,
                ),
                style: TextStyle(
                  color: widget.isDark ? Colors.white : AppColors.deepBlack,
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipItem {
  final IconData icon;
  final Color iconColor;
  final String enText;
  final String faText;
  final String arText;
  final String zhText;

  _TipItem({
    required this.icon,
    required this.iconColor,
    required this.enText,
    required this.faText,
    required this.arText,
    required this.zhText,
  });
}

/// Document preview confirmation sheet with thumbnail, file size check, and retake CTA
class DocumentConfirmationPreviewSheet extends StatelessWidget {
  final File file;
  final String documentTitle;
  final VoidCallback onRetake;
  final VoidCallback onConfirm;

  const DocumentConfirmationPreviewSheet({
    super.key,
    required this.file,
    required this.documentTitle,
    required this.onRetake,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor =
        isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    final fileLength = file.existsSync() ? file.lengthSync() : 0;
    final sizeInMB = fileLength / (1024 * 1024);
    final sizeString = '${sizeInMB.toStringAsFixed(2)} MB';
    final isSizeValid = !UploadHelper.exceedsSize(file, UploadHelper.maxKycDocBytes);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet Handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkDivider : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // Header Row: Title & Size Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    documentTitle,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: primaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: (isSizeValid
                            ? const Color(0xFF10B981)
                            : const Color(0xFFDC2626))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSizeValid
                            ? Icons.check_circle_rounded
                            : Icons.error_outline_rounded,
                        size: 13.sp,
                        color: isSizeValid
                            ? const Color(0xFF10B981)
                            : const Color(0xFFDC2626),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '$sizeString / 20MB',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: isSizeValid
                              ? const Color(0xFF10B981)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Thumbnail Preview Container
            Container(
              width: double.infinity,
              height: 210.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Image.file(
                  file,
                  width: double.infinity,
                  height: 210.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Quality Check Points
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCheckPoint(
                  context,
                  Icons.crop_free_rounded,
                  l10nPick(context, en: '4 Corners Visible', fa: '۴ گوشه مشخص'),
                  const Color(0xFF10B981),
                  secondaryTextColor,
                ),
                _buildCheckPoint(
                  context,
                  Icons.wb_sunny_outlined,
                  l10nPick(context, en: 'No Glare', fa: 'بدون بازتاب نور'),
                  const Color(0xFF10B981),
                  secondaryTextColor,
                ),
                _buildCheckPoint(
                  context,
                  Icons.text_fields_rounded,
                  l10nPick(context, en: 'Text Legible', fa: 'متن کاملاً خوانا'),
                  const Color(0xFF10B981),
                  secondaryTextColor,
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Actions: Retake / Replace Button + Confirm Button
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRetake,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(
                      l10nPick(
                        context,
                        en: 'Retake',
                        fa: 'تصویربرداری مجدد',
                        ar: 'إعادة الالتقاط',
                        zh: '重新拍摄',
                      ),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: isSizeValid ? onConfirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(
                      l10nPick(
                        context,
                        en: 'Confirm & Use Photo',
                        fa: 'تأیید و استفاده از عکس',
                        ar: 'تأكيد واستخدام الصورة',
                        zh: '确认并使用此照片',
                      ),
                      style: TextStyle(
                        fontSize: 13.sp,
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
      ),
    );
  }

  Widget _buildCheckPoint(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    Color textColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.sp, color: color),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
