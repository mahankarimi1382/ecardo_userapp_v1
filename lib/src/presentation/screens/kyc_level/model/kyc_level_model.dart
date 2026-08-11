// KYC Level Models — v1.0.5
// مدل‌های سیستم سطوح KYC (سازگار با API v3.9)

/// یک سطح KYC با ویژگی‌ها و مدارک لازم.
class KycLevel {
  final int level;
  final String name;
  final String description;
  final String color;
  final String icon;
  final List<String> requiredDocs;
  final List<String> features;
  final Map<String, dynamic> limits;
  final String status; // completed | current | available | locked

  KycLevel({
    required this.level,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
    required this.requiredDocs,
    required this.features,
    required this.limits,
    required this.status,
  });

  factory KycLevel.fromJson(Map<String, dynamic> json) {
    return KycLevel(
      level: json['level'] as int? ?? 1,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      color: json['color'] as String? ?? 'gray',
      icon: json['icon'] as String? ?? 'user',
      requiredDocs: (json['required_docs'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      limits: json['limits'] as Map<String, dynamic>? ?? {},
      status: json['status'] as String? ?? 'locked',
    );
  }

  /// رنگ به‌صورت Color (متدهای کمکی)
  int get colorValue {
    switch (color) {
      case 'green':
        return 0xFF14AE6F;
      case 'gold':
        return 0xFFFFD700;
      case 'blue':
        return 0xFF2196F3;
      case 'purple':
        return 0xFF7445FF;
      default:
        return 0xFF9E9E9E; // gray
    }
  }

  /// آیا این سطح تکمیل‌شده است؟
  bool get isCompleted => status == 'completed';

  /// آیا این سطح فعلی است؟
  bool get isCurrent => status == 'current';

  /// آیا این سطح قابل دسترسی است (مرحله بعدی)؟
  bool get isAvailable => status == 'available';

  /// آیا این سطح قفل است؟
  bool get isLocked => status == 'locked';

  /// آیا این سطح به feature خاصی دسترسی دارد؟
  bool hasFeature(String feature) => features.contains(feature);
}

/// Badge کاربر — اطلاعات خلاصه‌ی سطح فعلی + مرحله بعدی.
class KycBadge {
  final int level;
  final String name;
  final String color;
  final String icon;
  final String description;
  final List<String> requiredDocs;
  final String kycStatus; // verified | pending | failed | not_submitted
  final List<String> features;
  final KycNextLevel? nextLevel;
  final bool badgePulse;

  KycBadge({
    required this.level,
    required this.name,
    required this.color,
    required this.icon,
    required this.description,
    required this.requiredDocs,
    required this.kycStatus,
    required this.features,
    this.nextLevel,
    required this.badgePulse,
  });

  factory KycBadge.fromJson(Map<String, dynamic> json) {
    return KycBadge(
      level: json['level'] as int? ?? 1,
      name: json['name'] as String? ?? '',
      color: json['color'] as String? ?? 'gray',
      icon: json['icon'] as String? ?? 'user',
      description: json['description'] as String? ?? '',
      requiredDocs: (json['required_docs'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      kycStatus: json['kyc_status'] as String? ?? 'not_submitted',
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      nextLevel: json['next_level'] != null
          ? KycNextLevel.fromJson(json['next_level'] as Map<String, dynamic>)
          : null,
      badgePulse: json['badge_pulse'] as bool? ?? false,
    );
  }

  int get colorValue {
    switch (color) {
      case 'green':
        return 0xFF14AE6F;
      case 'gold':
        return 0xFFFFD700;
      case 'blue':
        return 0xFF2196F3;
      case 'purple':
        return 0xFF7445FF;
      default:
        return 0xFF9E9E9E;
    }
  }

  bool get isVerified => kycStatus == 'verified';
  bool get isPending => kycStatus == 'pending';
  bool get isRejected => kycStatus == 'failed';
  bool get isNotSubmitted => kycStatus == 'not_submitted';

  bool hasFeature(String feature) => features.contains(feature);
}

/// اطلاعات سطح بعدی برای ارتقا.
class KycNextLevel {
  final int level;
  final String name;
  final List<String> requiredDocs;
  final String description;

  KycNextLevel({
    required this.level,
    required this.name,
    required this.requiredDocs,
    required this.description,
  });

  factory KycNextLevel.fromJson(Map<String, dynamic> json) {
    return KycNextLevel(
      level: json['level'] as int? ?? 1,
      name: json['name'] as String? ?? '',
      requiredDocs: (json['required_docs'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      description: json['description'] as String? ?? '',
    );
  }
}

/// وضعیت کامل KYC کاربر — شامل badge + آخرین ارسال + سطح بعدی.
class KycStatus {
  final int currentLevel;
  final KycBadge badge;
  final String kycStatus;
  final KycSubmission? latestSubmission;
  final bool isRejected;
  final String? rejectionReason;
  final KycNextLevel? nextLevel;
  final List<String> availableFeatures;

  KycStatus({
    required this.currentLevel,
    required this.badge,
    required this.kycStatus,
    this.latestSubmission,
    required this.isRejected,
    this.rejectionReason,
    this.nextLevel,
    required this.availableFeatures,
  });

  factory KycStatus.fromJson(Map<String, dynamic> json) {
    return KycStatus(
      currentLevel: json['current_level'] as int? ?? 1,
      badge: KycBadge.fromJson(json['badge'] as Map<String, dynamic>? ?? {}),
      kycStatus: json['kyc_status'] as String? ?? 'not_submitted',
      latestSubmission: json['latest_submission'] != null
          ? KycSubmission.fromJson(
              json['latest_submission'] as Map<String, dynamic>)
          : null,
      isRejected: json['is_rejected'] as bool? ?? false,
      rejectionReason: json['rejection_reason'] as String?,
      nextLevel: json['next_level'] != null
          ? KycNextLevel.fromJson(json['next_level'] as Map<String, dynamic>)
          : null,
      availableFeatures: (json['available_features'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}

/// آخرین ارسال KYC کاربر.
class KycSubmission {
  final int id;
  final String status; // pending | approved | rejected
  final String? message;
  final String? submittedAt;
  final String? reviewedAt;

  KycSubmission({
    required this.id,
    required this.status,
    this.message,
    this.submittedAt,
    this.reviewedAt,
  });

  factory KycSubmission.fromJson(Map<String, dynamic> json) {
    return KycSubmission(
      id: json['id'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      message: json['message'] as String?,
      submittedAt: json['submitted_at'] as String?,
      reviewedAt: json['reviewed_at'] as String?,
    );
  }
}
