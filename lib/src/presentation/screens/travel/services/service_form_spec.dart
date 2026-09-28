import 'package:flutter/material.dart';

/// Field blueprint for the generic extra-service request forms. The screens
/// render and validate from this spec; the label keys are resolved against
/// the active localization at build time.
enum TravelFormFieldType { text, phone, date, time, number, dropdown, textarea }

class TravelFormFieldSpec {
  final String key;
  final String Function() label;
  final TravelFormFieldType type;
  final IconData icon;
  final bool required;
  final List<String> options;
  final int? maxLines;

  const TravelFormFieldSpec({
    required this.key,
    required this.label,
    required this.type,
    required this.icon,
    this.required = true,
    this.options = const [],
    this.maxLines,
  });
}
