import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/app_haptics.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../../shared/travel_theme.dart';

/// Comprehensive eSIM Activation Card containing:
/// - High-resolution GSMA LPA QR Code rendered via [SvgPicture.string].
/// - SM-DP+ Address with tap-to-copy and haptic feedback.
/// - Activation Code with tap-to-copy and haptic feedback.
/// - Confirmation code (or "None").
/// - Interactive 3-step installation tabs (iOS vs Android).
class EsimActivationCard extends StatefulWidget {
  /// SM-DP+ (Subscription Manager Data Preparation) server address.
  /// Example: "rsp.truphone.com" or "cust-sub.esim.global"
  final String smdpAddress;

  /// Activation code matching GSMA specifications.
  /// Example: "EC-TR-98421-B884" or "LPA:1$rsp.truphone.com$EC-TR-98421"
  final String activationCode;

  /// Optional Confirmation Code if required by carrier (or "None").
  final String? confirmationCode;

  /// Optional pre-computed QR payload. If omitted, standard LPA string is constructed.
  final String? qrPayload;

  /// Optional country or region label (e.g. "Turkey & Europe").
  final String? countryOrRegion;

  /// Optional SIM ICCID.
  final String? iccid;

  const EsimActivationCard({
    super.key,
    required this.smdpAddress,
    required this.activationCode,
    this.confirmationCode,
    this.qrPayload,
    this.countryOrRegion,
    this.iccid,
  });

  @override
  State<EsimActivationCard> createState() => _EsimActivationCardState();
}

class _EsimActivationCardState extends State<EsimActivationCard> {
  // 0: iOS, 1: Android
  int _selectedPlatformIndex = 0;

  // Track recently copied fields for checkmark animations
  String? _recentlyCopiedKey;

  /// Builds the standard GSMA SGP.22 LPA activation payload.
  String get effectiveQrPayload {
    if (widget.qrPayload != null && widget.qrPayload!.trim().isNotEmpty) {
      return widget.qrPayload!.trim();
    }
    if (widget.activationCode.startsWith('LPA:')) {
      return widget.activationCode;
    }
    final conf = widget.confirmationCode?.trim();
    final hasConf = conf != null &&
        conf.isNotEmpty &&
        conf.toLowerCase() != 'none';
    if (hasConf) {
      return 'LPA:1\$${widget.smdpAddress}\$${widget.activationCode}\$$conf';
    }
    return 'LPA:1\$${widget.smdpAddress}\$${widget.activationCode}';
  }

  /// Generates the QR Code SVG string using package:barcode.
  String _generateQrSvg({double size = 200}) {
    final barcode = Barcode.qrCode();
    return barcode.toSvg(
      effectiveQrPayload,
      width: size,
      height: size,
      drawText: false,
    );
  }

  Future<void> _copyToClipboard({
    required String text,
    required String key,
    required String label,
  }) async {
    AppHaptics.light();
    await Clipboard.setData(ClipboardData(text: text));

    if (!mounted) return;
    setState(() => _recentlyCopiedKey = key);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                l10nPick(
                  context,
                  en: '$label copied to clipboard',
                  fa: '$label در کلیپ‌بورد کپی شد',
                  ar: 'تم نسخ $label إلى الحافظة',
                  zh: '$label 已复制到剪贴板',
                ),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: TravelTheme.ink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );

    // Revert checkmark icon after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _recentlyCopiedKey == key) {
        setState(() => _recentlyCopiedKey = null);
      }
    });
  }

  void _showEnlargedQrDialog(BuildContext context) {
    AppHaptics.light();
    final isDark = TravelTheme.isDark(context);
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final svgString = _generateQrSvg(size: 260);
        return Dialog(
          backgroundColor: TravelTheme.cardSurfaceFor(ctx),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10nPick(
                        context,
                        en: 'eSIM Activation QR',
                        fa: 'کد QR فعال‌سازی eSIM',
                        ar: 'رمز QR لتفعيل eSIM',
                        zh: 'eSIM 激活二维码',
                      ),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: TravelTheme.textPrimaryFor(ctx),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                      color: TravelTheme.textSecondaryFor(ctx),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: TravelTheme.borderFor(ctx)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SvgPicture.string(
                    svgString,
                    width: 240.r,
                    height: 240.r,
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  l10nPick(
                    context,
                    en: 'Scan with your smartphone camera or Cellular settings.',
                    fa: 'با دوربین گوشی یا از بخش تنظیمات Cellular اسکن کنید.',
                    ar: 'امسح الرمز بكاميرا هاتفك أو من إعدادات الشبكة الخلوية.',
                    zh: '使用手机相机或蜂窝网络设置扫码。',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: TravelTheme.textSecondaryFor(ctx),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final qrSvg = _generateQrSvg(size: 190);
    final hasConfCode = widget.confirmationCode != null &&
        widget.confirmationCode!.trim().isNotEmpty &&
        widget.confirmationCode!.trim().toLowerCase() != 'none';
    final isDark = TravelTheme.isDark(context);
    final cardBg = TravelTheme.cardSurfaceFor(context);
    final chipBg = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8F9FA);
    final trackBg = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF0F2F5);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: TravelTheme.radius,
        border: Border.all(color: TravelTheme.borderFor(context)),
        boxShadow: TravelTheme.shadowFor(context),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.all(18.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Title & Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: TravelTheme.blue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_2_rounded,
                    color: TravelTheme.blue,
                    size: 22,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: 'eSIM Activation & Setup',
                          fa: 'راهنمای فعال‌سازی و بارکد eSIM',
                          ar: 'دليل تفعيل ورمز eSIM',
                          zh: 'eSIM 激活与安装指南',
                        ),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          color: TravelTheme.textPrimaryFor(context),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Scan QR or enter SM-DP+ details manually',
                          fa: 'اسکن بارکد QR یا ورود دستی اطلاعات SM-DP+',
                          ar: 'امسح الرمز أو أدخل بيانات SM-DP+ يدوياً',
                          zh: '扫码或手动输入 SM-DP+ 信息',
                        ),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: TravelTheme.textSecondaryFor(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 18.h),

            // High-Resolution QR Code Container — the quiet zone stays white in
            // BOTH themes on purpose: a QR only decodes against a light field.
            Center(
              child: Semantics(
                label: l10nPick(
                  context,
                  en: 'eSIM activation QR code',
                  fa: 'بارکد QR فعال‌سازی eSIM',
                  ar: 'رمز QR لتفعيل eSIM',
                  zh: 'eSIM 激活二维码',
                ),
                button: true,
                child: GestureDetector(
                  onTap: () => _showEnlargedQrDialog(context),
                  child: Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: TravelTheme.borderFor(context),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.28 : 0.04,
                          ),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.string(
                          qrSvg,
                          width: 180.r,
                          height: 180.r,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fullscreen_rounded,
                              size: 14.sp,
                              color: TravelTheme.blue,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              l10nPick(
                                context,
                                en: 'Tap to enlarge QR',
                                fa: 'برای بزرگ‌نمایی ضربه بزنید',
                                ar: 'اضغط لتكبير الرمز',
                                zh: '点击放大二维码',
                              ),
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w700,
                                color: TravelTheme.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 18.h),

            // Manual Activation Details Title
            Text(
              l10nPick(
                context,
                en: 'Manual Activation Details',
                fa: 'مشخصات نصب دستی',
                ar: 'بيانات التفعيل اليدوي',
                zh: '手动激活信息',
              ),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w900,
                color: TravelTheme.textPrimaryFor(context),
              ),
            ),
            SizedBox(height: 10.h),

            // 1. SM-DP+ Address Row
            _buildCopyableRow(
              context: context,
              fieldKey: 'smdp',
              label: 'SM-DP+ Address',
              value: widget.smdpAddress,
              icon: Icons.dns_rounded,
            ),
            SizedBox(height: 10.h),

            // 2. Activation Code Row
            _buildCopyableRow(
              context: context,
              fieldKey: 'act_code',
              label: 'Activation Code',
              value: widget.activationCode,
              icon: Icons.vpn_key_rounded,
            ),
            SizedBox(height: 10.h),

            // 3. Confirmation Code Row
            _buildConfirmationCodeRow(context, hasConfCode: hasConfCode),

            // Optional ICCID Row
            if (widget.iccid != null && widget.iccid!.trim().isNotEmpty) ...[
              SizedBox(height: 10.h),
              _buildCopyableRow(
                context: context,
                fieldKey: 'iccid',
                label: 'eSIM ICCID',
                value: widget.iccid!.trim(),
                icon: Icons.sim_card_outlined,
              ),
            ],

            SizedBox(height: 22.h),

            // 3-Step Installation Tabs Header (iOS vs Android)
            Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: trackBg,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildPlatformTab(
                      index: 0,
                      label: 'iOS (iPhone / iPad)',
                      icon: Icons.apple_rounded,
                    ),
                  ),
                  Expanded(
                    child: _buildPlatformTab(
                      index: 1,
                      label: 'Android',
                      icon: Icons.android_rounded,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Platform 3-step Instructions
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _selectedPlatformIndex == 0
                  ? _buildIosSteps(context)
                  : _buildAndroidSteps(context),
            ),

            SizedBox(height: 16.h),

            // Important Tips / Best Practices Banner
            Container(
              padding: EdgeInsetsDirectional.all(12.r),
              decoration: BoxDecoration(
                color: isDark
                    ? TravelTheme.yellow.withValues(alpha: 0.15)
                    : TravelTheme.yellow.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: TravelTheme.yellow.withValues(
                    alpha: isDark ? 0.45 : 0.35,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: isDark ? TravelTheme.yellow : TravelTheme.ink,
                    size: 18,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      l10nPick(
                        context,
                        en: 'Tip: An active Wi-Fi connection is required during profile installation. Do not delete the eSIM profile once added, as QR codes can only be scanned once.',
                        fa: 'نکته: در زمان نصب پروفایل، اتصال به اینترنت وای‌فای الزامی است. پس از نصب، خط eSIM را پاک نکنید زیرا بارکد فقط یک‌بار قابل اسکن است.',
                        ar: 'ملاحظة: يلزم اتصال واي فاي نشط أثناء التثبيت. لا تحذف الشريحة بعد تثبيتها لأن الرمز يُمسح لمرة واحدة فقط.',
                        zh: '提示：安装配置文件时必须连接 Wi-Fi。安装后请勿删除该 eSIM 配置，二维码仅支持单次扫描。',
                      ),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: TravelTheme.textPrimaryFor(context),
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
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

  Widget _buildPlatformTab({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedPlatformIndex == index;
    final isDark = TravelTheme.isDark(context);
    final selectedBg = isDark
        ? AppColors.darkSurfaceVariant
        : Colors.white;
    return Semantics(
      selected: isSelected,
      button: true,
      label: label,
      child: GestureDetector(
        onTap: () {
          AppHaptics.light();
          setState(() => _selectedPlatformIndex = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsetsDirectional.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected && !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: isSelected
                    ? TravelTheme.textPrimaryFor(context)
                    : TravelTheme.textSecondaryFor(context),
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    color: isSelected
                        ? TravelTheme.textPrimaryFor(context)
                        : TravelTheme.textSecondaryFor(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCopyableRow({
    required BuildContext context,
    required String fieldKey,
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isCopied = _recentlyCopiedKey == fieldKey;
    final isDark = TravelTheme.isDark(context);

    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 12.w,
        vertical: 10.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: TravelTheme.borderFor(context)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: TravelTheme.blue),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    color: TravelTheme.textSecondaryFor(context),
                  ),
                ),
                SizedBox(height: 2.h),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w800,
                      color: TravelTheme.textPrimaryFor(context),
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Material(
            color: isCopied
                ? TravelTheme.green.withValues(alpha: 0.15)
                : (isDark ? AppColors.darkSurfaceVariant : Colors.white),
            borderRadius: BorderRadius.circular(10.r),
            child: InkWell(
              onTap: () => _copyToClipboard(
                text: value,
                key: fieldKey,
                label: label,
              ),
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 10.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isCopied
                        ? TravelTheme.green.withValues(alpha: 0.4)
                        : TravelTheme.borderFor(context),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCopied
                          ? Icons.check_circle_rounded
                          : Icons.copy_rounded,
                      size: 14.sp,
                      color: isCopied
                          ? TravelTheme.green
                          : TravelTheme.textPrimaryFor(context),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isCopied
                          ? l10nPick(
                              context,
                              en: 'Copied',
                              fa: 'کپی شد',
                              ar: 'تم النسخ',
                              zh: '已复制',
                            )
                          : l10nPick(
                              context,
                              en: 'Copy',
                              fa: 'کپی',
                              ar: 'نسخ',
                              zh: '复制',
                            ),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: isCopied
                            ? TravelTheme.green
                            : TravelTheme.textPrimaryFor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationCodeRow(
    BuildContext context, {
    required bool hasConfCode,
  }) {
    final confValue = hasConfCode ? widget.confirmationCode!.trim() : 'None';
    final isCopied = _recentlyCopiedKey == 'conf';
    final isDark = TravelTheme.isDark(context);

    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 12.w,
        vertical: 10.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: TravelTheme.borderFor(context)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 18,
            color: TravelTheme.green,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirmation Code',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    color: TravelTheme.textSecondaryFor(context),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  hasConfCode
                      ? confValue
                      : l10nPick(
                          context,
                          en: 'None (Not Required)',
                          fa: 'ندارد (بدون نیاز به کد تایید)',
                          ar: 'لا يوجد (غير مطلوب)',
                          zh: '无（无需确认码）',
                        ),
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w800,
                    color: hasConfCode
                        ? TravelTheme.textPrimaryFor(context)
                        : TravelTheme.textSecondaryFor(context),
                    fontFamily: hasConfCode ? 'monospace' : null,
                  ),
                ),
              ],
            ),
          ),
          if (hasConfCode) ...[
            SizedBox(width: 8.w),
            Material(
              color: isCopied
                  ? TravelTheme.green.withValues(alpha: 0.15)
                  : (isDark ? AppColors.darkSurfaceVariant : Colors.white),
              borderRadius: BorderRadius.circular(10.r),
              child: InkWell(
                onTap: () => _copyToClipboard(
                  text: confValue,
                  key: 'conf',
                  label: 'Confirmation Code',
                ),
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isCopied
                          ? TravelTheme.green.withValues(alpha: 0.4)
                          : TravelTheme.borderFor(context),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCopied
                            ? Icons.check_circle_rounded
                            : Icons.copy_rounded,
                        size: 14.sp,
                        color: isCopied
                            ? TravelTheme.green
                            : TravelTheme.textPrimaryFor(context),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isCopied
                            ? l10nPick(
                                context,
                                en: 'Copied',
                                fa: 'کپی شد',
                                ar: 'تم النسخ',
                                zh: '已复制',
                              )
                            : l10nPick(
                                context,
                                en: 'Copy',
                                fa: 'کپی',
                                ar: 'نسخ',
                                zh: '复制',
                              ),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: isCopied
                              ? TravelTheme.green
                              : TravelTheme.textPrimaryFor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIosSteps(BuildContext context) {
    return Column(
      key: const ValueKey('ios_steps'),
      children: [
        _buildStepTile(
          stepNumber: '1',
          title: l10nPick(
            context,
            en: '1. Open Cellular Settings',
            fa: '۱. مراجعه به بخش Cellular',
            ar: '١. فتح إعدادات الخلوي',
            zh: '1. 打开蜂窝网络设置',
          ),
          description: l10nPick(
            context,
            en: 'Connect to Wi-Fi. Go to Settings > Cellular (or Mobile Data) > tap "Add eSIM" (or Add Cellular Plan).',
            fa: 'به وای‌فای وصل شوید. به Settings > Cellular بروید و روی Add eSIM بزنید.',
            ar: 'اتصل بشبكة واي فاي. اذهب إلى الإعدادات > خلوي > إضافة eSIM.',
            zh: '连接 Wi-Fi，进入 设置 > 蜂窝网络 > 点击“添加 eSIM”。',
          ),
          icon: Icons.settings_rounded,
        ),
        SizedBox(height: 10.h),
        _buildStepTile(
          stepNumber: '2',
          title: l10nPick(
            context,
            en: '2. Scan QR or Enter Manually',
            fa: '۲. اسکن بارکد یا ورود دستی',
            ar: '٢. مسح الرمز أو الإدخال يدوياً',
            zh: '2. 扫码或手动输入',
          ),
          description: l10nPick(
            context,
            en: 'Select "Use QR Code" and scan the QR above. Or tap "Enter Details Manually" and paste the SM-DP+ Address & Activation Code.',
            fa: 'گزینه Use QR Code را زده و بارکد بالا را اسکن کنید، یا اطلاعات SM-DP+ را دستی وارد کنید.',
            ar: 'اختر استخدام رمز QR وامسح الرمز أعلاه، أو أدخل عنوان SM-DP+ ورمز التفعيل يدوياً.',
            zh: '选择“使用二维码”扫码，或点击“手动输入详细信息”粘贴 SM-DP+ 和激活码。',
          ),
          icon: Icons.qr_code_scanner_rounded,
        ),
        SizedBox(height: 10.h),
        _buildStepTile(
          stepNumber: '3',
          title: l10nPick(
            context,
            en: '3. Turn on Data Roaming at Destination',
            fa: '۳. فعال‌سازی رومینگ در کشور مقصد',
            ar: '٣. تفعيل تجوال البيانات عند الوصول',
            zh: '3. 抵达目的地后开启数据漫游',
          ),
          description: l10nPick(
            context,
            en: 'Label this line (e.g. Travel eSIM). When you arrive, set it as your primary Mobile Data line and toggle "Data Roaming" ON.',
            fa: 'نام خط را مشخص کنید. هنگام فرود در مقصد، این خط را برای اینترنت انتخاب کرده و Data Roaming را روشن نمایید.',
            ar: 'قم بتسمية الشريحة (مثل eSIM سفر). عند وصولك اجعلها خط البيانات وفعّل تجوال البيانات.',
            zh: '为该线路添加标签（如：旅行 eSIM）。抵达目的地后将其设为移动数据线路，并开启“数据漫游”。',
          ),
          icon: Icons.flight_land_rounded,
        ),
      ],
    );
  }

  Widget _buildAndroidSteps(BuildContext context) {
    return Column(
      key: const ValueKey('android_steps'),
      children: [
        _buildStepTile(
          stepNumber: '1',
          title: l10nPick(
            context,
            en: '1. Open SIM Manager',
            fa: '۱. مراجعه به بخش مدیریت سیم‌کارت',
            ar: '١. فتح إدارة بطاقة SIM',
            zh: '1. 打开 SIM 卡管理器',
          ),
          description: l10nPick(
            context,
            en: 'Connect to Wi-Fi. Go to Settings > Connections (or Network & Internet) > SIM Manager > tap "Add eSIM".',
            fa: 'به وای‌فای وصل شوید. به Settings > Connections > SIM manager رفته و Add eSIM را بزنید.',
            ar: 'اتصل بالواي فاي. اذهب إلى الإعدادات > الاتصالات > إدارة بطاقة SIM > إضافة eSIM.',
            zh: '连接 Wi-Fi，进入 设置 > 连接 > SIM卡管理器 > 点击“添加 eSIM”。',
          ),
          icon: Icons.sim_card_download_rounded,
        ),
        SizedBox(height: 10.h),
        _buildStepTile(
          stepNumber: '2',
          title: l10nPick(
            context,
            en: '2. Scan QR or Enter Activation Code',
            fa: '۲. اسکن بارکد یا ورود کد فعال‌سازی',
            ar: '٢. مسح الرمز أو إدخال رمز التفعيل',
            zh: '2. 扫码或输入激活码',
          ),
          description: l10nPick(
            context,
            en: 'Tap "Scan QR code from service provider" and point camera at the QR above, or tap "Enter activation code" to paste manually.',
            fa: 'گزینه Scan QR code را انتخاب کرده و بارکد را اسکن کنید یا کد فعال‌سازی را به صورت دستی وارد نمایید.',
            ar: 'اختر مسح رمز QR من مزود الخدمة وامسح الرمز، أو أدخل رمز التفعيل يدوياً.',
            zh: '点击“扫描运营商提供的二维码”对准上方扫码，或点击“输入激活码”手动粘贴。',
          ),
          icon: Icons.qr_code_scanner_rounded,
        ),
        SizedBox(height: 10.h),
        _buildStepTile(
          stepNumber: '3',
          title: l10nPick(
            context,
            en: '3. Enable Roaming at Destination',
            fa: '۳. روشن کردن رومینگ دیتا در مقصد',
            ar: '٣. تشغيل تجوال البيانات عند الوصول',
            zh: '3. 抵达目的地后开启漫游',
          ),
          description: l10nPick(
            context,
            en: 'Download the profile. Upon arrival in your destination country, turn on this eSIM and enable "Data Roaming" under Mobile Networks.',
            fa: 'پروفایل را دانلود کنید. پس از فرود در مقصد، این eSIM را فعال کرده و در Mobile networks گزینه Data Roaming را روشن نمایید.',
            ar: 'قم بتنزيل الملف. عند الوصول فعّل هذه الشريحة وشغّل تجوال البيانات في إعدادات شبكة الهاتف المحمول.',
            zh: '完成配置文件下载。抵达目的地后，启用该 eSIM 并在移动网络中开启“数据漫游”。',
          ),
          icon: Icons.flight_land_rounded,
        ),
      ],
    );
  }

  Widget _buildStepTile({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isDark = TravelTheme.isDark(context);
    return Container(
      padding: EdgeInsetsDirectional.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: TravelTheme.borderFor(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.r,
            height: 28.r,
            decoration: BoxDecoration(
              color: TravelTheme.primaryFor(context),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              stepNumber,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w800,
                    color: TravelTheme.textPrimaryFor(context),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: TravelTheme.textSecondaryFor(context),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
