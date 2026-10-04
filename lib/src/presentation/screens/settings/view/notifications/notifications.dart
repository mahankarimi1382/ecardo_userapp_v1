import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/app_badge_service.dart';
import 'package:ecardo_user/src/common/services/app_update_controller.dart';
import 'package:ecardo_user/src/common/services/notification_history_service.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/responsive.dart';
import 'package:ecardo_user/src/helper/jalali_date_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/notification_controller.dart';
import 'package:ecardo_user/src/presentation/screens/settings/model/notifications_model.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/settings_screen.dart';
import 'package:ecardo_user/src/presentation/widgets/notification_dynamic_icon.dart';

enum _NotifFilter { all, unread, financial, system }

enum _DateGroup { today, yesterday, thisWeek, older }

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>
    with WidgetsBindingObserver {
  final NotificationController controller = Get.find();
  late ScrollController _scrollController;
  _NotifFilter _filter = _NotifFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    loadData();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        controller.hasMorePages.value &&
        !controller.isPageLoading.value) {
      controller.loadMoreNotifications();
    }
  }

  Future<void> loadData() async {
    controller.isLoading.value = true;
    await controller.fetchNotifications();
    controller.isLoading.value = false;
  }

  Future<void> refreshData() async {
    controller.isLoading.value = true;
    await controller.fetchNotifications();
    controller.isLoading.value = false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  _DateGroup _classifyDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diffDays = today.difference(target).inDays;

    if (diffDays == 0) return _DateGroup.today;
    if (diffDays == 1) return _DateGroup.yesterday;
    if (diffDays < 7) return _DateGroup.thisWeek;
    return _DateGroup.older;
  }

  String _dateGroupLabel(BuildContext context, _DateGroup group) {
    switch (group) {
      case _DateGroup.today:
        return l10nPick(
          context,
          en: 'Today',
          fa: 'امروز',
          ar: 'اليوم',
          tr: 'Bugün',
          ru: 'Сегодня',
          zh: '今天',
        );
      case _DateGroup.yesterday:
        return l10nPick(
          context,
          en: 'Yesterday',
          fa: 'دیروز',
          ar: 'أمس',
          tr: 'Dün',
          ru: 'Вчера',
          zh: '昨天',
        );
      case _DateGroup.thisWeek:
        return l10nPick(
          context,
          en: 'Earlier this week',
          fa: 'اوایل این هفته',
          ar: 'خلال هذا الأسبوع',
          tr: 'Bu hafta',
          ru: 'На этой неделе',
          zh: '本周更早',
        );
      case _DateGroup.older:
        return l10nPick(
          context,
          en: 'Older',
          fa: 'پیشین',
          ar: 'أقدم',
          tr: 'Daha eski',
          ru: 'Ранее',
          zh: '较早前',
        );
    }
  }

  String _relativeTime(BuildContext context, DateTime at) {
    final d = DateTime.now().difference(at);
    if (d.inMinutes < 1) {
      return l10nPick(
        context,
        en: 'Just now',
        fa: 'همین الان',
        ar: 'الآن',
        tr: 'Az önce',
        ru: 'Только что',
        zh: '刚刚',
      );
    }
    if (d.inMinutes < 60) {
      return l10nPick(
        context,
        en: '${d.inMinutes}m ago',
        fa: '${d.inMinutes} دقیقه پیش',
        ar: 'منذ ${d.inMinutes} دقيقة',
        tr: '${d.inMinutes} dk önce',
        ru: '${d.inMinutes} мин назад',
        zh: '${d.inMinutes}分钟前',
      );
    }
    if (d.inHours < 24) {
      return l10nPick(
        context,
        en: '${d.inHours}h ago',
        fa: '${d.inHours} ساعت پیش',
        ar: 'منذ ${d.inHours} ساعة',
        tr: '${d.inHours} sa önce',
        ru: '${d.inHours} ч назад',
        zh: '${d.inHours}小时前',
      );
    }
    if (d.inDays < 7) {
      return l10nPick(
        context,
        en: '${d.inDays}d ago',
        fa: '${d.inDays} روز پیش',
        ar: 'منذ ${d.inDays} يوم',
        tr: '${d.inDays} gün önce',
        ru: '${d.inDays} дн назад',
        zh: '${d.inDays}天前',
      );
    }
    return '${at.year}/${at.month}/${at.day}';
  }

  IconData _typeIcon(String type) => NotificationRouter.typeIcon(type);

  Widget _chevronIcon(BuildContext context, bool isDark) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Icon(
      isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
      size: 20,
      color: SettingsIconTokens.chevronColor(isDark: isDark),
    );
  }

  void _handleNotificationTap(String title, String message, String type,
      {String? link, String? payload}) {
    HapticFeedback.lightImpact();
    NotificationRouter.route(
      context,
      title: title,
      message: message,
      type: type,
      link: link,
      payload: payload,
    );
  }

  Future<void> _markAllAsRead(NotificationHistoryService? history) async {
    HapticFeedback.mediumImpact();
    final toastMsg = l10nPick(
      context,
      en: 'All notifications marked as read',
      fa: 'همه اعلان‌ها به عنوان خوانده‌شده علامت‌گذاری شدند',
    );
    await controller.markAsReadNotification();
    await history?.markAllRead();
    if (Get.isRegistered<AppBadgeService>()) {
      await Get.find<AppBadgeService>().clear();
    }
    ToastHelper().showSuccessToast(toastMsg);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final pad = Responsive.pagePadding(context);
    final history = Get.isRegistered<NotificationHistoryService>()
        ? Get.find<NotificationHistoryService>()
        : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: AppSpacing.cardGap),
              CommonAppBar(
                title: localization.notificationsScreenTitle,
                rightSideWidget: Padding(
                  padding: EdgeInsetsDirectional.only(end: pad),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        side: BorderSide(
                          color: (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                              .withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    onPressed: () => _markAllAsRead(history),
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: Text(
                      localization.notificationsMarkAllReadButton,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              // Category filter pills
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  children: [
                    _chip(
                      l10nPick(context, en: 'All', fa: 'همه', ar: 'الكل', tr: 'Tümü', ru: 'Все', zh: '全部'),
                      _NotifFilter.all,
                      isDark,
                    ),
                    _chip(
                      l10nPick(context, en: 'Unread', fa: 'خوانده‌نشده', ar: 'غير مقروءة', tr: 'Okunmamış', ru: 'Непрочитанные', zh: '未读'),
                      _NotifFilter.unread,
                      isDark,
                    ),
                    _chip(
                      l10nPick(context, en: 'Financial', fa: 'مالی', ar: 'مالي', tr: 'Finansal', ru: 'Финансовые', zh: '财务'),
                      _NotifFilter.financial,
                      isDark,
                    ),
                    _chip(
                      l10nPick(context, en: 'System', fa: 'سیستمی', ar: 'النظام', tr: 'Sistem', ru: 'Системные', zh: '系统'),
                      _NotifFilter.system,
                      isDark,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Expanded(
                child: RefreshIndicator(
                  color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                  onRefresh: refreshData,
                  child: Obx(() {
                    final localItems = history?.items.toList() ?? const [];
                    final server = controller
                            .notificationModel.value.data?.notifications ??
                        const [];

                    if (controller.isLoading.value &&
                        server.isEmpty &&
                        localItems.isEmpty) {
                      return _buildLoadingSkeleton(isDark);
                    }

                    final filteredLocal = localItems.where((e) {
                      switch (_filter) {
                        case _NotifFilter.unread:
                          return !e.read;
                        case _NotifFilter.financial:
                          return e.type == 'financial';
                        case _NotifFilter.system:
                          return e.type == 'system' || e.type == 'update';
                        case _NotifFilter.all:
                          return true;
                      }
                    }).toList();

                    final filteredServer = server.where((n) {
                      if (_filter == _NotifFilter.unread) {
                        return n.isRead == false;
                      }
                      return true;
                    }).toList();

                    final showServer = _filter == _NotifFilter.all ||
                        _filter == _NotifFilter.unread;

                    if (filteredLocal.isEmpty &&
                        (!showServer || filteredServer.isEmpty)) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: EcardoEmptyState(
                              animateGlow: false,
                              iconData: Icons.notifications_none_rounded,
                              title: l10nPick(
                                context,
                                en: 'No notifications yet',
                                fa: 'هنوز اعلانی نداری',
                                ar: 'لا توجد إشعارات بعد',
                                tr: 'Henüz bildirim yok',
                                ru: 'Пока нет уведомлений',
                                zh: '暂无通知',
                              ),
                              description: l10nPick(
                                context,
                                en: 'Important financial updates and system notices will appear here.',
                                fa: 'اعلان‌های مهم مالی و پیام‌های سیستم اینجا نمایش داده می‌شوند.',
                                ar: 'ستظهر الإشعارات المهمة هنا.',
                                tr: 'Önemli bildirimler burada görünecektir.',
                                ru: 'Важные уведомления появятся здесь.',
                                zh: '重要通知将在此显示。',
                              ),
                              primaryActionLabel: l10nPick(
                                context,
                                en: 'Refresh',
                                fa: 'بروزرسانی',
                                ar: 'تحديث',
                                tr: 'Yenile',
                                ru: 'Обновить',
                                zh: '刷新',
                              ),
                              onPrimaryAction: refreshData,
                            ),
                          ),
                        ],
                      );
                    }

                    // Group Server notifications by date
                    final Map<_DateGroup, List<Notificationss>> groupedServer = {};
                    for (final n in filteredServer) {
                      DateTime dt = DateTime.now();
                      try {
                        if (n.createdAt != null) dt = DateTime.parse(n.createdAt!);
                      } catch (_) {}
                      final group = _classifyDate(dt);
                      groupedServer.putIfAbsent(group, () => []).add(n);
                    }

                    return ListView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: pad),
                      children: [
                        // Local/Device notifications section if present
                        if (filteredLocal.isNotEmpty) ...[
                          _buildSectionHeader(
                            context,
                            title: l10nPick(
                              context,
                              en: 'Recent device alerts',
                              fa: 'اعلان‌های اخیر دستگاه',
                              ar: 'تنبيهات الجهاز الأخيرة',
                              zh: '设备即时通知',
                            ),
                            count: filteredLocal.length,
                            isDark: isDark,
                          ),
                          ...filteredLocal.map((item) {
                            return _localTile(item, history, isDark);
                          }),
                        ],

                        // Server notifications grouped chronologically
                        if (showServer && filteredServer.isNotEmpty) ...[
                          for (final group in _DateGroup.values)
                            if (groupedServer[group] != null &&
                                groupedServer[group]!.isNotEmpty) ...[
                              _buildSectionHeader(
                                context,
                                title: _dateGroupLabel(context, group),
                                count: groupedServer[group]!.length,
                                isDark: isDark,
                              ),
                              ...groupedServer[group]!.map((n) {
                                return _serverTile(n, isDark, primaryTextColor);
                              }),
                            ],
                        ],
                        SizedBox(height: AppSpacing.bottomSafe(context, AppSpacing.xxl)),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
          Obx(
            () => Visibility(
              visible: controller.isPageLoading.value ||
                  controller.isNotificationsLoading.value,
              child: const CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: List.generate(
        4,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkPrimaryContainer.withValues(alpha: 0.3)
                      : AppColors.lightPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightWarmGray.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightWarmGray.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required int count,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8, left: 4, right: 4),
      child: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.warmWhite : AppColors.deepBlack,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              '$count',
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, _NotifFilter f, bool isDark) {
    final selected = _filter == f;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filter = f),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        selectedColor: isDark
            ? AppColors.mainSoftBlue.withValues(alpha: 0.25)
            : AppColors.lightPrimary.withValues(alpha: 0.14),
        side: BorderSide(
          color: selected
              ? (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: selected ? 1.2 : 0.8,
        ),
        labelStyle: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w700,
          color: selected
              ? (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
              : (isDark ? AppColors.softGray : AppColors.lightTextSecondary),
        ),
      ),
    );
  }

  Widget _serverTile(
    Notificationss n,
    bool isDark,
    Color primaryTextColor,
  ) {
    final isUnread = n.isRead == false;
    final cardBg = isDark
        ? (isUnread
            ? AppColors.darkPrimaryContainer.withValues(alpha: 0.35)
            : AppColors.darkSurface)
        : (isUnread
            ? AppColors.lightSecondaryContainer.withValues(alpha: 0.45)
            : AppColors.white);

    final borderColor = isUnread
        ? (isDark ? AppColors.mainSoftBlue.withValues(alpha: 0.4) : AppColors.lightPrimary.withValues(alpha: 0.3))
        : (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: borderColor, width: isUnread ? 1.2 : 0.8),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: () {
            _handleNotificationTap(
              n.title ?? '',
              n.message ?? '',
              n.type ?? '',
              link: n.link,
              payload: n.payload,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unread indicator dot on start edge
                if (isUnread)
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsetsDirectional.only(top: 14, end: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),

                // Icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      NotificationDynamicIcon.getNotificationIcon(n.type),
                      errorBuilder: (_, _, _) => Icon(
                        Icons.notifications_none,
                        color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Title & message
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.title ?? n.message ?? '',
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                      if ((n.message ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            n.message!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark ? AppColors.softGray : AppColors.lightTextSecondary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        JalaliDateHelper.format(n.createdAt),
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          color: isDark ? AppColors.softGray.withValues(alpha: 0.7) : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _chevronIcon(context, isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _localTile(
    NotificationHistoryItem item,
    NotificationHistoryService? history,
    bool isDark,
  ) {
    final cardBg = isDark
        ? (!item.read
            ? AppColors.darkPrimaryContainer.withValues(alpha: 0.35)
            : AppColors.darkSurface)
        : (!item.read
            ? AppColors.lightSecondaryContainer.withValues(alpha: 0.45)
            : AppColors.white);

    final borderColor = !item.read
        ? (isDark ? AppColors.mainSoftBlue.withValues(alpha: 0.4) : AppColors.lightPrimary.withValues(alpha: 0.3))
        : (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: borderColor, width: !item.read ? 1.2 : 0.8),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: () async {
            await history?.markRead(item.id);
            if (Get.isRegistered<AppBadgeService>() && history != null) {
              await Get.find<AppBadgeService>().update(history.unreadCount);
            }
            // NOTIF-LINK: local history items carry the FCM payload — route
            // through it instead of discarding it.
            _handleNotificationTap(item.title, item.body, item.type,
                payload: item.payload);
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!item.read)
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsetsDirectional.only(top: 14, end: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    _typeIcon(item.type),
                    color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: !item.read ? FontWeight.w800 : FontWeight.w600,
                          color: isDark ? AppColors.warmWhite : AppColors.deepBlack,
                        ),
                      ),
                      if (item.body.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            item.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark ? AppColors.softGray : AppColors.lightTextSecondary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        _relativeTime(context, item.at),
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          color: isDark ? AppColors.softGray.withValues(alpha: 0.7) : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _chevronIcon(context, isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationRouter {
  static String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll('ي', 'ی')
        .replaceAll('ى', 'ی')
        .replaceAll('ك', 'ک')
        .replaceAll('ة', 'ه')
        .replaceAll('‌', ' ')
        .trim();
  }

  static IconData typeIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('ticket') || t.contains('support')) {
      return Icons.support_agent_rounded;
    }
    if (t.contains('virtual_card') || t.contains('card')) {
      return Icons.credit_card_rounded;
    }
    if (t.contains('kyc') || t.contains('verification')) {
      return Icons.verified_user_outlined;
    }
    if (t.contains('financial') ||
        t.contains('deposit') ||
        t.contains('payment') ||
        t.contains('transfer') ||
        t.contains('withdraw')) {
      return Icons.payments_outlined;
    }
    if (t.contains('update') || t.contains('version')) {
      return Icons.system_update_alt_rounded;
    }
    if (t.contains('system')) {
      return Icons.info_outline_rounded;
    }
    return Icons.notifications_none_rounded;
  }

  static void route(
    BuildContext? context, {
    required String title,
    required String message,
    required String type,
    String? link,
    String? payload,
  }) {
    // NOTIF-LINK: honor a server-provided deep link before any keyword
    // guessing. Accepts either a bare route name ('/support_tickets_route')
    // or a full URL (http/https opens via external handling is NOT done
    // here — a URL that isn't an app route falls through to the keyword
    // router below for safety).
    if (link != null && link.isNotEmpty) {
      final isRoute =
          link.startsWith('/') || Get.routeTree.routes.any((r) => r.name == link);
      if (isRoute) {
        Get.toNamed(link);
        return;
      }
    }

    final t = _normalize(title);
    final m = _normalize(message);
    final combined = '$t $m';
    final tp = _normalize(type);

    // NOTIF-LINK: server-supplied payload (e.g. ticket uuid) may carry
    // structured hints; currently passed through to keyword routing when
    // no explicit link exists.

    // 1. Ticket / Support
    final isTicket = tp.contains('ticket') ||
        tp.contains('support') ||
        combined.contains('ticket') ||
        combined.contains('support') ||
        combined.contains(_normalize('تیکت')) ||
        combined.contains(_normalize('پشتیبانی')) ||
        combined.contains(_normalize('دعم')) ||
        combined.contains('destek') ||
        combined.contains('тикет') ||
        combined.contains('поддержк') ||
        combined.contains('工单') ||
        combined.contains('客服');

    if (isTicket) {
      Get.toNamed(BaseRoute.supportTickets);
      return;
    }

    // 2. Virtual Card
    final isVirtualCard = tp.contains('virtual_card') ||
        tp.contains('virtualcard') ||
        tp == 'card' ||
        combined.contains('virtual card') ||
        combined.contains('virtualcard') ||
        combined.contains(_normalize('کارت مجازی')) ||
        combined.contains(_normalize('بطاقة افتراضية')) ||
        combined.contains('sanal kart') ||
        combined.contains('виртуальная карта') ||
        combined.contains('虚拟卡');

    if (isVirtualCard) {
      Get.toNamed(BaseRoute.virtualCard);
      return;
    }

    // 3. KYC / Verification
    final isKyc = tp.contains('kyc') ||
        tp.contains('id_verification') ||
        tp.contains('verification') ||
        combined.contains('kyc') ||
        combined.contains('verification') ||
        combined.contains('verify') ||
        combined.contains('identity') ||
        combined.contains(_normalize('احراز هویت')) ||
        combined.contains(_normalize('مدارک')) ||
        combined.contains(_normalize('شناسایی')) ||
        combined.contains(_normalize('توثيق')) ||
        combined.contains(_normalize('هوية')) ||
        combined.contains('doğrulama') ||
        combined.contains('kimlik') ||
        combined.contains('верификац') ||
        combined.contains('паспорт') ||
        combined.contains('认证') ||
        combined.contains('身份');

    if (isKyc) {
      Get.toNamed(BaseRoute.kycHistory);
      return;
    }

    // 4. Update / Version
    final isUpdate = tp.contains('app_update') ||
        tp == 'update' ||
        tp.contains('version') ||
        combined.contains('app update') ||
        combined.contains('new version') ||
        combined.contains('update available') ||
        combined.contains('upgrade') ||
        combined.contains(_normalize('بروزرسانی')) ||
        combined.contains(_normalize('به‌روزرسانی')) ||
        combined.contains(_normalize('آپدیت')) ||
        combined.contains(_normalize('ارتقا')) ||
        combined.contains(_normalize('نسخه جدید')) ||
        combined.contains(_normalize('نسخه')) ||
        combined.contains(_normalize('تحديث')) ||
        combined.contains(_normalize('إصدار')) ||
        combined.contains('güncelleme') ||
        combined.contains('sürüm') ||
        combined.contains('обновлен') ||
        combined.contains('верси') ||
        combined.contains('更新') ||
        combined.contains('版本') ||
        (combined.contains('update') &&
            !combined.contains('transaction') &&
            !combined.contains('payment') &&
            !combined.contains('deposit') &&
            !combined.contains('transfer'));

    if (isUpdate) {
      if (Get.isRegistered<AppUpdateController>()) {
        Get.find<AppUpdateController>().checkForUpdate(manual: true);
      } else {
        try {
          Get.find<AppUpdateController>().checkForUpdate(manual: true);
        } catch (_) {}
      }
      return;
    }

    // 5. Transfer / Transaction / Payment / Deposit
    final isFinancial = tp.contains('deposit') ||
        tp.contains('transfer') ||
        tp.contains('transaction') ||
        tp.contains('payment') ||
        tp.contains('withdraw') ||
        tp.contains('financial') ||
        tp.contains('cash_in') ||
        tp.contains('cash_out') ||
        tp.contains('receive_money') ||
        tp.contains('request_money') ||
        tp.contains('remittance') ||
        tp.contains('invoice') ||
        combined.contains('transfer') ||
        combined.contains('transaction') ||
        combined.contains('payment') ||
        combined.contains('deposit') ||
        combined.contains('withdraw') ||
        combined.contains('wallet') ||
        combined.contains('remittance') ||
        combined.contains('invoice') ||
        combined.contains('paid') ||
        combined.contains(_normalize('تراکنش')) ||
        combined.contains(_normalize('انتقال')) ||
        combined.contains(_normalize('پرداخت')) ||
        combined.contains(_normalize('واریز')) ||
        combined.contains(_normalize('برداشت')) ||
        combined.contains(_normalize('کیف پول')) ||
        combined.contains(_normalize('معاملة')) ||
        combined.contains(_normalize('تحويل')) ||
        combined.contains(_normalize('إيداع')) ||
        combined.contains(_normalize('سحب')) ||
        combined.contains(_normalize('دفعة')) ||
        combined.contains(_normalize('محفظة')) ||
        combined.contains('ödem') ||
        combined.contains('yatır') ||
        combined.contains('çekim') ||
        combined.contains('cüzdan') ||
        combined.contains('перевод') ||
        combined.contains('транзакц') ||
        combined.contains('платеж') ||
        combined.contains('депозит') ||
        combined.contains('кошелек') ||
        combined.contains('转账') ||
        combined.contains('交易') ||
        combined.contains('支付') ||
        combined.contains('充值') ||
        combined.contains('提现') ||
        combined.contains('钱包');

    if (isFinancial) {
      Get.toNamed(BaseRoute.transactions);
      return;
    }

    // 6. Otherwise: alert bottom sheet with full title and message
    final effectiveContext = context ?? Get.context;
    if (effectiveContext != null) {
      showDetailSheet(
        effectiveContext,
        title: title,
        message: message,
        type: type,
      );
    }
  }

  static void showDetailSheet(
    BuildContext context, {
    required String title,
    required String message,
    required String type,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayTitle = title.trim().isNotEmpty
        ? title.trim()
        : l10nPick(
            context,
            en: 'Notification Details',
            fa: 'جزئیات اعلان',
            ar: 'تفاصيل الإشعار',
            tr: 'Bildirim Detayları',
            ru: 'Детали уведомления',
            zh: '通知详情',
          );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
          ),
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.md,
            bottom: AppSpacing.bottomSafe(ctx, AppSpacing.xl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.warmWhite : AppColors.deepBlack)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(
                      typeIcon(type),
                      color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10nPick(
                        ctx,
                        en: 'Notification Details',
                        fa: 'جزئیات اعلان',
                        ar: 'تفاصيل الإشعار',
                        tr: 'Bildirim Detayları',
                        ru: 'Детали уведомления',
                        zh: '通知详情',
                      ),
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isDark ? AppColors.warmWhite : AppColors.deepBlack,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        displayTitle,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: isDark ? AppColors.warmWhite : AppColors.deepBlack,
                        ),
                      ),
                      if (message.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SelectableText(
                          message.trim(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.warmWhite.withValues(alpha: 0.8)
                                : AppColors.lightTextPrimary.withValues(alpha: 0.85),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CommonButton(
                onPressed: () => Navigator.of(ctx).pop(),
                width: double.infinity,
                height: 46,
                text: l10nPick(
                  ctx,
                  en: 'Close',
                  fa: 'بستن',
                  ar: 'إغلاق',
                  tr: 'Kapat',
                  ru: 'Закрыть',
                  zh: '关闭',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
