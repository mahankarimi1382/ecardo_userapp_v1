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
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/crypto_deposit_policy.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';

/// Modal bottom sheet displaying the dedicated TRON TRC-20 USDT deposit
/// assignment returned by the authenticated eCardo backend.
///
/// Security invariants:
/// 1. Strict fail-closed: the widget never derives an address from
///    `wallet.accountNo`, `initialAddress`, a cache or a hard-coded default.
/// 2. Every policy field (wallet id, assignment id, chain, asset, network,
///    contract, minimum, confirmations, expiry) must be present and valid
///    together; otherwise no QR, copy or share action is rendered.
/// 3. The on-chain feature can be disabled server-side; the sheet then shows
///    an explicit "temporarily unavailable" state with no address.
class CryptoDepositBottomSheet extends StatefulWidget {
  final Wallets wallet;

  const CryptoDepositBottomSheet({super.key, required this.wallet});

  static Future<void> show(
    BuildContext context, {
    required Wallets wallet,
  }) async {
    // WAL-175-03 & WAL-175-04: only USDT has an on-chain TRC-20 assignment.
    // USDT_IRT is an internal conversion pair and must never reach this flow.
    final assetCode = (wallet.code ?? '').toUpperCase().trim();
    if (assetCode != 'USDT') {
      ToastHelper().showWarningToast(
        l10nPick(
          context,
          en: 'On-chain deposit is available for USDT (TRC-20) only.',
          fa: 'واریز آن‌چین فقط برای تتر (USDT) بر بستر ترون فعال است. جفت USDT_IRT داخلی است و آدرس آن‌چین ندارد.',
          ar: 'الإيداع عبر البلوكشين متاح لعملة USDT (TRC-20) فقط.',
          tr: 'Zincir üstü yatırma yalnızca USDT (TRC-20) için geçerlidir.',
          ru: 'Пополнение через блокчейн доступно только для USDT (TRC-20).',
          zh: '链上充值仅支持 USDT (TRC-20)。',
        ),
      );
      return;
    }

    await Get.bottomSheet<void>(
      CryptoDepositBottomSheet(wallet: wallet),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<CryptoDepositBottomSheet> createState() =>
      _CryptoDepositBottomSheetState();
}

class _CryptoDepositBottomSheetState extends State<CryptoDepositBottomSheet> {
  CryptoDepositPolicy? _policy;
  bool _isLoading = true;
  bool _depositsDisabled = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPolicy();
  }

  Future<void> _fetchPolicy() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _depositsDisabled = false;
      _policy = null;
      _errorMessage = null;
    });

    try {
      final networkService = Get.find<NetworkService>();
      final response = await networkService.get(
        endpoint: '/user/crypto-wallet/address?chain=TRON&asset=USDT',
      );

      if (response.status != Status.completed || response.data == null) {
        _showNetworkError();
        return;
      }

      final rawData = response.data!['data'];
      if (rawData is! Map) {
        _showInvalidResponse();
        return;
      }

      final map = Map<String, dynamic>.from(rawData);
      final enabledFlag = map['deposits_enabled'];
      final isExplicitlyDisabled =
          enabledFlag == false ||
          enabledFlag == 0 ||
          enabledFlag?.toString().trim().toLowerCase() == 'false';
      if (isExplicitlyDisabled) {
        if (mounted) {
          setState(() {
            _depositsDisabled = true;
            _isLoading = false;
            final serverMessage = response.data!['message']?.toString().trim();
            _errorMessage = (serverMessage != null && serverMessage.isNotEmpty)
                ? serverMessage
                : null;
          });
        }
        return;
      }

      final policy = CryptoDepositPolicy.fromServerData(map);
      if (mounted) {
        setState(() {
          _policy = policy;
          _isLoading = false;
        });
      }
    } on CryptoDepositPolicyException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = _policyErrorMessage(error.error);
          _isLoading = false;
        });
      }
    } catch (_) {
      _showNetworkError();
    }
  }

  void _showNetworkError() {
    if (!mounted) return;
    setState(() {
      _errorMessage = l10nPick(
        context,
        en: 'Unable to reach the wallet service. Check your connection and try again.',
        fa: 'امکان برقراری ارتباط با سرویس کیف پول وجود ندارد. اتصال را بررسی و مجدداً تلاش کنید.',
        ar: 'تعذر الاتصال بخدمة المحفظة. تحقق من الاتصال وحاول مجدداً.',
        tr: 'Cüzdan servisine ulaşılamadı. Bağlantınızı kontrol edip tekrar deneyin.',
        ru: 'Не удалось связаться с сервисом кошелька. Проверьте соединение и повторите попытку.',
        zh: '无法连接钱包服务，请检查网络后重试。',
      );
      _isLoading = false;
    });
  }

  void _showInvalidResponse() {
    if (!mounted) return;
    setState(() {
      _errorMessage = _policyErrorMessage(
        CryptoDepositPolicyError.missingField,
      );
      _isLoading = false;
    });
  }

  String _policyErrorMessage(CryptoDepositPolicyError error) {
    switch (error) {
      case CryptoDepositPolicyError.depositsDisabled:
        return l10nPick(
          context,
          en: 'On-chain deposits are temporarily disabled pending infrastructure verification.',
          fa: 'واریز آن‌چین موقتاً غیرفعال است؛ زیرساخت زنجیره در حال راستی‌آزمایی است.',
          ar: 'الإيداع عبر البلوكشين معطل مؤقتاً ريثما يتم التحقق من البنية التحتية.',
          tr: 'Zincir üstü yatırma, altyapı doğrulaması tamamlanana kadar geçici olarak devre dışı.',
          ru: 'Пополнение через блокчейн временно отключено до завершения проверки инфраструктуры.',
          zh: '链上充值暂时停用，等待基础设施验证。',
        );
      case CryptoDepositPolicyError.expiredAssignment:
        return l10nPick(
          context,
          en: 'This deposit assignment has expired. Request a fresh address.',
          fa: 'مهلت این تخصیص واریز به پایان رسیده است. آدرس جدید دریافت کنید.',
          ar: 'انتهت صلاحية تخصيص الإيداع. اطلب عنواناً جديداً.',
          tr: 'Bu yatırma atamasının süresi doldu. Yeni adres isteyin.',
          ru: 'Срок действия назначения депозита истёк. Запросите новый адрес.',
          zh: '此充值分配已过期，请重新获取地址。',
        );
      case CryptoDepositPolicyError.missingField:
      case CryptoDepositPolicyError.invalidWalletId:
      case CryptoDepositPolicyError.unsupportedChain:
      case CryptoDepositPolicyError.unsupportedAsset:
      case CryptoDepositPolicyError.unsupportedNetwork:
      case CryptoDepositPolicyError.untrustedContract:
      case CryptoDepositPolicyError.invalidAddress:
      case CryptoDepositPolicyError.invalidMinimumDeposit:
      case CryptoDepositPolicyError.invalidConfirmations:
      case CryptoDepositPolicyError.invalidExpiry:
        return l10nPick(
          context,
          en: 'The server response did not pass the deposit security checks. No address is shown.',
          fa: 'پاسخ سرور از بررسی‌های امنیتی واریز عبور نکرد؛ برای محافظت از دارایی شما هیچ آدرسی نمایش داده نمی‌شود.',
          ar: 'لم يجتز رد الخادم فحوصات أمان الإيداع. لا يتم عرض أي عنوان.',
          tr: 'Sunucu yanıtı yatırma güvenlik kontrollerini geçemedi. Adres gösterilmiyor.',
          ru: 'Ответ сервера не прошёл проверки безопасности депозита. Адрес не отображается.',
          zh: '服务器响应未通过充值安全检查，不显示地址。',
        );
    }
  }

  void _copyToClipboard(BuildContext context) {
    final policy = _policy;
    if (policy == null) return;
    AppHaptics.selection();
    Clipboard.setData(ClipboardData(text: policy.depositAddress));
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
    final policy = _policy;
    if (policy == null) return;
    AppHaptics.light();
    final message = l10nPick(
      context,
      en: 'My eCardo USDT (TRC-20) Deposit Address:\n${policy.depositAddress}\n\nOnly send USDT via the TRON network.',
      fa: 'آدرس واریز تتر (TRC-20) من در eCardo:\n${policy.depositAddress}\n\nفقط تتر شبکه ترون ارسال شود.',
      ar: 'عنوان إيداع USDT (TRC-20) في eCardo:\n${policy.depositAddress}\n\nيرجى إرسال USDT عبر شبكة TRON فقط.',
      tr: 'eCardo USDT (TRC-20) Yatırma Adresim:\n${policy.depositAddress}\n\nYalnızca TRON ağı üzerinden USDT gönderin.',
      ru: 'Мой адрес депозита eCardo USDT (TRC-20):\n${policy.depositAddress}\n\nОтправляйте только USDT через сеть TRON.',
      zh: '我的 eCardo USDT (TRC-20) 充值地址:\n${policy.depositAddress}\n\n仅支持通过波场 (TRON) 网络充值。',
    );
    SharePlus.instance.share(
      ShareParams(text: message, subject: 'eCardo TRC-20 Deposit Address'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceBg = isDark ? AppColors.darkSurface : AppColors.white;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final ink = isDark ? AppColors.warmWhite : AppColors.lightTextPrimary;
    final inkMuted = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final policy = _policy;
    final hasValidPolicy = policy != null;

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
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
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
                          color: const Color(
                            0xFF26A69A,
                          ).withValues(alpha: 0.14),
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
                            'USDT • ${policy?.network ?? 'TRC20'}',
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
                    icon: Icon(
                      Icons.close_rounded,
                      color: inkMuted,
                      size: 22.r,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Loading State
              if (_isLoading) ...[
                SizedBox(height: 40.h),
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFF26A69A)),
                ),
                SizedBox(height: 16.h),
                Text(
                  l10nPick(
                    context,
                    en: 'Verifying your dedicated on-chain assignment...',
                    fa: 'در حال راستی‌آزمایی تخصیص اختصاصی آن‌چین شما...',
                    ar: 'جاري التحقق من تخصيصك المخصص على البلوكشين...',
                    tr: 'Özel zincir üstü atamanız doğrulanıyor...',
                    ru: 'Проверка вашего персонального назначения в блокчейне...',
                    zh: '正在验证您的专属链上分配...',
                  ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: inkMuted,
                  ),
                ),
                SizedBox(height: 60.h),
              ]
              // Fail-closed error / disabled state: no QR, no copy, no share.
              else if (!hasValidPolicy) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color:
                        (_depositsDisabled
                                ? const Color(0xFFF59E0B)
                                : AppColors.error)
                            .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color:
                          (_depositsDisabled
                                  ? const Color(0xFFF59E0B)
                                  : AppColors.error)
                              .withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _depositsDisabled
                            ? Icons.pause_circle_outline_rounded
                            : Icons.error_outline_rounded,
                        color: _depositsDisabled
                            ? const Color(0xFFF59E0B)
                            : AppColors.error,
                        size: 36.r,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        _depositsDisabled
                            ? l10nPick(
                                context,
                                en: 'On-chain Deposit Temporarily Disabled',
                                fa: 'واریز آن‌چین موقتاً غیرفعال است',
                                ar: 'الإيداع عبر البلوكشين معطل مؤقتاً',
                                tr: 'Zincir Üstü Yatırma Geçici Olarak Kapalı',
                                ru: 'Пополнение через блокчейн временно отключено',
                                zh: '链上充值暂时停用',
                              )
                            : l10nPick(
                                context,
                                en: 'Deposit Address Unavailable',
                                fa: 'آدرس واریز موقتاً در دسترس نیست',
                                ar: 'عنوان الإيداع غير متاح مؤقتاً',
                                tr: 'Yatırma Adresi Geçici Olarak Kullanılamıyor',
                                ru: 'Адрес депозита временно недоступен',
                                zh: '充值地址暂不可用',
                              ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: _depositsDisabled
                              ? const Color(0xFFF59E0B)
                              : AppColors.error,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _errorMessage ??
                            l10nPick(
                              context,
                              en: 'A valid, wallet-bound deposit assignment could not be verified. No address will be shown until the server policy is complete.',
                              fa: 'تخصیص واریز معتبر و متصل به کیف پول تأیید نشد. تا تکمیل سیاست سرور هیچ آدرسی نمایش داده نمی‌شود.',
                              ar: 'لم يتم التحقق من تخصيص إيداع صالح مرتبط بالمحفظة. لن يظهر أي عنوان حتى تكتمل سياسة الخادم.',
                              tr: 'Cüzdana bağlı geçerli bir yatırma ataması doğrulanamadı. Sunucu politikası tamamlanana kadar adres gösterilmez.',
                              ru: 'Не удалось проверить действительное назначение депозита, привязанное к кошельку. Адрес не будет показан до завершения политики сервера.',
                              zh: '无法验证有效的钱包绑定充值分配。在服务器策略完整前不会显示地址。',
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
                        onPressed: _fetchPolicy,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(
                          l10nPick(
                            context,
                            en: 'Retry',
                            fa: 'تلاش مجدد',
                            ar: 'إعادة المحاولة',
                            tr: 'Yeniden Dene',
                            ru: 'Повторить',
                            zh: '重试',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _depositsDisabled
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF26A69A),
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
              // Success State: fully-validated assignment only.
              else ...[
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
                          policy.depositAddress,
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
                            'Checksum-verified TRON address',
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

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightBackground,
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
                          policy.depositAddress,
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
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                          ),
                          foregroundColor: isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
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
                          backgroundColor: isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                          foregroundColor: isDark
                              ? AppColors.deepBlack
                              : AppColors.white,
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

              // Security & policy banner — values come only from the policy.
              if (hasValidPolicy)
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
                                en: 'Deposit Requirements',
                                fa: 'شرایط و ضوابط واریز آن‌چین',
                                ar: 'متطلبات الإيداع',
                                tr: 'Yatırma Koşulları',
                                ru: 'Требования к пополнению',
                                zh: '充值规则',
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
                                en:
                                    '• Only send USDT on ${policy.network} to this address.\n'
                                    '• Contract: ${policy.contractAddress}\n'
                                    '• Minimum deposit: ${policy.minimumDeposit.toStringAsFixed(2)} USDT.\n'
                                    '• Finality requires ${policy.requiredConfirmations} block confirmations.\n'
                                    '• Your balance is credited after on-chain finality and server reconciliation.',
                                fa:
                                    '• فقط تتر (USDT) بر بستر ${policy.network} به این آدرس واریز کنید.\n'
                                    '• قرارداد هوشمند: ${policy.contractAddress}\n'
                                    '• حداقل واریز: ${policy.minimumDeposit.toStringAsFixed(2)} تتر.\n'
                                    '• نهایی‌سازی نیازمند ${policy.requiredConfirmations} تأییدیه بلاک است.\n'
                                    '• موجودی پس از نهایی‌سازی زنجیره و تطبیق سمت سرور به حساب شما اضافه می‌شود.',
                                ar:
                                    '• أرسل USDT على ${policy.network} فقط إلى هذا العنوان.\n'
                                    '• العقد الذكي: ${policy.contractAddress}\n'
                                    '• الحد الأدنى: ${policy.minimumDeposit.toStringAsFixed(2)} USDT.\n'
                                    '• يتطلب ${policy.requiredConfirmations} تأكيد كتلة.\n'
                                    '• يُضاف الرصيد بعد نهائية الشبكة والتسوية من الخادم.',
                                tr:
                                    '• Bu adrese yalnızca ${policy.network} ağında USDT gönderin.\n'
                                    '• Akıllı sözleşme: ${policy.contractAddress}\n'
                                    '• Minimum: ${policy.minimumDeposit.toStringAsFixed(2)} USDT.\n'
                                    '• ${policy.requiredConfirmations} blok onayı gerekir.\n'
                                    '• Bakiye zincir finalitesi ve sunucu mutabakatından sonra eklenir.',
                                ru:
                                    '• Отправляйте только USDT (${policy.network}) на этот адрес.\n'
                                    '• Контракт: ${policy.contractAddress}\n'
                                    '• Минимум: ${policy.minimumDeposit.toStringAsFixed(2)} USDT.\n'
                                    '• Требуется ${policy.requiredConfirmations} подтверждений.\n'
                                    '• Баланс зачисляется после финальности сети и сверки на сервере.',
                                zh:
                                    '• 请仅通过 ${policy.network} 网络向此地址充值 USDT。\n'
                                    '• 合约地址：${policy.contractAddress}\n'
                                    '• 最低充值：${policy.minimumDeposit.toStringAsFixed(2)} USDT。\n'
                                    '• 需要 ${policy.requiredConfirmations} 个区块确认。\n'
                                    '• 链上最终确认及服务器对账后入账。',
                              ),
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: inkMuted,
                                height: 1.5,
                              ),
                            ),
                            if (policy.expiresAt != null) ...[
                              SizedBox(height: 6.h),
                              Text(
                                l10nPick(
                                  context,
                                  en: 'Assignment valid until ${policy.expiresAt!.toLocal()}.',
                                  fa: 'اعتبار این تخصیص تا ${policy.expiresAt!.toLocal()} است.',
                                  ar: 'التخصيص صالح حتى ${policy.expiresAt!.toLocal()}.',
                                  tr: 'Atama ${policy.expiresAt!.toLocal()} tarihine kadar geçerli.',
                                  ru: 'Назначение действительно до ${policy.expiresAt!.toLocal()}.',
                                  zh: '分配有效期至 ${policy.expiresAt!.toLocal()}。',
                                ),
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: inkMuted,
                                ),
                              ),
                            ],
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
