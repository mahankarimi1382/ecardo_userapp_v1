import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/controller/image_picker/image_picker_controller.dart';

class ImagePickerDropdownBottomSheet extends StatelessWidget {
  const ImagePickerDropdownBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final ImagePickerController imagePickerController = Get.put(
      ImagePickerController(),
    );

    final Color backgroundColorTop = AppColors.white;
    final Color backgroundColorBottom = AppColors.white;
    final Color textColor = AppColors.black;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      height: 230,

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            backgroundColorTop.withValues(alpha: 0.95),
            backgroundColorBottom.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(28),
          topEnd: Radius.circular(28),
        ),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(28),
          topEnd: Radius.circular(28),
        ),
        child: Column(
          children: [
            Column(
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localization.imagePickerDropdownTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: textColor,
                          letterSpacing: 0,
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(20, 0),
                        child: IconButton(
                          icon: Icon(Icons.close, color: AppColors.black),
                          onPressed: () => Navigator.pop(context),
                          splashRadius: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => imagePickerController.pickImageFromCamera(),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.lightTextTertiary.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Image.asset(
                          PngAssets.cameraCommonIconTwo,
                          width: 30,

                          height: 30,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        localization.imagePickerDropdownCamera,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => imagePickerController.pickImageFromGallery(),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.lightTextTertiary.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Image.asset(
                          PngAssets.galleryCommonIcon,
                          width: 30,

                          height: 30,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        localization.imagePickerDropdownGallery,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
