import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/my_order/model/order_message_response_model.dart'
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

    return Align(
      alignment: isMe ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        constraints: BoxConstraints(maxWidth: 280.w),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isMe ? null : AppColors.lightBackground,
          gradient: isMe
              ? const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF5B3BDB)],
                )
              : null,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!isMe)
                  CircleAvatar(
                    radius: 16.r,
                    backgroundColor: AppColors.lightTextPrimary.withValues(
                      alpha: 0.7,
                    ),
                    child: Text(
                      message.sender?.name?[0].toUpperCase() ?? 'U',
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                SizedBox(width: 8.w),
                Column(
                  children: [
                    if (!isMe && (message.sender?.name?.isNotEmpty ?? false))
                      Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: Text(
                          message.sender?.name ?? '',
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                            color: AppColors.lightTextPrimary,
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
                          fontSize: 11.sp,
                          color: AppColors.lightTextPrimary.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (!isMe) SizedBox(height: 10.h),
            if ((message.message ?? '').trim().isNotEmpty)
              Text(
                message.message!.trim(),
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  color: isMe
                      ? AppColors.white
                      : AppColors.lightTextPrimary.withValues(alpha: 0.8),
                ),
              ),
            if (attachment != null) ...[
              SizedBox(height: 8.h),
              Text(
                'Attachment:',
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                  color: isMe
                      ? AppColors.white
                      : AppColors.lightTextPrimary.withValues(alpha: 0.6),
                ),
              ),
              GestureDetector(
                onTap: () => onAttachmentTap(attachment),
                child: Text(
                  attachment.name ?? 'Attachment',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                    color: isMe ? AppColors.white : AppColors.lightPrimary,
                  ),
                ),
              ),
            ],
            SizedBox(height: 8.h),
            Align(
              alignment: !isMe ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
              child: Text(
                _formatDateTime(message.createdAt),
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  fontSize: 9.sp,
                  color: isMe
                      ? AppColors.white
                      : AppColors.lightTextPrimary.withValues(alpha: 0.6),
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
