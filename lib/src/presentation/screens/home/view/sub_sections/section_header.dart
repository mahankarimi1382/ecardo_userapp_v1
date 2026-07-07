import 'package:flutter/material.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String sectionName;
  final GestureTapCallback? onTap;
  final bool? isShowNavigateAction;

  const SectionHeader({
    super.key,
    required this.sectionName,
    this.onTap,
    this.isShowNavigateAction = true,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            sectionName,
            style: TextStyle(
              letterSpacing: 0,
              fontSize: 16,
              color: AppColors.lightTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (isShowNavigateAction == true)
            GestureDetector(
              onTap: onTap,
              child: Text(
                localizations.sectionHeaderSeeAll,
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.lightPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
