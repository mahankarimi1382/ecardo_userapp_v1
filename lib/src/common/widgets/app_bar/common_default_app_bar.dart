import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

class CommonDefaultAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Color? backgroundColor;
  final Color? surfaceTintColor;

  const CommonDefaultAppBar({
    super.key,
    this.backgroundColor,
    this.surfaceTintColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultBg =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return AppBar(
      backgroundColor:
          backgroundColor ?? theme.appBarTheme.backgroundColor ?? defaultBg,
      surfaceTintColor: surfaceTintColor ?? Colors.transparent,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(0);
}
