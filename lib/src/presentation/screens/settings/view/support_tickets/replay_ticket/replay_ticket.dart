import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:share_plus/share_plus.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/controller/image_picker/multiple_image_picker_controller.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/multiple_image_picker_dropdown_bottom_sheet.dart';
import 'package:ecardo_user/src/helper/jalali_date_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/reply_ticket_controller.dart';
import 'package:ecardo_user/src/presentation/screens/settings/model/ticket_message_model.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/support_tickets/sub_sections/ticket_status_badge.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/support_tickets/ticket_status_helper.dart'
    hide TicketStatusBadge;

class ReplayTicket extends StatefulWidget {
  final String ticketUid;

  const ReplayTicket({super.key, required this.ticketUid});

  @override
  State<ReplayTicket> createState() => _ReplayTicketState();
}

class _ReplayTicketState extends State<ReplayTicket> {
  final ReplyTicketController controller = Get.put(ReplyTicketController());
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _hasTextNotifier = ValueNotifier<bool>(false);
  Timer? _livePollingTimer;

  @override
  void initState() {
    super.initState();
    controller.messageController.addListener(_onMessageChanged);
    loadData();
    _startLivePolling();
  }

  void _onMessageChanged() {
    final hasText = controller.messageController.text.trim().isNotEmpty;
    if (_hasTextNotifier.value != hasText) {
      _hasTextNotifier.value = hasText;
    }
  }

  void _startLivePolling() {
    _livePollingTimer?.cancel();
    _livePollingTimer = Timer.periodic(const Duration(seconds: 6), (_) async {
      if (!mounted) return;
      final ticket = controller.ticketMessageModel.value.data?.ticket;
      if (ticket != null &&
          (ticket.isClosed == true || ticket.status == 'closed')) {
        _livePollingTimer?.cancel();
        return;
      }
      final prevCount =
          controller.ticketMessageModel.value.data?.messages?.length ?? 0;
      await controller.fetchTicketMessage(
        ticketUid: widget.ticketUid,
        isSilent: true,
      );
      if (!mounted) return;
      final newCount =
          controller.ticketMessageModel.value.data?.messages?.length ?? 0;
      if (newCount > prevCount) {
        HapticFeedback.lightImpact();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });
  }

  @override
  void dispose() {
    controller.messageController.removeListener(_onMessageChanged);
    _livePollingTimer?.cancel();
    _scrollController.dispose();
    _hasTextNotifier.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    controller.clearForm();
    controller.isLoading.value = true;
    await controller.fetchTicketMessage(ticketUid: widget.ticketUid);
    controller.isLoading.value = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: AppSpacing.normal,
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final localization = AppLocalizations.of(context)!;
    if (controller.messageController.text.trim().isNotEmpty) {
      HapticFeedback.lightImpact();
      await controller.submitReplayTicket(ticketUid: widget.ticketUid);
      controller.messageController.clear();
      controller.controller.clearImages();
      _hasTextNotifier.value = false;
      await controller.fetchTicketMessage(ticketUid: widget.ticketUid);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } else {
      ToastHelper().showErrorToast(localization.replayTicketEmptyMessageError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CommonDefaultAppBar(),
      body: Stack(
        children: [
          Obx(() {
            final isLoading = controller.isLoading.value;

            if (isLoading) {
              return const CommonLoading();
            }

            final ticket = controller.ticketMessageModel.value.data?.ticket;
            final canReply = TicketStatusHelper.canReply(
              canReply: ticket?.canReply,
              status: ticket?.status,
            );
            final isClosed = TicketStatusHelper.isClosed(
              isClosed: ticket?.isClosed,
              status: ticket?.status,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.cardGap),

                // Primary App Bar with Ticket UUID
                CommonAppBar(
                  title: "#${ticket?.uuid ?? widget.ticketUid}",
                  rightSideWidget: (!isClosed)
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (ticket?.status != null)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  end: 8,
                                ),
                                child: TicketStatusBadge(
                                  status: ticket!.status,
                                  isDark: isDark,
                                  localization: localization,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                end: 18,
                              ),
                              child: _buildCloseTicketButton(
                                context,
                                isDark,
                                localization,
                              ),
                            ),
                          ],
                        )
                      : (ticket?.status != null)
                      ? Padding(
                          padding: const EdgeInsetsDirectional.only(end: 18),
                          child: TicketStatusBadge(
                            status: ticket!.status,
                            isDark: isDark,
                            localization: localization,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // Ticket Context Sub-header (Subject / Priority / Created date)
                if (ticket != null) ...[
                  const SizedBox(height: 6),
                  _buildTicketContextCard(
                    context,
                    ticket,
                    isDark,
                    localization,
                  ),
                ],

                SizedBox(height: AppSpacing.sm),

                // Messages Chat Thread Area
                Expanded(
                  child: Container(
                    margin: const EdgeInsetsDirectional.symmetric(
                      horizontal: 16,
                    ),
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.20 : 0.03,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: RefreshIndicator(
                      color: AppColors.brandViolet,
                      onRefresh: () => loadData(),
                      child: Obx(() {
                        final model = controller.ticketMessageModel.value;
                        final allMessages = model.data?.messages ?? const [];
                        final t = model.data?.ticket;

                        // Sort oldest to newest
                        final messages = [...allMessages]
                          ..sort((a, b) {
                            final da =
                                DateTime.tryParse(a.createdAt ?? '') ??
                                DateTime.fromMillisecondsSinceEpoch(0);
                            final db =
                                DateTime.tryParse(b.createdAt ?? '') ??
                                DateTime.fromMillisecondsSinceEpoch(0);
                            return da.compareTo(db);
                          });

                        return SingleChildScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              // Initial ticket creator message
                              if (t != null)
                                _buildMessageBubble(
                                  context,
                                  isMe: true,
                                  name: t.user?.name ?? "",
                                  email: t.user?.email ?? "",
                                  message: t.message ?? "",
                                  personAvatar: t.user?.avatar ?? "",
                                  attachments: t.attachments ?? [],
                                  firstMessageDate: t.createdAt ?? "",
                                  rawDate: t.createdAt,
                                  isDark: isDark,
                                ),
                              // Conversation messages
                              ...messages.map((item) {
                                return _buildMessageBubble(
                                  context,
                                  isMe: !(item.isAdmin ?? false),
                                  name: item.user?.name ?? "",
                                  email: item.user?.email ?? "",
                                  message: item.message ?? "",
                                  personAvatar: item.user?.avatar ?? "",
                                  attachments: item.attachments ?? [],
                                  messageDate: item.createdAtFormatted ?? "",
                                  rawDate: item.createdAt,
                                  isDark: isDark,
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.sm),

                // Bottom Action: Floating Composer Bar or Closed Resolution Banner
                if (isClosed || !canReply)
                  _buildClosedTicketBanner(
                    context,
                    ticket,
                    isDark,
                    localization,
                  )
                else
                  _buildFloatingComposerBar(
                    context,
                    isDark,
                    primaryTextColor,
                    localization,
                  ),
              ],
            );
          }),

          // Full-screen loading indicator during close / action operations
          Obx(
            () => Visibility(
              visible: controller.isCloseTicketLoading.value,
              child: const CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }

  /// Close Ticket pill button on the top app bar
  Widget _buildCloseTicketButton(
    BuildContext context,
    bool isDark,
    AppLocalizations localization,
  ) {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        controller.submitCloseTicket(ticketUid: widget.ticketUid);
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                .withValues(alpha: 0.6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : AppColors.brandViolet).withValues(
                alpha: 0.08,
              ),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 14,
              color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
            ),
            const SizedBox(width: 5),
            Text(
              localization.replayTicketMarkAsClosedButton,
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Context card under app bar showing ticket subject, status, priority, and date
  Widget _buildTicketContextCard(
    BuildContext context,
    Ticket ticket,
    bool isDark,
    AppLocalizations localization,
  ) {
    final hasTitle = ticket.title != null && ticket.title!.trim().isNotEmpty;
    final priority = ticket.priority;
    final formattedCreated =
        ticket.createdAt != null && ticket.createdAt!.isNotEmpty
        ? _formatDate(ticket.createdAt!)
        : null;

    return Container(
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightOutlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasTitle) ...[
            Text(
              ticket.title!.trim(),
              style: AppTextStyles.titleSmall.copyWith(
                color: isDark ? AppColors.warmWhite : AppColors.deepBlack,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              TicketStatusBadge(
                status: ticket.status,
                isDark: isDark,
                localization: localization,
              ),
              if (priority != null && priority.isNotEmpty) ...[
                const SizedBox(width: 8),
                _buildPriorityBadge(priority, isDark, localization),
              ],
              const Spacer(),
              if (formattedCreated != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 11,
                      color: isDark
                          ? AppColors.softGray
                          : AppColors.lightTextTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedCreated,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 10.5,
                        color: isDark
                            ? AppColors.softGray
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Priority indicator pill
  Widget _buildPriorityBadge(
    String priority,
    bool isDark,
    AppLocalizations localization,
  ) {
    final p = priority.toLowerCase();
    final Color pColor;
    final String label;

    if (p == 'high' || p == 'urgent') {
      pColor = AppColors.error;
      label = localization.supportTicketsPriorityHigh;
    } else if (p == 'medium') {
      pColor = AppColors.warning;
      label = localization.supportTicketsPriorityMedium;
    } else {
      pColor = AppColors.mutedBlue;
      label = localization.supportTicketsPriorityLow;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: pColor.withValues(alpha: isDark ? 0.20 : 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: pColor.withValues(alpha: isDark ? 0.40 : 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5.5,
            height: 5.5,
            decoration: BoxDecoration(color: pColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: pColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// Modern chat bubble with Telegram / WhatsApp / Intercom standards
  Widget _buildMessageBubble(
    BuildContext context, {
    required bool isMe,
    required String name,
    required String email,
    required String message,
    required String personAvatar,
    required List<Attachments> attachments,
    String? firstMessageDate,
    String? messageDate,
    String? rawDate,
    required bool isDark,
  }) {
    // Bubble shape with directional message tail
    final bubbleBorderRadius = isMe
        ? const BorderRadiusDirectional.only(
            topStart: Radius.circular(18),
            topEnd: Radius.circular(18),
            bottomStart: Radius.circular(18),
            bottomEnd: Radius.circular(4),
          )
        : const BorderRadiusDirectional.only(
            topStart: Radius.circular(18),
            topEnd: Radius.circular(18),
            bottomEnd: Radius.circular(18),
            bottomStart: Radius.circular(4),
          );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMe) ...[
            const Flexible(flex: 1, child: SizedBox()),
            Flexible(
              flex: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.brandViolet, AppColors.brandVioletDeep],
                  ),
                  borderRadius: bubbleBorderRadius,
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.12),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandViolet.withValues(alpha: 0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _buildMessageContent(
                  context,
                  message: message,
                  attachments: attachments,
                  isMe: isMe,
                  messageDate: messageDate,
                  firstMessageDate: firstMessageDate,
                  rawDate: rawDate,
                  textColor: AppColors.white,
                  secondaryTextColor: AppColors.white.withValues(alpha: 0.82),
                  isDark: isDark,
                ),
              ),
            ),
          ] else ...[
            Flexible(
              flex: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.white,
                  borderRadius: bubbleBorderRadius,
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightOutlineVariant,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(
                        alpha: isDark ? 0.25 : 0.04,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Agent header with avatar & verified official badge
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.brandViolet.withValues(
                            alpha: 0.15,
                          ),
                          backgroundImage: personAvatar.isNotEmpty
                              ? NetworkImage(personAvatar)
                              : null,
                          child: personAvatar.isEmpty
                              ? const Icon(
                                  Icons.support_agent_rounded,
                                  size: 18,
                                  color: AppColors.brandViolet,
                                )
                              : null,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      name.isNotEmpty
                                          ? name
                                          : l10nPick(
                                              context,
                                              en: 'Support Agent',
                                              fa: 'پشتیبان',
                                            ),
                                      style: AppTextStyles.labelMedium.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? AppColors.warmWhite
                                            : AppColors.lightTextPrimary,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 14,
                                    color: AppColors.brandViolet,
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.brandViolet.withValues(
                                              alpha: 0.25,
                                            )
                                          : AppColors.brandVioletContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      l10nPick(
                                        context,
                                        en: 'SUPPORT',
                                        fa: 'پشتیبانی',
                                        ar: 'دعم',
                                      ),
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.brandViolet,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (email.isNotEmpty)
                                Text(
                                  email,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: isDark
                                        ? AppColors.softGray
                                        : AppColors.lightTextSecondary,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildMessageContent(
                      context,
                      message: message,
                      attachments: attachments,
                      isMe: isMe,
                      messageDate: messageDate,
                      firstMessageDate: firstMessageDate,
                      rawDate: rawDate,
                      textColor: isDark
                          ? AppColors.warmWhite
                          : AppColors.lightTextPrimary.withValues(alpha: 0.80),
                      secondaryTextColor: isDark
                          ? AppColors.softGray
                          : AppColors.lightTextSecondary,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
            const Flexible(flex: 1, child: SizedBox()),
          ],
        ],
      ),
    );
  }

  /// Message content with text, long-press to copy, attachments, and clean timestamp chip
  Widget _buildMessageContent(
    BuildContext context, {
    required String message,
    required List<Attachments> attachments,
    required bool isMe,
    String? messageDate,
    String? firstMessageDate,
    String? rawDate,
    required Color textColor,
    required Color secondaryTextColor,
    required bool isDark,
  }) {
    final localization = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isFa = Localizations.localeOf(context).languageCode == 'fa';

    String? formattedDate;
    if (rawDate != null && rawDate.isNotEmpty) {
      if (isFa) {
        formattedDate = JalaliDateHelper.format(rawDate);
      } else {
        try {
          final dt = DateTime.parse(rawDate);
          formattedDate = intl.DateFormat("dd MMM, yyyy hh:mm a").format(dt);
        } catch (_) {
          formattedDate = messageDate ?? rawDate;
        }
      }
    } else if (messageDate != null && messageDate.isNotEmpty) {
      formattedDate = messageDate;
    } else if (firstMessageDate != null && firstMessageDate.isNotEmpty) {
      if (isFa) {
        formattedDate = JalaliDateHelper.format(firstMessageDate);
      } else {
        try {
          formattedDate = intl.DateFormat(
            "dd MMM, yyyy hh:mm a",
          ).format(DateTime.parse(firstMessageDate));
        } catch (_) {
          formattedDate = firstMessageDate;
        }
      }
    }

    // Clean HTML break tags and entities from backend responses
    final cleanText = message
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (cleanText.isNotEmpty)
          GestureDetector(
            onLongPress: () {
              HapticFeedback.mediumImpact();
              Clipboard.setData(ClipboardData(text: cleanText));
              ToastHelper().showSuccessToast(
                l10nPick(
                  context,
                  en: 'Message copied to clipboard',
                  fa: 'پیام کپی شد',
                  ar: 'تم نسخ الرسالة',
                  tr: 'Mesaj kopyalandı',
                  ru: 'Сообщение скопировано',
                  zh: '消息已复制',
                ),
              );
            },
            child: Text(
              cleanText,
              style: AppTextStyles.bodyMedium.copyWith(
                color: textColor,
                height: 1.48,
                fontSize: 14,
              ),
            ),
          ),

        // Attachments preview inside bubble
        if (attachments.isNotEmpty) ...[
          const SizedBox(height: 10),
          _buildBubbleAttachments(
            context,
            attachments,
            isMe,
            isDark,
            textColor,
            localization,
          ),
        ],

        // Clean timestamp chip with RTL support
        if (formattedDate != null && formattedDate.isNotEmpty) ...[
          const SizedBox(height: 6),
          Align(
            alignment: isMe
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              children: [
                if (!isMe) ...[
                  Icon(
                    Icons.access_time_rounded,
                    size: 11,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  formattedDate,
                  textDirection: isFa
                      ? TextDirection.rtl
                      : (isRtl ? TextDirection.ltr : null),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: secondaryTextColor,
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Attachment tiles and image thumbnails inside message bubble
  Widget _buildBubbleAttachments(
    BuildContext context,
    List<Attachments> attachments,
    bool isMe,
    bool isDark,
    Color textColor,
    AppLocalizations localization,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.replayTicketAttachmentsLabel,
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: textColor,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        ...attachments.map((attachment) {
          final cleanUrl = attachment.cleanUrl;
          final isImage = attachment.isImage || _isImageUrl(cleanUrl);
          final fileName = _extractFileName(
            cleanUrl,
            attachment.name,
            localization,
          );

          if (isImage && cleanUrl.isNotEmpty) {
            return GestureDetector(
              onTap: () => _openLightboxViewer(
                context,
                cleanUrl,
                fileName,
                isDark,
                localization,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                constraints: const BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: textColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                  color: isMe
                      ? Colors.white.withValues(alpha: 0.12)
                      : (isDark
                            ? AppColors.darkCard
                            : AppColors.lightSurfaceVariant),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        cleanUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 120,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.brandViolet,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 90,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.image_not_supported_rounded,
                                  color: textColor.withValues(alpha: 0.6),
                                  size: 28,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  fileName,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: textColor,
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      PositionedDirectional(
                        top: 6,
                        end: 6,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.fullscreen_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Document attachment tile
          return GestureDetector(
            onTap: () => _openLightboxViewer(
              context,
              cleanUrl,
              fileName,
              isDark,
              localization,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: isMe
                    ? (isDark
                          ? AppColors.darkSurface.withValues(alpha: 0.5)
                          : AppColors.white.withValues(alpha: 0.15))
                    : (isDark ? AppColors.darkCard : AppColors.white),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                  color: textColor.withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getFileIcon(attachment.type ?? cleanUrl),
                    size: 18,
                    color: isMe ? Colors.white : AppColors.brandViolet,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fileName,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        if (attachment.formattedSize.isNotEmpty)
                          Text(
                            attachment.formattedSize,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: textColor.withValues(alpha: 0.7),
                              fontSize: 9.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 14,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Modern floating composer bar with attachment preview and glowing send button
  Widget _buildFloatingComposerBar(
    BuildContext context,
    bool isDark,
    Color primaryTextColor,
    AppLocalizations localization,
  ) {
    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(
        14,
        4,
        14,
        AppSpacing.bottomSafe(context, 10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightOutlineVariant,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.black.withValues(alpha: 0.40)
                : AppColors.brandViolet.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected attachment horizontal thumbnails
          _buildAttachmentPreview(context, isDark),

          // Input Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Attachment Picker Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  final newId = DateTime.now().millisecondsSinceEpoch;
                  Get.bottomSheet(
                    MultipleImagePickerDropdownBottomSheet(attachmentId: newId),
                  );
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        (isDark
                                ? AppColors.mainSoftBlue
                                : AppColors.brandViolet)
                            .withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    Icons.add_photo_alternate_rounded,
                    size: 20,
                    color: isDark
                        ? AppColors.mainSoftBlue
                        : AppColors.brandViolet,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Multi-line Expanding Text Field
              Expanded(
                child: TextField(
                  controller: controller.messageController,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: primaryTextColor,
                  ),
                  decoration: InputDecoration(
                    hintText: localization.replayTicketMessageHint,
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.softGray
                          : AppColors.lightTextTertiary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Circular Send Button with gradient and tap animation
              InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                onTap: () => _sendMessage(),
                child: ValueListenableBuilder<bool>(
                  valueListenable: _hasTextNotifier,
                  builder: (context, hasText, _) {
                    return Obx(() {
                      final hasImages =
                          controller.controller.attachedImages.isNotEmpty;
                      final isSending = controller.isReplayTicketLoading.value;
                      final isActive = hasText || hasImages;

                      return Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isActive
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.brandViolet,
                                    AppColors.brandVioletDeep,
                                  ],
                                )
                              : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    (isDark
                                            ? AppColors.softGray
                                            : AppColors.lightWarmGray)
                                        .withValues(alpha: 0.45),
                                    (isDark
                                            ? AppColors.darkGray
                                            : AppColors.lightWarmGray)
                                        .withValues(alpha: 0.45),
                                  ],
                                ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: AppColors.brandViolet.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isSending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  size: 19,
                                  color: Colors.white,
                                ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Horizontal thumbnail preview strip of selected images
  Widget _buildAttachmentPreview(BuildContext context, bool isDark) {
    final MultipleImagePickerController multipleImagePickerController = Get.put(
      MultipleImagePickerController(),
    );

    return Obx(() {
      if (multipleImagePickerController.images.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.only(bottom: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...multipleImagePickerController.images.entries.map((entry) {
                final int id = entry.key;
                final File imageFile = entry.value;
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.black.withValues(alpha: 0.10),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                          child: Image.file(
                            imageFile,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        top: -5,
                        end: -5,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            multipleImagePickerController.removeImage(id);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  /// Tasteful banner displayed when ticket is closed/resolved with Reopen and New Ticket options
  Widget _buildClosedTicketBanner(
    BuildContext context,
    Ticket? ticket,
    bool isDark,
    AppLocalizations localization,
  ) {
    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(
        16,
        8,
        16,
        AppSpacing.bottomSafe(context, 16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightOutlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  size: 20,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10nPick(
                        context,
                        en: 'Ticket Resolved',
                        fa: 'این تیکت حل و بسته شده است',
                        ar: 'تم حل هذه التذكرة وإغلاقها',
                        tr: 'Bu talep çözüldü ve kapatıldı',
                        ru: 'Этот тикет решен и закрыт',
                        zh: '此工单已解决并关闭',
                      ),
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.warmWhite
                            : AppColors.deepBlack,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10nPick(
                        context,
                        en: 'Need further help? Reopen this ticket or start a new request.',
                        fa: 'نیاز به راهنمایی بیشتر دارید؟ می‌توانید تیکت را باز کنید یا تیکت جدید ثبت کنید.',
                        ar: 'هل تحتاج إلى مزيد من المساعدة؟ يمكنك إعادة فتح التذكرة أو إنشاء طلب جديد.',
                        tr: 'Daha fazla yardıma mı ihtiyacınız var? Talebi yeniden açın veya yeni bir talep oluşturun.',
                        ru: 'Нужна помощь? Вы можете открыть тикет заново или создать новый запрос.',
                        zh: '需要进一步帮助？您可以重新开启此工单或创建新工单。',
                      ),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.softGray
                            : AppColors.lightTextSecondary,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Reopen Button
              Expanded(
                child: Obx(
                  () => OutlinedButton.icon(
                    onPressed: controller.isReopenTicketLoading.value
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            controller.submitReopenTicket(
                              ticketUid: widget.ticketUid,
                            );
                          },
                    icon: controller.isReopenTicketLoading.value
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.brandViolet,
                            ),
                          )
                        : Icon(
                            Icons.refresh_rounded,
                            size: 16,
                            color: isDark
                                ? AppColors.mainSoftBlue
                                : AppColors.brandViolet,
                          ),
                    label: Text(
                      l10nPick(
                        context,
                        en: 'Reopen',
                        fa: 'بازگشایی تیکت',
                        ar: 'إعادة فتح',
                        tr: 'Yeniden Aç',
                        ru: 'Открыть заново',
                        zh: '重新开启',
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.mainSoftBlue
                            : AppColors.brandViolet,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      side: BorderSide(
                        color:
                            (isDark
                                    ? AppColors.mainSoftBlue
                                    : AppColors.brandViolet)
                                .withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // New Ticket Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Get.toNamed(BaseRoute.addNewTicket);
                  },
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: Text(
                    l10nPick(
                      context,
                      en: 'New Ticket',
                      fa: 'تیکت جدید',
                      ar: 'تذكرة جديدة',
                      tr: 'Yeni Talep',
                      ru: 'Новый тикет',
                      zh: '新建工单',
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandViolet,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// High-end lightbox viewer with pinch-to-zoom interactive viewer
  void _openLightboxViewer(
    BuildContext context,
    String attachmentUrl,
    String fileName,
    bool isDark,
    AppLocalizations localization,
  ) {
    HapticFeedback.lightImpact();
    final isImage = _isImageUrl(attachmentUrl);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.90),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: Column(
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      fileName,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Content
              Expanded(
                child: isImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: InteractiveViewer(
                          minScale: 0.8,
                          maxScale: 4.0,
                          child: Center(
                            child: Image.network(
                              attachmentUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (ctx, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.brandViolet,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.broken_image_rounded,
                                        size: 48,
                                        color: Colors.white54,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        localization
                                            .replayTicketAttachmentError,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkCard
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.insert_drive_file_rounded,
                                size: 54,
                                color: AppColors.brandViolet,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                fileName,
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: isDark
                                      ? AppColors.warmWhite
                                      : AppColors.deepBlack,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  SharePlus.instance.share(
                                    ShareParams(text: attachmentUrl),
                                  );
                                },
                                icon: const Icon(Icons.share_rounded, size: 18),
                                label: Text(
                                  l10nPick(
                                    context,
                                    en: 'Share Link',
                                    fa: 'اشتراک‌گذاری لینک',
                                    ar: 'مشاركة الرابط',
                                    tr: 'Bağlantıyı Paylaş',
                                    ru: 'Поделиться ссылкой',
                                    zh: '分享链接',
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brandViolet,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusMd,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  bool _isImageUrl(String url) {
    final clean = url.replaceAll(RegExp(r'["\[\]]'), '').toLowerCase();
    return clean.endsWith('.png') ||
        clean.endsWith('.jpg') ||
        clean.endsWith('.jpeg') ||
        clean.endsWith('.webp') ||
        clean.endsWith('.gif') ||
        clean.endsWith('.svg');
  }

  IconData _getFileIcon(String typeOrUrl) {
    final ext = typeOrUrl.toLowerCase();
    if (ext.contains('pdf')) return Icons.picture_as_pdf_rounded;
    if (ext.contains('zip') || ext.contains('rar') || ext.contains('tar')) {
      return Icons.folder_zip_rounded;
    }
    if (ext.contains('doc') || ext.contains('docx')) {
      return Icons.description_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }

  String _formatDate(String dateStr) {
    try {
      final parsed = DateTime.parse(dateStr);
      return intl.DateFormat("dd MMM, yyyy").format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  String _extractFileName(
    String url,
    String? name,
    AppLocalizations localization,
  ) {
    if (name != null && name.trim().isNotEmpty) return name.trim();
    if (url.isEmpty) return localization.replayTicketUnknownFile;
    try {
      final cleanUrl = url.replaceAll(RegExp(r'["\[\]]'), '').trim();
      final parts = cleanUrl.split(RegExp(r'[/\\]'));
      if (parts.isNotEmpty && parts.last.isNotEmpty) return parts.last;
      return localization.replayTicketUnknownFile;
    } catch (e) {
      return localization.replayTicketUnknownFile;
    }
  }
}
