import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/services/session_timeout_service.dart';
import 'package:ecardo_user/src/common/services/connectivity_watch_service.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/presentation/screens/not_found/view/not_found_screen.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/config/theme/light_theme.dart';
import 'package:ecardo_user/src/app/config/theme/dark_theme.dart';
import 'package:ecardo_user/src/common/widgets/offline_queue_banner.dart';
import 'package:ecardo_user/src/app/constants/app_strings.dart';
import 'package:ecardo_user/src/app/bindings/app_bindings.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/app/routes/routes_handler.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';

class EcardoUser extends StatefulWidget {
  const EcardoUser({super.key});

  @override
  State<EcardoUser> createState() => _EcardoUserState();
}

class _EcardoUserState extends State<EcardoUser> {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  // Load saved language from SettingsService
  Future<void> _loadSavedLanguage() async {
    final savedLocale = await SettingsService.getLanguageLocaleCurrentState();

    if (savedLocale != null && mounted) {
      setState(() {
        _locale = Locale(savedLocale);
      });
      Get.updateLocale(Locale(savedLocale));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(376, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppStrings.appName,
          themeMode: ThemeMode.system,
          theme: LightTheme().lightTheme(context),
          darkTheme: DarkTheme().darkTheme(context),
          getPages: routesHandler,
          initialRoute: BaseRoute.root,
          unknownRoute: GetPage(
            name: '/not-found',
            page: () => const NotFoundScreen(),
          ),
          locale: _locale,
          fallbackLocale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // phase2-fix: ru/tr removed until translations are real (they
          // shipped 89% untranslated English). ARB files stay in lib/l10n.
          supportedLocales: const [
            Locale('en'),
            Locale("ar"),
            Locale('fa'),
            Locale('zh'),
          ],
          builder: (context, widget) {
            Widget body = widget ?? const SizedBox.shrink();
            // Touch tracking for idle session timeout.
            body = Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) {
                if (Get.isRegistered<SessionTimeoutService>()) {
                  Get.find<SessionTimeoutService>().touch();
                }
              },
              child: body,
            );
            // VPN soft guidance banner (does not block navigation).
            if (Get.isRegistered<ConnectivityWatchService>()) {
              body = Obx(() {
                final vpn = Get.find<ConnectivityWatchService>().isVpn.value;
                if (!vpn) return body;
                final loc = AppLocalizations.of(context);
                return Column(
                  children: [
                    Material(
                      color: const Color(0xFFFFF3CD),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.vpn_lock_rounded, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  loc?.vpnHintBanner ??
                                      'VPN detected — turn it off for a more stable experience',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: body),
                  ],
                );
              });
            }
            return Column(
              children: [
                const OfflineQueueBanner(),
                Expanded(child: body),
              ],
            );
          },
        );
      },
    );
  }
}
