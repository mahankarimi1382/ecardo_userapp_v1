import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/model/transfer_wallet_model.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/widgets/transfer_recipient_card.dart';

/// Premium visual transfer route card showing:
/// Sender Wallet  --> [Transfer Path with Arrow & Amount] --> Recipient
class TransferPathCard extends StatelessWidget {
  final Wallets? senderWallet;
  final String? customSenderName;
  final String? customSenderCode;
  final String? customSenderSymbol;
  final String recipientName;
  final String recipientUid;
  final String? recipientAvatar;
  final bool isRecipientVerified;
  final String formattedAmount;
  final String currencyCode;
  final String? fromLabel;
  final String? toLabel;
  final String? identifierLabel;
  final IconData? pathIcon;

  const TransferPathCard({
    super.key,
    this.senderWallet,
    this.customSenderName,
    this.customSenderCode,
    this.customSenderSymbol,
    required this.recipientName,
    required this.recipientUid,
    this.recipientAvatar,
    this.isRecipientVerified = false,
    required this.formattedAmount,
    required this.currencyCode,
    this.fromLabel,
    this.toLabel,
    this.identifierLabel,
    this.pathIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final sName = customSenderName ?? senderWallet?.name ?? 'Wallet';
    final sCode = customSenderCode ?? senderWallet?.code ?? '';
    final sSymbol = customSenderSymbol ??
        senderWallet?.symbol ??
        (sCode.isNotEmpty ? sCode.substring(0, 1) : 'W');
    final fromText = fromLabel ?? 'From';
    final toText = toLabel ?? 'To';
    final idLabel = identifierLabel ?? 'UID';
    final iconData = pathIcon ?? Icons.east_rounded;

    return EcardoGlassCard(
      variant: EcardoGlassVariant.frosted,
      interactive: false,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              // Sender side
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            isDark ? AppColors.mutedBlue : AppColors.darkGray,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          sSymbol,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      fromText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    if (sCode.isNotEmpty)
                      Text(
                        sCode,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),

              // Center Path with Arrow & Floating Amount
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(
                          alpha: isDark ? 0.2 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusFull,
                        ),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$formattedAmount $currencyCode',
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 2,
                          decoration: BoxDecoration(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.6,
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            iconData,
                            size: 16,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 2,
                          decoration: BoxDecoration(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.6,
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Recipient side
              Expanded(
                child: Column(
                  children: [
                    RecipientMonogramAvatar(
                      name: recipientName,
                      identifier: recipientUid,
                      avatarUrl: recipientAvatar,
                      size: 52,
                      isVerified: isRecipientVerified,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      toText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      recipientName.isNotEmpty ? recipientName : 'Recipient',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    if (recipientUid.isNotEmpty)
                      Text(
                        '$idLabel: $recipientUid',
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
