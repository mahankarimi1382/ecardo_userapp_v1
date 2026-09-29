import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Terms & Conditions and Privacy Policy screen with multi-language support.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final title = l10nPick(
      context,
      en: 'Terms & Privacy Policy',
      fa: 'قوانین و حریم خصوصی',
      ar: 'الشروط وسياسة الخصوصية',
      tr: 'Kullanım Koşulları ve Gizlilik',
      ru: 'Условия и конфиденциальность',
      zh: '服务条款与隐私政策',
    );

    final brandHeader = l10nPick(
      context,
      en: 'Privacy Policy & Terms of Service — Al Barakat',
      fa: 'حریم خصوصی و شرایط استفاده — Al Barakat',
      ar: 'سياسة الخصوصية وشروط الاستخدام — Al Barakat',
      tr: 'Gizlilik Politikası ve Kullanım Koşulları — Al Barakat',
      ru: 'Политика конфиденциальности и условия — Al Barakat',
      zh: '隐私政策与服务条款 — Al Barakat',
    );

    final lastUpdated = l10nPick(
      context,
      en: 'Last updated: 2025',
      fa: 'آخرین به‌روزرسانی: ۱۴۰۴',
      ar: 'آخر تحديث: ٢٠٢٥',
      tr: 'Son güncelleme: 2025',
      ru: 'Последнее обновление: 2025',
      zh: '最近更新：2025年',
    );

    final sec1Title = l10nPick(
      context,
      en: '1. Data We Collect',
      fa: '۱. داده‌هایی که جمع‌آوری می‌کنیم',
      ar: '١. البيانات التي نجمعها',
      tr: '1. Topladığımız Veriler',
      ru: '1. Собираемые данные',
      zh: '1. 我们收集的数据',
    );
    final sec1Body = l10nPick(
      context,
      en: 'Identity and verification information (such as mobile number and KYC documents), in-app financial transaction data, and device technical data for security and fraud prevention.',
      fa: 'اطلاعات هویتی و احراز هویت (مانند شماره موبایل و مدارک KYC)، اطلاعات تراکنش‌های مالی داخل اپ، و داده‌های فنی دستگاه برای امنیت و جلوگیری از تقلب.',
      ar: 'معلومات الهوية والتحقق (مثل رقم الهاتف ووثائق KYC)، بيانات المعاملات المالية داخل التطبيق، والبيانات الفنية للجهاز لتعزيز الأمان ومنع الاحتيال.',
      tr: 'Kimlik ve doğrulama bilgileri (cep telefonu numarası ve KYC belgeleri gibi), uygulama içi finansal işlem verileri ve güvenlik ile dolandırıcılığı önleme amaçlı teknik cihaz verileri.',
      ru: 'Идентификационная информация и данные верификации (номер телефона, документы KYC), сведения о финансовых операциях в приложении и технические данные устройства для безопасности и защиты от мошенничества.',
      zh: '身份与验证信息（例如手机号码和KYC认证文件）、应用内的金融交易数据，以及用于保障安全和防欺诈的设备技术信息。',
    );

    final sec2Title = l10nPick(
      context,
      en: '2. How We Use Information',
      fa: '۲. نحوه استفاده',
      ar: '٢. كيفية الاستخدام',
      tr: '2. Bilgilerin Kullanımı',
      ru: '2. Использование данных',
      zh: '2. 信息使用方式',
    );
    final sec2Body = l10nPick(
      context,
      en: 'Providing wallet and transfer services, complying with legal and anti-money laundering (AML) regulations, enhancing account security, and sending transaction notifications.',
      fa: 'ارائه خدمات کیف پول و انتقال، رعایت الزامات قانونی و مبارزه با پول‌شویی، بهبود امنیت حساب و اطلاع‌رسانی تراکنش‌ها.',
      ar: 'تقديم خدمات المحفظة والتحويلات، والامتثال للمتطلبات القانونية ومكافحة غسل الأموال، وتحسين أمان الحساب وإرسال إشعارات المعاملات.',
      tr: 'Cüzdan ve transfer hizmetleri sunmak, yasal gerekliliklere ve kara para aklamayı önleme (AML) standartlarına uymak, hesap güvenliğini artırmak ve işlem bildirimleri sağlamak.',
      ru: 'Предоставление услуг кошелька и переводов, соблюдение требований законодательства и противодействия отмыванию денег (AML), повышение безопасности аккаунта и оповещение о транзакциях.',
      zh: '提供电子钱包和转账服务、遵守法律法规与反洗钱（AML）要求、提高账户安全性以及发送交易动态通知。',
    );

    final sec3Title = l10nPick(
      context,
      en: '3. Storage & Security',
      fa: '۳. ذخیره‌سازی و امنیت',
      ar: '٣. التخزين والأمان',
      tr: '3. Depolama ve Güvenlik',
      ru: '3. Хранение и безопасность',
      zh: '3. 数据存储与安全',
    );
    final sec3Body = l10nPick(
      context,
      en: 'Passwords and PINs are securely hashed or stored in device-secure hardware storage. Server communications are encrypted. We never store your raw PIN in plain text.',
      fa: 'رمز عبور و PIN به‌صورت هش‌شده یا در فضای امن دستگاه نگهداری می‌شوند. ارتباط با سرور از طریق کانال امن انجام می‌شود. ما کلید PIN شما را به‌صورت متن ساده ذخیره نمی‌کنیم.',
      ar: 'يتم تخزين كلمات المرور ورقم PIN بشكل مشفر أو داخل مساحة التخزين الآمنة بالجهاز. يتم الاتصال بالخادم عبر قنوات مشفرة وآمنة. نحن لا نخزن رمز PIN الخاص بك كنص عادي أبداً.',
      tr: 'Şifreler ve PIN kodları şifrelenmiş veya cihazın güvenli donanımında saklanır. Sunucu iletişimi şifreli güvenli kanallar üzerinden gerçekleşir. PIN kodunuz asla açık metin olarak saklanmaz.',
      ru: 'Пароли и PIN-коды хранятся в зашифрованном виде или в защищенном хранилище устройства. Связь с сервером защищена сквозным шифрованием. Мы никогда не храним ваш PIN-код в открытом виде.',
      zh: '密码和PIN码均经过哈希加密处理或存储在设备的安全硬件环境中。所有与服务器的通信均采用加密传输。我们绝不会以明文形式存储您的PIN码。',
    );

    final sec4Title = l10nPick(
      context,
      en: '4. Data Sharing',
      fa: '۴. اشتراک‌گذاری',
      ar: '٤. مشاركة البيانات',
      tr: '4. Veri Paylaşımı',
      ru: '4. Передача данных',
      zh: '4. 数据共享',
    );
    final sec4Body = l10nPick(
      context,
      en: 'Data is only shared within legal requirements, with certified secure infrastructure providers, or with your explicit consent.',
      fa: 'داده‌ها فقط در چارچوب الزامات قانونی، ارائه‌دهندگان زیرساخت امن، یا با رضایت شما به اشتراک گذاشته می‌شود.',
      ar: 'لا تتم مشاركة البيانات إلا بموجب المتطلبات القانونية، أو مع مزودي البنية التحتية الآمنة، أو بموافقتك الصريحة.',
      tr: 'Veriler yalnızca yasal zorunluluklar kapsamında, güvenli altyapı sağlayıcılarıyla veya açık rızanız doğrultusunda paylaşılır.',
      ru: 'Данные передаются третьим лицам исключительно в рамках требований закона, проверенным поставщикам защищенной инфраструктуры либо с вашего явного согласия.',
      zh: '我们仅在法律法规明确要求、与经过安全认证的基础设施供应商合作，或在您明确同意的情况下共享必要数据。',
    );

    final sec5Title = l10nPick(
      context,
      en: '5. Your Rights',
      fa: '۵. حقوق شما',
      ar: '٥. حقوقك',
      tr: '5. Haklarınız',
      ru: '5. Ваши права',
      zh: '5. 您的权利',
    );
    final sec5Body = l10nPick(
      context,
      en: 'You may request access, correction, or deletion of your account through customer support. Account deletion remains subject to statutory regulatory retention requirements.',
      fa: 'می‌توانید درخواست دسترسی، اصلاح یا حذف حساب را از طریق پشتیبانی ثبت کنید. حذف حساب ممکن است مشمول الزامات نگهداری قانونی باشد.',
      ar: 'يمكنك طلب الوصول إلى بياناتك أو تعديلها أو حذف حسابك عبر فريق الدعم. قد يخضع حذف الحساب لمتطلبات الاحتفاظ القانونية.',
      tr: 'Müşteri desteği aracılığıyla hesap bilgilerinize erişim, düzeltme veya silme talebinde bulunabilirsiniz. Hesap silme işlemleri yasal saklama yükümlülüklerine tabi olabilir.',
      ru: 'Вы можете запросить доступ, изменение или удаление своей учетной записи через службу поддержки. Удаление аккаунта регулируется законодательными сроками обязательного хранения данных.',
      zh: '您可以通过客服中心申请访问、更正或注销您的账户。账户注销可能受到法定财务审计和监管保留期限的约束。',
    );

    final sec6Title = l10nPick(
      context,
      en: '6. Terms of Use',
      fa: '۶. شرایط استفاده',
      ar: '٦. شروط الاستخدام',
      tr: '6. Kullanım Koşulları',
      ru: '6. Условия использования',
      zh: '6. 使用条款',
    );
    final sec6Body = l10nPick(
      context,
      en: 'Using the app for unlawful activities is strictly prohibited. Users are responsible for safeguarding their password, PIN, and device. Al Barakat is not liable for unauthorized access resulting from user negligence.',
      fa: 'استفاده از اپ برای فعالیت غیرقانونی ممنوع است. مسئولیت حفظ رمز، PIN و دستگاه با کاربر است. Al Barakat در قبال دسترسی غیرمجاز ناشی از سهل‌انگاری کاربر مسئول نیست.',
      ar: 'يُحظر تماماً استخدام التطبيق لأي أنشطة غير قانونية. يتحمل المستخدم المسؤولية الكاملة عن حماية كلمة المرور ورمز PIN وجهازه. لا تتحمل Al Barakat أي مسؤولية عن الوصول غير المصرح به الناتج عن إهمال المستخدم.',
      tr: 'Uygulamanın yasa dışı faaliyetler için kullanılması kesinlikle yasaktır. Şifrenin, PIN kodunun ve cihazın güvenliğini sağlamak kullanıcının sorumluluğundadır. Al Barakat, kullanıcının ihmalinden kaynaklanan yetkisiz erişimlerden sorumlu değildir.',
      ru: 'Использование приложения для незаконной деятельности строго запрещено. Пользователь несет личную ответственность за сохранность пароля, PIN-кода и своего устройства. Al Barakat не несет ответственности за несанкционированный доступ, возникший по вине или неосторожности пользователя.',
      zh: '严禁使用本应用从事任何非法活动。用户须对自身密码、PIN码和设备的妥善保管负全责。因用户自身疏忽导致的任何未授权访问，Al Barakat 概不承担相关责任。',
    );

    final sec7Title = l10nPick(
      context,
      en: '7. Amendments & Support',
      fa: '۷. تغییرات و پشتیبانی',
      ar: '٧. التعديلات والدعم',
      tr: '7. Değişiklikler ve Destek',
      ru: '7. Изменения и поддержка',
      zh: '7. 条款更新与技术支持',
    );
    final sec7Body = l10nPick(
      context,
      en: 'These terms may be updated periodically; the latest version will always be accessible within the app.\n\nFor questions: Contact in-app support or official Al Barakat channels.',
      fa: 'ممکن است این متن به‌روز شود؛ نسخهٔ جدید از داخل اپ در دسترس خواهد بود.\n\nبرای هرگونه پرسش: پشتیبانی داخل اپ یا کانال‌های رسمی Al Barakat.',
      ar: 'قد يتم تحديث هذه الشروط دورياً؛ وستكون النسخة الأحدث متاحة دائماً داخل التطبيق.\n\nلأي استفسارات: يُرجى التواصل عبر الدعم داخل التطبيق أو القنوات الرسمية لـ Al Barakat.',
      tr: 'Bu şartlar periyodik olarak güncellenebilir; en güncel sürüme her zaman uygulama içinden erişilebilir.\n\nSorularınız için: Uygulama içi destek veya resmi Al Barakat kanalları ile iletişime geçebilirsiniz.',
      ru: 'Настоящие условия могут периодически обновляться; актуальная версия всегда доступна в приложении.\n\nПо любым вопросам: обратитесь в поддержку в приложении или официальные каналы Al Barakat.',
      zh: '本条款可能会定期修订；最新版本将随时在应用程序内公布。\n\n如有任何疑问：请联系应用内在线客服或通过 Al Barakat 官方渠道咨询。',
    );

    final sections = [
      (sec1Title, sec1Body),
      (sec2Title, sec2Body),
      (sec3Title, sec3Body),
      (sec4Title, sec4Body),
      (sec5Title, sec5Body),
      (sec6Title, sec6Body),
      (sec7Title, sec7Body),
    ];

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsetsDirectional.fromSTEB(
          AppSpacing.page,
          AppSpacing.page,
          AppSpacing.page,
          AppSpacing.bottomSafe(context, AppSpacing.page),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.lightPrimary.withValues(alpha: 0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brandHeader,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lastUpdated,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...sections.map(
              (sec) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sec.$1,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sec.$2,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.6,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
