import 'package:flutter/material.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';

/// Maps backend ticket status to UX label + color + icon + container styles.
/// Standards:
/// - "Open / باز": emerald (0xFF10B981)
/// - "In Progress / در حال بررسی": amber (0xFFF59E0B) with live pulse
/// - "Answered / پاسخ داده شده": brand violet (0xFF8B5CF6)
/// - "Closed / بسته شده": muted grey (0xFF64748B)
class TicketStatusHelper {
  TicketStatusHelper._();

  static const Color emerald = Color(0xFF10B981);
  static const Color amber = Color(0xFFF59E0B);
  static const Color brandViolet = Color(0xFF8B5CF6);
  static const Color mutedGrey = Color(0xFF64748B);
  static const Color teal = Color(0xFF0D9488);

  static String label(AppLocalizations l10n, String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'open':
        return l10n.supportTicketsStatusOpen;
      case 'in_progress':
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
        return emerald;
      case 'in_progress':
        return amber;
      case 'answered':
      case 'replied':
        return brandViolet;
      case 'waiting_user':
        return amber;
      case 'resolved':
        return teal;
      case 'closed':
      case 'archived':
        return mutedGrey;
      default:
        return AppColors.lightTextTertiary;
    }
  }

  static IconData icon(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'open':
        return Icons.mark_email_unread_outlined;
      case 'in_progress':
        return Icons.sync_rounded;
      case 'answered':
      case 'replied':
        return Icons.quickreply_rounded;
      case 'waiting_user':
        return Icons.hourglass_bottom_rounded;
      case 'resolved':
        return Icons.task_alt_rounded;
      case 'closed':
      case 'archived':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  static Color containerColor(String? status, {required bool isDark}) {
    final c = color(status);
    return isDark ? c.withValues(alpha: 0.20) : c.withValues(alpha: 0.12);
  }

  static Color borderColor(String? status, {required bool isDark}) {
    final c = color(status);
    return isDark ? c.withValues(alpha: 0.40) : c.withValues(alpha: 0.28);
  }

  static bool hasPulse(String? status) {
    return (status ?? '').toLowerCase() == 'in_progress';
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
        s == 'answered' ||
        s == 'replied' ||
        s == 'resolved';
  }
}

/// A badge that renders the live ticket status with optional pulse animation.
class TicketStatusBadge extends StatefulWidget {
  final String? status;
  final bool isDark;
  final AppLocalizations localization;
  final bool showIcon;
  final EdgeInsetsGeometry? padding;

  const TicketStatusBadge({
    super.key,
    required this.status,
    required this.isDark,
    required this.localization,
    this.showIcon = true,
    this.padding,
  });

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
    final shouldPulse = TicketStatusHelper.hasPulse(widget.status);
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
    final statusColor = TicketStatusHelper.color(widget.status);
    final statusBg = TicketStatusHelper.containerColor(
      widget.status,
      isDark: widget.isDark,
    );
    final statusBorder = TicketStatusHelper.borderColor(
      widget.status,
      isDark: widget.isDark,
    );
    final label = TicketStatusHelper.label(widget.localization, widget.status);
    final isPulsing =
        TicketStatusHelper.hasPulse(widget.status) && _pulseAnimation != null;

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
              TicketStatusHelper.icon(widget.status),
              size: 12,
              color: statusColor,
            ),
            const SizedBox(width: 4.5),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
