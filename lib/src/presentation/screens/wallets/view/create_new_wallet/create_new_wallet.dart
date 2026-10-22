import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/controller/create_new_wallet_controller.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/currencies_model.dart';

class CreateNewWallet extends StatelessWidget {
  const CreateNewWallet({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final CreateNewWalletController controller = Get.find();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: const CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 16.h),
              CommonAppBar(title: localization.createNewWalletScreenTitle),
              SizedBox(height: 24.h),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 18.w),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.white,
                        borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(30.r),
                          topEnd: Radius.circular(30.r),
                        ),
                      ),
                      child: const Center(
                        child: CommonLoading(isColorShow: false),
                      ),
                    );
                  }

                  // Display EcardoEmptyState if all currencies are already created
                  if (controller.currenciesList.isEmpty) {
                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 18.w),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.white,
                        borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(30.r),
                          topEnd: Radius.circular(30.r),
                        ),
                      ),
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: EcardoEmptyState(
                            iconData: Icons.account_balance_wallet_outlined,
                            title: l10nPick(
                              context,
                              en: 'All Wallets Created',
                              fa: 'همه کیف‌پول‌ها ایجاد شده‌اند',
                              ar: 'تم إنشاء جميع المحافظ',
                              tr: 'Tüm Cüzdanlar Oluşturuldu',
                              ru: 'Все кошельки уже созданы',
                              zh: '所有钱包均已创建',
                            ),
                            description: l10nPick(
                              context,
                              en: 'You already have active wallets for all supported currencies.',
                              fa: 'شما در حال حاضر برای تمام ارزهای پشتیبانی‌شده در سامانه کیف‌پول فعال دارید.',
                              ar: 'لديك بالفعل محافظ نشطة لجميع العملات المدعومة.',
                              tr: 'Desteklenen tüm para birimleri için zaten aktif cüzdanlarınız bulunmaktadır.',
                              ru: 'У вас уже есть активные кошельки для всех поддерживаемых валют.',
                              zh: '您已拥有所有支持币种的活动钱包。',
                            ),
                            primaryActionLabel: l10nPick(
                              context,
                              en: 'Back to Wallets',
                              fa: 'بازگشت به کیف‌پول‌ها',
                              ar: 'العودة إلى المحافظ',
                              tr: 'Cüzdanlara Dön',
                              ru: 'Назад к кошелькам',
                              zh: '返回钱包',
                            ),
                            onPrimaryAction: () => Get.back(),
                          ),
                        ),
                      ),
                    );
                  }

                  return Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 18.w),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.white,
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(30.r),
                        topEnd: Radius.circular(30.r),
                      ),
                    ),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 24.h),
                          CommonRequiredLabelAndDynamicField(
                            labelText: localization.createNewWalletCurrency,
                            isLabelRequired: true,
                            dynamicField: CommonTextInputField(
                              suffixIcon: Image.asset(
                                PngAssets.arrowDownCommonIcon,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextTertiary,
                              ),
                              suffixIconColor: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextTertiary,
                              focusNode: controller.currencyFocusNode,
                              isFocused: controller.isCurrencyFocused.value,
                              backgroundColor: AppColors.transparent,
                              controller: controller.currencyController,
                              onTap: () => _openCurrencyDropdown(
                                context,
                                controller,
                                localization,
                              ),
                              readOnly: true,
                              hintText:
                                  localization.createNewWalletSelectCurrency,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            l10nPick(
                              context,
                              en: 'Available Currencies',
                              fa: 'ارزهای موجود',
                              ar: 'العملات المتاحة',
                              tr: 'Mevcut Para Birimleri',
                              ru: 'Доступные валюты',
                              zh: '可用币种',
                            ),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          // Modernized Currency Selection Tiles with Active Border Highlights
                          ...controller.currenciesList.map((currencyItem) {
                            return Obx(() {
                              final isSelected =
                                  controller.currency.value?.id ==
                                  currencyItem.id;
                              return _CurrencySelectionTile(
                                currency: currencyItem,
                                isSelected: isSelected,
                                isDark: isDark,
                                onTap: () {
                                  controller.currency.value = currencyItem;
                                  controller.currencyController.text =
                                      currencyItem.fullName ??
                                      currencyItem.name ??
                                      currencyItem.code ??
                                      '';
                                },
                              );
                            });
                          }),
                          SizedBox(height: 30.h),
                          Obx(
                            () => CommonButton(
                              onPressed: controller.currency.value == null
                                  ? null
                                  : () => controller.createWallet(),
                              width: double.infinity,
                              text: localization.createNewWalletCreateButton,
                            ),
                          ),
                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          Obx(
            () => Visibility(
              visible: controller.isCreateWalletLoading.value,
              child: const CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }

  void _openCurrencyDropdown(
    BuildContext context,
    CreateNewWalletController controller,
    AppLocalizations localization,
  ) {
    Get.bottomSheet(
      CommonDropdownBottomSheet(
        title: localization.createNewWalletCurrency,
        isShowTitle: true,
        notFoundText: localization.createNewWalletCurrencyNotFound,
        onValueSelected: (value) {
          final index = controller.currenciesList.indexWhere(
            (item) => item.fullName == value,
          );
          if (index != -1) {
            final selectedCurrency = controller.currenciesList[index];
            controller.currency.value = selectedCurrency;
            controller.currencyController.text =
                selectedCurrency.fullName ?? '';
          }
        },
        selectedValue: controller.currenciesList
            .map((item) => item.fullName ?? '')
            .toList(),
        dropdownItems: controller.currenciesList
            .map((item) => item.fullName ?? '')
            .toList(),
        selectedItem: controller.currencyController.text,
        textController: controller.currencyController,
        currentlySelectedValue: controller.currencyController.text,
        bottomSheetHeight: 400.h,
      ),
    );
  }
}

/// Modernized Currency Selection Tile with Active Border Highlights
class _CurrencySelectionTile extends StatelessWidget {
  final CurrenciesData currency;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CurrencySelectionTile({
    required this.currency,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryAccent = isDark
        ? AppColors.mainSoftBlue
        : AppColors.brandViolet;
    final code = currency.code?.toUpperCase() ?? '';

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark
                        ? AppColors.darkPrimaryContainer.withValues(alpha: 0.40)
                        : AppColors.brandVioletContainer.withValues(
                            alpha: 0.50,
                          ))
                  : (isDark
                        ? AppColors.darkSurfaceVariant.withValues(alpha: 0.35)
                        : AppColors.lightSurfaceVariant.withValues(
                            alpha: 0.60,
                          )),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: isSelected
                    ? primaryAccent
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                width: isSelected ? 1.8.w : 1.0.w,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: primaryAccent.withValues(
                          alpha: isDark ? 0.25 : 0.12,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Currency Icon Badge
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? primaryAccent.withValues(alpha: isDark ? 0.25 : 0.15)
                        : (isDark ? AppColors.darkSurface : AppColors.white),
                    border: Border.all(
                      color: isSelected
                          ? primaryAccent
                          : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      currency.symbol?.isNotEmpty == true
                          ? currency.symbol!
                          : code.isNotEmpty
                          ? (code.length > 3 ? code.substring(0, 3) : code)
                          : '\$',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? primaryAccent
                            : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Currency Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currency.fullName ?? currency.name ?? code,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isSelected
                              ? (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.brandViolet)
                              : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary),
                        ),
                      ),
                      if (code.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          code,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Active Highlight Radio / Checkmark
                Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? primaryAccent : AppColors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? primaryAccent
                          : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 14.sp,
                          color: isDark ? AppColors.deepBlack : AppColors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
