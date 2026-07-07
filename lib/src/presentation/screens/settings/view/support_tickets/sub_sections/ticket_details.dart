import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/presentation/screens/settings/model/support_ticket_model.dart';

class TicketDetails extends StatelessWidget {
  final Tickets ticket;

  const TicketDetails({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return AnimatedContainer(
      width: double.infinity,
      height: 350,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(20),
          topEnd: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            spreadRadius: 0,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 24),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDetailRow(
                      label: localization.ticketDetailsTicketId,
                      value: "#(${ticket.uuid})",
                      valueColor: AppColors.lightTextPrimary,
                    ),
                    _buildDetailRow(
                      label: localization.ticketDetailsCategory,
                      value: ticket.title ?? "",
                      valueColor: AppColors.error,
                    ),
                    _buildDetailRow(
                      label: localization.ticketDetailsPriority,
                      value: ticket.priority == "high"
                          ? localization.ticketDetailsPriorityHigh
                          : ticket.priority == "medium"
                          ? localization.ticketDetailsPriorityMedium
                          : localization.ticketDetailsPriorityLow,
                      valueColor: AppColors.lightPrimary,
                    ),
                    _buildDetailRow(
                      label: localization.ticketDetailsCreatedOn,
                      value: DateFormat(
                        "dd MMM, yyyy - hh:mm a",
                      ).format(DateTime.parse(ticket.createdAt ?? "")),
                      valueColor: AppColors.lightTextPrimary,
                    ),
                    _buildDetailRow(
                      label: localization.ticketDetailsLastUpdated,
                      value: DateFormat(
                        "dd MMM, yyyy - hh:mm a",
                      ).format(DateTime.parse(ticket.updatedAt ?? "")),
                      valueColor: AppColors.lightTextPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Color valueColor = AppColors.error,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              letterSpacing: 0,
              fontSize: 15,
              color: AppColors.lightTextTertiary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  letterSpacing: 0,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: valueColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          localization.ticketDetailsTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildDivider(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 1.1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.white,
            AppColors.lightTextPrimary.withValues(alpha: 0.1),
            AppColors.white,
          ],
        ),
      ),
    );
  }
}
