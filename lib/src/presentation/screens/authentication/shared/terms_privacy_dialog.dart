import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/presentation/widgets/web_view_dynamic.dart';

/// Interactive modal sheet displaying eCardo Terms of Service and Privacy Pillars
/// with options for instant acceptance or full document review.
class TermsPrivacyDialog {
  const TermsPrivacyDialog._();

  static Future<bool?> show(
    BuildContext context, {
    VoidCallback? onAccept,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sheetBg = isDark ? const Color(0xFF111827) : AppColors.white;
    final titleColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextTertiary;

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.5.h,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.20)
                        : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? const [Color(0xFF38BDF8), Color(0xFF6366F1)]
                            : const [AppColors.deepBlack, Color(0xFF3F3F46)],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.verified_user_rounded,
                      color: Colors.white,
                      size: 20.sp,
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
                            en: 'Terms & Privacy Guarantee',
                            fa: 'قوانین و ضمانت حریم خصوصی',
                            ar: 'الشروط وضمان الخصوصية',
                            zh: '服务条款与隐私保障',
                            tr: 'Koşullar & Gizlilik Garantisi',
                            ru: 'Условия и гарантия приватности',
                          ),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            color: titleColor,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          l10nPick(
                            context,
                            en: 'Your security and rights are strictly protected.',
                            fa: 'امنیت و حقوق شما کاملاً محافظت شده است.',
                            ar: 'أمانك وحقوقك محمية بالكامل.',
                            zh: '您的安全与权益受到严格保护。',
                            tr: 'Güvenliğiniz ve haklarınız korunmaktadır.',
                            ru: 'Ваша безопасность строго защищена.',
                          ),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // 4 Trust Pillars
              _buildPillarRow(
                context,
                icon: Icons.lock_outline_rounded,
                title: l10nPick(
                  context,
                  en: 'Bank-Grade Security',
                  fa: 'امنیت بانکی و رمزنگاری پیشرفته',
                  ar: 'أمان بمستوى مصرفي',
                  zh: '银行级安全保障',
                  tr: 'Banka Düzeyinde Güvenlik',
                  ru: 'Банковский уровень защиты',
                ),
                desc: l10nPick(
                  context,
                  en: 'End-to-end AES-256 encryption & multi-signature asset segregation.',
                  fa: 'رمزنگاری سرتاسری و ذخیره‌سازی چندامضایی امن دارایی‌ها.',
                  ar: 'تشفير شامل وحفظ آمن للأصول بتوقيعات متعددة.',
                  zh: '端到端高级加密与多签资产隔离。',
                  tr: 'Uçtan uca şifreleme ve çoklu imzalı varlık koruması.',
                  ru: 'Сквозное шифрование и мультиподпись активов.',
                ),
                isDark: isDark,
              ),
              SizedBox(height: 12.h),
              _buildPillarRow(
                context,
                icon: Icons.privacy_tip_outlined,
                title: l10nPick(
                  context,
                  en: 'Zero Data Commercialization',
                  fa: 'عدم فروش داده‌ها به اشخاص ثالث',
                  ar: 'عدم المتاجرة بالبيانات',
                  zh: '绝不出售个人数据',
                  tr: 'Sıfır Veri Satışı',
                  ru: 'Нулевая продажа данных',
                ),
                desc: l10nPick(
                  context,
                  en: 'Your personal and financial records are never sold or shared.',
                  fa: 'اطلاعات شما هرگز فروخته یا بدون اجازه منتشر نمی‌شود.',
                  ar: 'بياناتك الشخصية والمالية لن تُباع أو تُشارك أبدًا.',
                  zh: '您的个人与财务信息绝不对外泄露。',
                  tr: 'Kişisel ve finansal kayıtlarınız asla satılmaz.',
                  ru: 'Ваши данные никогда не передаются третьим лицам.',
                ),
                isDark: isDark,
              ),
              SizedBox(height: 12.h),
              _buildPillarRow(
                context,
                icon: Icons.account_balance_outlined,
                title: l10nPick(
                  context,
                  en: 'Segregated Balance Protection',
                  fa: 'تفکیک و امنیت کامل موجودی',
                  ar: 'حماية الأرصدة المستقلة',
                  zh: '独立资金隔离保护',
                  tr: 'Ayrılmış Bakiye Koruması',
                  ru: 'Раздельное хранение средств',
                ),
                desc: l10nPick(
                  context,
                  en: 'Client funds are maintained separately from corporate operations.',
                  fa: 'موجودی کاربران در حساب‌های تفکیک‌شده و مجزا نگهداری می‌شود.',
                  ar: 'أموال العملاء محفوظة بشكل منفصل تمامًا عن عمليات الشركة.',
                  zh: '用户资金与公司运营账户严格分离。',
                  tr: 'Müşteri fonları şirket operasyonlarından ayrı tutulur.',
                  ru: 'Средства клиентов хранятся отдельно от операционных счетов.',
                ),
                isDark: isDark,
              ),

              SizedBox(height: 24.h),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Get.to(
                          () => WebViewDynamic(
                            dynamicUrl:
                                "${ApiPath.baseUrl}${ApiPath.termsAndConditionsEndpoint}",
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48.h),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.20)
                              : AppColors.lightBorder,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        l10nPick(
                          context,
                          en: 'Read Full Legal',
                          fa: 'مطالعه متن کامل',
                          ar: 'قراءة النص الكامل',
                          zh: '阅读完整条款',
                          tr: 'Metnin Tamamı',
                          ru: 'Полный текст',
                        ),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CommonButton(
                      height: 48,
                      borderRadius: 16.r,
                      text: l10nPick(
                        context,
                        en: 'Accept & Agree',
                        fa: 'می‌پذیرم و تأیید می‌کنم',
                        ar: 'أوافق وأؤكد',
                        zh: '同意并接受',
                        tr: 'Kabul Ediyorum',
                        ru: 'Принимаю',
                      ),
                      onPressed: () {
                        Navigator.pop(ctx, true);
                        onAccept?.call();
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildPillarRow(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String desc,
  required bool isDark,
}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 2.h),
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 16.sp,
            color: isDark ? const Color(0xFF38BDF8) : AppColors.deepBlack,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextTertiary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
