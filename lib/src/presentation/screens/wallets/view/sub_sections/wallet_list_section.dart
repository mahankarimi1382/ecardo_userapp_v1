import 'package:flutter/material.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/view/sub_sections/wallets_card_section.dart';

export 'package:ecardo_user/src/presentation/screens/wallets/view/sub_sections/wallets_card_section.dart';

/// Legacy alias for [WalletsCardSection] for backward compatibility.
class WalletListSection extends StatelessWidget {
  const WalletListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const WalletsCardSection();
  }
}
