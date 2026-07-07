import 'package:flutter/material.dart';
import 'package:qunzo_user/src/presentation/screens/referral/model/referral_tree_model.dart';
import 'package:qunzo_user/src/presentation/screens/referral/view/referral_tree/referral_tree.dart';
import 'package:qunzo_user/src/presentation/screens/referral/view/referral_tree/sub_sections/referral_node.dart';
import 'package:qunzo_user/src/presentation/screens/referral/view/referral_tree/sub_sections/tree_line_painter.dart';

class ReferralTreeWidget extends StatefulWidget {
  final ReferralTreeData root;

  const ReferralTreeWidget({super.key, required this.root});

  @override
  State<ReferralTreeWidget> createState() => _ReferralTreeWidgetState();
}

class _ReferralTreeWidgetState extends State<ReferralTreeWidget> {
  final Map<int, NodeInfo> _nodeInfos = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _nodeInfos.clear();
    final rootKey = GlobalKey();

    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        CustomPaint(
          painter: TreeLinePainter(nodeInfos: _nodeInfos, context: context),
          child: _buildNodeUI(widget.root, rootKey, false),
        ),
      ],
    );
  }

  Widget _buildNodeUI(dynamic nodeData, GlobalKey nodeKey, bool hasSiblings) {
    List<Widget> childrenWidgets = [];
    List<GlobalKey> childrenNodeKeys = [];

    if (nodeData.children != null && nodeData.children!.isNotEmpty) {
      for (var child in nodeData.children!) {
        final childKey = GlobalKey();
        childrenNodeKeys.add(childKey);

        childrenWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildNodeUI(child, childKey, nodeData.children!.length > 1),
          ),
        );
      }
    }

    _nodeInfos[nodeData.id ?? GlobalKey().hashCode] = NodeInfo(
      key: nodeKey,
      childrenKeys: childrenNodeKeys,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ReferralNode(
          key: nodeKey,
          name: nodeData.name ?? 'N/A',
          avatarUrl: nodeData.avatar ?? '',
        ),
        if (childrenWidgets.isNotEmpty) ...[
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: hasSiblings
                ? MainAxisAlignment.spaceEvenly
                : MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: childrenWidgets,
          ),
        ],
      ],
    );
  }
}
