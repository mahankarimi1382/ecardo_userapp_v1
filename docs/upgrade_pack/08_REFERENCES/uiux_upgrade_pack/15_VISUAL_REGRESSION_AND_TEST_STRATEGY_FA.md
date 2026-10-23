# راهبرد تست UI/UX و Visual Regression

## لایه‌های تست
1. Unit: formatter پول/تاریخ، state mapping، fee breakdown presentation، route guard و localization helpers.
2. Widget: هر component در حالت‌های default/loading/error/disabled/dark/RTL/large text.
3. Golden: صفحات حیاتی با mock controller و data deterministic؛ screenshot فقط presentation را ثابت می‌کند، صحت مالی را نه.
4. Integration: navigation/auth/session/transfer/exchange/cards/crypto deposit/receipt روی API mock یا staging کنترل‌شده.
5. E2E/emulator: APK Release، deep link، native permissions، keyboard, biometric/QR where applicable. برای native UI می‌توان Patrol را ارزیابی کرد؛ Flutter docs می‌گوید integration_test محدودیت تعامل با native UI دارد.
6. Accessibility: guideline tests + دستی screen reader/keyboard.
7. Performance: frame timing, memory, startup, scrolling و image cache.

## Golden naming
`<route_id>__<locale>__<theme>__<size>__<state>.png`
مثال: `wallet_detail__fa__light__small__loaded.png`.

## مهم
- از `DESIGN_SYSTEM_GUIDE.md` و `test/screenshot_harness.dart` واقعی مخزن استفاده کنید؛ قبل از ساخت harness موازی بررسی کنید که فعلی نیاز را پوشش می‌دهد یا خیر.
- baseline screenshots فقط بعد از تأیید دستی ذخیره شوند؛ update goldens برای سبز کردن CI کورکورانه انجام نشود.
- ترتیب تست‌ها سریالی بماند اگر policy جاری پروژه shared working tree را محدود کرده باشد.
- هر تغییر goldens باید همراه screenshot before/after و دلیل باشد.
- screenshot artifacts نباید PII، real account number، token، balance واقعی یا آدرس خصوصی داشته باشند.

## Gate
تمام routeهای P0 دارای widget+flow integration test؛ critical states دارای goldens در locale/themeهای هدف؛ صفر golden update بی‌توضیح؛ QA report لینک‌دار در PR.
