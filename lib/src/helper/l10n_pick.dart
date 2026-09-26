import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

/// Context-free variant for controllers/services — uses the GetX root
/// context and falls back to [en] when no context is available (cold start,
/// background callbacks). WAVE-1: lets the auth chain drop its hardcoded
/// Persian strings without ARB codegen on the server.
String l10nPickAuto({
  required String en,
  required String fa,
  String? ar,
  String? zh,
}) {
  final ctx = Get.context;
  if (ctx == null) return en;
  return l10nPick(ctx, en: en, fa: fa, ar: ar, zh: zh);
}
