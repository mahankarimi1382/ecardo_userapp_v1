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
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/qr_code/controller/qr_code_controller.dart';
import 'package:ecardo_user/src/presentation/screens/qr_code/view/sub_sections/qr_code_share_section.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/controller/wallets_controller.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';

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

  int _selectedWalletIndex = 0;
  String _selectedCurrencyCode = 'USD';

  static const List<Map<String, String>> _fallbackCurrencies = [
    {'code': 'USD', 'symbol': r'$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'IRT', 'symbol': 'تومان', 'name': 'Toman'},
    {'code': 'USDT', 'symbol': '₮', 'name': 'Tether'},
    {'code': 'BTC', 'symbol': '₿', 'name': 'Bitcoin'},
  ];

  List<Wallets> _getAvailableWallets() {
    if (Get.isRegistered<WalletsController>()) {
      final walletsCtrl = Get.find<WalletsController>();
      if (walletsCtrl.walletsList.isNotEmpty) {
        return walletsCtrl.walletsList;
      }
    }
    return const <Wallets>[];
  }

  String _currencySymbolFor(String code) {
    return switch (code.toUpperCase().trim()) {
      'USD' => r'$',
      'EUR' => '€',
      'GBP' => '£',
      'USDT' => '₮',
      'IRT' => 'تومان',
      'IRR' => 'ریال',
      'BTC' => '₿',
      'ETH' => 'Ξ',
      'BNB' => 'BNB',
      'SOL' => 'SOL',
      _ => code,
    };
  }

  void _onSelectWallet(int index, String code) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedWalletIndex = index;
      _selectedCurrencyCode = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
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

              // 4. Content State: Branded QR Card + Switcher + Actions
              return RefreshIndicator(
                onRefresh: () => controller.loadData(),
                color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Responsive Wallet / Currency Switcher
                      _buildWalletCurrencySwitcher(context, isDark),
                      const SizedBox(height: AppSpacing.lg),

                      // Branded QR Card
                      _buildBrandedCard(context, isDark),
                      const SizedBox(height: AppSpacing.xl),

                      // Share & Copy Section (accessible 44x44 touch targets, haptics, semantics)
                      QrCodeShareSection(
                        onCopy: _copyQrData,
                        onShare: _shareQr,
                        isCopied: _isCopied,
                        isSharing: _isSharing,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Download QR Action Button
                      Semantics(
                        button: true,
                        label: localization.qrCodeScreenDownloadButton,
                        hint: _qrL(
                          context,
                          en: 'Saves the QR code to your device gallery or files',
                          fa: 'کد QR را در گالری یا فایل‌های دستگاه شما ذخیره می‌کند',
                          ar: 'يحفظ رمز QR في معرض الصور أو ملفات جهازك',
                        ),
                        child: CommonButton(
                          isLoading: _isSaving,
                          onPressed: () => _downloadQr(
                            qrKey,
                            'ecardo_qr_${DateTime.now().millisecondsSinceEpoch}',
                          ),
                          width: double.infinity,
                          text: localization.qrCodeScreenDownloadButton,
                        ),
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
                            isDark
                                ? AppColors.mainSoftBlue
                                : AppColors.brandViolet,
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
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
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

  Widget _buildWalletCurrencySwitcher(BuildContext context, bool isDark) {
    final wallets = _getAvailableWallets();
    final hasWallets = wallets.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: AppSpacing.iconXs,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l10nPick(
                  context,
                  en: 'Receiving Wallet / Currency',
                  fa: 'کیف پول / ارز دریافت',
                  ar: 'محفظة / عملة الاستلام',
                ),
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 44,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: hasWallets
                  ? List.generate(wallets.length, (index) {
                      final wallet = wallets[index];
                      final isSelected = _selectedWalletIndex == index;
                      final code = wallet.code ?? 'USD';
                      final symbol = wallet.symbol ?? _currencySymbolFor(code);

                      return Padding(
                        padding: const EdgeInsetsDirectional.only(
                          end: AppSpacing.sm,
                        ),
                        child: Semantics(
                          button: true,
                          selected: isSelected,
                          label: '${wallet.name ?? code} wallet',
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                            child: Material(
                              color: AppColors.transparent,
                              child: InkWell(
                                onTap: () => _onSelectWallet(index, code),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusFull,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.brandViolet
                                        : (isDark
                                              ? AppColors.darkSurfaceVariant
                                              : AppColors.lightSurfaceVariant),
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusFull,
                                    ),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.brandViolet
                                          : (isDark
                                                ? AppColors.darkBorder
                                                : AppColors
                                                      .lightOutlineVariant),
                                      width: 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.brandViolet
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        symbol,
                                        style: AppTextStyles.labelMedium
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: isSelected
                                                  ? AppColors.white
                                                  : (isDark
                                                        ? AppColors.mainSoftBlue
                                                        : AppColors
                                                              .brandViolet),
                                            ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        code,
                                        style: AppTextStyles.labelMedium
                                            .copyWith(
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w600,
                                              color: isSelected
                                                  ? AppColors.white
                                                  : (isDark
                                                        ? AppColors
                                                              .darkTextPrimary
                                                        : AppColors
                                                              .lightTextPrimary),
                                            ),
                                      ),
                                      if (wallet.formattedBalance != null &&
                                          wallet
                                              .formattedBalance!
                                              .isNotEmpty) ...[
                                        const SizedBox(width: AppSpacing.xs),
                                        Text(
                                          '(${wallet.formattedBalance})',
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: isSelected
                                                ? AppColors.white.withValues(
                                                    alpha: 0.85,
                                                  )
                                                : (isDark
                                                      ? AppColors
                                                            .darkTextSecondary
                                                      : AppColors
                                                            .lightTextSecondary),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    })
                  : List.generate(_fallbackCurrencies.length, (index) {
                      final curr = _fallbackCurrencies[index];
                      final code = curr['code']!;
                      final symbol = curr['symbol']!;
                      final isSelected = _selectedCurrencyCode == code;

                      return Padding(
                        padding: const EdgeInsetsDirectional.only(
                          end: AppSpacing.sm,
                        ),
                        child: Semantics(
                          button: true,
                          selected: isSelected,
                          label: '$code currency',
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                            child: Material(
                              color: AppColors.transparent,
                              child: InkWell(
                                onTap: () => _onSelectWallet(index, code),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusFull,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.brandViolet
                                        : (isDark
                                              ? AppColors.darkSurfaceVariant
                                              : AppColors.lightSurfaceVariant),
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusFull,
                                    ),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.brandViolet
                                          : (isDark
                                                ? AppColors.darkBorder
                                                : AppColors
                                                      .lightOutlineVariant),
                                      width: 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.brandViolet
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        symbol,
                                        style: AppTextStyles.labelMedium
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: isSelected
                                                  ? AppColors.white
                                                  : (isDark
                                                        ? AppColors.mainSoftBlue
                                                        : AppColors
                                                              .brandViolet),
                                            ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        code,
                                        style: AppTextStyles.labelMedium
                                            .copyWith(
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w600,
                                              color: isSelected
                                                  ? AppColors.white
                                                  : (isDark
                                                        ? AppColors
                                                              .darkTextPrimary
                                                        : AppColors
                                                              .lightTextPrimary),
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
                    }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandedCard(BuildContext context, bool isDark) {
    final user = controller.userModel.value.data;
    final fullName = [
      user?.firstName,
      user?.lastName,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' ');
    final displayName = fullName.isNotEmpty
        ? fullName
        : (user?.username ??
              _qrL(
                context,
                en: 'eCardo Pay',
                fa: 'اکاردو پی',
                ar: 'إيكاردو باي',
              ));

    final wallets = _getAvailableWallets();
    final selectedWallet =
        (wallets.isNotEmpty && _selectedWalletIndex < wallets.length)
        ? wallets[_selectedWalletIndex]
        : null;

    final accountIdentifier =
        selectedWallet?.accountNo ?? user?.accountNumber ?? user?.email ?? '';

    final activeCurrencyTag = selectedWallet?.code ?? _selectedCurrencyCode;

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
                ? AppColors.brandViolet.withValues(alpha: 0.3)
                : AppColors.mutedBlue.withValues(alpha: 0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? AppColors.black.withValues(alpha: 0.45)
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
                  backgroundImage:
                      (user?.avatar != null && user!.avatar!.isNotEmpty)
                      ? NetworkImage(user.avatar!)
                      : null,
                  child: (user?.avatar == null || user!.avatar!.isEmpty)
                      ? Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : 'E',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.mainSoftBlue
                                : AppColors.brandViolet,
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
                    color:
                        (isDark
                                ? AppColors.mainSoftBlue
                                : AppColors.brandViolet)
                            .withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    'eCardo • $activeCurrencyTag',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.mainSoftBlue
                          : AppColors.brandViolet,
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
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder.withValues(alpha: 0.6),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? AppColors.darkShadow
                        : AppColors.lightShadow.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
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
                Flexible(
                  child: Text(
                    _qrL(
                      context,
                      en: 'Encrypted peer-to-peer payment code',
                      fa: 'کد پرداخت همتا‌به‌همتا رمزگذاری‌شده',
                      ar: 'رمز دفع نظير لنظير مشفر',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyQrData() {
    HapticFeedback.lightImpact();
    final data = controller.qrCodeModel.value.data ?? '';
    final user = controller.userModel.value.data;
    final wallets = _getAvailableWallets();
    final selectedWallet =
        (wallets.isNotEmpty && _selectedWalletIndex < wallets.length)
        ? wallets[_selectedWalletIndex]
        : null;

    final textToCopy =
        selectedWallet?.accountNo ?? user?.accountNumber ?? user?.email ?? data;

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
          ShareParams(files: [XFile(file.path)], text: shareText),
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
        debugPrint(
          '⚠️ downloadQr(): saved but could not open (${result.message})',
        );
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
