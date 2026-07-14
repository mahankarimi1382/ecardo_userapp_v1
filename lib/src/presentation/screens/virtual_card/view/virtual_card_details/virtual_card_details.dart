import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/virtual_card_details_controller.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/bsicards/bsicards_card_top_up_bottom_sheet.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/bsicards/bsicards_provider.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/stripe/stripe_card_top_up_bottom_sheet.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/stripe/stripe_provider.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/generic/generic_card_provider.dart';

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
  final String initialProvider = (Get.arguments?["provider"] ?? "")
      .toString()
      .toLowerCase();

  Future<void> _fetchCardDetailsByProvider() {
    if (initialProvider == "bsicards") {
      return controller.fetchVirtualCardDetailsBsiCardProvider(cardId: id);
    }

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
      final fetchedProvider =
          controller.virtualCardDetailsModel.value.data?.provider
              ?.toLowerCase() ??
          "";
      final provider = initialProvider.isNotEmpty
          ? initialProvider
          : fetchedProvider;
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
                          arguments: {"card_id": cardId},
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
                        child: provider == "stripe"
                            ? const StripeProvider()
                            : provider == "bsicards"
                            ? const BsicardsProvider()
                            : const GenericCardProvider(),
                      ),
                    ),
            ),
          ],
        ),
        floatingActionButton: controller.isLoading.value || !canTopUp
            ? null
            : Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: SizedBox(
                  height: 40.h,
                  width: 120.w,
                  child: FloatingActionButton(
                    heroTag: null,
                    elevation: 0,
                    onPressed: () {
                      if (provider == "stripe") {
                        Get.bottomSheet(StripeCardTopUpBottomSheet(cardId: id));
                      } else if (provider == "bsicards") {
                        Get.bottomSheet(BsicardsCardTopUpBottomSheet());
                      } else {
                        Get.bottomSheet(
                          _GenericTopUpBottomSheet(cardId: id),
                          isScrollControlled: true,
                        );
                      }
                    },
                    backgroundColor: const Color(0xFF7445FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(PngAssets.addCommonIcon, width: 18.w),
                        SizedBox(width: 4.w),
                        Text(
                          localization.virtualCardDetailsFloatingButton,
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
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

  @override
  void initState() {
    super.initState();
    final funding = controller.virtualCardDetailsModel.value.data?.funding;
    fundingSource = funding?.defaultSource ?? 'irr_wallet';
    gatewayMethodId = funding?.defaultGatewayMethodId;
    controller.fetchIrrWallets().then((_) {
      if (!mounted) return;
      setState(() {
        walletId ??= controller.irrWallets.firstOrNull?.id;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final funding = controller.virtualCardDetailsModel.value.data?.funding;
    final supportsWallet =
        funding?.mode == 'both' ||
        funding?.mode == 'irr_wallet' ||
        funding?.defaultSource == 'irr_wallet';
    final supportsGateway =
        funding?.mode == 'both' ||
        funding?.mode == 'gateway' ||
        funding?.defaultSource == 'gateway';

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
              TextField(
                controller: controller.amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Top-up amount (IRR)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.h),
              if (supportsWallet && supportsGateway) ...[
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'irr_wallet',
                      label: Text('IRR Wallet'),
                    ),
                    ButtonSegment(
                      value: 'gateway',
                      label: Text('Payment Gateway'),
                    ),
                  ],
                  selected: {fundingSource},
                  onSelectionChanged: (values) {
                    setState(() => fundingSource = values.first);
                  },
                ),
                SizedBox(height: 16.h),
              ],
              if (fundingSource == 'irr_wallet')
                Obx(
                  () => DropdownButtonFormField<int>(
                    initialValue: walletId,
                    decoration: const InputDecoration(
                      labelText: 'IRR wallet',
                      border: OutlineInputBorder(),
                    ),
                    items: controller.irrWallets
                        .map(
                          (wallet) => DropdownMenuItem(
                            value: wallet.id,
                            child: Text(
                              '${wallet.name ?? 'IRR'} - '
                              '${wallet.formattedBalance ?? wallet.balance ?? '0'}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => walletId = value),
                  ),
                ),
              if (fundingSource == 'gateway')
                DropdownButtonFormField<int>(
                  initialValue: gatewayMethodId,
                  decoration: const InputDecoration(
                    labelText: 'Payment gateway',
                    border: OutlineInputBorder(),
                  ),
                  items: (funding?.gateways ?? [])
                      .map(
                        (gateway) => DropdownMenuItem(
                          value: gateway.id,
                          child: Text(
                            gateway.name ?? gateway.gatewayCode ?? '',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => gatewayMethodId = value);
                  },
                ),
              SizedBox(height: 16.h),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isCardBalanceTopUpLoading.value
                        ? null
                        : () => controller.irrCardBalanceTopUp(
                            cardId: widget.cardId,
                            fundingSource: fundingSource,
                            walletId: walletId,
                            gatewayMethodId: gatewayMethodId,
                          ),
                    child: controller.isCardBalanceTopUpLoading.value
                        ? const CircularProgressIndicator()
                        : const Text('Continue'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
