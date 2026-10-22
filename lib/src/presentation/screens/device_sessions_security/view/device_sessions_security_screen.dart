import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/services/app_lock_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/device_sessions_security/controller/device_sessions_controller.dart';
import 'package:ecardo_user/src/presentation/screens/device_sessions_security/model/device_session_model.dart';
import 'package:ecardo_user/src/presentation/screens/device_sessions_security/view/widgets/other_session_card.dart';
import 'package:ecardo_user/src/presentation/screens/device_sessions_security/view/widgets/terminate_all_button.dart';
import 'package:ecardo_user/src/presentation/screens/device_sessions_security/view/widgets/this_device_hero_card.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/settings_screen.dart';

/// Screen providing comprehensive device session and security controls:
/// - "This Device" hero card with pulsating active indicator and OS/IP badge
/// - "Other Active Devices" list with individual revocation actions
/// - "Terminate All Other Sessions" destructive emergency button
/// - Biometric App Lock & PIN quick settings
/// - Audit log of recent security events
class DeviceSessionsSecurityScreen extends StatefulWidget {
  const DeviceSessionsSecurityScreen({super.key});

  @override
  State<DeviceSessionsSecurityScreen> createState() =>
      _DeviceSessionsSecurityScreenState();
}

class _DeviceSessionsSecurityScreenState
    extends State<DeviceSessionsSecurityScreen> {
  late final DeviceSessionsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DeviceSessionsController());
  }

  Future<void> _chooseAutoLock() async {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final textColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;

    final snackMsg = l10nPick(
      context,
      en: 'Auto-lock duration updated',
      fa: 'زمان‌بندی قفل خودکار تنظیم شد',
      ar: 'تم تحديث مدة القفل التلقائي',
      zh: '自动锁定时间已更新',
    );

    final v = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: Text(
                l10nPick(
                  context,
                  en: 'Auto App Lock Duration',
                  fa: 'مدت زمان قفل خودکار اپلیکیشن',
                  ar: 'مدة القفل التلقائي',
                  zh: '自动锁定时间',
                ),
                style: AppTextStyles.titleMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(
              height: 1,
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
            for (final e in {
              -1: l10nPick(
                context,
                en: 'Immediately (every time you leave)',
                fa: 'فوری (با هر بار خروج از اپ)',
              ),
              1: l10nPick(context, en: '1 minute', fa: '۱ دقیقه'),
              5: l10nPick(context, en: '5 minutes', fa: '۵ دقیقه'),
              15: l10nPick(context, en: '15 minutes', fa: '۱۵ دقیقه'),
              0: l10nPick(context, en: 'Never', fa: 'هرگز'),
            }.entries)
              ListTile(
                title: Text(
                  e.value,
                  style: AppTextStyles.bodyMedium.copyWith(color: textColor),
                ),
                trailing: controller.lockMinutes.value == e.key
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 20.sp,
                      )
                    : null,
                onTap: () => Navigator.pop(ctx, e.key),
              ),
            SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );

    if (v != null && mounted) {
      if (Get.isRegistered<SettingsService>()) {
        await Get.find<SettingsService>().setAppLockMinutes(v);
      }
      controller.lockMinutes.value = v;
      ToastHelper().showSuccessToast(snackMsg);
    }
  }

  Future<void> _changePin() async {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final textColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;

    if (controller.hasPinSet.value && Get.isRegistered<AppLockService>()) {
      final cOld = TextEditingController();
      final okOld = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          title: Text(
            l10nPick(context, en: 'Enter Current PIN', fa: 'ورود PIN فعلی'),
            style: AppTextStyles.titleMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: TextField(
            controller: cOld,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            autofocus: true,
            style: AppTextStyles.titleLarge.copyWith(
              color: textColor,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              hintText: '••••',
              hintStyle: TextStyle(
                color: isDark ? AppColors.softGray : AppColors.lightTextHint,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(l10nPick(context, en: 'Cancel', fa: 'انصراف')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.mainSoftBlue
                    : AppColors.lightPrimary,
                foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
              onPressed: () => Get.back(result: true),
              child: Text(l10nPick(context, en: 'Confirm', fa: 'تأیید')),
            ),
          ],
        ),
      );
      if (okOld != true || !mounted) return;
      final valid = await Get.find<AppLockService>().verifyPin(cOld.text);
      if (!valid) {
        if (!mounted) return;
        ToastHelper().showErrorToast(
          l10nPick(context, en: 'Incorrect PIN', fa: 'PIN فعلی نادرست است'),
        );
        return;
      }
    }

    if (!mounted) return;
    await _setAppPin();
  }

  Future<void> _setAppPin() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final textColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;

    final c1 = TextEditingController();
    final c2 = TextEditingController();

    final dialogTitle = l10nPick(
      context,
      en: 'Set 4-digit App Lock PIN',
      fa: 'تنظیم PIN ۴ رقمی قفل اپ',
    );
    final pinLabel1 = l10nPick(
      context,
      en: 'New 4-digit PIN',
      fa: 'PIN جدید (۴ رقم)',
    );
    final pinLabel2 = l10nPick(context, en: 'Repeat PIN', fa: 'تکرار PIN');
    final cancelLabel = l10nPick(context, en: 'Cancel', fa: 'انصراف');
    final saveLabel = l10nPick(context, en: 'Save', fa: 'ذخیره');
    final auditTitle = l10nPick(
      context,
      en: 'App Lock PIN Updated',
      fa: 'تغییر PIN قفل اپ',
    );
    final auditDesc = l10nPick(
      context,
      en: 'Device unlock passcode was set / updated',
      fa: 'رمز عبور قفل محلی دستگاه با موفقیت تنظیم یا تغییر یافت',
    );
    final snackSaved = l10nPick(
      context,
      en: 'PIN saved successfully',
      fa: 'PIN با موفقیت ذخیره شد',
    );
    final snackMismatch = l10nPick(
      context,
      en: 'The PIN must be 4 digits and match',
      fa: 'PIN باید ۴ رقم و یکسان باشد',
    );

    final ok = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(
          dialogTitle,
          style: AppTextStyles.titleMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: c1,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              autofocus: true,
              style: AppTextStyles.titleMedium.copyWith(
                color: textColor,
                letterSpacing: 6,
              ),
              decoration: InputDecoration(
                labelText: pinLabel1,
                labelStyle: TextStyle(
                  color: isDark
                      ? AppColors.softGray
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            TextField(
              controller: c2,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              style: AppTextStyles.titleMedium.copyWith(
                color: textColor,
                letterSpacing: 6,
              ),
              decoration: InputDecoration(
                labelText: pinLabel2,
                labelStyle: TextStyle(
                  color: isDark
                      ? AppColors.softGray
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.mainSoftBlue
                  : AppColors.lightPrimary,
              foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ),
            onPressed: () => Get.back(result: true),
            child: Text(saveLabel),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (ok == true && c1.text.length == 4 && c1.text == c2.text) {
      if (Get.isRegistered<AppLockService>()) {
        await Get.find<AppLockService>().setPin(c1.text);
      }
      controller.hasPinSet.value = true;
      controller.addAudit(
        title: auditTitle,
        description: auditDesc,
        type: SecurityAuditType.pinChange,
      );
      ToastHelper().showSuccessToast(snackSaved);
    } else if (ok == true) {
      ToastHelper().showErrorToast(snackMismatch);
    }
  }

  String _lockLabel(int m) {
    if (m < 0) return l10nPick(context, en: 'Immediately', fa: 'فوری');
    if (m == 0) return l10nPick(context, en: 'Never', fa: 'هرگز');
    if (m == 1) return l10nPick(context, en: '1 minute', fa: '۱ دقیقه');
    return l10nPick(context, en: '$m minutes', fa: '$m دقیقه');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          l10nPick(
            context,
            en: 'Devices & Active Sessions',
            fa: 'دستگاه‌ها و نشست‌های فعال',
            ar: 'الأجهزة والجلسات النشطة',
            zh: '设备与活动会话',
          ),
          style: AppTextStyles.titleMedium.copyWith(
            color: primaryTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: bgColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: l10nPick(
              context,
              en: 'Refresh',
              fa: 'به‌روزرسانی',
              ar: 'تحديث',
              zh: '刷新',
            ),
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.refreshSessions(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingSkeleton(isDark);
        }

        final curr = controller.currentDevice.value;

        return RefreshIndicator(
          onRefresh: () => controller.refreshSessions(context),
          color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsetsDirectional.fromSTEB(
              AppSpacing.page,
              AppSpacing.sm,
              AppSpacing.page,
              AppSpacing.bottomSafe(context, AppSpacing.xxxl),
            ),
            children: [
              // 1. "This Device" Hero Card
              if (curr != null)
                ThisDeviceHeroCard(device: curr, isDark: isDark),

              SizedBox(height: AppSpacing.xl),

              // 2. "Other Active Devices" Section
              _buildOtherDevicesSection(isDark),

              SizedBox(height: AppSpacing.lg),

              // 3. Emergency Red Action: Terminate All Other Sessions
              TerminateAllButton(
                otherCount: controller.otherSessions.length,
                isDark: isDark,
                onTerminateAll: () =>
                    controller.terminateAllOtherSessions(context),
              ),

              SizedBox(height: AppSpacing.xxl),

              // 4. Biometric App Lock & PIN Quick Settings Section
              _buildBiometricAndLockSection(isDark),

              SizedBox(height: AppSpacing.xxl),

              // 5. Security Activity Audit Log
              _buildSecurityAuditLogSection(isDark),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLoadingSkeleton(bool isDark) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.page),
      children: [
        Container(
          height: 180.h,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary,
              strokeWidth: 2.5,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 2. "Other Active Devices" Section
  // ==========================================
  Widget _buildOtherDevicesSection(bool isDark) {
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: 4.w,
            bottom: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Text(
                l10nPick(
                  context,
                  en: 'Other Active Devices',
                  fa: 'سایر نشست‌های فعال',
                  ar: 'الأجهزة النشطة الأخرى',
                  zh: '其他活动设备',
                ),
                style: AppTextStyles.titleSmall.copyWith(
                  color: primaryTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: controller.otherSessions.isNotEmpty
                      ? (isDark
                            ? AppColors.mainSoftBlue.withValues(alpha: 0.2)
                            : AppColors.lightPrimary.withValues(alpha: 0.12))
                      : (isDark
                            ? AppColors.darkCard
                            : AppColors.greyLight.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  '${controller.otherSessions.length}',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: controller.otherSessions.isNotEmpty
                        ? (isDark
                              ? AppColors.mainSoftBlue
                              : AppColors.lightPrimary)
                        : (isDark ? AppColors.softGray : AppColors.greyDark),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (controller.otherSessions.isEmpty)
          _buildEmptyOtherSessionsCard(isDark)
        else
          Column(
            children: controller.otherSessions
                .map(
                  (session) => Dismissible(
                    key: ValueKey(session.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      HapticFeedback.mediumImpact();
                      return await controller
                          .confirmAndRevokeSessionWithBottomSheet(
                            context,
                            session,
                          );
                    },
                    background: Container(
                      margin: EdgeInsets.only(bottom: AppSpacing.md),
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      alignment: AlignmentDirectional.centerEnd,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: AppColors.white,
                            size: 22.sp,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            l10nPick(
                              context,
                              en: 'Terminate',
                              fa: 'خروج از نشست',
                              ar: 'إنهاء',
                              zh: '终止会话',
                            ),
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    child: OtherSessionCard(
                      session: session,
                      isDark: isDark,
                      onRevoke: () =>
                          controller.revokeSession(context, session),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyOtherSessionsCard(bool isDark) {
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark
        ? AppColors.softGray
        : AppColors.lightTextSecondary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.8,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.gpp_good_rounded,
              color: AppColors.success,
              size: 32.sp,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            l10nPick(
              context,
              en: 'No Other Active Sessions',
              fa: 'هیچ نشست فعال دیگری وجود ندارد',
              ar: 'لا توجد جلسات نشطة أخرى',
              zh: '无其他活动会话',
            ),
            style: AppTextStyles.titleSmall.copyWith(
              color: primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            l10nPick(
              context,
              en: 'Your account is exclusively accessed from this device.',
              fa: 'حساب کاربری شما تنها روی همین دستگاه فعال است.',
              ar: 'يتم استخدام حسابك حصريًا من هذا الجهاز.',
              zh: '您的账户目前仅在此设备上登录。',
            ),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(color: secondaryTextColor),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. Biometric App Lock & PIN Quick Settings Section
  // ==========================================
  Widget _buildBiometricAndLockSection(bool isDark) {
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark
        ? AppColors.softGray
        : AppColors.lightTextSecondary;

    final bioStyle = SettingsIconTokens.biometric(isDark: isDark);
    final autoLockStyle = SettingsIconTokens.autoAppLock(isDark: isDark);
    final pinStyle = SettingsIconTokens.appLockPin(isDark: isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: 4.w,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            l10nPick(
              context,
              en: 'Biometric & Local App Lock',
              fa: 'تنظیمات قفل اپلیکیشن و بیومتریک',
              ar: 'قفل التطبيق والمصادقة البيومترية',
              zh: '生物识别与应用锁定',
            ),
            style: AppTextStyles.titleSmall.copyWith(
              color: primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.8,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6.h,
          ),
          child: Column(
            children: [
              // Biometric toggle
              if (controller.bioSupported.value)
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: bioStyle.backgroundColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(
                      Icons.fingerprint_rounded,
                      color: bioStyle.iconColor,
                      size: 22.sp,
                    ),
                  ),
                  title: Text(
                    l10nPick(
                      context,
                      en: 'Biometric Sign In / Unlock',
                      fa: 'ورود با اثر انگشت یا چهره',
                      ar: 'الدخول بالبصمة أو الوجه',
                      zh: '指纹或面容快速解锁',
                    ),
                    style: AppTextStyles.titleSmall.copyWith(
                      color: primaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    controller.bioEnabled.value
                        ? l10nPick(
                            context,
                            en: 'Enabled — quick security check',
                            fa: 'فعال — ورود سریع و امن',
                          )
                        : l10nPick(
                            context,
                            en: 'Sign in with your fingerprint or face',
                            fa: 'قفل‌گشایی سریع با بیومتریک این دستگاه',
                          ),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                  value: controller.bioEnabled.value,
                  activeTrackColor: isDark
                      ? AppColors.mainSoftBlue
                      : AppColors.lightPrimary,
                  onChanged: (val) => controller.toggleBiometric(val, context),
                )
              else
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkCard
                          : AppColors.greyLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(
                      Icons.fingerprint_rounded,
                      color: AppColors.softGray,
                      size: 22.sp,
                    ),
                  ),
                  title: Text(
                    l10nPick(
                      context,
                      en: 'Biometric Authentication',
                      fa: 'احراز هویت بیومتریک',
                    ),
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isDark ? AppColors.softGray : AppColors.greyDark,
                    ),
                  ),
                  subtitle: Text(
                    l10nPick(
                      context,
                      en: 'Not supported or not configured on this hardware',
                      fa: 'سخت‌افزار بیومتریک روی این دستگاه فعال نیست',
                    ),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.softGray,
                    ),
                  ),
                ),

              Divider(
                height: 1,
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),

              // Auto App Lock duration
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: autoLockStyle.backgroundColor,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    Icons.timer_outlined,
                    color: autoLockStyle.iconColor,
                    size: 22.sp,
                  ),
                ),
                title: Text(
                  l10nPick(
                    context,
                    en: 'Auto App Lock',
                    fa: 'قفل خودکار اپلیکیشن',
                    ar: 'قفل التطبيق التلقائي',
                    zh: '应用自动锁定',
                  ),
                  style: AppTextStyles.titleSmall.copyWith(
                    color: primaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _lockLabel(controller.lockMinutes.value),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _lockLabel(controller.lockMinutes.value),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isDark
                            ? AppColors.mainSoftBlue
                            : AppColors.lightPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.chevron_left_rounded
                          : Icons.chevron_right_rounded,
                      color: isDark ? AppColors.softGray : AppColors.grey,
                      size: 20.sp,
                    ),
                  ],
                ),
                onTap: _chooseAutoLock,
              ),

              Divider(
                height: 1,
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),

              // App Lock PIN
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: pinStyle.backgroundColor,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    Icons.pin_outlined,
                    color: pinStyle.iconColor,
                    size: 22.sp,
                  ),
                ),
                title: Text(
                  l10nPick(
                    context,
                    en: 'App Lock PIN',
                    fa: 'PIN قفل دستگاه',
                    ar: 'رمز قفل التطبيق',
                    zh: '应用锁定PIN',
                  ),
                  style: AppTextStyles.titleSmall.copyWith(
                    color: primaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  controller.hasPinSet.value
                      ? l10nPick(
                          context,
                          en: 'Active • Tap to change',
                          fa: 'تنظیم شده • برای تغییر کلیک کنید',
                        )
                      : l10nPick(
                          context,
                          en: 'Not configured • Tap to set 4 digits',
                          fa: 'تنظیم نشده • برای تعیین ۴ رقم کلیک کنید',
                        ),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: controller.hasPinSet.value
                        ? AppColors.success
                        : secondaryTextColor,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: controller.hasPinSet.value
                            ? AppColors.success.withValues(alpha: 0.12)
                            : AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: Text(
                        controller.hasPinSet.value
                            ? l10nPick(context, en: 'Configured', fa: 'فعال')
                            : l10nPick(
                                context,
                                en: 'Not set',
                                fa: 'تنظیم نشده',
                              ),
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: controller.hasPinSet.value
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.chevron_left_rounded
                          : Icons.chevron_right_rounded,
                      color: isDark ? AppColors.softGray : AppColors.grey,
                      size: 20.sp,
                    ),
                  ],
                ),
                onTap: _changePin,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 5. Security Activity Audit Log
  // ==========================================
  Widget _buildSecurityAuditLogSection(bool isDark) {
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark
        ? AppColors.softGray
        : AppColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 4.w, bottom: 4.h),
          child: Text(
            l10nPick(
              context,
              en: 'Security Activity Audit Log',
              fa: 'گزارش فعالیت‌های امنیتی',
              ar: 'سجل تدقيق النشاط الأمني',
              zh: '安全活动审计日志',
            ),
            style: AppTextStyles.titleSmall.copyWith(
              color: primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: 4.w,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            l10nPick(
              context,
              en: 'Recent sign-ins, password updates, and session events on your account.',
              fa: 'آخرین ورودها، تغییرات گذرواژه و رویدادهای حساس حساب شما.',
              ar: 'آخر عمليات تسجيل الدخول وتغييرات كلمة المرور على حسابك.',
              zh: '账户最近的登录记录、密码修改与安全事件。',
            ),
            style: AppTextStyles.bodySmall.copyWith(color: secondaryTextColor),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.8,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            children: [
              for (int i = 0; i < controller.auditLogs.length; i++) ...[
                _buildAuditLogTile(controller.auditLogs[i], isDark),
                if (i < controller.auditLogs.length - 1)
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.darkDivider
                        : AppColors.lightDivider,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuditLogTile(SecurityAuditLogItem item, bool isDark) {
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;
    final secondaryTextColor = isDark
        ? AppColors.softGray
        : AppColors.lightTextSecondary;

    final diff = DateTime.now().difference(item.timestamp);
    String relTime;
    if (diff.inMinutes < 60) {
      relTime = '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      relTime = '${diff.inHours}h ago';
    } else {
      relTime = '${diff.inDays}d ago';
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: item.iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 18.sp),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: primaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      relTime,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 10.sp,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  item.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: secondaryTextColor,
                    height: 1.35,
                  ),
                ),
                if (item.ipAddress != null || item.location != null) ...[
                  SizedBox(height: 4.h),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      if (item.ipAddress != null)
                        Text(
                          'IP: ${item.ipAddress}',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10.sp,
                            fontFamily: 'monospace',
                            color: secondaryTextColor,
                          ),
                        ),
                      if (item.location != null)
                        Text(
                          item.location!,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10.sp,
                            color: secondaryTextColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
