import 'package:flutter/material.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';

/// Semantic status badge for support tickets across eCardo user app.
///
/// Ensures compliance with eCardo UI/UX design tokens:
/// - Open / Resolved / Active: [AppColors.success]
/// - In Progress / Waiting / Pending: [AppColors.warning]
/// - Closed / Cancelled / Urgent: [AppColors.error]
/// - Answered / Replied: [AppColors.brandViolet]
class TicketStatusBadge extends StatefulWidget {
  final String? status;
  final bool isDark;
  final AppLocalizations? localization;
  final bool showIcon;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final double? iconSize;

  const TicketStatusBadge({
    super.key,
    required this.status,
    required this.isDark,
    this.localization,
    this.showIcon = true,
    this.padding,
    this.fontSize,
    this.iconSize,
  });

  /// Maps ticket status string to its semantic theme color.
  static Color colorForStatus(String? status) {
    switch ((status ?? '').toLowerCase().trim()) {
      case 'open':
      case 'resolved':
      case 'active':
        return AppColors.success;
      case 'in_progress':
      case 'inprogress':
      case 'waiting_user':
      case 'waiting':
      case 'pending':
        return AppColors.warning;
      case 'answered':
      case 'replied':
        return AppColors.brandViolet;
      case 'closed':
      case 'archived':
      case 'cancelled':
      case 'canceled':
      case 'rejected':
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.softGray;
    }
  }

  /// Returns container background color for status pill.
  static Color containerColorForStatus(String? status, {required bool isDark}) {
    final c = colorForStatus(status);
    return isDark ? c.withValues(alpha: 0.20) : c.withValues(alpha: 0.12);
  }

  /// Returns border color for status pill.
  static Color borderColorForStatus(String? status, {required bool isDark}) {
    final c = colorForStatus(status);
    return isDark ? c.withValues(alpha: 0.40) : c.withValues(alpha: 0.28);
  }

  /// Returns semantic icon for the given ticket status.
  static IconData iconForStatus(String? status) {
    switch ((status ?? '').toLowerCase().trim()) {
      case 'open':
        return Icons.mark_email_unread_outlined;
      case 'in_progress':
      case 'inprogress':
        return Icons.sync_rounded;
      case 'answered':
      case 'replied':
        return Icons.quickreply_rounded;
      case 'waiting_user':
      case 'waiting':
      case 'pending':
        return Icons.hourglass_bottom_rounded;
      case 'resolved':
        return Icons.task_alt_rounded;
      case 'closed':
      case 'archived':
      case 'cancelled':
      case 'canceled':
      case 'rejected':
      case 'failed':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  /// Whether the status should render an animated breathing pulse dot.
  static bool hasPulse(String? status) {
    final s = (status ?? '').toLowerCase().trim();
    return s == 'in_progress' || s == 'inprogress';
  }

  /// Resolves localized string for the given status.
  static String localizedLabel(AppLocalizations l10n, String? status) {
    switch ((status ?? '').toLowerCase().trim()) {
      case 'open':
        return l10n.supportTicketsStatusOpen;
      case 'in_progress':
      case 'inprogress':
        return l10n.supportTicketsStatusInProgress;
      case 'answered':
      case 'replied':
        final code = l10n.localeName.toLowerCase();
        if (code.startsWith('fa')) return 'پاسخ داده شده';
        if (code.startsWith('ar')) return 'تم الرد';
        if (code.startsWith('tr')) return 'Yanıtlandı';
        if (code.startsWith('ru')) return 'Отвечено';
        if (code.startsWith('zh')) return '已回复';
        return 'Answered';
      case 'waiting_user':
      case 'waiting':
        return l10n.supportTicketsStatusWaitingUser;
      case 'resolved':
        return l10n.supportTicketsStatusResolved;
      case 'closed':
        return l10n.supportTicketsStatusClosed;
      case 'archived':
        return l10n.supportTicketsStatusArchived;
      case 'rejected':
      case 'failed':
        final code = l10n.localeName.toLowerCase();
        if (code.startsWith('fa')) return 'رد شده';
        if (code.startsWith('ar')) return 'مرفوض';
        if (code.startsWith('tr')) return 'Reddedildi';
        if (code.startsWith('ru')) return 'Отклонено';
        if (code.startsWith('zh')) return '已拒绝';
        return 'Rejected';
      default:
        if (status == null || status.isEmpty) {
          return l10n.supportTicketsStatusOpen;
        }
        return status;
    }
  }

  @override
  State<TicketStatusBadge> createState() => _TicketStatusBadgeState();
}

class _TicketStatusBadgeState extends State<TicketStatusBadge>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupPulse();
  }

  @override
  void didUpdateWidget(covariant TicketStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _setupPulse();
    }
  }

  void _setupPulse() {
    final shouldPulse = TicketStatusBadge.hasPulse(widget.status);
    if (shouldPulse) {
      if (_pulseController == null) {
        _pulseController = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1200),
        )..repeat(reverse: true);
        _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
          CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
        );
      }
    } else {
      _pulseController?.dispose();
      _pulseController = null;
      _pulseAnimation = null;
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.localization ?? AppLocalizations.of(context);
    final statusColor = TicketStatusBadge.colorForStatus(widget.status);
    final statusBg = TicketStatusBadge.containerColorForStatus(
      widget.status,
      isDark: widget.isDark,
    );
    final statusBorder = TicketStatusBadge.borderColorForStatus(
      widget.status,
      isDark: widget.isDark,
    );
    final label = l10n != null
        ? TicketStatusBadge.localizedLabel(l10n, widget.status)
        : (widget.status ?? '');
    final isPulsing =
        TicketStatusBadge.hasPulse(widget.status) && _pulseAnimation != null;

    final fontSize = widget.fontSize ?? 11.0;
    final iconSize = widget.iconSize ?? 12.0;

    return Container(
      padding:
          widget.padding ??
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: statusBorder, width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isPulsing) ...[
            AnimatedBuilder(
              animation: _pulseAnimation!,
              builder: (context, child) {
                return Container(
                  width: 7.5,
                  height: 7.5,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(
                      alpha: _pulseAnimation!.value,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(
                          alpha: _pulseAnimation!.value * 0.6,
                        ),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 5.5),
          ] else if (widget.showIcon) ...[
            Icon(
              TicketStatusBadge.iconForStatus(widget.status),
              size: iconSize,
              color: statusColor,
            ),
            const SizedBox(width: 4.5),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
