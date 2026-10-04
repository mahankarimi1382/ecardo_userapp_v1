import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/widgets/multi_currency_flip_card.dart';

/// Smooth horizontal PageView carousel with 3D scaling and parallax depth for multi-currency cards.
class WalletCardCarousel extends StatefulWidget {
  final List<Wallets> wallets;
  final int initialPage;
  final ValueChanged<int>? onPageChanged;
  final Function(Wallets wallet)? onCardTap;

  const WalletCardCarousel({
    super.key,
    required this.wallets,
    this.initialPage = 0,
    this.onPageChanged,
    this.onCardTap,
  });

  @override
  State<WalletCardCarousel> createState() => _WalletCardCarouselState();
}

class _WalletCardCarouselState extends State<WalletCardCarousel> {
  late final PageController _pageController;
  double _currentPage = 0.0;

  /// Fraction of the screen one card slot occupies. The card is sized from
  /// the same value so it fills its slot exactly.
  static const double _kViewportFraction = 0.88;

  @override
  void initState() {
    super.initState();
    final safeInitial = widget.initialPage.clamp(0, max(0, widget.wallets.length - 1)).toInt();
    _currentPage = safeInitial.toDouble();
    _pageController = PageController(
      viewportFraction: _kViewportFraction,
      initialPage: safeInitial,
    )..addListener(() {
        if (mounted) {
          setState(() {
            _currentPage = _pageController.page ?? 0.0;
          });
        }
      });
  }

  @override
  void didUpdateWidget(WalletCardCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPage != oldWidget.initialPage &&
        widget.initialPage != _currentPage.round() &&
        _pageController.hasClients) {
      final safeTarget = widget.initialPage.clamp(0, max(0, widget.wallets.length - 1)).toInt();
      _pageController.animateToPage(
        safeTarget,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.wallets.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.wallets.length == 1) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 0),
            child: MultiCurrencyFlipCard(
              wallet: widget.wallets.first,
              width: double.infinity,
              height: 196,
              onTap: widget.onCardTap != null
                  ? () => widget.onCardTap!(widget.wallets.first)
                  : null,
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 204,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.wallets.length,
            onPageChanged: widget.onPageChanged,
            itemBuilder: (context, index) {
              final wallet = widget.wallets[index];
              // Compute scale and translation based on distance from current page
              final difference = (index - _currentPage).abs();
              final scale = (1.0 - (difference * 0.08)).clamp(0.90, 1.0);
              final opacity = (1.0 - (difference * 0.2)).clamp(0.7, 1.0);

              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Center(
                    child: MultiCurrencyFlipCard(
                      wallet: wallet,
                      width: min(MediaQuery.of(context).size.width * _kViewportFraction, 420.0),
                      height: 196,
                      onTap: widget.onCardTap != null
                          ? () => widget.onCardTap!(wallet)
                          : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Dynamic Page Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.wallets.length, (index) {
            final isSelected = (_currentPage.round() == index);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              // Dots are ordered LTR regardless of reading direction, so a
              // directional margin would flip the gap order under RTL for no
              // reason — kept symmetric on purpose.
              width: isSelected ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.lightPrimary
                    : AppColors.lightTextTertiary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
