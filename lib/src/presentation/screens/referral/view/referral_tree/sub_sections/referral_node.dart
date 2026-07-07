import 'package:flutter/material.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';

class ReferralNode extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final bool isRoot;

  const ReferralNode({
    super.key,
    required this.name,
    required this.avatarUrl,
    this.isRoot = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryTextColor = AppColors.lightTextPrimary;
    final Color nodeBackgroundColor = AppColors.lightBackground;

    Border? nodeBorder;
    nodeBorder = Border.all(
      color: AppColors.lightTextPrimary.withValues(alpha: 0.15),
      width: 1,
    );

    BoxDecoration nodeDecoration = BoxDecoration(
      color: nodeBackgroundColor,
      borderRadius: BorderRadius.circular(12.0),
      border: nodeBorder,
    );

    return Container(
      width: 150,
      decoration: nodeDecoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: isRoot ? 28 : 22,
              backgroundColor: AppColors.white,
              backgroundImage: avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              onBackgroundImageError:
                  (dynamic exception, StackTrace? stackTrace) {},
              child: avatarUrl.isEmpty
                  ? Icon(Icons.person_outline, size: isRoot ? 35 : 30)
                  : null,
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: isRoot ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
                color: primaryTextColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
