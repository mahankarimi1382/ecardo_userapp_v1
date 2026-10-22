import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/model/beneficiary_model.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_empty_state.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_error_view.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/beneficiary/widgets/monogram_avatar.dart';

/// Modern Beneficiary Management Screen.
///
/// Features:
/// - Full list of saved beneficiaries with search filter.
/// - Creative Neo-Fintech Empty State (`EcardoEmptyState`) with primary CTA.
/// - Minimum 44x44 touch targets for edit and delete actions with haptics and Semantics.
/// - Adaptive light and dark styling powered by semantic `AppColors` tokens.
/// - Pull-to-refresh and network error recovery.
class BeneficiaryScreen extends StatefulWidget {
  final void Function(Beneficiaries)? onSelect;
  final String accountUser;

  const BeneficiaryScreen({
    super.key,
    this.onSelect,
    this.accountUser = 'Beneficiary',
  });

  @override
  State<BeneficiaryScreen> createState() => _BeneficiaryScreenState();
}

class _BeneficiaryScreenState extends State<BeneficiaryScreen> {
  final RxList<Beneficiaries> _beneficiaries = <Beneficiaries>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasLoadError = false.obs;
  final RxString _searchQuery = ''.obs;

  late final ScrollController _scrollController;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      _searchQuery.value = _searchController.text.trim().toLowerCase();
    });
    fetchBeneficiaries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchBeneficiaries({bool isRefresh = false}) async {
    if (!isRefresh) {
      _isLoading.value = true;
    }
    _hasLoadError.value = false;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.beneficiaryEndpoint}?type=user",
      );

      if (response.status == Status.completed && response.data != null) {
        final model = BeneficiaryModel.fromJson(response.data!);
        _beneficiaries.assignAll(model.data?.beneficiaries ?? []);
      } else {
        _hasLoadError.value = true;
      }
    } catch (e) {
      debugPrint('❌ fetchBeneficiaries error: $e');
      _hasLoadError.value = true;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _deleteBeneficiary(String id) async {
    try {
      final response = await Get.find<NetworkService>().delete(
        endpoint: "${ApiPath.beneficiaryEndpoint}/$id",
      );
      if (response.status == Status.completed) {
        HapticFeedback.lightImpact();
        _beneficiaries.removeWhere((item) => item.id.toString() == id);
        ToastHelper().showSuccessToast(
          response.data?["message"] ?? "Beneficiary deleted successfully",
        );
      }
    } catch (e) {
      debugPrint('❌ deleteBeneficiary error: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ToastHelper().showErrorToast(
          l10n?.allControllerLoadError ?? "Error deleting beneficiary",
        );
      }
    }
  }

  Future<void> _navigateToAddBeneficiary() async {
    HapticFeedback.lightImpact();
    await Get.toNamed(
      BaseRoute.createBeneficiary,
      arguments: {"account_user": widget.accountUser},
    );
    fetchBeneficiaries(isRefresh: true);
  }

  Future<void> _navigateToEditBeneficiary(Beneficiaries item) async {
    HapticFeedback.lightImpact();
    await Get.toNamed(
      BaseRoute.updateBeneficiary,
      arguments: {
        "beneficiary_id": item.id.toString(),
        "account_user": widget.accountUser,
        "beneficiary_data": item,
      },
    );
    fetchBeneficiaries(isRefresh: true);
  }

  void _showDeleteBottomSheet(BuildContext context, Beneficiaries item) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightSurface,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(AppSpacing.radiusXl),
            topEnd: Radius.circular(AppSpacing.radiusXl),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: AppSpacing.xl,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.softGray : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                size: 34,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              localizations.transferAmountStepSectionDeleteConfirmationTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              localizations.transferAmountStepSectionDeleteConfirmationMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    label: localizations.transferAmountStepSectionCancelButton,
                    child: CommonButton(
                      borderRadius: AppSpacing.radiusLg,
                      backgroundColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightSurfaceVariant,
                      textColor: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      text: localizations.transferAmountStepSectionCancelButton,
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Get.back();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: localizations.transferAmountStepSectionDeleteButton,
                    child: CommonButton(
                      borderRadius: AppSpacing.radiusLg,
                      backgroundColor: AppColors.error,
                      textColor: AppColors.white,
                      text: localizations.transferAmountStepSectionDeleteButton,
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        Get.back();
                        if (item.id != null) {
                          await _deleteBeneficiary(item.id.toString());
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  List<Beneficiaries> _filterBeneficiaries(List<Beneficiaries> source) {
    final query = _searchQuery.value;
    if (query.isEmpty) return source;
    return source.where((item) {
      final nickname = (item.nickname ?? '').toLowerCase();
      final name = (item.receiver?.name ?? '').toLowerCase();
      final account = (item.accountNumber ?? '').toLowerCase();
      return nickname.contains(query) ||
          name.contains(query) ||
          account.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: const CommonDefaultAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            CommonAppBar(
              title: localizations.transferAmountStepSectionBeneficiariesTitle,
              rightSideWidget: Semantics(
                button: true,
                label: localizations.transferAmountStepSectionAddBeneficiary,
                tooltip: localizations.transferAmountStepSectionAddBeneficiary,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  onTap: _navigateToAddBeneficiary,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                          color:
                              (isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.brandViolet)
                                  .withValues(alpha: 0.10),
                          border: Border.all(
                            color:
                                (isDark
                                        ? AppColors.darkPrimary
                                        : AppColors.brandViolet)
                                    .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          size: 20,
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.brandViolet,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Obx(() {
                if (_isLoading.value && _beneficiaries.isEmpty) {
                  return const CommonLoading();
                }

                if (_hasLoadError.value && _beneficiaries.isEmpty) {
                  return EcardoErrorView(
                    message: localizations.allControllerLoadError,
                    onRetry: fetchBeneficiaries,
                    retryLabel: localizations.noInternetConnectionRetryButton,
                  );
                }

                if (_beneficiaries.isEmpty) {
                  return RefreshIndicator(
                    color: isDark
                        ? AppColors.darkPrimary
                        : AppColors.brandViolet,
                    onRefresh: () => fetchBeneficiaries(isRefresh: true),
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(
                            child: EcardoEmptyState(
                              title: localizations
                                  .transferAmountStepSectionBeneficiariesTitle,
                              description: localizations.noDataFound,
                              iconData: Icons.people_outline_rounded,
                              iconColor: isDark
                                  ? AppColors.mainSoftBlue
                                  : AppColors.brandViolet,
                              glowColor: isDark
                                  ? AppColors.mainSoftBlue
                                  : AppColors.brandViolet,
                              primaryActionLabel: localizations
                                  .transferAmountStepSectionAddBeneficiary,
                              onPrimaryAction: _navigateToAddBeneficiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final filteredList = _filterBeneficiaries(_beneficiaries);

                return RefreshIndicator(
                  color: isDark ? AppColors.darkPrimary : AppColors.brandViolet,
                  onRefresh: () => fetchBeneficiaries(isRefresh: true),
                  child: Column(
                    children: [
                      if (_beneficiaries.length > 3)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: AppSpacing.page,
                            end: AppSpacing.page,
                            bottom: AppSpacing.md,
                          ),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkCard
                                  : AppColors.lightCard,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  size: 20,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: localizations
                                          .paymentLinksFilterButton,
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? AppColors.darkTextHint
                                            : AppColors.lightTextHint,
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ),
                                if (_searchQuery.value.isNotEmpty)
                                  Semantics(
                                    button: true,
                                    label: 'Clear',
                                    child: InkWell(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        _searchController.clear();
                                      },
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minWidth: 44,
                                          minHeight: 44,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.close_rounded,
                                            size: 18,
                                            color: isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.lightTextSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      Expanded(
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: _scrollController,
                          padding: const EdgeInsetsDirectional.only(
                            top: AppSpacing.xs,
                            bottom: AppSpacing.xxxl,
                            start: AppSpacing.page,
                            end: AppSpacing.page,
                          ),
                          itemCount: filteredList.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            final displayName =
                                item.nickname ?? item.receiver?.name ?? 'User';

                            return Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkCard
                                    : AppColors.lightCard,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusLg,
                                ),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? AppColors.darkShadow
                                        : AppColors.lightShadow,
                                    blurRadius: AppSpacing.sm,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusLg,
                                ),
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  if (widget.onSelect != null) {
                                    widget.onSelect!(item);
                                    Get.back(result: item);
                                  }
                                },
                                child: Row(
                                  children: [
                                    MonogramAvatar(
                                      name: displayName,
                                      imageUrl: item.receiver?.avatar,
                                      size: 44,
                                      isVerified: item.receiver != null,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayName,
                                            style: TextStyle(
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: isDark
                                                  ? AppColors.darkTextPrimary
                                                  : AppColors.lightTextPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${localizations.transferAmountStepSectionUidLabel} ${item.accountNumber ?? ''}",
                                            style: TextStyle(
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: isDark
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors.lightTextTertiary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Semantics(
                                          button: true,
                                          label: localizations
                                              .updateBeneficiaryTitle,
                                          tooltip: localizations
                                              .updateBeneficiaryTitle,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              AppSpacing.radiusSm,
                                            ),
                                            onTap: () =>
                                                _navigateToEditBeneficiary(
                                                  item,
                                                ),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                minWidth: 44,
                                                minHeight: 44,
                                              ),
                                              child: Center(
                                                child: Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          AppSpacing.radiusSm,
                                                        ),
                                                    color:
                                                        (isDark
                                                                ? AppColors
                                                                      .darkPrimary
                                                                : AppColors
                                                                      .brandViolet)
                                                            .withValues(
                                                              alpha: 0.10,
                                                            ),
                                                    border: Border.all(
                                                      color:
                                                          (isDark
                                                                  ? AppColors
                                                                        .darkPrimary
                                                                  : AppColors
                                                                        .brandViolet)
                                                              .withValues(
                                                                alpha: 0.25,
                                                              ),
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.edit_outlined,
                                                    size: 18,
                                                    color: isDark
                                                        ? AppColors.darkPrimary
                                                        : AppColors.brandViolet,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Semantics(
                                          button: true,
                                          label: localizations
                                              .transferAmountStepSectionDeleteButton,
                                          tooltip: localizations
                                              .transferAmountStepSectionDeleteButton,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              AppSpacing.radiusSm,
                                            ),
                                            onTap: () {
                                              HapticFeedback.lightImpact();
                                              _showDeleteBottomSheet(
                                                context,
                                                item,
                                              );
                                            },
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                minWidth: 44,
                                                minHeight: 44,
                                              ),
                                              child: Center(
                                                child: Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          AppSpacing.radiusSm,
                                                        ),
                                                    color: AppColors
                                                        .errorContainer
                                                        .withValues(
                                                          alpha: isDark
                                                              ? 0.2
                                                              : 0.8,
                                                        ),
                                                    border: Border.all(
                                                      color: AppColors.error
                                                          .withValues(
                                                            alpha: 0.25,
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    Icons
                                                        .delete_outline_rounded,
                                                    size: 18,
                                                    color: AppColors.error,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
