import 'package:flutter/material.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/presentation/screens/payment_links/view/sub_sections/payment_links_amount_step_section.dart';

import '../../../../../../l10n/app_localizations.dart';

class PaymentLinksCreateSection extends StatelessWidget {
  const PaymentLinksCreateSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            SizedBox(height: 30),
            _buildInstructionSection(context),
            SizedBox(height: 30),
            PaymentLinksAmountStepSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionSection(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFDF2A7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        localizations.paymentLinksInstructionText,
        textAlign: TextAlign.justify,
        style: TextStyle(
          letterSpacing: 0,
          fontSize: 13,
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
