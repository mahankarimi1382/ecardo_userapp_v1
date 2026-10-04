import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/model/beneficiary_model.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';

/// Curated gradient palettes for fintech monogram avatars.
class MonogramGradients {
  static const List<List<Color>> palettes = [
    [Color(0xFF2E5CFF), Color(0xFF00C6FF)], // Sapphire
    [Color(0xFF0575E6), Color(0xFF00F260)], // Emerald
    [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Violet
    [Color(0xFFFF8008), Color(0xFFFFC837)], // Amber
    [Color(0xFFFF416C), Color(0xFFFF4B2B)], // Rose
    [Color(0xFF11998E), Color(0xFF38EF7D)], // Mint Teal
    [Color(0xFF654EA3), Color(0xFFEAAFC8)], // Orchid
    [Color(0xFF4776E6), Color(0xFF8E54E9)], // Royal Indigo
  ];

  static List<Color> forString(String key) {
    if (key.isEmpty) return palettes.first;
    final hash = key.codeUnits.fold<int>(0, (prev, elem) => prev + elem);
    return palettes[hash % palettes.length];
  }
}

/// Creative monogram avatar with deterministic vibrant gradient,
/// crisp initials, network image fallback, and optional KYC verified badge.
class RecipientMonogramAvatar extends StatelessWidget {
  final String? name;
  final String? identifier;
  final String? avatarUrl;
  final double size;
  final bool isVerified;
  final bool showBadge;

  const RecipientMonogramAvatar({
    super.key,
    this.name,
    this.identifier,
    this.avatarUrl,
    this.size = 48.0,
    this.isVerified = false,
    this.showBadge = true,
  });

  String _getInitials() {
    final cleanName = (name ?? '').trim();
    if (cleanName.isNotEmpty) {
      final parts = cleanName.split(RegExp(r'\s+'));
      if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return cleanName.substring(0, cleanName.length >= 2 ? 2 : 1).toUpperCase();
    }
    final cleanId = (identifier ?? '').trim();
    if (cleanId.isNotEmpty) {
      return cleanId.substring(0, cleanId.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyString = (name != null && name!.isNotEmpty) ? name! : (identifier ?? '');
    final gradientColors = MonogramGradients.forString(keyString);
    final initials = _getInitials();
    final badgeSize = (size * 0.32).clamp(14.0, 20.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: (avatarUrl != null && avatarUrl!.isNotEmpty)
                  ? Image.network(
                      avatarUrl!,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildInitialsText(initials),
                    )
                  : _buildInitialsText(initials),
            ),
          ),
          if (showBadge && isVerified)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: badgeSize * 0.65,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInitialsText(String initials) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Creative Recipient Identity Card displaying the active recipient with monogram avatar,
/// verified badge, copy button, and clear/change action.
class TransferRecipientCard extends StatelessWidget {
  final Beneficiaries? beneficiary;
  final String fallbackUid;
  final VoidCallback onClear;
  final VoidCallback? onChange;

  const TransferRecipientCard({
    super.key,
    this.beneficiary,
    required this.fallbackUid,
    required this.onClear,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final displayName = beneficiary?.nickname ?? beneficiary?.receiver?.name ?? 'Recipient';
    final displayUid = beneficiary?.accountNumber ?? fallbackUid;
    final hasVerifiedUser = beneficiary?.receiver != null;

    return EcardoGlassCard(
      variant: EcardoGlassVariant.subtle,
      interactive: false,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          RecipientMonogramAvatar(
            name: displayName,
            identifier: displayUid,
            avatarUrl: beneficiary?.receiver?.avatar,
            size: 46,
            isVerified: hasVerifiedUser,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasVerifiedUser) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 11,
                              color: AppColors.success,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'UID: $displayUid',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: displayUid));
                        ToastHelper().showSuccessToast('UID copied');
                        HapticFeedback.lightImpact();
                      },
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 13,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              size: 20,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            tooltip: 'Remove',
            onPressed: () {
              HapticFeedback.lightImpact();
              onClear();
            },
          ),
        ],
      ),
    );
  }
}

/// Horizontal quick-pick carousel of saved beneficiaries.
class BeneficiariesQuickPickRow extends StatelessWidget {
  final List<Beneficiaries> beneficiaries;
  final String? selectedUid;
  final ValueChanged<Beneficiaries> onSelect;
  final VoidCallback onAddNew;

  const BeneficiariesQuickPickRow({
    super.key,
    required this.beneficiaries,
    this.selectedUid,
    required this.onSelect,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: beneficiaries.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onAddNew();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? colorScheme.surfaceContainerHigh
                          : colorScheme.surfaceContainerLow,
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.group_outlined,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Saved',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          final item = beneficiaries[index - 1];
          final isSelected = selectedUid != null &&
              selectedUid!.isNotEmpty &&
              item.accountNumber == selectedUid;

          final name = item.nickname ?? item.receiver?.name ?? 'User';

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelect(item);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: AppDurations.fast,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: RecipientMonogramAvatar(
                    name: name,
                    identifier: item.accountNumber,
                    avatarUrl: item.receiver?.avatar,
                    size: 40,
                    isVerified: item.receiver != null,
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: 52,
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
