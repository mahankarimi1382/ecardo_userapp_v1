import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/controller/country_controller.dart';
import 'package:qunzo_user/src/common/model/country_model.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/controller/gift_card_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/model/gift_card_product_details_model.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/view/sub_sections/gift_card_review_details_section.dart';

class GiftCardDetailsSection extends StatefulWidget {
  final String giftCardId;

  const GiftCardDetailsSection({super.key, required this.giftCardId});

  @override
  State<GiftCardDetailsSection> createState() => _GiftCardDetailsState();
}

class _GiftCardDetailsState extends State<GiftCardDetailsSection> {
  final GiftCardController controller = Get.find();
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
    controller.isGiftCardDetailsLoading.value = false;
  }

  void _setSelectedCountry() {
    final selectedCountry = countryController.countryList.firstWhereOrNull(
      (country) => country.selected == true,
    );

    if (selectedCountry != null) {
      controller.countryController.text = selectedCountry.name ?? "";
      controller.selectedCountry.value = selectedCountry;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Column(
        children: [
          SizedBox(height: 16.h),
          CommonAppBar(title: localizations.giftCardDetailsTitle),
          Expanded(
            child: Obx(() {
              if (controller.isGiftCardDetailsLoading.value) {
                return CommonLoading();
              }

              final cardDetails = controller.giftCardProductDetails.value;

              return SingleChildScrollView(
                padding: EdgeInsetsDirectional.only(
                  top: 20.h,
                  start: 18.w,
                  end: 18.w,
                  bottom: 30.h,
                ),
                child: Column(
                  children: [
                    _buildGiftCardSection(cardDetails),
                    SizedBox(height: 30.h),
                    _buildAmountSection(cardDetails),
                    SizedBox(height: 40.h),
                    CommonButton(
                      text: localizations.giftCardBuyNowButton,
                      onPressed: () {
                        if (!controller.validateAmountStep(
                          denominationType: cardDetails.denominationType
                              .toString(),
                          minRecipientDenomination: cardDetails
                              .minRecipientDenomination
                              .toString(),
                          maxRecipientDenomination: cardDetails
                              .maxRecipientDenomination
                              .toString(),
                        )) {
                          return;
                        }
                        Get.to(
                          GiftCardReviewDetailsSection(
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

  Widget _buildAmountSection(GiftCardProductDetailsData cardDetails) {
    final localizations = AppLocalizations.of(context)!;
    final List<int> fixedRecipientDenominationsAmounts =
        cardDetails.fixedRecipientDenominations ?? [];

    if (cardDetails.denominationType == 'FIXED' &&
        fixedRecipientDenominationsAmounts.isNotEmpty) {
      controller.selectedAmount.value =
          fixedRecipientDenominationsAmounts.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Color(0xFF303030).withValues(alpha: 0.16),
            ),
          ),
          child: Column(
            children: [
              if (cardDetails.denominationType == 'FIXED' &&
                  fixedRecipientDenominationsAmounts.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.giftCardAmountLabel,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Obx(
                        () => Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          children: fixedRecipientDenominationsAmounts.map((
                            amount,
                          ) {
                            final isSelected =
                                controller.selectedAmount.value == amount;
                            return GestureDetector(
                              onTap: () {
                                controller.selectedAmount.value = amount;
                              },
                              child: Container(
                                padding: EdgeInsetsDirectional.symmetric(
                                  horizontal: 16.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.lightPrimary
                                      : AppColors.transparent,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.lightPrimary
                                        : AppColors.lightTextPrimary.withValues(
                                            alpha: 0.16,
                                          ),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  "$amount ${cardDetails.recipientCurrencyCode}",
                                  style: TextStyle(
                                    letterSpacing: 0,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.white
                                        : AppColors.lightTextTertiary,
                                  ),
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
                      hintText: "",
                      controller: controller.amountController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
              SizedBox(height: 16.h),
              CommonRequiredLabelAndDynamicField(
                isLabelRequired: true,
                labelText: localizations.giftCardEmailLabel,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    focusNode: controller.emailFocusNode,
                    isFocused: controller.isEmailFocused.value,
                    hintText: "",
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
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
                              controller.selectedCountry.value =
                                  selectedCountry;
                              controller.countryController.text =
                                  selectedCountry.name ?? "";
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
                    hintText: "",
                    controller: controller.countryController,
                    suffixIconColor: AppColors.lightTextTertiary,
                    readOnly: true,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              CommonRequiredLabelAndDynamicField(
                isLabelRequired: true,
                labelText: localizations.giftCardPhoneLabel,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    focusNode: controller.phoneFocusNode,
                    isFocused: controller.isPhoneFocused.value,
                    hintText: "",
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Padding(
                      padding: EdgeInsetsDirectional.only(
                        top: 14.h,
                        bottom: 14.h,
                      ),
                      child: Text(
                        controller.selectedCountry.value.dialCode ?? "",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: AppColors.lightTextPrimary,
                          letterSpacing: 0,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
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
                          hintText: "",
                          controller: controller.nameController,
                          keyboardType: TextInputType.name,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: CommonRequiredLabelAndDynamicField(
                      isLabelRequired: true,
                      labelText: localizations.giftCardQuantityLabel,
                      dynamicField: Container(
                        width: double.infinity,
                        height: 48.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColors.lightTextPrimary.withValues(
                              alpha: 0.2,
                            ),
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
                                    controller.count.value--;
                                  }
                                },
                                borderRadius: BorderRadius.circular(10.r),
                                child: Container(
                                  margin: EdgeInsetsDirectional.only(
                                    start: 6.w,
                                    top: 6.h,
                                    bottom: 6.h,
                                  ),
                                  width: 36.w,
                                  height: 36.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.lightTextPrimary
                                        .withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.remove,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),

                              Text(
                                controller.count.value.toString(),
                                style: TextStyle(
                                  letterSpacing: 0,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.lightTextPrimary,
                                ),
                              ),

                              InkWell(
                                onTap: () {
                                  controller.count.value++;
                                },
                                borderRadius: BorderRadius.circular(10.r),
                                child: Container(
                                  margin: EdgeInsetsDirectional.only(
                                    end: 6.w,
                                    top: 6.h,
                                    bottom: 6.h,
                                  ),
                                  width: 36.w,
                                  height: 36.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.lightPrimary,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: AppColors.white,
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

  Widget _buildGiftCardSection(GiftCardProductDetailsData cardDetails) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF303030).withValues(alpha: 0.16),
        ),
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
            child: Image.asset(
              width: double.infinity,
              PngAssets.giftCardPreview,
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: 12.w,
              end: 12.w,
              bottom: 16.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.giftCardProductDetails.value.productName ?? "",
                  style: TextStyle(
                    letterSpacing: 0,
                    fontSize: 20.sp,
                    color: AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  localizations.giftCardRedeemInstructionTitle,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontSize: 14.sp,
                    color: AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  cardDetails.redeemInstruction?.verbose ?? '',
                  style: TextStyle(
                    letterSpacing: 0,
                    fontSize: 12.sp,
                    color: AppColors.lightTextTertiary,
                    fontWeight: FontWeight.w500,
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
