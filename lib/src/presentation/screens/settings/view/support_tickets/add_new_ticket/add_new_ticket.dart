import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/multiple_image_picker_dropdown_bottom_sheet.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/add_new_ticket_controller.dart';

/// Department metadata for the Department/Topic selector.
class _DepartmentOption {
  final String id;
  final IconData icon;
  final Color color;

  const _DepartmentOption({
    required this.id,
    required this.icon,
    required this.color,
  });

  String label(BuildContext context) {
    switch (id) {
      case 'finance':
        return l10nPick(
          context,
          en: 'Finance & Payments',
          fa: 'مالی و پرداخت',
          ar: 'المالية والمدفوعات',
          tr: 'Finans ve Ödeme',
          ru: 'Финансы и платежи',
          zh: '财务与支付',
        );
      case 'technical':
        return l10nPick(
          context,
          en: 'Technical Issues',
          fa: 'مشکلات فنی',
          ar: 'مشاكل فنية',
          tr: 'Teknik Sorunlar',
          ru: 'Технические проблемы',
          zh: '技术问题',
        );
      case 'identity':
        return l10nPick(
          context,
          en: 'Identity & KYC',
          fa: 'احراز هویت',
          ar: 'التحقق من الهوية',
          tr: 'Kimlik Doğrulama',
          ru: 'Верификация личности',
          zh: '身份认证',
        );
      case 'travel':
        return l10nPick(
          context,
          en: 'Travel & Flights',
          fa: 'خدمات سفر و پرواز',
          ar: 'خدمات السفر والرحلات',
          tr: 'Seyahat ve Uçuşlar',
          ru: 'Путешествия и авиабилеты',
          zh: '旅行与航班',
        );
      case 'other':
      default:
        return l10nPick(
          context,
          en: 'Other / General',
          fa: 'سایر موارد',
          ar: 'أخرى',
          tr: 'Diğer',
          ru: 'Другое',
          zh: '其他',
        );
    }
  }
}

/// Priority metadata for the Priority selector.
class _PriorityOption {
  final String id;
  final IconData icon;
  final Color color;

  const _PriorityOption({
    required this.id,
    required this.icon,
    required this.color,
  });

  String label(BuildContext context) {
    switch (id) {
      case 'high':
        return l10nPick(
          context,
          en: 'Urgent',
          fa: 'فوری',
          ar: 'عاجل',
          tr: 'Acil',
          ru: 'Срочный',
          zh: '紧急',
        );
      case 'medium':
        return l10nPick(
          context,
          en: 'Important',
          fa: 'مهم',
          ar: 'مهم',
          tr: 'Önemli',
          ru: 'Важный',
          zh: '重要',
        );
      case 'low':
      default:
        return l10nPick(
          context,
          en: 'Normal',
          fa: 'عادی',
          ar: 'عادي',
          tr: 'Normal',
          ru: 'Обычный',
          zh: '普通',
        );
    }
  }
}

class AddNewTicket extends StatefulWidget {
  const AddNewTicket({super.key});

  @override
  State<AddNewTicket> createState() => _AddNewTicketState();
}

class _AddNewTicketState extends State<AddNewTicket> {
  final AddNewTicketController controller = Get.find();

  static const List<_DepartmentOption> _departments = [
    _DepartmentOption(
      id: 'finance',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF10B981),
    ),
    _DepartmentOption(
      id: 'technical',
      icon: Icons.terminal_rounded,
      color: Color(0xFF3B82F6),
    ),
    _DepartmentOption(
      id: 'identity',
      icon: Icons.verified_user_rounded,
      color: Color(0xFF8B5CF6),
    ),
    _DepartmentOption(
      id: 'travel',
      icon: Icons.flight_takeoff_rounded,
      color: Color(0xFF06B6D4),
    ),
    _DepartmentOption(
      id: 'other',
      icon: Icons.support_agent_rounded,
      color: Color(0xFFF59E0B),
    ),
  ];

  static const List<_PriorityOption> _priorities = [
    _PriorityOption(
      id: 'low',
      icon: Icons.shield_outlined,
      color: Color(0xFF10B981),
    ),
    _PriorityOption(
      id: 'medium',
      icon: Icons.priority_high_rounded,
      color: Color(0xFFF59E0B),
    ),
    _PriorityOption(
      id: 'high',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFEF4444),
    ),
  ];

  void _openAttachmentPicker() {
    HapticFeedback.lightImpact();
    final slotId = controller.addAttachmentSlot();
    Get.bottomSheet(
      MultipleImagePickerDropdownBottomSheet(attachmentId: slotId),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor =
        isDark ? AppColors.softGray : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppSpacing.cardGap),
              CommonAppBar(title: localization.addNewTicketScreenTitle),
              SizedBox(height: AppSpacing.sm),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: AppSpacing.page),
                  padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 20),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: const BorderRadiusDirectional.only(
                      topStart: Radius.circular(24),
                      topEnd: Radius.circular(24),
                    ),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1.0,
                    ),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, -2),
                            ),
                          ],
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Guidance Card
                        _buildGuidanceCard(context, isDark),
                        const SizedBox(height: 20),

                        // Auto-attached Transaction Context Card
                        _buildAttachedTransactionCard(context, isDark),

                        // Department / Topic Selector
                        _buildDepartmentSelector(
                          context,
                          isDark,
                          primaryTextColor,
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 20),

                        // Priority Selector
                        _buildPrioritySelector(
                          context,
                          isDark,
                          primaryTextColor,
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 20),

                        // Subject Input + Counter
                        _buildSubjectField(
                          context,
                          isDark,
                          primaryTextColor,
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 20),

                        // Message Input + Counter
                        _buildMessageField(
                          context,
                          isDark,
                          primaryTextColor,
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 20),

                        // Multi-attachment Uploader
                        _buildAttachmentUploader(
                          context,
                          isDark,
                          primaryTextColor,
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 28),

                        // Submit Button
                        _buildSubmitButton(context, isDark),
                        SizedBox(height: AppSpacing.bottomSafe(context, 20)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Obx(
            () => Visibility(
              visible: controller.isAddTicketLoading.value,
              child: const CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }

  /// Guidance card with tips on how to get faster support.
  Widget _buildGuidanceCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF6366F1).withValues(alpha: 0.08)
            : const Color(0xFF6366F1).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: isDark ? 0.35 : 0.22),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 17,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10nPick(
                    context,
                    en: 'Tips for Faster Support',
                    fa: 'راهنمای دریافت پاسخ سریع‌تر',
                    ar: 'إرشادات للحصول على رد أسرع',
                    tr: 'Hızlı Destek İpuçları',
                    ru: 'Советы для быстрого ответа',
                    zh: '快速获得支持的小贴士',
                  ),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: const Color(0xFF6366F1),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildTipItem(
            context,
            isDark,
            l10nPick(
              context,
              en: 'Provide Transaction ID (TXID) or reference code for payment issues.',
              fa: 'در صورت مشکل در پرداخت، شناسه تراکنش (TXID) یا شماره پیگیری را قید فرمایید.',
              ar: 'في مشاكل الدفع، يرجى ذكر معرف المعاملة (TXID) أو رمز المرجع.',
              tr: 'Ödeme sorunlarında işlem kimliği (TXID) veya referans kodunu belirtin.',
              ru: 'Для проблем с оплатой укажите ID транзакции (TXID) или чек.',
              zh: '如涉及支付问题，请务必提供交易单号（TXID）或凭据。',
            ),
          ),
          const SizedBox(height: 6),
          _buildTipItem(
            context,
            isDark,
            l10nPick(
              context,
              en: 'Attach clear screenshots of the error for faster technical review.',
              fa: 'بارگذاری اسکرین‌شات از صفحه خطا به کارشناسان در بررسی سریع‌تر کمک می‌کند.',
              ar: 'إرفاق لقطة شاشة للخطأ يساعد الخبراء على المراجعة السريعة.',
              tr: 'Hata ekran görüntüsü eklemek incelemeyi hızlandırır.',
              ru: 'Скриншот экрана ошибки ускорит рассмотрение обращения.',
              zh: '上传清晰的错误截图有助于技术人员更快排查。',
            ),
          ),
          const SizedBox(height: 6),
          _buildTipItem(
            context,
            isDark,
            l10nPick(
              context,
              en: 'Submit separate tickets for different issues for better tracking.',
              fa: 'برای هر مشکل مستقل یک تیکت مجزا ثبت کنید تا رسیدگی دقیق‌تر انجام شود.',
              ar: 'يرجى تقديم تذكرة منفصلة لكل مشكلة لتتبع أفضل.',
              tr: 'Daha iyi takip için farklı sorunlar için ayrı talep oluşturun.',
              ru: 'Создавайте отдельный тикет для каждого вопроса.',
              zh: '不同问题请分别提交工单，以便更有针对性地处理。',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachedTransactionCard(BuildContext context, bool isDark) {
    return Obx(() {
      final ref = controller.attachedTransactionRef.value;
      if (ref == null || ref.isEmpty) return const SizedBox.shrink();

      final amount = controller.attachedAmount.value;
      final currency = controller.attachedCurrency.value;
      final title = controller.attachedTitle.value;

      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCard
              : AppColors.lightSecondaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isDark
                ? AppColors.mainSoftBlue.withValues(alpha: 0.45)
                : AppColors.brandViolet.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.mainSoftBlue : AppColors.brandViolet)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10nPick(
                            context,
                            en: 'Auto-Attached Transaction',
                            fa: 'تراکنش ضمیمه‌شده خودکار',
                            ar: 'معاملة مرفقة تلقائياً',
                            tr: 'Otomatik Eklenen İşlem',
                            ru: 'Прикрепленная транзакция',
                          ),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                      if (title != null && title.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.softGray : AppColors.lightTextSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ref,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (amount != null && amount.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$amount ${currency ?? ""}'.trim(),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              tooltip: l10nPick(context, en: 'Remove', fa: 'حذف پیوست'),
              onPressed: () {
                HapticFeedback.lightImpact();
                controller.attachedTransactionRef.value = null;
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTipItem(BuildContext context, bool isDark, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.softGray : AppColors.lightTextSecondary,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// Department / Topic Selector.
  Widget _buildDepartmentSelector(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10nPick(
                context,
                en: 'Department / Topic',
                fa: 'دپارتمان / موضوع',
                ar: 'القسم / الموضوع',
                tr: 'Bölüm / Konu',
                ru: 'Отдел / Тема',
                zh: '部门 / 类别',
              ),
              style: AppTextStyles.labelMedium.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _departments.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final dept = _departments[index];
              return Obx(() {
                final isSelected = controller.selectedDepartment.value == dept.id;

                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.selectedDepartment.value = dept.id;
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? dept.color.withValues(alpha: isDark ? 0.22 : 0.12)
                          : (isDark
                              ? AppColors.darkBackground
                              : AppColors.lightBackground),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? dept.color
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                        width: isSelected ? 1.4 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: dept.color.withValues(alpha: 0.22),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          dept.icon,
                          size: 18,
                          color: isSelected ? dept.color : secondaryColor,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          dept.label(context),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected ? dept.color : secondaryColor,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  /// Priority Selector with distinctive colored badges (عادی، مهم، فوری).
  Widget _buildPrioritySelector(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10nPick(
                context,
                en: 'Priority Level',
                fa: 'اولویت بررسی',
                ar: 'مستوى الأولوية',
                tr: 'Öncelik Seviyesi',
                ru: 'Уровень приоритета',
                zh: '优先级',
              ),
              style: AppTextStyles.labelMedium.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: _priorities.map((priority) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Obx(() {
                  final isSelected = controller.selectedPriority.value == priority.id;

                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      controller.selectedPriority.value = priority.id;
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? priority.color.withValues(alpha: isDark ? 0.22 : 0.12)
                            : (isDark
                                ? AppColors.darkBackground
                                : AppColors.lightBackground),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? priority.color
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                          width: isSelected ? 1.4 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: priority.color.withValues(alpha: 0.22),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            priority.icon,
                            size: 16,
                            color: isSelected ? priority.color : secondaryColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            priority.label(context),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isSelected ? priority.color : secondaryColor,
                              fontWeight:
                                  isSelected ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Subject input with character counter.
  Widget _buildSubjectField(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final localization = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  localization.addNewTicketTitle,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const Text(
                  ' *',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Obx(
              () => Text(
                '${controller.titleLength.value} / 100',
                style: AppTextStyles.labelSmall.copyWith(
                  color: controller.titleLength.value > 90
                      ? AppColors.error
                      : secondaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: controller.isTitleFocused.value
                    ? (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                width: controller.isTitleFocused.value ? 1.4 : 1.0,
              ),
            ),
            child: TextField(
              focusNode: controller.titleFocusNode,
              controller: controller.titleController,
              maxLength: 100,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                  null,
              style: AppTextStyles.bodyMedium.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                hintText: l10nPick(
                  context,
                  en: 'e.g. Issue depositing funds to wallet...',
                  fa: 'مثال: عدم اعمال واریزی به کیف پول...',
                  ar: 'مثال: مشكلة في إيداع الرصيد في المحفظة...',
                  tr: 'Örn: Cüzdana para yatırma sorunu...',
                  ru: 'Например: Проблема с пополнением кошелька...',
                  zh: '例如：钱包充值未到账...',
                ),
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: secondaryColor.withValues(alpha: 0.6),
                  fontSize: 12.5,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Message input with character counter.
  Widget _buildMessageField(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final localization = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  localization.addNewTicketDescription,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const Text(
                  ' *',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Obx(
              () => Text(
                '${controller.descriptionLength.value} / 1000',
                style: AppTextStyles.labelSmall.copyWith(
                  color: controller.descriptionLength.value > 950
                      ? AppColors.error
                      : secondaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: controller.isDescriptionFocused.value
                    ? (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                width: controller.isDescriptionFocused.value ? 1.4 : 1.0,
              ),
            ),
            child: TextField(
              focusNode: controller.descriptionFocusNode,
              controller: controller.descriptionController,
              minLines: 4,
              maxLines: 7,
              maxLength: 1000,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                  null,
              style: AppTextStyles.bodyMedium.copyWith(
                color: primaryColor,
                fontSize: 13,
                height: 1.45,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(14),
                hintText: l10nPick(
                  context,
                  en: 'Describe the issue clearly with relevant details (e.g. transaction ID, date, error message)...',
                  fa: 'شرح کامل مشکل را بنویسید (در صورت وجود، شناسه تراکنش یا کد پیگیری را قید فرمایید)...',
                  ar: 'يرجى وصف المشكلة بالتفصيل (يرجى إرفاق معرف المعاملة إن وجد)...',
                  tr: 'Sorunu ayrıntılı açıklayın (varsa işlem kimliğini belirtin)...',
                  ru: 'Подробно опишите проблему (при наличии укажите ID транзакции)...',
                  zh: '请详细描述您遇到的问题（如涉及交易请提供交易单号）...',
                ),
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: secondaryColor.withValues(alpha: 0.6),
                  fontSize: 12.5,
                  height: 1.4,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Multi-attachment uploader: visual drag/tap zone with thumbnail strip and delete buttons.
  Widget _buildAttachmentUploader(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final localization = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  localization.addNewTicketAttachments,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: (isDark
                            ? AppColors.darkBackground
                            : AppColors.lightBackground),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l10nPick(
                      context,
                      en: 'Optional',
                      fa: 'اختیاری',
                      ar: 'اختياري',
                      tr: 'İsteğe bağlı',
                      ru: 'Необязательно',
                      zh: '选填',
                    ),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: secondaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Obx(() {
              final count =
                  controller.multipleImagePickerController.attachedImages.length;
              if (count == 0) return const SizedBox.shrink();
              return Text(
                '$count ${l10nPick(context, en: 'files attached', fa: 'فایل پیوست شد', ar: 'ملفات مرفقة', tr: 'dosya eklendi', ru: 'файлов прикреплено', zh: '个文件')}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 10),

        // Visual Drag / Tap Zone
        InkWell(
          onTap: _openAttachmentPicker,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBackground.withValues(alpha: 0.6)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorder
                    : const Color(0xFFCBD5E1),
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (isDark
                            ? AppColors.mainSoftBlue
                            : AppColors.lightPrimary)
                        .withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_upload_outlined,
                    size: 24,
                    color: isDark
                        ? AppColors.mainSoftBlue
                        : AppColors.lightPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10nPick(
                    context,
                    en: 'Tap to browse or upload images',
                    fa: 'برای بارگذاری تصویر یا مدرک کلیک کنید',
                    ar: 'انقر لتحميل الصور أو المستندات',
                    tr: 'Görsel yüklemek için dokunun',
                    ru: 'Нажмите для загрузки изображений',
                    zh: '点击上传图片或凭据',
                  ),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  l10nPick(
                    context,
                    en: 'Supported formats: PNG, JPG (Max 5MB each)',
                    fa: 'فرمت‌های مجاز: PNG, JPG (حداکثر ۵ مگابایت)',
                    ar: 'الصيغ المدعومة: PNG, JPG (الحد الأقصى 5 ميجابايت)',
                    tr: 'Desteklenen: PNG, JPG (Maks. 5 MB)',
                    ru: 'Форматы: PNG, JPG (макс. 5 МБ)',
                    zh: '支持格式：PNG、JPG（单个文件不超过5MB）',
                  ),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: secondaryColor.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        // Thumbnail Strip
        Obx(() {
          final attachedEntries =
              controller.multipleImagePickerController.attachedImages.entries.toList();
          if (attachedEntries.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: attachedEntries.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    if (index == attachedEntries.length) {
                      // Add More Tile
                      return InkWell(
                        onTap: _openAttachmentPicker,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 88,
                          height: 96,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkBackground
                                : AppColors.lightBackground,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline_rounded,
                                size: 22,
                                color: isDark
                                    ? AppColors.mainSoftBlue
                                    : AppColors.lightPrimary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10nPick(
                                  context,
                                  en: 'Add more',
                                  fa: 'افزودن',
                                  ar: 'إضافة',
                                  tr: 'Ekle',
                                  ru: 'Добавить',
                                  zh: '添加',
                                ),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: secondaryColor,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final entry = attachedEntries[index];
                    final file = entry.value;
                    final fileSizeKb = _getFileSize(file);

                    return Stack(
                      children: [
                        Container(
                          width: 88,
                          height: 96,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  file,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    color: Colors.black.withValues(alpha: 0.6),
                                    child: Text(
                                      fileSizeKb,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Delete Button
                        PositionedDirectional(
                          top: 4,
                          end: 4,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              controller.removeAttachment(entry.key);
                            },
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  String _getFileSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(0)} KB';
      } else {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (_) {
      return '';
    }
  }

  /// Submit Button.
  Widget _buildSubmitButton(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF4F46E5), Color(0xFF7C3AED)]
              : const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.38),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            HapticFeedback.mediumImpact();
            if (!controller.validateForm()) {
              return;
            }
            await controller.addNewTicket();
          },
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  l10nPick(
                    context,
                    en: 'Submit Ticket',
                    fa: 'ثبت و ارسال تیکت',
                    ar: 'إرسال التذكرة',
                    tr: 'Talebi Gönder',
                    ru: 'Отправить тикет',
                    zh: '提交工单',
                  ),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
