import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_icon_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/virtual_card_controller.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/model/virtual_cards_model.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/view/widgets/common_virtual_card_view.dart';

class VirtualCardScreen extends StatefulWidget {
  const VirtualCardScreen({super.key});

  @override
  State<VirtualCardScreen> createState() => _VirtualCardScreenState();
}

class _VirtualCardScreenState extends State<VirtualCardScreen> {
  final VirtualCardController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.syncCardBackgroundImageFromSettings();
    controller.fetchVirtualCards();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Obx(
        () => Column(
          children: [
            SizedBox(height: 16.h),
            CommonAppBar(title: localization.virtualCardScreenAppBarTitle),
            Expanded(
              child: controller.isLoading.value
                  ? const CommonLoading()
                  : RefreshIndicator(
                      onRefresh: controller.fetchVirtualCards,
                      color: AppColors.lightPrimary,
                      child: ListView(
                        padding: EdgeInsets.only(bottom: 30.h),
                        children: [
                          _buildCreateCardSection(localization),
                          SizedBox(height: 16.h),
                          ...List.generate(controller.virtualCardList.length, (
                            index,
                          ) {
                            return _cardItem(
                              controller.virtualCardList[index],
                              index,
                            );
                          }),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardItem(VirtualCardsData card, int index) {
    final rawNumber = card.cardNumber ?? '';
    final maskedNumber = card.displayNumber ??
        (rawNumber.isNotEmpty ? _maskNumber(rawNumber) : '');
    final canReveal =
        rawNumber.isNotEmpty &&
        card.display?.showPan != false &&
        card.capabilities?.canRevealPan == true;
    final revealed =
        index < controller.showAccountNumberList.length &&
        controller.showAccountNumberList[index].value;
    final value = maskedNumber.isEmpty
        ? '${card.amount ?? '0'} ${card.currency ?? ''}'
        : revealed
        ? _formatNumber(rawNumber)
        : maskedNumber;
    final showExpiry =
        card.display?.showExpiry == true &&
        card.expirationMonth != null &&
        card.expirationYear != null;
    final showCvc = card.display?.showCvc == true && card.cvc != null;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 18.w,
        end: 18.w,
        bottom: 16.h,
      ),
      child: GestureDetector(
        onTap: () {
          Get.toNamed(
            BaseRoute.virtualCardDetails,
            arguments: {
              'id': card.id.toString(),
              'card_id': card.cardId.toString(),
              'provider': card.provider,
            },
          );
        },
        child: CommonVirtualCardView(
          title:
              card.display?.title ??
              'Virtual Card',
          value: value,
          firstLabel: showExpiry
              ? card.display?.expiryLabel ?? 'Expiry'
              : card.display?.balanceLabel ?? 'Balance',
          firstValue: showExpiry
              ? '${card.expirationMonth}/${card.expirationYear.toString().substring(2)}'
              : '${card.amount ?? '0'} ${card.currency ?? ''}',
          secondLabel: showCvc
              ? card.display?.cvcLabel ?? 'CVC'
              : card.display?.currencyLabel ?? 'Currency',
          secondValue: showCvc ? card.cvc! : card.currency ?? '',
          status:
              card.lifecycleStatus ?? card.virtualStatus ?? card.status ?? '',
          canReveal: canReveal,
          isRevealed: revealed,
          onReveal: canReveal
              ? () {
                  controller.showAccountNumberList[index].value = !revealed;
                }
              : null,
          backgroundImage:
              card.display?.backgroundImage ??
              controller.cardBackgroundImage.value,
          brandImage: card.display?.brandImage,
          network: card.display?.network,
          primaryColor: card.display?.primaryColor,
          secondaryColor: card.display?.secondaryColor,
        ),
      ),
    );
  }

  Widget _buildCreateCardSection(AppLocalizations localization) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(PngAssets.createVirtualCardImage, fit: BoxFit.fill),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.w),
                child: Column(
                  children: [
                    Text(
                      localization.virtualCardCreateCardTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16.sp,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    CommonIconButton(
                      onPressed: () {
                        Get.toNamed(BaseRoute.getCardInfo);
                      },
                      width: 120,
                      height: 33,
                      text: localization.virtualCardCreateCardButton,
                      icon: PngAssets.addCommonIcon,
                      iconWidth: 17,
                      iconHeight: 17,
                      iconAndTextSpace: 4,
                      fontSize: 13,
                      borderRadius: 8,
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

  static String _formatNumber(String value) {
    return value
        .replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ')
        .trim();
  }

  static String _maskNumber(String value) {
    if (value.length <= 4) return value;
    return '**** **** **** ${value.substring(value.length - 4)}';
  }
}
