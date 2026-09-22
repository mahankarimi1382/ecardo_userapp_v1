import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/services/app_badge_service.dart';
import 'package:ecardo_user/src/common/services/notification_history_service.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/helper/responsive.dart';
import 'package:ecardo_user/src/helper/jalali_date_helper.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/notification_controller.dart';
import 'package:ecardo_user/src/presentation/widgets/empty_view.dart';
import 'package:ecardo_user/src/presentation/widgets/notification_dynamic_icon.dart';

enum _NotifFilter { all, unread, financial, system }

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

  String _relativeTime(DateTime at) {
    final d = DateTime.now().difference(at);
    if (d.inMinutes < 1) return 'همین الان';
    if (d.inMinutes < 60) return '${d.inMinutes} دقیقه پیش';
    if (d.inHours < 24) return '${d.inHours} ساعت پیش';
    if (d.inDays < 7) return '${d.inDays} روز پیش';
    return '${at.year}/${at.month}/${at.day}';
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'financial':
        return Icons.payments_outlined;
      case 'update':
        return Icons.system_update_alt_rounded;
      case 'system':
        return Icons.info_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final pad = Responsive.pagePadding(context);
    final history = Get.isRegistered<NotificationHistoryService>()
        ? Get.find<NotificationHistoryService>()
        : null;

    return Scaffold(
      appBar: const CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 12),
              CommonAppBar(
                title: localization.notificationsScreenTitle,
                rightSideWidget: Padding(
                  padding: EdgeInsetsDirectional.only(end: pad),
                  child: CommonButton(
                    onPressed: () async {
                      await controller.markAsReadNotification();
                      await history?.markAllRead();
                      if (Get.isRegistered<AppBadgeService>()) {
                        await Get.find<AppBadgeService>().clear();
                      }
                    },
                    width: 100,
                    height: 36,
                    fontSize: 12,
                    text: localization.notificationsMarkAllReadButton,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  children: [
                    _chip('همه', _NotifFilter.all),
                    _chip('خوانده‌نشده', _NotifFilter.unread),
                    _chip('مالی', _NotifFilter.financial),
                    _chip('سیستمی', _NotifFilter.system),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.lightPrimary,
                  onRefresh: refreshData,
                  child: Obx(() {
                    // Touch history for reactivity
                    final localItems = history?.items.toList() ?? const [];
                    final server = controller
                            .notificationModel.value.data?.notifications ??
                        const [];

                    final showLocal = _filter != _NotifFilter.all ||
                        localItems.isNotEmpty;

                    if (controller.isLoading.value &&
                        server.isEmpty &&
                        localItems.isEmpty) {
                      return const Center(child: CommonLoading());
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

                    final showServer = _filter == _NotifFilter.all ||
                        _filter == _NotifFilter.unread;

                    if (filteredLocal.isEmpty &&
                        (!showServer || server.isEmpty)) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          EmptyView(
                            icon: Icons.notifications_none_rounded,
                            title: 'هنوز اعلانی نداری',
                            subtitle:
                                'اعلان‌های مهم اینجا نشون داده میشن.',
                            ctaLabel: 'بروزرسانی',
                            onCta: refreshData,
                          ),
                        ],
                      );
                    }

                    return ListView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: pad),
                      children: [
                        if (showLocal && filteredLocal.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 6),
                            child: Text(
                              'اعلان‌های اخیر (دستگاه)',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          ...filteredLocal.map((item) {
                            return _localTile(item, history);
                          }),
                        ],
                        if (showServer && server.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.only(top: 12, bottom: 6),
                            child: Text(
                              'اعلان‌های حساب',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          ...server.map((n) {
                            return Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppColors.lightPrimary
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Image.asset(
                                            NotificationDynamicIcon
                                                .getNotificationIcon(
                                              n.type,
                                            ),
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                              Icons.notifications_none,
                                              color: AppColors.lightPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              n.title ?? n.message ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14.5,
                                              ),
                                            ),
                                            if ((n.message ?? '').isNotEmpty)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(top: 4),
                                                child: Text(
                                                  n.message!,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: AppColors
                                                        .lightTextPrimary
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(height: 6),
                                            Text(
                                              JalaliDateHelper.format(n.createdAt),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors
                                                    .lightTextPrimary
                                                    .withValues(alpha: 0.45),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  height: 1,
                                  color: AppColors.lightTextPrimary
                                      .withValues(alpha: 0.08),
                                ),
                              ],
                            );
                          }),
                        ],
                        const SizedBox(height: 24),
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

  Widget _chip(String label, _NotifFilter f) {
    final selected = _filter == f;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filter = f),
        selectedColor: AppColors.lightPrimary.withValues(alpha: 0.18),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: selected ? AppColors.lightPrimary : null,
        ),
      ),
    );
  }

  Widget _localTile(
    NotificationHistoryItem item,
    NotificationHistoryService? history,
  ) {
    return InkWell(
      onTap: () async {
        await history?.markRead(item.id);
        if (Get.isRegistered<AppBadgeService>() && history != null) {
          await Get.find<AppBadgeService>().update(history.unreadCount);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.read
              ? Theme.of(context).cardColor
              : AppColors.lightPrimary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.lightPrimary.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.lightPrimary.withValues(alpha: 0.12),
              child: Icon(_typeIcon(item.type), color: AppColors.lightPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  if (item.body.isNotEmpty)
                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.lightTextPrimary.withValues(alpha: 0.6),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _relativeTime(item.at),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.lightTextPrimary.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
