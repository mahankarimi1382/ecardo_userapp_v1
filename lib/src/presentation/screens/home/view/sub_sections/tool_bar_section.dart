import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/notification_history_service.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';

/// Dashboard greeting header: avatar + time-based hello + notif badge + settings.
class ToolBarSection extends StatefulWidget {
  const ToolBarSection({super.key});

  @override
  State<ToolBarSection> createState() => _ToolBarSectionState();
}

class _ToolBarSectionState extends State<ToolBarSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'صبح بخیر';
    if (h >= 12 && h < 17) return 'عصر بخیر';
    if (h >= 17 && h < 22) return 'شب بخیر';
    return 'خوش برگشتی';
  }

  String _firstName(String? full) {
    if (full == null || full.trim().isEmpty) return 'کاربر';
    return full.trim().split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final info = home.dashboardModel.value.data?.info;
    final user = home.dashboardModel.value.data?.user;
    final serverUnread = info?.unreadNotificationsCount ?? 0;
    final localUnread = Get.isRegistered<NotificationHistoryService>()
        ? Get.find<NotificationHistoryService>().unreadCount
        : 0;
    final unread = serverUnread + localUnread;
    final avatarPath = user?.avatarPath;
    final name = _firstName(user?.userName);
    final initial = name.isNotEmpty ? String.fromCharCodes(name.runes.take(1)) : 'ک';

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => home.openEndDrawer(),
              child: _Avatar(path: avatarPath, initial: initial),
            ),
            const SizedBox(width: AppSpacing.cardGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_greeting()}، $name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '👋 خوش برگشتی',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
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
                ),
              ),
            ),
            IconButton(
              onPressed: () => Get.toNamed(BaseRoute.profileSettings),
              icon: const Icon(Icons.settings_outlined, color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? path;
  final String initial;
  const _Avatar({required this.path, required this.initial});

  @override
  Widget build(BuildContext context) {
    if ((path ?? '').isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.network(
          path!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF3D248F),
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    );
  }
}
