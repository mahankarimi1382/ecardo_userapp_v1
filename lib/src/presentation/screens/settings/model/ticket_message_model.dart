class TicketMessageModel {
  String? status;
  String? message;
  TicketMessageData? data;

  TicketMessageModel({this.status, this.message, this.data});

  TicketMessageModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? TicketMessageData.fromJson(json['data']) : null;
  }
}

class TicketMessageData {
  Ticket? ticket;
  List<Messages>? messages;

  TicketMessageData({this.ticket, this.messages});

  TicketMessageData.fromJson(Map<String, dynamic> json) {
    ticket = json['ticket'] != null ? Ticket.fromJson(json['ticket']) : null;
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(Messages.fromJson(v));
      });
    }
  }
}

class Ticket {
  int? id;
  String? uuid;
  String? title;
  String? priority;
  String? status;
  String? message;
  List<Attachments>? attachments;
  bool? isClosed;
  bool? canReply;
  TicketUser? user;
  String? createdAt;
  String? updatedAt;

  Ticket({
    this.id,
    this.uuid,
    this.title,
    this.priority,
    this.status,
    this.message,
    this.attachments,
    this.isClosed,
    this.canReply,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  Ticket.fromJson(Map<String, dynamic> json) {
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
    isClosed = json['is_closed'];
    canReply = json['can_reply'];
    user = json['user'] != null ? TicketUser.fromJson(json['user']) : null;
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

class TicketUser {
  int? id;
  String? name;
  String? avatar;
  String? email;

  TicketUser({this.id, this.name, this.avatar, this.email});

  TicketUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    avatar = json['avatar'];
    email = json['email'];
  }
}

class Messages {
  int? id;
  String? message;
  List<Attachments>? attachments;
  User? user;
  bool? isAdmin;
  String? createdAt;
  String? createdAtFormatted;

  Messages({
    this.id,
    this.message,
    this.attachments,
    this.user,
    this.isAdmin,
    this.createdAt,
    this.createdAtFormatted,
  });

  Messages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    message = json['message'];
    if (json['attachments'] != null) {
      attachments = <Attachments>[];
      json['attachments'].forEach((v) {
        attachments!.add(Attachments.fromJson(v));
      });
    }
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    isAdmin = json['is_admin'];
    createdAt = json['created_at'];
    createdAtFormatted = json['created_at_formatted'];
  }
}

class User {
  String? name;
  String? email;
  String? avatar;

  User({this.name, this.email, this.avatar});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    avatar = json['avatar'];
  }
}
