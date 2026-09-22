import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';

/// Static privacy & terms (Option B) — replaceable when server content exists.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _body = '''
حریم خصوصی و شرایط استفاده — eCardo

آخرین به‌روزرسانی: ۱۴۰۴

۱. داده‌هایی که جمع‌آوری می‌کنیم
اطلاعات هویتی و احراز هویت (مانند شماره موبایل و مدارک KYC)، اطلاعات تراکنش‌های مالی داخل اپ، و داده‌های فنی دستگاه برای امنیت و جلوگیری از تقلب.

۲. نحوه استفاده
ارائه خدمات کیف پول و انتقال، رعایت الزامات قانونی و مبارزه با پول‌شویی، بهبود امنیت حساب و اطلاع‌رسانی تراکنش‌ها.

۳. ذخیره‌سازی و امنیت
رمز عبور و PIN به‌صورت هش‌شده یا در فضای امن دستگاه نگهداری می‌شوند. ارتباط با سرور از طریق کانال امن انجام می‌شود. ما کلید PIN شما را به‌صورت متن ساده ذخیره نمی‌کنیم.

۴. اشتراک‌گذاری
داده‌ها فقط در چارچوب الزامات قانونی، ارائه‌دهندگان زیرساخت امن، یا با رضایت شما به اشتراک گذاشته می‌شود.

۵. حقوق شما
می‌توانید درخواست دسترسی، اصلاح یا حذف حساب را از طریق پشتیبانی ثبت کنید. حذف حساب ممکن است مشمول الزامات نگهداری قانونی باشد.

۶. شرایط استفاده
استفاده از اپ برای فعالیت غیرقانونی ممنوع است. مسئولیت حفظ رمز، PIN و دستگاه با کاربر است. eCardo در قبال دسترسی غیرمجاز ناشی از سهل‌انگاری کاربر مسئول نیست.

۷. تغییرات
ممکن است این متن به‌روز شود؛ نسخهٔ جدید از داخل اپ در دسترس خواهد بود.

برای پرسش: پشتیبانی داخل اپ یا کانال‌های رسمی eCardo.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('قوانین و حریم خصوصی'),
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Text(
          _body,
          style: const TextStyle(height: 1.55, fontSize: 14),
        ),
      ),
    );
  }
}
