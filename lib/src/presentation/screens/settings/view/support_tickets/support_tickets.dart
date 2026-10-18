import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/helper/jalali_date_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/support_ticket_controller.dart';
import 'package:ecardo_user/src/presentation/screens/settings/model/support_ticket_model.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/support_tickets/replay_ticket/replay_ticket.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/support_tickets/sub_sections/ticket_details.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/support_tickets/ticket_status_helper.dart';

/// Filter buckets for top filter chips.
enum _TicketFilter { all, open, answered, closed }

/// Topic/Department metadata for smart category display.
enum _TicketCategory {
  finance,
  technical,
  identity,
  travel,
  other;

  String label(BuildContext context) {
    switch (this) {
      case _TicketCategory.finance:
        return l10nPick(
          context,
          en: 'Finance & Payments',
          fa: 'مالی و پرداخت',
          ar: 'المالية والمدفوعات',
          tr: 'Finans ve Ödeme',
          ru: 'Финансы и платежи',
          zh: '财务与支付',
        );
      case _TicketCategory.technical:
        return l10nPick(
          context,
          en: 'Technical Issues',
          fa: 'مشکلات فنی',
          ar: 'مشاكل فنية',
          tr: 'Teknik Sorunlar',
          ru: 'Технические проблемы',
          zh: '技术问题',
        );
      case _TicketCategory.identity:
        return l10nPick(
          context,
          en: 'Identity & KYC',
          fa: 'احراز هویت',
          ar: 'التحقق من الهوية',
          tr: 'Kimlik Doğrulama',
          ru: 'Верификация личности',
          zh: '身份认证',
        );
      case _TicketCategory.travel:
        return l10nPick(
          context,
          en: 'Travel & Flights',
          fa: 'خدمات سفر و پرواز',
          ar: 'خدمات السفر والرحلات',
          tr: 'Seyahat ve Uçuşlar',
          ru: 'Путешествия и авиабилеты',
          zh: '旅行与航班',
        );
      case _TicketCategory.other:
        return l10nPick(
          context,
          en: 'General Support',
          fa: 'سایر موارد',
          ar: 'دعم عام',
          tr: 'Genel Destek',
          ru: 'Общая поддержка',
          zh: '综合支持',
        );
    }
  }

  IconData get icon {
    switch (this) {
      case _TicketCategory.finance:
        return Icons.account_balance_wallet_rounded;
      case _TicketCategory.technical:
        return Icons.terminal_rounded;
      case _TicketCategory.identity:
        return Icons.verified_user_rounded;
      case _TicketCategory.travel:
        return Icons.flight_takeoff_rounded;
      case _TicketCategory.other:
        return Icons.support_agent_rounded;
    }
  }

  Color get color {
    switch (this) {
      case _TicketCategory.finance:
        return const Color(0xFF10B981);
      case _TicketCategory.technical:
        return const Color(0xFF3B82F6);
      case _TicketCategory.identity:
        return const Color(0xFF8B5CF6);
      case _TicketCategory.travel:
        return const Color(0xFF06B6D4);
      case _TicketCategory.other:
        return const Color(0xFFF59E0B);
    }
  }

  static _TicketCategory resolve(Tickets ticket) {
    final rawDept = (ticket.department ?? '').toLowerCase();
    if (rawDept.contains('finan') ||
        rawDept.contains('pay') ||
        rawDept.contains('مالی') ||
        rawDept.contains('پرداخت')) {
      return _TicketCategory.finance;
    }
    if (rawDept.contains('tech') ||
        rawDept.contains('فنی') ||
        rawDept.contains('باگ')) {
      return _TicketCategory.technical;
    }
    if (rawDept.contains('ident') ||
        rawDept.contains('kyc') ||
        rawDept.contains('هویت') ||
        rawDept.contains('احراز')) {
      return _TicketCategory.identity;
    }
    if (rawDept.contains('travel') ||
        rawDept.contains('flight') ||
        rawDept.contains('سفر') ||
        rawDept.contains('پرواز')) {
      return _TicketCategory.travel;
    }
    if (rawDept.contains('other') || rawDept.contains('سایر')) {
      return _TicketCategory.other;
    }

    final text = '${ticket.title ?? ''} ${ticket.message ?? ''}'.toLowerCase();
    if (text.contains('مالی') ||
        text.contains('پرداخت') ||
        text.contains('واریز') ||
        text.contains('برداشت') ||
        text.contains('کیف پول') ||
        text.contains('ارز') ||
        text.contains('تراکنش') ||
        text.contains('شارژ') ||
        text.contains('wallet') ||
        text.contains('payment') ||
        text.contains('deposit')) {
      return _TicketCategory.finance;
    }
    if (text.contains('احراز') ||
        text.contains('هویت') ||
        text.contains('مدارک') ||
        text.contains('پاسپورت') ||
        text.contains('شناسنامه') ||
        text.contains('kyc') ||
        text.contains('identity')) {
      return _TicketCategory.identity;
    }
    if (text.contains('سفر') ||
        text.contains('پرواز') ||
        text.contains('هتل') ||
        text.contains('تور') ||
        text.contains('بلیط') ||
        text.contains('travel') ||
        text.contains('flight') ||
        text.contains('hotel')) {
      return _TicketCategory.travel;
    }
    if (text.contains('باگ') ||
        text.contains('خطا') ||
        text.contains('ارور') ||
        text.contains('لود') ||
        text.contains('سرور') ||
        text.contains('فنی') ||
        text.contains('برنامه') ||
        text.contains('bug') ||
        text.contains('error') ||
        text.contains('crash') ||
        text.contains('technical')) {
      return _TicketCategory.technical;
    }
    return _TicketCategory.other;
  }
}

class SupportTickets extends StatefulWidget {
  const SupportTickets({super.key});

  @override
  State<SupportTickets> createState() => _SupportTicketsState();
}

class _SupportTicketsState extends State<SupportTickets>
    with WidgetsBindingObserver {
  final SupportTicketController controller = Get.find();
  late ScrollController _scrollController;
  final SettingsService settingsService = Get.find();
  _TicketFilter _selectedFilter = _TicketFilter.all;

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
      controller.loadMoreSupportTickets();
    }
  }

  Future<void> loadData() async {
    if (!controller.isInitialDataLoaded.value) {
      controller.isLoading.value = true;
      await controller.fetchSupportTickets();
      controller.isLoading.value = false;
      controller.isInitialDataLoaded.value = true;
    }
  }

  Future<void> refreshData() async {
    HapticFeedback.lightImpact();
    controller.isLoading.value = true;
    await controller.fetchSupportTickets();
    controller.isLoading.value = false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  int _countForFilter(List<Tickets> list, _TicketFilter filter) {
    switch (filter) {
      case _TicketFilter.all:
        return list.length;
      case _TicketFilter.open:
        return list.where((t) {
          final s = (t.status ?? '').toLowerCase();
          return s == 'open' || s == 'in_progress';
        }).length;
      case _TicketFilter.answered:
        return list.where((t) {
          final s = (t.status ?? '').toLowerCase();
          return s == 'answered' ||
              s == 'replied' ||
              s == 'waiting_user' ||
              s == 'resolved';
        }).length;
      case _TicketFilter.closed:
        return list.where((t) {
          final s = (t.status ?? '').toLowerCase();
          return s == 'closed' || s == 'archived' || t.isClosed == true;
        }).length;
    }
  }

  List<Tickets> _applyFilter(List<Tickets> list, _TicketFilter filter) {
    switch (filter) {
      case _TicketFilter.all:
        return list;
      case _TicketFilter.open:
        return list.where((t) {
          final s = (t.status ?? '').toLowerCase();
          return s == 'open' || s == 'in_progress';
        }).toList();
      case _TicketFilter.answered:
        return list.where((t) {
          final s = (t.status ?? '').toLowerCase();
          return s == 'answered' ||
              s == 'replied' ||
              s == 'waiting_user' ||
              s == 'resolved';
        }).toList();
      case _TicketFilter.closed:
        return list.where((t) {
          final s = (t.status ?? '').toLowerCase();
          return s == 'closed' || s == 'archived' || t.isClosed == true;
        }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CommonDefaultAppBar(),
      body: Obx(
        () {
          final allTickets = controller.supportTicketModel.value.data?.tickets ?? [];
          final filteredTickets = _applyFilter(allTickets, _selectedFilter);

          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppSpacing.cardGap),
                  CommonAppBar(title: localization.supportTicketsScreenTitle),
                  SizedBox(height: AppSpacing.sm),
                  _buildFilterBar(context, allTickets, isDark),
                  _buildTicketsBody(
                    context,
                    allTickets,
                    filteredTickets,
                    localization,
                    isDark,
                  ),
                ],
              ),
              Visibility(
                visible: controller.isPageLoading.value,
                child: const CommonLoading(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildGlowingFab(context, localization, isDark),
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    List<Tickets> allTickets,
    bool isDark,
  ) {
    final chips = [
      (
        filter: _TicketFilter.all,
        label: l10nPick(
          context,
          en: 'All',
          fa: 'همه',
          ar: 'الكل',
          tr: 'Tümü',
          ru: 'Все',
          zh: '全部',
        ),
      ),
      (
        filter: _TicketFilter.open,
        label: l10nPick(
          context,
          en: 'Open',
          fa: 'باز',
          ar: 'مفتوحة',
          tr: 'Açık',
          ru: 'Открытые',
          zh: '处理中',
        ),
      ),
      (
        filter: _TicketFilter.answered,
        label: l10nPick(
          context,
          en: 'Answered',
          fa: 'پاسخ داده شده',
          ar: 'تم الرد',
          tr: 'Yanıtlanan',
          ru: 'Отвеченные',
          zh: '已回复',
        ),
      ),
      (
        filter: _TicketFilter.closed,
        label: l10nPick(
          context,
          en: 'Closed',
          fa: 'بسته شده',
          ar: 'مغلقة',
          tr: 'Kapatılan',
          ru: 'Закрытые',
          zh: '已关闭',
        ),
      ),
    ];

    return Container(
      height: 44,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: chips.length,
        separatorBuilder: (_, _) => SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final item = chips[index];
          final isSelected = _selectedFilter == item.filter;
          final count = _countForFilter(allTickets, item.filter);

          return _buildFilterChip(
            label: item.label,
            count: count,
            isSelected: isSelected,
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedFilter = item.filter;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final activeGradient = LinearGradient(
      colors: isDark
          ? const [Color(0xFF4F46E5), Color(0xFF7C3AED)]
          : const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: isSelected ? activeGradient : null,
          color: isSelected
              ? null
              : (isDark ? AppColors.darkSurface : AppColors.white),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder.withValues(alpha: 0.8)),
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected
                    ? AppColors.white
                    : (isDark ? AppColors.softGray : AppColors.lightTextSecondary),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.white.withValues(alpha: 0.25)
                    : (isDark
                        ? AppColors.darkBackground
                        : AppColors.lightBackground),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected
                      ? AppColors.white
                      : (isDark ? AppColors.softGray : AppColors.lightTextTertiary),
                  fontWeight: FontWeight.w700,
                  fontSize: 10.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowingFab(
    BuildContext context,
    AppLocalizations localization,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.bottomSafe(context, 16)),
      child: _ScaleTapCard(
        onTap: () {
          HapticFeedback.mediumImpact();
          Get.toNamed(BaseRoute.addNewTicket);
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.45),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10nPick(
                  context,
                  en: 'New Ticket',
                  fa: 'ثبت تیکت جدید',
                  ar: 'تذكرة جديدة',
                  tr: 'Yeni Destek Talebi',
                  ru: 'Новый тикет',
                  zh: '新建工单',
                ),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketsBody(
    BuildContext context,
    List<Tickets> allTickets,
    List<Tickets> filteredTickets,
    AppLocalizations localization,
    bool isDark,
  ) {
    if (controller.isLoading.value && allTickets.isEmpty) {
      return Expanded(child: _buildLoadingSkeleton(isDark));
    }

    if (allTickets.isEmpty) {
      return Expanded(
        child: RefreshIndicator(
          color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
          onRefresh: refreshData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: EcardoEmptyState(
                  animateGlow: false,
                  iconData: Icons.headset_mic_outlined,
                  title: localization.supportTicketsScreenTitle,
                  description: l10nPick(
                    context,
                    en: 'No support tickets found. Tap below to create one.',
                    fa: 'هیچ تیکت پشتیبانی یافت نشد. برای ایجاد تیکت کلیک کنید.',
                    ar: 'لا توجد تذاكر دعم. انقر أدناه لإنشاء تذكرة.',
                    zh: '暂无支持工单，点击下方创建。',
                  ),
                  primaryActionLabel: localization.supportTicketsCreateTicketButton,
                  onPrimaryAction: () {
                    HapticFeedback.lightImpact();
                    Get.toNamed(BaseRoute.addNewTicket);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredTickets.isEmpty) {
      return Expanded(
        child: RefreshIndicator(
          color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
          onRefresh: refreshData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: EcardoEmptyState(
                  animateGlow: false,
                  iconData: Icons.filter_list_off_rounded,
                  title: l10nPick(
                    context,
                    en: 'No tickets in this section',
                    fa: 'هیچ تیکتی در این بخش وجود ندارد',
                    ar: 'لا توجد تذاكر في هذا القسم',
                    tr: 'Bu bölümde destek talebi yok',
                    ru: 'В этом разделе нет тикетов',
                    zh: '此分类暂无工单',
                  ),
                  description: l10nPick(
                    context,
                    en: 'You can view all tickets or submit a new one.',
                    fa: 'می‌توانید همه تیکت‌ها را مشاهده کرده یا تیکت جدید ثبت کنید.',
                    ar: 'يمكنك عرض كل التذاكر أو إنشاء تذكرة جديدة.',
                    tr: 'Tüm talepleri görebilir veya yeni talep oluşturabilirsiniz.',
                    ru: 'Вы можете просмотреть все тикеты или создать новый.',
                    zh: '您可以查看全部工单或提交新工单。',
                  ),
                  primaryActionLabel: l10nPick(
                    context,
                    en: 'Show All Tickets',
                    fa: 'نمایش همه تیکت‌ها',
                    ar: 'عرض كل التذاكر',
                    tr: 'Tüm Talepleri Göster',
                    ru: 'Показать все',
                    zh: '显示全部',
                  ),
                  onPrimaryAction: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedFilter = _TicketFilter.all;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
        onRefresh: refreshData,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          padding: EdgeInsetsDirectional.fromSTEB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.bottomSafe(context, 86),
          ),
          itemCount: filteredTickets.length,
          separatorBuilder: (_, _) => SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final Tickets ticket = filteredTickets[index];
            return _buildTicketCard(context, ticket, localization, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(bool isDark) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.page),
      itemCount: 4,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.md),
      itemBuilder: (_, _) => Container(
        height: 160,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.8,
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
            strokeWidth: 2.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(
    BuildContext context,
    Tickets ticket,
    AppLocalizations localization,
    bool isDark,
  ) {
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor =
        isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    final category = _TicketCategory.resolve(ticket);
    final timestampStr = _formatTicketDateTime(
      context,
      ticket.updatedAt?.isNotEmpty == true
          ? ticket.updatedAt
          : ticket.createdAt,
    );

    final excerpt = (ticket.lastReply?.isNotEmpty == true)
        ? ticket.lastReply!
        : (ticket.message ?? '');

    final isSupportReply = _isLastReplyFromSupport(ticket);

    return _ScaleTapCard(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.bottomSheet(
          TicketDetails(ticket: ticket),
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder
                : AppColors.lightBorder.withValues(alpha: 0.8),
            width: 1.0,
          ),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Category Icon Container + Title & Dept + Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Icon Container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: category.color.withValues(
                        alpha: isDark ? 0.22 : 0.12,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: category.color.withValues(
                          alpha: isDark ? 0.38 : 0.24,
                        ),
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        category.icon,
                        size: 22,
                        color: category.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Subject + Department / UUID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              category.label(context),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: category.color,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                            if (ticket.uuid != null && ticket.uuid!.isNotEmpty) ...[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  "•",
                                  style: TextStyle(
                                    color: secondaryTextColor.withValues(
                                      alpha: 0.5,
                                    ),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Text(
                                "#${ticket.uuid}",
                                style: AppTextStyles.labelSmall.copyWith(
                                  fontFamily: 'monospace',
                                  color: secondaryTextColor,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          ticket.title ?? '',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: primaryTextColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            height: 1.28,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Live Status Badge
                  TicketStatusBadge(
                    status: ticket.status,
                    isDark: isDark,
                    localization: localization,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Metadata Row: Priority Badge + Jalali Timestamp + Messages Count
              Row(
                children: [
                  if (ticket.priority != null &&
                      ticket.priority!.isNotEmpty) ...[
                    _buildPriorityBadge(
                      ticket.priority!,
                      localization,
                      isDark,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (timestampStr.isNotEmpty) ...[
                    Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        timestampStr,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: secondaryTextColor,
                          fontSize: 11.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  if (ticket.messagesCount != null &&
                      ticket.messagesCount! > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (isDark
                                ? AppColors.darkBackground
                                : AppColors.lightBackground)
                            .withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 11,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${ticket.messagesCount}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: secondaryTextColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              // Last reply excerpt preview
              if (excerpt.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBackground.withValues(alpha: 0.7)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder.withValues(alpha: 0.7)
                          : const Color(0xFFE2E8F0),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isSupportReply
                                ? Icons.support_agent_rounded
                                : Icons.person_outline_rounded,
                            size: 13,
                            color: isSupportReply
                                ? const Color(0xFF8B5CF6)
                                : secondaryTextColor,
                          ),
                          const SizedBox(width: 4.5),
                          Text(
                            isSupportReply
                                ? l10nPick(
                                    context,
                                    en: 'Support Team',
                                    fa: 'پشتیبانی اکاردو',
                                    ar: 'فريق الدعم',
                                    tr: 'Destek Ekibi',
                                    ru: 'Служба поддержки',
                                    zh: '客服团队',
                                  )
                                : l10nPick(
                                    context,
                                    en: 'You',
                                    fa: 'شما',
                                    ar: 'أنت',
                                    tr: 'Sen',
                                    ru: 'Вы',
                                    zh: '你',
                                  ),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isSupportReply
                                  ? const Color(0xFF8B5CF6)
                                  : secondaryTextColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        excerpt,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.warmWhite.withValues(alpha: 0.85)
                              : AppColors.deepBlack.withValues(alpha: 0.85),
                          fontSize: 12,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: isDark
                    ? AppColors.darkDivider
                    : AppColors.lightDivider.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 10),

              // Bottom Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Get.bottomSheet(
                        TicketDetails(ticket: ticket),
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                      );
                    },
                    icon: Icon(
                      Icons.info_outline_rounded,
                      size: 15,
                      color: isDark
                          ? AppColors.softGray
                          : AppColors.lightTextSecondary,
                    ),
                    label: Text(
                      l10nPick(
                        context,
                        en: 'Details',
                        fa: 'جزئیات',
                        ar: 'التفاصيل',
                        tr: 'Detaylar',
                        ru: 'Детали',
                        zh: '详情',
                      ),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.softGray
                            : AppColors.lightTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.mainSoftBlue
                          : AppColors.lightPrimary,
                      foregroundColor:
                          isDark ? AppColors.deepBlack : AppColors.white,
                      elevation: 0,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                    ),
                    icon: Icon(
                      ticket.isClosed == true
                          ? Icons.remove_red_eye_outlined
                          : Icons.chat_bubble_outline_rounded,
                      size: 14,
                    ),
                    label: Text(
                      ticket.isClosed == true
                          ? l10nPick(
                              context,
                              en: 'View Thread',
                              fa: 'مشاهده گفتگو',
                              ar: 'عرض المحادثة',
                              tr: 'Yazışmayı Gör',
                              ru: 'Диалог',
                              zh: '查看记录',
                            )
                          : localization.supportTicketsReplyButton,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Get.to(
                        () => ReplayTicket(
                          ticketUid: ticket.uuid.toString(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isLastReplyFromSupport(Tickets ticket) {
    if (ticket.lastReplyFromUser != null) {
      return !ticket.lastReplyFromUser!;
    }
    if (ticket.lastReplySender != null) {
      final s = ticket.lastReplySender!.toLowerCase();
      return s == 'support' || s == 'agent' || s == 'admin';
    }
    final st = (ticket.status ?? '').toLowerCase();
    return st == 'answered' || st == 'waiting_user' || st == 'resolved';
  }

  String _formatTicketDateTime(BuildContext context, String? rawIso) {
    if (rawIso == null || rawIso.isEmpty) return '';
    final dt = DateTime.tryParse(rawIso);
    if (dt == null) return rawIso;

    final now = DateTime.now();
    final diff = now.difference(dt);
    final effectiveDiff = diff.isNegative ? Duration.zero : diff;

    String relative;
    if (effectiveDiff.inMinutes < 1) {
      relative = l10nPick(
        context,
        en: 'Just now',
        fa: 'همین الان',
        ar: 'الآن',
        tr: 'Az önce',
        ru: 'Только что',
        zh: '刚刚',
      );
    } else if (effectiveDiff.inMinutes < 60) {
      relative = l10nPick(
        context,
        en: '${effectiveDiff.inMinutes}m ago',
        fa: '${effectiveDiff.inMinutes} دقیقه پیش',
        ar: 'منذ ${effectiveDiff.inMinutes} دقيقة',
        tr: '${effectiveDiff.inMinutes} dk önce',
        ru: '${effectiveDiff.inMinutes} мин назад',
        zh: '${effectiveDiff.inMinutes}分钟前',
      );
    } else if (effectiveDiff.inHours < 24) {
      relative = l10nPick(
        context,
        en: '${effectiveDiff.inHours}h ago',
        fa: '${effectiveDiff.inHours} ساعت پیش',
        ar: 'منذ ${effectiveDiff.inHours} ساعة',
        tr: '${effectiveDiff.inHours} sa önce',
        ru: '${effectiveDiff.inHours} ч назад',
        zh: '${effectiveDiff.inHours}小时前',
      );
    } else if (effectiveDiff.inDays < 7) {
      relative = l10nPick(
        context,
        en: '${effectiveDiff.inDays}d ago',
        fa: '${effectiveDiff.inDays} روز پیش',
        ar: 'منذ ${effectiveDiff.inDays} يوم',
        tr: '${effectiveDiff.inDays} gün önce',
        ru: '${effectiveDiff.inDays} дн назад',
        zh: '${effectiveDiff.inDays}天前',
      );
    } else {
      final weeks = (effectiveDiff.inDays / 7).floor();
      if (weeks < 4) {
        relative = l10nPick(
          context,
          en: '${weeks}w ago',
          fa: '$weeks هفته پیش',
          ar: 'منذ $weeks أسابيع',
          tr: '$weeks hf önce',
          ru: '$weeks нед назад',
          zh: '$weeks周前',
        );
      } else {
        relative = '';
      }
    }

    final isFa = Localizations.localeOf(context).languageCode == 'fa';
    if (isFa) {
      final jalaliStr = JalaliDateHelper.format(rawIso);
      if (relative.isNotEmpty) {
        return '$relative • $jalaliStr';
      }
      return jalaliStr;
    } else {
      final dateFormatted = DateFormat("dd MMM yyyy, HH:mm").format(dt);
      if (relative.isNotEmpty) {
        return '$relative • $dateFormatted';
      }
      return dateFormatted;
    }
  }

  Widget _buildPriorityBadge(
    String priority,
    AppLocalizations localization,
    bool isDark,
  ) {
    Color col;
    String label;
    IconData iconData;

    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
      case 'فوری':
        col = AppColors.error;
        label = localization.supportTicketsPriorityHigh;
        iconData = Icons.local_fire_department_rounded;
        break;
      case 'medium':
      case 'important':
      case 'مهم':
        col = AppColors.warning;
        label = localization.supportTicketsPriorityMedium;
        iconData = Icons.priority_high_rounded;
        break;
      case 'low':
      case 'normal':
      case 'عادی':
      default:
        col = isDark ? AppColors.softGray : AppColors.lightTextTertiary;
        label = localization.supportTicketsPriorityLow;
        iconData = Icons.shield_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: col.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 10.5, color: col),
          const SizedBox(width: 3.5),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: col,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper micro-interaction widget with scale animation and haptic feedback.
class _ScaleTapCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _ScaleTapCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_ScaleTapCard> createState() => _ScaleTapCardState();
}

class _ScaleTapCardState extends State<_ScaleTapCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.982).animate(
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
