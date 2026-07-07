import 'package:flutter/material.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';

class CommonAlertBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final Color? alertBoxColor;
  final String alertBoxIcon;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool? isPop;

  const CommonAlertBottomSheet({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.onCancel,
    this.alertBoxIcon = PngAssets.commonAlertIcon,
    this.alertBoxColor,
    this.isPop,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isPop ?? true,
      child: AnimatedContainer(
        width: double.infinity,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        margin: EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(20),
            topEnd: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 40,
              spreadRadius: 0,
              offset: Offset(0, 0),
            ),
          ],
        ),

        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12),
              Container(
                width: 40,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              SizedBox(height: 40),
              _buildAlertIcon(context),
              const SizedBox(height: 16),
              _buildTextSection(context),
              const SizedBox(height: 40),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertIcon(BuildContext context) {
    return Image.asset(PngAssets.commonExitAppIcon, width: 75, height: 75);
  }

  Widget _buildTextSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: AppColors.lightTextPrimary,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            textAlign: TextAlign.center,
            message,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.lightTextTertiary,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        CommonButton(
          backgroundColor: AppColors.error,
          width: 120,
          text: localizations.alertBottonSheetConfirmButton,
          onPressed: () => onConfirm(),
        ),
        SizedBox(height: 20),
        CommonButton(
          width: 120,
          text: localizations.alertBottonSheetCancelButton,
          backgroundColor: AppColors.transparent,
          textColor: AppColors.lightTextTertiary,
          onPressed: () => onCancel(),
        ),
        SizedBox(height: 30),
      ],
    );
  }
}
