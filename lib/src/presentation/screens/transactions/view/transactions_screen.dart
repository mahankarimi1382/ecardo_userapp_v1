import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_error_view.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/drop_down/recent_transaction_details.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/controller/transactions_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/model/transactions_model.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/view/sub_sections/bottom_sheet/transaction_filter_bottom_sheet.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/view/sub_sections/transaction_type_list.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/widgets/transaction_card.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/widgets/transaction_date_group_header.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/widgets/transaction_shimmer_skeleton.dart';
import 'package:ecardo_user/src/presentation/screens/transactions/widgets/transaction_summary_card.dart';

/// Helper model for day/date grouped transactions.
class _TransactionDateGroup {
  final String title;
  final String dateKey;
  final List<Transactions> transactions;

  _TransactionDateGroup({
    required this.title,
    required this.dateKey,
    required this.transactions,
  });
}

/// Ultra-Modernized Neo-Fintech Transactions Screen for eCardo.
///
/// Features:
/// - 4 Complete States: Shimmer loading, Error view with retry, Empty state with filter reset CTA, Content state.
/// - Activity summary hero banner via [TransactionSummaryCard] (EcardoGlassCard).
/// - Directional flow filter chips (All, Incoming, Outgoing) with tactile bounce.
/// - Categorized transaction type pills ([TransactionTypeList]).
/// - Date-grouped list view (Today, Yesterday, Jalali/Gregorian calendar dates).
/// - Rich transaction rows ([TransactionCard]) with signed colored amounts, status pills, and category avatars.
/// - Integrated filter sheet ([TransactionFilterBottomSheet]) with active filter indicators.
/// - 100% token adoption, dark mode adaptation, and RTL directionality.
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with WidgetsBindingObserver {
  final TransactionsController controller = Get.find();
  late ScrollController _scrollController;
  int _dirFilter = 0; // 0 all, 1 incoming, 2 outgoing
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    loadData();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        controller.hasMorePages.value &&
        !controller.isPageLoading.value) {
      controller.loadMoreTransactions();
    }
  }

  Future<void> loadData() async {
    try {
      setState(() {
        _hasError = false;
        _errorMessage = null;
      });
      await controller.fetchTransactions();
      final data = controller.transactionsModel.value.data;
      if (data == null && controller.transactionsModel.value.status == 'error') {
        setState(() {
          _hasError = true;
          _errorMessage = controller.transactionsModel.value.message;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
    _openDeepLinkedTransactionIfAny();
  }

  void _openDeepLinkedTransactionIfAny() {
    final args = Get.arguments;
    if (args is! Map) return;
    if (args['open_details'] != true) return;
    final id = args['transaction_id']?.toString();
    if (id == null || id.isEmpty) return;
    final list =
        controller.transactionsModel.value.data?.transactions ?? const [];
    Transactions? match;
    for (final t in list) {
      if (t.tnx?.toString() == id) {
        match = t;
        break;
      }
    }
    if (match == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Get.bottomSheet(
        RecentTransactionDetails(transaction: match!),
        isScrollControlled: true,
      );
    });
  }

  Future<void> refreshData() async {
    try {
      setState(() {
        _hasError = false;
        _errorMessage = null;
      });
      if (controller.hasActiveFilters()) {
        await controller.fetchDynamicTransactions();
      } else {
        await controller.fetchTransactions();
      }
      final data = controller.transactionsModel.value.data;
      if (data == null && controller.transactionsModel.value.status == 'error') {
        setState(() {
          _hasError = true;
          _errorMessage = controller.transactionsModel.value.message;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  bool get _hasAnyFilter => controller.hasActiveFilters() || _dirFilter != 0;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: CommonDefaultAppBar(),
      body: Obx(() {
        return Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            // Header Bar with Filter action
            CommonAppBar(
              title: localization.transactionsScreenTitle,
              rightSideWidget: _buildFilterButton(context, isDark),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Inline progress line when dynamic filters are loading
            if (controller.isTransactionsLoading.value)
              LinearProgressIndicator(
                minHeight: 2.5,
                backgroundColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                ),
              ),

            // Main Content Area
            Expanded(
              child: _buildBody(context, isDark),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterButton(BuildContext context, bool isDark) {
    return Semantics(
      button: true,
      label: l10nPick(context, en: 'Filter Transactions', fa: 'فیلتر تراکنش‌ها', ar: 'تصفية المعاملات'),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Get.bottomSheet(
            TransactionFilterBottomSheet(
              initialDirFilter: _dirFilter,
              onDirectionChanged: (val) {
                setState(() => _dirFilter = val);
              },
            ),
            isScrollControlled: true,
          );
        },
        child: Container(
          width: 44,
          height: 44,
          margin: const EdgeInsetsDirectional.only(end: AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: _hasAnyFilter
                  ? (isDark ? AppColors.mainSoftBlue : AppColors.deepBlack)
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: _hasAnyFilter ? 1.5 : 1.0,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                PngAssets.commonFilterIcon,
                width: AppSpacing.iconSm,
                height: AppSpacing.iconSm,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                excludeFromSemantics: true,
              ),
              if (_hasAnyFilter)
                PositionedDirectional(
                  top: 7,
                  end: 7,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    // 1. Shimmer Loading State
    if (controller.isLoading.value) {
      return const TransactionShimmerSkeleton();
    }

    // 2. Error View State
    if (_hasError) {
      return RefreshIndicator(
        color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
        onRefresh: () => refreshData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
          child: EcardoErrorView(
            title: l10nPick(
              context,
              en: 'Unable to Load Transactions',
              fa: 'خطا در بارگذاری تراکنش‌ها',
              ar: 'تعذر تحميل المعاملات',
            ),
            message: _errorMessage ??
                l10nPick(
                  context,
                  en: 'Could not connect to the transaction service. Please verify your connection and try again.',
                  fa: 'امکان برقراری ارتباط با سرور وجود ندارد. لطفا اتصال اینترنت خود را بررسی کرده و مجددا تلاش کنید.',
                  ar: 'تعذر الاتصال بخدمة المعاملات. يرجى التحقق من الاتصال والمحاولة مرة أخرى.',
                ),
            onRetry: () => loadData(),
            retryLabel: l10nPick(context, en: 'Try Again', fa: 'تلاش مجدد', ar: 'إعادة المحاولة'),
          ),
        ),
      );
    }

    // Filter transactions by direction
    final all = controller.transactionsModel.value.data?.transactions ?? [];
    final transactions = all.where((tx) {
      if (_dirFilter == 1) return tx.isPlus == true;
      if (_dirFilter == 2) return tx.isPlus != true;
      return true;
    }).toList();

    // 3. Empty State
    if (transactions.isEmpty) {
      return RefreshIndicator(
        color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
        onRefresh: () => refreshData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
          child: EcardoEmptyState(
            title: _hasAnyFilter
                ? l10nPick(
                    context,
                    en: 'No Matching Transactions',
                    fa: 'تراکنشی با این مشخصات یافت نشد',
                    ar: 'لم يتم العثور على معاملات مطابقة',
                  )
                : l10nPick(
                    context,
                    en: 'No Transactions Yet',
                    fa: 'هنوز تراکنشی ثبت نشده است',
                    ar: 'لا توجد معاملات بعد',
                  ),
            description: _hasAnyFilter
                ? l10nPick(
                    context,
                    en: 'No transactions match your active filters. Try adjusting or clearing your filters to see more results.',
                    fa: 'هیچ تراکنشی با فیلترهای انتخابی شما مطابقت ندارد. فیلترها را تغییر داده یا بازنشانی کنید.',
                    ar: 'لا توجد معاملات تطابق عوامل التصفية الحالية. جرب تغييرها أو مسحها.',
                  )
                : l10nPick(
                    context,
                    en: 'Your activity, transfers, exchanges, and payments will show up here once you make your first transaction.',
                    fa: 'فعالیت‌ها، انتقال‌ها، تبادلات و پرداخت‌های شما پس از اولین تراکنش در اینجا نمایش داده خواهند شد.',
                    ar: 'ستظهر هنا جميع التحويلات والمدفوعات بعد إجراء أول معاملة.',
                  ),
            iconData: _hasAnyFilter
                ? Icons.filter_alt_off_outlined
                : Icons.receipt_long_outlined,
            primaryActionLabel: _hasAnyFilter
                ? l10nPick(context, en: 'Reset Filters', fa: 'بازنشانی فیلترها', ar: 'إعادة ضبط الفلاتر')
                : l10nPick(context, en: 'Refresh History', fa: 'بروزرسانی', ar: 'تحديث السجل'),
            onPrimaryAction: () {
              if (_hasAnyFilter) {
                setState(() => _dirFilter = 0);
                controller.resetFilters();
              } else {
                refreshData();
              }
            },
          ),
        ),
      );
    }

    // 4. Content State with Grouping
    return RefreshIndicator(
      color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
      onRefresh: () => refreshData(),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // A. Hero Summary Glass Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(top: AppSpacing.sm),
              child: TransactionSummaryCard(transactions: transactions),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

          // B. Transaction Type Chips (Horizontal Pill Bar)
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 38,
              child: TransactionTypeList(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

          // C. Direction Filter Segmented Pills
          SliverToBoxAdapter(
            child: _buildDirectionPills(context, isDark),
          ),

          // D. Active Filter Notification Banner
          if (_hasAnyFilter)
            SliverToBoxAdapter(
              child: _buildActiveFilterBanner(context, isDark),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

          // E. Date-Grouped Transactions List
          ..._buildGroupedTransactionSlivers(context, isDark, transactions),

          // F. Infinite Pagination Bottom Loader
          if (controller.isPageLoading.value)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                    ),
                  ),
                ),
              ),
            ),

          // Bottom safe padding
          SliverToBoxAdapter(
            child: SizedBox(
              height: AppSpacing.bottomSafe(context, AppSpacing.xl),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionPills(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _buildDirectionPill(
            label: l10nPick(context, en: 'All', fa: 'همه', ar: 'الكل'),
            value: 0,
            icon: Icons.swap_vert_rounded,
            color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
            isDark: isDark,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildDirectionPill(
            label: l10nPick(context, en: 'Incoming', fa: 'ورودی', ar: 'واردة'),
            value: 1,
            icon: Icons.arrow_downward_rounded,
            color: AppColors.success,
            isDark: isDark,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildDirectionPill(
            label: l10nPick(context, en: 'Outgoing', fa: 'خروجی', ar: 'صادرة'),
            value: 2,
            icon: Icons.arrow_upward_rounded,
            color: AppColors.error,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionPill({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    final selected = _dirFilter == value;
    final bg = selected
        ? color.withValues(alpha: isDark ? 0.28 : 0.14)
        : (isDark ? AppColors.darkSurfaceVariant : AppColors.white);
    final fg = selected
        ? (isDark ? AppColors.darkTextPrimary : color)
        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);
    final borderColor = selected
        ? color
        : (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _dirFilter = value);
            },
            child: AnimatedContainer(
              duration: AppDurations.fast,
              curve: Curves.easeOutCubic,
              padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: borderColor,
                  width: selected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: fg),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: fg,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterBanner(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceVariant.withValues(alpha: 0.6)
              : AppColors.lightSecondaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightOutlineVariant,
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.filter_list_rounded,
              size: AppSpacing.iconXs,
              color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                l10nPick(
                  context,
                  en: 'Filters Applied',
                  fa: 'فیلترها اعمال شده است',
                  ar: 'تم تطبيق الفلاتر',
                ),
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _dirFilter = 0);
                controller.resetFilters();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10nPick(context, en: 'Clear', fa: 'پاک کردن', ar: 'مسح'),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupedTransactionSlivers(
    BuildContext context,
    bool isDark,
    List<Transactions> items,
  ) {
    final groups = _groupTransactions(context, items);
    final slivers = <Widget>[];

    for (final group in groups) {
      // 1. Group Header
      slivers.add(
        SliverToBoxAdapter(
          child: TransactionDateGroupHeader(
            title: group.title,
            count: group.transactions.length,
          ),
        ),
      );

      // 2. Grouped Card Container
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: List.generate(group.transactions.length, (index) {
                  final tx = group.transactions[index];
                  final isLast = index == group.transactions.length - 1;

                  return TransactionCard(
                    transaction: tx,
                    showDivider: !isLast,
                    onTap: () {
                      Get.bottomSheet(
                        RecentTransactionDetails(transaction: tx),
                        isScrollControlled: true,
                      );
                    },
                  );
                }),
              ),
            ),
          ),
        ),
      );
    }

    return slivers;
  }

  List<_TransactionDateGroup> _groupTransactions(
    BuildContext context,
    List<Transactions> items,
  ) {
    final Map<String, _TransactionDateGroup> map = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final tx in items) {
      final dt = tx.parsedDate;
      final String dateKey;
      final String groupTitle;

      if (dt != null) {
        final txDay = DateTime(dt.year, dt.month, dt.day);
        final diff = today.difference(txDay).inDays;
        dateKey =
            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

        if (diff == 0) {
          groupTitle = l10nPick(
            context,
            en: 'Today',
            fa: 'امروز',
            ar: 'اليوم',
            tr: 'Bugün',
            ru: 'Сегодня',
            zh: '今天',
          );
        } else if (diff == 1) {
          groupTitle = l10nPick(
            context,
            en: 'Yesterday',
            fa: 'دیروز',
            ar: 'أمس',
            tr: 'Dün',
            ru: 'Вчера',
            zh: '昨天',
          );
        } else {
          final locale = Localizations.localeOf(context).languageCode;
          if (locale == 'fa' || locale == 'ar') {
            final j = Jalali.fromDateTime(dt);
            const monthNames = [
              'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
              'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
            ];
            final monthName =
                (j.month >= 1 && j.month <= 12) ? monthNames[j.month - 1] : '${j.month}';
            groupTitle = '${j.day} $monthName ${j.year}';
          } else {
            const monthNames = [
              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
            ];
            final monthName =
                (dt.month >= 1 && dt.month <= 12) ? monthNames[dt.month - 1] : '${dt.month}';
            groupTitle = '${dt.day} $monthName ${dt.year}';
          }
        }
      } else {
        dateKey = 'undated';
        groupTitle = l10nPick(
          context,
          en: 'Other Transactions',
          fa: 'سایر تراکنش‌ها',
          ar: 'معاملات أخرى',
        );
      }

      if (!map.containsKey(dateKey)) {
        map[dateKey] = _TransactionDateGroup(
          title: groupTitle,
          dateKey: dateKey,
          transactions: [],
        );
      }
      map[dateKey]!.transactions.add(tx);
    }

    return map.values.toList();
  }
}
