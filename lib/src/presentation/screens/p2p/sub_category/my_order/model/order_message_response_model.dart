class OrderMessageResponseModel {
  String? status;
  String? message;
  Data? data;

  OrderMessageResponseModel({this.status, this.message, this.data});

  factory OrderMessageResponseModel.fromJson(Map<String, dynamic> json) =>
      OrderMessageResponseModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  List<Message>? messages;

  Data({this.messages});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    messages: json["messages"] == null
        ? []
        : List<Message>.from(json["messages"]!.map((x) => Message.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "messages": messages == null
        ? []
        : List<dynamic>.from(messages!.map((x) => x.toJson())),
  };
}

class Message {
  int? id;
  int? orderId;
  String? senderType;
  bool? isMe;
  Sender? sender;
  String? message;
  Attachment? attachment;
  DateTime? createdAt;

  Message({
    this.id,
    this.orderId,
    this.senderType,
    this.isMe,
    this.sender,
    this.message,
    this.attachment,
    this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"],
    orderId: json["order_id"],
    senderType: json["sender_type"],
    isMe: json["is_me"],
    sender: json["sender"] == null ? null : Sender.fromJson(json["sender"]),
    message: json["message"],
    attachment: json["attachment"] == null
        ? null
        : Attachment.fromJson(json["attachment"]),
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "sender_type": senderType,
    "is_me": isMe,
    "sender": sender?.toJson(),
    "message": message,
    "attachment": attachment?.toJson(),
    "created_at": createdAt?.toIso8601String(),
  };
}

class Attachment {
  String? name;
  String? mime;
  int? size;
  String? path;

  Attachment({this.name, this.mime, this.size, this.path});

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
    name: json["name"],
    mime: json["mime"],
    size: json["size"],
    path: json["path"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "mime": mime,
    "size": size,
    "path": path,
  };
}

class Sender {
  int? id;
  String? name;
  String? username;

  Sender({this.id, this.name, this.username});

  factory Sender.fromJson(Map<String, dynamic> json) =>
      Sender(id: json["id"], name: json["name"], username: json["username"]);

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "username": username,
  };
}
