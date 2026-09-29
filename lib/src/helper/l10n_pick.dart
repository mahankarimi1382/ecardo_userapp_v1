import 'package:flutter/material.dart';

/// Helper to pick localized string dynamically based on the current locale
/// without requiring rebuild of generated ARB localization files.
String l10nPick(
  BuildContext context, {
  required String en,
  required String fa,
  String? ar,
  String? tr,
  String? ru,
  String? zh,
}) {
  final locale = Localizations.localeOf(context).languageCode;
  switch (locale) {
    case 'fa':
      return fa;
    case 'ar':
      return ar ?? fa;
    case 'tr':
      return tr ?? en;
    case 'ru':
      return ru ?? en;
    case 'zh':
      return zh ?? en;
    case 'en':
    default:
      return en;
  }
}
