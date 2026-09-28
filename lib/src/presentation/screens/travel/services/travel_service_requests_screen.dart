import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/service_form_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/travel_service_request.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_theme.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_widgets.dart';

/// Localized display title for a service key — resolves against the same
/// dashboard tile names so requests always read like the service they came
/// from.
String travelServiceTitleByKey(String key, AppLocalizations localization) =>
    switch (key) {
      'visa' => localization.travelServiceVisa,
      'train' => localization.travelServiceTrain,
      'carRental' => localization.travelServiceCarRental,
      'taxi' => localization.travelServiceTaxi,
      'tour' => localization.travelServiceTour,
      'boat' => localization.travelServiceBoat,
      'local' => localization.travelServiceLocal,
      'food' => localization.travelServiceFood,
      'supermarket' => localization.travelServiceSupermarket,
      'restaurant' => localization.travelServiceRestaurant,
      'store' => localization.travelServiceStore,
      'translator' => localization.travelServiceTranslator,
      'emergency' => localization.travelServiceEmergency,
      'aliPay' => localization.travelServiceAliPay,
      'mirPay' => localization.travelServiceMirPay,
      'simTopUp' => localization.travelServiceSimTopUp,
      'insurance' => localization.travelServiceInsurance,
      _ => key,
    };

/// "My requests" — every submission made through the extra travel services,
/// with its current review state.
class TravelServiceRequestsScreen extends StatefulWidget {
  const TravelServiceRequestsScreen({super.key});

  @override
  State<TravelServiceRequestsScreen> createState() =>
      _TravelServiceRequestsScreenState();
}

class _TravelServiceRequestsScreenState
    extends State<TravelServiceRequestsScreen> {
  List<TravelServiceRequest> _requests = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final requests = await TravelServiceRequestStore.load();
    if (!mounted) return;
    setState(() {
      _requests = requests.reversed.toList(growable: false);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return TravelPage(
      title: localization.travelMyRequests,
      showTravelNavigation: false,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? ListView(
              padding: EdgeInsets.all(20.r),
              children: [
                SizedBox(height: 60.h),
                Icon(
                  Icons.receipt_long_rounded,
                  size: 64.r,
                  color: TravelTheme.muted.withValues(alpha: .5),
                ),
                SizedBox(height: 14.h),
                Text(
                  localization.travelRequestEmptyTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 6.h),
                Text(
                  localization.travelRequestEmptyDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TravelTheme.muted, fontSize: 11.5.sp),
                ),
              ],
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: EdgeInsets.all(20.r),
                itemCount: _requests.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final request = _requests[index];
                  return _RequestCard(
                    request: request,
                    serviceTitle: travelServiceTitleByKey(
                      request.serviceKey,
                      localization,
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final TravelServiceRequest request;
  final String serviceTitle;

  const _RequestCard({required this.request, required this.serviceTitle});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final createdAt = DateFormat('yyyy-MM-dd · HH:mm').format(request.createdAt);
    return TravelCard(
      onTap: request.details.isEmpty
          ? null
          : () => _showDetails(context, localization),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  serviceTitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: TravelTheme.blue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TravelRequestStatusChip(status: request.status),
            ],
          ),
          SizedBox(height: 6.h),
          TravelBidiText(
            request.title,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900),
          ),
          if (request.subtitle.isNotEmpty) ...[
            SizedBox(height: 4.h),
            TravelBidiText(
              request.subtitle,
              style: TextStyle(color: TravelTheme.muted, fontSize: 11.sp),
            ),
          ],
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localization.travelRequestReference,
                      style: TextStyle(
                        color: TravelTheme.muted,
                        fontSize: 10.sp,
                      ),
                    ),
                    Text(
                      request.reference,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    localization.travelRequestSubmittedAt,
                    style: TextStyle(
                      color: TravelTheme.muted,
                      fontSize: 10.sp,
                    ),
                  ),
                  Text(
                    createdAt,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
          if (request.amountLabel.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              '${localization.travelTotal}: ${request.amountLabel}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12.5.sp,
                color: TravelTheme.blue,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDetails(BuildContext context, AppLocalizations localization) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: TravelTheme.radius),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localization.travelRequestDetails,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 12.h),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: request.details.entries
                        .map(
                          (entry) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    entry.key,
                                    style: TextStyle(
                                      color: TravelTheme.muted,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: TravelBidiText(
                                    entry.value,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
