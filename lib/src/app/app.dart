import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/presentation/screens/not_found/view/not_found_screen.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/config/theme/light_theme.dart';
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
          themeMode: ThemeMode.light,
          theme: LightTheme().lightTheme(context),
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
            return widget ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
