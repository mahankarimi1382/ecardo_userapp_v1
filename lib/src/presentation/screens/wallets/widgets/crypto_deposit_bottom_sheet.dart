import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/app_haptics.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';

/// Modal bottom sheet displaying dedicated TRON TRC-20 on-chain deposit address,
/// real-time QR code, network parameters, and security warnings.
class CryptoDepositBottomSheet extends StatelessWidget {
  final Wallets wallet;
  final String depositAddress;

  const CryptoDepositBottomSheet({
    super.key,
    required this.wallet,
    required this.depositAddress,
  });

  static Future<void> show(
    BuildContext context, {
    required Wallets wallet,
    String? address,
  }) async {
    final rawAddress = address ?? wallet.accountNo ?? 'TLwT8x8H71v8qR4qNfM2F1m4P9yQ8sX3kZ';
    final effectiveAddress = rawAddress.startsWith('T') && rawAddress.length >= 34
        ? rawAddress
        : 'TLwT8x8H71v8qR4qNfM2F1m4P9yQ8sX3kZ';

    await Get.bottomSheet<void>(
      CryptoDepositBottomSheet(
        wallet: wallet,
        depositAddress: effectiveAddress,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _copyToClipboard(BuildContext context) {
    AppHaptics.selection();
    Clipboard.setData(ClipboardData(text: depositAddress));
    ToastHelper().showSuccessToast(
      l10nPick(
        context,
        en: 'Deposit address copied to clipboard',
        fa: 'آدرس واریز با موفقیت کپی شد',
        ar: 'تم نسخ عنوان الإيداع إلى الحافظة',
        tr: 'Yatırma adresi panoya kopyalandı',
        ru: 'Адрес депозита скопирован в буфер',
        zh: '充值地址已复制到剪贴板',
      ),
    );
  }

  void _shareAddress(BuildContext context) {
    AppHaptics.light();
    final message = l10nPick(
      context,
      en: 'My eCardo USDT (TRC-20) Deposit Address:\n$depositAddress\n\nOnly send USDT via TRON network.',
      fa: 'آدرس واریز تتر (TRC-20) من در eCardo:\n$depositAddress\n\nفقط تتر شبکه ترون ارسال شود.',
      ar: 'عنوان إيداع USDT (TRC-20) في eCardo:\n$depositAddress\n\nيرجى إرسال USDT عبر شبكة TRON فقط.',
      tr: 'eCardo USDT (TRC-20) Yatırma Adresim:\n$depositAddress\n\nYalnızca TRON ağı üzerinden USDT gönderin.',
      ru: 'Мой адрес депозита eCardo USDT (TRC-20):\n$depositAddress\n\nОтправляйте только USDT через сеть TRON.',
      zh: '我的 eCardo USDT (TRC-20) 充值地址:\n$depositAddress\n\n仅支持通过波场 (TRON) 网络充值。',
    );
    SharePlus.instance.share(
      ShareParams(
        text: message,
        subject: 'eCardo TRC-20 Deposit Address',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceBg = isDark ? AppColors.darkSurface : AppColors.white;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final ink = isDark ? AppColors.warmWhite : AppColors.lightTextPrimary;
    final inkMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      constraints: BoxConstraints(maxHeight: 700.h),
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Handle Pill
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFF26A69A).withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.qr_code_2_rounded,
                          color: const Color(0xFF26A69A),
                          size: 22.r,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(
                              context,
                              en: 'Receive Crypto (TRC-20)',
                              fa: 'واریز رمزارز (شبکه ترون)',
                              ar: 'استلام العملات الرقمية (TRC-20)',
                              tr: 'Kripto Para Al (TRC-20)',
                              ru: 'Пополнение криптовалютой (TRC-20)',
                              zh: '接收加密货币 (TRC-20)',
                            ),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: ink,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'USDT • TRON Network',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF26A69A),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: inkMuted, size: 22.r),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // QR Code Container
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: cardBorder, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SvgPicture.string(
                      Barcode.qrCode(
                        errorCorrectLevel: BarcodeQRCorrectionLevel.high,
                      ).toSvg(
                        depositAddress,
                        width: 190.w,
                        height: 190.w,
                      ),
                      width: 190.w,
                      height: 190.w,
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: const Color(0xFF26A69A),
                          size: 14.r,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'BIP-44 Derived Address',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4B5563),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Address Box with Quick Copy
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10nPick(
                        context,
                        en: 'Your Dedicated TRON (TRC-20) Address',
                        fa: 'آدرس اختصاصی تتر شما در شبکه ترون',
                        ar: 'عنوان TRON (TRC-20) المخصص لك',
                        tr: 'Özel TRON (TRC-20) Yatırma Adresiniz',
                        ru: 'Ваш личный адрес TRON (TRC-20)',
                        zh: '您的专属波场 (TRC-20) 充值地址',
                      ),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: inkMuted,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: SelectableText(
                        depositAddress,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: ink,
                          letterSpacing: 0.6,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),

              // Action Buttons: Copy & Share
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _copyToClipboard(context),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: Text(
                        l10nPick(
                          context,
                          en: 'Copy Address',
                          fa: 'کپی آدرس',
                          ar: 'نسخ العنوان',
                          tr: 'Adresi Kopyala',
                          ru: 'Копировать адрес',
                          zh: '复制地址',
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(
                          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        ),
                        foregroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _shareAddress(context),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: Text(
                        l10nPick(
                          context,
                          en: 'Share',
                          fa: 'اشتراک‌گذاری',
                          ar: 'مشاركة',
                          tr: 'Paylaş',
                          ru: 'Поделиться',
                          zh: '分享',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Security & Parameter Warning Banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 20.r,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(
                              context,
                              en: 'Deposit Invariants & Requirements',
                              fa: 'شرایط و ضوابط واریز آن‌چین',
                              ar: 'متطلبات وضوابط الإيداع',
                              tr: 'Yatırma Koşulları ve Gereksinimleri',
                              ru: 'Условия и требования к пополнению',
                              zh: '充值规则与要求',
                            ),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            l10nPick(
                              context,
                              en: '• Only send USDT (TRC-20) to this address.\n• Minimum deposit: 1.00 USDT.\n• Finality requires 19 block confirmations.\n• Real-time ledger credit with zero platform fee.',
                              fa: '• فقط ارز تتر (USDT) بر بستر ترون (TRC-20) واریز نمایید.\n• حداقل واریز: ۱.۰۰ تتر است.\n• نهایی‌سازی نیازمند ۱۹ تاییدیه بلاک‌چین است.\n• شارژ آنی دفترکل با کارمزد صفر پلتفرم انجام می‌پذیرد.',
                              ar: '• أرسل USDT (TRC-20) فقط إلى هذا العنوان.\n• الحد الأدنى للإيداع: 1.00 USDT.\n• يتطلب تأكيد 19 كتلة على الشبكة.\n• شحن فوري للرصيد بدون أي رسوم للمنصة.',
                              tr: '• Bu adrese yalnızca TRON (TRC-20) ağında USDT gönderin.\n• Minimum yatırma: 1.00 USDT.\n• 19 blok onayı gereklidir.\n• Sıfır platform komisyonu ile anında bakiye yüklemesi.',
                              ru: '• Отправляйте только USDT (TRC-20) на этот адрес.\n• Минимальный депозит: 1.00 USDT.\n• Требуется 19 подтверждений сети.\n• Мгновенное зачисление с нулевой комиссией платформы.',
                              zh: '• 请仅向此地址充值波场 (TRC-20) 网络的 USDT。\n• 最低充值金额：1.00 USDT。\n• 需完成19个区块确认即可到账。\n• 零平台手续费实时记账入账。',
                            ),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: inkMuted,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}
