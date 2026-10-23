# ترتیب اجرا و موازی‌سازی

بک‌لاگ قابل مدیریت در `TASK_BACKLOG.csv` شامل 98 کار است. کارها قبل از شروع باید به Route IDها و فایل‌های واقعی bind شوند؛ عبارت `DISCOVERY_OR_PREVIOUS_TASK` placeholder dependency است، نه dependency نهایی.

## در چه ترتیبی اجرا شود

1. `P0-BASELINE` و `P1-DISCOVERY` به‌صورت ترتیبی؛ بدون baseline، agentها نباید فایل تولیدی اپ را بازنویسی کنند.
2. `P2-CONTRACTS` پیش از اصلاح cross-module؛ قراردادهای مالی و state/status توسط integrator و owner حوزه تأیید شوند.
3. `P3-FOUNDATION` با مالکیت فایل مشخص؛ تغییر global network/state/shared UI بدون handoff ممنوع.
4. `P4-MONEY`, `P5-WALLET-CARD-CRYPTO`, `P6-AUTH-OPS` را بر اساس dependency واقعی تقسیم کن؛ از تغییر موازی فایل مشترک transaction/money/router خودداری کن.
5. `P7-UX` پس از page inventory و design token sign-off، اما با contract و stateهای backend هماهنگ.
6. `P8-QUALITY` از ابتدای کار طراحی شود اما final runs فقط طبق دستورالعمل پروژه توسط integrator انجام شود.
7. `P9-SEC-PERF` و `P10-FINAL` برای اثبات صحت و پوشش و گزارش نهایی.

## قوانین اجرای Agent

- هر task file allowlist، outcome و acceptance criteria مستقل داشته باشد.
- قبل از edit گراف را query کن؛ بعد از تغییر گراف را با دستور واقعی پروژه update کن.
- حداکثر یک owner هم‌زمان برای `router`, money primitives, global Dio interceptor, shared design tokens, themes, shared test fixtures و goldens داشته باش.
- کارهای read-only را می‌توان موازی کرد؛ تغییرات با dependency مشترک فقط بعد از handoff.
- به هیچ عامل اجازه نده `DONE` را بدون command output و evidence ثبت کند.
- هیچ agent با کاربر test data واقعی، secret یا عملیات financial live کار نکند.
