import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';

import '../controller/travel_controller.dart';
import '../model/travel_model.dart';
import 'widgets/travel_theme.dart';

class TravelCheckoutScreen extends StatelessWidget {
  final TravelServiceDefinition service;
  final TravelOffer offer;
  final TravelAction action;

  const TravelCheckoutScreen({
    super.key,
    required this.service,
    required this.offer,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final travel = Get.find<TravelController>();
    final home = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : null;
    final wallet =
        home?.walletsList.firstWhereOrNull((item) => item.isDefault == true) ??
        home?.walletsList.firstOrNull;
    final balance = wallet?.formattedBalance ?? '—';
    final symbol = wallet?.symbol ?? '';

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: TravelTheme.background,
        appBar: const CommonDefaultAppBar(
          backgroundColor: TravelTheme.background,
          surfaceTintColor: Colors.transparent,
        ),
        body: Obx(
          () => Column(
            children: [
              const CommonAppBar(title: 'تایید پرداخت'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  children: [
                    _StepHeader(),
                    const SizedBox(height: 22),
                    _OrderSummary(service: service, offer: offer),
                    const SizedBox(height: 18),
                    _WalletSummary(balance: balance, symbol: symbol),
                    if (travel.errorMessage.value.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        travel.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: TravelTheme.danger),
                      ),
                    ],
                    const SizedBox(height: 20),
                    CommonButton(
                      width: double.infinity,
                      height: 58,
                      borderRadius: 999,
                      text: action.label.isNotEmpty
                          ? action.label
                          : 'تایید و پرداخت',
                      isLoading: travel.isActionLoading.value,
                      backgroundColor: TravelTheme.gold,
                      textColor: TravelTheme.navy,
                      onPressed: () async {
                        final result = await travel.executeAction(action);
                        if (result == null) return;
                        Get.back(result: result);
                        Get.snackbar(
                          'درخواست ثبت شد',
                          'وضعیت نهایی سفارش از سرور دریافت و در سفارش‌ها نمایش داده می‌شود.',
                          backgroundColor: TravelTheme.navy,
                          colorText: Colors.white,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: TravelTheme.gold,
                          size: 18,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'پرداخت امن و رمزنگاری‌شده',
                          style: TextStyle(
                            color: TravelTheme.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _Step(number: '۱', label: 'انتخاب سرویس'),
        _Step(number: '۲', label: 'تایید اطلاعات'),
        _Step(number: '۳', label: 'پرداخت نهایی', active: true),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String label;
  final bool active;

  const _Step({required this.number, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? TravelTheme.goldSoft : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? TravelTheme.gold : TravelTheme.line,
            ),
          ),
          child: Text(number),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF745C00) : TravelTheme.muted,
            fontSize: 10,
            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final TravelServiceDefinition service;
  final TravelOffer offer;

  const _OrderSummary({required this.service, required this.offer});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'خلاصه سفارش',
            style: TextStyle(
              color: TravelTheme.navy,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TravelTheme.field,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: TravelTheme.navy,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(service.icon, color: Colors.white),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.title,
                        style: const TextStyle(
                          color: TravelTheme.navy,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        offer.subtitle,
                        style: const TextStyle(
                          color: TravelTheme.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...offer.priceLines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(child: Text(line.label)),
                  Text(
                    '${NumberFormat('#,###').format(line.amount)} ${line.currency.isEmpty ? offer.currency : line.currency}',
                    textDirection: ui.TextDirection.ltr,
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: TravelTheme.line),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'مبلغ قابل پرداخت',
                  style: TextStyle(
                    color: TravelTheme.navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${NumberFormat('#,###').format(offer.totalAmount)} ${offer.currency}',
                textDirection: ui.TextDirection.ltr,
                style: const TextStyle(
                  color: Color(0xFF806600),
                  fontSize: 21,
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

class _WalletSummary extends StatelessWidget {
  final String balance;
  final String symbol;

  const _WalletSummary({required this.balance, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TravelTheme.navy, Color(0xFF273449)],
        ),
        borderRadius: TravelTheme.cardRadius,
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: TravelTheme.goldSoft,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'موجودی کیف پول شما',
                  style: TextStyle(color: Color(0xFFCBD5E1)),
                ),
                Text(
                  '$balance $symbol',
                  textDirection: ui.TextDirection.ltr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
