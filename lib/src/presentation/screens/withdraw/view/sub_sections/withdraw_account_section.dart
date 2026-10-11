import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_error_view.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/controller/withdraw_account_controller.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/controller/withdraw_controller.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/model/withdraw_account_model.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/sub_sections/delete_account_dropdown_section.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/widgets/add_account_dashed_button.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/view/widgets/withdraw_destination_card.dart';

class WithdrawAccountSection extends StatefulWidget {
  const WithdrawAccountSection({super.key});

  @override
  State<WithdrawAccountSection> createState() => _WithdrawAccountSectionState();
}

class _WithdrawAccountSectionState extends State<WithdrawAccountSection>
    with WidgetsBindingObserver {
  final WithdrawAccountController controller = Get.find();
  late ScrollController _scrollController;
  final RxBool _hasLoadError = false.obs;

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
      controller.loadMoreWithdrawAccounts();
    }
  }

  Future<void> loadData() async {
    controller.isLoading.value = true;
    _hasLoadError.value = false;
    try {
      await controller.fetchWithdrawAccounts();
    } catch (_) {
      _hasLoadError.value = true;
    } finally {
      controller.isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    _hasLoadError.value = false;
    try {
      await controller.fetchWithdrawAccounts();
    } catch (_) {
      _hasLoadError.value = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with account count badge
          Obx(() {
            final accounts =
                controller.withdrawAccountModel.value.data?.accounts ?? [];
            final count = accounts.length;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      l10nPick(
                        context,
                        en: 'Saved Payout Accounts',
                        fa: 'حساب‌های بانکی و مقاصد تسویه',
                        ar: 'الحسابات المصرفية المحفوظة',
                        tr: 'Kayıtlı Çekim Hesapları',
                        ru: 'Сохраненные счета для вывода',
                      ),
                      style: TextStyle(
                        letterSpacing: -0.2,
                        fontSize: 17,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(
                            alpha: isDark ? 0.20 : 0.12,
                          ),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  l10nPick(
                    context,
                    en: 'Instant Payout',
                    fa: 'تسویه شتاب/پایا',
                    ar: 'تسوية سريعة',
                    tr: 'Hızlı Takas',
                    ru: 'Быстрый вывод',
                  ),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: AppSpacing.md),

          // Distinctive "Add New Account" button with dashed glowing border
          AddNewAccountDashedButton(
            onTap: () {
              Get.find<WithdrawController>().selectedScreen.value = 2;
            },
          ),

          const SizedBox(height: AppSpacing.sm),

          // Main content container with refresh indicator
          Expanded(
            child: Obx(
              () => Stack(
                children: [
                  RefreshIndicator(
                    color: accentColor,
                    onRefresh: refreshData,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCard
                            : AppColors.lightCard,
                        borderRadius: const BorderRadiusDirectional.only(
                          topStart: Radius.circular(AppSpacing.radiusLg),
                          topEnd: Radius.circular(AppSpacing.radiusLg),
                        ),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const CommonLoading()
                          : _hasLoadError.value
                          ? EcardoErrorView(
                              message: localization.allControllerLoadError,
                              onRetry: loadData,
                              retryLabel:
                                  localization.noInternetConnectionRetryButton,
                            )
                          : (controller
                                      .withdrawAccountModel
                                      .value
                                      .data
                                      ?.accounts
                                      ?.isEmpty ??
                                  true)
                          ? LayoutBuilder(
                              builder: (context, constraints) =>
                                  SingleChildScrollView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.lg,
                                      ),
                                      child: EcardoEmptyState(
                                        title: l10nPick(
                                          context,
                                          en: 'No Payout Accounts Added',
                                          fa: 'هیچ حساب برداشتی ثبت نشده است',
                                          ar: 'لم تتم إضافة أي حسابات',
                                          tr: 'Kayıtlı hesap bulunamadı',
                                          ru: 'Нет добавленных счетов',
                                        ),
                                        description: l10nPick(
                                          context,
                                          en: 'Add your Iranian Sheba (IBAN), bank card, or crypto wallet to withdraw your earnings instantly.',
                                          fa: 'شماره شبا، کارت بانکی یا آدرس کیف پول خود را برای تسویه فوری و آسان ثبت کنید.',
                                          ar: 'أضف رقم الآيبان أو البطاقة المصرفية للسحب السريع.',
                                          tr: 'Kazançlarınızı anında çekmek için IBAN veya kart ekleyin.',
                                          ru: 'Добавьте банковский счет или карту для мгновенного вывода средств.',
                                        ),
                                        iconData:
                                            Icons.account_balance_outlined,
                                        primaryActionLabel: localization
                                            .withdrawScreenAddAccountButton,
                                        onPrimaryAction: () {
                                          HapticFeedback.lightImpact();
                                          Get.find<WithdrawController>()
                                              .selectedScreen
                                              .value = 2;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.md,
                              ),
                              itemCount: (controller
                                      .withdrawAccountModel
                                      .value
                                      .data
                                      ?.accounts
                                      ?.length ??
                                  0) +
                                  (controller.isPageLoading.value ? 1 : 0),
                              itemBuilder: (context, index) {
                                final accounts = controller
                                        .withdrawAccountModel
                                        .value
                                        .data
                                        ?.accounts ??
                                    [];

                                if (index == accounts.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(AppSpacing.md),
                                    child: Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final Accounts account = accounts[index];

                                return WithdrawDestinationCard(
                                  account: account,
                                  mode: WithdrawCardMode.management,
                                  onEdit: () {
                                    final withdrawController =
                                        Get.find<WithdrawController>();
                                    withdrawController.selectedAccount.value =
                                        account;
                                    withdrawController.selectedScreen.value = 3;
                                  },
                                  onDelete: () {
                                    Get.bottomSheet(
                                      DeleteAccountDropdownSection(
                                        accountId: account.id.toString(),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
