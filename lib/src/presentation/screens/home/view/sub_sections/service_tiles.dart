import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/model/kyc_level_model.dart';

/// v1.0.45 (SERVICES HUB): shared tile engine for the dashboard service
/// sections (financial services, travel services, business services).
///
/// Every tile is in one of four states —
///   available   → navigates to the module
///   kycLocked   → greyed with a lock badge; tapping opens the
///                 UpgradeRequiredScreen which resolves the required level
///                 from the tiered KYC system (server feature keys)
///   comingSoon  → greyed; tapping shows a localized "coming soon" toast
///                 (module disabled by addon / admin toggle on this
///                 deployment)
///   notBuilt    → greyed with a lock badge; tapping shows a localized
///                 "not available in your region yet — raise your KYC
///                 level" toast (module not built yet)
///
/// Gating truth stays server-side (the 403 KYC contract enforces it); the
/// grid is the user-facing mirror of it.
///
/// v1.0.43 lesson (CRITICAL Obx fix): Rx reads must happen synchronously
/// INSIDE the calling section's Obx scope. The widgets below are pure —
/// they take already-resolved tiles and register no observables.
enum TileState { available, kycLocked, comingSoon, notBuilt }

class ServiceTile {
  final String title;
  final String? icon;
  final IconData? iconData;
  final String route;
  final String? feature;
  final bool available;
  final Map<String, dynamic> Function()? argumentsBuilder;

  /// v1.0.46: direct widget navigation for modules whose entry screens are
  /// not routed (travel search screens open via Get.to inside the module).
  /// When set, the tap pushes this widget instead of [route].
  final Widget Function()? pageBuilder;
  final VoidCallback? beforeNavigate;

  const ServiceTile({
    required this.title,
    this.icon,
    this.iconData,
    required this.route,
    this.feature,
    this.available = true,
    this.argumentsBuilder,
    this.pageBuilder,
    this.beforeNavigate,
  });
}

class ResolvedTile {
  final ServiceTile tile;
  final TileState state;

  const ResolvedTile(this.tile, this.state);
}

/// Tiered feature check — fail-open when the KYC badge is not ready yet
/// (fresh navigation frame); the server 403 contract is the enforcement
/// anyway.
bool hasKycFeature(String? feature, KycBadge? badge) {
  if (feature == null) return true;
  if (badge == null) return true;
  return badge.hasFeature(feature);
}

ResolvedTile resolveTile(ServiceTile tile, KycBadge? badge) {
  if (!tile.available) return ResolvedTile(tile, TileState.comingSoon);
  if (!hasKycFeature(tile.feature, badge)) {
    return ResolvedTile(tile, TileState.kycLocked);
  }
  return ResolvedTile(tile, TileState.available);
}

/// Reads the current KYC badge synchronously — call from INSIDE an Obx
/// scope so the badge observable gets registered there.
KycBadge? currentKycBadge() {
  if (!Get.isRegistered<KycLevelController>()) return null;
  return Get.find<KycLevelController>().badge.value;
}

void onTileTap(BuildContext context, ResolvedTile resolved) {
  final localization = AppLocalizations.of(context)!;
  switch (resolved.state) {
    case TileState.available:
      final tile = resolved.tile;
      if (tile.pageBuilder != null) {
        tile.beforeNavigate?.call();
        Get.to(
          tile.pageBuilder!(),
          arguments: tile.argumentsBuilder?.call(),
        );
      } else if (tile.route.isNotEmpty) {
        Get.toNamed(
          tile.route,
          arguments: tile.argumentsBuilder?.call(),
        );
      }
      return;
    case TileState.kycLocked:
      Get.toNamed(
        BaseRoute.upgradeRequired,
        arguments: <String, dynamic>{'feature': resolved.tile.feature},
      );
      return;
    case TileState.comingSoon:
      ToastHelper().showErrorToast(localization.commonComingSoon);
      return;
    case TileState.notBuilt:
      ToastHelper().showErrorToast(localization.serviceNotAvailableYet);
      return;
  }
}

/// Paged 4-column service grid with page dots — the exact rendering the
/// dashboard "other services" card has always used, extracted so the
/// financial / travel / business cards all look identical.
class PagedServiceTilesGrid extends StatefulWidget {
  final List<ResolvedTile> tiles;
  final int itemsPerPage;

  const PagedServiceTilesGrid({
    super.key,
    required this.tiles,
    this.itemsPerPage = 8,
  });

  @override
  State<PagedServiceTilesGrid> createState() => _PagedServiceTilesGridState();
}

class _PagedServiceTilesGridState extends State<PagedServiceTilesGrid> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serviceCount = widget.tiles.length;
    final int pageCount = (serviceCount / widget.itemsPerPage).ceil();

    final pages = List.generate(pageCount, (index) {
      final start = index * widget.itemsPerPage;
      final end = (start + widget.itemsPerPage < serviceCount)
          ? start + widget.itemsPerPage
          : serviceCount;
      return widget.tiles.sublist(start, end);
    });
    if (pages.isEmpty) return const SizedBox.shrink();

    final rows = ((pages.first.length) / 4).ceil();
    final double dynamicHeight = rows * 90.0;

    return Column(
      children: [
        SizedBox(
          height: dynamicHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, pageIndex) {
              final pageItems = pages[pageIndex];
              return GridView.builder(
                itemCount: pageItems.length,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  return ServiceTileView(resolved: pageItems[index]);
                },
              );
            },
          ),
        ),
        if (serviceCount > widget.itemsPerPage) ...[
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                height: 6,
                width: _currentPage == index ? 16 : 6,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.lightPrimary
                      : AppColors.lightPrimary.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Single service tile — icon, lock badge, label, greyed when disabled.
class ServiceTileView extends StatelessWidget {
  final ResolvedTile resolved;

  const ServiceTileView({super.key, required this.resolved});

  @override
  Widget build(BuildContext context) {
    final tile = resolved.tile;
    final disabled = resolved.state != TileState.available;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onTileTap(context, resolved),
      child: Opacity(
        opacity: disabled ? 0.55 : 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                if (tile.iconData is IconData)
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.lightPrimary.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      tile.iconData as IconData,
                      color: AppColors.lightPrimary,
                      size: 22,
                    ),
                  )
                else
                  Image.asset(
                    tile.icon as String,
                    width: 35,
                    color: disabled
                        ? AppColors.black.withValues(alpha: 0.30)
                        : null,
                  ),
                if (resolved.state == TileState.kycLocked ||
                    resolved.state == TileState.notBuilt)
                  PositionedDirectional(
                    top: -4,
                    end: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.black.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 9,
                        color: AppColors.lightTextTertiary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tile.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF2D2D2D).withValues(
                  alpha: disabled ? 0.35 : 0.60,
                ),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
