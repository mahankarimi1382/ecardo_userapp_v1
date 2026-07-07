class ReferralModel {
  String? status;
  String? message;
  ReferralData? data;

  ReferralModel({this.status, this.message, this.data});

  ReferralModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? ReferralData.fromJson(json['data']) : null;
  }
}

class ReferralData {
  String? amount;
  String? code;
  String? joinedText;
  bool? isShownReferralRules;
  List<Rules>? rules;

  ReferralData({
    this.amount,
    this.code,
    this.joinedText,
    this.isShownReferralRules,
    this.rules,
  });

  ReferralData.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    code = json['code'];
    joinedText = json['joined_text'];
    isShownReferralRules = json['is_shown_referral_rules'];
    if (json['rules'] != null) {
      rules = <Rules>[];
      json['rules'].forEach((v) {
        rules!.add(Rules.fromJson(v));
      });
    }
  }
}

class Rules {
  String? icon;
  String? rule;

  Rules({this.icon, this.rule});

  Rules.fromJson(Map<String, dynamic> json) {
    icon = json['icon'];
    rule = json['rule'];
  }
}
