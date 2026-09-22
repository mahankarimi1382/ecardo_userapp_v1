import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/notification_history_service.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';

/// Collapsing dashboard greeting header.
/// maxExtent ~120 (avatar + greeting), minExtent ~60 (name strip).
class DashboardSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  DashboardSliverHeaderDelegate({required this.topInset});

  final double topInset;

  @override
  double get maxExtent => topInset + 120;

  @override
  double get minExtent => topInset + 56;

  @override
  bool shouldRebuild(covariant DashboardSliverHeaderDelegate oldDelegate) {
    return oldDelegate.topInset != topInset;
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'صبح بخیر';
    if (h >= 12 && h < 17) return 'عصر بخیر';
    if (h >= 17 && h < 22) return 'شب بخیر';
    return 'خوش برگشتی';
  }

  String _firstName(HomeController home) {
    final full = home.dashboardModel.value.data?.user?.userName ?? '';
    if (full.trim().isEmpty) return 'کاربر';
    return full.trim().split(RegExp(r'\s+')).first;
  }

  int _unread(HomeController home) {
    final server =
        home.dashboardModel.value.data?.info?.unreadNotificationsCount ?? 0;
    final local = Get.isRegistered<NotificationHistoryService>()
        ? Get.find<NotificationHistoryService>().unreadCount
        : 0;
    return server + local;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = (maxExtent - minExtent).clamp(1.0, 999.0);
    final t = (1.0 - (shrinkOffset / range)).clamp(0.0, 1.0);
    // Ease-out cubic feel for opacity/scale.
    final eased = Curves.easeOutCubic.transform(t);

    return Obx(() {
    final home = Get.find<HomeController>();
    final name = _firstName(home);
    final unread = _unread(home);
    final avatarPath = home.dashboardModel.value.data?.user?.avatarPath;
    final initial =
        name.isNotEmpty ? String.fromCharCodes(name.runes.take(1)) : 'ک';

    return Material(
      color: AppColors.lightPrimary,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          top: topInset + 4,
          start: AppSpacing.page,
          end: AppSpacing.page,
          bottom: 8,
        ),
        child: Stack(
          children: [
            // Expanded content
            Opacity(
              opacity: eased,
              child: IgnorePointer(
                ignoring: eased < 0.2,
                child: Row(
                  children: [
                    _Avatar(path: avatarPath, initial: initial, size: 44),
                    const SizedBox(width: AppSpacing.cardGap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_greeting()}، $name',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '👋 خوش برگشتی',
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.75),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _NotifBtn(unread: unread),
                    _SettingsBtn(),
                  ],
                ),
              ),
            ),
            // Collapsed strip
            Opacity(
              opacity: 1.0 - eased,
              child: IgnorePointer(
                ignoring: eased > 0.8,
                child: Align(
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      _NotifBtn(unread: unread),
                      _SettingsBtn(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    });
  }
}

// Fix: typo Sli‌ver -> need real class name
class _Avatar extends StatelessWidget {
  final String? path;
  final String initial;
  final double size;
  const _Avatar({required this.path, required this.initial, this.size = 44});

  @override
  Widget build(BuildContext context) {
    if ((path ?? '').isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.network(
          path!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fb(),
        ),
      );
    }
    return _fb();
  }

  Widget _fb() {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF3D248F),
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}

class _NotifBtn extends StatelessWidget {
  final int unread;
  const _NotifBtn({required this.unread});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: () => Get.toNamed(BaseRoute.notifications),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(
          unread > 99 ? '99+' : '$unread',
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
        backgroundColor: AppColors.error,
        child: const Icon(
          Icons.notifications_none_rounded,
          color: AppColors.white,
          size: 22,
        ),
      ),
    );
  }
}

class _SettingsBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: () => Get.toNamed(BaseRoute.profileSettings),
      icon: const Icon(Icons.settings_outlined, color: AppColors.white, size: 22),
    );
  }
}
