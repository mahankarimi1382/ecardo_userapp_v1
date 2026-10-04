import 'dart:convert';

class NotificationsModel {
  String? status;
  String? message;
  NotificationsData? data;

  NotificationsModel({this.status, this.message, this.data});

  NotificationsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? NotificationsData.fromJson(json['data']) : null;
  }
}

class NotificationsData {
  List<Notificationss>? notifications;
  int? unreadCount;
  Meta? meta;

  NotificationsData({this.notifications, this.unreadCount, this.meta});

  NotificationsData.fromJson(Map<String, dynamic> json) {
    if (json['notifications'] != null) {
      notifications = <Notificationss>[];
      json['notifications'].forEach((v) {
        notifications!.add(Notificationss.fromJson(v));
      });
    }
    unreadCount = json['unread_count'];
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }
}

class Notificationss {
  int? id;
  String? title;
  String? message;
  String? type;
  bool? isRead;
  String? createdAt;
  // NOTIF-LINK: optional server-provided deep link. When the backend
  // includes it, tapping the notification navigates straight to the source
  // (route name like '/support_tickets_route' or a full URL) instead of
  // relying on keyword guessing.
  String? link;
  // NOTIF-LINK: free-form payload the backend may attach (e.g. a ticket or
  // transaction uuid) — passed through to the router.
  String? payload;

  Notificationss({
    this.id,
    this.title,
    this.message,
    this.type,
    this.isRead,
    this.createdAt,
    this.link,
    this.payload,
  });

  Notificationss.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    message = json['message'];
    type = json['type'];
    isRead = json['is_read'];
    createdAt = json['created_at'];
    link = json['link'] ?? json['url'] ?? json['route'];
    payload = json['payload'] is Map
        ? jsonEncode(json['payload'])
        : json['payload']?.toString();
  }
}

class Meta {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  Meta({this.currentPage, this.lastPage, this.perPage, this.total});

  Meta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
  }
}
