import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../models/escrow_models.dart';

class EscrowStatusBadge extends StatelessWidget {
  final String status;
  final String? label;

  const EscrowStatusBadge({
    super.key,
    required this.status,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String display = label ?? status;

    switch (status) {
      case 'DRAFT':
        bg = Colors.grey.shade100;
        text = Colors.grey.shade700;
        display = l10nPick(context, fa: 'پیش‌نویس', en: 'Draft');
        break;
      case 'AWAITING_AGREEMENT':
        bg = Colors.amber.shade50;
        text = Colors.amber.shade800;
        display = l10nPick(context, fa: 'در انتظار تأیید شرایط', en: 'Awaiting Agreement');
        break;
      case 'AWAITING_PAYMENT':
        bg = Colors.orange.shade50;
        text = Colors.orange.shade800;
        display = l10nPick(context, fa: 'در انتظار پرداخت', en: 'Awaiting Payment');
        break;
      case 'FUNDS_HELD':
        bg = Colors.blue.shade50;
        text = Colors.blue.shade800;
        display = l10nPick(context, fa: 'نزد پلتفرم امان است', en: 'Funds Held in Escrow');
        break;
      case 'IN_DELIVERY':
        bg = Colors.purple.shade50;
        text = Colors.purple.shade800;
        display = l10nPick(context, fa: 'در حال ارسال', en: 'In Delivery');
        break;
      case 'DELIVERED':
        bg = Colors.teal.shade50;
        text = Colors.teal.shade800;
        display = l10nPick(context, fa: 'تحویل‌شده (دوره بازرسی)', en: 'Delivered (Inspection)');
        break;
      case 'RELEASED':
      case 'COMPLETED':
        bg = Colors.green.shade50;
        text = Colors.green.shade800;
        display = l10nPick(context, fa: 'تکمیل‌شده و تسویه', en: 'Completed');
        break;
      case 'DISPUTED':
        bg = Colors.red.shade50;
        text = Colors.red.shade800;
        display = l10nPick(context, fa: 'در اختلاف', en: 'Disputed');
        break;
      case 'REFUNDED':
        bg = Colors.pink.shade50;
        text = Colors.pink.shade800;
        display = l10nPick(context, fa: 'عودت به خریدار', en: 'Refunded');
        break;
      case 'CANCELLED':
        bg = Colors.grey.shade100;
        text = Colors.grey.shade600;
        display = l10nPick(context, fa: 'لغو شده', en: 'Cancelled');
        break;
      case 'EXPIRED':
        bg = Colors.grey.shade100;
        text = Colors.grey.shade600;
        display = l10nPick(context, fa: 'منقضی شده', en: 'Expired');
        break;
      default:
        bg = Colors.grey.shade100;
        text = Colors.grey.shade800;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        display,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w900,
          color: text,
        ),
      ),
    );
  }
}

class EscrowTimelineWidget extends StatelessWidget {
  final List<EscrowEventModel> events;

  const EscrowTimelineWidget({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            l10nPick(context, fa: 'تاریخچه رویدادی ثبت نشده است.', en: 'No events logged yet.'),
            style: TextStyle(fontSize: 11.sp, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (ctx, i) {
        final ev = events[i];
        final isLast = i == events.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: isLast ? AppColors.lightPrimary : Colors.grey.shade300,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2.w,
                    height: 36.h,
                    color: Colors.grey.shade200,
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ev.action.isNotEmpty ? ev.action : ev.toStatus,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: isLast ? FontWeight.w900 : FontWeight.w700,
                          color: isLast ? AppColors.lightPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      if (ev.createdAt != null)
                        Text(
                          '${ev.createdAt!.hour.toString().padLeft(2, "0")}:${ev.createdAt!.minute.toString().padLeft(2, "0")}',
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                        ),
                    ],
                  ),
                  if (ev.reason != null && ev.reason!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        ev.reason!,
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
                      ),
                    ),
                  Text(
                    'توسط: ${ev.actorRole}',
                    style: TextStyle(fontSize: 9.sp, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}