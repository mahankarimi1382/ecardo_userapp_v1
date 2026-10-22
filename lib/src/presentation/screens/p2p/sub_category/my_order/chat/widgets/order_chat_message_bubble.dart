import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/my_order/model/order_message_response_model.dart'
    as chat_model;

class OrderChatMessageBubble extends StatelessWidget {
  final chat_model.Message message;
  final ValueChanged<chat_model.Attachment> onAttachmentTap;

  const OrderChatMessageBubble({
    super.key,
    required this.message,
    required this.onAttachmentTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe == true;
    final attachment = message.attachment;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryAccent = isDark
        ? AppColors.mainSoftBlue
        : AppColors.brandViolet;
    final otherBg = isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9);
    final otherBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final otherTextColor = isDark
        ? AppColors.darkTextPrimary
        : const Color(0xFF1E293B);
    final otherSubText = isDark
        ? AppColors.darkTextSecondary
        : const Color(0xFF64748B);

    return Align(
      alignment: isMe
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        constraints: BoxConstraints(maxWidth: 290.w),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: isMe ? null : otherBg,
          gradient: isMe
              ? const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF5B3BDB)],
                )
              : null,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isMe ? 16.r : 4.r),
            bottomRight: Radius.circular(isMe ? 4.r : 16.r),
          ),
          border: isMe ? null : Border.all(color: otherBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!isMe)
                  CircleAvatar(
                    radius: 14.r,
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : const Color(0xFFCBD5E1),
                    child: Text(
                      message.sender?.name?[0].toUpperCase() ?? 'U',
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.sp,
                        color: isDark
                            ? AppColors.warmWhite
                            : AppColors.deepBlack,
                      ),
                    ),
                  ),
                if (!isMe) SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe && (message.sender?.name?.isNotEmpty ?? false))
                      Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: Text(
                          message.sender?.name ?? '',
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5.sp,
                            color: otherTextColor,
                          ),
                        ),
                      ),

                    if (!isMe &&
                        (message.sender?.username?.isNotEmpty ?? false))
                      Text(
                        message.sender?.username ?? '',
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.5.sp,
                          color: otherSubText,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (!isMe) SizedBox(height: 8.h),
            if ((message.message ?? '').trim().isNotEmpty)
              Text(
                message.message!.trim(),
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w500,
                  fontSize: 13.5.sp,
                  height: 1.4,
                  color: isMe ? AppColors.white : otherTextColor,
                ),
              ),
            if (attachment != null) ...[
              SizedBox(height: 8.h),
              Text(
                'Attachment:',
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5.sp,
                  color: isMe
                      ? AppColors.white.withValues(alpha: 0.85)
                      : otherSubText,
                ),
              ),
              GestureDetector(
                onTap: () => onAttachmentTap(attachment),
                child: Container(
                  margin: EdgeInsets.only(top: 4.h),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.15)
                        : primaryAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.attach_file_rounded,
                        size: 14.sp,
                        color: isMe ? AppColors.white : primaryAccent,
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          attachment.name ?? 'Attachment',
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
                            color: isMe ? AppColors.white : primaryAccent,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 6.h),
            Align(
              alignment: !isMe
                  ? AlignmentDirectional.centerStart
                  : AlignmentDirectional.centerEnd,
              child: Text(
                _formatDateTime(message.createdAt),
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  fontSize: 9.sp,
                  color: isMe
                      ? AppColors.white.withValues(alpha: 0.70)
                      : otherSubText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--';
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime.toLocal());
  }
}
