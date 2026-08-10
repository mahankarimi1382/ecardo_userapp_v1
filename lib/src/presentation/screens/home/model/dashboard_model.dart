class DashboardModel {
  String? status;
  String? message;
  DashboardData? data;

  DashboardModel({this.status, this.message, this.data});

  DashboardModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? DashboardData.fromJson(json['data']) : null;
  }
}

class DashboardData {
  Referral? referral;
  Info? info;
  User? user;

  DashboardData({this.referral, this.info, this.user});

  DashboardData.fromJson(Map<String, dynamic> json) {
    referral =
        json['referral'] != null ? Referral.fromJson(json['referral']) : null;
    info = json['info'] != null ? Info.fromJson(json['info']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
}

class Referral {
  String? bonus;
  int? count;
  String? referralCode;

  Referral({this.bonus, this.count, this.referralCode});

  Referral.fromJson(Map<String, dynamic> json) {
    bonus = json['bonus'];
    count = json['count'];
    referralCode = json['referral_code'];
  }
}

class Info {
  String? timeWiseWish;
  ExchangeConfig? exchangeConfig;
  String? lastLogin;
  int? unreadNotificationsCount;

  Info({
    this.timeWiseWish,
    this.exchangeConfig,
    this.lastLogin,
    this.unreadNotificationsCount,
  });

  Info.fromJson(Map<String, dynamic> json) {
    timeWiseWish = json['time_wise_wish'];
    exchangeConfig =
        json['exchange_config'] != null
            ? ExchangeConfig.fromJson(json['exchange_config'])
            : null;
    lastLogin = json['last_login'];
    unreadNotificationsCount = json['unread_notifications_count'];
  }
}

class ExchangeConfig {
  String? charge;
  String? chargeType;

  ExchangeConfig({this.charge, this.chargeType});

  ExchangeConfig.fromJson(Map<String, dynamic> json) {
    charge = json['charge'];
    chargeType = json['charge_type'];
  }
}

class User {
  String? fullName;
  String? userName;
  String? accountNumber;
  String? email;
  String? avatarPath;

  User({
    this.fullName,
    this.accountNumber,
    this.email,
    this.avatarPath,
    this.userName,
  });

  User.fromJson(Map<String, dynamic> json) {
    userName = json['username'];
    fullName = json['full_name'];
    accountNumber = json['account_number'];
    email = json['email'];
    avatarPath = json['avatar_path'];
  }
}
