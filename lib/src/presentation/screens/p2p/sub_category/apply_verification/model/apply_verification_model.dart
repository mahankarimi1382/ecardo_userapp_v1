import 'dart:io';

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

class ApplyVerificationFieldFileValue {
  final File file;
  final bool isImage;
  final String name;

  const ApplyVerificationFieldFileValue({
    required this.file,
    required this.isImage,
    required this.name,
  });
}
