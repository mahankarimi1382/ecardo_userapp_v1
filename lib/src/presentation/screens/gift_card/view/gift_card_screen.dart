import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/controller/gift_card_controller.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/model/gift_card_categories_model.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/model/gift_card_product_model.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/view/sub_sections/gift_card_details_section.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/view/sub_sections/gift_card_header_section.dart';
import 'package:ecardo_user/src/presentation/screens/gift_card/view/sub_sections/gift_card_history_section.dart';

class GiftCardScreen extends StatefulWidget {
  const GiftCardScreen({super.key});

  @override
  State<GiftCardScreen> createState() => _GiftCardScreenState();
}

class _GiftCardScreenState extends State<GiftCardScreen> {
  final GiftCardController controller = Get.find<GiftCardController>();
  late final ScrollController _scrollController;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    controller.clearInitialData();
    controller.initGiftCardFilterDefaults();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreGiftCardProducts();
    }
  }

  Future<void> _loadData() async {
    controller.isGiftCardLoading.value = true;
    await controller.getGiftCardProducts(isRefresh: true);

    if (!controller.isInitialized.value) {
      await controller.getGiftCardCountry();
      await controller.getGiftCardCategory();
      controller.isInitialized.value = true;
    }

    controller.isGiftCardLoading.value = false;
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      controller.getGiftCardProducts(isRefresh: true);
    });
  }

  void _onClearSearch() {
    HapticFeedback.lightImpact();
    controller.giftCardController.clear();
    _searchDebounce?.cancel();
    controller.getGiftCardProducts(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkSurface, AppColors.darkBackground]
                : [AppColors.white, AppColors.lightBackground],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.26, 0.31],
          ),
        ),
        child: Column(
          children: [
            const GiftCardHeaderSection(),
            Expanded(
              child: Obx(
                () => controller.selectedScreen.value == 0
                    ? Column(
                        children: [
                          _buildSearchBar(context, isDark),
                          _buildCategoryChips(context, isDark),
                          Expanded(child: _buildVoucherGrid(context, isDark)),
                        ],
                      )
                    : controller.selectedScreen.value == 1
                    ? const GiftCardHistorySection()
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 10.h),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Semantics(
          label: l10nPick(
            context,
            en: 'Search gift card vouchers',
            fa: 'جستجوی کارت‌های هدیه و ووچرها',
            ar: 'البحث عن بطاقات الهدايا',
            zh: '搜索礼品卡',
            ru: 'Поиск подарочных карт',
            tr: 'Hediye kartı ara',
          ),
          textField: true,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 44.h),
            child: TextField(
              controller: controller.giftCardController,
              focusNode: controller.giftCardFocusNode,
              onChanged: _onSearchChanged,
              onSubmitted: (_) {
                _searchDebounce?.cancel();
                controller.getGiftCardProducts(isRefresh: true);
              },
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: l10nPick(
                  context,
                  en: 'Search brand or voucher...',
                  fa: 'جستجوی برند یا ووچر...',
                  ar: 'ابحث عن العلامة التجارية...',
                  zh: '搜索品牌或礼品卡...',
                  ru: 'Поиск бренда или ваучера...',
                  tr: 'Marka veya kupon ara...',
                ),
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color: isDark
                      ? AppColors.darkTextHint
                      : AppColors.lightTextHint,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.brandViolet,
                  size: 22.sp,
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller.giftCardController,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return Semantics(
                      button: true,
                      label: l10nPick(
                        context,
                        en: 'Clear search',
                        fa: 'پاک کردن جستجو',
                        ar: 'مسح البحث',
                        zh: '清空搜索',
                        ru: 'Очистить поиск',
                        tr: 'Aramayı temizle',
                      ),
                      child: IconButton(
                        constraints: BoxConstraints(
                          minWidth: 44.w,
                          minHeight: 44.h,
                        ),
                        icon: Icon(
                          Icons.cancel_rounded,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          size: 18.sp,
                        ),
                        onPressed: _onClearSearch,
                      ),
                    );
                  },
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, bool isDark) {
    return Obx(() {
      final categories = controller.giftCardCategoryList;
      if (categories.isEmpty) return const SizedBox.shrink();

      final selectedCategory = controller.selectedGiftCardCategory.value;

      return Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: SizedBox(
          height: 44.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length + 1,
            separatorBuilder: (_, _) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final category = isAll ? null : categories[index - 1];
              final name = isAll
                  ? l10nPick(
                      context,
                      en: 'All',
                      fa: 'همه',
                      ar: 'الكل',
                      zh: '全部',
                      ru: 'Все',
                      tr: 'Tümü',
                    )
                  : (category?.name ?? '');
              final isSelected = isAll
                  ? (selectedCategory.id == null ||
                        selectedCategory.name == null)
                  : (selectedCategory.id == category?.id);

              return Semantics(
                button: true,
                selected: isSelected,
                label: name,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (isAll) {
                      controller.selectedGiftCardCategory.value =
                          GiftCardCategoriesData();
                      controller.giftCardCategoryController.clear();
                    } else {
                      controller.selectedGiftCardCategory.value = category!;
                      controller.giftCardCategoryController.text =
                          category.name ?? '';
                    }
                    controller.getGiftCardProducts(isRefresh: true);
                  },
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 44.h,
                      minWidth: 44.w,
                    ),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [
                                AppColors.brandViolet,
                                AppColors.brandVioletDeep,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (isDark ? AppColors.darkSurface : AppColors.white),
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.brandViolet
                            : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                        width: 1.2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.brandViolet.withValues(
                                  alpha: isDark ? 0.35 : 0.25,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.white
                            : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildVoucherGrid(BuildContext context, bool isDark) {
    final localization = AppLocalizations.of(context)!;

    return Obx(() {
      final cardProductList = controller.giftCardProductList;

      if (controller.isGiftCardLoading.value && cardProductList.isEmpty) {
        return Center(
          child: CircularProgressIndicator(
            color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
          ),
        );
      }

      if (controller.isGiftCardError.value && cardProductList.isEmpty) {
        return Center(
          child: EcardoErrorView(
            title: localization.allControllerLoadError,
            message: l10nPick(
              context,
              en: 'Could not load gift card vouchers. Check your connection.',
              fa: 'بارگذاری ووچرهای کارت هدیه ناموفق بود. اتصال اینترنت را بررسی کنید.',
              ar: 'تعذر تحميل بطاقات الهدايا. تحقق من اتصالك.',
              zh: '无法加载礼品卡。请检查网络连接。',
              ru: 'Не удалось загрузить подарочные карты. Проверьте соединение.',
              tr: 'Hediye kartları yüklenemedi. Bağlantınızı kontrol edin.',
            ),
            retryLabel: localization.noInternetConnectionRetryButton,
            onRetry: _loadData,
          ),
        );
      }

      if (cardProductList.isEmpty) {
        return Center(
          child: EcardoEmptyState(
            iconData: Icons.card_giftcard_rounded,
            title: l10nPick(
              context,
              en: 'No Gift Cards Found',
              fa: 'کارت هدیه‌ای یافت نشد',
              ar: 'لم يتم العثور على بطاقات هدايا',
              zh: '未找到礼品卡',
              ru: 'Подарочные карты не найдены',
              tr: 'Hediye Kartı Bulunamadı',
            ),
            description: l10nPick(
              context,
              en: 'No brand gift cards match your filter. Try adjusting your search.',
              fa: 'هیچ کارت هدیه‌ای با فیلتر شما تطابق ندارد. جستجو را تغییر دهید.',
              ar: 'لا توجد بطاقات هدايا تطابق الفلتر الخاص بك.',
              zh: '没有符合筛选条件的礼品卡。请调整搜索条件。',
              ru: 'Нет подарочных карт, соответствующих вашему фильтру.',
              tr: 'Filtrenizle eşleşen hediye kartı bulunamadı.',
            ),
            primaryActionLabel: localization.noInternetConnectionRetryButton,
            onPrimaryAction: _loadData,
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await controller.getGiftCardProducts(isRefresh: true);
        },
        color: AppColors.brandViolet,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        child: Stack(
          children: [
            GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              padding: EdgeInsetsDirectional.only(
                top: 8.h,
                start: 16.w,
                end: 16.w,
                bottom: 32.h,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.85,
              ),
              itemCount: cardProductList.length,
              itemBuilder: (context, index) {
                final Content card = cardProductList[index];
                return _buildVoucherCard(context, card, isDark);
              },
            ),
            if (controller.isGiftCardLoadingMore.value)
              Positioned(
                bottom: 12.h,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 28.w,
                    height: 28.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.brandViolet,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildVoucherCard(BuildContext context, Content card, bool isDark) {
    final brandName = card.brand?.brandName ?? card.productName ?? '';
    final countryCode = card.country?.isoName ?? '';

    return Semantics(
      button: true,
      label:
          '$brandName ${countryCode.isNotEmpty ? "($countryCode)" : ""}, voucher card',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          Get.to(
            () => GiftCardDetailsSection(giftCardId: card.productId.toString()),
          );
        },
        child: Container(
          constraints: BoxConstraints(minHeight: 44.h, minWidth: 44.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorder
                  : AppColors.brandViolet.withValues(alpha: 0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AppColors.black.withValues(alpha: 0.25)
                    : AppColors.brandViolet.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(6.w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: CachedNetworkImage(
                          width: double.infinity,
                          height: double.infinity,
                          imageUrl: card.logoUrls?.first ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.lightBackground,
                            child: Center(
                              child: SizedBox(
                                width: 22.w,
                                height: 22.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.brandViolet,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.lightBackground,
                            child: Icon(
                              Icons.card_giftcard_rounded,
                              size: 32.sp,
                              color: isDark
                                  ? AppColors.mainSoftBlue
                                  : AppColors.brandViolet,
                            ),
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: 10.h,
                      start: 10.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.brandViolet,
                              AppColors.brandVioletDeep,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandViolet.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              size: 11.sp,
                              color: AppColors.white,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              l10nPick(
                                context,
                                en: 'Instant',
                                fa: 'آنی',
                                ar: 'فوري',
                                zh: '秒发',
                                ru: 'Мгновенно',
                                tr: 'Anında',
                              ),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brandName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      countryCode.isNotEmpty
                          ? countryCode
                          : l10nPick(
                              context,
                              en: 'Global Voucher',
                              fa: 'ووچر بین‌المللی',
                              ar: 'قسيمة عالمية',
                              zh: '全球礼品卡',
                              ru: 'Глобальный ваучер',
                              tr: 'Küresel Kupon',
                            ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
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
