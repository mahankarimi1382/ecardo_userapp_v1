import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

/// A reusable quick-amount percentage selector widget with chips
/// (defaulting to 25%, 50%, 75%, Max).
///
/// Tapping a chip computes the corresponding percentage of [availableBalance],
/// formats it accurately according to [isCrypto] and [currencyCode], writes
/// the value into [textController] with the cursor positioned at the end,
/// and triggers [onAmountChanged].
class QuickAmountSelector extends StatefulWidget {
  const QuickAmountSelector({
    super.key,
    required this.textController,
    required this.availableBalance,
    required this.isCrypto,
    this.onAmountChanged,
    this.percentages = const [0.25, 0.50, 0.75, 1.0],
    this.currencyCode,
    this.maxLabel,
    this.labelBuilder,
    this.enabled = true,
    this.height = 34.0,
    this.chipSpacing = 8.0,
  });

  /// The text controller whose text will be populated on chip tap.
  final TextEditingController textController;

  /// Total available balance in the selected wallet.
  final double availableBalance;

  /// Whether the selected asset is a cryptocurrency (requires 8 decimal precision).
  final bool isCrypto;

  /// Optional currency code (e.g. 'IRR', 'IRT', 'TOMAN', 'USD', 'USDT') used
  /// to apply 0-decimal integer formatting for Rial/Toman where fractional
  /// units are invalid.
  final String? currencyCode;

  /// Optional callback invoked with the newly selected raw amount.
  final Function(double amount)? onAmountChanged;

  /// List of percentage ratios between 0.0 and 1.0. Defaults to 25%, 50%, 75%, 100%.
  final List<double> percentages;

  /// Optional custom label for 100% (defaults to 'Max').
  final String? maxLabel;

  /// Optional custom label builder per percentage ratio.
  final String Function(double percent)? labelBuilder;

  /// Whether the selector allows interactions.
  final bool enabled;

  /// Height of each percentage chip. Defaults to 34.0.
  final double height;

  /// Horizontal spacing between chips. Defaults to 8.0.
  final double chipSpacing;

  @override
  State<QuickAmountSelector> createState() => _QuickAmountSelectorState();
}

class _QuickAmountSelectorState extends State<QuickAmountSelector> {
  @override
  void initState() {
    super.initState();
    widget.textController.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant QuickAmountSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.textController != widget.textController) {
      oldWidget.textController.removeListener(_onTextChanged);
      widget.textController.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.textController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Calculates decimal precision:
  /// - 0 decimals for IRR / IRT / TOMAN
  /// - 8 decimals for cryptocurrency
  /// - 2 decimals for standard fiat
  int _resolveDecimals() {
    final code = widget.currencyCode?.trim().toUpperCase();
    if (code == 'IRR' || code == 'IRT' || code == 'TOMAN') {
      return 0;
    }
    return widget.isCrypto ? 8 : 2;
  }

  /// Formats [amount] according to asset rules:
  /// - Integer for 0 decimals (IRR/TOMAN)
  /// - Fixed-point string otherwise
  String _formatAmount(double amount) {
    final decimals = _resolveDecimals();
    if (decimals == 0) {
      return amount.round().toString();
    }
    return amount.toStringAsFixed(decimals);
  }

  void _onChipTap(double percent) {
    if (!widget.enabled || widget.availableBalance <= 0) return;

    HapticFeedback.selectionClick();

    final rawAmount = widget.availableBalance * percent;
    final formatted = _formatAmount(rawAmount);

    widget.textController.text = formatted;
    widget.textController.selection = TextSelection.fromPosition(
      TextPosition(offset: formatted.length),
    );

    final parsedAmount = double.tryParse(formatted) ?? rawAmount;
    widget.onAmountChanged?.call(parsedAmount);
  }

  String _getChipLabel(double percent) {
    if (widget.labelBuilder != null) {
      return widget.labelBuilder!(percent);
    }
    if ((percent - 1.0).abs() < 1e-6) {
      return widget.maxLabel ?? 'Max';
    }
    return '${(percent * 100).round()}%';
  }

  bool _isChipSelected(double percent) {
    if (widget.availableBalance <= 0) return false;
    final currentText = widget.textController.text.trim();
    if (currentText.isEmpty) return false;

    final targetText = _formatAmount(widget.availableBalance * percent);
    return currentText == targetText;
  }

  @override
  Widget build(BuildContext context) {
    final bool isInteractable = widget.enabled && widget.availableBalance > 0;

    return Opacity(
      opacity: isInteractable ? 1.0 : 0.45,
      child: Row(
        children: [
          for (int i = 0; i < widget.percentages.length; i++) ...[
            if (i > 0) SizedBox(width: widget.chipSpacing),
            Expanded(
              child: _buildChip(
                percent: widget.percentages[i],
                isInteractable: isInteractable,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip({
    required double percent,
    required bool isInteractable,
  }) {
    final bool isSelected = _isChipSelected(percent);
    final String label = _getChipLabel(percent);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: isInteractable ? () => _onChipTap(percent) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          height: widget.height,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.lightPrimary
                : AppColors.lightPrimary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.lightPrimary
                  : AppColors.lightPrimary.withValues(alpha: 0.15),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isSelected ? AppColors.white : AppColors.lightPrimary,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
