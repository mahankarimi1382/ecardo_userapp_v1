class UserModel {
  String? status;
  String? message;
  UserData? data;

  UserModel({this.status, this.message, this.data});

  UserModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? UserData.fromJson(json['data']) : null;
  }
}

class UserData {
  int? id;
  String? role;
  String? firstName;
  String? lastName;
  String? username;
  String? accountNumber;
  String? phone;
  String? email;
  String? emailVerifiedAt;
  String? avatar;
  int? status;
  int? kyc;
  bool? phoneVerified;
  String? otp;
  String? provider;
  String? providerId;
  String? balance;
  String? passcode;
  String? country;
  String? gender;
  String? dateOfBirth;
  String? city;
  String? zipCode;
  String? address;
  String? closeReason;
  String? refId;
  String? referralCode;
  bool? twoFa;
  int? withdrawStatus;
  int? otpStatus;
  int? depositStatus;
  int? transferStatus;
  int? referralStatus;
  int? paymentStatus;
  String? createdAt;
  String? updatedAt;
  String? currentStep;
  BoardingSteps? boardingSteps;
  String? fullName;
  String? kycType;
  String? totalProfit;
  String? avatarPath;
  String? google2faSecret;
  bool? isRejected;
  String? rejectionReason;
  Addons? addons;

  UserData({
    this.id,
    this.role,
    this.firstName,
    this.lastName,
    this.username,
    this.accountNumber,
    this.phone,
    this.email,
    this.emailVerifiedAt,
    this.avatar,
    this.status,
    this.kyc,
    this.phoneVerified,
    this.otp,
    this.provider,
    this.providerId,
    this.balance,
    this.passcode,
    this.country,
    this.gender,
    this.dateOfBirth,
    this.city,
    this.zipCode,
    this.address,
    this.closeReason,
    this.refId,
    this.referralCode,
    this.twoFa,
    this.withdrawStatus,
    this.otpStatus,
    this.depositStatus,
    this.transferStatus,
    this.referralStatus,
    this.paymentStatus,
    this.createdAt,
    this.updatedAt,
    this.currentStep,
    this.boardingSteps,
    this.fullName,
    this.kycType,
    this.totalProfit,
    this.avatarPath,
    this.google2faSecret,
    this.isRejected,
    this.rejectionReason,
    this.addons,
  });

  UserData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    username = json['username'];
    accountNumber = json['account_number'];
    phone = json['phone'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    avatar = json['avatar'];
    status = json['status'];
    kyc = json['kyc'];
    phoneVerified = json['phone_verified'];
    otp = json['otp'];
    provider = json['provider'];
    providerId = json['provider_id'];
    balance = json['balance'];
    passcode = json['passcode'];
    country = json['country'];
    gender = json['gender'];
    dateOfBirth = json['date_of_birth'];
    city = json['city'];
    zipCode = json['zip_code'];
    address = json['address'];
    closeReason = json['close_reason'];
    refId = json['ref_id'];
    referralCode = json['referral_code'];
    twoFa = json['two_fa'];
    withdrawStatus = json['withdraw_status'];
    otpStatus = json['otp_status'];
    depositStatus = json['deposit_status'];
    transferStatus = json['transfer_status'];
    referralStatus = json['referral_status'];
    paymentStatus = json['payment_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    currentStep = json['current_step'];
    boardingSteps = json['boarding_steps'] != null
        ? BoardingSteps.fromJson(json['boarding_steps'])
        : null;
    fullName = json['full_name'];
    kycType = json['kyc_type'];
    totalProfit = json['total_profit'];
    avatarPath = json['avatar_path'];
    google2faSecret = json['google2fa_secret'];
    isRejected = json['is_rejected'];
    rejectionReason = json['rejection_reason'];
    addons = json['addons'] != null ? Addons.fromJson(json['addons']) : null;
  }
}

class BoardingSteps {
  bool? emailVerification;
  bool? passwordSetup;
  bool? personalInfo;
  bool? idVerification;
  bool? completed;

  BoardingSteps({this.personalInfo, this.idVerification, this.completed});

  BoardingSteps.fromJson(Map<String, dynamic> json) {
    emailVerification = json['email_verification'];
    passwordSetup = json['password_setup'];
    personalInfo = json['personal_info'];
    idVerification = json['id_verification'];
    completed = json['completed'];
  }
}

class Addons {
  bool? virtualCards;
  bool? giftCards;
  bool? p2pTrading;

  Addons({this.virtualCards, this.giftCards, this.p2pTrading});

  Addons.fromJson(Map<String, dynamic> json) {
    virtualCards = json['virtual_cards'];
    giftCards = json['gift_cards'];
    p2pTrading = json['p2p_trading'];
  }
}
