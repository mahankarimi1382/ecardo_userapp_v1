import 'package:flutter/material.dart';
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
import 'package:ecardo_user/src/helper/l10n_pick.dart';
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

  Widget _chevronIcon(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Icon(
      isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
      size: 20,
      color: AppColors.lightTextPrimary.withValues(alpha: 0.35),
    );
  }

  void _handleNotificationTap(String title, String message, String type) {
    NotificationRouter.route(
      context,
      title: title,
      message: message,
      type: type,
    );
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
                    _chip(l10nPick(context, en: 'All', fa: 'همه', ar: 'الكل', tr: 'Tümü', ru: 'Все', zh: '全部'), _NotifFilter.all),
                    _chip(l10nPick(context, en: 'Unread', fa: 'خوانده‌نشده', ar: 'غير مقروءة', tr: 'Okunmamış', ru: 'Непрочитанные', zh: '未读'), _NotifFilter.unread),
                    _chip(l10nPick(context, en: 'Financial', fa: 'مالی', ar: 'مالي', tr: 'Finansal', ru: 'Финансовые', zh: '财务'), _NotifFilter.financial),
                    _chip(l10nPick(context, en: 'System', fa: 'سیستمی', ar: 'النظام', tr: 'Sistem', ru: 'Системные', zh: '系统'), _NotifFilter.system),
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
                          EmptyView(
                            icon: Icons.notifications_none_rounded,
                            title: l10nPick(
                              context,
                              en: 'No notifications yet',
                              fa: 'هنوز اعلانی نداری',
                              ar: 'لا توجد إشعارات بعد',
                              tr: 'Henüz bildirim yok',
                              ru: 'Пока нет уведомлений',
                              zh: '暂无通知',
                            ),
                            subtitle: l10nPick(
                              context,
                              en: 'Important notifications will appear here.',
                              fa: 'اعلان‌های مهم اینجا نشون داده میشن.',
                              ar: 'ستظهر الإشعارات المهمة هنا.',
                              tr: 'Önemli bildirimler burada görünecektir.',
                              ru: 'Важные уведомления появятся здесь.',
                              zh: '重要通知将在此显示。',
                            ),
                            ctaLabel: l10nPick(
                              context,
                              en: 'Refresh',
                              fa: 'بروزرسانی',
                              ar: 'تحديث',
                              tr: 'Yenile',
                              ru: 'Обновить',
                              zh: '刷新',
                            ),
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
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 6),
                            child: Text(
                              l10nPick(
                                context,
                                en: 'Recent notifications (device)',
                                fa: 'اعلان‌های اخیر (دستگاه)',
                                ar: 'الإشعارات الأخيرة (الجهاز)',
                                tr: 'Son bildirimler (cihaz)',
                                ru: 'Недавние уведомления (устройство)',
                                zh: '最近通知 (设备)',
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          ...filteredLocal.map((item) {
                            return _localTile(item, history);
                          }),
                        ],
                        if (showServer && filteredServer.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 6),
                            child: Text(
                              l10nPick(
                                context,
                                en: 'Account notifications',
                                fa: 'اعلان‌های حساب',
                                ar: 'إشعارات الحساب',
                                tr: 'Hesap bildirimleri',
                                ru: 'Уведомления аккаунта',
                                zh: '账户通知',
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          ...filteredServer.map((n) {
                            final isUnread = n.isRead == false;
                            return InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                _handleNotificationTap(
                                  n.title ?? '',
                                  n.message ?? '',
                                  n.type ?? '',
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isUnread
                                          ? AppColors.lightPrimary
                                              .withValues(alpha: 0.05)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 6,
                                    ),
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
                                              errorBuilder: (_, _, _) =>
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
                                        const SizedBox(width: 8),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (isUnread)
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  margin:
                                                      const EdgeInsetsDirectional
                                                          .only(end: 6),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color:
                                                        AppColors.lightPrimary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              _chevronIcon(context),
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
                              ),
                            );
                          }),
                        ],
                        SizedBox(height: AppSpacing.bottomSafe(context, 24)),
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
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        await history?.markRead(item.id);
        if (Get.isRegistered<AppBadgeService>() && history != null) {
          await Get.find<AppBadgeService>().update(history.unreadCount);
        }
        _handleNotificationTap(item.title, item.body, item.type);
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
            color: item.read
                ? AppColors.lightPrimary.withValues(alpha: 0.08)
                : AppColors.lightPrimary.withValues(alpha: 0.24),
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
                    _relativeTime(context, item.at),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.lightTextPrimary.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!item.read)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsetsDirectional.only(end: 6),
                    decoration: const BoxDecoration(
                      color: AppColors.lightPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                _chevronIcon(context),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationRouter {
  static String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll('ي', 'ی') // Arabic Yeh -> Persian Yeh
        .replaceAll('ى', 'ی') // Alef Maksura -> Persian Yeh
        .replaceAll('ك', 'ک') // Arabic Kaf -> Persian Keheh
        .replaceAll('ة', 'ه') // Teh Marbuta -> Heh
        .replaceAll('‌', ' ')     // ZWNJ -> space
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
  }) {
    final t = _normalize(title);
    final m = _normalize(message);
    final combined = '$t $m';
    final tp = _normalize(type);

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

    // 3. KYC / Verification (check before app update so "KYC tier upgrade" routes to KYC)
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
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: AppSpacing.bottomSafe(ctx, 20),
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
                    color: Colors.grey.withValues(alpha: 0.3),
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
                      color: AppColors.lightPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      typeIcon(type),
                      color: AppColors.lightPrimary,
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (message.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SelectableText(
                          message.trim(),
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: isDark
                                ? Colors.white70
                                : AppColors.lightTextPrimary
                                    .withValues(alpha: 0.8),
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
