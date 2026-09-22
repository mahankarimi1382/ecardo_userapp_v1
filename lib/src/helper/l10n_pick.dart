import 'package:flutter/material.dart';

/// Pick a string for the current locale without requiring new ARB keys.
String l10nPick(
  BuildContext context, {
  required String en,
  required String fa,
  String? ar,
  String? zh,
}) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'fa':
      return fa;
    case 'ar':
      return ar ?? en;
    case 'zh':
      return zh ?? en;
    default:
      return en;
  }
}
