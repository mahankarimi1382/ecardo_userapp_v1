class ReferralTreeModel {
  String? status;
  String? message;
  ReferralTreeData? data;

  ReferralTreeModel({this.status, this.message, this.data});

  ReferralTreeModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? ReferralTreeData.fromJson(json['data']) : null;
  }
}

class ReferralTreeData {
  int? id;
  String? name;
  String? avatar;
  bool? isMe;
  List<Children>? children;

  ReferralTreeData({this.id, this.name, this.avatar, this.isMe, this.children});

  ReferralTreeData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    avatar = json['avatar'];
    isMe = json['is_me'];
    if (json['children'] != null) {
      children = <Children>[];
      json['children'].forEach((v) {
        children!.add(Children.fromJson(v));
      });
    }
  }
}

class Children {
  int? id;
  String? name;
  String? avatar;
  List<Children>? children;

  Children({this.id, this.name, this.avatar, this.children});

  Children.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    avatar = json['avatar'];
    if (json['children'] != null) {
      children = <Children>[];
      json['children'].forEach((v) {
        children!.add(Children.fromJson(v));
      });
    }
  }
}
