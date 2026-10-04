import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/presentation/screens/settings/model/support_ticket_model.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/support_tickets/ticket_status_helper.dart';

class TicketDetails extends StatelessWidget {
  final Tickets ticket;

  const TicketDetails({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark ? AppColors.softGray : AppColors.lightTextTertiary;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(24),
          topEnd: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, localization, isDark, primaryTextColor),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        label: localization.ticketDetailsTicketId,
                        value: "#${ticket.uuid ?? ''}",
                        valueColor: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                        isMono: true,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      _buildDetailRow(
                        label: localization.ticketDetailsCategory,
                        value: ticket.title ?? "",
                        valueColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      _buildDetailRow(
                        label: localization.ticketDetailsPriority,
                        value: ticket.priority == "high"
                            ? localization.ticketDetailsPriorityHigh
                            : ticket.priority == "medium"
                            ? localization.ticketDetailsPriorityMedium
                            : localization.ticketDetailsPriorityLow,
                        valueColor: ticket.priority == "high"
                            ? AppColors.error
                            : ticket.priority == "medium"
                            ? AppColors.warning
                            : (isDark ? AppColors.softGray : AppColors.lightTextSecondary),
                        secondaryTextColor: secondaryTextColor,
                      ),
                      _buildStatusRow(
                        label: localization.supportTicketsStatus.replaceAll(':', '').trim(),
                        status: ticket.status,
                        localization: localization,
                        isDark: isDark,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      if (ticket.createdAt != null && ticket.createdAt!.isNotEmpty)
                        _buildDetailRow(
                          label: localization.ticketDetailsCreatedOn,
                          // TICKET-FIX: DateTime.parse throws on formatted
                          // date strings ("12 Mar, 2026") — fall back to
                          // the raw string instead of crashing the sheet.
                          value: _formatTicketDate(ticket.createdAt!),
                          valueColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                        ),
                      if (ticket.updatedAt != null && ticket.updatedAt!.isNotEmpty)
                        _buildDetailRow(
                          label: localization.ticketDetailsLastUpdated,
                          value: _formatTicketDate(ticket.updatedAt!),
                          valueColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// TICKET-FIX: parse defensively — ISO strings format nicely, anything
  /// else is shown as-is instead of throwing.
  String _formatTicketDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat("dd MMM, yyyy - hh:mm a").format(parsed);
  }

  Widget _buildStatusRow({
    required String label,
    required String? status,
    required AppLocalizations localization,
    required bool isDark,
    required Color secondaryTextColor,
  }) {
    final statusColor = TicketStatusHelper.color(status);
    final statusBg = TicketStatusHelper.containerColor(status, isDark: isDark);
    final statusLabel = TicketStatusHelper.label(localization, status);
    final statusIcon = TicketStatusHelper.icon(status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: statusColor.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 5),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required Color valueColor,
    required Color secondaryTextColor,
    bool isMono = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                  fontFamily: isMono ? 'monospace' : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations localization,
    bool isDark,
    Color primaryTextColor,
  ) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(
            color: (isDark ? AppColors.warmWhite : AppColors.deepBlack)
                .withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          localization.ticketDetailsTitle,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 14),
        Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
        const SizedBox(height: 16),
      ],
    );
  }
}
