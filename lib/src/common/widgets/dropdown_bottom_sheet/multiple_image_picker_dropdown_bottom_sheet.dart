import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/controller/image_picker/multiple_image_picker_controller.dart';

class MultipleImagePickerDropdownBottomSheet extends StatelessWidget {
  final int attachmentId;

  const MultipleImagePickerDropdownBottomSheet({
    required this.attachmentId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final MultipleImagePickerController multipleImagePickerController =
        Get.find<MultipleImagePickerController>();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      height: 250,
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
      child: Column(
        children: [
          Column(
            children: [
              SizedBox(height: 12),
              Container(
                width: 45,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localization.multipleImagePickerDropdownTitle,
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
              SizedBox(height: 12),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 18),
                width: double.infinity,
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.white,
                      AppColors.lightTextPrimary.withValues(alpha: 0.1),
                      AppColors.white,
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  multipleImagePickerController.pickImageFromCamera(
                    attachmentId,
                  );
                  Get.back();
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.lightTextPrimary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Image.asset(
                        PngAssets.cameraCommonIconTwo,
                        width: 30,
                        height: 30,
                        color: AppColors.lightTextPrimary.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      localization.multipleImagePickerDropdownCamera,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  multipleImagePickerController.pickImageFromGallery(
                    attachmentId,
                  );
                  Get.back();
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.lightTextPrimary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Image.asset(
                        PngAssets.galleryCommonIcon,
                        width: 30,
                        height: 30,
                        color: AppColors.lightTextPrimary.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      localization.multipleImagePickerDropdownGallery,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
