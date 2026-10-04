import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/qr_code/controller/qr_code_controller.dart';

/// Locale-aware fallback string helper.
String _qrL(
  BuildContext context, {
  required String en,
  required String fa,
  required String ar,
}) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'fa':
      return fa;
    case 'ar':
      return ar;
    default:
      return en;
  }
}

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  final QrCodeController controller = Get.find<QrCodeController>();
  final GlobalKey qrKey = GlobalKey();
  bool _isSaving = false;
  bool _isSharing = false;
  bool _isCopied = false;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: CommonDefaultAppBar(),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          CommonAppBar(title: localization.qrCodeScreenTitle),
          Expanded(
            child: Obx(() {
              // 1. Loading State
              if (controller.isLoading.value) {
                return _buildLoadingState(isDark);
              }

              // 2. Error State
              if (controller.hasError.value) {
                return Center(
                  child: EcardoErrorView(
                    title: _qrL(
                      context,
                      en: 'Unable to Load QR Code',
                      fa: 'خطا در بارگذاری کد QR',
                      ar: 'تعذر تحميل رمز QR',
                    ),
                    message: _qrL(
                      context,
                      en: 'Please verify your internet connection and try again.',
                      fa: 'لطفاً اتصال اینترنت خود را بررسی کرده و مجدداً تلاش کنید.',
                      ar: 'يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.',
                    ),
                    retryLabel: _qrL(
                      context,
                      en: 'Retry',
                      fa: 'تلاش مجدد',
                      ar: 'إعادة المحاولة',
                    ),
                    onRetry: () => controller.loadData(),
                  ),
                );
              }

              // 3. Empty State
              if (!controller.hasQrData) {
                return Center(
                  child: EcardoEmptyState(
                    iconData: Icons.qr_code_2_rounded,
                    title: _qrL(
                      context,
                      en: 'QR Code Not Available',
                      fa: 'کد QR در دسترس نیست',
                      ar: 'رمز QR غير متوفر',
                    ),
                    description: _qrL(
                      context,
                      en: 'Your unique payment QR code could not be found. Please contact support.',
                      fa: 'کد QR پرداخت شما یافت نشد. لطفاً با پشتیبانی تماس بگیرید.',
                      ar: 'لم يتم العثور على رمز QR للدفع الخاص بك. يرجى الاتصال بالدعم.',
                    ),
                    primaryActionLabel: _qrL(
                      context,
                      en: 'Refresh',
                      fa: 'تازه‌سازی',
                      ar: 'تحديث',
                    ),
                    onPrimaryAction: () => controller.loadData(),
                  ),
                );
              }

              // 4. Content State: Creative Branded QR Card
              return RefreshIndicator(
                onRefresh: () => controller.loadData(),
                color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    children: [
                      _buildBrandedCard(context, isDark),
                      const SizedBox(height: AppSpacing.xl),
                      _buildActionGrid(context, isDark, localization),
                      const SizedBox(height: AppSpacing.md),
                      CommonButton(
                        isLoading: _isSaving,
                        onPressed: () => _downloadQr(
                          qrKey,
                          'ecardo_qr_${DateTime.now().millisecondsSinceEpoch}',
                        ),
                        width: double.infinity,
                        text: localization.qrCodeScreenDownloadButton,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 280,
              height: 380,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                    : AppColors.lightSurfaceVariant.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? AppColors.darkCard : AppColors.white,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    width: 140,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandedCard(BuildContext context, bool isDark) {
    final user = controller.userModel.value.data;
    final fullName = [user?.firstName, user?.lastName]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .join(' ');
    final displayName = fullName.isNotEmpty
        ? fullName
        : (user?.username ?? _qrL(context, en: 'eCardo Pay', fa: 'اکاردو پی', ar: 'إيكاردو باي'));
    final accountIdentifier = user?.accountNumber ?? user?.email ?? '';

    return RepaintBoundary(
      key: qrKey,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: isDark
                ? AppColors.mainSoftBlue.withValues(alpha: 0.22)
                : AppColors.mutedBlue.withValues(alpha: 0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : AppColors.mutedBlue.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User / Brand Header
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: isDark
                      ? AppColors.darkPrimaryContainer
                      : AppColors.lightSecondaryContainer,
                  backgroundImage: (user?.avatar != null && user!.avatar!.isNotEmpty)
                      ? NetworkImage(user.avatar!)
                      : null,
                  child: (user?.avatar == null || user!.avatar!.isEmpty)
                      ? Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'E',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.mainSoftBlue
                                : AppColors.lightPrimary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.titleSmall.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(
                            Icons.verified_rounded,
                            size: 15,
                            color: AppColors.success,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        accountIdentifier.isNotEmpty
                            ? accountIdentifier
                            : _qrL(
                                context,
                                en: 'Scan & Pay Instantly',
                                fa: 'اسکن و پرداخت آنی',
                                ar: 'امسح وادفع فوراً',
                              ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.mainSoftBlue : AppColors.mutedBlue)
                        .withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    'eCardo',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.mainSoftBlue : AppColors.mutedBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // High-Contrast QR Code Surface
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(
                  color: AppColors.lightBorder.withValues(alpha: 0.6),
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: SvgPicture.string(
                  controller.qrCodeModel.value.data ?? '',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Bottom Microcopy
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: AppSpacing.iconXs,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _qrL(
                    context,
                    en: 'Encrypted peer-to-peer payment code',
                    fa: 'کد پرداخت همتا‌به‌همتا رمزگذاری‌شده',
                    ar: 'رمز دفع نظير لنظير مشفر',
                  ),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid(
    BuildContext context,
    bool isDark,
    AppLocalizations localization,
  ) {
    return Row(
      children: [
        // Action 1: Copy Payload / Identifier
        Expanded(
          child: _buildActionButton(
            isDark: isDark,
            icon: _isCopied ? Icons.check_circle_rounded : Icons.copy_rounded,
            iconColor: _isCopied ? AppColors.success : null,
            label: _isCopied
                ? _qrL(context, en: 'Copied!', fa: 'کپی شد!', ar: 'تم النسخ!')
                : _qrL(context, en: 'Copy Data', fa: 'کپی داده', ar: 'نسخ البيانات'),
            onTap: _copyQrData,
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // Action 2: Share QR
        Expanded(
          child: _buildActionButton(
            isDark: isDark,
            isLoading: _isSharing,
            icon: Icons.share_rounded,
            label: _qrL(context, en: 'Share QR', fa: 'اشتراک‌گذاری', ar: 'مشاركة QR'),
            onTap: _shareQr,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightOutlineVariant,
            width: 0.9,
          ),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: AppSpacing.iconSm,
                      color: iconColor ??
                          (isDark ? AppColors.mainSoftBlue : AppColors.deepBlack),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      label,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _copyQrData() {
    HapticFeedback.lightImpact();
    final data = controller.qrCodeModel.value.data ?? '';
    final user = controller.userModel.value.data;
    final textToCopy = user?.accountNumber ?? user?.email ?? data;

    Clipboard.setData(ClipboardData(text: textToCopy));
    setState(() => _isCopied = true);
    ToastHelper().showSuccessToast(
      _qrL(
        context,
        en: 'QR code details copied to clipboard',
        fa: 'اطلاعات کد QR در کلیپ‌بورد کپی شد',
        ar: 'تم نسخ تفاصيل رمز QR إلى الحافظة',
      ),
    );
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  Future<void> _shareQr() async {
    final shareText = _qrL(
      context,
      en: 'My eCardo payment QR code',
      fa: 'کد QR پرداخت من در اکاردو',
      ar: 'رمز QR للدفع الخاص بي على إيكاردو',
    );
    HapticFeedback.lightImpact();
    setState(() => _isSharing = true);
    try {
      final file = await _renderAndSaveQrFile('share_ecardo_qr');
      if (file != null) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            text: shareText,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ _shareQr error: $e');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<File?> _renderAndSaveQrFile(String fileName) async {
    final ctx = qrKey.currentContext;
    if (ctx == null) return null;
    final boundary = ctx.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;

    final pngBytes = byteData.buffer.asUint8List();
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/$fileName.png');
    await file.writeAsBytes(pngBytes);
    return file;
  }

  Future<void> _downloadQr(GlobalKey key, String fileName) async {
    final localization = AppLocalizations.of(context)!;
    HapticFeedback.lightImpact();
    setState(() => _isSaving = true);
    try {
      final file = await _renderAndSaveQrFile(fileName);
      if (file == null) {
        ToastHelper().showErrorToast(localization.allControllerLoadError);
        return;
      }

      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        debugPrint('⚠️ downloadQr(): saved but could not open (${result.message})');
      }
      ToastHelper().showSuccessToast(localization.qrCodeScreenDownloadSuccess);
    } catch (e) {
      debugPrint('❌ downloadQr() error: $e');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
