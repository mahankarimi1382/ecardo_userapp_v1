import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/model/kyc_badge_model.dart';

/// Small KYC rank badge shown next to the notification bell in the home toolbar.
/// Taps route the user to the KYC verification screen.
class KycRankBadge extends StatelessWidget {
  final KycBadge? badge;
  final double size;

  const KycRankBadge({super.key, required this.badge, this.size = 30});

  @override
  Widget build(BuildContext context) {
    // If there is no badge (e.g. loading), show a neutral gray placeholder.
    final b = badge ??
        KycBadge(level: 1, color: 'gray', icon: 'user', kycStatus: 'not_submitted');

    final bgColor = _bgFor(b.color);
    final borderColor = _borderFor(b.color);

    return GestureDetector(
      onTap: () {
        // Navigate to sign-up-status/kyc flow
        Get.toNamed(
          BaseRoute.signUpStatus,
          arguments: {"is_login_state": true},
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bgColor.withValues(alpha: b.badgePulse == true ? 0.25 : 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Center(child: _iconFor(b, size * 0.5)),
          ),
          // Pulsing dot when KYC is pending
          if (b.badgePulse == true)
            const Positioned(
              top: -2,
              right: -2,
              child: _PulsingDot(color: Color(0xFFFFB84D)), // amber-ish
            ),
          // Red dot when failed/rejected
          if (b.kycStatus == 'failed')
            const Positioned(
              top: -2,
              right: -2,
              child: _PulsingDot(color: AppColors.error),
            ),
        ],
      ),
    );
  }

  Widget _iconFor(KycBadge b, double iconSize) {
    final color = _borderFor(b.color);
    IconData icon;
    switch (b.icon) {
      case 'check-badge':
        icon = Icons.verified_user_outlined;
        break;
      case 'briefcase':
        icon = Icons.business_center_outlined;
        break;
      case 'user':
      default:
        icon = Icons.person_outline;
        break;
    }
    return Icon(icon, size: iconSize, color: color);
  }

  Color _bgFor(String? c) {
    switch (c) {
      case 'green':
        return AppColors.success;
      case 'gold':
        return const Color(0xFFFFD700); // gold
      case 'gray':
      default:
        return Colors.grey;
    }
  }

  Color _borderFor(String? c) {
    switch (c) {
      case 'green':
        return AppColors.success;
      case 'gold':
        return const Color(0xFFD4AF37);
      case 'gray':
      default:
        return Colors.white;
    }
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _a = Tween<double>(begin: 0.4, end: 1.0).animate(_c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.2),
        ),
      ),
    );
  }
}
