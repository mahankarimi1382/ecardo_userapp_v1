import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/model/gift_card_history_model.dart';

class GiftCardHistoryDetails extends StatefulWidget {
  final GiftCards giftCard;

  const GiftCardHistoryDetails({super.key, required this.giftCard});

  @override
  State<GiftCardHistoryDetails> createState() => _GiftCardHistoryDetailsState();
}

class _GiftCardHistoryDetailsState extends State<GiftCardHistoryDetails> {
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return AnimatedContainer(
      width: double.infinity,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      margin: EdgeInsetsDirectional.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(20.r),
          topEnd: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 40.r,
            spreadRadius: 0,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTransactionInfo(),
                    SizedBox(height: 30.h),
                    _buildDetailRow(
                      label: localization.giftCardTransactionIdLabel,
                      value: widget.giftCard.transactionId ?? "",
                    ),
                    _buildDetailRow(
                      label: localization.giftCardSenderNameLabel,
                      value: widget.giftCard.senderName ?? "",
                    ),
                    _buildDetailRow(
                      label: localization.giftCardRecipientEmailLabel,
                      value: widget.giftCard.recipientEmail ?? "",
                    ),
                    _buildDetailRow(
                      label: localization.giftCardRecipientPhoneLabel,
                      value: widget.giftCard.recipientPhoneNumber ?? "",
                    ),
                    _buildDetailRow(
                      label: localization.giftCardUnitPriceLabel,
                      value: widget.giftCard.unitPrice ?? "",
                    ),
                    _buildDetailRow(
                      label: localization.giftCardQuantityLabel,
                      value: widget.giftCard.quantity.toString(),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              letterSpacing: 0,
              fontSize: 13.sp,
              color: AppColors.lightTextTertiary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                letterSpacing: 0,
                fontSize: 13.sp,
                color: AppColors.lightTextPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 1.1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.white,
            AppColors.lightTextPrimary.withValues(alpha: 0.1),
            AppColors.white,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final localization = AppLocalizations.of(context)!;

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          localization.giftCardHistoryDetailsTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildDivider(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTransactionInfo() {
    final localization = AppLocalizations.of(context)!;
    final giftCard = widget.giftCard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: CachedNetworkImage(
                width: 100.w,
                height: 66.h,
                imageUrl: giftCard.productThumbnail ?? "",
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    color: AppColors.lightPrimary,
                  ),
                ),
                errorWidget: (context, url, error) =>
                    Icon(Icons.error, size: 20.w, color: AppColors.error),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    giftCard.totalPrice ?? "",
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      color: AppColors.success,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    localization.giftCardHistoryQtyLabel(
                      giftCard.quantity.toString(),
                    ),
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Text(
          giftCard.productName ?? "",
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            color: AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          giftCard.createdAt ?? "",
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
            color: AppColors.lightTextTertiary,
          ),
        ),
      ],
    );
  }
}
