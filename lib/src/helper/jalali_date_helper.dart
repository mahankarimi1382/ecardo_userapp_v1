import 'package:shamsi_date/shamsi_date.dart';

/// Formats server timestamps in Asia/Tehran as Jalali with relative day labels.
class JalaliDateHelper {
  static DateTime _toTehran(DateTime dt) {
    // If already local with offset, convert via UTC then +3:30.
    final utc = dt.isUtc ? dt : dt.toUtc();
    return utc.add(const Duration(hours: 3, minutes: 30));
  }

  static DateTime? tryParse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw.trim());
  }

  static String format(String? raw, {DateTime? now}) {
    final parsed = tryParse(raw);
    if (parsed == null) return raw ?? '';
    return formatDateTime(parsed, now: now);
  }

  static String formatDateTime(DateTime dt, {DateTime? now}) {
    final tehran = _toTehran(dt);
    final n = now != null ? _toTehran(now) : _toTehran(DateTime.now().toUtc());
    final time =
        '${tehran.hour.toString().padLeft(2, '0')}:${tehran.minute.toString().padLeft(2, '0')}';

    final today = DateTime(n.year, n.month, n.day);
    final day = DateTime(tehran.year, tehran.month, tehran.day);
    final diff = today.difference(day).inDays;

    if (diff == 0) return 'امروز $time';
    if (diff == 1) return 'دیروز $time';

    final j = Jalali.fromDateTime(tehran);
    final y = j.year.toString().padLeft(4, '0');
    final m = j.month.toString().padLeft(2, '0');
    final d = j.day.toString().padLeft(2, '0');
    return '$y/$m/$d - $time';
  }
}
