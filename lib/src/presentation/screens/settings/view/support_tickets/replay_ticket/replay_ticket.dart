import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/controller/image_picker/multiple_image_picker_controller.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/multiple_image_picker_dropdown_bottom_sheet.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/reply_ticket_controller.dart';
import 'package:ecardo_user/src/presentation/screens/settings/model/ticket_message_model.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/support_tickets/ticket_status_helper.dart';

class ReplayTicket extends StatefulWidget {
  final String ticketUid;

  const ReplayTicket({super.key, required this.ticketUid});

  @override
  State<ReplayTicket> createState() => _ReplayTicketState();
}

class _ReplayTicketState extends State<ReplayTicket> {
  final ReplyTicketController controller = Get.put(ReplyTicketController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
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
                CommonAppBar(
                  title: "#${ticket?.uuid ?? widget.ticketUid}",
                  rightSideWidget: (!isClosed)
                      ? Padding(
                          padding: const EdgeInsetsDirectional.only(end: 18),
                          child: CommonButton(
                            backgroundColor: AppColors.transparent,
                            borderColor: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                            borderWidth: 1.5,
                            width: 125,
                            height: 38,
                            fontSize: 12,
                            borderRadius: AppSpacing.radiusMd,
                            textColor: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                            text: localization.replayTicketMarkAsClosedButton,
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              controller.submitCloseTicket(
                                ticketUid: widget.ticketUid,
                              );
                            },
                          ),
                        )
                      : (ticket?.status != null)
                          ? Padding(
                              padding: const EdgeInsetsDirectional.only(end: 18),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: TicketStatusHelper.containerColor(ticket!.status, isDark: isDark),
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                  border: Border.all(
                                    color: TicketStatusHelper.color(ticket.status).withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  TicketStatusHelper.label(localization, ticket.status),
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: TicketStatusHelper.color(ticket.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                ),

                SizedBox(height: AppSpacing.md),

                // Messages Chat View
                Expanded(
                  child: Container(
                    margin: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 1,
                      ),
                    ),
                    child: RefreshIndicator(
                      color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                      onRefresh: () => loadData(),
                      child: Obx(() {
                        final model = controller.ticketMessageModel.value;
                        final allMessages = model.data?.messages ?? const [];
                        final t = model.data?.ticket;

                        // TICKET-FIX: the chat renders messages in list
                        // order. Some backends return newest-first
                        // (Laravel latest() default), which displays the
                        // conversation reversed. Sort by created_at so the
                        // thread is always oldest→newest regardless of the
                        // server's ordering.
                        final messages = [...allMessages]..sort((a, b) {
                          final da =
                              DateTime.tryParse(a.createdAt ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
                          final db =
                              DateTime.tryParse(b.createdAt ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
                          return da.compareTo(db);
                        });

                        return SingleChildScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
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
                                  isDark: isDark,
                                ),
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

                // Reply Input Bar
                if (canReply)
                  Container(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      16,
                      AppSpacing.sm,
                      16,
                      AppSpacing.bottomSafe(context, AppSpacing.sm),
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.white,
                      border: Border(
                        top: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAttachmentPreview(context, isDark),
                        Row(
                          children: [
                            Expanded(child: _buildReplyInput(context, isDark, primaryTextColor)),
                            SizedBox(width: AppSpacing.sm),
                            _buildActionButtons(context, isDark),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }),
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
    required bool isDark,
  }) {
    final bubbleBg = isMe
        ? (isDark ? AppColors.darkPrimaryContainer : AppColors.lightPrimary)
        : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant);

    final textColor = isMe
        ? (isDark ? AppColors.warmWhite : AppColors.white)
        : (isDark
            ? AppColors.warmWhite
            : AppColors.lightTextPrimary.withValues(alpha: 0.80));

    final secondaryTextColor = isMe
        ? (isDark ? AppColors.warmWhite.withValues(alpha: 0.75) : AppColors.white.withValues(alpha: 0.75))
        : (isDark ? AppColors.softGray : AppColors.lightTextSecondary);

    final bubbleBorderRadius = isMe
        ? const BorderRadiusDirectional.only(
            topStart: Radius.circular(16),
            topEnd: Radius.circular(16),
            bottomStart: Radius.circular(16),
            bottomEnd: Radius.circular(4),
          )
        : const BorderRadiusDirectional.only(
            topStart: Radius.circular(16),
            topEnd: Radius.circular(16),
            bottomEnd: Radius.circular(16),
            bottomStart: Radius.circular(4),
          );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMe) ...[
            const Flexible(flex: 1, child: SizedBox()),
            Flexible(
              flex: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: bubbleBg,
                  borderRadius: bubbleBorderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
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
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  isDark: isDark,
                ),
              ),
            ),
          ] else ...[
            Flexible(
              flex: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: bubbleBg,
                  borderRadius: bubbleBorderRadius,
                  border: isDark
                      ? Border.all(color: AppColors.darkBorder, width: 0.8)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Agent header with avatar & verified badge
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                              .withValues(alpha: 0.15),
                          backgroundImage: personAvatar.isNotEmpty ? NetworkImage(personAvatar) : null,
                          child: personAvatar.isEmpty
                              ? Icon(
                                  Icons.support_agent_rounded,
                                  size: 16,
                                  color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    name.isNotEmpty
                                        ? name
                                        : l10nPick(
                                            context,
                                            en: 'Support Agent',
                                            fa: 'پشتیبان',
                                          ),
                                    style: AppTextStyles.labelMedium.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 13,
                                    color: AppColors.success,
                                  ),
                                ],
                              ),
                              if (email.isNotEmpty)
                                Text(
                                  email,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: secondaryTextColor,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildMessageContent(
                      context,
                      message: message,
                      attachments: attachments,
                      isMe: isMe,
                      messageDate: messageDate,
                      firstMessageDate: firstMessageDate,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
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

  Widget _buildMessageContent(
    BuildContext context, {
    required String message,
    required List<Attachments> attachments,
    required bool isMe,
    String? messageDate,
    String? firstMessageDate,
    required Color textColor,
    required Color secondaryTextColor,
    required bool isDark,
  }) {
    final localization = AppLocalizations.of(context)!;
    String? formattedDate = messageDate;
    if ((formattedDate == null || formattedDate.isEmpty) &&
        firstMessageDate != null &&
        firstMessageDate.isNotEmpty) {
      try {
        formattedDate = intl.DateFormat(
          "dd MMM, yyyy hh:mm a",
        ).format(DateTime.parse(firstMessageDate));
      } catch (e) {
        formattedDate = firstMessageDate;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: textColor,
            height: 1.4,
          ),
        ),
        if (attachments.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            localization.replayTicketAttachmentsLabel,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          ...attachments.map((attachment) {
            final fileName = _extractFileName(attachment.url ?? '', localization);
            final attachmentUrl = attachment.url ?? '';
            return GestureDetector(
              onTap: () => _openAttachmentViewer(context, attachmentUrl, localization, isDark),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isMe
                      ? (isDark
                          ? AppColors.darkSurface.withValues(alpha: 0.5)
                          : AppColors.white.withValues(alpha: 0.15))
                      : (isDark
                          ? AppColors.darkCard
                          : AppColors.white),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: textColor.withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      PngAssets.albumCommonIcon,
                      width: 16,
                      height: 16,
                      color: textColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        fileName,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
        if (formattedDate != null && formattedDate.isNotEmpty) ...[
          const SizedBox(height: 6),
          Align(
            alignment: isMe
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: Text(
              formattedDate,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 10,
                color: secondaryTextColor,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _openAttachmentViewer(
    BuildContext context,
    String attachmentUrl,
    AppLocalizations localization,
    bool isDark,
  ) {
    HapticFeedback.lightImpact();
    Get.bottomSheet(
      Container(
        height: 420,
        margin: const EdgeInsetsDirectional.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(24),
            topEnd: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.warmWhite : AppColors.deepBlack).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localization.replayTicketAttachmentPreviewTitle,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isDark ? AppColors.warmWhite : AppColors.deepBlack,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  attachmentUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return const CommonLoading();
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        localization.replayTicketAttachmentError,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  String _extractFileName(String url, AppLocalizations localization) {
    if (url.isEmpty) return localization.replayTicketUnknownFile;
    try {
      String cleanUrl = url.replaceAll(RegExp(r'["\[\]]'), '');
      List<String> parts = cleanUrl.split('/');
      if (parts.isNotEmpty) return parts.last;
      return localization.replayTicketUnknownFile;
    } catch (e) {
      return localization.replayTicketUnknownFile;
    }
  }

  Widget _buildReplyInput(BuildContext context, bool isDark, Color primaryTextColor) {
    final localization = AppLocalizations.of(context)!;
    return CommonTextInputField(
      isBorderShow: true,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      controller: controller.messageController,
      hintText: localization.replayTicketMessageHint,
      borderRadius: AppSpacing.radiusFull,
      keyboardType: TextInputType.text,
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: isDark ? AppColors.softGray : AppColors.lightTextTertiary,
      ),
      suffixIconWidth: 24,
      suffixIconHeight: 24,
      isSuffixIconOnTap: true,
      suffixIconOnTap: () {
        HapticFeedback.lightImpact();
        final newId = DateTime.now().millisecondsSinceEpoch;
        Get.bottomSheet(
          MultipleImagePickerDropdownBottomSheet(attachmentId: newId),
        );
      },
      suffixIcon: Icon(
        Icons.attach_file_rounded,
        size: 20,
        color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
      ),
    );
  }

  Widget _buildAttachmentPreview(BuildContext context, bool isDark) {
    final MultipleImagePickerController multipleImagePickerController = Get.put(
      MultipleImagePickerController(),
    );

    return Obx(
      () => SizedBox(
        height: multipleImagePickerController.images.isEmpty ? 0 : 80,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...multipleImagePickerController.images.entries.map((entry) {
                final int id = entry.key;
                final File imageFile = entry.value;
                return Padding(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 6),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.black.withValues(alpha: 0.10),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
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
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Obx(
      () => InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        onTap: () => _sendMessage(),
        child: Container(
          padding: const EdgeInsets.all(12),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
          ),
          child: controller.isReplayTicketLoading.value
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: isDark ? AppColors.deepBlack : AppColors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  Icons.send_rounded,
                  size: 20,
                  color: isDark ? AppColors.deepBlack : AppColors.white,
                ),
        ),
      ),
    );
  }
}
