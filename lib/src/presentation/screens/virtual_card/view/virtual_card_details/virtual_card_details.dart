import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet_three.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/virtual_card_details_controller.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/generic/generic_card_provider.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/model/virtual_card_details_model.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/model/wallets_model.dart';

import '../../../../../app/constants/app_colors.dart';
import '../../../../../app/constants/assets_path/png/png_assets.dart';
import '../../../../../common/widgets/app_bar/common_app_bar.dart';
import '../../../../../common/widgets/app_bar/common_default_app_bar.dart';

class VirtualCardDetails extends StatefulWidget {
  const VirtualCardDetails({super.key});

  @override
  State<VirtualCardDetails> createState() => _VirtualCardDetailsState();
}

class _VirtualCardDetailsState extends State<VirtualCardDetails> {
  final VirtualCardDetailsController controller = Get.find();
  final String id = Get.arguments?["id"] ?? "";
  final String cardId = Get.arguments?["card_id"] ?? "";
  Future<void> _fetchCardDetailsByProvider() {
    return controller.fetchVirtualCardDetails(cardId: id);
  }

  @override
  void initState() {
    super.initState();
    _fetchCardDetailsByProvider();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Obx(() {
      final card = controller.virtualCardDetailsModel.value.data;
      final hasGenericContract =
          card?.display != null ||
          card?.capabilities != null ||
          card?.funding != null ||
          card?.actions != null;
      final canViewTransactions =
          !hasGenericContract || card?.capabilities?.canViewTransactions == true;
      final canTopUp =
          !hasGenericContract || card?.capabilities?.canTopup == true;

      return Scaffold(
        appBar: const CommonDefaultAppBar(),
        body: Column(
          children: [
            SizedBox(height: 16.h),
            CommonAppBar(
              title: localization!.virtualCardDetailsAppBarTitle,
              rightSideWidget: canViewTransactions
                  ? GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          BaseRoute.virtualCardTransaction,
                          arguments: {
                            "card_id": cardId,
                            "endpoint": card?.actions?.transactionsEndpoint,
                          },
                        );
                      },
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(end: 18.w),
                        child: Image.asset(
                          PngAssets.commonHistoryIcon,
                          width: 30.w,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Expanded(
              child: controller.isLoading.value
                  ? const CommonLoading()
                  : RefreshIndicator(
                      onRefresh: _fetchCardDetailsByProvider,
                      color: AppColors.lightPrimary,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: const GenericCardProvider(),
                      ),
                    ),
            ),
          ],
        ),
        floatingActionButton: controller.isLoading.value || !canTopUp
            ? null
            : Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: CommonButton(
                  width: 130,
                  height: 42,
                  borderRadius: 12,
                  fontSize: 13,
                  text: localization.virtualCardDetailsFloatingButton,
                  onPressed: () {
                    Get.bottomSheet(
                      _GenericTopUpBottomSheet(cardId: id),
                      isScrollControlled: true,
                    );
                  },
                ),
              ),
      );
    });
  }
}

class _GenericTopUpBottomSheet extends StatefulWidget {
  final String cardId;

  const _GenericTopUpBottomSheet({required this.cardId});

  @override
  State<_GenericTopUpBottomSheet> createState() =>
      _GenericTopUpBottomSheetState();
}

class _GenericTopUpBottomSheetState extends State<_GenericTopUpBottomSheet> {
  final VirtualCardDetailsController controller = Get.find();
  String fundingSource = 'irr_wallet';
  int? walletId;
  int? gatewayMethodId;
  final walletController = TextEditingController();
  final gatewayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.amountController.clear();
    final funding = controller.virtualCardDetailsModel.value.data?.funding;
    fundingSource = funding?.defaultSource ??
        (funding?.mode == 'gateway_direct' ? 'gateway' : 'irr_wallet');
    gatewayMethodId = funding?.defaultGatewayMethodId;
    final selectedGateway = funding?.gateways.firstWhereOrNull(
      (gateway) => gateway.id == gatewayMethodId,
    );
    gatewayController.text =
        selectedGateway?.name ?? selectedGateway?.gatewayCode ?? '';
    if (_supportsWallet(funding)) {
      controller.fetchIrrWallets().then((_) {
        if (!mounted) return;
        setState(() {
          walletId ??= controller.irrWallets.firstOrNull?.id;
          walletController.text = _walletText(
            controller.irrWallets.firstOrNull,
          );
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
    final funding = controller.virtualCardDetailsModel.value.data?.funding;
    final supportsWallet = _supportsWallet(funding);
    final supportsGateway = _supportsGateway(funding);
    final hasFundingContract = funding != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonRequiredLabelAndDynamicField(
                labelText: 'Top-up amount',
                isLabelRequired: true,
                dynamicField: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonTextInputField(
                      hintText: 'Enter amount',
                      controller: controller.amountController,
                      keyboardType: TextInputType.number,
                    ),
                    if (hasFundingContract) ...[
                      SizedBox(height: 6.h),
                      Text(
                        '${funding!.minimumTopup} - '
                        '${funding.maximumTopup} '
                        '${controller.virtualCardDetailsModel.value.data?.currency ?? ''}',
                        style: TextStyle(
                          color: AppColors.lightTextTertiary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              if (supportsWallet && supportsGateway) ...[
                _FundingTabs(
                  value: fundingSource,
                  onChanged: (value) {
                    setState(() => fundingSource = value);
                  },
                ),
                SizedBox(height: 16.h),
              ],
              if (hasFundingContract &&
                  supportsWallet &&
                  fundingSource == 'irr_wallet')
                Obx(
                  () => CommonRequiredLabelAndDynamicField(
                    labelText: 'IRR wallet',
                    isLabelRequired: true,
                    dynamicField: CommonTextInputField(
                      hintText: 'Select IRR wallet',
                      controller: walletController,
                      readOnly: true,
                      suffixIcon: Image.asset(
                        PngAssets.arrowDownCommonIcon,
                      ),
                      onTap: () {
                        final selected = controller.irrWallets.firstWhereOrNull(
                          (wallet) => wallet.id == walletId,
                        );
                        Get.bottomSheet(
                          CommonDropdownBottomSheetThree<Wallets>(
                            items: controller.irrWallets,
                            selectedItem: selected,
                            bottomSheetHeight: 400.h,
                            isShowTitle: true,
                            title: 'Select IRR Wallet',
                            notFoundText: 'No IRR wallet found',
                            getDisplayText: (wallet) =>
                                _walletText(wallet),
                            areItemsEqual: (first, second) =>
                                first.id == second.id,
                            onItemSelected: (wallet) {
                              setState(() {
                                walletId = wallet.id;
                                walletController.text = _walletText(wallet);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              if (hasFundingContract &&
                  supportsGateway &&
                  fundingSource == 'gateway')
                CommonRequiredLabelAndDynamicField(
                  labelText: 'Payment gateway',
                  isLabelRequired: true,
                  dynamicField: CommonTextInputField(
                    hintText: 'Select payment gateway',
                    controller: gatewayController,
                    readOnly: true,
                    suffixIcon: Image.asset(PngAssets.arrowDownCommonIcon),
                    onTap: () {
                      final selected = funding?.gateways.firstWhereOrNull(
                        (gateway) => gateway.id == gatewayMethodId,
                      );
                      Get.bottomSheet(
                        CommonDropdownBottomSheetThree<CardGateway>(
                          items: funding?.gateways ?? [],
                          selectedItem: selected,
                          bottomSheetHeight: 400.h,
                          isShowTitle: true,
                          title: 'Select Payment Gateway',
                          notFoundText: 'No payment gateway found',
                          getDisplayText: (gateway) =>
                              gateway.name ?? gateway.gatewayCode ?? '',
                          areItemsEqual: (first, second) =>
                              first.id == second.id,
                          onItemSelected: (gateway) {
                            setState(() {
                              gatewayMethodId = gateway.id;
                              gatewayController.text =
                                  gateway.name ?? gateway.gatewayCode ?? '';
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 16.h),
              Obx(
                () => CommonButton(
                  width: double.infinity,
                  text: 'Continue',
                  isLoading: controller.isCardBalanceTopUpLoading.value,
                  onPressed: () => controller.cardBalanceTopUpFromContract(
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
    );
  }

  static String _walletText(Wallets? wallet) {
    if (wallet == null) return '';
    return '${wallet.name ?? 'IRR'} - '
        '${wallet.formattedBalance ?? wallet.balance ?? '0'}';
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
    return Row(
      children: [
        Expanded(
          child: CommonButton(
            height: 42,
            borderRadius: 12,
            fontSize: 12,
            text: 'IRR Wallet',
            backgroundColor: value == 'irr_wallet'
                ? AppColors.lightPrimary
                : AppColors.white,
            textColor: value == 'irr_wallet'
                ? AppColors.white
                : AppColors.lightTextPrimary,
            borderColor: value == 'irr_wallet'
                ? null
                : AppColors.lightTextPrimary.withValues(alpha: 0.15),
            onPressed: () => onChanged('irr_wallet'),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: CommonButton(
            height: 42,
            borderRadius: 12,
            fontSize: 12,
            text: 'Payment Gateway',
            backgroundColor: value == 'gateway'
                ? AppColors.lightPrimary
                : AppColors.white,
            textColor: value == 'gateway'
                ? AppColors.white
                : AppColors.lightTextPrimary,
            borderColor: value == 'gateway'
                ? null
                : AppColors.lightTextPrimary.withValues(alpha: 0.15),
            onPressed: () => onChanged('gateway'),
          ),
        ),
      ],
    );
  }
}
