import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/support_ticket_controller.dart';
import 'package:ecardo_user/src/presentation/screens/settings/model/support_ticket_model.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/support_tickets/replay_ticket/replay_ticket.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/support_tickets/sub_sections/ticket_details.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/support_tickets/ticket_status_helper.dart';

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

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CommonDefaultAppBar(),
      body: Obx(
        () => Stack(
          children: [
            Column(
              children: [
                SizedBox(height: AppSpacing.cardGap),
                CommonAppBar(title: localization.supportTicketsScreenTitle),
                _buildTicketsBody(context, localization, isDark),
              ],
            ),
            Visibility(
              visible: controller.isPageLoading.value,
              child: const CommonLoading(),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.bottomSafe(context, 20)),
        child: SizedBox(
          height: 48,
          child: FloatingActionButton.extended(
            heroTag: null,
            elevation: 2,
            onPressed: () {
              HapticFeedback.lightImpact();
              Get.toNamed(BaseRoute.addNewTicket);
            },
            backgroundColor: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
            foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            icon: Image.asset(
              PngAssets.addCommonIcon,
              width: 20,
              color: isDark ? AppColors.deepBlack : AppColors.white,
            ),
            label: Text(
              localization.supportTicketsCreateTicketButton,
              style: AppTextStyles.labelMedium.copyWith(
                color: isDark ? AppColors.deepBlack : AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketsBody(
    BuildContext context,
    AppLocalizations localization,
    bool isDark,
  ) {
    final tickets = controller.supportTicketModel.value.data?.tickets ?? [];

    if (controller.isLoading.value && tickets.isEmpty) {
      return Expanded(child: _buildLoadingSkeleton(isDark));
    }

    if (tickets.isEmpty) {
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

    return Expanded(
      child: RefreshIndicator(
        color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
        onRefresh: refreshData,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          padding: EdgeInsetsDirectional.fromSTEB(
            AppSpacing.page,
            AppSpacing.cardGap,
            AppSpacing.page,
            AppSpacing.bottomSafe(context, 80),
          ),
          itemCount: tickets.length,
          separatorBuilder: (_, _) => SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final Tickets ticket = tickets[index];
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
        height: 140,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
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
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    final statusColor = TicketStatusHelper.color(ticket.status);
    final statusBg = TicketStatusHelper.containerColor(ticket.status, isDark: isDark);
    final statusLabel = TicketStatusHelper.label(localization, ticket.status);
    final statusIcon = TicketStatusHelper.icon(ticket.status);

    DateTime? date;
    try {
      final raw = ticket.canReply == true ? ticket.updatedAt : ticket.createdAt;
      if (raw != null) date = DateTime.parse(raw);
    } catch (_) {}

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.8,
        ),
        boxShadow: !isDark
            ? [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: () {
            HapticFeedback.lightImpact();
            Get.bottomSheet(
              TicketDetails(ticket: ticket),
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
            );
          },
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: UUID badge + Priority badge + Status chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Monospace UUID Chip
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        "#${ticket.uuid ?? ''}",
                        style: AppTextStyles.labelSmall.copyWith(
                          fontFamily: 'monospace',
                          color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Priority Badge
                        if (ticket.priority != null && ticket.priority!.isNotEmpty) ...[
                          _buildPriorityBadge(ticket.priority!, localization, isDark),
                          SizedBox(width: AppSpacing.xs),
                        ],
                        // Status Chip
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                            border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 12, color: statusColor),
                              SizedBox(width: 4),
                              Text(
                                statusLabel,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.md),

                // Ticket Title
                Text(
                  ticket.title ?? '',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: primaryTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: AppSpacing.sm),

                // Timestamp row
                if (date != null)
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 14, color: secondaryTextColor),
                      SizedBox(width: 4),
                      Text(
                        "${ticket.canReply == true ? localization.supportTicketsLastUpdate : localization.supportTicketsRequestedAt}: "
                        "${DateFormat("dd MMM, yyyy - hh:mm a").format(date)}",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: AppSpacing.md),
                Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                SizedBox(height: AppSpacing.md),

                // Action buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
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
                        size: 16,
                        color: isDark ? AppColors.softGray : AppColors.lightTextSecondary,
                      ),
                      label: Text(
                        l10nPick(
                          context,
                          en: 'Details',
                          fa: 'جزئیات',
                          ar: 'التفاصيل',
                          zh: '详情',
                        ),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDark ? AppColors.softGray : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                        foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                        elevation: 0,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      ),
                      icon: Icon(Icons.chat_bubble_outline_rounded, size: 14),
                      label: Text(
                        localization.supportTicketsReplyButton,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildPriorityBadge(
    String priority,
    AppLocalizations localization,
    bool isDark,
  ) {
    Color col;
    String label;
    switch (priority.toLowerCase()) {
      case 'high':
        col = AppColors.error;
        label = localization.supportTicketsPriorityHigh;
        break;
      case 'medium':
        col = AppColors.warning;
        label = localization.supportTicketsPriorityMedium;
        break;
      case 'low':
      default:
        col = isDark ? AppColors.softGray : AppColors.lightTextTertiary;
        label = localization.supportTicketsPriorityLow;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: col.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: col,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
