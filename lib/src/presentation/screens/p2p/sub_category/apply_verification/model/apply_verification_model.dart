/// مدل‌های مربوط به فرم درخواست تأیید معامله‌گر تأیید شده P2P
/// استفاده از XFile به جای dart:io File برای سازگاری با وب و موبایل

import 'package:image_picker/image_picker.dart' show XFile;

/// مدل ساده فیلد فرم (نام، نوع، اعتبارسنجی، دستورالعمل‌ها)
class ApplyVerificationModel {
  final String name;
  final String type;
  final String validation;
  final String instructions;

  const ApplyVerificationModel({
    required this.name,
    required this.type,
    required this.validation,
    required this.instructions,
  });
}

/// مدل مقدار فایل انتخاب‌شده برای هر فیلد فایلی
/// از XFile استفاده شده تا هم در موبایل و هم در وب کار کند
/// dart:io.File فقط در موبایل در دسترس است و در وب خطا می‌دهد
class ApplyVerificationFieldFileValue {
  final XFile file;
  final bool isImage;
  final String name;

  const ApplyVerificationFieldFileValue({
    required this.file,
    required this.isImage,
    required this.name,
  });
}
