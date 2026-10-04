import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/app_haptics.dart';
import 'package:shimmer/shimmer.dart';

import '../core/controller/travel_controller.dart';
import '../core/models/travel_models.dart';
import 'travel_theme.dart';

void showTravelMessage(
  BuildContext context, {
  required String title,
  required String message,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final safeMessage = travelSafePresentationMessage(message);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('$title\n$safeMessage'),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

enum TravelNavigationSection { dashboard, history, account }

String travelSafePresentationMessage(String message) {
  final trimmed = message.trim();
  if (trimmed.isEmpty) return travelGenericErrorMessage;
  final reference = _travelReferenceFromText(trimmed);
  final looksUnsafe = RegExp(
    r'(DioException|Exception|Error|StackTrace|package:|dart:|<html|{|"message")',
    caseSensitive: false,
  ).hasMatch(trimmed);
  if (!looksUnsafe) return trimmed;
  if (reference == null) return travelGenericErrorMessage;
  return '$travelGenericErrorMessage Reference: $reference';
}

String? _travelReferenceFromText(String value) {
  final match = RegExp(
    r'(?:support[_ -]?reference|request[_ -]?reference|request[_ -]?id|correlation[_ -]?id|trace[_ -]?id|reference)["\s:=]+([A-Za-z0-9][A-Za-z0-9._:-]{0,79})',
    caseSensitive: false,
  ).firstMatch(value);
  return match?.group(1);
}

TravelController ensureTravelController() {
  if (Get.isRegistered<TravelController>()) {
    return Get.find<TravelController>();
  }
  return Get.put(TravelController());
}

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
      backgroundColor: TravelTheme.backgroundFor(context),
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
        ?actionBar,
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
        padding: EdgeInsetsDirectional.fromSTEB(18.w, 8.h, 18.w, 10.h),
        decoration: BoxDecoration(
          color: TravelTheme.cardSurfaceFor(context),
          border: Border(
            top: BorderSide(color: TravelTheme.borderFor(context)),
          ),
          boxShadow: [
            BoxShadow(
              color: TravelTheme.shadowFor(context).first.color.withValues(
                alpha: .06,
              ),
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
              semanticLabel: localization.travelTitle,
              onTap: () => _open(BaseRoute.travel),
            ),
            _TravelNavigationItem(
              label: localization.travelHistory,
              icon: Icons.history_rounded,
              selected: activeSection == TravelNavigationSection.history,
              semanticLabel: localization.travelHistory,
              onTap: () => _open(BaseRoute.travelHistory),
            ),
            _TravelNavigationItem(
              label: localization.travelAccount,
              icon: Icons.person_rounded,
              selected: activeSection == TravelNavigationSection.account,
              semanticLabel: localization.travelAccount,
              onTap: () => _open(BaseRoute.travelAccount),
            ),
            _TravelNavigationItem(
              label: localization.bottomNavHome,
              icon: Icons.home_rounded,
              selected: false,
              semanticLabel: localization.bottomNavHome,
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
  final String semanticLabel;
  final VoidCallback onTap;

  const _TravelNavigationItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? TravelTheme.primaryFor(context)
        : TravelTheme.textSecondaryFor(context);
    return Expanded(
      child: Semantics(
        label: semanticLabel,
        selected: selected,
        button: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            AppHaptics.selection();
            onTap();
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
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
        ),
      ),
    );
  }
}

class TravelCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const TravelCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? TravelTheme.radius;
    final surface =
        color ??
        (TravelTheme.isDark(context)
            ? AppColors.darkSurfaceVariant
            : TravelTheme.cardSurfaceFor(context));
    return Material(
      color: surface,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap == null
            ? null
            : () {
                AppHaptics.light();
                onTap!();
              },
        child: Container(
          padding: padding ?? EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: TravelTheme.borderFor(context)),
            boxShadow: onTap == null ? null : TravelTheme.shadowFor(context),
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
    return Semantics(
      button: onTap != null,
      label: '$label: $value',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
        onTap: onTap == null
            ? null
            : () {
                AppHaptics.light();
                onTap!();
              },
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 44),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: TravelTheme.isDark(context)
                ? AppColors.darkSurfaceVariant
                : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
            border: Border.all(color: TravelTheme.borderFor(context)),
          ),
          child: Row(
            children: [
              Icon(icon, color: TravelTheme.primaryFor(context)),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: TravelTheme.textSecondaryFor(context),
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      value,
                      style: TextStyle(
                        color: TravelTheme.textPrimaryFor(context),
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: TravelTheme.textSecondaryFor(context),
              ),
            ],
          ),
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
              color: TravelTheme.textPrimaryFor(context),
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (action != null)
          InkWell(
            borderRadius: BorderRadius.circular(10.r),
            onTap: onTapWithHaptics(onAction),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                child: Text(
                  action!,
                  style: TextStyle(
                    color: TravelTheme.primaryFor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Wraps a callback with light haptic feedback, tolerating a null action.
VoidCallback? onTapWithHaptics(VoidCallback? action) {
  if (action == null) return null;
  return () {
    AppHaptics.light();
    action();
  };
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

String travelBackendText(BuildContext context, dynamic value) {
  if (value == null) return '';
  if (value is! Map) return value.toString().trim();
  final map = Map<String, dynamic>.from(value);
  final language = Localizations.localeOf(context).languageCode.toLowerCase();
  final selected =
      map[language] ??
      (language == 'zh' ? map['zh-cn'] ?? map['zh_cn'] : null) ??
      map['en'] ??
      map.values.firstOrNull;
  return selected?.toString().trim() ?? '';
}

String travelBackendFieldLabel(AppLocalizations localization, String key) {
  return switch (key.toLowerCase()) {
    'address' => localization.travelAddress,
    'amenities' => localization.travelIncluded,
    'airline' || 'airline_name' => localization.travelAirline,
    'arrival' || 'arrival_time' => localization.travelArrival,
    'aircraft' || 'aircraft_code' => localization.travelAircraft,
    'baggage' || 'baggage_allowance' => localization.travelBaggage,
    'board' || 'board_type' => localization.travelBoard,
    'booking_number' => localization.travelBookingNumber,
    'cabin' || 'cabin_class' => localization.travelCabin,
    'cancellation' ||
    'cancellation_policy' ||
    'cancellation_rules' => localization.travelCancellationPolicy,
    'check_in' || 'check_in_time' => localization.travelCheckIn,
    'check_out' || 'check_out_time' => localization.travelCheckOut,
    'child_count' || 'children' => localization.travelChildren,
    'departure' || 'departure_time' => localization.travelDeparture,
    'description' => localization.travelDescription,
    'destination' || 'destination_name' => localization.travelDestination,
    'duration' => localization.travelDuration,
    'flight' || 'flight_number' => localization.travelFlightNumber,
    'origin' || 'origin_name' => localization.travelOrigin,
    'price' || 'total' || 'total_amount' => localization.travelTotal,
    'rating' || 'stars' => localization.travelRating,
    'refund_policy' || 'refundability' => localization.travelRefundPolicy,
    'room' || 'room_name' => localization.travelRoom,
    'room_count' || 'rooms' => localization.travelRooms,
    'supplier_reference' => localization.travelSupplierReference,
    'voucher_number' => localization.travelVoucherNumber,
    _ =>
      key
          .replaceAll('_', ' ')
          .split(' ')
          .where((part) => part.isNotEmpty)
          .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
          .join(' '),
  };
}

String travelBackendValue(BuildContext context, dynamic value) {
  if (value == null) return '';
  if (value is bool) return value ? '✓' : '—';
  if (value is List) {
    return value
        .map((item) => travelBackendValue(context, item))
        .where((item) => item.isNotEmpty)
        .join(', ');
  }
  if (value is Map) {
    final localized = travelBackendText(context, value);
    if (localized.isNotEmpty && !localized.startsWith('{')) return localized;
    final localization = AppLocalizations.of(context)!;
    return value.entries
        .map(
          (entry) =>
              '${travelBackendFieldLabel(localization, entry.key.toString())}: '
              '${travelBackendValue(context, entry.value)}',
        )
        .where((item) => !item.endsWith(': '))
        .join(' • ');
  }
  return value.toString().trim();
}

class TravelJourneyGuide extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  final String? message;

  const TravelJourneyGuide({
    super.key,
    required this.currentStep,
    required this.steps,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = TravelTheme.primaryFor(context);
    final borderColor = TravelTheme.borderFor(context);
    final textPrimary = TravelTheme.textPrimaryFor(context);
    final textSecondary = TravelTheme.textSecondaryFor(context);

    return TravelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message?.isNotEmpty == true) ...[
            Text(
              message!,
              style: TextStyle(
                color: textSecondary,
                fontSize: 11.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: AppSpacing.md.h),
          ],
          Row(
            children: [
              for (var index = 0; index < steps.length; index++) ...[
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 14.r,
                        backgroundColor: index <= currentStep
                            ? primaryColor
                            : borderColor,
                        child: index < currentStep
                            ? const Icon(
                                Icons.check_rounded,
                                color: AppColors.white,
                                size: 16,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: index == currentStep
                                      ? AppColors.white
                                      : textSecondary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10.sp,
                                ),
                              ),
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Text(
                        steps[index],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: index == currentStep
                              ? textPrimary
                              : textSecondary,
                          fontSize: 9.sp,
                          fontWeight: index == currentStep
                              ? FontWeight.w900
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index != steps.length - 1)
                  Container(
                    width: 18.w,
                    height: 2,
                    color: index < currentStep
                        ? primaryColor
                        : borderColor,
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
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

/// 4-State: Empty State with themed icon, title, subtitle, and primary action CTA.
class TravelEmptyState extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;

  const TravelEmptyState({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = TravelTheme.isDark(context);
    final primaryColor = TravelTheme.primaryFor(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl.w,
          vertical: AppSpacing.xxxl.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68.r,
              height: 68.r,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? TravelTheme.borderFor(context)
                      : primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                icon ?? Icons.flight_takeoff_rounded,
                size: 32.r,
                color: primaryColor,
              ),
            ),
            if (title?.isNotEmpty == true) ...[
              SizedBox(height: AppSpacing.lg.h),
              TravelBidiText(
                title!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TravelTheme.textPrimaryFor(context),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            SizedBox(height: AppSpacing.sm.h),
            TravelBidiText(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TravelTheme.textSecondaryFor(context),
                fontSize: 13.sp,
                height: 1.4,
              ),
            ),
            if (actionText?.isNotEmpty == true && onAction != null) ...[
              SizedBox(height: AppSpacing.xl.h),
              CommonButton(
                width: 200.w,
                height: 44.h,
                text: actionText!,
                onPressed: () {
                  AppHaptics.light();
                  onAction!();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 4-State: Error State with themed icon, humanized message, and Retry button.
class TravelErrorState extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final String? retryText;

  const TravelErrorState({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final isDark = TravelTheme.isDark(context);
    final safeMessage = travelSafePresentationMessage(message);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl.w,
          vertical: AppSpacing.xxxl.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68.r,
              height: 68.r,
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withValues(alpha: isDark ? 0.2 : 0.7),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 32,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            TravelBidiText(
              title ?? localization?.allControllerLoadError ?? 'Connection Error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TravelTheme.textPrimaryFor(context),
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            TravelBidiText(
              safeMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TravelTheme.textSecondaryFor(context),
                fontSize: 13.sp,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppSpacing.xl.h),
              CommonButton(
                width: 180.w,
                height: 44.h,
                text: retryText ?? localization?.noInternetConnectionRetryButton ?? 'Retry',
                onPressed: () {
                  AppHaptics.light();
                  onRetry!();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer layout types for travel skeleton loader.
enum TravelShimmerType { card, flightCard, hotelCard, list, tile }

/// 4-State: Dark-mode safe shimmer loading skeleton for travel screens.
class TravelShimmerLoading extends StatelessWidget {
  final TravelShimmerType type;
  final int count;

  const TravelShimmerLoading({
    super.key,
    this.type = TravelShimmerType.card,
    this.count = 3,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = TravelTheme.isDark(context);
    final baseColor = isDark ? const Color(0xFF262625) : const Color(0xFFE5E7EB);
    final highlightColor = isDark ? const Color(0xFF383836) : const Color(0xFFF3F4F6);
    final blockColor = isDark ? const Color(0xFF2E2E2D) : AppColors.white;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.sm.h),
        itemCount: count,
        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.md.h),
        itemBuilder: (_, index) => _buildShimmerItem(context, blockColor),
      ),
    );
  }

  Widget _buildShimmerItem(BuildContext context, Color blockColor) {
    switch (type) {
      case TravelShimmerType.flightCard:
        return Container(
          padding: EdgeInsets.all(AppSpacing.lg.r),
          decoration: BoxDecoration(
            color: blockColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: blockColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 120.w, height: 14.h, color: blockColor),
                        SizedBox(height: 6.h),
                        Container(width: 80.w, height: 10.h, color: blockColor),
                      ],
                    ),
                  ),
                  Container(width: 70.w, height: 16.h, color: blockColor),
                ],
              ),
              SizedBox(height: AppSpacing.lg.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 60.w, height: 28.h, color: blockColor),
                  Container(width: 100.w, height: 12.h, color: blockColor),
                  Container(width: 60.w, height: 28.h, color: blockColor),
                ],
              ),
            ],
          ),
        );

      case TravelShimmerType.hotelCard:
        return Container(
          decoration: BoxDecoration(
            color: blockColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 140.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: blockColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusXl.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 160.w, height: 16.h, color: blockColor),
                    SizedBox(height: 8.h),
                    Container(width: 100.w, height: 12.h, color: blockColor),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 80.w, height: 12.h, color: blockColor),
                        Container(width: 90.w, height: 22.h, color: blockColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case TravelShimmerType.tile:
      case TravelShimmerType.list:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.md.h),
          decoration: BoxDecoration(
            color: blockColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
          ),
          child: Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: blockColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                ),
              ),
              SizedBox(width: AppSpacing.md.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 140.w, height: 14.h, color: blockColor),
                    SizedBox(height: 6.h),
                    Container(width: 90.w, height: 10.h, color: blockColor),
                  ],
                ),
              ),
              Container(width: 50.w, height: 14.h, color: blockColor),
            ],
          ),
        );

      case TravelShimmerType.card:
        return Container(
          height: 90.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: blockColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
          ),
        );
    }
  }
}

/// Stylish dashed divider line for tickets, receipts, and vouchers.
class TravelDashedDivider extends StatelessWidget {
  final Color? color;
  final double height;
  final double dashWidth;
  final double dashGap;

  const TravelDashedDivider({
    super.key,
    this.color,
    this.height = 1.0,
    this.dashWidth = 6.0,
    this.dashGap = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? TravelTheme.borderFor(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        final count = (boxWidth / (dashWidth + dashGap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(count, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: effectiveColor),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Creative celebratory ticket card with notch cutouts, dashed divider, and theme awareness.
class TravelTicketCard extends StatelessWidget {
  final Widget header;
  final Widget body;
  final Widget? footer;
  final EdgeInsetsGeometry? padding;

  const TravelTicketCard({
    super.key,
    required this.header,
    required this.body,
    this.footer,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final surface = TravelTheme.cardSurfaceFor(context);
    final borderColor = TravelTheme.borderFor(context);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
        border: Border.all(color: borderColor),
        boxShadow: TravelTheme.shadowFor(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: padding ?? EdgeInsets.all(AppSpacing.lg.r),
            child: header,
          ),
          TravelDashedDivider(color: borderColor),
          Padding(
            padding: padding ?? EdgeInsets.all(AppSpacing.lg.r),
            child: body,
          ),
          if (footer != null) ...[
            TravelDashedDivider(color: borderColor),
            Padding(
              padding: padding ?? EdgeInsets.all(AppSpacing.lg.r),
              child: footer!,
            ),
          ],
        ],
      ),
    );
  }
}
