import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet_three.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/create_virtual_card_controller.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/create_virtual_card/sub_sections/card_holder_tab_section.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/create_virtual_card/sub_sections/choose_card_holder_section.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/create_virtual_card/sub_sections/create_new_card_holder_section.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/create_virtual_card/sub_sections/irr_card_order_section.dart';

class CreateVirtualCard extends StatefulWidget {
  const CreateVirtualCard({super.key});

  @override
  State<CreateVirtualCard> createState() => _CreateVirtualCardState();
}

class _CreateVirtualCardState extends State<CreateVirtualCard> {
  final CreateVirtualCardController controller = Get.find();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    controller.selectedTab.value = true;
    controller.isLoading.value = true;
    await Future.wait([
      controller.fetchCardProducts(),
      controller.fetchCardProviders(),
      controller.fetchCountries(),
    ]);
    if (controller.cardProducts.isNotEmpty) await controller.fetchIrrWallets();
    await controller.initializeCreationSelection();
    controller.isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 16.h),
              CommonAppBar(
                title: AppLocalizations.of(
                  context,
                )!.createVirtualCardAppBarTitle,
              ),
              SizedBox(height: 30.h),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const CommonLoading();
                  }

                  return Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 18.w),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(30.r),
                        topEnd: Radius.circular(30.r),
                      ),
                    ),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        18.w,
                        20.h,
                        18.w,
                        30.h + MediaQuery.viewInsetsOf(context).bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _UnifiedProviderSelector(controller: controller),
                          Obx(
                            () => AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: controller.creationMode.value == 'product'
                                  ? _IrrProductArea(
                                      key: const ValueKey('product'),
                                      controller: controller,
                                    )
                                  : _LegacyCardArea(
                                      key: const ValueKey('legacy'),
                                      controller: controller,
                                    ),
                            ),
                          ),
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
              visible: controller.isCardHolderLoading.value,
              child: CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }
}

class _IrrProductArea extends StatelessWidget {
  final CreateVirtualCardController controller;

  const _IrrProductArea({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isCardProductsLoading.value) {
        return const SizedBox(height: 180, child: CommonLoading());
      }

      if (controller.cardProducts.isNotEmpty) {
        return IrrCardOrderSection(
          applicantSection: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 24.h),
              const _SectionHeader(
                title: 'Cardholder information',
                subtitle:
                    'Enter the identity and delivery details required by this product.',
              ),
              SizedBox(height: 16.h),
              const CreateNewCardHolderSection(showSubmitButton: false),
            ],
          ),
        );
      }

      if (!controller.hasLoadedCardProducts.value) {
        return const SizedBox.shrink();
      }

      final hasError = controller.cardProductsError.value.isNotEmpty;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: (hasError ? AppColors.error : AppColors.lightTextTertiary)
              .withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Text(
              hasError
                  ? controller.cardProductsError.value
                  : 'No active IRR card product is currently available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: hasError
                    ? AppColors.error
                    : AppColors.lightTextTertiary,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 8.h),
            CommonButton(
              width: 180,
              height: 42,
              fontSize: 13,
              text: 'Retry IRR products',
              onPressed: controller.retryCardProducts,
            ),
          ],
        ),
      );
    });
  }
}

class _UnifiedProviderSelector extends StatelessWidget {
  final CreateVirtualCardController controller;

  const _UnifiedProviderSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final options = [
        ...controller.cardProducts.map(
          (product) => _ProviderOption(
            value: 'product:${product.id}',
            title: product.name ?? product.code ?? 'Card product',
            subtitle: [
              product.issuer?.name,
              product.issuer?.countryCode,
              product.issuer?.network,
            ].whereType<String>().where((value) => value.isNotEmpty).join(' · '),
          ),
        ),
        ...controller.cardProvidersList
            .where((provider) => (provider.code ?? '').isNotEmpty)
            .map(
              (provider) => _ProviderOption(
                value: 'legacy:${provider.code}',
                title:
                    provider.name ?? provider.code ?? 'Virtual card provider',
                subtitle: 'Legacy provider integration',
              ),
            ),
      ];

      if (options.isEmpty) {
        return const _AvailabilityMessage(
          message: 'No virtual-card provider is currently available.',
        );
      }

      return Padding(
        padding: EdgeInsets.only(bottom: 24.h),
        child: CommonRequiredLabelAndDynamicField(
          labelText: 'Card Provider',
          isLabelRequired: true,
          dynamicField: CommonTextInputField(
            suffixIcon: Image.asset(PngAssets.arrowDownCommonIcon),
            focusNode: controller.cardProviderFocusNode,
            isFocused: controller.isCardProviderFocused.value,
            hintText: 'Select Card Provider',
            controller: controller.cardProviderController,
            suffixIconColor: AppColors.lightTextTertiary,
            readOnly: true,
            onTap: () {
              final selectedOption = options.firstWhereOrNull(
                (option) =>
                    option.value == controller.selectedCreationOption.value,
              );
              Get.bottomSheet(
                CommonDropdownBottomSheetThree<_ProviderOption>(
                  items: options,
                  selectedItem: selectedOption,
                  bottomSheetHeight: 440.h,
                  isShowTitle: true,
                  title: 'Select Card Provider',
                  notFoundText: 'Card provider not found',
                  showSearch: options.length > 6,
                  getDisplayText: (option) => option.title,
                  getSearchKeywords: (option) => [
                    option.title,
                    option.subtitle,
                  ],
                  areItemsEqual: (first, second) =>
                      first.value == second.value,
                  onItemSelected: (option) {
                    controller.selectCreationOption(option.value);
                  },
                  customItemBuilder: (option, isSelected) {
                    return _ProviderOptionTile(
                      option: option,
                      isSelected: isSelected,
                    );
                  },
                ),
              );
            },
          ),
        ),
      );
    });
  }
}

class _LegacyCardArea extends StatelessWidget {
  final CreateVirtualCardController controller;

  const _LegacyCardArea({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.cardProvidersList.isEmpty) {
      return const _AvailabilityMessage(
        message: 'No legacy virtual-card provider is currently available.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(
          title: 'Provider cardholder',
          subtitle:
              'Create the card for an existing cardholder or add a new one.',
        ),
        SizedBox(height: 16.h),
        const _LegacyIssueFee(),
        SizedBox(height: 20.h),
        const CardHolderTabSection(),
        SizedBox(height: 16.h),
        Obx(
          () => controller.selectedTab.value
              ? const ChooseCardHolderSection()
              : const CreateNewCardHolderSection(),
        ),
      ],
    );
  }
}

class _LegacyIssueFee extends StatelessWidget {
  const _LegacyIssueFee();

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsService>();
    final fee = settings.getSetting('card_creation_charge');
    final currency = settings.getSetting('site_currency');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: AppColors.lightTextTertiary.withValues(alpha: 0.05),
      ),
      child: Text(
        'Issue fee: $fee $currency',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColors.error.withValues(alpha: 0.70),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProviderOption {
  final String value;
  final String title;
  final String subtitle;

  const _ProviderOption({
    required this.value,
    required this.title,
    required this.subtitle,
  });
}

class _ProviderOptionTile extends StatelessWidget {
  final _ProviderOption option;
  final bool isSelected;

  const _ProviderOptionTile({
    required this.option,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.lightPrimary.withValues(alpha: 0.06)
            : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: isSelected
            ? Border.all(
                color: AppColors.lightPrimary.withValues(alpha: 0.20),
                width: 1.5.w,
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.title,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.lightPrimary
                        : AppColors.lightTextPrimary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (option.subtitle.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    option.subtitle,
                    style: TextStyle(
                      color: AppColors.lightTextTertiary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isSelected)
            Image.asset(
              PngAssets.commonDropdownTickIcon,
              width: 18.w,
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.lightTextTertiary,
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }
}

class _AvailabilityMessage extends StatelessWidget {
  final String message;

  const _AvailabilityMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.lightTextTertiary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.lightTextTertiary,
          fontSize: 13.sp,
        ),
      ),
    );
  }
}
