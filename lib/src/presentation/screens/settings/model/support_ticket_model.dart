class SupportTicketModel {
  String? status;
  String? message;
  SupportTicketData? data;

  SupportTicketModel({this.status, this.message, this.data});

  SupportTicketModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? SupportTicketData.fromJson(json['data']) : null;
  }
}

class SupportTicketData {
  List<Tickets>? tickets;
  Pagination? pagination;

  SupportTicketData({this.tickets, this.pagination});

  SupportTicketData.fromJson(Map<String, dynamic> json) {
    if (json['tickets'] != null) {
      tickets = <Tickets>[];
      json['tickets'].forEach((v) {
        tickets!.add(Tickets.fromJson(v));
      });
    }
    pagination =
        json['pagination'] != null
            ? Pagination.fromJson(json['pagination'])
            : null;
  }
}

class Tickets {
  int? id;
  String? uuid;
  String? title;
  String? priority;
  String? status;
  String? message;
  List<Attachments>? attachments;
  int? messagesCount;
  bool? isClosed;
  bool? canReply;
  String? createdAt;
  String? updatedAt;

  Tickets({
    this.id,
    this.uuid,
    this.title,
    this.priority,
    this.status,
    this.message,
    this.attachments,
    this.messagesCount,
    this.isClosed,
    this.canReply,
    this.createdAt,
    this.updatedAt,
  });

  Tickets.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    title = json['title'];
    priority = json['priority'];
    status = json['status'];
    message = json['message'];
    if (json['attachments'] != null) {
      attachments = <Attachments>[];
      json['attachments'].forEach((v) {
        attachments!.add(Attachments.fromJson(v));
      });
    }
    messagesCount = json['messages_count'];
    isClosed = json['is_closed'];
    canReply = json['can_reply'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}

class Attachments {
  String? name;
  String? url;
  int? size;
  String? type;

  Attachments({this.name, this.url, this.size, this.type});

  Attachments.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    url = json['url'];
    size = json['size'];
    type = json['type'];
  }
}

class Pagination {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  Pagination({this.currentPage, this.lastPage, this.perPage, this.total});

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
  }
}
