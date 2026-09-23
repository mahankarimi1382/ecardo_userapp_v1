import 'package:flutter/material.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

/// Maps backend ticket status (6 values) to label + color.
/// Contract 2026-09-23: open|in_progress|waiting_user|resolved|closed|archived
/// is_closed only closed/archived; can_reply for open/in_progress/waiting_user/resolved
class TicketStatusHelper {
  TicketStatusHelper._();

  static String label(AppLocalizations l10n, String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'open':
        return l10n.supportTicketsStatusOpen;
      case 'in_progress':
        return l10n.supportTicketsStatusInProgress;
      case 'waiting_user':
        return l10n.supportTicketsStatusWaitingUser;
      case 'resolved':
        return l10n.supportTicketsStatusResolved;
      case 'closed':
        return l10n.supportTicketsStatusClosed;
      case 'archived':
        return l10n.supportTicketsStatusArchived;
      default:
        if (status == null || status.isEmpty) {
          return l10n.supportTicketsStatusOpen;
        }
        return status;
    }
  }

  static Color color(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'open':
        return AppColors.success;
      case 'in_progress':
        return AppColors.lightPrimary;
      case 'waiting_user':
        return const Color(0xFFE6A700);
      case 'resolved':
        return const Color(0xFF0D9488);
      case 'closed':
      case 'archived':
        return AppColors.error;
      default:
        return AppColors.lightTextTertiary;
    }
  }

  static bool isClosed({bool? isClosed, String? status}) {
    if (isClosed != null) return isClosed;
    final s = (status ?? '').toLowerCase();
    return s == 'closed' || s == 'archived';
  }

  static bool canReply({bool? canReply, String? status}) {
    if (canReply != null) return canReply;
    final s = (status ?? '').toLowerCase();
    return s == 'open' ||
        s == 'in_progress' ||
        s == 'waiting_user' ||
        s == 'resolved';
  }
}
