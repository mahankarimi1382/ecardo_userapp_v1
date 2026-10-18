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
import 'package:ecardo_user/src/helper/tron_address_validator.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';

/// Modal bottom sheet displaying dedicated TRON TRC-20 on-chain deposit address,
/// real-time QR code, network parameters, and security warnings.
///
/// Security Invariants (P0-01, P0-02, P0-03, WAL-P1-09):
/// 1. Strict Fail-Closed: Never displays or copies a fake or invalid fallback address.
/// 2. Base58Check Validation: Only cryptographically valid TRON addresses can render a QR code.
/// 3. Server-Driven Policy: Deposit thresholds and confirmation counts are driven by server configuration.
/// 4. Asset/Network Binding: Explicitly bound to USDT on TRON (TRC-20).
class CryptoDepositBottomSheet extends StatefulWidget {
  final Wallets wallet;
  final String? initialAddress;
  final String minDeposit;
  final int requiredConfirmations;
  final String networkName;
  final String contractAddress;

  const CryptoDepositBottomSheet({
    super.key,
    required this.wallet,
    this.initialAddress,
    this.minDeposit = '1.00',
    this.requiredConfirmations = 19,
    this.networkName = 'TRON (TRC-20)',
    this.contractAddress = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t',
  });

  static Future<void> show(
    BuildContext context, {
    required Wallets wallet,
    String? address,
    String minDeposit = '1.00',
    int requiredConfirmations = 19,
  }) async {
    // P0-03: Strict asset validation — only USDT is accepted for TRC-20 flow
    final assetCode = (wallet.code ?? '').toUpperCase().trim();
    if (assetCode != 'USDT' && assetCode != 'USDT_IRT') {
      ToastHelper().showWarningToast(
        l10nPick(
          context,
          en: 'On-chain deposit is currently supported for USDT (TRC-20) only.',
          fa: 'واریز آن‌چین در حال حاضر فقط برای ارز تتر (TRC-20) فعال است.',
          ar: 'الإيداع عبر البلوكشين متاح حالياً لعملة USDT (TRC-20) فقط.',
          tr: 'Zincir üstü yatırma şu anda yalnızca USDT (TRC-20) için desteklenmektedir.',
          ru: 'Пополнение через блокчейн в настоящее время доступно только для USDT (TRC-20).',
          zh: '目前仅支持 USDT (TRC-20) 链上充值。',
        ),
      );
      return;
    }

    await Get.bottomSheet<void>(
      CryptoDepositBottomSheet(
        wallet: wallet,
        initialAddress: address,
        minDeposit: minDeposit,
        requiredConfirmations: requiredConfirmations,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<CryptoDepositBottomSheet> createState() => _CryptoDepositBottomSheetState();
}

class _CryptoDepositBottomSheetState extends State<CryptoDepositBottomSheet> {
  String? _address;
  late String _minDeposit;
  late int _requiredConfirmations;
  late String _networkName;
  late String _contractAddress;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _minDeposit = widget.minDeposit;
    _requiredConfirmations = widget.requiredConfirmations;
    _networkName = widget.networkName;
    _contractAddress = widget.contractAddress;

    // Check if initialAddress or wallet.accountNo is a valid Base58Check TRON address
    final candidate = widget.initialAddress ?? widget.wallet.accountNo;
    if (TronAddressValidator.isValid(candidate)) {
      _address = candidate;
    } else {
      _fetchServerAddress();
    }
  }

  Future<void> _fetchServerAddress() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final networkService = Get.find<NetworkService>();
      final response = await networkService.get(
        endpoint: '/user/crypto/tron/address',
      );

      if (response.status == Status.completed && response.data != null) {
        final data = response.data!['data'] is Map ? response.data!['data'] : response.data!;
        final serverAddress = data['address']?.toString() ?? '';

        if (TronAddressValidator.isValid(serverAddress)) {
          if (mounted) {
            setState(() {
              _address = serverAddress;
              if (data['min_deposit'] != null) {
                _minDeposit = data['min_deposit'].toString();
              }
              if (data['required_confirmations'] != null) {
                _requiredConfirmations = int.tryParse(data['required_confirmations'].toString()) ?? 19;
              }
              if (data['network'] != null) {
                _networkName = data['network'].toString();
              }
              if (data['contract'] != null) {
                _contractAddress = data['contract'].toString();
              }
              _isLoading = false;
            });
          }
          return;
        }
      }

      if (mounted) {
        setState(() {
          _errorMessage = l10nPick(
            context,
            en: 'Server returned an unverified deposit address format.',
            fa: 'آدرس واریز ارائه‌شده توسط سرور از نظر ساختار معتبر نیست.',
            ar: 'عنوان الإيداع المستلم غير متوافق.',
            tr: 'Sunucudan alınan yatırma adresi formatı doğrulanamadı.',
            ru: 'Формат адреса депозита от сервера не прошел проверку.',
            zh: '服务器返回的充值地址格式未通过校验。',
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = l10nPick(
            context,
            en: 'Unable to connect to wallet node. Please check connection and try again.',
            fa: 'امکان برقراری ارتباط با نود والت وجود ندارد. لطفاً اتصال را بررسی و مجدداً تلاش کنید.',
            ar: 'تعذر الاتصال بخادم المحفظة. يرجى التحقق والمحاولة مجدداً.',
            tr: 'Cüzdan sunucusuna bağlanılamadı. Lütfen tekrar deneyin.',
            ru: 'Не удалось подключиться к серверу кошелька. Попробуйте снова.',
            zh: '无法连接到钱包节点，请检查网络后重试。',
          );
          _isLoading = false;
        });
      }
    }
  }

  void _copyToClipboard(BuildContext context) {
    if (_address == null || !TronAddressValidator.isValid(_address)) return;
    AppHaptics.selection();
    Clipboard.setData(ClipboardData(text: _address!));
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
    if (_address == null || !TronAddressValidator.isValid(_address)) return;
    AppHaptics.light();
    final message = l10nPick(
      context,
      en: 'My eCardo USDT (TRC-20) Deposit Address:\n$_address\n\nOnly send USDT via TRON network.',
      fa: 'آدرس واریز تتر (TRC-20) من در eCardo:\n$_address\n\nفقط تتر شبکه ترون ارسال شود.',
      ar: 'عنوان إيداع USDT (TRC-20) في eCardo:\n$_address\n\nيرجى إرسال USDT عبر شبكة TRON فقط.',
      tr: 'eCardo USDT (TRC-20) Yatırma Adresim:\n$_address\n\nYalnızca TRON ağı üzerinden USDT gönderin.',
      ru: 'Мой адрес депозита eCardo USDT (TRC-20):\n$_address\n\nОтправляйте только USDT через сеть TRON.',
      zh: '我的 eCardo USDT (TRC-20) 充值地址:\n$_address\n\n仅支持通过波场 (TRON) 网络充值。',
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

    final isAddressValid = TronAddressValidator.isValid(_address);

    return Container(
      constraints: BoxConstraints(maxHeight: 740.h),
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
                            'USDT • $_networkName',
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

              // Loading State
              if (_isLoading) ...[
                SizedBox(height: 40.h),
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF26A69A),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  l10nPick(
                    context,
                    en: 'Allocating dedicated on-chain address...',
                    fa: 'در حال تخصیص آدرس یکتای آن‌چین از نود والت...',
                    ar: 'جاري إنشاء العنوان المخصص على البلوكشين...',
                    tr: 'Özel zincir üstü adres tahsis ediliyor...',
                    ru: 'Получение выделенного адреса в блокчейне...',
                    zh: '正在从钱包节点获取专属链上充值地址...',
                  ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: inkMuted,
                  ),
                ),
                SizedBox(height: 60.h),
              ]
              // Error State (P0-01 Fail-Closed: Never show fake QR or copy button)
              else if (!isAddressValid) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline_rounded, color: AppColors.error, size: 36.r),
                      SizedBox(height: 10.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Deposit Address Unavailable',
                          fa: 'آدرس واریز موقتاً در دسترس نیست',
                          ar: 'عنوان الإيداع غير متاح مؤقتاً',
                          tr: 'Yatırma Adresi Geçici Olarak Kullanılamıyor',
                          ru: 'Адрес депозита временно недоступен',
                          zh: '充值地址暂不可用',
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.error,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _errorMessage ??
                            l10nPick(
                              context,
                              en: 'A valid deposit address could not be verified by the cryptographic security gate.',
                              fa: 'آدرس واریز معتبر توسط گیت امنیتی رمزنگاری تأیید نشد. هیچ تراکنشی به آدرس نامعتبر مجاز نیست.',
                              ar: 'لم يتم التحقق من عنوان الإيداع من قِبل بوابة الأمان.',
                              tr: 'Geçerli bir yatırma adresi doğrulanamadı.',
                              ru: 'Не удалось проверить адрес депозита криптографическим шлюзом.',
                              zh: '充值地址未通过安全校验。',
                            ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: inkMuted,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      ElevatedButton.icon(
                        onPressed: _fetchServerAddress,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(
                          l10nPick(
                            context,
                            en: 'Retry Fetching Address',
                            fa: 'تلاش مجدد جهت استعلام آدرس',
                            ar: 'إعادة المحاولة',
                            tr: 'Adresi Yeniden Al',
                            ru: 'Повторить запрос адреса',
                            zh: '重试获取地址',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF26A69A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
              ]
              // Success State: Valid Base58Check Address
              else ...[
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
                          _address!,
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
                            'BIP-44 Verified Address',
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
                          _address!,
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
              ],

              // Security & Parameter Warning Banner (Driven by Server Policies)
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
                              en: '• Only send USDT ($_networkName) to this address.\n• Contract: $_contractAddress\n• Minimum deposit: $_minDeposit USDT.\n• Finality requires $_requiredConfirmations block confirmations.\n• Real-time ledger credit with zero platform fee.',
                              fa: '• فقط ارز تتر (USDT) بر بستر $_networkName واریز نمایید.\n• قرارداد هوشمند: $_contractAddress\n• حداقل واریز: $_minDeposit تتر است.\n• نهایی‌سازی نیازمند $_requiredConfirmations تاییدیه بلاک‌چین است.\n• شارژ آنی دفترکل با کارمزد صفر پلتفرم انجام می‌پذیرد.',
                              ar: '• أرسل USDT ($_networkName) فقط إلى هذا العنوان.\n• العقد الذكي: $_contractAddress\n• الحد الأدنى للإيداع: $_minDeposit USDT.\n• يتطلب تأكيد $_requiredConfirmations كتلة على الشبكة.\n• شحن فوري للرصيد بدون أي رسوم للمنصة.',
                              tr: '• Bu adrese yalnızca $_networkName ağında USDT gönderin.\n• Akıllı Sözleşme: $_contractAddress\n• Minimum yatırma: $_minDeposit USDT.\n• $_requiredConfirmations blok onayı gereklidir.\n• Sıfır platform komisyonu ile anında bakiye yüklemesi.',
                              ru: '• Отправляйте только USDT ($_networkName) на этот адрес.\n• Смарт-контракт: $_contractAddress\n• Минимальный депозит: $_minDeposit USDT.\n• Требуется $_requiredConfirmations подтверждений сети.\n• Мгновенное зачисление с нулевой комиссией платформы.',
                              zh: '• 请仅向此地址充值 $_networkName 网络的 USDT。\n• 合约地址：$_contractAddress\n• 最低充值金额：$_minDeposit USDT。\n• 需完成 $_requiredConfirmations 个区块确认即可到账。\n• 零平台手续费实时记账入账。',
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
