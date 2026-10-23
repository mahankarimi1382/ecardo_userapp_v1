# پرامپت ایجنت اصلی — eCardo UI/UX Convergence

مخزن: `https://github.com/mahankarimi1382/ecardo_userapp_v1`

هدف: ارتقای باقیماندهٔ صفحات و جریان‌های eCardo با الهام تحلیلی از XPay و محصولات مالی پیشرو، بدون کپی غیرمجاز و بدون خراب‌کردن logic/security فعلی.

## قوانین قطعی
- اول نسخهٔ checkout، `AGENTS.md`, `FILE_OWNERSHIP.md`, `DESIGN_SYSTEM_GUIDE.md`, `routes.dart` و design system موجود را بخوان.
- هیچ `git push`, tag, release, deploy یا تغییر production انجام نده.
- به‌طور پیش‌فرض route/navigation/state architecture را مهاجرت نده؛ XPay با GoRouter و mock data، اما eCardo با GetX و backend واقعی توصیف شده است.
- فایل‌های مشترک را بین agentها تقسیم owner-based کن. هیچ دو agent هم‌زمان یک فایل را ویرایش نکنند.
- اگر policy جاری repo تست/golden را سریالی می‌خواهد، agentها فقط تست متعلق به فایل خود را بنویسند و test suite/golden update را owner مرکزی اجرا کند.
- از UI-only success، fake values، fallback wallet/address و status guessed جلوگیری کن.

## Phase 0
ثبت SHA، tree status، route inventory دقیق، component inventory، screenshots baseline، test baseline و gap matrix؛ هیچ بازطراحی قبل از این.

## تقسیم تخصصی
A. Navigation + Home/Overview
B. Wallets/Accounts/Cards
C. Transfers/Exchange/Withdraw/Payments
D. Auth/Passcode/KYC/Security
E. Activity/Receipts/Notifications/Support
F. Localization/Accessibility (reviewer/implementer مجزا)
G. Visual tests + performance (owner تست مرکزی)

تقسیم بر اساس فایل‌ها و ownership مخزن باشد؛ این تقسیم مسئولیت محصولی است، نه اجازهٔ هم‌زمان تغییر shared tokens.

## روش هر task
1. قبل از کد، هدف UX و before screenshot ثبت کن.
2. فایل‌ها، route، controller/API, user state و حالات edge را شناسایی کن.
3. Spec کوچک بنویس: change, no-change, acceptance, tests, rollback.
4. از design tokens/components موجود استفاده کن.
5. کوچک‌ترین تغییر امن را اعمال کن؛ business logic مالی را در UI پیاده نکن.
6. تست مناسب و after screenshot ثبت کن.
7. `flutter analyze` و تست‌های مجاز طبق workflow مخزن اجرا شود.
8. وضعیت PASS/FAIL/BLOCKED و evidence ثبت شود.

## Deliverables
- `docs/uiux/BASELINE.md`
- `docs/uiux/PAGE_INVENTORY.csv`
- `docs/uiux/COMPONENT_GAP_MATRIX.csv`
- `docs/uiux/SCREEN_STATE_MATRIX.md`
- `docs/uiux/UX_DECISIONS.md`
- `docs/uiux/ACCESSIBILITY_LOCALE_REPORT.md`
- `docs/uiux/VISUAL_REGRESSION_REPORT.md`
- `docs/uiux/PERFORMANCE_BASELINE.md`
- `docs/uiux/RELEASE_UI_QA.md`

هر تسک باید route واقعی، owner، فایل‌ها، before/after، tests، evidence، ریسک باقی‌مانده و dependency داشته باشد. اگر API یا backend در دسترس نیست، `BLOCKED` بزن و fake success نساز.
