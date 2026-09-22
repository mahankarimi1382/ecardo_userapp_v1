# PRE_PUSH_CHECK — قبل از هر push روی ecardo_userapp_v1

هدف: جلوگیری از زنجیره بیلدهای قرمز analyze (الگوی 1.0.58–1.0.61).

## ۱) لیست فایل‌های تغییر یافته
```bash
git status -sb
git diff --name-only origin/main...HEAD
```

## ۲) هر import جدید
برای هر فایل تغییر یافته:
- نام پکیج / مسیر پروژه
- آیا `import ... as alias` دارد؟ (مثال خطرناک: `get as getx` → فقط `getx.Get`)
- آیا پکیج در `pubspec.yaml` هست؟
- آیا پکیج discontinued است یا AGP/namespace می‌خواهد؟

## ۳) نمادهای جدید/تغییر یافته + call-site
- **static vs instance**: اگر `Foo.bar()` نوشتی، واقعاً `static` است؟
- **alias**: در فایل‌هایی که `import 'package:get/get.dart' as getx` دارند هرگز `Get.` ننویس.
- جستجو: `rg "ClassName\.|methodName\(" lib`

## ۴) تغییر pubspec
- نسخه دقیق پکیج
- اگر پلاگین Android: `android/build.gradle` داخل پکیج باید `namespace` داشته باشد (AGP 8+)
- از پکیج‌های `discontinued` روی pub.dev پرهیز کن

## ۵) تغییر امضای متد
- همه call-siteها با امضای جدید
- پارامتر named اختیاری که در SDK پروژه وجود ندارد را اضافه نکن (مثال: `floatHeaderSlivers` اگر analyze رد کرد)

## آنچه لوکال در این محیط **نمی‌توان** چک کرد
- `flutter analyze` / `flutter test` / بیلد NDK واقعی → **نیاز به تأیید CI**
