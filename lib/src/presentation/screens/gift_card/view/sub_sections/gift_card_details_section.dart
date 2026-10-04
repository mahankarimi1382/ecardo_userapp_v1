import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/controller/country_controller.dart';
import 'package:ecardo_user/src/common/model/country_model.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/controller/gift_card_controller.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/model/gift_card_product_details_model.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/view/sub_sections/gift_card_review_details_section.dart';

class GiftCardDetailsSection extends StatefulWidget {
  final String giftCardId;

  const GiftCardDetailsSection({super.key, required this.giftCardId});

  @override
  State<GiftCardDetailsSection> createState() => _GiftCardDetailsState();
}

class _GiftCardDetailsState extends State<GiftCardDetailsSection> {
  final GiftCardController controller = Get.find<GiftCardController>();
  final CountryController countryController = Get.put(CountryController());

  @override
  void initState() {
    super.initState();
    controller.amountController.clear();
    controller.emailController.clear();
    controller.countryController.clear();
    controller.phoneController.clear();
    controller.nameController.clear();
    controller.selectedCountry.value = CountryData();
    controller.count.value = 1;
    loadData();
  }

  Future<void> loadData() async {
    controller.isGiftCardDetailsLoading.value = true;
    await controller.getGiftCardProductDetails(giftCardId: widget.giftCardId);
    await countryController.fetchCountries();
    _setSelectedCountry();
    _initDefaultDenomination();
    controller.isGiftCardDetailsLoading.value = false;
  }

  void _initDefaultDenomination() {
    final details = controller.giftCardProductDetails.value;
    final denominations = details.fixedRecipientDenominations ?? [];
    if (details.denominationType == 'FIXED' && denominations.isNotEmpty) {
      if (controller.selectedAmount.value == 0 ||
          !denominations.contains(controller.selectedAmount.value)) {
        controller.selectedAmount.value = denominations.first;
      }
    }
  }

  void _setSelectedCountry() {
    final selectedCountry = countryController.countryList.firstWhereOrNull(
      (country) => country.selected == true,
    );

    if (selectedCountry != null) {
      controller.countryController.text = selectedCountry.name ?? '';
      controller.selectedCountry.value = selectedCountry;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: CommonDefaultAppBar(),
      body: Column(
        children: [
          SizedBox(height: AppSpacing.lg.h),
          CommonAppBar(title: localizations.giftCardDetailsTitle),
          Expanded(
            child: Obx(() {
              if (controller.isGiftCardDetailsLoading.value) {
                return const CommonLoading();
              }

              final cardDetails = controller.giftCardProductDetails.value;

              return SingleChildScrollView(
                padding: EdgeInsetsDirectional.only(
                  top: AppSpacing.lg.h,
                  start: AppSpacing.lg.w,
                  end: AppSpacing.lg.w,
                  bottom: AppSpacing.xxxl.h,
                ),
                child: Column(
                  children: [
                    _buildGiftCardSection(cardDetails, isDark),
                    SizedBox(height: AppSpacing.xl.h),
                    _buildAmountSection(cardDetails, isDark),
                    SizedBox(height: AppSpacing.xxxl.h),
                    CommonButton(
                      text: localizations.giftCardBuyNowButton,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        if (!controller.validateAmountStep(
                          denominationType: cardDetails.denominationType.toString(),
                          minRecipientDenomination:
                              cardDetails.minRecipientDenomination.toString(),
                          maxRecipientDenomination:
                              cardDetails.maxRecipientDenomination.toString(),
                        )) {
                          return;
                        }
                        Get.to(
                          () => GiftCardReviewDetailsSection(
                            cardDetails: cardDetails,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(
    GiftCardProductDetailsData cardDetails,
    bool isDark,
  ) {
    final localizations = AppLocalizations.of(context)!;
    final List<int> fixedRecipientDenominationsAmounts =
        cardDetails.fixedRecipientDenominations ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.lg.r),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : AppColors.mutedBlue.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Denomination Selector: FIXED
              if (cardDetails.denominationType == 'FIXED' &&
                  fixedRecipientDenominationsAmounts.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localizations.giftCardAmountLabel,
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                                  isDark ? AppColors.mutedBlue : AppColors.darkGray,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                            ),
                            child: Text(
                              'SELECT VALUE',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: isDark ? AppColors.deepBlack : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      Obx(
                        () => Wrap(
                          spacing: AppSpacing.sm.w,
                          runSpacing: AppSpacing.sm.h,
                          children: fixedRecipientDenominationsAmounts.map((amount) {
                            final isSelected =
                                controller.selectedAmount.value == amount;
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                controller.selectedAmount.value = amount;
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: EdgeInsetsDirectional.symmetric(
                                  horizontal: AppSpacing.lg.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark ? AppColors.mainSoftBlue : AppColors.deepBlack)
                                      : (isDark
                                          ? AppColors.darkSurfaceVariant
                                          : AppColors.lightSurfaceVariant),
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                  border: Border.all(
                                    color: isSelected
                                        ? (isDark ? AppColors.mainSoftBlue : AppColors.deepBlack)
                                        : (isDark
                                            ? AppColors.darkBorder
                                            : AppColors.lightOutlineVariant),
                                    width: isSelected ? 1.8 : 1.0,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: (isDark
                                                    ? AppColors.mainSoftBlue
                                                    : AppColors.deepBlack)
                                                .withValues(alpha: 0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSelected) ...[
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 14.sp,
                                        color: isDark ? AppColors.deepBlack : Colors.white,
                                      ),
                                      SizedBox(width: 4.w),
                                    ],
                                    Text(
                                      '$amount ${cardDetails.recipientCurrencyCode ?? ''}',
                                      style: AppTextStyles.labelLarge.copyWith(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.w800,
                                        color: isSelected
                                            ? (isDark ? AppColors.deepBlack : Colors.white)
                                            : (isDark
                                                ? AppColors.darkTextPrimary
                                                : AppColors.lightTextPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                )
              else if (cardDetails.denominationType == 'RANGE' &&
                  cardDetails.minSenderDenomination != null &&
                  cardDetails.maxSenderDenomination != null)
                CommonRequiredLabelAndDynamicField(
                  isLabelRequired: true,
                  labelText: localizations.giftCardAmountBetweenLabel(
                    cardDetails.recipientCurrencyCode.toString(),
                    cardDetails.maxRecipientDenomination.toString(),
                    cardDetails.minRecipientDenomination.toString(),
                  ),
                  dynamicField: Obx(
                    () => CommonTextInputField(
                      focusNode: controller.amountFocusNode,
                      isFocused: controller.isAmountFocused.value,
                      hintText: '',
                      controller: controller.amountController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
              SizedBox(height: AppSpacing.lg.h),
              CommonRequiredLabelAndDynamicField(
                isLabelRequired: true,
                labelText: localizations.giftCardEmailLabel,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    focusNode: controller.emailFocusNode,
                    isFocused: controller.isEmailFocused.value,
                    hintText: '',
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              CommonRequiredLabelAndDynamicField(
                labelText: localizations.giftCardCountryLabel,
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    suffixIcon: Image.asset(PngAssets.arrowDownCommonIcon),
                    focusNode: controller.countryFocusNode,
                    isFocused: controller.isCountryFocused.value,
                    onTap: () {
                      Get.bottomSheet(
                        CommonDropdownBottomSheet(
                          showSearch: true,
                          isShowTitle: true,
                          title: localizations.giftCardSelectCountryTitle,
                          isUnselectedValue: true,
                          onValueSelected: (value) async {
                            int index = countryController.countryList
                                .indexWhere((item) => item.name == value);

                            if (index != -1) {
                              final selectedCountry =
                                  countryController.countryList[index];
                              controller.selectedCountry.value = selectedCountry;
                              controller.countryController.text =
                                  selectedCountry.name ?? '';
                            }
                          },
                          onValueUnSelected: () {
                            controller.selectedCountry.value = CountryData();
                            controller.countryController.clear();
                          },
                          selectedValue: countryController.countryList
                              .map((item) => item.name.toString())
                              .toList(),
                          dropdownItems: countryController.countryList
                              .map((item) => item.name.toString())
                              .toList(),
                          selectedItem: controller.countryController.text,
                          textController: controller.countryController,
                          bottomSheetHeight: 450.h,
                          currentlySelectedValue:
                              controller.countryController.text,
                          notFoundText: localizations.giftCardCountryNotFound,
                        ),
                      );
                    },
                    hintText: '',
                    controller: controller.countryController,
                    suffixIconColor: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextTertiary,
                    readOnly: true,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              CommonRequiredLabelAndDynamicField(
                isLabelRequired: true,
                labelText: localizations.giftCardPhoneLabel,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    focusNode: controller.phoneFocusNode,
                    isFocused: controller.isPhoneFocused.value,
                    hintText: '',
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Padding(
                      padding: EdgeInsetsDirectional.only(
                        top: 14.h,
                        bottom: 14.h,
                      ),
                      child: Text(
                        controller.selectedCountry.value.dialCode ?? '',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              Row(
                children: [
                  Expanded(
                    child: CommonRequiredLabelAndDynamicField(
                      isLabelRequired: true,
                      labelText: localizations.giftCardYourNameLabel,
                      dynamicField: Obx(
                        () => CommonTextInputField(
                          focusNode: controller.nameFocusNode,
                          isFocused: controller.isNameFocused.value,
                          hintText: '',
                          controller: controller.nameController,
                          keyboardType: TextInputType.name,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.lg.w),
                  Expanded(
                    child: CommonRequiredLabelAndDynamicField(
                      isLabelRequired: true,
                      labelText: localizations.giftCardQuantityLabel,
                      dynamicField: Container(
                        width: double.infinity,
                        height: 48.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Obx(() {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (controller.count.value > 1) {
                                    HapticFeedback.selectionClick();
                                    controller.count.value--;
                                  }
                                },
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                child: Container(
                                  margin: EdgeInsetsDirectional.only(
                                    start: 6.w,
                                    top: 6.h,
                                    bottom: 6.h,
                                  ),
                                  width: 36.w,
                                  height: 36.w,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkSurfaceVariant
                                        : AppColors.lightSurfaceVariant,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.remove,
                                    size: 16.sp,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                controller.count.value.toString(),
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  controller.count.value++;
                                },
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                child: Container(
                                  margin: EdgeInsetsDirectional.only(
                                    end: 6.w,
                                    top: 6.h,
                                    bottom: 6.h,
                                  ),
                                  width: 36.w,
                                  height: 36.w,
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 16.sp,
                                    color: isDark ? AppColors.deepBlack : Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGiftCardSection(
    GiftCardProductDetailsData cardDetails,
    bool isDark,
  ) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : AppColors.mutedBlue.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              top: 4.h,
              start: 4.w,
              end: 4.w,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Image.asset(
                width: double.infinity,
                PngAssets.giftCardPreview,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 160.h,
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  child: const Center(
                    child: Icon(Icons.card_giftcard_rounded, size: 48, color: AppColors.softGray),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg.h),
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: AppSpacing.lg.w,
              end: AppSpacing.lg.w,
              bottom: AppSpacing.lg.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.giftCardProductDetails.value.productName ?? '',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.lg.h),
                Text(
                  localizations.giftCardRedeemInstructionTitle,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                Text(
                  cardDetails.redeemInstruction?.verbose ?? '',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextTertiary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
