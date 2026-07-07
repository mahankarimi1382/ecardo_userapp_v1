import 'package:flutter/material.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';

class LightTheme {
  ThemeData lightTheme(BuildContext context) => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    fontFamily: "Plus Jakarta Sans",
  );
}
