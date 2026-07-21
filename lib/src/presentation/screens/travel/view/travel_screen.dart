import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';

import '../controller/travel_controller.dart';
import '../model/travel_model.dart';
import 'travel_service_screen.dart';
import 'widgets/travel_theme.dart';

class TravelScreen extends StatelessWidget {
  const TravelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<TravelController>()
        ? Get.find<TravelController>()
        : Get.put(TravelController());
    final home = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: TravelTheme.background,
        body: SafeArea(
          child: RefreshIndicator(
            color: TravelTheme.gold,
            onRefresh: controller.loadBootstrap,
            child: Obx(
              () => CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 44),
                    sliver: SliverList.list(
                      children: [
                        _Header(home: home),
                        const SizedBox(height: 24),
                        _TravelHero(controller: controller),
                        const SizedBox(height: 20),
                        _CreditCard(home: home),
                        const SizedBox(height: 18),
                        const _WalletActions(),
                        const SizedBox(height: 28),
                        _PrimaryServices(controller: controller),
                        const SizedBox(height: 24),
                        _Promotion(controller: controller),
                        const SizedBox(height: 30),
                        _RecentSearches(controller: controller),
                        const SizedBox(height: 30),
                        _FeaturedDestinations(controller: controller),
                        if (controller.errorMessage.value.isNotEmpty &&
                            controller.services.isEmpty) ...[
                          const SizedBox(height: 24),
                          _EmptyState(
                            message: controller.errorMessage.value,
                            onRetry: controller.loadBootstrap,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final HomeController? home;

  const _Header({required this.home});

  @override
  Widget build(BuildContext context) {
    final name = home?.userModel.value.data?.fullName;
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: TravelTheme.gold, width: 1.5),
          ),
          child: const Icon(Icons.person_rounded, color: TravelTheme.navy),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'eCardo Travel',
                style: TextStyle(
                  color: TravelTheme.navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (name?.isNotEmpty == true)
                Text(
                  name!,
                  style: const TextStyle(
                    color: TravelTheme.muted,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Get.toNamed(BaseRoute.notifications),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: TravelTheme.navy,
          ),
        ),
      ],
    );
  }
}

class _TravelHero extends StatelessWidget {
  final TravelController controller;

  const _TravelHero({required this.controller});

  @override
  Widget build(BuildContext context) {
    final hero = _firstContent(controller, 'home_hero');
    return Container(
      height: 210,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: TravelTheme.cardRadius,
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [TravelTheme.navy, Color(0xFF334155)],
        ),
        boxShadow: TravelTheme.cardShadow,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hero?.imageUrl.isNotEmpty == true)
            CachedNetworkImage(
              imageUrl: hero!.imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x220F172A), Color(0xE60F172A)],
              ),
            ),
          ),
          Positioned(
            right: 22,
            left: 22,
            bottom: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hero?.title.isNotEmpty == true
                      ? hero!.title
                      : 'تجربه مجلل سفر',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  hero?.subtitle.isNotEmpty == true
                      ? hero!.subtitle
                      : 'پرواز، اقامت و اتصال جهانی در یک تجربه یکپارچه.',
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditCard extends StatelessWidget {
  final HomeController? home;

  const _CreditCard({required this.home});

  @override
  Widget build(BuildContext context) {
    final wallet =
        home?.walletsList.firstWhereOrNull((item) => item.isDefault == true) ??
        home?.walletsList.firstOrNull;
    final balance =
        wallet?.formattedBalance ?? home?.userModel.value.data?.balance ?? '—';
    final symbol = wallet?.symbol ?? '';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: TravelTheme.cardRadius,
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [TravelTheme.navy, Color(0xFF303B54)],
        ),
        boxShadow: TravelTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.contactless_rounded,
                color: TravelTheme.gold,
                size: 30,
              ),
              Spacer(),
              Text(
                'TRAVEL CREDIT BALANCE',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: TravelTheme.goldSoft,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '$balance $symbol',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Text(
                'ECARDO TRAVEL',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              _CardServiceIcon(icon: Icons.flight_rounded),
              SizedBox(width: 6),
              _CardServiceIcon(icon: Icons.sim_card_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardServiceIcon extends StatelessWidget {
  final IconData icon;

  const _CardServiceIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: TravelTheme.gold.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: TravelTheme.gold.withValues(alpha: 0.55)),
      ),
      child: Icon(icon, size: 19, color: TravelTheme.goldSoft),
    );
  }
}

class _WalletActions extends StatelessWidget {
  const _WalletActions();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: TravelTheme.cardRadius,
        boxShadow: TravelTheme.cardShadow,
      ),
      child: Row(
        children: [
          _WalletAction(
            label: 'افزایش اعتبار',
            icon: Icons.add_rounded,
            selected: true,
            onTap: () => Get.toNamed(BaseRoute.addMoney),
          ),
          _WalletAction(
            label: 'انتقال',
            icon: Icons.swap_horiz_rounded,
            onTap: () => Get.toNamed(BaseRoute.transfer),
          ),
          _WalletAction(
            label: 'تاریخچه',
            icon: Icons.history_rounded,
            onTap: () => Get.toNamed(BaseRoute.transactions),
          ),
        ],
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _WalletAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: TravelTheme.pillRadius,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected ? TravelTheme.goldSoft : TravelTheme.field,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: TravelTheme.navy),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: TravelTheme.text,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryServices extends StatelessWidget {
  final TravelController controller;

  const _PrimaryServices({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isBootstrapLoading.value && controller.services.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: CircularProgressIndicator(color: TravelTheme.gold),
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: controller.services.map((service) {
        final width = (MediaQuery.sizeOf(context).width - 52) / 2;
        return SizedBox(
          width: width,
          child: Material(
            color: service.key == 'flight'
                ? TravelTheme.navy
                : TravelTheme.field,
            borderRadius: TravelTheme.pillRadius,
            child: InkWell(
              borderRadius: TravelTheme.pillRadius,
              onTap: () => Get.to(() => TravelServiceScreen(service: service)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      service.icon,
                      color: service.key == 'flight'
                          ? Colors.white
                          : TravelTheme.navy,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        service.displayName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: service.key == 'flight'
                              ? Colors.white
                              : TravelTheme.navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Promotion extends StatelessWidget {
  final TravelController controller;

  const _Promotion({required this.controller});

  @override
  Widget build(BuildContext context) {
    final promotion = _firstContent(controller, 'promotions');
    if (promotion == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TravelTheme.goldSoft,
        borderRadius: TravelTheme.cardRadius,
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: TravelTheme.gold.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.flight_takeoff_rounded, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (promotion.badge.isNotEmpty)
                  Text(
                    promotion.badge,
                    style: const TextStyle(
                      color: Color(0xFF745C00),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                Text(
                  promotion.title,
                  style: const TextStyle(
                    color: TravelTheme.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (promotion.subtitle.isNotEmpty)
                  Text(
                    promotion.subtitle,
                    style: const TextStyle(
                      color: Color(0xFF745C00),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  final TravelController controller;

  const _RecentSearches({required this.controller});

  @override
  Widget build(BuildContext context) {
    final items = _allContent(controller, 'recent_searches');
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'جستجوهای اخیر'),
        const SizedBox(height: 14),
        SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final item = items[index];
              return Container(
                width: 170,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: TravelTheme.cardRadius,
                  border: Border.all(color: TravelTheme.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.travel_explore_rounded,
                          color: TravelTheme.gold,
                          size: 20,
                        ),
                        const Spacer(),
                        if (item.badge.isNotEmpty)
                          Text(
                            item.badge,
                            style: const TextStyle(
                              color: Color(0xFF745C00),
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      item.title,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        color: TravelTheme.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: TravelTheme.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeaturedDestinations extends StatelessWidget {
  final TravelController controller;

  const _FeaturedDestinations({required this.controller});

  @override
  Widget build(BuildContext context) {
    final items = _allContent(controller, 'featured_destinations');
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'پیشنهادهای ویژه'),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          itemBuilder: (_, index) => _DestinationCard(item: items[index]),
        ),
      ],
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final TravelContentItem item;

  const _DestinationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: TravelTheme.cardRadius,
        gradient: const LinearGradient(
          colors: [TravelTheme.navySoft, TravelTheme.navy],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (item.imageUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xD90F172A)],
              ),
            ),
          ),
          Positioned(
            right: 14,
            left: 14,
            bottom: 13,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (item.subtitle.isNotEmpty)
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: TravelTheme.navy,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _EmptyState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: TravelTheme.cardRadius,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.travel_explore_rounded,
            color: TravelTheme.gold,
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          TextButton(onPressed: onRetry, child: const Text('تلاش دوباره')),
        ],
      ),
    );
  }
}

TravelContentItem? _firstContent(TravelController controller, String key) {
  final items = _allContent(controller, key);
  return items.firstOrNull;
}

List<TravelContentItem> _allContent(TravelController controller, String key) {
  return controller.services.expand((service) => service.content(key)).toList();
}
