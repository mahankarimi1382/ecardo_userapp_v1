import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';

import '../core/models/travel_models.dart';
import 'travel_theme.dart';

void showTravelMessage(
  BuildContext context, {
  required String title,
  required String message,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('$title\n$message'),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

enum TravelNavigationSection { dashboard, history, account }

class TravelPage extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? bottomNavigationBar;
  final Widget? trailing;
  final bool showBack;
  final bool showTravelNavigation;
  final TravelNavigationSection activeSection;

  const TravelPage({
    super.key,
    required this.title,
    required this.child,
    this.bottomNavigationBar,
    this.trailing,
    this.showBack = true,
    this.showTravelNavigation = true,
    this.activeSection = TravelNavigationSection.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TravelTheme.background,
      appBar: const CommonDefaultAppBar(),
      body: Column(
        children: [
          SizedBox(height: 10.h),
          CommonAppBar(
            title: title,
            isBackLogicApply: !showBack,
            backLogicFunction: showBack ? null : () {},
            rightSideWidget: trailing,
          ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: _TravelPageFooter(
        actionBar: bottomNavigationBar,
        showNavigation: showTravelNavigation,
        activeSection: activeSection,
      ),
    );
  }
}

class _TravelPageFooter extends StatelessWidget {
  final Widget? actionBar;
  final bool showNavigation;
  final TravelNavigationSection activeSection;

  const _TravelPageFooter({
    required this.actionBar,
    required this.showNavigation,
    required this.activeSection,
  });

  @override
  Widget build(BuildContext context) {
    if (!showNavigation) return actionBar ?? const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (actionBar != null) actionBar!,
        TravelBottomNavigation(activeSection: activeSection),
      ],
    );
  }
}

class TravelBottomNavigation extends StatelessWidget {
  final TravelNavigationSection activeSection;

  const TravelBottomNavigation({super.key, required this.activeSection});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: TravelTheme.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .06),
              blurRadius: 22,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          children: [
            _TravelNavigationItem(
              label: localization.travelTitle,
              icon: Icons.dashboard_rounded,
              selected: activeSection == TravelNavigationSection.dashboard,
              onTap: () => _open(BaseRoute.travel),
            ),
            _TravelNavigationItem(
              label: localization.travelHistory,
              icon: Icons.history_rounded,
              selected: activeSection == TravelNavigationSection.history,
              onTap: () => _open(BaseRoute.travelHistory),
            ),
            _TravelNavigationItem(
              label: localization.travelAccount,
              icon: Icons.person_rounded,
              selected: activeSection == TravelNavigationSection.account,
              onTap: () => _open(BaseRoute.travelAccount),
            ),
            _TravelNavigationItem(
              label: localization.bottomNavHome,
              icon: Icons.home_rounded,
              selected: false,
              onTap: () => Get.offAllNamed(BaseRoute.navigation),
            ),
          ],
        ),
      ),
    );
  }

  void _open(String route) {
    if (Get.currentRoute == route) return;
    Get.offNamed(route);
  }
}

TextDirection travelTextDirection(
  BuildContext context,
  String value, {
  TextDirection? fallback,
}) {
  final firstStrong = RegExp(
    r'[\u0590-\u08FF]|[A-Za-z\u0400-\u04FF\u4E00-\u9FFF]',
  ).firstMatch(value)?.group(0);
  if (firstStrong == null) {
    return fallback ?? Directionality.of(context);
  }
  return RegExp(r'[\u0590-\u08FF]').hasMatch(firstStrong)
      ? TextDirection.rtl
      : TextDirection.ltr;
}

class TravelBidiText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TravelBidiText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: travelTextDirection(context, text),
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

class _TravelNavigationItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TravelNavigationItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? TravelTheme.blue : TravelTheme.muted;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 23.r),
              SizedBox(height: 3.h),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 9.sp,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TravelCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color color;
  final VoidCallback? onTap;

  const TravelCard({
    super.key,
    required this.child,
    this.padding,
    this.color = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: TravelTheme.radius,
      child: InkWell(
        borderRadius: TravelTheme.radius,
        onTap: onTap,
        child: Container(
          padding: padding ?? EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            borderRadius: TravelTheme.radius,
            border: Border.all(color: TravelTheme.border),
            boxShadow: onTap == null ? null : TravelTheme.shadow,
          ),
          child: child,
        ),
      ),
    );
  }
}

class TravelFieldTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const TravelFieldTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F2F4),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: TravelTheme.blue),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: TravelTheme.muted, fontSize: 11.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: TravelTheme.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class TravelSectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const TravelSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: TravelTheme.ink,
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (action != null)
          InkWell(
            borderRadius: BorderRadius.circular(10.r),
            onTap: onAction,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: Text(
                action!,
                style: const TextStyle(
                  color: TravelTheme.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

String travelLocalizedKey(AppLocalizations localization, String key) {
  return switch (key) {
    'travelMockHotelEspinas' => localization.travelMockHotelEspinas,
    'travelMockHotelEspinasLocation' =>
      localization.travelMockHotelEspinasLocation,
    'travelMockHotelParsian' => localization.travelMockHotelParsian,
    'travelMockHotelParsianLocation' =>
      localization.travelMockHotelParsianLocation,
    'travelMockHotelVisteria' => localization.travelMockHotelVisteria,
    'travelMockHotelVisteriaLocation' =>
      localization.travelMockHotelVisteriaLocation,
    'travelMockFlightTehranIstanbul' =>
      localization.travelMockFlightTehranIstanbul,
    'travelMockAirlineOne' => localization.travelMockAirlineOne,
    'travelMockAirlineTwo' => localization.travelMockAirlineTwo,
    'travelRecommended' => localization.travelRecommended,
    'travelBestValue' => localization.travelBestValue,
    'travelLuxury' => localization.travelLuxury,
    'travelDirect' => localization.travelDirect,
    'travelLowestPrice' => localization.travelLowestPrice,
    'travelFeatureBreakfast' => localization.travelFeatureBreakfast,
    'travelFeaturePool' => localization.travelFeaturePool,
    'travelFeatureWifi' => localization.travelFeatureWifi,
    'travelFeatureParking' => localization.travelFeatureParking,
    'travelFeatureAirportTransfer' => localization.travelFeatureAirportTransfer,
    'travelFeatureCabinBag' => localization.travelFeatureCabinBag,
    'travelFeatureRefundable' => localization.travelFeatureRefundable,
    'travelEsimTurkey' => localization.travelEsimTurkey,
    'travelActivityFlightPurchase' => localization.travelActivityFlightPurchase,
    'travelActivityEsimPurchase' => localization.travelActivityEsimPurchase,
    'travelActivityWalletTopUp' => localization.travelActivityWalletTopUp,
    'travelMainWallet' => localization.travelMainWallet,
    'travelDemoOffer' => localization.travelDemoOffer,
    'travelRequiresConfirmation' => localization.travelRequiresConfirmation,
    'travelHotelBooking' => localization.travelHotelBooking,
    _ => key,
  };
}

String travelMoney(BuildContext context, TravelMoney money) {
  final value = NumberFormat.decimalPattern(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(money.amount);
  return '$value ${money.currency}';
}

IconData travelProductIcon(TravelProductType type) => switch (type) {
  TravelProductType.hotel => Icons.hotel_rounded,
  TravelProductType.flight => Icons.flight_rounded,
  TravelProductType.esim => Icons.sim_card_rounded,
};

Color travelProductColor(TravelProductType type) => switch (type) {
  TravelProductType.hotel => TravelTheme.purple,
  TravelProductType.flight => TravelTheme.blue,
  TravelProductType.esim => TravelTheme.yellow,
};

class TravelEmptyState extends StatelessWidget {
  final String message;

  const TravelEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: TravelTheme.muted, fontSize: 14.sp),
        ),
      ),
    );
  }
}
