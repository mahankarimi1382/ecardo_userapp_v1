import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';

/// Status of the transaction represented in [EcardoDigitalReceipt].
enum EcardoReceiptStatus {
  success,
  pending,
  failed,
}

/// An entry row in the receipt breakdown table.
class EcardoReceiptItem {
  final String label;
  final String? value;
  final double? amount;
  final String? currency;
  final int decimals;
  final bool isHighlighted;
  final bool isCopyable;
  final String? copyText;
  final Color? valueColor;
  final Widget? trailing;

  const EcardoReceiptItem({
    required this.label,
    this.value,
    this.amount,
    this.currency,
    this.decimals = 2,
    this.isHighlighted = false,
    this.isCopyable = false,
    this.copyText,
    this.valueColor,
    this.trailing,
  });
}

/// Creative Neo-Fintech Digital Receipt Card for eCardo.
///
/// Features:
/// - Jagged / notched perforation divider with concave ticket cutouts.
/// - Prominent monospace transaction reference code with instant copy.
/// - Floating feedback chip that pops up inside the card upon copy.
/// - Status watermark stamp angled with neo-fintech micro-typography.
/// - Detailed financial breakdown table with highlighted totals.
/// - Share and Export action buttons with tactile bounce press.
class EcardoDigitalReceipt extends StatefulWidget {
  final String title;
  final String transactionReference;
  final DateTime? timestamp;
  final String? formattedTimestamp;
  final double? primaryAmount;
  final String? primaryCurrency;
  final int primaryDecimals;
  final EcardoReceiptStatus status;
  final List<EcardoReceiptItem> items;
  final String? note;
  final VoidCallback? onShare;
  final VoidCallback? onDownload;
  final bool showBarcode;
  final bool showWatermark;
  final String? watermarkText;
  final EdgeInsetsGeometry padding;

  const EcardoDigitalReceipt({
    super.key,
    required this.title,
    required this.transactionReference,
    this.timestamp,
    this.formattedTimestamp,
    this.primaryAmount,
    this.primaryCurrency,
    this.primaryDecimals = 2,
    this.status = EcardoReceiptStatus.success,
    this.items = const [],
    this.note,
    this.onShare,
    this.onDownload,
    this.showBarcode = true,
    this.showWatermark = true,
    this.watermarkText,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  @override
  State<EcardoDigitalReceipt> createState() => _EcardoDigitalReceiptState();
}

class _EcardoDigitalReceiptState extends State<EcardoDigitalReceipt> {
  final GlobalKey _dividerKey = GlobalKey();
  final GlobalKey _containerKey = GlobalKey();

  double? _measuredNotchY;
  String? _feedbackMessage;
  Timer? _feedbackTimer;

  static const double _notchRadius = 12.0;
  static const double _borderRadius = 18.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureNotchPosition());
  }

  @override
  void didUpdateWidget(EcardoDigitalReceipt oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureNotchPosition());
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    super.dispose();
  }

  void _measureNotchPosition() {
    if (!mounted) return;
    final dividerBox = _dividerKey.currentContext?.findRenderObject() as RenderBox?;
    final containerBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;

    if (dividerBox != null && containerBox != null && dividerBox.hasSize && containerBox.hasSize) {
      final offset = dividerBox.localToGlobal(Offset.zero, ancestor: containerBox);
      final calculatedY = offset.dy + (dividerBox.size.height / 2);
      if (_measuredNotchY == null || (_measuredNotchY! - calculatedY).abs() > 0.5) {
        setState(() {
          _measuredNotchY = calculatedY;
        });
      }
    }
  }

  void _triggerCopy(String text, [String? label]) {
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: text));

    _feedbackTimer?.cancel();
    setState(() {
      _feedbackMessage = label != null ? '$label Copied' : 'Copied to Clipboard';
    });

    _feedbackTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() => _feedbackMessage = null);
      }
    });
  }

  String _resolveTimestamp() {
    if (widget.formattedTimestamp != null) return widget.formattedTimestamp!;
    final dt = widget.timestamp ?? DateTime.now();
    return DateFormat('dd MMM yyyy, HH:mm:ss').format(dt);
  }

  String _formatAmount(double amount, int decimals) {
    return NumberFormat.currency(
      symbol: '',
      decimalDigits: decimals,
    ).format(amount).trim();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkCard : AppColors.white;
    final borderColor = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder.withValues(alpha: 0.8);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            // 1. Ticket Card Body with custom notches
            CustomPaint(
              key: _containerKey,
              painter: _ReceiptBorderPainter(
                borderRadius: _borderRadius,
                notchRadius: _notchRadius,
                notchY: _measuredNotchY,
                borderColor: borderColor,
                borderWidth: 1.2,
                fillColor: cardBg,
                drawShadow: true,
                isDark: isDark,
              ),
              child: ClipPath(
                clipper: _ReceiptClipper(
                  borderRadius: _borderRadius,
                  notchRadius: _notchRadius,
                  notchY: _measuredNotchY,
                ),
                child: Container(
                  color: Colors.transparent,
                  padding: widget.padding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header & Status
                      _buildHeader(context, isDark),
                      const SizedBox(height: AppSpacing.md),

                      // Primary Amount Hero
                      if (widget.primaryAmount != null) ...[
                        _buildHeroAmount(isDark),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Reference code pill
                      _buildReferenceCode(isDark),
                      const SizedBox(height: AppSpacing.lg),

                      // Breakdown table items
                      if (widget.items.isNotEmpty) ...[
                        ...widget.items.map((item) => _buildItemRow(context, item, isDark)),
                        const SizedBox(height: AppSpacing.sm),
                      ],

                      // Optional free-text note (e.g. settlement terms, memo)
                      if (widget.note != null && widget.note!.isNotEmpty) ...[
                        _buildNote(widget.note!, isDark),
                        const SizedBox(height: AppSpacing.sm),
                      ],

                      // Jagged Perforation Divider with Ticket Notches
                      Container(
                        key: _dividerKey,
                        height: _notchRadius * 2,
                        alignment: Alignment.center,
                        child: CustomPaint(
                          size: const Size(double.infinity, 8),
                          painter: _JaggedPerforationPainter(
                            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                            strokeWidth: 1.2,
                            toothWidth: 8.0,
                            toothHeight: 4.0,
                            padding: _notchRadius + 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Barcode & Cryptographic Security Note
                      if (widget.showBarcode) ...[
                        _buildBarcodeSection(isDark),
                        const SizedBox(height: AppSpacing.sm),
                      ],

                      // Timestamp and Verified Footer
                      _buildFooter(isDark),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Angled Watermark Stamp (e.g. PAID / VERIFIED)
            if (widget.showWatermark)
              Positioned(
                top: 72,
                right: 20,
                child: _buildWatermarkStamp(isDark),
              ),

            // 3. Floating Copy Feedback Chip
            if (_feedbackMessage != null)
              Positioned(
                top: 12,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _feedbackMessage != null ? 1.0 : 0.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.deepBlack,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _feedbackMessage!,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Action Buttons Row (Share / Download)
        if (widget.onShare != null || widget.onDownload != null) ...[
          const SizedBox(height: AppSpacing.md),
          _buildActionButtons(context, isDark),
        ],
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 18,
                    color: isDark ? AppColors.deepBlack : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'eCardo Receipt',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.title,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _buildStatusPill(isDark),
      ],
    );
  }

  Widget _buildStatusPill(bool isDark) {
    // The `*Container` tokens are light-theme tints (near-white); used raw they glow on
    // a dark receipt. Keep the light tint on light, and tint the vivid hue over the
    // surface on dark so the pill stays legible in both.
    Color surface(Color lightTint, Color vivid) =>
        isDark ? vivid.withValues(alpha: 0.18) : lightTint;

    final (bg, border, text, icon, label) = switch (widget.status) {
      EcardoReceiptStatus.success => (
          surface(AppColors.successContainer, AppColors.success),
          AppColors.success.withValues(alpha: 0.35),
          AppColors.success,
          Icons.check_circle_rounded,
          'Success',
        ),
      EcardoReceiptStatus.pending => (
          surface(AppColors.warningContainer, AppColors.warning),
          AppColors.warning.withValues(alpha: 0.35),
          AppColors.warning,
          Icons.schedule_rounded,
          'Pending',
        ),
      EcardoReceiptStatus.failed => (
          surface(AppColors.errorContainer, AppColors.error),
          AppColors.error.withValues(alpha: 0.35),
          AppColors.error,
          Icons.cancel_rounded,
          'Failed',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAmount(bool isDark) {
    final formatted = _formatAmount(widget.primaryAmount!, widget.primaryDecimals);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            formatted,
            style: AppTextStyles.headlineLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              letterSpacing: -0.5,
            ),
          ),
          if (widget.primaryCurrency != null) ...[
            const SizedBox(width: 6),
            Text(
              widget.primaryCurrency!,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.mainSoftBlue
                    : AppColors.mutedBlue,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReferenceCode(bool isDark) {
    return GestureDetector(
      onTap: () => _triggerCopy(widget.transactionReference, 'Ref ID'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
              : AppColors.lightSecondaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightOutlineVariant,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRANSACTION REFERENCE',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 9.5,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.transactionReference,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.copy_rounded,
              size: 16,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, EcardoReceiptItem item, bool isDark) {
    String valueText = item.value ?? '';
    if (item.amount != null) {
      valueText = '${_formatAmount(item.amount!, item.decimals)} ${item.currency ?? ''}'.trim();
    }

    final textColor = item.valueColor ??
        (item.isHighlighted
            ? (isDark ? AppColors.mainSoftBlue : AppColors.deepBlack)
            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 4,
            child: Text(
              item.label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 6,
            child: item.trailing ??
                GestureDetector(
                  onTap: item.isCopyable
                      ? () => _triggerCopy(item.copyText ?? valueText, item.label)
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          valueText,
                          textAlign: TextAlign.end,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: item.isHighlighted
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.isCopyable) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.copy_rounded,
                          size: 12,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                        ),
                      ],
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  /// Renders [note] as a muted caption block under the item table.
  Widget _buildNote(String note, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSecondaryContainer.withValues(alpha: 0.35)
            : AppColors.lightSecondaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Text(
        note,
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 11,
          height: 1.45,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),
    );
  }

  Widget _buildBarcodeSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      alignment: Alignment.center,
      child: Column(
        children: [
          CustomPaint(
            size: const Size(180, 32),
            painter: _BarcodePlaceholderPainter(
              barColor: isDark ? AppColors.warmWhite : AppColors.deepBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.transactionReference,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_outlined,
                size: 13,
                color: AppColors.mainSoftBlue,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Verified Network',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _resolveTimestamp(),
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 10,
            color: isDark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildWatermarkStamp(bool isDark) {
    final stampText = widget.watermarkText ??
        switch (widget.status) {
          EcardoReceiptStatus.success => 'PAID',
          EcardoReceiptStatus.pending => 'PENDING',
          EcardoReceiptStatus.failed => 'VOID',
        };

    final stampColor = switch (widget.status) {
      EcardoReceiptStatus.success => AppColors.success,
      EcardoReceiptStatus.pending => AppColors.warning,
      EcardoReceiptStatus.failed => AppColors.error,
    };

    return IgnorePointer(
      child: Transform.rotate(
        angle: -math.pi / 16,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: stampColor.withValues(alpha: 0.45),
              width: 1.5,
            ),
            color: stampColor.withValues(alpha: isDark ? 0.08 : 0.05),
          ),
          child: Text(
            stampText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: stampColor.withValues(alpha: 0.65),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Row(
      children: [
        if (widget.onShare != null)
          Expanded(
            child: _ReceiptActionButton(
              icon: Icons.share_rounded,
              label: 'Share Receipt',
              onPressed: widget.onShare!,
              isPrimary: false,
              isDark: isDark,
            ),
          ),
        if (widget.onShare != null && widget.onDownload != null)
          const SizedBox(width: AppSpacing.md),
        if (widget.onDownload != null)
          Expanded(
            child: _ReceiptActionButton(
              icon: Icons.download_rounded,
              label: 'Download PDF',
              onPressed: widget.onDownload!,
              isPrimary: true,
              isDark: isDark,
            ),
          ),
      ],
    );
  }
}

class _ReceiptActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDark;

  const _ReceiptActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isPrimary,
    required this.isDark,
  });

  @override
  State<_ReceiptActionButton> createState() => _ReceiptActionButtonState();
}

class _ReceiptActionButtonState extends State<_ReceiptActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isPrimary
        ? (widget.isDark ? AppColors.mainSoftBlue : AppColors.deepBlack)
        : (widget.isDark ? AppColors.darkCard : AppColors.white);

    final fg = widget.isPrimary
        ? (widget.isDark ? AppColors.deepBlack : Colors.white)
        : (widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
      },
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: widget.isPrimary
                  ? Colors.transparent
                  : (widget.isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: widget.isDark ? 0.25 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 16, color: fg),
              const SizedBox(width: AppSpacing.sm),
              Text(
                widget.label,
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom clipper that punches side semicircles into the ticket edge.
class _ReceiptClipper extends CustomClipper<Path> {
  final double borderRadius;
  final double notchRadius;
  final double? notchY;

  const _ReceiptClipper({
    required this.borderRadius,
    required this.notchRadius,
    this.notchY,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;
    final double r = borderRadius.clamp(0.0, math.min(w / 2, h / 2));
    final double nr = notchRadius.clamp(0.0, math.min(w / 4, h / 4));
    final double ny = (notchY ?? (h * 0.65)).clamp(r + nr, h - r - nr);

    path.moveTo(r, 0);
    path.lineTo(w - r, 0);
    path.arcToPoint(Offset(w, r), radius: Radius.circular(r), clockwise: true);

    // Right edge down to notch
    path.lineTo(w, ny - nr);
    path.arcToPoint(Offset(w, ny + nr), radius: Radius.circular(nr), clockwise: false);

    // Right edge down to bottom corner
    path.lineTo(w, h - r);
    path.arcToPoint(Offset(w - r, h), radius: Radius.circular(r), clockwise: true);

    // Bottom edge to left corner
    path.lineTo(r, h);
    path.arcToPoint(Offset(0, h - r), radius: Radius.circular(r), clockwise: true);

    // Left edge up to notch
    path.lineTo(0, ny + nr);
    path.arcToPoint(Offset(0, ny - nr), radius: Radius.circular(nr), clockwise: false);

    // Left edge up to top corner
    path.lineTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r), clockwise: true);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(_ReceiptClipper oldClipper) =>
      oldClipper.borderRadius != borderRadius ||
      oldClipper.notchRadius != notchRadius ||
      oldClipper.notchY != notchY;
}

/// Custom painter for the ticket boundary and drop shadow.
class _ReceiptBorderPainter extends CustomPainter {
  final double borderRadius;
  final double notchRadius;
  final double? notchY;
  final Color borderColor;
  final double borderWidth;
  final Color fillColor;
  final bool drawShadow;
  final bool isDark;

  const _ReceiptBorderPainter({
    required this.borderRadius,
    required this.notchRadius,
    this.notchY,
    required this.borderColor,
    required this.borderWidth,
    required this.fillColor,
    required this.drawShadow,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final clipper = _ReceiptClipper(
      borderRadius: borderRadius,
      notchRadius: notchRadius,
      notchY: notchY,
    );
    final path = clipper.getClip(size);

    if (drawShadow) {
      canvas.drawShadow(
        path,
        Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
        10.0,
        true,
      );
    }

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    if (borderWidth > 0) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(_ReceiptBorderPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.notchRadius != notchRadius ||
      oldDelegate.notchY != notchY ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.borderWidth != borderWidth ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.isDark != isDark;
}

/// Custom painter that draws a zig-zag perforation line between notches.
class _JaggedPerforationPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double toothWidth;
  final double toothHeight;
  final double padding;

  const _JaggedPerforationPainter({
    required this.color,
    required this.strokeWidth,
    required this.toothWidth,
    required this.toothHeight,
    required this.padding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final double startX = padding;
    final double endX = size.width - padding;
    final double midY = size.height / 2;

    double currentX = startX;
    bool up = true;

    path.moveTo(currentX, midY);

    while (currentX < endX) {
      final nextX = math.min(currentX + toothWidth, endX);
      final y = up ? (midY - toothHeight / 2) : (midY + toothHeight / 2);
      path.lineTo(nextX, y);
      currentX = nextX;
      up = !up;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_JaggedPerforationPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.toothWidth != toothWidth ||
      oldDelegate.toothHeight != toothHeight ||
      oldDelegate.padding != padding;
}

/// Procedural barcode painter for a clean realistic barcode strip.
class _BarcodePlaceholderPainter extends CustomPainter {
  final Color barColor;

  const _BarcodePlaceholderPainter({required this.barColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    // Deterministic pseudo-random bar pattern
    final widths = [
      1.5, 3.0, 1.0, 2.0, 4.0, 1.0, 2.5, 1.5, 3.5, 1.0,
      2.0, 1.5, 4.0, 2.0, 1.0, 3.0, 1.5, 2.0, 1.0, 3.5,
      2.5, 1.0, 2.0, 3.0, 1.5, 4.0, 1.0, 2.0, 1.5, 3.0,
    ];

    double currentX = 0;
    for (int i = 0; i < widths.length && currentX < size.width; i++) {
      final barWidth = widths[i];
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(currentX, 0, barWidth, size.height),
          paint,
        );
      }
      currentX += barWidth + 1.5;
    }
  }

  @override
  bool shouldRepaint(_BarcodePlaceholderPainter oldDelegate) =>
      oldDelegate.barColor != barColor;
}
