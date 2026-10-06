import 'package:flutter/material.dart';

/// LocaleTransitionScreen — a deliberately empty, dependency-free waypoint
/// used by LocaleThemeService.setLanguage().
///
/// Why it exists: applying a locale while every live route + GetX controller
/// is mounted rebuilds the WHOLE tree in one frame. That in-place full-tree
/// rebuild is the confirmed release crash (GetX "controller not found" while
/// a widget in the tree looks up a controller whose route is being torn down,
/// error_log #62/#63 — v1.0.121/122). The field-proven fix (v1.0.123) is to
/// clear the navigation stack BEFORE applying the locale; this screen is the
/// stack-clearing target so the SplashScreen is NOT replayed. After the new
/// locale is applied, the service returns the user to the captured route.
class LocaleTransitionScreen extends StatelessWidget {
  const LocaleTransitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Intentionally no GetX lookups, no AppLocalizations, no ScreenUtil:
    // this must build safely while every controller has just been disposed.
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}
