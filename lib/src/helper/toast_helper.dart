import 'package:fluttertoast/fluttertoast.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';

class ToastHelper {
  // Warning Toast Message
  void showWarningToast(String message) {
    Fluttertoast.showToast(msg: message, backgroundColor: AppColors.warning);
  }

  // Error Toast Message
  void showErrorToast(String message) {
    Fluttertoast.showToast(msg: message, backgroundColor: AppColors.error);
  }

  // Success Toast Message
  void showSuccessToast(String message) {
    Fluttertoast.showToast(msg: message, backgroundColor: AppColors.success);
  }
}
