import 'package:flutter/material.dart';

class TravelServiceDefinition {
  final String key;
  final String displayName;
  final String description;
  final String iconKey;
  final Color accentColor;
  final List<String> capabilities;
  final List<TravelSearchField> searchFields;
  final Map<String, dynamic> resultSchema;

  const TravelServiceDefinition({
    required this.key,
    required this.displayName,
    required this.description,
    required this.iconKey,
    required this.accentColor,
    required this.capabilities,
    required this.searchFields,
    required this.resultSchema,
  });

  factory TravelServiceDefinition.fromJson(Map<String, dynamic> json) {
    final rawFields = json['search_schema'] as List? ?? const [];
    final rawCapabilities = json['capabilities'] as List? ?? const [];

    return TravelServiceDefinition(
      key: json['key']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      iconKey: json['icon_key']?.toString() ?? 'travel',
      accentColor: travelColor(json['accent_color']?.toString()),
      capabilities: rawCapabilities.map((item) => item.toString()).toList(),
      searchFields: rawFields
          .whereType<Map>()
          .map(
            (item) =>
                TravelSearchField.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      resultSchema: travelMap(json['result_schema']),
    );
  }

  Map<String, dynamic> get presentation =>
      travelMap(resultSchema['presentation']);

  String get searchLayout =>
      presentation['search_layout']?.toString() ??
      resultSchema['search_layout']?.toString() ??
      (key == 'flight'
          ? 'flight'
          : key == 'esim'
          ? 'destination'
          : 'form');

  String get resultLayout =>
      resultSchema['layout']?.toString() ??
      (key == 'flight'
          ? 'flight_cards'
          : key == 'esim'
          ? 'esim_packages'
          : 'offer_cards');

  List<TravelContentItem> content(String key) {
    final raw = presentation[key] as List? ?? const [];
    return raw
        .whereType<Map>()
        .map(
          (item) => TravelContentItem.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  String copy(String key, String fallback) =>
      presentation[key]?.toString().trim().isNotEmpty == true
      ? presentation[key].toString()
      : fallback;

  IconData get icon => switch (iconKey) {
    'hotel' => Icons.hotel_rounded,
    'flight' => Icons.flight_rounded,
    'sim' || 'esim' => Icons.sim_card_rounded,
    'insurance' => Icons.health_and_safety_rounded,
    'transfer' => Icons.airport_shuttle_rounded,
    'tour' => Icons.explore_rounded,
    _ => Icons.travel_explore_rounded,
  };
}

class TravelSearchField {
  final String key;
  final String type;
  final String label;
  final String hint;
  final bool required;
  final dynamic defaultValue;
  final dynamic min;
  final dynamic max;
  final List<TravelFieldOption> options;

  const TravelSearchField({
    required this.key,
    required this.type,
    required this.label,
    required this.hint,
    required this.required,
    required this.defaultValue,
    required this.min,
    required this.max,
    required this.options,
  });

  factory TravelSearchField.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List? ?? const [];

    return TravelSearchField(
      key: json['key']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      label: json['label']?.toString() ?? '',
      hint: json['hint']?.toString() ?? '',
      required: json['required'] == true,
      defaultValue: json['default'],
      min: json['min'],
      max: json['max'],
      options: rawOptions
          .whereType<Map>()
          .map(
            (item) =>
                TravelFieldOption.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }
}

class TravelFieldOption {
  final String value;
  final String label;

  const TravelFieldOption({required this.value, required this.label});

  factory TravelFieldOption.fromJson(Map<String, dynamic> json) {
    return TravelFieldOption(
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}

class TravelOffer {
  final String id;
  final String service;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String badge;
  final double totalAmount;
  final String currency;
  final List<String> highlights;
  final Map<String, dynamic> attributes;
  final Map<String, dynamic> policies;
  final List<TravelPriceLine> priceLines;
  final List<TravelAction> actions;
  final String bookingMode;
  final DateTime? expiresAt;

  const TravelOffer({
    required this.id,
    required this.service,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.badge,
    required this.totalAmount,
    required this.currency,
    required this.highlights,
    required this.attributes,
    required this.policies,
    required this.priceLines,
    required this.actions,
    required this.bookingMode,
    required this.expiresAt,
  });

  factory TravelOffer.fromJson(Map<String, dynamic> json, String service) {
    final product = travelMap(json['product']);
    final pricing = travelMap(json['pricing']);
    final rawHighlights = json['highlights'] as List? ?? const [];
    final rawLines =
        pricing['lines'] as List? ??
        pricing['components'] as List? ??
        json['price_lines'] as List? ??
        const [];
    final rawActions = json['actions'] as List? ?? const [];

    return TravelOffer(
      id: (json['id'] ?? json['offer_id'])?.toString() ?? '',
      service: service,
      title: (json['title'] ?? product['name'])?.toString() ?? '',
      subtitle: (json['subtitle'] ?? product['description'])?.toString() ?? '',
      imageUrl: (json['image_url'] ?? product['image_url'])?.toString() ?? '',
      badge: json['badge']?.toString() ?? '',
      totalAmount:
          double.tryParse(
            (pricing['total_amount'] ??
                        pricing['amount'] ??
                        json['total_amount'])
                    ?.toString() ??
                '0',
          ) ??
          0,
      currency: (pricing['currency'] ?? json['currency'])?.toString() ?? 'IRR',
      highlights: rawHighlights.map((item) => item.toString()).toList(),
      attributes: travelMap(json['attributes']),
      policies: travelMap(json['policies']),
      priceLines: rawLines
          .whereType<Map>()
          .map(
            (item) => TravelPriceLine.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      actions: rawActions
          .whereType<Map>()
          .map((item) => TravelAction.fromJson(Map<String, dynamic>.from(item)))
          .where((action) => action.url.isNotEmpty)
          .toList(),
      bookingMode: json['booking_mode']?.toString() ?? '',
      expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? ''),
    );
  }

  TravelAction? action(String key) {
    for (final action in actions) {
      if (action.key == key) return action;
    }
    return null;
  }
}

class TravelPriceLine {
  final String label;
  final double amount;
  final String currency;

  const TravelPriceLine({
    required this.label,
    required this.amount,
    required this.currency,
  });

  factory TravelPriceLine.fromJson(Map<String, dynamic> json) {
    return TravelPriceLine(
      label: json['label']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      currency: json['currency']?.toString() ?? '',
    );
  }
}

class TravelAction {
  final String key;
  final String label;
  final String method;
  final String url;
  final bool requiresAuth;
  final Map<String, dynamic> payload;

  const TravelAction({
    required this.key,
    required this.label,
    required this.method,
    required this.url,
    required this.requiresAuth,
    required this.payload,
  });

  factory TravelAction.fromJson(Map<String, dynamic> json) {
    return TravelAction(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      method: json['method']?.toString().toUpperCase() ?? 'POST',
      url: json['url']?.toString() ?? '',
      requiresAuth: json['requires_auth'] != false,
      payload: travelMap(json['payload']),
    );
  }
}

class TravelContentItem {
  final String key;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String badge;
  final String value;
  final Map<String, dynamic> data;

  const TravelContentItem({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.badge,
    required this.value,
    required this.data,
  });

  factory TravelContentItem.fromJson(Map<String, dynamic> json) {
    return TravelContentItem(
      key: json['key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      badge: json['badge']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      data: travelMap(json['data']),
    );
  }
}

Map<String, dynamic> travelMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

Color travelColor(String? value) {
  final hex = value?.replaceFirst('#', '');
  if (hex == null || (hex.length != 6 && hex.length != 8)) {
    return const Color(0xFFD4AF37);
  }
  final normalized = hex.length == 6 ? 'FF$hex' : hex;
  return Color(int.parse(normalized, radix: 16));
}
