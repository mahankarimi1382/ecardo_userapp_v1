# دسترس‌پذیری و localization QA

## منابع اصلی
- Flutter accessibility: https://docs.flutter.dev/ui/accessibility
- Flutter accessibility testing: https://docs.flutter.dev/ui/accessibility/accessibility-testing
- Flutter internationalization: https://docs.flutter.dev/ui/internationalization
- WCAG 2.2: https://www.w3.org/TR/WCAG22/

## معیارهای minimum
- Android tap targets حداقل راهنمای Flutter را رعایت کنند (معمولاً 48×48 logical pixels)؛ iOS مطابق راهنمای platform بررسی شود.
- contrast متن معمولی هدف 4.5:1؛ status فقط با رنگ منتقل نشود.
- تمام actionable widgets label/hint/value/selected state مناسب دارند.
- text scaling بالا، keyboard open، safe areas و orientation بررسی شود.
- TalkBack و VoiceOver روی جریان‌های مالی حیاتی بررسی شوند.
- RTL/LTR برای هر شش زبان واقعی پروژه؛ number/currency/date/phone/address و mixed-script تست شود.
- ترجمه‌ها placeholder و plural/select مطابق template هستند؛ رشتهٔ فارسی یا عربی هاردکد نشود.
- کاهش حرکت، focus واضح و keyboard navigation مناسب باشد.
