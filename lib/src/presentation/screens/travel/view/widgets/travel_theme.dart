import 'package:flutter/material.dart';

abstract final class TravelTheme {
  static const navy = Color(0xFF0F172A);
  static const navySoft = Color(0xFF1E293B);
  static const gold = Color(0xFFD4AF37);
  static const goldSoft = Color(0xFFFFE08A);
  static const background = Color(0xFFF8FAFC);
  static const field = Color(0xFFF1F5F9);
  static const text = Color(0xFF191C1E);
  static const muted = Color(0xFF64748B);
  static const line = Color(0xFFE2E8F0);
  static const success = Color(0xFF14805E);
  static const danger = Color(0xFFBA1A1A);

  static BorderRadius get cardRadius => BorderRadius.circular(24);
  static BorderRadius get pillRadius => BorderRadius.circular(999);

  static const cardShadow = [
    BoxShadow(color: Color(0x0F0F172A), blurRadius: 30, offset: Offset(0, 12)),
  ];
}
