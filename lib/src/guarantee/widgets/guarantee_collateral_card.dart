import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';

/// Supported types of collateral for Bank Guarantee (LG) requests.
enum GuaranteeCollateralType {
  /// Cash Deposit in Escrow Wallet (سپرده نقدی مسدودشده در کیف‌پول)
  cash(
    id: 'CASH_DEPOSIT',
    titleFa: 'سپرده نقدی در کیف‌پول',
    titleEn: 'Cash Deposit (Escrow)',
    descFa: 'سپرده نقدی مسدودشده در کیف‌پول پلتفرم با دسترسی امن',
    descEn: 'Cash deposit locked in platform escrow wallet',
    ltvPct: 100,
    icon: Icons.account_balance_wallet_rounded,
    themeColor: Color(0xFF0D9488),
  ),

  /// Crypto / USDT Collateral at 120% LTV (وثیقه تتر با نسبت LTV 120%)
  cryptoUsdt(
    id: 'CRYPTO_USDT',
    titleFa: 'وثیقه تتر (USDT Collateral)',
    titleEn: 'Crypto / USDT (120% LTV)',
    descFa: 'وثیقه تتر با نسبت LTV ۱۲۰٪ در قرارداد هوشمند امانی',
    descEn: 'USDT collateral locked in escrow smart contract at 120% LTV',
    ltvPct: 120,
    icon: Icons.currency_bitcoin_rounded,
    themeColor: Color(0xFF2563EB),
  ),

  /// Digital Promissory Note / Sayad Check (سفته الکترونیک / چک صیادی)
  promissoryNote(
    id: 'DIGITAL_PROMISSORY',
    titleFa: 'سفته الکترونیک / چک صیادی',
    titleEn: 'Promissory Note / Check',
    descFa: 'سفته الکترونیک با شناسه یکتا یا چک صیادی ثبت‌شده',
    descEn: 'Digital promissory note or verified Sayad check',
    ltvPct: 110,
    icon: Icons.receipt_long_rounded,
    themeColor: Color(0xFF7C3AED),
  ),

  /// Real Estate / Bank Deposit Certificate (گواهی سپرده بانکی / سند ملکی)
  bankCertificate(
    id: 'REAL_ESTATE_CERTIFICATE',
    titleFa: 'گواهی سپرده / سند ملکی',
    titleEn: 'Bank Certificate / Real Estate',
    descFa: 'گواهی سپرده عام بانکی یا توثیق رسمی سند تک‌برگ ملکی',
    descEn: 'Bank deposit certificate or registered property deed mortgage',
    ltvPct: 130,
    icon: Icons.apartment_rounded,
    themeColor: Color(0xFFD97706),
  );

  final String id;
  final String titleFa;
  final String titleEn;
  final String descFa;
  final String descEn;
  final int ltvPct;
  final IconData icon;
  final Color themeColor;

  const GuaranteeCollateralType({
    required this.id,
    required this.titleFa,
    required this.titleEn,
    required this.descFa,
    required this.descEn,
    required this.ltvPct,
    required this.icon,
    required this.themeColor,
  });
}

/// Interactive Collateral Selection & Deposit Card for Bank Guarantee requests.
///
/// Features:
/// 1. Collateral type selector with icons, required LTV ratio pills, and coverage indicators.
/// 2. Live wallet balance check vs required collateral (Sufficient green pill or Top-Up Required warning).
/// 3. Terms of collateral release notice (released upon beneficiary discharge or contract completion).
class GuaranteeCollateralCard extends StatefulWidget {
  final double guaranteeAmount;
  final double marginPct;
  final String currency;
  final GuaranteeCollateralType initialType;
  final ValueChanged<GuaranteeCollateralType>? onCollateralTypeChanged;
  final VoidCallback? onTopUpPressed;

  const GuaranteeCollateralCard({
    super.key,
    required this.guaranteeAmount,
    this.marginPct = 10.0,
    this.currency = 'IRR',
    this.initialType = GuaranteeCollateralType.cash,
    this.onCollateralTypeChanged,
    this.onTopUpPressed,
  });

  @override
  State<GuaranteeCollateralCard> createState() => _GuaranteeCollateralCardState();
}

class _GuaranteeCollateralCardState extends State<GuaranteeCollateralCard> {
  late GuaranteeCollateralType _selectedType;

  // Approximate USDT / IRR conversion rate for coverage display purposes
  static const double _irrPerUsdt = 1000000.0;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void didUpdateWidget(covariant GuaranteeCollateralCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialType != widget.initialType) {
      _selectedType = widget.initialType;
    }
  }

  void _selectType(GuaranteeCollateralType type) {
    if (_selectedType == type) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedType = type);
    widget.onCollateralTypeChanged?.call(type);
  }

  double get _baseMarginAmount {
    if (widget.guaranteeAmount <= 0) return 0.0;
    return widget.guaranteeAmount * (widget.marginPct / 100.0);
  }

  double get _requiredCoverageAmount {
    return _baseMarginAmount * (_selectedType.ltvPct / 100.0);
  }

  double get _requiredUsdtAmount {
    if (widget.currency.toUpperCase() == 'USDT' || widget.currency.toUpperCase() == 'USD') {
      return _requiredCoverageAmount;
    }
    return _requiredCoverageAmount / _irrPerUsdt;
  }

  /// Live wallet balance detection from HomeController
  ({double balance, String code, bool found}) _detectLiveWalletBalance() {
    try {
      if (!Get.isRegistered<HomeController>()) {
        return (balance: 0.0, code: widget.currency, found: false);
      }
      final homeController = Get.find<HomeController>();
      final wallets = homeController.walletsList;

      if (_selectedType == GuaranteeCollateralType.cryptoUsdt) {
        final usdtWallet = wallets.firstWhereOrNull(
          (w) => (w.code ?? '').toUpperCase() == 'USDT' || w.isCrypto == true,
        );
        if (usdtWallet != null) {
          final b = double.tryParse(usdtWallet.balance?.replaceAll(',', '') ?? '0') ?? 0.0;
          return (balance: b, code: 'USDT', found: true);
        }
        return (balance: 0.0, code: 'USDT', found: false);
      }

      // Cash or others: Match guarantee currency
      final targetCode = widget.currency.toUpperCase();
      final matchWallet = wallets.firstWhereOrNull(
        (w) => (w.code ?? '').toUpperCase() == targetCode,
      );
      if (matchWallet != null) {
        final b = double.tryParse(matchWallet.balance?.replaceAll(',', '') ?? '0') ?? 0.0;
        return (balance: b, code: targetCode, found: true);
      }

      // Fallback to first fiat wallet or userModel balance
      if (wallets.isNotEmpty) {
        final first = wallets.first;
        final b = double.tryParse(first.balance?.replaceAll(',', '') ?? '0') ?? 0.0;
        return (balance: b, code: first.code ?? targetCode, found: true);
      }

      final userBalanceStr = homeController.userModel.value.data?.balance;
      if (userBalanceStr != null && userBalanceStr.isNotEmpty) {
        final b = double.tryParse(userBalanceStr.replaceAll(',', '')) ?? 0.0;
        return (balance: b, code: targetCode, found: true);
      }
    } catch (_) {}

    return (balance: 0.0, code: widget.currency, found: false);
  }

  String _formatAmount(double amount) {
    if (amount <= 0) return '0';
    final isInt = (amount.truncateToDouble() == amount);
    final fixed = isInt ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
  }

  @override
  Widget build(BuildContext context) {
    final liveWallet = _detectLiveWalletBalance();
    final isCryptoType = _selectedType == GuaranteeCollateralType.cryptoUsdt;
    final targetNeeded = isCryptoType ? _requiredUsdtAmount : _requiredCoverageAmount;
    final isSufficient = liveWallet.balance >= targetNeeded && targetNeeded > 0;
    final deficit = (targetNeeded - liveWallet.balance).clamp(0.0, double.infinity);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.lightBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title and explanation
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.lock_clock_rounded,
                  color: const Color(0xFF0D9488),
                  size: 22.sp,
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
                        fa: 'تودیع وثیقه و وجه التزام بانکی',
                        en: 'Guarantee Collateral & Margin',
                        ar: 'تأمين الضمان والغطاء المصرفي',
                        zh: '保函保证金与反担保抵押',
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      l10nPick(
                        context,
                        fa: 'نوع وثیقه تودیعی جهت صدور ضمانت‌نامه را انتخاب نمایید',
                        en: 'Select collateral type to secure the guarantee issuance',
                        ar: 'اختر نوع الضمان المطلوب لإصدار الخطاب',
                        zh: '选择用于担保开立的抵押资产形式',
                      ),
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // Collateral Type Selector (4 Types)
          Column(
            children: GuaranteeCollateralType.values.map((type) {
              final isSelected = _selectedType == type;
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14.r),
                    onTap: () => _selectType(type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? type.themeColor.withValues(alpha: 0.07)
                            : const Color(0xFFFAFAFC),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: isSelected ? type.themeColor : AppColors.lightBorder,
                          width: isSelected ? 1.8 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Leading icon
                          Container(
                            width: 38.r,
                            height: 38.r,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? type.themeColor
                                  : type.themeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              type.icon,
                              color: isSelected ? Colors.white : type.themeColor,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),

                          // Title and description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        l10nPick(
                                          context,
                                          fa: type.titleFa,
                                          en: type.titleEn,
                                          ar: type.titleFa,
                                          zh: type.titleEn,
                                        ),
                                        style: TextStyle(
                                          fontSize: 12.5.sp,
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? type.themeColor
                                              : AppColors.lightTextPrimary,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    // LTV ratio pill
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 3.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? type.themeColor
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(20.r),
                                      ),
                                      child: Text(
                                        'LTV ${type.ltvPct}%',
                                        style: TextStyle(
                                          fontSize: 9.5.sp,
                                          fontWeight: FontWeight.w800,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  l10nPick(
                                    context,
                                    fa: type.descFa,
                                    en: type.descEn,
                                    ar: type.descFa,
                                    zh: type.descEn,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey.shade600,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: 8.w),

                          // Selection radio indicator
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: isSelected ? type.themeColor : Colors.grey.shade400,
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 12.h),

          // Coverage Amount Indicator & Calculation Breakdown
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildBreakdownRow(
                  label: l10nPick(
                    context,
                    fa: 'مبلغ اسمی ضمانت‌نامه:',
                    en: 'Guarantee Face Amount:',
                    ar: 'مبلغ الضمان الاسمي:',
                    zh: '保函开立面额：',
                  ),
                  value: '${_formatAmount(widget.guaranteeAmount)} ${widget.currency}',
                  isBold: false,
                ),
                SizedBox(height: 6.h),
                _buildBreakdownRow(
                  label: l10nPick(
                    context,
                    fa: 'درصد وجه التزام مبنا (${widget.marginPct}٪):',
                    en: 'Base Margin (${widget.marginPct}%):',
                    ar: 'نسبة الهامش الأساسية (${widget.marginPct}%):',
                    zh: '基础保证金比例 (${widget.marginPct}%):',
                  ),
                  value: '${_formatAmount(_baseMarginAmount)} ${widget.currency}',
                  isBold: false,
                ),
                SizedBox(height: 6.h),
                const Divider(height: 12, thickness: 0.8),
                SizedBox(height: 4.h),
                _buildBreakdownRow(
                  label: l10nPick(
                    context,
                    fa: 'پوشش وثیقه لازم (${_selectedType.ltvPct}٪ LTV):',
                    en: 'Required Coverage (${_selectedType.ltvPct}% LTV):',
                    ar: 'قيمة التغطية المطلوبة (${_selectedType.ltvPct}% LTV):',
                    zh: '所需抵押覆盖价值 (${_selectedType.ltvPct}% LTV):',
                  ),
                  value: isCryptoType
                      ? '${_formatAmount(_requiredUsdtAmount)} USDT (~${_formatAmount(_requiredCoverageAmount)} ${widget.currency})'
                      : '${_formatAmount(_requiredCoverageAmount)} ${widget.currency}',
                  isBold: true,
                  valueColor: _selectedType.themeColor,
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // Live Wallet Balance Check vs Required Collateral
          _buildLiveBalanceCheckSection(
            context: context,
            liveWallet: liveWallet,
            isCryptoType: isCryptoType,
            targetNeeded: targetNeeded,
            isSufficient: isSufficient,
            deficit: deficit,
          ),

          SizedBox(height: 14.h),

          // Terms of Collateral Release Notice
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: const Color(0xFF475569),
                  size: 20.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          fa: 'شرایط آزادسازی وثیقه (Collateral Release Terms)',
                          en: 'Collateral Release Terms',
                          ar: 'شروط تحرير واسترداد الضمان',
                          zh: '抵押品解除锁定与释放条款',
                        ),
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10nPick(
                          context,
                          fa: 'وثایق و وجوه تودیع‌شده در حساب امانی امن (Escrow) پلتفرم مسدود می‌ماند و صرفاً پس از ارائه برگه رفع تعهد کتبی ذینفع (کارفرما)، خاتمه رسمی قرارداد یا انقضای قطعی مهلت قانونی ۳۰ روزه پس از سررسید بدون ثبت ادعا، به‌صورت آنی آزاد می‌گردد.',
                          en: 'Collateral is held in platform escrow and released upon official discharge letter by the beneficiary, contract completion, or expiry of the statutory 30-day waiting period without claim.',
                          ar: 'يتم حجز الضمان في محفظة الضمان الآمنة ويُحرَّر فور تقديم خطاب براءة الذمة من المستفيد أو انتهاء مهلة الـ 30 يوماً القانونية دون مطالبة.',
                          zh: '所抵押资产安全锁定于平台托管合约中，待收到受益人书面解除保函通知、合同顺利履行完毕或30天法定索赔缓冲期届满且无索赔后全额返还。',
                        ),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFF475569),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow({
    required String label,
    required String value,
    required bool isBold,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold ? AppColors.lightTextPrimary : AppColors.lightTextSecondary,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 12.sp : 11.sp,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveBalanceCheckSection({
    required BuildContext context,
    required ({double balance, String code, bool found}) liveWallet,
    required bool isCryptoType,
    required double targetNeeded,
    required bool isSufficient,
    required double deficit,
  }) {
    // If Promissory Note or Real Estate: show registry/signature verification status
    if (_selectedType == GuaranteeCollateralType.promissoryNote) {
      return Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFDDD6FE)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.verified_user_rounded,
              color: const Color(0xFF7C3AED),
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(
                      context,
                      fa: 'آماده صدور و امضای دیجیتال سفته',
                      en: 'Ready for Digital Promissory Signature',
                      ar: 'جاهز للتوقيع الإلكتروني للسند',
                      zh: '就绪：待签署电子本票/提报合规支票',
                    ),
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5B21B6),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'پس از تایید اولیه، امضای الکترونیک در سامانه سفته یا چک صیادی انجام می‌شود.',
                      en: 'Digital signature on official e-promissory registry or Sayad check will follow initial review.',
                    ),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: const Color(0xFF6D28D9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_selectedType == GuaranteeCollateralType.bankCertificate) {
      return Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.home_work_rounded,
              color: const Color(0xFFD97706),
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(
                      context,
                      fa: 'نیازمند استعلام ثبتی و توثیق رسمی',
                      en: 'Cadastre & Official Mortgage Required',
                      ar: 'يتطلب استعلاماً عقارياً وتوثيقاً رسمياً',
                      zh: '需提报房产证/银行存单确权备案',
                    ),
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    l10nPick(
                      context,
                      fa: 'مدارک ثبتی در مرحله بارگذاری اسناد پرونده استعلام و توثیق خواهند شد.',
                      en: 'Property or deposit certificate will be mortgaged during document upload step.',
                    ),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Cash and Crypto: Live Wallet balance check
    if (isSufficient) {
      return Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.successContainer,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 22.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          l10nPick(
                            context,
                            fa: 'موجودی کافی است',
                            en: 'Sufficient Balance',
                            ar: 'الرصيد كافٍ',
                            zh: '余额充足',
                          ),
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        l10nPick(
                          context,
                          fa: 'موجودی کیف‌پول آماده مسدودی در اسکرو',
                          en: 'Wallet balance ready for escrow lock',
                        ),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${l10nPick(context, fa: 'موجودی فعلی:', en: 'Available Balance:')} ${_formatAmount(liveWallet.balance)} ${liveWallet.code} · ${l10nPick(context, fa: 'پوشش مورد نیاز:', en: 'Required:')} ${_formatAmount(targetNeeded)} ${liveWallet.code}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.green.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Insufficient balance: Top-Up warning pill
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  l10nPick(
                    context,
                    fa: 'کسری موجودی - شارژ الزامی است',
                    en: 'Top-Up Required',
                    ar: 'شحن الرصيد مطلوب',
                    zh: '余额不足需充值',
                  ),
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              if (widget.onTopUpPressed != null || Get.isRegistered<HomeController>())
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (widget.onTopUpPressed != null) {
                      widget.onTopUpPressed!();
                    } else {
                      try {
                        Get.toNamed(BaseRoute.addMoney);
                      } catch (_) {}
                    }
                  },
                  child: Text(
                    l10nPick(
                      context,
                      fa: 'شارژ کیف‌پول',
                      en: 'Top-Up',
                      ar: 'شحن',
                      zh: '充值',
                    ),
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            '${l10nPick(context, fa: 'موجودی فعلی:', en: 'Current:')} ${_formatAmount(liveWallet.balance)} ${liveWallet.code} · ${l10nPick(context, fa: 'کسری مورد نیاز:', en: 'Deficit:')} ${_formatAmount(deficit)} ${liveWallet.code}',
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }
}
