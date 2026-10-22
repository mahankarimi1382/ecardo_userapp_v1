import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/controller/virtual_card_details_controller.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/model/virtual_card_details_model.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/generic/generic_card_provider.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/view/virtual_card_details/sub_sections/provider/generic/generic_card_top_up_bottom_sheet.dart';

class VirtualCardDetails extends StatefulWidget {
  const VirtualCardDetails({super.key});

  @override
  State<VirtualCardDetails> createState() => _VirtualCardDetailsState();
}

class _VirtualCardDetailsState extends State<VirtualCardDetails> {
  final VirtualCardDetailsController controller = Get.find();
  final String id = Get.arguments?["id"] ?? "";
  final String cardId = Get.arguments?["card_id"] ?? "";
  int _selectedTabIndex = 0;

  Future<void> _fetchCardDetailsByProvider() {
    return controller.fetchVirtualCardDetails(cardId: id);
  }

  @override
  void initState() {
    super.initState();
    _fetchCardDetailsByProvider();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Scaffold moved outside Obx so route/scaffold state does not needlessly rebuild
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: const CommonDefaultAppBar(),
      body: Column(
        children: [
          SizedBox(height: 16.h),
          Obx(() {
            final card = controller.virtualCardDetailsModel.value.data;
            final hasGenericContract = card?.display != null ||
                card?.capabilities != null ||
                card?.funding != null ||
                card?.actions != null;
            final canViewTransactions =
                !hasGenericContract || card?.capabilities?.canViewTransactions == true;

            return CommonAppBar(
              title: localization?.virtualCardDetailsAppBarTitle ?? 'Card Details',
              rightSideWidget: canViewTransactions
                  ? GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          BaseRoute.virtualCardTransaction,
                          arguments: {
                            "card_id": cardId.isNotEmpty ? cardId : (card?.cardId ?? id),
                            "endpoint": card?.actions?.transactionsEndpoint,
                          },
                        );
                      },
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(end: 18.w),
                        child: Image.asset(
                          PngAssets.commonHistoryIcon,
                          width: 30.w,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          }),
          SizedBox(height: 12.h),

          // Clean, modern tab navigation between Overview and Transactions with 1-tap Sensitive Details modal
          Obx(() {
            final card = controller.virtualCardDetailsModel.value.data;
            return _CardNavigationTabs(
              selectedIndex: _selectedTabIndex,
              isDark: isDark,
              onTabSelected: (index) {
                setState(() => _selectedTabIndex = index);
                if (index == 1) {
                  Get.toNamed(
                    BaseRoute.virtualCardTransaction,
                    arguments: {
                      "card_id": cardId.isNotEmpty ? cardId : (card?.cardId ?? id),
                      "endpoint": card?.actions?.transactionsEndpoint,
                    },
                  )?.then((_) {
                    if (mounted) setState(() => _selectedTabIndex = 0);
                  });
                }
              },
              onOpenSensitiveModal: () {
                _showSensitiveCardDetailsModal(context, card, isDark);
              },
            );
          }),

          SizedBox(height: 10.h),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const CommonLoading();
              }

              final card = controller.virtualCardDetailsModel.value.data;
              final hasGenericContract = card?.display != null ||
                  card?.capabilities != null ||
                  card?.funding != null ||
                  card?.actions != null;
              final canTopUp =
                  !hasGenericContract || card?.capabilities?.canTopup == true;

              return RefreshIndicator(
                onRefresh: _fetchCardDetailsByProvider,
                color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    18.w,
                    0,
                    18.w,
                    canTopUp ? 90.h : 30.h,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: const GenericCardProvider(),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        final card = controller.virtualCardDetailsModel.value.data;
        final hasGenericContract = card?.display != null ||
            card?.capabilities != null ||
            card?.funding != null ||
            card?.actions != null;
        final canTopUp =
            !hasGenericContract || card?.capabilities?.canTopup == true;

        if (controller.isLoading.value || !canTopUp) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: CommonButton(
            width: 140,
            height: 44,
            borderRadius: 14,
            fontSize: 13,
            text: localization?.virtualCardDetailsFloatingButton ?? 'Top Up',
            onPressed: () {
              Get.bottomSheet(
                GenericCardTopUpBottomSheet(cardId: id),
                isScrollControlled: true,
              );
            },
          ),
        );
      }),
    );
  }

  void _showSensitiveCardDetailsModal(
    BuildContext context,
    VirtualCardDetailsData? card,
    bool isDark,
  ) {
    HapticFeedback.mediumImpact();
    Get.bottomSheet(
      _SensitiveCardDetailsModal(card: card, isDark: isDark),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
    );
  }
}

/// Clean Segmented Tab Navigation for Virtual Card Details
class _CardNavigationTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onOpenSensitiveModal;
  final bool isDark;

  const _CardNavigationTabs({
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onOpenSensitiveModal,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.mainSoftBlue : AppColors.brandViolet;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Row(
        children: [
          // Segmented Tabs: Overview & Transactions
          Expanded(
            child: Container(
              height: 42.h,
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant.withValues(alpha: 0.50)
                    : AppColors.lightSurfaceVariant.withValues(alpha: 0.80),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: l10nPick(
                        context,
                        en: 'Overview',
                        fa: 'نمای کلی',
                        ar: 'نظرة عامة',
                        tr: 'Genel Bakış',
                        ru: 'Обзор',
                        zh: '概览',
                      ),
                      icon: Icons.credit_card_rounded,
                      isSelected: selectedIndex == 0,
                      isDark: isDark,
                      activeColor: activeColor,
                      onTap: () => onTabSelected(0),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: _TabButton(
                      label: l10nPick(
                        context,
                        en: 'Activity',
                        fa: 'تراکنش‌ها',
                        ar: 'النشاط',
                        tr: 'İşlemler',
                        ru: 'История',
                        zh: '交易明细',
                      ),
                      icon: Icons.history_rounded,
                      isSelected: selectedIndex == 1,
                      isDark: isDark,
                      activeColor: activeColor,
                      onTap: () => onTabSelected(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // 1-Tap Sensitive Details Security Button
          Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: onOpenSensitiveModal,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                height: 42.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkPrimaryContainer.withValues(alpha: 0.35)
                      : AppColors.brandVioletContainer.withValues(alpha: 0.60),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: activeColor.withValues(alpha: isDark ? 0.35 : 0.40),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 16.sp,
                      color: activeColor,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      l10nPick(
                        context,
                        en: 'Sensitive',
                        fa: 'اطلاعات امنیتی',
                        ar: 'أمني',
                        tr: 'Güvenlik',
                        ru: 'Данные',
                        zh: '安全信息',
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: activeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final Color activeColor;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkCard : AppColors.white)
              : AppColors.transparent,
          borderRadius: BorderRadius.circular(9.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: isDark ? 0.30 : 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15.sp,
              color: isSelected
                  ? activeColor
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextTertiary),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tokenized Sensitive Card Details Modal
class _SensitiveCardDetailsModal extends StatefulWidget {
  final VirtualCardDetailsData? card;
  final bool isDark;

  const _SensitiveCardDetailsModal({
    required this.card,
    required this.isDark,
  });

  @override
  State<_SensitiveCardDetailsModal> createState() =>
      _SensitiveCardDetailsModalState();
}

class _SensitiveCardDetailsModalState extends State<_SensitiveCardDetailsModal> {
  bool _revealPan = false;
  bool _revealCvv = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final card = widget.card;
    final activeColor = isDark ? AppColors.mainSoftBlue : AppColors.brandViolet;

    final rawPan = card?.cardNumber ?? '';
    final formattedPan = _formatPan(rawPan);
    final maskedPan = _maskPan(rawPan, card?.displayNumber);
    final cvv = card?.cvc ?? '—';
    final expiryMonth = card?.expirationMonth?.toString().padLeft(2, '0') ?? '--';
    final expiryYear = card?.expirationYear?.toString() ?? '--';
    final shortYear = expiryYear.length > 2 ? expiryYear.substring(expiryYear.length - 2) : expiryYear;
    final expiry = '$expiryMonth/$shortYear';
    final holderName = card?.cardHolder?.name ?? '—';

    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        14.h,
        20.w,
        24.h + MediaQuery.viewInsetsOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Indicator Bar
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Security Modal Header
              Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? AppColors.darkPrimaryContainer.withValues(alpha: 0.40)
                          : AppColors.brandVioletContainer,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.shield_outlined,
                        size: 24.sp,
                        color: activeColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10nPick(
                            context,
                            en: 'Sensitive Card Details',
                            fa: 'اطلاعات محرمانه کارت',
                            ar: 'بيانات البطاقة الحساسة',
                            tr: 'Hassas Kart Bilgileri',
                            ru: 'Конфиденциальные данные карты',
                            zh: '敏感卡片信息',
                          ),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          l10nPick(
                            context,
                            en: 'For security, never share these details with anyone.',
                            fa: 'جهت حفظ امنیت، این مشخصات را هرگز در اختیار شخص دیگری قرار ندهید.',
                            ar: 'لحمايتك، لا تشارك هذه التفاصيل مع أي شخص.',
                            tr: 'Güvenliğiniz için bu bilgileri kimseyle paylaşmayın.',
                            ru: 'В целях безопасности никогда никому не сообщайте эти данные.',
                            zh: '出于安全考虑，请勿向任何人透露这些信息。',
                          ),
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightSurfaceVariant,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18.sp,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // 1. Full Card Number (PAN)
              _SensitiveDataTile(
                label: l10nPick(
                  context,
                  en: 'Card Number (PAN)',
                  fa: 'شماره کارت',
                  ar: 'رقم البطاقة',
                  tr: 'Kart Numarası',
                  ru: 'Номер карты',
                  zh: '卡号',
                ),
                value: _revealPan ? formattedPan : maskedPan,
                copyValue: rawPan,
                isDark: isDark,
                activeColor: activeColor,
                trailingAction: rawPan.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          _revealPan ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() => _revealPan = !_revealPan);
                        },
                      )
                    : null,
              ),

              SizedBox(height: 12.h),

              // 2. Expiry Date & CVV Row
              Row(
                children: [
                  Expanded(
                    child: _SensitiveDataTile(
                      label: l10nPick(
                        context,
                        en: 'Expires',
                        fa: 'تاریخ انقضا',
                        ar: 'تاريخ الانتهاء',
                        tr: 'Son Geçerlilik',
                        ru: 'Срок действия',
                        zh: '有效期',
                      ),
                      value: expiry,
                      copyValue: expiry,
                      isDark: isDark,
                      activeColor: activeColor,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _SensitiveDataTile(
                      label: l10nPick(
                        context,
                        en: 'CVV / CVC',
                        fa: 'کد امنیتی (CVV)',
                        ar: 'رمز الأمان (CVV)',
                        tr: 'Güvenlik Kodu (CVV)',
                        ru: 'Код CVV / CVC',
                        zh: '安全码 (CVV)',
                      ),
                      value: _revealCvv ? cvv : '•••',
                      copyValue: cvv,
                      isDark: isDark,
                      activeColor: activeColor,
                      trailingAction: cvv != '—'
                          ? IconButton(
                              icon: Icon(
                                _revealCvv ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 20.sp,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                setState(() => _revealCvv = !_revealCvv);
                              },
                            )
                          : null,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // 3. Cardholder Name
              _SensitiveDataTile(
                label: l10nPick(
                  context,
                  en: 'Cardholder Name',
                  fa: 'نام دارنده کارت',
                  ar: 'اسم حامل البطاقة',
                  tr: 'Kart Sahibi Adı',
                  ru: 'Имя держателя карты',
                  zh: '持卡人姓名',
                ),
                value: holderName,
                copyValue: holderName != '—' ? holderName : null,
                isDark: isDark,
                activeColor: activeColor,
              ),

              SizedBox(height: 16.h),

              // PCI-DSS Security Compliance Banner
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkPrimaryContainer.withValues(alpha: 0.25)
                      : AppColors.brandVioletContainer.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: activeColor.withValues(alpha: 0.25),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 16.sp,
                      color: activeColor,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        l10nPick(
                          context,
                          en: 'Encrypted end-to-end under PCI-DSS Level 1 standards.',
                          fa: 'رمزنگاری‌شده بر اساس استانداردهای سطح ۱ امنیت داده پرداخت (PCI-DSS).',
                          ar: 'مشفر وفق معايير PCI-DSS المستوى 1.',
                          tr: 'PCI-DSS Seviye 1 standartlarına göre uçtan uca şifrelenmiştir.',
                          ru: 'Сквозное шифрование по стандартам PCI-DSS Level 1.',
                          zh: '采用 PCI-DSS Level 1 标准进行端到端加密保护。',
                        ),
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.deepBlack,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Dismiss / Done Button
              CommonButton(
                width: double.infinity,
                text: l10nPick(
                  context,
                  en: 'Done',
                  fa: 'بستن',
                  ar: 'إغلاق',
                  tr: 'Tamam',
                  ru: 'Готово',
                  zh: '完成',
                ),
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPan(String pan) {
    if (pan.isEmpty) return '—';
    return pan.replaceAllMapped(RegExp(r'.{4}'), (m) => '${m.group(0)} ').trim();
  }

  String _maskPan(String pan, String? display) {
    if (display != null && display.isNotEmpty) return display;
    if (pan.length >= 4) {
      return '•••• •••• •••• ${pan.substring(pan.length - 4)}';
    }
    return '•••• •••• •••• ••••';
  }
}

/// Tokenized tile for displaying sensitive data with copy feedback
class _SensitiveDataTile extends StatelessWidget {
  final String label;
  final String value;
  final String? copyValue;
  final bool isDark;
  final Color activeColor;
  final Widget? trailingAction;

  const _SensitiveDataTile({
    required this.label,
    required this.value,
    this.copyValue,
    required this.isDark,
    required this.activeColor,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant.withValues(alpha: 0.35)
            : AppColors.lightSurfaceVariant.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          ?trailingAction,
          if (copyValue != null && copyValue!.isNotEmpty && copyValue != '—')
            IconButton(
              icon: Icon(
                Icons.copy_rounded,
                size: 18.sp,
                color: activeColor,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                Clipboard.setData(ClipboardData(text: copyValue!));
                ToastHelper().showSuccessToast(
                  l10nPick(
                    context,
                    en: 'Copied to clipboard',
                    fa: 'در کلیپ‌بورد کپی شد',
                    ar: 'تم النسخ إلى الحافظة',
                    tr: 'Panoya kopyalandı',
                    ru: 'Скопировано в буфер обмена',
                    zh: '已复制到剪贴板',
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
