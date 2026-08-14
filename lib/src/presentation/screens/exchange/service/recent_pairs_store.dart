import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local-only store of the user's recently-used currency pairs in the
/// Exchange flow. Persisted to [SharedPreferences] so it survives across
/// sessions. No backend involvement.
///
/// A "pair" is stored as `"FROM_CODE-TO_CODE"` — order matters: a tap
/// on the chip restores the exact direction the user used last time.
///
/// The store is intentionally tiny: at most 6 pairs, FIFO eviction.
class RecentPairsStore {
  RecentPairsStore._();

  static const String _key = 'exchange_recent_pairs';
  static const int _maxEntries = 6;

  /// Returns the recent pairs, most-recent first.
  static Future<List<RecentPair>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    return raw
        .map((s) {
          final parts = s.split('-');
          if (parts.length != 2) return null;
          return RecentPair(
            fromCode: parts[0].toUpperCase(),
            toCode: parts[1].toUpperCase(),
          );
        })
        .whereType<RecentPair>()
        .toList(growable: false);
  }

  /// Inserts [pair] at the front. If the same pair (in either direction)
  /// already exists, it is moved to the front instead of duplicated.
  /// Trims to [_maxEntries].
  static Future<void> add(RecentPair pair) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await load();

    final filtered = current.where((p) {
      // Treat A→B and B→A as the same logical pair for de-duplication,
      // but preserve the new direction.
      final sameForward = p.fromCode == pair.fromCode &&
          p.toCode == pair.toCode;
      final sameReverse = p.fromCode == pair.toCode &&
          p.toCode == pair.fromCode;
      return !(sameForward || sameReverse);
    }).toList();

    filtered.insert(0, pair);
    if (filtered.length > _maxEntries) {
      filtered.removeRange(_maxEntries, filtered.length);
    }

    final raw = filtered
        .map((p) => '${p.fromCode}-${p.toCode}')
        .toList(growable: false);
    await prefs.setStringList(_key, raw);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

class RecentPair {
  const RecentPair({required this.fromCode, required this.toCode});

  final String fromCode;
  final String toCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentPair &&
          fromCode == other.fromCode &&
          toCode == other.toCode;

  @override
  int get hashCode => Object.hash(fromCode, toCode);

  @override
  String toString() => '$fromCode-$toCode';

  String toJson() => jsonEncode({'from': fromCode, 'to': toCode});
}
