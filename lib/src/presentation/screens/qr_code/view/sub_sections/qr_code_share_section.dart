import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Sub-section providing accessible, haptic-enabled Copy and Share action
/// buttons for the QR code display screen.
///
/// Features:
/// - Enforced minimum 44x44 touch targets (exceeds WCAG 2.5.5 requirements).
/// - Haptic feedback on tap (`HapticFeedback.lightImpact()`).
/// - Full accessibility semantics for screen readers.
/// - Clean dark mode support powered by [AppColors] design tokens.
class QrCodeShareSection extends StatelessWidget {
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final bool isCopied;
  final bool isSharing;
  final String? copyLabel;
  final String? shareLabel;

  const QrCodeShareSection({
    super.key,
    required this.onCopy,
    required this.onShare,
    this.isCopied = false,
    this.isSharing = false,
    this.copyLabel,
    this.shareLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final resolvedCopyLabel = copyLabel ??
        (isCopied
            ? l10nPick(
                context,
                en: 'Copied!',
                fa: 'کپی شد!',
                ar: 'تم النسخ!',
              )
            : l10nPick(
                context,
                en: 'Copy Data',
                fa: 'کپی داده',
                ar: 'نسخ البيانات',
              ));

    final resolvedCopyHint = l10nPick(
      context,
      en: 'Copies payment QR identifier to clipboard',
      fa: 'شناسه پرداخت کد QR را در کلیپ‌بورد کپی می‌کند',
      ar: 'ينسخ معرف رمز QR للدفع إلى الحافظة',
    );

    final resolvedShareLabel = shareLabel ??
        l10nPick(
          context,
          en: 'Share QR',
          fa: 'اشتراک‌گذاری',
          ar: 'مشاركة QR',
        );

    final resolvedShareHint = l10nPick(
      context,
      en: 'Shares your payment QR code image',
      fa: 'تصویر کد QR پرداخت شما را به اشتراک می‌گذارد',
      ar: 'يشارك صورة رمز QR للدفع الخاص بك',
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 280;

        final copyButton = _buildShareActionButton(
          context: context,
          isDark: isDark,
          icon: isCopied ? Icons.check_circle_rounded : Icons.copy_rounded,
          iconColor: isCopied ? AppColors.success : null,
          label: resolvedCopyLabel,
          semanticHint: resolvedCopyHint,
          isLoading: false,
          onTap: onCopy,
        );

        final shareButton = _buildShareActionButton(
          context: context,
          isDark: isDark,
          icon: Icons.share_rounded,
          iconColor: null,
          label: resolvedShareLabel,
          semanticHint: resolvedShareHint,
          isLoading: isSharing,
          onTap: onShare,
        );

        if (isNarrow) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              copyButton,
              const SizedBox(height: AppSpacing.sm),
              shareButton,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: copyButton),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: shareButton),
          ],
        );
      },
    );
  }

  Widget _buildShareActionButton({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String label,
    required String semanticHint,
    required bool isLoading,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final effectiveIconColor = iconColor ??
        (isDark ? AppColors.mainSoftBlue : AppColors.brandViolet);

    return Semantics(
      button: true,
      enabled: !isLoading,
      label: label,
      hint: semanticHint,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 48,
          minWidth: 48,
        ),
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: isLoading
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    onTap();
                  },
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Ink(
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.lightOutlineVariant,
                  width: 0.9,
                ),
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark
                                ? AppColors.mainSoftBlue
                                : AppColors.brandViolet,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            size: AppSpacing.iconSm,
                            color: effectiveIconColor,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.labelMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
