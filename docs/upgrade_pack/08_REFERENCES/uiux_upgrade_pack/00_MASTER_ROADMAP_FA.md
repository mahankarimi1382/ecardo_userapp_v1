# نقشه راه جامع UI/UX برای eCardo

## چشم‌انداز
ساخت یک تجربهٔ مالی ممتاز، قابل‌فهم، سریع، چندزبانه و قابل‌اعتماد که در همهٔ صفحات از منطق یکپارچه استفاده کند. معیار کیفیت صرفاً زیبایی صفحه نیست؛ کاربر باید بتواند عمل درست را با اطمینان انجام دهد، هزینه و نتیجه را پیش از تأیید بفهمد و پس از خطا راه امن بازیابی داشته باشد.

## نتیجه بررسی اولیه
- مخزن عمومی eCardo یک اپ Flutter با معماری Feature-driven/GetX، حدود ۹۹ route اعلام‌شده، baseline طراحی ScreenUtil حدود 376×812 و سیستم طراحی اختصاصی دارد.
- `DESIGN_SYSTEM_GUIDE.md` از توکن‌های `AppColors` و `AppSpacing` و کامپوننت‌هایی مانند `EcardoBalanceHero`, `EcardoSwipeButton`, `EcardoDigitalReceipt`, `EcardoEmptyState` و `EcardoErrorView` یاد می‌کند؛ همچنین harness اسکرین‌شات در `test/screenshot_harness.dart` را معرفی می‌کند.
- XPay UI Kit طبق صفحه رسمی ۴۴ صفحه، ۱۴ ماژول، ۳۵+ route، Light/Dark، و مجموعه‌ای از onboarding، dashboard، account، transfer, request, QR, exchange, cards, budget, invoice, rewards و settings دارد. همان منبع صریحاً می‌گوید dataها mock هستند، QR واقعی نیازمند اتصال است و biometric toggle فقط UI است. بنابراین آن را به‌عنوان چک‌لیست پوشش و الگوی بصری ارزیابی می‌کنیم؛ نه محصول آمادهٔ production.
- اعداد نسخه، تست و route باید از checkout/CI همان SHA استخراج شوند؛ اعداد README یا گزارش‌های قدیمی را baseline قطعی ندانید.

## اصول برنامه
1. **Audit قبل از Redesign:** route، اسکرین، state، endpoint، controller، test و owner هر صفحه ثبت شوند.
2. **Preserve eCardo identity:** هویت فعلی را حفظ و سلسله‌مراتب، وضوح، سازگاری و ergonomics را ارتقا دهید؛ کل اپ را به یک قالب دیگر تبدیل نکنید.
3. **Reuse before add:** از design system موجود استفاده کنید. package یا design system جدید فقط با ADR، تست compatibility و مجوز اضافه شود.
4. **Real data states:** هر route باید حالت loading, stale, empty, error, offline, permission denied, pending, success و retry مختص خودش را تعریف کند.
5. **Financial truth:** UI منبع حقیقت مبلغ، وضعیت تراکنش، fee، eligibility یا crypto address نیست.
6. **Locale parity:** فارسی، عربی، انگلیسی، چینی، ترکی و روسی از لحاظ محتوا، RTL/LTR، عدد، تاریخ، پول و شکست layout برابر بررسی شوند.
7. **Evidence-based Done:** هر ادعای تکمیل باید به screenshot/golden، تست، لاگ یا PR متصل باشد.

## فازها
### Phase 0 — Freeze & inventory (روز 1–5)
- ثبت SHA، وضعیت tree و route inventory واقعی.
- گرفتن baseline screenshots از تمام routeهای کاربرمحور و stateهای حیاتی.
- ساخت heatmap شدت/فراوانی/ریسک برای هر صفحه.
- ثبت design tokens/components موجود و componentهای تکراری/متناقض.
- خروجی: `docs/uiux/BASELINE.md`, `PAGE_INVENTORY.csv`, `VISUAL_BASELINE.md`.

### Phase 1 — Core interaction & tokens (روز 6–14)
- تثبیت spacing/type/color/radius/elevation/motion tokens بدون تغییر سلیقه‌ای گسترده.
- اصلاح tap target، focus، keyboard insets، safe areas، error text و dynamic type.
- componentهای وضعیت عمومی و فرم‌های مالی را یکسان کنید.
- پوشش Home, Wallet, Transaction Detail, Transfer Review را به‌عنوان pilot تکمیل کنید.

### Phase 2 — Money movement (روز 15–30)
- Transfer, Exchange, Withdraw, Cash Out, Make Payment, Gift, bills، QR و receipt.
- Quote، fees، beneficiary، funding source، limits، passcode، idempotency message، pending/reconciliation و recover-from-timeout.
- widget + integration tests برای هر جریان.

### Phase 3 — Accounts, cards & crypto (روز 31–50)
- account list/detail, card list/detail/creation, card funding, wallet switch, crypto deposit/withdraw/address QR.
- عدم نمایش address/provider/network/fee با defaultهای محلی برای عملیات واقعی.
- stateهای unsupported/ineligible/maintenance/limit exceeded.

### Phase 4 — Auth, safety, support & long tail (روز 51–70)
- OTP, passcode, biometric, session expired, KYC, profile, language/theme, privacy, help, tickets, notifications, rewards.
- بهبود navigation/deep links و state persistence.

### Phase 5 — localization & accessibility convergence (روز 71–90)
- stress-test همهٔ شش زبان و فونت بزرگ، RTL/LTR، TalkBack/VoiceOver، contrast و keyboard.
- screenshot matrix device×locale×theme برای pages حساس.

### Phase 6 — instrumented UX & performance (روز 91–120)
- رویدادهای UX privacy-safe، funnel completion، abandonment و error recovery.
- cold start/frame timings، jank، image memory، rebuilds و navigation latency.
- فقط مشکلات قابل‌اندازه‌گیری بهینه شوند؛ animation و effects هرگز مالیات performance نباشند.

### Phase 7 — usability validation & release gates (روز 121–180)
- تست کاربردپذیری وظیفه‌محور با کاربران هدف در بازارهای هدف.
- visual regression, accessibility regression, performance regression و E2E روی APK release.
- rollout کنترل‌شده و گزارش post-release؛ release به تأیید صریح وابسته بماند.

## فهرست صفحات/ماژول‌های پوشش
Home/dashboard; wallet/account portfolio; account detail; wallet creation/selection; local & external transfers; requests/P2P; exchange; deposit/withdraw/cash-out; payment/merchant; card list/detail/create/funding; crypto deposit/withdraw; transaction activity/detail/receipt; QR/payments; bills; travel/commercial services; auth/session; KYC/profile; security; notifications; rewards; settings; help/tickets; legal/privacy; accessibility and error/recovery states. نام دقیق routeها فقط از `routes.dart` و UI registry محلی استخراج شود.

## معیارهای outcome پیشنهادی
- 100% صفحات حیاتی دارای owner، route ID، API dependency، screen-state matrix و تست.
- 0 known P0/P1 visual/interaction blockers قبل از Release.
- 100% صفحات حیاتی در RTL/LTR و light/dark آزمایش شده باشند.
- 100% عملیات مالی وضعیت backend-confirmed و pending/failure واضح داشته باشند.
- نرخ تکمیل وظیفه و زمان انجام با baseline اندازه‌گیری و سپس هدف‌گذاری شود؛ پیش از measurement عدد تبلیغاتی اعلام نشود.
- هیچ رنگ، متن یا animationی به‌تنهایی حامل پیام وضعیت مالی نباشد.
