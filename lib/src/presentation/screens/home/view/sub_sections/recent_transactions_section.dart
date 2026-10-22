import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/helper/jalali_date_helper.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/responsive.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/drop_down/recent_transaction_details.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/section_header.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/model/transactions_model.dart';
import 'package:ecardo_user/src/presentation/widgets/empty_view.dart';

/// Semantic cluster categories for human-friendly date grouping.
enum _DateCluster {
  today,
  yesterday,
  thisWeek,
  past,
}

/// Helper model representing a cluster of transactions sharing a date tier.
class _GroupedTransactions {
  final _DateCluster cluster;
  final String title;
  final List<Transactions> transactions;

  const _GroupedTransactions({
    required this.cluster,
    required this.title,
    required this.transactions,
  });
}

/// Modernized Neo-Fintech Recent Transactions component for eCardo.
///
/// Features:
/// - Smart Date Clustering: groups transactions by "Today", "Yesterday",
///   "This Week", and "Past" using accurate Shamsi/Jalali date comparison.
/// - Distinctive Category Icons with rounded 14px containers and soft tinted
///   pastel/gradient tones based on transaction type.
/// - Explicit Financial Typography: emerald green (#10B981) credit (+) vs
///   crimson red debit (-) with tabular figures.
/// - Live Status Badges: pulsing amber indicator for pending, emerald badge
///   for success, and red alert for failed.
/// - Micro-interactions: scale compression effect and tactile haptic feedback.
/// - Full Dark Mode and RTL support conforming to fintech standards.
class RecentTransactionsSection extends StatelessWidget {
  /// Optional explicit list of transactions (used for testing or custom feeds).
  /// If null, reads dynamically from [HomeController.transactionsModel].
  final List<Transactions>? transactions;

  const RecentTransactionsSection({
    super.key,
    this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions != null) {
      return _buildContent(context, transactions!);
    }

    final HomeController? homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : null;

    if (homeController == null) {
      return _buildContent(context, const []);
    }

    return Obx(() {
      final txList =
          homeController.transactionsModel.value.data?.transactions ??
          <Transactions>[];
      return _buildContent(context, txList);
    });
  }

  Widget _buildContent(BuildContext context, List<Transactions> txList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Section Header with "See All" action
        SectionHeader(
          sectionName: l10nPick(
            context,
            en: 'Recent Transactions',
            fa: 'تراکنش‌های اخیر',
            ar: 'المعاملات الأخيرة',
            zh: '近期交易记录',
            ru: 'Недавние транзакции',
            tr: 'Son İşlemler',
          ),
          onTap: () {
            HapticFeedback.lightImpact();
            Get.toNamed(BaseRoute.transactions);
          },
        ),
        const SizedBox(height: 12),

        // 2. Content or Empty View
        if (txList.isEmpty)
          EmptyView(
            icon: Icons.receipt_long_outlined,
            title: l10nPick(
              context,
              en: 'No transactions yet',
              fa: 'هنوز تراکنشی ندارید',
              ar: 'لا توجد معاملات بعد',
              zh: '暂无交易记录',
              ru: 'Пока нет транзакций',
              tr: 'Henüz işlem yok',
            ),
            subtitle: l10nPick(
              context,
              en: 'Make your first deposit or transfer and it will show up here.',
              fa: 'اولین واریز یا انتقال خود را انجام دهید تا تاریخچه اینجا نمایش داده شود.',
              ar: 'قم بأول إيداع أو تحويل وسيظهر هنا.',
              zh: '完成第一笔充值或转账后，记录会显示在这里。',
              ru: 'Совершите первое пополнение или перевод, и он отобразится здесь.',
              tr: 'İlk para yatırma veya transferinizi yapın, burada görünecektir.',
            ),
            ctaLabel: l10nPick(
              context,
              en: 'First transaction',
              fa: 'اولین تراکنش',
              ar: 'أول معاملة',
              zh: '立即交易',
              ru: 'Первая операция',
              tr: 'İlk İşlem',
            ),
            onCta: () => Get.toNamed(BaseRoute.transfer),
          )
        else
          _buildGroupedCardContainer(context, txList),
      ],
    );
  }

  /// Luxury grouped card container with smart date clustering.
  Widget _buildGroupedCardContainer(
    BuildContext context,
    List<Transactions> txList,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Show up to 6 recent transactions on the dashboard stream
    final displayItems = txList.take(6).toList();
    final groups = _clusterTransactions(context, displayItems);

    final children = <Widget>[];

    for (int gIdx = 0; gIdx < groups.length; gIdx++) {
      final group = groups[gIdx];
      children.add(
        _buildGroupHeader(
          context,
          title: group.title,
          count: group.transactions.length,
          isFirst: gIdx == 0,
          isDark: isDark,
        ),
      );

      for (int tIdx = 0; tIdx < group.transactions.length; tIdx++) {
        final tx = group.transactions[tIdx];
        final isLastInGroup = tIdx == group.transactions.length - 1;
        final isLastOverall = gIdx == groups.length - 1 && isLastInGroup;

        children.add(
          _TransactionRowItem(
            transaction: tx,
            onTap: () {
              Get.bottomSheet(
                RecentTransactionDetails(transaction: tx),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              );
            },
          ),
        );

        if (!isLastOverall && !isLastInGroup) {
          children.add(
            Divider(
              height: 1,
              thickness: 0.8,
              indent: 68.0,
              endIndent: 16.0,
              color: isDark
                  ? AppColors.darkDivider
                  : Colors.grey.withValues(alpha: 0.12),
            ),
          );
        }
      }

      if (gIdx < groups.length - 1) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              height: 12.0,
              thickness: 0.8,
              color: isDark
                  ? AppColors.darkDivider
                  : Colors.grey.withValues(alpha: 0.08),
            ),
          ),
        );
      }
    }

    children.add(const SizedBox(height: 6.0));

    return Container(
      margin: EdgeInsetsDirectional.symmetric(
        horizontal: Responsive.pagePadding(context),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightOutlineVariant,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  /// Clean group divider with date label in muted secondary text.
  Widget _buildGroupHeader(
    BuildContext context, {
    required String title,
    required int count,
    required bool isFirst,
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 16.0,
        end: 16.0,
        top: isFirst ? 14.0 : 10.0,
        bottom: 8.0,
      ),
      child: Row(
        children: [
          Container(
            width: 6.0,
            height: 6.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
            ),
          ),
          const SizedBox(width: 8.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Container(
              height: 0.8,
              color: isDark
                  ? AppColors.darkDivider
                  : AppColors.lightDivider.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 10.0,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Date clustering logic comparing timestamps with Asia/Tehran and Gregorian dates.
  static _DateCluster _resolveCluster(String? rawCreatedAt) {
    if (rawCreatedAt == null || rawCreatedAt.trim().isEmpty) {
      return _DateCluster.past;
    }
    final dt = JalaliDateHelper.tryParse(rawCreatedAt);
    if (dt == null) return _DateCluster.past;

    final nowUtc = DateTime.now().toUtc();
    final tehranNow = nowUtc.add(const Duration(hours: 3, minutes: 30));
    final txUtc = dt.isUtc ? dt : dt.toUtc();
    final tehranTx = txUtc.add(const Duration(hours: 3, minutes: 30));

    final today = DateTime(tehranNow.year, tehranNow.month, tehranNow.day);
    final txDay = DateTime(tehranTx.year, tehranTx.month, tehranTx.day);
    final diff = today.difference(txDay).inDays;

    if (diff <= 0) return _DateCluster.today;
    if (diff == 1) return _DateCluster.yesterday;
    if (diff <= 7) return _DateCluster.thisWeek;
    return _DateCluster.past;
  }

  /// Groups transactions preserving original chronological stream ordering.
  static List<_GroupedTransactions> _clusterTransactions(
    BuildContext context,
    List<Transactions> items,
  ) {
    final Map<_DateCluster, List<Transactions>> map = {};
    for (final tx in items) {
      final c = _resolveCluster(tx.createdAt);
      map.putIfAbsent(c, () => []).add(tx);
    }

    final List<_GroupedTransactions> result = [];
    for (final c in _DateCluster.values) {
      if (map.containsKey(c) && map[c]!.isNotEmpty) {
        result.add(_GroupedTransactions(
          cluster: c,
          title: _getClusterTitle(context, c),
          transactions: map[c]!,
        ));
      }
    }
    return result;
  }

  static String _getClusterTitle(BuildContext context, _DateCluster cluster) {
    switch (cluster) {
      case _DateCluster.today:
        return l10nPick(
          context,
          en: 'Today',
          fa: 'امروز',
          ar: 'اليوم',
          zh: '今天',
          ru: 'Сегодня',
          tr: 'Bugün',
        );
      case _DateCluster.yesterday:
        return l10nPick(
          context,
          en: 'Yesterday',
          fa: 'دیروز',
          ar: 'أمس',
          zh: '昨天',
          ru: 'Вчера',
          tr: 'Dün',
        );
      case _DateCluster.thisWeek:
        return l10nPick(
          context,
          en: 'This Week',
          fa: 'این هفته',
          ar: 'هذا الأسبوع',
          zh: '本周',
          ru: 'На этой неделе',
          tr: 'Bu Hafta',
        );
      case _DateCluster.past:
        return l10nPick(
          context,
          en: 'Past',
          fa: 'گذشته',
          ar: 'السابق',
          zh: '过去',
          ru: 'Ранее',
          tr: 'Geçmiş',
        );
    }
  }
}

/// Single transaction row item with tactile micro-interaction.
class _TransactionRowItem extends StatelessWidget {
  final Transactions transaction;
  final VoidCallback onTap;

  const _TransactionRowItem({
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visual = _getVisual(context, transaction.type);
    final isPlus = transaction.isPlus == true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _BouncingCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 16.0,
        ),
        child: Row(
          children: [
            // 1. Sleek category icon container with rounded 14px
            _buildCategoryIcon(visual, isDark, isPlus),
            const SizedBox(width: 12.0),

            // 2. Title and formatted date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _resolveTitle(context, visual.title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w800,
                      fontSize: 14.0,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    JalaliDateHelper.format(transaction.createdAt),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontSize: 11.5,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),

            // 3. Amount and live status badge stacked on the right
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAmountText(isPlus, isDark),
                  const SizedBox(height: 4.0),
                  _buildStatusBadge(context, transaction, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _resolveTitle(BuildContext context, String fallback) {
    final desc = transaction.description?.trim();
    if (desc != null && desc.isNotEmpty && desc != transaction.type) {
      return desc;
    }
    return fallback;
  }

  Widget _buildCategoryIcon(_TxVisual visual, bool isDark, bool isPlus) {
    final iconBg = isDark
        ? visual.iconColor.withValues(alpha: 0.20)
        : visual.bgColor;
    final borderColor = visual.iconColor.withValues(alpha: isDark ? 0.35 : 0.20);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44.0,
          height: 44.0,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: borderColor,
              width: 0.8,
            ),
          ),
          child: Icon(
            visual.icon,
            color: visual.iconColor,
            size: 22.0,
          ),
        ),
        // Mini direction indicator badge
        PositionedDirectional(
          bottom: -2,
          end: -2,
          child: Container(
            width: 16.0,
            height: 16.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPlus ? AppColors.success : AppColors.error,
              border: Border.all(
                color: isDark ? AppColors.darkCard : AppColors.white,
                width: 1.6,
              ),
            ),
            child: Icon(
              isPlus ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              size: 10.0,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountText(bool isPlus, bool isDark) {
    final prefix = isPlus ? '+' : '-';
    final isCrypto = transaction.isCrypto == true;
    final symbol = transaction.trxCurrencySymbol ?? r'$';
    final code = transaction.trxCurrencyCode ?? '';
    final amountVal = transaction.amount ?? '0.00';

    String cleanAmount = amountVal;
    final parsed = double.tryParse(amountVal.replaceAll(',', ''));
    if (parsed != null) {
      final decimals = DynamicDecimalsHelper().getDynamicDecimals(
        currencyCode: code,
        siteCurrencyCode: 'USD',
        siteCurrencyDecimals: '2',
        isCrypto: isCrypto,
      );
      if (decimals == 0) {
        final intVal = parsed.toInt();
        cleanAmount = intVal.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
      } else {
        cleanAmount = parsed.toStringAsFixed(decimals).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
      }
    }

    final Color amountColor = isPlus
        ? AppColors.success
        : (isDark ? const Color(0xFFF87171) : AppColors.error);

    final formattedText = isCrypto
        ? '$prefix$cleanAmount $code'
        : '$prefix$symbol $cleanAmount';

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(
        formattedText,
        style: TextStyle(
          letterSpacing: 0.1,
          fontWeight: FontWeight.w900,
          fontSize: 14.5,
          fontFeatures: const [
            FontFeature.tabularFigures(),
          ],
          color: amountColor,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    Transactions tx,
    bool isDark,
  ) {
    if (tx.isPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.warning.withValues(alpha: 0.20)
              : AppColors.warningContainer,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.35),
            width: 0.6,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _PulsingDot(color: AppColors.warning),
            const SizedBox(width: 4.0),
            Text(
              l10nPick(
                context,
                en: 'Pending',
                fa: 'در انتظار',
                ar: 'قيد الانتظار',
                zh: '处理中',
                ru: 'В обработке',
                tr: 'Beklemede',
              ),
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.warning : AppColors.darkGray,
              ),
            ),
          ],
        ),
      );
    } else if (tx.isFailed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.error.withValues(alpha: 0.20)
              : AppColors.errorContainer,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.35),
            width: 0.6,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cancel_rounded,
              size: 10.0,
              color: AppColors.error,
            ),
            const SizedBox(width: 3.0),
            Text(
              l10nPick(
                context,
                en: 'Failed',
                fa: 'ناموفق',
                ar: 'فشل',
                zh: '失败',
                ru: 'Не удалось',
                tr: 'Başarısız',
              ),
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      );
    }

    // Success / Completed
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.success.withValues(alpha: 0.20)
            : AppColors.successContainer,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.35),
          width: 0.6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_rounded,
            size: 10.0,
            color: AppColors.success,
          ),
          const SizedBox(width: 3.0),
          Text(
            l10nPick(
              context,
              en: 'Success',
              fa: 'موفق',
              ar: 'ناجح',
              zh: '成功',
              ru: 'Успешно',
              tr: 'Başarılı',
            ),
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.mainSoftBlue : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  static _TxVisual _getVisual(BuildContext context, String? type) {
    switch (type?.toLowerCase()) {
      case 'deposit':
      case 'add_money':
      case 'manual_deposit':
        return _TxVisual(
          title: l10nPick(
            context,
            en: 'Deposit to Wallet',
            fa: 'واریز به کیف‌پول',
            ar: 'إيداع في المحفظة',
            zh: '充值到钱包',
            ru: 'Пополнение кошелька',
            tr: 'Cüzdana Para Yatırma',
          ),
          icon: Icons.south_west_rounded,
          iconColor: const Color(0xFF10B981),
          bgColor: const Color(0xFFECFDF5),
        );
      case 'virtual_card':
      case 'credit':
      case 'debit':
        return _TxVisual(
          title: l10nPick(
            context,
            en: 'Virtual Card Payment',
            fa: 'پرداخت با کارت اعتباری',
            ar: 'دفع بالبطاقة الافتراضية',
            zh: '虚拟卡支付',
            ru: 'Оплата виртуальной картой',
            tr: 'Sanal Kart Ödemesi',
          ),
          icon: Icons.credit_card_rounded,
          iconColor: const Color(0xFF8B5CF6),
          bgColor: const Color(0xFFF3E8FF),
        );
      case 'exchange':
        return _TxVisual(
          title: l10nPick(
            context,
            en: 'Currency Exchange',
            fa: 'تبدیل ارز آنی',
            ar: 'صرف العملات',
            zh: '即时货币兑换',
            ru: 'Обмен валюты',
            tr: 'Döviz Dönüşümü',
          ),
          icon: Icons.currency_exchange_rounded,
          iconColor: const Color(0xFF0284C7),
          bgColor: const Color(0xFFE0F2FE),
        );
      case 'transfer':
      case 'send_money':
        return _TxVisual(
          title: l10nPick(
            context,
            en: 'Money Transfer',
            fa: 'انتقال وجه بین‌الملل',
            ar: 'تحويل أموال',
            zh: '跨境转账',
            ru: 'Перевод средств',
            tr: 'Para Transferi',
          ),
          icon: Icons.north_east_rounded,
          iconColor: const Color(0xFF7445FF),
          bgColor: const Color(0xFFF0ECFF),
        );
      case 'receive_money':
      case 'cash_received':
        return _TxVisual(
          title: l10nPick(
            context,
            en: 'Received Money',
            fa: 'دریافت وجه',
            ar: 'استلام أموال',
            zh: '收到款项',
            ru: 'Получение средств',
            tr: 'Para Alma',
          ),
          icon: Icons.call_received_rounded,
          iconColor: const Color(0xFF00BFA6),
          bgColor: const Color(0xFFE0F8F5),
        );
      case 'withdraw':
      case 'cash_out':
      case 'withdraw_auto':
        return _TxVisual(
          title: l10nPick(
            context,
            en: 'Withdrawal',
            fa: 'برداشت وجه',
            ar: 'سحب أموال',
            zh: '账户提现',
            ru: 'Вывод средств',
            tr: 'Para Çekme',
          ),
          icon: Icons.arrow_upward_rounded,
          iconColor: const Color(0xFFE11D48),
          bgColor: const Color(0xFFFFE4E6),
        );
      case 'payment':
      case 'make_payment':
      case 'pay_bill':
        return _TxVisual(
          title: l10nPick(
            context,
            en: 'Payment',
            fa: 'پرداخت صورتحساب',
            ar: 'دفع فاتورة',
            zh: '账单支付',
            ru: 'Оплата счета',
            tr: 'Ödeme',
          ),
          icon: Icons.shopping_bag_outlined,
          iconColor: const Color(0xFFEA580C),
          bgColor: const Color(0xFFFFEDD5),
        );
      case 'gift_card':
      case 'gift_code':
      case 'gift_redeemed':
        return _TxVisual(
          title: l10nPick(
            context,
            en: 'Gift Card',
            fa: 'گیفت کارت',
            ar: 'بطاقة هدايا',
            zh: '礼品卡',
            ru: 'Поداрочная карта',
            tr: 'Hediye Kartı',
          ),
          icon: Icons.card_giftcard_rounded,
          iconColor: const Color(0xFFD97706),
          bgColor: const Color(0xFFFEF3C7),
        );
      default:
        return _TxVisual(
          title: type ??
              l10nPick(
                context,
                en: 'Transaction',
                fa: 'تراکنش مالی',
                ar: 'معاملة مالية',
                zh: '财务交易',
                ru: 'Транзакция',
                tr: 'İşlem',
              ),
          icon: Icons.receipt_long_rounded,
          iconColor: const Color(0xFF64748B),
          bgColor: const Color(0xFFF1F5F9),
        );
    }
  }
}

/// Visual properties descriptor for transaction categories.
class _TxVisual {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _TxVisual({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}

/// Micro-interaction card supporting scale feedback and haptics on press.
class _BouncingCard extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const _BouncingCard({
    required this.onTap,
    required this.child,
  });

  @override
  State<_BouncingCard> createState() => _BouncingCardState();
}

class _BouncingCardState extends State<_BouncingCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Pulsing dot indicator for real-time live Pending status badges.
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 1.0;
    }
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 6.0,
        height: 6.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
        ),
      ),
    );
  }
}
