# راهنمای ادغام دیزاین‌سیستم

این سند برای ایجنت‌هایی است که کتابخانه‌ی `design_system` را در اسکرین‌ها ادغام می‌کنند. دقت کنید: امضای دقیق پارامترها حیاتی است — کدی که بنویسید باید **بدون خطای کامپایل** باشد.

## قوانین سخت (نقضشان کار را خراب می‌کند)

۱. **فقط فایل‌های قلمرو خودتان را ویرایش کنید.** مرجع: `FILE_OWNERSHIP.md`. اگر فایلی خارج از قلمروتان لازم دارید، متوقف شوید و گزارش دهید — دست نزنید.

۲. **`flutter test` را اجرا نکنید.** همه ایجنت‌ها روی یک working tree مشترک کار می‌کنند. یک تست موازی، تست ایجنت دیگر را می‌شکند و نتیجه گمراه‌کننده می‌شود. **فقط `flutter analyze` روی فایل‌های خودتان بزنید** — تست نهایی را من سریال می‌زنم.

۳. **`git checkout` / `git stash` ممنوع.** روی `main` هستیم و ۲۶۵+ فایل تغییرنشده متعلق به سه سشن دیگر روی دیسک است.

۴. **این فایل‌ها قفل‌شده‌اند و مال من (سشن دیزاین‌سیستم) هستند:** `app_colors.dart`، `app_spacing.dart`، `light_theme.dart`، `dark_theme.dart`، و کل `common/widgets/design_system/**`. اگر فکر می‌کنید یکی از این‌ها نیاز به تغییر دارد، گزارش دهید — خودم تغییرش می‌دهم.

۵. **منطق موجود را حفظ کنید.** سشن باگ‌فیکس قبلاً در `home_controller.dart`، `drawer_section.dart`، `user_profile_section.dart` و `splash_controller.dart` فیکس‌هایی اعمال کرده (null-safe بودن toastها، فیکس باگ Obx، پرامپت مجوز). این‌ها را بازنویسی نکنید.

## نکته‌ی پروژه درباره‌ی کاوش کد

پیش از خواندن فایل‌های سورس، طبق قانون پروژه ابتدا اجرا کنید:
```
graphify query "<سوال شما>"
```
`graphify-out/graph.json` وجود دارد و ۶۸٬۰۷۱ نود دارد. بعد از تغییر کد:
```
graphify update .
```

## API دقیق کامپوننت‌ها

همه از `package:ecardo_user/src/common/widgets/design_system/design_system.dart` import می‌شوند.

### `EcardoGlassCard` — StatefulWidget
```dart
const EcardoGlassCard({
  Key? key,
  required Widget child,          // تنها پارامتر اجباری
  double blur = 12.0,
  double borderRadius = AppSpacing.radiusLg,
  EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.lg),
  EdgeInsetsGeometry? margin,
  double? width,
  double? height,
  Color? backgroundColor,
  Gradient? borderGradient,
  double borderWidth = 1.2,
  Color? glowColor,
  Alignment glowAlignment = const Alignment(-0.8, -0.8),
  double glowRadius = 0.9,
  VoidCallback? onTap,
  VoidCallback? onLongPress,
  bool interactive = true,
  double pressedScale = 0.978,
  EcardoGlassVariant variant = EcardoGlassVariant.standard,  // standard|frosted|accent|neon|subtle
  List<BoxShadow>? shadows,
  Clip clipBehavior = Clip.antiAlias,
})
```
- `onTap` فقط وقتی اجرا می‌شود که `interactive == true` **و** onTap یا onLongPress غیر null باشد.
- blur با `BackdropFilter` کار می‌کند؛ روی پس‌زمینه‌ی ساده بی‌اثر است.

### `EcardoHeroAction` — مدل، نه ویجت
```dart
const EcardoHeroAction({
  required String label,
  required IconData icon,
  required VoidCallback onTap,
  Color? accentColor,
})
```

### `EcardoBalanceHero` — StatefulWidget
```dart
const EcardoBalanceHero({
  Key? key,
  required double amount,         // تنها پارامتر اجباری
  String currencyCode = 'USD',
  String? currencySymbol,
  List<String> availableCurrencies = const ['USD','USDT','EUR','IRT'],
  ValueChanged<String>? onCurrencyChanged,
  double? pnlPercentage,
  double? pnlAmount,
  String pnlPeriodLabel = '24h',
  String? secondaryEquivalent,
  String accountLabel = 'Total Balance',
  bool? isObscured,
  ValueChanged<bool>? onTogglePrivacy,
  int? decimalDigits,             // null → خودکار (۰ برای IRT/IRR، وگرنه ۲)
  bool showQuickActions = false,
  List<EcardoHeroAction>? actions,  // null → ۴ اکشن بی‌اثر پیش‌فرض
  VoidCallback? onTapBalance,
  EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
})
```
- لمس ناحیه‌ی مبلغ: اگر `onTapBalance` داده شود آن را صدا می‌زند، **وگرنه** privacy را toggle می‌کند.
- اگر `onTogglePrivacy` بدهید، باید `isObscured` را هم به‌روز کنید (کنترل‌شده است).

### `EcardoSwipeButton` — StatefulWidget
```dart
const EcardoSwipeButton({
  Key? key,
  required VoidCallback onSwipeComplete,
  String text = 'Swipe to Confirm',
  String? loadingText = 'Processing...',
  String? successText = 'Confirmed',
  Widget? icon,
  bool isLoading = false,
  bool isSuccess = false,
  bool enabled = true,
  double height = 58.0,
  double? width,
  double threshold = 0.85,
  Gradient? activeGradient,
  Color? trackColor,
  Color? thumbColor,
  Color? textColor,
  bool animateShimmer = true,
  EdgeInsetsGeometry? margin,
})
```
- `EcardoSwipeButtonState` عمومی است: `final k = GlobalKey<EcardoSwipeButtonState>(); k.currentState?.reset();`
- کنترل‌شده است؛ بعد از موفقیت باید خودتان `reset()` صدا بزنید.

### `EcardoReceiptStatus` — enum: `success` | `pending` | `failed`
### `EcardoReceiptItem` — مدل
```dart
const EcardoReceiptItem({
  required String label,
  String? value,
  double? amount,                 // اگر set شود value را بازنویسی می‌کند
  String? currency,
  int decimals = 2,
  bool isHighlighted = false,
  bool isCopyable = false,
  String? copyText,
  Color? valueColor,
  Widget? trailing,
})
```

### `EcardoDigitalReceipt` — StatefulWidget
```dart
const EcardoDigitalReceipt({
  Key? key,
  required String title,
  required String transactionReference,
  DateTime? timestamp,
  String? formattedTimestamp,
  double? primaryAmount,
  String? primaryCurrency,
  int primaryDecimals = 2,
  EcardoReceiptStatus status = EcardoReceiptStatus.success,
  List<EcardoReceiptItem> items = const [],
  String? note,                   // کپشن زیر جدول — حالا رندر می‌شود
  VoidCallback? onShare,
  VoidCallback? onDownload,
  bool showBarcode = true,
  bool showWatermark = true,
  String? watermarkText,
  EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.lg),
})
```

### `EcardoEmptyState` — StatefulWidget
```dart
const EcardoEmptyState({
  Key? key,
  required String title,
  required String description,
  IconData? iconData = Icons.account_balance_wallet_outlined,
  Widget? icon,
  Color? iconColor,
  Color? glowColor,
  String? primaryActionLabel,
  VoidCallback? onPrimaryAction,
  String? secondaryActionLabel,
  VoidCallback? onSecondaryAction,
  Widget? customIllustration,
  bool animateGlow = true,
  EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.xxl),
})
```
- هر CTA فقط وقتی رندر می‌شود که **هم برچسب و هم callback** غیر null باشد.

### `EcardoErrorView` — StatefulWidget
```dart
const EcardoErrorView({
  Key? key,
  String title = 'Unable to Complete Request',
  required String message,         // تنها پارامتر اجباری
  String? errorCode,
  VoidCallback? onRetry,           // null → دکمه اصلاً رندر نمی‌شود
  String retryLabel = 'Try Again',
  bool isRetrying = false,
  VoidCallback? onSecondaryAction,
  String? secondaryActionLabel,
  String? technicalDetails,        // آکاردئون «View Diagnostics»
  IconData iconData = Icons.wifi_off_rounded,
  Color? iconColor,
  bool animatePulse = true,
  EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.xxl),
})
```

## توکن‌های موجود

از `app_colors.dart`: `AppColors.deepBlack`, `warmWhite`, `mainSoftBlue`, `mutedBlue`, `softGray`, `white`, `error`, `success`, `warning`, و نسخه‌های `dark*` / `light*`.

از `app_spacing.dart`: `AppSpacing.xs`(4) `sm`(8) `md`(12) `lg`(16) `xl`(20) `xxl`(24)، شعاع‌ها `radiusSm`(8) `radiusMd`(12) `radiusLg`(16) `radiusFull`(999)، و `AppTextStyles` با `displayMedium`، `headlineSmall`، `headlineLarge`، `titleSmall/Medium/Large`، `bodySmall/Medium/Large`، `labelSmall/Medium/Large`.

**قاعده:** رنگ و فاصله‌ی هاردکد نکنید. از توکن‌ها استفاده کنید.

## تست اسکرین‌شات

هارنس آماده در `test/screenshot_harness.dart`:
```dart
import 'screenshot_harness.dart';

void main() {
  tearDown(resetHarness);
  testWidgets('<name> — light', (tester) async {
    await pumpScreen(tester, const MyScreen(), registrations: [
      () => registerController<MyController>(_TestMyController()),
      () => registerController<SettingsService>(_TestSettingsService()),
    ]);
    await capture(tester, 'my__light');
  });
}
```

سه دام که حتماً بخوانید:
- `Get.put(fake)` زیر **نوع subclass** ثبت می‌کند نه نوع پایه — حتماً `registerController<BaseType>(fake)` را صدا بزنید وگرنه `Get.find` می‌گوید «not found».
- کنترلرها باید subclass شوند و `onInit` خالی باشد تا شبکه صدا نزند (`GetxController.onInit` `@mustCallSuper` است — متد را کاملاً خالی بگذارید و super صدا نزنید).
- تصویر با `flutter test --update-goldens` ساخته می‌شود — ولی **این را شما نزنید**، من سریال می‌زنم. فقط تست را بنویسید.