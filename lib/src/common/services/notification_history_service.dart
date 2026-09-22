import 'dart:convert';

import 'package:get/get.dart';
import 'package:ecardo_user/src/common/services/app_badge_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local notification history that survives logout (prefs, not session wipe).
class NotificationHistoryItem {
  final String id;
  final String title;
  final String body;
  final String type; // financial | system | update | general
  final DateTime at;
  final bool read;
  final String? payload;

  NotificationHistoryItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.at,
    this.read = false,
    this.payload,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type,
        'at': at.toIso8601String(),
        'read': read,
        'payload': payload,
      };

  factory NotificationHistoryItem.fromJson(Map<String, dynamic> j) {
    return NotificationHistoryItem(
      id: j['id']?.toString() ?? '',
      title: j['title']?.toString() ?? '',
      body: j['body']?.toString() ?? '',
      type: j['type']?.toString() ?? 'general',
      at: DateTime.tryParse(j['at']?.toString() ?? '') ?? DateTime.now(),
      read: j['read'] == true,
      payload: j['payload']?.toString(),
    );
  }

  NotificationHistoryItem copyWith({bool? read}) => NotificationHistoryItem(
        id: id,
        title: title,
        body: body,
        type: type,
        at: at,
        read: read ?? this.read,
        payload: payload,
      );
}

class NotificationHistoryService extends GetxService {
  static const _key = 'ecardo_notif_history_v1';
  static const _max = 200;

  final RxList<NotificationHistoryItem> items = <NotificationHistoryItem>[].obs;

  Future<NotificationHistoryService> init() async {
    await _load();
    return this;
  }

  int get unreadCount => items.where((e) => !e.read).length;

  Future<void> add({
    required String title,
    required String body,
    String type = 'general',
    String? payload,
  }) async {
    final item = NotificationHistoryItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      at: DateTime.now(),
      payload: payload,
    );
    items.insert(0, item);
    if (items.length > _max) {
      items.removeRange(_max, items.length);
    }
    await _persist();
    await _syncBadge();
  }

  Future<void> markRead(String id) async {
    final i = items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    items[i] = items[i].copyWith(read: true);
    items.refresh();
    await _persist();
    await _syncBadge();
  }

  Future<void> markAllRead() async {
    for (var i = 0; i < items.length; i++) {
      if (!items[i].read) items[i] = items[i].copyWith(read: true);
    }
    items.refresh();
    await _persist();
    await _syncBadge();
  }

  List<NotificationHistoryItem> filtered({
    bool? unreadOnly,
    String? type,
  }) {
    return items.where((e) {
      if (unreadOnly == true && e.read) return false;
      if (type != null && type.isNotEmpty && e.type != type) return false;
      return true;
    }).toList();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      items.assignAll(
        list
            .whereType<Map>()
            .map((e) => NotificationHistoryItem.fromJson(
                  Map<String, dynamic>.from(e),
                )),
      );
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _syncBadge() async {
    if (!Get.isRegistered<AppBadgeService>()) return;
    await Get.find<AppBadgeService>().update(unreadCount);
  }
}
