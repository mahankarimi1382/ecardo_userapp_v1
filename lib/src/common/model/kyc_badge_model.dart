// KycBadge info model — returned by /auth/user/get as `kyc_badge`
// Used to show KYC rank indicator next to notification bell in the home toolbar
// and to enable/disable feature tiles.

class KycBadge {
  int? level;           // 1 = Basic, 2 = Standard, 3 = Merchant/Gold
  String? name;         // e.g. "استاندارد / Standard"
  String? color;        // "gray" | "green" | "gold"
  String? icon;         // "user" | "check-badge" | "briefcase"
  String? description;
  String? kycStatus;    // "not_submitted" | "pending" | "verified" | "failed"
  List<String> features; // feature keys allowed at this level
  bool? badgePulse;     // true when KYC is pending → animate pulse
  KycNextLevel? nextLevel;

  KycBadge({
    this.level,
    this.name,
    this.color,
    this.icon,
    this.description,
    this.kycStatus,
    this.features = const [],
    this.badgePulse,
    this.nextLevel,
  });

  KycBadge.fromJson(Map<String, dynamic> json)
      : level = json['level'],
        name = json['name'],
        color = json['color'],
        icon = json['icon'],
        description = json['description'],
        kycStatus = json['kyc_status'],
        features = (json['features'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        badgePulse = json['badge_pulse'] ?? false,
        nextLevel = json['next_level'] != null ? KycNextLevel.fromJson(json['next_level']) : null;

  bool get isFeatureBlockedPending => kycStatus == 'pending';
  bool get isVerified => kycStatus == 'verified';
  bool get isFailed => kycStatus == 'failed';
  bool get isNotSubmitted => kycStatus == null || kycStatus == 'not_submitted';
}

class KycNextLevel {
  int? level;
  String? name;
  String? description;
  List<String> requiredDocs;

  KycNextLevel({this.level, this.name, this.description, this.requiredDocs = const []});

  KycNextLevel.fromJson(Map<String, dynamic> json)
      : level = json['level'],
        name = json['name'],
        description = json['description'],
        requiredDocs = (json['required_docs'] as List?)?.map((e) => e.toString()).toList() ?? const [];
}
