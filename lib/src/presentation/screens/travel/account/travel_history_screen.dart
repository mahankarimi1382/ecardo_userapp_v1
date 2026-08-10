import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';

import '../core/models/travel_models.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';

class TravelHistoryScreen extends StatelessWidget {
  const TravelHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = ensureTravelController();
    return TravelPage(
      title: localization.travelHistory,
      activeSection: TravelNavigationSection.history,
      child: Obx(
        () => controller.activity.isEmpty
            ? TravelEmptyState(message: localization.travelNoActivity)
            : ListView.separated(
                padding: EdgeInsets.all(20.r),
                itemCount: controller.activity.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final item = controller.activity[index];
                  final color = item.isCredit
                      ? TravelTheme.green
                      : travelProductColor(
                          item.type ?? TravelProductType.hotel,
                        );
                  return TravelCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: color.withValues(alpha: .12),
                          child: Icon(
                            item.isCredit
                                ? Icons.account_balance_wallet_rounded
                                : travelProductIcon(
                                    item.type ?? TravelProductType.hotel,
                                  ),
                            color: color,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                travelLocalizedKey(localization, item.titleKey),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                travelLocalizedKey(
                                  localization,
                                  item.subtitleKey,
                                ),
                                style: TextStyle(
                                  color: TravelTheme.muted,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            '${item.isCredit ? '+' : '-'}${travelMoney(context, item.amount)}',
                            style: TextStyle(
                              color: item.isCredit
                                  ? TravelTheme.green
                                  : TravelTheme.red,
                              fontWeight: FontWeight.w900,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
