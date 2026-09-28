import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local, in-app request book for the extra travel services (train, visa,
/// car rental, taxi, ...). These services run on curated in-app demo data —
/// no backend contract yet — so submissions live in shared_preferences and
/// start in the `underReview` state the admin flow will later take over.
enum TravelServiceRequestStatus { underReview, approved, rejected }

TravelServiceRequestStatus travelServiceRequestStatusFromRaw(String raw) {
  return switch (raw.trim().toLowerCase()) {
    'approved' => TravelServiceRequestStatus.approved,
    'rejected' => TravelServiceRequestStatus.rejected,
    _ => TravelServiceRequestStatus.underReview,
  };
}

class TravelServiceRequest {
  final String id;
  final String serviceKey;
  final String title;
  final String subtitle;
  final String amountLabel;
  final String reference;
  final DateTime createdAt;
  final TravelServiceRequestStatus status;
  final Map<String, String> details;

  const TravelServiceRequest({
    required this.id,
    required this.serviceKey,
    required this.title,
    required this.subtitle,
    required this.amountLabel,
    required this.reference,
    required this.createdAt,
    this.status = TravelServiceRequestStatus.underReview,
    this.details = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'service_key': serviceKey,
    'title': title,
    'subtitle': subtitle,
    'amount_label': amountLabel,
    'reference': reference,
    'created_at': createdAt.toIso8601String(),
    'status': status.name,
    'details': details,
  };

  factory TravelServiceRequest.fromJson(Map<String, dynamic> json) {
    return TravelServiceRequest(
      id: json['id']?.toString() ?? '',
      serviceKey: json['service_key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      amountLabel: json['amount_label']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      status: travelServiceRequestStatusFromRaw(
        json['status']?.toString() ?? '',
      ),
      details: (json['details'] as Map? ?? const {}).map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
    );
  }

  /// Human-friendly tracking code shown to the user and later quoted to the
  /// admin flow: `TSR-<base36 stamp><checksum>` — unique enough per device.
  static String generateReference() {
    final stamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final checksum = (stamp.hashCode.abs() % 97).toString().padLeft(2, '0');
    return 'TSR-$stamp$checksum'.toUpperCase();
  }
}

class TravelServiceRequestStore {
  static const _storageKey = 'travel_service_requests_v1';

  static Future<List<TravelServiceRequest>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List? ?? const [];
      return decoded
          .whereType<Map>()
          .map(
            (entry) => TravelServiceRequest.fromJson(
              Map<String, dynamic>.from(entry),
            ),
          )
          .toList();
    } catch (_) {
      // Corrupted payload must never break the app — start clean.
      return const [];
    }
  }

  static Future<void> add(TravelServiceRequest request) async {
    final requests = [...await load(), request];
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(requests.map((entry) => entry.toJson()).toList()),
    );
  }

  static Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }
}

/// One passenger collected inside the local train booking form. Mirrors the
/// shape of [TravelPassenger] without its backend contract (no passport for
/// domestic rail, national code instead).
class TravelLocalPassenger {
  final String fullName;
  final String nationalCode;
  final String gender;

  const TravelLocalPassenger({
    required this.fullName,
    required this.nationalCode,
    required this.gender,
  });

  Map<String, String> toDetails() => {
    'full_name': fullName,
    'national_code': nationalCode,
    'gender': gender,
  };
}
