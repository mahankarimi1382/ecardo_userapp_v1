import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet_three.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/virtual_card_details_controller.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/model/virtual_card_details_model.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/model/wallets_model.dart';

class GenericCardTopUpBottomSheet extends StatefulWidget {
  final String cardId;

  const GenericCardTopUpBottomSheet({
    super.key,
    required this.cardId,
  });

  @override
  State<GenericCardTopUpBottomSheet> createState() =>
      _GenericCardTopUpBottomSheetState();
}

class _GenericCardTopUpBottomSheetState
    extends State<GenericCardTopUpBottomSheet> {
  final VirtualCardDetailsController controller = Get.find();
  final walletController = TextEditingController();
  final gatewayController = TextEditingController();
  String fundingSource = 'irr_wallet';
  int? walletId;
  int? gatewayMethodId;

  @override
  void initState() {
    super.initState();
    controller.amountController.clear();
    controller.baseAmount.value = 0;
    controller.calculatedCharge.value = 0;
    controller.totalAmount.value = 0;
    final funding = controller.virtualCardDetailsModel.value.data?.funding;
    fundingSource = _initialFundingSource(funding);
    gatewayMethodId = funding?.defaultGatewayMethodId;
    final gateway = funding?.gateways.firstWhereOrNull(
      (item) => item.id == gatewayMethodId,
    );
    gatewayController.text = _gatewayText(gateway);

    if (_supportsWallet(funding)) {
      controller.fetchIrrWallets().then((_) {
        if (!mounted) return;
        final wallet = controller.irrWallets.firstOrNull;
        setState(() {
          walletId = wallet?.id;
          walletController.text = _walletText(wallet);
        });
      });
    }
  }

  @override
  void dispose() {
    walletController.dispose();
    gatewayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final card = controller.virtualCardDetailsModel.value.data;
    final funding = card?.funding;
    final supportsWallet = _supportsWallet(funding);
    final supportsGateway = _supportsGateway(funding);
    final selectedWallet = controller.irrWallets.firstWhereOrNull(
      (wallet) => wallet.id == walletId,
    );
    final limitText = _limitText(card, funding);
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final availableHeight = screenHeight - keyboardHeight;
    final sheetHeight = keyboardHeight > 0
        ? availableHeight
        : screenHeight * 0.88;
    final gateways = funding?.gateways ?? <CardGateway>[];

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: SizedBox(
        height: sheetHeight,
        child: AnimatedContainer(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuart,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(24.r),
              topEnd: Radius.circular(24.r),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.06),
                blurRadius: 40,
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 35.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                localization.cardTopUpTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 10.h),
              _Divider(),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.only(bottom: 30.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      _BalanceBanner(
                        title: _balanceTitle(localization, funding),
                        value: _balanceValue(
                          card,
                          funding,
                          selectedWallet,
                        ),
                      ),
                      if (supportsWallet && supportsGateway) ...[
                        SizedBox(height: 16.h),
                        _FundingTabs(
                          value: fundingSource,
                          onChanged: (value) {
                            setState(() => fundingSource = value);
                            _review();
                          },
                        ),
                      ],
                      if (funding != null &&
                          supportsWallet &&
                          fundingSource == 'irr_wallet') ...[
                        SizedBox(height: 16.h),
                        CommonRequiredLabelAndDynamicField(
                          labelText: 'IRR wallet',
                          isLabelRequired: true,
                          dynamicField: CommonTextInputField(
                            backgroundColor: AppColors.lightBackground,
                            hintText: 'Select IRR wallet',
                            controller: walletController,
                            readOnly: true,
                            suffixIcon: Image.asset(
                              PngAssets.arrowDownCommonIcon,
                            ),
                            onTap: () {
                              Get.bottomSheet(
                                CommonDropdownBottomSheetThree<Wallets>(
                                  items: controller.irrWallets,
                                  selectedItem: selectedWallet,
                                  bottomSheetHeight: 400.h,
                                  isShowTitle: true,
                                  title: 'Select IRR Wallet',
                                  notFoundText: 'No IRR wallet found',
                                  getDisplayText: _walletText,
                                  areItemsEqual: (first, second) =>
                                      first.id == second.id,
                                  onItemSelected: (wallet) {
                                    setState(() {
                                      walletId = wallet.id;
                                      walletController.text =
                                          _walletText(wallet);
                                    });
                                  },
                                ),
                                isScrollControlled: true,
                              );
                            },
                          ),
                        ),
                      ],
                      if (funding != null &&
                          supportsGateway &&
                          fundingSource == 'gateway') ...[
                        SizedBox(height: 16.h),
                        CommonRequiredLabelAndDynamicField(
                          labelText: 'Payment gateway',
                          isLabelRequired: true,
                          dynamicField: CommonTextInputField(
                            backgroundColor: AppColors.lightBackground,
                            hintText: 'Select payment gateway',
                            controller: gatewayController,
                            readOnly: true,
                            suffixIcon: Image.asset(
                              PngAssets.arrowDownCommonIcon,
                            ),
                            onTap: () {
                              final selected = gateways.firstWhereOrNull(
                                (gateway) => gateway.id == gatewayMethodId,
                              );
                              Get.bottomSheet(
                                CommonDropdownBottomSheetThree<CardGateway>(
                                  items: gateways,
                                  selectedItem: selected,
                                  bottomSheetHeight: 400.h,
                                  isShowTitle: true,
                                  title: 'Select Payment Gateway',
                                  notFoundText: 'No payment gateway found',
                                  getDisplayText: _gatewayText,
                                  getItemSubtitle: (gateway) =>
                                      '${gateway.minimumDeposit} - '
                                      '${gateway.maximumDeposit} '
                                      '${gateway.currency ?? card?.currency ?? ''}',
                                  areItemsEqual: (first, second) =>
                                      first.id == second.id,
                                  onItemSelected: (gateway) {
                                    setState(() {
                                      gatewayMethodId = gateway.id;
                                      gatewayController.text =
                                          _gatewayText(gateway);
                                    });
                                    _review();
                                  },
                                ),
                                isScrollControlled: true,
                              );
                            },
                          ),
                        ),
                      ],
                      SizedBox(height: 16.h),
                      CommonRequiredLabelAndDynamicField(
                        labelText: localization.cardTopUpLabelAmount,
                        isLabelRequired: true,
                        dynamicField: Obx(
                          () => CommonTextInputField(
                            backgroundColor: AppColors.lightBackground,
                            controller: controller.amountController,
                            focusNode: controller.amountFocusNode,
                            isFocused: controller.isAmountFocused.value,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: funding == null,
                            ),
                            hintText: '',
                            onChanged: (_) => _review(),
                          ),
                        ),
                      ),
                      if (limitText.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          limitText,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                      SizedBox(height: 30.h),
                      _ReviewSection(controller: controller, card: card),
                      SizedBox(height: 30.h),
                      Obx(
                        () => CommonButton(
                          isLoading:
                              controller.isCardBalanceTopUpLoading.value,
                          text: localization.cardTopUpButtonTopupNow,
                          onPressed: () =>
                              controller.cardBalanceTopUpFromContract(
                                cardId: widget.cardId,
                                fundingSource: fundingSource,
                                walletId: walletId,
                                gatewayMethodId: gatewayMethodId,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _review() {
    controller.reviewContractTopUp(
      fundingSource: fundingSource,
      gatewayMethodId: gatewayMethodId,
    );
  }

  static bool _supportsWallet(CardFunding? funding) {
    return funding?.mode == 'both' ||
        funding?.mode == 'wallet' ||
        funding?.mode == 'irr_wallet' ||
        funding?.defaultSource == 'irr_wallet';
  }

  static bool _supportsGateway(CardFunding? funding) {
    return funding?.mode == 'both' ||
        funding?.mode == 'gateway_direct' ||
        funding?.mode == 'gateway' ||
        funding?.defaultSource == 'gateway';
  }

  static String _initialFundingSource(CardFunding? funding) {
    final defaultSource = funding?.defaultSource;
    if (defaultSource == 'gateway' || defaultSource == 'irr_wallet') {
      return defaultSource!;
    }
    return _supportsGateway(funding) && !_supportsWallet(funding)
        ? 'gateway'
        : 'irr_wallet';
  }

  static String _walletText(Wallets? wallet) {
    if (wallet == null) return '';
    return '${wallet.name ?? 'IRR'} - '
        '${wallet.formattedBalance ?? wallet.balance ?? '0'}';
  }

  static String _gatewayText(CardGateway? gateway) {
    return gateway?.name ?? gateway?.gatewayCode ?? '';
  }

  static String _limitText(
    VirtualCardDetailsData? card,
    CardFunding? funding,
  ) {
    if (funding != null) {
      return '${funding.minimumTopup} - ${funding.maximumTopup} '
          '${card?.currency ?? ''}';
    }
    final settings = Get.find<SettingsService>();
    final minimum = settings.getSetting('min_card_topup') ?? '';
    final maximum = settings.getSetting('max_card_topup') ?? '';
    final currency =
        settings.getSetting('site_currency') ?? card?.currency ?? '';
    if (minimum.isEmpty && maximum.isEmpty) return '';
    return '$minimum - $maximum $currency';
  }

  String _balanceTitle(
    AppLocalizations localization,
    CardFunding? funding,
  ) {
    if (funding == null || fundingSource == 'irr_wallet') {
      return localization.cardTopUpMainWalletBalance;
    }
    return controller
            .virtualCardDetailsModel
            .value
            .data
            ?.display
            ?.balanceLabel ??
        'Card Balance';
  }

  String _balanceValue(
    VirtualCardDetailsData? card,
    CardFunding? funding,
    Wallets? selectedWallet,
  ) {
    if (funding == null) {
      final settings = Get.find<SettingsService>();
      final balance = Get.find<HomeController>().userModel.value.data?.balance;
      final symbol = settings.getSetting('currency_symbol') ?? '';
      final currency =
          settings.getSetting('site_currency') ?? card?.currency ?? '';
      return '$symbol${balance ?? '0'} $currency';
    }
    if (fundingSource == 'irr_wallet') {
      return '${selectedWallet?.formattedBalance ?? selectedWallet?.balance ?? '0'} '
          '${selectedWallet?.code ?? card?.currency ?? ''}';
    }
    return '${card?.amount ?? '0'} ${card?.currency ?? ''}';
  }
}

class _BalanceBanner extends StatelessWidget {
  final String title;
  final String value;

  const _BalanceBanner({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3.25,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          Image.asset(PngAssets.cardTopUpImage, fit: BoxFit.fill),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                    color: AppColors.white,
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

class _FundingTabs extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _FundingTabs({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: CommonButton(
              height: 42,
              borderRadius: 12,
              fontSize: 11,
              text: 'IRR Wallet',
              backgroundColor: value == 'irr_wallet'
                  ? AppColors.lightPrimary
                  : AppColors.white,
              textColor: value == 'irr_wallet'
                  ? AppColors.white
                  : AppColors.lightTextPrimary,
              onPressed: () => onChanged('irr_wallet'),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: CommonButton(
              height: 42,
              borderRadius: 12,
              fontSize: 11,
              text: 'Payment Gateway',
              backgroundColor: value == 'gateway'
                  ? AppColors.lightPrimary
                  : AppColors.white,
              textColor: value == 'gateway'
                  ? AppColors.white
                  : AppColors.lightTextPrimary,
              onPressed: () => onChanged('gateway'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final VirtualCardDetailsController controller;
  final VirtualCardDetailsData? card;

  const _ReviewSection({
    required this.controller,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final currency = card?.currency ?? '';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: AppColors.lightBackground,
      ),
      child: Column(
        children: [
          Obx(
            () => _ReviewRow(
              title: localization.cardTopUpReviewTopupAmount,
              content: controller.amount.value.isEmpty
                  ? ''
                  : '${controller.baseAmount.value} $currency',
              color: AppColors.success,
            ),
          ),
          _ReviewDivider(),
          Obx(
            () => _ReviewRow(
              title: localization.cardTopUpReviewTopupCharge,
              content: controller.amount.value.isEmpty
                  ? ''
                  : '${controller.calculatedCharge.value} $currency',
              color: AppColors.error,
            ),
          ),
          _ReviewDivider(),
          Obx(
            () => _ReviewRow(
              title: localization.cardTopUpReviewTotalTopupBalance,
              content: controller.amount.value.isEmpty
                  ? ''
                  : '${controller.totalAmount.value} $currency',
              color: AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String title;
  final String content;
  final Color color;

  const _ReviewRow({
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15.sp,
                color: AppColors.lightTextPrimary.withValues(alpha: 0.60),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15.sp,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Divider(
        height: 0,
        color: AppColors.black.withValues(alpha: 0.10),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 1.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.white,
            Colors.grey.shade400,
            AppColors.white,
          ],
        ),
      ),
    );
  }
}
