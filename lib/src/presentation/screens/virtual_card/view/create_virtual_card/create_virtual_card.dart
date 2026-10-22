import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet_three.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/controller/create_virtual_card_controller.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/view/create_virtual_card/sub_sections/card_holder_tab_section.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/view/create_virtual_card/sub_sections/choose_card_holder_section.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/view/create_virtual_card/sub_sections/create_new_card_holder_section.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/view/create_virtual_card/sub_sections/irr_card_order_section.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/view/widgets/common_virtual_card_view.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: const CommonDefaultAppBar(),
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
              SizedBox(height: 24.h),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const CommonLoading();
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
                      padding: EdgeInsets.fromLTRB(
                        18.w,
                        20.h,
                        18.w,
                        30.h + MediaQuery.viewInsetsOf(context).bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _CreateCardPreviewHero(controller: controller),
                          _UnifiedProviderSelector(controller: controller),
                          SizedBox(height: 12.h),
                          _FeeBreakdownTable(controller: controller),
                          SizedBox(height: 16.h),
                          Obx(() => controller.creationMode.value == 'product'
                              ? _IrrProductArea(controller: controller)
                              : const SizedBox.shrink()),
                          SizedBox(height: 20.h),
                          _SectionHeader(
                            title: l10nPick(
                              context,
                              en: 'Cardholder information',
                              fa: 'اطلاعات دارنده کارت',
                              ar: 'معلومات حامل البطاقة',
                              tr: 'Kart Sahibi Bilgileri',
                              ru: 'Информация о держателе карты',
                              zh: '持卡人信息',
                            ),
                            subtitle: l10nPick(
                              context,
                              en: 'Choose an existing cardholder or enter new cardholder details.',
                              fa: 'یک دارنده کارت موجود را انتخاب کرده یا مشخصات جدید وارد کنید.',
                              ar: 'اختر حامل بطاقة موجود أو أدخل تفاصيل حامل بطاقة جديد.',
                              tr: 'Mevcut bir kart sahibini seçin veya yeni kart sahibi bilgileri girin.',
                              ru: 'Выберите существующего держателя карты или введите новые данные.',
                              zh: '选择已有持卡人或输入新持卡人信息。',
                            ),
                          ),
                          SizedBox(height: 16.h),
                          const CardHolderTabSection(),
                          SizedBox(height: 16.h),
                          Obx(
                            () => controller.selectedTab.value
                                ? const ChooseCardHolderSection(
                                    showSubmitButton: false,
                                  )
                                : const CreateNewCardHolderSection(
                                    showSubmitButton: false,
                                  ),
                          ),
                          SizedBox(height: 12.h),
                          Obx(
                            () => CommonButton(
                              width: double.infinity,
                              text: l10nPick(
                                context,
                                en: 'Create Virtual Card',
                                fa: 'ایجاد کارت مجازی',
                                ar: 'إنشاء بطاقة افتراضية',
                                tr: 'Sanal Kart Oluştur',
                                ru: 'Создать виртуальную карту',
                                zh: '创建虚拟卡',
                              ),
                              isLoading:
                                  controller.isCreateVirtualCardLoading.value,
                              onPressed: controller.submitSelectedCard,
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
              child: const CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }
}

class _IrrProductArea extends StatelessWidget {
  final CreateVirtualCardController controller;

  const _IrrProductArea({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isCardProductsLoading.value) {
        return const SizedBox(height: 180, child: CommonLoading());
      }

      if (controller.cardProducts.isNotEmpty) {
        return const IrrCardOrderSection();
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
                  : 'No active card product is currently available.',
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
              text: 'Retry',
              onPressed: controller.retryCardProducts,
            ),
          ],
        ),
      );
    });
  }
}

/// Tokenized Card Provider Selection Cards & Dropdown
class _UnifiedProviderSelector extends StatelessWidget {
  final CreateVirtualCardController controller;

  const _UnifiedProviderSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            network: product.issuer?.network ?? product.display?.network ?? 'VISA',
            currency: product.currency?.toUpperCase() ?? 'USD',
          ),
        ),
        ...controller.cardProvidersList
            .where((provider) => (provider.code ?? '').isNotEmpty)
            .map(
              (provider) => _ProviderOption(
                value: 'legacy:${provider.code}',
                title: provider.name ?? provider.code ?? 'Virtual card provider',
                subtitle: 'Legacy provider integration',
                network: 'CARD',
                currency: 'USD',
              ),
            ),
      ];

      if (options.isEmpty) {
        return const _AvailabilityMessage(
          message: 'No virtual-card provider is currently available.',
        );
      }

      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonRequiredLabelAndDynamicField(
              labelText: l10nPick(
                context,
                en: 'Card Provider',
                fa: 'ارائه‌دهنده کارت',
                ar: 'مزود البطاقة',
                tr: 'Kart Sağlayıcısı',
                ru: 'Провайдер карты',
                zh: '发卡机构',
              ),
              isLabelRequired: true,
              dynamicField: CommonTextInputField(
                suffixIcon: Image.asset(
                  PngAssets.arrowDownCommonIcon,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextTertiary,
                ),
                focusNode: controller.cardProviderFocusNode,
                isFocused: controller.isCardProviderFocused.value,
                hintText: l10nPick(
                  context,
                  en: 'Select Card Provider',
                  fa: 'انتخاب ارائه‌دهنده کارت',
                  ar: 'اختر مزود البطاقة',
                  tr: 'Kart Sağlayıcısı Seçin',
                  ru: 'Выберите провайдера карты',
                  zh: '选择发卡机构',
                ),
                controller: controller.cardProviderController,
                suffixIconColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextTertiary,
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
                      title: l10nPick(
                        context,
                        en: 'Select Card Provider',
                        fa: 'انتخاب ارائه‌دهنده کارت',
                        ar: 'اختر مزود البطاقة',
                        tr: 'Kart Sağlayıcısı Seçin',
                        ru: 'Выберите провайдера карты',
                        zh: '选择发卡机构',
                      ),
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
            SizedBox(height: 12.h),
            Text(
              l10nPick(
                context,
                en: 'Choose Card Type',
                fa: 'انتخاب نوع کارت',
                ar: 'اختر نوع البطاقة',
                tr: 'Kart Tipini Seçin',
                ru: 'Выберите тип карты',
                zh: '选择卡片类型',
              ),
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            // Modern Tokenized Card Provider Selection Cards
            ...options.map((option) {
              final isSelected = option.value == controller.selectedCreationOption.value;
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _ProviderSelectionCard(
                  option: option,
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () => controller.selectCreationOption(option.value),
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}

/// Tokenized Provider Selection Card with active border highlights
class _ProviderSelectionCard extends StatelessWidget {
  final _ProviderOption option;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ProviderSelectionCard({
    required this.option,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.mainSoftBlue : AppColors.brandViolet;

    return Material(
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
                    : AppColors.brandVioletContainer.withValues(alpha: 0.50))
                : (isDark
                    ? AppColors.darkSurfaceVariant.withValues(alpha: 0.35)
                    : AppColors.lightSurfaceVariant.withValues(alpha: 0.60)),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isSelected ? 1.8.w : 1.0.w,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: isDark ? 0.25 : 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Network / Card Icon Badge
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: isSelected
                      ? activeColor.withValues(alpha: isDark ? 0.25 : 0.15)
                      : (isDark ? AppColors.darkSurface : AppColors.white),
                  border: Border.all(
                    color: isSelected
                        ? activeColor
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.credit_card_rounded,
                    color: isSelected
                        ? activeColor
                        : (isDark ? AppColors.darkTextPrimary : AppColors.brandViolet),
                    size: 22.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            option.title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected
                                  ? (isDark ? AppColors.darkTextPrimary : AppColors.brandViolet)
                                  : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                            ),
                          ),
                        ),
                        if (option.currency.isNotEmpty) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? activeColor.withValues(alpha: 0.18)
                                  : (isDark
                                      ? AppColors.darkBorder.withValues(alpha: 0.5)
                                      : AppColors.lightBorder.withValues(alpha: 0.5)),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              option.currency,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? activeColor
                                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (option.subtitle.isNotEmpty) ...[
                      SizedBox(height: 3.h),
                      Text(
                        option.subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              // Selection Checkmark
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? activeColor : AppColors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? activeColor
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
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
    );
  }
}

/// Modern Fee Breakdown Table using DynamicDecimalsHelper, AppColors.brandViolet and AppColors.success
class _FeeBreakdownTable extends StatelessWidget {
  final CreateVirtualCardController controller;

  const _FeeBreakdownTable({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final SettingsService settingsService = Get.find<SettingsService>();
    final siteCurrency = settingsService.getSetting('site_currency') ?? 'USD';
    final siteDecimals = settingsService.getSetting('site_currency_decimals');

    return Obx(() {
      final product = controller.selectedCardProduct.value;
      final isProductMode = controller.creationMode.value == 'product' && product != null;

      final currency = isProductMode
          ? (product.currency ?? 'USD').toUpperCase()
          : siteCurrency.toUpperCase();

      // Resolve decimal precision using DynamicDecimalsHelper
      final decimals = DynamicDecimalsHelper().getDynamicDecimals(
        currencyCode: currency,
        siteCurrencyCode: siteCurrency,
        siteCurrencyDecimals: siteDecimals,
        isCrypto: false,
      );

      final formatter = NumberFormat.currency(
        symbol: '',
        decimalDigits: decimals,
      );

      // Card Issuance Fee calculation
      final double creationFee = isProductMode
          ? product.creationFee.toDouble()
          : (double.tryParse(settingsService.getSetting('card_creation_charge') ?? '0') ?? 0);

      // Physical Card Fee
      final bool hasPhysical = isProductMode &&
          product.capabilities?.canRequestPhysical == true &&
          controller.requestPhysical.value;
      final double physicalFee = hasPhysical ? product.physicalCardFee.toDouble() : 0.0;

      // Initial Load Amount entered or minimum
      final double enteredAmount = double.tryParse(controller.amountController.text.trim()) ?? 0.0;
      final double minLoad = isProductMode ? product.minimumInitialLoad.toDouble() : 0.0;
      final double displayLoad = enteredAmount > 0 ? enteredAmount : minLoad;

      // Total Estimated Cost
      final double totalPayable = creationFee + physicalFee + (isProductMode ? displayLoad : 0.0);

      String format(num value) {
        final formatted = formatter.format(value).trim();
        if (currency == 'USD') return '\$$formatted';
        if (currency == 'EUR') return '€$formatted';
        return '$formatted $currency';
      }

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceVariant.withValues(alpha: 0.40)
              : AppColors.lightSurfaceVariant.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 18.sp,
                  color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                ),
                SizedBox(width: 8.w),
                Text(
                  l10nPick(
                    context,
                    en: 'Fee & Pricing Breakdown',
                    fa: 'جزئیات کارمزد و هزینه‌ها',
                    ar: 'تفاصيل الرسوم والأسعار',
                    tr: 'Ücret ve Fiyat Detayları',
                    ru: 'Детализация комиссий и стоимости',
                    zh: '费用明细',
                  ),
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(
              height: 1,
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
            SizedBox(height: 10.h),

            // 1. Issuance Fee Row
            _FeeRow(
              label: l10nPick(
                context,
                en: 'Card Issuance Fee',
                fa: 'کارمزد صدور کارت',
                ar: 'رسوم إصدار البطاقة',
                tr: 'Kart Basım Ücreti',
                ru: 'Комиссия за выпуск карты',
                zh: '开卡费',
              ),
              valueWidget: creationFee <= 0
                  ? Text(
                      l10nPick(
                        context,
                        en: 'FREE',
                        fa: 'رایگان',
                        ar: 'مجاناً',
                        tr: 'ÜCRETSİZ',
                        ru: 'БЕСПЛАТНО',
                        zh: '免费',
                      ),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                      ),
                    )
                  : Text(
                      format(creationFee),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
              isDark: isDark,
            ),

            // 2. Initial Deposit / Load (for products)
            if (isProductMode && displayLoad > 0) ...[
              SizedBox(height: 8.h),
              _FeeRow(
                label: l10nPick(
                  context,
                  en: 'Initial Card Balance',
                  fa: 'موجودی اولیه کارت',
                  ar: 'الرصيد الأولي للبطاقة',
                  tr: 'İlk Kart Bakiyesi',
                  ru: 'Начальный баланс карты',
                  zh: '初始卡内充值',
                ),
                valueWidget: Text(
                  format(displayLoad),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                isDark: isDark,
              ),
            ],

            // 3. Physical Card Fee (if requested)
            if (hasPhysical) ...[
              SizedBox(height: 8.h),
              _FeeRow(
                label: l10nPick(
                  context,
                  en: 'Physical Delivery Fee',
                  fa: 'هزینه ارسال کارت فیزیکی',
                  ar: 'رسوم تسليم البطاقة الفعلية',
                  tr: 'Fiziksel Kart Gönderim Ücreti',
                  ru: 'Доставка физической карты',
                  zh: '实体卡寄送费',
                ),
                valueWidget: Text(
                  format(physicalFee),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                isDark: isDark,
              ),
            ],

            // 4. Monthly Maintenance Fee
            SizedBox(height: 8.h),
            _FeeRow(
              label: l10nPick(
                context,
                en: 'Monthly Maintenance',
                fa: 'آبونمان و نگهداری ماهانه',
                ar: 'الصيانة الشهرية',
                tr: 'Aylık Bakım Ücreti',
                ru: 'Ежемесячное обслуживание',
                zh: '月度管理费',
              ),
              valueWidget: Text(
                l10nPick(
                  context,
                  en: 'FREE',
                  fa: 'رایگان (0.00)',
                  ar: 'مجاناً',
                  tr: 'ÜCRETSİZ',
                  ru: 'БЕСПЛАТНО',
                  zh: '免费',
                ),
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
              isDark: isDark,
            ),

            SizedBox(height: 12.h),
            Divider(
              height: 1,
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
            SizedBox(height: 10.h),

            // Total Estimated Row with brandViolet highlight
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10nPick(
                    context,
                    en: 'Total Estimated Cost',
                    fa: 'مجموع هزینه برآوردی',
                    ar: 'إجمالي التكلفة المقدرة',
                    tr: 'Tahmini Toplam Tutar',
                    ru: 'Итоговая расчетная стоимость',
                    zh: '预计总费用',
                  ),
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  format(totalPayable),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final Widget valueWidget;
  final bool isDark;

  const _FeeRow({
    required this.label,
    required this.valueWidget,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5.sp,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
        valueWidget,
      ],
    );
  }
}

class _ProviderOption {
  final String value;
  final String title;
  final String subtitle;
  final String network;
  final String currency;

  const _ProviderOption({
    required this.value,
    required this.title,
    required this.subtitle,
    this.network = 'VISA',
    this.currency = 'USD',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.mainSoftBlue : AppColors.brandViolet;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark
                ? AppColors.darkPrimaryContainer.withValues(alpha: 0.35)
                : AppColors.brandVioletContainer.withValues(alpha: 0.45))
            : (isDark ? AppColors.darkCard : AppColors.lightBackground),
        borderRadius: BorderRadius.circular(16.r),
        border: isSelected
            ? Border.all(
                color: activeColor.withValues(alpha: 0.60),
                width: 1.5.w,
              )
            : Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1.0,
              ),
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
                        ? activeColor
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (option.subtitle.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    option.subtitle,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextTertiary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle_rounded,
              color: activeColor,
              size: 20.sp,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextTertiary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkSurfaceVariant : AppColors.lightTextTertiary)
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextTertiary,
          fontSize: 13.sp,
        ),
      ),
    );
  }
}

class _CreateCardPreviewHero extends StatelessWidget {
  final CreateVirtualCardController controller;

  const _CreateCardPreviewHero({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final product = controller.selectedCardProduct.value;
      final provider = controller.selectedCardProvider.value;
      final holder = controller.selectedCardHolder.value;
      final typedName = controller.nameController.text.trim();
      final holderName = controller.selectedTab.value
          ? (holder?.name?.isNotEmpty == true ? holder!.name! : 'CARDHOLDER NAME')
          : (typedName.isNotEmpty ? typedName : 'CARDHOLDER NAME');

      final cardTitle = product?.display?.title ??
          product?.name ??
          provider?.name ??
          'Virtual Card';

      final network = product?.display?.network ??
          product?.issuer?.network ??
          'Visa';

      final currency = product?.currency?.toUpperCase() ?? 'USD';

      return Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonVirtualCardView(
              title: cardTitle,
              cardHolderName: holderName,
              value: '•••• •••• •••• 4242',
              firstLabel: 'EXPIRY',
              firstValue: '12/29',
              secondLabel: 'CURRENCY',
              secondValue: currency,
              status: 'Active',
              enableFlip: true,
              showFlipIndicator: true,
              network: network,
              brandImage: product?.display?.brandImage,
              backgroundImage: product?.display?.backgroundImage,
            ),
          ],
        ),
      );
    });
  }
}
