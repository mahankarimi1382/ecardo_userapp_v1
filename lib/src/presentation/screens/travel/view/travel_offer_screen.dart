import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';

import '../controller/travel_controller.dart';
import '../model/travel_model.dart';
import 'travel_checkout_screen.dart';
import 'widgets/travel_theme.dart';

class TravelOfferScreen extends StatefulWidget {
  final TravelServiceDefinition service;
  final TravelOffer initialOffer;

  const TravelOfferScreen({
    super.key,
    required this.service,
    required this.initialOffer,
  });

  @override
  State<TravelOfferScreen> createState() => _TravelOfferScreenState();
}

class _TravelOfferScreenState extends State<TravelOfferScreen> {
  late final TravelController _travel;

  @override
  void initState() {
    super.initState();
    _travel = Get.find<TravelController>();
    _travel.selectedOffer.value = widget.initialOffer;
    _travel.loadOffer(widget.service, widget.initialOffer);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: TravelTheme.background,
        appBar: const CommonDefaultAppBar(
          backgroundColor: TravelTheme.background,
          surfaceTintColor: Colors.transparent,
        ),
        body: Obx(() {
          final offer = _travel.selectedOffer.value ?? widget.initialOffer;
          return Stack(
            children: [
              Column(
                children: [
                  CommonAppBar(title: 'جزئیات ${widget.service.displayName}'),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                      children: [
                        _SummaryCard(offer: offer, service: widget.service),
                        const SizedBox(height: 16),
                        if (offer.highlights.isNotEmpty)
                          _Highlights(items: offer.highlights),
                        if (offer.attributes.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _Attributes(attributes: offer.attributes),
                        ],
                        const SizedBox(height: 16),
                        _Pricing(offer: offer),
                        if (_travel.errorMessage.value.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            _travel.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: TravelTheme.danger),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _BottomAction(offer: offer, service: widget.service),
                ],
              ),
              if (_travel.isOfferLoading.value)
                const Positioned.fill(child: CommonLoading(isColorShow: true)),
            ],
          );
        }),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final TravelOffer offer;
  final TravelServiceDefinition service;

  const _SummaryCard({required this.offer, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: TravelTheme.cardRadius,
        boxShadow: TravelTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: TravelTheme.field,
                  shape: BoxShape.circle,
                ),
                child: Icon(service.icon, color: TravelTheme.navy, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.title,
                      style: const TextStyle(
                        color: TravelTheme.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      offer.subtitle,
                      style: const TextStyle(color: TravelTheme.muted),
                    ),
                  ],
                ),
              ),
              if (offer.badge.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: TravelTheme.goldSoft,
                    borderRadius: TravelTheme.pillRadius,
                  ),
                  child: Text(
                    offer.badge,
                    style: const TextStyle(
                      color: Color(0xFF745C00),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          if (service.key == 'flight') ...[
            const SizedBox(height: 26),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _LargeValue(
                  value:
                      offer.attributes['departure_time']?.toString() ?? '--:--',
                  label:
                      offer.attributes['origin']?.toString() ??
                      offer.attributes['departure_airport']?.toString() ??
                      'مبدا',
                ),
                const Icon(
                  Icons.flight_rounded,
                  color: TravelTheme.gold,
                  size: 34,
                ),
                _LargeValue(
                  value:
                      offer.attributes['arrival_time']?.toString() ?? '--:--',
                  label:
                      offer.attributes['destination']?.toString() ??
                      offer.attributes['arrival_airport']?.toString() ??
                      'مقصد',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LargeValue extends StatelessWidget {
  final String value;
  final String label;

  const _LargeValue({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          textDirection: TextDirection.ltr,
          style: const TextStyle(
            color: TravelTheme.navy,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          textDirection: TextDirection.ltr,
          style: const TextStyle(color: TravelTheme.muted),
        ),
      ],
    );
  }
}

class _Highlights extends StatelessWidget {
  final List<String> items;

  const _Highlights({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: TravelTheme.line),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: TravelTheme.gold,
                    size: 18,
                  ),
                  const SizedBox(width: 7),
                  Text(item),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Attributes extends StatelessWidget {
  final Map<String, dynamic> attributes;

  const _Attributes({required this.attributes});

  @override
  Widget build(BuildContext context) {
    final entries = attributes.entries
        .where(
          (entry) =>
              entry.value is String ||
              entry.value is num ||
              entry.value is bool,
        )
        .take(8);
    if (entries.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: TravelTheme.cardRadius,
      ),
      child: Column(
        children: entries
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key.replaceAll('_', ' '),
                        style: const TextStyle(color: TravelTheme.muted),
                      ),
                    ),
                    Text(
                      entry.value.toString(),
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        color: TravelTheme.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Pricing extends StatelessWidget {
  final TravelOffer offer;

  const _Pricing({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: TravelTheme.navy,
        borderRadius: TravelTheme.cardRadius,
        boxShadow: TravelTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'جزئیات قیمت',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          ...offer.priceLines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      line.label,
                      style: const TextStyle(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                  Text(
                    '${NumberFormat('#,###').format(line.amount)} ${line.currency.isEmpty ? offer.currency : line.currency}',
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          if (offer.priceLines.isNotEmpty)
            const Divider(color: Color(0xFF475569)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'مبلغ کل قابل پرداخت',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${NumberFormat('#,###').format(offer.totalAmount)} ${offer.currency}',
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  color: TravelTheme.goldSoft,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final TravelOffer offer;
  final TravelServiceDefinition service;

  const _BottomAction({required this.offer, required this.service});

  @override
  Widget build(BuildContext context) {
    final action =
        offer.action('checkout') ??
        offer.action('book') ??
        offer.action('buy') ??
        offer.actions.firstOrNull;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.paddingOf(context).bottom + 14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: TravelTheme.line)),
      ),
      child: CommonButton(
        width: double.infinity,
        height: 56,
        borderRadius: 999,
        text: action?.label.isNotEmpty == true
            ? action!.label
            : 'این پیشنهاد فعلاً قابل خرید نیست',
        backgroundColor: action == null ? TravelTheme.muted : TravelTheme.navy,
        onPressed: action == null
            ? null
            : () => Get.to(
                () => TravelCheckoutScreen(
                  service: service,
                  offer: offer,
                  action: action,
                ),
              ),
      ),
    );
  }
}
