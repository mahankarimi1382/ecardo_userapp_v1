import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/mock_travel_data.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/service_form_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/service_form_spec.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/travel_service_requests_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_theme.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_widgets.dart';

/// Form-only extra services: the tile opens straight into the generic
/// request form. Submissions land in the shared local request book.
TravelServiceFormScreen taxiRequestScreen(AppLocalizations localization) =>
    TravelServiceFormScreen(
      serviceKey: 'taxi',
      title: localization.travelServiceTaxi,
      itemTitle: localization.travelServiceTaxi,
      itemSubtitle: localization.travelTaxiHero,
      amountLabel: '',
      fields: [
        TravelFormFieldSpec(
          key: 'origin',
          label: () => localization.travelOrigin,
          type: TravelFormFieldType.text,
          icon: Icons.trip_origin_rounded,
        ),
        TravelFormFieldSpec(
          key: 'destination',
          label: () => localization.travelDestination,
          type: TravelFormFieldType.text,
          icon: Icons.location_on_rounded,
        ),
        TravelFormFieldSpec(
          key: 'ride_date',
          label: () => localization.travelDepartureDate,
          type: TravelFormFieldType.date,
          icon: Icons.event_rounded,
        ),
        TravelFormFieldSpec(
          key: 'ride_time',
          label: () => localization.travelFieldTime,
          type: TravelFormFieldType.time,
          icon: Icons.schedule_rounded,
        ),
        TravelFormFieldSpec(
          key: 'car_class',
          label: () => localization.travelTaxiCarClass,
          type: TravelFormFieldType.dropdown,
          icon: Icons.local_taxi_rounded,
          options: mockTaxiClasses,
        ),
        TravelFormFieldSpec(
          key: 'phone',
          label: () => localization.travelContactPhone,
          type: TravelFormFieldType.phone,
          icon: Icons.phone_rounded,
        ),
      ],
    );

TravelServiceFormScreen simTopUpRequestScreen(AppLocalizations localization) =>
    TravelServiceFormScreen(
      serviceKey: 'simTopUp',
      title: localization.travelServiceSimTopUp,
      itemTitle: localization.travelServiceSimTopUp,
      itemSubtitle: localization.travelSimTopUpHero,
      amountLabel: '',
      fields: [
        TravelFormFieldSpec(
          key: 'operator',
          label: () => localization.travelSimOperator,
          type: TravelFormFieldType.dropdown,
          icon: Icons.cell_tower_rounded,
          options: mockSimOperators,
        ),
        TravelFormFieldSpec(
          key: 'mobile_number',
          label: () => localization.travelSimNumber,
          type: TravelFormFieldType.phone,
          icon: Icons.phone_android_rounded,
        ),
        TravelFormFieldSpec(
          key: 'amount',
          label: () => localization.travelSimAmount,
          type: TravelFormFieldType.dropdown,
          icon: Icons.payments_rounded,
          options: mockSimTopUpAmounts
              .map((amount) => '$amount ${localization.travelMockCurrency}')
              .toList(),
        ),
        TravelFormFieldSpec(
          key: 'full_name',
          label: () => localization.travelFieldName,
          type: TravelFormFieldType.text,
          icon: Icons.person_outline_rounded,
        ),
      ],
    );

/// Emergency assistance — live safety contacts first, then the assisted
/// request form for non-urgent follow-ups.
class EmergencyServiceScreen extends StatelessWidget {
  const EmergencyServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return TravelPage(
      title: localization.travelServiceEmergency,
      showTravelNavigation: false,
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          Container(
            height: 140.h,
            padding: EdgeInsets.all(22.r),
            decoration: BoxDecoration(
              borderRadius: TravelTheme.radius,
              gradient: const LinearGradient(
                colors: [Color(0xFFB71C1C), TravelTheme.red],
              ),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Icon(
                    Icons.support_agent_rounded,
                    size: 96.r,
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Text(
                    localization.travelEmergencyHero,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          TravelSectionHeader(title: localization.travelEmergencyContactsTitle),
          SizedBox(height: 10.h),
          ...mockEmergencyContacts.map(
            (contact) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: TravelCard(
                child: Row(
                  children: [
                    Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(
                        color: TravelTheme.red.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.emergency_rounded,
                        color: TravelTheme.red,
                        size: 22.r,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TravelBidiText(
                            contact.$1,
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          SizedBox(height: 3.h),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              contact.$2,
                              style: TextStyle(
                                color: TravelTheme.muted,
                                fontSize: 11.5.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_left_rounded,
                      color: TravelTheme.muted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          CommonButton(
            width: double.infinity,
            text: localization.travelEmergencyRequest,
            backgroundColor: TravelTheme.red,
            onPressed: () => Get.to(
              () => TravelServiceFormScreen(
                serviceKey: 'emergency',
                title: localization.travelServiceEmergency,
                itemTitle: localization.travelEmergencyRequest,
                itemSubtitle: localization.travelEmergencyHero,
                amountLabel: '',
                fields: [
                  TravelFormFieldSpec(
                    key: 'subject',
                    label: () => localization.travelEmergencySubject,
                    type: TravelFormFieldType.dropdown,
                    icon: Icons.help_outline_rounded,
                    options: mockEmergencySubjects,
                  ),
                  TravelFormFieldSpec(
                    key: 'city',
                    label: () => localization.travelDestination,
                    type: TravelFormFieldType.text,
                    icon: Icons.location_city_rounded,
                  ),
                  TravelFormFieldSpec(
                    key: 'phone',
                    label: () => localization.travelContactPhone,
                    type: TravelFormFieldType.phone,
                    icon: Icons.phone_rounded,
                  ),
                  TravelFormFieldSpec(
                    key: 'note',
                    label: () => localization.travelFieldNote,
                    type: TravelFormFieldType.textarea,
                    icon: Icons.notes_rounded,
                    required: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// AliPay / MirPay — wallet connect + top-up request on demo rails.
class WalletServiceScreen extends StatelessWidget {
  final String serviceKey;
  final Color brandStart;
  final Color brandEnd;
  final String Function(AppLocalizations) description;

  const WalletServiceScreen({
    super.key,
    required this.serviceKey,
    required this.brandStart,
    required this.brandEnd,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final title = travelServiceTitleByKey(serviceKey, localization);
    return TravelPage(
      title: title,
      showTravelNavigation: false,
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          Container(
            height: 140.h,
            padding: EdgeInsets.all(22.r),
            decoration: BoxDecoration(
              borderRadius: TravelTheme.radius,
              gradient: LinearGradient(colors: [brandStart, brandEnd]),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 96.r,
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Text(
                    description(localization),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          TravelCard(
            child: TravelBidiText(
              localization.travelPayDescription,
              style: TextStyle(color: TravelTheme.muted, fontSize: 11.5.sp),
            ),
          ),
          SizedBox(height: 16.h),
          CommonButton(
            width: double.infinity,
            text: localization.travelPayLinkAccount,
            backgroundColor: brandEnd,
            onPressed: () => Get.to(
              () => TravelServiceFormScreen(
                serviceKey: serviceKey,
                title: title,
                itemTitle: localization.travelPayTopUp,
                itemSubtitle: description(localization),
                amountLabel: '',
                fields: [
                  TravelFormFieldSpec(
                    key: 'account_id',
                    label: () => localization.travelPayAccountId,
                    type: TravelFormFieldType.text,
                    icon: Icons.account_circle_rounded,
                  ),
                  TravelFormFieldSpec(
                    key: 'phone',
                    label: () => localization.travelFieldPhone,
                    type: TravelFormFieldType.phone,
                    icon: Icons.phone_rounded,
                  ),
                  TravelFormFieldSpec(
                    key: 'amount',
                    label: () => localization.travelFieldAmount,
                    type: TravelFormFieldType.dropdown,
                    icon: Icons.payments_rounded,
                    options: mockWalletTopUpAmounts
                        .map(
                          (amount) =>
                              '$amount ${localization.travelMockCurrency}',
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          CommonButton(
            width: double.infinity,
            text: localization.travelMyRequests,
            backgroundColor: TravelTheme.muted,
            onPressed: () => Get.to(
              () => const TravelServiceRequestsScreen(),
            ),
          ),
        ],
      ),
    );
  }
}
