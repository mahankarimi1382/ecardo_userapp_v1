import 'dart:ui' show ImageFilter;
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/app_haptics.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/home_screen.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/drawer/drawer_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/drawer/end_drawer_section.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/settings_screen.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/transfer_screen.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/controller/virtual_card_controller.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/view/virtual_card_screen.dart';
import 'package:ecardo_user/src/presentation/widgets/qr_scanner_screen.dart';
import 'package:ecardo_user/src/app/bindings/app_bindings.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final HomeController homeController = Get.find<HomeController>();
  final String signUpBonus = Get.arguments?["bonus"] ?? "";

  final iconList = [
    PngAssets.bottomNavigationHomeSolidIcon,
    PngAssets.bottomNavigationTransferSolidIcon,
    PngAssets.virtualCardService,
    PngAssets.bottomNavigationSettingsSolidIcon,
  ];

  // phase2-fix: highest tab index visited so far — pages above it stay
  // unbuilt (lazy) until first visit, then remain keep-alive.
  int _maxVisitedIndex = 0;

  @override
  void initState() {
    super.initState();
    homeController.setScaffoldKey(_scaffoldKey);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final localization = AppLocalizations.of(context);
      // DARK-FIX: this early scaffold used to hardcode the light background
      // and flashed white during dark-mode boots.
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      if (localization == null) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final labelList = [
        localization.bottomNavHome,
        localization.bottomNavTransfer,
        localization.bottomNavMyCards,
        localization.bottomNavSettings,
      ];

      final pages = [
        HomeScreen(signUpBonus: signUpBonus),
        TransferScreen(),
        const VirtualCardScreen(embeddedInTabs: true),
        SettingsScreen(),
      ];

      return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        drawer: DrawerSection(),
        endDrawer: EndDrawerSection(),
        // phase2-fix: keep-alive tabs — switching tabs no longer destroys
        // scroll/form state or refetches everything (IndexedStack + lazy
        // build on first visit).
        body: IndexedStack(
          index: homeController.selectedIndex.value,
          children: [
            for (var i = 0; i < pages.length; i++)
              if (i <= _maxVisitedIndex ||
                  i == homeController.selectedIndex.value)
                pages[i]
              else
                const SizedBox.shrink(),
          ],
        ),
        floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
            ? FloatingActionButton(
                heroTag: null,
                tooltip: l10nPick(
                  context,
                  en: 'QR & Quick Actions',
                  fa: 'کیو‌آر و عملیات سریع',
                  ar: 'رمز QR والإجراءات السريعة',
                  tr: 'QR ve Hızlı İşlemler',
                  ru: 'QR и быстрые действия',
                  zh: '二维码与快捷操作',
                ),
                backgroundColor:
                    isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Image.asset(
                  PngAssets.commonScannerIcon,
                  color: AppColors.white,
                  width: 25,
                  height: 25,
                ),
                onPressed: () => _showQrQuickActionsBottomSheet(context),
              )
            : null,

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: AnimatedBottomNavigationBar.builder(
          height: 80,
          // DARK-FIX: the bar used to be hardcode-white in dark mode.
          backgroundColor:
              isDark ? AppColors.darkSurface : AppColors.white,
          itemCount: iconList.length,
          activeIndex: homeController.selectedIndex.value,
          notchSmoothness: NotchSmoothness.softEdge,
          gapLocation: GapLocation.center,

          tabBuilder: (int index, bool isActive) {
            final color = isActive
                ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary)
                    .withValues(alpha: 0.30);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  iconList[index],
                  color: color,
                  width: index == 0
                      ? 25
                      : index == 1
                      ? 26
                      : index == 2
                      ? 22
                      : 28,
                ),
                const SizedBox(height: 2),
                Text(
                  labelList[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            );
          },

          onTap: _selectTab,

          shadow: BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 20,
            spreadRadius: 0,
            color: AppColors.black.withValues(alpha: 0.10),
          ),
        ),
      );
    });
  }

  void _selectTab(int index) {
    final settings = Get.find<SettingsService>();
    final bool isUserTransferEnabled =
        settings.getSetting("user_transfer") == "1";
    final myCardsEnabled =
        homeController.userModel.value.data?.addons?.virtualCards == true;
    final localization = AppLocalizations.of(context);

    if (index == 1 && !isUserTransferEnabled) {
      if (localization != null) {
        ToastHelper().showErrorToast(localization.userTransferNotEnabled);
      }
      return;
    }

    if (index == 2) {
      if (!myCardsEnabled) {
        if (localization != null) {
          ToastHelper().showErrorToast(localization.myCardsNotEnabled);
        }
        return;
      }
      // The virtual-cards route binding normally provides the
      // controller; as an embedded tab we register it on first visit.
      if (!Get.isRegistered<VirtualCardController>()) {
        VirtualCardBinding().dependencies();
      }
    }

    if (index > _maxVisitedIndex) {
      setState(() {
        _maxVisitedIndex = index;
      });
    }
    homeController.selectedIndex.value = index;
  }

  Future<void> _handleScanQr() async {
    final scannedCode = await Get.to(
      () => const QrScannerScreen(),
    );

    if (!mounted || scannedCode == null) return;

    final code = (scannedCode as String).trim();
    final aidMatch = RegExp(
      r'^AID\s*:\s*(\d+)$',
      caseSensitive: false,
    ).firstMatch(code);
    if (aidMatch != null) {
      Get.toNamed(
        BaseRoute.cashOut,
        arguments: {"aid_account": aidMatch.group(1)},
      );
      return;
    }
    final midMatch = RegExp(
      r'^MID\s*:\s*(\d+)$',
      caseSensitive: false,
    ).firstMatch(code);
    if (midMatch != null) {
      Get.toNamed(
        BaseRoute.makePayment,
        arguments: {"mid_account": midMatch.group(1)},
      );
      return;
    }
    final uidMatch = RegExp(
      r'^UID\s*:\s*(\d+)$',
      caseSensitive: false,
    ).firstMatch(code);
    if (uidMatch != null) {
      Get.toNamed(
        BaseRoute.transfer,
        arguments: {"uid_account": uidMatch.group(1)},
      );
      return;
    }
    if (RegExp(r'^\d+$').hasMatch(code)) {
      Get.toNamed(
        BaseRoute.transfer,
        arguments: {"uid_account": code},
      );
      return;
    }
    final localization = AppLocalizations.of(context);
    if (localization != null) {
      ToastHelper().showErrorToast(
        localization.qrInvalidFormat,
      );
    }
  }

  void _showQrQuickActionsBottomSheet(BuildContext context) {
    AppHaptics.light();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: isDark ? 0.65 : 0.45),
      builder: (sheetContext) {
        return _QrQuickActionsBottomSheet(
          isDark: isDark,
          isRtl: isRtl,
          onScan: () {
            Navigator.of(sheetContext).pop();
            _handleScanQr();
          },
          onReceive: () {
            Navigator.of(sheetContext).pop();
            Get.toNamed(BaseRoute.qrCode);
          },
          onTransfer: () {
            Navigator.of(sheetContext).pop();
            _selectTab(1);
          },
          onServices: () {
            Navigator.of(sheetContext).pop();
            Get.toNamed(BaseRoute.services);
          },
        );
      },
    );
  }
}

/// Frosted Neo-Fintech bottom sheet presenting QR and instant financial actions.
class _QrQuickActionsBottomSheet extends StatelessWidget {
  final bool isDark;
  final bool isRtl;
  final VoidCallback onScan;
  final VoidCallback onReceive;
  final VoidCallback onTransfer;
  final VoidCallback onServices;

  const _QrQuickActionsBottomSheet({
    required this.isDark,
    required this.isRtl,
    required this.onScan,
    required this.onReceive,
    required this.onTransfer,
    required this.onServices,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark
        ? const Color(0xFF131722).withValues(alpha: 0.94)
        : Colors.white.withValues(alpha: 0.95);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.brandViolet.withValues(alpha: 0.15);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: borderColor, width: 1.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
                blurRadius: 30,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.85,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Drag Handle
                    Center(
                      child: Container(
                        width: 44,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 2. Header
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF7445FF),
                                Color(0xFF5A35CC),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7445FF)
                                    .withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.bolt_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10nPick(
                                  context,
                                  en: 'Quick Actions',
                                  fa: 'عملیات سریع',
                                  ar: 'إجراءات سريعة',
                                  tr: 'Hızlı İşlemler',
                                  ru: 'Быستрые действия',
                                  zh: '快捷操作',
                                ),
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.deepBlack,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10nPick(
                                  context,
                                  en: 'Scan, receive, transfer or explore services',
                                  fa: 'اسکن، دریافت، انتقال وجه یا دسترسی به خدمات',
                                  ar: 'المسح، الاستلام، التحويل أو استكشاف الخدمات',
                                  tr: 'Tara, al, aktar veya hizmetleri keşfet',
                                  ru: 'Сканирование, получение, перевод и сервисы',
                                  zh: '扫码、收款、转账或浏览所有服务',
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.06),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Option A: Scan QR Code
                    _QuickActionTile(
                      title: l10nPick(
                        context,
                        en: 'Scan QR Code',
                        fa: 'اسکن کد QR',
                        ar: 'مسح رمز QR',
                        tr: 'QR Kodu Tara',
                        ru: 'Сканировать QR',
                        zh: '扫描二维码',
                      ),
                      subtitle: l10nPick(
                        context,
                        en: 'Scan merchant, agent or payment QR',
                        fa: 'اسکن کد پذیرنده، نماینده یا پرداخت سریع',
                        ar: 'مسح رمز التاجر أو الوكيل للدفع السريع',
                        tr: 'Üye işyeri veya ödeme QR kodunu tara',
                        ru: 'Сканирование QR мерчанта или оплаты',
                        zh: '扫描商户、代理或付款二维码',
                      ),
                      icon: Icons.qr_code_scanner_rounded,
                      gradientColors: const [
                        Color(0xFF2563EB),
                        Color(0xFF38BDF8),
                      ],
                      shadowColor:
                          const Color(0xFF2563EB).withValues(alpha: 0.30),
                      isDark: isDark,
                      isRtl: isRtl,
                      onTap: onScan,
                    ),
                    const SizedBox(height: 12),

                    // Option B: My QR Code / Receive
                    _QuickActionTile(
                      title: l10nPick(
                        context,
                        en: 'My QR Code / Receive',
                        fa: 'کیو‌آر من / دریافت وجه',
                        ar: 'رمز QR الخاص بي / استلام',
                        tr: 'QR Kodum / Para Al',
                        ru: 'Мой QR / Получение',
                        zh: '我的二维码 / 收款',
                      ),
                      subtitle: l10nPick(
                        context,
                        en: 'Show your unique QR code to receive funds',
                        fa: 'نمایش بارکد اختصاصی جهت دریافت فوری پول',
                        ar: 'عرض رمز الاستجابة السريعة لاستلام الأموال',
                        tr: 'Ödeme almak için özel QR kodunuzu gösterin',
                        ru: 'Показать свой QR-код для получения средств',
                        zh: '出示专属二维码以接收款项',
                      ),
                      icon: Icons.qr_code_2_rounded,
                      gradientColors: const [
                        Color(0xFF059669),
                        Color(0xFF34D399),
                      ],
                      shadowColor:
                          const Color(0xFF059669).withValues(alpha: 0.30),
                      isDark: isDark,
                      isRtl: isRtl,
                      onTap: onReceive,
                    ),
                    const SizedBox(height: 12),

                    // Option C: Direct Transfer
                    _QuickActionTile(
                      title: l10nPick(
                        context,
                        en: 'Direct Transfer',
                        fa: 'انتقال وجه سریع',
                        ar: 'تحويل مباشر وسريع',
                        tr: 'Hızlı Havale / Transfer',
                        ru: 'Быстрый перевод',
                        zh: '即时快速转账',
                      ),
                      subtitle: l10nPick(
                        context,
                        en: 'Send money instantly to accounts & users',
                        fa: 'انتقال آنی به سایر حساب‌ها و کاربران',
                        ar: 'تحويل فوري إلى الحسابات والمستخدمين',
                        tr: 'Hesaplara ve kullanıcılara anında para gönderin',
                        ru: 'Мгновенная отправка пользователям и счетам',
                        zh: '即时转账至其他用户或账户',
                      ),
                      icon: Icons.swap_horiz_rounded,
                      gradientColors: const [
                        Color(0xFF7C3AED),
                        Color(0xFFA78BFA),
                      ],
                      shadowColor:
                          const Color(0xFF7C3AED).withValues(alpha: 0.30),
                      isDark: isDark,
                      isRtl: isRtl,
                      onTap: onTransfer,
                    ),
                    const SizedBox(height: 12),

                    // Option D: All Services Hub
                    _QuickActionTile(
                      title: l10nPick(
                        context,
                        en: 'All Services Hub',
                        fa: 'همه خدمات و سوپراپ',
                        ar: 'مركز جميع الخدمات',
                        tr: 'Tüm Hizmetler Merkezi',
                        ru: 'Центр всех сервисов',
                        zh: '所有服务中心',
                      ),
                      subtitle: l10nPick(
                        context,
                        en: 'Explore financial, travel, cards & business tools',
                        fa: 'دسترسی به خدمات مالی، سفر، گردشگری و کسب‌وکار',
                        ar: 'استكشف الخدمات المالية والسياحية والبطاقات',
                        tr: 'Finans, seyahat, kartlar ve iş araçlarını keşfedin',
                        ru: 'Финансовые, туристические и бизнес-инструменты',
                        zh: '探索金融、旅行、卡片与商务工具',
                      ),
                      icon: Icons.grid_view_rounded,
                      gradientColors: const [
                        Color(0xFFF59E0B),
                        Color(0xFFFBBF24),
                      ],
                      shadowColor:
                          const Color(0xFFF59E0B).withValues(alpha: 0.30),
                      isDark: isDark,
                      isRtl: isRtl,
                      onTap: onServices,
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

/// An interactive Neo-Fintech tile with haptic feedback and micro-scaling.
class _QuickActionTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final Color shadowColor;
  final VoidCallback onTap;
  final bool isDark;
  final bool isRtl;

  const _QuickActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.shadowColor,
    required this.onTap,
    required this.isDark,
    required this.isRtl,
  });

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
            width: 1.1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: () {
              AppHaptics.light();
              widget.onTap();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: widget.shadowColor,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: widget.isDark
                                ? Colors.white
                                : AppColors.deepBlack,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: widget.isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    widget.isRtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    color: widget.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary.withValues(alpha: 0.6),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
