class TypesAndStatusModel {
  bool? status;
  TypesAndStatusData? data;

  TypesAndStatusModel({this.status, this.data});

  TypesAndStatusModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data =
        json['data'] != null ? TypesAndStatusData.fromJson(json['data']) : null;
  }
}

class TypesAndStatusData {
  List<Types>? types;
  List<Statuses>? statuses;

  TypesAndStatusData({this.types, this.statuses});

  TypesAndStatusData.fromJson(Map<String, dynamic> json) {
    if (json['types'] != null) {
      types = <Types>[];
      json['types'].forEach((v) {
        types!.add(Types.fromJson(v));
      });
    }
    if (json['statuses'] != null) {
      statuses = <Statuses>[];
      json['statuses'].forEach((v) {
        statuses!.add(Statuses.fromJson(v));
      });
    }
  }
}

class Types {
  String? name;
  String? value;

  Types({this.name, this.value});

  Types.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }
}

class Statuses {
  String? name;
  String? value;

  Statuses({this.name, this.value});

  Statuses.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }
}
