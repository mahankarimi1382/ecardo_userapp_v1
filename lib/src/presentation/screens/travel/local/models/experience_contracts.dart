// DATA: REAL | MOCK | PLACEHOLDER | NOT-IMPLEMENTED
// Contract specification for eCardo Travel Engine Experience Domain
// Supports Boat, Dining, and Local sub-services under schema_version: 1.0

import 'package:flutter/foundation.dart';

/// The domain sub-type for experience offerings.
enum ExperienceDomain {
  boat,
  dining,
  local;

  String get wireName {
    switch (this) {
      case ExperienceDomain.boat:
        return 'boat';
      case ExperienceDomain.dining:
        return 'dining';
      case ExperienceDomain.local:
        return 'local';
    }
  }

  static ExperienceDomain fromWireName(String name) {
    switch (name.toLowerCase()) {
      case 'boat':
      case 'marine':
        return ExperienceDomain.boat;
      case 'dining':
      case 'restaurant':
      case 'food':
        return ExperienceDomain.dining;
      case 'local':
      case 'activity':
      case 'tour_activity':
      default:
        return ExperienceDomain.local;
    }
  }
}

/// Explicit 12-state UI machine mandatory across all subservices.
enum ExperienceServiceState {
  defaultState,
  loading,
  skeleton,
  empty,
  partial,
  success,
  error,
  validationError,
  offline,
  processing,
  completed,
  cancelled;

  bool get isLoading => this == loading || this == skeleton;
  bool get isOffline => this == offline;
  bool get hasError => this == error || this == validationError;
  bool get isTerminal => this == completed || this == cancelled;
}

/// Unit of pricing applied to experience offerings.
enum ExperiencePricingType {
  perPerson,
  perGroup,
  perHour,
  fixedItem;

  String get wireName {
    switch (this) {
      case ExperiencePricingType.perPerson:
        return 'per_person';
      case ExperiencePricingType.perGroup:
        return 'per_group';
      case ExperiencePricingType.perHour:
        return 'per_hour';
      case ExperiencePricingType.fixedItem:
        return 'fixed_item';
    }
  }

  static ExperiencePricingType fromWireName(String? name) {
    switch (name) {
      case 'per_group':
        return ExperiencePricingType.perGroup;
      case 'per_hour':
        return ExperiencePricingType.perHour;
      case 'fixed_item':
        return ExperiencePricingType.fixedItem;
      case 'per_person':
      default:
        return ExperiencePricingType.perPerson;
    }
  }
}

/// Result of a calculated refund based on cancellation policy.
@immutable
class ExperienceRefundCalculation {
  final double originalAmount;
  final double refundableAmount;
  final double penaltyAmount;
  final String currency;
  final String refundDestinationWalletCurrency;
  final bool isFreeCancellation;
  final String policySummary;

  const ExperienceRefundCalculation({
    required this.originalAmount,
    required this.refundableAmount,
    required this.penaltyAmount,
    required this.currency,
    required this.refundDestinationWalletCurrency,
    required this.isFreeCancellation,
    required this.policySummary,
  });

  Map<String, dynamic> toJson() => {
        'original_amount': originalAmount,
        'refundable_amount': refundableAmount,
        'penalty_amount': penaltyAmount,
        'currency': currency,
        'refund_destination_wallet_currency': refundDestinationWalletCurrency,
        'is_free_cancellation': isFreeCancellation,
        'policy_summary': policySummary,
      };

  factory ExperienceRefundCalculation.fromJson(Map<String, dynamic> json) {
    return ExperienceRefundCalculation(
      originalAmount: (json['original_amount'] as num?)?.toDouble() ?? 0.0,
      refundableAmount: (json['refundable_amount'] as num?)?.toDouble() ?? 0.0,
      penaltyAmount: (json['penalty_amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      refundDestinationWalletCurrency:
          json['refund_destination_wallet_currency'] as String? ?? 'USD',
      isFreeCancellation: json['is_free_cancellation'] as bool? ?? false,
      policySummary: json['policy_summary'] as String? ?? '',
    );
  }
}

/// Structured cancellation policy for experiences.
@immutable
class ExperienceCancellationPolicy {
  final int freeCancellationHours;
  final double lateCancelPenaltyPercent;
  final bool isRefundable;
  final String policyNotes;

  const ExperienceCancellationPolicy({
    this.freeCancellationHours = 24,
    this.lateCancelPenaltyPercent = 30.0,
    this.isRefundable = true,
    this.policyNotes =
        'Full refund available up to free cancellation window. Matching currency wallet credit upon cancellation.',
  });

  ExperienceRefundCalculation calculateRefund({
    required DateTime scheduledAt,
    required double totalAmount,
    required String currency,
    DateTime? requestTime,
  }) {
    final now = requestTime ?? DateTime.now();
    final difference = scheduledAt.difference(now);
    final hoursRemaining = difference.inHours;

    if (!isRefundable || hoursRemaining < 0) {
      return ExperienceRefundCalculation(
        originalAmount: totalAmount,
        refundableAmount: 0.0,
        penaltyAmount: totalAmount,
        currency: currency,
        refundDestinationWalletCurrency: currency,
        isFreeCancellation: false,
        policySummary: 'Non-refundable after scheduled departure or service time.',
      );
    }

    if (hoursRemaining >= freeCancellationHours) {
      return ExperienceRefundCalculation(
        originalAmount: totalAmount,
        refundableAmount: totalAmount,
        penaltyAmount: 0.0,
        currency: currency,
        refundDestinationWalletCurrency: currency,
        isFreeCancellation: true,
        policySummary:
            'Free cancellation ($hoursRemaining hrs prior, threshold $freeCancellationHours hrs). 100% refund to $currency wallet.',
      );
    }

    final penalty = (totalAmount * (lateCancelPenaltyPercent / 100.0)).clamp(0.0, totalAmount);
    final refundable = (totalAmount - penalty).clamp(0.0, totalAmount);

    return ExperienceRefundCalculation(
      originalAmount: totalAmount,
      refundableAmount: refundable,
      penaltyAmount: penalty,
      currency: currency,
      refundDestinationWalletCurrency: currency,
      isFreeCancellation: false,
      policySummary:
          'Late cancellation penalty of ${lateCancelPenaltyPercent.toStringAsFixed(0)}% applied. Remaining credited to $currency wallet.',
    );
  }

  Map<String, dynamic> toJson() => {
        'free_cancellation_hours': freeCancellationHours,
        'late_cancel_penalty_percent': lateCancelPenaltyPercent,
        'is_refundable': isRefundable,
        'policy_notes': policyNotes,
      };

  factory ExperienceCancellationPolicy.fromJson(Map<String, dynamic> json) {
    return ExperienceCancellationPolicy(
      freeCancellationHours: json['free_cancellation_hours'] as int? ?? 24,
      lateCancelPenaltyPercent:
          (json['late_cancel_penalty_percent'] as num?)?.toDouble() ?? 30.0,
      isRefundable: json['is_refundable'] as bool? ?? true,
      policyNotes: json['policy_notes'] as String? ?? '',
    );
  }
}

/// Standardized search request for travel engine experience endpoints.
@immutable
class ExperienceSearchQuery {
  final String schemaVersion;
  final ExperienceDomain domain;
  final String? keyword;
  final String? city;
  final String? category;
  final DateTime? date;
  final int adults;
  final int children;
  final double? maxPrice;
  final String currency;

  const ExperienceSearchQuery({
    this.schemaVersion = '1.0',
    required this.domain,
    this.keyword,
    this.city,
    this.category,
    this.date,
    this.adults = 1,
    this.children = 0,
    this.maxPrice,
    this.currency = 'USD',
  });

  Map<String, dynamic> toJson() => {
        'schema_version': schemaVersion,
        'domain': domain.wireName,
        if (keyword != null && keyword!.isNotEmpty) 'keyword': keyword,
        if (city != null && city != 'ALL') 'city': city,
        if (category != null) 'category': category,
        if (date != null) 'date': date!.toIso8601String(),
        'adults': adults,
        'children': children,
        if (maxPrice != null) 'max_price': maxPrice,
        'currency': currency,
      };

  factory ExperienceSearchQuery.fromJson(Map<String, dynamic> json) {
    return ExperienceSearchQuery(
      schemaVersion: json['schema_version'] as String? ?? '1.0',
      domain: ExperienceDomain.fromWireName(json['domain'] as String? ?? 'local'),
      keyword: json['keyword'] as String?,
      city: json['city'] as String?,
      category: json['category'] as String?,
      date: json['date'] != null ? DateTime.tryParse(json['date'] as String) : null,
      adults: json['adults'] as int? ?? 1,
      children: json['children'] as int? ?? 0,
      maxPrice: (json['max_price'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'USD',
    );
  }
}

/// Standardized search response schema.
@immutable
class ExperienceSearchResult {
  final String schemaVersion;
  final ExperienceDomain domain;
  final int totalCount;
  final bool isDegraded;
  final String? degradedReason;
  final List<Map<String, dynamic>> items;

  const ExperienceSearchResult({
    this.schemaVersion = '1.0',
    required this.domain,
    required this.totalCount,
    this.isDegraded = false,
    this.degradedReason,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'schema_version': schemaVersion,
        'domain': domain.wireName,
        'total_count': totalCount,
        'is_degraded': isDegraded,
        if (degradedReason != null) 'degraded_reason': degradedReason,
        'items': items,
      };

  factory ExperienceSearchResult.fromJson(Map<String, dynamic> json) {
    return ExperienceSearchResult(
      schemaVersion: json['schema_version'] as String? ?? '1.0',
      domain: ExperienceDomain.fromWireName(json['domain'] as String? ?? 'local'),
      totalCount: json['total_count'] as int? ?? 0,
      isDegraded: json['is_degraded'] as bool? ?? false,
      degradedReason: json['degraded_reason'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [],
    );
  }
}
