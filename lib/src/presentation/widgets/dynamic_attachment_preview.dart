import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';

class DynamicAttachmentPreview extends StatelessWidget {
  final File file;
  final double scaledHeight;
  final double bottomExtraHeight;

  const DynamicAttachmentPreview({
    super.key,
    required this.file,
    required this.scaledHeight,
    this.bottomExtraHeight = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.95,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 45,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localization.dynamicAttachmentPreviewTitle,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Image.asset(
                    PngAssets.closeCommonIcon,
                    width: 28,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.8,
                maxScale: 4.0,
                child: Image.file(
                  file,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: scaledHeight,
                ),
              ),
            ),
          ),
          SizedBox(height: bottomExtraHeight),
        ],
      ),
    );
  }
}
