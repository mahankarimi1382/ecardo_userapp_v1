import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';

/// An ultra-polished neo-fintech monogram avatar component with optional verified badge.
///
/// Features:
/// - Deterministic gradient background derived from the entity's name.
/// - Graceful network image loading with smooth error fallback to initials monogram.
/// - Verified checkmark badge positioned at the bottom-end corner.
/// - Dark mode responsive borders and shadows.
/// - Full RTL support using [AlignmentDirectional].
class MonogramAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;
  final bool isVerified;
  final Color? badgeColor;
  final VoidCallback? onTap;

  const MonogramAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 46.0,
    this.isVerified = true,
    this.badgeColor,
    this.onTap,
  });

  String _extractInitials(String rawName) {
    final trimmed = rawName.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.last.isNotEmpty ? parts.last[0] : '';
    final result = '$first$last'.toUpperCase();
    return result.isEmpty ? '?' : result;
  }

  List<Color> _deriveGradient(String key, bool isDark) {
    if (key.isEmpty) {
      return isDark
          ? [AppColors.darkSurfaceVariant, AppColors.darkCard]
          : [AppColors.lightSecondaryContainer, AppColors.lightSurfaceVariant];
    }
    final hash = key.codeUnits.fold<int>(0, (prev, elem) => prev + elem);
    final palettes = isDark
        ? [
            [const Color(0xFF1E2E42), const Color(0xFF263345)],
            [const Color(0xFF2A2421), const Color(0xFF382F2B)],
            [const Color(0xFF1B2F2A), const Color(0xFF253E38)],
            [const Color(0xFF2A2333), const Color(0xFF372E43)],
          ]
        : [
            [const Color(0xFFE3EDFC), const Color(0xFFCFE1FA)],
            [const Color(0xFFF7EBE1), const Color(0xFFEEDCCF)],
            [const Color(0xFFE2F5EC), const Color(0xFFCDEFE0)],
            [const Color(0xFFEFE6FA), const Color(0xFFE3D4F5)],
          ];
    return palettes[hash % palettes.length];
  }

  Color _deriveTextColor(String key, bool isDark) {
    if (isDark) return AppColors.warmWhite;
    final hash = key.codeUnits.fold<int>(0, (prev, elem) => prev + elem);
    const lightTextColors = [
      AppColors.mutedBlue,
      AppColors.warmBrown,
      AppColors.success,
      Color(0xFF6B4FA0),
    ];
    return lightTextColors[hash % lightTextColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = _extractInitials(name);
    final gradientColors = _deriveGradient(name, isDark);
    final textColor = _deriveTextColor(name, isDark);
    final badgeSize = (size * 0.34).clamp(14.0, 22.0);

    Widget avatarCore = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: AppSpacing.sm,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: (imageUrl != null && imageUrl!.trim().isNotEmpty)
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildInitials(initials, textColor),
              )
            : _buildInitials(initials, textColor),
      ),
    );

    if (onTap != null) {
      avatarCore = InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatarCore,
      );
    }

    return Semantics(
      label: name,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            avatarCore,
            if (isVerified)
              PositionedDirectional(
                bottom: -1,
                end: -1,
                child: Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: BoxDecoration(
                    color: badgeColor ?? AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.darkCard : AppColors.white,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (badgeColor ?? AppColors.success)
                            .withValues(alpha: 0.35),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: badgeSize * 0.65,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitials(String initials, Color textColor) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
