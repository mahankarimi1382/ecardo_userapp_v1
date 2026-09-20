import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/status_label_helper.dart';

/// Maps API status tokens (Success/Pending/Failed, any casing) to localized
/// chip/list labels. Keeps the raw token for query params unchanged.
class StatusLabelHelper {
  const StatusLabelHelper._();

  static String localize(AppLocalizations loc, String status) {
    switch (status.trim().toLowerCase()) {
      case 'success':
        return loc.transactionStatusSuccess;
      case 'pending':
        return loc.transactionStatusPending;
      case 'failed':
      case 'reject':
      case 'rejected':
        return loc.transactionStatusFailed;
      default:
        return status;
    }
  }
}
