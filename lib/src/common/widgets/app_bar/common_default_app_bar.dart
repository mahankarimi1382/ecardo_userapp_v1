import 'package:flutter/material.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';

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
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.lightBackground,
      surfaceTintColor: surfaceTintColor ?? AppColors.lightBackground,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(0);
}
