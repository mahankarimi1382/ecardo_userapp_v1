import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_glass_card.dart';

/// Model representing a quick action button underneath the balance hero.
class EcardoHeroAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? accentColor;

  const EcardoHeroAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.accentColor,
  });
}

/// Signature flagship balance hero display widget for eCardo.
///
/// Features:
/// - Prominent neo-fintech typography with split integer and fractional units.
/// - Privacy mode with smooth eye-toggle crossfade and micro-haptic feedback.
/// - 24h PnL pill badge with directional trend arrow and glow container.
/// - Interactive currency switcher pill supporting multi-currency accounts.
/// - Optional secondary fiat equivalent subtitle and quick action buttons row.
/// - Ambient light-field glow reflecting portfolio performance.
class EcardoBalanceHero extends StatefulWidget {
  final double amount;
  final String currencyCode;
  final String? currencySymbol;
  final List<String> availableCurrencies;
  final ValueChanged<String>? onCurrencyChanged;
  final double? pnlPercentage;
  final double? pnlAmount;
  final String pnlPeriodLabel;
  final String? secondaryEquivalent;
  final String accountLabel;
  final bool? isObscured;
  final ValueChanged<bool>? onTogglePrivacy;
  final int? decimalDigits;
  final bool showQuickActions;
  final List<EcardoHeroAction>? actions;
  final VoidCallback? onTapBalance;
  final EdgeInsetsGeometry padding;

  const EcardoBalanceHero({
    super.key,
    required this.amount,
    this.currencyCode = 'USD',
    this.currencySymbol,
    this.availableCurrencies = const ['USD', 'USDT', 'EUR', 'IRT'],
    this.onCurrencyChanged,
    this.pnlPercentage,
    this.pnlAmount,
    this.pnlPeriodLabel = '24h',
    this.secondaryEquivalent,
    this.accountLabel = 'Total Balance',
    this.isObscured,
    this.onTogglePrivacy,
    this.decimalDigits,
    this.showQuickActions = false,
    this.actions,
    this.onTapBalance,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.xl,
    ),
  });

  @override
  State<EcardoBalanceHero> createState() => _EcardoBalanceHeroState();
}

class _EcardoBalanceHeroState extends State<EcardoBalanceHero> {
  late bool _internalObscured;

  @override
  void initState() {
    super.initState();
    _internalObscured = widget.isObscured ?? false;
  }

  @override
  void didUpdateWidget(EcardoBalanceHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isObscured != null && widget.isObscured != _internalObscured) {
      _internalObscured = widget.isObscured!;
    }
  }

  bool get _isObscured => widget.isObscured ?? _internalObscured;

  void _togglePrivacy() {
    HapticFeedback.lightImpact();
    final nextState = !_isObscured;
    if (widget.onTogglePrivacy != null) {
      widget.onTogglePrivacy!(nextState);
    } else {
      setState(() => _internalObscured = nextState);
    }
  }

  int get _resolvedDecimals {
    if (widget.decimalDigits != null) return widget.decimalDigits!;
    if (widget.currencyCode.toUpperCase() == 'IRT' ||
        widget.currencyCode.toUpperCase() == 'IRR') {
      return 0;
    }
    return 2;
  }

  String get _resolvedSymbol {
    if (widget.currencySymbol != null) return widget.currencySymbol!;
    return switch (widget.currencyCode.toUpperCase()) {
      'USD' => r'$',
      'EUR' => '€',
      'GBP' => '£',
      'USDT' => '₮',
      'IRT' => 'تومان',
      _ => widget.currencyCode,
    };
  }

  void _openCurrencyPicker(BuildContext context) {
    if (widget.availableCurrencies.length <= 1) return;
    HapticFeedback.selectionClick();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(sheetContext).bottom + AppSpacing.md,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.md,
          ),
          child: EcardoGlassCard(
            variant: EcardoGlassVariant.frosted,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBorder : AppColors.lightDivider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Select Currency',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...widget.availableCurrencies.map((code) {
                  final isSelected = code.toUpperCase() == widget.currencyCode.toUpperCase();
                  return InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(sheetContext);
                      if (widget.onCurrencyChanged != null) {
                        widget.onCurrencyChanged!(code);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                ? AppColors.mainSoftBlue.withValues(alpha: 0.15)
                                : AppColors.mainSoftBlue.withValues(alpha: 0.20))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: isSelected
                            ? Border.all(
                                color: AppColors.mainSoftBlue.withValues(alpha: 0.5),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? AppColors.darkSurfaceVariant
                                  : AppColors.lightSecondaryContainer,
                            ),
                            child: Text(
                              _currencyIconOrSymbol(code),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              code,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: AppColors.mainSoftBlue,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  String _currencyIconOrSymbol(String code) {
    return switch (code.toUpperCase()) {
      'USD' => r'$',
      'EUR' => '€',
      'GBP' => '£',
      'USDT' => '₮',
      'IRT' => 'ت',
      _ => code.isNotEmpty ? code[0] : '¤',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isPnlPositive = (widget.pnlPercentage ?? 0) >= 0;
    final pnlColor = isPnlPositive ? AppColors.success : AppColors.error;

    return Padding(
      padding: widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Top metadata row: Account Label + Currency Switcher + Privacy Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.accountLabel,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _buildCurrencyPill(context, isDark),
              const SizedBox(width: AppSpacing.xs),
              _buildPrivacyButton(isDark),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 2. Hero Amount Section with ambient performance glow
          GestureDetector(
            onTap: widget.onTapBalance ?? _togglePrivacy,
            behavior: HitTestBehavior.opaque,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.96, end: 1.0).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _isObscured
                  ? _buildObscuredBalance(isDark)
                  : _buildVisibleBalance(isDark),
            ),
          ),

          // 3. Secondary Fiat Equivalent (if provided)
          if (widget.secondaryEquivalent != null && !_isObscured) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.secondaryEquivalent!,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          // 4. 24h PnL badge
          if (widget.pnlPercentage != null) ...[
            const SizedBox(height: AppSpacing.md),
            _buildPnlBadge(isDark, isPnlPositive, pnlColor),
          ],

          // 5. Quick Actions Row (optional)
          if (widget.showQuickActions) ...[
            const SizedBox(height: AppSpacing.xl),
            _buildQuickActions(context, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildPrivacyButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        onTap: _togglePrivacy,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Icon(
            _isObscured
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            size: 16,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyPill(BuildContext context, bool isDark) {
    final canSwitch = widget.availableCurrencies.length > 1;
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant.withValues(alpha: 0.6)
            : AppColors.lightSecondaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightOutlineVariant,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.currencyCode,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          if (canSwitch) ...[
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ],
        ],
      ),
    );

    if (!canSwitch) return pill;

    return GestureDetector(
      onTap: () => _openCurrencyPicker(context),
      behavior: HitTestBehavior.opaque,
      child: pill,
    );
  }

  Widget _buildVisibleBalance(bool isDark) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: _resolvedDecimals,
    );
    final formatted = formatter.format(widget.amount).trim();

    String integerPart = formatted;
    String decimalPart = '';

    if (_resolvedDecimals > 0 && formatted.contains('.')) {
      final parts = formatted.split('.');
      integerPart = parts[0];
      decimalPart = '.${parts[1]}';
    }

    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    final isRtlCurrency = widget.currencyCode.toUpperCase() == 'IRT';

    return KeyedSubtree(
      key: const ValueKey('visible_balance'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          if (!isRtlCurrency) ...[
            Text(
              _resolvedSymbol,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.mainSoftBlue
                    : AppColors.mutedBlue,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            integerPart,
            style: AppTextStyles.displayMedium.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: textColor,
            ),
          ),
          if (decimalPart.isNotEmpty)
            Text(
              decimalPart,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: textColor.withValues(alpha: 0.55),
              ),
            ),
          if (isRtlCurrency) ...[
            const SizedBox(width: 6),
            Text(
              _resolvedSymbol,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildObscuredBalance(bool isDark) {
    return KeyedSubtree(
      key: const ValueKey('obscured_balance'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            6,
            (index) => Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPnlBadge(bool isDark, bool isPnlPositive, Color pnlColor) {
    final formattedPnl = widget.pnlPercentage!.abs().toStringAsFixed(2);
    final sign = isPnlPositive ? '+' : '-';
    final arrowIcon = isPnlPositive
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: pnlColor.withValues(alpha: isDark ? 0.15 : 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: pnlColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            arrowIcon,
            size: 15,
            color: pnlColor,
          ),
          const SizedBox(width: 4),
          Text(
            '$sign$formattedPnl%',
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: pnlColor,
            ),
          ),
          if (widget.pnlAmount != null) ...[
            const SizedBox(width: 4),
            Text(
              '($sign${NumberFormat.compact().format(widget.pnlAmount!.abs())})',
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: pnlColor.withValues(alpha: 0.85),
              ),
            ),
          ],
          const SizedBox(width: 4),
          Text(
            widget.pnlPeriodLabel,
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    final actionsList = widget.actions ?? _defaultQuickActions(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: actionsList.map((action) {
        return _QuickActionButton(
          action: action,
          isDark: isDark,
        );
      }).toList(),
    );
  }

  List<EcardoHeroAction> _defaultQuickActions(BuildContext context) {
    return [
      EcardoHeroAction(
        label: 'Add Money',
        icon: Icons.add_rounded,
        onTap: () {},
      ),
      EcardoHeroAction(
        label: 'Send',
        icon: Icons.arrow_outward_rounded,
        onTap: () {},
      ),
      EcardoHeroAction(
        label: 'Exchange',
        icon: Icons.swap_horiz_rounded,
        onTap: () {},
      ),
      EcardoHeroAction(
        label: 'More',
        icon: Icons.more_horiz_rounded,
        onTap: () {},
      ),
    ];
  }
}

class _QuickActionButton extends StatefulWidget {
  final EcardoHeroAction action;
  final bool isDark;

  const _QuickActionButton({
    required this.action,
    required this.isDark,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
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
    final accent = widget.action.accentColor ??
        (widget.isDark ? AppColors.mainSoftBlue : AppColors.deepBlack);

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _controller.forward();
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.action.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isDark
                    ? AppColors.darkCard
                    : AppColors.white,
                border: Border.all(
                  color: widget.isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: widget.isDark ? 0.25 : 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.action.icon,
                size: 22,
                color: accent,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.action.label,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: widget.isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
