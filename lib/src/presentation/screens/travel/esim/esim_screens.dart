import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';

import '../bookings/travel_checkout_screen.dart';
import '../core/controller/travel_controller.dart';
import '../core/models/travel_models.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';

class EsimIntroScreen extends StatelessWidget {
  const EsimIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = Get.find<TravelController>();
    final service = controller.serviceFor(TravelProductType.esim);
    final heroTitle =
        service?.presentation['hero_title']?.toString() ??
        localization.travelEsimIntroTitle;
    final heroSubtitle =
        service?.presentation['hero_subtitle']?.toString() ??
        localization.travelEsimIntroDescription;
    return TravelPage(
      title: localization.travelEsim,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CommonButton(
            width: double.infinity,
            text: localization.travelBrowseEsimPackages,
            textColor: TravelTheme.ink,
            backgroundColor: TravelTheme.yellow,
            onPressed: () => Get.to(() => const EsimPackagesScreen()),
          ),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          Container(
            height: 260.h,
            decoration: BoxDecoration(
              borderRadius: TravelTheme.radius,
              gradient: const LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [Color(0xFFFFE082), TravelTheme.yellow],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.sim_card_download_rounded,
                color: TravelTheme.ink,
                size: 120.r,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            heroTitle,
            style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 10.h),
          Text(
            heroSubtitle,
            style: TextStyle(
              color: TravelTheme.muted,
              fontSize: 13.sp,
              height: 1.7,
            ),
          ),
          SizedBox(height: 24.h),
          _Benefit(
            icon: Icons.flash_on_rounded,
            title: localization.travelEsimInstantTitle,
            subtitle: localization.travelEsimInstantDescription,
          ),
          _Benefit(
            icon: Icons.public_rounded,
            title: localization.travelEsimCoverageTitle,
            subtitle: localization.travelEsimCoverageDescription,
          ),
          _Benefit(
            icon: Icons.payments_outlined,
            title: localization.travelEsimTransparentTitle,
            subtitle: localization.travelEsimTransparentDescription,
          ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Benefit({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TravelCard(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: TravelTheme.yellow.withValues(alpha: .25),
              child: Icon(icon, color: TravelTheme.ink),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(color: TravelTheme.muted, fontSize: 10.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EsimPackagesScreen extends StatefulWidget {
  const EsimPackagesScreen({super.key});

  @override
  State<EsimPackagesScreen> createState() => _EsimPackagesScreenState();
}

class _EsimPackagesScreenState extends State<EsimPackagesScreen> {
  final destinationController = TextEditingController();

  @override
  void dispose() {
    destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = Get.find<TravelController>();
    final service = controller.serviceFor(TravelProductType.esim);
    final destinationField = service?.searchFields.firstWhereOrNull(
      (field) => field.key == 'country_code',
    );
    return TravelPage(
      title: localization.travelEsimPackages,
      child: Obx(
        () => controller.isLoading.value && controller.esimPackages.isEmpty
            ? const CommonLoading()
            : ListView(
                padding: EdgeInsets.all(20.r),
                children: [
                  CommonTextInputField(
                    controller: destinationController,
                    hintText:
                        destinationField?.hint ??
                        destinationField?.label ??
                        localization.travelDestination,
                    prefixIcon: const Icon(
                      Icons.public_rounded,
                      color: TravelTheme.yellow,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  CommonButton(
                    width: double.infinity,
                    text: localization.travelBrowseEsimPackages,
                    textColor: TravelTheme.ink,
                    backgroundColor: TravelTheme.yellow,
                    isLoading: controller.isLoading.value,
                    onPressed: () async {
                      final destination = destinationController.text
                          .trim()
                          .toUpperCase();
                      if (destination.isEmpty) {
                        showTravelMessage(
                          context,
                          title: localization.travelEsimPackages,
                          message: localization.travelDestination,
                        );
                        return;
                      }
                      final succeeded = await controller.loadEsimPackages(
                        destination,
                      );
                      if (!succeeded) {
                        showTravelMessage(
                          context,
                          title: localization.travelEsimPackages,
                          message: localization.allControllerLoadError,
                        );
                      }
                    },
                  ),
                  SizedBox(height: 20.h),
                  TravelSectionHeader(title: localization.travelChoosePackage),
                  SizedBox(height: 10.h),
                  ...controller.esimPackages.map(
                    (package) => Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: _PackageCard(package: package),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final TravelEsimPackage package;

  const _PackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = Get.find<TravelController>();
    final canPurchase = controller.canPurchase(TravelProductType.esim);
    return TravelCard(
      onTap: canPurchase
          ? () {
              controller.selectedEsim.value = package;
              Get.to(
                () => TravelCheckoutScreen(
                  type: TravelProductType.esim,
                  productId: package.id,
                  title: package.destinationCode,
                  total: package.total,
                ),
              );
            }
          : null,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54.r,
                height: 54.r,
                decoration: BoxDecoration(
                  color: TravelTheme.yellow.withValues(alpha: .25),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: const Icon(
                  Icons.sim_card_rounded,
                  color: TravelTheme.ink,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        package.dataLabel,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      localization.travelValidityDays(package.validityDays),
                      style: TextStyle(
                        color: TravelTheme.muted,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              if (package.isPopular)
                Chip(
                  backgroundColor: TravelTheme.yellow,
                  label: Text(localization.travelMostPopular),
                ),
            ],
          ),
          const Divider(height: 28),
          Row(
            children: [
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    travelMoney(context, package.total),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 120.w,
                child: CommonButton(
                  height: 42,
                  text: canPurchase
                      ? localization.travelSelect
                      : localization.travelOfferUnavailable,
                  fontSize: 10,
                  textColor: canPurchase ? TravelTheme.ink : Colors.white,
                  backgroundColor: canPurchase
                      ? TravelTheme.yellow
                      : TravelTheme.muted,
                  onPressed: canPurchase
                      ? () {
                          controller.selectedEsim.value = package;
                          Get.to(
                            () => TravelCheckoutScreen(
                              type: TravelProductType.esim,
                              productId: package.id,
                              title: package.destinationCode,
                              total: package.total,
                            ),
                          );
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
