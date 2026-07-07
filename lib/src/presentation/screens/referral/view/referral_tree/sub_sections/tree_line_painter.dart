import 'package:flutter/material.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/presentation/screens/referral/view/referral_tree/referral_tree.dart';

class TreeLinePainter extends CustomPainter {
  final Map<int, NodeInfo> nodeInfos;
  final BuildContext context;

  TreeLinePainter({required this.nodeInfos, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.lightTextTertiary.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    final double verticalLineSegmentLength = 40.0;

    nodeInfos.forEach((nodeId, info) {
      final parentRenderBox =
          info.key.currentContext?.findRenderObject() as RenderBox?;
      if (parentRenderBox == null || !parentRenderBox.hasSize) return;

      final parentPosition = parentRenderBox.localToGlobal(
        Offset.zero,
        ancestor: context.findRenderObject(),
      );
      final parentAnchor = Offset(
        parentPosition.dx + parentRenderBox.size.width / 2,
        parentPosition.dy + parentRenderBox.size.height - 30,
      );

      if (info.childrenKeys.isEmpty) return;

      final parentVerticalLineEnd = Offset(
        parentAnchor.dx,
        parentAnchor.dy + verticalLineSegmentLength,
      );
      canvas.drawLine(parentAnchor, parentVerticalLineEnd, paint);

      List<RenderBox> childRenderBoxes = [];
      List<Offset> childAnchors = [];

      for (var childKey in info.childrenKeys) {
        final childRenderBox =
            childKey.currentContext?.findRenderObject() as RenderBox?;
        if (childRenderBox != null && childRenderBox.hasSize) {
          childRenderBoxes.add(childRenderBox);
          final childPosition = childRenderBox.localToGlobal(
            Offset.zero,
            ancestor: context.findRenderObject(),
          );
          childAnchors.add(
            Offset(
              childPosition.dx + childRenderBox.size.width / 2,
              childPosition.dy + 30,
            ),
          );
        }
      }

      if (childAnchors.isEmpty) return;

      final double horizontalLineY = parentVerticalLineEnd.dy;

      if (childAnchors.length > 1) {
        canvas.drawLine(
          Offset(childAnchors.first.dx, horizontalLineY),
          Offset(childAnchors.last.dx, horizontalLineY),
          paint,
        );

        canvas.drawLine(
          parentVerticalLineEnd,
          Offset(parentAnchor.dx, horizontalLineY),
          paint,
        );
      } else if (childAnchors.length == 1) {
        canvas.drawLine(
          parentVerticalLineEnd,
          Offset(childAnchors.first.dx, horizontalLineY),
          paint,
        );
      }

      for (var childAnchor in childAnchors) {
        canvas.drawLine(
          Offset(childAnchor.dx, horizontalLineY),
          childAnchor,
          paint,
        );
      }
    });
  }

  @override
  bool shouldRepaint(covariant TreeLinePainter oldDelegate) {
    return oldDelegate.nodeInfos != nodeInfos;
  }
}
