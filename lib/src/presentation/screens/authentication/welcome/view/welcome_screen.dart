import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/bottom_sheet/common_alert_bottom_sheet.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/ambient_auth_background.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/auth_language_pill.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % 4;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Get.bottomSheet(
            CommonAlertBottomSheet(
              title: localizations.exitApplicationTitle,
              message: localizations.exitApplicationMessage,
              onConfirm: () => exit(0),
              onCancel: () => Get.back(),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF090D1A) : AppColors.lightBackground,
        appBar: const CommonDefaultAppBar(),
        body: AmbientAuthBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.page,
                          vertical: 12.h,
                        ),
                        child: Column(
                          children: [
                            // Top Header: Logo with glowing halo + Language pill
                            _buildTopHeader(isDark),

                            SizedBox(height: 12.h),

                            // Dynamic Feature Highlights Carousel
                            Expanded(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: 440,
                                    maxHeight: 400.h,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 310.h,
                                        child: PageView(
                                          controller: _pageController,
                                          onPageChanged: (idx) {
                                            setState(() => _currentPage = idx);
                                          },
                                          children: [
                                            _buildFeatureCard(
                                              context,
                                              tag: l10nPick(
                                                context,
                                                en: 'MULTI-CURRENCY',
                                                fa: 'چند ارزی',
                                                ar: 'متعدد العملات',
                                                zh: '多币种',
                                                tr: 'ÇOKLU PARA BİRİMİ',
                                                ru: 'МУЛЬТИВАЛЮТА',
                                              ),
                                              title: l10nPick(
                                                context,
                                                en: 'Borderless Wallets',
                                                fa: 'کیف‌پول‌های بدون مرز',
                                                ar: 'محافظ بلا حدود',
                                                zh: '无界多币种钱包',
                                                tr: 'Sınırsız Cüzdanlar',
                                                ru: 'Кошельки без границ',
                                              ),
                                              subtitle: l10nPick(
                                                context,
                                                en: 'Multi-currency crypto + fiat in unified vaults',
                                                fa: 'ترکیب یکپارچه دارایی‌های فیات و ارزهای دیجیتال',
                                                ar: 'عملات مشفرة وتقليدية في خزائن موحدة',
                                                zh: '统一金库管理加密与法定货币',
                                                tr: 'Birleşik kasalarda kripto + fiat varlıklar',
                                                ru: 'Крипто и фиатные активы в едином сейфе',
                                              ),
                                              description: l10nPick(
                                                context,
                                                en: 'Manage 40+ fiat currencies and leading crypto assets with real-time conversion and institutional security.',
                                                fa: 'مدیریت بیش از ۴۰ ارز فیات و رمزارز با نرخ لحظه‌ای و امنیت پیشرفته بانکی.',
                                                ar: 'إدارة أكثر من ٤٠ عملة نقدية ومشفرة بتحويل فوري وأمان مؤسسي.',
                                                zh: '支持40+法定货币及顶级加密资产的实时兑换与机构级安全。',
                                                tr: 'Gerçek zamanlı dönüşüm ve kurumsal güvenlikle 40+ fiat ve kriptoyu yönetin.',
                                                ru: 'Управление 40+ валютами и криптоактивами с моментальным обменом.',
                                              ),
                                              icon: Icons.account_balance_wallet_rounded,
                                              imageAsset: PngAssets.walletsService,
                                              accentGradient: const [
                                                Color(0xFF0284C7),
                                                Color(0xFF38BDF8),
                                              ],
                                              isDark: isDark,
                                            ),
                                            _buildFeatureCard(
                                              context,
                                              tag: l10nPick(
                                                context,
                                                en: 'INSTANT SETTLEMENT',
                                                fa: 'تسویه آنی',
                                                ar: 'تسوية فورية',
                                                zh: '极速到账',
                                                tr: 'ANINDA MUTABAKAT',
                                                ru: 'МГНОВЕННЫЙ РАСЧЕТ',
                                              ),
                                              title: l10nPick(
                                                context,
                                                en: 'Instant Global Remittance',
                                                fa: 'حواله ارزی بین‌المللی آنی',
                                                ar: 'تحويلات عالمية فورية',
                                                zh: '全球秒级跨境汇款',
                                                tr: 'Anında Küresel Havale',
                                                ru: 'Мгновенные переводы по миру',
                                              ),
                                              subtitle: l10nPick(
                                                context,
                                                en: 'Low fees, instant settlement across 150+ countries',
                                                fa: 'کارمزد حداقلی و واریز فوری به سراسر جهان',
                                                ar: 'رسوم منخفضة وتسوية فورية لأكثر من ١٥٠ دولة',
                                                zh: '低费率，即时结算覆盖150+国家',
                                                tr: '150+ ülkeye düşük komisyon ve anında transfer',
                                                ru: 'Низкие комиссии и расчет в 150+ странах',
                                              ),
                                              description: l10nPick(
                                                context,
                                                en: 'Send money worldwide in seconds with full transparency, zero hidden margins, and bank-grade encryption.',
                                                fa: 'انتقال وجه به سراسر جهان در چند ثانیه بدون هزینه‌های پنهان و با تضمین سرعت.',
                                                ar: 'أرسل الأموال حول العالم في ثوانٍ بشفافية تامة ودون رسوم خفية.',
                                                zh: '数秒完成全球跨国转账，费用完全透明，零隐藏汇差。',
                                                tr: 'Sıfır gizli masraf ve banka düzeyinde korumayla saniyeler içinde gönderin.',
                                                ru: 'Отправляйте средства за секунды без скрытых комиссий с защитой банка.',
                                              ),
                                              icon: Icons.bolt_rounded,
                                              imageAsset: PngAssets.transferService,
                                              accentGradient: const [
                                                Color(0xFF059669),
                                                Color(0xFF10B981),
                                              ],
                                              isDark: isDark,
                                            ),
                                            _buildFeatureCard(
                                              context,
                                              tag: l10nPick(
                                                context,
                                                en: 'GLOBAL ACCEPTANCE',
                                                fa: 'پذیرش جهانی',
                                                ar: 'قبول عالمي',
                                                zh: '全球通用',
                                                tr: 'KÜRESEL KABUL',
                                                ru: 'ГЛОБАЛЬНОЕ ПРИЗНАНИЕ',
                                              ),
                                              title: l10nPick(
                                                context,
                                                en: 'Virtual & Metal Cards',
                                                fa: 'کارت‌های مجازی و فلزی',
                                                ar: 'بطاقات افتراضية ومعدنية',
                                                zh: '虚拟卡与实体金属卡',
                                                tr: 'Sanal & Metal Kartlar',
                                                ru: 'Виртуальные и металл. карты',
                                              ),
                                              subtitle: l10nPick(
                                                context,
                                                en: 'Spend anywhere globally online and in-store',
                                                fa: 'خرید آسان از تمام درگاه‌ها و پایانه‌های بین‌المللی',
                                                ar: 'أنفق في أي مكان عالميًا عبر الإنترنت والمتاجر',
                                                zh: '全球线上线下随意消费',
                                                tr: 'Dünyanın her yerinde çevrim içi ve mağazada harcayın',
                                                ru: 'Оплата онлайн и в терминалах по всему миру',
                                              ),
                                              description: l10nPick(
                                                context,
                                                en: 'Deploy instant virtual cards for online subscriptions or order personalized laser-etched metal cards.',
                                                fa: 'صدور آنی کارت مجازی برای پرداخت‌های اینترنتی یا سفارش کارت‌های فلزی اختصاصی.',
                                                ar: 'أصدر بطاقات افتراضية فورية للاشتراكات أو اطلب بطاقات معدنية فاخرة.',
                                                zh: '即时开通虚拟卡用于订阅，或定制专属奢华激光雕刻金属实体卡。',
                                                tr: 'Abonelikler için anında sanal kart oluşturun veya özel metal kart sipariş edin.',
                                                ru: 'Выпускайте виртуальные карты или заказывайте металлические карты.',
                                              ),
                                              icon: Icons.credit_card_rounded,
                                              imageAsset: PngAssets.virtualCardService,
                                              accentGradient: const [
                                                Color(0xFF6366F1),
                                                Color(0xFF818CF8),
                                              ],
                                              isDark: isDark,
                                            ),
                                            _buildFeatureCard(
                                              context,
                                              tag: l10nPick(
                                                context,
                                                en: 'ESCROW-PROTECTED',
                                                fa: 'تضمین اسکرو',
                                                ar: 'حماية الضمان',
                                                zh: '智能托管保障',
                                                tr: 'EMANET KORUMALI',
                                                ru: 'ЭСКРОУ-ЗАЩИТА',
                                              ),
                                              title: l10nPick(
                                                context,
                                                en: 'Secure P2P Trading',
                                                fa: 'معاملات مستقیم P2P امن',
                                                ar: 'تداول P2P آمن',
                                                zh: '安全点对点交易',
                                                tr: 'Güvenli P2P Ticaret',
                                                ru: 'Безопасный P2P-обмен',
                                              ),
                                              subtitle: l10nPick(
                                                context,
                                                en: 'Escrow-backed global marketplace',
                                                fa: 'بازار مبادلات همتا‌به‌همتا با سیستم وثیقه‌گذاری هوشمند',
                                                ar: 'سوق عالمي مدعوم بحساب ضمان آمن',
                                                zh: '基于托管的全球点对点交易市场',
                                                tr: 'Emanet destekli küresel P2P pazaryeri',
                                                ru: 'Прямая торговля с гарантом эскроу',
                                              ),
                                              description: l10nPick(
                                                context,
                                                en: 'Exchange assets directly with verified users globally with 100% escrow protection and dispute resolution.',
                                                fa: 'تبادل مستقیم ارز و دارایی با کاربران تأییدشده همراه با ضمانت قطعی اسکرو.',
                                                ar: 'تداول مباشرة مع مستخدمين موثقين عالميًا بحماية ضمان كاملة وحل النزاعات.',
                                                zh: '直接与全球认证用户交易，尊享100%智能托管保护与专业仲裁。',
                                                tr: '%100 emanet koruması ile doğrulanmış kullanıcılarla doğrudan işlem yapın.',
                                                ru: 'Обменивайтесь напрямую с верифицированными пользователями с защитой 100%.',
                                              ),
                                              icon: Icons.swap_horiz_rounded,
                                              imageAsset: PngAssets.p2pTradingService,
                                              accentGradient: const [
                                                Color(0xFFD97706),
                                                Color(0xFFF59E0B),
                                              ],
                                              isDark: isDark,
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(height: 16.h),

                                      // Carousel indicators
                                      _buildPageIndicator(isDark),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 24.h),

                            // Bottom Glassmorphic Actions Deck
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 440),
                              child: EcardoGlassCard(
                                variant: EcardoGlassVariant.subtle,
                                interactive: false,
                                borderRadius: 24.r,
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg.w,
                                  vertical: AppSpacing.lg.h,
                                ),
                                child: Column(
                                  children: [
                                    // Primary Button: "Get Started" / "Create Account"
                                    Container(
                                      width: double.infinity,
                                      height: 54.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18.r),
                                        gradient: LinearGradient(
                                          colors: isDark
                                              ? const [
                                                  Color(0xFF38BDF8),
                                                  Color(0xFF6366F1),
                                                ]
                                              : const [
                                                  AppColors.deepBlack,
                                                  Color(0xFF27272A),
                                                ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (isDark
                                                    ? const Color(0xFF38BDF8)
                                                    : AppColors.deepBlack)
                                                .withValues(alpha: 0.32),
                                            blurRadius: 18,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(18.r),
                                          onTap: () => Get.toNamed(BaseRoute.email),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    localizations.welcomeCreateAccount,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w900,
                                                      fontSize: 16.sp,
                                                      color: Colors.white,
                                                      letterSpacing: 0,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                const Icon(
                                                  Icons.arrow_forward_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 12.h),

                                    // Ghost Button: "Sign In"
                                    Container(
                                      width: double.infinity,
                                      height: 52.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18.r),
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.05)
                                            : AppColors.white.withValues(alpha: 0.9),
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white.withValues(alpha: 0.18)
                                              : AppColors.lightBorder,
                                          width: 1.4,
                                        ),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(18.r),
                                          onTap: () => Get.toNamed(BaseRoute.signIn),
                                          child: Center(
                                            child: Text(
                                              localizations.welcomeSignIn,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 15.5.sp,
                                                color: primaryTextColor,
                                                letterSpacing: 0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Brand logo with ambient subtle halo
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: (isDark ? const Color(0xFF38BDF8) : AppColors.mainSoftBlue)
                    .withValues(alpha: isDark ? 0.15 : 0.25),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Image.asset(
            PngAssets.appLogo,
            height: 28.h,
            fit: BoxFit.contain,
          ),
        ),

        // Language selector pill
        const AuthLanguagePill(),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String tag,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required String imageAsset,
    required List<Color> accentGradient,
    required bool isDark,
  }) {
    final titleColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextTertiary;

    return EcardoGlassCard(
      variant: EcardoGlassVariant.standard,
      interactive: false,
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      borderRadius: 26.r,
      child: LayoutBuilder(
        builder: (context, cardConstraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: cardConstraints.maxHeight,
                minWidth: cardConstraints.maxWidth,
                maxWidth: cardConstraints.maxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon container with glowing accent
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: accentGradient),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: accentGradient.first.withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(icon, color: Colors.white, size: 24.sp),
                        ),
                      ),
                      // Feature Tag Badge
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                          color: accentGradient.first.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: accentGradient.first.withValues(alpha: 0.40),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w900,
                            color: isDark ? accentGradient.last : accentGradient.first,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                  SizedBox(height: 12.h),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: titleColor,
                      letterSpacing: -0.4,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB),
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor,
                      height: 1.4,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = index == _currentPage;
        return GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            height: 5.h,
            width: isActive ? 24.w : 6.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.r),
              color: isActive
                  ? (isDark ? const Color(0xFF38BDF8) : AppColors.deepBlack)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : const Color(0xFFCBD5E1)),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: (isDark
                                ? const Color(0xFF38BDF8)
                                : AppColors.deepBlack)
                            .withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
